# Patient UKB-0001
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
# Tag 2: Entlassung
# Tag 3: Wiederaufnahme Versorgungsstellenkontakt auf Station 2 Zimmer 1-2, Bett 1-2

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 3

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
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 4: Encounter wird entlassen
    testDischarge(pid1)
  })
  runCodeForDebugDay(3, {
    # Patient 1 Tag 5: Neuer Encounter und neuer Versorgungsstellenkontakt auf gleicher IP-Station 1 Zimmer 1-3, Bett 1-3
    testAdmission(pid1, "Raum 1-2", "Bett 1-2", "Station 2")
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
