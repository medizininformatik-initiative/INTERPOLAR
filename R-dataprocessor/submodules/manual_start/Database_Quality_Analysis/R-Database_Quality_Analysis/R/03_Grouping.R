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

getGroupingPrefix <- function(resource_id_column) {
  sub("_id$", "", resource_id_column)
}

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

  grouping <- unlist(grouping, use.names = TRUE)
  if (identical(table_name, "encounter") &&
      all(c("enc_type_system", "enc_type_code", "enc_class_system", "enc_class_code") %in% columns)) {
    encounter_type_grouping <- stats::setNames(
      rep(grouping[["resource_id"]], length(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_TYPE_GROUPINGS)),
      names(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_TYPE_GROUPINGS)
    )
    grouping <- c(grouping, encounter_type_grouping)
  }

  grouping
}

addGroupingRoles <- function(result, grouping_columns) {
  result[, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := NA_character_]
  for (grouping_name in names(grouping_columns)) {
    grouping_column <- grouping_columns[[grouping_name]]
    if (is.na(grouping_column) || !grouping_column %in% result$COLUMN_NAME) {
      next
    }
    count_column <- c(
      DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS,
      DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS
    )[[grouping_name]]
    role_columns <- grouping_column
    if (grouping_name %in% names(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_TYPE_GROUPINGS)) {
      role_columns <- intersect(
        c(grouping_column, "enc_type_system", "enc_type_code", "enc_class_system", "enc_class_code"),
        result$COLUMN_NAME
      )
    }
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
