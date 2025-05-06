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
# TODO: check each FHIR item for the possible values and include this into filetring e.g. "Begleitperson" --------

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
  }

  return(added_FAS1)
}

#------------------------------------------------------------------------------#

#' Define FAS2.1 Dataset from FAS1
#'
#' This function derives the FAS2.1 dataset from the FAS1 cohort by identifying ward contacts
#' that meet the FAS2.1 criteria—specifically, a stay of at least 7 days on a ward (versorgungsstellenkontakt).
#' It handles ongoing encounters (i.e., `enc_status == "in-progress"`) by computing their duration up to
#' the specified reporting period end. The result is a logical column `FAS2_1` added to the original data,
#' indicating whether each row qualifies under the FAS2.1 condition.
#'
#' @param FAS1 A data frame or tibble representing the FAS1 dataset. Must contain the columns:
#'   `FAS1` (logical), `enc_period_start`, `enc_period_end`, `enc_status`, `enc_id`, `main_enc_id`, and `pat_id`.
#' @param REPORT_PERIOD_START A POSIXct object or string convertible to POSIXct, representing the start of the reporting period.
#' @param REPORT_PERIOD_END A POSIXct object or string convertible to POSIXct, representing the end of the reporting period.
#'
#' @return A data frame or tibble identical to `FAS1`, with an added column:
#'   \item{`FAS2_1`}{Logical indicator for whether the ward stay lasted at least 7 days, including in-progress encounters evaluated against the report period end.}
#'
#' @details
#' The function:
#' \enumerate{
#'   \item Filters for FAS1-included rows (`FAS1 == TRUE`).
#'   \item Flags rows as `FAS2_1 = TRUE` if:
#'     \itemize{
#'       \item the difference between `enc_period_end` and `enc_period_start` is ≥ 7 days, or
#'       \item the encounter is `in-progress` and the duration from `enc_period_start` to `REPORT_PERIOD_END` is ≥ 7 days.
#'     }
#'   \item Left-joins the flags back to the full dataset.
#'   \item Sets unflagged rows to `FAS2_1 = FALSE`.
#'   \item Relocates the `FAS2_1` column immediately after `FAS1`.
#' }
#'
#' @importFrom dplyr filter mutate left_join distinct select if_else relocate case_when
#' @export

# TODO: fix many-to-many relationship -----------
# TODO: implement rules for combining short absences (!is.na(ward_name) = no INTERPOLAR ward?) -------
# TODO: include all patients with documented medication analysis within the first 7 days -------------
# TODO: handle NA end-dates properly (e.g. deceased) -------------

defineFAS2_1 <- function(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  FAS2_1 <- FAS1 |>
    dplyr::left_join(FAS1 |>
                       dplyr::filter(FAS1 == TRUE) |>
                       dplyr::filter(dplyr::case_when(
                         !is.na(enc_period_end) ~
                           as.numeric(enc_period_end - enc_period_start) >= 7,
                         is.na(enc_period_end) & enc_status == "in-progress" ~
                           as.numeric(as.POSIXct(REPORT_PERIOD_END) - enc_period_start) >= 7)) |>
                       dplyr::mutate(FAS2_1 = TRUE) |>
                       dplyr::distinct() |>
                       dplyr::select(enc_id,main_enc_id,pat_id,FAS2_1),
                     by = c("enc_id","main_enc_id","pat_id")) |>
    dplyr::mutate(FAS2_1 = dplyr::if_else(is.na(FAS2_1), FALSE, FAS2_1)) |>
    dplyr::relocate(FAS2_1, .after = FAS1)
  return(FAS2_1)
}


