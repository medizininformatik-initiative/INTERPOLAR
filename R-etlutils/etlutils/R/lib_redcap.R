# Environment for saving everything but the connections
.lib_redcap_env <- new.env()
.lib_redcap_env[["ESCAPE_SIGNS"]] <- c("PLUS" = "+",
                                       "POUND" = "#",
                                       "AMPER" = "&",
                                       "APOS" = "'",
                                       "LINE" = "\n",
                                       "QUOTE" = "\"")

#' Encode special characters for REDCap import using ESCAPE_SIGNS vector
#'
#' This function replaces problematic special characters in a string with placeholders
#' to ensure error-free import into REDCap.
#'
#' @param string A character vector or single string to be encoded.
#' @return A character vector with special characters replaced by placeholders.
#'
#' @export
redcapEscape <- function(string) {
  signs <- .lib_redcap_env[["ESCAPE_SIGNS"]]
  # Iterate over signs and replace each character by placeholder %NAME%
  for (name in names(signs)) {
    pattern <- signs[[name]]
    replacement <- paste0("%", name, "%")
    string <- gsub(pattern, replacement, string, fixed = TRUE)
  }
  return(string)
}

#' Decode special characters from REDCap import format using ESCAPE_SIGNS vector
#'
#' This function converts placeholders used for REDCap import back to their original special characters.
#'
#' @param string A character vector or single string containing placeholders.
#' @return A character vector with original special characters restored.
#'
#' @export
redcapUnescape <- function(string) {
  signs <- .lib_redcap_env[["ESCAPE_SIGNS"]]
  # Iterate over signs and replace each placeholder %NAME% by original character
  for (name in names(signs)) {
    pattern <- paste0("%", name, "%")
    replacement <- signs[[name]]
    string <- gsub(pattern, replacement, string, fixed = TRUE)
  }
  return(string)
}
