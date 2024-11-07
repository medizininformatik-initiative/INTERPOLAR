#' Extract Words from String
#'
#' Extracts individual words from a string that contains words separated by
#' any number of spaces and/or commas. Returns a vector of words.
#'
#' @param input_string A character string from which to extract words.
#' @return A character vector containing the extracted words.
#' @examples
#' input_string <- "Here are some words, separated, by, commas, and spaces"
#' extractWords(input_string)
#' @export
extractWords <- function(input_string) {
  # Replace commas with spaces for uniform separation
  unified_string <- gsub(",", " ", input_string)

  # Extract all words based on space as the separator
  words <- unlist(strsplit(unified_string, "\\s+"))

  # Remove empty elements, if any
  words <- words[words != ""]

  return(words)
}

#' Perform a case-insensitive pattern search using `grepl` with Perl patterns (perl = TRUE).
#'
#' @param pattern A pattern to search for.
#' @param x A list or table where the pattern should be searched.
#' @param whole_word If TRUE, the pattern will be treated as a whole word and matched accordingly.
#'                   It adds '^' to the beginning and '$' to the end of the pattern if they don't exist.
#' @param perl If TRUE, uses Perl-compatible regular expressions for pattern matching (default is TRUE).
#' @seealso grepl
#'
#' This function performs case-insensitive pattern searches using `grepl` with Perl patterns. If `whole_word` is set to TRUE,
#' the pattern is treated as a whole word, and '^' is added to the beginning and '$' to the end of the pattern if they are missing.
#' When `perl` is TRUE, Perl-compatible regular expressions are used for pattern matching. The pattern
#' you are looking for must be a string surrounded by whitespaces.
#'
#' @examples
#' pattern <- 'AAA|BBB'
#' greplic(pattern, 'I am a sentence with AAAA and CCC.', whole_word = TRUE) # FALSE
#' greplic(pattern, 'I am a sentence with AAA and CCC.', whole_word = TRUE) # TRUE
#'
#' @export
greplic <- function(pattern, x, whole_word = FALSE, perl = TRUE) {
  if (whole_word) {
    subPatterns <- unlist(strsplit(pattern, '\\|'))
    subPatterns <- lapply(subPatterns, function(subPattern) subPattern <- paste0('(?<!\\S)', subPattern, '(?!\\S)'))
    pattern <- paste0(subPatterns, collapse = '|')
  }
  grepl(pattern, x, ignore.case = TRUE, perl)
}

#' Remove the last character from a string if it is not alphanumeric.
#'
#' This function takes a character vector and removes the last character
#' from each string element if it is not alphanumeric (i.e., not a letter or a number).
#'
#' @param text A character vector containing strings.
#'
#' @return A character vector with the last character removed from each element if it is not alphanumeric.
#'
#' @examples
#' # Example data.table
#' library(data.table)
#' dt <- data.table(
#'   ID = 1:4,
#'   Text = c("abc123!", "hello-", "world9", "example")
#' )
#'
#' # Apply the function to the "Text" column
#' dt[, Text := lapply(Text, removeLastCharsIfNotAlphanumeric)]
#' print(dt)
#'
#' @export
removeLastCharsIfNotAlphanumeric <- function(text) {
  for (i in seq_len(length(text))) {
    while (nchar(text[i]) & !grepl("[A-Za-z0-9]$", text[i])) {
      text[i] <- substr(text[i], 1, nchar(text[i]) - 1)
    }
  }
  return(text)
}

#' Extract Everything After the Last Slash
#'
#' This function takes a vector of strings and returns a new vector where each element
#' is modified to include only the portion of the original string that appears
#' after the last slash.
#'
#' @param strings A character vector where each element is a string potentially
#'   containing slashes.
#'
#' @return A character vector of the same length as `strings`, where each element
#'   is the part of the original string after the last slash.
#'
#' @examples
#' strings <- c('Patient/PID_001', 'Encounter/EID_001', 'Condition/CID_001', 'aaa/bbb/ccc', 'aaa')
#' getAfterLastSlash(strings)
#'
#' @export
getAfterLastSlash <- function(strings) {
  return(sub(".*/", "", strings))
}

