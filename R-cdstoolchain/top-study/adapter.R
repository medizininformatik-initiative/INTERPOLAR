# Generate scoped TOP adapters from the image template and INTERPOLAR configuration.
readPeriods <- function(path) {
  config <- etlutils::readTomlAsNamedList(path)
  definitions <- config[grepl("^PHASES_WARD_", names(config))]
  if (!length(definitions)) stop("Keine PHASES_WARD-Einträge gefunden.")
  records <- etlutils::parseStructuredConfigDefinitions(
    list(definitions), "ward_name|phase_a_start|phase_b_start|phase_b_end|department|ward_type", FALSE
  )
  rows <- lapply(names(definitions), function(name) {
    values <- Filter(function(x) identical(x$entry_name, name), records)
    getValue <- function(key) {
      found <- Filter(function(x) identical(x$key, key), values)
      if (length(found) != 1L || !nzchar(trimws(found[[1]]$value))) {
        stop(paste(name, ": genau eine Angabe für", key, "erforderlich."))
      }
      found[[1]]$value
    }
    start <- etlutils::parseTimestamp(getValue("phase_a_start"), timezone = "Europe/Berlin")
    end <- etlutils::parseTimestamp(getValue("phase_b_end"), timezone = "Europe/Berlin")
    # Use the local calendar date; do not convert midnight via UTC.
    start <- as.Date(format(start, "%Y-%m-%d", tz = "Europe/Berlin"))
    end <- as.Date(format(end, "%Y-%m-%d", tz = "Europe/Berlin"))
    if (is.na(start) || is.na(end) || start >= end) stop(paste(name, ": ungültiger Studienzeitraum."))
    data.frame(ward_name = getValue("ward_name"), start = as.character(start), end = as.character(end))
  })
  periods <- do.call(rbind, rows)
  if (anyDuplicated(periods$ward_name)) stop("Stationsnamen sind mehrfach konfiguriert.")
  periods
}

quoteSql <- function(value) paste0("'", gsub("'", "''", value, fixed = TRUE), "'")

scopeSql <- function(periods, remaining = FALSE) {
  values <- paste(sprintf(
    "(%s, DATE %s, DATE %s)", quoteSql(periods$ward_name),
    quoteSql(periods$start), quoteSql(periods$end)
  ), collapse = ",\n    ")
  paste0("WITH study_periods(ward_name, study_start, study_end) AS (\n  VALUES ", values, "
), ip_contacts AS (
  SELECT e.enc_main_encounter_calculated_ref AS case_ref,
         e.enc_period_start AS ward_start, w.ward_name,
         -- Find the first IP contact BEFORE applying the study period.
         MIN(e.enc_period_start) OVER (
           PARTITION BY e.enc_main_encounter_calculated_ref
         ) AS first_ip_start
  FROM db2dataprocessor_out.v_encounter_last_version e
  JOIN (SELECT DISTINCT encounter_id, ward_name
        FROM db2dataprocessor_out.v_pids_per_ward) w ON w.encounter_id = e.enc_id
), study_cases AS (
  SELECT DISTINCT c.case_ref
  FROM ip_contacts c JOIN study_periods s ON s.ward_name = c.ward_name
  WHERE c.ward_start = c.first_ip_start
    -- Inclusive start and exclusive end, at local midnight.
    AND c.first_ip_start >= s.study_start AND c.first_ip_start < s.study_end
), eligible_cases AS (
  SELECT DISTINCT h.enc_id
  FROM db2dataprocessor_out.v_encounter_last_version h
  WHERE h.enc_type_code = 'einrichtungskontakt'
    AND EXISTS (SELECT 1 FROM db2dataprocessor_out.v_patient_last_version p
                WHERE h.enc_patient_ref = 'Patient/' || p.pat_id)
    -- NOT EXISTS gives the exact complement, including cases without IP contacts.
    AND ", if (remaining) "NOT " else "", "EXISTS (
      SELECT 1 FROM study_cases s WHERE s.case_ref = 'Encounter/' || h.enc_id
    )
)")
}

