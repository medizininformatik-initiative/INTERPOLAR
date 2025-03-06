#' Establish a Valid Connection to REDCap
#'
#' This function establishes a connection to a REDCap server using a specified API token
#' and URL. It performs a validation check by attempting to export metadata from the REDCap
#' project to ensure that the connection is valid.
#'
#' @return A valid REDCap connection object of class `redcapConnection` if the connection
#'         is successful.
#'
#' @details Throws An error if the connection cannot be established, if the API token or URL is
#'          invalid, or if no valid metadata is retrieved from REDCap.
#'
getRedcapConnection <- function() {
  # Connect to REDCap
  frontend_connection <- redcapAPI::redcapConnection(url = REDCAP_URL, token = REDCAP_TOKEN)

  # Run REDCap metadata export to test the connection
  meta_data <- tryCatch({
    redcapAPI::exportMetaData(frontend_connection)
  }, error = function(e) {
    stop("Invalid API token or REDCap URL! Error: ", e$message)
  })

  # Validate connection test result
  if (!"field_name" %in% colnames(meta_data)) {
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
