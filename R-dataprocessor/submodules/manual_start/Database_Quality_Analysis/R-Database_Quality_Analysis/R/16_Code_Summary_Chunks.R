#' Plan serial batches of complete code groups, isolating oversized codes
planCodeSummaryChunks <- function(catalog, processing) {
  if (!nrow(catalog)) return(list())
  catalog <- data.table::copy(catalog)
  catalog[, source_rows := as.numeric(source_rows)]
  if (anyNA(catalog$source_rows) || any(!is.finite(catalog$source_rows)) || any(catalog$source_rows < 0)) {
    stop("Invalid code catalog row estimates.", call. = FALSE)
  }
  data.table::setorderv(catalog, c("source_rows", "system", "code"), c(-1L, 1L, 1L))
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

#' Execute code-group counts/statistics and independent cross-code summaries
#'
#' Reuses source/reference resolution and all exact SQL aggregation rules. Only
#' aggregate code/group metadata leaves SQL. No partial medians or ID counts are
#' combined in R. A hot code stays intact and runs in its own count/statistic passes.
runCodeSummaryChunks <- function(sources, links, config, report_types, case_scope_query,
                                 case_groups_query, export_variants, label, query_fun) {
  processing <- parseCodeSummaryProcessing(config$code_summary_processing)
  dimensions <- c("report_scope", "report", "system", "coding_path", "version", "code", "unit", "unit_system", "low", "high")
  statistics_columns <- c("median", "q1", "q3", "mean", "sd", "minimum", "maximum")
  runPass <- function(mode, keys = NULL, rare = NULL, pass_label = mode) {
    query <- buildCodeSummaryQuery(sources, links, config$code_summary_systems,
      config$code_summary_normal_range, report_types,
      case_scope_query = case_scope_query, case_groups_query = case_groups_query,
      export_variants = if (mode == "rare") unique(rare$report_scope) else export_variants,
      query_mode = mode, code_keys = keys, rare_groups = rare
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
  rare_rows <- list()
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
    detail <- runPass("details", chunk, pass_label = paste0(chunk_label, "; counts"))
    if (!nrow(detail)) next
    detail <- detail[row_type == "detail"]
    if (!nrow(detail)) next
    rare_rows[[length(rare_rows) + 1L]] <- unique(detail[export_target == "local" & count < 5, ..dimensions])
    if (measurements && (!"measurement" %in% names(chunk) || any(chunk$measurement == 1L))) {
      stats <- runPass("statistics", chunk, pass_label = paste0(chunk_label, "; exact statistics"))
      if (nrow(stats)) {
        keys <- c(dimensions, "row_type")
        stats <- stats[, c(keys, statistics_columns), with = FALSE]
        # One metadata group can feed both exports. NA keys match just as in SQL.
        detail[, (statistics_columns) := NULL]
        detail <- merge(detail, stats, by = keys, all.x = TRUE, sort = FALSE)
      }
    }
    rows[[length(rows) + 1L]] <- detail
  }
  rare <- data.table::rbindlist(rare_rows, use.names = TRUE, fill = TRUE)
  if (nrow(rare)) {
    rare <- unique(rare)
    pools <- unique(rare[, c("report_scope", "report", "system", "coding_path"), with = FALSE])
    for (index in seq_len(nrow(pools))) {
      pool <- rare[pools[index], on = c("report_scope", "report", "system", "coding_path"), nomatch = 0L]
      keys <- unique(pool[, c("system", "code"), with = FALSE])
      rows[[length(rows) + 1L]] <- runPass(
        "rare", keys, pool,
        paste0("exact rare pool ", index, "/", nrow(pools))
      )
    }
  }
  result <- data.table::rbindlist(rows, use.names = TRUE, fill = TRUE)
  if (nrow(result)) {
    data.table::setorderv(result, c("report_scope", "export_target", "report", "system", "coding_path", "row_type", "version", "code", "unit", "unit_system", "low", "high"), na.last = TRUE)
  }
  result
}
