if (exists("DEBUG_DAY")) {

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    etlutils::dbReset()
    pats <- c("UKB-0001") # present at day 1
  } else{
    if (DEBUG_DAY == 2) {
      pats <- c("UKB-0001") # still there
    } else if (DEBUG_DAY == 3) {
      pats <- c("UKB-0001")  # still there
    } else if (DEBUG_DAY == 4) {
      pats <- c() # discharged
    }
    # Load all encounters from the database which, according to the database,
    # have not yet ended on the 'current' date and determine the PIDs.
    # Background: We want to track all cases that have ever been on a relevant
    # station until they are completed. So if a patient is discharged, we still
    # want to track the case until it is completed.
    patient_ids_db <- etlutils::getAfterLastSlash(getActiveEncounterPIDsFromDB())

    pats <- unique(c(pats, patient_ids_db))
  }

  pats <- namedListByValue(pats)

  #resource_tables <- retainRAWTables("Patient", "Encounter")
  resource_tables <- getFilteredRAWResources(pats)
  # short reference to Encounter table
  dt_enc <- resource_tables[["Encounter"]]
  dt_pat <- resource_tables[["Patient"]]

  # Identify columns starting with "enc_diagnosis_" and "enc_servicetype_" as
  # vector of column names
  colnames_pattern_diagnosis <- "^enc_diagnosis_"
  colnames_pattern_servicetype <- "^enc_servicetype_"
  enc_diagnosis_cols <- grep(colnames_pattern_diagnosis, names(dt_enc), value = TRUE)
  enc_servicetype_cols <- grep(colnames_pattern_servicetype, names(dt_enc), value = TRUE)

  # Remove multiple diagnoses to prevent splitting the main encounter to multiple
  # lines after fhir_melt (= set first value before " ~ " and remove the rest)
  dt_enc[, (enc_diagnosis_cols) := lapply(.SD, function(x) sub(" ~ .*", "", x)), .SDcols = enc_diagnosis_cols]

  # set the enc_period_start of all encounters of a patient to the current date
  # minus an offset
  for (i in c(1:5)) {
    changeDataForPID(dt_enc, paste0("UKB-000", i), "enc_period_start", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = i))
  }

  ### Add encounters with type "Versorgungstellenkontakt" ###

  # Find rows where enc_id ends with -A-<NUMBER> (= Abteilungskontakt)
  pattern <- "-A-(\\d+)$"
  rows_to_duplicate <- dt_enc[grepl(pattern, enc_id)] # extract all Abteilungskontakt rows

  # Duplicate and modify enc_id
  if (nrow(rows_to_duplicate) > 0) {

    # Set correct partof reference to the Abteilungskontakt for every new created
    # Versorgungsstellenkontakt (same value as the still existing Abteilungskontakt
    # enc_id of the row)
    rows_to_duplicate <- rows_to_duplicate[, enc_partof_ref := sub("(Encounter/).*", paste0("\\1", sub(".*]", "", enc_id)), enc_partof_ref)]

    # Extract the number at the end of the enc_id and append "-V-<number>" to
    # create a new unique enc_id for every Versorgungsstellenkontakt
    rows_to_duplicate[, enc_id := sub(pattern, "-A-\\1-V-\\1", enc_id)]

    # Replace enc_type_code abteilungskontakt with versorgungsstellenkontakt but
    # keep the leading index in the brackets
    rows_to_duplicate[, enc_type_code := sub("\\](.*)", "]versorgungsstellenkontakt", enc_type_code)]

    # Replace enc_type_display Abteilungskontakt with Versorgungsstellenkontakt
    # but keep the leading index in the brackets
    rows_to_duplicate[, enc_type_display := sub("\\](.*)", "]Versorgungsstellenkontakt", enc_type_display)]

    # Delete Fachabteilungsschlüssel
    rows_to_duplicate[, (enc_servicetype_cols) := NA]

    # Add room and bed as two new locations
    rows_to_duplicate[, enc_location_physicaltype_code := "[1.1.1.1]ro ~ [2.1.1.1]bd"]
    rows_to_duplicate[, enc_location_identifier_value := paste0("[1.1.1.1]Raum", .I, " ~ [2.1.1.1]Bett ", .I)]

    # Append the new Versorgungsstellenkontakt rows to the Encounter table
    dt_enc <- rbind(dt_enc, rows_to_duplicate)
  }

  if (DEBUG_DAY == 1) {

    # Set all encounter to "in-progress", delete end date and diagnoses and set
    # the encounter last updated date to the current date with a small offset
    for (i in seq_along(pats)) {
      # Encounter
      changeDataForPID(dt_enc, pats[[i]], "enc_status", "in-progress")
      changeDataForPID(dt_enc, pats[[i]], "enc_period_end", NA)
      changeDataForPID(dt_enc, pats[[i]], colnames_pattern_diagnosis, NA)
      changeDataForPID(dt_enc, pats[[i]], "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.1))
      # Patient
      changeDataForPID(dt_pat, pats[[i]], "pat_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.1))
    }

  } else if (DEBUG_DAY == 2) {

    # Patient 1: unchanged Encounter to day 1
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_status", "in-progress")
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_end", NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.1))
    # Patient 1: changed Patient to day 1
    changeDataForPID(dt_pat, pats$`UKB-0001`, "pat_name_given", "[1.1]Alex")
    changeDataForPID(dt_pat, pats$`UKB-0001`, "pat_gender", "[1]divers")
    changeDataForPID(dt_pat, pats$`UKB-0001`, "pat_birthdate", "[1]1976-02-02")
    changeDataForPID(dt_pat, pats$`UKB-0001`, "pat_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[2], offset_days = 0.2))

  } else if (DEBUG_DAY == 3) {

    # Patient 1: not in the data anymore (left the ward) and the existing
    # diagnosis from the loaded RAW data is not removed
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_end", getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.6))
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.1))

  } else if (DEBUG_DAY == 4) {

  }

  # All Versorgungsstellenkontakte must be added to the pids_per_ward table in order to also receive
  # the information for rooms and bed
  pids_per_wards <- resource_tables$pids_per_ward
  dt_enc_2 <- dt_enc[, c("enc_id", "enc_partof_ref")]
  dt_enc_2 <- fhircrackr::fhir_rm_indices(dt_enc_2, brackets = c("[", "]"))
  dt_enc_2 <- dt_enc_2[, enc_partof_ref := getAfterLastSlash(enc_partof_ref)]
  # Merge the tables to get the rows with referenced encounters
  merged <- merge(pids_per_wards, dt_enc_2, by.x = "encounter_id", by.y = "enc_partof_ref", all.x = TRUE)
  # Duplicate the rows: Create new rows and replace encounter_id with the corresponding enc_id
  new_rows <- merged[, .(patient_id, encounter_id = enc_id, ward_name)]
  # Remove duplicates that already exist in pids_per_wards
  new_rows <- new_rows[!encounter_id %in% pids_per_wards$encounter_id]
  # Add the new rows to the original pids_per_wards table
  pids_per_wards <- rbind(pids_per_wards, new_rows)

  # Update the Encounter table in the resource_tables list
  resource_tables[["Encounter"]] <- dt_enc
  resource_tables[["Patient"]] <- dt_pat
  resource_tables[["pids_per_ward"]] <- pids_per_wards
}
