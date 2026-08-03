DATABASE_QUALITY_ANALYSIS_VALUE_SUMMARY_SUFFIX <- "Value_Summary"
DATABASE_QUALITY_ANALYSIS_TEXT_VALUE_MIN_COUNT <- 5L
DATABASE_QUALITY_ANALYSIS_VALUE_SUMMARY_COLUMNS <- c(
  "COLUMN_NAME",
  "DATA_TYPE",
  "VALUE_TYPE",
  "DISTINCT_VALUES",
  "VALUE_COUNTS",
  "MIN",
  "MAX",
  "AVG",
  "MEDIAN",
  "Q1",
  "Q3",
  "SE",
  "EMPTY"
)

getValueSummaryType <- function(data_type) {
  data_type <- tolower(data_type)
  if (grepl("timestamp|date|time", data_type)) {
    return("datetime")
  }
  if (grepl("integer|bigint|smallint|numeric|decimal|double precision|real", data_type)) {
    return("numeric")
  }
  "text"
}

formatValueCountLabel <- function(value) {
  value <- gsub("\r\n|\r|\n", "\\n", value)
  value <- gsub("'", "''", value, fixed = TRUE)
  paste0("'", value, "'")
}

formatValueCounts <- function(values, counts, min_count = DATABASE_QUALITY_ANALYSIS_TEXT_VALUE_MIN_COUNT) {
  common_indexes <- which(counts >= min_count)
  rare_count <- sum(counts[counts < min_count], na.rm = TRUE)
  parts <- character()
  if (length(common_indexes)) {
    common_order <- order(-counts[common_indexes], values[common_indexes])
    common_indexes <- common_indexes[common_order]
    parts <- paste0(formatValueCountLabel(values[common_indexes]), ": ", counts[common_indexes])
  }
  if (rare_count > 0L) {
    parts <- c(parts, paste0("Other (count < ", min_count, "): ", rare_count))
  }
  paste(parts, collapse = "; ")
}

createEmptyValueSummaryRows <- function() {
  data.table::data.table(
    COLUMN_NAME = character(),
    DATA_TYPE = character(),
    VALUE_TYPE = character(),
    DISTINCT_VALUES = integer(),
    VALUE_COUNTS = character(),
    MIN = character(),
    MAX = character(),
    AVG = character(),
    MEDIAN = character(),
    Q1 = character(),
    Q3 = character(),
    SE = numeric(),
    EMPTY = integer()
  )
}

formatValueSummaryOutputValue <- function(value) {
  if (inherits(value, "POSIXt")) {
    return(format(value, "%Y-%m-%d %H:%M:%S", tz = "UTC", usetz = FALSE))
  }
  as.character(value)
}

normalizeValueSummaryColumnClasses <- function(rows) {
  character_columns <- c("MIN", "MAX", "AVG", "MEDIAN", "Q1", "Q3")
  for (column_name in intersect(character_columns, names(rows))) {
    rows[, (column_name) := formatValueSummaryOutputValue(get(column_name))]
  }
  if ("DISTINCT_VALUES" %in% names(rows)) {
    rows[, DISTINCT_VALUES := as.integer(DISTINCT_VALUES)]
  }
  if ("VALUE_COUNTS" %in% names(rows)) {
    rows[, VALUE_COUNTS := as.character(VALUE_COUNTS)]
  }
  if ("SE" %in% names(rows)) {
    rows[, SE := as.numeric(SE)]
  }
  if ("EMPTY" %in% names(rows)) {
    rows[, EMPTY := as.integer(EMPTY)]
  }
  rows
}

getValueSummarySuppressedColumnPatterns <- function(config) {
  patterns <- config$value_summary_suppressed_column_patterns
  if (is.null(patterns)) {
    return(character())
  }
  patterns[nzchar(patterns)]
}

shouldSuppressValueSummaryValues <- function(column_name, config) {
  patterns <- getValueSummarySuppressedColumnPatterns(config)
  if (!length(patterns)) {
    return(FALSE)
  }
  any(vapply(patterns, grepl, logical(1), x = column_name))
}

