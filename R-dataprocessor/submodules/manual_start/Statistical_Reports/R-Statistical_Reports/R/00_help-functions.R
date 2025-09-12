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
#' @importFrom dplyr group_by add_count filter ungroup across all_of
#'
#' @export
checkMultipleRows <- function(data, grouping_vars) {
  data_check_multiple_row <- data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) |>
    dplyr::add_count() |>
    dplyr::filter(n > 1) |>
    dplyr::ungroup()
  if (nrow(data_check_multiple_row) > 0) {
    print(data_check_multiple_row, width = Inf)
  }
  return(nrow(data_check_multiple_row) > 0)
}

#------------------------------------------------------------------------------#
#' Flag Groups with Multiple Rows by Adding a Processing Exclusion Reason
#'
#' This function checks whether groups defined by a set of variables contain
#' multiple rows. If so, it assigns a specified processing exclusion reason
#' to those rows. Existing values in the column `processing_exclusion_reason`
#' are preserved (prior exclusion reason) and remain NA for groups with only one row.
#'
#' @param data A `data.frame` or `tibble` containing the input data.
#' @param grouping_vars A character vector of column names used to define groups.
#' @param processing_exclusion_reason_name A character string specifying the
#'   reason to assign when a group contains more than one row.
#'
#' @return A `tibble` with the same structure as `data`, but with the column
#'   `processing_exclusion_reason` updated for groups with multiple rows.
#'
#' @details
#' - Groups are defined by the variables provided in `grouping_vars`.
#' - If a group contains more than one row, all rows in that group will be
#'   assigned the value from `processing_exclusion_reason_name` in the column
#'   `processing_exclusion_reason`. If the column already has a value, it will be
#'   preserved.
#' - If a group has only one row, the existing value in
#'   `processing_exclusion_reason` is preserved.
#'
#' @examples
#' library(dplyr)
#' df <- data.frame(
#'   patient_id = c(1, 1, 2, 3, 3, 3),
#'   value = c(10, 12, 5, 7, 8, 9),
#'   processing_exclusion_reason = NA_character_
#' )
#' df_flagged <- addMultipleRowsProcessingExclusionReason(
#'   data = df,
#'   grouping_vars = c("patient_id"),
#'   processing_exclusion_reason_name = "Multiple entries for patient"
#' )
#' df_flagged
#'
#' @importFrom dplyr group_by add_count mutate if_else ungroup select across all_of
#'
#' @export
addMultipleRowsProcessingExclusionReason <- function(data, grouping_vars, processing_exclusion_reason_name) {
  data_add_multiple_row_reason <- data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) |>
    dplyr::add_count() |>
    dplyr::mutate(processing_exclusion_reason = dplyr::if_else(n > 1 & is.na(processing_exclusion_reason),
                                                       processing_exclusion_reason_name,
                                                       processing_exclusion_reason)) |>
    dplyr::ungroup() |>
    dplyr::select(-n)
  return(data_add_multiple_row_reason)
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

parseNamedArgs <- function() {
  command_arguments <- commandArgs(trailingOnly = TRUE)

  named_args <- command_arguments[grepl("=", command_arguments)]

  # Convert to named character vector
  parsed <- sapply(named_args, function(arg) {
    parts <- strsplit(arg, "=", fixed = TRUE)[[1]]
    parts <- setNames(parts[2], parts[1])
  }, USE.NAMES = FALSE)

  return(parsed)
}


#------------------------------------------------------------------------------#

#' Split Multi-System Variable into Separate Columns
#'
#' Transforms a long-format dataset containing codes and system identifiers into
#' a wider format by creating two new columns corresponding to two distinct systems.
#' Each row will have at most one code per system; groups with multiple codes per
#' system will trigger an error.
#'
#' @param data A data frame or tibble containing the original dataset.
#' @param system1 Character vector specifying the first system(s) of interest.
#' @param codes1 Character vector specifying codes to include in the first system.
#' @param system2 Character vector specifying the second system(s) of interest.
#' @param codes2 Character vector specifying codes to include in the second system.
#' @param var_code String; the name of the column in `data` containing the code values.
#' @param var_system String; the name of the column in `data` containing the system identifiers.
#' @param var_new_system_1 String; the name of the new column to create for system 1 codes.
#' @param var_new_system_2 String; the name of the new column to create for system 2 codes.
#'
#' @return A data frame in which:
#' \itemize{
#'   \item The original `var_code` and `var_system` columns are removed.
#'   \item Two new columns (`var_new_system_1` and `var_new_system_2`) contain
#'         the corresponding code for each system or `NA` if none exists.
#'   \item If a group has multiple codes for the same system, an error is thrown.
#' }
#'
#' @details
#' The function first assigns codes to their respective new system columns using
#' the provided `system` and `codes` vectors. It then groups by all other columns
#' and ensures that each group has at most one code per system. If multiple codes
#' exist in a group, the function stops with an informative error.
#'
#' @importFrom dplyr mutate if_else select all_of across group_by summarise
#'
#' @export
PivotWiderTwoSystems <- function(data, system1, codes1, system2, codes2, var_code, var_system, var_new_system_1, var_new_system_2) {

  data <- data |>
    dplyr::mutate(!!var_new_system_1 := dplyr::if_else(get(var_system) %in% system1 | get(var_code) %in% codes1,
                                                       get(var_code), NA_character_)) |>
    dplyr::mutate(!!var_new_system_2 := dplyr::if_else(get(var_system) %in% system2 | get(var_code) %in% codes2,
                                                       get(var_code), NA_character_)) |>
    dplyr::select(-dplyr::all_of(c(var_code, var_system))) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c(var_new_system_1, var_new_system_2)))) |>
    dplyr::summarise(
      !!var_new_system_1 := {
        vals <- na.omit(.data[[var_new_system_1]])
        if (length(unique(vals)) > 1) {
          print(unique(vals), width = Inf)
          stop(paste0("Multiple ",var_new_system_1," values in group"))
        }
        if (length(vals) == 0) NA_character_ else vals[1]
      },
      !!var_new_system_2 := {
        vals <- na.omit(.data[[var_new_system_2]])
        if (length(unique(vals)) > 1) {
          print(unique(vals), width = Inf)
          stop(paste0("Multiple ",var_new_system_2," values in group"))
        }
        if (length(vals) == 0) NA_character_ else vals[1]
      },
      .groups = "drop"
    )
  return(data)

}



