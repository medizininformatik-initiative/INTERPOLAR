# Clinical context preparation for diagnoses, medications, observations and procedures.

#' Add formatted diagnoses to fallvignette source rows
#'
#' Includes every diagnosis assigned to the current encounter. Diagnoses from
#' previous encounters are included only if their ICD code occurs in the
#' processed WP7 Drug-Disease or Drug-Niereninsuffizienz rules and their
#' configured validity period covers the medication analysis timestamp.
#' Identical formatted lines are removed; the same diagnosis with different
#' timestamps is retained.
#'
#' @param source_data Fallvignette source rows. Required columns are pat_id,
#'   fall_fhir_enc_id and meda_dat.
#' @param conditions Condition resources as returned by the existing
#'   getConditionsFromDB() helper.
#' @param diagnosis_rules Combined processed WP7 Drug-Disease and
#'   Drug-Niereninsuffizienz rules containing ICD and ICD_VALIDITY_DAYS.
#' @param datetime_format Format used for available diagnosis timestamps.
#'
#' @return A copy of source_data with the wp8_fv_diagnosen column.
addFallvignetteDiagnoses <- function(
  source_data,
  conditions,
  diagnosis_rules,
  datetime_format = "%Y-%m-%d %H:%M:%S"
) {
  if (!data.table::is.data.table(source_data)) {
    stop("source_data must be a data.table.")
  }
  if (!data.table::is.data.table(conditions)) {
    stop("conditions must be a data.table.")
  }
  if (!data.table::is.data.table(diagnosis_rules)) {
    stop("diagnosis_rules must be a data.table.")
  }

  required_source_columns <- c("pat_id", "fall_fhir_enc_id", "meda_dat")
  required_condition_columns <- c(
    "con_patient_ref",
    "con_encounter_calculated_ref",
    "con_code_code",
    "con_code_system",
    "con_code_display",
    "start_datetime"
  )
  required_rule_columns <- c("ICD", "ICD_VALIDITY_DAYS")
  missing_source_columns <- setdiff(
    required_source_columns,
    names(source_data)
  )
  missing_condition_columns <- setdiff(
    required_condition_columns,
    names(conditions)
  )
  missing_rule_columns <- setdiff(
    required_rule_columns,
    names(diagnosis_rules)
  )
  if (length(missing_source_columns)) {
    stop(
      "source_data is missing columns: ",
      paste(missing_source_columns, collapse = ", ")
    )
  }
  if (length(missing_condition_columns)) {
    stop(
      "conditions is missing columns: ",
      paste(missing_condition_columns, collapse = ", ")
    )
  }
  if (length(missing_rule_columns)) {
    stop(
      "diagnosis_rules is missing columns: ",
      paste(missing_rule_columns, collapse = ", ")
    )
  }

  is_rule_valid <- function(icd_code, diagnosis_datetime, meda_datetime) {
    matching_indices <- which(
      diagnosis_rules[["ICD"]] == icd_code &
        !is.na(diagnosis_rules[["ICD"]])
    )
    if (!length(matching_indices)) {
      return(FALSE)
    }

    validity_values <- trimws(as.character(
      diagnosis_rules[["ICD_VALIDITY_DAYS"]][matching_indices]
    ))
    unlimited <- is.na(validity_values) |
      !nzchar(validity_values) |
      tolower(validity_values) == "unbegrenzt"
    if (any(unlimited)) {
      return(TRUE)
    }
    if (is.na(diagnosis_datetime) || is.na(meda_datetime)) {
      return(FALSE)
    }

    validity_days <- suppressWarnings(as.numeric(validity_values))
    any(
      !is.na(validity_days) &
        diagnosis_datetime >= meda_datetime - validity_days * 24 * 60 * 60 &
        diagnosis_datetime <= meda_datetime
    )
  }

  result <- data.table::copy(source_data)
  diagnosis_texts <- vapply(
    seq_len(nrow(result)),
    function(source_index) {
      patient_reference <- paste0(
        "Patient/",
        result[["pat_id"]][source_index]
      )
      patient_indices <- which(
        conditions[["con_patient_ref"]] == patient_reference &
          conditions[["con_code_system"]] ==
            "http://fhir.de/CodeSystem/bfarm/icd-10-gm"
      )
      if (!length(patient_indices)) {
        return(NA_character_)
      }

      patient_conditions <- conditions[
        patient_indices,
        names(conditions),
        with = FALSE
      ]
      meda_datetime <- asFallvignetteDatetime(result[["meda_dat"]][source_index])
      diagnosis_datetimes <- asFallvignetteDatetime(patient_conditions[["start_datetime"]])
      current_encounter_id <- normalizeFallvignetteReference(
        result[["fall_fhir_enc_id"]][source_index],
        "Encounter"
      )
      condition_encounter_ids <- normalizeFallvignetteReference(
        patient_conditions[["con_encounter_calculated_ref"]],
        "Encounter"
      )
      current_case <- !is.na(condition_encounter_ids) &
        condition_encounter_ids == current_encounter_id
      not_after_analysis <- is.na(diagnosis_datetimes) |
        diagnosis_datetimes <= meda_datetime

      historical_valid <- vapply(
        seq_len(nrow(patient_conditions)),
        function(condition_index) {
          is_rule_valid(
            patient_conditions[["con_code_code"]][condition_index],
            diagnosis_datetimes[condition_index],
            meda_datetime
          )
        },
        logical(1)
      )
      include_condition <- not_after_analysis &
        (current_case | historical_valid)
      included_indices <- which(include_condition)
      if (!length(included_indices)) {
        return(NA_character_)
      }

      included_conditions <- patient_conditions[
        included_indices,
        names(patient_conditions),
        with = FALSE
      ]
      included_datetimes <- diagnosis_datetimes[included_indices]
      diagnosis_displays <- trimws(included_conditions[["con_code_display"]])
      diagnosis_codes <- trimws(included_conditions[["con_code_code"]])

      diagnosis_lines <- diagnosis_displays
      has_code <- !is.na(diagnosis_codes) & nzchar(diagnosis_codes)
      diagnosis_lines[has_code] <- paste0(
        diagnosis_lines[has_code],
        " (ICD: ",
        diagnosis_codes[has_code],
        ")"
      )
      has_datetime <- !is.na(included_datetimes)
      diagnosis_lines[has_datetime] <- paste0(
        diagnosis_lines[has_datetime],
        " [",
        format(
          included_datetimes[has_datetime],
          datetime_format,
          tz = "UTC"
        ),
        "]"
      )
      diagnosis_order <- order(
        tolower(diagnosis_displays),
        diagnosis_codes,
        included_datetimes,
        na.last = TRUE
      )
      paste(unique(diagnosis_lines[diagnosis_order]), collapse = "\n")
    },
    character(1)
  )
  data.table::set(
    result,
    j = "wp8_fv_diagnosen",
    value = diagnosis_texts
  )
  result[]
}

