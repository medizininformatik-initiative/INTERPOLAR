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
    dplyr::slice_max({{ selection_variable }}) |>
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
    dplyr::slice_min({{ selection_variable }}) |>
    dplyr::ungroup()
  return(data_current)
}

#------------------------------------------------------------------------------#

#' Check for Multiple Rows Within Each Group
#'
#' This function checks whether there are multiple rows for the same group in a dataset, based on
#' specified grouping variables.
#'
#' @param data A data frame containing the dataset to be checked.
#' @param grouping_vars A character vector specifying the columns used for grouping.
#'
#' @return A logical value: `TRUE` if there are groups with multiple rows, otherwise `FALSE`.
#'
#' @details
#' The function groups the data by the specified grouping variables, counts the number of rows in
#' each group, and checks whether any group contains more than one row.
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
addMultipleRowsProcessingExclusionReason <- function(data, grouping_vars,
                                                     processing_exclusion_reason_name) {
  data_add_multiple_row_reason <- data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) |>
    dplyr::add_count() |>
    dplyr::mutate(processing_exclusion_reason = dplyr::if_else(n > 1 &
      is.na(processing_exclusion_reason),
    processing_exclusion_reason_name,
    processing_exclusion_reason
    )) |>
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

#' Pivot Encounter Types from Two Coding Systems into Separate Columns
#'
#' This function restructures encounter type information from two different
#' coding systems (e.g. FHIR Kontaktebene and Kontaktart) into two separate
#' columns. It checks for unknown systems/codes, assigns exclusion reasons,
#' and ensures that only one unique code per encounter and system exists.
#' If multiple distinct codes are present in a group, a warning is issued,
#' the corresponding value is set to `"MULTIPLE_VALUES"`, and an exclusion
#' reason is recorded.
#'
#' @param data A data frame containing encounter type information.
#' @param system1 Character vector of accepted system identifiers for the first
#'   coding system.
#' @param codes1 Character vector of accepted codes for the first coding system.
#' @param system2 Character vector of accepted system identifiers for the second
#'   coding system.
#' @param codes2 Character vector of accepted codes for the second coding system.
#' @param var_code Character string giving the column name in `data` that holds
#'   the encounter type code.
#' @param var_system Character string giving the column name in `data` that holds
#'   the code system (e.g. FHIR system URL).
#' @param var_new_system_1 Name of the new column (as character) to store codes
#'   from the first system.
#' @param var_new_system_2 Name of the new column (as character) to store codes
#'   from the second system.
#' @param exclusion_reason Character string that will be written into
#'   `processing_exclusion_reason` when unknown or multiple values are detected.
#' @param id_column Character string specifying an identifier column (e.g. encounter ID),
#'   used only for warning messages to help trace problematic rows.
#'
#' @return A data frame where:
#'   \itemize{
#'     \item Codes belonging to `system1` or `codes1` appear in `var_new_system_1`.
#'     \item Codes belonging to `system2` or `codes2` appear in `var_new_system_2`.
#'     \item Rows with unknown or inconsistent coding receive
#'       `processing_exclusion_reason = exclusion_reason`.
#'   }
#'
#' @details
#' The function:
#' \enumerate{
#'   \item Checks if `var_code` or `var_system` contains unexpected values and warns.
#'   \item Maps codes to system-specific columns.
#'   \item Groups by all other variables and collapses codes to one per group.
#'   \item If more than one unique code is found per group and system,
#'         `"MULTIPLE_VALUES"` is inserted and `exclusion_reason` is set.
#' }
#'
#' @importFrom dplyr mutate if_else select group_by summarise across all_of distinct
#'
#' @examples
#' df <- data.frame(
#'   id = c(1, 2, 3, 4),
#'   enc_type_code = c(
#'     "einrichtungskontakt", "normalstationaer",
#'     "abteilungskontakt", "unknown_code"
#'   ),
#'   enc_type_system = c(
#'     "http://fhir.de/CodeSystem/Kontaktebene",
#'     "http://fhir.de/CodeSystem/kontaktart-de",
#'     "http://fhir.de/CodeSystem/Kontaktebene",
#'     "http://fhir.de/CodeSystem/Kontaktebene"
#'   )
#' )
#'
#' PivotWiderTwoSystems(
#'   data = df,
#'   system1 = "http://fhir.de/CodeSystem/Kontaktebene",
#'   codes1 = c("einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt"),
#'   system2 = "http://fhir.de/CodeSystem/kontaktart-de",
#'   codes2 = c("normalstationaer"),
#'   var_code = "enc_type_code",
#'   var_system = "enc_type_system",
#'   var_new_system_1 = "enc_type_code_Kontaktebene",
#'   var_new_system_2 = "enc_type_code_Kontaktart",
#'   exclusion_reason = "mapping_failed",
#'   id_column = "id"
#' )
#'
#' @export
PivotWiderTwoSystems <- function(data, system1, codes1, system2, codes2, var_code, var_system,
                                 var_new_system_1, var_new_system_2, exclusion_reason, id_column) {
  # Check for unexpected codes/systems
  unexpected_code_rows <- !is.na(data[[var_code]]) & !data[[var_code]] %in% c(codes1, codes2)
  if (any(unexpected_code_rows)) {
    affected_ids <- unique(data[[id_column]][unexpected_code_rows])
    warning(paste0(
      "Some codes in ", var_code, " are not expected. Affected IDs: ",
      paste(affected_ids, collapse = ", ")
    ))
  }
  unexpected_system_rows <- !is.na(data[[var_system]]) & !data[[var_system]] %in% c(system1, system2)
  if (any(unexpected_system_rows)) {
    affected_ids <- unique(data[[id_column]][unexpected_system_rows])
    warning(paste0(
      "Some systems in ", var_system, " are not expected. Affected IDs: ",
      paste(affected_ids, collapse = ", ")
    ))
  }
  data <- data |>
    dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
      !get(var_code) %in% c(codes1, codes2), exclusion_reason, NA_character_
    )) |>
    # System 1-Mapping
    dplyr::mutate(!!var_new_system_1 := dplyr::if_else(get(var_system) %in% system1 |
      get(var_code) %in% codes1,
    get(var_code), NA_character_
    )) |>
    # System 2-Mapping
    dplyr::mutate(!!var_new_system_2 := dplyr::if_else(get(var_system) %in% system2 |
      get(var_code) %in% codes2,
    get(var_code), NA_character_
    )) |>
    # Pivot wider
    dplyr::select(-dplyr::all_of(c(var_code, var_system))) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c(var_new_system_1, var_new_system_2)))) |>
    dplyr::summarise(
      !!var_new_system_1 := {
        vals <- na.omit(.data[[var_new_system_1]])
        if (length(unique(vals)) > 1) {
          warning(paste0(
            "Multiple ", var_new_system_1,
            " values for ID(s): ", paste(unique(.data[[id_column]]), collapse = ", "),
            ". No unique mapping possible."
          ))
          "MULTIPLE_VALUES"
        } else if (length(vals) == 0) NA_character_ else vals[1]
      },
      !!var_new_system_2 := {
        vals <- na.omit(.data[[var_new_system_2]])
        if (length(unique(vals)) > 1) {
          warning(paste0(
            "Multiple ", var_new_system_2,
            " values for ID(s): ", paste(unique(.data[[id_column]]), collapse = ", "),
            ". No unique mapping possible."
          ))
          "MULTIPLE_VALUES"
        } else if (length(vals) == 0) NA_character_ else vals[1]
      },
      .groups = "drop"
    ) |>
    # Add processing exclusion reason for multiple/unknown values
    dplyr::mutate(
      processing_exclusion_reason = dplyr::if_else(
        is.na(processing_exclusion_reason) &
          (.data[[var_new_system_1]] %in% c("MULTIPLE_VALUES") |
            .data[[var_new_system_2]] %in% c("MULTIPLE_VALUES")),
        exclusion_reason,
        processing_exclusion_reason
      )
    ) |>
    dplyr::distinct()
  return(data)
}

