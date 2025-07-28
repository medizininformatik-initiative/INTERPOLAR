#' Prepare F1 Dataset from FAS1
#'
#' This function filters and prepares the F1 dataset from the FAS1 cohort. It identifies the first
#' qualifying INTERPOLAR ward (as defined for the pids_per_ward table) contact per main encounter during the reporting period. It includes
#' checks for data quality, such as missing start dates or duplicate entries with identical start dates.
#'
#' @param FAS1 A data frame or tibble representing the FAS1 dataset. It must include the following columns:
#'   `enc_id`, `main_enc_id`, `main_enc_period_start`, `enc_identifier_value`, `pat_id`,
#'   `pat_identifier_value`, `record_id`, `fall_id_cis`, `enc_type_code`,
#'   `age_at_hospitalization`, `enc_period_start`, `calendar_week`, `enc_period_end`,
#'   `ward_name`, `studienphase`, and `enc_status`.
#' @param REPORT_PERIOD_START A POSIXct date-time object representing the start of the reporting period.
#' @param REPORT_PERIOD_END A POSIXct date-time object representing the end of the reporting period.
#'
#' @return A filtered tibble containing the earliest INTERPOLAR ward contact per main encounter
#' during the reporting period. Includes columns:
#'   \item{`pat_id`}{Patient ID}
#'   \item{`main_enc_id`}{Main encounter ID}
#'   \item{`enc_id`}{Sub-Encounter ID}
#'   \item{`record_id`}{Record ID of the patient in frontend}
#'   \item{`fall_id_cis`}{Case ID from clinical information system shown in frontend}
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
    dplyr::mutate(calendar_week = data.table::isoweek(enc_period_start), .after = enc_period_start) |> # add calendar week
    dplyr::distinct(enc_id, main_enc_id, main_enc_period_start, enc_identifier_value, pat_id, pat_identifier_value,
                    record_id, fall_id_cis, enc_type_code, age_at_hospitalization, enc_period_start, calendar_week,
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
      dplyr::distinct(pat_id, main_enc_id, enc_id, record_id, fall_id_cis, calendar_week, ward_name) |>
      dplyr::mutate(dplyr::across(c(ward_name, calendar_week), as.character))

    return(F1_prep)
  }
}
#------------------------------------------------------------------------------#

#' Prepare Front-End Summary Data for Reporting Period
#'
#' Filters and reduces the complete front-end dataset to the relevant summary variables for
#' reporting within a defined period. Only entries with a `enc_period_start` timestamp falling
#' within the specified `REPORT_PERIOD_START` and `REPORT_PERIOD_END` range are retained.
#'
#' @param complete_fe_table A data frame containing merged front-end data, including medication analysis
#'   and MRP documentation information. Must include at least `pat_id`, `record_id`, `fall_id_cis`,
#'   `enc_id`, `enc_period_start`, and relevant MRP fields.
#' @param REPORT_PERIOD_START A character string representing the start of the reporting period (format: "YYYY-MM-DD").
#' @param REPORT_PERIOD_END A character string representing the end of the reporting period (format: "YYYY-MM-DD").
#'
#' @return A filtered and deduplicated data frame containing selected columns of interest
#'   for encounters with starting date (`enc_period_start`) within the reporting period.
#'
#' @details
#' The resulting dataset includes distinct rows based on identifiers and key variables such as:
#' - `medikationsanalyse_complete`
#' - `mrp_dokup_hand_emp_akz`
#' - `mrp_merp`
#' - `mrpdokumentation_validierung_complete`
#'
#' Time filtering is performed with `enc_period_start >= REPORT_PERIOD_START` and `< REPORT_PERIOD_END`.
#'
#' @importFrom dplyr distinct filter
#' @export
prepareFeSummaryData <- function(complete_fe_table,REPORT_PERIOD_START,REPORT_PERIOD_END) {

  fe_summary_prep <- complete_fe_table |>
    dplyr::distinct(pat_id, pat_cis_pid, record_id, fall_fhir_main_enc_id,
                    fall_id_cis, fall_station, enc_id, enc_status, meda_id,
                    enc_period_start, medikationsanalyse_complete, mrp_id,
                    mrp_pigrund___21, mrp_ip_klasse_01, mrp_dokup_hand_emp_akz,
                    mrp_merp, mrpdokumentation_validierung_complete) |>
    dplyr::rename(Kontraindikation = mrp_pigrund___21) |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only sub-encounter start date in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END))

  return(fe_summary_prep)
}


# TODO: prepare F2 data for calculation ---------
prepareF2data <- function(FAS2_1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F2_prep <- FAS2_1 |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
    dplyr::distinct()
  return(F2_prep)
}
