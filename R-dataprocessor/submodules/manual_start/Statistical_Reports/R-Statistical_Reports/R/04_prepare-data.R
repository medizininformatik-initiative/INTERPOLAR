#' Prepare F1 Dataset from Full Analysis Set 1 (FAS1)
#'
#' This function filters and prepares the F1 dataset from the Full Analysis Set 1 (FAS1) cohort.
#' It identifies the first qualifying INTERPOLAR ward (as defined for the pids_per_ward table)
#' contact per main encounter during the reporting period. It includes checks for data quality, such
#' as missing start dates or duplicate entries with identical start dates.
#'
#' @param full_analysis_set_1 A data frame or tibble representing the full_analysis_set_1 dataset.
#' It must include the following columns:
#'   `enc_id`, `main_enc_id`, `main_enc_period_start`, `enc_identifier_value`, `pat_id`,
#'   `pat_identifier_value`, `record_id`, `fall_id_cis`, `enc_type_code_Kontaktebene`,
#'   `age_at_hospitalization`, `enc_period_start`, `calendar_week`, `enc_period_end`,
#'   `ward_name`, `studienphase`, `enc_status` and `processing_exclusion_reason`.
#' @param report_period_start A POSIXct date-time object representing the start of the reporting period.
#' @param report_period_end A POSIXct date-time object representing the end of the reporting period.
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
#'   \item{`main_enc_any_processing_exclusion`}{Logical flag indicating if any processing exclusion
#'                                              reason exists for the main encounter}
#'
#' @details
#' \itemize{
#'   \item Rows with missing `ward_name` are excluded, since they either are not INTERPOLAR ward
#'         contacts or are not the lowest level of encounter (e.g. Versorgungsstellenkontakt)
#'   \item Checks are performed for missing `enc_period_start` values, since the admission to the
#'         INTERPOLAR ward must be defined
#'   \item If multiple entries exist for the same `main_enc_id` and `enc_period_start`, an error is
#'         thrown, since then, the admission date to the INTERPOLAR ward is not defined.
#'   \item The `selectMin()` function is assumed to select the first entry per `main_enc_id` based
#'         on the earliest `enc_period_start`.
#'   \item The data is limited to entries where `enc_period_start` falls within the specified
#'        reporting period.
#' }
#' Note: studienphase is not included in the output, as it is not used for the F1 report.
#'
#' @importFrom dplyr filter distinct select mutate across
#' @importFrom data.table isoweek
#' @export
prepareF1data <- function(full_analysis_set_1, report_period_start, report_period_end) {
  F1_prep_raw <- full_analysis_set_1 |>
    dplyr::filter(!is.na(ward_name)) |> # only encounters with ward name (see addWardName)
    dplyr::mutate(calendar_week = data.table::isoweek(enc_period_start), .after = enc_period_start) |> # add calendar week
    dplyr::distinct(
      enc_id, main_enc_id, main_enc_period_start, enc_identifier_value, pat_id, pat_identifier_value,
      record_id, fall_id_cis, enc_type_code_Kontaktebene, age_at_hospitalization, enc_period_start,
      calendar_week, enc_period_end, ward_name,
      # studienphase,
      enc_status, processing_exclusion_reason
    )

  if (anyNA(F1_prep_raw$enc_period_start)) {
    F1_prep_raw <- F1_prep_raw |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(is.na(enc_period_start) &
        is.na(processing_exclusion_reason),
      "Missing_start_date_ward_contact",
      processing_exclusion_reason
      ))
    print(F1_prep_raw |>
      dplyr::filter(is.na(enc_period_start)), width = Inf)
    warning("Starting day undefined for a INTERPOLAR-ward contact (NA start date).
            Please check the data.")
  }

  if (checkMultipleRows(F1_prep_raw, c("main_enc_id", "enc_period_start"))) {
    F1_prep_raw <- F1_prep_raw |>
      addMultipleRowsProcessingExclusionReason(
        grouping_variables = c("main_enc_id", "enc_period_start"),
        reason = "Multiple_rows_same_start_date_ward_contact"
      )

    warning("First INTERPOLAR-ward contact undefinded for a main encounter (multiple rows with same
             start date).Please check the data.")
  } else {
    F1_prep <- F1_prep_raw |>
      selectMin(
        grouping_variables = c("main_enc_id"),
        selection_variable = enc_period_start
      ) |>
      dplyr::filter(enc_period_start >= as.POSIXct(report_period_start)) |> # only admission to INTEROPLAR ward in reporting period
      dplyr::filter(enc_period_start < as.POSIXct(report_period_end)) |>
      dplyr::group_by(main_enc_id) |>
      dplyr::mutate(main_enc_any_processing_exclusion = any(!is.na(processing_exclusion_reason))) |>
      dplyr::ungroup() |>
      dplyr::distinct(
        pat_id, main_enc_id, enc_id, record_id, fall_id_cis, calendar_week, ward_name,
        main_enc_any_processing_exclusion
      ) |>
      dplyr::mutate(dplyr::across(c(ward_name, calendar_week), as.character))

    return(F1_prep)
  }
}
#------------------------------------------------------------------------------#