#' Add active medication to fallvignette source rows
#'
#' Includes MedicationRequest resources active at the medication analysis.
#' ATC information is preferred; a directly coded PZN is used as fallback.
#'
#' @param source_data Source rows containing the main encounter and analysis
#'   timestamps.
#' @param medication_requests MedicationRequest resources from
#'   getMedicationRequestsFromDB(), optionally enriched by appendATCColumns().
#' @param datetime_format Format used for the first planned administration.
#' @param active_atc_fun Existing getActiveATCs() helper from the regular MRP
#'   calculation.
#'
#' @return A copy of source_data with the wp8_fv_medikation column.
addFallvignetteMedications <- function(
  source_data,
  medication_requests,
  datetime_format = "%Y-%m-%d %H:%M:%S",
  active_atc_fun = getActiveATCs
) {
  validateFallvignetteClinicalData(
    source_data,
    "source_data",
    c(
      "pat_id",
      "fall_fhir_enc_id",
      "fall_aufn_dat",
      "fall_ent_dat",
      "meda_dat"
    )
  )
  validateFallvignetteClinicalData(
    medication_requests,
    "medication_requests",
    c(
      "medreq_id",
      "medreq_patient_ref",
      "medreq_encounter_calculated_ref",
      "medreq_medicationcodeableconcept_system",
      "medreq_medicationcodeableconcept_code",
      "medreq_medicationcodeableconcept_display",
      "medreq_authoredon",
      "start_datetime",
      "end_datetime"
    )
  )

  medications <- data.table::copy(medication_requests)
  if (!"atc_code" %in% names(medications)) {
    data.table::set(medications, j = "atc_code", value = NA_character_)
  }
  if (!"atc_display" %in% names(medications)) {
    data.table::set(medications, j = "atc_display", value = NA_character_)
  }

  direct_system <- tolower(trimws(as.character(
    medications[["medreq_medicationcodeableconcept_system"]]
  )))
  direct_code <- trimws(as.character(medications[["medreq_medicationcodeableconcept_code"]]))
  direct_display <- trimws(as.character(medications[["medreq_medicationcodeableconcept_display"]]))
  atc_code <- trimws(as.character(medications[["atc_code"]]))
  atc_display <- trimws(as.character(medications[["atc_display"]]))
  has_atc <- !is.na(atc_code) & nzchar(atc_code)
  is_pzn <- !has_atc & !is.na(direct_system) & grepl("pzn", direct_system)

  data.table::set(
    medications,
    j = "fallvignette_code",
    value = data.table::fifelse(
      has_atc,
      atc_code,
      data.table::fifelse(is_pzn, direct_code, NA_character_)
    )
  )
  data.table::set(
    medications,
    j = "fallvignette_code_type",
    value = data.table::fifelse(
      has_atc,
      "ATC",
      data.table::fifelse(is_pzn, "PZN", NA_character_)
    )
  )
  data.table::set(
    medications,
    j = "fallvignette_display",
    value = data.table::fifelse(
      has_atc,
      atc_display,
      data.table::fifelse(is_pzn, direct_display, NA_character_)
    )
  )

  result <- data.table::copy(source_data)
  medication_texts <- vapply(seq_len(nrow(result)), function(source_index) {
    meda_datetime <- asFallvignetteDatetime(result[["meda_dat"]][source_index])
    admission_datetime <- asFallvignetteDatetime(result[["fall_aufn_dat"]][source_index])
    discharge_datetime <- asFallvignetteDatetime(result[["fall_ent_dat"]][source_index])
    patient_reference <- paste0("Patient/", result[["pat_id"]][source_index])
    current_encounter_id <- normalizeFallvignetteReference(
      result[["fall_fhir_enc_id"]][source_index],
      "Encounter"
    )
    request_encounter_ids <- normalizeFallvignetteReference(
      medications[["medreq_encounter_calculated_ref"]],
      "Encounter"
    )
    encounter_request_indices <- which(
      medications[["medreq_patient_ref"]] == patient_reference &
        !is.na(request_encounter_ids) &
        request_encounter_ids == current_encounter_id
    )
    if (!length(encounter_request_indices)) {
      return(NA_character_)
    }

    encounter_requests <- data.table::copy(medications)[
      encounter_request_indices,
      names(medications),
      with = FALSE
    ]
    medication_start <- asFallvignetteDatetime(encounter_requests[["start_datetime"]])
    active_atcs <- active_atc_fun(
      medication_requests = encounter_requests,
      enc_period_start = admission_datetime,
      enc_period_end = discharge_datetime,
      meda_datetime = meda_datetime
    )
    active_request_ids <- unique(active_atcs[["fhir_id"]][
      !is.na(active_atcs[["start_datetime"]]) &
        active_atcs[["start_datetime"]] <= meda_datetime
    ])
    active <- encounter_requests[["medreq_id"]] %in% active_request_ids &
      !is.na(encounter_requests[["fallvignette_code"]]) &
      nzchar(encounter_requests[["fallvignette_code"]])
    included_indices <- which(active %in% TRUE)
    if (!length(included_indices)) {
      return(NA_character_)
    }

    display <- encounter_requests[["fallvignette_display"]][included_indices]
    code <- encounter_requests[["fallvignette_code"]][included_indices]
    code_type <- encounter_requests[["fallvignette_code_type"]][
      included_indices
    ]
    start <- medication_start[included_indices]
    lines <- paste0(display, " (", code_type, ": ", code, ")")
    timestamp <- formatFallvignetteTimestamp(start, datetime_format)
    has_timestamp <- !is.na(timestamp)
    lines[has_timestamp] <- paste0(
      lines[has_timestamp],
      " [",
      timestamp[has_timestamp],
      "]"
    )
    line_order <- order(tolower(display), code, start, na.last = TRUE)
    paste(unique(lines[line_order]), collapse = "\n")
  }, character(1))

  data.table::set(result, j = "wp8_fv_medikation", value = medication_texts)
  result[]
}