getValueSummaryResourceIdColumn <- function(table_metadata, config) {
  grouping_columns <- tryCatch(
    inferGroupingColumns(table_metadata, config),
    error = function(error) {
      logProgress(
        "Skipping value details for table ",
        table_metadata$TABLE_NAME[[1]],
        ": ",
        conditionMessage(error),
        "."
      )
      return(NULL)
    }
  )
  if (is.null(grouping_columns)) {
    return(NA_character_)
  }
  resource_id_column <- grouping_columns[["resource_id"]]
  if (is.na(resource_id_column) || !resource_id_column %in% table_metadata$COLUMN_NAME) {
    logProgress(
      "Skipping value details for table ",
      table_metadata$TABLE_NAME[[1]],
      ": no resource_id grouping column available."
    )
    return(NA_character_)
  }
  resource_id_column
}

createValueSummaryRow <- function(table_metadata, column_name, value_type) {
  column_metadata <- table_metadata[COLUMN_NAME == column_name][1]
  data.table::data.table(
    COLUMN_NAME = column_name,
    DATA_TYPE = column_metadata$DATA_TYPE,
    VALUE_TYPE = value_type,
    DISTINCT_VALUES = NA_integer_,
    VALUE_COUNTS = NA_character_,
    MIN = NA_character_,
    MAX = NA_character_,
    AVG = NA_character_,
    MEDIAN = NA_character_,
    Q1 = NA_character_,
    Q3 = NA_character_,
    SE = NA_real_,
    EMPTY = NA_integer_
  )
}

buildTextValueSummaryQuery <- function(table_metadata, data_columns, resource_id_column) {
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
  value_alias <- "value_summary"
  filled_alias <- "filled_resources"
  resource_values_alias <- "resource_values"
  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )
  resource_id_ref <- quoteQualifiedIdentifier(table_alias, resource_id_column)
  value_rows <- vapply(data_columns, function(column_name) {
    column_ref <- quoteQualifiedIdentifier(table_alias, column_name)
    paste0(
      "(",
      quoteSqlString(column_name),
      ", CASE WHEN ",
      column_ref,
      " IS NULL OR ",
      column_ref,
      "::text = '' THEN NULL ELSE ",
      column_ref,
      "::text END)"
    )
  }, character(1))

  paste0(
    "WITH ",
    quoteIdentifier(resource_values_alias),
    " AS (\n  SELECT\n    ",
    resource_id_ref,
    " AS ",
    quoteIdentifier("resource_id"),
    ",\n    ",
    quoteQualifiedIdentifier(value_alias, "column_name"),
    " AS ",
    quoteIdentifier("column_name"),
    ",\n    ",
    quoteQualifiedIdentifier(value_alias, "value"),
    " AS ",
    quoteIdentifier("value"),
    "\n  FROM ",
    table_ref,
    " ",
    quoteIdentifier(table_alias),
    "\n  CROSS JOIN LATERAL (\n    VALUES\n      ",
    paste(value_rows, collapse = ",\n      "),
    "\n  ) AS ",
    quoteIdentifier(value_alias),
    "(",
    paste(vapply(c("column_name", "value"), quoteIdentifier, character(1)), collapse = ", "),
    ")\n  GROUP BY ",
    resource_id_ref,
    ", ",
    quoteQualifiedIdentifier(value_alias, "column_name"),
    ", ",
    quoteQualifiedIdentifier(value_alias, "value"),
    "\n), ",
    quoteIdentifier(filled_alias),
    " AS (\n  SELECT DISTINCT ",
    quoteIdentifier("resource_id"),
    ", ",
    quoteIdentifier("column_name"),
    "\n  FROM ",
    quoteIdentifier(resource_values_alias),
    "\n  WHERE ",
    quoteIdentifier("value"),
    " IS NOT NULL\n)\nSELECT\n  ",
    quoteSqlString(table_metadata$TABLE_FAMILY[[1]]),
    " AS ",
    quoteIdentifier("TABLE_FAMILY"),
    ",\n  ",
    quoteSqlString(table_metadata$TABLE_NAME[[1]]),
    " AS ",
    quoteIdentifier("TABLE_NAME"),
    ",\n  ",
    quoteQualifiedIdentifier(resource_values_alias, "column_name"),
    " AS ",
    quoteIdentifier("COLUMN_NAME"),
    ",\n  ",
    quoteQualifiedIdentifier(resource_values_alias, "value"),
    " AS ",
    quoteIdentifier("VALUE"),
    ",\n  CASE WHEN ",
    quoteQualifiedIdentifier(resource_values_alias, "value"),
    " IS NULL THEN\n    COUNT(DISTINCT ",
    quoteQualifiedIdentifier(resource_values_alias, "resource_id"),
    ") FILTER (WHERE ",
    quoteQualifiedIdentifier(filled_alias, "resource_id"),
    " IS NULL)::integer\n  ELSE\n    COUNT(DISTINCT ",
    quoteQualifiedIdentifier(resource_values_alias, "resource_id"),
    ")::integer\n  END AS ",
    quoteIdentifier("COUNT"),
    "\nFROM ",
    quoteIdentifier(resource_values_alias),
    "\nLEFT JOIN ",
    quoteIdentifier(filled_alias),
    " ON ",
    quoteQualifiedIdentifier(filled_alias, "resource_id"),
    " = ",
    quoteQualifiedIdentifier(resource_values_alias, "resource_id"),
    " AND ",
    quoteQualifiedIdentifier(filled_alias, "column_name"),
    " = ",
    quoteQualifiedIdentifier(resource_values_alias, "column_name"),
    "\nGROUP BY ",
    quoteQualifiedIdentifier(resource_values_alias, "column_name"),
    ", ",
    quoteQualifiedIdentifier(resource_values_alias, "value"),
    "\nORDER BY ",
    quoteQualifiedIdentifier(resource_values_alias, "column_name"),
    " ASC, COUNT(DISTINCT ",
    quoteQualifiedIdentifier(resource_values_alias, "resource_id"),
    ") DESC, ",
    quoteQualifiedIdentifier(resource_values_alias, "value"),
    " ASC"
  )
}

