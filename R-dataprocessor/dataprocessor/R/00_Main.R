#' Run submodules by sourcing the Start.R script or all R scripts in each submodule directory
#'
#' This function iterates over the submodule directories in the package,
#' sourcing the Start.R file if present. If no Start.R file is found, it
#' sources all R scripts in the directory.
#'
runSubmodules <- function() {

  # Path to the submodules directory
  submodule_path <- system.file("submodules", package = "dataprocessor")

  # Get list of submodule directories
  submodule_dirs <- list.dirs(submodule_path, recursive = FALSE)

  # Iterate over each submodule directory
  for (dir in submodule_dirs) {
    start_script <- file.path(dir, "Start.R")
    submodule_name <- basename(dir)

    # If Start.R exists, source it
    if (file.exists(start_script)) {
      etlutils::runLevel1(paste0("Run Dataprocessor submodule ", submodule_name), {
        source(start_script)
      })
    } else {
      etlutils::runLevel1(paste0("Source submodule scripts in ", submodule_name), {
        # Otherwise, source all R scripts in the directory
        scripts <- list.files(dir, pattern = "\\.R$", full.names = TRUE)

        for (script in scripts) {
          source(script)
        }
      })
    }
  }
}

#'
#'
#' Starts the retrieval for this project. This is the main start function start the Data Processor
#' job
#'
#' @export
processData <- function() {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- "./R-dataprocessor/dataprocessor_config.toml"
  config <- etlutils::initConstants(path2config_toml,
                          c(MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE = 30,

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

                          ))

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Set the project name to 'dataprocessor'
  PROJECT_NAME <<- "dataprocessor"
  ###

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
      runSubmodules()
      closeAllDatabaseConnections()
  }))

  if (etlutils::isErrorOccured()) {
    finish_message <- "Module 'dataprocessor' finished with errors (see details above).\n"
    finish_message <- paste0(finish_message, etlutils::getErrorMessage())
  } else {
    finish_message <- "Module 'dataprocessor' finished with no errors.\n"
  }

  etlutils::finalize(finish_message)

}
