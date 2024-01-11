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
    patientIDs <- getInterpolarPatientIDs()
  })

  ###
  # Save all console logs
  ###
  interpolar.R.utils::end_logging()

}
