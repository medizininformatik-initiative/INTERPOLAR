#' Write Data Tables to a Database
#'
#' This function takes a list of data.table objects and writes them to a specified database.
#' It establishes a database connection using predefined credentials and configuration parameters.
#' Users have the option to clear existing table contents before writing new data by setting
#' `clear_before_insert` to TRUE. The function writes all provided tables.
#'
#' @param tables A named list of data.table objects to be written to the database. Each element in
#'               the list represents a dataset intended for a corresponding table in the database.
#' @param clear_before_insert A logical flag indicating whether to clear the table contents
#'                            before inserting new data. Defaults to FALSE.
writeTablesToDatabase <- function(tables, clear_before_insert = FALSE) {
  etlutils::writeTablesToDatabase(tables,
                                  db_user = DB_CDS2DB_USER,
                                  db_password = DB_CDS2DB_PASSWORD,
                                  db_name = DB_GENERAL_NAME,
                                  db_host = DB_GENERAL_HOST,
                                  db_port = DB_GENERAL_PORT,
                                  db_schema = DB_CDS2DB_SCHEMA_IN,
                                  clear_before_insert = clear_before_insert)
}

#' Retrieve Untyped RAW Data from Database
#'
#' This function connects to a database, retrieves the table names, reads the tables, and returns
#' the data as a list of data frames.
#'
#' @return A list of data frames where each data frame corresponds to a table from the database.
#'
readUntypedRAWDataFromDatabase <- function() {
  etlutils::readTablesFromDatabase(db_user = DB_CDS2DB_USER,
                                   db_password = DB_CDS2DB_PASSWORD,
                                   db_name = DB_GENERAL_NAME,
                                   db_host = DB_GENERAL_HOST,
                                   db_port = DB_GENERAL_PORT,
                                   db_schema = DB_CDS2DB_SCHEMA_OUT)
}
