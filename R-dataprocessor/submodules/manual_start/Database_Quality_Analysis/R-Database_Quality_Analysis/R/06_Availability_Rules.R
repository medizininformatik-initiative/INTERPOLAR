#' Get frontend checkbox group columns
#'
#' Returns the configured checkbox columns that belong to a frontend field.
getFrontendCheckboxGroupColumns <- function(table_name, column_name, available_columns) {
  if (is.na(table_name)) {
    return(character())
  }
  table_groups <- DATABASE_QUALITY_ANALYSIS_FRONTEND_CHECKBOX_GROUPS[[table_name]]
  if (is.null(table_groups)) {
    return(character())
  }

  for (group_columns in table_groups) {
    if (column_name %in% group_columns) {
      return(intersect(group_columns, available_columns))
    }
  }
  character()
}

#' Build a checked-value condition
#'
#' Builds the SQL condition that treats a frontend checkbox value as checked.
getCheckedCondition <- function(column_name) {
  paste(
    quoteIdentifier(column_name),
    "=",
    quoteSqlString(DATABASE_QUALITY_ANALYSIS_CHECKED_VALUE)
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
getProjectAvailabilityOverrideCondition <- function(column_name, table_metadata) {
  table_name <- if ("TABLE_NAME" %in% names(table_metadata)) {
    table_metadata$TABLE_NAME[[1]]
  } else {
    NA_character_
  }
  checkbox_group_columns <- getFrontendCheckboxGroupColumns(
    table_name,
    column_name,
    table_metadata$COLUMN_NAME
  )
  if (length(checkbox_group_columns)) {
    return(paste0(
      "(",
      paste(
        vapply(checkbox_group_columns, getCheckedCondition, character(1)),
        collapse = " OR "
      ),
      ")"
    ))
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
