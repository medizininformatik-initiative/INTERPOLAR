#' Retrieve Frontend Table Names
#'
#' This function returns a vector of predefined frontend table names used in the REDCap export
#' process.
#'
getFrontendTableNames <- function() {
  # TODO: Read this information from frontend_table_desciptin.xlsx
  c("patient", "fall", "medikationsanalyse", "mrpdokumentation_validierung")
}

#' Adjust R Data Table to Match PostgreSQL Table Structure
#'
#' This function adjusts an R data.table to match the structure of a specified
#' PostgreSQL table by retrieving the table's schema and converting the data types
#' accordingly.
#'
#' @param con A database connection object. This connection must be established
#'   using an appropriate database driver.
#' @param dt A data.table object containing the data to be adjusted.
#' @param table_name A character string representing the name of the PostgreSQL table
#'   whose schema will be used for adjustment.
#'
#' @return A data.table that has been adjusted to match the PostgreSQL table structure,
#'   including appropriate column names and converted data types.
#'
adjustTableToDBTable <- function(con, dt, table_name) {
  # 1. Get the PostgreSQL table columns and types
  db_columns <- etlutils::getDBTableColumns(con, table_name)
  # 2. Convert the R data.table columns to match the PostgreSQL types
  adjusted_dt <- etlutils::convertToDBTypes(dt, db_columns)
  return(adjusted_dt)
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
importRedcap2DB <- function() {

    #connect to REDCap
    frontend_connection <- redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)

    form_names <- getFrontendTableNames()

    tables2Export <- list()

    # get data from REDCap
    for (form_name in form_names) {
      dt <- data.table::setDT(redcapAPI::exportRecordsTyped(rcon = frontend_connection, forms = form_name))
      redcapAPI::reviewInvalidRecords(dt)
      data.table::set(dt, j = "redcap_repeat_instrument", value = ifelse(!is.na(dt$redcap_repeat_instrument), form_name, NA))
      tables2Export[[form_name]] <- dt
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
      tables2Export[[i]] <- adjustTableToDBTable(db_connection, tables2Export[[i]], table_name)
      etlutils::dbAddContent(db_connection, table_name, tables2Export[[i]])
    }

    #disconnect from db
    etlutils::dbDisconnect(db_connection)
}
