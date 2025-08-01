# Zwei Patienten
# Tag 1: Je einen Versorgungsstellenkontakt auf Station 1
# Tag 2: Patient 1 bleibt unverändert auf Station 1. Patient 2 wird auf nicht-IP Station verlegt.
# Tag 3: Beide Patienten werden entlassen
if (exists("DEBUG_DAY")) {

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    etlutils::dbReset()
    pats <- c("UKB-0001", "UKB-0002") # present at day 1
  } else{
    pats <- c("UKB-0001", "UKB-0002")
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

  # Remove diagnoses
  dt_enc[, (enc_diagnosis_cols) := NA]

  # set the enc_period_start of all encounters of a patient to the current date
  # minus an offset
  for (i in c(1:2)) {
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

    # Append the new Versorgungsstellenkontakt rows to the Encounter table
    dt_enc <- rbind(dt_enc, rows_to_duplicate)
  }

  if (DEBUG_DAY %in% c(1:3)) {
    # Set all encounter to "in-progress", delete end date and diagnoses and set
    # the encounter last updated date to the current date with a small offset
    # Set the patient last updated date to the current date with a small offset
    # Set enc_location_identifier_value for the Versorgungsstellenkontakt (Raum 1, Bett 1)
    # Change pids_per_wards to the correct encounter id and ward name (Station 1)
    for (i in seq_along(pats)) {
      # Encounter
      changeDataForPID(dt_enc, pats[[i]], "enc_status", "in-progress")
      changeDataForPID(dt_enc, pats[[i]], "enc_period_end", NA)
      changeDataForPID(dt_enc, pats[[i]], colnames_pattern_diagnosis, NA)
      changeDataForPID(dt_enc, pats[[i]], "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[DEBUG_DAY], offset_days = 0.1))
      # Patient
      changeDataForPID(dt_pat, pats[[i]], "pat_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[DEBUG_DAY], offset_days = 0.1))
    }

    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1",
                     enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [2.1.1.1]Bett 1"]

    dt_enc[enc_id == "[1]UKB-0002-E-1-A-1-V-1",
           `:=`(
             enc_location_identifier_value = "[1.1.1.1]Raum 2 ~ [2.1.1.1]Bett 2",
             enc_partof_ref = "[1.1]Encounter/UKB-0002-E-1-A-1"
           )]

    pids_per_wards <- resource_tables$pids_per_ward

    if (DEBUG_DAY == 1) {
      pids_per_wards[, encounter_id := c("UKB-0001-E-1-A-1-V-1", "UKB-0002-E-1-A-1-V-1")]
      pids_per_wards[, ward_name := c("Station 1", "Station 1")]

    } else if (DEBUG_DAY == 2) {

      dt_enc <- dt_enc[grepl("-V-1$", enc_id)]
      dt_enc <- rbind(dt_enc, dt_enc[2])

      dt_enc[2, enc_id := "[1]UKB-0002-E-1-A-1-V-1"]
      dt_enc[2, enc_status := "finished"]
      dt_enc[2, enc_location_identifier_value := "[1.1.1.1]Raum 2 ~ [2.1.1.1]Bett 2"]
      dt_enc[2, enc_period_end := getFormattedRAWDateTime(DEBUG_DATES[DEBUG_DAY], offset_days = 0.5)]

      dt_enc[3, enc_id := "[1]UKB-0002-E-1-A-1-V-2"]
      dt_enc[3, enc_status := "in-progress"]
      dt_enc[3, enc_location_identifier_value := "[1.1.1.1]Nicht-IP-Raum 3 ~ [2.1.1.1]Nicht-IP-Bett 3"]
      dt_enc[3, enc_period_start := getFormattedRAWDateTime(DEBUG_DATES[DEBUG_DAY], offset_days = 0.5)]
      dt_enc[3, enc_period_end := NA]
      pids_per_wards <- pids_per_wards[-2]
      pids_per_wards[, ward_name := "Station 1"]
      pids_per_wards[, encounter_id := "UKB-0001-E-1-A-1-V-1"]

    } else if (DEBUG_DAY == 3) {
      dt_pat <- dt_pat[0]
      pids_per_wards <- pids_per_wards[0]
      dt_enc[grepl("^\\[1\\]UKB-0001-E-1", enc_id), `:=`(
        enc_status = "finished",
        enc_period_end = getFormattedRAWDateTime(DEBUG_DATES[DEBUG_DAY], offset_days = 0.5)
      )]
      to_modify <- c(
        "[1]UKB-0002-E-1",
        "[1]UKB-0002-E-1-A-1",
        "[1]UKB-0002-E-1-A-1-V-2"
      )
      dt_enc[enc_id %in% to_modify, `:=`(
        enc_status = "finished",
        enc_period_end = getFormattedRAWDateTime(DEBUG_DATES[DEBUG_DAY], offset_days = 0.5)
      )]
    }
  }
  # Update the Encounter table in the resource_tables list
  resource_tables[["Encounter"]] <- dt_enc
  resource_tables[["Patient"]] <- dt_pat
  resource_tables[["pids_per_ward"]] <- pids_per_wards
}
