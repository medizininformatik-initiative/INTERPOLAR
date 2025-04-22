#' Initialize and Start a Module
#'
#' This function initializes the module by setting up necessary constants,
#' creating required directories, starting a process clock, and logging configuration details.
#' It ensures that the module environment is properly configured before execution.
#'
#' @param module_name A character string specifying the name of the module.
#' @param path_to_toml (Optional) A character string specifying the path to the
#' TOML configuration file. Default is `NA`.
#' @param hide_value_pattern (Optional) A character string pattern used to hide
#' certain values in the logged configuration output. Default is `""`.
#' @param mandatory_parameters (Optional) A character vector containing the names
#' of mandatory parameters. If these parameters are not found in the configuration
#' file, an error is thrown.
#' @param init_constants_only A logical value indicating whether only module constants
#' should be initialized (`TRUE`) or if the full module setup (including directory creation,
#' logging, and process clock initialization) should be performed (`FALSE`).
#'
#' @details
#' - Initializes module-specific constants using `initModuleConstants()`.
#' - Creates necessary directories using `createDIRS()`, if `init_constants_only = FALSE`.
#' - Initializes a global process clock using `createClock()`, if `init_constants_only = FALSE`.
#' - Starts logging all console outputs using `startLogging()`, if `init_constants_only = FALSE`.
#' - Logs all configuration parameters while optionally hiding values that match `hide_value_pattern`.
#'
#' @return This function does not return a value. It performs setup operations as a side effect.
#'
#' @export
startModule <- function(module_name, path_to_toml = NA, hide_value_pattern = "", mandatory_parameters = c(), init_constants_only) {
  # Init module constants
  config <- initModuleConstants(
    module_name = module_name,
    path_to_toml = path_to_toml
  )

  if(!init_constants_only) {
    # Check for mandatory parameters
    checkMandatoryParameters(mandatory_parameters)
    # Create necessary directories
    createDIRS(module_name)
    # Create globally used process clock
    createClock()
    # Start logging console outputs
    startLogging(module_name)
    # Log github active tag and branch
    cat("\n---------------------------\nGithub Script Version:\n---------------------------\n")
    cat("Tag: ", system("git describe --tags", intern = TRUE), "\n")
    cat("Branch: ", system("git branch --show-current", intern = TRUE), "\n")
    cat("Current Time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
    # Log all configuration parameters, optionally hiding values based on the pattern
    catList(config, prefix = "\n---------------------------\nConfiguration:\n---------------------------\n", suffix = "\n", hide_value_pattern)
  }
}

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
