#' Quote a SQL identifier
#'
#' Escapes and double-quotes a schema, table, column or alias identifier.
quoteIdentifier <- function(identifier) {
  if (is.na(identifier) || !nzchar(identifier)) {
    stop("Identifier must not be empty.")
  }
  paste0('"', gsub('"', '""', identifier, fixed = TRUE), '"')
}

#' Quote a qualified SQL identifier
#'
#' Quotes an alias and identifier and joins them with a dot.
quoteQualifiedIdentifier <- function(alias, identifier) {
  paste(quoteIdentifier(alias), quoteIdentifier(identifier), sep = ".")
}

#' Quote a SQL table reference
#'
#' Quotes a schema and table name and joins them as a qualified table reference.
quoteTable <- function(schema, table_name) {
  paste(
    quoteIdentifier(schema),
    quoteIdentifier(table_name),
    sep = "."
  )
}

#' Build a generic filled-value condition
#'
#' Builds the default non-empty condition when no data type is known.
getFilledCondition <- function(column_name) {
  getColumnFilledCondition(column_name, NA_character_)
}

#' Check whether a database type is textual
#'
#' Returns TRUE for text-like database types and unknown types.
isTextType <- function(data_type) {
  if (is.na(data_type) || !nzchar(data_type)) {
    return(TRUE)
  }
  data_type %in% c("character", "character varying", "text")
}

#' Build a filled-value condition for a column
#'
#' Builds a non-null condition and excludes empty strings for text columns.
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

#' Map column names to data types
#'
#' Builds a named vector of data types from table metadata.
getMetadataDataTypes <- function(table_metadata) {
  stats::setNames(
    if ("DATA_TYPE" %in% names(table_metadata)) {
      table_metadata$DATA_TYPE
    } else {
      rep(NA_character_, nrow(table_metadata))
    },
    table_metadata$COLUMN_NAME
  )
}

#' Build a SELECT query
#'
#' Combines select expressions, a table reference and an optional WHERE clause.
buildSelectQuery <- function(select_parts, table_ref, row_filter_condition = NA_character_) {
  paste0(
    "SELECT\n  ",
    paste(select_parts, collapse = ",\n  "),
    "\nFROM ",
    table_ref,
    getOptionalWhereClause(row_filter_condition)
  )
}

#' Build a distinct count expression
#'
#' Builds a conditional COUNT DISTINCT expression for one grouping column.
buildDistinctCountExpression <- function(conditions, grouping_column, alias) {
  conditions <- conditions[!is.na(conditions)]
  paste0(
    "COUNT(DISTINCT CASE WHEN ",
    paste(conditions, collapse = " AND "),
    " THEN ",
    quoteIdentifier(grouping_column),
    " END) AS ",
    quoteIdentifier(alias)
  )
}

#' Quote a SQL string literal
#'
#' Escapes single quotes and wraps the value as a SQL string literal.
quoteSqlString <- function(value) {
  paste0("'", gsub("'", "''", value, fixed = TRUE), "'")
}

#' Build the availability condition for a value column
#'
#' Combines default filled-value logic with project-specific availability rules.
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

#' Build an optional WHERE clause
#'
#' Returns an empty string or a WHERE clause for an additional row filter.
getOptionalWhereClause <- function(row_filter_condition) {
  if (is.na(row_filter_condition) || !nzchar(row_filter_condition)) {
    return("")
  }

  paste0("\nWHERE ", row_filter_condition)
}

#' Create an empty count alias map
#'
#' Returns the expected alias-map columns for count queries with no expressions.
getEmptyCountAliasMap <- function() {
  data.table::data.table(
    alias = character(),
    COLUMN_NAME = character(),
    count_column = character()
  )
}

