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
      dplyr::relocate(main_enc_period_start, .after = main_enc_id)

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

#' Add Ward Name to Merged Patient-Encounter Data
#'
#' This function enriches the merged patient-encounter table with ward names from a
#' `pids_per_ward_table`, taking into account potential ward changes during a single encounter.
#' Ward names are assigned only to encounters of type `"versorgungsstellenkontakt"`, as higher-level
#' encounters like `"einrichtungskontakt"` and `"abteilungskontakt"` may span multiple wards.
#'
#' @param merged_table_with_main_enc A data frame or tibble containing merged patient and
#'   encounter data. It must include the columns `main_enc_id`, `pat_id`, `enc_type_code`,
#'   `enc_partof_ref`, `enc_class_code`, `enc_period_start`, and `enc_period_end`.
#' @param pids_per_ward_table A data frame or tibble containing the mapping between patients,
#'   encounters, and their associated ward names, including the columns `encounter_id`,
#'   `patient_id`, `ward_name`, and `input_datetime` (indicating the timing of the ward assignment).
#'
#' @return A data frame or tibble that includes the original merged data with an additional
#'   `ward_name` column. The `ward_name` column is placed immediately after `enc_period_end`.
#'
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Assigns a row number within each `main_enc_id` + `enc_partof_ref` group in the merged data.
#'   \item Assigns a row number within each `encounter_id` + `patient_id` group in the ward mapping table,
#'         ordered by `input_datetime`.
#'   \item Performs a left join on `main_enc_id = encounter_id`, `pat_id = patient_id`, and
#'         `grouped_row_number` to align corresponding ward records with sub-encounters.
#'   \item For higher-level encounters (`"einrichtungskontakt"` and `"abteilungskontakt"`),
#'         sets the ward name to `NA_character_`.
#'   \item Removes temporary grouping columns and ensures distinct rows in the result.
#' }
#'
#' @importFrom dplyr left_join select relocate mutate case_when distinct arrange group_by ungroup row_number
#' @export
addWardName <- function(merged_table_with_main_enc,pids_per_ward_table) {
  # TODO: how to identify non-INTERPOLAR ward encounters -----------------
  # TDDO: fix logic, numbering doesn't work as expected (non interpolar ward),
  # also multiple rows for one encounter
  merged_table_with_ward <-merged_table_with_main_enc |>
    dplyr::arrange(main_enc_period_start, enc_class_code, enc_type_code, enc_period_start, enc_period_end) |>
    dplyr::group_by(main_enc_id,enc_partof_ref) |>
    dplyr::mutate(grouped_row_number = dplyr::row_number()) |>
    dplyr::ungroup() |>
    dplyr::left_join(pids_per_ward_table |>
                       dplyr::arrange(patient_id, encounter_id, input_datetime) |>
                       dplyr::group_by(patient_id, encounter_id) |>
                       dplyr::mutate(grouped_row_number = dplyr::row_number()) |>
                       dplyr::ungroup() |>
                       dplyr::select(ward_name, patient_id, encounter_id, grouped_row_number),
                     by = c("main_enc_id" = "encounter_id", "pat_id" = "patient_id", "grouped_row_number")) |>
    dplyr::select(-grouped_row_number) |>
    dplyr::relocate(ward_name, .after = enc_period_end) |>
    dplyr::mutate(ward_name = dplyr::case_when(
      enc_type_code == "einrichtungskontakt" ~ NA_character_,
      enc_type_code == "abteilungskontakt" ~ NA_character_,
      enc_type_code == "versorgungsstellenkontakt" ~ ward_name)) |>
    dplyr::distinct()
  return(merged_table_with_ward)
}

#------------------------------------------------------------------------------#
