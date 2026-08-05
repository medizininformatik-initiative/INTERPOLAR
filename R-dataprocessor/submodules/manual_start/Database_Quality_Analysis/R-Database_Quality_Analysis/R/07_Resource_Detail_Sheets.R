#' Build a resource detail row-group condition
#'
#' Builds the SQL condition for one repeated row group in a detail sheet.
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

#' Build a resource detail count-group condition
#'
#' Builds the SQL condition for one nested count group in a detail sheet.
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

#' Get required resource detail columns
#'
#' Returns all metadata columns needed to create a configured detail sheet.
getRequiredDetailColumns <- function(detail_config) {
  unique(c(
    detail_config$row_group_system_column,
    detail_config$row_group_value_column,
    detail_config$count_group_system_column,
    detail_config$count_group_value_column
  ))
}

#' Build a resource detail count query
#'
#' Builds availability counts for one configured resource detail row group.
buildResourceDetailCountQuery <- function(
  table_metadata,
  grouping_columns,
  data_columns,
  detail_config,
  row_group_value,
  row_filter_condition = NA_character_
) {
  row_group_condition <- getDetailRowGroupCondition(detail_config, row_group_value)
  count_groups <- buildConfiguredCountGroups(
    grouping_columns,
    extra_condition = row_group_condition
  )

  resource_id_column <- grouping_columns[["resource_id"]]
  detail_count_groups <- lapply(names(detail_config$count_group_values), function(count_group_name) {
    data.table::data.table(
      grouping_column = resource_id_column,
      count_column = detail_config$count_group_count_columns[[count_group_name]],
      extra_condition = paste(
        row_group_condition,
        "AND",
        getDetailCountGroupCondition(
          detail_config,
          detail_config$count_group_values[[count_group_name]]
        )
      )
    )
  })

  count_groups <- data.table::rbindlist(
    c(list(count_groups), detail_count_groups),
    use.names = TRUE
  )

  buildAvailabilityCountQuery(
    table_metadata,
    data_columns,
    count_groups,
    row_filter_condition = row_filter_condition
  )
}
#' Create a resource detail sheet
#'
#' Creates one sheet with repeated row groups and configured count groups.
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
        lock_id = getDatabaseQualityAnalysisLockId(
          config,
          paste0(
            "calculate database quality analysis ",
            detail_config$table_name,
            " detail counts for ",
            row_group_value
          )
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

#' Create configured resource detail sheets
#'
#' Builds all configured resource detail sheets that have available metadata.
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
