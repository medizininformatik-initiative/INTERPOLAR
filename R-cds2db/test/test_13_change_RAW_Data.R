# Patient UKB-0001 Test für die MRP-Rekalkulation
# Tag 1: Aufnahme, erste MRP-ausloesende Konstellation, erste Medikationsanalyse,
#        Entlassung noch am selben Tag. Die volle Toolchain laeuft und stellt den
#        Fall inkl. Medikationsanalyse im Frontend bereit.
# Tag 2: keine neuen RAW-Daten. Die an Tag 1 im REDCap angelegte Medikationsanalyse
#        wird per frontend2db in die DB uebernommen; danach berechnet der reguläre
#        dataprocessor genau das erste retrospektive MRP.
# Tag 3: verspaetete, rueckdatierte RAW-Daten fuer denselben Fall treffen ein.
#        Es wird absichtlich nur cds2db ausgefuehrt, damit die neuen RAW-Daten
#        in der DB liegen, aber das zweite MRP noch NICHT regulär berechnet wird.
# Danach soll MRP_Recalculation genau dieses zusaetzliche MRP nachziehen.

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 3

# Activate if only a specific debug day should be run
# DEBUG_RUN_SINGLE_DAY_ONLY <- 2

# Immediate MRP calculation after encounter end so the effect of day 1 is visible.
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

###############################
# End Define global variables #
###############################


if (exists("TOOLCHAIN_DAY")) {
  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  # resources are a list of data tables from outside we want to change for the test
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pats <- pid1

  if (TOOLCHAIN_DAY > 1) {
    if (exists("DEBUG_RUN_SINGLE_DAY_ONLY")) {
      etlutils::dbReset(c("db_log.dp_mrp_calculations", "db_log.retrolektive_mrpbewertung_fe"))
    }
    # Keep the original test patient in scope even if the encounter is already finished.
    patient_ids_db <- etlutils::getAfterLastSlash(getActiveEncounterPIDsFromDB())
    pats <- unique(c(pats, patient_ids_db))
  }

  # Convenience list of patient IDs
  pats <- namedListByValue(pats)

  testPrepareRAWResources(pats)
  testRemoveMultipleDiagnoses()

  current_debug_day <- TOOLCHAIN_DAY

  runCodeForDebugDay(1, {
    # Ensure the regular full toolchain is active for day 1.
    if (exists("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)) {
      rm("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)
    }

    # Day 1: one encounter with one MRP-generating constellation.
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1", day_offset = -0.8)

    # Drug_Disease -> simple Drug + simple Disease
    # MedicationRequest - N02AA01 + Diagnosis - R10.0 -> 1 MRP
    pid <- addDrugs(pid1, "N02AA01", day_offset = -0.7)
    addConditions(pid, "R10.0", day_offset = -0.69)

    # End the encounter on the same debug day. The associated REDCap medication
    # analysis is added in the matching change_REDCap_Data script shortly before discharge.
    testDischarge(pid1)
    # Keep the finished case in pids_per_ward so the regular dataprocessor run
    # on day 1 can still build the case context from the last import.
    testUpdateWard(testGetEncounterLevel(pid1, 1)$enc_id, "Station 1")
  })

  runCodeForDebugDay(2, {
    # Day 2: regular full toolchain run.
    # This is the first day on which the Medikationsanalyse from REDCap exists
    # in the DB before dataprocessor starts, so the initial MRP can be calculated.
    if (exists("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)) {
      rm("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)
    }
  })

  runCodeForDebugDay(3, {
    # Day 3: after cds2db has written the late-arriving RAW data, the remaining
    # modules must be skipped. This leaves the DB in the desired state for the
    # explicit MRP_Recalculation run.
    assign("DEBUG_START_SINGLE_MODULE", "cds2db", envir = .GlobalEnv)

    # The timestamps are intentionally backdated to lie
    #   encounter_start < late_data < first_medication_analysis < encounter_end
    # so the already existing first medication analysis should now trigger one
    # additional MRP for the same case once MRP_Recalculation is started.

    # Drug_Disease -> simple Drug + simple Disease
    # MedicationRequest - R03CC53 + Diagnosis - I47 -> 1 additional MRP
    pid <- addDrugs(pid1, "R03CC53", day_offset = -2.65)
    addConditions(pid, "I47", day_offset = -2.64)
  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
  return(resource_tables)
}
