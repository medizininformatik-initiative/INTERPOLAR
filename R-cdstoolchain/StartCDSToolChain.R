# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

# Reset error status
options(error = NULL)

if (exists("DEBUG_DAY") && !etlutils::isErrorOccured()) {
  cat("START DEBUG_DAY", DEBUG_DAY, "\n")
}

tryCatch({
  if (!etlutils::isErrorOccured()) {
    cds2db::retrieve()
  }
  if (!etlutils::isErrorOccured()) {
    dataprocessor::processData()
  }
  if (!etlutils::isErrorOccured()) {
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

if (exists("DEBUG_DAY") && !etlutils::isErrorOccured()) {
  cat("END DEBUG_DAY", DEBUG_DAY, "\n")
}
