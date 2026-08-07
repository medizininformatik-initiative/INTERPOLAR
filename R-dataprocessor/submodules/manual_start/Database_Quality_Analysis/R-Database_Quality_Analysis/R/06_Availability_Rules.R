#' Check whether boolean group rules apply to a table
#'
#' Tests the configured table families for pattern-based boolean groups.
isBooleanGroupTable <- function(table_metadata, config) {
  table_families <- config[["boolean_group_table_families"]]
  if (is.null(table_families) || !length(table_families)) {
    return(FALSE)
  }
  table_family <- if ("TABLE_FAMILY" %in% names(table_metadata)) {
    table_metadata[["TABLE_FAMILY"]][[1]]
  } else if ("TABLE_NAME" %in% names(table_metadata)) {
    getTableFamily(table_metadata[["TABLE_NAME"]][[1]])
  } else {
    NA_character_
  }
  !is.na(table_family) && table_family %in% table_families
}

#' Get the configured boolean group base name
#'
#' Removes the configured option suffix from a boolean group column name.
getBooleanGroupBaseName <- function(column_name, config) {
  pattern <- config[["boolean_group_column_pattern"]]
  if (is.null(pattern) || !nzchar(pattern)) {
    return(NA_character_)
  }
  if (!grepl(pattern, column_name, perl = TRUE)) {
    return(NA_character_)
  }
  sub(pattern, "", column_name, perl = TRUE)
}

#' Get columns in the same boolean group
#'
#' Detects option columns by pattern and returns all columns with the same base name.
getBooleanGroupColumns <- function(column_name, table_metadata, config) {
  if (!isBooleanGroupTable(table_metadata, config)) {
    return(character())
  }
  group_base_name <- getBooleanGroupBaseName(column_name, config)
  if (is.na(group_base_name) || !nzchar(group_base_name)) {
    return(character())
  }

  available_columns <- table_metadata[["COLUMN_NAME"]]
  group_base_names <- vapply(
    available_columns,
    getBooleanGroupBaseName,
    character(1),
    config = config
  )
  available_columns[!is.na(group_base_names) & group_base_names == group_base_name]
}

#' Build a boolean true-value condition
#'
#' Builds the SQL condition that treats a boolean group option as checked.
getBooleanTrueCondition <- function(column_name, config) {
  true_values <- config[["boolean_true_values"]]
  true_values <- true_values[!is.na(true_values) & nzchar(true_values)]
  if (!length(true_values)) {
    return(NA_character_)
  }
  quoted_column <- quoteIdentifier(column_name)
  if (length(true_values) == 1L) {
    return(paste(quoted_column, "=", quoteSqlString(true_values[[1]])))
  }
  paste0(
    quoted_column,
    " IN (",
    paste(vapply(true_values, quoteSqlString, character(1)), collapse = ", "),
    ")"
  )
}

#' Build availability for calculated references
#'
#' Treats calculated reference columns as available only when they are not invalid.
getCalculatedRefAvailableCondition <- function(column_name) {
  paste0(
    quoteIdentifier(column_name),
    "::text <> ",
    quoteSqlString("invalid")
  )
}

#' Get project-specific availability override
#'
#' Returns special availability logic for columns that need custom counting.
getProjectAvailabilityOverrideCondition <- function(column_name, table_metadata, config = list()) {
  boolean_group_columns <- getBooleanGroupColumns(column_name, table_metadata, config)
  if (length(boolean_group_columns)) {
    true_conditions <- vapply(
      boolean_group_columns,
      getBooleanTrueCondition,
      character(1),
      config = config
    )
    true_conditions <- true_conditions[!is.na(true_conditions)]
    if (length(true_conditions)) {
      return(paste0("(", paste(true_conditions, collapse = " OR "), ")"))
    }
  }

  NA_character_
}

#' Get additional availability conditions
#'
#' Returns optional extra conditions that are added to the default value check.
getProjectAvailabilityAdditionalCondition <- function(column_name) {
  if (endsWith(column_name, "_calculated_ref")) {
    return(getCalculatedRefAvailableCondition(column_name))
  }

  NA_character_
}
