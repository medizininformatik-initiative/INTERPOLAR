#' Merge Patient and Encounter Data
#'
#' This function merges patient-level data with encounter-level data into a unified dataset.
#' It extracts the patient ID from the `enc_patient_ref` column in the encounter data and
#' then joins the patient details using that ID.
#'
#' @param patient_table A data frame containing patient information, including at least:
#'   - `pat_id`: FHIR patient ID
#'   - Additional patient attributes such as birthdate
#' @param encounter_table A data frame containing encounter information, including at least:
#'   - `enc_patient_ref`: A reference to the patient (format: "Patient/<pat_id>")
#'   - Other encounter attributes such as `enc_id`, `enc_type_code_Kontaktebene`, etc.
#'
#' @return A data frame that merges the encounter data with patient data, based on the extracted
#' patient ID. The resulting table includes all columns from both input tables.
#'
#' @details
#' The function performs the following steps:
#' 1. Extracts the `pat_id` from the `enc_patient_ref` string in the `encounter_table`.
#' 2. Performs a left join between the encounter table and the patient table using `pat_id` as the key.
#'
#' This merged dataset is used for further filtering, enrichment, or analysis involving both patient
#' and encounter context.
#'
#' @importFrom dplyr mutate left_join select relocate
#' @export

mergePatEnc <- function(patient_table, encounter_table) {
  merged_table <- encounter_table |>
    dplyr::mutate(pat_id = sub("^Patient/", "", enc_patient_ref), .keep = "unused") |>
    dplyr::left_join(
      patient_table |>
        dplyr::select(c(pat_id, pat_birthdate)) |>
        dplyr::distinct(),
      by = "pat_id"
    ) |>
    dplyr::relocate(
      enc_identifier_value,
      pat_id,
      enc_partof_calculated_ref,
      enc_class_code,
      enc_type_code_Kontaktebene,
      enc_type_code_Kontaktart,
      pat_birthdate,
      enc_period_start,
      enc_period_end,
      enc_status,
      .after = enc_id
    )
  return(merged_table)
}

#------------------------------------------------------------------------------#
#' Add Curated Encounter End Date
#'
#' This function adds a new column `curated_enc_period_end` to the encounter table,
#' handling missing (`NA`) end dates for ongoing hospital stays. If the encounter
#' is marked as `"in-progress"` and has no `enc_period_end`, the current system
#' date is inserted to allow downstream time-based operations.
#'
#' @param encounter_table A data frame containing encounter-level data, with columns
#'   `enc_period_end` and `enc_status`.
#'
#' @return A data frame identical to `encounter_table` with an added column
#'   `curated_enc_period_end`, located immediately after `enc_period_end`.
#'
#' @details
#' The function is especially useful for ensuring valid time intervals in joins
#' or filters where open-ended encounters (i.e., missing `enc_period_end`)
#' would otherwise break logic or be excluded.
#'
#' - If `enc_period_end` is `NA` and `enc_status` is `"in-progress"`, then
#'   `curated_enc_period_end` is set to the current system date (`Sys.Date()`).
#' - If `enc_period_end` is `NA` and `enc_status` is `"onleave"`, then
#'  `curated_enc_period_end` is set to `enc_period_start`.
#' - Otherwise, `curated_enc_period_end` takes the value of `enc_period_end`.
#'
#' If any `curated_enc_period_end` values remain `NA` after this process,
#' a warning is issued and those rows are printed for review. The function also
#' updates the `processing_exclusion_reason` column to indicate the presence of
#' `NA` values in `curated_enc_period_end`: "NA_in_curated_enc_period_end".
#'
#' @importFrom dplyr mutate case_when relocate
#' @export
addCuratedEncPeriodEnd <- function(encounter_table) {
  encounter_table_with_curated_enc_period_end <- encounter_table |>
    dplyr::mutate(curated_enc_period_end = dplyr::case_when(
      is.na(enc_period_end) & enc_status == "in-progress" ~ Sys.time(),
      is.na(enc_period_end) & enc_status == "onleave" ~ enc_period_start,
      TRUE ~ enc_period_end
    )) |>
    dplyr::relocate(curated_enc_period_end, .after = enc_period_end)

  if (any(is.na(encounter_table_with_curated_enc_period_end$curated_enc_period_end))) {
    encounter_table_with_curated_enc_period_end <- encounter_table_with_curated_enc_period_end |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(curated_enc_period_end),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "NA_in_curated_enc_period_end",
          level = "sub_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(
      encounter_table_with_curated_enc_period_end |>
        dplyr::filter(is.na(curated_enc_period_end)),
      width = Inf
    )
    warning("There are NA values in curated_enc_period_end. Please check the data.")
  }
  return(encounter_table_with_curated_enc_period_end)
}

#------------------------------------------------------------------------------#

