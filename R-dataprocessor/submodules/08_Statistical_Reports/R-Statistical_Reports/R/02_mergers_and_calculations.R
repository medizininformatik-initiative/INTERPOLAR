#' Merge Patient, Encounter, and Ward Data
#'
#' This function merges patient data, encounter data, and ward-related patient data into a single dataset.
#' It performs a series of joins to link patients, encounters, and ward-related data using appropriate keys.
#'
#' @param patient_table A data frame containing patient information (e.g., patient ID and other patient details).
#' @param encounter_table A data frame containing encounter data (e.g., encounter ID, patient reference, etc.).
#' @param pids_per_ward_table A data frame containing ward-related patient data (e.g., patient ID, encounter ID, ward name).
#'
#' @return A data frame containing merged data from the patient, encounter, and ward datasets.
#'   The resulting dataset will include columns from all three input tables.
#'
#' @details
#' This function performs the following steps:
#' 1. It modifies the `encounter_table` by extracting the patient ID from the `enc_patient_ref` column.
#' 2. It performs a left join with the `patient_table` to include patient details in the encounter data.
#' 3. It performs another left join with the `pids_per_ward_table` to include ward-related data for each patient and encounter.
#' 4. The function returns the resulting merged data frame.
#'
#' @importFrom dplyr mutate left_join
#' @export
mergePatEncWard <- function(patient_table, encounter_table, pids_per_ward_table) {

  merged_table <- encounter_table |>
    dplyr::mutate(pat_id = sub("^Patient/", "", enc_patient_ref)) |>
    dplyr::left_join(patient_table) |>
    dplyr::left_join(pids_per_ward_table,
                     by = c("enc_patient_ref" = "patient_id",
                            "enc_id" = "encounter_id"),
                     suffix = c("_encounter", "_pids_per_ward"))

  return(merged_table)
}

#------------------------------------------------------------------------------#

#' Calculate Additional Variables for the Merged Table
#'
#' This function calculates additional variables based on the merged patient and encounter data.
#' Specifically, it calculates the age of the patient at the start of the encounter period by
#' calculating the difference between the encounter's start date and the patient's birthdate.
#'
#' @param merged_table A data frame or tibble containing the merged patient and encounter data.
#'   It should include columns such as `pat_birthdate` and `enc_period_start`.
#'
#' @return A data frame or tibble that includes the original data with an additional `age` column,
#'   representing the age of the patient at the start of the encounter period.
#'
#' @details
#' This function calculates the age by using the `enc_period_start` (the start date of the encounter)
#' and `pat_birthdate` (the patient's birthdate) columns in the merged data. The result is a new
#' column `age` that is the patient's age at the time of the encounter start date, calculated in years
#' (with precision to the nearest whole number).
#'
#' @importFrom dplyr mutate
#' @export
calculateAge <- function(merged_table) {

  merged_table_with_calc <- merged_table |>
    dplyr::mutate(age = floor(as.numeric(difftime(as.Date(enc_period_start), pat_birthdate)) / 365.25))

  return(merged_table_with_calc)
}

