# Define the days count for this test
DEBUG_DAYS_COUNT <- 2

WARDS_PHASE_B_TEST <- c("Station 1-1")

# Patient UKB-0001 6x dupliziert -> UKB-0001_1 bis UKB-0001_6
# Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
#        Erster Patient hat nichts, alle anderen haben jeweils ein MRP und eine Medikationsanalyse
# Tag 2: Encounter wird entlassen

# Ergebnis: Am Ende soll im Redcap nach Tag 2 für UKB-0001_1 bis UKB-0001_6 jeweils ein MRP und eine Medikationsanalyse vorliegen

if (exists("DEBUG_DAY")) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  # resources are a list of data tables from outside we want to change for the test
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pats <- pid1 # present at day 1

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

  runCodeForDebugDay(1, {
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1-1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 4: Encounter wird entlassen
    testDischarge(pid1)
  })

  duplicatePatients(6)

  runCodeForDebugDay(1, {
    #UKB-0001_1 -> Drug_Disease_Interaction             -> MedicationRequest - N02AA01 + Diagnosis - R10.0
    addDrugs("UKB-0001_1", "N02AA01")
    addConditions("UKB-0001_1", "R10.0")
    #UKB-0001_2 -> Drug_Drug_Interaction                -> MedicationRequests - N06AX22 + J01MA02
    addDrugs("UKB-0001_2", c("N06AX22", "J01MA02"))
    #UKB-0001_3 -> Drug_DrugGroup_Interaction           -> MedicationRequests - N06BA09 + C02KC01
    addDrugs("UKB-0001_3", c("N06BA09", "C02KC01"))
    #UKB-0001_4 -> Drug_Disease_Interaction (Proxy ATC) -> MedicationRequest - A10BA02 + N07BB03(ATC-Proxy)
    addDrugs("UKB-0001_4", c("A10BA02", "N07BB03"))
    #UKB-0001_5 -> Drug_Disease_Interaction (Pro.LOINC) -> MedicationRequest - C02KX01 + Observation - 14631-6
    addDrugs("UKB-0001_5", "C02KX01")
    addObservations("UKB-0001_5", "14631-6")
    #UKB-0001_6 -> Drug_Disease_Interaction (LOINC Cut) -> MedicationRequest - C03DA02 + Observation - 2823-3
    addDrugs("UKB-0001_6", "C03DA02")
    addObservations("UKB-0001_6", "2823-3", value = 12, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10)
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
