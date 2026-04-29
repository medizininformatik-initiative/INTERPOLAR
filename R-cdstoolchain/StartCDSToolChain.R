library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

etlutils::setProcess("FullToolchain")

# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")


# Reset error status
options(error = NULL)

start_full <- Sys.time()

if (exists("TOOLCHAIN_DAY") && !etlutils::isErrorOccured()) {
  cat("START TOOLCHAIN_DAY", TOOLCHAIN_DAY, "\n")
}

# Process command line arguments
# Currently supported arguments:
# --resetLock: Resets all locks and continues with the execution. This is useful if
#              a lock is set due to an error or interruption in a previous run and
#              you want to run the toolchain again after fixing the error without
#              waiting for the lock to expire.
# --resetLockAndStop: Resets all locks and stops the execution. This is useful
#                     if a lock is set due to an error or interruption in a previous
#                     run and you want to reset the lock after fixing the error
#                     without waiting for the lock to expire, but you don't want to
#                     run the toolchain again immediately.
# --ignoreNewerDBVersion: Ignores if the database version is newer than the
#                         release version. This is useful if you are running the
#                         toolchain with a newer database version than the release
#                         version and you want to ignore the check for compatibility.
#                         Use this with caution, as it may lead to unexpected errors
#                         if the database version is not compatible with the toolchain.
args <- commandArgs(trailingOnly = TRUE)
for (arg in args) {
  if (arg %in% c("--resetLock", "--resetLockAndStop")) {
    message("Resetting lock")
    cds2db::resetLock()
    dataprocessor::resetLock()
    db2frontend::resetLockFrontend2DB()
    db2frontend::resetLockDB2Frontend()
    message("All locks resettet")
    if (arg == "--resetLockAndStop") {
      quit(status = 0, save = "no")  # clean exit without error
    }
  } else if (!arg %in% c("--ignoreNewerDBVersion", "--ignoreWardNameMismatch")) {
    warning("Unknown argument: ", arg, "\nAllowed arguments: --resetLock, --resetlockAndStop, --ignoreNewerDBVersion")
  }
}

resetMemory <- function(...) {
  etlutils::resetMemory(protected_objects = c(
    ...,

    "TOOLCHAIN_DAY",
    "DEBUG_DATES",
    "DEBUG_MODULES_PATH_TO_CONFIG_TOML",

    "DEBUG_DB_PORT",
    "DEBUG_REDCAP_PORT",
    "DEBUG_REDCAP_TOKEN",
    "DEBUG_PATH_TO_RAW_RDATA_FILES",

    "DEBUG_SUBMODULE_DIR",
    "DEBUG_RUN_SINGLE_DAY_ONLY",
    "DEBUG_START_SINGLE_MODULE",
    "DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME",
    "DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME",

    "CLEAR_DATABASE_AND_REDCAP_ON_TOOLCHAIN_DAY_1",

    "DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS",

    # Runtime variables from StartDebugCDSToolChain.R that should not be deleted
    "start_full",
    "day_times",
    "start_day",
    "debug_day_index",
    "delete_db_and_redcap",

    # Module configurations
    "config_cds2db",
    "config_dataprocessor",
    "config_db2frontend",
    "config_frontend2db"
  ))
}

setDebugPathToConfigToml <- function(module_name) {
  # DEBUG_MODULES_PATH_TO_CONFIG_TOML can contain for every module a path to
  # a config file. If the path is not set, then only the default config file
  # is used and no default values are overwritten by the debug config file.
  if (exists("DEBUG_MODULES_PATH_TO_CONFIG_TOML") && module_name %in% names(DEBUG_MODULES_PATH_TO_CONFIG_TOML)) {
    DEBUG_PATH_TO_CONFIG_TOML <- DEBUG_MODULES_PATH_TO_CONFIG_TOML[[module_name]]
  }
}

shouldStart <- function(module_name) {
  if (!etlutils::isErrorOccured()) {
    if (!exists("DEBUG_START_SINGLE_MODULE") ||
        (exists("DEBUG_START_SINGLE_MODULE") && identical(DEBUG_START_SINGLE_MODULE, module_name))) {
      resetMemory()
      setDebugPathToConfigToml(module_name)
      return(TRUE)
    }
  }
  return(FALSE)
}

