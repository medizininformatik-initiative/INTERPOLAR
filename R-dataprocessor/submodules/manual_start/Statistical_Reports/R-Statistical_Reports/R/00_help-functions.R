#' Select Maximum Values by Group
#'
#' This function groups a dataset by specified grouping variables and selects the rows
#' with the maximum values of a specified selection variable within each group.
#'
#' @param data A data frame containing the dataset to be processed.
#' @param grouping_variables A character vector of column names to group the data by.
#' @param selection_variable An unquoted string specifying the column name for which the maximum
#' value is used for filtering within each group.
#'
#' @return A data frame containing the rows with the maximum values of the
#' selection variable for each group defined by the grouping variables.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' df <- data.frame(
#'   group = c("A", "A", "B", "B"),
#'   value = c(10, 20, 5, 30)
#' )
#'
#' selectMax(df, grouping_variables = "group", selection_variable = value)
#' }
#'
#' @importFrom dplyr group_by slice_max ungroup across all_of
#' @export
selectMax <- function(data, grouping_variables, selection_variable) {
  data_current <- data |>
    dplyr::group_by(across(all_of(grouping_variables))) |>
    dplyr::slice_max({{selection_variable}}) |>
    dplyr::ungroup()
  return(data_current)
}

#------------------------------------------------------------------------------#
#' Select Minimum Values by Group
#'
#' This function groups a dataset by specified grouping variables and selects the rows
#' with the minimum values of a specified selection variable within each group.
#'
#' @param data A data frame containing the dataset to be processed.
#' @param grouping_variables A character vector of column names to group the data by.
#' @param selection_variable An unquoted string specifying the column name for which the minimum
#' value is used for filtering within each group.
#'
#' @return A data frame containing the rows with the minimum values of the
#' selection variable for each group defined by the grouping variables.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' df <- data.frame(
#'   group = c("A", "A", "B", "B"),
#'   value = c(10, 20, 5, 30)
#' )
#'
#' selectMin(df, grouping_variables = "group", selection_variable = value)
#' }
#'
#' @importFrom dplyr group_by slice_min ungroup across all_of
#' @export
selectMin <- function(data, grouping_variables, selection_variable) {
  data_current <- data |>
    dplyr::group_by(across(all_of(grouping_variables))) |>
    dplyr::slice_min({{selection_variable}}) |>
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

#------------------------------------------------------------------------------#

#' Parse Named Command-Line Arguments
#'
#' Extracts and parses named command-line arguments passed in the format `name=value`
#' when the R script is executed from the command line.
#'
#' @return A named character vector where each element corresponds to a parsed
#' command-line argument, with argument names as the vector names.
#'
#' @details
#' This function is useful for command-line R scripts where parameters
#' are passed as `name=value` pairs (e.g., `Rscript script.R param1=value1 param2=value2`).
#'
#' Arguments without an `=` sign are ignored.
#'
#' @export

parse_named_args <- function() {
  command_arguments <- commandArgs(trailingOnly = TRUE)

  named_args <- command_arguments[grepl("=", command_arguments)]

  # Convert to named character vector
  parsed <- sapply(named_args, function(arg) {
    parts <- strsplit(arg, "=", fixed = TRUE)[[1]]
    setNames(parts[2], parts[1])
  })

  return(parsed)
}






