#' Parse structured config definitions
#'
#' This function parses structured config definitions represented as a nested list
#' of character vectors containing key-value lines. It validates the formal line
#' structure and returns a flat list of parsed records that can be used by
#' package-specific validators.
#'
#' @param definitions A list of named lists containing character vectors with
#'   config lines.
#' @param allowed_key_pattern A regular expression describing all allowed keys.
#'   The pattern must be suitable for direct use inside a grouped regex.
#' @param allow_plus Logical. If `TRUE`, multiple subconditions connected by `+`
#'   are allowed within one line. If `FALSE`, `+` is rejected.
#'
#' @return A list of parsed records. Each record contains `definition_name`,
#'   `entry_name`, `line_index`, `part_index`, `part_count_in_line`,
#'   `key`, `value`, and `original_line`.
#'
#' @export
parseStructuredConfigDefinitions <- function(
    definitions,
    allowed_key_pattern,
    allow_plus = FALSE
) {

  getNameOrIndex <- function(x, index) {
    x_names <- names(x)
    if (is.null(x_names) || length(x_names) < index || is.na(x_names[index]) || x_names[index] == "") {
      return(paste0("[[", index, "]]"))
    }
    x_names[index]
  }

  splitOutsideSingleQuotes <- function(x, separator = "+") {
    chars <- strsplit(x, "", fixed = TRUE)[[1]]
    parts <- character()
    current_part <- character()
    in_quotes <- FALSE

    for (char in chars) {
      if (char == "'") {
        in_quotes <- !in_quotes
        current_part <- c(current_part, char)
      } else if (!in_quotes && char == separator) {
        parts <- c(parts, paste0(current_part, collapse = ""))
        current_part <- character()
      } else {
        current_part <- c(current_part, char)
      }
    }

    if (in_quotes) {
      stop("Unmatched single quote in line: ", x)
    }

    c(parts, paste0(current_part, collapse = ""))
  }

  part_pattern <- paste0("^\\s*(", allowed_key_pattern, ")\\s*=\\s*'([^']*)'\\s*$")

  parsed_records <- list()
  record_index <- 1L

  for (definition_index in seq_along(definitions)) {
    definition <- definitions[[definition_index]]
    definition_name <- getNameOrIndex(definitions, definition_index)

    for (entry_index in seq_along(definition)) {
      entry <- definition[[entry_index]]
      entry_name <- getNameOrIndex(definition, entry_index)

      for (line_index in seq_along(entry)) {
        original_line <- entry[[line_index]]

        if (allow_plus) {
          parts <- splitOutsideSingleQuotes(original_line, separator = "+")

          if (any(trimws(parts) == "")) {
            stop("Invalid empty subcondition in ", definition_name, " / ", entry_name, " / line ", line_index, ": ", original_line)
          }
        } else {
          parts <- splitOutsideSingleQuotes(original_line, separator = "+")

          if (length(parts) > 1L) {
            stop("Character '+' is not allowed in ", definition_name, " / ", entry_name, " / line ", line_index, ": ", original_line)
          }
        }

        invalid_parts <- !grepl(part_pattern, parts, perl = TRUE)
        if (any(invalid_parts)) {
          stop("Invalid subcondition in ", definition_name, " / ", entry_name, " / line ", line_index, ": ", parts[which(invalid_parts)[1]])
        }

        for (part_index in seq_along(parts)) {
          match <- regmatches(
            parts[part_index],
            regexec(part_pattern, parts[part_index], perl = TRUE)
          )[[1]]

          parsed_records[[record_index]] <- list(
            definition_name = definition_name,
            entry_name = entry_name,
            line_index = line_index,
            part_index = part_index,
            part_count_in_line = length(parts),
            key = match[2],
            value = match[3],
            original_line = original_line
          )

          record_index <- record_index + 1L
        }
      }
    }
  }

  parsed_records
}
