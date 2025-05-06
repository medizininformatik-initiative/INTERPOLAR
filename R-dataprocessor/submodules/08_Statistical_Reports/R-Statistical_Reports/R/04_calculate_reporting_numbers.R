#' Calculate F1 Subset from FAS1 Dataset
#'
#' This function extracts the F1 dataset from the previously defined FAS1 dataset. It includes only
#' those encounters where the admission to the interpolar ward (`versorgungsstellenkontakt`) occurred
#' within a specified reporting period.
#'
#' @param FAS1 A data frame or tibble representing the FAS1 dataset. It must include a logical column
#'   `FAS1`, indicating the first valid interpolar ward contact per inpatient encounter, as well as
#'   a datetime column `enc_period_start`.
#' @param REPORT_PERIOD_START A character string representing the start date-time of the reporting period (in `"YYYY-MM-DD"` format or compatible POSIX format).
#' @param REPORT_PERIOD_END A character string representing the end date-time of the reporting period (exclusive).
#'
#' @return A data frame or tibble containing only those rows from FAS1 that:
#' \itemize{
#'   \item Are marked as `FAS1 == TRUE`.
#'   \item Have an `enc_period_start` on or after `REPORT_PERIOD_START`.
#'   \item Have an `enc_period_start` before `REPORT_PERIOD_END`.
#' }
#' The result contains distinct rows based on all columns in the input.
#'
#' @details
#' The function filters for encounters that represent admissions to interpolar wards occurring
#' during the defined report period. This ensures temporal relevance of ward admissions for the F1 cohort.
#'
#' @importFrom dplyr filter distinct
#' @export
calculateF1 <- function(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F1 <- FAS1 |>
    dplyr::filter(FAS1 == TRUE) |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
    dplyr::distinct()

  return(F1)
}

#------------------------------------------------------------------------------#

#' Calculate F2 Subset from FAS2.1 Dataset
#'
#' This function filters the FAS2.1 dataset to produce the F2 subset, which includes
#' only those ward contacts that meet the FAS2.1 criteria and have a start date within
#' the specified reporting period.
#'
#' @param FAS2_1 A data frame or tibble containing the FAS2.1 dataset. It must include:
#'   a logical column `FAS2_1`, and a `enc_period_start` column of type POSIXct.
#' @param REPORT_PERIOD_START A POSIXct object or character string convertible to POSIXct, indicating the start of the reporting period.
#' @param REPORT_PERIOD_END A POSIXct object or character string convertible to POSIXct, indicating the end of the reporting period.
#'
#' @return A filtered data frame or tibble containing only those FAS2.1 encounters where:
#'   \itemize{
#'     \item `FAS2_1` is TRUE, and
#'     \item `enc_period_start` falls within the defined reporting period
#'           (`REPORT_PERIOD_START` <= `enc_period_start` < `REPORT_PERIOD_END`).
#'   }
#' The resulting dataset is also deduplicated.
#'
#' @importFrom dplyr filter distinct
#' @export


calculateF2 <- function(FAS2_1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  F2 <- FAS2_1 |>
    dplyr::filter(FAS2_1 == TRUE) |>
    dplyr::filter(enc_period_start >= as.POSIXct(REPORT_PERIOD_START)) |> # only admission to INTEROPLAR ward in reporting period
    dplyr::filter(enc_period_start < as.POSIXct(REPORT_PERIOD_END)) |>
    dplyr::distinct()

  return(F2)
}
