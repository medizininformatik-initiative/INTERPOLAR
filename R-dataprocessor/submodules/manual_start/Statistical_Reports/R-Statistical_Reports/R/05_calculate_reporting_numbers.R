#' Calculate F1 Aggregates
#'
#' This function summarizes the prepared F1 dataset by computing counts of encounters and patients
#' grouped by ward and calendar week. It also computes overall totals across all wards and weeks.
#'
#' @param F1_prep A data frame or tibble as returned by `prepareF1data()`. It must include the columns:
#'   `main_enc_id`, `fall_id_KIS`, `pat_id`, `record_id`, `ward_name`, and `calendar_week`.
#'
#' @return A tibble containing aggregated counts of F1-relevant metrics. The result includes:
#'   \item{`ward_name`}{Ward name or `"all wards"` for total counts.}
#'   \item{`calendar_week`}{Calendar week or `"all weeks"` for total counts.}
#'   \item{`F1_encounters`}{Number of distinct main encounters.}
#'   \item{`F1_encounters_also_in_fe`}{Number of main encounters matched in the front-end data (`fall_id_KIS`).}
#'   \item{`F1_patients`}{Number of distinct patients.}
#'   \item{`F1_patients_also_in_fe`}{Number of patients matched in the front-end data (`record_id`).}
#'
#' @details
#' The function performs two levels of aggregation:
#' \itemize{
#'   \item Grouped by `ward_name` and `calendar_week`.
#'   \item Total row for all wards and all calendar weeks.
#' }
#'
#' This helps in comparing study and front-end data coverage over time and location.
#'
#' @importFrom dplyr group_by summarise n_distinct bind_rows
#' @export
calculateF1 <- function(F1_prep) {

    F1_grouped_counts <- F1_prep |>
      dplyr::group_by(ward_name, calendar_week) |>
      dplyr::summarise(
        F1_encounters = dplyr::n_distinct(main_enc_id),
        F1_encounters_also_in_fe = dplyr::n_distinct(fall_id_KIS),
        F1_patients = dplyr::n_distinct(pat_id),
        F1_patients_also_in_fe = dplyr::n_distinct(record_id),
        .groups = 'drop'
      )

    F1_total_counts <- F1_prep |>
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

#------------------------------------------------------------------------------#
# TODO: calculate F2 counts ---------
calculateF2 <- function(F2_prep) {
  return(F2)
}