#' Add Main Encounter ID to Encounter Table
#'
#' This function adds a new column `main_enc_id` to the encounter table, identifying
#' the top-level inpatient encounter (e.g., a facility-level "einrichtungskontakt" encounter)
#' for each record. It determines the main encounter by walking up the encounter hierarchy
#' based on encounter type and `enc_partof_calculated_ref` relationships. If part-of references are not
#' available, it uses the unique`enc_identifier_value` to identify top-level encounters.
#' Update: The function now also uses the pre-calculated `enc_main_encounter_calculated_ref` column
#' from the cds-toolchain to determine the main encounter ID, falling back to the original logic if necessary.
#'
#' @param encounter_table A data frame or tibble containing FHIR-based encounter data.
#'   Must include the following columns:
#'   - `enc_id`: Unique identifier of the encounter.
#'   - `enc_partof_calculated_ref`: Reference to the parent encounter (e.g., "Encounter/123").
#'   - `enc_type_code_Kontaktebene`: Type of the encounter (e.g., "einrichtungskontakt",
#'                                   "abteilungskontakt", "versorgungsstellenkontakt").
#'   - `enc_class_code`: Class of the encounter (e.g., "IMP" for inpatient).
#'   - `enc_identifier_value`: Identifier value for the encounter, used to identify top-level
#'                             encounters.
#'
#' @return A data frame or tibble identical to the input but with an additional column:
#'   - `main_enc_id`: The ID of the top-level (main) encounter associated with each record.
#'     For top-level encounters themselves, this is simply their own `enc_id`.
#'
#' @details
#' The main encounter ID is determined using the following logic:
#' 1. If the encounter has no parent (`enc_partof_calculated_ref` is `NA`), is of type `"einrichtungskontakt"`,
#' it is considered a top-level encounter, and its own `enc_id` is used.
#' 2. If the encounter is of type `"abteilungskontakt"` (departmental contact), its parent is
#'    assumed to be the main encounter.
#' 3. If the encounter is of type `"versorgungsstellenkontakt"` (sub-departmental contact), the
#'    function extracts the parent encounter's `enc_id`, finds its parent, and uses that as the
#'    top-level `main_enc_id`.
#' The function also handles cases where encounters may not have a parent reference but have a
#' unique identifier value. The function also checks for the presence of `enc_identifier_value` for
#' top-level encounters and ensures that there are no multiple `einrichtungskontakt` encounters with
#' the same identifier value. If any inconsistencies are found (e.g., multiple top-level encounters
#' for the same identifier), an error is raised. Update: The function now also uses the pre-calculated
#' `enc_main_encounter_calculated_ref` column from the cds-toolchain to determine the main encounter ID,
#' falling back to the original logic if necessary.
#' If any encounters cannot be assigned a `main_enc_id`, a warning is issued, and those records
#' are printed for review. The `processing_exclusion_reason` column is updated to indicate
#' these cases: "encounter_without_main_enc_id".
#'
#' @importFrom dplyr mutate case_when relocate
#' @export
addMainEncId <- function(encounter_table) {
  encounter_table_with_main_enc <- encounter_table |>
    dplyr::left_join(
      encounter_table |>
        dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
        dplyr::distinct(enc_id, enc_identifier_value),
      by = "enc_identifier_value",
      suffix = c("", "_einrichtungskontakt")
    ) |>
    dplyr::mutate(main_enc_id = dplyr::case_when(
      is.na(enc_partof_calculated_ref) &
        enc_type_code_Kontaktebene != "einrichtungskontakt" ~ enc_id_einrichtungskontakt,

      # Top-level: einrichtungskontakt
      is.na(enc_partof_calculated_ref) &
        enc_type_code_Kontaktebene == "einrichtungskontakt" ~ enc_id,

      # Middle-level: abteilungskontakt
      enc_type_code_Kontaktebene == "abteilungskontakt" ~ sub("^Encounter/", "", enc_partof_calculated_ref),

      # Bottom-level: versorgungsstellenkontakt
      enc_type_code_Kontaktebene == "versorgungsstellenkontakt" ~ {
        parent_id <- sub("^Encounter/", "", enc_partof_calculated_ref)
        grandparent_ref <- encounter_table$enc_partof_calculated_ref[match(parent_id, encounter_table$enc_id)]
        sub("^Encounter/", "", grandparent_ref)
      }
    )) |>
    dplyr::select(-enc_id_einrichtungskontakt) |>
    # use new calculation from cds-toolchain
    dplyr::rename(main_enc_id_initial_try = main_enc_id) |>
    dplyr::mutate(main_enc_id = sub("^Encounter/", "", enc_main_encounter_calculated_ref)) |>
    dplyr::mutate(main_enc_id = dplyr::if_else(is.na(main_enc_id), main_enc_id_initial_try, main_enc_id)) |>
    dplyr::relocate(main_enc_id, main_enc_id_initial_try, .after = enc_id) |>
    dplyr::distinct()

  if (any(is.na(encounter_table_with_main_enc$main_enc_id))) {
    encounter_table_with_main_enc <- encounter_table_with_main_enc |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(main_enc_id),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "encounter_without_main_enc_id",
          level = "sub_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(encounter_table_with_main_enc |>
      dplyr::filter(is.na(main_enc_id)), width = Inf)
    warning("Some encounters have no calculated main_enc_id.
            Please check the data.")
  }

  return(encounter_table_with_main_enc)
}


