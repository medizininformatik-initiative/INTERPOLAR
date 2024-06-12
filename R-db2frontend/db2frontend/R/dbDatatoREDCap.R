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
  dbcon <- etlutils::dbConnect(dbname = DB_GENERAL_NAME,
                               host = DB_GENERAL_HOST,
                               port = DB_GENERAL_PORT,
                               user = DB_DB2FRONTEND_USER,
                               password = DB_DB2FRONTEND_PASSWORD,
                               schema = DB_DB2FRONTEND_SCHEMA_OUT)


  #connect to REDCap project
  redcapcon <- redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)

  #get relevant data for Patient and Fall (Phase 1a of INTERPOLAR)
  PatientFromDB <- DBI::dbGetQuery(dbcon,
      "SELECT record_id, patient_fe_id, pat_id, pat_name, pat_vorname, pat_gebdat, pat_aktuell_alter, pat_geschlecht,
       patient_complete FROM v_patient")

  FallFromDB <- DBI::dbGetQuery(dbcon,
       "SELECT record_id, redcap_repeat_instrument, redcap_repeat_instance, patient_id_fk, fall_fe_id, fall_pat_id, fall_id,
       fall_studienphase, fall_station, fall_aufn_dat, fall_aufn_diag, fall_gewicht_aktuell, fall_gewicht_aktl_einheit,
       fall_groesse, fall_groesse_einheit, fall_status, fall_ent_dat, fall_complete FROM v_fall")


  #send data to REDCap for Patient and Fall (Phase 1a of INTERPOLAR)
  redcapAPI::importRecords(redcapcon, data = PatientFromDB, logfile = "log.txt")
  redcapAPI::importRecords(redcapcon, data = FallFromDB, logfile = "log.txt")

  #disconnect from db
  DBI::dbDisconnect(dbcon)
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
copyRedcap2DB <- function() {
  #get data from patient view / tabelle, schema _out
  initConstants()

  #connect to REDCap project
  rcon <- redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)

  #get data from REDCap
  rc_pat<-redcapAPI::exportRecordsTyped(rcon,forms="patient")
  rc_fall<-redcapAPI::exportRecordsTyped(rcon,forms="fall")
  rc_medana<-redcapAPI::exportRecordsTyped(rcon,forms="medikationsanalyse")
  rc_mrp<-redcapAPI::exportRecordsTyped(rcon,forms="mrpdokumentation_validierung")

  #establish connection to db
  dbcon <- etlutils::dbConnect(dbname = DB_GENERAL_NAME,
                                host = DB_GENERAL_HOST,
                                port = DB_GENERAL_PORT,
                                user = DB_DB2FRONTEND_USER,
                                password = DB_DB2FRONTEND_PASSWORD,
                                schema = DB_DB2FRONTEND_SCHEMA_IN)


  #write to relevant tables
  DBI::dbAppendTable(dbcon,"patient_fe",rc_pat)
  DBI::dbAppendTable(dbcon,"fall_fe",rc_fall)
  DBI::dbAppendTable(dbcon,"medikationsanalyse_fe",rc_medana)
  DBI::dbAppendTable(dbcon,"mrpdokumentation_validierung_fe",rc_mrp)

  #disconnect from db
  DBI::dbDisconnect(dbcon)
}