getFilteredAggregate <- function(aggregate_expression, filled_condition) {
  paste0("(", aggregate_expression, " FILTER (WHERE ", filled_condition, "))")
}

getStatisticSummaryExpressions <- function(column_ref, value_type, filled_condition) {
  if (identical(value_type, "datetime")) {
    numeric_expression <- paste0("EXTRACT(EPOCH FROM ", column_ref, ")::double precision")
    datetime_from_epoch <- function(aggregate_expression) {
      paste0(
        "('epoch'::timestamp + ",
        getFilteredAggregate(aggregate_expression, filled_condition),
        " * INTERVAL '1 second')"
      )
    }
    standard_error <- paste0(
      getFilteredAggregate(paste0("STDDEV_SAMP(", numeric_expression, ")"), filled_condition),
      " / NULLIF(SQRT(",
      getFilteredAggregate(paste0("COUNT(", numeric_expression, ")"), filled_condition),
      "), 0)"
    )
    return(list(
      MIN = getFilteredAggregate(paste0("MIN(", column_ref, ")"), filled_condition),
      MAX = getFilteredAggregate(paste0("MAX(", column_ref, ")"), filled_condition),
      AVG = datetime_from_epoch(paste0("AVG(", numeric_expression, ")")),
      SE = standard_error,
      MEDIAN = datetime_from_epoch(paste0(
        "PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ",
        numeric_expression,
        ")"
      )),
      Q1 = datetime_from_epoch(paste0(
        "PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ",
        numeric_expression,
        ")"
      )),
      Q3 = datetime_from_epoch(paste0(
        "PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ",
        numeric_expression,
        ")"
      ))
    ))
  }

  numeric_expression <- paste0(column_ref, "::double precision")
  standard_error <- paste0(
    getFilteredAggregate(paste0("STDDEV_SAMP(", numeric_expression, ")"), filled_condition),
    " / NULLIF(SQRT(",
    getFilteredAggregate(paste0("COUNT(", numeric_expression, ")"), filled_condition),
    "), 0)"
  )
  list(
    MIN = getFilteredAggregate(paste0("MIN(", numeric_expression, ")"), filled_condition),
    MAX = getFilteredAggregate(paste0("MAX(", numeric_expression, ")"), filled_condition),
    AVG = getFilteredAggregate(paste0("AVG(", numeric_expression, ")"), filled_condition),
    SE = standard_error,
    MEDIAN = getFilteredAggregate(
      paste0("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ", numeric_expression, ")"),
      filled_condition
    ),
    Q1 = getFilteredAggregate(
      paste0("PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ", numeric_expression, ")"),
      filled_condition
    ),
    Q3 = getFilteredAggregate(
      paste0("PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ", numeric_expression, ")"),
      filled_condition
    )
  )
}

