# Test, ob wirklochnur der letzte Laborwert bei Drug-Disease ein MRP triggert.
# Sind die Observations gleichzeitig, dann gibt es ein MRP, wenn mind. eine Observation triggert.

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 2

# Activate if only a specific debug day should be run
#DEBUG_RUN_SINGLE_DAY_ONLY <- 2

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

###############################
# End Define global variables #
###############################


if (exists("TOOLCHAIN_DAY")) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  # resources are a list of data tables from outside we want to change for the test
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pats <- pid1 # present at day 1

  if (TOOLCHAIN_DAY > 1) {
    if (exists("DEBUG_RUN_SINGLE_DAY_ONLY")) {
      etlutils::dbReset(c("db_log.dp_mrp_calculations", "db_log.retrolektive_mrpbewertung_fe"))
    }
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
  current_debug_day <- TOOLCHAIN_DAY

  runCodeForDebugDay(1, {
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 2: Encounter wird entlassen
    testDischarge(pid1)
  })

  duplicatePatients(12)

  runCodeForDebugDay(1, {

    #########################################################################
    # Drug_Disease mit Beachtung des letzten Laborwertes, der triggern muss #
    #########################################################################

    ##
    # A. cutoff absolute: alle Observations finden zu unterschiedlichen Zeiten statt
    ##

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_1", "N02BA01")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.01, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.02, value = 0.052, unit = "mmol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.03, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.04, value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.05, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid,  "1975-2", day_offset = -0.5 + 0.06, value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.07, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "35194-0", day_offset = -0.5 + 0.08, value =  1000, unit = "mg/dL") # letzter Wert triggert ein MRP

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_2", "N02BA01")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.01, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.02, value = 0.052, unit = "mmol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.03, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.04, value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.05, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid,  "1975-2", day_offset = -0.5 + 0.06, value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.07, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "35194-0", day_offset = -0.5 + 0.08, value =  1000, unit = "mg/dL")
    addObservation(pid, "35194-0", day_offset = -0.5 + 0.09, value = "bla", unit = "mg/dL") # letzter Wert ist ungültig -> wirklich letzter Wert muss der davor sein -> der triggert ein MRP

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_3", "N02BA01")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.01, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.02, value = 0.052, unit = "mmol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.03, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.04, value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.05, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid,  "1975-2", day_offset = -0.5 + 0.06, value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.07, value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "35194-0", day_offset = -0.5 + 0.08, value =  1000, unit = "mg/dL")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.09, value =    51, unit = "umol/L") # letzer Wert ist gültig, aber triggert kein MRP, weil Wert zu niedrig -> ingsgesamt kein MRP

    ##
    # B. wie A. aber alle Observations finden zur gleichen Zeit statt -> alle MRP sind die letzten -> triggert ein Wert, dann gibt es ein MRP
    ##

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_4", "N02BA01")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", value = 0.052, unit = "mmol/L")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid,  "1975-2", value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "35194-0", value =  1000, unit =  "mg/dL") #  mehrere Werte triggern ein MRP

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_5", "N02BA01")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", value = 0.052, unit = "mmol/L")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid,  "1975-2", value =    52, unit = "umol/L")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "35194-0", value =  1000, unit =  "mg/dL")
    addObservation(pid, "35194-0", value = "bla", unit =  "mg/dL") # Wert ungültig -> sollte ignoriert werden

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_6", "N02BA01")
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", value = 0.052, unit = "mmol/L") # MRP
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "14631-6", value =    52, unit = "umol/L") # MRP
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid,  "1975-2", value =    52, unit = "umol/L") # MRP
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP
    addObservation(pid, "35194-0", value =  1000, unit =  "mg/dL") # MRP
    addObservation(pid, "14631-6", value =    51, unit = "umol/L") # kein MRP

    ##
    # C. reference range: alle Observations finden zu unterschiedlichen Zeiten statt
    ##

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_7", "C03DA02")
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.01, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid,  "2823-3", day_offset = -0.5 + 0.02, value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.03, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.04, value =  4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.05, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.06, value =  3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2)
    # anderes MRP für dasselbe Medikament
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.05, value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.06, value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_8", "C03DA02")
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.01, value =     1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid,  "2823-3", day_offset = -0.5 + 0.02, value =    12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.03, value =     1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.04, value =     4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.05, value =     1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.06, value =     3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.07, value = "bla", unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # ungültiger Wert
    # anderes MRP für dasselbe Medikament
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.06, value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.07, value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_9", "C03DA02")
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.01, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid,  "2823-3", day_offset = -0.5 + 0.02, value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.03, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.04, value =  4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.05, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.06, value =  3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2)
    addObservation(pid, "39789-3", day_offset = -0.5 + 0.07, value =  1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value =  2) # kein MRP
    # anderes MRP für dasselbe Medikament
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.05, value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.06, value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "2951-2", day_offset = -0.5 + 0.07, value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP

    ##
    # D. wie C. aber alle Observations finden zur gleichen Zeit statt -> alle MRP sind die letzten -> triggert ein Wert, dann gibt es ein MRP
    ##

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_10", "C03DA02")
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "2823-3", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    # anderes MRP für dasselbe Medikament
    addObservation(pid, "2951-2", value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP
    addObservation(pid, "2951-2", value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_11", "C03DA02")
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "2823-3", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    addObservation(pid, "39789-3", value = "bla", unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # ungültiger Wert
    # anderes MRP für dasselbe Medikament
    addObservation(pid, "2951-2", value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP
    addObservation(pid, "2951-2", value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "2951-2", value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # ungültiger Wert

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_12", "C03DA02")
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "2823-3", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    addObservation(pid, "39789-3", value = 2, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2)
    addObservation(pid, "39789-3", value = 1, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP
    # anderes MRP für dasselbe Medikament
    addObservation(pid, "2951-2", value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP
    addObservation(pid, "2951-2", value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "2951-2", value = 7, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP

  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
