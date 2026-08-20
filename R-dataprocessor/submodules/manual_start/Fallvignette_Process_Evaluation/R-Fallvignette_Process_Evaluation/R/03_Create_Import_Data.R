#' Generate unique fallvignette record IDs and their local mapping
#'
#' Combines the site code with a one-based, zero-padded sequence and hashes the
#' resulting local IDs with SHA-256. The unhashed IDs are retained only in the
#' returned local mapping.
#'
#' @param row_count Number of identifiers to generate.
#' @param site_code Non-empty site code configured for the exporting site.
#'
#' @return A `data.table` containing local_record_id and record_id.
generateFallvignetteRecordIdMapping <- function(row_count, site_code) {
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
  if (
    !is.character(site_code) || length(site_code) != 1L ||
      is.na(site_code) || !nzchar(trimws(site_code))
  ) {
    stop("site_code must be one non-empty string.")
  }

  local_record_ids <- if (row_count == 0L) {
    character()
  } else {
    paste0(
      trimws(site_code),
      sprintf("%04d", seq_len(as.integer(row_count)))
    )
  }
  record_ids <- vapply(
    local_record_ids,
    digest::digest,
    character(1),
    algo = "sha256",
    serialize = FALSE
  )
  data.table::data.table(
    local_record_id = local_record_ids,
    record_id = record_ids
  )
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
#' @param record_id_mapping_fun Function accepting a row count and site code
#'   and returning local and hashed record IDs.
#'
#' @return A data.table with all ordered WP8 output columns.
createFallvignetteImportData <- function(
  source_data,
  mapping,
  ward_definitions,
  site_code,
  record_id_mapping_fun = generateFallvignetteRecordIdMapping
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
  if (!is.function(record_id_mapping_fun)) {
    stop("record_id_mapping_fun must be a function.")
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
  redcap_code_values <- c(
    wp8_ret_gewissheit = "3",
    wp8_ret_gewiss_grund_abl_01 = "3"
  )
  checkbox_target <- "wp8_ret_gewiss_grund_abl_klin_neg___1"
  mrp_class_values <- c(
    `Drug-Drug` = "1",
    `Drug-Disease` = "2",
    `Drug-Niereninsuffizienz` = "3"
  )
  atc_targets <- c("wp8_ret_atc1_2026", "wp8_ret_atc2_2026")
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
    "mrp_auswahl_complete",
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

  complete_values <- unique(mapping[["fixed_value"]][
    mapping[["target_field"]] == "mrp_auswahl_complete"
  ])
  complete_values <- complete_values[
    !is.na(complete_values) & nzchar(complete_values)
  ]
  if (length(complete_values) != 1L) {
    stop("mrp_auswahl_complete must contain exactly one fixed Value.")
  }

  output_rows <- data.table::rbindlist(lapply(
    seq_len(nrow(eligibility_mapping)),
    function(evaluation_index) {
      eligibility_source <- eligibility_mapping[["source_field"]][
        evaluation_index
      ]
      eligibility_values <- as.character(source_data[[eligibility_source]])
      data.table::data.table(
        source_row = which(
          !is.na(eligibility_values) &
            eligibility_values ==
              "MRP sachlich richtig, aber klinisch nicht relevant"
        ),
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
  record_id_mapping <- data.table::as.data.table(
    record_id_mapping_fun(output_count, site_code)
  )
  if (
    !all(c("local_record_id", "record_id") %in% names(record_id_mapping)) ||
      nrow(record_id_mapping) != output_count ||
      anyNA(record_id_mapping[["local_record_id"]]) ||
      anyNA(record_id_mapping[["record_id"]]) ||
      any(!nzchar(record_id_mapping[["local_record_id"]])) ||
      any(!nzchar(record_id_mapping[["record_id"]])) ||
      anyDuplicated(record_id_mapping[["local_record_id"]]) ||
      anyDuplicated(record_id_mapping[["record_id"]])
  ) {
    stop(
      "record_id_mapping_fun must return one unique, non-empty local_record_id ",
      "and record_id per row."
    )
  }

  empty_export <- createEmptyFallvignetteExport(mapping)
  export_data <- data.table::as.data.table(stats::setNames(
    lapply(names(empty_export), function(column_name) {
      rep(NA_character_, output_count)
    }),
    names(empty_export)
  ))
  data.table::set(
    export_data,
    j = "record_id",
    value = record_id_mapping[["record_id"]]
  )
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
  data.table::set(
    export_data,
    j = "mrp_auswahl_complete",
    value = rep(complete_values, output_count)
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
    if (target_field %in% names(redcap_code_values)) {
      target_values[] <- redcap_code_values[[target_field]]
    }
    if (identical(target_field, checkbox_target)) {
      invalid_values <- unique(target_values[
        !is.na(target_values) &
          !target_values %in% c("Unchecked", "Checked")
      ])
      if (length(invalid_values)) {
        stop(
          checkbox_target,
          " must contain only Unchecked, Checked or NA: ",
          paste(invalid_values, collapse = ", ")
        )
      }
      target_values[which(target_values == "Unchecked")] <- "0"
      target_values[which(target_values == "Checked")] <- "1"
    }
    if (identical(target_field, "wp8_ret_ip_klasse_01")) {
      nonempty_values <- !is.na(target_values) & nzchar(target_values)
      invalid_values <- unique(target_values[
        nonempty_values & !target_values %in% names(mrp_class_values)
      ])
      if (length(invalid_values)) {
        stop(
          target_field,
          " contains invalid MRP classes: ",
          paste(invalid_values, collapse = ", ")
        )
      }
      target_values[nonempty_values] <- unname(
        mrp_class_values[target_values[nonempty_values]]
      )
    }
    if (target_field %in% atc_targets) {
      nonempty_values <- !is.na(target_values) & nzchar(trimws(target_values))
      atc_codes <- sub("\\s+-.*$", "", trimws(target_values))
      invalid_values <- unique(target_values[
        nonempty_values &
          !grepl("^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$", atc_codes)
      ])
      if (length(invalid_values)) {
        stop(
          target_field,
          " contains invalid ATC values: ",
          paste(invalid_values, collapse = ", ")
        )
      }
      target_values[nonempty_values] <- atc_codes[nonempty_values]
    }
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
  traceability_columns <- intersect(
    c(
      "source_record_id",
      "pat_id",
      "fall_id",
      "fall_fhir_enc_id",
      "meda_id",
      "ret_id",
      "ret_meda_id"
    ),
    names(source_data)
  )
  local_mapping <- data.table::copy(record_id_mapping)
  data.table::set(
    local_mapping,
    j = "site_code",
    value = rep(trimws(site_code), output_count)
  )
  data.table::set(
    local_mapping,
    j = "evaluation_index",
    value = output_rows[["evaluation_index"]]
  )
  for (column_name in traceability_columns) {
    data.table::set(
      local_mapping,
      j = column_name,
      value = source_data[[column_name]][output_rows[["source_row"]]]
    )
  }
  data.table::setcolorder(
    local_mapping,
    c(
      "record_id",
      "local_record_id",
      "site_code",
      "evaluation_index",
      traceability_columns
    )
  )
  attr(export_data, "fallvignette_id_mapping") <- local_mapping
  export_data[]
}
