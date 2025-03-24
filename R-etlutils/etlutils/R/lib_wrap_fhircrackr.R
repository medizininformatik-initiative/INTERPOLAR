#' Get the global curl timeout value for fhir search requests
#'
#' Retrieves the CURL timeout value from the global environment if it exists;
#' otherwise, returns a default value of 1800 seconds.
#'
#' @return An integer representing the timeout in seconds.
getFhirSearchCurlTimeout <- function() {
  if (exists("FHIR_SEARCH_CURL_TIMEOUT", envir = .GlobalEnv)) {
    as.integer(FHIR_SEARCH_CURL_TIMEOUT)
  } else {
    1800
  }
}

#' Wrapper for fhircrackr::fhir_search with automatic Authentication
#'
#' @param request A string containing a fhir search request.
#' @param body A string containing the body for a POST request.
#' @param max_bundles An integer. How many bundles should be retrieved.
#' @param verbose An integer. Selects the verbosity. Defaults to 1.
#' @param max_attempts An integer. The number of attempts, if some error occurs.
#' @param delay_between_attempts An number. The time between two attempts in seconds.
#' @param log_errors Either NULL or a string indicating the name of a file
#'  in which to save the http errors.
#'  NULL means no error logging. When a file name is provided, the errors are saved in the specified file.
#'  Defaults to NULL. Regardless of the value of log_errors the most recent http error message whithin
#'  the current R session is saved internally and can be accessed with fhir_recent_http_error().
#' @param save_to_disc Either NULL or a string indicating the name of a directory
#' in which to save the bundles. If a directory name is provided, the bundles are saved as numerated xml-files
#' into the directory specified and not returned as a bundle list in the R session.
#' This is useful when a lot of bundles are to be downloaded and keeping them all in one R session might
#' overburden working memory. When the download is complete, the bundles can be loaded into R using fhir_load().
#' Defaults to NULL, i.e. bundles are returned as a list within the R session.
#' @param delay_between_bundles A numeric scalar specifying a time in seconds to wait between pages
#' of the search result, i.e. between downloading the current bundle and the next bundle.
#' This can be used to avoid choking a weak server with too many requests to quickly. Defaults to zero.
#' @return A fhir_bundle_list when save_to_disc = NULL (the default), else NULL.
#' @export
executeFHIRSearchVariation <- function(
  request                = fhircrackr::fhir_current_request(),
  body                   = NULL,
  max_bundles            = MAX_ENCOUNTER_BUNDLES,
  verbose                = 1,
  max_attempts           = 5,
  delay_between_attempts = 10,
  log_errors             = NULL,
  save_to_disc           = NULL,
  delay_between_bundles  = 0
) {

  # Set new timeout (e.g., 30 minutes)
  httr::set_config(httr::timeout(getFhirSearchCurlTimeout()))

  result <- if (!is.null(FHIR_TOKEN) && FHIR_TOKEN != "") {

    fhircrackr::fhir_search(
      request                = request,
      body                   = body,
      token                  = FHIR_TOKEN,
      max_bundles            = max_bundles,
      verbose                = verbose,
      delay_between_attempts = delay_between_attempts,
      log_errors             = if (!is.null(log_errors)) combineLogPaths(log_errors),
      save_to_disc           = if (!is.null(save_to_disc)) combineBundlePaths(save_to_disc),
      delay_between_bundles  = delay_between_bundles
    )
  } else if (!is.null(FHIR_SERVER_USER) && !is.null(FHIR_SERVER_PASS) && FHIR_SERVER_USER != "" && FHIR_SERVER_PASS != "") {

    fhircrackr::fhir_search(
      request                = request,
      body                   = body,
      username               = FHIR_SERVER_USER,
      password               = FHIR_SERVER_PASS,
      max_bundles            = max_bundles,
      verbose                = verbose,
      delay_between_attempts = delay_between_attempts,
      log_errors             = if (!is.null(log_errors)) combineLogPaths(log_errors),
      save_to_disc           = if (!is.null(save_to_disc)) combineBundlePaths(save_to_disc),
      delay_between_bundles  = delay_between_bundles
    )
  } else {

    fhircrackr::fhir_search(
      request                = request,
      body                   = body,
      max_bundles            = max_bundles,
      verbose                = verbose,
      delay_between_attempts = delay_between_attempts,
      log_errors             = if (!is.null(log_errors)) combineLogPaths(log_errors),
      save_to_disc           = if (!is.null(save_to_disc)) combineBundlePaths(save_to_disc),
      delay_between_bundles  = delay_between_bundles
    )
  }

  # Reset httr config to defaults
  httr::reset_config()

  return(result)
}