#------------------------------------------------------------------------------#

#' Add Main Encounter Period Start to Encounter Table
#'
#' This function adds a new column `main_enc_period_start` to the encounter table.
#' It retrieves the `enc_period_start` date from the main (Einrichtungskontakt) encounter associated
#' with each record and joins it based on the `main_enc_id`.
#'
#' @param encounter_table_with_main_enc A data frame or tibble that contains encounter records
#'   with an existing `main_enc_id` column (usually created by \code{\link{addMainEncId}}).
#'   The table must include at least:
#'   - `enc_id`: Encounter ID
#'   - `main_enc_id`: ID of the main (Einrichtungskontakt) encounter
#'   - `enc_period_start`: Start date of the encounter period
#'
#' @return A data frame or tibble with an additional column:
#'   - `main_enc_period_start`: The `enc_period_start` date corresponding to the `main_enc_id`.
#'     This represents the start date of the primary encounter for each record.
#'
#' @details
#' The function performs a left join between the encounter table and a mapping
#' of `main_enc_id` to `enc_period_start`. It ensures that each encounter record
#' has easy access to the start date of its top-level (Einrichtungskontakt) encounter period.
#' The new column is relocated immediately after `main_enc_id` for better readability.
#' If any encounters cannot be assigned a `main_enc_period_start`, a warning is issued,
#' and those records are printed for review. The `processing_exclusion_reason` column
#' is updated to indicate these cases: "encounter_without_main_enc_period_start".
#'
#' @importFrom dplyr left_join select rename relocate
#' @export
addMainEncPeriodStart <- function(encounter_table_with_main_enc) {
  encounter_table_with_MainEncPeriodStart <- encounter_table_with_main_enc |>
    dplyr::left_join(
      encounter_table_with_main_enc |>
        dplyr::select(enc_id, enc_period_start) |>
        dplyr::rename(main_enc_id = enc_id, main_enc_period_start = enc_period_start),
      by = "main_enc_id"
    ) |>
    dplyr::relocate(main_enc_period_start, .after = main_enc_id) |>
    dplyr::arrange(
      main_enc_period_start, enc_class_code, enc_type_code_Kontaktebene,
      enc_period_start, enc_period_end
    )

  if (any(is.na(encounter_table_with_MainEncPeriodStart$main_enc_period_start))) {
    encounter_table_with_MainEncPeriodStart <- encounter_table_with_MainEncPeriodStart |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(main_enc_period_start),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "encounter_without_main_enc_period_start",
          level = "sub_encounter",
          type = "data_issues"
        ),
        "encounter_without_main_enc_period_start",
        processing_exclusion_reason
      ))
    print(encounter_table_with_MainEncPeriodStart |>
      dplyr::filter(is.na(main_enc_period_start)), width = Inf)
    warning("Some encounters have no determined main_enc_period_start.
            Please check the data.")
  }

  return(encounter_table_with_MainEncPeriodStart)
}

#------------------------------------------------------------------------------#

