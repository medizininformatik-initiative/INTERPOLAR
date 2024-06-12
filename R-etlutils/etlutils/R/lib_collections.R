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
sortListByName <- function(list) list[order(names(list))]

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
