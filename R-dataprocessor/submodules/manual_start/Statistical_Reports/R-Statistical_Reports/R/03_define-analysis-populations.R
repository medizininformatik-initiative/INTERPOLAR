#' Filter Data for Full Analysis Set 1
#'
#' Filters front-end summary data to retain only records belonging to the
#' first analysis set according to the earliest encounter period start and
#' the first medication analysis per sub-encounter.
#'
#' The function keeps only records where the encounter period start matches
#' the first encounter period start of the corresponding main encounter.
#' Within each main and sub-encounter combination, the medication analysis
#' identifier is parsed to determine the earliest medication analysis number.
#' If medication analyses are available, only records belonging to the
#' earliest analysis are retained. Duplicate rows are removed afterwards.
#'
#' @param data A data frame containing encounter and medication analysis
#'   information.
#' @param main_enc_id The column identifying main encounters. The column
#'   should be supplied unquoted.
#' @param sub_enc_id The column identifying sub-encounters. The column
#'   should be supplied unquoted.
#' @param enc_period_start The date or date-time column containing the
#'   encounter period start. The column should be supplied unquoted.
#' @param meda_id The medication analysis identifier column used to determine
#'   the first medication analysis. The column should be supplied unquoted.
#' @param first_enc_period_start_col The column containing the first encounter
#'   period start per main encounter. The column should be supplied unquoted.
#'
#' @return A data frame containing records assigned to full analysis set 1,
#'   including only the earliest encounter period and earliest medication
#'   analysis per sub-encounter where available.
#'
#' @importFrom dplyr distinct
#' @importFrom dplyr filter
#' @importFrom dplyr group_by
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom dplyr ungroup
#' @importFrom stringr str_extract
#'
#' @export
# TODO: test and add warnings for missing meda_id or _meda_dat (already exclusion reason) --------------
filterFullAnalysisSet1 <- function(
  data = frontend_summary_prep,
  main_enc_id = main_enc_id,
  sub_enc_id = enc_id,
  enc_period_start = enc_period_start,
  meda_id = meda_id,
  first_enc_period_start_col = first_enc_period_start_per_main_enc
) {
  full_analysis_set_1 <- data |>
    dplyr::filter({{ enc_period_start }} == {{ first_enc_period_start_col }}) |>
    dplyr::group_by({{ main_enc_id }}, {{ sub_enc_id }}) |>
    dplyr::mutate(meda_number = as.integer(stringr::str_extract({{ meda_id }}, "(?<=-)\\d+$"))) |>
    dplyr::filter(
      if (any(!is.na(meda_number))) {
        meda_number == min(meda_number, na.rm = TRUE)
      } else {
        TRUE
      }
    ) |>
    dplyr::ungroup() |>
    dplyr::select(-meda_number) |>
    dplyr::distinct()

  return(full_analysis_set_1)
}

#------------------------------------------------------------------------------#

# TODO: implement rules for combining short absences for determining length of first interpolar ward contact? -------
# TODO: handle NA end-dates properly (e.g. deceased) -------------