#' Calculate Patient Age at Main Encounter Start
#'
#' This function calculates the patient's age at the start of the main encounter period
#' (Einrichtungskontakt) by computing the difference between the main encounter start date and the
#' patient's birthdate. It adds a new column `age_at_hospitalization` to the merged table.
#' The age is calculated in completed years, rounding down to the nearest whole number.
#'
#' @param merged_table_with_MainEncPeriodStart A data frame or tibble containing merged patient
#'   and encounter data. It must include the columns `pat_birthdate` (patient's birth date)
#'   and `main_enc_period_start` (start date of the main encounter (Einrichtungskontakt)).
#'
#' @return A data frame or tibble with an additional column:
#'   - `age_at_hospitalization`: The patient's age in completed years at the time of the main
#'   encounter start.
#'
#' @details
#' The function calculates age by taking the difference between `main_enc_period_start` and
#' `pat_birthdate`, converting it into days, dividing by 365.25 to account for leap years,
#' and rounding down to the nearest whole number. If any patients cannot have their age
#' determined (i.e., if `age_at_hospitalization` is `NA`), a warning is issued, and those
#' records are printed for review. The `processing_exclusion_reason` column is updated to
#' indicate these cases: "patient_without_determined_age". Similarly, if any patients have
#' an implausible age (<= 0 or > 120), a warning is issued, and those records are printed
#' for review. The `processing_exclusion_reason` column is updated to indicate these cases:
#' "patient_with_implausible_age". If any patients are underage (< 18 years), the
#' `processing_exclusion_reason` column is updated to indicate these cases: "patient_underage".
#'
#' @importFrom dplyr mutate case_when if_else
#' @export
calculateAge <- function(merged_table_with_MainEncPeriodStart) {
  merged_table_with_age <- merged_table_with_MainEncPeriodStart |>
    dplyr::mutate(age_at_hospitalization = floor(as.numeric(difftime(
      as.Date(main_enc_period_start),
      pat_birthdate
    )) / 365.25)) |>
    dplyr::relocate(age_at_hospitalization, .after = pat_birthdate) |>
    dplyr::select(-pat_birthdate)

  if (any(is.na(merged_table_with_age$age_at_hospitalization))) {
    warning("Some patients have no determined age_at_hospitalization.
            Please check the data.")
    merged_table_with_age <- merged_table_with_age |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(age_at_hospitalization),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "patient_without_determined_age",
          level = "main_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(merged_table_with_age |>
      dplyr::filter(is.na(age_at_hospitalization)), width = Inf)
  }

  if (any(merged_table_with_age$age_at_hospitalization <= 0 | merged_table_with_age$age_at_hospitalization > 120)) {
    warning("Some patients have a implausible age_at_hospitalization (<= 0 or > 120).
            Please check the data.")
    merged_table_with_age <- merged_table_with_age |>
      dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
        (age_at_hospitalization <= 0 | age_at_hospitalization > 120) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "patient_with_implausible_age",
            level = "main_encounter",
            type = "data_issues"
          ),
        TRUE ~ processing_exclusion_reason
      ))
    print(merged_table_with_age |>
      dplyr::filter(age_at_hospitalization <= 0 | age_at_hospitalization > 120), width = Inf)
  }

  if (any(merged_table_with_age$age_at_hospitalization < 18)) {
    merged_table_with_age <- merged_table_with_age |>
      dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
        age_at_hospitalization < 18 ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "patient_underage",
            level = "main_encounter",
            type = "not_in_inclusion_criteria"
          ),
        TRUE ~ processing_exclusion_reason
      ))
  }

  return(merged_table_with_age)
}

#------------------------------------------------------------------------------#
#' Tag Ambulant Encounters in the Processing Exclusion Reason
#'
#' This function marks ambulant encounters by appending a structured
#' processing exclusion reason to the \code{processing_exclusion_reason}
#' column for encounters with class code \code{"AMB"}.
#'
#' The tagging uses \code{\link{AddProcessingExclusionReason}} to ensure
#' consistent formatting and to avoid duplicate entries.
#'
#' @param merged_table A data frame containing encounter-level data.
#'   It must include the columns \code{enc_class_code} and
#'   \code{processing_exclusion_reason}.
#'
#' @return
#' A data frame identical to \code{merged_table}, but with
#' \code{processing_exclusion_reason} updated for ambulant encounters.
#'
#' @details
#' For rows where \code{enc_class_code == "AMB"}, the following exclusion
#' reason entry is added:
#'
#' \code{ambulant_encounter|sub_encounter|not_in_inclusion_criteria}
#'
#' If this exclusion reason already exists, it is not added again.
#' Non-ambulant encounters are returned unchanged.
#'
#' @seealso
#' \code{\link{AddProcessingExclusionReason}}
#'
#' @importFrom dplyr mutate case_when
#'
#' @export
tagAmbulantEncounters <- function(merged_table) {
  merged_table_with_ambulant_tag <- merged_table |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      enc_class_code == "AMB" ~
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "ambulant_encounter",
          level = "sub_encounter",
          type = "not_in_inclusion_criteria"
        ),
      TRUE ~ processing_exclusion_reason
    ))
  return(merged_table_with_ambulant_tag)
}