buildStatisticValueSummaryQuery <- function(table_metadata, data_columns, value_type, resource_id_column) {
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
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  table_alias <- "source_row"
  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )
  resource_id_ref <- quoteQualifiedIdentifier(table_alias, resource_id_column)
  select_parts <- character()
  alias_rows <- list()
  alias_index <- 0L

  for (column_name in data_columns) {
    column_ref <- quoteQualifiedIdentifier(table_alias, column_name)
    filled_condition <- paste0(column_ref, " IS NOT NULL")
    expressions <- getStatisticSummaryExpressions(column_ref, value_type, filled_condition)
    expressions$DISTINCT_VALUES <- paste0(
      "COUNT(DISTINCT ",
      column_ref,
      ") FILTER (WHERE ",
      filled_condition,
      ")::integer"
    )
    expressions$EMPTY <- paste0(
      "(COUNT(DISTINCT ",
      resource_id_ref,
      ") - COUNT(DISTINCT ",
      resource_id_ref,
      ") FILTER (WHERE ",
      filled_condition,
      "))::integer"
    )

    for (result_column in names(expressions)) {
      alias_index <- alias_index + 1L
      alias <- paste0("value_summary_", alias_index)
      expression <- expressions[[result_column]]
      select_parts <- c(select_parts, paste0(expression, " AS ", quoteIdentifier(alias)))
      alias_rows[[length(alias_rows) + 1L]] <- data.table::data.table(
        COLUMN_NAME = column_name,
        result_column = result_column,
        alias = alias
      )
    }
  }

  list(
    query = paste0(
      "SELECT\n  ",
      paste(select_parts, collapse = ",\n  "),
      "\nFROM ",
      table_ref,
      " ",
      quoteIdentifier(table_alias)
    ),
    alias_map = data.table::rbindlist(alias_rows, use.names = TRUE)
  )
}

buildSuppressedValueSummaryQuery <- function(table_metadata, data_columns, resource_id_column) {
  data_columns <- intersect(data_columns, table_metadata$COLUMN_NAME)
  if (!length(data_columns)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  table_alias <- "source_row"
  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )
  resource_id_ref <- quoteQualifiedIdentifier(table_alias, resource_id_column)
  select_parts <- character()
  alias_rows <- list()
  alias_index <- 0L

  for (column_name in data_columns) {
    column_ref <- quoteQualifiedIdentifier(table_alias, column_name)
    filled_condition <- paste0(
      column_ref,
      " IS NOT NULL AND ",
      column_ref,
      "::text <> ",
      quoteSqlString("")
    )
    expressions <- list(
      DISTINCT_VALUES = paste0(
        "COUNT(DISTINCT ",
        column_ref,
        ") FILTER (WHERE ",
        filled_condition,
        ")::integer"
      ),
      EMPTY = paste0(
        "(COUNT(DISTINCT ",
        resource_id_ref,
        ") - COUNT(DISTINCT ",
        resource_id_ref,
        ") FILTER (WHERE ",
        filled_condition,
        "))::integer"
      )
    )

    for (result_column in names(expressions)) {
      alias_index <- alias_index + 1L
      alias <- paste0("value_summary_", alias_index)
      select_parts <- c(select_parts, paste0(expressions[[result_column]], " AS ", quoteIdentifier(alias)))
      alias_rows[[length(alias_rows) + 1L]] <- data.table::data.table(
        COLUMN_NAME = column_name,
        result_column = result_column,
        alias = alias
      )
    }
  }

  list(
    query = paste0(
      "SELECT\n  ",
      paste(select_parts, collapse = ",\n  "),
      "\nFROM ",
      table_ref,
      " ",
      quoteIdentifier(table_alias)
    ),
    alias_map = data.table::rbindlist(alias_rows, use.names = TRUE)
  )
}

summariseSuppressedValueSummary <- function(summary_result, alias_map, table_metadata, data_columns) {
  rows <- lapply(data_columns, function(column_name) {
    column_metadata <- table_metadata[COLUMN_NAME == column_name][1]
    row <- createValueSummaryRow(table_metadata, column_name, column_metadata$VALUE_TYPE)
    column_aliases <- alias_map[COLUMN_NAME == column_name]
    for (row_index in seq_len(nrow(column_aliases))) {
      alias_row <- column_aliases[row_index]
      value <- summary_result[[alias_row$alias]][[1]]
      row[, (alias_row$result_column) := value]
    }
    row
  })
  rows <- lapply(rows, normalizeValueSummaryColumnClasses)
  data.table::rbindlist(rows, use.names = TRUE)
}

