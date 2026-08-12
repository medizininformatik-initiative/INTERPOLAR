#' Generate unique fallvignette record IDs
#'
#' Generates random UUID version 4 identifiers for new records in the separate
#' WP8 REDCap project.
#'
#' @param row_count Number of identifiers to generate.
#'
#' @return A character vector containing unique UUIDs.
generateFallvignetteRecordIds <- function(row_count) {
  if (
    !is.numeric(row_count) ||
      length(row_count) != 1L ||
      is.na(row_count) ||
      !is.finite(row_count) ||
      row_count < 0L ||
      row_count != floor(row_count)
  ) {
    stop("row_count must be one non-negative integer.")
  }

  record_ids <- character(as.integer(row_count))
  for (row_index in seq_along(record_ids)) {
    repeat {
      uuid_bytes <- sample.int(256L, 16L, replace = TRUE) - 1L
      uuid_bytes[7] <- bitwOr(bitwAnd(uuid_bytes[7], 15L), 64L)
      uuid_bytes[9] <- bitwOr(bitwAnd(uuid_bytes[9], 63L), 128L)
      uuid_hex <- sprintf("%02x", uuid_bytes)
      record_id <- paste0(
        paste0(uuid_hex[1:4], collapse = ""), "-",
        paste0(uuid_hex[5:6], collapse = ""), "-",
        paste0(uuid_hex[7:8], collapse = ""), "-",
        paste0(uuid_hex[9:10], collapse = ""), "-",
        paste0(uuid_hex[11:16], collapse = "")
      )
      if (!record_id %in% record_ids) {
        record_ids[row_index] <- record_id
        break
      }
    }
  }
  record_ids
}

#' Create a ward-to-department mapping
#'
#' @param ward_definitions Environment or named list containing the
#'   PHASES_WARD definitions from the dataprocessor configuration.
#'
#' @return A data.table with ward_name and department columns.
createFallvignetteWardDepartmentMapping <- function(ward_definitions) {
  if (!is.environment(ward_definitions) && !is.list(ward_definitions)) {
    stop("ward_definitions must be an environment or named list.")
  }

  phase_wards <- etlutils::getVariablesByPrefix(
    "PHASES_WARD",
    envir = ward_definitions
  )
  if (!length(phase_wards)) {
    stop("ward_definitions must contain at least one PHASES_WARD entry.")
  }

  ward_mapping <- data.table::rbindlist(lapply(
    names(phase_wards),
    function(entry_name) {
      entry_lines <- phase_wards[[entry_name]]
      ward_name <- etlutils::extractValuesForKey(entry_lines, "ward_name")
      department <- etlutils::extractValuesForKey(entry_lines, "department")
      if (
        is.na(ward_name) || !nzchar(trimws(ward_name)) ||
          is.na(department) || !nzchar(trimws(department))
      ) {
        stop(
          entry_name,
          " must contain one non-empty ward_name and department."
        )
      }
      data.table::data.table(
        ward_name = trimws(ward_name),
        department = trimws(department)
      )
    }
  ))

  if (anyDuplicated(ward_mapping$ward_name)) {
    duplicate_wards <- unique(
      ward_mapping$ward_name[duplicated(ward_mapping$ward_name)]
    )
    stop(
      "ward_definitions contain duplicate ward_name values: ",
      paste(duplicate_wards, collapse = ", ")
    )
  }
  ward_mapping[]
}

#' Hash a site code for the fallvignette export
#'
#' Applies the same SHA-256 operation used by the snapshot pseudonymization.
#'
#' @param site_code Non-empty site code configured for the exporting site.
#'
#' @return Lowercase hexadecimal SHA-256 hash.
hashFallvignetteSiteCode <- function(site_code) {
  if (
    !is.character(site_code) || length(site_code) != 1L ||
      is.na(site_code) || !nzchar(trimws(site_code))
  ) {
    stop("site_code must be one non-empty string.")
  }
  digest::digest(trimws(site_code), algo = "sha256", serialize = FALSE)
}

