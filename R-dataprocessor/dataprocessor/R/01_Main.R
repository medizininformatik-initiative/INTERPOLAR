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
  }
}

#' Starts the retrieval for this project. This is the main start function start the Data Processor
#' job
#'
#' @export
processData <- function() {

  # Initialize and start module
  etlutils::startModule("dataprocessor",
                        path_to_toml = "./R-dataprocessor/dataprocessor_config.toml")

  try(etlutils::runLevel1("Run Dataprocessor", {

    # Reset lock from unfinished previous dataprocessor run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    etlutils::runLevel2("Source function script", {
      source("./R-dataprocessor/dataprocessor/R/00_Functions.R")
    })

    etlutils::runLevel2("Run dataprocessor submodules", {
      runSubmodules()
    })

  }))

  try(etlutils::runLevel1(paste("Finishing", PROJECT_NAME), {
    etlutils::runLevel2("Close database connections", {
      etlutils::dbCloseAllConnections()
    })
  }))

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage(PROJECT_NAME)

  etlutils::finalize(finish_message)

}
