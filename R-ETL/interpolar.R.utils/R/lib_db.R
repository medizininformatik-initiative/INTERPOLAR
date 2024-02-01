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
getDBConnection <- function(user, password, dbname, host, port, schema) {
  db_connection <- DBI::dbConnect(RPostgres::Postgres(),
                                  dbname = dbname,
                                  host = host,
                                  port = port,
                                  user = user,
                                  password = password,
                                  options = paste0('-c search_path=', schema))
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
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  time0 <- Sys.time()
  row_count <- nrow(table)
  if (row_count > 0) {
    db_insert_result <- try(RPostgres::dbAppendTable(db_connection, table_name, table))
    if (isError(db_insert_result)) {
      print(db_insert_result)
      STOP <<- TRUE
    }
  }
  duration <- difftime(Sys.time(), time0, units = 'secs')
  print(paste0('Inserted in ', table_name, ', ', row_count, ' rows (took ', duration, ' seconds)', ifelse(STOP, ' with error', '')))
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
#' con <- DBI::dbConnect(RSQLite::SQLite(), dbname = 'your_database.db')
#'
#' # Delete all rows from the 'your_table' table
#' deleteTableContentFromDatabase(con, 'your_table')
#' }
#'
#' @export
deleteTableContentFromDatabase <- function(db_connection, table_name) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  DBI::dbExecute(db_connection, paste0('DELETE FROM ', table_name, ';'))
}

#' Add Internal Columns to Database Tables
#'
#' This function modifies a list of data.tables by adding several internal columns
#' specific for database management. These columns include a unique ID column for each table,
#' columns for input and last check datetimes, and a column for the current dataset status.
#' All added columns are initialized with NA values. The unique ID column is placed as the
#' first column in each table.
#'
#' @param tables A list of data.table objects. Each data.table represents a table in the database
#'               where internal columns need to be added.
#'
#' @return The modified list of data.tables with added internal columns.
#'
#' @examples
#' # Example usage:
#' library(data.table)
#' my_tables <- list(table1 = data.table(id = 1:3, data = c("A", "B", "C")),
#'                   table2 = data.table(id = 4:6, data = c("D", "E", "F")))
#' my_tables <- addDatabaseInternalColumns(my_tables)
#'
#' # Now `my_tables` will have additional internal columns in each data.table
#'
#' @export
addDatabaseInternalColumns <- function(tables) {
  # Postgres only accepts lower case names -> convert them hard here
  names(tables) <- tolower(names(tables))
  for (i in seq_along(tables)) {
    table_name <- tolower(names(tables)[i])
    db_internal_id_column_name <- paste0(table_name, '_id')
    tables[[i]][, (db_internal_id_column_name) := NA_integer_]
    tables[[i]][, input_datetime := as.Date(NA_character_)]
    tables[[i]][, last_check_datetime := as.Date(NA_character_)]
    tables[[i]][, current_dataset_status := NA_character_]
    setcolorder(tables[[i]], db_internal_id_column_name)
  }
  tables
}

