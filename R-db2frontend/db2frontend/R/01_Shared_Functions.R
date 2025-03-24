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
    redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)
  }, error = function(e) {
    stop("Failed to establish a REDCap connection. Error: ", e$message)
  })

  # Test the connection by fetching metadata
  meta_data <- tryCatch({
    redcapAPI::exportMetaData(frontend_connection)
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
  table_description <- etlutils::splitTableToList(table_description, "TABLE_NAME")
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
deleteRedcapContent <- function() {

  # Define REDCap API connection
  frontend_connection <- db2frontend::getRedcapConnection()

  # Retrieve all record IDs
  records <- redcapAPI::exportRecords(frontend_connection, fields = "record_id")

  # Check if there are records to delete
  if (nrow(records) > 0) {
    record_ids <- records$record_id

    # Delete all records
    delete_result <- redcapAPI::deleteRecords(frontend_connection, records = record_ids)

  } else {
    message("No records found in the project.")
  }
}
