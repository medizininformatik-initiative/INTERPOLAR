#' Copy Database Content to Frontend
#'
#' This function retrieves data from the view or table in a database
#' (defined in the schema `_out`) and imports this data into an existing REDCap project.
#' It establishes a connection to a PostgreSQL database, fetches relevant data for
#' each table defined in `getDBTableAndColumnNames`, then connects to the REDCap project
#' using API credentials and imports the data.
#'
#' Note: Database and REDCap connection details (e.g., credentials, table names) are
#' required to be predefined or passed as arguments (not included in this example for
#' security reasons).
#'
#' @return Invisible. The function is called for its side effects: importing data
#' into REDCap and does not return a value.
#'
importDB2Redcap <- function() {

  # Connect to REDCap
  frontend_connection <- getRedcapConnection()

  # Get splitted frontend table descriptions
  table_description <- getFrontendTableDescription()

  table_names <- names(table_description)

  # Iterate over tables and columns to fetch and send data
  for (i in seq_along(table_names)) {

    table_name <- table_names[i]

    #TODO. klären, warum diese beiden Tabels hier ausgeschlossen wurden und ob das wirklich sein muss
#    if(!(table_name %in% c("risikofaktor", "trigger"))) {

      db_generated_id_column_name <- paste0(table_name, "_fe_id")
      columns <- c(db_generated_id_column_name, table_description[[table_name]]$COLUMN_NAME)

      # Create SQL query dynamically based on columns
      query <- sprintf("SELECT %s FROM v_%s", paste(columns, collapse = ", "), table_name)

      # Fetch data from the database
      data_from_db <- etlutils::dbGetReadOnlyQuery(query, lock_id = "importDB2Redcap()")

      table_filename_prefix <- if (exists("DEBUG_DAY")) paste0(DEBUG_DAY, "_") else ""
      etlutils::writeRData(data_from_db, paste0(table_filename_prefix, "db2frontend_", i, "_", table_name))

      # Import data to REDCap
      tryCatch({
        redcapAPI::importRecords(rcon = frontend_connection, data = data_from_db)
      }, error = function(e) {
        message("This error may have occurred because the user preferences in the Redcap project ",
                "have been changed. Use the default values if possible.")
        stop(e$message)
      })
#    }
  }

}
