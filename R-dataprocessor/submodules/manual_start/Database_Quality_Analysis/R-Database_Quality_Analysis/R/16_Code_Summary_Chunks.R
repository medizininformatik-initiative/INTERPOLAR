# Stop counting as soon as the source-row budget is exceeded. Coding and link
# mappings can share a view, so each physical row is probed at most once.
buildCodeSummarySizeProbe <- function(sources, links, target_rows) {
  views <- unique(vapply(c(sources, links), function(source) {
    quoteTable(source$schema, source$view)
  }, character(1)))
  paste0(
    "/* INTERPOLAR DQA code size probe */ SELECT COUNT(*) AS source_rows FROM (",
    paste0("SELECT 1 FROM ", views, collapse = " UNION ALL "),
    " LIMIT ", format(target_rows + 1, scientific = FALSE, trim = TRUE), ") probe"
  )
}

#' Plan serial batches of complete code groups, isolating oversized codes
planCodeSummaryChunks <- function(catalog, processing) {
  if (!nrow(catalog)) return(list())
  catalog <- data.table::copy(catalog)
  catalog[, source_rows := as.numeric(source_rows)]
  if (anyNA(catalog$source_rows) || any(!is.finite(catalog$source_rows)) || any(catalog$source_rows < 0)) {
    stop("Invalid code catalog row estimates.", call. = FALSE)
  }
  # Keep oversized codes first so they never interrupt packing the smaller
  # groups from adjacent partitions.
  catalog[, oversized := source_rows > processing$target_rows_per_chunk]
  partition_column <- intersect("source_partition", names(catalog))
  data.table::setorderv(
    catalog, c("oversized", partition_column, "source_rows", "system", "code"),
    c(-1L, rep(1L, length(partition_column)), -1L, 1L, 1L)
  )
  catalog[, oversized := NULL]
  chunks <- list()
  indexes <- integer()
  size <- 0
  for (index in seq_len(nrow(catalog))) {
    next_size <- catalog$source_rows[[index]]
    if (length(indexes) && (size + next_size > processing$target_rows_per_chunk || length(indexes) >= processing$max_codes_per_chunk)) {
      chunks[[length(chunks) + 1L]] <- catalog[indexes]
      indexes <- integer()
      size <- 0
    }
    indexes <- c(indexes, index)
    size <- size + next_size
  }
  if (length(indexes)) chunks[[length(chunks) + 1L]] <- catalog[indexes]
  chunks
}

#' Standardize nullable textual group keys across database result batches
normalizeCodeSummaryGroupKeys <- function(rows, columns) {
  for (column in intersect(columns, names(rows))) data.table::set(rows, j = column, value = as.character(rows[[column]]))
  rows
}

