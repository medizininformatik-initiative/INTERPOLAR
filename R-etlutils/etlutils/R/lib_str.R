#' Extract Words from String
#'
#' Extracts individual words from a string that contains words separated by
#' any number of spaces and/or commas. Returns a vector of words.
#'
#' @param input_string A character string from which to extract words.
#' @return A character vector containing the extracted words.
#' @examples
#' input_string <- "Here are some words, separated, by, commas, and spaces"
#' extract_words(input_string)
#' @export
extract_words <- function(input_string) {
  # Replace commas with spaces for uniform separation
  unified_string <- gsub(",", " ", input_string)

  # Extract all words based on space as the separator
  words <- unlist(strsplit(unified_string, "\\s+"))

  # Remove empty elements, if any
  words <- words[words != ""]

  return(words)
}
