SNAPSHOT_LOINC_MAPPING_FILE <- file.path(
  "LOINC_Mapping",
  "LOINC_Mapping_content",
  "LOINC_Mapping_Table_processed.xlsx"
)

SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS <- c(
  "value_in_reference_unit",
  "reference_unit",
  "primary_loinc_code"
)

SNAPSHOT_OBSERVATION_SOURCE_COLUMNS <- c(
  "obs_code_system",
  "obs_code_code",
  "obs_valuequantity_value",
  "obs_valuequantity_code",
  "obs_valuequantity_unit"
)

loadSnapshotLoincMapping <- function(input_repo_path) {
  if (is.null(input_repo_path) || is.na(input_repo_path) || !nzchar(input_repo_path)) {
    stop("input_repo_path must be provided for observation LOINC enrichment.")
  }

  mapping_file_path <- file.path(input_repo_path, SNAPSHOT_LOINC_MAPPING_FILE)
  if (!file.exists(mapping_file_path)) {
    stop("LOINC mapping file not found: ", mapping_file_path)
  }

  mapping_sheets <- etlutils::readExcelFileAsTableList(mapping_file_path)
  if (length(mapping_sheets) == 0) {
    stop("LOINC mapping file contains no readable sheets: ", mapping_file_path)
  }

  mapping <- data.table::as.data.table(mapping_sheets[[1]])
  required_columns <- c(
    "LOINC",
    "LOINC_PRIMARY",
    "UNIT",
    "CONVERSION_FACTOR",
    "CONVERSION_UNIT"
  )
  missing_columns <- setdiff(required_columns, names(mapping))
  if (length(missing_columns) > 0) {
    stop(
      "LOINC mapping file is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }

  mapping <- mapping[
    !is.na(mapping[["LOINC"]]) & nzchar(trimws(mapping[["LOINC"]])),
    required_columns,
    with = FALSE
  ]
  duplicated_loincs <- unique(mapping[["LOINC"]][duplicated(mapping[["LOINC"]])])
  if (length(duplicated_loincs) > 0) {
    stop(
      "LOINC mapping contains duplicate LOINC values: ",
      paste(utils::head(duplicated_loincs, 20), collapse = ", ")
    )
  }

  mapping
}

getObservationValueUnit <- function(observation) {
  if ("obs_valuequantity_code" %in% names(observation)) {
    unit_code <- observation[["obs_valuequantity_code"]]
  } else {
    unit_code <- rep(NA_character_, nrow(observation))
  }
  if ("obs_valuequantity_unit" %in% names(observation)) {
    unit_display <- observation[["obs_valuequantity_unit"]]
  } else {
    unit_display <- rep(NA_character_, nrow(observation))
  }
  use_code <- !is.na(unit_code) & nzchar(unit_code) & etlutils::isValidUnit(unit_code)
  data.table::fifelse(use_code, unit_code, unit_display)
}

normalizeConversionFactor <- function(conversion_factor) {
  conversion_factor <- suppressWarnings(as.numeric(conversion_factor))
  conversion_factor[conversion_factor %in% 1] <- NA_real_
  conversion_factor
}

enrichObservationWithLoincMapping <- function(
  observation,
  loinc_mapping,
  enrichment_columns = SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS,
  source_columns = names(observation)
) {
  observation <- data.table::copy(data.table::as.data.table(observation))
  enrichment_columns <- intersect(
    enrichment_columns,
    SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS
  )
  if (length(enrichment_columns) == 0) {
    return(observation)
  }
  for (column_name in SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS) {
    if (!column_name %in% names(observation)) {
      observation[[column_name]] <- NA
    }
  }

  if (
    !all(SNAPSHOT_OBSERVATION_SOURCE_COLUMNS %in% source_columns) ||
    !all(SNAPSHOT_OBSERVATION_SOURCE_COLUMNS %in% names(observation))
  ) {
    observation[setdiff(
      SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS,
      enrichment_columns
    )] <- NULL
    return(observation)
  }

  mapping <- data.table::copy(data.table::as.data.table(loinc_mapping))
  mapping_column_names <- c(
    "LOINC",
    "LOINC_PRIMARY",
    "UNIT",
    "CONVERSION_FACTOR",
    "CONVERSION_UNIT"
  )
  data.table::setnames(mapping, mapping_column_names, c(
    "obs_code_code",
    "primary_loinc_code",
    "reference_unit",
    "conversion_factor",
    "conversion_unit"
  ))
  mapping[["conversion_factor"]] <- normalizeConversionFactor(mapping[["conversion_factor"]])
  mapping[["conversion_unit"]][is.na(mapping[["conversion_factor"]])] <- NA_character_

  observation[["value_in_reference_unit"]] <- as.numeric(observation[["value_in_reference_unit"]])
  observation[["reference_unit"]] <- as.character(observation[["reference_unit"]])
  observation[["primary_loinc_code"]] <- as.character(observation[["primary_loinc_code"]])
  row_id_column <- ".snapshot_pseudonym_row_id"
  source_unit_column <- ".snapshot_pseudonym_source_unit"
  candidate_row_indices <- which(
    observation[["obs_code_system"]] == "http://loinc.org" &
      !is.na(observation[["obs_valuequantity_value"]])
  )
  candidate_mapping_rows <- match(
    observation[["obs_code_code"]][candidate_row_indices],
    mapping[["obs_code_code"]]
  )
  matched_candidate_indices <- which(!is.na(candidate_mapping_rows))

  if (length(matched_candidate_indices) > 0) {
    matched_row_indices <- candidate_row_indices[matched_candidate_indices]
    matched_rows <- observation[matched_row_indices, ]
    matched_rows[[row_id_column]] <- matched_row_indices
    matched_rows[[source_unit_column]] <- getObservationValueUnit(matched_rows)
    matched_mapping_rows <- candidate_mapping_rows[matched_candidate_indices]
    matched_rows[[".snapshot_pseudonym_target_unit"]] <-
      mapping[["reference_unit"]][matched_mapping_rows]
    matched_rows[[".snapshot_pseudonym_primary_loinc"]] <-
      mapping[["primary_loinc_code"]][matched_mapping_rows]
    matched_rows[[".snapshot_pseudonym_conversion_factor"]] <-
      mapping[["conversion_factor"]][matched_mapping_rows]
    matched_rows[[".snapshot_pseudonym_conversion_unit"]] <-
      mapping[["conversion_unit"]][matched_mapping_rows]
    conversion_factor_column <- ".snapshot_pseudonym_conversion_factor"
    conversion_unit_column <- ".snapshot_pseudonym_conversion_unit"
    conversion_group_columns <- c(
      "obs_code_code",
      source_unit_column
    )
    data.table::setorderv(matched_rows, conversion_group_columns, na.last = TRUE)
    conversion_group_ids <- data.table::rleidv(
      matched_rows,
      conversion_group_columns
    )
    group_starts <- which(!duplicated(conversion_group_ids))
    group_ends <- c(group_starts[-1L] - 1L, nrow(matched_rows))
    converted_values <- rep(NA_real_, nrow(matched_rows))
    for (group_index in seq_along(group_starts)) {
      group_rows <- seq.int(group_starts[group_index], group_ends[group_index])
      first_group_row <- group_rows[1L]
      group_conversion_factor <-
        matched_rows[[conversion_factor_column]][first_group_row]
      group_conversion_unit <-
        matched_rows[[conversion_unit_column]][first_group_row]
      converted_values[group_rows] <- etlutils::convertLabUnits(
        measured_value = matched_rows[["obs_valuequantity_value"]][group_rows],
        measured_unit = matched_rows[[source_unit_column]][first_group_row],
        target_unit = matched_rows[[".snapshot_pseudonym_target_unit"]][first_group_row],
        conversion_factor = group_conversion_factor,
        conversion_unit = group_conversion_unit,
        additional_error_message = paste0(
          " for LOINC code ",
          matched_rows[["obs_code_code"]][first_group_row]
        )
      )
    }

    enriched_row_ids <- matched_rows[[row_id_column]]
    observation[["value_in_reference_unit"]][enriched_row_ids] <-
      converted_values
    observation[["reference_unit"]][enriched_row_ids] <-
      matched_rows[[".snapshot_pseudonym_target_unit"]]
    observation[["primary_loinc_code"]][enriched_row_ids] <-
      matched_rows[[".snapshot_pseudonym_primary_loinc"]]
  }

  unused_enrichment_columns <- setdiff(
    SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS,
    enrichment_columns
  )
  observation[unused_enrichment_columns] <- NULL
  observation
}