#------------------------------------------------------------------------------#
#' Tag Kontaktarten That Do Not Represent Inpatient Encounters
#'
#' This function identifies encounters whose \code{enc_type_code_Kontaktart}
#' denotes a contact type that should not be considered an inpatient encounter
#' and appends a structured processing exclusion reason accordingly.
#'
#' The tagging is performed using \code{\link{AddProcessingExclusionReason}}
#' to ensure consistent formatting and to prevent duplicate entries.
#'
#' @param merged_table A data frame containing encounter-level data.
#'   It must include the columns \code{enc_type_code_Kontaktart} and
#'   \code{processing_exclusion_reason}.
#'
#' @return
#' A data frame identical to \code{merged_table}, but with
#' \code{processing_exclusion_reason} updated for encounters whose
#' Kontaktart denotes no inpatient encounter.
#'
#' @details
#' The following Kontaktart codes are interpreted as *not* representing
#' inpatient encounters:
#' \itemize{
#'   \item \code{"vorstationaer"}
#'   \item \code{"nachstationaer"}
#'   \item \code{"ub"}
#'   \item \code{"konsil"}
#'   \item \code{"operation"}
#' }
#'
#' For affected rows, the following entry is added to
#' \code{processing_exclusion_reason}:
#'
#' \code{kontaktart_denoting_no_inpatient_encounter|sub_encounter|not_in_inclusion_criteria}
#'
#' If the entry already exists, it is not duplicated.
#' Rows with other Kontaktart codes remain unchanged.
#'
#' @seealso
#' \code{\link{AddProcessingExclusionReason}}
#'
#' @importFrom dplyr mutate case_when
#'
#' @export
tagKontaktartDenotingNoInpatientEncounter <- function(merged_table) {
  kontaktarten_denoting_no_inpatient_encounter <- c(
    "vorstationaer", "nachstationaer",
    "ub", "konsil", "operation"
  )

  merged_table_with_kontaktart_tag <- merged_table |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      enc_type_code_Kontaktart %in% kontaktarten_denoting_no_inpatient_encounter ~
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "kontaktart_denoting_no_inpatient_encounter",
          level = "sub_encounter",
          type = "not_in_inclusion_criteria"
        ),
      TRUE ~ processing_exclusion_reason
    ))
  return(merged_table_with_kontaktart_tag)
}

#------------------------------------------------------------------------------#

#' Add Ward Name to Patient Encounters
#'
#' This function adds ward names to a table of patient encounters by merging it with a table that
#' provides ward names for each patient and encounter.
#' It ensures ward names are placed after the `curated_enc_period_end` column and removes duplicate rows.
#'
#' @param merged_table_with_main_enc A data frame containing patient encounters. Must include
#' `enc_id`, `pat_id`,`curated_enc_period_end` and encounter type/class columns.
#' @param pids_per_ward_table A data frame containing ward names along with corresponding patient
#' and encounter IDs of the "Versogungsstellenkontakt". Must include `ward_name`, `patient_id`, and
#' `encounter_id`.
#'
#' @return A data frame similar to the input `merged_table_with_main_enc`, but with the `ward_name`
#' column added and located after the `curated_enc_period_end` column. Duplicate rows in the output are
#' removed.
#'
#' @details
#' The function performs a left join between `merged_table_with_main_enc` and `pids_per_ward_table`
#' based on patient and encounter IDs. It uses the `enc_id` and `pat_id` from the encounter_table
#' to match with `encounter_id` and `patient_id` in the pids_per_ward_table.
#' it ensures that ward names are added only to 'Versorgungsstellenkontakten'.
#' It relocates the `ward_name` column to directly follow
#' `curated_enc_period_end`, ensuring that the returned table is free of duplicate rows.
#'
#' @seealso
#' \code{\link[dplyr]{left_join}}, \code{\link[dplyr]{relocate}}, \code{\link[dplyr]{distinct}}
#'
#' @importFrom dplyr left_join select relocate distinct case_when
#' @export
addWardName <- function(merged_table_with_main_enc, pids_per_ward_table) {
  merged_table_with_ward <- merged_table_with_main_enc |>
    dplyr::left_join(
      pids_per_ward_table |>
        dplyr::select(ward_name, patient_id, encounter_id),
      by = c("enc_id" = "encounter_id", "pat_id" = "patient_id")
    ) |>
    dplyr::mutate(ward_name = dplyr::case_when(
      enc_type_code_Kontaktebene == "versorgungsstellenkontakt" ~
        ward_name, TRUE ~ NA_character_
    )) |>
    dplyr::relocate(ward_name, .after = curated_enc_period_end) |>
    dplyr::distinct()
  return(merged_table_with_ward)
}

#------------------------------------------------------------------------------#
#' Add Record Merged Table
#'
#' This function adds a `record_id` to each row in a given merged table by joining it with a
#' patient front-end data table. It ensures that each patient entry in the merged table is
#' complemented with its corresponding `record_id` from the patient data when available.
#'
#' @param merged_table_with_ward A dataframe that includes patient and encounter information, likely
#' merged with ward data. It should have columns that can be used to identify patients.
#' @param patient_fe_table A dataframe containing patient front-end data, including columns
#' `pat_id`, and `record_id`.
#'
#' @return A dataframe identical to `merged_table_with_ward` but with an additional
#' `record_id` column, which is relocated immediately after `pat_id`.
#'
#' @details
#' The function performs a left join on `merged_table_with_ward` using `pat_id` from the merged
#' table and matches it with `pat_id` from `patient_fe_table`. This adds the `record_id` to the
#' merged table, providing a unique identification feature that can be crucial for subsequent
#' analyses or data organization tasks. If any patients in the merged table do not have a matching
#' `record_id` in the patient front-end table, a warning is issued, and those records are printed
#' for review. The `processing_exclusion_reason` column is updated to indicate these cases:
#' "patient_without_matching_record_id_in_fe".
#'
#' @importFrom dplyr left_join select relocate if_else
#' @export
addRecordId <- function(merged_table_with_ward, patient_fe_table) {
  merged_table_with_record_id <- merged_table_with_ward |>
    dplyr::left_join(
      patient_fe_table |>
        dplyr::select(pat_id, record_id),
      by = c("pat_id" = "pat_id")
    ) |>
    dplyr::relocate(record_id, .after = pat_id) |>
    dplyr::distinct()

  if (any(is.na(merged_table_with_record_id$record_id))) {
    warning("Some patients in the database have no matching record id in the frontend patient_fe datatable.
            Please check the data.")
    merged_table_with_record_id <- merged_table_with_record_id |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(record_id),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "patient_without_matching_record_id_in_fe",
          level = "patient",
          type = "linkage_issues"
        ),
        processing_exclusion_reason
      ))
    print(merged_table_with_record_id |>
      dplyr::filter(is.na(record_id)), width = Inf)
  }

  return(merged_table_with_record_id)
}

