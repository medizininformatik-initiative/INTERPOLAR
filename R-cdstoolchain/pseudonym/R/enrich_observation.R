SNAPSHOT_LOINC_MAPPING_FILE <- file.path(
  "LOINC_Mapping",
  "LOINC_Mapping_content",
  "LOINC_Mapping_Table_processed.xlsx"
)

SNAPSHOT_OBSERVATION_ANALYSIS_DEFAULTS <- list(
  analysis_loinc_code = NA_character_,
  analysis_unit = NA_character_,
  analysis_value = NA_real_,
  analysis_value_status = NA_character_
)

SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS <- names(SNAPSHOT_OBSERVATION_ANALYSIS_DEFAULTS)

SNAPSHOT_OBSERVATION_SOURCE_COLUMNS <- c(
  "obs_code_system",
  "obs_code_code",
  "obs_valuequantity_value",
  "obs_valuequantity_code",
  "obs_valuequantity_unit"
)

SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN <- ".snapshot_pseudonym_loinc_conversion_issue"
SNAPSHOT_LOINC_MAPPING_UNIT_COLUMN <- ".snapshot_pseudonym_loinc_mapping_conversion_unit"
SNAPSHOT_LOINC_TARGET_UNIT_COLUMN <- ".snapshot_pseudonym_loinc_target_unit"

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

emptyLoincUnitConversionReview <- function() {
  data.table::data.table(
    TABLE_NAME = character(),
    LOINC_CODE = character(),
    SOURCE_UNIT_CODE = character(),
    SOURCE_UNIT_DISPLAY = character(),
    USED_SOURCE_UNIT = character(),
    MAPPING_CONVERSION_UNIT = character(),
    TARGET_UNIT = character(),
    AFFECTED_ROWS = numeric()
  )
}

getLoincUnitConversionReview <- function(table, table_name) {
  table <- data.table::as.data.table(table)
  if (!SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN %in% names(table)) {
    return(emptyLoincUnitConversionReview())
  }
  issue_rows <- which(table[[SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN]] %in% TRUE)
  if (length(issue_rows) == 0) {
    return(emptyLoincUnitConversionReview())
  }
  review <- data.table::data.table(
    TABLE_NAME = table_name,
    LOINC_CODE = as.character(table[["obs_code_code"]][issue_rows]),
    SOURCE_UNIT_CODE = as.character(table[["obs_valuequantity_code"]][issue_rows]),
    SOURCE_UNIT_DISPLAY = as.character(table[["obs_valuequantity_unit"]][issue_rows]),
    USED_SOURCE_UNIT = as.character(getObservationValueUnit(table)[issue_rows]),
    MAPPING_CONVERSION_UNIT = as.character(table[[SNAPSHOT_LOINC_MAPPING_UNIT_COLUMN]][issue_rows]),
    TARGET_UNIT = as.character(table[[SNAPSHOT_LOINC_TARGET_UNIT_COLUMN]][issue_rows]),
    N = 1L
  )
  sumDataTableColumnBy(
    review,
    group_columns = setdiff(names(review), "N"),
    value_column = "N",
    result_column = "AFFECTED_ROWS"
  )
}

newLoincUnitConversionReview <- function() {
  context <- new.env(parent = emptyenv())
  context$summary <- emptyLoincUnitConversionReview()
  context$reported_issue_keys <- character()
  context
}

loincUnitConversionIssueKeys <- function(review) {
  key_columns <- setdiff(names(emptyLoincUnitConversionReview()), c("TABLE_NAME", "AFFECTED_ROWS"))
  key_values <- lapply(key_columns, function(column_name) {
    values <- as.character(review[[column_name]])
    values[is.na(values)] <- "<NA>"
    values
  })
  do.call(paste, c(key_values, sep = "\r"))
}

formatLoincUnitReviewValue <- function(value) {
  value <- as.character(value)
  if (length(value) == 0 || is.na(value) || !nzchar(value)) {
    return("<leer>")
  }
  paste0('"', value, '"')
}

reportNewLoincUnitConversionIssues <- function(context, review) {
  issue_keys <- loincUnitConversionIssueKeys(review)
  new_rows <- which(!issue_keys %in% context$reported_issue_keys)
  if (length(new_rows) == 0) {
    return(invisible())
  }
  for (row_index in new_rows) {
    message(
      "WARNING: Laboreinheit nicht umrechenbar: LOINC ",
      review[["LOINC_CODE"]][row_index],
      "; verwendete Einheit ",
      formatLoincUnitReviewValue(review[["USED_SOURCE_UNIT"]][row_index]),
      "; Unit-Code ",
      formatLoincUnitReviewValue(review[["SOURCE_UNIT_CODE"]][row_index]),
      "; Unit-Anzeige ",
      formatLoincUnitReviewValue(review[["SOURCE_UNIT_DISPLAY"]][row_index]),
      "; Mapping-Eingangseinheit ",
      formatLoincUnitReviewValue(review[["MAPPING_CONVERSION_UNIT"]][row_index]),
      "; Zieleinheit ",
      formatLoincUnitReviewValue(review[["TARGET_UNIT"]][row_index]),
      "."
    )
  }
  context$reported_issue_keys <- unique(c(context$reported_issue_keys, issue_keys[new_rows]))
  invisible()
}

