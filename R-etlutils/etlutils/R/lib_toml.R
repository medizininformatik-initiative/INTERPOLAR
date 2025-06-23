#' Serialize atomic vector into a TOML array string
#'
#' Converts a given atomic vector into a TOML-compatible array string. If no key is provided,
#' the name of the vector as passed to the function is used as the TOML key.
#'
#' @param vec An atomic vector (character, numeric, integer, or logical) to be serialized.
#' @param key Optional. A character string to be used as the TOML key. If NULL, the name of
#'   the vector as passed to the function is used.
#'
#' @return A character string representing the TOML array (e.g., `key = [1, 2, 3]`).
#'
#' @examples
#' ids <- c("enc_id_1", "enc_id_2", "enc_id_3")
#' tomlFromVector(ids)
#'
#' tomlFromVector(c(TRUE, FALSE, TRUE), key = "flags")
#'
#' tomlFromVector(1:3)
#'
#' @export
tomlFromVector <- function(vec, key = NULL) {
  if (isSimpleNAorNULL(key)) {
    key <- deparse(substitute(vec))
  }

  format_value <- function(v) {
    if (is.character(v)) {
      return(paste0('"', v, '"'))
    } else if (is.logical(v)) {
      return(tolower(as.character(v)))
    } else {
      return(as.character(v))
    }
  }

  elements <- vapply(vec, format_value, FUN.VALUE = character(1))
  line <- paste0(key, " = [", paste(elements, collapse = ", "), "]")
  return(line)
}

#' Serialize a data.table into a TOML array-of-tables string
#'
#' Converts a data.table into a TOML string using array-of-tables syntax (\code{[[key]]}).
#' If no key is provided, the name of the data.table variable is used as the section key.
#' Additionally, a header of the form \code{[table.<key>]} is inserted before the data block.
#'
#' @param dt A data.table to be serialized into TOML format.
#' @param key Optional. A character string used as the TOML section key. If NULL, the variable
#'   name passed as \code{dt} is used.
#'
#' @return A character string representing the TOML serialization of the data.table.
#'
#' @examples
#' dt <- data.table::data.table(name = c("A", "B"), value = c(1, 2))
#' toml_string <- tomlFromDT(dt)
#' cat(toml_string)
#'
#' @export
tomlFromDT <- function(dt, key = NULL) {
  # Determine key from variable name if not provided
  if (isSimpleNAorNULL(key)) {
    key <- deparse(substitute(dt))
  }

  lines <- character()

  # Optional outer key for grouping (e.g. [table.dt])
  lines <- c(lines, paste0("[table.", key, "]"), "")

  # Array-of-tables under the key
  for (i in seq_len(nrow(dt))) {
    lines <- c(lines, paste0("[[", key, "]]"))
    for (j in names(dt)) {
      val <- dt[[j]][i]
      if (is.character(val)) val <- paste0('"', val, '"')
      lines <- c(lines, paste0(j, " = ", val))
    }
  }

  paste(lines, collapse = "\n")
}

#' Extract a data.table from parsed TOML content
#'
#' Converts a TOML array-of-tables section (as parsed by \code{RcppTOML::parseTOML}) into
#' a data.table. This assumes the section specified by \code{key} is a list of named lists.
#'
#' @param parsed_toml A named list resulting from \code{RcppTOML::parseTOML()}.
#' @param key A character string specifying the TOML key under which the array-of-tables is stored.
#'
#' @return A data.table reconstructed from the TOML content.
#'
#' @examples
#' toml_txt <- '
#' [[entries]]
#' name = "A"
#' value = 1
#'
#' [[entries]]
#' name = "B"
#' value = 2
#' '
#' parsed <- parseTOMLString(toml_txt)
#' dt <- tomlToDT(parsed, "entries")
#' print(dt)
#'
#' @export
tomlToDT <- function(parsed_toml, key) {
  data.table::rbindlist(parsed[[key]], fill = TRUE)
}

#' Append a new section header to an existing TOML string
#'
#' Adds a TOML section header (e.g., \code{[section_name]}) to the end of a given TOML string.
#' Ensures that the section header starts on a new line, regardless of whether the input string
#' ends with a newline.
#'
#' @param toml_string A character string containing the current TOML content.
#' @param section_string A character string specifying the name of the section to append.
#'
#' @return A character string with the new section header appended at the end.
#'
#' @examples
#' base_toml <- vectorToTOML(c("a", "b"), key = "values")
#' full_toml <- appendSection(base_toml, "metadata")
#' cat(full_toml)
#'
#' @export
tomlAppendSection <- function(toml_string, section_string) {
  # Ensure the TOML string ends with a newline
  if (nchar(toml_string) && !grepl("\\n$", toml_string)) {
    toml_string <- paste0(toml_string, "\n")
  }

  # Add the new section
  paste0(toml_string, "\n[", section_string, "]\n\n")
}

#' Append a vector as a TOML array to an existing TOML string
#'
#' Appends a vector to a TOML string using array syntax (\code{key = [val1, val2, ...]}).
#' Optionally, a comment can be added before the array. If no key is provided, the variable
#' name of the vector is used as the key.
#'
#' @param toml_string A character string containing existing TOML content.
#' @param vec An atomic vector to be appended as a TOML array.
#' @param key Optional. A character string to use as the key. If NULL, the name of the vector
#'   as passed to the function is used.
#' @param comment Optional. A character string to insert as a TOML comment before the array.
#'
#' @return A character string representing the original TOML content with the vector array
#'   and optional comment appended.
#'
#' @examples
#' toml <- "title = \"example\"\n"
#' ids <- c("a", "b", "c")
#' toml <- tomlAppendVector(toml, ids, comment = "IDs used for processing")
#' cat(toml)
#'
#' @export
tomlAppendVector <- function(toml_string, vec, key = NULL, comment = NULL) {
  # Ensure the TOML string ends with a newline
  if (nchar(toml_string) && !grepl("\\n$", toml_string)) {
    toml_string <- paste0(toml_string, "\n")
  }

  if (isSimpleNAorNULL(key)) {
    key <- deparse(substitute(vec))
  }

  # Append comment if provided
  if (!isSimpleNAorNULL(comment)) {
    if (!grepl("^#", comment)) {
      comment <- paste0("# ", comment)
    }
    if (!grepl("\\n$", comment)) {
      comment <- paste0(comment, "\n")
    }
    toml_string <- paste0(toml_string, comment)
  }

  # Append vector as TOML array
  paste0(toml_string, tomlFromVector(vec, key))
}

#' Parse a TOML string into a named list
#'
#' Parses a TOML-formatted character string into a named list structure using RcppTOML.
#' This allows reading TOML content directly from a string rather than a file.
#'
#' @param toml_string A character string containing valid TOML content.
#'
#' @return A named list representing the parsed TOML structure.
#'
#' @examples
#' toml_txt <- 'values = ["a", "b", "c"]'
#' parsed <- parseTOMLString(toml_txt)
#' parsed$values
#'
#' @export
tomlParseString <- function(toml_string) {
  RcppTOML::parseTOML(toml_string, fromFile = FALSE)
}
