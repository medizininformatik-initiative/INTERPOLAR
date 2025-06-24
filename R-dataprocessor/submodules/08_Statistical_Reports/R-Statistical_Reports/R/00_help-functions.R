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

# -------------------------------------------------------------------------------#

#' Write a Formatted Table to a File
#'
#' This function converts a data frame or matrix into a table formatted in the specified format
#' and writes it to a file. It leverages the `kableExtra` package for styling and file output.
#'
#' @param table A data frame or matrix to convert into a formatted table.
#' @param filename_without_extension A character string specifying the base name of the output file.
#' If `NA`, the name of the `table` variable is used as the filename.
#' @param project_sub_dir A character string defining a sub-directory within the project's local directory
#' where the file will be saved, or `NA` to use a default directory path. The path is constructed using `fhircrackr::pastep`.
#' @param format A character string indicating the format of the output table file (only html); Default is "html".
#'
#' @return This function does not return a value. It creates a side effect of writing a file in the specified format.
#'
#' @details
#' The function determines the filename by examining the call stack if `filename_without_extension` is `NA`.
#' It calculates the save path using `fhircrackr::pastep` and applies styling to the table using `kableExtra`.
#' The table format is flexible, supporting "html" outputs.
#'
#' @examples
#' \dontrun{
#' writeKable(mtcars, "mtcars_summary", format = "html")
#' }
#'
#' @seealso
#' \code{\link[kableExtra]{kable}}, \code{\link[kableExtra]{kable_styling}}, \code{\link[kableExtra]{save_kable}}
#'
writeKable <- function(table, filename_without_extension = NA, project_sub_dir = NA, format = "html", caption=NA) {
  if (!is.null(table)) {
    if (is.na(filename_without_extension)) {
      filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
    }
    if (is.na(project_sub_dir)) {
      project_sub_dir <- fhircrackr::pastep(MODULE_DIRS$local_dir, "reports")
    } else {
      project_sub_dir <- fhircrackr::pastep('.', project_sub_dir)
    }
    if (!dir.exists(project_sub_dir)) {
      dir.create(project_sub_dir, recursive = TRUE)
    }
    kableExtra::kable(table, format = "html", caption = caption) |>
      kableExtra::kable_styling("striped", full_width = FALSE, position = "center") |>
      kableExtra::save_kable(file = fhircrackr::pastep(project_sub_dir, filename_without_extension, ext = paste0(".",format)))
  }
  else {
    warning(paste0("The table '", deparse(substitute(table)), "' is NULL. No file was written."))
  }
}