#------------------------------------------------------------------------------#
#' Merge Fall ID and Studienphase into Merged Table
#'
#' This function enriches a merged dataset with additional information from a front-end fall data
#' table. It performs a left join to append the cis Fall ID (`fall_id`) and study phase
#' (`fall_studienphase`) based on multiple matching keys, and renames the resulting columns for
#' clarity.
#'
#' @param merged_table_with_record_id A data frame or tibble that must contain the following columns:
#'   `record_id`, `main_enc_id`, `pat_id`, `ward_name`, `main_enc_period_start`, and `enc_identifier_value`.
#' @param fall_fe_table A data frame or tibble returned by [getFallFeData()], which includes:
#'   `record_id`, `fall_fhir_enc_id`, `fall_pat_id`, `fall_id`, `fall_studienphase`, `fall_station`,
#'   and `fall_aufn_dat`.
#'
#' @return A data frame identical to `merged_table_with_record_id`, but with two additional columns:
#'   \item{`fall_id_cis`}{cis Fall ID, renamed from `fall_id`}
#'   \item{`studienphase`}{Study phase, renamed from `fall_studienphase`}
#' The new columns are relocated for readability: `fall_id_cis` is placed after `enc_identifier_value`,
#' and `studienphase` is placed after `ward_name`.
#'
#' @details
#' The function joins the datasets using a composite key made up of:
#' \itemize{
#'   \item `record_id`
#'   \item `main_enc_id` = `fall_fhir_enc_id`
#'   \item `pat_id` = `fall_pat_id`
#'   \item `ward_name` = `fall_station`
#'   \item `main_enc_period_start` = `fall_aufn_dat`
#' }
#' After the join, the function renames and relocates the relevant columns, and ensures uniqueness
#' using `distinct()`. If any INTERPOLAR ward encounters lack a matching record in the
#' `fall_fe_table`, a warning is issued, and those records are printed for review. The
#' `processing_exclusion_reason` column is updated to indicate these cases: "encounter_without_matching_fall_fe_record".
#' Note: fall_studienphase is currently not used in the analysis, therefore it is commented out.
#'
#'
#' @importFrom dplyr left_join select rename relocate distinct case_when
#' @export
addFallIdAndStudienphase <- function(merged_table_with_record_id, fall_fe_table) {
  merged_table_with_fall_id_and_studienphase <- merged_table_with_record_id |>
    dplyr::left_join(fall_fe_table,
      by = c(
        "record_id" = "record_id", "main_enc_id" = "fall_fhir_enc_id",
        "pat_id" = "fall_pat_id", "ward_name" = "fall_station",
        "main_enc_period_start" = "fall_aufn_dat"
      )
    ) |>
    dplyr::rename(
      fall_id_cis = fall_id # ,
      # studienphase = fall_studienphase
    ) |>
    dplyr::relocate(fall_id_cis, .after = enc_identifier_value) |>
    # dplyr::relocate(studienphase, .after = ward_name) |>
    dplyr::distinct()

  if (any(merged_table_with_fall_id_and_studienphase$enc_type_code_Kontaktebene == "versorgungsstellenkontakt" &
    !is.na(merged_table_with_fall_id_and_studienphase$ward_name) &
    is.na(merged_table_with_fall_id_and_studienphase$fall_id_cis))) {
    warning("Some INTERPOLAR-ward-encounters in the database have no matching record (CIS-identifier) in the
            frontend fall_fe datatable. Please check the data.")
    merged_table_with_fall_id_and_studienphase <- merged_table_with_fall_id_and_studienphase |>
      dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
        enc_type_code_Kontaktebene == "versorgungsstellenkontakt" & !is.na(ward_name) &
          is.na(fall_id_cis) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "encounter_without_matching_fall_fe_record",
            level = "main_encounter",
            type = "linkage_issues"
          ),
        TRUE ~ processing_exclusion_reason
      ))
    print(merged_table_with_fall_id_and_studienphase |>
      dplyr::filter(enc_type_code_Kontaktebene == "versorgungsstellenkontakt" & !is.na(ward_name) &
        is.na(fall_id_cis)), width = Inf)
  }

  return(merged_table_with_fall_id_and_studienphase)
}

