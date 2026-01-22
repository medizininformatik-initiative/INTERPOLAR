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

args <- commandArgs(trailingOnly = TRUE)
for (arg in args) {
  if (arg %in% c("--resetLock", "--resetLockAndStop")) {
    message("Resetting lock")
    cds2db::retrieve(reset_lock_only = TRUE)
    dataprocessor::processData(reset_lock_only = TRUE)
    db2frontend::startDB2Frontend(reset_lock_only = TRUE)
    message("All locks resettet")
    if (arg == "--resetLockAndStop") {
      quit(status = 0, save = "no")  # clean exit without error
    }
  } else if (!arg %in% c("--ignoreNewerDBVersion")) {
    stop("Unknown argument: ", arg, "\nAllowed arguments: --resetLock, --resetlockAndStop, --ignoreNewerDBVersion")
  }
}

resetMemory <- function() {
  rm(list = setdiff(ls(), c(
    "DEBUG_DAY",
    "DEBUG_DATES",
    "DEBUG_MODULES_PATH_TO_CONFIG_TOML",

    "DEBUG_PATH_TO_RAW_RDATA_FILES",
    "DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME",

    "DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME",

    "DEBUG_SUBMODULE_DIR",
    "DEBUG_RUN_SINGLE_DAY_ONLY",
    "DEBUG_START_SINGLE_MODULE",

    "DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS"
  )))
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
    if (exists("DEBUG_START_SINGLE_MODULE") && DEBUG_START_SINGLE_MODULE == module_name) {
      resetMemory()
      setDebugPathToConfigToml(module_name)
      return(TRUE)
    } else if (!exists("DEBUG_START_SINGLE_MODULE")) {
      resetMemory()
      setDebugPathToConfigToml(module_name)
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  return(FALSE)
}

# Check if the release version of the database is compatible
etlutils::checkVersion(ingnore_newer_db_version = "--ignoreNewerDBVersion" %in% args)

tryCatch({
  if (shouldStart("cds2db")) {
    cds2db::retrieve()
  }
  if (shouldStart("db2frontend")) {
    db2frontend::startFrontend2DB()
  }
  if (shouldStart("dataprocessor")) {
    dataprocessor::processData()
  }
  if (shouldStart("db2frontend")) {
    db2frontend::startDB2Frontend()
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
