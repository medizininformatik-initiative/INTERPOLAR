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
#'   `record_id`, `fall_id_cis`, `enc_type_code_Kontaktebene`,
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
#' @importFrom dplyr filter distinct select mutate across if_else
#' @importFrom data.table isoweek
#' @export
prepareF1data <- function(full_analysis_set_1, report_period_start, report_period_end) {
  F1_prep_raw <- full_analysis_set_1 |>
    dplyr::filter(!is.na(ward_name)) |> # only encounters with ward name (see addWardName)
    addCalendarWeek(reference_date_col = enc_period_start) |>
    dplyr::distinct(
      enc_id, main_enc_id, main_enc_period_start, enc_identifier_value, pat_id,
      record_id, fall_id_cis, enc_type_code_Kontaktebene, age_at_hospitalization, enc_period_start,
      calendar_week, enc_period_end, ward_name,
      # studienphase,
      enc_status, processing_exclusion_reason
    )

  if (anyNA(F1_prep_raw$enc_period_start)) {
    F1_prep_raw <- F1_prep_raw |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(enc_period_start),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "Missing_start_date_ward_contact",
          level = "main_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(F1_prep_raw |>
      dplyr::filter(is.na(enc_period_start)), width = 1000)
    warning("Starting day undefined for a INTERPOLAR-ward contact (NA start date).
            Please check the data.")
  }

  if (checkMultipleRows(F1_prep_raw, c("main_enc_id", "enc_period_start"))) {
    F1_prep_raw <- F1_prep_raw |>
      addMultipleRowsProcessingExclusionReason(
        c("main_enc_id", "enc_period_start"),
        "Multiple_rows_same_start_date_ward_contact"
      )
    warning("First INTERPOLAR-ward contact undefinded for a main encounter (multiple rows with same
             start date).Please check the data.")
  }
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
#------------------------------------------------------------------------------#
#' Combine Wards for Analysis
#'
#' Standardizes ward names in the front-end dataset by replacing specified
#' groups of wards with a common reference ward for analysis purposes.
#'
#' @param frontend_table A data frame containing front-end data with a
#'   `fall_station` column representing ward names.
#'
#' @return A data frame in which specified ward names have been replaced by
#'   their corresponding reference ward names.
#'
#' @details
#' The function dynamically identifies ward combination definitions from the
#' global environment by searching for objects matching the pattern
#' `"^COMBINE_WARDS_FOR_ANALYSIS_"`.
#'
#' Each definition is expected to contain:
#' \itemize{
#'   \item A reference ward (first element)
#'   \item A set of ward names to be replaced (second element)
#' }
#'
#' The reference ward is extracted and cleaned using
#' `stringr::str_split_i()`. The additional wards are parsed by splitting
#' and cleaning the definition string using `stringr` functions.
#'
#' For each definition, the function updates the `fall_station` column by
#' replacing any occurrence of the specified wards with the corresponding
#' reference ward.
#'
#' @importFrom dplyr mutate case_when
#' @importFrom etlutils isDefinedAndNotEmpty
#' @importFrom stringr str_split_i str_remove_all str_split
#'
#' @export
CombineWardsForAnalysis <- function(frontend_table) {
  combined_wards_definition <- ls(pattern = "^COMBINE_WARDS_FOR_ANALYSIS_", envir = .GlobalEnv)
  frontend_table_combined_wards <- frontend_table
  for (i in seq_along(combined_wards_definition)) {
    ward_definition_information <- combined_wards_definition[i]
    if (etlutils::isDefinedAndNotEmpty(ward_definition_information)) {
      regular_ward <- get(ward_definition_information, envir = .GlobalEnv)[1] |>
        stringr::str_split_i("'", 2)
      additional_wards <- get(ward_definition_information, envir = .GlobalEnv)[2] |>
        stringr::str_split_i("=", 2) |>
        stringr::str_remove_all(" '") |>
        stringr::str_remove_all("' ") |>
        stringr::str_remove_all("'") |>
        stringr::str_split(",") |>
        unlist()

      frontend_table_combined_wards <- frontend_table_combined_wards |>
        dplyr::mutate(fall_station = dplyr::case_when(
          fall_station %in% additional_wards ~ regular_ward,
          TRUE ~ fall_station
        ))
    }
  }
  return(frontend_table_combined_wards)
}

#------------------------------------------------------------------------------#
#' Prepare Front-End Summary Data for a Reporting Period
#'
#' Enriches front-end data with summary variables and restricts the
#' resulting data to a specified reporting period and boundary.
#'
#' The function combines ward information, determines the first encounter
#' period start per main encounter, adds a calendar week, and derives flags
#' for verification status, processing exclusions, medication analyses, MRP
#' documentation, algorithmic MRP eligibility, and reporting thresholds.
#' Depending on `report_period_boundary`, encounters are filtered according
#' to either their hospital stay or their ward stay.
#'
#' @param frontend_table A data frame containing merged front-end data,
#'   including patient, encounter, ward, medication analysis, MRP
#'   documentation, and processing exclusion information.
#' @param report_period_start A character string specifying the start of the
#'   reporting period in `"YYYY-MM-DD"` format.
#' @param report_period_end A character string specifying the end of the
#'   reporting period in `"YYYY-MM-DD"` format.
#' @param report_period_boundary A character string specifying the temporal
#'   boundary used for filtering. Must be either `"hospital_stay"` or
#'   `"ward_stay"`.
#' @param calendar_week_reference_date_col A date or date-time column used
#'   as the reference for calculating the calendar week. The column should
#'   be supplied unquoted.
#'
#' @return A data frame containing enriched front-end summary data restricted
#'   to the specified reporting period. The result includes derived variables
#'   for calendar week, encounter verification, processing exclusions,
#'   medication analyses, MRP documentation, algorithmic MRP eligibility,
#'   patient-count thresholds, and renamed encounter and ward identifiers.
#'
#' @details
#' The resulting data includes the following derived variables:
#' \itemize{
#'   \item `calendar_week`: ISO calendar week derived from the specified
#'     reference date.
#'   \item `Kontraindikation`: Renamed from `mrp_pigrund___21`.
#'   \item `main_enc_id`: Renamed from `fall_fhir_main_enc_id`.
#'   \item `ward_name`: Renamed from `fall_station`.
#'   \item `unverified_pat_or_sub_enc`: Indicates whether the patient or
#'     encounter is unverified.
#'   \item `main_enc_any_processing_exclusion_fe`: Indicates whether any
#'     main-encounter processing exclusion exists, excluding
#'     `not_in_inclusion_criteria`.
#'   \item `main_enc_not_in_inclusion_criteria`: Indicates whether the main
#'     encounter has a `not_in_inclusion_criteria` exclusion.
#'   \item `sub_enc_any_processing_exclusion_fe`: Indicates whether any
#'     sub-encounter processing exclusion exists, excluding
#'     `not_in_inclusion_criteria`.
#'   \item `sub_enc_all_processing_exclusion_fe`: Indicates whether all
#'     observations in a sub-encounter have a processing exclusion, excluding
#'     `not_in_inclusion_criteria`.
#'   \item `sub_enc_any_completed_medication_analysis`: Indicates whether a
#'     completed medication analysis exists for the sub-encounter.
#'   \item `sub_enc_any_MRP`: Indicates whether completed MRP documentation
#'     exists for the sub-encounter.
#'   \item `sub_enc_any_algorithmic_MRP`: Indicates whether algorithmic MRP
#'     documentation exists for the sub-encounter.
#'   \item `eligible_for_algorithmic_MRP_calculation`: Indicates whether the
#'     encounter meets the implemented criteria for algorithmic MRP
#'     calculation, including more than 14 days since discharge, a completed
#'     medication analysis, and study Phase B.
#'   \item `overall_count_less_than_5`: Indicates whether fewer than five
#'     distinct patients are present in the complete result.
#'   \item `ward_count_less_than_5`: Indicates whether fewer than five
#'     distinct patients are present within the ward.
#'   \item `ward_week_count_less_than_5`: Indicates whether fewer than five
#'     distinct patients are present within the ward and calendar week.
#' }
#'
#' For `report_period_boundary = "hospital_stay"`, observations are retained
#' when `fall_ent_dat` is missing or is greater than or equal to the later of
#' `ward_start` and `report_period_start`, and `fall_aufn_dat` is earlier than
#' the earlier of `ward_end` and `report_period_end`.
#'
#' For `report_period_boundary = "ward_stay"`, observations are retained
#' when `curated_enc_period_end` is missing or is greater than or equal to
#' the later of `ward_start` and `report_period_start`, and `enc_period_start`
#' is earlier than the earlier of `ward_end` and `report_period_end`.
#'
#' @importFrom dplyr distinct
#' @importFrom dplyr filter
#' @importFrom dplyr group_by
#' @importFrom dplyr if_else
#' @importFrom dplyr mutate
#' @importFrom dplyr n_distinct
#' @importFrom dplyr rename
#' @importFrom dplyr ungroup
#' @importFrom stringr str_detect
#'
#' @export
prepareFeSummaryData <- function(frontend_table, report_period_start, report_period_end,
                                 report_period_boundary = c("hospital_stay", "ward_stay"),
                                 calendar_week_reference_date_col) {
  frontend_summary_prep <- frontend_table |>
    CombineWardsForAnalysis() |>
    addFirstEncPeriodStartPerMainEnc(
      grouping_vars = c("pat_id", "fall_fhir_main_enc_id"),
      time_var = enc_period_start
    ) |>
    addCalendarWeek(reference_date_col = {{ calendar_week_reference_date_col }}) |>
    dplyr::mutate(unverified_pat_or_sub_enc = dplyr::if_else(
      patient_complete == "Unverified" | fall_complete == "Unverified",
      TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::group_by(fall_fhir_main_enc_id) |>
    dplyr::mutate(main_enc_any_processing_exclusion_fe = dplyr::if_else(any(
      !is.na(processing_exclusion_reason) &
        stringr::str_detect(
          processing_exclusion_reason,
          pattern = "main_encounter"
        ) &
        stringr::str_detect(
          processing_exclusion_reason,
          pattern = "not_in_inclusion_criteria",
          negate = TRUE
        )
    ), TRUE, FALSE, missing = FALSE)) |>
    dplyr::mutate(main_enc_not_in_inclusion_criteria = dplyr::if_else(
      any(stringr::str_detect(
        processing_exclusion_reason,
        pattern = "not_in_inclusion_criteria"
      )), TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::mutate(sub_enc_all_processing_exclusion_fe = dplyr::if_else(
      all(
        !is.na(processing_exclusion_reason) &
          stringr::str_detect(
            processing_exclusion_reason,
            pattern = "sub_encounter"
          ) &
          stringr::str_detect(
            processing_exclusion_reason,
            pattern = "not_in_inclusion_criteria",
            negate = TRUE
          )
      ), TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::ungroup() |>
    dplyr::group_by(fall_fhir_main_enc_id, fall_station) |>
    dplyr::mutate(sub_enc_any_completed_medication_analysis = dplyr::if_else(
      any(!is.na(meda_id) &
        medikationsanalyse_complete == "Complete"), TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::mutate(sub_enc_any_MRP = dplyr::if_else(
      any(!is.na(mrp_id) &
        mrpdokumentation_validierung_complete == "Complete"), TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::mutate(sub_enc_any_algorithmic_MRP = dplyr::if_else(
      any(!is.na(ret_id) &
        retrolektive_mrpbewertung_complete != "Unverified"), TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::mutate(sub_enc_any_processing_exclusion_fe = dplyr::if_else(
      any(
        !is.na(processing_exclusion_reason) &
          stringr::str_detect(
            processing_exclusion_reason,
            pattern = "sub_encounter"
          ) &
          stringr::str_detect(
            processing_exclusion_reason,
            pattern = "not_in_inclusion_criteria",
            negate = TRUE
          )
      ), TRUE, FALSE, missing = FALSE
    )) |>
    dplyr::ungroup() |>
    dplyr::mutate(overall_count_less_than_5 = dplyr::n_distinct(pat_id) < 5) |>
    dplyr::group_by(fall_station) |>
    dplyr::mutate(ward_count_less_than_5 = dplyr::n_distinct(pat_id) < 5) |>
    dplyr::ungroup() |>
    dplyr::group_by(fall_station, calendar_week) |>
    dplyr::mutate(ward_week_count_less_than_5 = dplyr::n_distinct(pat_id) < 5) |>
    dplyr::ungroup() |>
    dplyr::mutate(eligible_for_algorithmic_MRP_calculation = dplyr::if_else(
      ((as.POSIXct(report_period_end) - fall_ent_dat) > 14) &
        sub_enc_any_completed_medication_analysis &
        actual_fall_studienphase == "PhaseB",
      TRUE, FALSE, missing = FALSE
    ), .after = sub_enc_any_MRP) |>
    dplyr::rename(
      Kontraindikation = mrp_pigrund___21,
      main_enc_id = fall_fhir_main_enc_id,
      ward_name = fall_station
    ) |>
    mergeWardStartsAndEnds()

  if (report_period_boundary == "hospital_stay") {
    # Filter for encounters that fall within the reporting period based on fall_ent_dat and fall_aufn_dat
    frontend_summary_prep <- frontend_summary_prep |>
      dplyr::filter(is.na(fall_ent_dat) | fall_ent_dat >= max(as.POSIXct(ward_start), as.POSIXct(report_period_start))) |>
      dplyr::filter(fall_aufn_dat < min(as.POSIXct(ward_end), as.POSIXct(report_period_end))) |>
      dplyr::distinct()
  } else if (report_period_boundary == "ward_stay") {
    # Filter for encounters that fall within the reporting period based on enc_period_start and curated_enc_period_end
    frontend_summary_prep <- frontend_summary_prep |>
      dplyr::filter(is.na(curated_enc_period_end) | curated_enc_period_end >= max(as.POSIXct(ward_start), as.POSIXct(report_period_start))) |>
      dplyr::filter(enc_period_start < min(as.POSIXct(ward_end), as.POSIXct(report_period_end))) |>
      dplyr::distinct()
  }

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
        dplyr::distinct(main_enc_id, main_enc_any_processing_exclusion_fe),
      by = c("main_enc_id")
    ) |>
    dplyr::left_join(
      frontend_summary_data |>
        dplyr::distinct(
          pat_id, main_enc_id, enc_id, record_id, fall_id_cis,
          ward_name, meda_id, meda_dat, medikationsanalyse_complete,
          mrp_id, Kontraindikation, mrp_ip_klasse_01,
          mrp_dokup_hand_emp_akz, mrpdokumentation_validierung_complete
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