#------------------------------------------------------------------------------#

#' Merge Patient Front-End and Fall Front-End Tables
#'
#' This function merges patient front-end (`patient_fe_table`) and case-level front-end
#' (`fall_fe_table`) data based on shared identifiers (`record_id` and `pat_id`).
#' The goal is to enrich the patient-level data with associated case-level details.
#'
#' @param patient_fe_table A data frame containing front-end patient data, including
#'   at least `record_id`, `pat_id`.
#'
#' @param fall_fe_table A data frame containing front-end fall/case data, including
#'   at least `record_id`, `fall_pat_id`, `fall_fhir_enc_id`, `fall_id`, `fall_studienphase`,
#'   `fall_station`, and `fall_aufn_dat`.
#'
#' @return A merged data frame with the selected columns from both input tables.
#'
#' @details
#' The merge operation:
#' - Performs a left join using `record_id` and `pat_id` (matched to `fall_pat_id`),
#' - Adds fall-specific columns such as `fall_fhir_enc_id`, `fall_id`, and `fall_studienphase`
#'   to the patient FE data.
#' - Removes duplicate rows after the merge.
#'
#' This is useful for linking case trajectories from the FE system with individual
#' patient-level data in analytical workflows.
#'
#'
#' @importFrom dplyr left_join select distinct
#' @export
mergePatFeFallFe <- function(patient_fe_table, fall_fe_table) {
  frontend_table <- patient_fe_table |>
    dplyr::left_join(fall_fe_table,
      by = c(
        "pat_id" = "fall_pat_id",
        "record_id"
      )
    ) |>
    dplyr::distinct() |>
    dplyr::rename(
      fall_id_cis = fall_id,
      fall_fhir_main_enc_id = fall_fhir_enc_id
    )
  return(frontend_table)
}


#------------------------------------------------------------------------------#

#' Add Medication Analysis data to Merged FE Table
#'
#' This function merges medication analysis data (`meda_id`, `meda_dat`) into a merged
#' front-end table that contains patient and case-level information.
#' The merge is based on matching both `record_id` and `fall_id_cis` to `fall_meda_id`.
#' It retains all original columns from the merged patient and fall data,
#' and adds the medication analysis fields. In this step, it may happen, that a meda_id is added
#' to a fall record that it doesen't belong to (e.g. it is the fall record of a different ward).
#' This is fixed in the next step after adding only the fitting Versorungsstellenkontakt
#' enc_id with the ovberlapping period_start/end and meda_dat.
#'
#' @param merged_fe_pat_fall_table A data frame that includes merged patient and fall data.
#'   Must include `record_id` and `fall_id_cis`.
#' @param medikationsanalyse_fe_table A data frame with medication analysis entries from the
#' front-end system.
#'   Must include `record_id`, `fall_meda_id`, `meda_id`, `meda_dat`.
#'
#' @return A data frame containing all original columns from `merged_fe_pat_fall_table`,
#'   plus matched medication analysis fields: `meda_id`, `meda_dat`
#'
#' @details
#' The join is based on:
#' - Equality of `record_id`
#' - Equality of `fall_id_cis` and `fall_meda_id`
#'
#' @note
#' - Multiple medication analysis entries per fall are retained.
#'
#' @importFrom dplyr left_join select distinct
#' @export
addMedaData <- function(merged_fe_pat_fall_table, medikationsanalyse_fe_table) {
  merged_fe_pat_fall_meda_table <- merged_fe_pat_fall_table |>
    dplyr::left_join(
      medikationsanalyse_fe_table |>
        dplyr::distinct(),
      by = c("record_id",
        "fall_id_cis" = "fall_meda_id"
      ),
      relationship = "many-to-many"
    ) |>
    dplyr::distinct()
  return(merged_fe_pat_fall_meda_table)
}

