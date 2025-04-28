#' Define FAS1 Dataset from Complete Table
#'
#' This function filters and processes patient and encounter data to define the
#' FAS1 dataset, which includes encounters of type "versorgungsstellenkontakt" (ward contact).
#' It ensures that only relevant encounters are included, based on criteria such as the patient
#' being at least 18 years old, the presence of the ward in the `pids_per_ward` name, and the encounter_id being part
#' of an inpatient encounter. The dataset is then arranged and returned.
#'
#' @param complete_table A data frame or tibble containing the complete patient and encounter data, as well as ward name from pids_per_ward.
#'   This table must include columns such as `enc_type_code`, `enc_class_code`, `enc_id`, `enc_period_start`,
#'   `enc_period_end`, `ward_name`, and `age`.
#' @param REPORT_PERIOD_START A character string specifying the start date of the report period.
#' @param REPORT_PERIOD_END A character string specifying the end date of the report period.
#'
#' @return A data frame or tibble representing the FAS1 dataset. It contains filtered encounters of type
#'   "versorgungsstellenkontakt" (ward contact), with patients aged 18 or older, that are associated with an inpatient ward.
#'   The dataset is distinct and sorted by encounter reference, encounter ID, and encounter period start and end dates.
#'
#' @details
#' The function performs the following steps to define the FAS1 dataset:
#' 1. It selects encounters of type "versorgungsstellenkontakt" (ward contact).
#' 2. It ensures the encounters are part of inpatient encounters ("Einrichtungscontakt") by checking if `enc_partof_ref` matches any inpatient
#'    encounter ID.
#' 3. It only includes encounters where a valid `ward_name` exists (encounter is present in pids_per_ward).
#' 4. It filters out encounters where the patient is younger than 18 years.
#' 5. It ensures that the encounter's start date is within the provided report period (`REPORT_PERIOD_START` and `REPORT_PERIOD_END`).
#' 6. It filters encounters where the difference between the encounter start date and the report period end date is at least 7 days.
#' 7. It ensures that the `enc_id` is unique by filtering for distinct encounters.
#' 8. The function sorts the resulting dataset by encounter reference, encounter ID, and encounter period start and end dates.
#'
#' The function checks for the presence of multiple rows for the same encounter ID in the resulting dataset. If duplicates
#' are found, the function returns a warning.
#'
#' @importFrom dplyr filter distinct arrange pull
#' @export
#'

# TODO: implement KW week stratification ----------

defineFAS1 <- function(complete_table, REPORT_PERIOD_START, REPORT_PERIOD_END) {

  inpatient_encounters <- complete_table |>
    dplyr::filter(enc_type_code == "einrichtungskontakt" & enc_class_code == "IMP") |>
    dplyr::pull(enc_id)

  FAS1 <- complete_table |>
     dplyr::filter(enc_type_code == "versorgungsstellenkontakt") |>
    dplyr::filter(main_enc_id %in% inpatient_encounters) |>
    dplyr::filter(!is.na(ward_name)) |>
    dplyr::filter(age >= 18) |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |>
    # not needed anymore
    # dplyr::filter(as.numeric(as.POSIXct(REPORT_PERIOD_END) - enc_period_start) >= 7) |>
    dplyr::distinct() |>
    dplyr::arrange(enc_patient_ref, enc_id, enc_period_start, enc_period_end, input_datetime_encounter)

  # Check if there are multiple rows for the same Versorgungsstellenkontakt in the FAS1 dataset
  if (checkMultipleRows(FAS1, c("enc_id"))) {
    warning("There are multiple rows for the same Versorgungsstellenkontakt. Please check the data.")
  }

  # Check if there are multiple rows for the same Einrichtungskontakt in the FAS1 dataset
  if (checkMultipleRows(FAS1, c("enc_partof_ref"))) {
    warning("There are multiple rows for the same Einrichtungskontakt. Please check the data.")
  }

  return(FAS1)
}
