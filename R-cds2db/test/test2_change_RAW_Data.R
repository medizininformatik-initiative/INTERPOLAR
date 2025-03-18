#browser()

if (exists("DEBUG_DAY")) {

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    etlutils::dbReset()
    pats <- c("UKB-0001")
  } else{
    if (DEBUG_DAY == 2) {
      pats <- c("UKB-0001")
    } else if (DEBUG_DAY == 3) {
      pats <- c("UKB-0001")
    } else if (DEBUG_DAY == 4) {
      pats <- c()
    }
    # Load all encounters from the database which, according to the database, have not yet ended on the
    # ‘current’ date and determine the PIDs.
    # Background: We want to track all cases that have ever been on a relevant station until they are completed.
    patient_ids_db <- etlutils::getAfterLastSlash(getActiveEncounterPIDsFromDB())

    pats <- unique(c(pats, patient_ids_db))
  }

  pats <- namedListByValue(pats)

  #resource_tables <- retainRAWTables("Patient", "Encounter")
  resource_tables <- getFilteredRAWResources(pats)
  # short reference to Encounter table
  dt_enc <- resource_tables[["Encounter"]]

  colnames_pattern_diagnosis <- "^enc_diagnosis_"
  colnames_pattern_servicetype <- "^enc_servicetype_"

  # Identify columns starting with "enc_diagnosis_"
  enc_diagnosis_cols <- grep("^enc_diagnosis_", names(dt_enc), value = TRUE)
  # Identify columns starting with "enc_diagnosis_"
  enc_servicetype_cols <- grep("^enc_servicetype_", names(dt_enc), value = TRUE)
  # Set first value before " ~ " and remove the rest
  dt_enc[, (enc_diagnosis_cols) := lapply(.SD, function(x) sub(" ~ .*", "", x)), .SDcols = enc_diagnosis_cols]

  for (i in c(1:5)) {
    changeDataForPID(dt_enc, paste0("UKB-000", i), "enc_period_start", getFormattedRAWDateTime(offset_days = i))
  }

  ### Add encounters with type "Versorgungstellenkontakt" ###

  # Find rows where enc_id ends with -A-<NUMBER> (= Abteilungskontakt)
  pattern <- "-A-(\\d+)$"

  rows_to_duplicate <- dt_enc[grepl(pattern, enc_id)]

  # Duplicate and modify enc_id
  if (nrow(rows_to_duplicate) > 0) {
    # Extract the number at the end and append "-V-<number>"
    rows_to_duplicate[, enc_id := sub(pattern, "-A-\\1-V-\\1", enc_id)]

    # Replace enc_type_code only in duplicated rows
    rows_to_duplicate[, enc_type_code := sub("\\](.*)", "]versorgungsstellenkontakt", enc_type_code)]

    # Replace enc_type_display only in duplicated rows
    rows_to_duplicate[, enc_type_display := sub("\\](.*)", "]Versorgungsstellenkontakt", enc_type_display)]

    browser()

    # Delete Fachabteilungsschlüssel
    rows_to_duplicate[, (enc_servicetype_cols) := NA]

    # Add room and bed
    rows_to_duplicate[, enc_location_physicaltype_code := "[1.1.1.1]ro ~ [1.2.1.1]bd"]
    rows_to_duplicate[, enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [1.2.1.1]Bett 2"]

    # Append new rows to dt_enc
    dt_enc <- rbind(dt_enc, rows_to_duplicate)
  }

  if (DEBUG_DAY == 1) {

    # Set all encounter to "in-progress" and delete end date
    for (i in seq_along(pats)) {
      changeDataForPID(dt_enc, pats[[i]], "enc_status", "in-progress")
      changeDataForPID(dt_enc, pats[[i]], "enc_period_end", NA)
      changeDataForPID(dt_enc, pats[[i]], "enc_diagnosis_cols", NA)
      changeDataForPID(dt_enc, pats[[i]], "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.1))
    }

  } else if (DEBUG_DAY == 2) {

    # Patient 1: unverändert zu Tag 1
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_status", "in-progress")
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_end", NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.1))

  } else if (DEBUG_DAY == 3) {

    # Patient 1: ist nicht mehr in den Daten (hat Station verlassen)
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_end", getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.6))
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.1))

  } else if (DEBUG_DAY == 4) {

  }

  resource_tables[["Encounter"]] <- dt_enc
}
