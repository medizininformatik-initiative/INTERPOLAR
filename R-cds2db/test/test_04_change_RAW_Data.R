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

  duplicatePatients(14)
  #duplicatePatients(1, 1)

  runCodeForDebugDay(1, {

    ############################################
    # Drug-Disease - Multiple Reference Ranges #
    ############################################

    # 1.) Filter auf type_code "normal"
    # 1.1.) mind. 1 "normal" -> Filter Einheiten umrechenbar, wenn im Ref Range Einheit vorhanden (fehlend gilt als umrechenbar)
    # 1.1.1.) mind. eine mit umrechendbarer/fehlender Einheit -> nimm die 1. -> return
    # 1.1.2.) keine mit umrechendbarer/fehlender Einheit -> invalid OBS
    # 1.2.) keine "normal" -> Filter auf type_code NA
    # 1.2.1.) mind. 1 NA -> weiter wie 1.1.)
    # 1.2.2.) keine NA -> type_code weder "normal" noch NA -> invalid OBS

    # Variante 1: alle Einheiten sind umrechendbar/fehlend
    # NO: so | NA | no | result
    # -------------------------
    #  1:  0 |  0 |  0 | invalid Obs
    #  2:  0 |  0 |  1 | OK no
    #  3:  0 |  1 |  0 | OK NA
    #  4:  0 |  1 |  1 | OK no
    #  5:  1 |  0 |  0 | invalid Obs
    #  6:  1 |  0 |  1 | OK no
    #  7:  1 |  1 |  0 | OK NA
    #  8:  1 |  1 |  1 | OK no
    #  9:  2 |  0 |  2 | OK no[1]
    # 10:  2 |  1 |  2 | OK no[1]
    # 11:  2 |  2 |  0 | OK NA[1]
    # 12:  2 |  2 |  1 | OK no
    # 13:  2 |  2 |  2 | OK no[1]
    # 14:  2 |  0 |  0 | invalid Obs


    # Variante 2: keine Einheit ist umrechendbar
    # immer invalid Obs
    # Variante 3: maximal eine Einheit aus no oder NA ist umrechendbar (bei 2 immer die 2.)
    # Variante 4: nur eine Einheit aus NA ist umrechendbar, aber keine aus no

    ########################################################
    # Variante 1: alle Einheiten sind umrechendbar/fehlend #
    ########################################################

    ref_range_no <- createReferenceRange(0.005, "g/dl", 0.01, "g/dl", "normal")
    ref_range_no2 <- createReferenceRange(0.0051, "g/dl", 0.011, "g/dl", "normal")
    ref_range_NA <- createReferenceRange(0.0052, "g/dl", 0.012, "g/dl")
    ref_range_NA2 <- createReferenceRange(0.0053, "g/dl", 0.013, "g/dl")
    ref_range_so <- createReferenceRange(0.0054, "g/dl", 0.014, "g/dl", "something")
    ref_range_so2 <- createReferenceRange(0.0055, "g/dl", 0.015, "g/dl", "something")

    addObs <- function(pid, reference_ranges = NULL, code = "21198-7", day_offset = -0.5, value = 16, unit = "mg/dL") {
      day_offset_plus <- sub(".*_(\\d+)$", "\\1", pid) # get the number after the last underscore (UKB-0001_3 -> 3)
      day_offset_plus <- as.numeric(day_offset_plus) / 100
      addObservationWithRanges(pid, code = "21198-7", day_offset = -0.5 + day_offset_plus, value = 16, unit = "mg/dL", reference_ranges = reference_ranges)
    }

    # NO: so | NA | no | result
    # -------------------------
    #
    # Drug_Disease -> Proxy LOINC primary 21198-7 oder secondary 19080-1 und 20415-6 > ULN
    # Line 76539 -> MedicationRequest - C03DA02 + Observation - 21198-7
    #  1:  0 |  0 |  0 | invalid Obs
    pid <- addDrugs("UKB-0001_1", "C03DA02")
    addObs(pid, NULL, "21198-7")
    addObs(pid, NULL, "19080-1")
    addObs(pid, NULL, "20415-6")

    #  2:  0 |  0 |  1 | OK no
    pid <- addDrugs("UKB-0001_2", "C03DA02")
    addObs(pid, ref_range_no)

    #  3:  0 |  1 |  0 | OK NA
    pid <- addDrugs("UKB-0001_3", "C03DA02")
    addObs(pid, ref_range_NA)

    #  4:  0 |  1 |  1 | OK no
    pid <- addDrugs("UKB-0001_4", "C03DA02")
    addObs(pid, list(ref_range_NA, ref_range_no))

    #  5:  1 |  0 |  0 | invalid Obs
    pid <- addDrugs("UKB-0001_5", "C03DA02")
    addObs(pid, ref_range_so)

    #  6:  1 |  0 |  1 | OK no
    pid <- addDrugs("UKB-0001_6", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_no))

    #  7:  1 |  1 |  0 | OK NA
    pid <- addDrugs("UKB-0001_7", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_NA))

    #  8:  1 |  1 |  1 | OK no
    pid <- addDrugs("UKB-0001_8", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_NA, ref_range_no))

    #  9:  2 |  0 |  2 | OK no[1]
    pid <- addDrugs("UKB-0001_9", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_so2, ref_range_no, ref_range_no2))

    # 10:  2 |  1 |  2 | OK no[1]
    pid <- addDrugs("UKB-0001_10", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_so2, ref_range_NA, ref_range_no, ref_range_no2))

    # 11:  2 |  2 |  0 | OK NA[1]
    pid <- addDrugs("UKB-0001_11", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_so2, ref_range_NA, ref_range_NA2))

    # 12:  2 |  2 |  1 | OK no
    pid <- addDrugs("UKB-0001_12", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_so2, ref_range_NA, ref_range_NA2, ref_range_no))

    # 13:  2 |  2 |  2 | OK no[1]
    pid <- addDrugs("UKB-0001_13", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_so2, ref_range_NA, ref_range_NA2, ref_range_no, ref_range_no2))

    # 14:  2 |  0 |  0 | invalid Obs
    pid <- addDrugs("UKB-0001_14", "C03DA02")
    addObs(pid, list(ref_range_so, ref_range_so2))

  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
