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
  for (db_connection_variable_name in ls(.db_connections_env)) {
    db_connection <- get(db_connection_variable_name, envir = .db_connections_env)
    if (etlutils::dbIsValid(db_connection)) {
      etlutils::dbDisconnect(db_connection)
    }
    rm(list = db_connection_variable_name, envir = .db_connections_env)
  }
}

#' Get Tables with Name Part
#'
#' This function retrieves the names of tables in a database connection that contain a specific part in their name.
#' The search is case-insensitive.
#'
#' @param db_connection A database connection object.
#' @param name_part A string representing the part of the table name to search for.
#'
#' @return A character vector containing the names of the tables that match the specified name part.
#'
getTablesWithNamePart <- function(db_connection, name_part) {
  name_part <- tolower(name_part)
  table_names <- etlutils::dbListTableNames(db_connection, FALSE)
  return(grep(name_part, table_names, fixed = TRUE, value = TRUE))
}

#' Get First Table with Name Part
#'
#' This function retrieves the first table name in a database connection that contains a specific part in its name.
#' If there are multiple tables that match the name part, an error is thrown. If no tables match, an error is thrown
#' depending on the `stop_on_empty_result` parameter.
#'
#' @param db_connection A database connection object.
#' @param name_part A string representing the part of the table name to search for.
#' @param stop_on_empty_result A logical value indicating whether to stop with an error if no tables match the name part.
#'        Default is \code{TRUE}.
#' @return A character string representing the first table name that matches the specified name part, if exactly one match is found.
#'
getFirstTableWithNamePart <- function(db_connection, name_part, stop_on_empty_result = TRUE) {
  table_names <- getTablesWithNamePart(db_connection, name_part)
  if (length(table_names) == 1) {
    return(table_names[1])
  } else if (length(table_names) > 1) {
    connection_display <- etlutils::getPrintString(db_connection)
    etlutils::stopWithError("There are multiple tables with name part '", name_part, "' found for DB connection ", connection_display, "\n",
                            "Tables: ", paste0(table_names, collapse = ","), "\n",
                            "Hint: choose the namepart so that the result tablename is unique.")
  } else if (stop_on_empty_result) {
    connection_display <- etlutils::getPrintString(db_connection)
    etlutils::stopWithError("No table with name part '", name_part, "' found for DB connection ", connection_display, "\n")
  }
}
