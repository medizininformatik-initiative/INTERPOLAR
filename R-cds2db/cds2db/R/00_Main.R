#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @export
retrieve <- function() {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- './R-cds2db/cds2db_config.toml'
  etlutils::initConstants(path2config_toml)

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Set the project name to 'cds2db'
  PROJECT_NAME <<- 'cds2db'
  ###

  etlutils::createDIRS(PROJECT_NAME)

  ###
  # Create globally used process_clock
  ###
  etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::startLogging('retrieval-total')

  etlutils::logBlockHeader()

  etlutils::runLevel1('Run Retrieve', {

    # Extract Patient IDs
    etlutils::runProcess(etlutils::runLevel2('Extract Patient IDs', {
      patient_IDs_per_ward <- getPatientIDsPerWard(ifelse(exists('PATH_TO_PID_LIST_FILE'), PATH_TO_PID_LIST_FILE, NA))
    }))

    # Load Table Description
    etlutils::runProcess(etlutils::runLevel2('Load Table Description', {
      fhir_table_descriptions <- getFhircrackrTableDescriptions()
    }))

    # Download and crack resources by Patient IDs per ward
    etlutils::runProcess(etlutils::runLevel2('Download and crack resources by Patient IDs per ward', {
      resource_tables <- loadResourcesFromFHIRServer(patient_IDs_per_ward, fhir_table_descriptions)
    }))

    # Write raw tables to database
    etlutils::runProcess(etlutils::runLevel2('Write raw tables to database', {
      table_names <- names(resource_tables)
      names(resource_tables) <- tolower(paste0(names(resource_tables), "_raw"))
      writeTablesToDatabase(resource_tables, clear_before_insert = TRUE)
      names(resource_tables) <- table_names
    }))

    # Wait until the copy cron job runs after insertion
    etlutils::runProcess(etlutils::runLevel2('Wait until the copy cron job runs after insertion', {
      start <- as.numeric(Sys.time())
      while (start + DELAY_MINUTES_BETWEEN_RAW_INSERT_AND_START_TYPING * 60 > as.numeric(Sys.time())) {
        cat(".")
        Sys.sleep(10)
      }
      cat("\n")
    }))

    # Convert Column Types in resource tables
    etlutils::runProcess(etlutils::runLevel2('Load untyped RAW tables from database', {
      resource_tables <- readUntypedRAWDataFromDatabase()
    }))

    etlutils::runProcess(etlutils::runLevel2('Convert RAW tables to typed tables', {
      fhir_table_descriptions <- extractTableDescriptionsList(fhir_table_descriptions)
      resource_tables <- convertTypes(resource_tables, fhir_table_descriptions)
    }))

    etlutils::runProcess(etlutils::runLevel2('Write typed tables to database', {
      writeTablesToDatabase(resource_tables, clear_before_insert = FALSE)
    }))

  })

  etlutils::finalize()

}
