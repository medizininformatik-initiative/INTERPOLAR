#' Validate a grouping column
#'
#' Ensures a configured grouping column exists in the table metadata.
validateGroupingColumn <- function(table_name, columns, column_name, grouping_name) {
  if (is.na(column_name)) {
    return(NA_character_)
  }
  if (!column_name %in% columns) {
    stop(
      "Configured grouping column '",
      column_name,
      "' for ",
      grouping_name,
      " does not exist in table ",
      table_name,
      ".",
      call. = FALSE
    )
  }
  column_name
}

#' Require a grouping column from candidates
#'
#' Selects the first available candidate or stops with a descriptive error.
requireGroupingColumn <- function(table_name, columns, candidates, grouping_name) {
  present <- candidates[candidates %in% columns]
  if (!length(present)) {
    stop(
      "Could not infer ",
      grouping_name,
      " grouping column for table ",
      table_name,
      ". Add a GROUPING_OVERRIDES entry if the table does not follow the convention.",
      call. = FALSE
    )
  }
  if (length(present) > 1L) {
    stop(
      "Could not infer a unique ",
      grouping_name,
      " grouping column for table ",
      table_name,
      ". Candidates: ",
      paste(present, collapse = ", "),
      ". Add a GROUPING_OVERRIDES entry.",
      call. = FALSE
    )
  }
  present[[1]]
}

#' Select an optional grouping column
#'
#' Returns the first available grouping candidate or NA when none exists.
optionalGroupingColumn <- function(table_name, columns, candidates, grouping_name) {
  present <- candidates[candidates %in% columns]
  if (!length(present)) {
    return(NA_character_)
  }
  if (length(present) > 1L) {
    stop(
      "Could not infer a unique ",
      grouping_name,
      " grouping column for table ",
      table_name,
      ". Candidates: ",
      paste(present, collapse = ", "),
      ". Add a GROUPING_OVERRIDES entry.",
      call. = FALSE
    )
  }
  present[[1]]
}

#' Derive a resource grouping prefix
#'
#' Removes the resource id suffix to infer related patient or encounter columns.
getGroupingPrefix <- function(resource_id_column) {
  sub("_id$", "", resource_id_column)
}

#' Classify the resource reference scope
#'
#' Classifies resources as case-, patient- or case/patient-independent.
getResourceReferenceScope <- function(grouping_columns, table_metadata = NULL) {
  if (!is.na(grouping_columns[["case_id"]])) {
    return("case_dependent")
  }
  if (!is.null(table_metadata)) {
    grouping_prefix <- getGroupingPrefix(grouping_columns[["resource_id"]])
    calculated_ref_column <- paste0(grouping_prefix, "_encounter_calculated_ref")
    if (calculated_ref_column %in% table_metadata$COLUMN_NAME) {
      return("case_dependent")
    }
  }
  if (!is.na(grouping_columns[["pid"]])) {
    return("patient_dependent")
  }
  "case_patient_independent"
}

#' Get the sorting order for a reference scope
#'
#' Returns the configured report order for resource reference scope classes.
getResourceReferenceScopeOrder <- function(reference_scope) {
  match(
    reference_scope,
    c("patient_dependent", "case_dependent", "case_patient_independent"),
    nomatch = 4L
  )
}

#' Sort report rows by reference scope
#'
#' Orders report rows by resource scope, table name and original column order.
orderByResourceReferenceScope <- function(result) {
  if (!"RESOURCE_REFERENCE_SCOPE" %in% names(result)) {
    return(result[order(TABLE_FAMILY, TABLE_NAME, ORDINAL_POSITION)])
  }
  result[
    order(
      TABLE_FAMILY,
      getResourceReferenceScopeOrder(RESOURCE_REFERENCE_SCOPE),
      TABLE_NAME,
      ORDINAL_POSITION
    )
  ]
}

#' Infer grouping columns for a table
#'
#' Resolves resource, patient and case grouping columns from metadata and overrides.
inferGroupingColumns <- function(table_metadata, config) {
  table_name <- table_metadata$TABLE_NAME[[1]]
  columns <- table_metadata$COLUMN_NAME

  override <- config$grouping_overrides[TABLE_NAME == table_name]
  grouping <- list(resource_id = NA_character_, pid = NA_character_, case_id = NA_character_)
  if (nrow(override)) {
    grouping$resource_id <- override$resource_id[[1]]
    grouping$pid <- override$pid[[1]]
    grouping$case_id <- override$case_id[[1]]
  }

  if (!is.na(grouping$resource_id)) {
    grouping$resource_id <- validateGroupingColumn(table_name, columns, grouping$resource_id, "resource_id")
  } else {
    own_id_candidates <- setdiff(grep("^[a-z0-9]+_id$", columns, value = TRUE), "record_id")
    grouping$resource_id <- requireGroupingColumn(table_name, columns, own_id_candidates, "resource_id")
  }
  grouping_prefix <- getGroupingPrefix(grouping$resource_id)

  if (!is.na(grouping$pid)) {
    grouping$pid <- validateGroupingColumn(table_name, columns, grouping$pid, "pid")
  } else {
    if (endsWith(table_name, "_fe")) {
      grouping$pid <- requireGroupingColumn(table_name, columns, "record_id", "pid")
    } else {
      grouping$pid <- optionalGroupingColumn(
        table_name,
        columns,
        paste0(grouping_prefix, "_patient_ref"),
        "pid"
      )
    }
  }

  if (!is.na(grouping$case_id)) {
    grouping$case_id <- validateGroupingColumn(table_name, columns, grouping$case_id, "case_id")
  } else {
    case_id_candidates <- paste0(grouping_prefix, "_encounter_ref")
    if (identical(table_name, "encounter")) {
      case_id_candidates <- c("enc_main_encounter_calculated_ref", case_id_candidates)
    }
    grouping$case_id <- optionalGroupingColumn(
      table_name,
      columns,
      case_id_candidates,
      "case_id"
    )
  }

  unlist(grouping, use.names = TRUE)
}

#' Mark columns used for grouping
#'
#' Adds a display label for columns that are used as report grouping dimensions.
addGroupingRoles <- function(result, grouping_columns) {
  result[, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := NA_character_]
  for (grouping_name in names(grouping_columns)) {
    grouping_column <- grouping_columns[[grouping_name]]
    if (is.na(grouping_column) || !grouping_column %in% result$COLUMN_NAME) {
      next
    }
    count_column <- DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS[[grouping_name]]
    role_columns <- grouping_column
    result[
      COLUMN_NAME %in% role_columns,
      (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := data.table::fifelse(
        is.na(get(DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN)),
        count_column,
        paste(get(DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN), count_column, sep = "; ")
      )
    ]
  }
  result
}
