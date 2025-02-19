#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from Database to Frontend and back.
#'
#' @export
retrieve <- function() {

  ###
  # Init module constants
  ###
  config <- etlutils::initModuleConstants(
    module_name = "db2frontend",
    path_to_toml = "./R-db2frontend/db2frontend_config.toml"
  )

  etlutils::createDIRS(PROJECT_NAME)

  ###
  # Create globally used process_clock
  ###
  etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::startLogging(PROJECT_NAME)

  # log all configuration parameters but hide value with parameter name starts with "REDCAP_"
  etlutils::catList(config, "Configuration:\n--------------\n", "\n", "^REDCAP_")

  try(etlutils::runLevel1("Run Retrieve", {

    # Reset database lock from unfinished previous db2frontend run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    # Import Data from Database to Frontend
    etlutils::runLevel2("Run Import Data from Database to Frontend", {
      importDB2Redcap()
    })

    # Import Data from Frontend to Database
    etlutils::runLevel2("Run Import Data from Frontend to Database", {
      importRedcap2DB()
    })

  }))

  try(etlutils::runLevel1(paste("Finishing", PROJECT_NAME), {
    etlutils::runLevel2("Close database connections", {
      etlutils::dbCloseAllConnections()
    })
  }))

  if (etlutils::isErrorOccured()) {
    finish_message <- "Module 'DB2Frontend' finished with errors (see details above).\n"
    finish_message <- paste0(finish_message, etlutils::getErrorMessage())
  } else {
    finish_message <- "Module 'DB2Frontend' finished with no errors.\n"
  }

  etlutils::finalize(finish_message)

}