#' Extract Everything Before the Last Slash or Return Empty String if No Slash Present
#'
#' This function takes a vector of strings and returns a new vector. For strings containing slashes,
#' it includes only the portion of the string that appears before the last slash. For strings without
#' any slashes, it returns an empty string. The last slash itself is not included in the returned strings.
#'
#' @param strings A character vector where each element is a string that may or may not contain slashes.
#'
#' @return A character vector of the same length as `strings`, where each element is the part of the
#' original string up to (but not including) the last slash, or an empty string if no slash is present.
#'
#' @examples
#' absolute <- c('Patient/PID_001', 'Encounter/EID_001', 'Condition/CID_001', 'aaa/bbb/ccc', 'aaa')
#' getBeforeLastSlash(absolute)
#'
#' @export
getBeforeLastSlash <- function(strings) {
  sapply(strings, function(string) {
    if (grepl("/", string)) {
      sub("/[^/]*$", "", string)
    } else {
      ""
    }
  })
}

#' Extract text between single or double quotes in a string.
#'
#' This function takes a string and extracts the text between the first pair
#' of single or double quotes encountered. It uses regular expressions to find
#' the text enclosed within the quotes and returns it.
#'
#' @param x A character vector or string containing text with single or double quotes.
#' @return A character vector containing the text between the first pair of quotes.
#'
#' @examples
#' # Example usage
#' result_single <- getBetweenQuotes("This is a 'sample' string.")
#' result_double <- getBetweenQuotes('Another "example" string.')
#' print(result_single)  # Output: "sample"
#' print(result_double)  # Output: "example"
#'
#' @export
getBetweenQuotes <- function(x) {
  gsub(".*?['\"](.*?)['\"].*", "\\1", as.character(x))
}

#' Replace Patterns in a String with Specified Replacements
#'
#' This function replaces specified patterns in a given string with their corresponding replacements.
#' It takes a named list (`patternsAndReplacements`) where each name-value pair corresponds to a pattern
#' and its replacement. The function performs a case-insensitive replacement of these patterns within
#' the provided string.
#'
#' @param patternsAndReplacements A named list where names are patterns to be replaced and values are
#' the corresponding replacements.
#' @param string The string within which the patterns should be replaced.
#' @param ignore.case logical. Indicates whether the strings should be compared case sensitive. If TRUE
#' then all result strings are in lower case.
#' @param perl logical. Should Perl-compatible regexps be used?
#'
#' @return The modified string with all specified patterns replaced by their corresponding replacements.
#'
#' @examples
#' patternsAndReplacements <- list("hello" = "hi", "world" = "earth")
#' replacePatternsInString(patternsAndReplacements, "Hello World!")
#' # Returns "hi earth!"
#' @export
replacePatternsInString <- function(patternsAndReplacements, string, ignore.case = FALSE, perl = FALSE) {
  patterns <- names(patternsAndReplacements)
  replacements <- unlist(patternsAndReplacements)
  for (i in seq_along(patterns)) {
    pattern <- patterns[i]
    replacement <- replacements[i]
    if (ignore.case) {
      string <- gsub(tolower(pattern), replacement, tolower(string), ignore.case = TRUE, perl = perl)
    } else {
      string <- gsub(pattern, replacement, string, perl = perl)
    }
  }
  return(string)
}

#' Pluralize Suffix Based on Count
#'
#' This function returns an empty string for count 1 and 's' for any other count.
#'
#' @param counts Numeric vector of counts.
#'
#' @return
#' An empty string for count 1, 's' otherwise.
#' @export
getPluralSuffix <- function(counts) {
  ifelse(counts == 1, '', 's')
}

#' Count Trailing Spaces in a String
#'
#' This function calculates the number of consecutive spaces at the end of a string.
#' It iterates from the end of the string to the beginning and counts spaces until
#' a non-space character is encountered.
#'
#' @param text A character string for which to count trailing spaces.
#' @return An integer representing the number of trailing spaces.
#' @examples
#' countTrailingSpaces("Hello World   ")  # returns 3
#' countTrailingSpaces("NoSpacesHere")    # returns 0
#' @export
countTrailingSpaces <- function(text) {
  space_count <- 0
  for (i in nchar(text):1) {
    if (substr(text, i, i) == " ") {
      space_count <- space_count + 1
    } else {
      break
    }
  }
  return(space_count)
}