summariseTextValueCounts <- function(counts, table_metadata, data_columns) {
  rows <- lapply(data_columns, function(column_name) {
    column_counts <- counts[COLUMN_NAME == column_name]
    empty_count <- column_counts[is.na(VALUE), sum(COUNT, na.rm = TRUE)]
    value_counts <- column_counts[!is.na(VALUE)]
    value_counts <- value_counts[, .(COUNT = sum(COUNT, na.rm = TRUE)), by = VALUE]
    distinct_values <- nrow(value_counts)
    value_count_text <- NA_character_
    if (nrow(value_counts)) {
      value_count_text <- formatValueCounts(value_counts$VALUE, value_counts$COUNT)
    }
    row <- createValueSummaryRow(table_metadata, column_name, "text")
    row[, DISTINCT_VALUES := as.integer(distinct_values)]
    row[, VALUE_COUNTS := value_count_text]
    row[, EMPTY := as.integer(empty_count)]
    row
  })
  rows <- lapply(rows, normalizeValueSummaryColumnClasses)
  data.table::rbindlist(rows, use.names = TRUE)
}

summariseStatisticValues <- function(summary_result, alias_map, table_metadata, data_columns, value_type) {
  rows <- lapply(data_columns, function(column_name) {
    row <- createValueSummaryRow(table_metadata, column_name, value_type)
    column_aliases <- alias_map[COLUMN_NAME == column_name]
    for (row_index in seq_len(nrow(column_aliases))) {
      alias_row <- column_aliases[row_index]
      value <- summary_result[[alias_row$alias]][[1]]
      row[, (alias_row$result_column) := value]
    }
    row[, EMPTY := as.integer(EMPTY)]
    row
  })
  rows <- lapply(rows, normalizeValueSummaryColumnClasses)
  data.table::rbindlist(rows, use.names = TRUE)
}

