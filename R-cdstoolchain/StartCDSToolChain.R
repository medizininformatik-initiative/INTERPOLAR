# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

DEBUG_DATES <- c("2025-03-05 13:55:45 CET",
                 "2025-03-06 13:55:45 CET")

# Reset error status
options(error = NULL)

for (i in seq_along(DEBUG_DATES)) {
  DEBUG_DAY <- i

  if (!etlutils::isErrorOccured()) {
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
      # here. The hard stop here would message the error again in
      # an inappropriate way.
      #stop(e)  # Abort on other errors
    }
  })
  if (!etlutils::isErrorOccured()) {
    cat("END DEBUG_DAY", DEBUG_DAY, "\n")
  }
}

#'
#' Loads all tables from subdirectory 'tables' of the last directory
#' in the given tale_path.
#'
loadTables <- function(table_path, name_pattern = NA) {
  table_names <- list.files(path = table_path, pattern = ".\\.RData$")
  if (!is.na(name_pattern)) {
    table_names <- table_names[grep(name_pattern, table_names, ignore.case = TRUE)]
  }
  tables <- list()
  for (table_name in table_names) {
    full_table_path <- paste0(table_path, table_name)
    table <- try(readRDS(full_table_path), silent = TRUE)
    if (data.table::is.data.table(table)) {
      tables <- append(tables, list(table))
      names(tables)[length(tables)] <- gsub("\\.RData$", "", table_name)
    }
  }
  return(tables)
}

#tables <- loadTables("./outputLocal/db2frontend/tables/")
