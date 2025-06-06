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
  } else {
    stop("Unknown argument: ", arg, "\nAllowed arguments: --resetLock, --resetlockAndStop")
  }
}

resetMemory <- function() {
  rm(list = setdiff(ls(), c("DEBUG_DAY", "DEBUG_DATES")))
}

tryCatch({
  if (!etlutils::isErrorOccured()) {
    resetMemory()
    cds2db::retrieve()
  }
  if (!etlutils::isErrorOccured()) {
    resetMemory()
    db2frontend::startFrontend2DB()
  }
  if (!etlutils::isErrorOccured()) {
    resetMemory()
    dataprocessor::processData()
  }
  if (!etlutils::isErrorOccured()) {
    resetMemory()
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
      stop(e)  # Abort on other errors
    }
  }
})

if (!etlutils::isErrorOccured()){
  if (exists("DEBUG_DAY")) {
    cat("END DEBUG_DAY", DEBUG_DAY, "\n")
  } else {
    # Print the elapsed time
    end <- Sys.time()
    cat("Full toolchain took ", capture.output(print(end - start)), "\n")
  }
}
