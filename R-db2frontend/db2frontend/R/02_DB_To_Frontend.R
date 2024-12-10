#' Retrieve Database Table and Column Names
#'
#' This function returns a list of predefined database table names and their associated column names
#' that are used in the database export and REDCap import process.
#'
getDBTableAndColumnNames <- function() {
  # TODO: can we get this from an external source?
  list(v_patient = c("record_id", "patient_fe_id", "pat_id", "pat_cis_pid", "pat_name", "pat_vorname",
                     "pat_gebdat", "pat_aktuell_alter", "pat_geschlecht", "patient_complete"),
       v_fall = c("record_id", "redcap_repeat_instrument", "redcap_repeat_instance", "patient_id_fk",
                  "fall_fe_id", "fall_pat_id", "fall_id", "fall_studienphase",
                  "fall_station", "fall_aufn_dat", "fall_aufn_diag", "fall_gewicht_aktuell",
                  "fall_gewicht_aktl_einheit", "fall_groesse", "fall_groesse_einheit",
                  "fall_status", "fall_ent_dat", "fall_complete")
      )
}

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
    frontend_connection <- redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)

    # Get table and column names
    db_table_and_columns <- getDBTableAndColumnNames()

    # Iterate over tables and columns to fetch and send data
    for (table_name in names(db_table_and_columns)) {
      columns <- db_table_and_columns[[table_name]]

      # Create SQL query dynamically based on columns
      query <- sprintf("SELECT %s FROM %s", paste(columns, collapse = ", "), table_name)

      # Fetch data from the database
      data_from_db <- dbReadQuery(query, "importDB2Redcap()")
      # Import data to REDCap
      tryCatch({
        redcapAPI::importRecords(rcon = frontend_connection, data = data_from_db)
      }, error = function(e) {
        message("This error may have occurred because the user preferences in the Redcap project
                have been changed. Use the default values if possible.")
        stop(e$message)
      })

    }

}
