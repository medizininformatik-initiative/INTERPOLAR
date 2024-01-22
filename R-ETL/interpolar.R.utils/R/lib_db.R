#' Get a database connection
#'
#' This function establishes a connection to a PostgreSQL database using the specified credentials.
#'
#' @param user The username for the database connection.
#' @param password The password for the database connection.
#' @param dbname The name of the database.
#' @param host The host address where the database is located.
#' @param port The port number for the database connection.
#' @param schema The schema under which the tables can be found
#'
#' @return A database connection object.
#'
#' @export
getDBConnection <- function(user = DB_USER,
                            password = DB_PASSWORD,
                            dbname = DB_NAME,
                            host = DB_HOST,
                            port = DB_PORT,
                            schema = DB_SCHEMA) {

  db_connection <- DBI::dbConnect(RPostgres::Postgres(),
                                  dbname = dbname,
                                  host = host,
                                  port = port,
                                  user = user,
                                  password = password,
                                  options = paste0("-c search_path=", schema))
  # command line would be:
  # psql -p DB_PORT -U DB_USER -d DB_NAME -h DB_HOST
  # or with values
  # psql -p 5431 -U user_1234 -d db_with_fancy_name -h localhost

  ## get more than default (4MB) memory for this connectoin
  DBI::dbExecute(db_connection, "set work_mem to '32MB';")
  return(db_connection)
}

#' Show the structure of tables in a database
#'
#' This function retrieves the list of existing table names in a database connection and displays their structure.
#'
#' @param db_connection A valid database connection object.
#'
#' @export

showTablesStructure <- function(db_connection) {
  # Get existing table names
  tables <- DBI::dbListTables(db_connection)

  # Display structure of tables
  utils::str(tables)
}


#' Add table content to a PostgreSQL database
#'
#' This function inserts rows from a data.table or data.frame into a specified PostgreSQL table.
#'
#' @param db_connection A valid database connection object.
#' @param table_name The name of the table in the database.
#' @param table A data.table or data.frame containing the rows to be inserted.
#'
#' @export
addTableContentToDatabase <- function(db_connection, table_name, table) {
  #print(paste("Inserting rows into", table_name, appendLF = FALSE))
  time0 <- Sys.time()
  row_count <- nrow(table)
  if (row_count > 0) {
    RPostgres::dbAppendTable(db_connection, table_name, table)
  }
  duration <- difftime(Sys.time(), time0, units = "secs")
  print(paste0("Inserted in ", table_name, ", ", row_count, " rows (took ", duration, " seconds)"))
}

#' Delete all rows from a table in the database.
#'
#' This function deletes all rows from a specified table in the database.
#'
#' @param db_connection A database connection object.
#' @param table_name    The name of the table from which rows should be deleted.
#' @return              The result of the delete operation.
#'
#' @examples
#' \dontrun{
#' # Connect to a database (replace with your actual connection details)
#' con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "your_database.db")
#'
#' # Delete all rows from the "your_table" table
#' deleteTableContentFromDatabase(con, "your_table")
#' }
#'
#' @export
deleteTableContentFromDatabase <- function(db_connection, table_name) {
  DBI::dbExecute(db_connection, paste0('DELETE FROM ', table_name, ';'))
}
