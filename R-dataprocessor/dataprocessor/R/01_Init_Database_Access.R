# Environment for saving the db_connnections
.db_connections_env <- new.env()

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
#' @export
getDatabaseReadConnection <- function() getDatabaseConnection(DB_DATAPROCESSOR_SCHEMA_OUT)

#' Get Database Write Connection
#'
#' This function retrieves a write-enabled database connection for the default schema.
#' It is a wrapper around the \code{getDatabaseConnection} function.
#'
#' @return A database connection object for the default write schema.
#'
#' @export
getDatabaseWriteConnection <- function() getDatabaseConnection(DB_DATAPROCESSOR_SCHEMA_IN)

#' Close All Database Connections
#'
#' This function closes all active database connections stored in the global connection environment.
#' It iterates through all the connection objects in the environment, disconnects them, and removes them from the environment.
#'
closeAllDatabaseConnections <- function() {
  for (db_connection_variable_name in ls(.db_connections_env)) {
    db_connection <- get(db_connection_variable_name, envir = .db_connections_env)
    if (etlutils::dbIsValid(db_connection)) {
      etlutils::dbDisconnect(db_connection)
    }
    rm(list = db_connection_variable_name, envir = .db_connections_env)
  }
}
