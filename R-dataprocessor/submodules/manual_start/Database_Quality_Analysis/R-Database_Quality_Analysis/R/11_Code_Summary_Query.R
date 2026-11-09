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
  medication_reports <- unique(unlist(lapply(Filter(function(source) {
    source$resource == "Medication"
  }, sources), `[[`, "reports"), use.names = FALSE))
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
    source_measurement_condition <- if (isTRUE(source$measurement)) "true" else "false"
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
    # A Patient is its own patient association, without a subject reference.
    patient_reference <- if (source$resource == "Patient") {
      paste0("'Patient/' || ", fieldSql("resource_id"))
    } else fieldSql("pid")
    parts <- c(
      paste0("CASE ", paste(report_cases, collapse = " "), " END AS report"),
      paste0(fieldSql("system"), " AS system"),
      paste0(quoteSqlString(source$coding), " AS coding_path"),
      paste0(fieldSql("version"), " AS version"), paste0(fieldSql("code"), " AS code"),
      paste0(quoteSqlString(source$resource), " AS kind"),
      paste0(fieldSql("resource_id"), " AS own_id"),
      paste0(codeSummaryReferenceSql(patient_reference, "Patient"), " AS pid"),
      paste0(codeSummaryReferenceSql(fieldSql("case_id"), "Encounter"), " AS case_id"),
      paste0(measurementFieldSql("unit"), " AS unit"),
      paste0(measurementFieldSql("unit_system"), " AS unit_system"),
      paste0(measurementFieldSql("low"), " AS low"),
      paste0(measurementFieldSql("high"), " AS high"),
      paste0(measurementFieldSql("value", numeric = TRUE), " AS value"),
      paste0("CASE WHEN ", source_measurement_condition, " THEN ", range_priority, " ELSE 0 END AS range_priority")
    )
    paste0(
      "SELECT ", paste(parts, collapse = ", "), " WHERE ", fieldSql("system"), " IN (",
      paste(vapply(unique(unlist(systems[source$reports])), quoteSqlString, character(1)), collapse = ", "), ")"
    )
  })
  # Expand all Coding fields in one pass over each projected resource view.
  # This avoids rescanning a materialized view for every SNOMED Coding path.
  source_views <- vapply(sources, function(source) quoteTable(source$schema, source$view), character(1))
  code_selects <- lapply(unique(source_views), function(view) {
    indexes <- which(source_views == view)
    paste0(
      "SELECT expanded.* FROM ", sourceName(sources[[indexes[[1]]]]), " s CROSS JOIN LATERAL (",
      paste(code_selects[indexes], collapse = " UNION ALL "), ") expanded"
    )
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
      "report,system,coding_path,kind,own_id,version,code,pid,case_id,unit,unit_system,value) AS preferred_range_priority ",
      "FROM raw_codings)"
    ),
    # Priority zero preserves coded observations without eligible limits; dropping
    # them entirely would undercount code occurrences in a data quality report.
    paste0(
      "codings AS MATERIALIZED (SELECT DISTINCT report,system,coding_path,version,code,kind,own_id,pid,case_id,unit,unit_system, ",
      "CASE WHEN range_priority > 0 THEN low END AS low, ",
      "CASE WHEN range_priority > 0 THEN high END AS high, value FROM ranked_codings ",
      "WHERE range_priority = preferred_range_priority)"
    )
  )

  link_kinds <- vapply(links, `[[`, character(1), "resource")
  medication_sources <- Filter(function(source) source$resource == "Medication", sources)
  medication_available <- length(medication_sources) > 0L
  usage_condition <- if (length(link_kinds)) {
    paste0("c.kind IN (", paste(vapply(link_kinds, quoteSqlString, character(1)), collapse = ", "), ")")
  } else "false"
  if (length(links)) {
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
  }
  # A direct code shares a Medication identity only if its reference resolves to
  # that same primary code/version. Otherwise its own usage ID is the fallback.
  direct_joins <- if (length(links)) paste0(
    " LEFT JOIN links l ON l.kind = c.kind AND l.own_id = c.own_id ",
    "LEFT JOIN codings m ON m.kind = 'Medication' AND m.coding_path = 'code/coding' ",
    "AND c.coding_path = 'medicationCodeableConcept/coding' ",
    "AND l.medication_ref = 'Medication/' || m.own_id AND m.system = c.system ",
    "AND m.code = c.code AND m.version IS NOT DISTINCT FROM c.version"
  ) else ""
  count_key <- if (length(links)) {
    "COALESCE('Medication/' || m.own_id, c.kind || '/' || c.own_id)"
  } else "c.kind || '/' || c.own_id"
  # Medication IDs are deliberately unfiltered by system/code for reference validation.
  if (medication_available && length(links)) {
    medication_source <- medication_sources[[1]]
    ctes <- c(ctes, paste0(
      "medication_ids AS MATERIALIZED (SELECT DISTINCT ",
      quoteIdentifier(medication_source$fields[["resource_id"]]), "::text AS id FROM ",
      sourceName(medication_source), ")"
    ))
    direct_joins <- paste0(
      direct_joins,
      " LEFT JOIN medication_ids r ON l.medication_ref = 'Medication/' || r.id"
    )
  }
  missing_reference <- if (length(links) && medication_available) {
    paste0("(", usage_condition, " AND r.id IS NULL)")
  } else "NULL::boolean"
  events <- paste0(
    "SELECT CASE WHEN ", usage_condition, " THEN 'Medication' ELSE c.kind END AS report, ",
    "c.system, CASE WHEN ", usage_condition, " THEN c.kind || '/' || c.coding_path ELSE c.coding_path END AS coding_path, ",
    "c.version,c.code,c.unit,c.unit_system,c.low,c.high, ", count_key, " AS count_key, ",
    "c.kind || '/' || c.own_id AS event_key, c.kind,c.pid,c.case_id,c.value, ",
    missing_reference, " AS missing_medication,false AS unresolved FROM codings c", direct_joins
  )
  if (length(links) && medication_available) {
    # Count usage resources beside their Medication code, rather than exporting
    # separate usage CSVs. Distinct keys prevent flattened rows multiplying counts.
    events <- c(events, paste0(
      "SELECT 'Medication',c.system,c.coding_path,c.version,c.code,NULL,NULL,NULL,NULL, ",
      "'Medication/' || c.own_id,l.kind || '/' || l.own_id,l.kind,l.pid,l.case_id, ",
      "NULL::double precision,false,false FROM links l JOIN codings c ON c.kind = 'Medication' ",
      "AND l.medication_ref = 'Medication/' || c.own_id WHERE l.own_id IS NOT NULL"
    ))
    ctes <- c(ctes, paste0(
      "unresolved_links AS MATERIALIZED (SELECT DISTINCT l.* FROM links l ",
      "WHERE l.own_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM medication_ids m ",
      "WHERE l.medication_ref = 'Medication/' || m.id) ",
      "AND NOT EXISTS (SELECT 1 FROM codings d WHERE d.kind = l.kind AND d.own_id = l.own_id ",
      "AND d.coding_path = 'medicationCodeableConcept/coding'))"
    ))
    events <- c(events, paste0(
      "SELECT 'Medication', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ",
      "l.kind || '/' || l.own_id, l.kind || '/' || l.own_id, l.kind, l.pid, l.case_id, ",
      "NULL::double precision, true, true FROM unresolved_links l"
    ))
  }
  ctes <- c(ctes, paste0("raw_events AS (", paste(events, collapse = " UNION ALL "), ")"))
  dimensions <- "report, system, coding_path, version, code, unit, unit_system, low, high"
  # Both exports share the expensive source/event CTEs. Local groups retain
  # every combination; global rare groups must deduplicate their IDs again.
  export_targets <- "(VALUES ('global'), ('local')) AS t(export_target)"
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
      "labelled AS MATERIALIZED (SELECT e.*, t.export_target, ",
      "CASE WHEN e.unresolved THEN 'unresolved medication reference' ",
      "WHEN t.export_target = 'global' AND f.n < 5 THEN 'other (count < 5)' ELSE 'detail' END AS row_type ",
      "FROM events e LEFT JOIN frequencies f USING (combination_id) CROSS JOIN ", export_targets, ")"
    ),
    paste0(
      "group_labels AS (SELECT export_target, report, system, coding_path, row_type, ",
      "CASE WHEN row_type = 'detail' THEN version END AS version, ",
      "CASE WHEN row_type = 'detail' THEN code END AS code, ",
      "CASE WHEN row_type = 'detail' THEN unit END AS unit, ",
      "CASE WHEN row_type = 'detail' THEN unit_system END AS unit_system, ",
      "CASE WHEN row_type = 'detail' THEN low END AS low, ",
      "CASE WHEN row_type = 'detail' THEN high END AS high, ",
      "count_key, event_key, kind, pid, case_id, ",
      "CASE WHEN row_type = 'detail' THEN value END AS value, missing_medication,unresolved FROM labelled ",
      "UNION ALL SELECT t.export_target,report, system, NULL::text, 'total', NULL,NULL,NULL,NULL,NULL,NULL, ",
      "count_key,event_key,kind,pid,case_id,NULL::double precision,missing_medication,false ",
      "FROM events CROSS JOIN ", export_targets, " WHERE NOT unresolved)"
    ),
    # Integer group keys allow hash/merge joins instead of null-safe comparisons
    # across every dimension, which PostgreSQL would execute as nested loops.
    paste0(
      "grouped AS MATERIALIZED (SELECT *, COALESCE(count_key,event_key) AS resource_key, ",
      "dense_rank() OVER (ORDER BY export_target,report,system,coding_path,row_type,version,code,unit,unit_system,low,high) AS summary_id ",
      "FROM group_labels)"
    ),
    paste0(
      "case_presence AS (SELECT summary_id,resource_key, ",
      "BOOL_OR(case_id IS NOT NULL) AS has_case FROM grouped GROUP BY ",
      "summary_id,resource_key)"
    ),
    paste0(
      "counts AS (SELECT g.summary_id,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high, ",
      "COUNT(DISTINCT g.count_key) AS count, ",
      "COUNT(DISTINCT g.pid) AS patient_count, COUNT(DISTINCT g.case_id) AS case_count, ",
      "CASE WHEN g.row_type = 'unresolved medication reference' THEN ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE NOT p.has_case) ELSE ",
      "COUNT(DISTINCT g.count_key) FILTER (WHERE NOT p.has_case) END AS no_case_count, ",
      "COUNT(DISTINCT g.count_key) FILTER (WHERE g.count_key LIKE 'Medication/%') AS medication_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationRequest') AS medication_request_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationAdministration') AS medication_administration_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationStatement') AS medication_statement_count, ",
      "CASE WHEN BOOL_OR(g.missing_medication IS NOT NULL) THEN ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.missing_medication) END AS no_reference_count_to_medication ",
      "FROM grouped g JOIN case_presence p USING (summary_id,resource_key) ",
      "GROUP BY g.summary_id,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high)"
    ),
    # A separate DISTINCT observation/value projection prevents medication joins
    # and repeated flattened reference/coding rows from weighting statistics.
    paste0(
      "measurements AS (SELECT DISTINCT summary_id,count_key,value ",
      "FROM grouped WHERE row_type = 'detail' AND value IS NOT NULL ",
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
    "ORDER BY c.export_target,c.report,c.system,c.coding_path,c.row_type,c.version,c.code,c.unit,c.unit_system,c.low,c.high"
  )
}
