#' Select the Most Recent Row for Each Group
#'
#' This function filters a dataset to retain only the most recent row for each group, based on the `input_datetime` column.
#'
#' @param data A data frame containing the dataset to be filtered.
#' @param grouping_vars A character vector specifying the columns used for grouping.
#'
#' @return A data frame containing the most recent row for each group, based on the maximum value of `input_datetime`.
#'
#' @details
#' The function uses `dplyr` to group the data by the specified grouping variables, then selects the row with the maximum value of `input_datetime` within each group.
#'
#'
#' # Select the most recent row for each group
#' select_newest_input(data, grouping_vars = "group")
#'
#' @importFrom dplyr group_by slice_max ungroup
#'
#' @export
selectNewestInput <- function(data, grouping_vars) {
  data_current <- data |>
    dplyr::group_by(across(all_of(grouping_vars))) |>
    dplyr::slice_max(input_datetime) |>
    dplyr::ungroup()
  return(data_current)
}

#------------------------------------------------------------------------------#

#' Check for Multiple Rows Within Each Group
#'
#' This function checks whether there are multiple rows for the same group in a dataset, based on specified grouping variables.
#'
#' @param data A data frame containing the dataset to be checked.
#' @param grouping_vars A character vector specifying the columns used for grouping.
#'
#' @return A logical value: `TRUE` if there are groups with multiple rows, otherwise `FALSE`.
#'
#' @details
#' The function groups the data by the specified grouping variables, counts the number of rows in each group, and checks whether any group contains more than one row.
#'
#'
#' # Check for multiple rows in each group
#' check_multiple_rows(data, grouping_vars = "group")
#'
#' @importFrom dplyr group_by add_count filter ungroup
#'
#' @export
checkMultipleRows <- function(data, grouping_vars) {
  data_check_multiple_row <- data |>
    dplyr::group_by(across(all_of(grouping_vars))) |>
    dplyr::add_count() |>
    dplyr::filter(n > 1) |>
    dplyr::ungroup()
  return(nrow(data_check_multiple_row) > 0)
}
