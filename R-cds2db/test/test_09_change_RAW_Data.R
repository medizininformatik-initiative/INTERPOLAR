# Test für MedicationRequest mit medreq_doseinstruc_timing_repeat_boundsperiod_start
# (und eventuell medreq_doseinstruc_timing_repeat_boundsperiod_end) und gleichzeitig
# oder alleine medreq_doseinstruc_timing_event oder medreq_authoredon

# Patient UKB-0001 dupliziert
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
#        Originaler Patient hat nichts, alle duplizierten haben jeweils ein MRP
#        Medikationsanalyse (diese kommt aus der zugehörigne change_REDCap_Data.R)
#        Besonderheit: Alle Patienten haben verschiedene MRP, weil bei allen
#                      MedicationRequest und deren Start und Ende gebraucht werden.
#
#
# Tag 2: Encounter wird entlassen

# Prüfung wie sich der Code verhält, wenn bestimmte Diagnosen/Medikamente etc. mehrfach/doppelt vorkommen,
# die ein einzelnes MRP erzeugen.

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 2

DEBUG_DAYS_OFFSET <- 5

# # Activate if only a specific debug day should be run
# DEBUG_RUN_SINGLE_DAY_ONLY <- 2

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

  duplicatePatients(7)

  runCodeForDebugDay(1, {

    ################
    # Drug_Drug #
    ################

    # immer zwei MRPS, weil beide Kombinationen in Drug Drug und in Drug Drug Group vorkommen (wird noch bereinigt -> dann nur noch 1)
    # Drug_Drug -> ATCs - N06AX22 + J01MA02

    # MRP, weil beide Medikamente nur ein Start aber kein Ende haben (NA) und somit
    # zum Zeitpunkt der Analyse als weiterhin aktiv gelten
    pid <- "UKB-0001_1"
    addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "start")
    addDrugs(pid, "J01MA02", day_offset =  1.1, period_type = "start")

    # MRP, weil das Ende beider Medikamente durch addDrugs(...) auf 5 Tage nach dem
    # Start gesetzt wird und sich somit die Einnahmezeitpunkte überschneiden
    pid <- "UKB-0001_2"
    addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "start_and_end")
    addDrugs(pid, "J01MA02", day_offset =  1.1, period_type = "start_and_end")

    # MRP, weil das Ende beider Medikamente durch addDrugs(...) auf 5 Tage nach dem
    # Start gesetzt wird und sich somit die Einnahmezeitpunkte überschneiden und das
    # event als Einzelgabe in diesem Fall ignoriert wird.
    pid <- "UKB-0001_3"
    addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "start_and_end_and_timing_event")
    addDrugs(pid, "J01MA02", day_offset =  1.1, period_type = "start_and_end_and_timing_event")

    # kein MRP, weil jede Gabe einzeln an verschiedenen Tagen
    pid <- "UKB-0001_4"
    addDrugs(pid, "N06AX22", day_offset = 2.1, period_type = "timing_event")
    addDrugs(pid, "J01MA02", day_offset = 3.2, period_type = "timing_event")

    # MRP, weil beide Gaben am gleichen Tag wie auch die Medikationsanaylse, aber beide vorher
    pid <- "UKB-0001_5"
    addDrugs(pid, "N06AX22", day_offset = 4.1, period_type = "timing_event")
    addDrugs(pid, "J01MA02", day_offset = 4.2, period_type = "timing_event")

    # MRP, weil das erste Medikament nun mehrfach über 3 Tage verabreicht wird
    # (die 3 Tage stehen hart in addDrugs(...))
    pid <- "UKB-0001_6"
    addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "timing_events")
    addDrugs(pid, "J01MA02", day_offset =  4.1, period_type = "timing_event")

    # MRP, weil das erste Medikament bis day_offset 5.7 gegeben wird (-0.3 + 3 * 2 Tage)
    # und das zweite kurz vorder Medikationsanalyse an startet, die bei day_offset 4.4 startet)
    # (die 2 Tage sind die Pause zw. den Events; das kommt aus addDrugs(...))
    pid <- "UKB-0001_7"
    addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "timing_events")
    addDrugs(pid, "J01MA02", day_offset =  4.1, period_type = "timing_events")

    # # kein MRP, weil das erste Medikament bis day_offset 2.7 gegeben wird (-0.3 + 3 Tage)
    # # und das zweite kurz danach startet
    # pid <- "UKB-0001_8"
    # addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "timing_events")
    # addDrugs(pid, "J01MA02", day_offset =  5.2, period_type = "timing_events")
    #
    # # MRP, weil das erste Medikament bis day_offset 2.7 gegeben wird (-0.3 + 3 Tage)
    # # und das zweite kurz davor startet, aber über authoredon
    # pid <- "UKB-0001_9"
    # addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "timing_events")
    # addDrugs(pid, "J01MA02", day_offset =  2.6, period_type = "authoredon")
    #
    # # kein MRP, weil das erste Medikament bis day_offset 2.7 gegeben wird (-0.3 + 3 Tage)
    # # und das zweite gar keinen Zeitstempel hat
    # pid <- "UKB-0001_10"
    # addDrugs(pid, "N06AX22", day_offset = -0.3, period_type = "timing_events")
    # addDrugs(pid, "J01MA02", period_type = "all_timestamps_NA")

  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
