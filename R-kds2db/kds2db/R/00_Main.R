#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @export
retrieve <- function() {

  # Iniialzes the global STOP variable. If a subprocess sets this variable to TRUE then the execution will be stopped.
  STOP <<- FALSE

  ###
  # Read the module configuration toml file
  ###
  etlutils::initConstants('../kds2db_config.toml')

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Create globally used polar_clock
  ###
  POLAR_CLOCK <<- etlutils::createClock()

  ###
  # Set the project name to 'kds2db'
  PROJECT_NAME <<- 'kds2db'
  ###

  etlutils::create_dirs(PROJECT_NAME)

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::start_logging('retrieval-total')

  etlutils::run_out('Run Retrieve', {

    etlutils::run_in('Extract Patient IDs', {
      patientIDsPerWard <- getPatientIDsPerWard(ifelse(exists('PATH_TO_PID_LIST_FILE'), PATH_TO_PID_LIST_FILE, NA))
    })

    etlutils::run_in('Load Table Description', {
      table_descriptions <- getTableDescriptions()
    })

    etlutils::run_in('Download and crack resources by Patient IDs per ward', {
      resource_table_list <<- loadResourcesByPatientIDFromFHIRServer(patientIDsPerWard, table_descriptions)
    })

    etlutils::run_in('Write resource tables to database', {
      writeResourceTablesToDatabase(resource_table_list, clear_before_insert = FALSE)
    })

  })

  ###
  # Save all console logs
  ###
  etlutils::end_logging()

}
