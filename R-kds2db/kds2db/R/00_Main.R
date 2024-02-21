#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @export
retrieve <- function() {
  # Iniialzes the global STOP variable. If a subprocess sets this variable to TRUE then the execution will be stopped.
  STOP <<- FALSE

  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- ifelse(interactive(), './R-kds2db', '.')
  path2config_toml <- paste0(path2config_toml, '/kds2db_config.toml')
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
  PROCESS_CLOCK <<- etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::start_logging('retrieval-total')

  etlutils::START__()
  etlutils::run_out('Run Retrieve', {

    # Extract Patient IDs
    etlutils::START__()
    err <- try(etlutils::run_in('Extract Patient IDs', {
      patientIDsPerWard <- getPatientIDsPerWard(ifelse(exists('PATH_TO_PID_LIST_FILE'), PATH_TO_PID_LIST_FILE, NA))
    }), silent = TRUE)
    print(PROCESS_CLOCK)
    warnings()
    if(inherits(err, "try-error")) stop()
    etlutils::END__()

    # Load Table Description
    etlutils::START__()
    err <- try(etlutils::run_in('Load Table Description', {
      table_descriptions <- getTableDescriptions()
    }), silent = TRUE)
    print(PROCESS_CLOCK)
    warnings()
    if(inherits(err, "try-error")) stop()
    etlutils::END__()

    # Download and crack resources by Patient IDs per ward
    etlutils::START__()
    err <- try(etlutils::run_in('Download and crack resources by Patient IDs per ward', {
      resource_table_list <<- loadResourcesByPatientIDFromFHIRServer(patientIDsPerWard, table_descriptions)
    }), silent = TRUE)
    print(PROCESS_CLOCK)
    warnings()
    if(inherits(err, "try-error")) stop()
    etlutils::END__()

    # Write resource tables to database
    etlutils::START__()
    err <- try(etlutils::run_in('Write resource tables to database', {
      writeResourceTablesToDatabase(resource_table_list, clear_before_insert = FALSE)
    }), silent = TRUE)
    print(PROCESS_CLOCK)
    warnings()
    if(inherits(err, "try-error")) stop()
    etlutils::END__()

    # # Maybe relevant in future
    # if (STOP) {
    #   cat_red('An Error occured in a for the following Scripts relevant Script. So stop execution here.\n')
    #   cat(str.(err, fg = 1), '\n')
    #   break;
    # }
  })
  etlutils::END__()
  #warnings()
  print(PROCESS_CLOCK)
  ###
  # Save all console logs
  ###
  etlutils::end_logging()

}