#' Execute code-group counts/statistics and independent cross-code totals
#'
#' Reuses source/reference resolution and all exact SQL aggregation rules. Only
#' aggregate code/group metadata leaves SQL. No partial medians or ID counts are
#' combined in R. A hot code stays intact and runs in its own shared detail pass.
runCodeSummaryChunks <- function(sources, links, config, report_types, case_scope_query,
                                 case_groups_query, export_variants, label, query_fun,
                                 include_no_version = FALSE) {
  processing <- parseCodeSummaryProcessing(config$code_summary_processing)
  dimensions <- c("report_scope", "report", "system", "coding_path", "version", "code", "unit", "unit_system", "low", "high", "range_type", "range_type_system", "age_low", "age_low_unit", "age_low_code", "age_low_system", "age_high", "age_high_unit", "age_high_code", "age_high_system")
  runPass <- function(mode, keys = NULL, pass_label = mode) {
    query <- buildCodeSummaryQuery(sources, links, config$code_summary_systems,
      report_types,
      case_scope_query = case_scope_query, case_groups_query = case_groups_query,
      export_variants = export_variants,
      query_mode = mode, code_keys = keys, include_no_version = include_no_version
    )
    if (is.na(query)) return(data.table::data.table())
    rows <- data.table::as.data.table(runLoggedQuery(
      query,
      query_fun = query_fun, config = config,
      label = paste0("Code summary SQL ", label, "; ", pass_label),
      lock_id = getDatabaseQualityAnalysisLockId(config, "calculate code summary")
    ))
    normalizeCodeSummaryGroupKeys(rows, c(dimensions, "row_type", "export_target"))
  }
  catalog <- runPass("catalog")
  chunks <- planCodeSummaryChunks(catalog, processing)
  logProgress(
    "Code summary ", label, ": ", nrow(catalog), " code groups in ", length(chunks),
    " serial chunks; target ", processing$target_rows_per_chunk, " source rows, at most ", processing$max_codes_per_chunk, " codes per chunk."
  )
  rows <- list(runPass("totals", pass_label = "exact cross-code totals and diagnostics"))
  measurements <- any(vapply(sources, function(source) isTRUE(source$measurement), logical(1)))
  for (index in seq_along(chunks)) {
    chunk <- chunks[[index]]
    estimate <- sum(chunk$source_rows)
    chunk_label <- paste0("chunk ", index, "/", length(chunks), "; ", nrow(chunk), " codes; estimated ", estimate, " source rows")
    if (estimate > processing$target_rows_per_chunk) {
      logProgress(
        "Code summary ", label, ": oversized code ", chunk$system[[1]], " / ", chunk$code[[1]],
        " runs alone; its exact statistics require all values of this code."
      )
    }
    has_measurements <- measurements && (!"measurement" %in% names(chunk) || any(chunk$measurement == 1L))
    detail <- runPass(
      if (has_measurements) "details_statistics" else "details", chunk,
      pass_label = paste0(chunk_label, if (has_measurements) "; counts and exact statistics (shared preparation)" else "; counts")
    )
    if (!nrow(detail)) next
    detail <- detail[row_type == "detail"]
    if (!nrow(detail)) next
    rows[[length(rows) + 1L]] <- detail
  }
  result <- data.table::rbindlist(rows, use.names = TRUE, fill = TRUE)
  if (nrow(result)) {
    data.table::setorderv(result, c("report_scope", "export_target", "report", "system", "coding_path", "row_type", "version", "code", "unit", "unit_system", "low", "high", "range_type", "range_type_system", "age_low", "age_low_unit", "age_low_code", "age_low_system", "age_high", "age_high_unit", "age_high_code", "age_high_system"), na.last = TRUE)
  }
  result
}

isClinicalCodeSummary <- function(sources, links) {
  medication_resources <- c("Medication", "MedicationRequest", "MedicationAdministration", "MedicationStatement")
  !length(links) && !any(vapply(sources, function(source) source$resource %in% medication_resources, logical(1)))
}

# Route each system/code pair to one temporary partition during the initial write.
# The frequency catalog can then pack nearby code groups without rescanning the
# entire prepared data set for each batch.
buildCodeSummaryStageCommands <- function(stage_query) {
  partitions <- seq_len(16L) - 1L
  c(
    paste0("CREATE TEMP TABLE dqa_code_event_shape AS ", stage_query, " WITH NO DATA"),
    "CREATE TEMP TABLE dqa_code_events (LIKE pg_temp.dqa_code_event_shape) PARTITION BY HASH (system,code)",
    sprintf(
      "CREATE TEMP TABLE dqa_code_events_%d PARTITION OF pg_temp.dqa_code_events FOR VALUES WITH (MODULUS %d, REMAINDER %d)",
      partitions, length(partitions), partitions
    ),
    paste0("INSERT INTO pg_temp.dqa_code_events ", stage_query)
  )
}

buildCodeSummaryStageCatalog <- function() {
  paste(
    "SELECT c.*,r.relname AS source_partition FROM (",
    "SELECT tableoid,system,code,SUM(cardinality(report_scopes))::double precision AS source_rows,",
    "MAX(CASE WHEN value IS NOT NULL THEN 1 ELSE 0 END) AS measurement",
    "FROM pg_temp.dqa_code_events WHERE NOT unresolved GROUP BY tableoid,system,code",
    ") c JOIN pg_catalog.pg_class r ON r.oid=c.tableoid"
  )
}