#' Create fallvignette import data from directly mapped fields
#'
#' Creates one WP8 import row for every qualifying retrospective MRP evaluation.
#' If both evaluations are marked as factually correct but clinically irrelevant,
#' two rows are created. Fields with only one mapping source are repeated in the
#' second row, while duplicated target fields use their second mapping source.
#' Calculated fallvignette fields remain empty for subsequent processing.
#'
#' @param source_data Source rows returned by [getFallvignetteSourceData()].
#' @param mapping Normalized mapping returned by [loadFallvignetteMapping()].
#' @param ward_definitions Environment or named list containing the
#'   PHASES_WARD definitions from the dataprocessor configuration.
#' @param site_code Non-empty site code configured for the exporting site.
#' @param record_id_fun Function accepting a row count and returning unique
#'   record IDs.
#'
#' @return A data.table with all ordered WP8 output columns.
createFallvignetteImportData <- function(
  source_data,
  mapping,
  ward_definitions,
  site_code,
  record_id_fun = generateFallvignetteRecordIds
) {
  if (!data.table::is.data.table(source_data)) {
    stop("source_data must be a data.table.")
  }
  if (
    !data.table::is.data.table(mapping) ||
      !all(c("target_field", "source_field") %in% names(mapping))
  ) {
    stop("mapping must be a normalized fallvignette mapping.")
  }
  if (!is.function(record_id_fun)) {
    stop("record_id_fun must be a function.")
  }
  hashed_site_code <- hashFallvignetteSiteCode(site_code)

  mapping_source_fields <- mapping[["source_field"]]
  direct_mapping_indices <- which(
    !is.na(mapping_source_fields) &
      nzchar(mapping_source_fields) &
      !mapping[["target_field"]] %in% c(
        "record_id",
        "wp8_standort_id",
        "wp8_mrp_fachbereich"
      )
  )
  direct_mapping <- mapping[
    direct_mapping_indices,
    names(mapping),
    with = FALSE
  ]
  direct_target_fields <- direct_mapping[["target_field"]]
  target_mapping_counts <- table(direct_target_fields)
  if (any(target_mapping_counts > 2L)) {
    stop("Fallvignette mapping must contain at most two sources per target field.")
  }

  eligibility_target <- "wp8_ret_gewiss_grund_abl_01"
  eligibility_mapping_indices <- which(
    direct_target_fields == eligibility_target
  )
  eligibility_mapping <- direct_mapping[
    eligibility_mapping_indices,
    names(direct_mapping),
    with = FALSE
  ]
  if (nrow(eligibility_mapping) != 2L) {
    stop(
      "Fallvignette mapping must contain two sources for ",
      eligibility_target,
      "."
    )
  }

  required_source_columns <- c(
    "fall_station",
    unique(direct_mapping[["source_field"]])
  )
  missing_source_columns <- setdiff(required_source_columns, names(source_data))
  if (length(missing_source_columns)) {
    stop(
      "source_data is missing columns: ",
      paste(missing_source_columns, collapse = ", ")
    )
  }

  required_target_fields <- c(
    "record_id",
    "wp8_standort_id",
    "wp8_mrp_fachbereich",
    unique(direct_target_fields)
  )
  missing_target_fields <- setdiff(
    required_target_fields,
    unique(mapping[["target_field"]])
  )
  if (length(missing_target_fields)) {
    stop(
      "Fallvignette mapping is missing target fields: ",
      paste(missing_target_fields, collapse = ", ")
    )
  }

  output_rows <- data.table::rbindlist(lapply(
    seq_len(nrow(eligibility_mapping)),
    function(evaluation_index) {
      eligibility_source <- eligibility_mapping[["source_field"]][
        evaluation_index
      ]
      eligibility_values <- as.character(source_data[[eligibility_source]])
      data.table::data.table(
        source_row = which(!is.na(eligibility_values) & eligibility_values == "3"),
        evaluation_index = evaluation_index
      )
    }
  ))
  data.table::setorderv(
    output_rows,
    c("source_row", "evaluation_index")
  )

  ward_mapping <- createFallvignetteWardDepartmentMapping(ward_definitions)
  output_wards <- source_data[["fall_station"]][output_rows[["source_row"]]]
  ward_indices <- match(output_wards, ward_mapping[["ward_name"]])
  if (anyNA(ward_indices)) {
    unknown_wards <- unique(output_wards[is.na(ward_indices)])
    unknown_wards[is.na(unknown_wards)] <- "<NA>"
    stop(
      "No department configured for fall_station: ",
      paste(unknown_wards, collapse = ", ")
    )
  }

  output_count <- nrow(output_rows)
  record_ids <- record_id_fun(output_count)
  if (
    !is.character(record_ids) ||
      length(record_ids) != output_count ||
      anyNA(record_ids) ||
      any(!nzchar(record_ids)) ||
      anyDuplicated(record_ids)
  ) {
    stop("record_id_fun must return one unique, non-empty character ID per row.")
  }

  empty_export <- createEmptyFallvignetteExport(mapping)
  export_data <- data.table::as.data.table(stats::setNames(
    lapply(names(empty_export), function(column_name) {
      rep(NA_character_, output_count)
    }),
    names(empty_export)
  ))
  data.table::set(export_data, j = "record_id", value = record_ids)
  data.table::set(
    export_data,
    j = "wp8_standort_id",
    value = rep(hashed_site_code, output_count)
  )
  data.table::set(
    export_data,
    j = "wp8_mrp_fachbereich",
    value = ward_mapping[["department"]][ward_indices]
  )

  for (target_field in unique(direct_target_fields)) {
    target_mapping_indices <- which(direct_target_fields == target_field)
    target_source_fields <- direct_mapping[["source_field"]][
      target_mapping_indices
    ]
    selected_source_fields <- target_source_fields[pmin(
      output_rows[["evaluation_index"]],
      length(target_source_fields)
    )]
    target_values <- vapply(
      seq_len(output_count),
      function(output_index) {
        as.character(source_data[[selected_source_fields[output_index]]][
          output_rows[["source_row"]][output_index]
        ])
      },
      character(1)
    )
    data.table::set(
      export_data,
      j = target_field,
      value = target_values
    )
  }

  calculated_mapping_indices <- which(
    is.na(mapping_source_fields) | !nzchar(mapping_source_fields)
  )
  calculated_target_fields <- intersect(
    mapping[["target_field"]][calculated_mapping_indices],
    names(source_data)
  )
  for (target_field in calculated_target_fields) {
    data.table::set(
      export_data,
      j = target_field,
      value = as.character(source_data[[target_field]][
        output_rows[["source_row"]]
      ])
    )
  }
  export_data[]
}