createValueSummaryReports <- function(
  metadata,
  config = list(count_batch_size = 100),
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  metadata <- metadata[TABLE_FAMILY == "FHIR"]
  table_names <- unique(metadata$TABLE_NAME)
  count_batch_size <- if (is.null(config$count_batch_size)) 100L else config$count_batch_size
  result <- list()

  for (table_name in table_names) {
    table_start_time <- Sys.time()
    table_metadata <- metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
    table_metadata[, VALUE_TYPE := vapply(DATA_TYPE, getValueSummaryType, character(1))]
    table_metadata[, SUPPRESS_VALUES := vapply(
      COLUMN_NAME,
      shouldSuppressValueSummaryValues,
      logical(1),
      config = config
    )]
    resource_id_column <- getValueSummaryResourceIdColumn(table_metadata, config)
    data_columns <- table_metadata$COLUMN_NAME
    column_batches <- split(data_columns, ceiling(seq_along(data_columns) / count_batch_size))
    table_rows <- list()

    logProgress(
      "Value summary for table ",
      table_name,
      " (",
      table_metadata$TABLE_FAMILY[[1]],
      "): ",
      formatCountLabel(length(data_columns), "column"),
      ", ",
      formatCountLabel(length(column_batches), "batch", "batches"),
      "."
    )

    if (is.na(resource_id_column)) {
      table_rows[[length(table_rows) + 1L]] <- data.table::rbindlist(
        lapply(data_columns, function(column_name) {
          column_metadata <- table_metadata[COLUMN_NAME == column_name][1]
          createValueSummaryRow(table_metadata, column_name, column_metadata$VALUE_TYPE)
        }),
        use.names = TRUE
      )
    } else {
      for (batch_index in seq_along(column_batches)) {
        data_column_batch <- column_batches[[batch_index]]
        batch_metadata <- table_metadata[COLUMN_NAME %in% data_column_batch]
        if (length(column_batches) > 1L) {
          logProgress(
            "Value summary for table ",
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

        suppressed_columns <- batch_metadata[SUPPRESS_VALUES == TRUE, COLUMN_NAME]
        if (length(suppressed_columns)) {
          suppressed_query <- buildSuppressedValueSummaryQuery(
            table_metadata,
            suppressed_columns,
            resource_id_column
          )
          suppressed_result <- query_fun(
            suppressed_query$query,
            lock_id = paste0(
              "calculate database quality analysis suppressed value summary for ",
              table_name,
              " batch ",
              batch_index
            )
          )
          suppressed_result <- data.table::as.data.table(suppressed_result)
          table_rows[[length(table_rows) + 1L]] <- summariseSuppressedValueSummary(
            suppressed_result,
            suppressed_query$alias_map,
            table_metadata,
            suppressed_columns
          )
        }

        text_columns <- batch_metadata[VALUE_TYPE == "text" & SUPPRESS_VALUES == FALSE, COLUMN_NAME]
        if (length(text_columns)) {
          text_query <- buildTextValueSummaryQuery(
            table_metadata,
            text_columns,
            resource_id_column
          )
          text_counts <- query_fun(
            text_query,
            lock_id = paste0(
              "calculate database quality analysis text value summary for ",
              table_name,
              " batch ",
              batch_index
            )
          )
          text_counts <- data.table::as.data.table(text_counts)
          table_rows[[length(table_rows) + 1L]] <- summariseTextValueCounts(
            text_counts,
            table_metadata,
            text_columns
          )
        }

        for (value_type in c("numeric", "datetime")) {
          statistic_columns <- batch_metadata[VALUE_TYPE == value_type & SUPPRESS_VALUES == FALSE, COLUMN_NAME]
          if (!length(statistic_columns)) {
            next
          }
          statistic_query <- buildStatisticValueSummaryQuery(
            table_metadata,
            statistic_columns,
            value_type,
            resource_id_column
          )
          statistic_result <- query_fun(
            statistic_query$query,
            lock_id = paste0(
              "calculate database quality analysis ",
              value_type,
              " value summary for ",
              table_name,
              " batch ",
              batch_index
            )
          )
          statistic_result <- data.table::as.data.table(statistic_result)
          table_rows[[length(table_rows) + 1L]] <- summariseStatisticValues(
            statistic_result,
            statistic_query$alias_map,
            table_metadata,
            statistic_columns,
            value_type
          )
        }
      }
    }

    if (length(table_rows)) {
      table_rows <- lapply(table_rows, normalizeValueSummaryColumnClasses)
      table_result <- data.table::rbindlist(table_rows, use.names = TRUE, fill = TRUE)
      table_result[, ORDINAL_POSITION := match(COLUMN_NAME, table_metadata$COLUMN_NAME)]
      data.table::setorder(table_result, ORDINAL_POSITION)
      table_result[, ORDINAL_POSITION := NULL]
      data.table::setcolorder(table_result, DATABASE_QUALITY_ANALYSIS_VALUE_SUMMARY_COLUMNS)
      result[[table_name]] <- table_result
    }

    logProgress(
      "Finished value summary for table ",
      table_name,
      " in ",
      formatDuration(table_start_time),
      "."
    )
  }

  result
}

sanitizeValueSummaryFileName <- function(value) {
  value <- gsub("[^A-Za-z0-9_.-]+", "_", value)
  value <- gsub("_+", "_", value)
  value <- gsub("^_|_$", "", value)
  if (!nzchar(value)) {
    return("resource")
  }
  value
}

writeValueSummaryArchive <- function(
  value_summaries,
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
  archive_name <- file.path(
    normalizePath(module_sub_dir, mustWork = TRUE),
    paste0(
      filename_without_extension,
      "_",
      DATABASE_QUALITY_ANALYSIS_VALUE_SUMMARY_SUFFIX,
      "_",
      formatFilenameTimestamp(timestamp),
      ".zip"
    )
  )

  temp_dir <- tempfile("database-quality-analysis-value-summary-")
  dir.create(temp_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  csv_files <- vapply(names(value_summaries), function(table_name) {
    file_name <- file.path(temp_dir, paste0(sanitizeValueSummaryFileName(table_name), ".csv"))
    data.table::fwrite(
      value_summaries[[table_name]],
      file = file_name,
      sep = ",",
      na = "",
      quote = TRUE
    )
    file_name
  }, character(1))

  if (!length(csv_files)) {
    file_name <- file.path(temp_dir, "FHIR_Value_Summary.csv")
    data.table::fwrite(
      createEmptyValueSummaryRows(),
      file = file_name,
      sep = ",",
      na = "",
      quote = TRUE
    )
    csv_files <- file_name
  }

  if (file.exists(archive_name)) {
    file.remove(archive_name)
  }
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(temp_dir)
  logProgress("Writing value summary archive to ", archive_name, ".")
  utils::zip(archive_name, files = basename(csv_files), flags = "-q")
  logProgress("Value summary archive written to ", archive_name, ".")
  invisible(archive_name)
}