# Resolve sources once per reporting session. Store scope membership with each
# event, expand it only for the current pass, and leave all raw rows in PostgreSQL.
runStagedCodeSummary <- function(connection, sources, links, config, report_types,
                                 case_scope_query, case_groups_query, export_variants, label, processing) {
  capability <- DBI::dbGetQuery(connection, paste(
    "SELECT has_database_privilege(current_database(),'TEMP')",
    "AND current_setting('transaction_read_only')='off' AS can_stage"
  ))
  if (!isTRUE(capability$can_stage[[1L]])) {
    logProgress(label, ": temporary tables unavailable; using serial queries on the source views.")
    return(NULL)
  }

  runPass <- function(query, suffix, execute = FALSE) {
    runLoggedQuery(
      query,
      config = config, label = paste0(label, "; ", suffix),
      query_fun = function(query, lock_id) {
        if (execute) invisible(DBI::dbExecute(connection, query)) else data.table::as.data.table(DBI::dbGetQuery(connection, query))
      }
    )
  }
  stage_query <- buildCodeSummaryQuery(sources, links, config$code_summary_systems, report_types,
    case_scope_query = case_scope_query, case_groups_query = case_groups_query,
    export_variants = export_variants, query_mode = "stage", include_no_version = TRUE
  )
  commands <- buildCodeSummaryStageCommands(stage_query)
  DBI::dbExecute(connection, paste(commands[-length(commands)], collapse = ";\n"), immediate = TRUE)
  runPass(utils::tail(commands, 1L), "preparing scoped events", execute = TRUE)
  runPass("ANALYZE pg_temp.dqa_code_events", "analyzing scoped events", execute = TRUE)
  catalog <- runPass(buildCodeSummaryStageCatalog(), "code frequencies")
  chunks <- planCodeSummaryChunks(catalog, processing)
  logProgress(label, ": ", nrow(catalog), " system/code groups in ", length(chunks), " serial chunks.")
  clinical_cases_only <- isClinicalCodeSummary(sources, links) && !"all" %in% export_variants
  # Cross-code totals still need complete resource identities. They cannot
  # be recovered by summing the per-code patient, case or resource counts.
  rows <- list(runPass(
    buildStagedCodeSummaryPass("totals", clinical_cases_only,
      observation_only = all(vapply(sources, function(source) source$resource == "Observation", logical(1)))
    ),
    "exact cross-code totals and diagnostics"
  ))
  for (index in seq_along(chunks)) {
    keys <- chunks[[index]]
    # A hot code can still be split by report scope: every statistic and
    # distinct count is scoped, so each exact group remains in a single pass.
    scopes <- if (sum(keys$source_rows) > processing$target_rows_per_chunk) export_variants else NA_character_
    for (scope in scopes) {
      rows[[length(rows) + 1L]] <- runPass(
        buildStagedCodeSummaryPass(
          "details_statistics", clinical_cases_only,
          keys, any(keys$measurement == 1L), scope
        ),
        paste0(
          "chunk ", index, "/", length(chunks), "; ", nrow(keys), " codes",
          if (!is.na(scope)) paste0("; ", scope)
        )
      )
    }
  }
  data.table::rbindlist(rows, use.names = TRUE, fill = TRUE)
}

buildStagedCodeSummaryPass <- function(mode, clinical_cases_only,
                                       keys = NULL, measurements = FALSE, scope = NA_character_, observation_only = FALSE) {
  partitions <- unique(keys$source_partition)
  from <- "pg_temp.dqa_code_events e"
  if (length(partitions)) {
    tables <- vapply(partitions, function(partition) quoteTable("pg_temp", partition), character(1))
    from <- if (length(tables) == 1L) {
      paste(tables, "e")
    } else {
      paste0("(", paste("SELECT * FROM", tables, collapse = " UNION ALL "), ") e")
    }
  }
  scope_column <- "v.report_scope"
  filters <- character()
  if (!is.na(scope)) {
    scope_column <- paste0(quoteSqlString(scope), "::text AS report_scope")
    filters <- paste0(quoteSqlString(scope), "=ANY(e.report_scopes)")
  } else {
    from <- paste(from, "CROSS JOIN LATERAL unnest(e.report_scopes) v(report_scope)")
  }
  if (!is.null(keys)) {
    filters <- c(filters, buildCodeSummaryKeyPredicate(keys, "e.system", "e.code"))
  }
  where <- if (length(filters)) paste("WHERE", paste(filters, collapse = " AND ")) else ""
  # Materialize bounded chunks once. Oversized per-scope chunks and totals
  # avoid a second on-disk copy, even if their scans must be repeated.
  materialized <- !is.null(keys) && is.na(scope)
  ctes <- paste0(
    "scoped_events AS ", if (materialized) "MATERIALIZED" else "NOT MATERIALIZED",
    " (SELECT ", scope_column, ",e.* FROM ", from, " ", where, ")"
  )
  buildCodeSummaryNoVersionQuery(ctes, mode, measurements, clinical_cases_only, observation_only)
}
