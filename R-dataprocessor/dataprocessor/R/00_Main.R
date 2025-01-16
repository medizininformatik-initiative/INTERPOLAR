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
#' @param debug_path_to_config_toml Debug parameter for loading an optional debug config.toml file
#'
#' @export
processData <- function(debug_path_to_config_toml = NA) {
  ###
  # Read the module configuration toml file.
  ###
  config <- etlutils::initModuleConstants(
    module_name <- "dataprocessor",
    path_to_toml = "./R-dataprocessor/dataprocessor_config.toml",
    defaults = c(
      MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE = 30,

      # default medication resource should be MedicationRequest and its
      # timestamps
      MEDICATION_REQUEST_RESOURCE = "MedicationRequest",
      MEDICATION_REQUEST_RESOURCE_ENCOUNTER_REFERENCE_COLUMN_NAME = "medreq_encounter_id",
      MEDICATION_REQUEST_RESOURCE_MEDICATION_REFERENCE_COLUMN_NAME = "medreq_medicationreference_id",
      MEDICATION_REQUEST_RESOURCE_TIMESTAMP_COLUMN_NAME = "medreq_doseinstruc_timing_event",
      MEDICATION_REQUEST_RESOURCE_PERIOD_START_COLUMN_NAME = "medreq_doseinstruc_timing_repeat_boundsperiod_start",
      MEDICATION_REQUEST_RESOURCE_PERIOD_END_COLUMN_NAME = "medreq_doseinstruc_timing_repeat_boundsperiod_end",

      # The default for the FHIR 'system', the 'type/coding/system' and
      # 'type/coding/code' of the PID entry in the frontend
      # result table for patients are empty strings, so all Identifiers
      # found in the FHIR data will be displayed in the frontend tables
      # (multiple values will be separated by semicolon)
      FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM = "",
      FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM = "",
      FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE = ""
    )
  )

  etlutils::createDIRS(PROJECT_NAME)

  ###
  # Create globally used process_clock
  ###
  etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::startLogging(PROJECT_NAME)

  # log all configuration parameters but hide value with parameter name starts with "FHIR_"
  etlutils::catList(config, "Configuration:\n--------------\n", "\n", "^FHIR_")

  try(etlutils::runLevel1("Run Dataprocessor", {

    # Reset lock from unfinished previous dataprocessor run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
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

  if (etlutils::isErrorOccured()) {
    finish_message <- "Module 'dataprocessor' finished with errors (see details above).\n"
    finish_message <- paste0(finish_message, etlutils::getErrorMessage())
  } else {
    finish_message <- "Module 'dataprocessor' finished with no errors.\n"
  }

  etlutils::finalize(finish_message)

}
