calculateCounts <- function(
  metadata,
  config,
  query_fun = etlutils::dbGetReadOnlyQuery,
  history_metadata = NULL
) {
  result <- unique(metadata[, .(TABLE_FAMILY, TABLE_NAME, COLUMN_NAME, COLUMN_DESCRIPTION, ORDINAL_POSITION)])
  result[, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := NA_character_]
  if (isTRUE(config$include_value_datetime_columns)) {
    result[, (DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS) := as.POSIXct(NA)]
  }
  for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
    result[, (count_column) := NA_integer_]
  }
  for (count_column in DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS) {
    result[, (count_column) := NA_integer_]
  }

  table_names <- unique(metadata$TABLE_NAME)
  for (table_index in seq_along(table_names)) {
    table_start_time <- Sys.time()
    table_name <- table_names[[table_index]]
    table_metadata <- metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
    grouping_columns <- inferGroupingColumns(table_metadata, config)
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

      count_query <- buildCountQuery(table_metadata, grouping_columns, data_column_batch)
      if (!is.na(count_query$query)) {
        count_result <- query_fun(
          count_query$query,
          lock_id = paste0("calculate database quality analysis counts for ", table_name)
        )
        for (row_index in seq_len(nrow(count_query$alias_map))) {
          alias_row <- count_query$alias_map[row_index]
          result[
            TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
            (alias_row$count_column) := as.integer(count_result[[alias_row$alias]][[1]])
          ]
        }
      }

      if (isTRUE(config$include_value_datetime_columns)) {
        date_range_query <- buildValueDateRangeQuery(
          table_metadata,
          history_metadata,
          config,
          data_column_batch
        )
        if (!is.na(date_range_query$query)) {
          date_range_result <- query_fun(
            date_range_query$query,
            lock_id = paste0("calculate database quality analysis value date ranges for ", table_name)
          )
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
        }
      }
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
    DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS,
    "TABLE_FAMILY",
    "ORDINAL_POSITION"
  ))
  result[order(TABLE_FAMILY, TABLE_NAME, ORDINAL_POSITION)]
}

formatRunTimestamp <- function(timestamp) {
  format(timestamp, "%Y-%m-%d %H:%M:%S UTC", tz = "UTC")
}

formatFilenameTimestamp <- function(timestamp) {
  format(timestamp, "%Y-%m-%d_%H-%M-%S")
}

collapseConfigValue <- function(value) {
  if (length(value) == 0L) {
    return("")
  }
  paste(value, collapse = "; ")
}

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

  rows <- list(
    add_row("analysis started at", formatRunTimestamp(analysis_start_time)),
    add_row("analysis finished at", formatRunTimestamp(analysis_end_time)),
    add_row(
      "analysis duration seconds",
      round(as.numeric(difftime(analysis_end_time, analysis_start_time, units = "secs")), 2)
    ),
    add_row("view schema", config$view_schema),
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

splitResultForExcel <- function(result) {
  output_columns <- setdiff(names(result), c("TABLE_FAMILY", "ORDINAL_POSITION"))
  non_fhir_output_columns <- setdiff(
    output_columns,
    c(
      DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[c("first_meta_last_updated", "last_meta_last_updated")],
      DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS
    )
  )
  sheets <- list(
    FHIR = result[TABLE_FAMILY == "FHIR", ..output_columns],
    Frontend = result[TABLE_FAMILY == "Frontend", ..non_fhir_output_columns],
    Other = result[TABLE_FAMILY == "Other", ..non_fhir_output_columns]
  )
  sheets <- lapply(sheets, function(sheet) {
    for (count_column in c(DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS, DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS)) {
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
  formatted_tables <- lapply(split(sheet, sheet$TABLE_NAME), function(table_rows) {
    table_rows[-1, TABLE_NAME := NA_character_]
    data.table::rbindlist(list(table_rows, blank_row), use.names = TRUE)
  })
  data.table::rbindlist(formatted_tables, use.names = TRUE)
}

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
    config$output_filename,
    timestamp = analysis_start_time
  )
  logProgress(
    "Finished report in ",
    formatDuration(analysis_start_time),
    ". Output: ",
    output_file
  )

  invisible(result)
}
