# Patient UKB-0001 dupliziert
# Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
#        Erster Patient mit Observation, Medication, Condition
#        Weiterer Versorgungsstellenkontakt mit zeitlichen Überschneidungen

#  zwei Einrichtungskontakte mit je zwei Abteilungskontakten mit je drei Versorgungsstellenkontakte
#  Versorgungsstellenkontakt ohne partof
#  Abteilungskontakt ohne partof
#  beide kein partof
#


#        Medikationsanalyse (diese kommt aus der zugehörigne change_REDCap_Data.R)
# Tag 2: Encounter wird entlassen

# Prüfung, ob die kalkulierten Encounter-Referenzen in den jeweiligen Spalten korrekt ermittelt werden
#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 1

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
    enc_ids <- testAdmission(pid1, "Raum 1", "Bett 1", "Station 1", -10)
    addDrugs(pid1, c("M04AA01"), day_offset = -9.59, period_type = "authoredon", encounter_id = enc_ids[[3]]) # Referenz auf Versorgungsstellenkontakt -> medreq_encounter_ref = Einrichtungskontakt
    addDrugs(pid1, c("M04AA02"), day_offset = -9.58, period_type = "authoredon", encounter_id = enc_ids[[2]]) # Referenz auf Abteilungskontakt -> medreq_encounter_ref = Einrichtungskontakt
    addDrugs(pid1, c("M04AA03"), day_offset = -9.57, period_type = "authoredon", encounter_id = enc_ids[[1]]) # Referenz auf Einrichtungskontakt -> medreq_encounter_ref = Einrichtungskontakt
    addDrugs(pid1, c("M04AA04"), day_offset = -9.56, period_type = "authoredon", encounter_id = NA) # ohne Referenz -> per Zeitstempel abgeleitete Ref auf Einrichtungskontakt in medreq_encounter_ref

    addDrugs(pid1, c("M04AA05"), day_offset = -9.49, period_type = "start", encounter_id = enc_ids[[3]]) # Referenz auf Versorgungsstellenkontakt
    addDrugs(pid1, c("M04AA06"), day_offset = -9.48, period_type = "start", encounter_id = enc_ids[[2]]) # Referenz auf Abteilungskontakt
    addDrugs(pid1, c("M04AA07"), day_offset = -9.47, period_type = "start", encounter_id = enc_ids[[1]]) # Referenz auf Einrichtungskontakt
    addDrugs(pid1, c("M04AA08"), day_offset = -9.46, period_type = "start", encounter_id = NA) # ohne Referenz -> "invalid" in medreq_encounter_ref

    addDrugs(pid1, c("M04AA09"), day_offset = -9.39, period_type = "timing_events", encounter_id = enc_ids[[3]]) # Referenz auf Versorgungsstellenkontakt
    addDrugs(pid1, c("M04AA10"), day_offset = -9.38, period_type = "timing_events", encounter_id = enc_ids[[2]]) # Referenz auf Abteilungskontakt
    addDrugs(pid1, c("M04AA11"), day_offset = -9.37, period_type = "timing_events", encounter_id = enc_ids[[1]]) # Referenz auf Einrichtungskontakt
    addDrugs(pid1, c("M04AA12"), day_offset = -9.36, period_type = "timing_events", encounter_id = NA) # ohne Referenz -> "invalid" in medreq_encounter_ref

    addDrugs(pid1, c("M04AA13"), day_offset = -9.29, period_type = "all_timestamps_NA", encounter_id = enc_ids[[3]]) # Referenz auf Versorgungsstellenkontakt
    addDrugs(pid1, c("M04AA14"), day_offset = -9.28, period_type = "all_timestamps_NA", encounter_id = enc_ids[[2]]) # Referenz auf Abteilungskontakt
    addDrugs(pid1, c("M04AA15"), day_offset = -9.27, period_type = "all_timestamps_NA", encounter_id = enc_ids[[1]]) # Referenz auf Einrichtungskontakt
    addDrugs(pid1, c("M04AA16"), day_offset = -9.26, period_type = "all_timestamps_NA", encounter_id = NA) # ohne Referenz -> "invalid" in medreq_encounter_ref

    testTransferWardInternal(pid1, "Raum 2", "Bett 2", "Station 1", -8.5)
    addObservation(pid1, "14933-1", day_offset = -8.39, value = 1000, unit = "umol/L", encounter_id = enc_ids[[3]]) # Referenz auf Versorgungsstellenkontakt
    addObservation(pid1, "14933-2", day_offset = -8.38, value = 1001, unit = "umol/L", encounter_id = enc_ids[[2]]) # Referenz auf Abteilungskontakt
    addObservation(pid1, "14933-3", day_offset = -8.37, value = 1002, unit = "umol/L", encounter_id = enc_ids[[1]]) # Referenz auf Einrichtungskontakt
    addObservation(pid1, "14933-4", day_offset = -8.36, value = 1003, unit = "umol/L", encounter_id = NA) # # ohne Referenz -> per Zeitstempel abgeleitete Ref auf Einrichtungskontakt in obs_encounter_ref

    testTransferWardInternal(pid1, "Raum 3", "Bett 3", "Station 1", -7.0)
    addProcedures(pid1, c("8-151.1"), day_offset = -6.89, encounter_id = enc_ids[[3]]) # Referenz auf Versorgungsstellenkontakt
    addProcedures(pid1, c("8-151.2"), day_offset = -6.88, encounter_id = enc_ids[[2]]) # Referenz auf Abteilungskontakt
    addProcedures(pid1, c("8-151.3"), day_offset = -6.87, encounter_id = enc_ids[[1]]) # Referenz auf Einrichtungskontakt
    addProcedures(pid1, c("8-151.4"), day_offset = -6.86, encounter_id = NA) # ohne Referenz -> per Zeitstempel abgeleitete Ref auf Einrichtungskontakt in obs_encounter_ref

    enc_level_2_id <- testTransferWardDepartment(pid1, "Raum 4", "Bett 4", "Station 2", -5.5)
    dt_enc <- testGetResourceTable("Encounter")
    dt_enc[enc_id %in% enc_level_2_id, enc_partof_ref := NA_character_]
    testSetResourceTable("Encounter", dt_enc)

    enc_level_3_id <- testTransferWardInternal(pid1, "Raum 5", "Bett 5", "Station 2", -4.0)
    dt_enc <- testGetResourceTable("Encounter")
    dt_enc[enc_id %in% enc_level_3_id, enc_partof_ref := NA_character_]
    testSetResourceTable("Encounter", dt_enc)

    testTransferWardInternal(pid1, "Raum 6", "Bett 6", "Station 2", -2.5)
    testDischarge(pid1)
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
  return(resource_tables)
}
