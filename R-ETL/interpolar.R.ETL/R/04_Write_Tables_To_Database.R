#' Write Data Tables to a Database
#'
#' This function takes a list of data tables and writes them to a specified database. It establishes
#' a database connection using provided credentials and configuration, adds necessary internal
#' columns for database processing, and writes each table to the database. Users can choose to
#' write all tables or specify which tables to write.
#'
#' @param tables A named list of data.table objects to be written to the database. Each element in
#'               the list represents a table in the database.
#' @param table_names An optional vector of table names to specify which tables should be written
#'                    to the database. If `NA` (default), all tables in the `tables` list are written.
#'
#' @examples
#' \dontrun{
#'   # Example usage:
#'   my_tables <- list(table1 = data.table(id = 1:3, data = c("A", "B", "C")),
#'                     table2 = data.table(id = 4:6, data = c("D", "E", "F")))
#'   writeTablesToDatabase(my_tables)
#'
#'   # Write only specific tables
#'   writeTablesToDatabase(my_tables, table_names = c("table1"))
#' }
#'
#' @export
writeTablesToDatabase <- function(tables, table_names = NA) {
  db_connection <- interpolar.R.utils::getDBConnection(
    user = DB_USER_ETL,
    password = DB_PASSWORD_ETL,
    dbname = DB_NAME_ETL,
    host = DB_HOST_ETL,
    port = DB_PORT_ETL,
    schema = DB_SCHEMA_ETL
  )

  # Add columns which ate needed for DB internal processing
  interpolar.R.utils::addDatabaseInternalColumns(tables)

  # write all tables (table_names == NA) or only tables with the gien names
  if (is.na(table_names)) {
    table_names <- names(tables)
  }

  # write tables to DB
  for (table_name in table_names) {
    table <- tables[[table_name]]
    interpolar.R.utils::addTableContentToDatabase(db_connection, table_name, table)
  }

}
