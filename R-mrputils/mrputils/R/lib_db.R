#' Establish a Connection to a PostgreSQL Database
#'
#' This function establishes a connection to a PostgreSQL database using the specified credentials and settings.
#' It configures the connection to use a specific schema and adjusts the `work_mem` setting to allow more memory for
#' operations, enhancing performance for tasks that require more memory.
#'
#' @param user The username for the database connection.
#' @param password The password for the database connection.
#' @param dbname The name of the database.
#' @param host The host address where the database is located.
#' @param port The port number for the database connection.
#' @param schema The schema under which the tables can be found. This sets the search path to the specified schema.
#'
#' @return A database connection object that is configured to use the specified schema and has an increased `work_mem`
#' setting.
#'
#' @export
dbConnect <- function(user, password, dbname, host, port, schema) {
  db_connection <- DBI::dbConnect(RPostgres::Postgres(),
                                  dbname = dbname,
                                  host = host,
                                  port = port,
                                  user = user,
                                  password = password,
                                  options = paste0('-c search_path=', schema))
  # Increase memory allocation for this connection to improve performance for memory-intensive operations
  DBI::dbExecute(db_connection, "set work_mem to '32MB';")
  return(db_connection)
}

#' Close Database Connection
#'
#' This function serves as a wrapper around `DBI::dbDisconnect`, providing a simplified
#' interface for closing an open database connection. It ensures that the connection
#' is properly closed to free up resources.
#'
#' @param db_connection A valid database connection object created by `DBI::dbConnect` or
#' a similar DBI connection function. This connection will be closed by this function.
#'
#' @return Invisible `TRUE` if the disconnection was successful, otherwise an error is thrown
#' by the underlying DBI function.
#'
#' @seealso \code{\link[DBI]{dbDisconnect}} for the underlying DBI function.
#' @export
dbDisconnect <- function(db_connection) {
  DBI::dbDisconnect(db_connection)
}

#' List Table Names in a Database
#'
#' Retrieves and displays the list of existing table names in a database connection. This function
#' provides a quick overview of all tables within the specified database, offering immediate insight
#' into the database structure without returning the actual data.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#' This connection should already be established and active to successfully retrieve table names.
#'
#' @return Invisibly returns a character vector of table names. The function primarily prints
#' these names using `utils::str()` for immediate inspection, which is useful for debugging or
#' quick checks in an interactive R session.
#'
#' @seealso
#' \code{\link[DBI]{dbConnect}} to learn about establishing database connections.
#' \code{\link[DBI]{dbListTables}} for the underlying DBI function that this wrapper utilizes.
#' \code{\link[utils]{str}} to explore the utility function used for displaying the table names.
#'
#' @export
dbListTables <- function(db_connection) {
  # Get existing table names from the database connection
  tables <- DBI::dbListTables(db_connection)
  # Display the table names using the str() function for a concise overview
  utils::str(tables)
}

#' Insert Rows into a PostgreSQL Table
#'
#' This function inserts rows from a `data.table` or `data.frame` into a specified table within a PostgreSQL database.
#' It automatically converts the table name to lower case to align with PostgreSQL's case sensitivity conventions.
#' The function attempts to insert all provided rows into the database and reports the number of rows inserted
#' along with the duration of the operation. In case of an error during the insert operation, it prints out the error
#' message and stops execution.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#' @param table_name The name of the target table in the PostgreSQL database where rows will be inserted.
#'                   The table name is automatically converted to lower case.
#' @param table A `data.table` or `data.frame` containing the rows to be inserted into the specified table.
#'
#' @export
dbAddContent <- function(db_connection, table_name, table) {
  # Convert table name to lower case for PostgreSQL
  table_name <- tolower(table_name)
  # Measure start time
  time0 <- Sys.time()
  # Get row count for reporting
  row_count <- nrow(table)
  if (row_count > 0) {
    # Try to append table content and catch any error
    db_insert_result <- try(RPostgres::dbAppendTable(db_connection, table_name, table))
    # Check for error in insertion and stop execution if error occurs
    if (isError(db_insert_result)) {
      print(db_insert_result)
      STOP <<- TRUE
    }
  }
  # Calculate and print duration of operation
  duration <- difftime(Sys.time(), time0, units = 'secs')
  print(paste0('Inserted in ', table_name, ', ', row_count, ' rows (took ', duration, ' seconds)', ifelse(STOP, ' with error', '')))
}

#' Delete All Rows from a Database Table
#'
#' This function deletes all rows from a specified table in the database. It is designed to
#' work with PostgreSQL databases, where table names are case-sensitive and typically lower case.
#' The function converts the provided table name to lower case before executing the delete operation.
#'
#' @param db_connection A database connection object created by `DBI::dbConnect` or a similar
#'                      DBI connection function. This connection should be active and valid for
#'                      the deletion to work.
#' @param table_name The name of the table from which all rows should be deleted. The table name
#'                   will be converted to lower case to comply with PostgreSQL naming conventions.
#'
#' @return An integer value indicating the number of rows affected by the delete operation. For
#'         a successful deletion, this will be the number of rows that were in the table prior
#'         to deletion.
#'
#' @export
dbDeleteContent <- function(db_connection, table_name) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  DBI::dbExecute(db_connection, paste0('DELETE FROM ', table_name, ';'))
}
