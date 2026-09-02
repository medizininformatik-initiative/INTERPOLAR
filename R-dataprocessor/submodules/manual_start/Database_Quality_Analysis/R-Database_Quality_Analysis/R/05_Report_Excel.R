#' Apply count query results
#'
#' Writes count query aliases back into the corresponding report rows.
applyCountQueryResult <- function(result, table_name, count_query, count_result) {
  for (row_index in seq_len(nrow(count_query$alias_map))) {
    alias_row <- count_query$alias_map[row_index]
    result[
      TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
      (alias_row$count_column) := as.integer(count_result[[alias_row$alias]][[1]])
    ]
  }
  invisible(result)
}

#' Apply value date range query results
#'
#' Writes first and last value timestamps back into the corresponding report rows.
applyDateRangeQueryResult <- function(result, table_name, date_range_query, date_range_result) {
  for (row_index in seq_len(nrow(date_range_query$alias_map))) {
    alias_row <- date_range_query$alias_map[row_index]
    result[
      TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
      (alias_row$first_result_column) := date_range_result[[alias_row$first_alias]][[1]]
    ]
    result[
      TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
      (alias_row$last_result_column) := date_range_result[[alias_row$last_alias]][[1]]
    ]
  }
  invisible(result)
}

#' Fill count and date range columns
#'
#' Runs the batched count and optional date-range queries for one table batch.
fillCountAndDateRangeColumns <- function(
  result,
  table_name,
  table_metadata,
  grouping_columns,
  data_column_batch,
  config,
  history_metadata = NULL,
  query_fun = etlutils::dbGetReadOnlyQuery,
  row_filter_condition = NA_character_,
  lock_label = NULL
) {
  if (is.null(lock_label)) {
    lock_label <- table_name
  }

  count_query <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_column_batch,
    row_filter_condition = row_filter_condition,
    config = config
  )
  if (!is.na(count_query$query)) {
    count_result <- query_fun(
      count_query$query,
      lock_id = getDatabaseQualityAnalysisLockId(
        config,
        paste0("calculate database quality analysis counts for ", lock_label)
      )
    )
    applyCountQueryResult(result, table_name, count_query, count_result)
  }

  if (isTRUE(config$include_value_datetime_columns)) {
    date_range_query <- buildValueDateRangeQuery(
      table_metadata,
      history_metadata,
      config,
      data_column_batch,
      row_filter_condition = row_filter_condition
    )
    if (!is.na(date_range_query$query)) {
      date_range_result <- query_fun(
        date_range_query$query,
        lock_id = getDatabaseQualityAnalysisLockId(
          config,
          paste0(
            "calculate database quality analysis value date ranges for ",
            lock_label
          )
        )
      )
      applyDateRangeQueryResult(result, table_name, date_range_query, date_range_result)
    }
  }

  invisible(result)
}

