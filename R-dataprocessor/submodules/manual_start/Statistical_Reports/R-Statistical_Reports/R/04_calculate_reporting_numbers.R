#' Calculate F1 from FAS1 Dataset
#'
#'#' This function processes encounter data to calculate the F1 metric by filtering encounters to those
#' starting in the specified reporting period and selecting the first encounter within the INTERPOLAR
#' ward (as defined for the pids_per_ward table). It groups entries by ward and calendar week and counts
#' distinct occurrences of encounters, patients, and patient records (patients_also_in_patients_fe).
#'
#' @param FAS1 A data frame or tibble representing the FAS1 dataset. It must include columns
#'   indicating the first valid interpolar ward contact per inpatient encounter, as well as
#'   a datetime column `enc_period_start`.
#' @param REPORT_PERIOD_START A character string representing the start date-time of the reporting period (in `"YYYY-MM-DD"` format or compatible POSIX format).
#' @param REPORT_PERIOD_END A character string representing the end date-time of the reporting period (exclusive).
#'
#' @return A dataframe summarizing the first encounter within each ward for the specified calendar week
#' and ward, containing columns for `ward_name`, `calendar_week`, distinct counts of encounters, patients,
#' and `patients_also_in_patients_fe` (patient records).
#' If issues are detected (e.g., undefined start dates or multiple first contacts), a error is issued
#' and the preprocessed data is returned for inspection.
#'
#' @importFrom dplyr filter distinct group_by tally select mutate across summarise bind_rows n_distinct
#' @export
#' @seealso `checkMultipleRows` for handling potential issues with encounter data rows.
#'
calculateF1 <- function(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F1_prep <- FAS1 |>
    dplyr::filter(!is.na(ward_name)) |>  # only encounters with ward name
    dplyr::distinct(enc_id, main_enc_id, main_enc_period_start, enc_identifier_value, pat_id, pat_identifier_value,
                    record_id, fall_id_KIS, enc_type_code, age_at_hospitalization, enc_period_start, calendar_week,
                    enc_period_end, ward_name, studienphase, enc_status)

  if (anyNA(F1_prep$enc_period_start)) {
    stop("Starting day undefined for a INTERPOLAR-ward contact (NA start date). Please check the data.")
  }

  if (checkMultipleRows(F1_prep, c("main_enc_id","enc_period_start"))) {
    stop("First INTERPOLAR-ward contact undefinded for a main encounter (multiple rows with same start date). Please check the data.")
    }

  else {
    F1_prep_red <- F1_prep |>
      selectMin(grouping_variables = c("main_enc_id"),
                selection_variable = enc_period_start) |>
      dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
      dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
      dplyr::distinct(pat_id, main_enc_id, record_id, fall_id_KIS, calendar_week, ward_name) |>
      dplyr::mutate(dplyr::across(c(ward_name, calendar_week), as.character))

    F1_grouped_counts <- F1_prep_red |>
      dplyr::group_by(ward_name, calendar_week) |>
      dplyr::summarise(
        F1_encounters = dplyr::n_distinct(main_enc_id),
        F1_encounters_also_in_fe = dplyr::n_distinct(fall_id_KIS),
        F1_patients = dplyr::n_distinct(pat_id),
        F1_patients_also_in_fe = dplyr::n_distinct(record_id),
        .groups = 'drop'
      )

    F1_total_counts <- F1_prep_red |>
      dplyr::summarise(
        ward_name = "all wards",
        calendar_week = "all weeks",
        F1_encounters = dplyr::n_distinct(main_enc_id),
        F1_encounters_also_in_fe = dplyr::n_distinct(fall_id_KIS),
        F1_patients = dplyr::n_distinct(pat_id),
        F1_patients_also_in_fe = dplyr::n_distinct(record_id)
    )

    F1 <- dplyr::bind_rows(F1_grouped_counts, F1_total_counts)

    return(F1)
    }
}

#------------------------------------------------------------------------------#
#TODO: needs updates and advancements! -------
#' Calculate F2 from FAS2.1 Dataset
#'
#' This function filters the FAS2.1 dataset to calculate the F2.  It includes only those ward contacts
#' that meet the FAS2.1 criteria and have a start date within the specified reporting period.
#'
#' @param FAS2_1 A data frame or tibble containing the FAS2.1 dataset. It must include
#'   an enc_period_start column of type POSIXct.
#' @param REPORT_PERIOD_START A character string or POSIXct object indicating the start of the reporting period. It must be convertible to POSIXct.
#' @param REPORT_PERIOD_END A character string or POSIXct object indicating the end of the reporting period. It must be convertible to POSIXct.
#'
#' @return A filtered data frame or tibble containing only those encounters where:
#' \itemize{
#'   \item enc_period_start falls within the defined reporting period
#'         (REPORT_PERIOD_START <= enc_period_start < REPORT_PERIOD_END).
#' }
#'
#' @details
#' The function extracts encounters from the FAS2.1 dataset that start during the specified reporting period.
#' After filtering, the function removes duplicate rows,
#' returning a clean dataset of distinct encounters within the period.
#'
#' @importFrom dplyr filter distinct
calculateF2 <- function(FAS2_1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F2 <- FAS2_1 |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
    dplyr::distinct()
  return(F2)
}
