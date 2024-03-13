#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @export
retrieve <- function() {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- './R-kds2db/kds2db_config.toml'
  etlutils::initConstants(path2config_toml)

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Set the project name to 'kds2db'
  PROJECT_NAME <<- 'kds2db'
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
    etlutils::startProcess(etlutils::run_in('Extract Patient IDs', {
      patientIDsPerWard <- getPatientIDsPerWard(ifelse(exists('PATH_TO_PID_LIST_FILE'), PATH_TO_PID_LIST_FILE, NA))
    }))

    # Load Table Description
    etlutils::startProcess(etlutils::run_in('Load Table Description', {
      table_descriptions <- getTableDescriptions()
    }))

    # Download and crack resources by Patient IDs per ward
    etlutils::startProcess(etlutils::run_in('Download and crack resources by Patient IDs per ward', {
      resource_table_list <- loadResourcesByPatientIDFromFHIRServer(patientIDsPerWard, table_descriptions)
    }))

    # Write resource tables to database
    etlutils::startProcess(etlutils::run_in('Download and crack resources by Patient IDs per ward', {
      writeResourceTablesToDatabase(resource_table_list, clear_before_insert = FALSE)
    }))

  })
  etlutils::printClock()
  warnings()
  etlutils::END__()
  ###
  # Save all console logs
  ###
  etlutils::end_logging()
}