#' Build configured count groups
#'
#' Converts grouping columns into count group rows used by count query builders.
buildConfiguredCountGroups <- function(grouping_columns, extra_condition = NA_character_) {
  count_group_rows <- lapply(names(grouping_columns), function(grouping_name) {
    count_column <- DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS[[grouping_name]]
    if (is.null(count_column)) {
      return(NULL)
    }

    data.table::data.table(
      grouping_column = grouping_columns[[grouping_name]],
      count_column = count_column,
      extra_condition = extra_condition
    )
  })
  count_group_rows <- Filter(Negate(is.null), count_group_rows)
  if (!length(count_group_rows)) {
    return(data.table::data.table(
      grouping_column = character(),
      count_column = character(),
      extra_condition = character()
    ))
  }

  data.table::rbindlist(count_group_rows, use.names = TRUE)
}

#' Build an availability count query
#'
#' Builds one batched query for value availability counts across count groups.
buildAvailabilityCountQuery <- function(
  table_metadata,
  data_columns,
  count_groups,
  row_filter_condition = NA_character_
) {
  empty_alias_map <- getEmptyCountAliasMap()
  if (!length(data_columns) || !nrow(count_groups)) {
    return(list(query = NA_character_, alias_map = empty_alias_map))
  }

  table_ref <- quoteTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )

  select_parts <- character()
  alias_rows <- list()
  alias_index <- 1L
  data_types <- getMetadataDataTypes(table_metadata)

  for (column_name in data_columns) {
    filled_condition <- getValueAvailableCondition(column_name, table_metadata, data_types)
    for (count_group_index in seq_len(nrow(count_groups))) {
      count_group <- count_groups[count_group_index]
      grouping_column <- count_group$grouping_column
      if (is.na(grouping_column) || !grouping_column %in% table_metadata$COLUMN_NAME) {
        next
      }

      alias <- paste0("count_", alias_index)
      grouping_filled_condition <- getValueAvailableCondition(
        grouping_column,
        table_metadata,
        data_types
      )
      select_parts <- c(
        select_parts,
        buildDistinctCountExpression(
          c(filled_condition, grouping_filled_condition, count_group$extra_condition),
          grouping_column,
          alias
        )
      )
      alias_rows[[length(alias_rows) + 1L]] <- data.table::data.table(
        alias = alias,
        COLUMN_NAME = column_name,
        count_column = count_group$count_column
      )
      alias_index <- alias_index + 1L
    }
  }

  alias_map <- if (length(alias_rows)) {
    data.table::rbindlist(alias_rows, use.names = TRUE)
  } else {
    empty_alias_map
  }
  if (!length(select_parts)) {
    return(list(query = NA_character_, alias_map = alias_map))
  }

  list(
    query = buildSelectQuery(select_parts, table_ref, row_filter_condition),
    alias_map = alias_map
  )
}

#' Build the standard availability count query
#'
#' Builds availability counts for the configured resource, patient and case groups.
buildCountQuery <- function(
  table_metadata,
  grouping_columns,
  data_columns,
  row_filter_condition = NA_character_
) {
  buildAvailabilityCountQuery(
    table_metadata,
    data_columns,
    buildConfiguredCountGroups(grouping_columns),
    row_filter_condition = row_filter_condition
  )
}
#' Build a value date range query
#'
#' Builds min and max timestamp expressions for filled values in history views.
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
  data_types <- getMetadataDataTypes(history_table_metadata)
  select_parts <- character()
  alias_rows <- list()

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
        paste0(
          "MIN(CASE WHEN ",
          column_filled_condition,
          " THEN ",
          quoted_datetime_column,
          " END) AS ",
          quoteIdentifier(first_alias)
        ),
        paste0(
          "MAX(CASE WHEN ",
          column_filled_condition,
          " THEN ",
          quoted_datetime_column,
          " END) AS ",
          quoteIdentifier(last_alias)
        )
      )
      alias_rows[[length(alias_rows) + 1L]] <- data.table::data.table(
        first_alias = first_alias,
        last_alias = last_alias,
        first_result_column = date_source$first_result_column,
        last_result_column = date_source$last_result_column,
        COLUMN_NAME = column_name
      )
    }
  }

  list(
    query = buildSelectQuery(select_parts, table_ref, row_filter_condition),
    alias_map = data.table::rbindlist(alias_rows, use.names = TRUE)
  )
}
