#' Initializes the module context for dataprocessor.
#'
#' This function initializes the module context for the dataprocessor module by loading
#' the necessary configuration parameters from a specified TOML file and setting up
#' the module environment. It ensures that all mandatory parameters are present and
#' can optionally validate the configuration values.
#'
#' @param validate_config Logical. If TRUE, validates the module configuration
#' after initialization. Default is TRUE.
#'
#' @return A list containing the module configuration parameters loaded from the
#' TOML file and initialized in the module context. This list will be used for the
#' execution of the module and contains all necessary parameters for the ETL process.
#'
#' @export
init <- function(validate_config = TRUE) {
  # Initialize and start module if init_constants_only == FALSE
  config <- etlutils::initModule(
    "dataprocessor",
    path_to_toml = "./R-dataprocessor/dataprocessor_config.toml",
    defaults = list(
      VERBOSE = 10,
      MAX_DIR_COUNT = 5,
      FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM = ".*",
      FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM = ".*",
      FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE = ".*",
      MEDICAL_CASE_ID_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM = ""
    ),
    mandatory_parameters = c(
      "PHASES_WARD",
      "OBSERVATION_BODY_WEIGHT_SYSTEM",
      "OBSERVATION_BODY_WEIGHT_CODES",
      "OBSERVATION_BODY_HEIGHT_SYSTEM",
      "OBSERVATION_BODY_HEIGHT_CODES",
      "OBSERVATION_BMI_SYSTEM",
      "OBSERVATION_BMI_CODES",
      "SITE_CODE",
      "INPUT_REPO_PATH",
      "PATH_TO_DB_CONFIG_TOML"
    )
  )
  if (validate_config) {
    validateWardPhases()
    validateSiteCode(config[["SITE_CODE"]])
  }
  return(config)
}

#' Resets the database lock.
#'
#' Resets the database lock, if this module has set a lock in a previous run and
#' the lock was not reset due to an error or interruption. This allows to run
#' the module again after fixing the error without having to wait for the lock
#' to expire.
#'
#' @export
resetLock <- function() {
  init(validate_config = FALSE)
  etlutils::dbResetLock()
}

#' Run submodules by sourcing all R scripts in each submodule directory, including Start.R
#'
#' This function iterates over the submodule directories in the package, sourcing all R scripts in the directory.
#' If a Start.R file is present, it will be sourced after all other R scripts in the submodule directory.
#'
#' If a manual submodule should be started independently, it must be specified as a command-line argument for the dataprocessor
#' using its name according to the manual_start subdirectory of the submodules directory.
#'
runSubmodules <- function(command_line_args = NULL) {
  # Get lists of submodule directories
  submodule_dirs <- list.dirs(DATAPROCESSOR_SUBMODULES_PATH, recursive = FALSE)
  manual_start_submodule_dirs <- list.dirs(DATAPROCESSOR_MANUAL_START_PATH, recursive = FALSE)

  if (is.null(command_line_args)) {
    command_line_args <- commandArgs(trailingOnly = TRUE)
  }
  # # for debug purposes set hard our new submodule MRP_Check
  # if (interactive()) {
  #   command_line_args <- c("mrp-check", "start-date=2025-12-01") # second parameter is irrelevant
  # }

  # Check if any submodule directories were specified in the command line arguments.
  # Manual-start submodules also need the functions of the automatic submodules
  # when they are started interactively via DEBUG_SUBMODULE_DIR.
  if (!interactive() || length(command_line_args) || exists("DEBUG_SUBMODULE_DIR")) {
    # enable minus for underscrore in arguments and ignore case
    called_manual_start_submodule_dirs <- getCalledManualStartSubmoduleDirs(
      command_line_args,
      manual_start_submodule_dirs
    )
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

startDataprocessorModule <- function(
  validate_config = TRUE,
  command_line_args = NULL
) {
  config <- init(validate_config)
  configureManualStartDatabase(config, command_line_args)
  etlutils::startModule(config)
  config
}

sourceDataprocessorSubmodules <- function(ignore_newer_db_version = FALSE,
                                          source_submodule_functions = FALSE) {
  etlutils::runLevel2("Reset database lock from unfinished previous run", {
    etlutils::dbResetLock()
    etlutils::checkVersion(ignore_newer_db_version)
  })

  if (source_submodule_functions) {
    etlutils::runLevel2("Source dataprocessor submodule functions", {
      sourceAllSubmodules()
    })
  }
}

#' Starts the Data Processor execution for this project
#'
#' This is the main entry point for the data processing pipeline. It initializes the
#' Data Processor module, selects the database for a manually started project,
#' resets any existing ETL lock and runs the selected submodules.
#'
#' @param ignore_newer_db_version Logical. If `TRUE`, allows a database version
#'   newer than the release version. Default is `FALSE`.
#' @param validate_config Logical. If `TRUE`, validates the module configuration
#'   before starting the retrieval process. Default is `TRUE`.
#' @param command_line_args Optional character vector of command-line arguments.
#'   Defaults to `commandArgs(trailingOnly = TRUE)`.
#'
#' @export
processData <- function(
  ignore_newer_db_version = FALSE,
  validate_config = TRUE,
  command_line_args = NULL
) {
  # Initialize and start module
  startDataprocessorModule(validate_config, command_line_args)

  try(etlutils::runLevel1("Run Dataprocessor", {
    sourceDataprocessorSubmodules(ignore_newer_db_version)

    etlutils::runLevel2("Run dataprocessor submodules", {
      runSubmodules(command_line_args)
    })
  }))

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage()

  return(etlutils::finalize(finish_message))
}
