#' Initialize Configuration Constants from TOML Files
#'
#' This function loads configuration settings from two TOML files: one for the module
#' configuration and one for the database configuration.
#' It sets all variables defined in these files in the global context. The function is
#' designed to be run at the start of a session to set up necessary configurations.
#' The path to the module configuration file is determined based on whether the session
#' is interactive or not, defaulting to './R-db2frontend/db2frontend_config.toml' in
#' interactive sessions. The path to the database configuration file is specified by
#' the global variable PATH_TO_DB_CONFIG_TOML.
#'
#' @seealso \code{\link[etlutils]{initConstants}} for details on how configuration settings are loaded and set.
#'
initConstantsAndLogging <- function() {
  if (!exists("PROJECT_NAME", envir = .GlobalEnv)) {
    # Path to the module configuration TOML file
    path2config_toml <- './R-db2frontend/db2frontend_config.toml'
    # Load module configuration settings
    config <- etlutils::initConstants(path2config_toml)
    # Load database configuration settings
    etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)
    # Set the PROJECT_NAME to 'db2frontend'
    PROJECT_NAME <<- "db2frontend"
    etlutils::createDIRS(PROJECT_NAME)
    # Create globally used process_clock
    etlutils::createClock()
    # log all console outputs and save them at the end
    etlutils::startLogging(PROJECT_NAME)
    # log all configuration parameters but hide value with parameter name starts with "FHIR_"
    etlutils::catList(config, "Configuration:\n--------------\n", "\n", "^FHIR_")
  }
}

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
#' @export
importDB2Redcap <- function() {
  # Initialize constants
  initConstantsAndLogging()

  try(etlutils::runLevel1("Run Import from Database to Frontend", {


    # Establish connection to the database
    db_connection <- etlutils::dbConnect(dbname = DB_GENERAL_NAME,
                                         host = DB_GENERAL_HOST,
                                         port = DB_GENERAL_PORT,
                                         user = DB_DB2FRONTEND_USER,
                                         password = DB_DB2FRONTEND_PASSWORD,
                                         schema = DB_DB2FRONTEND_SCHEMA_OUT)

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
      data_from_db <- etlutils::dbGetQuery(db_connection, query)

      # Import data to REDCap
      redcapAPI::importRecords(rcon = frontend_connection, data = data_from_db)
    }

    # Disconnect from the database
    etlutils::dbDisconnect(db_connection)

  }))
}

#' Retrieve Frontend Table Names
#'
#' This function returns a vector of predefined frontend table names used in the REDCap export
#' process.
#'
getFrontendTableNames <- function() {
  # TODO: Read this information from frontend_table_desciptin.xlsx
  c("patient", "fall", "medikationsanalyse", "mrpdokumentation_validierung")
}

#' Copy REDCap Content to Database
#'
#' This function retrieves data from an existing REDCap project and imports this data into
#' the table in a database (defined in the schema `_in`).
#' It establishes a connection to the REDCap project using API credentials and fetches relevant
#' patient, case, medication analysis and MRP data,
#' then connects a PostgreSQL database  to  import the data into it.
#'
#' Note: Database and REDCap connection details (e.g., credentials, table names) are
#' required to be predefined or passed as arguments (not included in this example for
#' security reasons).
#'
#' @return Invisible. The function is called for its side effects: exporting data
#' out of REDCap and does not return a value.
#'
#' @examples
#' # Before using this function, ensure that variables `dbname`, `dbhost`, `dbport`,
#' # `dbfrontenduser`, `dbfrontendpassword`, `dbfrontendoptionsout`, `url`, and `token`
#' # are correctly set up with your database and REDCap project details.
#' # This is a placeholder example and won't run without proper setup:
#' # copyRedcap2DB()
#'
#' @export
importRedcap2DB <- function() {

  try(etlutils::runLevel1("Run Import from Frontend to Database", {

    #get data from patient view / tabelle, schema _out
    initConstantsAndLogging()

    #connect to REDCap
    frontend_connection <- redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)

    form_names <- getFrontendTableNames()

    tables2Export <- list()

    # get data from REDCap
    for (form_name in form_names) {
      tables2Export[[form_name]] <- redcapAPI::exportRecordsTyped(rcon = frontend_connection, forms = form_name)
    }

    #establish connection to db
    db_connection <- etlutils::dbConnect(dbname = DB_GENERAL_NAME,
                                         host = DB_GENERAL_HOST,
                                         port = DB_GENERAL_PORT,
                                         user = DB_DB2FRONTEND_USER,
                                         password = DB_DB2FRONTEND_PASSWORD,
                                         schema = DB_DB2FRONTEND_SCHEMA_IN)

    # write tables to database
    for (i in seq_along(tables2Export)) {
      table_name <- paste0(names(tables2Export)[i], "_fe")
      etlutils::dbAddContent(db_connection, table_name, tables2Export[[i]])
    }

    #disconnect from db
    etlutils::dbDisconnect(db_connection)

  }))

}
