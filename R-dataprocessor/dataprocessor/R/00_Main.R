#' Run submodules by sourcing all R scripts in each submodule directory, including Start.R
#'
#' This function iterates over the submodule directories in the package, sourcing all R scripts in the directory.
#' If a Start.R file is present, it will be sourced after all other R scripts in the submodule directory.
#'
#' If a manual submodule should be started independently, it must be specified as a command-line argument for the dataprocessor
#' using its name according to the manual_start subdirectory of the submodules directory.
#'
runSubmodules <- function() {

  # Get lists of submodule directories
  submodule_dirs <- list.dirs(DATAPROCESSOR_SUBMODULES_PATH, recursive = FALSE)
  manual_start_submodule_dirs <- list.dirs(DATAPROCESSOR_MANUAL_START_PATH, recursive = FALSE)

  command_line_args <- commandArgs(trailingOnly = TRUE)
  # for debug purposes set hard our new submodule MRP_Check
  # if (interactive()) {
  #   command_line_args <- c("mrp-check", "start-date=2025-12-01") # second parameter is irrelevant
  # }

  # Check if any submodule directories were specified in the command line arguments
  if (!interactive() || length(command_line_args)) {
    # enable minus for underscrore in arguments and ignore case
    command_line_args <- sub("-", "_", tolower(command_line_args), fixed = TRUE)
    called_manual_start_submodule_dirs <- manual_start_submodule_dirs[
      tolower(basename(manual_start_submodule_dirs)) %in% command_line_args]
    sourceAllSubmodules() # initialize all functions of all automatic submodules for a use in the now manual started submodule
  } else {
    called_manual_start_submodule_dirs <- as.character(c())
  }

  if (length(called_manual_start_submodule_dirs) > 0) {
    submodule_dirs <- called_manual_start_submodule_dirs
  }

  # if (dir.exists("./R-dataprocessor/submodules/01_Study_1a")) {
  #   submodule_dirs <- "./R-dataprocessor/submodules/01_Study_1a"
  # }
  # if (dir.exists("./R-dataprocessor/submodules/02_MRP_Calculation")) {
  #   submodule_dirs <- "./R-dataprocessor/submodules/02_MRP_Calculation"
  # }

  if (exists("DEBUG_SUBMODULE_DIR")) submodule_dirs <- DEBUG_SUBMODULE_DIR

  # Iterate over each submodule directory
  for (dir in submodule_dirs) {

    submodule_name <- basename(dir)
    etlutils::setSubmoduleName(submodule_name)

    # Source all R scripts in the directory
    etlutils::runLevel1(paste0("Run Dataprocessor submodule ", submodule_name), {

      # Load all submodule config.toml files
      submodule_config <- etlutils::initSubmoduleConstants(dir)
      # log all configuration parameters but hide value with parameter name starts with "FHIR_"
      etlutils::catList(submodule_config, "Submodule configuration:\n------------------------\n", "\n")

      # Source all R scripts in R subdirectory of an package project
      # and all R files in the subdirectory itself (but not Start.R)
      sourceSubmoduleRFiles(dir)

      # Check for Start.R and source it if exists
      start_script <- file.path(dir, "Start.R")
      if (file.exists(start_script)) {
        source(start_script)
      }

    })

    etlutils::removeSubmoduleName()

  }
}

#' Starts the Data Processor execution for this project
#'
#' This is the main entry point for the data processing pipeline. It initializes the
#' Data Processor module, resets any existing ETL lock, and triggers the creation
#' of frontend tables. If `reset_lock_only` is set to `TRUE`, the function only resets
#' the lock and exits without executing any further logic.
#'
#' @param reset_lock_only Logical. If TRUE, only resets the ETL lock and exits. Default is FALSE.
#'
#' @export
processData <- function(reset_lock_only = FALSE) {

  # Initialize and start module
  etlutils::startModule("dataprocessor",
                        path_to_toml = "./R-dataprocessor/dataprocessor_config.toml",
                        init_constants_only = reset_lock_only)

  if (reset_lock_only) {
    etlutils::dbResetLock()
    return()
  }

  # Check if the release version of the database is compatible
  etlutils::checkVersion()

  try(etlutils::runLevel1("Run Dataprocessor", {

    # Reset lock from unfinished previous dataprocessor run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    etlutils::runLevel2("Source function script", {
      source("./R-dataprocessor/dataprocessor/R/01_Shared_Functions.R")
      source("./R-dataprocessor/dataprocessor/R/02_Input_Files_Functions.R")
    })

    etlutils::runLevel2("Run dataprocessor submodules", {
      runSubmodules()
    })

  }))

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage()

  return(etlutils::finalize(finish_message))

}
