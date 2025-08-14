# Define the days count for this test
DEBUG_DAYS_COUNT <- 7

# Ein Patient
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1, Bett 1
# Tag 2: Versorgungsstellenkontakt auf Station 1 Zimmer 1, Bett 2
# Tag 3: Versorgungsstellenkontakt auf nicht-IP-Station
# Tag 4: Versorgungsstellenkontakt auf Station 2 Zimmer 9, Bett 9
# Tag 5: Encounter wird entlassen
# Tag 6: Neuer Encounter und neuer Versorgungsstellenkontakt auf neuer Station 3 Zimmer 666, Bett 666
# Tag 7: Versorgungsstellenkontakt auf Station 3 Zimmer 777, Bett 777

#TODO: Tag 8: Verlegung auf Nicht Interpolar-Station
#TODO: Tag 9: Entlassung von Nicht Interpolar-Station
#TODO: MRP-haltige Medikation und Medikationsanalsyse anlegen für beide Fälle -> prüfen, ob der Stationsname für das MRP stimmt, wenn die Medikationsanalyse immer auf dem ersten IP-Station stattfand.

if (exists("DEBUG_DAY")) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    etlutils::dbReset()
    pats <- c("UKB-0001") # present at day 1
  } else{
    pats <- c("UKB-0001")
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

    # Append the new Versorgungsstellenkontakt rows to the Encounter table
    dt_enc <- rbind(dt_enc, rows_to_duplicate)
  }

  if (DEBUG_DAY == 1) {
    # Day 1: #Versorgungsstellenkontakt to ward Station 1 Zimmer 1, Bett 1

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
      changeDataForPID(dt_enc, pats[[i]], "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.5))
      # Patient
      changeDataForPID(dt_pat, pats[[i]], "pat_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.5))
    }

    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1",
                     enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [2.1.1.1]Bett 1"]
    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards[, encounter_id := "UKB-0001-E-1-A-1-V-1"]
    pids_per_wards[, ward_name := "Station 1"]

  } else if (DEBUG_DAY == 2) {
    # Day 2: Versorgungsstellenkontakt to ward Station 1 Zimmer 1, Bett 2

    # Remove Einrichtungs- und Abteilungskontakt from encounter table
    # Patient unchanged to day 1, delete row
    # Set all encounter to "in-progress", delete end date and diagnoses and set
    # the encounter last updated date to the current date with a small offset
    # Set enc_location_identifier_value for the Versorgungsstellenkontakt (Raum 1, Bett 2)
    # Change pids_per_wards to the correct encounter id and ward name (Station 1)

    dt_enc <- dt_enc[-c(1, 2)]
    dt_pat <- dt_pat[-1]
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_status", "in-progress")
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_end", NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[2], offset_days = 0.5))


    dt_enc[, enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [2.1.1.1]Bett 2"]
    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards[, encounter_id := "UKB-0001-E-1-A-1-V-1"]
    pids_per_wards[, ward_name := "Station 1"]

  } else if (DEBUG_DAY == 3) {
    # Day 3: Versorgungsstellenkontakt to ward Nicht-IP-Station Z, Raum 5, Bett 5

    # Remove Einrichtungs- und Abteilungskontakt from encounter table and duplicate Versorgungsstellenkontakt
    # Patient unchanged to day 1, delete row
    # Delete diagnoses and set the encounter last updated date to the current date with a small offset
    # Versorgungsstellenkontakt 1: Set enc_location_identifier_value for the Versorgungsstellenkontakt (Raum 1, Bett 2)
    # And enc_period_end to the current date and enc_status to "finished"
    # Versorgungsstellenkontakt 2: Set enc_location_identifier_value for the Versorgungsstellenkontakt (Nicht-IP-Raum 5, Nicht-IP-Bett 5)
    # And enc_period_start to debug day 2 and enc_period_enc to NA and enc_status to "in-progress"
    # Clean pids_per_wards

    dt_enc[2] <- dt_enc[3]
    dt_enc <- dt_enc[-1]
    dt_pat <- dt_pat[-1]
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.3))
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)

    dt_enc[1, enc_id := "UKB-0001-E-1-A-1-V-1"]
    dt_enc[1, enc_status := "finished"]
    dt_enc[1, enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [2.1.1.1]Bett 2"]
    dt_enc[1, enc_period_end := getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.5)]

    dt_enc[2, enc_id := "UKB-0001-E-1-A-1-V-2"]
    dt_enc[2, enc_status := "in-progress"]
    dt_enc[2, enc_location_identifier_value := "[1.1.1.1]Nicht-IP-Raum 5 ~ [2.1.1.1]Nicht-IP-Bett 5"]
    dt_enc[2, enc_period_start := getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.5)]
    dt_enc[2, enc_period_end := NA]

    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards <- pids_per_wards[-1]

  } else if (DEBUG_DAY == 4) {
    # Day 4: Versorgungsstellenkontakt to ward Station 2 Zimmer 9, Bett 9

    # Remove Einrichtungs- und Abteilungskontakt from encounter table and duplicate Versorgungsstellenkontakt
    # Patient unchanged to day 1, delete row
    # Set the encounter last updated date to the current date with a small offset
    # Versorgungsstellenkontakt 1: Set enc_location_identifier_value for the Versorgungsstellenkontakt (Raum 1, Bett 2)
    # And enc_period_end to the current date and enc_status to "finished"
    # Versorgungsstellenkontakt 2: Set enc_location_identifier_value for the Versorgungsstellenkontakt ([1.1.1.1]Raum 9 ~ [2.1.1.1]Bett 9)
    # And enc_period_start to debug day 3 and enc_period_enc to NA and enc_status to "in-progress"
    # Change pids_per_wards to the correct encounter id and ward name (Station 2)

    dt_enc[2] <- dt_enc[3]
    dt_enc <- dt_enc[-1]
    dt_pat <- dt_pat[-1]
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[4], offset_days = 0.3))
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)

    dt_enc[1, enc_id := "UKB-0001-E-1-A-1-V-2"]
    dt_enc[1, enc_status := "finished"]
    dt_enc[1, enc_location_identifier_value := "[1.1.1.1]Nicht-IP-Raum 5 ~ [2.1.1.1]Nicht-IP-Bett 5"]
    dt_enc[1, enc_period_start := getFormattedRAWDateTime(DEBUG_DATES[3], offset_days = 0.5)]
    dt_enc[1, enc_period_end := getFormattedRAWDateTime(DEBUG_DATES[4], offset_days = 0.5)]

    dt_enc[2, enc_id := "UKB-0001-E-1-A-1-V-3"]
    dt_enc[2, enc_status := "in-progress"]
    dt_enc[2, enc_location_identifier_value := "[1.1.1.1]Raum 9 ~ [2.1.1.1]Bett 9"]
    dt_enc[2, enc_period_start := getFormattedRAWDateTime(DEBUG_DATES[4], offset_days = 0.5)]
    dt_enc[2, enc_period_end := NA]

    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards[, encounter_id := "UKB-0001-E-1-A-1-V-3"]
    pids_per_wards[, ward_name := "Station 2"]

  } else if (DEBUG_DAY == 5) {
    # Day 5: Versorgungsstellenkontakt finished

    # Patient unchanged to day 1, delete row
    # Set the encounter last updated date to the current date with a small offset
    # Set all encounter to status "finished" and set enc_period_end to the current date
    # Set the enc_location_identifier_value for the Versorgungsstellenkontakt ([1.1.1.1]Raum 9 ~ [2.1.1.1]Bett 9)
    # Clean pids_per_wards

    dt_pat <- dt_pat[-1]
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[5], offset_days = 0.3))
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)

    dt_enc[grepl("^\\[1\\]UKB-0001-E-1", enc_id), `:=`(
      enc_status = "finished",
      enc_period_end = getFormattedRAWDateTime(DEBUG_DATES[5], offset_days = 0.5)
    )]
    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1",
                     enc_id := "UKB-0001-E-1-A-1-V-3"]
    dt_enc <- dt_enc[enc_id == "UKB-0001-E-1-A-1-V-3",
                     enc_location_identifier_value := "[1.1.1.1]Raum 9 ~ [2.1.1.1]Bett 9"]
    dt_enc <- dt_enc[enc_id == "UKB-0001-E-1-A-1-V-3",
                     enc_period_start := getFormattedRAWDateTime(DEBUG_DATES[4], offset_days = 0.5)]

    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards <- pids_per_wards[-1]

  } else if (DEBUG_DAY == 6 || DEBUG_DAY == 7) {
    # Day 6: New Encounter on ward Station 3 Zimmer 666, Bett 666
    # Day 6: New Encounter on ward Station 3 Zimmer 777, Bett 777

    num <- if (DEBUG_DAY == 6) 666 else 777

    # Set all encounter to "in-progress", delete end date, set start date to last debug day and diagnoses and set
    # the encounter last updated date to the current date with a small offset
    # Set new enc_location_identifier_value to "[1.1.1.1]Raum 666 ~ [2.1.1.1]Bett 666" and add part of references
    # Update patient with new pat_meta_lastupdated
    # Change pids_per_wards to the correct encounter id and ward name (Station 3)

    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_status", "in-progress")
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_start", getFormattedRAWDateTime(DEBUG_DATES[6], offset_days = 0.5))
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_period_end", NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[6], offset_days = 0.5))
    # Patient
    changeDataForPID(dt_pat, pats$`UKB-0001`, "pat_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[6], offset_days = 0.5))

    dt_enc <- dt_enc[, enc_id := gsub("\\[1\\]UKB-0001-E-1", "[1]UKB-0001-E-2", enc_id)]

    # Neuer Encounter auf neuer Station 3 Zimmer 666, Bett 666
    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-2-A-1-V-1",
                     enc_location_identifier_value := paste0("[1.1.1.1]Raum ", num, " ~ [2.1.1.1]Bett ", num)]
    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-2",
                     enc_identifier_value := "UKB-0001-E-2"]
    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-2-A-1",
                     enc_partof_ref := "Encounter/UKB-0001-E-2"]
    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-2-A-1-V-1",
                     enc_partof_ref := "Encounter/UKB-0001-E-2-A-1"]

    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards[, encounter_id := "UKB-0001-E-2-A-1-V-1"]
    pids_per_wards[, ward_name := "Station 3"]

  }
  # Update the Encounter table in the resource_tables list
  resource_tables[["Encounter"]] <- dt_enc
  resource_tables[["Patient"]] <- dt_pat
  resource_tables[["pids_per_ward"]] <- pids_per_wards
}
