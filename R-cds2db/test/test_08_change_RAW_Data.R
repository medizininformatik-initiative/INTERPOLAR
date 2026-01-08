# Patient UKB-0001 dupliziert
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
#        Erster Patient hat nichts, alle anderen haben jeweils ein MRP und eine
#        Medikationsanalyse (diese kommt aus der zugehörigne change_REDCap_Data.R)
# Tag 2: Encounter wird entlassen

# Prüfung wie sich der Code verhält, wenn bestimmte Diagnosen/Medikamente etc. mehrfach/doppelt vorkommen,
# die ein einzelnes MRP erzeugen.

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
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 2: Encounter wird entlassen
    testDischarge(pid1)
  })

  duplicatePatients(17)

  runCodeForDebugDay(1, {

    ################
    # Drug_Disease #
    ################

    # Zeile 445 aus Drug Disease Originalliste - mehrere Diagnosen (auch doppelt) + mehrere Proxy-Medikationen (auch doppelt) + mehrer LOINC (auch mehrfach) an verschiedene Zeitpunkte
    pid <- addDrugs("UKB-0001_1", "C09DA06")
    addConditions(pid, c("M10.00", "M10.00", "M10.01", "M14.00"))
    addDrugs(pid, c("M04AA01", "M04AA01", "M04AA51"))
    addDrugs(pid, c("M04AA01"))
    addDrugs(pid, c("M04AA03"))
    addDrugs(pid, c("C09DA06", "C09DA06"))

    # Zeile 1429 aus Drug Disease Originalliste -  Weiteres Drug-Disease MRP mit Diagnose/Procedure
    addDrugs(pid, c("B01AB01",	"B01AB01", "B01AB51"))
    addDrugs(pid, c("B05CX05",	"B01AB51"))
    addProcedures(pid, c("1-204.2", "1-204.2", "8-151.4"))
    addProcedures(pid, c("8-151.4"))
    addConditions(pid, "G97.0")
    addConditions(pid, "G97.0")

    pid <- addDrugs("UKB-0001_2", "C09DA06")
    addConditions(pid, c("M10.00", "M10.00", "M10.01", "M14.00"))

    pid <- addDrugs("UKB-0001_3", "C09DA06")
    addDrugs(pid, c("M04AA01", "M04AA01", "M04AA51"))

    pid <- addDrugs("UKB-0001_4", "C09DA06")
    addDrugs(pid, c("M04AA03"))

    pid <- addDrugs("UKB-0001_5", "C09DA06") # this Observation should be create a MRP because it's not older than 7 days
    addObservation(pid, "14933-6", day_offset = -0.6, value = 1000, unit = "umol/L")

    pid <- addDrugs("UKB-0001_6", "C09DA06") # this Observation should be create a MRP because it's not older than 7 days
    addObservation(pid, "14933-6", day_offset = -5.6, value = 1000, unit = "umol/L")

    pid <- addDrugs("UKB-0001_7", "C09DA06") # this Observation should be ignored because it's older than 7 days
    addObservation(pid, "14933-6", day_offset = -7.6, value = 1000, unit = "umol/L")

    # Zeile 1004 aus Drug Disease Originalliste - mehrere ATC1 (in selber/unterschiedlichen Request) + mehrer OPS-Codes + Diagnose
    pid <- addDrugs("UKB-0001_8", c("B01AB01",	"B01AB01", "B01AB51"))
    addDrugs(pid, c("B05CX05",	"B01AB51"))
    addProcedures(pid, c("1-204.2", "1-204.2", "8-151.4"))
    addProcedures(pid, c("8-151.4"))
    addConditions(pid, "G97.0")

    pid <- addDrugs("UKB-0001_9", "B01AB51")
    addDrugs(pid, "B01AB51")
    addProcedures(pid, c("1-204.2", "1-204.2", "8-151.4"))
    addProcedures(pid, c("8-151.4"))
    addConditions(pid, "G97.0")

    pid <- addDrugs("UKB-0001_10", "B01AB51")
    addProcedures(pid, c("1-204.2", "1-204.2", "8-151.4"))

    # ATC und Diagnose mit mehreren Zeilen in der nach ICD gesplitteten Drug Disease Liste
    pid <- addDrugs("UKB-0001_11", "L04AX03")
    addDrugs(pid, "L04AX03")
    addDrugs(pid, "L04AX03")
    addConditions(pid, "J32.0")

    # ATC und mehrere Diagnosen mit mehreren Zeilen in der nach ICD gesplitteten Drug Disease Liste
    pid <- addDrugs("UKB-0001_12", "L01XX05")
    addConditions(pid, c("D69.58", "D69.61"))

    #############################
    ## Test for MRP Clustering ##
    #############################

    # Drug_Disease -> Drug  + simple Disease
    # MedicationRequest - M01AB11 + Diagnosis - I60/I60.1 -> 1 MRP mit zwei Diagnose-Codes und zwei Diagnose Cluster
    pid <- addDrugs("UKB-0001_13", "M01AB11")
    addConditions(pid, "I60")
    addConditions(pid, "I60.1")

    # Drug_Disease -> Drug  + simple Disease
    # MedicationRequest - C10BX02 + Diagnosis - K72.0 -> 2 MRP mit zwei zwei Diagnose Cluster und 2 ATC Displays
    pid <- addDrugs("UKB-0001_14", "C10BX02")
    addConditions(pid, "K72.0")

    # Drug_Disease -> Drug  + simple Disease
    # MedicationRequest - M01AB68 + Diagnosis - I60.5 -> 1 MRP mit zwei Diagnose Cluster
    pid <- addDrugs("UKB-0001_15", "M01AB68")
    addConditions(pid, "I60.5")

    # Drug_Disease -> Drug  + simple Disease
    # MedicationRequest - R03CC03 + Diagnosis - I47 -> 1 MRP mit zwei Diagnose Cluster
    pid <- addDrugs("UKB-0001_16", c("R03CC03", "R03CC53"))
    addConditions(pid, "I47")

    # Drug_Disease -> Drug  + simple Disease
    # MedicationRequest - R03CC53 + Diagnosis - I47 -> 1 MRP mit zwei Diagnose Cluster
    pid <- addDrugs("UKB-0001_17", "R03CC53")
    addConditions(pid, "I47")
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
