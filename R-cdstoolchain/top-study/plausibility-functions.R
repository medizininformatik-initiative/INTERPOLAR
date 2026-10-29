# Independent SQL checks; only aggregates are written to the public report.
modelCodes <- function(entity) {
  collect <- function(codes) {
    unlist(lapply(codes, function(code) c(code$code, collect(code$children))), use.names = FALSE)
  }
  unique(collect(entity$codes))
}

sqlList <- function(values) paste(quoteSql(values), collapse = ", ")

# Group contacts independently of scopeSql's window function for the cohort check.
auditPopulationSql <- function(periods) {
  period_values <- paste(sprintf(
    "(%s, DATE %s, DATE %s)", quoteSql(periods$ward_name), quoteSql(periods$start), quoteSql(periods$end)
  ), collapse = ",")
  paste0("WITH periods(ward, start_date, end_date) AS (VALUES ", period_values, "),
  hospitals AS (
    SELECT e.enc_id, MIN(e.enc_period_start) AS hospital_start,
      BOOL_OR(p.pat_id IS NOT NULL) AS has_patient,
      CASE WHEN COUNT(DISTINCT p.pat_gender)=1 AND MIN(p.pat_gender) IN ('male','female')
        THEN MIN(p.pat_gender) ELSE 'unknown_or_conflicting' END AS sex
    FROM db2dataprocessor_out.v_encounter_last_version e
    LEFT JOIN db2dataprocessor_out.v_patient_last_version p ON e.enc_patient_ref='Patient/'||p.pat_id
    WHERE e.enc_type_code='einrichtungskontakt' GROUP BY e.enc_id
  ), contacts AS MATERIALIZED (
    SELECT DISTINCT e.enc_main_encounter_calculated_ref AS case_ref, e.enc_period_start AS start_time, w.ward_name
    FROM db2dataprocessor_out.v_pids_per_ward w
    JOIN db2dataprocessor_out.v_encounter_last_version e ON e.enc_id=w.encounter_id
  ), first_starts AS (
    SELECT case_ref, MIN(start_time) AS first_ip_start FROM contacts GROUP BY case_ref
  ), cohort AS MATERIALIZED (
    SELECT h.*, f.first_ip_start, c.ward_name, p.start_date, p.end_date,
      CASE WHEN f.first_ip_start IS NULL THEN 'no_resolvable_ip_contact'
           WHEN p.ward IS NULL THEN 'unknown_ward'
           WHEN f.first_ip_start < p.start_date THEN 'before_study'
           WHEN f.first_ip_start >= p.end_date THEN 'after_study'
           WHEN NOT h.has_patient THEN 'within_study_missing_patient'
           ELSE 'selected' END AS selection
    FROM hospitals h
    LEFT JOIN first_starts f ON f.case_ref='Encounter/'||h.enc_id
    LEFT JOIN contacts c ON c.case_ref=f.case_ref AND c.start_time=f.first_ip_start
    LEFT JOIN periods p ON p.ward=c.ward_name
  ), selected AS MATERIALIZED (SELECT * FROM cohort WHERE selection='selected')")
}

# Translate only the simple laboratory definitions used by anaemia 1 and its grades.
# Unexpected structures fail visibly instead of silently approximating a new model.
anaemiaExpression <- function(expression, entities, valid_units = FALSE) {
  if (!is.null(expression$entityId)) {
    entity <- entities[[expression$entityId]]
    if (is.null(entity)) stop("Anämie-Modell: referenzierter Phänotyp fehlt.")
    if (!is.null(entity$expression)) return(anaemiaExpression(entity$expression, entities, valid_units))
    restriction <- entity$restriction
    if (is.null(restriction) || restriction$quantifier != "min" || restriction$cardinality != 1) {
      stop("Anämie-Modell: unerwartete Laborrestriktion.")
    }
    parent <- entities[[entity$superPhenotype$id]]
    if (identical(restriction$type, "string") && "46098-0" %in% modelCodes(parent)) {
      if (!all(unlist(restriction$values) %in% c("male", "female"))) stop("Unbekannte Geschlechtsbedingung.")
      return(paste0("s.sex IN (", sqlList(unlist(restriction$values)), ")"))
    }
    if (!identical(restriction$type, "number") || is.null(parent$unit)) stop("Unbekannte Laborbedingung.")
    parts <- paste0("o.analysis_loinc_code IN (", sqlList(modelCodes(parent)), ")")
    for (bound in c("min", "max")) {
      operator <- restriction[[paste0(bound, "Operator")]]
      if (!is.null(operator)) {
        if (!operator %in% c("<", "<=", ">", ">=")) stop("Unbekannter Vergleichsoperator.")
        value <- restriction$values[[if (bound == "min") 1 else 2]]
        if (!is.numeric(value) || !is.finite(value)) stop("Ungültiger Laborgrenzwert.")
        parts <- c(parts, paste("o.analysis_value", operator, format(value, scientific = FALSE, trim = TRUE)))
      }
    }
    if (valid_units) {
      # Exact unit labels are deliberately conservative; unmatched labels require local review.
      parts <- c(
        parts, paste0("o.analysis_unit=", quoteSql(parent$unit)),
        "o.analysis_value_status IN ('converted','already_reference_unit')"
      )
    }
    return(paste0("(", paste(parts, collapse = " AND "), ")"))
  }
  operator <- switch(
    expression$functionId,
    And = " AND ",
    Or = " OR ",
    NULL
  )
  if (is.null(operator) || !length(expression$arguments)) stop("Anämie-Modell: unerwarteter Ausdruck.")
  paste0("(", paste(vapply(expression$arguments, anaemiaExpression, character(1),
    entities = entities, valid_units = valid_units
  ), collapse = operator), ")")
}

readTopCaseIds <- function(path) {
  if (!file.exists(path)) stop("TOP-Ergebnis für Kontrollvergleich fehlt: ", basename(path))
  header <- names(utils::read.csv(unz(path, "data_subjects.csv"), sep = ";", nrows = 0, check.names = FALSE))
  if (!length(header) || header[1] != "Id") stop("Unerwartetes TOP-CSV-Format.")
  result <- utils::read.csv(unz(path, "data_subjects.csv"),
    sep = ";", check.names = FALSE,
    colClasses = c("character", rep("NULL", length(header) - 1))
  )
  unique(result$Id)
}

runPlausibility <- function(con, periods, out, logProgress) {
  report <- file.path(out, "plausibility.txt")
  writeLines(c(
    "Aggregierte Standortprüfung. Bezugsgröße sind Krankenhausfälle, nicht Personen.",
    "Die Fallauswahl verlangt den ersten auflösbaren IP-Kontakt im Stations-Studienzeitraum.",
    "TOP verwendet anschließend die Daten des gesamten ausgewählten Krankenhausfalls.",
    "Fehlende Daten und nicht bestätigte Einheiten sind keine negativen klinischen Befunde.",
    "Tabellenzeilen können sich bei Laborcodes, Fehlermerkmalen und Befundzeiten überschneiden.",
    "not_declared: Das Modell nennt für diesen Laborparameter keine Einheit. Alter wird aus Encounter-Daten bezogen und nicht als Laborwert gezählt."
  ), report)
  section <- function(title, data) {
    cat("\n", title, "\n", file = report, append = TRUE, sep = "")
    if (is.null(data) || !nrow(data)) {
      cat("Keine Einträge.\n", file = report, append = TRUE)
      return(invisible(NULL))
    }
    connection <- file(report, open = "a")
    on.exit(close(connection))
    utils::write.table(data, connection,
      sep = "\t", quote = FALSE, row.names = FALSE,
      col.names = TRUE, na = "nicht_verfügbar"
    )
  }
  query <- function(sql) DBI::dbGetQuery(con, sql)
  population <- auditPopulationSql(periods)
  logProgress("Fallauswahl unabhängig nachzählen.")
  section("FALLAUSWAHL NACH ERSTER IP-STATION (Studienende exklusiv)", query(paste0(population, "
    SELECT ward_name, start_date, end_date, selection, COUNT(*) AS cases,
      COUNT(*) FILTER (WHERE hospital_start < start_date) AS hospital_admission_before_study
    FROM cohort GROUP BY ward_name, start_date, end_date, selection
    ORDER BY ward_name, selection")))
  population_check <- query(paste0(population, ", adapter_cases AS (", scopeSql(periods), "
    SELECT enc_id FROM eligible_cases)
    SELECT (SELECT COUNT(*) FROM selected) AS independent_cases,
      (SELECT COUNT(*) FROM adapter_cases) AS adapter_cases,
      (SELECT COUNT(*) FROM selected s WHERE NOT EXISTS (SELECT 1 FROM adapter_cases a WHERE a.enc_id=s.enc_id)) AS independent_only,
      (SELECT COUNT(*) FROM adapter_cases a WHERE NOT EXISTS (SELECT 1 FROM selected s WHERE s.enc_id=a.enc_id)) AS adapter_only"))
  section("ABGLEICH DER FALLAUSWAHL", population_check)
  if (population_check$independent_only != 0 || population_check$adapter_only != 0) {
    stop("Unabhängige Fallauswahl stimmt nicht mit dem Adapter überein.")
  }
  models <- lapply(list.files(file.path(out, "models"), pattern = "[.]json$", full.names = TRUE), function(path) {
    list(name = tools::file_path_sans_ext(basename(path)), entities = jsonlite::read_json(path))
  })
  inputs <- do.call(rbind, lapply(models, function(model) {
    do.call(rbind, lapply(model$entities, function(entity) {
      codes <- setdiff(modelCodes(entity), "29553-5")
      systems <- vapply(entity$codes, function(code) code$codeSystem$uri, character(1))
      if (!identical(entity$dataType, "number") || !length(codes) || !all(systems == "http://loinc.org")) return(NULL)
      unit <- if (is.null(entity$unit) || !nzchar(entity$unit)) "not_declared" else entity$unit
      data.frame(model = model$name, code = codes, expected_unit = unit)
    }))
  }))
  inputs <- unique(inputs)
  if (is.null(inputs) || !nrow(inputs)) stop("Keine Laborparameter in TOP-Modellen gefunden.")
  values <- paste(sprintf("(%s,%s,%s)", quoteSql(inputs$model), quoteSql(inputs$code), quoteSql(inputs$expected_unit)), collapse = ",")
  observations <- paste0(population, ", model_inputs(model,code,expected_unit) AS (VALUES ", values, "),
    observations AS MATERIALIZED (
      SELECT s.enc_id, o.analysis_loinc_code, o.analysis_unit, o.analysis_value_status,
        o.analysis_value, o.obs_effectivedatetime
      FROM selected s JOIN db2dataprocessor_out.v_observation_last_version o
        ON o.obs_encounter_calculated_ref='Encounter/'||s.enc_id
      WHERE EXISTS (SELECT 1 FROM model_inputs i WHERE i.code=o.analysis_loinc_code)
    )")
  logProgress("Laborabdeckung, Einheiten und Umrechnungsstatus zählen.")
  section("LABORABDECKUNG (Modellparameter, auch wenn nicht jeder Algorithmus sie verwendet)", query(paste0(observations, "
    SELECT i.model, i.code AS analysis_loinc_code, i.expected_unit,
      COUNT(DISTINCT o.enc_id) AS cases_with_rows,
      COUNT(DISTINCT o.enc_id) FILTER (WHERE o.analysis_value IS NOT NULL) AS cases_with_nonnull_values,
      COUNT(DISTINCT o.enc_id) FILTER (WHERE o.analysis_value IS NOT NULL AND o.analysis_unit=i.expected_unit
        AND o.analysis_value_status IN ('converted','already_reference_unit')) AS cases_with_confirmed_unit
    FROM model_inputs i LEFT JOIN observations o ON o.analysis_loinc_code=i.code
    GROUP BY i.model,i.code,i.expected_unit ORDER BY i.model,i.code,i.expected_unit")))
  # Report unit/status categories only, no individual values or timestamps.
  section("LABOR-EINHEITEN UND KONVERTIERUNG", query(paste0(observations, "
    SELECT analysis_loinc_code, analysis_unit, analysis_value_status,
      COUNT(*) AS rows, COUNT(DISTINCT enc_id) AS cases,
      COUNT(*) FILTER (WHERE analysis_value IS NOT NULL) AS nonnull_values
    FROM observations GROUP BY analysis_loinc_code,analysis_unit,analysis_value_status
    ORDER BY analysis_loinc_code,analysis_unit,analysis_value_status")))
  section("MÖGLICHE MESSWERTDUBLETTEN (gleicher Fall, Code, Zeitpunkt, Wert und Einheit; kein Beweis einer Dublette)", query(paste0(observations, ", duplicates AS (
    SELECT enc_id, analysis_loinc_code, obs_effectivedatetime, analysis_value, analysis_unit, COUNT(*) AS n
    FROM observations WHERE analysis_value IS NOT NULL AND obs_effectivedatetime IS NOT NULL
    GROUP BY enc_id,analysis_loinc_code,obs_effectivedatetime,analysis_value,analysis_unit HAVING COUNT(*)>1
  ) SELECT analysis_loinc_code, COUNT(*) AS duplicate_groups, SUM(n-1) AS extra_rows,
    COUNT(DISTINCT enc_id) AS affected_cases FROM duplicates GROUP BY analysis_loinc_code ORDER BY analysis_loinc_code")))
  anaemia <- Filter(function(model) model$name == "anaemia", models)
  if (length(anaemia) != 1) stop("Anämie-Modell für die Standortprüfung fehlt.")
  entities <- setNames(anaemia[[1]]$entities, vapply(anaemia[[1]]$entities, function(x) x$id, character(1)))
  algorithm_ids <- c(
    "f4774c29-6210-4c70-bcf2-8cc6b66e5f9b", "03b2c335-3656-4629-96f2-62390592b160",
    "8fd0d50c-2fb7-4cb7-980f-c814fd15f229", "dbc2c1af-2280-4691-b372-0ea320534937"
  )
  expressions <- vapply(algorithm_ids, function(id) anaemiaExpression(list(entityId = id), entities), character(1))
  valid_expressions <- vapply(algorithm_ids, function(id) anaemiaExpression(list(entityId = id), entities, TRUE), character(1))
  hb_codes <- unique(unlist(lapply(entities, function(x) if (!is.null(x$unit)) modelCodes(x))))
  control_columns <- paste(c(
    sprintf("COALESCE(BOOL_OR(%s),FALSE) AS a%s", expressions, seq_along(expressions)),
    sprintf("COALESCE(BOOL_OR(%s),FALSE) AS valid_a%s", valid_expressions, seq_along(expressions))
  ), collapse = ",\n")
  logProgress("Anämie-Regeln unabhängig auswerten und mit lokalen TOP-Ergebnissen vergleichen.")
  controls <- query(paste0(population, "
    SELECT s.enc_id, s.sex, COUNT(o.obs_id) AS hb_rows,
      COUNT(o.analysis_value) AS hb_values, ", control_columns, ",
      COALESCE(BOOL_OR((", expressions[1], ") AND o.obs_effectivedatetime < s.first_ip_start),FALSE) AS positive_before_first_ip,
      COALESCE(BOOL_OR((", expressions[1], ") AND o.obs_effectivedatetime >= s.first_ip_start),FALSE) AS positive_from_first_ip,
      COALESCE(BOOL_OR((", expressions[1], ") AND o.obs_effectivedatetime >= s.end_date),FALSE) AS positive_after_study,
      COALESCE(BOOL_OR((", expressions[1], ") AND o.obs_effectivedatetime IS NULL),FALSE) AS positive_without_time
    FROM selected s LEFT JOIN db2dataprocessor_out.v_observation_last_version o
      ON o.obs_encounter_calculated_ref='Encounter/'||s.enc_id AND o.analysis_loinc_code IN (", sqlList(hb_codes), ")
    GROUP BY s.enc_id,s.sex"))
  coverage <- do.call(rbind, lapply(split(controls, controls$sex), function(rows) {
    data.frame(
      sex = rows$sex[1], cases = nrow(rows), with_hb_values = sum(rows$hb_values > 0),
      without_hb_values = sum(rows$hb_values == 0), positive_algorithm_1 = sum(rows$a1),
      positive_with_confirmed_units = sum(rows$valid_a1),
      positive_before_first_ip = sum(rows$positive_before_first_ip), positive_from_first_ip = sum(rows$positive_from_first_ip),
      positive_after_study = sum(rows$positive_after_study), positive_without_time = sum(rows$positive_without_time)
    )
  }))
  section("ANÄMIE: DATENABDECKUNG UND ZEITLICHE LAGE POSITIVER BEFUNDE (Fallzahlen, Zeitgruppen überlappen)", coverage)
  for (index in seq_along(algorithm_ids)) {
    id <- algorithm_ids[index]
    top <- readTopCaseIds(file.path(out, "results", paste0("anaemia_", id, ".zip")))
    expected <- controls$enc_id[controls[[paste0("a", index)]]]
    valid <- controls$enc_id[controls[[paste0("valid_a", index)]]]
    name <- Filter(function(t) t$lang == "de", entities[[id]]$titles)[[1]]$text
    section(paste("ANÄMIE-KONTROLLVERGLEICH:", name), data.frame(
      comparison_status = if (setequal(top, expected)) "match" else "difference",
      both_positive = length(intersect(top, expected)), top_only = length(setdiff(top, expected)),
      control_only = length(setdiff(expected, top)), both_negative = sum(!controls$enc_id %in% union(top, expected)),
      top_outside_study_cases = length(setdiff(top, controls$enc_id)),
      control_positive_without_confirmed_unit = length(setdiff(expected, valid))
    ))
  }
  exclusion <- entities[["9dc14968-d483-4987-9a7a-46c0601b29e1"]]
  exclusion_codes <- modelCodes(exclusion)
  # Same ICD category semantics, expressed independently of the adapter query.
  exclusion_codes <- unique(regmatches(
    exclusion_codes,
    regexpr("^[A-Z][0-9]{2}(\\.[0-9]{1,2})?", exclusion_codes)
  ))
  if (!length(exclusion_codes)) stop("Anämie-Ausschlussdefinition fehlt.")
  excluded <- query(paste0(population, "
    SELECT DISTINCT s.enc_id FROM selected s
    JOIN db2dataprocessor_out.v_condition_last_version c ON c.con_encounter_calculated_ref='Encounter/'||s.enc_id
    WHERE c.con_code_system='http://fhir.de/CodeSystem/bfarm/icd-10-gm'
      AND (LEFT(c.con_code_code,3) IN (", sqlList(exclusion_codes), ")
        OR LEFT(c.con_code_code,5) IN (", sqlList(exclusion_codes), ")
        OR LEFT(c.con_code_code,6) IN (", sqlList(exclusion_codes), "))"))$enc_id
  all_anaemia <- Filter(function(entity) identical(entity$entityType, "composite_phenotype") &&
    identical(entity$dataType, "boolean"), entities)
  section(
    "ANÄMIE: AUSSCHLUSSDIAGNOSEN UND FEHLENDE LABORNACHWEISE (Diagnosen werden hier nur gezählt, nicht ausgeschlossen)",
    do.call(rbind, lapply(all_anaemia, function(entity) {
      top <- readTopCaseIds(file.path(out, "results", paste0("anaemia_", entity$id, ".zip")))
      hits <- controls[controls$enc_id %in% top, , drop = FALSE]
      data.frame(
        algorithm = Filter(function(t) t$lang == "de", entity$titles)[[1]]$text,
        top_cases = length(top), with_exclusion_diagnosis = sum(top %in% excluded),
        without_hb_values = sum(hits$hb_values == 0), with_hb_but_negative_algorithm_1 = sum(hits$hb_values > 0 & !hits$a1),
        unknown_or_conflicting_sex = sum(hits$sex == "unknown_or_conflicting")
      )
    }))
  )
  # Extract only numerical rules for interpretation; the complete metadata stays local.
  limits <- do.call(rbind, lapply(entities, function(entity) {
    r <- entity$restriction
    if (is.null(r) || !identical(r$type, "number")) return(NULL)
    parent <- entities[[entity$superPhenotype$id]]
    data.frame(
      criterion = Filter(function(t) t$lang == "de", entity$titles)[[1]]$text,
      unit = if (is.null(parent$unit)) "not_declared" else parent$unit, lower = if (is.null(r$minOperator)) "" else paste(r$minOperator, r$values[[1]]),
      upper = if (is.null(r$maxOperator)) "" else paste(r$maxOperator, r$values[[2]])
    )
  }))
  utils::write.table(limits, file.path(out, "model-limits.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
  cat("\nPrüfung abgeschlossen. comparison_status=match bedeutet gleiche Fallmengen; difference erfordert lokale Prüfung.\nEinheitenbestätigung verlangt exakt die Modelleinheit und Status converted oder already_reference_unit; andere Einträge sind ungeprüft, nicht automatisch falsch.\nDie Modellgrenzen stehen lokal in model-limits.tsv; ihre Laborbestätigung bleibt erforderlich.\n",
    file = report, append = TRUE
  )
  logProgress("Aggregierte Plausibilitätsprüfung abgeschlossen.")
}
