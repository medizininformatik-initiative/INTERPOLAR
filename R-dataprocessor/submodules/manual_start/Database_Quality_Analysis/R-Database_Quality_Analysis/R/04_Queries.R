quoteIdentifier <- function(identifier) {
  if (is.na(identifier) || !nzchar(identifier)) {
    stop("Identifier must not be empty.")
  }
  paste0('"', gsub('"', '""', identifier, fixed = TRUE), '"')
}

quoteTable <- function(schema, table_name) {
  paste(
    quoteIdentifier(schema),
    quoteIdentifier(table_name),
    sep = "."
  )
}

getFilledCondition <- function(column_name) {
  getColumnFilledCondition(column_name, NA_character_)
}

isTextType <- function(data_type) {
  if (is.na(data_type) || !nzchar(data_type)) {
    return(TRUE)
  }
  data_type %in% c("character", "character varying", "text")
}

getColumnFilledCondition <- function(column_name, data_type) {
  quoted_column <- quoteIdentifier(column_name)
  not_null_condition <- paste(quoted_column, "IS NOT NULL")
  if (!isTextType(data_type)) {
    return(not_null_condition)
  }
  conditions <- c(
    not_null_condition,
    paste0(quoted_column, "::text <> ''")
  )

  paste(conditions, collapse = " AND ")
}

quoteSqlString <- function(value) {
  paste0("'", gsub("'", "''", value, fixed = TRUE), "'")
}

getValueAvailableCondition <- function(column_name, table_metadata, data_types) {
  override_condition <- getProjectAvailabilityOverrideCondition(column_name, table_metadata)
  if (!is.na(override_condition)) {
    return(override_condition)
  }

  conditions <- c(
    getColumnFilledCondition(column_name, data_types[[column_name]]),
    getProjectAvailabilityAdditionalCondition(column_name)
  )
  conditions <- conditions[!is.na(conditions)]
  paste(conditions, collapse = " AND ")
}

getOptionalWhereClause <- function(row_filter_condition) {
  if (is.na(row_filter_condition) || !nzchar(row_filter_condition)) {
    return("")
  }

  paste0("\nWHERE ", row_filter_condition)
}

buildCountQuery <- function(
  table_metadata,
  grouping_columns,
  data_columns,
  row_filter_condition = NA_character_
) {
  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )

  select_parts <- character()
  alias_map <- data.table::data.table(
    alias = character(),
    COLUMN_NAME = character(),
    count_column = character()
  )
  alias_index <- 1L

  data_types <- stats::setNames(
    if ("DATA_TYPE" %in% names(table_metadata)) table_metadata$DATA_TYPE else rep(NA_character_, nrow(table_metadata)),
    table_metadata$COLUMN_NAME
  )

  for (column_name in data_columns) {
    filled_condition <- getValueAvailableCondition(column_name, table_metadata, data_types)
    for (grouping_name in names(grouping_columns)) {
      grouping_column <- grouping_columns[[grouping_name]]
      if (is.na(grouping_column) || !grouping_column %in% table_metadata$COLUMN_NAME) {
        next
      }
      alias <- paste0("count_", alias_index)
      quoted_grouping <- quoteIdentifier(grouping_column)
      grouping_filled_condition <- getValueAvailableCondition(
        grouping_column,
        table_metadata,
        data_types
      )
      conditions <- c(
        filled_condition,
        grouping_filled_condition
      )
      conditions <- conditions[!is.na(conditions)]
      select_parts <- c(select_parts, paste0(
        "COUNT(DISTINCT CASE WHEN ",
        paste(conditions, collapse = " AND "),
        " THEN ",
        quoted_grouping,
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

buildValueDateRangeQuery <- function(
  table_metadata,
  history_metadata,
  config,
  data_columns,
  row_filter_condition = NA_character_
) {
  if (is.null(history_metadata) || !nrow(history_metadata)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  history_view_name <- getHistoryViewName(table_metadata$TABLE_NAME[[1]], config)
  history_table_metadata <- history_metadata[
    VIEW_SCHEMA == table_metadata$VIEW_SCHEMA[[1]] &
      VIEW_NAME == history_view_name
  ]
  if (!nrow(history_table_metadata)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }
  history_table_metadata <- data.table::copy(history_table_metadata)

  data_columns <- intersect(data_columns, history_table_metadata$COLUMN_NAME)
  if (!length(data_columns)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  date_sources <- getDateSources(table_metadata, history_table_metadata, config)
  if (!nrow(date_sources)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    history_view_name
  )
  history_table_metadata[, TABLE_NAME := table_metadata$TABLE_NAME[[1]]]
  data_types <- stats::setNames(history_table_metadata$DATA_TYPE, history_table_metadata$COLUMN_NAME)
  select_parts <- character()
  alias_map <- data.table::data.table(
    first_alias = character(),
    last_alias = character(),
    first_result_column = character(),
    last_result_column = character(),
    COLUMN_NAME = character()
  )

  for (column_index in seq_along(data_columns)) {
    column_name <- data_columns[[column_index]]
    column_filled_condition <- getValueAvailableCondition(column_name, history_table_metadata, data_types)
    for (source_index in seq_len(nrow(date_sources))) {
      date_source <- date_sources[source_index]
      first_alias <- paste0("first_value_datetime_", column_index, "_", date_source$source_name)
      last_alias <- paste0("last_value_datetime_", column_index, "_", date_source$source_name)
      quoted_datetime_column <- quoteIdentifier(date_source$column_name)
      select_parts <- c(
        select_parts,
        paste0("MIN(CASE WHEN ", column_filled_condition, " THEN ", quoted_datetime_column, " END) AS ", quoteIdentifier(first_alias)),
        paste0("MAX(CASE WHEN ", column_filled_condition, " THEN ", quoted_datetime_column, " END) AS ", quoteIdentifier(last_alias))
      )
      alias_map <- rbind(
        alias_map,
        data.table::data.table(
          first_alias = first_alias,
          last_alias = last_alias,
          first_result_column = date_source$first_result_column,
          last_result_column = date_source$last_result_column,
          COLUMN_NAME = column_name
        )
      )
    }
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
