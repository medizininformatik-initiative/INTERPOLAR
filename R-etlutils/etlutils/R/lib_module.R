#' #' Store Finish Data in a Log File
#' #'
#' #' This function records log messages, error messages, and error status
#' #' into an `.RData` file stored in the `Input-Repo` directory. It appends
#' #' new log entries to an existing log file or creates a new log file if it
#' #' does not exist.
#' #'
#' #' @details
#' #' - The function ensures that the directory `Input-Repo` exists.
#' #' - It retrieves the module name using `dbGetModuleName()`.
#' #' - If an existing log file (`finish_data.RData`) is found, it is loaded.
#' #' - A new log entry is created with the provided message details.
#' #' - The log entry is appended to the existing data while avoiding duplicates.
#' #' - The updated log data is saved back to the `.RData` file.
#' #'
#' #' @param log_message A character string containing the log message.
#' #' @param log_error_message A character string containing the error message (if applicable).
#' #'
#' #' @return This function does not return a value. It saves log data as a side effect.
#' #'
#' storeFinishData <- function(log_message, log_error_message) {
#'
#'   module_log <- data.table::data.table(
#'     module_name = as.character(dbGetModuleName()),
#'     message = as.character(log_message),
#'     error_message = as.character(log_error_message),
#'     timestamp =  as.POSIXctWithTimezone(Sys.time())
#'   )
#'   #dbWriteTable(module_log, lock_id = "storeFinishData()")
#'
#'   #TODO: Delete
#'   dir_path <- "./Input-Repo"
#'   file_path <- file.path(dir_path, "module_log.RData")
#'
#'   # Create directory if it does not exist
#'   if (!dir.exists(dir_path)) {
#'     dir.create(dir_path, recursive = TRUE)
#'   }
#'
#'   # Load existing file if it exists; otherwise, initialize an empty table
#'   if (file.exists(file_path)) {
#'     finish_data <- readRDS(file_path)  # Loads `finish_data`
#'     module_log <- data.table::rbindlist(list(finish_data, module_log), fill = TRUE)
#'   }
#'
#'   # Save the updated data table back to file
#'   saveRDS(module_log, file = file_path)
#' }
