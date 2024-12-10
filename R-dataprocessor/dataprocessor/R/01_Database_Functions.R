# Environment for saving the db_connnections
.db_connections_env <- new.env()

#' Create a Lock ID with Default Project Name
#'
#' This function generates a lock ID by combining a predefined project name with a variable number
#' of arguments for the lock ID message. The arguments are concatenated and combined with the
#' project name, separated by a colon (`:`). The project name is sourced from the global constant
#' `PROJECT_NAME`.
#'
#' @param ... A variable number of strings to be concatenated as the lock ID message.
#'
#' @return A character string representing the combined lock ID in the format
#'         `<PROJECT_NAME>:<lock_id_message>`.
#'
createLockID <- function(...) {
  etlutils::createLockID(PROJECT_NAME, ...)
}

#' Get Database Connection
#'
#' This function retrieves a database connection for the specified schema.
#' If a connection for the schema does not already exist, it creates a new one.
#'
#' @param schema_name The name of the database schema for which to get the connection.
#'
#' @return A database connection object.
#'
getDatabaseConnection <- function(schema_name) {
  connection_env_identifier <- as.character(sys.call()[2]) # get the schema variable name
  db_connection <- .db_connections_env[[connection_env_identifier]]
  if (is.null(db_connection) || !etlutils::dbIsValid(db_connection)) {
    db_connection <- etlutils::dbConnect(dbname = DB_GENERAL_NAME,
                                         host = DB_GENERAL_HOST,
                                         port = DB_GENERAL_PORT,
                                         user = DB_DATAPROCESSOR_USER,
                                         password = DB_DATAPROCESSOR_PASSWORD,
                                         schema = schema_name)
    .db_connections_env[[connection_env_identifier]] <- db_connection
  }
  return(db_connection)
}

#' Get Database Read Connection
#'
#' This function retrieves a read-only database connection for the default schema.
#' It is a wrapper around the `getDatabaseConnection` function.
#'
#' @return A database connection object for the default read schema.
#'
getDatabaseReadConnection <- function() getDatabaseConnection(DB_DATAPROCESSOR_SCHEMA_OUT)

#' Get Database Write Connection
#'
#' This function retrieves a write-enabled database connection for the default schema.
#' It is a wrapper around the \code{getDatabaseConnection} function.
#'
#' @return A database connection object for the default write schema.
#'
getDatabaseWriteConnection <- function() getDatabaseConnection(DB_DATAPROCESSOR_SCHEMA_IN)

#' Close All Database Connections
#'
#' This function closes all active database connections stored in the global connection environment.
#' It iterates through all the connection objects in the environment, disconnects them, and removes them from the environment.
#'
closeAllDatabaseConnections <- function() {
  resetRemainingDatabaseLock()
  for (db_connection_variable_name in ls(.db_connections_env)) {
    db_connection <- get(db_connection_variable_name, envir = .db_connections_env)
    if (etlutils::dbIsValid(db_connection)) {
      etlutils::dbDisconnect(db_connection)
    }
    rm(list = db_connection_variable_name, envir = .db_connections_env)
  }
}

#' Reset Remaining Database Lock
#'
#' This function resets any remaining database locks for a given project. It utilizes
#' the `dbResetLock` function from the `etlutils` package, using the database write
#' connection and project-specific configurations.
#'
resetRemainingDatabaseLock <- function() {
  etlutils::dbResetLock(
    db_connection = getDatabaseWriteConnection(),
    log = LOG_DB_QUERIES,
    project_name = PROJECT_NAME)
}

#' Execute a Read-Only Query
#'
#' This function executes a read-only SQL query on a database connection,
#' with a locking mechanism for safe execution.
#'
#' @param query A string representing the SQL query to be executed.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return A data frame containing the result of the executed query.
#'
dbReadQuery <- function(query, lock_id) {
  etlutils::dbGetQuery(
    db_connection = getDatabaseReadConnection(),
    query = query,
    log = LOG_DB_QUERIES,
    project_name = PROJECT_NAME,
    lock_id = createLockID(lock_id),
    readonly = TRUE)
}
