# Patient UKB-0001 dupliziert
# Tag 1: Versorgungsstellenkontakt auf Station 1 Zimmer 1-1, Bett 1-1
#        Erster Patient hat nichts, alle anderen haben jeweils ein MRP und eine
#        Medikationsanalyse (diese kommt aus der zugehörigen change_REDCap_Data.R)
# Tag 2: Encounter wird entlassen

# Prüfung wie sich der Code verhält, wenn bestimmte Diagnosen/Medikamente etc. mehrfach/doppelt vorkommen,
# die ein einzelnes MRP erzeugen.
# Weitere Prüfung, wie sich der Code verhält, wenn Überschneidungen bei den
# Medikamentenverordnungen auftreten.

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 4

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
  runCodeForDebugDay(4, {
    # Patient 1 Tag 2: Encounter wird entlassen
    testDischarge(pid1)
  })

  duplicatePatients(5, 15)

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
    addObservation(pid, "14933-6", value = 1000, unit = "umol/L")
    addObservation(pid, "14933-6", day_offset = -0.5, value = 1000, unit = "umol/L")
    addObservation(pid, "14933-6", value = 2000, unit = "umol/L")
    addObservation(pid, "12980-9", value = 1000, unit = "umol/L") # secondary loinc code

    # Drug_Drug                  -> MedicationRequests - N06AX22 + J01MA02
    addDrugs(pid, c("N06AX22", "J01MA02")) # zwei MRPS, weil in Drug Drug und in Drug Drug Group (Wird noch bereinigt)
    # Drug_DrugGroup             -> MedicationRequests - N06BA09 + C02KC01
    addDrugs(pid, c("N06BA09", "C02KC01"))

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

    # Drug-Disease Zeile 1, ATC systemisch
    pid <- addDrugs("UKB-0001_13", "L01XK52", period_type = "timing_events", timing_events_count = 5, timing_events_day_offset = 0.05)
    addConditions(pid, c("O09"))
    addObservation(pid, "21198-7", day_offset = -5.0, value = 12, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "21198-7", day_offset = -4.9, value = 13, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "21198-7", day_offset = -4.8, value = 14, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "21198-7", day_offset = -4.7, value = 15, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)
    addObservation(pid, "21198-7", day_offset = -4.6, value = 16, unit = "mg/dL", referencerange_low_value = 5, referencerange_high_value = 10)

    addObservation(pid, "2111-3", day_offset = -5.0, value = 1.2, unit = "g/dL", referencerange_low_value = 0.5, referencerange_high_value = 1.0)
    addObservation(pid, "2111-3", day_offset = -4.9, value = 1.3, unit = "g/dL", referencerange_low_value = 0.5, referencerange_high_value = 1.0)
    addObservation(pid, "2111-3", day_offset = -4.8, value = 1.4, unit = "g/dL", referencerange_low_value = 0.5, referencerange_high_value = 1.0)
    addObservation(pid, "2111-3", day_offset = -4.7, value = 1.5, unit = "g/dL", referencerange_low_value = 0.5, referencerange_high_value = 1.0)
    addObservation(pid, "2111-3", day_offset = -4.6, value = 1.6, unit = "g/dL", referencerange_low_value = 0.5, referencerange_high_value = 1.0)

    # Drug-Disease check specific lab units
    pid <- addDrugs("UKB-0001_14", "R05DA04")
    addConditions(pid, c("J95.1"))
    addObservation(pid, "11557-6", value = 70, unit = "%")

    # Drug Drug mit Überschneidung innerhalb eines Tages
    # Zwei Request mit dem selben Code am selben Tag (Startzeit vom ersten Request und Endzeit vom zweiten Event)
    pid <- addDrugs("UKB-0001_15", "A02BD04", day_offset = -0.4, period_type = "timing_events", timing_events_count = 3, timing_events_day_offset = 0.05)
    addDrugs(pid, "A02BD04", day_offset = -0.35, period_type = "timing_events", timing_events_count = 3, timing_events_day_offset = 0.1)
    # Einzelner Request mit anderen Code am selben Tag
    addDrugs(pid, "A03FA03", day_offset = -0.4, period_type = "timing_events", timing_events_count = 3, timing_events_day_offset = 0.11)

    # Drug Drug mit Überschneidung über mehrere Tage
    pid <- addDrugs("UKB-0001_16", "A02BD04", day_offset = -0.4, period_type = "timing_events", timing_events_count = 3, timing_events_day_offset = 0.4)
    addDrugs(pid, "A02BD04", day_offset = -0.35, period_type = "timing_events", timing_events_count = 3, timing_events_day_offset = 0.4)
    addDrugs(pid, "A02BD04", day_offset = 3, period_type = "timing_events", timing_events_count = 3, timing_events_day_offset = 0.4)
    addDrugs(pid, "A03FA03", day_offset = -0.4, period_type = "start_and_end")
    # Fake ATC Code hinzufügen, um zu testen, dass der Code nicht gefunden wird
    addDrugs(pid, "A00AA00", day_offset = -0.4, period_type = "timing_events", timing_events_count = 8, timing_events_day_offset = 0.6)

    # Drug Drug mit Überschneidung, aber mit Tag Pause dazwischen
    pid <- addDrugs("UKB-0001_17", "A02BD04", period_type = "timing_events", timing_events_count = 2, timing_events_day_offset = 2.0)
    addDrugs(pid, "A03FA03", period_type = "timing_events", timing_events_count = 2, timing_events_day_offset = 1.7)

    # Drug Drug mit Überschneidung, aber mit Tag Pause dazwischen für mehrere Medication Requests
    pid <- addDrugs("UKB-0001_18", "A02BD04", day_offset = -0.4, period_type = "timing_event")
    addDrugs(pid, "A02BD04", day_offset = 1.6, period_type = "timing_event")
    addDrugs(pid, "A03FA03", day_offset = -0.399, period_type = "timing_event")
    addDrugs(pid, "A03FA03", day_offset = 1.599, period_type = "timing_event")

    # Drug Drug ohne Überschneidung innerhalb eines Tages -> kein MRP
    pid <- addDrugs("UKB-0001_19", "A02BD04", day_offset = -0.4, period_type = "timing_events", timing_events_count = 2, timing_events_day_offset = 0.05)
    addDrugs(pid, "A03FA03", day_offset = 0.6, period_type = "timing_events", timing_events_count = 2, timing_events_day_offset = 1.15)
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
