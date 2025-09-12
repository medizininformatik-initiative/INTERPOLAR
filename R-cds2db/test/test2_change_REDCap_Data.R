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
  return(exists("DEBUG_DAY") && (is.null(index) || DEBUG_DAY == index))
}

if (isDebugDay()) {
  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  template <- loadDebugREDCapDataTemplatesFromFile(c("medikationsanalyse"))$medikationsanalyse

  getRecordID <- function(pid) {
    data_to_import$patient$record_id[which(data_to_import$patient$pat_id == pid)][1]
  }

  getPatientIdsByLevel <- function(last_index, duplicate_level = 1) {
    ids <- data_to_import$patient$pat_id
    underscore_counts <- stringr::str_count(ids, "_")
    pattern <- paste0("_", last_index, "$")
    matching_ids <- ids[underscore_counts == duplicate_level & grepl(pattern, ids)]
  }

  dt_pat_ids <- getPatientIdsByLevel(DEBUG_DAY)

  for (pid in dt_pat_ids) {
    # Clean and add correct medication analysis datetime
    meda_datetime <- getDebugDatesRAWDateTime(-1.5)
    meda_datetime_cleaned <- sub("^\\[.*?\\]", "", meda_datetime)
    template$meda_dat <- lubridate::ymd_hms(meda_datetime_cleaned)
    # set the record_id in the template based on the current patient id
    template$record_id <- getRecordID(pid)
    # join with the encounter table to populate fall_meda_id in the template
    template[data_to_import$fall, on = "record_id", fall_meda_id := i.fall_id]
    # count how many entries already exist in "medikationsanalyse" for this fall_meda_id
    count <- data_to_import$medikationsanalyse[fall_meda_id == template$fall_meda_id, .N]
    # create a new meda_id by appending "-(count + 1)" to the fall_meda_id
    template[, meda_id := paste0(fall_meda_id, "-", count + 1)]
    # append the updated template row into the "medikationsanalyse" table
    data_to_import[["medikationsanalyse"]] <- rbind(data_to_import[["medikationsanalyse"]], template)
  }

}
