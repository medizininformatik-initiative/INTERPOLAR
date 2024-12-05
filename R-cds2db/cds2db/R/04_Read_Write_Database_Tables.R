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
                                         user = DB_CDS2DB_USER,
                                         password = DB_CDS2DB_PASSWORD,
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
getDatabaseReadConnection <- function() getDatabaseConnection(DB_CDS2DB_SCHEMA_OUT)

#' Get Database Write Connection
#'
#' This function retrieves a write-enabled database connection for the default schema.
#' It is a wrapper around the \code{getDatabaseConnection} function.
#'
#' @return A database connection object for the default write schema.
#'
getDatabaseWriteConnection <- function() getDatabaseConnection(DB_CDS2DB_SCHEMA_IN)

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

#' Write Data Tables to a Database
#'
#' This function takes a list of data.table objects and writes them to a specified database.
#' It establishes a database connection using predefined credentials and configuration parameters,
#' and optionally checks if tables are empty before writing.
#'
#' @param tables A named list of data.table objects to be written to the database. Each element in
#'               the list represents a dataset intended for a corresponding table in the database.
#' @param stop_if_table_not_empty A logical value indicating whether to check if each target table
#'                        in the database is empty before writing. If `TRUE`, the function will stop
#'                        with an error if any table already contains data. Default is `FALSE`.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' write access under this name
writeTablesToDatabase <- function(tables, stop_if_table_not_empty = FALSE, lock_id) {
  etlutils::writeTablesToDatabase(tables = tables,
                                  db_connection = getDatabaseWriteConnection(),
                                  stop_if_table_not_empty = stop_if_table_not_empty,
                                  close_db_connection = FALSE,
                                  log = VERBOSE >= VL_90_FHIR_RESPONSE,
                                  lock_id = lock_id)
}

#' Retrieve Untyped RAW Data from Database
#'
#' This function connects to a database, retrieves the table names, reads the tables, and returns
#' the data as a list of data frames.
#'
#' @param table_names names of the tables or views to load
#' @param lock_id A string representation as ID for the process to lock the database during the
#' read access under this name
#'
#' @return A list of data frames where each data frame corresponds to a table from the database.
#'
readTablesFromDatabase <- function(table_names, lock_id) {
  etlutils::readTablesFromDatabase(db_connection = getDatabaseReadConnection(),
                                 table_names = table_names,
                                 close_db_connection = FALSE,
                                 log = VERBOSE >= VL_90_FHIR_RESPONSE,
                                 lock_id = lock_id)
}

#' Retrieve Data from Database using a Predefined Connection Configuration
#'
#' This function executes a SQL query on a database using a predefined set of
#' connection parameters, which are sourced from globally defined variables.
#'
#' @param query A string representing the SQL query to be executed.
#' @param params A list of parameters to be safely inserted into the SQL query, allowing for
#'        parameterized queries. If NA, no parameters will be used. This is useful for preventing
#'        SQL injection and handling dynamic query inputs.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @param readonly Logical value indicating whether the database was changed with the query. This should
#' be used to trigger a database internal cron job which copies the changed data in the database core.
#' If the query has not changed anything then set this paramter to TRUE to prevent the expensive cron
#' job execution.
#'
#' @return A data.table containing the result of the SQL query.
#'
getQueryFromDatabase <- function(query, params = NULL, lock_id, readonly) {
  db_connection <- if (readonly) getDatabaseReadConnection() else getDatabaseWriteConnection()
  etlutils::dbGetQuery(db_connection = db_connection,
                      query = query,
                      params = params,
                      log = VERBOSE >= VL_90_FHIR_RESPONSE,
                      lock_id = lock_id,
                      readonly = readonly)
}