#' Check for Missing Encounter Start Dates
#'
#' Checks an encounter table for missing values in `enc_period_start` and marks
#' affected rows with a processing exclusion reason. A warning is issued if any
#' missing start dates are detected.
#'
#' @param encounter_table A data.frame containing encounter-level data.
#'   Must include the columns `enc_period_start` and `processing_exclusion_reason`.
#'
#' @return A data.frame identical to `encounter_table`, but with
#'   `processing_exclusion_reason` set to `"missing_start_date"` for rows where
#'   `enc_period_start` is `NA` and no exclusion reason was previously defined.
#'
#' @details
#' If at least one missing value is found in `enc_period_start`, the function:
#' \enumerate{
#'   \item Assigns `"missing_start_date"` to `processing_exclusion_reason`
#'         where it is currently `NA`
#'   \item Prints affected rows to the console
#'   \item Emits a warning indicating potential data loss
#' }
#'
#' This function does not stop execution and always returns the modified table.
#'
#' @importFrom dplyr mutate if_else filter
#' @export
CheckMissingStartDate <- function(encounter_table) {
  if (any(is.na(encounter_table$enc_period_start))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(is.na(enc_period_start) &
        is.na(processing_exclusion_reason), "missing_start_date", processing_exclusion_reason))
    print(encounter_table |>
      dplyr::filter(is.na(enc_period_start)), width = Inf)
    warning("The encounter table contains NA values in enc_period_start.
            Relevant encounter data may be missed. Please check the data")
  }
  return(encounter_table)
}