#' Calculate availability counts
#'
#' Builds the main availability result table for all configured metadata rows.
calculateCounts <- function(
  metadata,
  config,
  query_fun = etlutils::dbGetReadOnlyQuery,
  history_metadata = NULL
) {
  result <- unique(metadata[, .(TABLE_FAMILY, TABLE_NAME, COLUMN_NAME, COLUMN_DESCRIPTION, ORDINAL_POSITION)])
  result[, RESOURCE_REFERENCE_SCOPE := NA_character_]
  result[, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := NA_character_]
  if (isTRUE(config$include_value_datetime_columns)) {
    result[, (DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS) := as.POSIXct(NA)]
  }
  for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
    result[, (count_column) := NA_integer_]
  }

  table_names <- unique(metadata$TABLE_NAME)
  for (table_index in seq_along(table_names)) {
    table_start_time <- Sys.time()
    table_name <- table_names[[table_index]]
    table_metadata <- metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
    grouping_columns <- inferGroupingColumns(table_metadata, config)
    result[
      TABLE_NAME == table_name,
      RESOURCE_REFERENCE_SCOPE := getResourceReferenceScope(grouping_columns, table_metadata)
    ]
    table_result <- result[TABLE_NAME == table_name]
    table_result <- addGroupingRoles(table_result, grouping_columns)
    result[TABLE_NAME == table_name, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) :=
      table_result[[DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN]]]

    data_columns <- table_metadata$COLUMN_NAME
    column_batches <- split(data_columns, ceiling(seq_along(data_columns) / config$count_batch_size))
    logProgress(
      "Table ",
      table_index,
      "/",
      length(table_names),
      " ",
      table_name,
      " (",
      table_metadata$TABLE_FAMILY[[1]],
      "): ",
      formatCountLabel(length(data_columns), "column"),
      ", ",
      formatCountLabel(length(column_batches), "batch", "batches"),
      ", value datetime columns ",
      if (isTRUE(config$include_value_datetime_columns)) "enabled" else "disabled",
      "."
    )

    for (batch_index in seq_along(column_batches)) {
      data_column_batch <- column_batches[[batch_index]]
      if (length(column_batches) > 1L) {
        logProgress(
          "Table ",
          table_name,
          ": batch ",
          batch_index,
          "/",
          length(column_batches),
          " with ",
          formatCountLabel(length(data_column_batch), "column"),
          "."
        )
      }

      fillCountAndDateRangeColumns(
        result,
        table_name,
        table_metadata,
        grouping_columns,
        data_column_batch,
        config,
        history_metadata = history_metadata,
        query_fun = query_fun
      )
    }
    logProgress(
      "Finished table ",
      table_name,
      " in ",
      formatDuration(table_start_time),
      "."
    )
  }

  data.table::setcolorder(result, c(
    "TABLE_NAME",
    "COLUMN_NAME",
    "COLUMN_DESCRIPTION",
    DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN,
    DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS,
    intersect(DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS, names(result)),
    "TABLE_FAMILY",
    "RESOURCE_REFERENCE_SCOPE",
    "ORDINAL_POSITION"
  ))
  orderByResourceReferenceScope(result)
}
#' Describe a report sheet
#'
#' Returns human-readable metadata used by the sheet description workbook tab.
getSheetDescription <- function(sheet_name, config = list()) {
  filtered_scope_label <- getFilteredScopeLabel(config)
  filtered_scope_fhir_sheet_name <- getFilteredScopeSheetName("FHIR", config)
  filtered_scope_detail_sheet_suffix <- getFilteredScopeDetailSheetSuffix(config)

  if (identical(sheet_name, "FHIR")) {
    return(list(
      description = "FHIR resource availability counts from last-version views.",
      filter_scope = "All FHIR rows included in the configured views.",
      count_logic = "Counts filled values per resource ID, patient ID and case ID."
    ))
  }
  if (identical(sheet_name, filtered_scope_fhir_sheet_name)) {
    return(list(
      description = paste("FHIR resource availability counts restricted to the", filtered_scope_label, "scope."),
      filter_scope = paste(
        "Patient-dependent resources are filtered to patients in the configured scope;",
        "case-dependent resources are filtered to cases in the configured scope;",
        "case- and patient-independent resources are excluded."
      ),
      count_logic = "Same count columns as FHIR, calculated after applying the filtered scope."
    ))
  }
  if (identical(sheet_name, "Frontend")) {
    return(list(
      description = "Frontend table availability counts from last-version views.",
      filter_scope = "All configured frontend rows included.",
      count_logic = "Counts filled values per resource ID, patient ID and case ID where available."
    ))
  }
  if (identical(sheet_name, "Other")) {
    return(list(
      description = "Additional configured views outside FHIR and Frontend.",
      filter_scope = "All rows from the configured additional views.",
      count_logic = "Counts filled values using configured or inferred grouping columns."
    ))
  }
  if (identical(sheet_name, "Metadata")) {
    return(list(
      description = "Technical metadata for the database quality analysis run.",
      filter_scope = "Not a data availability sheet.",
      count_logic = "Contains runtime, configuration and source metadata values."
    ))
  }
  if (nzchar(filtered_scope_detail_sheet_suffix) && endsWith(sheet_name, paste0(" ", filtered_scope_detail_sheet_suffix))) {
    return(list(
      description = paste("Resource detail sheet restricted to the", filtered_scope_label, "scope."),
      filter_scope = "Rows are filtered with the same filtered scope logic as the filtered FHIR sheet.",
      count_logic = "Uses the configured resource detail row groups and count groups after filtering."
    ))
  }
  return(list(
    description = "Configured resource detail sheet.",
    filter_scope = "All rows from the configured resource detail view.",
    count_logic = "Uses configured resource detail row groups and count groups."
  ))
}

