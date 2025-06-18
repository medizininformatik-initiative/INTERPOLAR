#' Merge Patient and Encounter Data
#'
#' This function merges patient-level data with encounter-level data into a unified dataset.
#' It extracts the patient ID from the `enc_patient_ref` column in the encounter data and
#' then joins the patient details using that ID.
#'
#' @param patient_table A data frame containing patient information, including at least:
#'   - `pat_id`: FHIR patient ID
#'   - Additional patient attributes such as birthdate, identifier, etc.
#' @param encounter_table A data frame containing encounter information, including at least:
#'   - `enc_patient_ref`: A reference to the patient (format: "Patient/<pat_id>")
#'   - Other encounter attributes such as `enc_id`, `enc_type_code`, etc.
#'
#' @return A data frame that merges the encounter data with patient data, based on the extracted patient ID.
#'   The resulting table includes all columns from both input tables.
#'
#' @details
#' The function performs the following steps:
#' 1. Extracts the `pat_id` from the `enc_patient_ref` string in the `encounter_table`.
#' 2. Performs a left join between the encounter table and the patient table using `pat_id` as the key.
#' 3. Adds suffixes to overlapping column names (`_enc`, `_pat`) to distinguish their origin.
#'
#' This merged dataset is used for further filtering, enrichment, or analysis involving both patient
#' and encounter context.
#'
#' @importFrom dplyr mutate left_join
#' @export

mergePatEnc <- function(patient_table, encounter_table) {

  merged_table <- encounter_table |>
    dplyr::mutate(pat_id = sub("^Patient/", "", enc_patient_ref), .keep = "unused") |>
    dplyr::left_join(patient_table, by = "pat_id", suffix = c("_enc", "_pat")) |>
    dplyr::relocate(
      enc_identifier_value,
      pat_id,
      pat_identifier_value,
      enc_partof_ref,
      enc_class_code,
      enc_type_code,
      pat_birthdate,
      enc_period_start,
      enc_period_end,
      pat_deceaseddatetime,
      enc_status,
      .after = enc_id
    )
  return(merged_table)
}

#------------------------------------------------------------------------------#

