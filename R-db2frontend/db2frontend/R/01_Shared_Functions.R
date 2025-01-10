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
