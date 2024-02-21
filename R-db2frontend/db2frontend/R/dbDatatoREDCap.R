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
initConstants <- function() {
  # Path to the module configuration TOML file
  path2config_toml <- './R-db2frontend/db2frontend_config.toml'
  # Load module configuration settings
  etlutils::initConstants(path2config_toml)
  # Load database configuration settings
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)
}

#' Copy Database Content to REDCap
#'
#' This function retrieves data from the view or table in a database
#' (defined in the schema `_out`) and imports this data into an existing REDCap project.
#' It establishes a connection to a PostgreSQL database, fetches relevant patient data,
#' then connects to the REDCap project using API credentials and imports the data.
#'
#' Note: Database and REDCap connection details (e.g., credentials, table names) are
#' required to be predefined or passed as arguments (not included in this example for
#' security reasons).
#'
#' @return Invisible. The function is called for its side effects: importing data
#' into REDCap and does not return a value.
#'
#' @examples
#' # Before using this function, ensure that variables `dbname`, `dbhost`, `dbport`,
#' # `dbfrontenduser`, `dbfrontendpassword`, `dbfrontendoptionsout`, `url`, and `token`
#' # are correctly set up with your database and REDCap project details.
#' # This is a placeholder example and won't run without proper setup:
#' # copyDB2Redcap()
#'
#' @export
copyDB2Redcap <- function() {
  #get data from patient view / tabelle, schema _out
  initConstants()
  #establish connection to db
  dbcon <- etlutils::dbConnect(DB_DB2FRONTEND_USER, DB_DB2FRONTEND_PASSWORD, DB_GENERAL_NAME, DB_GENERAL_HOST,
                   DB_GENERAL_PORT, DB_DB2FRONTEND_SCHEMA_OUT)


  #get relevant columns
  new_data <- DBI::dbGetQuery(dbcon, "SELECT record_id,pat_id,pat_name,pat_vorname,pat_ak_alter,
                              pat_gschlcht FROM patient")

  #connect to REDCap project
  redcapcon <- redcapAPI::redcapConnection(url = url,token = token)

  #send data to REDCap
  redcapAPI::importRecords(redcapcon, data = new_data, logfile = "log.txt")

  #disconnect from db
  DBI::dbDisconnect(dbcon)
}
