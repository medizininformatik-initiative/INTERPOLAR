#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from Database to Frontend and back.
#'
#' @export
retrieve <- function() {

  # Initialize and start module
  etlutils::startModule("db2frontend",
                        path_to_toml = "./R-db2frontend/db2frontend_config.toml",
                        hide_value_pattern = "^REDCAP_")

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

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage(PROJECT_NAME)

  etlutils::finalize(finish_message)

}
