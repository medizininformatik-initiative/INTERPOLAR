# Build the condition for the outer row group. Each row group becomes one repeated table block in the detail sheet.
getDetailRowGroupCondition <- function(detail_config, row_group_value) {
  paste(
    quoteIdentifier(detail_config$row_group_system_column),
    "=",
    quoteSqlString(detail_config$row_group_system),
    "AND",
    quoteIdentifier(detail_config$row_group_value_column),
    "=",
    quoteSqlString(row_group_value)
  )
}

# Build the condition for the inner count group. Each count group becomes one additional count column in every row group.
getDetailCountGroupCondition <- function(detail_config, count_group_value) {
  count_group_system_condition <- paste(
    quoteIdentifier(detail_config$count_group_system_column),
    "=",
    quoteSqlString(detail_config$count_group_system)
  )

  if (identical(count_group_value, "OTHER")) {
    explicit_values <- sort(detail_config$count_group_values[detail_config$count_group_values != "OTHER"])
    count_group_value_condition <- paste0(
      "(",
      quoteIdentifier(detail_config$count_group_value_column),
      " IS NOT NULL AND ",
      quoteIdentifier(detail_config$count_group_value_column),
      "::text <> '' AND ",
      quoteIdentifier(detail_config$count_group_value_column),
      " NOT IN (",
      paste(quoteSqlString(unname(explicit_values)), collapse = ", "),
      "))"
    )
  } else {
    count_group_value_condition <- paste(
      quoteIdentifier(detail_config$count_group_value_column),
      "=",
      quoteSqlString(count_group_value)
    )
  }

  paste(count_group_system_condition, "AND", count_group_value_condition)
}

getRequiredDetailColumns <- function(detail_config) {
  unique(c(
    detail_config$row_group_system_column,
    detail_config$row_group_value_column,
    detail_config$count_group_system_column,
    detail_config$count_group_value_column
  ))
}

buildResourceDetailCountQuery <- function(
  table_metadata,
  grouping_columns,
  data_columns,
  detail_config,
  row_group_value,
  row_filter_condition = NA_character_
) {
  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )
  data_types <- stats::setNames(
    if ("DATA_TYPE" %in% names(table_metadata)) table_metadata$DATA_TYPE else rep(NA_character_, nrow(table_metadata)),
    table_metadata$COLUMN_NAME
  )
  row_group_condition <- getDetailRowGroupCondition(detail_config, row_group_value)
  select_parts <- character()
  alias_map <- data.table::data.table(
    alias = character(),
    COLUMN_NAME = character(),
    count_column = character()
  )
  alias_index <- 1L

  for (column_name in data_columns) {
    filled_condition <- getValueAvailableCondition(column_name, table_metadata, data_types)
    for (grouping_name in names(grouping_columns)) {
      grouping_column <- grouping_columns[[grouping_name]]
      if (is.na(grouping_column) || !grouping_column %in% table_metadata$COLUMN_NAME) {
        next
      }
      alias <- paste0("count_", alias_index)
      grouping_filled_condition <- getValueAvailableCondition(
        grouping_column,
        table_metadata,
        data_types
      )
      conditions <- c(
        filled_condition,
        grouping_filled_condition,
        row_group_condition
      )
      conditions <- conditions[!is.na(conditions)]
      select_parts <- c(select_parts, paste0(
        "COUNT(DISTINCT CASE WHEN ",
        paste(conditions, collapse = " AND "),
        " THEN ",
        quoteIdentifier(grouping_column),
        " END) AS ",
        quoteIdentifier(alias)
      ))
      alias_map <- rbind(
        alias_map,
        data.table::data.table(
          alias = alias,
          COLUMN_NAME = column_name,
          count_column = DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS[[grouping_name]]
        )
      )
      alias_index <- alias_index + 1L
    }
    for (count_group_name in names(detail_config$count_group_values)) {
      grouping_column <- grouping_columns[["resource_id"]]
      if (is.na(grouping_column) || !grouping_column %in% table_metadata$COLUMN_NAME) {
        next
      }
      alias <- paste0("count_", alias_index)
      grouping_filled_condition <- getValueAvailableCondition(
        grouping_column,
        table_metadata,
        data_types
      )
      conditions <- c(
        filled_condition,
        grouping_filled_condition,
        row_group_condition,
        getDetailCountGroupCondition(detail_config, detail_config$count_group_values[[count_group_name]])
      )
      conditions <- conditions[!is.na(conditions)]
      select_parts <- c(select_parts, paste0(
        "COUNT(DISTINCT CASE WHEN ",
        paste(conditions, collapse = " AND "),
        " THEN ",
        quoteIdentifier(grouping_column),
        " END) AS ",
        quoteIdentifier(alias)
      ))
      alias_map <- rbind(
        alias_map,
        data.table::data.table(
          alias = alias,
          COLUMN_NAME = column_name,
          count_column = detail_config$count_group_count_columns[[count_group_name]]
        )
      )
      alias_index <- alias_index + 1L
    }
  }

  if (!length(select_parts)) {
    return(list(query = NA_character_, alias_map = alias_map))
  }

  list(
    query = paste0(
      "SELECT\n  ",
      paste(select_parts, collapse = ",\n  "),
      "\nFROM ",
      table_ref,
      getOptionalWhereClause(row_filter_condition)
    ),
    alias_map = alias_map
  )
}

