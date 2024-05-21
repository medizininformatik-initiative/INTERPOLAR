#' Write Data Tables to a Database
#'
#' This function takes a list of data.table objects and writes them to a specified database.
#' It establishes a database connection using predefined credentials and configuration parameters.
#' Users have the option to clear existing table contents before writing new data by setting
#' `clear_before_insert` to TRUE. The function can write all provided tables or only specific tables
#' if specified by the `table_names` parameter.
#'
#' @param tables A named list of data.table objects to be written to the database. Each element in
#'               the list represents a dataset intended for a corresponding table in the database.
#' @param table_names An optional vector of table names to specify which tables should be written
#'                    to the database. If `NA` (default), all tables in the `tables` list are written.
#' @param clear_before_insert A logical flag indicating whether to clear the table contents
#'                            before inserting new data. Defaults to FALSE.
#'
#' @examples
#' \dontrun{
#'   # Example usage:
#'   my_tables <- list(table1 = data.table(id = 1:3, data = c("A", "B", "C")),
#'                     table2 = data.table(id = 4:6, data = c("D", "E", "F")))
#'   writeTablesToDatabase(my_tables)
#'
#'   # Write only specific tables and clear contents before inserting
#'   writeTablesToDatabase(my_tables, table_names = c("table1"), clear_before_insert = TRUE)
#' }
#'
writeTablesToDatabase <- function(tables, table_names = NA, clear_before_insert = FALSE) {

  # write all tables (table_names == NA) or only tables with the given names
  if (isSimpleNA(table_names)) {
    table_names <- names(tables)
  }

  db_connection <- etlutils::dbConnect(
    user = DB_CDS2DB_USER,
    password = DB_CDS2DB_PASSWORD,
    dbname = DB_GENERAL_NAME,
    host = DB_GENERAL_HOST,
    port = DB_GENERAL_PORT,
    schema = DB_CDS2DB_SCHEMA_IN
  )

  db_table_names <- etlutils::dbListTables(db_connection)
  # Display the table names
  print(paste("The following tables are found in database:", paste(db_table_names, collapse = ", ")))
  if (is.null(db_table_names)) {
    warning("There are no tables found in database")
  }

  # write tables to DB
  for (table_name in table_names) {
    if (table_name %in% db_table_names) {
      table <- tables[[table_name]]
      if (clear_before_insert) {
        etlutils::dbDeleteContent(db_connection, table_name)
      }
      # Check column widths of table content
      etlutils::dbCheckContent(db_connection, table_name, table)
      # Add table content to DB
      etlutils::dbAddContent(db_connection, table_name, table)
    } else {
      warning(paste("Table", table_name, "not found in database"))
    }
  }
  etlutils::dbDisconnect(db_connection)
}
