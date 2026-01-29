#' Starts the db2frontend ETL job
#'
#' This is the main entry point for the ETL process that transfers data between
#' the database and the frontend (Redcap) and back. It initializes the `db2frontend`
#' module, optionally resets the ETL lock, deletes Redcap content (in debug mode),
#' and runs both import directions. If `reset_lock_only` is set to `TRUE`, the function
#' only resets the lock and exits without executing the ETL job.
#'
#' @param reset_lock_only Logical. If TRUE, only resets the ETL lock and exits. Default is FALSE.
#' @param ignore_newer_db_version Logical. If TRUE, ignores if the database version is newer
#' than the release version. Default is FALSE and will stop if the database version is newer.
#'
#' @export
startFrontend2DB <- function(reset_lock_only = FALSE, ignore_newer_db_version = FALSE) {

  # Initialize and start module
  etlutils::startModule("frontend2db",
                        db_schema_base_name = "db2frontend",
                        path_to_toml = "./R-db2frontend/db2frontend_config.toml",
                        hide_value_pattern = "^REDCAP_",
                        init_constants_only = reset_lock_only)

  if (reset_lock_only) {
    etlutils::dbResetLock()
    return()
  }

  # Check if the release version of the database is compatible
  etlutils::checkVersion(ignore_newer_db_version)

  try(etlutils::runLevel1("Run Frontend -> DB", {

    # Reset database lock from unfinished previous db2frontend run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    # Delete Redcap content (DEBUG and TESTS)
    if (exists("DEBUG_DAY") && DEBUG_DAY == 1) {
      etlutils::runLevel2("DEBUG_DAY == 1 -> Delete all Redcap records", {
        deleteRedcapContent()
      })
    } else {
      # Import Data from Frontend to Database
      etlutils::runLevel2("Run Import Data from Frontend to Database", {
        importRedcap2DB()
      })
    }

  }))

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage()

  etlutils::finalize(finish_message)

}


#' Starts the db2frontend ETL job
#'
#' This is the main entry point for the ETL process that transfers data between
#' the database and the frontend (Redcap) and back. It initializes the `db2frontend`
#' module, optionally resets the ETL lock, deletes Redcap content (in debug mode),
#' and runs both import directions. If `reset_lock_only` is set to `TRUE`, the function
#' only resets the lock and exits without executing the ETL job.
#'
#' @param reset_lock_only Logical. If TRUE, only resets the ETL lock and exits. Default is FALSE.
#' @param ignore_newer_db_version Logical. If TRUE, ignores if the database version is newer
#' than the release version. Default is FALSE and will stop if the database version is newer.
#'
#' @export
startDB2Frontend <- function(reset_lock_only = FALSE, ignore_newer_db_version = FALSE) {

  # Initialize and start module
  etlutils::startModule("db2frontend",
                        path_to_toml = "./R-db2frontend/db2frontend_config.toml",
                        hide_value_pattern = "^REDCAP_",
                        init_constants_only = reset_lock_only)

  if (reset_lock_only) {
    etlutils::dbResetLock()
    return()
  }

  # Check if the release version of the database is compatible
  etlutils::checkVersion(ignore_newer_db_version)

  try(etlutils::runLevel1("Run DB -> Frontend", {

    # Reset database lock from unfinished previous db2frontend run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    # Import Data from Database to Frontend
    etlutils::runLevel2("Run Import Data from Database to Frontend", {
      importDB2Redcap()
    })

  }))

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage()

  return(etlutils::finalize(finish_message))

}
