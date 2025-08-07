# Ein Patient
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1, Bett 1, bekommt Medikamente + Diagnose + Medikationsanalyse
# Tag 2: Versorgungsstellenkontakt wird entlassen

isDebugDay <- function(index) {
  if (exists("DEBUG_DAY")) {
    return(DEBUG_DAY == index)
  }
  return(FALSE)
}

getOffsetDateTime <- function(datetime = DEBUG_DATES[DEBUG_DAY], offset_days = 1) {
  datetime <- as.POSIXct(datetime)
  # Subtract the specified number of days from the given datetime
  return(datetime - offset_days * 86400)
}

loadDebugREDCapDataFromFile <- function(table_names) {
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

loadDebugREDCapData <- function() {
  debug_redcap_data_from_db <- list()
  if (isDebugDay(1)) {
    debug_redcap_data_from_db <- loadDebugREDCapDataFromFile(c("medikationsanalyse"))
  }
  return(debug_redcap_data_from_db)
}

changeDebugREDCapData <- function(redcap_tables) {
  #browser()
  if (isDebugDay(1)) {
    # Set the date of the Mediaktionsanylyse just before the end date of all MedicationRequests
    redcap_tables$medikationsanalyse$meda_dat <- getOffsetDateTime(DEBUG_DATES[DEBUG_DAY], 0.21)
    redcap_tables$medikationsanalyse$record_id <- redcap_tables$patient$record_id[1]
  }
  return(redcap_tables)
}
