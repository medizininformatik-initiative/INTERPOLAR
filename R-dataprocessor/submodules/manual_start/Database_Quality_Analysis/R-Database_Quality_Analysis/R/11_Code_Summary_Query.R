#' SQL expression for a nullable mapped code-report field
codeSummaryFieldSql <- function(fields, name, alias = "s") {
  column <- fields[[name]]
  if (is.null(column) || is.na(column)) return("NULL::text")
  paste0("NULLIF(BTRIM(", quoteQualifiedIdentifier(alias, column), "::text), '')")
}

#' SQL expression for valid calculated references
codeSummaryReferenceSql <- function(expression, resource) {
  pattern <- paste0("^(", resource, "/[^/[:space:]]+|https?://[^[:space:]]+/", resource, "/[^/[:space:]]+)$")
  paste0(
    "CASE WHEN ", expression, " ~ ", quoteSqlString(pattern),
    " THEN ", quoteSqlString(paste0(resource, "/")),
    " || regexp_replace(", expression, ", '^.*/', '') END"
  )
}

#' Build a batched, database-aggregated code summary
#'
#' Each source view is projected once into a materialized CTE. Coding fields are
#' expanded from these projections, so configured coding fields and code systems
#' do not trigger separate requests. Only aggregates leave the database.
buildCodeSummaryQuery <- function(sources, links, systems, normal_range, report_types) {
  if (!length(sources)) return(NA_character_)
  report_types <- parseCodeSummaryReportTypes(report_types, names(systems))
  measurement_reports <- names(report_types)[report_types == "measurement"]
  medication_reports <- names(report_types)[report_types == "medication"]
  if (!length(medication_reports)) links <- list()
  measurement_condition <- if (length(measurement_reports)) {
    paste0("report IN (", paste(vapply(measurement_reports, quoteSqlString, character(1)), collapse = ", "), ")")
  } else {
    "false"
  }
  ctes <- character()
  views <- unique(vapply(c(sources, links), function(source) quoteTable(source$schema, source$view), character(1)))
  for (index in seq_along(views)) {
    view_sources <- Filter(function(source) quoteTable(source$schema, source$view) == views[[index]], c(sources, links))
    columns <- unique(unlist(lapply(view_sources, function(source) unname(source$fields))))
    columns <- columns[!is.na(columns)]
    filters <- character()
    coding_view <- all(vapply(view_sources, function(source) !is.null(source$coding), logical(1)))
    requires_all_medication_ids <- length(links) > 0L && any(vapply(view_sources, function(source) {
      source$resource == "Medication" && any(source$reports %in% medication_reports)
    }, logical(1)))
    if (coding_view && !requires_all_medication_ids) {
      filters <- vapply(view_sources, function(source) {
        paste0(
          quoteIdentifier(source$fields[["system"]]), "::text IN (",
          paste(vapply(unique(unlist(systems[source$reports])), quoteSqlString, character(1)), collapse = ", "), ")"
        )
      }, character(1))
    }
    ctes <- c(ctes, paste0(
      "source_", index, " AS MATERIALIZED (SELECT ",
      paste(vapply(columns, quoteIdentifier, character(1)), collapse = ", "),
      " FROM ", views[[index]],
      if (length(filters)) paste0(" WHERE ", paste(filters, collapse = " OR ")), ")"
    ))
  }
  sourceName <- function(source) {
    paste0("source_", match(quoteTable(source$schema, source$view), views))
  }
  code_selects <- lapply(sources, function(source) {
    fieldSql <- function(name) codeSummaryFieldSql(source$fields, name)
    report_cases <- vapply(source$reports, function(report) {
      paste0(
        "WHEN ", fieldSql("system"), " IN (",
        paste(vapply(systems[[report]], quoteSqlString, character(1)), collapse = ", "),
        ") THEN ", quoteSqlString(report)
      )
    }, character(1))
    measurement_systems <- unique(unlist(systems[intersect(source$reports, measurement_reports)], use.names = FALSE))
    source_measurement_condition <- if (length(measurement_systems)) {
      paste0(fieldSql("system"), " IN (", paste(vapply(measurement_systems, quoteSqlString, character(1)), collapse = ", "), ")")
    } else {
      "false"
    }
    measurementFieldSql <- function(name, numeric = FALSE) {
      expression <- fieldSql(name)
      if (numeric) expression <- paste0("(", expression, ")::double precision")
      paste0("CASE WHEN ", source_measurement_condition, " THEN ", expression, " END")
    }
    # Reproduce MRP type priority in SQL, without converting units or selecting
    # just one range: all ranges at the preferred priority remain visible.
    range_priority <- paste0(
      "CASE WHEN ", fieldSql("range_type"), " = ", quoteSqlString(normal_range$code),
      " THEN 2 WHEN ", fieldSql("range_type"), " IS NULL THEN ",
      if (isTRUE(normal_range$fallback_to_missing_type)) "1" else "0", " ELSE 0 END"
    )
    parts <- c(
      paste0("CASE ", paste(report_cases, collapse = " "), " END AS report"),
      paste0(fieldSql("version"), " AS version"), paste0(fieldSql("code"), " AS code"),
      paste0(quoteSqlString(source$resource), " AS kind"),
      paste0(fieldSql("resource_id"), " AS own_id"),
      paste0(codeSummaryReferenceSql(fieldSql("pid"), "Patient"), " AS pid"),
      paste0(codeSummaryReferenceSql(fieldSql("case_id"), "Encounter"), " AS case_id"),
      paste0(measurementFieldSql("unit"), " AS unit"),
      paste0(measurementFieldSql("unit_system"), " AS unit_system"),
      paste0(measurementFieldSql("low"), " AS low"),
      paste0(measurementFieldSql("high"), " AS high"),
      paste0(measurementFieldSql("value", numeric = TRUE), " AS value"),
      paste0("CASE WHEN ", source_measurement_condition, " THEN ", range_priority, " ELSE 0 END AS range_priority")
    )
    paste0("SELECT ", paste(parts, collapse = ", "), " FROM ", sourceName(source), " s")
  })
  ctes <- c(ctes, paste0(
    "raw_codings AS (SELECT DISTINCT * FROM (",
    paste(code_selects, collapse = " UNION ALL "),
    ") codes WHERE report IS NOT NULL AND code IS NOT NULL AND own_id IS NOT NULL)"
  ))
  ctes <- c(
    ctes,
    paste0(
      "ranked_codings AS (SELECT *, MAX(range_priority) OVER (PARTITION BY ",
      "report,kind,own_id,version,code,pid,case_id,unit,unit_system,value) AS preferred_range_priority ",
      "FROM raw_codings)"
    ),
    # Priority zero preserves coded observations without eligible limits; dropping
    # them entirely would undercount code occurrences in a data quality report.
    paste0(
      "codings AS MATERIALIZED (SELECT DISTINCT report,version,code,kind,own_id,pid,case_id,unit,unit_system, ",
      "CASE WHEN range_priority > 0 THEN low END AS low, ",
      "CASE WHEN range_priority > 0 THEN high END AS high, value FROM ranked_codings ",
      "WHERE range_priority = preferred_range_priority)"
    )
  )

  events <- paste0(
    "SELECT report, version, code, CASE WHEN ", measurement_condition, " THEN unit END AS unit, ",
    "CASE WHEN ", measurement_condition, " THEN unit_system END AS unit_system, ",
    "CASE WHEN ", measurement_condition, " THEN low END AS low, CASE WHEN ", measurement_condition, " THEN high END AS high, ",
    "kind || '/' || own_id AS count_key, kind || '/' || own_id AS event_key, kind, pid, case_id, ",
    "CASE WHEN ", measurement_condition, " THEN value END AS value, false AS unresolved FROM codings"
  )
  if (length(links) && length(medication_reports)) {
    link_selects <- lapply(links, function(source) {
      fieldSql <- function(name) codeSummaryFieldSql(source$fields, name)
      paste0(
        "SELECT ", quoteSqlString(source$resource), " AS kind, ", fieldSql("resource_id"), " AS own_id, ",
        codeSummaryReferenceSql(fieldSql("medication_ref"), "Medication"), " AS medication_ref, ",
        codeSummaryReferenceSql(fieldSql("pid"), "Patient"), " AS pid, ",
        codeSummaryReferenceSql(fieldSql("case_id"), "Encounter"), " AS case_id FROM ", sourceName(source), " s"
      )
    })
    ctes <- c(ctes, paste0("links AS MATERIALIZED (", paste(link_selects, collapse = " UNION ALL "), ")"))
    events <- c(events, paste0(
      "SELECT c.report, c.version, c.code, NULL, NULL, NULL, NULL, 'Medication/' || c.own_id, ",
      "l.kind || '/' || l.own_id, l.kind, l.pid, l.case_id, NULL::double precision, false ",
      "FROM links l JOIN codings c ON c.kind = 'Medication' ",
      "AND l.medication_ref = 'Medication/' || c.own_id WHERE l.own_id IS NOT NULL ",
      "AND c.report IN (", paste(vapply(medication_reports, quoteSqlString, character(1)), collapse = ", "), ")"
    ))
    # Resolve against all Medication IDs, including medications without a report code.
    medication_sources <- Filter(function(source) source$resource == "Medication", sources)
    if (length(medication_sources)) {
      medication_source <- medication_sources[[1]]
      # Resolve once against all Medication IDs, including medications without
      # report codes. Reuse the materialized result for every medication report.
      ctes <- c(
        ctes,
        paste0(
          "medication_ids AS MATERIALIZED (SELECT DISTINCT ",
          quoteIdentifier(medication_source$fields[["resource_id"]]), "::text AS id FROM ",
          sourceName(medication_source), ")"
        ),
        paste0(
          "unresolved_links AS MATERIALIZED (SELECT DISTINCT l.* FROM links l ",
          "WHERE l.own_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM medication_ids m ",
          "WHERE l.medication_ref = 'Medication/' || m.id))"
        )
      )
      report_values <- paste0("(", vapply(medication_reports, quoteSqlString, character(1)), ")")
      events <- c(events, paste0(
        "SELECT r.report, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ",
        "l.kind || '/' || l.own_id, l.kind, l.pid, l.case_id, NULL::double precision, true ",
        "FROM unresolved_links l CROSS JOIN (VALUES ", paste(report_values, collapse = ", "), ") r(report)"
      ))
    }
  }
  ctes <- c(ctes, paste0("raw_events AS (", paste(events, collapse = " UNION ALL "), ")"))
  dimensions <- "report, version, code, unit, unit_system, low, high"
  ctes <- c(
    ctes,
    paste0(
      "events AS MATERIALIZED (SELECT *, dense_rank() OVER (ORDER BY ", dimensions,
      ") AS combination_id FROM raw_events)"
    ),
    paste0(
      "frequencies AS (SELECT combination_id, COUNT(DISTINCT count_key) AS n ",
      "FROM events WHERE NOT unresolved GROUP BY combination_id)"
    ),
    paste0(
      "labelled AS MATERIALIZED (SELECT e.*, ",
      "CASE WHEN e.unresolved THEN 'unresolved medication reference' WHEN f.n < 5 THEN 'other (count < 5)' ELSE 'detail' END AS row_type ",
      "FROM events e LEFT JOIN frequencies f USING (combination_id))"
    ),
    paste0(
      "group_labels AS (SELECT report, row_type, ",
      "CASE WHEN row_type = 'detail' THEN version END AS version, ",
      "CASE WHEN row_type = 'detail' THEN code END AS code, ",
      "CASE WHEN row_type = 'detail' THEN unit END AS unit, ",
      "CASE WHEN row_type = 'detail' THEN unit_system END AS unit_system, ",
      "CASE WHEN row_type = 'detail' THEN low END AS low, ",
      "CASE WHEN row_type = 'detail' THEN high END AS high, ",
      "count_key, event_key, kind, pid, case_id, ",
      "CASE WHEN row_type = 'detail' THEN value END AS value, unresolved FROM labelled ",
      "UNION ALL SELECT report, 'total', NULL,NULL,NULL,NULL,NULL,NULL, ",
      "count_key,event_key,kind,pid,case_id,NULL::double precision,false FROM events WHERE NOT unresolved)"
    ),
    # Integer group keys allow hash/merge joins instead of null-safe comparisons
    # across every dimension, which PostgreSQL would execute as nested loops.
    paste0(
      "grouped AS MATERIALIZED (SELECT *, COALESCE(count_key,event_key) AS resource_key, ",
      "dense_rank() OVER (ORDER BY report,row_type,version,code,unit,unit_system,low,high) AS summary_id ",
      "FROM group_labels)"
    ),
    paste0(
      "case_presence AS (SELECT summary_id,resource_key, ",
      "BOOL_OR(case_id IS NOT NULL) AS has_case FROM grouped GROUP BY ",
      "summary_id,resource_key)"
    ),
    paste0(
      "counts AS (SELECT g.summary_id,g.report,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high, ",
      "CASE WHEN g.row_type <> 'unresolved medication reference' THEN COUNT(DISTINCT g.count_key) END AS count, ",
      "COUNT(DISTINCT g.pid) AS patient_count, COUNT(DISTINCT g.case_id) AS case_count, ",
      "CASE WHEN g.row_type = 'unresolved medication reference' THEN ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE NOT p.has_case) ELSE ",
      "COUNT(DISTINCT g.count_key) FILTER (WHERE NOT p.has_case) END AS no_case_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'Medication') AS medication_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationRequest') AS medication_request_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationAdministration') AS medication_administration_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationStatement') AS medication_statement_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.unresolved) AS no_reference_count_to_medication ",
      "FROM grouped g JOIN case_presence p USING (summary_id,resource_key) ",
      "GROUP BY g.summary_id,g.report,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high)"
    ),
    # A separate DISTINCT observation/value projection prevents medication joins
    # and repeated flattened reference/coding rows from weighting statistics.
    paste0(
      "measurements AS (SELECT DISTINCT summary_id,count_key,value ",
      "FROM grouped WHERE ", measurement_condition, " AND row_type = 'detail' AND value IS NOT NULL ",
      "AND value NOT IN ('NaN'::double precision, 'Infinity'::double precision, '-Infinity'::double precision))"
    ),
    paste0(
      "statistics AS (SELECT summary_id, ",
      "percentile_cont(0.5) WITHIN GROUP (ORDER BY value) AS median, ",
      "percentile_cont(0.25) WITHIN GROUP (ORDER BY value) AS q1, ",
      "percentile_cont(0.75) WITHIN GROUP (ORDER BY value) AS q3, ",
      "AVG(value) AS mean, STDDEV_SAMP(value) AS sd, MIN(value) AS minimum, MAX(value) AS maximum ",
      "FROM measurements GROUP BY summary_id)"
    )
  )
  paste0(
    "WITH ", paste(ctes, collapse = ",\n"),
    "\nSELECT c.*, s.median,s.q1,s.q3,s.mean,s.sd,s.minimum,s.maximum FROM counts c LEFT JOIN statistics s ",
    "USING (summary_id) ",
    "ORDER BY c.report,c.row_type,c.version,c.code,c.unit,c.unit_system,c.low,c.high"
  )
}
