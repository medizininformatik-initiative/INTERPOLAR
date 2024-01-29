#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @export
retrieve <- function() {

  ###
  # Read the configuration toml file
  ###
  interpolar.R.utils::initConstants('../interpolar_R_ETL_config.toml')

  ###
  # Create globally used polar_clock
  ###
  POLAR_CLOCK <<- interpolar.R.utils::createClock()

  ###
  # Set the project name to 'interpolar'
  PROJECT_NAME <<- 'interpolar'
  ###

  interpolar.R.utils::create_dirs(PROJECT_NAME)

  ###
  # STOP is set by a Script to TRUE, if this script 'wants' to stop the Scripts Loop
  ###
  STOP <- FALSE

  ###
  # log all console outputs and save them at the end
  ###
  interpolar.R.utils::start_logging('retrieval-total')

  interpolar.R.utils::run_out('Run Retrieve', {

    interpolar.R.utils::run_in('Extract Patient IDs', {
      patientIDsPerWard <- getInterpolarPatientIDsPerWard(ifelse(exists('PATH_TO_PID_LIST_FILE'), PATH_TO_PID_LIST_FILE, NA))
    })

    interpolar.R.utils::run_in('Load Table Description', {
      table_descriptions <- getTableDescriptions()
    })

    interpolar.R.utils::run_in('Download and crack resources by Patient IDs per ward', {
      resource_table_list <<- loadResourcesByPatientIDFromFHIRServer(patientIDsPerWard, table_descriptions)
    })

  })

  ###
  # Save all console logs
  ###
  interpolar.R.utils::end_logging()

}
