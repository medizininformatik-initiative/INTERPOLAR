# Test der checkt, ob die retrolektiven MRP Bewertungen im Redcap korrekt geleert werden
# Checkt den zeitlichen Verlauf der MRP Bewertungen, wenn Patienten auf Stationen kommen, die in verschiedenen Phasen liegen
# Patienten auf PhaseBTest und PhaseB gleichzeitig -> retrolektiven MRP Bewertungen für Patienten auf PhaseBTest werden nicht ins Redcap geschrieben
# Patient erst auf PhaseBTest und erst nach Entlassung ein andere Patient auf PhaseB ->
# retrolektiven MRP Bewertungen für Patient auf PhaseBTest werden in Redcap geleert

# Wichtig: es sind drei Anpassungen in den Skripten nötig, damit der Verlauf korrekt funktioniert:
# 1: In dem Skript lib_envir, Zeile 46 hiermit ersetzen:
# if (!exists(variable_name, envir = envir)) {
#   assign(variable_name, constants[[variable_name]], envir = envir)
# }
# 2: In dem Skript 00_Lib_MRP_Data_Preparation, Zeile 258 auskommentieren:
#encounters <- encounters[!(study_phase %in% "PhaseB" & enc_period_end > (getCurrentDate() - DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS))]
# 3: in dataprocessor toml:
#WARDS_PHASE_B_TEST = ["Station 1"] # Study phase A but with test calculation for retrolective MRP evaluations
#WARDS_PHASE_B = ["Station 2"] # Study phase B with regular calculation for retrolective MRP evaluations 14 days

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 4

# Activate if only a specific debug day should be run
#DEBUG_RUN_SINGLE_DAY_ONLY <- 2

# Muss auf 0 gesetzt werden, damit auch für PhaseB Patienten MRP sofort berechnet werden
DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS <- 0

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


#DEBUG_DONT_DELETE_REDCAP_DATA <- TRUE
#DEBUG_DONT_DELETE_DB_DATA <- TRUE
###############################
# End Define global variables #
###############################

if (exists("DEBUG_DAY")) {
  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  # resources are a list of data tables from outside we want to change for the test
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pid2 <- "UKB-0002"
  pid3 <- "UKB-0003"
  pid4 <- "UKB-0004"
  pats <- c(pid1, pid2, pid3, pid4) # present at day 1

  if (DEBUG_DAY == 1  && !etlutils::isDefinedAndTrue("DEBUG_DONT_DELETE_DB_DATA")) {
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
    # Die Stationen werden den Phasen zugeordnet.Das ist notwenig, damit diese dann nicht über die toml Dateien geändert werden
    assign("WARDS_PHASE_A", c("Station 2", "Station 3"), envir = .GlobalEnv) # Study phase A without retrolective MRP evaluations
    assign("WARDS_PHASE_B_TEST", c("Station 1"), envir = .GlobalEnv) # Study phase A without retrolective MRP evaluations
    assign("WARDS_PHASE_B", c(""), envir = .GlobalEnv) # Study phase A without retrolective MRP evaluations

    # Aufnahme von Patient 1 auf Station 1 (PhaseBTest)
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1") # PhaseBTest
    # Aufnahme von Patient 4 auf Station 3 (PhaseA)
    testAdmission(pid4, "Raum 1-1", "Bett 1-1", "Station 3") # PhaseA
  })
  runCodeForDebugDay(2, {
    # Patient 1 wird entlassen
    testDischarge(pid1)
  })
  runCodeForDebugDay(3, {
    assign("WARDS_PHASE_A", c("Station 3"), envir = .GlobalEnv)
    assign("WARDS_PHASE_B", c("Station 2"), envir = .GlobalEnv)
    # Patient 1 Tag 2: Versorgungsstellenkontakt auf nicht-IP-Station Zimmer Nicht-IP-Raum 1-1, Bett Nicht-IP-Bett 1-1
    #testTransferWardInternal(pid1, "Raum 2-1", "Bett 2-1", "Station 1")
    testAdmission(pid2, "Raum 1-2", "Bett 1-2", "Station 1") # PhaseBTest
    testAdmission(pid3, "Raum 1-1", "Bett 1-1", "Station 2") # PhaseB
  })

  runCodeForDebugDay(4, {
    # Patient 2-4 werden entlassen
    testDischarge(pid2)
    testDischarge(pid3)
    testDischarge(pid4)
  })

  runCodeForDebugDay(1, {
    # MRP für Patient 4
    addDrugs(pid4, "C10BX02")
    addConditions(pid4, "K72.0")
    # MRP für Patient 1
    addDrugs(pid1, "C10BX02")
    addConditions(pid1, "K72.0")
  })

  runCodeForDebugDay(3, {
    # MRP für Patient 2
    addDrugs(pid2, c("J04AB02", "J05AP52"))

    # MRP für Patient 3
    addDrugs(pid3, "R03CC53")
    addConditions(pid3, "I47")
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
