# Test für die Clusterung von Diagnosen bei selber Medikation in Drug Disease
# Möglichkeit 1. gleiche Medikation + gleiche Diagnose + unterschiedliches Diagnose-Cluster
# Möglichkeit 2. gleiche Medikation + unterschiedliche Diagnose + gleiches Diagnose-Cluster

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

  duplicatePatients(9)

  runCodeForDebugDay(1, {

    ################
    # Drug_Disease #
    ################

    # Drug_Disease -> No Cluster
    # MedicationRequest - N02BB02 + Condition E80.2
    addDrugs("UKB-0001_1", "N02BB02")
    addConditions("UKB-0001_1", c("E80.2"))

    # Drug_Disease -> Same Drug and ICD Code with same Diagnosis Cluster
    # MedicationRequest - N02BB02 + 2x Condition E80.2
    addDrugs("UKB-0001_2", "N02BB02")
    addConditions("UKB-0001_2", c("E80.2", "E80.2"))

    # Drug_Disease -> Same Drug and ICD Code with different Diagnosis Cluster (both with validity day = inf)
    # MedicationRequest - N02BB02 + Condition D70.12
    addDrugs("UKB-0001_3", "N02BB02")
    addConditions("UKB-0001_3", c("D70.12"))

    # Drug_Disease -> Same Drug and ICD Code with different Diagnosis Cluster (one with validity day = 30 and one with inf)
    # MedicationRequest - N02BB02 + Condition D61.10
    addDrugs("UKB-0001_4", "N02BB02")
    addConditions("UKB-0001_4", c("D61.10"))

    # Drug_Disease -> Same Drug and different ICD Codes with same Diagnosis Cluster
    # MedicationRequest - N02BB02 + Condition D47.1 D47.4
    addDrugs("UKB-0001_5", "N02BB02")
    addConditions("UKB-0001_5", c("D47.1", "D47.4"))

    # Drug_Disease -> Same Drug and different ICD Codes with 1 same and 1 different Diagnosis Cluster (both with validity day = inf)
    # MedicationRequest - N02BB02 + Condition D70.12 D47.1
    addDrugs("UKB-0001_6", "N02BB02")
    addConditions("UKB-0001_6", c("D70.12", "D47.1"))

    # Drug_Disease -> Same Drug and different ICD Codes with 1 same and 1 different Diagnosis Cluster (one with validity day = 30 and one with inf)
    # MedicationRequest - N02BB02 + Condition D61.10 D47.1
    addDrugs("UKB-0001_7", "N02BB02")
    addConditions("UKB-0001_7", c("D61.10", "D47.1"))

    # Drug_Disease -> Same Drug and different ICD Codes with 2 same and 1 different Diagnosis Cluster (all with validity day = inf)
    # MedicationRequest - N02BB02 + Condition D70.12 D47.1 D47.4
    addDrugs("UKB-0001_8", "N02BB02")
    addConditions("UKB-0001_8", c("D70.12", "D47.1", "D47.4"))

    # Drug_Disease -> Same Drug and different ICD Codes with 2 same and 1 different Diagnosis Cluster (all with validity day = inf) and 1 without Cluster
    # MedicationRequest - N02BB02 + Condition D70.12 D47.1 D47.4 E80.2
    addDrugs("UKB-0001_9", "N02BB02")
    addConditions("UKB-0001_9", c("D70.12", "D47.1", "D47.4", "E80.2"))
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
