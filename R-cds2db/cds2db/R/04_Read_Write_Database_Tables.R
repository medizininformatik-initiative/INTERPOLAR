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
writeTablesToDatabase <- function(tables, stop_if_table_not_empty = FALSE) {
  etlutils::createConnectionAndWriteTablesToDatabase(tables,
                                                     dbname = DB_GENERAL_NAME,
                                                     host = DB_GENERAL_HOST,
                                                     port = DB_GENERAL_PORT,
                                                     user = DB_CDS2DB_USER,
                                                     password = DB_CDS2DB_PASSWORD,
                                                     schema = DB_CDS2DB_SCHEMA_IN,
                                                     stop_if_table_not_empty = stop_if_table_not_empty)
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
#' @param params A list of parameters to be safely inserted into the SQL query, allowing for
#'        parameterized queries. If NA, no parameters will be used. This is useful for preventing
#'        SQL injection and handling dynamic query inputs.
#'
#' @return A data.table containing the result of the SQL query.
#'
#' @export
getQueryFromDatabase <- function(query, params = NULL) {
  etlutils::dbConnectAndGetQuery(dbname = DB_GENERAL_NAME,
                                 host = DB_GENERAL_HOST,
                                 port = DB_GENERAL_PORT,
                                 user = DB_CDS2DB_USER,
                                 password = DB_CDS2DB_PASSWORD,
                                 schema = DB_CDS2DB_SCHEMA_OUT,
                                 query = query,
                                 params = params)
}
