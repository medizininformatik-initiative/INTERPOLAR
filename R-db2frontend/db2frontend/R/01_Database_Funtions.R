#' Create a Lock ID with Default Project Name
#'
#' This function generates a lock ID by combining a predefined project name with a variable number
#' of arguments for the lock ID message. The arguments are concatenated and combined with the
#' project name, separated by a colon (`:`). The project name is sourced from the global constant
#' `PROJECT_NAME`.
#'
#' @param ... A variable number of strings to be concatenated as the lock ID message.
#'
#' @return A character string representing the combined lock ID in the format
#'         `<PROJECT_NAME>:<lock_id_message>`.
#'
createLockID <- function(...) {
  etlutils::createLockID(PROJECT_NAME, ...)
}
