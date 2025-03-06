#'
#'
#' Starts the retrieval for this project. This is the main start function start the Data Processor
#' job
#'
#' @export
processData <- function() {

  # Initialize and start module
  etlutils::startModule("dataprocessor",
                        path_to_toml = "./R-dataprocessor/dataprocessor_config.toml")

  try(etlutils::runLevel1("Run Dataprocessor", {

    # Reset lock from unfinished previous dataprocessor run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    etlutils::runLevel2("Create Frontend Tables for Patient and Encounter", {
      createFrontendTables()
    })

  }))

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage(PROJECT_NAME)

  etlutils::finalize(finish_message)

  if (etlutils::isErrorOccured()) {
    stop(finish_message)
  }

}
