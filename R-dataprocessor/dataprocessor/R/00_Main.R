#' Run submodules by sourcing all R scripts in each submodule directory, including Start.R
#'
#' This function iterates over the submodule directories in the package, sourcing all R scripts in the directory.
#' If a Start.R file is present, it will be sourced after all other R scripts in the submodule directory.
#'
runSubmodules <- function() {

  # Path to the submodules directory
  #submodule_path <- system.file("submodules", package = "dataprocessor")
  submodule_path <- "./R-dataprocessor/submodules"

  # Get list of submodule directories
  submodule_dirs <- list.dirs(submodule_path, recursive = FALSE)

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
      submodule_subdirs <- list.dirs(dir, recursive = FALSE)
      for (subdir in submodule_subdirs) {
        subdir_rpath <- paste0(subdir, "/R")
        if (dir.exists(subdir_rpath)) {
          r_scripts <- list.files(subdir_rpath, pattern = "\\.R$", full.names = TRUE)
          for (script in r_scripts) {
            source(script)
          }
        }
      }

      # Source all R files in the subdirectory itself (but not Start.R)
      r_scripts <- list.files(dir, pattern = "\\.R$", full.names = TRUE)
      for (script in r_scripts) {
        # Source each R script except Start.R
        if (basename(script) != "Start.R") {
          source(script)
        }
      }

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

  try(etlutils::runLevel1("Run Dataprocessor", {

    # Reset lock from unfinished previous dataprocessor run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    etlutils::runLevel2("Source function script", {
      source("./R-dataprocessor/dataprocessor/R/01_Shared_Functions.R")
      source("./R-dataprocessor/dataprocessor/R/02_MRP_Functions.R")
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
