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

#' Add Main Encounter Period Start to Merged Table
#'
#' This function adds a new column `main_enc_period_start` to the merged dataset.
#' It determines the start date of the main inpatient encounter by checking whether
#' an encounter is an inpatient facility contact (`einrichtungskontakt`) of class `IMP`.
#' If so, it assigns the encounter’s own start date as `main_enc_period_start` and assigns it
#' within the same main encounter group.
#'
#' @param merged_table A data frame or tibble containing patient and encounter data.
#'   This table must include columns such as `enc_partof_ref`, `enc_type_code`,
#'   `enc_class_code`, `enc_id`, and `enc_period_start`.
#'
#' @return A data frame or tibble with an additional column `main_enc_period_start`,
#'   representing start date of the main inpatient encounter.
#'
#' @details
#' The function performs the following steps:
#' 1. Checks if `enc_partof_ref` is `NA` and if the encounter is an inpatient facility
#'    contact (`einrichtungskontakt`) of class `IMP`.
#' 2. If both conditions are met, assigns `enc_period_start` as `main_enc_period_start`.
#' 3. Otherwise, sets `main_enc_period_start` as `NA`.
#' 4. Groups the dataset by `main_enc_id` and assigns the (only) non-NA
#'    `main_enc_period_start` within the group.
#' 5. Ungroups the dataset to return the final modified table.
#'
#' @importFrom dplyr mutate if_else group_by ungroup
#' @export
addMainEncPeriodStart <- function(merged_table) {
  merged_table <- merged_table |>
    dplyr::mutate(main_enc_period_start = dplyr::if_else(is.na(enc_partof_ref) &
                                                           enc_type_code == "einrichtungskontakt" &
                                                           enc_class_code == "IMP",
                                                         enc_period_start,
                                                         NA)) |>
    dplyr::group_by(main_enc_id) |>
    dplyr::mutate(main_enc_period_start = dplyr::if_else(is.na(main_enc_period_start),
                                                         min(main_enc_period_start, na.rm = TRUE),
                                                         main_enc_period_start)) |>
    dplyr::ungroup()

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
#'   It should include columns such as `pat_birthdate` and `main_enc_period_start`.
#'
#' @return A data frame or tibble that includes the original data with an additional `age` column,
#'   representing the age of the patient at the start of the main encounter period.
#'
#' @details
#' This function calculates the age by using the `main_enc_period_start` (the start date of the main encounter)
#' and `pat_birthdate` (the patient's birthdate) columns in the merged data. The result is a new
#' column `age` that is the patient's age at the time of the encounter start date, calculated in years
#' (with precision to the nearest whole number).
#'
#' @importFrom dplyr mutate
#' @export
calculateAge <- function(merged_table) {

  merged_table_with_calc <- merged_table |>
    dplyr::mutate(age = floor(as.numeric(difftime(as.Date(main_enc_period_start), pat_birthdate)) / 365.25))

  return(merged_table_with_calc)
}

