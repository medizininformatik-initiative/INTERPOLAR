# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

# Reset error status
options(error = NULL)

start <- Sys.time()

if (exists("DEBUG_DAY") && !etlutils::isErrorOccured()) {
  cat("START DEBUG_DAY", DEBUG_DAY, "\n")
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
  } else if (!arg %in% c("--ignoreNewerDBVersion")) {
    stop("Unknown argument: ", arg, "\nAllowed arguments: --resetLock, --resetlockAndStop, --ignoreNewerDBVersion")
  }
}

resetMemory <- function(...) {
  etlutils::resetMemory(protected_objects = c(
    ...,
    "DEBUG_DAY",
    "DEBUG_DATES",
    "DEBUG_MODULES_PATH_TO_CONFIG_TOML",

    "DEBUG_DB_PORT",
    "DEBUG_REDCAP_PORT",
    "DEBUG_PATH_TO_RAW_RDATA_FILES",
    "DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME",
    "DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME",

    "DEBUG_SUBMODULE_DIR",
    "DEBUG_RUN_SINGLE_DAY_ONLY",
    "DEBUG_START_SINGLE_MODULE",

    "DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS",

    # Runtime variables from StartDebugCDSToolChain.R that should not be deleted
    "start_full",
    "day_times",
    "start_day",
    "debug_day_index"
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

# Initialize modules and validate configurations
resetMemory()
config_cds2db <- cds2db::init()
resetMemory("config_cds2db")
config_dataprocessor <- dataprocessor::init()

#TODO: Check if the parameters in config_cds2db and config_dataprocessor are compatible, e.g. if the encounter filter pattern in config_cds2db matches the expected ward definition in config_dataprocessor

resetMemory("config_cds2db", "config_dataprocessor")
config_db2frontend <- db2frontend::initFrontend2DB()
# checks needed config_cds2db or config_dataprocessor vs. config_db2frontend?
resetMemory("config_cds2db", "config_dataprocessor", "config_db2frontend")
config_frontend2db <- db2frontend::initDB2Frontend()
# checks needed config_cds2db or config_dataprocessor vs. config_frontend2db?
# config_frontend2db and config_db2frontend should be the same and should be checked vise versa during the init of one of these modules
resetMemory()

tryCatch({
  args <- commandArgs(trailingOnly = TRUE)
  ignore_newer_db_version = "--ignoreNewerDBVersion" %in% args
  if (shouldStart("cds2db")) {
    cds2db::retrieve(ignore_newer_db_version = ignore_newer_db_version, validate_config = FALSE)
  }
  if (shouldStart("db2frontend")) {
    db2frontend::startFrontend2DB(ignore_newer_db_version = ignore_newer_db_version, validate_config = FALSE)
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
  if (exists("DEBUG_DAY")) {
    cat("END DEBUG_DAY", DEBUG_DAY, "\n")
  } else {
    # Print the elapsed time
    end <- Sys.time()
    cat("Full toolchain took ", capture.output(print(end - start)), "\n")
  }
} else {
  status <- 1
}

if (!interactive() && !exists("DEBUG_DAY")) {
  quit(status = status, save = "no")
}
