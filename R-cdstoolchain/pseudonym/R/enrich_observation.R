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
  observation <- as.data.frame(data.table::copy(observation), stringsAsFactors = FALSE)
  enrichment_columns <- intersect(
    enrichment_columns,
    SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS
  )
  if (length(enrichment_columns) == 0) {
    return(data.table::as.data.table(observation))
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
    return(data.table::as.data.table(observation))
  }

  mapping <- as.data.frame(data.table::copy(loinc_mapping), stringsAsFactors = FALSE)
  mapping_column_names <- c(
    "LOINC",
    "LOINC_PRIMARY",
    "UNIT",
    "CONVERSION_FACTOR",
    "CONVERSION_UNIT"
  )
  names(mapping)[match(mapping_column_names, names(mapping))] <- c(
    "obs_code_code",
    "primary_loinc_code",
    "reference_unit",
    "conversion_factor",
    "conversion_unit"
  )
  mapping[["conversion_factor"]] <- normalizeConversionFactor(mapping[["conversion_factor"]])
  mapping[["conversion_unit"]][is.na(mapping[["conversion_factor"]])] <- NA_character_

  observation[["value_in_reference_unit"]] <- as.numeric(observation[["value_in_reference_unit"]])
  observation[["reference_unit"]] <- as.character(observation[["reference_unit"]])
  observation[["primary_loinc_code"]] <- as.character(observation[["primary_loinc_code"]])
  row_id_column <- ".snapshot_pseudonym_row_id"
  source_unit_column <- ".snapshot_pseudonym_source_unit"
  observation[[row_id_column]] <- seq_len(nrow(observation))
  observation[[source_unit_column]] <- getObservationValueUnit(observation)

  observation_rows <- observation[
    observation[["obs_code_system"]] == "http://loinc.org" &
      !is.na(observation[["obs_valuequantity_value"]]), ,
    drop = FALSE
  ]
  mapping_by_loinc <- match(observation_rows[["obs_code_code"]], mapping[["obs_code_code"]])
  matched_rows <- which(!is.na(mapping_by_loinc))

  if (length(matched_rows) > 0) {
    matched_mapping_rows <- mapping_by_loinc[matched_rows]
    converted_values <- vapply(seq_along(matched_rows), function(i) {
      etlutils::convertLabUnits(
        measured_value = observation_rows[["obs_valuequantity_value"]][matched_rows[i]],
        measured_unit = observation_rows[[source_unit_column]][matched_rows[i]],
        target_unit = mapping[["reference_unit"]][matched_mapping_rows[i]],
        conversion_factor = mapping[["conversion_factor"]][matched_mapping_rows[i]],
        conversion_unit = mapping[["conversion_unit"]][matched_mapping_rows[i]],
        additional_error_message = paste0(
          " for LOINC code ",
          observation_rows[["obs_code_code"]][matched_rows[i]]
        )
      )
    }, numeric(1))

    enriched_row_ids <- observation_rows[[row_id_column]][matched_rows]
    observation[["value_in_reference_unit"]][enriched_row_ids] <- converted_values
    observation[["reference_unit"]][enriched_row_ids] <-
      mapping[["reference_unit"]][matched_mapping_rows]
    observation[["primary_loinc_code"]][enriched_row_ids] <-
      mapping[["primary_loinc_code"]][matched_mapping_rows]
  }

  observation[[row_id_column]] <- NULL
  observation[[source_unit_column]] <- NULL
  unused_enrichment_columns <- setdiff(
    SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS,
    enrichment_columns
  )
  observation[unused_enrichment_columns] <- NULL
  data.table::as.data.table(observation)
}

#' Enrich Snapshot Observation Tables with Primary LOINC Reference Values
#'
#' Adds snapshot-specific observation columns from the configured LOINC mapping:
#' `value_in_reference_unit`, `reference_unit`, and `primary_loinc_code`.
#'
#' @param tables Named list of snapshot source tables.
#' @param input_repo_path TOML-configured input repository directory.
#'
#' @return The table list with enriched `observation` tables.
#' @export
enrichSnapshotObservationTables <- function(tables, input_repo_path) {
  if (is.null(tables[["observation"]]) && is.null(tables[["observation_last_version"]])) {
    return(tables)
  }

  loinc_mapping <- loadSnapshotLoincMapping(input_repo_path)
  observation_table_names <- intersect(
    c("observation", "observation_last_version"),
    names(tables)
  )
  for (table_name in observation_table_names) {
    tables[[table_name]] <- enrichObservationWithLoincMapping(
      tables[[table_name]],
      loinc_mapping
    )
  }

  tables
}
