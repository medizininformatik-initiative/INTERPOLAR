#' Retrieve Git Branch and Commit Information
#'
#' This function reads the `.git/HEAD` file and resolves the current branch name and commit hash.
#' It supports both symbolic references (e.g., pointing to a branch) and detached HEAD states.
#'
#' @param git_dir Character. Path to the `.git` directory. Defaults to the current directory's `.git`.
#'
#' @return Invisibly returns a list with elements `branch` and `commit`, and prints them to the console along with the current time.
#'
getGitInfo <- function(git_dir = ".git") {
  tryCatch({
    # Path to HEAD file
    head_path <- file.path(git_dir, "HEAD")
    if (!file.exists(head_path)) {
      stop("HEAD file not found. Is this a valid .git directory?")
    }
    head_content <- readLines(head_path, warn = FALSE)
    # Check if HEAD points to a ref or is a detached commit
    if (grepl("^ref:", head_content)) {
      ref_rel_path <- sub("^ref: ", "", head_content)
      ref_path <- file.path(git_dir, ref_rel_path)
      if (!file.exists(ref_path)) {
        stop("Reference file not found: ", ref_path)
      }
      commit_id <- readLines(ref_path, warn = FALSE)
      branch_name <- basename(ref_rel_path)
    } else {
      commit_id <- head_content
      branch_name <- "-"
    }

    info <- paste0(
      "Branch: ", branch_name, "\n",
      "Commit: ", commit_id, "\n",
      "Current Time: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n"
    )

    return(info)

  }, error = function(e) {
    paste0("Git info could not be retrieved: ", e$message, "\n")
  })
}

#' Initialize Module Context
#'
#' @param module_name A character string specifying the name of the module.
#' @param db_schema_base_name The base name of the database schema. If NULL the
#' module name is used.
#' @param path_to_toml (Optional) A character string specifying the path to the
#' TOML configuration file. Default is `NA`.
#' @param mandatory_parameters (Optional) A character vector containing the names
#' of mandatory parameters. If these parameters are not found in the configuration
#' file, an error is thrown.
#'
#' @export
initModule <- function(module_name, db_schema_base_name = NULL, path_to_toml = NA, mandatory_parameters = c()) {
  # Init module constants
  config <- initModuleConstants(
    module_name = module_name,
    db_schema_base_name = db_schema_base_name,
    path_to_toml = path_to_toml
  )
  # Check for mandatory parameters
  checkMandatoryParameters(mandatory_parameters)
}

#' Start Module Execution (logging and directories)
#'
#' @param config A list containing the module configuration parameters. This is typically
#' the output of `initModuleConstants()` which initializes the module context and loads
#' the configuration from a TOML file. The `config` object should contain all necessary
#' parameters for the module execution, and it will be logged at the start of the module run.
#' @param hide_value_pattern (Optional) A character string pattern used to hide
#' certain values in the logged configuration output. Default is `""`.
#'
#' @export
startModule <- function(config, hide_value_pattern = "") {
  # Create necessary directories
  createDIRS(MODULE_NAME) # MODULE_NAME is set in initModuleConstants
  # Create globally used process clock
  createClock()
  # Start logging console outputs
  startLogging(MODULE_NAME)
  # Log github active tag and branch
  cat("\n---------------------------\nGithub Script Version:\n---------------------------\n")
  cat(getGitInfo())
  # Log all configuration parameters, optionally hiding values based on the pattern
  catList(config, prefix = "\n---------------------------\nConfiguration:\n---------------------------\n", suffix = "\n", hide_value_pattern)
}

#' Store Finish Data in a Log File
#'
#' This function records log messages, error messages, and error status
#' into an `.RData` file stored in the `Input-Repo` directory. It appends
#' new log entries to an existing log file or creates a new log file if it
#' does not exist.
#'
#' @details
#' - The function ensures that the directory `Input-Repo` exists.
#' - It retrieves the module name using `dbGetModuleName()`.
#' - If an existing log file (`finish_data.RData`) is found, it is loaded.
#' - A new log entry is created with the provided message details.
#' - The log entry is appended to the existing data while avoiding duplicates.
#' - The updated log data is saved back to the `.RData` file.
#'
#' @param finish_message A character string containing the log message.
#' @param error_message A character string containing the error message (if applicable).
#'
#' @return This function does not return a value. It saves log data as a side effect.
#'
storeFinishData <- function(finish_message, error_message) {

  module_log <- data.table::data.table(
    module_name = as.character(dbGetModuleName()),
    message = as.character(finish_message),
    error_message = as.character(error_message),
    timestamp =  as.POSIXctWithTimezone(Sys.time())
  )

  dir_path <- "./outputLocal"
  file_path <- file.path(dir_path, "module_log.RData")

  # Create directory if it does not exist
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }

  # Load existing file if it exists; otherwise, initialize an empty table
  if (file.exists(file_path)) {
    finish_data <- readRDS(file_path)  # Loads `finish_data`
    module_log <- data.table::rbindlist(list(finish_data, module_log), fill = TRUE)
  }

  # Save the updated data table back to file
  saveRDS(module_log, file = file_path)
}