#' Find the Index of a Substring in a String
#'
#' This function searches for the first occurrence of a specified substring in a main string
#' and returns its 1-based position. It treats the substring as fixed text, not a regular expression,
#' which makes it suitable for substrings containing special characters.
#'
#' @param main_string The main string in which to search for the substring.
#' @param fixed_substring The substring to find in the main string. It is treated as fixed text,
#' so special characters are not interpreted as regular expression elements.
#' @return Integer value of the substring's position if found, otherwise returns -1.
#' @examples
#' indexOfSubstring("Hello world", "world")  # returns 7
#' indexOfSubstring("Sample text", "not found")  # returns -1
#' @export
indexOfSubstring <- function(main_string, fixed_substring) {
  match_position <- regexpr(fixed_substring, main_string, fixed = TRUE)
  if (match_position > 0) {
    return(match_position)
  }
  return(-1)
}

#' Get All Whitespaces Before a Word in a String
#'
#' This function counts and returns all consecutive whitespaces located immediately before
#' the first occurrence of a specified word in a string. The function uses `etlutils::indexOfSubstring`
#' to find the starting index of the word and then counts backwards to capture the whitespaces.
#'
#' @param string The string in which to search for the word.
#' @param word The word before which whitespaces are to be counted.
#' @return A string containing only the whitespaces found before the word in the main string.
#' @examples
#' getWhitespacesBeforeWord("Hello    world", "world")  # returns "    "
#' getWhitespacesBeforeWord("No space here", "space")   # returns ""
#' @export
getWhitespacesBeforeWord <- function(string, word) {
  wordIndex <- etlutils::indexOfSubstring(string, word)
  whitespaces <- ""
  index <- wordIndex - 1
  while (index > 0) {
    if (substr(string, index, index) == " ") {
      whitespaces <- paste0(whitespaces, " ")
      index <- index - 1
    } else {
      break
    }
  }
  return(whitespaces)
}

#' Count Characters from End to Last Newline in a String
#'
#' This function counts the number of characters from the end of a given string
#' up to the last newline character (`\n`). If no newline character is present,
#' it counts the characters from the end of the string to the beginning.
#'
#' @param text A character string to be processed.
#' @return An integer representing the number of characters from the end of the
#' string to the last newline character, or to the beginning of the string if
#' no newline character is present.
#' @examples
#' countCharsFromEndToLastNewline("Hello\nWorld\n!")  # returns 1
#' countCharsFromEndToLastNewline("HelloWorld")       # returns 10
#' @export
countCharsFromEndToLastNewline <- function(text) {
  newline_pos <- gregexpr("\n", text, fixed = TRUE)[[1]]
  if (newline_pos[1] == -1) {
    return(nchar(text))  # No newline, count from end to beginning
  } else {
    last_newline_pos <- max(newline_pos)
    return(nchar(text) - last_newline_pos)
  }
}

#' Get Indentation of a Word in a Text
#'
#' This function calculates the indentation level of a specified word in a given text.
#' It measures the number of characters from the last newline character (`\n`) up to the
#' specified word. If there is no newline character before the word, it measures from the
#' beginning of the text to the word. The function then returns a string consisting of spaces
#' equal to the indentation level.
#'
#' @param text A character string to be processed.
#' @param word A character string representing the word whose indentation level is to be measured.
#' @return A character string consisting of spaces equal to the number of characters from the last
#' newline character to the specified word, or from the beginning of the text if no newline character is present.
#' @examples
#' getWordIndentation("Hello\n  world", "world")  # returns "  "
#' getWordIndentation("No newline here", "here")  # returns "              "
#' @export
getWordIndentation <- function(text, word) {
  text_before_word <- substr(text, 1, regexpr(word, text, fixed = TRUE) - 1)
  indentation <- etlutils::countCharsFromEndToLastNewline(text_before_word)
  strrep(" ", indentation)
}