# DEBUG Section ----------------------------------------------------------

DEBUG_TEST_REPORTING_WARNINGS <- FALSE

if (DEBUG_TEST_REPORTING_WARNINGS) {
  createEncounerDataWarningSituations <- function(encounter_table) {
    missing_start_date_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "versorgungsstellenkontakt") |>
      dplyr::slice(1) |>
      dplyr::mutate(enc_period_start = as.POSIXct(NA))

    missing_kontaktebene_for_imp_encounter_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::filter(enc_class_code == "IMP") |>
      dplyr::slice(2) |>
      dplyr::mutate(enc_type_code_Kontaktebene = as.character(NA))

    unexpected_imp_status_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::filter(enc_class_code == "IMP") |>
      dplyr::slice(3) |>
      dplyr::mutate(enc_status = "test_status")

    imp_finished_without_end_date_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::filter(enc_class_code == "IMP") |>
      dplyr::slice(4) |>
      dplyr::mutate(enc_status = "finished", enc_period_end = as.POSIXct(NA))

    unexpected_class_code_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "abteilungskontakt") |>
      dplyr::slice(5) |>
      dplyr::mutate(enc_class_code = "TEST")

    unexpected_kontaktart_code_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::slice(6) |>
      dplyr::mutate(enc_type_code_Kontaktart = "TEST_KONTAKTART")

    multiple_einrichtungskontakt_enc_identifier_values_for_same_enc_id_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::slice(7) |>
      dplyr::mutate(enc_identifier_value = paste0(enc_identifier_value, "-test"))

    multiple_einrichtungskontakt_enc_ids_for_same_enc_identifier_value_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::slice(8) |>
      dplyr::mutate(
        enc_id = paste0(enc_id, "-test"),
        enc_main_encounter_calculated_ref = paste0(enc_main_encounter_calculated_ref, "-test")
      )

    no_enc_main_encounter_calculated_ref_check <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::slice(9) |>
      dplyr::mutate(enc_main_encounter_calculated_ref = as.character(NA))

    check_encounter_table <- missing_start_date_check |>
      rbind(missing_kontaktebene_for_imp_encounter_check) |>
      rbind(unexpected_imp_status_check) |>
      rbind(imp_finished_without_end_date_check) |>
      rbind(unexpected_class_code_check) |>
      rbind(unexpected_kontaktart_code_check) |>
      rbind(no_enc_main_encounter_calculated_ref_check)

    check_encounter_table_enc_ids <- check_encounter_table$enc_id

    encounter_table <- encounter_table |>
      dplyr::filter(!enc_id %in% check_encounter_table_enc_ids) |>
      rbind(check_encounter_table) |>
      rbind(multiple_einrichtungskontakt_enc_identifier_values_for_same_enc_id_check) |>
      rbind(multiple_einrichtungskontakt_enc_ids_for_same_enc_identifier_value_check)

    return(encounter_table)
  }
}