# Preserve all original restriction fragments by appending the population predicate
# to the original WHERE. The population CTE is nested in IN, avoiding WITH collisions.
makeAdapter <- function(original, condition, periods, remaining = FALSE) {
  adapter <- original
  expected <- c(
    "encounter", "observation", "condition", "procedure", "medication",
    "medication_administration", "medication_statement", "medication_request"
  )
  if (!setequal(names(adapter$phenotypeQueries), expected)) stop("Unbekannte TOP-Abfragestruktur.")
  adapter$phenotypeQueries$condition <- condition
  expressions <- c(
    encounter = "enc_id", observation = "un.enc_id",
    condition = "SUBSTRING(con.con_encounter_calculated_ref FROM 11)",
    procedure = "SUBSTRING(proc.proc_encounter_calculated_ref FROM 11)",
    medication_administration = "SUBSTRING(medadm.medadm_encounter_calculated_ref FROM 11)",
    medication_statement = "SUBSTRING(medstat.medstat_encounter_calculated_ref FROM 11)",
    medication_request = "SUBSTRING(medreq_encounter_calculated_ref FROM 11)"
  )
  extend <- function(query, expression) {
    if (
      is.null(query) || !grepl("WHERE", query, fixed = TRUE) ||
      grepl(";", gsub("--[^\n]*", "", query), fixed = TRUE)
    ) {
      stop("Unerwartete TOP-Abfragestruktur; Adapter bitte prüfen.")
    }
    paste0(
      "-- FROM 11 removes Encounter/ (10 characters; PostgreSQL positions start at 1).\n",
      query, "\nAND ", expression, " IN (\n", scopeSql(periods, remaining),
      "\nSELECT enc_id FROM eligible_cases\n)"
    )
  }
  adapter$subjectQuery$baseQuery <- extend(adapter$subjectQuery$baseQuery, "enc_id")
  for (name in names(expressions)) {
    adapter$phenotypeQueries[[name]]$baseQuery <- extend(
      adapter$phenotypeQueries[[name]]$baseQuery, expressions[[name]]
    )
  }
  adapter$id <- if (remaining) "interpolar_remaining" else "interpolar_study"
  adapter$adapter <- "care.smith.top.top_phenotypic_query.adapter.sql.InterpolarAdapter"
  adapter$connection <- list(
    url = "jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}",
    user = "${DB_USER}", password = "${DB_PASS}"
  )
  adapter
}

# Keep raw contact multiplicity in the diagnostic count; scopeSql deduplicates eligibility.
preparationSql <- function(periods) {
  paste0(scopeSql(periods), "
    , hospital_cases AS (
      -- Preserve EXISTS semantics even when the source contains duplicate cases.
      SELECT DISTINCT 'Encounter/' || enc_id AS case_ref
      FROM db2dataprocessor_out.v_encounter_last_version
      WHERE enc_type_code = 'einrichtungskontakt'
    )
    , contact_counts AS (
      SELECT COUNT(*) FILTER (
        WHERE e.enc_id IS NULL OR e.enc_period_start IS NULL
          OR e.enc_main_encounter_calculated_ref IS NULL
          OR h.case_ref IS NULL OR p.ward_name IS NULL
      ) AS invalid_contacts,
      COUNT(*) FILTER (WHERE e.enc_id IS NULL) AS ignored_missing_encounter_contacts,
      COUNT(DISTINCT w.encounter_id) FILTER (WHERE e.enc_id IS NULL) AS ignored_distinct_encounter_ids,
      COUNT(*) FILTER (WHERE w.encounter_id IS NULL) AS missing_encounter_id_contacts,
      COUNT(*) FILTER (WHERE e.enc_id IS NOT NULL AND e.enc_period_start IS NULL) AS missing_start_contacts,
      COUNT(*) FILTER (WHERE e.enc_id IS NOT NULL AND e.enc_main_encounter_calculated_ref IS NULL) AS missing_main_reference_contacts,
      COUNT(*) FILTER (WHERE e.enc_main_encounter_calculated_ref IS NOT NULL AND h.case_ref IS NULL) AS missing_hospital_case_contacts,
      COUNT(*) FILTER (WHERE p.ward_name IS NULL) AS unknown_ward_contacts
      FROM db2dataprocessor_out.v_pids_per_ward w
      LEFT JOIN db2dataprocessor_out.v_encounter_last_version e ON e.enc_id=w.encounter_id
      LEFT JOIN hospital_cases h ON h.case_ref=e.enc_main_encounter_calculated_ref
      LEFT JOIN study_periods p ON p.ward_name=w.ward_name
    )
    SELECT contact_counts.*,
      (SELECT COUNT(*) FROM db2dataprocessor_out.v_pids_per_ward) AS total_ward_contact_rows,
      (SELECT COUNT(case_ref) FROM hospital_cases) AS total_hospital_cases,
      (SELECT COUNT(*) FROM (SELECT case_ref FROM ip_contacts
         WHERE ward_start=first_ip_start GROUP BY case_ref
         HAVING COUNT(DISTINCT ward_name)>1) t) AS ambiguous_first_contacts,
      (SELECT COUNT(*) FROM eligible_cases) AS study_cases
    FROM contact_counts")
}
