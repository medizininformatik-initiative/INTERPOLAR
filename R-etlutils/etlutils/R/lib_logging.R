#' Start Logging to a File
#'
#' This function initializes logging by creating or opening a log file for writing.
#'
#' @param prefix A prefix to be used in the log file name.
#' @return NULL
#'
#' @details
#' The function creates or opens a log file with a name generated from the provided prefix and the current timestamp.
#' It redirects the console output and messages to the log file, allowing for systematic logging of activities.
#' The log file is stored in the log directory, and each log entry is appended to the existing file.
#'
#' @export
start_logging <- function(prefix) {
  log_file <- file(fhircrackr::paste_paths(polar_path_to_log_directory(), paste0(prefix, "-log.txt")), open = "wt")
  sink(log_file, append = TRUE, split = TRUE)
  sink(log_file, append = TRUE, type = "message")
  #sink(log_file, append = TRUE, type = c("output", "message"))
}

#' End Logging
#'
#' This function finalizes the logging process by closing the log file.
#'
#' @return NULL
#'
#' @details
#' The function stops the redirection of console output and messages to the log file initiated by \code{start_logging}.
#' It closes the log file, ensuring that no further entries are appended to it.
#'
#' @export
end_logging <- function() {
  sink(type = "message")
  sink()
}
