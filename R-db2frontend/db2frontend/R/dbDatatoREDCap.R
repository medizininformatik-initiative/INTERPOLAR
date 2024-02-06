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
  #establish connection to db
  dbcon <- dbConnect(RPostgres::Postgres(),
                     dbname = dbname,
                     host = dbhost,
                     port = dbport,
                     user = dbfrontenduser,
                     password = dbfrontendpassword,
                     options = dbfrontendoptionsout)

  #get relevant columns
  new_data <- DBI::dbGetQuery(dbcon, "SELECT record_id,pat_id,pat_name,pat_vorname,pat_ak_alter FROM patient")

  #connect to REDCap project
  redcapcon <- redcapAPI::redcapConnection(url = url,token = token)

  #send data to REDCap
  redcapAPI::importRecords(redcapcon, data = new_data, logfile = "log.txt")

  #disconnect from db
  DBI::dbDisconnect(dbcon)
}
