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
#' Clinical sources are filtered before materialization and Coding/range processing
#' when no complete-database CSV is requested. Medication additionally retains narrow
#' global identity projections for correct reference resolution. Only aggregates leave SQL.
buildCodeSummaryQuery <- function(sources, links, systems, normal_range, report_types,
                                  case_scope_query = NULL, case_groups_query = NULL,
                                  export_variants = c("all", "filtered"),
                                  query_mode = c("combined", "catalog", "details", "statistics", "totals", "rare", "details_statistics"),
                                  code_keys = NULL, rare_groups = NULL) {
  query_mode <- match.arg(query_mode)
  if (!is.null(code_keys) && !nrow(code_keys)) return(NA_character_)
  if (query_mode == "rare" && (is.null(rare_groups) || !nrow(rare_groups))) return(NA_character_)
  if (query_mode %in% c("catalog", "totals")) {
    sources <- lapply(sources, function(source) {
      source$catalog_measurement <- isTRUE(source$measurement)
      source$measurement <- FALSE
      source$fields[c("value", "unit", "unit_system", "low", "high", "range_type")] <- NA_character_
      source
    })
  }
  if (!length(export_variants)) return(NA_character_)
  if (!length(sources)) return(NA_character_)
  report_types <- parseCodeSummaryReportTypes(report_types, names(systems))
  measurement_sources <- vapply(sources, function(source) isTRUE(source$measurement), logical(1))
  collect_statistics <- any(measurement_sources) && query_mode == "combined"
  cache_measurements <- any(measurement_sources) && query_mode == "combined"
  chunked_codes <- !is.null(code_keys) && nrow(code_keys) > 0L
  include_diagnostics <- query_mode %in% c("combined", "totals")
  medication_reports <- unique(unlist(lapply(Filter(function(source) {
    source$resource == "Medication"
  }, sources), `[[`, "reports"), use.names = FALSE))
  ctes <- character()
  # Build case buckets before sources so restricted exports can filter before
  # materialization, Coding deduplication and reference-range ranking.
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
      if (!is.null(case_groups_query)) "case_groups" else "scope_cases", " s WHERE (",
      paste(conditions, collapse = ") OR ("), "))"
    ))
  }
  filter_cases <- !"all" %in% names(conditions)
  link_kinds <- vapply(links, `[[`, character(1), "resource")
  medication_sources <- Filter(function(source) source$resource == "Medication", sources)
  medication_available <- length(medication_sources) > 0L
  global_identities <- (filter_cases || chunked_codes) && medication_available && length(links) > 0L
  caseFilterSql <- function(source, alias = "s") {
    reference <- codeSummaryReferenceSql(codeSummaryFieldSql(source$fields, "case_id", alias), "Encounter")
    paste0("EXISTS (SELECT 1 FROM scope_buckets selected_case WHERE selected_case.case_id=", reference, ")")
  }
  codeFilterSql <- function(source, alias = "s") {
    paste0(
      "EXISTS (SELECT 1 FROM code_keys k WHERE k.system=", codeSummaryFieldSql(source$fields, "system", alias),
      " AND k.code=", codeSummaryFieldSql(source$fields, "code", alias), ")"
    )
  }
  if (chunked_codes) {
    ctes <- c(ctes, buildCodeSummaryKeyCte(code_keys))
    if (medication_available && length(links)) {
      ctes <- c(ctes, buildCodeSummaryChunkMedicationCte(medication_sources))
    }
  }
  if (global_identities && !chunked_codes) {
    ctes <- c(ctes, buildCodeSummaryUsageIdentityCtes(sources, links, systems))
  }
  views <- unique(vapply(c(sources, links), function(source) quoteTable(source$schema, source$view), character(1)))
  source_ctes <- character(length(views))
  medication_views <- logical(length(views))
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
    medication_views[[index]] <- any(vapply(view_sources, function(source) source$resource == "Medication", logical(1)))
    if (filter_cases) {
      selected_cases <- unique(vapply(view_sources, caseFilterSql, character(1)))
      case_filter <- paste0("(", paste(selected_cases, collapse = " OR "), ")")
      if (medication_views[[index]] && global_identities) {
        ids <- unique(vapply(view_sources, function(source) {
          paste0("'Medication/' || ", codeSummaryFieldSql(source$fields, "resource_id"))
        }, character(1)))
        case_filter <- paste0(case_filter, " OR EXISTS (SELECT 1 FROM selected_medication_refs r WHERE r.medication_ref IN (", paste(ids, collapse = ","), "))")
      }
      filters <- c(if (length(filters)) paste0("(", paste(filters, collapse = " OR "), ")"), paste0("(", case_filter, ")"))
    }
    if (chunked_codes) {
      coding_sources <- Filter(function(source) !is.null(source$coding), view_sources)
      key_filters <- unique(vapply(coding_sources, codeFilterSql, character(1)))
      view_links <- Filter(function(source) source$resource %in% link_kinds && is.null(source$coding), view_sources)
      if (medication_available && length(view_links)) {
        key_filters <- c(key_filters, vapply(view_links, function(source) {
          paste0(
            "EXISTS (SELECT 1 FROM chunk_medication_ids m WHERE 'Medication/' || m.id=",
            codeSummaryReferenceSql(codeSummaryFieldSql(source$fields, "medication_ref"), "Medication"), ")"
          )
        }, character(1)))
      }
      filters <- c(
        if (length(filters)) paste0("(", paste(filters, collapse = if (filter_cases) " AND " else " OR "), ")"),
        paste0("(", paste(key_filters, collapse = " OR "), ")")
      )
    }
    source_ctes[[index]] <- paste0(
      "source_", index, " AS ", if (cache_measurements) "MATERIALIZED ", "(SELECT ",
      paste(vapply(columns, quoteIdentifier, character(1)), collapse = ", "),
      " FROM ", views[[index]], " s",
      if (length(filters)) paste0(" WHERE ", paste(filters, collapse = if (filter_cases || chunked_codes) " AND " else " OR ")), ")"
    )
  }
  sourceName <- function(source) {
    paste0("source_", match(quoteTable(source$schema, source$view), views))
  }
  ctes <- c(ctes, if (global_identities || filter_cases) source_ctes[!medication_views] else source_ctes)
  if (length(links)) {
    link_selects <- lapply(links, function(source) {
      fieldSql <- function(name) codeSummaryFieldSql(source$fields, name)
      paste0(
        "SELECT ", quoteSqlString(source$resource), " AS kind, ", fieldSql("resource_id"), " AS own_id, ",
        codeSummaryReferenceSql(fieldSql("medication_ref"), "Medication"), " AS medication_ref, ",
        codeSummaryReferenceSql(fieldSql("pid"), "Patient"), " AS pid, ",
        codeSummaryReferenceSql(fieldSql("case_id"), "Encounter"), " AS case_id FROM ", sourceName(source), " s",
        if (filter_cases) paste0(" WHERE ", caseFilterSql(source))
      )
    })
    ctes <- c(ctes, paste0("links AS MATERIALIZED (SELECT DISTINCT * FROM (", paste(link_selects, collapse = " UNION ALL "), ") linked_resources)"))
  }
  if (global_identities) {
    # An ID can occur in several cases. Retain all reference identities for any
    # selected usage ID, including references stored on another row of that ID.
    usage_sources <- Filter(function(source) source$resource %in% link_kinds, c(sources, links))
    usage_ids <- unique(vapply(usage_sources, function(source) {
      paste0(
        "SELECT ", quoteSqlString(source$resource), " AS kind, ",
        codeSummaryFieldSql(source$fields, "resource_id"), " AS own_id FROM ", sourceName(source), " s"
      )
    }, character(1)))
    ctes <- c(ctes, paste0(
      "selected_usage_ids AS MATERIALIZED (SELECT DISTINCT kind,own_id FROM (",
      paste(usage_ids, collapse = " UNION ALL "), ") ids WHERE own_id IS NOT NULL)"
    ))
    if (chunked_codes) {
      ctes <- c(ctes, buildCodeSummaryUsageIdentityCtes(sources, links, systems,
        include_direct_codes = FALSE, chunk_identity = TRUE
      ))
    }
    ctes <- c(ctes, paste0(
      "selected_medication_refs AS MATERIALIZED (SELECT DISTINCT r.medication_ref FROM reference_links r ",
      "JOIN selected_usage_ids u ON u.kind=r.kind AND u.own_id=r.own_id WHERE r.medication_ref IS NOT NULL)"
    ))
  }
  if (global_identities || filter_cases) ctes <- c(ctes, source_ctes[medication_views])
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
    slim_total <- query_mode == "totals" && !source$resource %in% c("Medication", link_kinds)
    parts <- c(
      paste0("CASE ", paste(report_cases, collapse = " "), " END AS report"),
      paste0(fieldSql("system"), " AS system"),
      paste0(if (slim_total) "NULL::text" else quoteSqlString(source$coding), " AS coding_path"),
      paste0(if (slim_total) "NULL::text" else fieldSql("version"), " AS version"),
      paste0(if (slim_total) "'present'::text" else fieldSql("code"), " AS code"),
      paste0(quoteSqlString(source$resource), " AS kind"),
      paste0(fieldSql("resource_id"), " AS own_id"),
      paste0(codeSummaryReferenceSql(patient_reference, "Patient"), " AS pid"),
      paste0(codeSummaryReferenceSql(fieldSql("case_id"), "Encounter"), " AS case_id"),
      paste0(measurementFieldSql("unit"), " AS unit"),
      paste0(measurementFieldSql("unit_system"), " AS unit_system"),
      paste0(measurementFieldSql("low"), " AS low"),
      paste0(measurementFieldSql("high"), " AS high"),
      paste0(measurementFieldSql("value", numeric = TRUE), " AS value"),
      paste0(if (query_mode == "catalog" && isTRUE(source$catalog_measurement)) "true" else source_measurement_condition, " AS is_measurement"),
      paste0("CASE WHEN ", source_measurement_condition, " THEN ", range_priority, " ELSE 0 END AS range_priority")
    )
    paste0(
      "SELECT ", paste(parts, collapse = ", "), " WHERE ", fieldSql("system"), " IN (",
      paste(vapply(unique(unlist(systems[source$reports])), quoteSqlString, character(1)), collapse = ", "), ")",
      if (filter_cases && source$resource != "Medication") paste0(" AND ", caseFilterSql(source)),
      if (chunked_codes) paste0(" AND ", codeFilterSql(source)),
      if (slim_total) paste0(" AND ", fieldSql("code"), " IS NOT NULL")
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
  if (query_mode == "catalog") {
    catalog_codes <- paste0(
      "SELECT system,code,kind,own_id,is_measurement FROM (", paste(code_selects, collapse = " UNION ALL "),
      ") codes WHERE report IS NOT NULL AND code IS NOT NULL AND own_id IS NOT NULL"
    )
    catalog_counts <- "SELECT system,code,COUNT(*)::double precision AS source_rows,MAX(CASE WHEN is_measurement THEN 1 ELSE 0 END) AS measurement FROM catalog_codes GROUP BY system,code"
    if (medication_available && length(links)) {
      # Linked usages without a direct code also contribute processing volume.
      catalog_counts <- paste0(
        catalog_counts, " UNION ALL SELECT c.system,c.code,COUNT(*)::double precision,MAX(CASE WHEN c.is_measurement THEN 1 ELSE 0 END) FROM catalog_codes c ",
        "JOIN links l ON l.medication_ref='Medication/' || c.own_id WHERE c.kind='Medication' AND l.own_id IS NOT NULL GROUP BY c.system,c.code"
      )
    }
    return(paste0(
      "/* INTERPOLAR DQA code catalog */\nWITH ", paste(ctes, collapse = ",\n"),
      ", catalog_codes AS (", catalog_codes, ") SELECT system,code,SUM(source_rows)::double precision AS source_rows,MAX(measurement) AS measurement FROM (",
      catalog_counts, ") counts GROUP BY system,code ORDER BY system,code"
    ))
  }
  ctes <- c(ctes, paste0(
    "raw_codings AS ", if (cache_measurements) "MATERIALIZED ", "(SELECT DISTINCT * FROM (",
    paste(code_selects, collapse = " UNION ALL "),
    ") codes WHERE report IS NOT NULL AND code IS NOT NULL AND own_id IS NOT NULL)"
  ))
  coding_columns <- "report,system,coding_path,version,code,kind,own_id,pid,case_id,unit,unit_system,low,high,value"
  if (!any(measurement_sources)) {
    # All omitted raw columns are constant here. raw_codings already deduplicated
    # these rows; an extra UNION/DISTINCT or range window would only sort them again.
    ctes <- c(ctes, paste0("codings AS ", if (query_mode == "combined") "MATERIALIZED ", "(SELECT ", coding_columns, " FROM raw_codings)"))
  } else {
    ctes <- c(ctes, paste0(
      "ranked_codings AS (SELECT *, MAX(range_priority) OVER (PARTITION BY ",
      "report,system,coding_path,kind,own_id,version,code,pid,case_id,unit,unit_system,value) AS preferred_range_priority ",
      "FROM raw_codings", if (!all(measurement_sources)) " WHERE is_measurement", ")"
    ))
    # Priority zero preserves coded observations without eligible limits.
    ctes <- c(ctes, paste0(
      "codings AS ", if (query_mode == "combined") "MATERIALIZED ", "(SELECT DISTINCT report,system,coding_path,version,code,kind,own_id,pid,case_id,unit,unit_system, ",
      "CASE WHEN range_priority > 0 THEN low END AS low, ",
      "CASE WHEN range_priority > 0 THEN high END AS high, value FROM ranked_codings ",
      "WHERE range_priority = preferred_range_priority",
      if (!all(measurement_sources)) paste0(" UNION SELECT ", coding_columns, " FROM raw_codings WHERE NOT is_measurement"), ")"
    ))
  }

  usage_condition <- if (length(link_kinds)) {
    paste0("c.kind IN (", paste(vapply(link_kinds, quoteSqlString, character(1)), collapse = ", "), ")")
  } else "false"
  # Only usage codings need reference resolution. Joining every Observation to
  # all Medication codings produced quadratic nested loops on large databases.
  if (medication_available && length(links)) {
    medication_source <- medication_sources[[1]]
    ctes <- c(ctes, paste0(
      "medication_ids AS MATERIALIZED (SELECT DISTINCT ",
      quoteIdentifier(medication_source$fields[["resource_id"]]), "::text AS id FROM ",
      if (global_identities) quoteTable(medication_source$schema, medication_source$view) else sourceName(medication_source), ")"
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
      "referenced_medication_ids AS MATERIALIZED (SELECT DISTINCT medication_ref FROM ",
      if (global_identities) "reference_links " else "links ",
      "WHERE medication_ref IS NOT NULL)"
    ))
  }
  event_columns <- paste0(
    "c.system, CASE WHEN ", usage_condition, " THEN c.kind || '/' || c.coding_path ELSE c.coding_path END AS coding_path, ",
    "c.version,c.code,c.unit,c.unit_system,c.low,c.high, "
  )
  event_tail <- paste0(
    "c.kind || '/' || c.own_id AS event_key, c.kind,c.pid,c.case_id,",
    if (query_mode %in% c("combined", "statistics", "details_statistics")) "c.value" else "NULL::double precision", " AS value, "
  )
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
      " LEFT JOIN ", if (global_identities) "reference_links" else "links", " l ON l.kind=c.kind AND l.own_id=c.own_id ",
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
    if (include_diagnostics) {
      ctes <- c(ctes, paste0(
        "unresolved_links AS MATERIALIZED (SELECT DISTINCT l.* FROM links l ",
        "WHERE l.own_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM medication_ids m ",
        "WHERE l.medication_ref = 'Medication/' || m.id) ",
        "AND NOT EXISTS (SELECT 1 FROM ", if (global_identities) "direct_coding_ids" else "codings",
        " d WHERE d.kind = l.kind AND d.own_id = l.own_id ",
        if (!global_identities) "AND d.coding_path = 'medicationCodeableConcept/coding'", "))"
      ))
      events <- c(events, paste0(
        "SELECT 'Medication', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ",
        "l.kind || '/' || l.own_id, l.kind || '/' || l.own_id, l.kind, l.pid, l.case_id, ",
        "NULL::double precision,true,false FROM unresolved_links l"
      ))
    }
  }
  ctes <- c(ctes, paste0("raw_events AS (", paste(events, collapse = " UNION ALL "), ")"))
  if (!is.null(case_groups_query) || !is.null(case_scope_query)) {
    fallback_scopes <- if ("all" %in% names(conditions)) "ARRAY['all']::text[]" else "ARRAY[]::text[]"
    # Restricted bucket counts can be severely underestimated. A FULL equality
    # join requires a hash/merge plan instead of a quadratic nested loop. Cases
    # without an event emit an empty array, preserving the LEFT-join result.
    scope_array <- paste0("COALESCE(s.report_scopes,", fallback_scopes, ")")
    if (filter_cases) scope_array <- paste0("CASE WHEN e.count_key IS NULL THEN ARRAY[]::text[] ELSE ", scope_array, " END")
    scoped_events <- paste0(
      "SELECT v.report_scope,e.* FROM raw_events e ", if (filter_cases) "FULL" else "LEFT",
      " JOIN scope_buckets s ON s.case_id=e.case_id ",
      "CROSS JOIN LATERAL unnest(", scope_array, ") v(report_scope)"
    )
  } else {
    scoped_events <- "SELECT 'all'::text AS report_scope,e.* FROM raw_events e"
  }
  # Reuse only the selected chunk's resolved events for counts and statistics.
  # Materializing here avoids repeating source reads and range selection, without
  # keeping separate wide source/Coding/label caches as in the combined mode.
  ctes <- c(ctes, paste0(
    "scoped_events AS ", if (query_mode == "details_statistics") "MATERIALIZED ",
    "(", scoped_events, ")"
  ))
  if (query_mode == "details_statistics") {
    return(buildCodeSummaryDetailQuery(ctes, collect_statistics = any(measurement_sources)))
  }
  if (query_mode == "details") return(buildCodeSummaryDetailQuery(ctes))
  if (query_mode == "statistics") return(buildCodeSummaryStatisticsQuery(ctes))
  if (query_mode %in% c("totals", "rare")) {
    return(buildCodeSummaryCompactQuery(ctes, query_mode, rare_groups))
  }
  dimensions <- "report_scope, report, system, coding_path, version, code, unit, unit_system, low, high"
  # Both exports retain every combination; masking is applied during CSV export.
  ctes <- c(
    ctes,
    paste0(
      "events AS MATERIALIZED (SELECT *, ARRAY[", dimensions,
      "] AS combination_id FROM scoped_events)"
    ),
    paste0(
      "labelled AS ", if (collect_statistics) "MATERIALIZED ", "(SELECT e.*, 'both'::text AS export_target, ",
      "CASE WHEN e.unresolved THEN 'unresolved medication reference' ELSE 'detail' END AS row_type FROM events e)"
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
      if (query_mode == "combined") paste0(
        "UNION ALL SELECT report_scope,'both',report, system, NULL::text, 'total', NULL,NULL,NULL,NULL,NULL,NULL, ",
        "count_key,event_key,kind,pid,case_id,NULL::double precision,false,unreferenced_medication ",
        "FROM events WHERE NOT unresolved"
      ), ")"
    ),
    # NULL-safe array keys avoid ranking the full event stream. Summary keys
    # are built only after aggregation, not stored beside every input event.
    paste0("grouped AS ", if (collect_statistics) "MATERIALIZED ", "(SELECT * FROM group_labels)"),
    buildCodeSummaryCountsCte()
  )
  if (collect_statistics) {
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

  buildCodeSummaryResultQuery(ctes, collect_statistics)
}
