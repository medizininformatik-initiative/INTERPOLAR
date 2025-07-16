# Ein Patient
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1, Bett 1, bekommt Medikamente + Diagnose + Medikationsanalyse
# Tag 2: Versorgungsstellenkontakt wird entlassen
if (exists("DEBUG_DAY")) {

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
  dt_medreq <- resource_tables[["MedicationRequest"]]
  dt_med <- resource_tables[["Medication"]]
  dt_con <- resource_tables[["Condition"]]

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

      # lastupdated date
      lastupdated <- getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.5)
      changeDataForPID(dt_enc, pats[[i]], "enc_meta_lastupdated", lastupdated)
      changeDataForPID(dt_pat, pats[[i]], "pat_meta_lastupdated", lastupdated)
      changeDataForPID(dt_med, pats[[i]], "med_meta_lastupdated", lastupdated)
      changeDataForPID(dt_medreq, pats[[i]], "medreq_meta_lastupdated", lastupdated)
      changeDataForPID(dt_con, pats[[i]], "medreq_meta_lastupdated", lastupdated)
    }

    # Ressources for Drug-Disease MRP
    dt_med <- dt_med[1,]
    dt_med[1, `:=`(
      med_id = "[1]UKB-0001-M-1",
      med_code_code = "[1.1.1]14022620 ~ [1.2.1]A10BA02"
    )]
    dt_med <- rbind(dt_med, dt_med[1])
    dt_med[2, `:=`(
      med_id = "[1]UKB-0001-M-2",
      med_code_code = "[1.1.1]14022620 ~ [1.2.1]N07BB03"
    )]
    dt_med <- rbind(dt_med, dt_med[1])
    dt_med[3, `:=`(
      med_id = "[1]UKB-0001-M-3",
      med_code_code = "[1.1.1]14022620 ~ [1.2.1]N02AA01"
    )]

    dt_medreq <- rbind(
      dt_medreq,
      data.table::data.table(
        medreq_id = c("[1]UKB-0001-MR-1", "[1]UKB-0001-MR-2", "[1]UKB-0001-MR-3"),
        medreq_patient_ref = "[1.1]Patient/UKB-0001",
        medreq_medicationreference_ref = c("[1]Medication/UKB-0001-M-1", "[1]Medication/UKB-0001-M-2", "[1]Medication/UKB-0001-M-3"),
        medreq_authoredon = c(
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.8),
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.7),
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.6)
        )
      ),
      fill = TRUE
    )

    dt_con <- dt_con[1,] # keep only one row
    dt_con[nrow(dt_con), `:=`(
      con_id = "[1]UKB-0001-C-2",
      con_patient_ref = "[1.1]Patient/UKB-0001",
      con_code_code = "[1.1.1]R10.0",
      con_recordeddate = getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.7),
      con_onsetperiod_start = getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.7)
    )]

    # Ressources for Drug-Drug MRP
    dt_med <- rbind(dt_med, dt_med[1])
    dt_med[4, `:=`(
      med_id = "[1]UKB-0001-M-4",
      med_code_code = "[1.1.1]14022620 ~ [1.2.1]N06AX22"
    )]
    dt_med <- rbind(dt_med, dt_med[1])
    dt_med[5, `:=`(
      med_id = "[1]UKB-0001-M-5",
      med_code_code = "[1.1.1]14022620 ~ [1.2.1]J01MA02"
    )]

    dt_medreq <- rbind(
      dt_medreq,
      data.table::data.table(
        medreq_id = c("[1]UKB-0001-MR-4", "[1]UKB-0001-MR-5"),
        medreq_patient_ref = "[1.1]Patient/UKB-0001",
        medreq_medicationreference_ref = c("[1]Medication/UKB-0001-M-4", "[1]Medication/UKB-0001-M-5"),
        medreq_doseinstruc_timing_repeat_boundsperiod_start = c(
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.5),
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.5)
        ),
        medreq_doseinstruc_timing_repeat_boundsperiod_end = c(
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.2),
          getFormattedRAWDateTime(DEBUG_DATES[1], offset_days = 0.2)
        )
      ),
      fill = TRUE
    )
    #########################################################
    dt_enc <- dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1",
                     enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [2.1.1.1]Bett 1"]
    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards[, encounter_id := "UKB-0001-E-1-A-1-V-1"]
    pids_per_wards[, ward_name := "Station 2"]

  } else if (DEBUG_DAY == 2) {
    # Day 2: Versorgungsstellenkontakt wird entlassen

    dt_pat <- dt_pat[-1]
    changeDataForPID(dt_enc, pats$`UKB-0001`, "enc_meta_lastupdated", getFormattedRAWDateTime(DEBUG_DATES[2], offset_days = 0.1))
    changeDataForPID(dt_enc, pats$`UKB-0001`, colnames_pattern_diagnosis, NA)

    dt_enc[1, enc_id := "UKB-0001-E-1"]
    dt_enc[1, enc_status := "finished"]
    dt_enc[1, enc_location_identifier_value := "[1.1.1.1]Raum 1 ~ [2.1.1.1]Bett 1"]
    dt_enc[1, enc_period_end := getFormattedRAWDateTime(DEBUG_DATES[2], offset_days = 0.2)]

    dt_enc[2, enc_id := "UKB-0001-E-1-A-1"]
    dt_enc[2, enc_status := "finished"]
    dt_enc[2, enc_period_end := getFormattedRAWDateTime(DEBUG_DATES[2], offset_days = 0.2)]

    dt_enc[3, enc_id := "UKB-0001-E-1-A-1-V-1"]
    dt_enc[3, enc_status := "finished"]
    dt_enc[3, enc_period_end := getFormattedRAWDateTime(DEBUG_DATES[2], offset_days = 0.2)]

    pids_per_wards <- resource_tables$pids_per_ward
    pids_per_wards <- pids_per_wards[-1]

  }
  # Update the Encounter table in the resource_tables list
  resource_tables[["Encounter"]] <- dt_enc
  resource_tables[["Patient"]] <- dt_pat
  resource_tables[["MedicationRequest"]] <- dt_medreq
  resource_tables[["Medication"]] <- dt_med
  resource_tables[["Condition"]] <- dt_con
  resource_tables[["pids_per_ward"]] <- pids_per_wards
}
