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

#' Check Multiple Rows per Patient ID
#'
#' This function checks whether the patient table contains multiple rows for the
#' same patient id (`pat_id`).
#'
#' If multiple rows are found for the same `pat_id`, a warning is issued and the
#' function assigns a processing exclusion reason
#' `"multiple_rows_per_pat_id"` using `addMultipleRowsProcessingExclusionReason`.
#'
#' @param patient_table A data frame containing patient-level data. The table
#'   must include the column `pat_id`.
#'
#' @return
#' A data frame identical to `patient_table`, with `processing_exclusion_reason`
#' updated for patient IDs that appear in multiple rows.
#'
#' @details
#' Multiple rows per patient ID may indicate duplicated patient entries (e.g. multiple
#' pat_identifier_value). Flagging these rows ensures that downstream
#' analyses handle such cases appropriately.
#'
#' @importFrom dplyr mutate
#'
#' @export
CheckMultipleRowsPerPatId <- function(patient_table) {
  if (checkMultipleRows(patient_table, c("pat_id"))) {
    warning("The patient table contains multiple rows for the same pat_id(FHIR).
            Please check the data.")
    patient_table <- patient_table |>
      addMultipleRowsProcessingExclusionReason(c("pat_id"), "multiple_rows_per_pat_id")
  }
  return(patient_table)
}

#' Check Multiple Rows per Patient Identifier Value
#'
#' This function checks whether the patient table contains multiple rows for the
#' same patient identifier value (`pat_identifier_value`).
#'
#' If multiple rows are found for the same `pat_identifier_value`, a warning is issued
#' and the function assigns a processing exclusion reason
#' `"multiple_rows_per_pat_identifier_value"` using `addMultipleRowsProcessingExclusionReason`.
#'
#' @param patient_table A data frame containing patient-level data. The table
#'   must include the column `pat_identifier_value`.
#'
#' @return
#' A data frame identical to `patient_table`, with `processing_exclusion_reason`
#' updated for patient identifier values that appear in multiple rows.
#'
#' @details
#' Multiple rows per patient identifier value may indicate duplicated patient
#' entries or issues in data extraction. Flagging these rows ensures that
#' downstream analyses handle such cases appropriately.
#'
#' @importFrom dplyr mutate
#'
#' @export
CheckMultipleRowsPerPatIdentifierValue <- function(patient_table) {
  if (checkMultipleRows(patient_table, c("pat_identifier_value"))) {
    warning("The patient table contains multiple rows for the same patient identifier (cis).
            Please check the data.")
    patient_table <- patient_table |>
      addMultipleRowsProcessingExclusionReason(
        c("pat_identifier_value"),
        "multiple_rows_per_pat_identifier_value"
      )
  }
  return(patient_table)
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

#' Check Missing Kontaktebene for Inpatient Encounters
#'
#' Identifies inpatient encounters (`enc_class_code == "IMP"`) that are missing
#' a Kontaktebene classification (`enc_type_code_Kontaktebene`). For affected
#' rows where no processing exclusion reason has yet been set, the function
#' assigns the exclusion reason `"missing_kontaktebene_for_imp_encounter"`.
#'
#' If such cases are detected, the function prints the affected rows and issues
#' a warning to indicate potentially incomplete or unexpected encounter type
#' coding.
#'
#' @param encounter_table A data frame containing encounter-level data. The
#'   table must include the columns:
#'   \itemize{
#'     \item \code{enc_class_code}
#'     \item \code{enc_type_code_Kontaktebene}
#'     \item \code{processing_exclusion_reason}
#'   }
#'
#' @return
#' A data frame identical to \code{encounter_table}, but with
#' \code{processing_exclusion_reason} populated with
#' `"missing_kontaktebene_for_imp_encounter"` for inpatient encounters missing
#' Kontaktebene information.
#'
#' @details
#' The function only applies to encounters classified as inpatient
#' (\code{enc_class_code == "IMP"}). Existing values in
#' \code{processing_exclusion_reason} are preserved and will not be overwritten.
#'
#' When missing Kontaktebene values are detected, the affected encounter rows
#' are printed and a warning is raised to alert the user that encounter filtering
#' or downstream analyses may be impacted.
#'
#' @importFrom dplyr mutate if_else filter
#'
#' @export
CheckMissingKontaktebeneForImpEncounter <- function(encounter_table) {
  if (any(!is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
    (is.na(encounter_table$enc_type_code_Kontaktebene)))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(processing_exclusion_reason) &
          !is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
          is.na(encounter_table$enc_type_code_Kontaktebene),
        "missing_kontaktebene_for_imp_encounter", processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter(enc_class_code == "IMP" & is.na(enc_type_code_Kontaktebene)), width = Inf)
    warning("The encounter table with extended filtering contains inpatient encounters with missing
    type codes for Kontaktebene. Please check the data for expected implementation of enc_type_code
            and enc_type_system.")
  }
  return(encounter_table)
}

#' Check for Unexpected Status Values in Inpatient Encounters
#'
#' Identifies inpatient encounters (`enc_class_code == "IMP"`) with missing or
#' unexpected encounter status values. Valid inpatient status values are
#' `"finished"`, `"in-progress"`, and `"onleave"`.
#'
#' For affected rows where no processing exclusion reason has yet been assigned,
#' the function sets the exclusion reason to `"unexpected_imp_status"`.
#'
#' If such encounters are found, the function prints the affected rows and
#' issues a warning to alert the user to potentially invalid or incomplete
#' encounter status coding.
#'
#' @param encounter_table A data frame containing encounter-level data. The
#'   table must include the columns:
#'   \itemize{
#'     \item \code{enc_class_code}
#'     \item \code{enc_status}
#'     \item \code{processing_exclusion_reason}
#'   }
#'
#' @return
#' A data frame identical to \code{encounter_table}, but with
#' \code{processing_exclusion_reason} populated with `"unexpected_imp_status"`
#' for inpatient encounters with missing or invalid status values.
#'
#' @details
#' The check applies only to inpatient encounters
#' (\code{enc_class_code == "IMP"}). Existing values in
#' \code{processing_exclusion_reason} are preserved and will not be overwritten.
#'
#' Encounter rows with \code{enc_status} equal to \code{NA} or not belonging to
#' the allowed set (`"finished"`, `"in-progress"`, `"onleave"`) are considered
#' invalid.
#'
#' When invalid statuses are detected, affected rows are printed and a warning
#' is emitted to indicate that downstream filtering or reporting may be
#' affected.
#'
#' @importFrom dplyr mutate if_else filter
#'
#' @export
CheckUnexpectedImpStatus <- function(encounter_table) {
  if (any(!is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
    (is.na(encounter_table$enc_status) | !encounter_table$enc_status %in% c(
      "finished", "in-progress", "onleave"
    )))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(enc_class_code == "IMP" &
        (is.na(encounter_table$enc_status) | !enc_status %in% c("finished", "in-progress", "onleave")) &
        is.na(processing_exclusion_reason),
      "unexpected_imp_status", processing_exclusion_reason
      ))
    print(
      encounter_table |>
        dplyr::filter(enc_class_code == "IMP" & (is.na(enc_status) | !enc_status %in% c(
          "finished", "in-progress",
          "onleave"
        ))),
      width = Inf
    )
    warning("The encounter table contains inpatient encounters with unexpected or NA status values.
            Please check the data.")
  }
  return(encounter_table)
}

#' Check Finished Inpatient Encounters Without an End Date
#'
#' Identifies inpatient encounters (`enc_class_code == "IMP"`) that are marked
#' as `"finished"` but have a missing encounter end date
#' (`enc_period_end == NA`).
#'
#' For affected rows where no processing exclusion reason has yet been assigned,
#' the function sets the exclusion reason to
#' `"imp_finished_without_end_date"`.
#'
#' If such encounters are detected, the affected rows are printed and a warning
#' is issued to inform the user about potentially incomplete encounter period
#' data.
#'
#' @param encounter_table A data frame containing encounter-level data. The
#'   table must include the columns:
#'   \itemize{
#'     \item \code{enc_class_code}
#'     \item \code{enc_status}
#'     \item \code{enc_period_end}
#'     \item \code{processing_exclusion_reason}
#'   }
#'
#' @return
#' A data frame identical to \code{encounter_table}, but with
#' \code{processing_exclusion_reason} set to
#' `"imp_finished_without_end_date"` for inpatient encounters that are marked
#' as finished but lack an end date.
#'
#' @details
#' The check applies only to inpatient encounters
#' (\code{enc_class_code == "IMP"}). Existing values in
#' \code{processing_exclusion_reason} are preserved and will not be overwritten.
#'
#' Finished inpatient encounters are expected to have a valid end date.
#' Missing end dates may lead to incorrect length-of-stay calculations or
#' incomplete reporting.
#'
#' When affected rows are found, they are printed for inspection and a warning
#' is emitted to highlight potential data quality issues.
#'
#' @importFrom dplyr mutate if_else filter
#'
#' @export
CheckImpFinishedWithoutEndDate <- function(encounter_table) {
  if (any(!is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
    (!is.na(encounter_table$enc_status) &
      encounter_table$enc_status == "finished") & is.na(encounter_table$enc_period_end))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(enc_class_code == "IMP" &
        enc_status == "finished" & is.na(enc_period_end) &
        is.na(processing_exclusion_reason),
      "imp_finished_without_end_date", processing_exclusion_reason
      ))
    print(
      encounter_table |>
        dplyr::filter(enc_class_code == "IMP" & enc_status == "finished" &
          is.na(encounter_table$enc_period_end)),
      width = Inf
    )
    warning("The encounter table contains finished IMP encounters without an end date.
         Please check the data.")
  }
  return(encounter_table)
}

#' Check for Unexpected Encounter Class Codes
#'
#' This function checks an encounter table for encounter class codes that are
#' not among the expected values (`"AMB"`, `"SS"`, `"IMP"`). If such values are
#' found, the function assigns the processing exclusion reason
#' `"unexpected_class_code"` to affected rows where no exclusion reason is
#' already present.
#'
#' In addition, the affected rows are printed to the console and a warning is
#' issued to alert the user that unexpected class codes were detected.
#'
#' @param encounter_table A data frame containing encounter-level data. The
#'   table must include the columns `enc_class_code` and
#'   `processing_exclusion_reason`.
#'
#' @return
#' A data frame with the same structure as `encounter_table`. Rows with
#' unexpected encounter class codes have their `processing_exclusion_reason`
#' updated accordingly.
#'
#' @details
#' Expected encounter class codes are:
#' \itemize{
#'   \item \code{"AMB"} – ambulatory encounters
#'   \item \code{"SS"} – same-day surgery encounters
#'   \item \code{"IMP"} – inpatient encounters
#' }
#'
#' Any non-missing value of \code{enc_class_code} that is not one of these
#' values is considered unexpected.
#'
#' @importFrom dplyr mutate if_else filter
#'
#' @export
CheckUnexpectedClassCode <- function(encounter_table) {
  if (any((!encounter_table$enc_class_code %in% c("AMB", "SS", "IMP")) &
    !is.na(encounter_table$enc_class_code))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else((!enc_class_code %in%
        c("AMB", "SS", "IMP")) &
        !is.na(enc_class_code) &
        is.na(processing_exclusion_reason),
      "unexpected_class_code", processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter((!encounter_table$enc_class_code %in% c("AMB", "SS", "IMP")) &
        !is.na(encounter_table$enc_class_code)), width = Inf)
    warning("The encounter table contains class codes with unexpected values.
            Please check the data.")
  }
  return(encounter_table)
}

#' Check for Unexpected Kontaktart Type Codes
#'
#' This function checks an encounter table for unexpected values in the
#' `enc_type_code_Kontaktart` column. If encounter type codes are found that are
#' not among the expected Kontaktart codes, the function assigns the processing
#' exclusion reason `"unexpected_kontaktart_code"` to the affected rows where no
#' exclusion reason is already present.
#'
#' The affected rows are printed to the console and a warning is issued to inform
#' the user that unexpected Kontaktart type codes were detected.
#'
#' @param encounter_table A data frame containing encounter-level data. The
#'   table must include the columns `enc_type_code_Kontaktart` and
#'   `processing_exclusion_reason`.
#'
#' @return
#' A data frame with the same structure as `encounter_table`. Rows containing
#' unexpected Kontaktart type codes have their
#' `processing_exclusion_reason` updated accordingly.
#'
#' @details
#' Expected Kontaktart type codes are:
#' \itemize{
#'   \item \code{"vorstationaer"}
#'   \item \code{"nachstationaer"}
#'   \item \code{"teilstationaer"}
#'   \item \code{"tagesklinik"}
#'   \item \code{"nachtklinik"}
#'   \item \code{"normalstationaer"}
#'   \item \code{"intensivstationaer"}
#'   \item \code{"ub"}
#'   \item \code{"konsil"}
#'   \item \code{"stationsaequivalent"}
#'   \item \code{"operation"}
#' }
#'
#' Any non-missing value of \code{enc_type_code_Kontaktart} that is not one of
#' these values is considered unexpected.
#'
#' @importFrom dplyr mutate if_else filter
#'
#' @export
CheckUnexpectedKontaktartCode <- function(encounter_table) {
  if (any((!encounter_table$enc_type_code_Kontaktart %in% c(
    "vorstationaer", "nachstationaer",
    "teilstationaer", "tagesklinik",
    "nachtklinik", "normalstationaer",
    "intensivstationaer", "ub", "konsil",
    "stationsaequivalent", "operation"
  )) &
    !is.na(encounter_table$enc_type_code_Kontaktart))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else((!enc_type_code_Kontaktart %in% c(
        "vorstationaer", "nachstationaer",
        "teilstationaer", "tagesklinik",
        "nachtklinik", "normalstationaer",
        "intensivstationaer", "ub", "konsil",
        "stationsaequivalent", "operation"
      )) &
        !is.na(enc_type_code_Kontaktart) &
        is.na(processing_exclusion_reason),
      "unexpected_kontaktart_code", processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter((!enc_type_code_Kontaktart %in% c(
        "vorstationaer", "nachstationaer",
        "teilstationaer", "tagesklinik",
        "nachtklinik", "normalstationaer",
        "intensivstationaer", "ub", "konsil",
        "stationsaequivalent", "operation"
      )) &
        !is.na(enc_type_code_Kontaktart)), width = Inf)
    warning("The encounter table contains type codes for Kontaktart with unexpected values.
            Please check the data.")
  }
  return(encounter_table)
}

#' Check for Multiple Einrichtungskontakt Encounter IDs per Identifier
#'
#' This function checks whether multiple encounter IDs (`enc_id`) exist for the
#' same encounter identifier value (`enc_identifier_value`) among encounters
#' classified as `"einrichtungskontakt"` on the Kontaktebene level.
#'
#' If multiple encounter IDs are found for the same identifier value, the function
#' assigns the processing exclusion reason
#' `"multiple_einrichtungskontakt_enc_ids_for_same_enc_identifier_value"` to the
#' affected encounters where no exclusion reason is already present and issues a
#' warning to inform the user about the data inconsistency.
#'
#' @param encounter_table A data frame containing encounter-level data. The table
#'   must include the columns `enc_id`, `enc_identifier_value`,
#'   `enc_type_code_Kontaktebene`, and `processing_exclusion_reason`.
#'
#' @return
#' A data frame with the same structure as `encounter_table`. For
#' `"einrichtungskontakt"` encounters that share the same
#' `enc_identifier_value` across multiple `enc_id` values, the
#' `processing_exclusion_reason` is updated accordingly.
#'
#' @details
#' The check is limited to encounters where
#' \code{enc_type_code_Kontaktebene == "einrichtungskontakt"}.
#'
#' If multiple rows are detected per `enc_identifier_value`, the function relies on
#' \code{checkMultipleRows()} to identify the condition and
#' \code{addMultipleRowsProcessingExclusionReason()} to assign the exclusion reason.
#'
#' @importFrom dplyr filter distinct right_join mutate if_else
#'
#' @export
CheckMultipleEinrichtungskontaktEncIdsForSameEncIdentifierValue <- function(encounter_table) {
  if (checkMultipleRows(
    (encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::distinct(enc_id, enc_identifier_value)),
    c("enc_identifier_value")
  )) {
    warning("Multiple enc_ids found for the same 'einrichtungskontakt' enc_identifier_value. Please check the data.")
    encounter_table <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::distinct(enc_id, enc_identifier_value, processing_exclusion_reason, enc_type_code_Kontaktebene) |>
      addMultipleRowsProcessingExclusionReason(
        c("enc_identifier_value"),
        "multiple_einrichtungskontakt_enc_ids_for_same_enc_identifier_value"
      ) |>
      dplyr::distinct(enc_identifier_value, processing_exclusion_reason, enc_type_code_Kontaktebene) |>
      dplyr::right_join(encounter_table, by = c("enc_identifier_value", "enc_type_code_Kontaktebene")) |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(processing_exclusion_reason.y),
        processing_exclusion_reason.x,
        processing_exclusion_reason.y
      ), .keep = "unused") |>
      dplyr::distinct()
  }
  return(encounter_table)
}

#' Check for Multiple Einrichtungskontakt Identifier Values per Encounter ID
#'
#' This function checks whether multiple encounter identifier values
#' (`enc_identifier_value`) are associated with the same encounter ID (`enc_id`)
#' for encounters classified as `"einrichtungskontakt"` on the Kontaktebene level.
#'
#' If more than one identifier value is found for the same `enc_id`, the function
#' assigns the processing exclusion reason
#' `"multiple_einrichtungskontakt_enc_identifier_values_for_same_enc_id"` to the
#' affected encounters where no exclusion reason is already present and issues a
#' warning to inform the user about the data inconsistency.
#'
#' @param encounter_table A data frame containing encounter-level data. The table
#'   must include the columns `enc_id`, `enc_identifier_value`,
#'   `enc_type_code_Kontaktebene`, and `processing_exclusion_reason`.
#'
#' @return
#' A data frame with the same structure as `encounter_table`. For
#' `"einrichtungskontakt"` encounters that have multiple
#' `enc_identifier_value` values associated with the same `enc_id`, the
#' `processing_exclusion_reason` is updated accordingly.
#'
#' @details
#' The check is restricted to encounters where
#' \code{enc_type_code_Kontaktebene == "einrichtungskontakt"}.
#'
#' Detection of multiple rows is performed using \code{checkMultipleRows()}.
#' The exclusion reason is assigned using
#' \code{addMultipleRowsProcessingExclusionReason()}.
#'
#' @importFrom dplyr filter distinct right_join mutate if_else
#'
#' @export

CheckMultipleEinrichtungskontaktEncIdentifierValuesForSameEncId <- function(encounter_table) {
  if (checkMultipleRows(
    (encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::distinct(enc_id, enc_identifier_value)),
    c("enc_id")
  )) {
    warning("Multiple enc_identifier_values found for the same 'einrichtungskontakt' enc_id. Please check the data.")
    encounter_table <- encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
      dplyr::distinct(enc_id, enc_identifier_value, processing_exclusion_reason, enc_type_code_Kontaktebene) |>
      addMultipleRowsProcessingExclusionReason(
        c("enc_id"),
        "multiple_einrichtungskontakt_enc_identifier_values_for_same_enc_id"
      ) |>
      dplyr::distinct(enc_id, processing_exclusion_reason, enc_type_code_Kontaktebene) |>
      dplyr::right_join(encounter_table, by = c("enc_id", "enc_type_code_Kontaktebene")) |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(processing_exclusion_reason.y),
        processing_exclusion_reason.x,
        processing_exclusion_reason.y
      ), .keep = "unused") |>
      dplyr::distinct()
  }
  return(encounter_table)
}

#' Check Encounters Without Calculated Parent Reference
#'
#' This function checks whether encounters that are *not* of Kontaktebene
#' `"einrichtungskontakt"` are missing a calculated parent encounter reference
#' (`enc_partof_calculated_ref`).
#'
#' For all encounters where `enc_type_code_Kontaktebene` is not
#' `"einrichtungskontakt"` and `enc_partof_calculated_ref` is `NA`, the function
#' prints the affected rows and issues a warning to highlight the potential data
#' inconsistency.
#'
#' The encounter table itself is not modified by this function; it is returned
#' unchanged.
#'
#' @param encounter_table A data frame containing encounter-level data. The table
#'   must include the columns `enc_type_code_Kontaktebene` and
#'   `enc_partof_calculated_ref`.
#'
#' @return
#' A data frame identical to `encounter_table`. The function performs validation
#' checks only and does not alter the data.
#'
#' @details
#' In hierarchical encounter structures, encounters other than
#' `"einrichtungskontakt"` are expected to reference a parent encounter. Missing
#' values in `enc_partof_calculated_ref` may indicate incomplete linkage or
#' errors in parent reference calculation.
#'
#' @importFrom dplyr filter
#'
#' @export
CheckEncountersWithoutCalculatedParentRef <- function(encounter_table) {
  if (any(!is.na(encounter_table$enc_type_code_Kontaktebene) &
    encounter_table$enc_type_code_Kontaktebene != "einrichtungskontakt" &
    is.na(encounter_table$enc_partof_calculated_ref))) {
    print(encounter_table |>
      dplyr::filter(enc_type_code_Kontaktebene != "einrichtungskontakt" &
        is.na(enc_partof_calculated_ref)), width = Inf)
    warning("Some encounters of type other than 'einrichtungskontakt' have no calculated parent
            reference. Please check the data.")
  }
  return(encounter_table)
}

#' Check Encounters Without Calculated Main Encounter Reference
#'
#' This function checks whether encounters are missing a calculated main
#' encounter reference (`enc_main_encounter_calculated_ref`).
#'
#' For encounters where `enc_main_encounter_calculated_ref` is `NA`, the function
#' assigns the processing exclusion reason
#' `"no_enc_main_encounter_calculated_ref"` if no exclusion reason has already
#' been set. The affected rows are printed and a warning is issued to signal that
#' the main encounter identifier (`main_enc_id`) cannot be determined.
#'
#' @param encounter_table A data frame containing encounter-level data. The table
#'   must include the columns `enc_main_encounter_calculated_ref` and
#'   `processing_exclusion_reason`.
#'
#' @return
#' A data frame identical to `encounter_table`, except that
#' `processing_exclusion_reason` is updated for encounters without a calculated
#' main encounter reference.
#'
#' @details
#' A calculated main encounter reference is required to derive a unique
#' `main_enc_id`. Missing values may indicate incomplete encounter hierarchies or
#' failures in earlier processing steps. Such encounters are flagged to prevent
#' downstream analyses from silently using incomplete data.
#'
#' @importFrom dplyr mutate filter if_else
#'
#' @export
CheckEncountersWithoutCalculatedMainEncounterRef <- function(encounter_table) {
  if (any(is.na(encounter_table$enc_main_encounter_calculated_ref))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(enc_main_encounter_calculated_ref) & is.na(processing_exclusion_reason),
        "no_enc_main_encounter_calculated_ref",
        processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter(is.na(enc_main_encounter_calculated_ref)), width = Inf)
    warning("Some encounters have no calculated main encounter reference, main_enc_id cannot be defined.
            Please check the data.")
  }
  return(encounter_table)
}

#' Check for Multiple Rows per Patient ID in FE Table
#'
#' This function checks whether the patient FE (Front-End) table contains
#' multiple rows for the same `pat_id` (FHIR identifier).
#'
#' If multiple rows are found for a `pat_id`, a warning is issued and the
#' `processing_exclusion_reason` column is updated with
#' `"multiple_rows_per_pat_id_in_fe"` for the affected rows.
#'
#' @param patient_fe_table A data frame containing patient-level FE data.
#'   The table must include the column `pat_id` and
#'   `processing_exclusion_reason`.
#'
#' @return
#' A data frame identical to `patient_fe_table`, with `processing_exclusion_reason`
#' updated for rows where multiple entries exist for the same `pat_id`.
#'
#' @details
#' Having multiple rows per `pat_id` may indicate duplicate records or data
#' inconsistencies. This function flags such cases to ensure downstream
#' analyses handle them appropriately.
#'
#' @importFrom dplyr mutate
#'
#' @export
CheckMultipleRowsPerPatIdInFe <- function(patient_fe_table) {
  if (checkMultipleRows(patient_fe_table, c("pat_id"))) {
    patient_fe_table <- patient_fe_table |>
      addMultipleRowsProcessingExclusionReason(c("pat_id"), "multiple_rows_per_pat_id_in_fe")
    warning("The patient_fe table contains multiple rows for the same pat_id(FHIR).
            Please check the data.")
  }
  return(patient_fe_table)
}


#' Check for Multiple Rows per Patient Identifier in FE Table
#'
#' This function checks whether the patient FE (Front-End) table contains
#' multiple rows for the same `pat_cis_pid` (CIS patient identifier).
#'
#' If multiple rows are found for a `pat_cis_pid`, a warning is issued and the
#' `processing_exclusion_reason` column is updated with
#' `"multiple_rows_per_pat_identifier_in_fe"` for the affected rows.
#'
#' @param patient_fe_table A data frame containing patient-level FE data.
#'   The table must include the columns `pat_cis_pid` and
#'   `processing_exclusion_reason`.
#'
#' @return
#' A data frame identical to `patient_fe_table`, with `processing_exclusion_reason`
#' updated for rows where multiple entries exist for the same `pat_cis_pid`.
#'
#' @details
#' Having multiple rows per `pat_cis_pid` may indicate duplicate records or data
#' inconsistencies. This function flags such cases to ensure downstream
#' analyses handle them appropriately.
#'
#' @importFrom dplyr mutate
#'
#' @export
CheckMultipleRowsPerPatIdentifierInFe <- function(patient_fe_table) {
  if (checkMultipleRows(patient_fe_table, c("pat_cis_pid"))) {
    patient_fe_table <- patient_fe_table |>
      addMultipleRowsProcessingExclusionReason(
        c("pat_cis_pid"),
        "multiple_rows_per_pat_identifier_in_fe"
      )
    warning("The patient_fe table contains multiple rows for the same patient identifier (cis).
            Please check the data.")
  }
  return(patient_fe_table)
}

#' Check for NA Values in Curated Encounter Period End
#'
#' This function checks whether the encounter table contains `NA` values
#' in the `curated_enc_period_end` column.
#'
#' If any `NA` values are found, a warning is issued and the function assigns a
#' processing exclusion reason `"NA_in_curated_enc_period_end"` for those rows.
#'
#' @param encounter_table_with_curated_enc_period_end A data frame containing
#'   encounter-level data. The table must include the column
#'   `curated_enc_period_end` and `processing_exclusion_reason`.
#'
#' @return
#' A data frame identical to `encounter_table_with_curated_enc_period_end`,
#' with `processing_exclusion_reason` updated for rows where
#' `curated_enc_period_end` is `NA`.
#'
#' @details
#' NA values in `curated_enc_period_end` indicate that the encounter end date
#' could not be determined or was missing in the source data. Flagging these
#' rows ensures downstream analyses handle such cases appropriately.
#'
#' @importFrom dplyr mutate filter
#'
#' @export
CheckNAInCuratedEncPeriodEnd <- function(encounter_table_with_curated_enc_period_end) {
  if (any(is.na(encounter_table_with_curated_enc_period_end$curated_enc_period_end))) {
    encounter_table_with_curated_enc_period_end <- encounter_table_with_curated_enc_period_end |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(is.na(curated_enc_period_end) &
        is.na(processing_exclusion_reason),
      "NA_in_curated_enc_period_end",
      processing_exclusion_reason
      ))
    print(
      encounter_table_with_curated_enc_period_end |>
        dplyr::filter(is.na(curated_enc_period_end)),
      width = Inf
    )
    warning("There are NA values in curated_enc_period_end. Please check the data.")
  }
  return(encounter_table_with_curated_enc_period_end)
}

# DEBUG Section ----------------------------------------------------------

DEBUG_TEST_REPORTING_WARNINGS <- FALSE

if (DEBUG_TEST_REPORTING_WARNINGS) {
  createPatientDataWarningsSituations <- function(patient_table) {
    multiple_rows_per_pat_id_check_system <- patient_table |>
      dplyr::slice(6) |>
      dplyr::mutate(pat_identifier_system = paste0(pat_identifier_system, "-test"))

    multiple_rows_per_pat_id_check_type_system <- patient_table |>
      dplyr::slice(7) |>
      dplyr::mutate(pat_identifier_type_system = paste0(pat_identifier_type_system, "-test"))

    multiple_rows_per_pat_id_check_type_code <- patient_table |>
      dplyr::slice(8) |>
      dplyr::mutate(pat_identifier_type_code = paste0(pat_identifier_type_code, "-test"))

    multiple_rows_per_pat_identifier_value_check <- patient_table |>
      dplyr::slice(9) |>
      dplyr::mutate(pat_id = paste0(pat_id, "-test"))

    check_patient_table <- multiple_rows_per_pat_id_check_system |>
      rbind(multiple_rows_per_pat_id_check_type_system) |>
      rbind(multiple_rows_per_pat_id_check_type_code) |>
      rbind(multiple_rows_per_pat_identifier_value_check)

    patient_table <- patient_table |>
      rbind(check_patient_table) |>
      dplyr::arrange(pat_id)

    return(patient_table)
  }

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