#' Create the sheet description table
#'
#' Builds the workbook sheet that explains the generated report sheets.
createSheetDescriptionSheet <- function(sheet_names, config = list()) {
  rows <- lapply(sheet_names, function(sheet_name) {
    description <- getSheetDescription(sheet_name, config)
    data.table::data.table(
      SHEET_NAME = sheet_name,
      DESCRIPTION = description$description,
      FILTER_SCOPE = description$filter_scope,
      COUNT_LOGIC = description$count_logic
    )
  })
  data.table::rbindlist(rows, use.names = TRUE)
}

#' Prepend the sheet description tab
#'
#' Places the sheet description table before all generated report sheets.
prependSheetDescriptionSheet <- function(sheets, config = list()) {
  c(
    "Sheet Description" = list(createSheetDescriptionSheet(c(names(sheets), "Metadata"), config)),
    sheets
  )
}

#' Format a run timestamp
#'
#' Formats a timestamp for display in the metadata sheet.
formatRunTimestamp <- function(timestamp) {
  format(timestamp, "%Y-%m-%d %H:%M:%S UTC", tz = "UTC")
}

#' Format a timestamp for filenames
#'
#' Formats a timestamp for generated report file names.
formatFilenameTimestamp <- function(timestamp) {
  format(timestamp, "%Y-%m-%d_%H-%M-%S")
}

#' Collapse a config value for display
#'
#' Formats scalar and vector config values for the metadata sheet.
collapseConfigValue <- function(value) {
  if (length(value) == 0L) {
    return("")
  }
  paste(value, collapse = "; ")
}

#' Create the metadata sheet
#'
#' Builds technical run metadata for the generated Excel workbook.
createMetadataSheet <- function(
  result,
  source_metadata,
  config,
  analysis_start_time,
  analysis_end_time,
  database_metadata = NULL
) {
  add_row <- function(property, value) {
    data.table::data.table(PROPERTY = property, VALUE = as.character(value))
  }

  result_rows_by_family <- result[, .N, by = TABLE_FAMILY][order(TABLE_FAMILY)]
  table_counts_by_family <- unique(result[, .(TABLE_FAMILY, TABLE_NAME)])[
    ,
    .N,
    by = TABLE_FAMILY
  ][order(TABLE_FAMILY)]
  commented_columns <- source_metadata[
    !is.na(COLUMN_DESCRIPTION) & nzchar(COLUMN_DESCRIPTION)
  ]
  view_schemas <- unique(source_metadata$VIEW_SCHEMA)

  rows <- list(
    add_row("analysis started at", formatRunTimestamp(analysis_start_time)),
    add_row("analysis finished at", formatRunTimestamp(analysis_end_time)),
    add_row(
      "analysis duration seconds",
      round(as.numeric(difftime(analysis_end_time, analysis_start_time, units = "secs")), 2)
    ),
    add_row("view schema", collapseConfigValue(view_schemas)),
    add_row("view prefix", config$view_prefix),
    add_row("view postfix", config$view_postfix),
    add_row("included view patterns", collapseConfigValue(config$included_view_patterns)),
    add_row("excluded view patterns", collapseConfigValue(config$excluded_view_patterns)),
    add_row("additional views", collapseConfigValue(config$additional_views)),
    add_row("count batch size", config$count_batch_size),
    add_row("value datetime columns enabled", isTRUE(config$include_value_datetime_columns)),
    add_row("value import datetime column", config$value_import_datetime_column),
    add_row("grouping overrides", nrow(config$grouping_overrides)),
    add_row("source views", data.table::uniqueN(source_metadata$VIEW_NAME)),
    add_row("source columns", nrow(source_metadata)),
    add_row("source columns with description", nrow(commented_columns)),
    add_row("report rows", nrow(result))
  )

  for (row_index in seq_len(nrow(table_counts_by_family))) {
    family_row <- table_counts_by_family[row_index]
    rows <- c(rows, list(add_row(
      paste0("tables in ", family_row$TABLE_FAMILY),
      family_row$N
    )))
  }
  for (row_index in seq_len(nrow(result_rows_by_family))) {
    family_row <- result_rows_by_family[row_index]
    rows <- c(rows, list(add_row(
      paste0("report rows in ", family_row$TABLE_FAMILY),
      family_row$N
    )))
  }

  if (!is.null(database_metadata) && nrow(database_metadata)) {
    rows <- c(rows, list(
      add_row("database system", database_metadata$dbms[[1]]),
      add_row("database server version", database_metadata$server_version[[1]]),
      add_row("database server encoding", database_metadata$server_encoding[[1]])
    ))
  }

  data.table::rbindlist(rows, use.names = TRUE)
}

