#' Validate ATC Codes in Multiple Columns
#'
#' This function checks whether the values in specified columns of a data table
#' are valid ATC7 codes and issues warnings for any invalid values.
#'
#' @param data A data table containing the columns to validate.
#' @param columns A character vector specifying the column names to check for ATC7 validity.
#'
#' @details The function filters out \code{NA} values and validates each value in the specified
#' columns using \code{etlutils::isATC7}. If invalid ATC7 codes are found, a warning is issued
#' for each column.
#'
#' @return This function does not return any value. It issues warnings for invalid codes.
#'
#' @examples
#' library(data.table)
#' drug_disease_mrp_definition <- data.table(
#'   ATC = c("A01AB07", "INVALID", NA),
#'   ATC_PROXY = c(NA, "WRONG", "B03AA02")
#' )
#' validateATCCodes(drug_disease_mrp_definition, c("ATC", "ATC_PROXY"))
#'
#' @export
validateATCCodes <- function(data, columns) {
  errors <- list()
  for (column in columns) {
    invalid_codes <- data[[column]][!etlutils::isATC7orSmaller(data[[column]]) & !is.na(data[[column]])]
    if (length(invalid_codes) > 0) {
      errors[[column]] <- invalid_codes
    }
  }
  return(errors)
}

#' Validate LOINC Codes in a Column
#'
#' This function validates whether all non-NA values in a specified column of a data table
#' conform to the standard LOINC format.
#'
#' @param data A data.table containing the column to validate.
#' @param column_name The name of the column to check for valid LOINC codes.
#'
#' @details A valid LOINC code matches the pattern `^\d{1,5}-\d$`:
#' - 1 to 5 digits
#' - Followed by a hyphen (`-`)
#' - Ending with exactly 1 digit.
#'
#' If invalid codes are found, the function will issue a warning with the invalid codes.
#'
#' @return The function does not return any value but will issue a warning
#' if invalid LOINC codes are found in the column.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   LOINC = c("12345-6", "67890-1", "INVALID", NA, "12321", "21312123-1")
#' )
#' validateLOINCCodes(dt, "LOINC")
#' # Warning: The following codes in column 'LOINC' are not valid LOINC codes: INVALID
#'
#' @export
validateLOINCCodes <- function(data, column_name) {
  column_values <- data[[column_name]]
  invalid_codes <- column_values[!etlutils::isLOINC(column_values) & !is.na(column_values)]
  if (length(invalid_codes) > 0) {
    return(setNames(list(invalid_codes), column_name))
  } else {
    return(list())
  }
}

#' Get Processed and Expanded MRP Definition Table
#'
#' This function loads a specific MRP (Medication-Related Problem) definition from an Excel file,
#' computes its content hash, and either returns a cached, already-processed version or processes
#' it using a dynamic cleaning/expansion function. The result is cached for future use.
#'
#' @param mrp_type A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A data.table containing the processed and expanded MRP definition.
#'
getExpandedContent <- function(mrp_type) {

  #path to the directory containing the MRP Excel files.
  path_to_mrp_tables <- file.path(MRP_PAIR_PATH, paste0("MRP_", mrp_type))

  # Load the MRP definition from the Excel file
  mrp_columnnames <- getPairListColumnNames(mrp_type)
  mrp_definition <- etlutils::readFirstExcelFileSheet(path_to_mrp_tables, mrp_type, mrp_columnnames)
  if (is.null(mrp_definition)) {
    stop(paste0("No or empty ", mrp_type, " MRP definition table found in the specified path: ", path_to_mrp_tables))
  }
  # Compute the hash of the current MRP definition
  content_hash <- digest::digest(mrp_definition$excel_file_content, algo = "sha256")
  file_name <- mrp_definition$excel_file_name
  content <- mrp_definition$excel_file_content
  processed_content_hash <- getStoredProcessedContentHash(content_hash, path_to_mrp_tables)

  if (is.null(processed_content_hash)) {
    # If the hash is not found, process the MRP definition
    processed_content <- getMRPTypeFunction("cleanAndExpandDefinition", mrp_type)(mrp_definition$excel_file_content)
    processed_content_hash <- digest::digest(processed_content, algo = "sha256")

    output_dir <- file.path(path_to_mrp_tables, paste0(mrp_type, "_content"))
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    file_path_part <- paste0(path_to_mrp_tables, "/", mrp_type, "_content")

    # Write content and processed content to Excel files
    openxlsx::write.xlsx(content, file = file.path(file_path_part,
                                                   paste0(mrp_type, "_MRP_Table.xlsx")), overwrite = TRUE)
    openxlsx::write.xlsx(processed_content, file = file.path(file_path_part,
                                                             paste0(mrp_type, "_MRP_Table_processed.xlsx")), overwrite = TRUE)

    # Load or init storage tables locally
    input_data_files_path <- paste0(path_to_mrp_tables, "/input_data_files.RData")
    input_data_files_processed_path <- paste0(path_to_mrp_tables, "/input_data_files_processed_content.RData")

    if (file.exists(input_data_files_path)) {
      input_data_files <- readRDS(input_data_files_path)
    } else {
      input_data_files <- data.table::data.table()
    }

    if (file.exists(input_data_files_processed_path)) {
      input_data_files_processed_content <- readRDS(input_data_files_processed_path)
    } else {
      input_data_files_processed_content <- data.table::data.table()
    }

    # Convert content and processed_content to base64-encoded serialized data
    content <- base64enc::base64encode(serialize(content, NULL))
    processed_content_serialized <- base64enc::base64encode(serialize(processed_content, NULL))

    new_input_data_file_row <- data.table::data.table(
      file_name = file_name,
      content_hash = content_hash,
      content = content,
      processed_content_hash = processed_content_hash
    )
    input_data_files <- rbind(
      input_data_files,
      new_input_data_file_row,
      use.names = TRUE,
      fill = TRUE
    )
    new_input_data_file_processed_content_row <- data.table::data.table(
      processed_content_hash = processed_content_hash,
      processed_content = processed_content_serialized
    )
    input_data_files_processed_content <- rbind(
      input_data_files_processed_content,
      new_input_data_file_processed_content_row,
      use.names = TRUE,
      fill = TRUE
    )

    # Save the updated data tables back to the RData file
    saveRDS(input_data_files, input_data_files_path)
    saveRDS(input_data_files_processed_content, input_data_files_processed_path)

    # Save the updated data tables back to the database
    etlutils::dbWriteTables(
      tables = etlutils::namedListByParam(input_data_files, input_data_files_processed_content),
      lock_id = "Write input data files to database",
      stop_if_table_not_empty = TRUE)

  } else {
    # Load processed content
    #TODO: Replace with database functionality
    input_data_files_processed_content <- readRDS(paste0(path_to_mrp_tables, "/input_data_files_processed_content.RData"))
    matching_row <- input_data_files_processed_content[processed_content_hash == get("processed_content_hash")]
    processed_content <- unserialize(base64enc::base64decode(matching_row$processed_content))
  }

  # Return both processed content and hash
  return(list(
    processed_content = processed_content,
    processed_content_hash = processed_content_hash
  ))
}