#------------------------------------------------------------------------------#
#' Add Encounter ID to Front-End Medication Analysis Table
#'
#' This function enriches a merged front-end data table (`merged_fe_pat_fall_meda_table`) with
#' `enc_id` and additional sub-encounter-related dates by performing a multi-key, non-equi join with
#' the complete FHIR data. The join ensures that medication analysis entries (`meda_dat`) are
#' matched to the corresponding ward stay segment.
#'
#'
#' @param merged_fe_pat_fall_meda_table A data frame containing merged patient, fall, and
#' medication analysis data, typically resulting from `addMedaData()`. Must include `meda_dat`,
#' `pat_id`, `record_id`, `fall_fhir_main_enc_id`, `fall_studienphase`,
#' `fall_station`, and `fall_aufn_dat`.
#'
#' @param full_analysis_set_1 A data frame containing full encounter-level data. Must include columns:
#'   `enc_id`, `main_enc_id`, `main_enc_period_start`, `fall_id_cis`, `pat_id`,
#'   `record_id`, `enc_period_start`, `curated_enc_period_end`, `ward_name`, `studienphase`,
#'   `enc_status`, and `processing_exclusion_reason`.
#'
#' @return A data frame containing all original columns from `merged_fe_pat_fall_meda_table` plus the
#'   matched `enc_id` and related encounter period dates. Only rows where a valid encounter match is
#'   found are retained.
#'
#' @details
#' The join is based on a combination of:
#' - Identifiers (`pat_id`, `record_id`, `main_enc_id`, `fall_id_cis`)
#' - Temporal matching: `meda_dat` must lie within `[enc_period_start, curated_enc_period_end]`
#' - Additional context: `studienphase`, `ward_name`, and `main_enc_period_start` must match the
#' fall metadata
#'
#' The function filters the `full_analysis_set_1` to only include main encounters without any
#' processing exclusion reason.
#' Rows with no matching `enc_id` (e.g., due to unmatched date windows or inconsistencies) are
#' excluded post-join.
#'
#' @note
#' - Make sure `curated_enc_period_end` is preprocessed (e.g., using `addCuratedEncperiodEnd()`) to
#' avoid NAs.
#' - This function is useful when matching granular front-end entries (e.g., medication records) to
#' sub-encounter blocks.
#' - fall_studienphase is currently not used in the analysis, therefore it is commented out.
#'
#' @importFrom dplyr left_join select distinct filter join_by between
#' @export
addEncIdToFeData <- function(merged_fe_pat_fall_meda_table, full_analysis_set_1) {
  merged_fe_pat_fall_meda_table_with_enc_id <- merged_fe_pat_fall_meda_table |>
    dplyr::left_join(
      full_analysis_set_1 |>
        dplyr::group_by(main_enc_id) |>
        dplyr::filter(all(is.na(processing_exclusion_reason))) |> # only use main encounters without exclusion reason
        dplyr::ungroup() |>
        dplyr::select(
          enc_id, main_enc_id, main_enc_period_start, fall_id_cis,
          pat_id, record_id, enc_period_start,
          curated_enc_period_end, ward_name,
          # studienphase,
          enc_status
        ) |>
        dplyr::distinct(),
      by = dplyr::join_by(
        pat_id == pat_id,
        record_id == record_id,
        fall_fhir_main_enc_id == main_enc_id,
        fall_id_cis == fall_id_cis,
        # fall_studienphase == studienphase,
        fall_station == ward_name,
        fall_aufn_dat == main_enc_period_start,
        dplyr::between(
          meda_dat,
          enc_period_start,
          curated_enc_period_end
        )
      )
    ) |>
    dplyr::filter(!(is.na(enc_id) & !is.na(meda_id))) |>
    dplyr::distinct() |>
    dplyr::relocate(enc_id, enc_period_start, curated_enc_period_end, enc_status,
      .after = fall_aufn_dat
    )
  return(merged_fe_pat_fall_meda_table_with_enc_id)
}

#------------------------------------------------------------------------------#

#' Merge MRP Documentation Data with Medication Analysis Table
#'
#' This function merges MRP (Medication-Related Problems) documentation validation data
#' into a processed table that already includes medication analysis data, encounter linkage,
#' and patient/case-level identifiers.
#'
#' @param merged_fe_pat_fall_meda_table_with_enc_id A data frame containing merged patient,
#'   case, and encounter data, enriched with medication analysis IDs (`meda_id`) and linked
#'   to a specific hospital stay segment.
#' @param mrp_dokumentation_validierung_fe_table A data frame containing MRP documentation
#'   validation entries as retrieved by `getMRPDokumentationValidierungFeData()`.
#'
#' @return A data frame that includes all columns from `merged_fe_pat_fall_meda_table_with_enc_id`
#'   along with matching MRP documentation fields (e.g., `mrp_id`, etc.) based on `record_id` and `meda_id`.
#'
#' @details
#' The merge operation is performed on the following keys:
#' - `record_id` (common to both datasets)
#' - `meda_id` from the medication analysis table matched to `mrp_meda_id` in the MRP documentation
#'    table
#'
#' Duplicate entries are removed post-merge using `dplyr::distinct()`.
#'
#' @importFrom dplyr left_join distinct
#' @export
addMRPDokuData <- function(merged_fe_pat_fall_meda_table_with_enc_id,
                           mrp_dokumentation_validierung_fe_table) {
  merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku <- merged_fe_pat_fall_meda_table_with_enc_id |>
    dplyr::left_join(
      mrp_dokumentation_validierung_fe_table |>
        dplyr::distinct(),
      by = c("record_id",
        "meda_id" = "mrp_meda_id"
      )
    ) |>
    dplyr::distinct()
  return(merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku)
}