#' Split the availability result into sheets
#'
#' Separates the combined result table into FHIR, Frontend and Other sheets.
splitResultForExcel <- function(result) {
  output_columns <- setdiff(names(result), c("TABLE_FAMILY", "RESOURCE_REFERENCE_SCOPE", "ORDINAL_POSITION"))
  non_fhir_output_columns <- setdiff(
    output_columns,
    DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[c("first_meta_last_updated", "last_meta_last_updated")]
  )
  sheets <- list(
    FHIR = result[TABLE_FAMILY == "FHIR", ..output_columns],
    Frontend = result[TABLE_FAMILY == "Frontend", ..non_fhir_output_columns],
    Other = result[TABLE_FAMILY == "Other", ..non_fhir_output_columns]
  )
  sheets <- lapply(sheets, function(sheet) {
    for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
      if (!count_column %in% names(sheet)) {
        next
      }
      data.table::set(
        sheet,
        i = which(!is.na(sheet[[count_column]]) & sheet[[count_column]] == 0L),
        j = count_column,
        value = NA_integer_
      )
    }
    sheet
  })
  sheets[vapply(sheets, nrow, integer(1)) > 0L]
}

#' Format a sheet for Excel output
#'
#' Converts date-time columns to character values for stable Excel writing.
formatSheetForExcel <- function(sheet) {
  sheet <- data.table::as.data.table(data.table::copy(sheet))
  if (!nrow(sheet)) {
    return(sheet)
  }

  blank_row <- data.table::as.data.table(
    stats::setNames(
      as.list(rep(NA, ncol(sheet))),
      names(sheet)
    )
  )
  formatted_tables <- lapply(unique(sheet$TABLE_NAME), function(table_name) {
    table_rows <- sheet[TABLE_NAME == table_name]
    table_rows[-1, TABLE_NAME := NA_character_]
    data.table::rbindlist(list(table_rows, blank_row), use.names = TRUE)
  })
  data.table::rbindlist(formatted_tables, use.names = TRUE)
}

#' Get the count-summary output filename base
#'
#' Adds the count-summary suffix to the configured report basename.
getCountSummaryOutputFilename <- function(config) {
  paste(config$output_filename, "Count_Summary", sep = "_")
}

