DATABASE_QUALITY_ANALYSIS_UNIQUE_VALUES_SUFFIX <- "Unique_Values"


formatUniqueValue <- function(value) {
  value <- gsub("\r\n|\r|\n", "\\n", value)
  value <- gsub("'", "''", value, fixed = TRUE)
  paste0("'", value, "'")
}

collapseUniqueValues <- function(values) {
  values <- sort(unique(values))
  paste(vapply(values, formatUniqueValue, character(1)), collapse = "\n")
}

buildUniqueValuesQuery <- function(table_metadata, data_columns) {
  missing_columns <- setdiff(data_columns, table_metadata$COLUMN_NAME)
  if (length(missing_columns)) {
    stop(
      "Columns do not exist in table ",
      table_metadata$TABLE_NAME[[1]],
      ": ",
      paste(missing_columns, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  data_columns <- intersect(data_columns, table_metadata$COLUMN_NAME)
  if (!length(data_columns)) {
    return(NA_character_)
  }

  table_alias <- "source_row"
  value_alias <- "unique_values"
  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )
  value_rows <- vapply(data_columns, function(column_name) {
    paste0(
      "(",
      quoteSqlString(column_name),
      ", ",
      quoteQualifiedIdentifier(table_alias, column_name),
      "::text)"
    )
  }, character(1))

  paste0(
    "SELECT DISTINCT\n  ",
    quoteSqlString(table_metadata$TABLE_FAMILY[[1]]),
    " AS ",
    quoteIdentifier("TABLE_FAMILY"),
    ",\n  ",
    quoteSqlString(table_metadata$TABLE_NAME[[1]]),
    " AS ",
    quoteIdentifier("TABLE_NAME"),
    ",\n  ",
    quoteQualifiedIdentifier(value_alias, "column_name"),
    " AS ",
    quoteIdentifier("COLUMN_NAME"),
    ",\n  ",
    quoteQualifiedIdentifier(value_alias, "value"),
    " AS ",
    quoteIdentifier("VALUE"),
    "\nFROM ",
    table_ref,
    " ",
    quoteIdentifier(table_alias),
    "\nCROSS JOIN LATERAL (\n  VALUES\n    ",
    paste(value_rows, collapse = ",\n    "),
    "\n) AS ",
    quoteIdentifier(value_alias),
    "(",
    paste(vapply(c("column_name", "value"), quoteIdentifier, character(1)), collapse = ", "),
    ")\nWHERE ",
    quoteQualifiedIdentifier(value_alias, "value"),
    " IS NOT NULL\nORDER BY ",
    quoteQualifiedIdentifier(value_alias, "column_name"),
    " ASC, ",
    quoteQualifiedIdentifier(value_alias, "value"),
    " ASC"
  )
}

createUniqueValuesReport <- function(
  metadata,
  config = list(count_batch_size = 100),
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  result_parts <- list()
  metadata <- metadata[TABLE_FAMILY == "FHIR"]
  table_names <- unique(metadata$TABLE_NAME)
  count_batch_size <- if (is.null(config$count_batch_size)) 100L else config$count_batch_size

  for (table_name in table_names) {
    table_metadata <- metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
    table_start_time <- Sys.time()
    data_columns <- table_metadata$COLUMN_NAME
    column_batches <- split(data_columns, ceiling(seq_along(data_columns) / count_batch_size))
    logProgress(
      "Unique values for table ",
      table_name,
      " (",
      table_metadata$TABLE_FAMILY[[1]],
      "): ",
      formatCountLabel(length(data_columns), "column"),
      ", ",
      formatCountLabel(length(column_batches), "batch", "batches"),
      "."
    )

    for (batch_index in seq_along(column_batches)) {
      data_column_batch <- column_batches[[batch_index]]
      if (length(column_batches) > 1L) {
        logProgress(
          "Unique values for table ",
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

      query <- buildUniqueValuesQuery(table_metadata, data_column_batch)
      if (is.na(query)) {
        next
      }
      batch_values <- query_fun(
        query,
        lock_id = paste0(
          "calculate database quality analysis unique values for ",
          table_name,
          " batch ",
          batch_index
        )
      )
      batch_values <- data.table::as.data.table(batch_values)
      if (nrow(batch_values)) {
        result_parts[[length(result_parts) + 1L]] <- batch_values
      }
    }

    logProgress(
      "Finished unique values for table ",
      table_name,
      " in ",
      formatDuration(table_start_time),
      "."
    )
  }

  if (!length(result_parts)) {
    return(data.table::data.table(
      TABLE_FAMILY = character(),
      TABLE_NAME = character(),
      COLUMN_NAME = character(),
      VALUES = character()
    ))
  }

  result <- data.table::rbindlist(result_parts, use.names = TRUE)
  result <- result[, .(VALUES = collapseUniqueValues(VALUE)), by = .(
    TABLE_FAMILY,
    TABLE_NAME,
    COLUMN_NAME
  )]
  data.table::setorder(result, TABLE_FAMILY, TABLE_NAME, COLUMN_NAME)
  result
}

writeUniqueValuesFile <- function(
  unique_values,
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
      DATABASE_QUALITY_ANALYSIS_UNIQUE_VALUES_SUFFIX,
      "_",
      formatFilenameTimestamp(timestamp),
      ".csv"
    )
  )

  logProgress("Writing unique value report to ", file_name, ".")
  data.table::fwrite(
    unique_values,
    file = file_name,
    sep = ",",
    na = "",
    quote = TRUE
  )
  logProgress("Unique value report written to ", file_name, ".")
  invisible(file_name)
}
