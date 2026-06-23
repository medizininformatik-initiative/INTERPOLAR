getRedcapURL <- function() {
  if (exists("DEBUG_REDCAP_PORT")) {
    redcap_host <- if (exists("DEBUG_REDCAP_HOST")) DEBUG_REDCAP_HOST else "127.0.0.1"
    url <- paste0("http://", redcap_host, ":", DEBUG_REDCAP_PORT, "/redcap/api/")
  } else {
    url <- REDCAP_URL
  }
  return(url)
}

getRedcapToken <- function() {
  if (etlutils::isDefinedAndNotEmpty("DEBUG_REDCAP_TOKEN")) {
    token <- DEBUG_REDCAP_TOKEN
  } else {
    token <- REDCAP_TOKEN
  }
  return(token)
}

#' Establish a Valid Connection to REDCap
#'
#' This function establishes a connection to a REDCap server using a specified API token
#' and URL. It validates the connection by attempting to export metadata from the REDCap
#' project.
#'
#' @return A valid REDCap connection object of class `redcapConnection` if the connection
#'         is successful.
#'
#' @details Throws an error if the connection cannot be established, if the API token or URL is
#'          invalid, or if no valid metadata is retrieved from REDCap.
#'
#' @export
getRedcapConnection <- function() {
  # Attempt to connect to REDCap
  frontend_connection <- tryCatch({
    suppressWarnings(redcapAPI::redcapConnection(url = getRedcapURL(), token = getRedcapToken()))
  }, error = function(e) {
    stop("Failed to establish a REDCap connection. Error: ", e$message)
  })

  if (etlutils::isDefinedAndNotEmpty("REDCAP_CSV_DELIMITER")) {
    frontend_connection$set_csv_delimiter(REDCAP_CSV_DELIMITER)
  }

  # Test the connection by fetching metadata
  meta_data <- tryCatch({
    suppressWarnings(redcapAPI::exportMetaData(frontend_connection))
  }, error = function(e) {
    stop("Invalid API token or REDCap URL! Error: ", e$message)
  })

  # Ensure metadata retrieval was successful
  if (is.null(meta_data) || nrow(meta_data) == 0) {
    stop("Connection failed: No valid metadata retrieved. Check REDCap server and token.")
  }

  return(frontend_connection)
}

#' Retrieve Database Table and Column Names
#'
#' This function retrieves a predefined list of database table names along with
#' their associated column names. The information is sourced from an external
#' Excel file and is used in the database export and REDCap import process.
#'
#' @return A named list where each element represents a table, and its value is a
#'   data frame containing the corresponding column names and details.
getFrontendTableDescription <- function() {
  table_description_path <- system.file("extdata", "Frontend_Table_Description.xlsx", package = "db2frontend")
  table_description <- etlutils::loadTableDescriptionFile(table_description_path, "frontend_table_description")
  table_description <- etlutils::splitTableToList(table_description, "TABLE_NAME", TRUE)
  return(table_description)
}

#' Delete All Records from REDCap
#'
#' This function removes all records from the connected REDCap project. It first retrieves
#' all existing record IDs and then deletes them in bulk.
#'
#' @details The function establishes a connection to REDCap using `getRedcapConnection()`,
#'          fetches all record IDs, and deletes them using `deleteRecords()`. If no records
#'          are found, a message is displayed instead.
#'
#' @export
deleteRedcapContent <- function() {

  # Define REDCap API connection
  frontend_connection <- db2frontend::getRedcapConnection()

  # Retrieve all record IDs
  records <- suppressWarnings(redcapAPI::exportRecords(frontend_connection, fields = "record_id"))

  # Check if there are records to delete
  if (nrow(records) > 0) {
    record_ids <- records$record_id

    # Delete all records
    delete_result <- suppressWarnings(redcapAPI::deleteRecords(frontend_connection, records = record_ids))

  } else {
    message("No records found in the project.")
  }
}

#' Get all importable REDCap field names, including *_complete fields
#'
#' @param rcon A REDCap connection object from redcapAPI
#'
#' @return A character vector of REDCap field names used for imports
#'
getRedcapFieldNames <- function(rcon) {

  field_names <- redcapAPI::exportFieldNames(rcon)$export_field_name
  metadata <- redcapAPI::exportMetaData(rcon)
  calc_field_names <- metadata$field_name[metadata$field_type == "calc"]
  field_names <- setdiff(field_names, calc_field_names)

  instruments <- redcapAPI::exportInstruments(rcon)$instrument_name

  return(unique(c(
    field_names,
    "redcap_repeat_instrument",
    "redcap_repeat_instance",
    "redcap_data_access_group",
    paste0(instruments, "_complete")
  )))
}
