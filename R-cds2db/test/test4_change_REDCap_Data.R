loadDebugREDCapDataTemplatesFromFile <- function(table_names) {
  debug_redcap_data_from_db <- list()
  files <- list.files(DEBUG_PATH_TO_REDCAP_RDATA_FILES, pattern = "_redcap\\.RData$", full.names = TRUE)
  names(files) <- sub(paste0("^", DEBUG_PATH_TO_REDCAP_RDATA_FILES, "/(.*?)_redcap\\.RData$"), "\\1", files)
  # Filter files to keep only those whose names are in table_names
  files <- files[names(files) %in% table_names]
  for (i in seq_along(files)) {
    debug_redcap_data_from_db[[names(files)[i]]] <- readRDS(files[i])
  }
  return(debug_redcap_data_from_db)
}

isDebugDay <- function(index = NULL) {
  return(exists("DEBUG_DAY") && !is.null(index) && DEBUG_DAY == index)
}





if (isDebugDay()) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  #DEBUG_PATH_TO_REDCAP_RDATA_FILES <- "./R-cds2db/test/tables/"
  templates <- loadDebugREDCapDataTemplatesFromFile(c("medikationsanalyse"))

  if (isDebugDay(1)) {
    data_to_import[["medikationsanalyse"]] <- templates["medikationsanalyse"]
    templates$medikationsanalyse
    # Set the date of the Mediaktionsanylyse just before the end date of all MedicationRequests
    redcap_tables$medikationsanalyse$meda_dat <- getOffsetDateTime(DEBUG_DATES[DEBUG_DAY], 0.21)
    redcap_tables$medikationsanalyse$record_id <- redcap_tables$patient$record_id[1]
  } else if (isDebugDay(2)) {
  } else if (isDebugDay(3)) {
  } else if (isDebugDay(4)) {
  } else if (isDebugDay(5)) {
  } else if (isDebugDay(6)) {
  } else if (isDebugDay(7)) {
  } else if (isDebugDay(8)) {
  }

}