recordLoincUnitConversionReview <- function(context, review) {
  if (nrow(review) == 0) {
    return(invisible())
  }
  reportNewLoincUnitConversionIssues(context, review)
  group_columns <- setdiff(names(context$summary), "AFFECTED_ROWS")
  context$summary <- sumDataTableColumnBy(
    data.table::rbindlist(list(context$summary, review)),
    group_columns = group_columns,
    value_column = "AFFECTED_ROWS",
    result_column = "AFFECTED_ROWS"
  )
  invisible()
}

finalizeLoincUnitConversionReview <- function(context) {
  data.table::setorderv(
    context$summary,
    c("TABLE_NAME", "LOINC_CODE", "USED_SOURCE_UNIT", "TARGET_UNIT")
  )
  context$summary[]
}

enrichObservationWithLoincMapping <- function(
  observation,
  loinc_mapping,
  enrichment_columns = SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS,
  source_columns = names(observation)
) {
  observation <- data.table::copy(data.table::as.data.table(observation))
  enrichment_columns <- intersect(enrichment_columns, SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS)
  if (length(enrichment_columns) == 0) {
    return(observation)
  }
  for (column_name in SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS) {
    if (!column_name %in% names(observation)) {
      observation[[column_name]] <- rep(
        SNAPSHOT_OBSERVATION_ANALYSIS_DEFAULTS[[column_name]],
        nrow(observation)
      )
    }
  }

  if (
    !all(SNAPSHOT_OBSERVATION_SOURCE_COLUMNS %in% source_columns) ||
    !all(SNAPSHOT_OBSERVATION_SOURCE_COLUMNS %in% names(observation))
  ) {
    observation[setdiff(SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS, enrichment_columns)] <- NULL
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
    "analysis_loinc_code",
    "analysis_unit",
    "conversion_factor",
    "conversion_unit"
  ))
  mapping[["conversion_factor"]] <- normalizeConversionFactor(mapping[["conversion_factor"]])
  mapping[["conversion_unit"]][is.na(mapping[["conversion_factor"]])] <- NA_character_

  observation[["analysis_value"]] <- as.numeric(observation[["analysis_value"]])
  observation[["analysis_unit"]] <- as.character(observation[["analysis_unit"]])
  observation[["analysis_loinc_code"]] <- as.character(observation[["analysis_loinc_code"]])
  observation[["analysis_value_status"]] <- as.character(observation[["analysis_value_status"]])
  row_id_column <- ".snapshot_pseudonym_row_id"
  source_unit_column <- ".snapshot_pseudonym_source_unit"
  loinc_row_indices <- which(observation[["obs_code_system"]] == "http://loinc.org")
  source_units <- getObservationValueUnit(observation)
  observation[["analysis_loinc_code"]][loinc_row_indices] <-
    observation[["obs_code_code"]][loinc_row_indices]
  observation[["analysis_unit"]][loinc_row_indices] <- source_units[loinc_row_indices]
  observation[["analysis_value"]][loinc_row_indices] <-
    observation[["obs_valuequantity_value"]][loinc_row_indices]
  observation[["analysis_value_status"]][loinc_row_indices] <- "missing_value"

  loinc_mapping_rows <- match(
    observation[["obs_code_code"]][loinc_row_indices],
    mapping[["obs_code_code"]]
  )
  mapped_loinc_indices <- which(!is.na(loinc_mapping_rows))
  mapped_primary_loincs <-
    mapping[["analysis_loinc_code"]][loinc_mapping_rows[mapped_loinc_indices]]
  has_mapped_primary <- !is.na(mapped_primary_loincs) & nzchar(trimws(mapped_primary_loincs))
  observation[["analysis_loinc_code"]][
    loinc_row_indices[mapped_loinc_indices[has_mapped_primary]]
  ] <- mapped_primary_loincs[has_mapped_primary]

  candidate_loinc_indices <- which(
    !is.na(observation[["obs_valuequantity_value"]][loinc_row_indices])
  )
  candidate_row_indices <- loinc_row_indices[candidate_loinc_indices]
  candidate_source_units <- source_units[candidate_row_indices]
  candidate_units_missing <- is.na(candidate_source_units) | !nzchar(trimws(candidate_source_units))
  observation[["analysis_value_status"]][candidate_row_indices] <-
    data.table::fifelse(
      candidate_units_missing,
      "source_no_mapping_missing_unit",
      "source_no_mapping"
    )
  candidate_mapping_rows <- loinc_mapping_rows[candidate_loinc_indices]
  matched_candidate_indices <- which(!is.na(candidate_mapping_rows))

  if (length(matched_candidate_indices) > 0) {
    matched_row_indices <- candidate_row_indices[matched_candidate_indices]
    matched_rows <- observation[matched_row_indices, ]
    matched_rows[[row_id_column]] <- matched_row_indices
    matched_rows[[source_unit_column]] <- source_units[matched_row_indices]
    matched_mapping_rows <- candidate_mapping_rows[matched_candidate_indices]
    matched_rows[[".snapshot_pseudonym_target_unit"]] <-
      mapping[["analysis_unit"]][matched_mapping_rows]
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
    conversion_group_ids <- data.table::rleidv(matched_rows, conversion_group_columns)
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
      group_target_unit <- matched_rows[[".snapshot_pseudonym_target_unit"]][first_group_row]
      if (is.na(group_target_unit) || !nzchar(trimws(group_target_unit))) {
        next
      }
      invisible(utils::capture.output(
        converted_values[group_rows] <- etlutils::convertLabUnits(
          measured_value = matched_rows[["obs_valuequantity_value"]][group_rows],
          measured_unit = matched_rows[[source_unit_column]][first_group_row],
          target_unit = group_target_unit,
          conversion_factor = group_conversion_factor,
          conversion_unit = group_conversion_unit,
          additional_error_message = paste0(
            " for LOINC code ",
            matched_rows[["obs_code_code"]][first_group_row]
          )
        )
      ))
    }

    enriched_row_ids <- matched_rows[[row_id_column]]
    converted_rows <- which(!is.na(converted_values))
    if (length(converted_rows) > 0) {
      converted_row_ids <- enriched_row_ids[converted_rows]
      converted_source_units <- matched_rows[[source_unit_column]][converted_rows]
      converted_target_units <- matched_rows[[".snapshot_pseudonym_target_unit"]][converted_rows]
      same_unit <- !is.na(converted_source_units) &
        !is.na(converted_target_units) &
        tolower(trimws(converted_source_units)) == tolower(trimws(converted_target_units))
      observation[["analysis_value"]][converted_row_ids] <- converted_values[converted_rows]
      observation[["analysis_unit"]][converted_row_ids] <- converted_target_units
      observation[["analysis_value_status"]][converted_row_ids] <-
        data.table::fifelse(same_unit, "already_reference_unit", "converted")
    }
    failed_conversion_rows <- which(is.na(converted_values))
    if (length(failed_conversion_rows) > 0) {
      failed_row_ids <- enriched_row_ids[failed_conversion_rows]
      failed_source_units <- matched_rows[[source_unit_column]][failed_conversion_rows]
      failed_target_units <-
        matched_rows[[".snapshot_pseudonym_target_unit"]][failed_conversion_rows]
      failed_units_missing <- is.na(failed_source_units) | !nzchar(trimws(failed_source_units))
      failed_targets_missing <- is.na(failed_target_units) | !nzchar(trimws(failed_target_units))
      observation[["analysis_value_status"]][failed_row_ids] <-
        data.table::fifelse(
          failed_targets_missing,
          "source_mapping_missing_unit",
          data.table::fifelse(
            failed_units_missing,
            "source_missing_unit",
            "source_conversion_failed"
          )
        )
      observation[[SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN]] <- FALSE
      observation[[SNAPSHOT_LOINC_MAPPING_UNIT_COLUMN]] <- NA_character_
      observation[[SNAPSHOT_LOINC_TARGET_UNIT_COLUMN]] <- NA_character_
      observation[[SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN]][failed_row_ids] <- TRUE
      observation[[SNAPSHOT_LOINC_MAPPING_UNIT_COLUMN]][failed_row_ids] <-
        matched_rows[[conversion_unit_column]][failed_conversion_rows]
      observation[[SNAPSHOT_LOINC_TARGET_UNIT_COLUMN]][failed_row_ids] <-
        matched_rows[[".snapshot_pseudonym_target_unit"]][failed_conversion_rows]
    }
  }

  unused_enrichment_columns <- setdiff(SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS, enrichment_columns)
  observation[unused_enrichment_columns] <- NULL
  observation
}