#' Get Print String of an Object
#'
#' This function captures the output of the `print` function for a given object and returns it as a single string.
#'
#' @param object The object to be printed.
#'
#' @return A string containing the printed representation of the object.
#'
#' @examples
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' print_string <- getPrintString(df)
#' cat(print_string)
#'
#' @export
getPrintString <- function(object) {
  paste(capture.output(print(object)), collapse = "\n")
}

#' Reverse a string
#'
#' This function takes an input string and returns it reversed.
#'
#' @param input_string A string to be reversed.
#'
#' @return A reversed string.
#' @examples
#' reverseString("abc")  # Returns "cba"
#' @export
reverseString <- function(input_string) {
  return(paste0(rev(strsplit(input_string, NULL)[[1]]), collapse = ""))
}

#' Convert a String to Prefixed Format
#'
#' This function takes a string and converts it to a prefixed format
#' if it is not already in that format.
#'
#' @param str A string to be converted.
#' @param prefix A string to be used as the prefix for the format. It may or may not
#' contain a trailing separator.
#' @param separator A string to be used as the separator between the prefix and the string.
#' Default is "/". If set to NA or an empty string, no separator will be added.
#'
#' @return A string converted to the prefixed format.
#'
#' @examples
#' convertStringToPrefixedFormat("001", prefix = "Patient", separator = "/")
#' # Returns: "Patient/001"
#'
#' @export
convertStringToPrefixedFormat <- function(str, prefix, separator = "/") {
  # Ensure separator is not NA or empty
  if (!is.na(separator) && separator != "") {
    # Ensure the prefix ends with the separator
    if (substr(prefix, nchar(prefix), nchar(prefix)) != separator) {
      prefix <- paste0(prefix, separator)
    }
  }

  # Convert string to prefixed format if it is not already in that format
  if (!grepl(paste0("^", prefix), str)) {
    str <- paste0(prefix, str)
  }
  return(str)
}

#' Escape special characters in a string for grep patterns
#'
#' This function escapes only special characters in a given string by prefixing them with a
#' backslash. Alphanumeric characters (letters and numbers) are not escaped.
#'
#' @param string A string to be escaped.
#'
#' @return A string with special characters escaped by a backslash.
#'
#' @examples
#' escaped <- getEscaped("example@#")
#' print(escaped) # Output: "example\@\#"
#'
#' @export
getEscaped <- function(string) {
  if (nchar(string) == 0) {
    return(string)
  }
  special_chars <- c(".", "\\", "|", "(", ")", "[", "]", "{", "}", "^", "$", "*", "+", "?", "-")
  chars <- strsplit(string, "")[[1]]
  escaped_chars <- sapply(chars, function(char) {
    if (char %in% special_chars) {
      return(paste0("\\", char))
    } else {
      return(char)
    }
  })
  escaped_string <- paste0(escaped_chars, collapse = "")
  return(escaped_string)
}

#' Escape all characters in a string
#'
#' This function escapes every character in the input string by prepending a backslash (`\`).
#' If the string is empty, it returns the empty string. If the string contains only one character,
#' it simply prepends a backslash to that character.
#'
#' @param string A character string to be escaped.
#'
#' @return The input string where every character is escaped with a backslash.
#'
#' @examples
#' getEscapedAll("abc") # returns "\\a\\b\\c"
#' getEscapedAll("[.]") # returns "\\[\\.\\]"
#' getEscapedAll("")     # returns ""
#' getEscapedAll("a")    # returns "\\a"
#'
#' @export
getEscapedAll <- function(string) {
  if (nchar(string) == 0) {
    return(string)  # Return empty string if input is empty
  } else if (nchar(string) == 1) {
    return(paste0("\\", string))  # Escape single character
  } else {
    chars <- strsplit(string, "")[[1]]  # Split string into individual characters
    escaped_string <- paste0("\\", chars, collapse = "")  # Escape each character
    return(escaped_string)  # Return the fully escaped string
  }
}
