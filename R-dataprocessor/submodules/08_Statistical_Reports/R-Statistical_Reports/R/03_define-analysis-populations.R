#' Define FAS1 Dataset from Complete Table
#'
#' This function defines the FAS1 dataset by filtering and processing a complete table of merged
#' patient and encounter data. It focuses on encounters of type `"versorgungsstellenkontakt"`
#' (ward-level contact) that are part of an inpatient hospital stay and meet specific inclusion criteria.
#'
#' @param complete_table A data frame or tibble containing the full patient-encounter dataset,
#'   including merged ward information. Required columns include `enc_id`, `main_enc_id`,
#'   `enc_type_code`, `enc_class_code`, `enc_period_start`, `enc_period_end`,
#'   `main_enc_period_start`, `age_at_hospitalization`, `ward_name`, `input_datetime_enc`, and `pat_id`.
#'
#' @return A data frame or tibble with an added logical column `FAS1`, where `TRUE` indicates
#'   that the row represents the first valid interpolar ward contact for a patient within an
#'   inpatient encounter. The result includes all relevant records, even those not selected for FAS1,
#'   with `FAS1 = FALSE`.
#'
#' @details
#' The function constructs the FAS1 dataset by:
#' \itemize{
#'   \item Filtering to encounters of type `"einrichtungskontakt"` with class `"IMP"` to identify inpatient encounters.
#'   \item Retaining only `"versorgungsstellenkontakt"` rows linked to those inpatient encounters.
#'   \item Filtering to adult patients (age ≥ 18).
#'   \item Selecting only those rows that include a non-missing `ward_name` (i.e., mapped to an interpolar ward).
#'   \item Within each inpatient encounter (`main_enc_id`) and patient (`pat_id`), identifying the first ward contact
#'         by ordering on `main_enc_period_start`, `enc_period_start`, `enc_period_end`, and `input_datetime_enc`.
#'   \item Marking only that first ward contact as `FAS1 = TRUE`, while all others are set to `FALSE`.
#'   \item Checking for duplicates: If multiple rows exist per `enc_id` or `main_enc_id` in the final dataset
#'         marked as `FAS1 = TRUE`, a warning is issued.
#' }
#'
#' @importFrom dplyr filter pull left_join distinct arrange group_by ungroup slice_min mutate if_else add_count
#' @export

# TODO: implement KW week stratification ----------
# TODO: select 1st INTERPOLAR station (correct addWardName) ---------

defineFAS1 <- function(complete_table) {

  inpatient_encounters <- complete_table |>
    dplyr::filter(enc_type_code == "einrichtungskontakt" & enc_class_code == "IMP") |>
    dplyr::pull(enc_id)

  FAS1_included_encounters <- complete_table |>
    dplyr::filter(main_enc_id %in% inpatient_encounters) |> # only IMP patients
    dplyr::filter(age_at_hospitalization >= 18) |> # only adults
    dplyr::filter(enc_type_code == "versorgungsstellenkontakt") # use only ward contacts

  added_FAS1 <- FAS1_included_encounters |>
    dplyr::left_join(FAS1_included_encounters |>
                       dplyr::filter(!is.na(ward_name)) |> # only interpolar wards
                       dplyr::arrange(main_enc_period_start, enc_period_start, enc_period_end, input_datetime_enc) |>
                       dplyr::group_by(main_enc_id, pat_id) |>
                       dplyr::slice_min(enc_period_start) |> # only first INTERPOLAR contact ward
                       dplyr::ungroup() |>
                       dplyr::mutate(FAS1 = TRUE) |>
                       dplyr::select(enc_id,main_enc_id,pat_id,FAS1) |>
                       dplyr::distinct(),
                     by = c("enc_id","main_enc_id","pat_id")
                       ) |>
    dplyr::mutate(FAS1 = dplyr::if_else(is.na(FAS1), FALSE, FAS1)) |>
    dplyr::relocate(FAS1, .after = enc_status)

  # Check if there are multiple rows for the same Versorgungsstellenkontakt in the F1 dataset
  if (checkMultipleRows(added_FAS1 |>
                        dplyr::filter(FAS1 == TRUE), c("enc_id"))) {
    warning("There are multiple rows for the same Versorgungsstellenkontakt. Please check the data.")
  }

  # Check if there are multiple rows for the same Einrichtungskontakt in the F1 dataset
  if (checkMultipleRows(added_FAS1 |>
                        dplyr::filter(FAS1 == TRUE), c("main_enc_id"))) {
    warning("There are multiple rows for the same Einrichtungskontakt. Please check the data.")

    added_FAS1 |>
      dplyr::filter(FAS1 == TRUE) |>
      dplyr::group_by(main_enc_id) |>
      dplyr::add_count() |>
      dplyr::filter(n > 1) |>
      print(width = Inf)
  }

  return(added_FAS1)
}

# TODO: implement rules for combining short absences (!is.na(ward_name) = no INTERPOLAR ward?) -------
# TODO: include all patients with documented medication analysis? -------------
# TODO: handle NA end-dates properly -------------

defineFAS2.1 <- function(FAS1) {
  FAS2.1 <- FAS1 |>
    dplyr::filter(as.numeric(enc_period_end - enc_period_start) >= 7) |>
    dplyr::distinct() |>
    dplyr::arrange(enc_patient_ref, enc_id, enc_period_start, enc_period_end, input_datetime_encounter)

  return(FAS2.1)
}