#' Prepare Front-End Summary Data for Reporting Period
#'
#' Filters and reduces the complete front-end dataset to the relevant summary variables for
#' reporting within a defined period. Only entries with a `fall_aufn_dat` timestamp falling
#' within the specified `report_period_start` and `report_period_end` range are retained.
#' To show all frontend cases, this is needed (instead of using the enc_period_start),
#' because the frontend only provides the main encounter start date and cases without medication
#' analysis are not assigned to a sub-encounter.
#'
#' @param frontend_table A data frame containing merged front-end data, including medication analysis
#'   and MRP documentation information. Must include at least `pat_id`, `record_id`, `fall_id_cis`,
#'   `enc_id`, `fall_aufn_dat`,  relevant MRP fields and `processing_exclusion_reason`.
#' @param report_period_start A character string representing the start of the reporting period
#'                           (format: "YYYY-MM-DD").
#' @param report_period_end A character string representing the end of the reporting period
#'                          (format: "YYYY-MM-DD").
#'
#' @return A filtered and deduplicated data frame containing selected columns of interest
#'   for encounters with starting date (`fall_aufn_dat`) within the reporting period.
#'
#' @details
#' The resulting dataset includes distinct rows based on identifiers and key variables such as:
#' - `medikationsanalyse_complete`
#' - `mrp_dokup_hand_emp_akz`
#' - `mrp_merp`
#' - `mrpdokumentation_validierung_complete`
#' - `main_enc_any_processing_exclusion_fe` (indicating if any processing exclusion reason exists
#'                                           for the main encounter)
#'
#' Time filtering is performed with `fall_aufn_dat >= report_period_start` and `< report_period_end`.
#'
#' @importFrom dplyr distinct filter
#' @export
prepareFeSummaryData <- function(frontend_table, report_period_start, report_period_end) {
  frontend_summary_prep <- frontend_table |>
    dplyr::group_by(fall_fhir_main_enc_id) |>
    dplyr::mutate(main_enc_any_processing_exclusion_fe = any(!is.na(processing_exclusion_reason))) |>
    dplyr::ungroup() |>
    dplyr::distinct(
      pat_id, pat_cis_pid, record_id, fall_fhir_main_enc_id,
      fall_id_cis, fall_station, fall_aufn_dat, enc_id, enc_status, meda_id,
      meda_dat, enc_period_start, medikationsanalyse_complete, mrp_id,
      mrp_pigrund___21, mrp_ip_klasse_01, mrp_dokup_hand_emp_akz,
      mrp_merp, mrpdokumentation_validierung_complete, main_enc_any_processing_exclusion_fe
    ) |>
    dplyr::rename(
      Kontraindikation = mrp_pigrund___21,
      main_enc_id = fall_fhir_main_enc_id,
      ward_name = fall_station
    ) |>
    dplyr::filter(fall_aufn_dat >= as.POSIXct(report_period_start)) |> # only main-encounter start date in reporting period
    dplyr::filter(fall_aufn_dat < as.POSIXct(report_period_end))

  return(frontend_summary_prep)
}

# ----------------------------------------------------------------------------------#

#' Merge Front-End Data into F1 Dataset
#'
#' Enhances the F1 dataset by merging selected front-end documentation metrics
#' (e.g., medication analysis, MRP documentation) into each encounter based on
#' patient and encounter identifiers.
#'
#' @param F1_data A data frame containing F1 base population metrics, typically generated by
#' `prepareF1data()`.
#' @param frontend_summary_data A data frame of front-end documentation data, typically generated
#' by `prepareFeSummaryData()`.
#'
#' @return A data frame where `F1_data` is enriched with selected variables from `frontend_summary_data`,
#' joined on patient and encounter keys. If multiple rows match, the one with the earliest
#' `meda_dat` (medication analysis date) per group is selected using `selectMin()`.
#'
#' @details
#' The join is performed on the following variables:
#' \itemize{
#'   \item `pat_id`
#'   \item `main_enc_id`
#'   \item `enc_id`
#'   \item `record_id`
#'   \item `fall_id_cis`
#'   \item `ward_name`
#'   \item `main_enc_any_processing_exclusion_fe`
#' }
#'
#' The function retains only one row per group of interest using `selectMin()` based on the minimum
#' `meda_dat`.
#'
#' The merged variables include:
#' \itemize{
#'   \item `meda_id`, `meda_dat`, `medikationsanalyse_complete`
#'   \item `mrp_id`, `Kontraindikation`, `mrp_ip_klasse_01`
#'   \item `mrp_dokup_hand_emp_akz`, `mrpdokumentation_validierung_complete`
#' }
#'
#' @seealso [prepareF1data()], [prepareFeSummaryData()], [selectMin()]
#'
#' @importFrom dplyr left_join distinct
#' @export
addFeDataToF1data <- function(F1_data, frontend_summary_data) {
  F1_data_with_fe <- F1_data |>
    dplyr::left_join(
      frontend_summary_data |>
        dplyr::distinct(
          pat_id, main_enc_id, enc_id, record_id, fall_id_cis,
          ward_name, meda_id, meda_dat, medikationsanalyse_complete,
          mrp_id, Kontraindikation, mrp_ip_klasse_01,
          mrp_dokup_hand_emp_akz, mrpdokumentation_validierung_complete,
          main_enc_any_processing_exclusion_fe
        ),
      by = c(
        "pat_id", "main_enc_id", "enc_id", "record_id",
        "fall_id_cis", "ward_name"
      )
    ) |>
    selectMin(
      grouping_variables = c(
        "pat_id", "main_enc_id", "enc_id",
        "record_id", "fall_id_cis", "calendar_week",
        "ward_name"
      ),
      selection_variable = meda_dat
    )

  return(F1_data_with_fe)
}

# TODO: prepare F2 data for calculation -----------------------------------------------
prepareF2data <- function(FAS2_1, report_period_start, report_period_end) {
  F2_prep <- FAS2_1 |>
    dplyr::filter(enc_period_start >= as.POSIXct(report_period_start)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(report_period_end)) |>
    dplyr::distinct()
  return(F2_prep)
}