#' Add Main Encounter ID to Encounter Table
#'
#' This function adds a new column `main_enc_id` to the encounter table, identifying
#' the top-level inpatient encounter (e.g., a facility-level "einrichtungskontakt" encounter)
#' for each record. It determines the main encounter by walking up the encounter hierarchy
#' based on encounter type and `enc_partof_ref` relationships.
#'
#' @param encounter_table A data frame or tibble containing FHIR-based encounter data.
#'   Must include the following columns:
#'   - `enc_id`: Unique identifier of the encounter.
#'   - `enc_partof_ref`: Reference to the parent encounter (e.g., "Encounter/123").
#'   - `enc_type_code`: Type of the encounter (e.g., "einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt").
#'   - `enc_class_code`: Class of the encounter (e.g., "IMP" for inpatient).
#'
#' @return A data frame or tibble identical to the input but with an additional column:
#'   - `main_enc_id`: The ID of the top-level (main) encounter associated with each record.
#'     For top-level encounters themselves, this is simply their own `enc_id`.
#'
#' @details
#' The main encounter ID is determined using the following logic:
#' 1. If the encounter has no parent (`enc_partof_ref` is `NA`), is of type `"einrichtungskontakt"`,
#'    and class `"IMP"`, it is considered a top-level encounter, and its own `enc_id` is used.
#' 2. If the encounter is of type `"abteilungskontakt"` (departmental contact), its parent is assumed to be the main encounter.
#' 3. If the encounter is of type `"versorgungsstellenkontakt"` (sub-departmental contact), the function extracts the parent encounter's
#'    `enc_id`, finds its parent, and uses that as the top-level `main_enc_id`.
#'
#' @importFrom dplyr mutate case_when relocate
#' @export
addMainEncId <- function(encounter_table) {
  encounter_table_with_main_enc <- encounter_table |>
    dplyr::mutate(main_enc_id = dplyr::case_when(
      # Top-level: einrichtungskontakt
      is.na(enc_partof_ref) &
        enc_type_code == "einrichtungskontakt" &
        enc_class_code == "IMP" ~ enc_id,

      # Middle-level: abteilungskontakt
      enc_type_code == "abteilungskontakt" ~ sub("^Encounter/", "", enc_partof_ref),

      # Bottom-level: versorgungsstellenkontakt
      enc_type_code == "versorgungsstellenkontakt" ~ {
        parent_id <- sub("^Encounter/", "", enc_partof_ref)
        grandparent_ref <- encounter_table$enc_partof_ref[match(parent_id, encounter_table$enc_id)]
        sub("^Encounter/", "", grandparent_ref)
      })) |>
    dplyr::relocate(main_enc_id, .after = enc_id)

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
#'
#' @importFrom dplyr left_join select rename relocate
#' @export
addMainEncPeriodStart <- function(encounter_table_with_main_enc) {
  encounter_table_with_MainEncPeriodStart <- encounter_table_with_main_enc |>
      dplyr::left_join(encounter_table_with_main_enc |>
                         dplyr::select(enc_id, enc_period_start) |>
                         dplyr::rename(main_enc_id = enc_id, main_enc_period_start = enc_period_start),
        by = "main_enc_id") |>
      dplyr::relocate(main_enc_period_start, .after = main_enc_id) |>
    dplyr::arrange(main_enc_period_start, enc_class_code, enc_type_code, enc_period_start, enc_period_end)

  return(encounter_table_with_MainEncPeriodStart)
}


#------------------------------------------------------------------------------#

#' Calculate Patient Age at Main Encounter Start
#'
#' This function calculates the patient's age at the start of the main encounter period (Einrichtungskontakt)
#' by computing the difference between the main encounter start date and the patient's birthdate.
#'
#' @param merged_table_with_MainEncPeriodStart A data frame or tibble containing merged patient
#'   and encounter data. It must include the columns `pat_birthdate` (patient's birth date)
#'   and `main_enc_period_start` (start date of the main encounter (Einrichtungskontakt)).
#'
#' @return A data frame or tibble with an additional column:
#'   - `age_at_hospitalization`: The patient's age in completed years at the time of the main encounter start.
#'
#' @details
#' The function calculates age by taking the difference between `main_enc_period_start` and
#' `pat_birthdate`, converting it into days, dividing by 365.25 to account for leap years,
#' and rounding down to the nearest whole number.
#'
#' @importFrom dplyr mutate
#' @export
calculateAge <- function(merged_table_with_MainEncPeriodStart) {

  merged_table_with_age <- merged_table_with_MainEncPeriodStart |>
    dplyr::mutate(age_at_hospitalization = floor(as.numeric(difftime(as.Date(main_enc_period_start), pat_birthdate)) / 365.25)) |>
    dplyr::relocate(age_at_hospitalization, .after = pat_birthdate)

  return(merged_table_with_age)
}

#------------------------------------------------------------------------------#

#' Add Ward Name to Patient Encounters
#'
#' This function adds ward names to a table of patient encounters by merging it with a table that provides ward names for each patient and encounter.
#' It ensures ward names are placed after the `enc_period_end` column and removes duplicate rows.
#'
#' @param merged_table_with_main_enc A data frame containing patient encounters. Must include `enc_id`, `pat_id`, and `enc_period_end`.
#' @param pids_per_ward_table A data frame containing ward names along with corresponding patient and encounter IDs of the "Versogungsstellenkontakt". Must include `ward_name`, `patient_id`, and `encounter_id`.
#'
#' @return A data frame similar to the input `merged_table_with_main_enc`, but with the `ward_name` column added and located after the `enc_period_end` column. Duplicate rows in the output are removed.
#'
#' @details
#' The function performs a left join between `merged_table_with_main_enc` and `pids_per_ward_table` based on patient and encounter IDs. It relocates the `ward_name` column to directly follow `enc_period_end`, ensuring that the returned table is free of duplicate rows.
#' Note: The current implementation assumes complete join coverage and may require logic refinement for handling situations with multiple rows for a single encounter.
#'
#' @seealso
#' \code{\link[dplyr]{left_join}}, \code{\link[dplyr]{relocate}}, \code{\link[dplyr]{distinct}}
#'
#' @export
addWardName <- function(merged_table_with_main_enc,pids_per_ward_table) {
  # TODO: check multiple rows for one encounter (e.g. ward change)
  merged_table_with_ward <- merged_table_with_main_enc |>
    dplyr::left_join(pids_per_ward_table |>
                       dplyr::select(ward_name, patient_id, encounter_id),
                     by = c("enc_id" = "encounter_id", "pat_id" = "patient_id")) |>
    dplyr::relocate(ward_name, .after = enc_period_end) |>
    dplyr::distinct()
  return(merged_table_with_ward)
}

#------------------------------------------------------------------------------#
