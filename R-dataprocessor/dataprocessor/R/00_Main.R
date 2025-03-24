#' Starts the Data Processor execution for this project
#'
#' This is the main entry point for the data processing pipeline. It initializes the
#' Data Processor module, resets any existing ETL lock, and triggers the creation
#' of frontend tables. If `reset_lock_only` is set to `TRUE`, the function only resets
#' the lock and exits without executing any further logic.
#'
#' @param reset_lock_only Logical. If TRUE, only resets the ETL lock and exits. Default is FALSE.
#'
#' @export
processData <- function(reset_lock_only = FALSE) {

  # Initialize and start module
  etlutils::startModule("dataprocessor",
                        path_to_toml = "./R-dataprocessor/dataprocessor_config.toml",
                        init_constants_only = reset_lock_only)

  if (reset_lock_only) {
    etlutils::dbResetLock()
    return()
  }

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

}