# This function checks if the ward names defined in the encounter filter patterns in config_cds2db
# match the ward names defined in the PHASES_WARD definitions in config_dataprocessor. If there is a
# mismatch, it throws an error with details about the mismatch.
validateConfigs <- function() {

  args <- commandArgs(trailingOnly = TRUE)
  if ("--ignoreWardNameMismatch" %in% args) {
    etlutils::catWarningMessage("Ignoring ward name mismatch between config_cds2db and config_dataprocessor due to --ignoreWardNameMismatch argument.")
    return()
  }

  encounter_filter_patterns_wards <- etlutils::getVariablesByPrefix("ENCOUNTER_FILTER_PATTERN", envir = config_cds2db)
  phases_wards <- etlutils::getVariablesByPrefix("PHASES_WARD", envir = config_dataprocessor)

  getWardNames <- function(x) {
    pattern <- "^\\s*ward_name\\s*=\\s*'([^']*)'\\s*$"
    vals <- unlist(x, use.names = FALSE)
    matches <- vals[grepl(pattern, vals)]
    sub(pattern, "\\1", matches)
  }

  ward_names_cds2db <- getWardNames(encounter_filter_patterns_wards)
  ward_names_dataprocessor <- getWardNames(phases_wards)

  # Validate that both ward name vectors contain exactly the same elements
  if (!setequal(ward_names_cds2db, ward_names_dataprocessor)) {
    stop(
      paste0(
        "Mismatch between ward names in ENCOUNTER_FILTER_PATTERN in 'cds2db_config.toml' and PHASES_WARD definitions in 'dataprocessor_config.toml'. Please fix and restart process.",
        "\n  Only in ENCOUNTER_FILTER_PATTERN: ",
        paste(setdiff(ward_names_cds2db, ward_names_dataprocessor), collapse = ", "),
        "\n  Only in PHASES_WARD: ",
        paste(setdiff(ward_names_dataprocessor, ward_names_cds2db), collapse = ", "),
        "\n  If this should be ignored, the start the toolchain with the argument --ignoreWardNameMismatch (use with caution, as it may lead to unexpected errors if the ward names are not compatible between the modules)."
      )
    )
  }
}

# Initialize modules and validate configurations
resetMemory()
config_cds2db <- cds2db::init()
resetMemory()
config_dataprocessor <- dataprocessor::init()
resetMemory()
config_db2frontend <- db2frontend::initFrontend2DB()
# checks needed config_cds2db or config_dataprocessor vs. config_db2frontend?
resetMemory()
config_frontend2db <- db2frontend::initDB2Frontend() # should be the same like config_db2frontend

# Check if the parameters in config_cds2db and config_dataprocessor are compatible, e.g. if the encounter
# filter pattern in config_cds2db matches the expected ward definition in config_dataprocessor
validateConfigs()
resetMemory()

delete_db_and_redcap <- etlutils::isDefinedAndTrue("CLEAR_DATABASE_AND_REDCAP_ON_TOOLCHAIN_DAY_1") && exists("TOOLCHAIN_DAY") && TOOLCHAIN_DAY == 1

tryCatch({
  args <- commandArgs(trailingOnly = TRUE)
  ignore_newer_db_version = "--ignoreNewerDBVersion" %in% args
  if (shouldStart("cds2db")) {
    if (delete_db_and_redcap && !etlutils::isDefinedAndTrue("DEBUG_DONT_DELETE_DB_DATA")) {
      etlutils::dbReset()
    }
    # the dataprocessors validator ensures that there is exact 1 ward name and 1 phase_a_start defined for each ward in the PHASES_WARD definitions.
    # Therefore, we can safely assume that the length of the vectors is the same and the order is the same, so we can use the ward names and
    # phase_a_start values in the same order for both modules.
    ward_names <- etlutils::extractVariablesListValues("PHASES_WARD", "ward_name", config_dataprocessor)
    phase_a_starts <- etlutils::extractVariablesListValues("PHASES_WARD", "phase_a_start", config_dataprocessor)
    # set the ward names for the phase_a_start values to get the map from ward_name to it's phase a start date
    names(phase_a_starts) <- ward_names
    cds2db::retrieve(phase_a_starts, ignore_newer_db_version = ignore_newer_db_version, validate_config = isProcess("DataImport"))
  }
  if (shouldStart("db2frontend")) {
    db2frontend::startFrontend2DB(ignore_newer_db_version = ignore_newer_db_version, validate_config = FALSE, delete_redcap_content = delete_db_and_redcap)
  }
  if (shouldStart("dataprocessor")) {
    dataprocessor::processData(ignore_newer_db_version = ignore_newer_db_version, validate_config = FALSE)
  }
  if (shouldStart("db2frontend")) {
    db2frontend::startDB2Frontend(ignore_newer_db_version = ignore_newer_db_version, validate_config = FALSE)
  }
  if (etlutils::isErrorOccured()) {
    stop(etlutils::getErrorMessage())
  }
}, error = function(e) {
  # Split the error message into individual lines
  error_lines <- unlist(strsplit(e$message, "\n"))

  # Define the pattern for SQL column errors
  allowed_pattern <- "column .* of relation .* does not exist"

  # Check if any of the lines contain the pattern
  if (any(grepl(allowed_pattern, error_lines))) {
    message("Ignoring expected error: ", e$message)

    # Execute `next` only if not in the last iteration of the loop
    if (i < length(DEBUG_DATES)) {
      next
    }
  } else {
    # the submodules log their errors itself -> we must check
    # if etlutils::isErrorOccured() and if TRUE then do nothing
    # here. Stop hard only if the error comes not from a submodule.
    if (!etlutils::isErrorOccured()) {
      etlutils::catErrorMessage(e$message)
      quit(status = 1, save = "no")  # Abort with error
    }
  }
})

if (!etlutils::isErrorOccured()) {
  status <- 0
  if (exists("TOOLCHAIN_DAY")) {
    cat("END TOOLCHAIN_DAY", TOOLCHAIN_DAY, "\n")
  } else {
    # Print the elapsed time
    end_full <- Sys.time()
    cat("Full toolchain took ", capture.output(print(end_full - start_full)), "\n")
  }
} else {
  status <- 1
}

if (!interactive() && etlutils::isProcess("FullToolchain")) {
  quit(status = status, save = "no")
}
