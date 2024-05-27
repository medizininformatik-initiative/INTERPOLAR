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

  etlutils::create_dirs(PROJECT_NAME)

  ###
  # Create globally used process_clock
  ###
  etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::start_logging('retrieval-total')

  etlutils::START__()

  etlutils::run_out('Run Retrieve', {

    # Extract Patient IDs
    etlutils::runProcess(etlutils::run_in('Extract Patient IDs', {
      patient_IDs_per_ward <- getPatientIDsPerWard(ifelse(exists('PATH_TO_PID_LIST_FILE'), PATH_TO_PID_LIST_FILE, NA))
    }))

    # Load Table Description
    etlutils::runProcess(etlutils::run_in('Load Table Description', {
      fhir_table_descriptions <- getFhircrackrTableDescriptions()
    }))

    # Download and crack resources by Patient IDs per ward
    etlutils::runProcess(etlutils::run_in('Download and crack resources by Patient IDs per ward', {
      resource_tables <- loadResourcesFromFHIRServer(patient_IDs_per_ward, fhir_table_descriptions)
    }))

    # Write raw tables to database
    etlutils::runProcess(etlutils::run_in('Write raw tables to database', {
      table_names <- names(resource_tables)
      names(resource_tables) <- tolower(paste0(names(resource_tables), "_raw"))
      writeTablesToDatabase(resource_tables, clear_before_insert = TRUE)
      names(resource_tables) <- table_names
    }))

    # Convert Column Types in resource tables
    etlutils::runProcess(etlutils::run_in('Load untyped RAW tables from database', {
      fhir_table_descriptions <- extractTableDescriptionsList(fhir_table_descriptions)
      resource_tables <- readUntypedRAWDataFromDatabase()
    }))

    etlutils::runProcess(etlutils::run_in('Convert RAW tables to typed tables', {
      resource_tables <- convertTypes(resource_tables, fhir_table_descriptions)
    }))

    etlutils::runProcess(etlutils::run_in('Write typed tables to database', {
      writeTablesToDatabase(resource_tables, clear_before_insert = FALSE)
    }))

  })

  etlutils::finalize()

}