validateFallvignetteClinicalData <- function(data, data_name, required_columns) {
  if (!data.table::is.data.table(data)) {
    stop(data_name, " must be a data.table.")
  }
  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns)) {
    stop(
      data_name,
      " is missing columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
}

asFallvignetteDatetime <- function(value) {
  if (inherits(value, "POSIXt")) {
    return(as.POSIXct(value))
  }
  if (inherits(value, "Date")) {
    return(as.POSIXct(value))
  }
  suppressWarnings(as.POSIXct(value, tz = "UTC"))
}

normalizeFallvignetteReference <- function(reference, resource_type) {
  sub(paste0("^", resource_type, "/"), "", reference)
}

formatFallvignetteTimestamp <- function(value, datetime_format) {
  result <- rep(NA_character_, length(value))
  available <- !is.na(value)
  result[available] <- format(value[available], datetime_format, tz = "UTC")
  result
}

#' Add recent WP7 laboratory values to fallvignette source rows
#'
#' Includes every matching LOINC observation from the seven days up to and
#' including the medication analysis timestamp.
#'
#' @param source_data Source rows containing pat_id and meda_dat.
#' @param observations Laboratory observations from getObservationsFromDB().
#' @param loinc_mapping Processed LOINC_Mapping table.
#' @param relevant_loinc_codes LOINC or primary LOINC codes used in WP7 rules.
#' @param lookback_days Number of days before the medication analysis.
#' @param datetime_format Format used for observation timestamps.
#'
#' @return A copy of source_data with the wp8_fv_laborparameter column.
addFallvignetteLaboratoryValues <- function(
  source_data,
  observations,
  loinc_mapping,
  relevant_loinc_codes,
  lookback_days = 7,
  datetime_format = "%Y-%m-%d %H:%M:%S"
) {
  validateFallvignetteClinicalData(
    source_data,
    "source_data",
    c("pat_id", "meda_dat")
  )
  validateFallvignetteClinicalData(
    observations,
    "observations",
    c(
      "obs_patient_ref",
      "obs_code_system",
      "obs_code_code",
      "obs_code_display",
      "obs_valuequantity_value",
      "obs_valuequantity_code",
      "obs_valuequantity_unit",
      "start_datetime"
    )
  )
  validateFallvignetteClinicalData(
    loinc_mapping,
    "loinc_mapping",
    c("LOINC", "LOINC_PRIMARY")
  )
  if (
    !is.numeric(lookback_days) || length(lookback_days) != 1L ||
    is.na(lookback_days) || lookback_days < 0
  ) {
    stop("lookback_days must be one non-negative number.")
  }

  relevant_loinc_codes <- unique(trimws(as.character(relevant_loinc_codes)))
  relevant_loinc_codes <- relevant_loinc_codes[
    !is.na(relevant_loinc_codes) & nzchar(relevant_loinc_codes)
  ]
  mapped_rows <- loinc_mapping[["LOINC"]] %in% relevant_loinc_codes |
    loinc_mapping[["LOINC_PRIMARY"]] %in% relevant_loinc_codes
  relevant_mapping <- loinc_mapping[mapped_rows]
  accepted_codes <- unique(c(
    relevant_loinc_codes,
    relevant_mapping[["LOINC"]],
    relevant_mapping[["LOINC_PRIMARY"]]
  ))

  result <- data.table::copy(source_data)
  laboratory_texts <- vapply(seq_len(nrow(result)), function(source_index) {
    meda_datetime <- asFallvignetteDatetime(result[["meda_dat"]][source_index])
    observation_datetime <- asFallvignetteDatetime(observations[["start_datetime"]])
    patient_reference <- paste0("Patient/", result[["pat_id"]][source_index])
    include <- observations[["obs_patient_ref"]] == patient_reference &
      observations[["obs_code_system"]] == "http://loinc.org" &
      observations[["obs_code_code"]] %in% accepted_codes &
      !is.na(observation_datetime) &
      observation_datetime >= meda_datetime - lookback_days * 24 * 60 * 60 &
      observation_datetime <= meda_datetime
    included_indices <- which(include %in% TRUE)
    if (!length(included_indices)) {
      return(NA_character_)
    }

    code <- as.character(observations[["obs_code_code"]][included_indices])
    display <- trimws(as.character(observations[["obs_code_display"]][included_indices]))

    value <- as.character(observations[["obs_valuequantity_value"]][included_indices])
    unit <- trimws(as.character(observations[["obs_valuequantity_unit"]][included_indices]))
    unit_code <- trimws(as.character(observations[["obs_valuequantity_code"]][included_indices]))
    missing_unit <- is.na(unit) | !nzchar(unit)
    unit[missing_unit] <- unit_code[missing_unit]
    value_text <- value
    has_unit <- !is.na(unit) & nzchar(unit)
    value_text[has_unit] <- paste(value_text[has_unit], unit[has_unit])

    timestamp <- formatFallvignetteTimestamp(
      observation_datetime[included_indices],
      datetime_format
    )
    lines <- paste0(display, " (LOINC: ", code, "): ", value_text)
    has_timestamp <- !is.na(timestamp)
    lines[has_timestamp] <- paste0(
      lines[has_timestamp],
      " [",
      timestamp[has_timestamp],
      "]"
    )
    line_order <- order(
      tolower(display),
      observation_datetime[included_indices],
      code,
      na.last = TRUE
    )
    paste(unique(lines[line_order]), collapse = "\n")
  }, character(1))

  data.table::set(
    result,
    j = "wp8_fv_laborparameter",
    value = laboratory_texts
  )
  result[]
}

#' Add the recent-operation status to fallvignette source rows
#'
#' A recent operation is identified either by a KontaktArt operation Encounter
#' or by an OPS chapter 5 Procedure.
#'
#' @param source_data Source rows containing pat_id and meda_dat.
#' @param procedures OPS-coded Procedure resources from getProceduresFromDB().
#' @param encounters Encounter resources containing the KontaktArt coding.
#' @param lookback_days Number of days before the medication analysis.
#'
#' @return A copy of source_data with wp8_fv_op coded as 1 for yes and 0 for no.
addFallvignetteOperationStatus <- function(
  source_data,
  procedures,
  encounters,
  lookback_days = 30
) {
  validateFallvignetteClinicalData(
    source_data,
    "source_data",
    c("pat_id", "meda_dat")
  )
  validateFallvignetteClinicalData(
    procedures,
    "procedures",
    c(
      "proc_patient_ref",
      "proc_code_system",
      "proc_code_code",
      "start_datetime"
    )
  )
  validateFallvignetteClinicalData(
    encounters,
    "encounters",
    c(
      "enc_patient_ref",
      "enc_type_system",
      "enc_type_code",
      "enc_period_start",
      "enc_period_end"
    )
  )
  if (
    !is.numeric(lookback_days) || length(lookback_days) != 1L ||
    is.na(lookback_days) || lookback_days < 0
  ) {
    stop("lookback_days must be one non-negative number.")
  }

  result <- data.table::copy(source_data)
  operation_status <- vapply(seq_len(nrow(result)), function(source_index) {
    meda_datetime <- asFallvignetteDatetime(result[["meda_dat"]][source_index])
    window_start <- meda_datetime - lookback_days * 24 * 60 * 60
    procedure_datetime <- asFallvignetteDatetime(procedures[["start_datetime"]])
    encounter_start <- asFallvignetteDatetime(encounters[["enc_period_start"]])
    encounter_end <- asFallvignetteDatetime(encounters[["enc_period_end"]])
    patient_reference <- paste0("Patient/", result[["pat_id"]][source_index])

    recent_operation_procedure <-
      procedures[["proc_patient_ref"]] == patient_reference &
        procedures[["proc_code_system"]] ==
          "http://fhir.de/CodeSystem/bfarm/ops" &
        grepl("^5-", procedures[["proc_code_code"]]) &
        !is.na(procedure_datetime) &
        procedure_datetime >= window_start &
        procedure_datetime <= meda_datetime
    recent_operation_encounter <-
      encounters[["enc_patient_ref"]] == patient_reference &
        encounters[["enc_type_system"]] ==
          "http://fhir.de/CodeSystem/kontaktart-de" &
        encounters[["enc_type_code"]] == "operation" &
        !is.na(encounter_start) &
        encounter_start <= meda_datetime &
        (is.na(encounter_end) | encounter_end >= window_start)

    if (
      any(recent_operation_procedure %in% TRUE) ||
      any(recent_operation_encounter %in% TRUE)
    ) {
      "1"
    } else {
      "0"
    }
  }, character(1))

  data.table::set(result, j = "wp8_fv_op", value = operation_status)
  result[]
}

#' Add all calculated clinical context fields
#'
#' Applies the diagnosis, medication, laboratory and operation transformations
#' to the same fallvignette source rows.
#'
#' @param source_data Fallvignette source rows.
#' @param conditions Condition resources from getConditionsFromDB().
#' @param diagnosis_rules Processed WP7 Drug-Disease rules.
#' @param medication_requests MedicationRequest resources.
#' @param observations Laboratory Observation resources.
#' @param loinc_mapping Processed LOINC_Mapping table.
#' @param relevant_loinc_codes LOINC or primary LOINC codes used in WP7 rules.
#' @param procedures OPS-coded Procedure resources.
#' @param encounters Encounter resources containing KontaktArt codings.
#'
#' @return A copy of source_data containing all four calculated fields.
addFallvignetteClinicalContext <- function(
  source_data,
  conditions,
  diagnosis_rules,
  medication_requests,
  observations,
  loinc_mapping,
  relevant_loinc_codes,
  procedures,
  encounters
) {
  result <- addFallvignetteDiagnoses(
    source_data,
    conditions,
    diagnosis_rules
  )
  result <- addFallvignetteMedications(result, medication_requests)
  result <- addFallvignetteLaboratoryValues(
    result,
    observations,
    loinc_mapping,
    relevant_loinc_codes
  )
  addFallvignetteOperationStatus(result, procedures, encounters)
}
