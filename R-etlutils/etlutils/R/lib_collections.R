#'
#' Creates a named list of all parameters. The names are the variable names of the parameters.
#'
#' @param ... A vector from which a named list will be created.
#'
#' @examples
#' # Create a named list with specified names using the variables
#' a <- 1
#' b <- 2
#' c <- 3
#' named_list <- namedListByParam(a, b, c)
#' print(named_list)  # Output: $a [1] 1, $b [1] 2, $c [1] 3
#'
#' #Create a named list of 2 tables
#' library(data.table)
#'
#' table1 <- data.table(
#'   column1 = c(1:5),
#'   column2 = c('A', 'B', 'C', 'D', 'E')
#' )
#' table2 <- data.table(
#'   column1 = c(1:10),
#'   column2 = c('f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o')
#' )
#'
#' tableList <- namedListByParam(table1, table2)
#'
#' @export
namedListByParam <- function(...) {
  params <- list(...)
  names <- rep(NULL, length(params))
  for (i in seq_len(length(params))) {
    names[i] <- as.character(sys.call()[i + 1])
  }
  names(params) <- names
  params
}

#' Create a named list based on the values of a vector.
#'
#' This function takes a vector as input and returns a named list in which the names and the content of the list elements are identical.
#'
#' @param ... A vector from which a named list will be created.
#'
#' @return A named list where the names are identical to the values of the input vector.
#'
#' @examples
#' # Create a named list from a vector
#' values <- c("apple", "banana", "cherry", NA_character_)
#' named_list <- namedListByValue(values)
#' print(named_list)
#'
#' @export
namedListByValue <- function(...) {
  x <- as.list(c(...))
  names(x) <- as.character(x)
  x
}

#' Sort a named list alphabetically by its values.
#'
#' This function takes a list and sorts it alphabetically based on its values.
#'
#' @param list A list to be sorted.
#' @return A sorted list.
#'
#' @examples
#' # Create an unsorted named list
#' unsorted_list <- list(b = 3, a = 2, c = 1)
#'
#' # Sort the named list
#' sorted_list <- sortListByValue(unsorted_list)
#' print(sorted_list)
#'
#' @export
sortListByValue <- function(list) list[order(names(setNames(list, list)))]

#' Sort a named list alphabetically by its names.
#'
#' This function takes a named list and sorts it alphabetically based on its names.
#'
#' @param list A named list to be sorted.
#' @return A sorted named list.
#'
#' @examples
#' # Create an unsorted named list
#' unsorted_list <- list(b = 3, a = 2, c = 1)
#'
#' # Sort the named list
#' sorted_list <- sortListByName(unsorted_list)
#' print(sorted_list)
#'
#' @export
sortListByName <- function(list) {
  if (length(list) == 0) return(list)
  list[order(names(list))]
}

#' Flatten a nested list
#'
#' This function takes a nested list and flattens it into a single-level list and
#' removes parent names from the variable names.
#' It is particularly useful when you have flattened nested structures and want to
#' clean up the variable names by removing the prefixes introduced during flattening.
#'
#' @param x The input nested list.
#' @param prefix An optional prefix to be added to the names of the flattened list.
#'
#' @return A flattened list.
#'
#' @details
#' The function recursively iterates through the nested list, creating a flattened list
#' with modified variable names by adding the specified prefix. If no prefix is provided,
#' the original names are retained. The function uses a regular expression to remove parent names from variable names.
#' It looks for patterns at the beginning of each name and removes everything up to
#' the first uppercase letter, assuming that uppercase letters indicate the start of a new variable.
#' For example, "retrieve_fhir_server_SORT" becomes "SORT".
#' @export
flattenList <- function(x, prefix = NULL) {
  result <- list()
  for (name in names(x)) {
    new_prefix <- ifelse(is.null(prefix), name, paste0(prefix, "_", name))
    if (is.list(x[[name]])) {
      result <- c(result, flattenList(x[[name]], new_prefix))
    } else {
      result[[name]] <- x[[name]]
    }
  }
  result
}

#' Extract Indices from a Filter String
#'
#' This function parses a filter string containing comma-separated values and ranges
#' and returns a vector of unique, sorted indices. It handles both individual values
#' and ranges specified with a hyphen.
#'
#' @param filter_string A character string containing comma-separated values and/or ranges.
#'   Values can be individual numbers or ranges (e.g., "1, 2, 3, 5-10").
#' @param delimiter A character used to separate values in the string. The default is a comma (",").
#' @param range_delimiter A character used to specify ranges within the string. The default is a hyphen ("-").
#'
#' @return A numeric vector of sorted, unique indices derived from the input string.
#'   Returns `NA` if the input string is empty.
#'
#' @examples
#' getIndices("1, 2, 3, 5-10")
#' # Returns: 1 2 3 5 6 7 8 9 10
#'
#' getIndices("10-12, 14")
#' # Returns: 10 11 12 14
#'
#' @export
getIndices <- function(filter_string, delimiter = ",", range_delimiter = "-") {
  # Remove leading/trailing whitespace and all spaces within the string
  filter_string <- gsub(" ", "", trimws(filter_string))
  # Return NA if the input string is empty
  if (!nchar(filter_string)) return(NA)
  # Split the string by the main delimiter (default is a comma)
  split_values <- strsplit(filter_string, delimiter)[[1]]
  # Initialize an empty vector to store the results
  result <- c()
  # Iterate over each split value
  for (value in split_values) {
    # Check if the value contains a range
    if (grepl(range_delimiter, value)) {
      # If it's a range, split by the range delimiter and generate the sequence
      range_limits <- as.integer(strsplit(value, range_delimiter)[[1]])
      result <- c(result, seq(range_limits[1], range_limits[2]))
    } else {
      # If it's a single value, directly convert and append it
      result <- c(result, as.integer(value))
    }
  }
  # Return the sorted, unique result
  return(sort(unique(result)))
}

#' Print a list with each element's name and value, with optional prefix and suffix
#'
#' This function prints each element of a given list in the format "name = value".
#' It uses the helper function `getPrintString` to format each value. If a list
#' contains other lists, the nested lists are handled recursively. The user can
#' specify a prefix and suffix to wrap the output.
#'
#' @param list A named list or a list of lists to be printed.
#' @param prefix A string to print before the list output (optional).
#' @param suffix A string to print after the list output (optional).
#'
#' @return None. Prints the list elements to the console.
#'
#' @examples
#' my_list <- list(a = 1, b = list(x = 10, y = 20))
#' catList(my_list, prefix = "Start:\n", suffix = "End\n")
#'
#' @export
catList <- function(list, prefix = "", suffix = "") {
  cat(prefix)
  for (name in names(list)) {
    value <- list[[name]]
    if (is.list(value)) value <- getPrintString(value)
    cat(paste0(name, " = ", value, "\n"))
  }
  cat(suffix)
}