#' Write the Excel report
#'
#' Writes all report sheets to the configured output workbook.
writeExcelFile <- function(
  sheets,
  filename_without_extension,
  timestamp = Sys.time(),
  subdir = "reports",
  target = c("global", "local")
) {
  target <- match.arg(target)
  module_sub_dir <- file.path(
    if (identical(target, "global")) MODULE_DIRS$global_dir else MODULE_DIRS$local_dir,
    subdir
  )
  if (!dir.exists(module_sub_dir)) {
    dir.create(module_sub_dir, recursive = TRUE)
  }
  file_name <- file.path(
    module_sub_dir,
    paste0(
      filename_without_extension,
      "_",
      formatFilenameTimestamp(timestamp),
      ".xlsx"
    )
  )
  logProgress("Writing Excel report to ", file_name, ".")

  workbook <- openxlsx::createWorkbook()
  datetime_style <- openxlsx::createStyle(numFmt = "yyyy-mm-dd hh:mm:ss")
  for (sheet_name in names(sheets)) {
    sheet <- data.table::as.data.table(sheets[[sheet_name]])
    if ("TABLE_NAME" %in% names(sheet)) {
      sheet <- formatSheetForExcel(sheet)
    }
    openxlsx::addWorksheet(workbook, sheet_name)
    openxlsx::writeData(workbook, sheet_name, sheet, colNames = TRUE)
    datetime_columns <- match(DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS, names(sheet))
    datetime_columns <- datetime_columns[!is.na(datetime_columns)]
    if (length(datetime_columns) && nrow(sheet)) {
      openxlsx::addStyle(
        workbook,
        sheet = sheet_name,
        style = datetime_style,
        rows = seq_len(nrow(sheet)) + 1L,
        cols = datetime_columns,
        gridExpand = TRUE,
        stack = TRUE
      )
    }
    openxlsx::setColWidths(
      workbook,
      sheet = sheet_name,
      cols = seq_along(sheet),
      widths = "auto"
    )
  }
  openxlsx::saveWorkbook(workbook, file_name, overwrite = TRUE)
  logProgress("Excel report written to ", file_name, ".")
  invisible(file_name)
}

#' Create the database quality analysis report
#'
#' Orchestrates metadata loading, count calculation and report file creation.
createReport <- function(config = getConfig()) {
  analysis_start_time <- Sys.time()
  logProgress(
    "Starting report. Output filename=",
    config$output_filename,
    ", count batch size=",
    config$count_batch_size,
    ", value datetime columns=",
    isTRUE(config$include_value_datetime_columns),
    "."
  )
  metadata <- loadViewMetadata(config)
  history_metadata <- if (isTRUE(config$include_value_datetime_columns)) {
    loadHistoryMetadata(config)
  } else {
    logProgress("Skipping historical view metadata because value datetime columns are disabled.")
    NULL
  }
  database_metadata <- loadDatabaseMetadata()
  logProgress("Calculating database quality analysis counts.")
  result <- calculateCounts(metadata, config, history_metadata = history_metadata)
  analysis_end_time <- Sys.time()
  result_rows_by_family <- result[, .N, by = TABLE_FAMILY][order(TABLE_FAMILY)]
  logProgress(
    "Calculated ",
    nrow(result),
    " report rows: ",
    paste(paste(result_rows_by_family$TABLE_FAMILY, result_rows_by_family$N, sep = "="), collapse = ", "),
    "."
  )
  sheets <- splitResultForExcel(result)
  filtered_scope_fhir_sheets <- createFilteredScopeFhirSheets(
    metadata,
    result,
    config,
    history_metadata = history_metadata
  )
  if (length(filtered_scope_fhir_sheets)) {
    fhir_sheet_position <- match("FHIR", names(sheets))
    sheets <- append(
      sheets,
      filtered_scope_fhir_sheets,
      after = if (is.na(fhir_sheet_position)) length(sheets) else fhir_sheet_position
    )
  }
  sheets <- c(
    sheets,
    createResourceDetailSheets(metadata, result, config),
    createFilteredScopeResourceDetailSheets(metadata, result, config)
  )
  sheets <- prependSheetDescriptionSheet(sheets, config)
  sheets$Metadata <- createMetadataSheet(
    result,
    metadata,
    config,
    analysis_start_time,
    analysis_end_time,
    database_metadata = database_metadata
  )

  output_file <- writeExcelFile(
    sheets,
    getCountSummaryOutputFilename(config),
    timestamp = analysis_start_time
  )
  logProgress("Calculating database quality analysis value summary.")
  value_summaries <- createValueSummaryReports(metadata, config = config)
  value_summary_file <- writeValueSummaryArchive(
    value_summaries,
    config$output_filename,
    timestamp = analysis_start_time
  )
  if (!file.exists(value_summary_file)) {
    stop("Value summary archive was not created: ", value_summary_file, call. = FALSE)
  }
  logProgress(
    "Finished report in ",
    formatDuration(analysis_start_time),
    ". Outputs: ",
    output_file,
    ", ",
    value_summary_file
  )

  invisible(result)
}
