# Patient UKB-0001 6x dupliziert -> UKB-0001_1 bis UKB-0001_6
# Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
#        Erster Patient hat nichts, alle anderen haben jeweils ein MRP und eine
#        Medikationsanalyse (diese kommt aus der zugehörigne change_REDCap_Data.R)
# Tag 2: Encounter wird entlassen

# Ergebnis: Am Ende soll im Redcap nach Tag 2 für UKB-0001_1 bis UKB-0001_6 jeweils ein MRP und eine Medikationsanalyse vorliegen

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

WARDS_PHASE_B_TEST <- c("Station 1-1")

###############################
# End Define global variables #
###############################


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
  current_debug_day <- DEBUG_DAY

  runCodeForDebugDay(1, {
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1-1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 2: Encounter wird entlassen
    testDischarge(pid1)
  })

  duplicatePatients(20)

  runCodeForDebugDay(1, {

    ################
    # Drug_Disease #
    ################

    # TODO: Test mit mehreren Conditions gleichzeitig und mehrere davon mit identischem Code

    # Drug_Disease -> simple Drug + simple Disease
    # Line 114850 -> MedicationRequest - N02AA01 + Diagnosis - R10.0
    pid <- addDrugs("UKB-0001_1", "N02AA01")
    addConditions(pid, "R10.0")

    # Drug_Disease -> Drug SY + simple Disease
    # MedicationRequest - L01XK52 + Diagnosis - O20.0
    pid <- addDrugs("UKB-0001_2", "L01XK52")
    addConditions(pid, "O20.0")

    # UKB-0001_3 -> Drug_Disease -> Proxy ATC
    # Line 71835 -> MedicationRequest - C09DA06 + M04AA01 (ATC-Proxy)
    addDrugs("UKB-0001_3", c("C09DA06", "M04AA01"))

    # Drug_Disease -> Proxy LOINC primary, > ULN
    # Line 76539 -> MedicationRequest - C03DA02 + Observation - 2823-3
    pid <- addDrugs("UKB-0001_4", "C03DA02")
    addObservation(pid, "2823-3", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 104451 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_5", "C03DA02")
    addObservation(pid, "2951-2", value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC primary, > 5 * ULN
    # Line 8096 -> MedicationRequest - J01MA14 + Observation - 1742-6
    pid <- addDrugs("UKB-0001_6", "J01MA14")
    addObservation(pid, "1742-6", day_offset = -0.5, value = 60.01, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC secondary, > 5 * ULN
    # Line 8096 -> MedicationRequest - J01MA14 + Observation - 1743-4
    pid <- addDrugs("UKB-0001_7", "J01MA14")
    addObservation(pid, "1743-4", value = 60, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, no unit conversion
    # MedicationRequest - L02BX03 + Observation - 14631-6 > 51,312 umol//L
    pid <- addDrugs("UKB-0001_8", "L02BX03")
    addObservation(pid, "14631-6", value = 52, unit = "umol/L")

    # Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # Line 133 -> MedicationRequest - C02KX01 + Observation - 14631-6  > 51,312 umol//L
    pid <- addDrugs("UKB-0001_9", "N02BA01")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.01, value = 0.052, unit = "mmol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.02, value = 52, unit = "umol/L")
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.03, value = 52, unit = "mU/L") # kein MRP, ivalide Einheit
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.04, value = 51, unit = "umol/L") # kein MRP, liegt unter Cutoff
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.05, value = 52, unit = "blabla") # kein MRP, keine gültige Unit
    addObservation(pid, "14631-6", day_offset = -0.5 + 0.06, value = 52, unit = NA) # kein MRP, keine gültige Unit
    addObservation(pid, "1975-2", day_offset = -0.5 + 0.07, value = 52, unit = "umol/L")
    addObservation(pid, "35194-0", day_offset = -0.5 + 0.08, value = 1000, unit = "mg/dL")
    addObservation(pid, "35194-0", day_offset = -0.5 + 0.09, value = "blub", unit = "mg/dL") # kein MRP, keine gültiger Value

    # Drug_Disease -> Proxy LOINC secondary, cutoff absolute, no unit conversion
    # MedicationRequest - L02BX03 + Observation - 1975-2 > 51,312 umol//L
    pid <- addDrugs("UKB-0001_10", "L02BX03")
    addObservation(pid, "1975-2", value = 52, unit = "umol/L")

    # Drug_Disease -> Proxy LOINC secondary, cutoff absolute, simple SI unit conversion
    # MedicationRequest - L02BX03 + Observation - 1975-2 > 51,312 umol//L
    pid <- addDrugs("UKB-0001_11", "L02BX03")
    addObservation(pid, "1975-2", value = 0.052, unit = "mmol/dL")

    # Drug_Disease -> Proxy LOINC secondary, cutoff absolute, complex unit conversion
    # MedicationRequest - L02BX03 + Observation - 1975-2 > 51,312 umol//L with umol/L = 17.1 * mg/dL
    pid <- addDrugs("UKB-0001_12", "L02BX03")
    addObservation(pid, "1975-2", value = 1000, unit = "mg/dL")

    # Drug_Disease -> Proxy LOINC secondary, cutoff absolute, simple non-SI and complex unit conversion
    # MedicationRequest - L02BX03 + Observation - 1975-2 > 51,312 umol//L with umol/L = 17.1 * mg/dL
    pid <- addDrugs("UKB-0001_13", "L02BX03")
    addObservation(pid, "1975-2", value = 10, unit = "g/L")

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_14", "C03DA02")
    addObservation(pid, "2823-3", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # MRP, weil > ULN
    addObservation(pid, "2951-2", value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # MRP, weil < LLN
    addObservation(pid, "1111-1", value = 3, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10) # kein MRP, weil ungültiger LOINC
    addObservation(pid, "39789-3", value = 4, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # MRP, weil > ULN
    addObservation(pid, "39789-3", value = 3, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # MRP, weil > ULN
    addObservation(pid, "39789-3", value = 2, unit = "mg/dL", referencerange_low_value = 1, referencerange_high_value = 2) # kein MRP, weil = ULN

    # Drug_Disease -> Proxy LOINC secondary, cutoff absolute, decimal unit conversion
    # Line 103536 -> MedicationRequest - N05AB10 + Observation - 26464-8 (Proxy for 6690-2, 10*9/L Leukozyten < 2,0)
    pid <- addDrugs("UKB-0001_15", "N05AB10")
    addObservation(pid, "26464-8", value = 999, unit = "10*6/L") # kein MRP, nicht in WP 7 Liste

    # Drug_Disease -> Proxy LOINC primary, < LLN
    # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    pid <- addDrugs("UKB-0001_16", "C03DA02")
    addObservation(pid, "2951-2", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_low_code = 10) # kein MRP, invalid code
    addObservation(pid, "2951-2", value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_low_code = "value") # kein MRP, invalid code
    addObservation(pid, "2951-2", value = 12, unit = "mg/dL", referencerange_low_value = "value", referencerange_low_code = "value") # kein MRP, invalid value and code
    addObservation(pid, "2951-2", value = 12, unit = "mg/dL", referencerange_low_value = "g/L", referencerange_low_code = "g/L") # kein MRP, invalid value

    ###############
    # Drug - Drug #
    ###############

    # Drug_Drug_Interaction                  -> MedicationRequests - N06AX22 + J01MA02
    addDrugs("UKB-0001_17", c("N06AX22", "J01MA02"))

    # Drug_Drug_Interaction                  -> MedicationRequests - J04AB02 + J05AP52
    addDrugs("UKB-0001_18", c("J04AB02", "J05AP52"))

    # Drug_Drug_Interaction                  -> MedicationRequests - A02BD04 + A03FA03 ATC kommen jeweils gespiegelt vor in ATC und ATC2
    addDrugs("UKB-0001_19", c("A02BD04", "A03FA03")) #  2 MRPS, weil diese Kombination in Drug Drug und Drug DrugGroup vorkommt


    ####################
    # Drug - DrugGroup #
    ####################

    # Drug_DrugGroup_Interaction             -> MedicationRequests - N06BA09 + C02KC01
    addDrugs("UKB-0001_20", c("N06BA09", "C02KC01"))

  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
