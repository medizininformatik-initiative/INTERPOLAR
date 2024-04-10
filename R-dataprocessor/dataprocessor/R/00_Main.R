#'
#' Starts the retrieval for this project. This is the main start function start the Data Processor job
#'
#' @export
dataprocessor <- function() {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- './R-dataprocessor/dataprocessor_config.toml'
  etlutils::initConstants(path2config_toml)

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Set the project name to 'dataprocessor'
  PROJECT_NAME <<- 'dataprocessor'
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

    # steps to do:
    # correcting laboratory codes, units and values
    # ...
    # MRP calculation

    # Initialization
    etlutils::startProcess(etlutils::run_in('Initialization', {
      init()
    }))

    # Calculate Drug Disease MPRS
    etlutils::startProcess(etlutils::run_in('Calculate Drug Disease MRPs', {
      calculateDrugDiseaseMRPs()
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