#' Retrieve Stored Processed Content Hash from Input Data File Table
#'
#' This function loads the input data file metadata table and returns the
#' corresponding `processed_content_hash` for a given `target_hash`, if available.
#'
#' @param target_hash A character string representing the content hash to look up.
#' @param table_path A character string representing the table path of the MRP definition.
#'
#' @return A character string containing the processed content hash if found; otherwise `NULL`.
#'
getStoredProcessedContentHash <- function(target_hash, table_path) {
  file_path <- paste0(table_path, "/input_data_files.RData")
  if (file.exists(file_path)) {
    input_data_files <- readRDS(file_path)
    matching_row <- input_data_files[content_hash == target_hash]
    if (nrow(matching_row)) {
      return(matching_row$processed_content_hash)
    }
  }
  return(NULL)
}

#' Format code-related error messages for display
#'
#' Takes a named list of validation errors per column and creates a character vector of formatted
#' error messages that can be displayed to the user or logged. If no errors are provided, an empty
#' character vector is returned.
#'
#' @param error_list A named list where each element contains a character vector of error messages
#'   for a specific column.
#' @param code_type_label A character string indicating the type of codes being validated (e.g.,
#'   "diagnosis", "procedure").
#'
#' @return A character vector of formatted error messages. If \code{error_list} is empty, an empty
#'   character vector is returned.
#'
#' @examples
#' errors <- list(
#'   diagnosis = c("Invalid format", "Unknown code"),
#'   procedure = c("Missing value")
#' )
#' formatCodeErrors(errors, "input")
#'
#' empty_errors <- list()
#' formatCodeErrors(empty_errors, "output")
#'
#' @export
formatCodeErrors <- function(error_list, code_type_label) {
  if (length(error_list) == 0) return(character())

  messages <- c(sprintf("The following errors were found in %s codes:", code_type_label))
  for (col in names(error_list)) {
    messages <- c(messages,
                  sprintf("  Column '%s': %s", col, paste(error_list[[col]], collapse = ", ")))
  }
  return(messages)
}

#' Filter active MedicationRequests for an encounter within a specific time window
#'
#' @param medication_requests A \code{data.table} of MedicationRequest resources. Must contain columns \code{medreq_encounter_ref} and \code{medreq_authoredon}.
#' @param enc_period_start POSIXct. The start datetime of the encounter period.
#' @param meda_datetime POSIXct. The datetime of the medication analysis (cutoff point).
#'
#' @return A \code{data.table} with filtered active medication requests for the given encounter and time range.
#'
#' @export
getActiveMedicationRequests <- function(medication_requests, enc_period_start, meda_datetime) {

  active_requests <- medication_requests[
    !is.na(start_date) &
      start_date >= enc_period_start &
      start_date <= meda_datetime &
      (is.na(end_date) |
         end_date >= meda_datetime)
  ]
  atc_codes <- active_requests[, c("atc_code")]
  return(atc_codes)
}
