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
  etlutils::createConnectionAndWriteTablesToDatabase(tables,
                                                     dbname = DB_GENERAL_NAME,
                                                     host = DB_GENERAL_HOST,
                                                     port = DB_GENERAL_PORT,
                                                     user = DB_CDS2DB_USER,
                                                     password = DB_CDS2DB_PASSWORD,
                                                     schema = DB_CDS2DB_SCHEMA_IN,
                                                     clear_before_insert = clear_before_insert)
}

#' Retrieve Untyped RAW Data from Database
#'
#' This function connects to a database, retrieves the table names, reads the tables, and returns
#' the data as a list of data frames.
#'
#' @param table_names names of the tables or views to load
#'
#' @return A list of data frames where each data frame corresponds to a table from the database.
#'
readTablesFromDatabase <- function(table_names) {
  etlutils::createConnectionAndReadTablesFromDatabase(dbname = DB_GENERAL_NAME,
                                                      host = DB_GENERAL_HOST,
                                                      port = DB_GENERAL_PORT,
                                                      user = DB_CDS2DB_USER,
                                                      password = DB_CDS2DB_PASSWORD,
                                                      schema = DB_CDS2DB_SCHEMA_OUT,
                                                      table_names = table_names)
}

#' Retrieve Data from Database using a Predefined Connection Configuration
#'
#' This function executes a SQL query on a database using a predefined set of
#' connection parameters, which are sourced from globally defined variables.
#'
#' @param query A string representing the SQL query to be executed.
#'
#' @return A data.table containing the result of the SQL query.
#'
#' @export
getQueryFromDatabase <- function(query) {
  etlutils::dbConnectAndGetQuery(dbname = DB_GENERAL_NAME,
                                 host = DB_GENERAL_HOST,
                                 port = DB_GENERAL_PORT,
                                 user = DB_CDS2DB_USER,
                                 password = DB_CDS2DB_PASSWORD,
                                 schema = DB_CDS2DB_SCHEMA_OUT,
                                 query = query)
}
