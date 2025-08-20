# Define the days count for this test
DEBUG_DAYS_COUNT <- 8

# Patient UKB-0001
# Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
# Tag 2: Versorgungsstellenkontakt auf Nicht IP-Station Zimmer Nicht-IP-Raum 1-1, Bett Nicht-IP-Bett 1-1
# Tag 3: Versorgungsstellenkontakt auf Station 1-2 Zimmer 1-2, Bett 1-2
# Tag 4: Encounter wird entlassen
# Tag 5: Neuer Encounter und neuer Versorgungsstellenkontakt auf gleicher IP-Station 1-1 Zimmer 1-3, Bett 1-3
# Tag 6: keine Verlegung
# Tag 7: Versorgungsstellenkontakt auf Nicht IP-Station Zimmer Nicht-IP-Raum 1-2, Bett Nicht-IP-Bett 1-2
# Tag 8: Entlassung von Nicht IP-Station

# Patient UKB-0002
# Tag 1: Versorgungsstellenkontakt auf nicht-IP-Station
# Tag 2: Versorgungsstellenkontakt auf Station 2-1 Zimmer 2-1, Bett 2-1
# Tag 3: Versorgungsstellenkontakt auf Station 2-1 Zimmer 2-2, Bett 2-2
# Tag 4: Versorgungsstellenkontakt auf nicht-IP-Station
# Tag 5: Encounter wird entlassen
# Tag 6: Neuer Encounter und neuer Versorgungsstellenkontakt auf nicht-IP-Station
# Tag 7: Versorgungsstellenkontakt auf Station 2-2 Zimmer 2-3, Bett 2-3
# Tag 8: Entlassung von IP-Station

#TODO: MRP-haltige Medikation und Medikationsanalsyse anlegen für beide Fälle -> prüfen, ob der Stationsname für das MRP stimmt, wenn die Medikationsanalyse immer auf dem ersten IP-Station stattfand.

