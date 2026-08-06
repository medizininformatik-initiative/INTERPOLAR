# Recovery test for interrupted toolchain runs (issue #813)
# First Start Day 1 and after that Start Day 2. The first day simulates an interrupted run of the toolchain, where only
# cds2db is run and dataprocessor is not. The second day starts the complete toolchain, which must first process the
# historical pids_per_ward data before processing the new data.
#
# Day 1:
#   - create one patient and case
#   - run only cds2db, simulating an interruption before dataprocessor
#   - pids_per_ward is present, but fall_fe is not
#
# Day 2:
#   - start the complete toolchain
#   - the recovery pass must process the historical pids_per_ward first
#   - the regular toolchain pass follows afterwards

DEBUG_DAYS_COUNT <- 2

# Activate if only a specific debug day should be run
if (!exists("DEBUG_RUN_SINGLE_DAY_ONLY")) {
  DEBUG_RUN_SINGLE_DAY_ONLY <- 2
}

DEBUG_MODULES_PATH_TO_CONFIG_TOML <- c(
  cds2db = "./R-cds2db/test/test_cds2db_config.toml",
  dataprocessor = "",
  db2frontend = ""
)

DEBUG_PATH_TO_RAW_RDATA_FILES <- "./R-cds2db/test/tables/"

if (exists("TOOLCHAIN_DAY")) {
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  testSetResourceTables(resource_tables)

  pid <- "UKB-0001"
  testPrepareRAWResources(namedListByValue(pid))
  testRemoveMultipleDiagnoses()
  testAdmission(pid, "Raum 1-1", "Bett 1-1", "Station 1")

  runCodeForDebugDay(1, {
    assign("DEBUG_START_SINGLE_MODULE", "cds2db", envir = .GlobalEnv)
  })

  runCodeForDebugDay(2, {
    if (exists("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)) {
      rm("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)
    }
  })

  resource_tables <- testGetResourceTables()
  return(resource_tables)
}
