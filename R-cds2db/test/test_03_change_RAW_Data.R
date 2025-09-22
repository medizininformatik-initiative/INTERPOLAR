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

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 8

###
# DEBUG_MODULES_PATH_TO_CONFIG_TOML can contain for every module a path to
# a config file. If the path is not set, then only the default config file
# is used and no default values are overwritten by the debug config file.
###
DEBUG_MODULES_PATH_TO_CONFIG_TOML <- c(
  cds2db = "./R-cds2db/test/test_cds2db_config.toml",
  dataprocessor = "",
  db2frontend = ""
)

###
# If this parameter is given, then no request is sent to the FHIR server, but
# all data is loaded from this folder from RData files
###
DEBUG_PATH_TO_RAW_RDATA_FILES <- "./R-cds2db/test/tables/"

WARDS_PHASE_B_TEST <- c("Station 1-1", "Station 1-2", "Station 2-1", "Station 2-2", "Station 2-3")

###############################
# End Define global variables #
###############################

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
    etlutils::dbReset()
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

  ##########
  # Generate Admission, Transfer and Discharge events for two patients #
  ##########

  runCodeForDebugDay(1, {
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1-1")
    # Patient 2 Tag 1: Versorgungsstellenkontakt auf nicht-IP-Station
    testAdmission(pid2, "Nicht-IP-Raum 2-1", "Nicht-IP-Bett 2-1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 2: Versorgungsstellenkontakt auf nicht-IP-Station Zimmer Nicht-IP-Raum 1-1, Bett Nicht-IP-Bett 1-1
    testTransferWardInternal(pid1, "Nicht-IP-Raum 1-1", "Nicht-IP-Bett 1-1")
    # Patient 2 Tag 2: Versorgungsstellenkontakt auf Station 2-1 Zimmer 2-1, Bett 2-1
    testTransferWardInternal(pid2, "Raum 2-1", "Bett 2-1", "Station 2-1")
  })
  runCodeForDebugDay(3, {
    # Patient 1 Tag 3: Versorgungsstellenkontakt auf Station 1-2 Zimmer 1-2, Bett 1-2
    testTransferWardInternal(pid1, "Raum 1-2", "Bett 1-2", "Station 1-2")
    # Patient 2 Tag 3: Abteilungswechsel auf Station 2-3 Zimmer 2-3, Bett 2-3
    testTransferWardDepartment(pid2, "Raum 2-3", "Bett 2-3", "Station 2-3")
  })
  runCodeForDebugDay(4, {
    # Patient 1 Tag 4: Encounter wird entlassen
    testDischarge(pid1)
    # Patient 2 Tag 4: Versorgungsstellenkontakt auf nicht-IP-Station Zimmer Nicht-IP-Raum 2-2, Bett Nicht-IP-Bett 2-2
    testTransferWardInternal(pid2, "Nicht-IP-Raum 2-2", "Nicht-IP-Bett 2-2")
  })
  runCodeForDebugDay(5, {
    # Patient 1 Tag 5: Neuer Encounter und neuer Versorgungsstellenkontakt auf gleicher IP-Station 1-1 Zimmer 1-3, Bett 1-3
    testAdmission(pid1, "Raum 1-3", "Bett 1-3", "Station 1-1")
    # Patient 2 Tag 5: Encounter wird entlassen
    testDischarge(pid2)
  })
  runCodeForDebugDay(6, {
    # Patient 1 Tag 6: keine Verlegung
    # no action
    # Patient 2 Tag 6: neuer Encounter nicht-IP-Station Zimmer Nicht-IP-Raum 2-3, Bett Nicht-IP-Bett 2-3
    testAdmission(pid2, "Nicht-IP-Raum 2-3", "Nicht-IP-Bett 2-3")
  })
  runCodeForDebugDay(7, {
    # Patient 1 Tag 7: Versorgungsstellenkontakt auf Nicht IP-Station Zimmer Nicht-IP-Raum 1-2, Bett Nicht-IP-Bett 1-2
    testTransferWardInternal(pid1, "Nicht-IP-Raum 1-2", "Nicht-IP-Bett 1-2")
    # Patient 2 Tag 7: Versorgungsstellenkontakt auf Station 2-2 Zimmer 2-3, Bett 2-3
    testTransferWardInternal(pid2, "Raum 2-1", "Bett 2-3", "Station 2-3")
  })
  runCodeForDebugDay(8, {
    # Patient 1 Tag 8: Entlassung von Nicht IP-Station
    testDischarge(pid1)
    # Patient 2 Tag 8: Entlassung von IP-Station
    testDischarge(pid2)
  })


  ##########
  # Duplicate patients for every MRP type
  ##########
  duplicatePatients(4)


  ##########
  # Add Medication, Conditions and Observations for all MRP types to the duplicated patients
  ##########

  runCodeForDebugDay(1, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> MedicationRequest - N02AA01
    addDrugs("UKB-0001_1", "N02AA01")
    #UKB-0001_2 -> Drug_Drug_Interaction                -> NULL
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> MedicationRequest - N06BA09
    addDrugs("UKB-0001_3", "N06BA09")
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> NULL

    #UKB-0002_1 -> Drug_Disease_Interaction (Pro.LOINC) -> MedicationRequest - C02KX01
    addDrugs("UKB-0002_1", "C02KX01")
    #UKB-0002_2 -> Drug_Disease_Interaction (LOINC Cut) -> MedicationRequest - C03DA02
    addDrugs("UKB-0002_2", "C03DA02")
  })
  runCodeForDebugDay(2, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> NULL
    #UKB-0001_2 -> Drug_Drug_Interaction                -> MedicationRequests - N06AX22 + J01MA02
    addDrugs("UKB-0001_2", c("N06AX22", "J01MA02"))
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> MedicationRequest C02KC01
    addDrugs("UKB-0001_3", "C02KC01")
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> NULL
    #UKB-0002_1 -> Drug_Disease_Interaction (Pro.LOINC) -> Observation - 14631-6
    addObservations("UKB-0002_1", "14631-6")
    #UKB-0002_2 -> Drug_Disease_Interaction (LOINC Cut) -> Observation - 2823-3
    addObservations("UKB-0002_2", "2823-3", value = 12, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10)
  })
  runCodeForDebugDay(3, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> Diagnosis - R10.0
    addConditions("UKB-0001_1", "R10.0")
    #UKB-0001_2 -> Drug_Drug_Interaction                -> Medikationsanalyse
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> Medikationsanalyse
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> MedicationRequest - A10BA02
    addDrugs("UKB-0001_4", "A10BA02")
  })
  runCodeForDebugDay(4, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> NULL
    #UKB-0001_2 -> Drug_Drug_Interaction                -> NULL
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> NULL
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> NULL
  })
  runCodeForDebugDay(5, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> Medikationsanalyse
    #UKB-0001_2 -> Drug_Drug_Interaction                -> NULL
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> NULL
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> MedicationRequest - N07BB03
    addDrugs("UKB-0001_4", "N07BB03")
  })
  runCodeForDebugDay(6, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> NULL
    #UKB-0001_2 -> Drug_Drug_Interaction                -> NULL
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> NULL
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> Medikationsanalyse
  })
  runCodeForDebugDay(7, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> NULL
    #UKB-0001_2 -> Drug_Drug_Interaction                -> NULL
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> NULL
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> NULL
  })
  runCodeForDebugDay(8, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> NULL
    #UKB-0001_2 -> Drug_Drug_Interaction                -> NULL
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> NULL
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> NULL
  })
  duplicatePatients(10)
  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