if (exists("DEBUG_DAY")) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  # resources are a list of data tables from outside we want to change for the test
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pid2 <- "UKB-0002"
  pats <- c(pid1, pid2) # present at day 1

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    #etlutils::dbReset()
  } else {
    # Load all encounters from the database which, according to the database,
    # have not yet ended on the 'current' date and determine the PIDs.
    # Background: We want to track all cases that have ever been on a relevant
    # station until they are completed. So if a patient is discharged, we still
    # want to track the case until it is completed.
    patient_ids_db <- etlutils::getAfterLastSlash(getActiveEncounterPIDsFromDB())
    pats <- unique(c(pats, patient_ids_db))
  }

  # Convenience list of patient IDs
  pats <- namedListByValue(pats)

  testPrepareRAWResources(pats)
  testRemoveMultipleDiagnoses()

  # set the enc_period_start of all encounters of a patient to the current date
  # minus an offset
  for (i in seq_along(pats)) {
    testChangeDataForPIDEncounter(paste0("UKB-000", i), "enc_period_start", getDebugDatesRAWDateTime(-i, 1))
  }

  ### Add encounters with type "Versorgungstellenkontakt" ###
  # dt_enc <- testGetResourceTable("Encounter")
  # pids_per_wards <- testGetResourceTable("pids_per_ward")

  #testAddEncounterLevel3()

  if (DEBUG_DAY >= 1) {
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1

    # Set all encounter to "in-progress", delete end date and diagnoses and set
    # the encounter last updated date to the current date with a small offset
    # Set the patient last updated date to the current date with a small offset
    # Set enc_location_identifier_value for the Versorgungsstellenkontakt (Raum 1, Bett 1)
    # Change pids_per_wards to the correct encounter id and ward name (Station 1)
    # testUpdateEncounterStatus(pid1, "in-progress", end = NA)
    # testSetBedAndRoom("UKB-0001-E-1-A-1-V-1", "Raum 1-1", "Bett 1-1")
    # testUpdateWard("UKB-0001-E-1", "Station 1-1", pid1)
    browser()
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1-1")

    # Patient 2 Tag 1: Versorgungsstellenkontakt auf nicht-IP-Station
    testAdmission(pid2, "Nicht-IP-Raum 2-1", "Nicht-IP-Bett 2-1")
    # testUpdateEncounterStatus(pid2, "in-progress", end = NA)
    # testSetBedAndRoom("UKB-0002-E-1-A-1-V-1", "Nicht-IP-Raum 2-1", "Nicht-IP-Bett 2-1")
    # testUpdateWard(remove_pids = pid2)

  }
  if (DEBUG_DAY >= 2) {
    browser()
    # prepare encounter and patient data

    # Patient 1 Tag 2: Versorgungsstellenkontakt auf nicht-IP-Station Zimmer Nicht-IP-Raum 1-1, Bett Nicht-IP-Bett 1-1

    # Remove Einrichtungs- und Abteilungskontakt from encounter table and duplicate Versorgungsstellenkontakt
    # Patient unchanged to day 1, delete row
    # Delete diagnoses and set the encounter last updated date to the current date with a small offset
    # Versorgungsstellenkontakt 1: Set enc_location_identifier_value for the Versorgungsstellenkontakt (Raum 1, Bett 1)
    # And enc_period_end to the current date and enc_status to "finished"
    # Versorgungsstellenkontakt 2: Set enc_location_identifier_value for the Versorgungsstellenkontakt (Nicht-IP-Raum 5, Nicht-IP-Bett 5)
    # And enc_period_start to debug day 2 and enc_period_enc to NA and enc_status to "in-progress"
    # Clean pids_per_wards
    testTransferEncounterLevel3("UKB-0001")
    dt_enc <- finishAndStartEncounterLevel3(dt_enc, "UKB-0001-E-1-A-1-V-1")
    testSetBedAndRoom("UKB-0001-E-1-A-1-V-2", "Nicht-IP-Raum 1-1", "Nicht-IP-Bett 1-1")

    dt_pat <- removePatient("UKB-0001")
    pids_per_wards <- removePatientFromWard("UKB-0001")


    dt_pat <- dt_pat[pat_id != "[1]UKB-0001"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0001"]

    # Patient 2 Tag 2: Versorgungsstellenkontakt auf Station 2-1 Zimmer 2-1, Bett 2-1
    testSetBedAndRoom("[1]UKB-0002-E-1-A-1-V-1", "Nicht-IP-Raum 2-1", "Nicht-IP-Bett 2-1")
    dt_enc <- finishAndStartEncounterLevel3(dt_enc, "UKB-0002", 3,
                                            "Nicht-IP-Raum 2-1", "Nicht-IP-Bett 2-1", -0.5,
                                            4, "UKB-0002-E-1-A-1-V-2",
                                            "Raum 2-1", "Bett 2-1", -0.5)
    testUpdateWard("UKB-0002-E-1-A-1-V-2", "Station 2-1", "UKB-0002")

  }
  if (DEBUG_DAY >= 3) {
    # prepare encounter and patient data
    testTransferEncounterLevel3()
    dt_pat <- dt_pat[0]
    dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1", enc_id := "[1]UKB-0001-E-1-A-1-V-2"]
    dt_enc[enc_id == "[1]UKB-0002-E-1-A-1-V-1", enc_id := "[1]UKB-0002-E-1-A-1-V-2"]

    # Patient 1 Tag 3: Versorgungsstellenkontakt auf Station 1-2 Zimmer 1-2, Bett 1-2
    testSetBedAndRoom("[1]UKB-0001-E-1-A-1-V-2", "Nicht-IP-Raum 1-1", "Nicht-IP-Bett 1-1")
    dt_enc <- finishAndStartEncounterLevel3(
      dt_enc,
      pid = "UKB-0001",
      old_row_idx = 1,
      old_room = "Nicht-IP-Raum 1-1", old_bed = "Nicht-IP-Bett 1-1", old_end_offset = -0.5,
      new_row_idx = 2,
      new_enc_id = "UKB-0001-E-1-A-1-V-3",
      new_room = "Raum 1-2", new_bed = "Bett 1-2", new_start_offset = -0.5
    )
    testUpdateWard("UKB-0001-E-1-A-1-V-3", "Station 1-2", "UKB-0001")

    # Patient 2 Tag 3: Versorgungsstellenkontakt auf Station 2-1 Zimmer 2-2, Bett 2-2
    testSetBedAndRoom("[1]UKB-0002-E-1-A-1-V-2", "Raum 2-1", "Bett 2-1")
    dt_enc <- finishAndStartEncounterLevel3(dt_enc, "UKB-0002", 3,
                                            "Raum 2-1", "Bett 2-1", -0.1,
                                            4, "UKB-0002-E-1-A-1-V-3",
                                            "Raum 2-2", "Bett 2-2", -0.1)
    testUpdateWard("UKB-0002-E-1-A-1-V-3", "Station 2-1", "UKB-0002")


  }
  if (DEBUG_DAY >= 4) {
    # prepare encounter and patient data
    dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1", enc_id := "[1]UKB-0001-E-1-A-1-V-3"]
    dt_enc[enc_id == "[1]UKB-0002-E-1-A-1-V-1", enc_id := "[1]UKB-0002-E-1-A-1-V-3"]

    # Patient 1 Tag 4: Encounter wird entlassen
    dt_enc <- dischargeEncounter(
      dt_enc,
      patient_id = "UKB-0001",
      enc_id = "[1]UKB-0001-E-1-A-1-V-3",
      encounter_number = 1,
      room = "Raum 1-2",
      bed  = "Bett 1-2",
      debug_day = DEBUG_DAY
    )
    dt_pat <- dt_pat[pat_id != "[1]UKB-0001"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0001"]

    # Patient 2 Tag 4: nicht-IP-Station
    #dt_enc <- testTransferEncounterLevel3(dt_enc, patient_refs = "[1.1]Patient/UKB-0002")
    testTransferEncounterLevel3()  # checken, ob das noch so stimmt
    dt_pat <- dt_pat[0]
    testSetBedAndRoom("[1]UKB-0001-E-1-A-1-V-3", "Raum 2-2", "Bett 2-2")
    dt_enc <- finishAndStartEncounterLevel3(dt_enc, "UKB-0002", 4,
                                            "Raum 2-2", "Bett 2-2", -0.5,
                                            5, "UKB-0002-E-1-A-1-V-4",
                                            "Nicht-IP-Raum 2-2", "Nicht-IP-Bett 2-2", -0.5)
    dt_pat <- dt_pat[pat_id != "[1]UKB-0002"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0002"]

  }
  if (DEBUG_DAY >= 5) {
    # Patient 1 Tag 5: Neuer Encounter und neuer Versorgungsstellenkontakt auf gleicher IP-Station 1-1 Zimmer 1-3, Bett 1-3
    dt_enc <- startNewEncounter(
      dt_enc,
      patient_id       = "UKB-0001",
      encounter_number = 2,
      room    = "Raum 1-3",
      bed     = "Bett 1-3",
      debug_day = DEBUG_DAY,
      start_offset = 0
    )
    testUpdateWard("Encounter/UKB-0001-E-2-A-1", "Station 1-1", "UKB-0001")

    # Patient 2 Tag 5: Encounter wird entlassen
    dt_enc[enc_id == "[1]UKB-0002-E-1-A-1-V-1", enc_id := "[1]UKB-0002-E-1-A-1-V-4"]
    dt_enc <- dischargeEncounter(
      dt_enc,
      patient_id = "UKB-0002",
      enc_id = "[1]UKB-0002-E-1-A-1-V-4",
      encounter_number = 1,
      room = "Nicht-IP-Raum 2-2",
      bed  = "Nicht-IP-Bett 2-2",
      debug_day = DEBUG_DAY
    )
    dt_pat <- dt_pat[pat_id != "[1]UKB-0002"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0002"]

  }
  if (DEBUG_DAY == 6) {
    # Patient 1 Tag 6: keine Verlegung (siehe Tag 5)
    dt_enc <- startNewEncounter(
      dt_enc,
      patient_id       = "UKB-0001",
      encounter_number = 2,
      room    = "Raum 1-3",
      bed     = "Bett 1-3",
      debug_day = DEBUG_DAY,
      start_offset = 1
    )
    testUpdateWard("Encounter/UKB-0001-E-2-A-1", "Station 1-1", "UKB-0001")

    # Patient 2 Tag 6: neuer Encounter nicht-IP
    dt_enc <- startNewEncounter(
      dt_enc,
      patient_id       = "UKB-0002",
      encounter_number = 2,
      room    = "Nicht-IP-Raum 2-3",
      bed     = "Nicht-IP-Bett 2-3",
      debug_day = DEBUG_DAY,
      start_offset = 0
    )
    dt_pat <- dt_pat[pat_id != "[1]UKB-0002"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0002"]

  }
  if (DEBUG_DAY == 7) {
    # prepare encounter and patient data
    testTransferEncounterLevel3()
    dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1", enc_id := "[1]UKB-0001-E-2-A-1-V-1"]
    dt_enc[enc_id == "[1]UKB-0002-E-1-A-1-V-1", enc_id := "[1]UKB-0002-E-2-A-1-V-1"]
    # Patient 1 Tag 7: Versorgungsstellenkontakt auf Nicht IP-Station Zimmer Nicht-IP-Raum 1-2, Bett Nicht-IP-Bett 1-2
    dt_enc <- finishAndStartEncounterLevel3(
      dt_enc,
      pid = "UKB-0001",
      old_row_idx = 1,
      old_room = "Raum 1-3", old_bed = "Bett 1-3", old_end_offset = -0.5,
      new_row_idx = 2,
      new_enc_id = "UKB-0001-E-2-A-1-V-2",
      new_room = "Nicht-IP-Raum 1-2", new_bed = "Nicht-IP-Bett 1-2", new_start_offset = -0.5
    )
    dt_pat <- dt_pat[pat_id != "[1]UKB-0001"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0001"]

    # Patient 2 Tag 7: Versorgungsstellenkontakt auf Station 2-2 Zimmer 2-3, Bett 2-3
    dt_enc <- finishAndStartEncounterLevel3(
      dt_enc,
      pid = "UKB-0002",
      old_row_idx = 3,
      old_room = "Nicht-IP-Raum 2-3", old_bed = "Nicht-IP-Bett 2-3", old_end_offset = -0.5,
      new_row_idx = 4,
      new_enc_id = "UKB-0002-E-2-A-1-V-2",
      new_room = "Raum 2-3", new_bed = "Bett 2-3", new_start_offset = -0.5
    )
    testUpdateWard("UKB-0002-E-2-A-1-V-2", "Station 2-3", "UKB-0001")

  }
  if (DEBUG_DAY == 8) {
    browser()
    # prepare encounter and patient data
    dt_enc[enc_id == "[1]UKB-0001-E-1-A-1-V-1", enc_id := "[1]UKB-0001-E-2-A-1-V-2"]
    dt_enc[enc_id == "[1]UKB-0002-E-1-A-1-V-1", enc_id := "[1]UKB-0002-E-2-A-1-V-2"]
    # Patient 1 Tag 8: Entlassung von Nicht IP-Station

    dt_enc <- dischargeEncounter(
      dt_enc,
      patient_id = "UKB-0001",
      enc_id = "[1]UKB-0001-E-2-A-1-V-2",
      encounter_number = 2,
      room = "Nicht-IP-Raum 1-2",
      bed  = "Nicht-IP-Bett 1-2",
      debug_day = DEBUG_DAY
    )
    dt_pat <- dt_pat[pat_id != "[1]UKB-0001"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0001"]

    # Patient 2 Tag 8: Entlassung von IP-Station
    dt_enc <- dischargeEncounter(
      dt_enc,
      patient_id = "UKB-0002",
      enc_id = "[1]UKB-0002-E-2-A-1-V-2",
      encounter_number = 2,
      room = "Raum 2-3",
      bed  = "Bett 2-3",
      debug_day = DEBUG_DAY
    )
    dt_pat <- dt_pat[pat_id != "[1]UKB-0002"]
    pids_per_wards <- pids_per_wards[patient_id != "UKB-0002"]
  }
  # Add partof Reference to the Encounter table
  testAddPartOf()

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
