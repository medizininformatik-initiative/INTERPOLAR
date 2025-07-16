#' Prepare F1 Dataset from FAS1
#'
#' This function filters and prepares the F1 dataset from the FAS1 cohort. It identifies the first
#' qualifying INTERPOLAR ward (as defined for the pids_per_ward table) contact per main encounter during the reporting period. It includes
#' checks for data quality, such as missing start dates or duplicate entries with identical start dates.
#'
#' @param FAS1 A data frame or tibble representing the FAS1 dataset. It must include the following columns:
#'   `enc_id`, `main_enc_id`, `main_enc_period_start`, `enc_identifier_value`, `pat_id`,
#'   `pat_identifier_value`, `record_id`, `fall_id_KIS`, `enc_type_code`,
#'   `age_at_hospitalization`, `enc_period_start`, `calendar_week`, `enc_period_end`,
#'   `ward_name`, `studienphase`, and `enc_status`.
#' @param REPORT_PERIOD_START A POSIXct date-time object representing the start of the reporting period.
#' @param REPORT_PERIOD_END A POSIXct date-time object representing the end of the reporting period.
#'
#' @return A filtered tibble containing the earliest INTERPOLAR ward contact per main encounter
#' during the reporting period. Includes columns:
#'   \item{`pat_id`}{Patient ID}
#'   \item{`main_enc_id`}{Main encounter ID}
#'   \item{`record_id`}{Record ID of the patient in frontend}
#'   \item{`fall_id_KIS`}{Case ID from clinical information system shown in frontend}
#'   \item{`calendar_week`}{Calendar week of admission to the first INTERPOLAR ward}
#'   \item{`ward_name`}{Name of the INTERPOLAR-ward}
#'
#' @details
#' \itemize{
#'   \item Rows with missing `ward_name` are excluded, since they either are not INTERPOLAR ward contacts or are not the lowest level of encounter (e.g. Versorgungsstellenkontakt)
#'   \item Checks are performed for missing `enc_period_start` values, since the admission to the INTERPOLAR ward must be defined
#'   \item If multiple entries exist for the same `main_enc_id` and `enc_period_start`, an error is thrown, since then, the admission date to the INTERPOLAR ward is not defined.
#'   \item The `selectMin()` function is assumed to select the first entry per `main_enc_id` based on the earliest `enc_period_start`.
#'   \item The data is limited to entries where `enc_period_start` falls within the specified reporting period.
#' }
#'
#' @importFrom dplyr filter distinct select mutate across
#' @export
prepareF1data <- function(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F1_prep_raw <- FAS1 |>
    dplyr::filter(!is.na(ward_name)) |>  # only encounters with ward name
    dplyr::distinct(enc_id, main_enc_id, main_enc_period_start, enc_identifier_value, pat_id, pat_identifier_value,
                    record_id, fall_id_KIS, enc_type_code, age_at_hospitalization, enc_period_start, calendar_week,
                    enc_period_end, ward_name, studienphase, enc_status)

  if (anyNA(F1_prep_raw$enc_period_start)) {
    stop("Starting day undefined for a INTERPOLAR-ward contact (NA start date). Please check the data.")
  }

  if (checkMultipleRows(F1_prep_raw, c("main_enc_id","enc_period_start"))) {
    stop("First INTERPOLAR-ward contact undefinded for a main encounter (multiple rows with same start date). Please check the data.")
  }

  else {
    F1_prep <- F1_prep_raw |>
      selectMin(grouping_variables = c("main_enc_id"),
                selection_variable = enc_period_start) |>
      dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
      dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
      dplyr::distinct(pat_id, main_enc_id, record_id, fall_id_KIS, calendar_week, ward_name) |>
      dplyr::mutate(dplyr::across(c(ward_name, calendar_week), as.character))

    return(F1_prep)
  }
}
#------------------------------------------------------------------------------#
# TODO: prepare F2 data for calculation ---------
prepareF2data <- function(FAS2_1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F2_prep <- FAS2_1 |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
    dplyr::distinct()
  return(F2_prep)
}
