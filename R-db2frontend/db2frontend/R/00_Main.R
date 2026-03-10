initInternal <- function(module_name, validate_config = TRUE) {
  etlutils::initModule(module_name,
                       db_schema_base_name = "db2frontend",
                       path_to_toml = "./R-db2frontend/db2frontend_config.toml",
                       mandatory_parameters = c(
                         "REDCAP_URL",
                         "REDCAP_TOKEN",
                         "PATH_TO_DB_CONFIG_TOML"
                       )
  )
  if (validate_config) {
    # TODO: add validation for common parameters of frontend2db and db2frontend
  }
}

#' Initializes the module context for frontend2db.
#'
#' This function initializes the module context for the frontend2db module by loading
#' the necessary configuration parameters from a specified TOML file and setting up
#' the module environment. It ensures that all mandatory parameters are present and
#' can optionally validate the configuration values.
#'
#' @param validate_config Logical. If TRUE, validates the module configuration
#' after initialization. Default is TRUE.
#'
#' @return A list containing the module configuration parameters loaded from the
#' TOML file and initialized in the module context. This list will be used for the
#' execution of the module and contains all necessary parameters for the ETL process.
#'
#' @export
initFrontend2DB <- function(validate_config = TRUE) {
  config <- initInternal("frontend2db")
  if (validate_config) {
    # TODO: add validation for frontend2db
  }
  return(config)
}

#' Initializes the module context for db2frontend
#'
#' This function initializes the module context for the db2frontend module by loading
#' the necessary configuration parameters from a specified TOML file and setting up
#' the module environment. It ensures that all mandatory parameters are present and
#' can optionally validate the configuration values.
#'
#' @param validate_config Logical. If TRUE, validates the module configuration
#' after initialization. Default is TRUE.
#'
#' @return A list containing the module configuration parameters loaded from the
#' TOML file and initialized in the module context. This list will be used for the
#' execution of the module and contains all necessary parameters for the ETL process.
#'
#' @export
initDB2Frontend <- function(validate_config = TRUE) {
  config <- initInternal("db2frontend")
  if (validate_config) {
    # TODO: add validation for db2frontend
  }
  return(config)
}

#' Resets the database lock for module name "frontend2db".
#'
#' Resets the database lock, if this module has set a lock in a previous run and
#' the lock was not reset due to an error or interruption. This allows to run
#' the module again after fixing the error without having to wait for the lock
#' to expire.
#'
#' @export
resetLockFrontend2DB <- function() {
  initFrontend2DB(validate_config = FALSE)
  etlutils::dbResetLock()
}

#' Resets the database lock for module name "db2frontend".
#'
#' Resets the database lock, if this module has set a lock in a previous run and
#' the lock was not reset due to an error or interruption. This allows to run
#' the module again after fixing the error without having to wait for the lock
#' to expire.
#'
#' @export
resetLockDB2Frontend <- function() {
  initDB2Frontend(validate_config = FALSE)
  etlutils::dbResetLock()
}

#' Starts the db2frontend ETL job
#'
#' This is the main entry point for the ETL process that transfers data between
#' the database and the frontend (Redcap) and back. It initializes the `db2frontend`
#' module, optionally resets the ETL lock, deletes Redcap content (in debug mode),
#' and runs both import directions.
#'
#' @param ignore_newer_db_version Logical. If TRUE, ignores if the database version is newer
#' @param validate_config Logical. If TRUE, validates the module configuration before starting
#'                        the retrieval process. Default is TRUE.
#' than the release version. Default is FALSE and will stop if the database version is newer.
#'
#' @export
startFrontend2DB <- function(ignore_newer_db_version = FALSE, validate_config = TRUE) {
  # Initialize and start module
  config <- initFrontend2DB(validate_config)
  etlutils::startModule(config, hide_value_pattern = "^REDCAP_")

  try(etlutils::runLevel1("Run Frontend -> DB", {

    # Reset database lock from unfinished previous db2frontend run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
      # Check if the release version of the database is compatible
      etlutils::checkVersion(ignore_newer_db_version)
    })

    # Delete Redcap content (DEBUG and TESTS)
    if (exists("DEBUG_DAY") && DEBUG_DAY == 1 && !etlutils::isDefinedAndTrue("DEBUG_DONT_DELETE_REDCAP_DATA")) {
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
#' @param ignore_newer_db_version Logical. If TRUE, ignores if the database version is newer
#' @param validate_config Logical. If TRUE, validates the module configuration before starting
#'                        the retrieval process. Default is TRUE.
#' than the release version. Default is FALSE and will stop if the database version is newer.
#'
#' @export
startDB2Frontend <- function(ignore_newer_db_version = FALSE, validate_config = TRUE) {

  # Initialize and start module
  config <- initDB2Frontend(validate_config)
  etlutils::startModule(config, hide_value_pattern = "^REDCAP_")

  try(etlutils::runLevel1("Run DB -> Frontend", {

    # Reset database lock from unfinished previous db2frontend run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
      # Check if the release version of the database is compatible
      etlutils::checkVersion(ignore_newer_db_version)
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
