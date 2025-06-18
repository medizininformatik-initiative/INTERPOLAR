#TODO: needs updates and advancements! -------

#' Calculate F1from FAS1 Dataset
#'
#' This function calucaltes the F1 from the previously defined FAS1 dataset. It includes only
#' those encounters where the admission to the INTERPOLAR ward (`versorgungsstellenkontakt`) occurred
#' within a specified reporting period. The output provides a tally of distinct encounters by ward.
#'
#' @param FAS1 A data frame or tibble representing the FAS1 dataset. It must include columns
#'   indicating the first valid interpolar ward contact per inpatient encounter, as well as
#'   a datetime column `enc_period_start`.
#' @param REPORT_PERIOD_START A character string representing the start date-time of the reporting period (in `"YYYY-MM-DD"` format or compatible POSIX format).
#' @param REPORT_PERIOD_END A character string representing the end date-time of the reporting period (exclusive).
#'
#' @return A data frame or tibble that:
#' \itemize{
#'   \item Contains distinct rows based on `main_enc_id` and `ward_name`.
#'   \item Groups the data by `ward_name` and provides a count of encounters per ward.
#' }
#'
#' @details
#' The function filters encounters admitted to INTERPOLAR wards during the report period, ensuring temporal relevance of ward admissions. It further groups by `ward_name` and counts the distinct admissions, reflecting the activity per ward.
#'
#' @importFrom dplyr filter distinct group_by tally
#' @export
calculateF1 <- function(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F1 <- FAS1 |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
    dplyr::filter(!is.na(ward_name)) |> # only encounters with ward name
    dplyr::distinct(main_enc_id,ward_name) |>
    dplyr::group_by(ward_name) |>
    dplyr::tally()

  return(F1)
}

#------------------------------------------------------------------------------#

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
