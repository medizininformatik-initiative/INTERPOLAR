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
#' Each source view is projected once. Reused and measurement-stage projections
#' are materialized; plain one-pass projections can be inlined. Coding fields and systems
#' do not trigger separate requests. Only aggregates leave the database.
buildCodeSummaryQuery <- function(sources, links, systems, normal_range, report_types,
                                  case_scope_query = NULL, case_groups_query = NULL,
                                  export_variants = c("all", "filtered")) {
  if (!length(export_variants)) return(NA_character_)
  if (!length(sources)) return(NA_character_)
  report_types <- parseCodeSummaryReportTypes(report_types, names(systems))
  measurement_sources <- vapply(sources, function(source) isTRUE(source$measurement), logical(1))
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
      "source_", index, " AS ", if (any(measurement_sources)) "MATERIALIZED ", "(SELECT ",
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
      paste0(source_measurement_condition, " AS is_measurement"),
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
    "raw_codings AS ", if (any(measurement_sources)) "MATERIALIZED ", "(SELECT DISTINCT * FROM (",
    paste(code_selects, collapse = " UNION ALL "),
    ") codes WHERE report IS NOT NULL AND code IS NOT NULL AND own_id IS NOT NULL)"
  ))
  coding_columns <- "report,system,coding_path,version,code,kind,own_id,pid,case_id,unit,unit_system,low,high,value"
  if (!any(measurement_sources)) {
    # All omitted raw columns are constant here. raw_codings already deduplicated
    # these rows; an extra UNION/DISTINCT or range window would only sort them again.
    ctes <- c(ctes, paste0("codings AS MATERIALIZED (SELECT ", coding_columns, " FROM raw_codings)"))
  } else {
    ctes <- c(ctes, paste0(
      "ranked_codings AS (SELECT *, MAX(range_priority) OVER (PARTITION BY ",
      "report,system,coding_path,kind,own_id,version,code,pid,case_id,unit,unit_system,value) AS preferred_range_priority ",
      "FROM raw_codings", if (!all(measurement_sources)) " WHERE is_measurement", ")"
    ))
    # Priority zero preserves coded observations without eligible limits.
    ctes <- c(ctes, paste0(
      "codings AS MATERIALIZED (SELECT DISTINCT report,system,coding_path,version,code,kind,own_id,pid,case_id,unit,unit_system, ",
      "CASE WHEN range_priority > 0 THEN low END AS low, ",
      "CASE WHEN range_priority > 0 THEN high END AS high, value FROM ranked_codings ",
      "WHERE range_priority = preferred_range_priority",
      if (!all(measurement_sources)) paste0(" UNION SELECT ", coding_columns, " FROM raw_codings WHERE NOT is_measurement"), ")"
    ))
  }

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
    ctes <- c(ctes, paste0("links AS MATERIALIZED (SELECT DISTINCT * FROM (", paste(link_selects, collapse = " UNION ALL "), ") linked_resources)"))
  }
  # Only usage codings need reference resolution. Joining every Observation to
  # all Medication codings produced quadratic nested loops on large databases.
  if (medication_available && length(links)) {
    medication_source <- medication_sources[[1]]
    ctes <- c(ctes, paste0(
      "medication_ids AS MATERIALIZED (SELECT DISTINCT ",
      quoteIdentifier(medication_source$fields[["resource_id"]]), "::text AS id FROM ",
      sourceName(medication_source), ")"
    ), paste0(
      "primary_medication_codes AS MATERIALIZED (SELECT DISTINCT 'Medication/' || own_id AS medication_ref, ",
      "own_id,system,code,COALESCE(version,'') AS version_key FROM codings ",
      "WHERE kind='Medication' AND coding_path='code/coding')"
    ))
  }
  if (medication_available && length(links)) {
    # Reference existence belongs to the Medication ID, independently of the
    # code, case association or presence of direct usage codes. Deduplicate
    # before joining so repeated usage rows cannot multiply Medication events.
    ctes <- c(ctes, paste0(
      "referenced_medication_ids AS MATERIALIZED (SELECT DISTINCT medication_ref FROM links ",
      "WHERE medication_ref IS NOT NULL)"
    ))
  }
  event_columns <- paste0(
    "c.system, CASE WHEN ", usage_condition, " THEN c.kind || '/' || c.coding_path ELSE c.coding_path END AS coding_path, ",
    "c.version,c.code,c.unit,c.unit_system,c.low,c.high, "
  )
  event_tail <- "c.kind || '/' || c.own_id AS event_key, c.kind,c.pid,c.case_id,c.value, "
  base_event_select <- paste0(
    "SELECT c.kind AS report, ", event_columns,
    "c.kind || '/' || c.own_id AS count_key, ", event_tail,
    "false AS unresolved, "
  )
  events <- paste0(
    base_event_select,
    "false AS unreferenced_medication FROM codings c WHERE NOT (", usage_condition, ") AND c.kind<>'Medication'"
  )
  if (medication_available) {
    # Keep this lookup out of unrelated resource streams in the combined mode.
    events <- c(events, paste0(
      base_event_select,
      if (length(links)) "(u.medication_ref IS NULL)" else "NULL::boolean",
      " AS unreferenced_medication FROM codings c",
      if (length(links)) " LEFT JOIN referenced_medication_ids u ON u.medication_ref='Medication/' || c.own_id",
      " WHERE c.kind='Medication'"
    ))
  }
  if (length(links)) {
    direct_joins <- if (medication_available) paste0(
      " LEFT JOIN links l ON l.kind=c.kind AND l.own_id=c.own_id ",
      "LEFT JOIN primary_medication_codes m ON l.medication_ref=m.medication_ref ",
      "AND m.system=c.system AND m.code=c.code AND m.version_key=COALESCE(c.version,'') "
    ) else ""
    # Empty versions have already been normalized to NULL. The non-null key
    # above preserves null equality while allowing an ordinary equijoin.
    count_key <- if (medication_available) {
      "COALESCE('Medication/' || m.own_id,c.kind || '/' || c.own_id)"
    } else "c.kind || '/' || c.own_id"
    events <- c(events, paste0(
      "SELECT 'Medication' AS report, ", event_columns, count_key, " AS count_key, ", event_tail,
      "false AS unresolved,false AS unreferenced_medication FROM codings c", direct_joins,
      " WHERE ", usage_condition
    ))
  }
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
      "NULL::double precision,true,false FROM unresolved_links l"
    ))
  }
  ctes <- c(ctes, paste0("raw_events AS (", paste(events, collapse = " UNION ALL "), ")"))
  # Classify each event once via a compact case lookup. Expand only requested
  # buckets, avoiding a separate source/event scan for each CSV variant.
  if (!is.null(case_groups_query)) {
    ctes <- c(ctes, paste0("case_groups AS (", case_groups_query, ")"))
  } else if (!is.null(case_scope_query)) {
    ctes <- c(ctes, paste0(
      "scope_cases AS MATERIALIZED (SELECT DISTINCT ",
      codeSummaryReferenceSql(codeSummaryFieldSql(
        c(case_id = "enc_main_encounter_calculated_ref"), "case_id", "scope_input"
      ), "Encounter"),
      " AS case_id FROM (", case_scope_query, ") scope_input)"
    ))
  }
  conditions <- c(all = "true")
  if (!is.null(case_groups_query)) {
    conditions <- c(
      conditions,
      all_age_ge18 = "s.age_group='ge18'", all_age_lt18 = "s.age_group='lt18'",
      filtered = "s.is_filtered", filtered_age_ge18 = "s.is_filtered AND s.age_group='ge18'",
      filtered_age_lt18 = "s.is_filtered AND s.age_group='lt18'"
    )
  } else if (!is.null(case_scope_query)) {
    conditions <- c(conditions, filtered = "s.case_id IS NOT NULL")
  }
  conditions <- conditions[intersect(export_variants, names(conditions))]
  if (!length(conditions)) return(NA_character_)
  if (!is.null(case_groups_query) || !is.null(case_scope_query)) {
    # Assign CSV buckets once per case, rather than re-evaluating every scope
    # condition for each Observation/usage event in a multi-million-row source.
    buckets <- vapply(names(conditions), function(scope) {
      paste0("CASE WHEN ", conditions[[scope]], " THEN ", quoteSqlString(scope), " END")
    }, character(1))
    ctes <- c(ctes, paste0(
      "scope_buckets AS MATERIALIZED (SELECT s.case_id, ARRAY_REMOVE(ARRAY[",
      paste(buckets, collapse = ","), "]::text[],NULL) AS report_scopes FROM ",
      if (!is.null(case_groups_query)) "case_groups" else "scope_cases", " s)"
    ))
    fallback_scopes <- if ("all" %in% names(conditions)) "ARRAY['all']::text[]" else "ARRAY[]::text[]"
    scoped_events <- paste0(
      "SELECT v.report_scope,e.* FROM raw_events e LEFT JOIN scope_buckets s ON s.case_id=e.case_id ",
      "CROSS JOIN LATERAL unnest(COALESCE(s.report_scopes,", fallback_scopes, ")) v(report_scope)"
    )
  } else {
    scoped_events <- "SELECT 'all'::text AS report_scope,e.* FROM raw_events e"
  }
  ctes <- c(ctes, paste0("scoped_events AS (", scoped_events, ")"))
  dimensions <- "report_scope, report, system, coding_path, version, code, unit, unit_system, low, high"
  # Both exports share the expensive source/event CTEs. Local groups retain
  # every combination; global rare groups must deduplicate their IDs again.
  export_targets <- "(VALUES ('global'), ('local')) AS t(export_target)"
  ctes <- c(
    ctes,
    paste0(
      "events AS MATERIALIZED (SELECT *, ARRAY[", dimensions,
      "] AS combination_id FROM scoped_events)"
    ),
    paste0(
      "frequencies AS (SELECT combination_id, COUNT(DISTINCT count_key) AS n ",
      "FROM events WHERE NOT unresolved GROUP BY combination_id)"
    ),
    paste0(
      "labelled AS ", if (any(measurement_sources)) "MATERIALIZED ", "(SELECT e.*, t.export_target,t.row_type ",
      "FROM events e LEFT JOIN frequencies f USING (combination_id) CROSS JOIN LATERAL (",
      "SELECT 'both'::text AS export_target, CASE WHEN e.unresolved THEN 'unresolved medication reference' ELSE 'detail' END AS row_type ",
      "WHERE e.unresolved OR f.n >= 5 UNION ALL ",
      "SELECT 'local','detail' WHERE NOT e.unresolved AND f.n < 5 UNION ALL ",
      "SELECT 'global','other (count < 5)' WHERE NOT e.unresolved AND f.n < 5) t)"
    ),
    paste0(
      "group_labels AS (SELECT report_scope,export_target, report, system, coding_path, row_type, ",
      "CASE WHEN row_type = 'detail' THEN version END AS version, ",
      "CASE WHEN row_type = 'detail' THEN code END AS code, ",
      "CASE WHEN row_type = 'detail' THEN unit END AS unit, ",
      "CASE WHEN row_type = 'detail' THEN unit_system END AS unit_system, ",
      "CASE WHEN row_type = 'detail' THEN low END AS low, ",
      "CASE WHEN row_type = 'detail' THEN high END AS high, ",
      "count_key, event_key, kind, pid, case_id, ",
      "CASE WHEN row_type = 'detail' THEN value END AS value,unresolved,unreferenced_medication FROM labelled ",
      "UNION ALL SELECT report_scope,'both',report, system, NULL::text, 'total', NULL,NULL,NULL,NULL,NULL,NULL, ",
      "count_key,event_key,kind,pid,case_id,NULL::double precision,false,unreferenced_medication ",
      "FROM events WHERE NOT unresolved)"
    ),
    # NULL-safe array keys avoid ranking the full event stream. Summary keys
    # are built only after aggregation, not stored beside every input event.
    paste0("grouped AS ", if (any(measurement_sources)) "MATERIALIZED ", "(SELECT * FROM group_labels)"),
    paste0(
      "counts AS (SELECT ARRAY[g.report_scope,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high] AS summary_id,g.report_scope,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high, ",
      "COUNT(DISTINCT g.count_key) AS count, ",
      "COUNT(DISTINCT g.pid) AS patient_count, COUNT(DISTINCT g.case_id) AS case_count, ",
      "CASE WHEN g.row_type = 'unresolved medication reference' THEN ",
      "COUNT(DISTINCT g.event_key) - COUNT(DISTINCT g.event_key) FILTER (WHERE g.case_id IS NOT NULL) ELSE ",
      "COUNT(DISTINCT g.count_key) - COUNT(DISTINCT g.count_key) FILTER (WHERE g.case_id IS NOT NULL) END AS no_case_count, ",
      "COUNT(DISTINCT g.count_key) FILTER (WHERE g.count_key LIKE 'Medication/%') AS medication_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationRequest') AS medication_request_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationAdministration') AS medication_administration_count, ",
      "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationStatement') AS medication_statement_count, ",

      "COUNT(DISTINCT g.count_key) FILTER (WHERE g.unreferenced_medication) AS unreferenced_medication_count ",
      "FROM grouped g ",
      "GROUP BY g.report_scope,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high)"
    )
  )
  if (any(measurement_sources)) {
    ctes <- c(
      ctes,
      # A separate DISTINCT observation/value projection prevents medication joins
      # and repeated flattened reference/coding rows from weighting statistics.
      paste0(
        "measurements AS (SELECT DISTINCT report_scope,export_target,report,system,coding_path,row_type,version,code,unit,unit_system,low,high,count_key,value ",
        "FROM grouped WHERE row_type = 'detail' AND value IS NOT NULL ",
        "AND value NOT IN ('NaN'::double precision, 'Infinity'::double precision, '-Infinity'::double precision))"
      ),
      paste0(
        "statistics AS (SELECT ARRAY[report_scope,export_target,report,system,coding_path,row_type,version,code,unit,unit_system,low,high] AS summary_id, ",
        "percentile_cont(0.5) WITHIN GROUP (ORDER BY value) AS median, ",
        "percentile_cont(0.25) WITHIN GROUP (ORDER BY value) AS q1, ",
        "percentile_cont(0.75) WITHIN GROUP (ORDER BY value) AS q3, ",
        "AVG(value) AS mean, STDDEV_SAMP(value) AS sd, MIN(value) AS minimum, MAX(value) AS maximum ",
        "FROM measurements GROUP BY report_scope,export_target,report,system,coding_path,row_type,version,code,unit,unit_system,low,high)"
      )
    )
  }

  ctes <- c(ctes, paste0(
    "counts_outputs AS (SELECT c.*,t.export_target AS output_target FROM counts c CROSS JOIN ",
    export_targets, " WHERE c.export_target IN ('both',t.export_target))"
  ))
  # Statistics contain a subset of the count groups, keyed identically. FULL
  # therefore has the same rows as LEFT here, while requiring a hash/merge join
  # even when PostgreSQL underestimates the number of measurement groups.
  # Expand targets before that join: a post-join count-side filter would let
  # PostgreSQL reduce FULL back to LEFT and choose quadratic nested loops again.
  statistic_columns <- c("median", "q1", "q3", "mean", "sd", "minimum", "maximum")
  statistics_select <- if (any(measurement_sources)) {
    paste0("s.", statistic_columns, collapse = ",")
  } else {
    paste0("NULL::double precision AS ", statistic_columns, collapse = ",")
  }
  statistics_join <- if (any(measurement_sources)) " FULL JOIN statistics s USING (summary_id) " else " "
  paste0(
    "/* INTERPOLAR DQA code summary */\nWITH ", paste(ctes, collapse = ",\n"),
    "\nSELECT c.summary_id,c.report_scope,c.output_target AS export_target,c.report,c.system,c.coding_path,c.row_type,c.version,c.code,",
    "c.unit,c.unit_system,c.low,c.high,c.count,c.patient_count,c.case_count,c.no_case_count,c.medication_count,",
    "c.medication_request_count,c.medication_administration_count,c.medication_statement_count,c.unreferenced_medication_count,",
    statistics_select, " FROM counts_outputs c", statistics_join,
    "ORDER BY c.report_scope,c.output_target,c.report,c.system,c.coding_path,c.row_type,c.version,c.code,c.unit,c.unit_system,c.low,c.high"
  )
}
