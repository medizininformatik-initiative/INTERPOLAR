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
# Tag 3: Abteilungswechsel auf Station 2-3 Zimmer 2-3, Bett 2-3
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

  # Show the current state of the resources
  # dt_enc <- testGetResourceTable("Encounter")
  # pids_per_wards <- testGetResourceTable("pids_per_ward")
  current_debug_day <- DEBUG_DAY
  if (DEBUG_DAY >= 1) {
    DEBUG_DAY <- 1
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1-1")
    # Patient 2 Tag 1: Versorgungsstellenkontakt auf nicht-IP-Station
    testAdmission(pid2, "Nicht-IP-Raum 2-1", "Nicht-IP-Bett 2-1")
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 2) {
    DEBUG_DAY <- 2
    # Patient 1 Tag 2: Versorgungsstellenkontakt auf nicht-IP-Station Zimmer Nicht-IP-Raum 1-1, Bett Nicht-IP-Bett 1-1
    testTransferWardInternal(pid1, "Nicht-IP-Raum 1-1", "Nicht-IP-Bett 1-1")
    # Patient 2 Tag 2: Versorgungsstellenkontakt auf Station 2-1 Zimmer 2-1, Bett 2-1
    testTransferWardInternal(pid2, "Raum 2-1", "Bett 2-1", "Station 2-1")
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 3) {
    DEBUG_DAY <- 3
    # Patient 1 Tag 3: Versorgungsstellenkontakt auf Station 1-2 Zimmer 1-2, Bett 1-2
    testTransferWardInternal(pid1, "Raum 1-2", "Bett 1-2", "Station 1-2")
    # Patient 2 Tag 3: Abteilungswechsel auf Station 2-3 Zimmer 2-3, Bett 2-3
    testTransferWardDepartment(pid2, "Raum 2-3", "Bett 2-3", "Station 2-3")
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 4) {
    DEBUG_DAY <- 4
    # Patient 1 Tag 4: Encounter wird entlassen
    testDischarge(pid1)
    # Patient 2 Tag 4: Versorgungsstellenkontakt auf nicht-IP-Station Zimmer Nicht-IP-Raum 2-2, Bett Nicht-IP-Bett 2-2
    testTransferWardInternal(pid2, "Nicht-IP-Raum 2-2", "Nicht-IP-Bett 2-2")
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 5) {
    DEBUG_DAY <- 5
    browser()
    # Patient 1 Tag 5: Neuer Encounter und neuer Versorgungsstellenkontakt auf gleicher IP-Station 1-1 Zimmer 1-3, Bett 1-3
    testAdmission(pid1, "Raum 1-3", "Bett 1-3", "Station 1-1")
    # Patient 2 Tag 5: Encounter wird entlassen
    testDischarge(pid2)
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 6) {
    DEBUG_DAY <- 6
    # Patient 1 Tag 6: keine Verlegung
    # no action
    # Patient 2 Tag 6: neuer Encounter nicht-IP-Station Zimmer Nicht-IP-Raum 2-3, Bett Nicht-IP-Bett 2-3
    testAdmission(pid2, "Nicht-IP-Raum 2-3", "Nicht-IP-Bett 2-3")
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 7) {
    DEBUG_DAY <- 7
    # Patient 1 Tag 7: Versorgungsstellenkontakt auf Nicht IP-Station Zimmer Nicht-IP-Raum 1-2, Bett Nicht-IP-Bett 1-2
    testTransferWardInternal(pid1, "Nicht-IP-Raum 1-2", "Nicht-IP-Bett 1-2")
    # Patient 2 Tag 7: Versorgungsstellenkontakt auf Station 2-2 Zimmer 2-3, Bett 2-3
    testTransferWardInternal(pid2, "Raum 2-1", "Bett 2-3", "Station 2-3")
    DEBUG_DAY <- current_debug_day
  }
  if (DEBUG_DAY >= 8) {
    DEBUG_DAY <- 8
    # Patient 1 Tag 8: Entlassung von Nicht IP-Station
    testDischarge(pid1)
    # Patient 2 Tag 8: Entlassung von IP-Station
    testDischarge(pid2)
    DEBUG_DAY <- current_debug_day
  }

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
