#' Get Processed and Expanded MRP Definition Table
#'
#' This function loads a specific MRP (Medication-Related Problem) definition from an Excel file,
#' computes its content hash, and either returns a cached, already-processed version or processes
#' it using a dynamic cleaning/expansion function. The result is cached for future use.
#'
#' @param table_name Character. The base name of the Excel file (without file extension).
#' @param table_name_prefix Character. Prefix to use for identifying table variants. (Currently unused in function logic.)
#'
#' @return A data.table containing the processed and expanded MRP definition.
#'
getExpandedExcelContent <- function(table_name, table_name_prefix = "") {

  #path to the directory containing the MRP Excel files.
  table_dir <- file.path(INPUT_REPO_PATH, paste0(table_name_prefix, table_name))
  # Load the MRP definition from the Excel file
  columnnames <- getRelevantColumnNames(table_name)
  file_definition <- etlutils::readFirstExcelFileSheet(table_dir, table_name, columnnames)

  if (is.null(file_definition)) {
    stop(paste0("No or empty ", table_name, " excel file found in the specified path: ", table_dir))
  }
  # Compute the hash of the current MRP definition
  content_hash <- digest::digest(file_definition$excel_file_content, algo = "sha256")
  file_name <- file_definition$excel_file_name
  content <- file_definition$excel_file_content
  processed_content_hash <- getStoredProcessedContentHash(content_hash, table_dir)

  if (is.null(processed_content_hash)) {
    # If the hash is not found, process the MRP definition
    process_content_function_name <- paste0("processExcelContent", gsub("_", "", table_name))
    if (exists(process_content_function_name, mode = "function")) {
      process_content_function <- get(process_content_function_name, mode = "function")
      processed_content <- process_content_function(file_definition$excel_file_content, table_name)
    } else {
      processed_content <- file_definition$excel_file_content
    }
    processed_content_hash <- digest::digest(processed_content, algo = "sha256")

    output_dir <- file.path(table_dir, paste0(table_name, "_content"))
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    file_path_part <- paste0(table_dir, "/", table_name, "_content")

    # Write content and processed content to Excel files
    openxlsx::write.xlsx(content, file = file.path(file_path_part,
                                                   paste0(table_name, "_", table_name_prefix, "Table.xlsx")), overwrite = TRUE)
    openxlsx::write.xlsx(processed_content, file = file.path(file_path_part,
                                                             paste0(table_name, "_", table_name_prefix, "Table_processed.xlsx")), overwrite = TRUE)

    # Load or init storage tables locally
    input_data_files_path <- paste0(table_dir, "/input_data_files.RData")
    input_data_files_processed_path <- paste0(table_dir, "/input_data_files_processed_content.RData")

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
      lock_id = "Write input data files to database")

  } else {
    # Load processed content
    #TODO: Replace with database functionality
    input_data_files_processed_content <- readRDS(paste0(table_dir, "/input_data_files_processed_content.RData"))
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