createResourceDetailSheet <- function(
  metadata,
  result,
  config,
  detail_config,
  query_fun = etlutils::dbGetReadOnlyQuery,
  row_filter_condition = NA_character_
) {
  table_metadata <- metadata[TABLE_NAME == detail_config$table_name][order(ORDINAL_POSITION)]
  if (!nrow(table_metadata)) {
    return(NULL)
  }

  required_columns <- getRequiredDetailColumns(detail_config)
  if (!all(required_columns %in% table_metadata$COLUMN_NAME)) {
    logProgress(
      "Skipping ",
      detail_config$sheet_name,
      " detail sheet because required columns are missing."
    )
    return(NULL)
  }

  grouping_columns <- tryCatch(
    inferGroupingColumns(table_metadata, config),
    error = function(error) {
      logProgress("Skipping ", detail_config$sheet_name, " detail sheet: ", conditionMessage(error))
      NULL
    }
  )
  if (is.null(grouping_columns)) {
    return(NULL)
  }

  base_rows <- data.table::copy(result[TABLE_NAME == detail_config$table_name][order(ORDINAL_POSITION)])
  if (!nrow(base_rows)) {
    return(NULL)
  }

  output_columns <- setdiff(names(base_rows), c("TABLE_FAMILY", "RESOURCE_REFERENCE_SCOPE", "ORDINAL_POSITION"))
  base_rows <- base_rows[, ..output_columns]
  for (count_column in detail_config$count_group_count_columns) {
    base_rows[, (count_column) := NA_integer_]
  }

  data_columns <- table_metadata$COLUMN_NAME
  sheets <- list()
  for (row_group_label in names(detail_config$row_group_values)) {
    row_group_value <- detail_config$row_group_values[[row_group_label]]
    row_group_rows <- data.table::copy(base_rows)
    row_group_rows[, TABLE_NAME := paste(detail_config$table_name, row_group_label, sep = " - ")]
    count_query <- buildResourceDetailCountQuery(
      table_metadata,
      grouping_columns,
      data_columns,
      detail_config,
      row_group_value,
      row_filter_condition = row_filter_condition
    )
    if (!is.na(count_query$query)) {
      count_result <- query_fun(
        count_query$query,
        lock_id = paste0(
          "calculate database quality analysis ",
          detail_config$table_name,
          " detail counts for ",
          row_group_value
        )
      )
      for (row_index in seq_len(nrow(count_query$alias_map))) {
        alias_row <- count_query$alias_map[row_index]
        row_group_rows[
          COLUMN_NAME == alias_row$COLUMN_NAME,
          (alias_row$count_column) := as.integer(count_result[[alias_row$alias]][[1]])
        ]
      }
    }
    sheets[[row_group_label]] <- row_group_rows
  }

  sheet <- data.table::rbindlist(sheets, use.names = TRUE)
  for (count_column in c(DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS, detail_config$count_group_count_columns)) {
    data.table::set(
      sheet,
      i = which(!is.na(sheet[[count_column]]) & sheet[[count_column]] == 0L),
      j = count_column,
      value = NA_integer_
    )
  }
  sheet
}

createResourceDetailSheets <- function(
  metadata,
  result,
  config,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  sheets <- list()
  resource_detail_sheets <- config$resource_detail_sheets
  if (is.null(resource_detail_sheets) || !length(resource_detail_sheets)) {
    return(sheets)
  }

  for (detail_config in resource_detail_sheets) {
    detail_sheet <- createResourceDetailSheet(
      metadata,
      result,
      config,
      detail_config,
      query_fun = query_fun
    )
    if (!is.null(detail_sheet) && nrow(detail_sheet)) {
      sheets[[detail_config$sheet_name]] <- detail_sheet
    }
  }
  sheets
}
