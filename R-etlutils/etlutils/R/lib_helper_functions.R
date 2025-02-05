#' Check if a value is a simple NA.
#'
#' This function checks whether a value is a simple NA by ensuring that it is atomic (simple),
#' has a length of 1, and the value is NA.
#'
#' @param x The value to be checked.
#' @return TRUE if the value is a simple NA, otherwise FALSE.
#' @examples
#' x <- NA
#' isSimpleNA(x) # TRUE
#'
#' y <- c(1, NA, 3)
#' isSimpleNA(y) # FALSE
#'
#' @export
isSimpleNA <- function(x) {
  is.atomic(x) && length(x) == 1 && is.na(x)
}

#' Check if a value is a simple true value (TRUE) or not zero (0).
#'
#' This function evaluates whether the input value is an atomic element, has a length of 1,
#' and is either a logical true value (TRUE) or a non-zero numeric value. If these conditions are met,
#' the function returns TRUE; otherwise, it returns FALSE.
#'
#' @param x The value to be checked.
#'
#' @return TRUE if the input is a simple true value or a non-zero numeric value, FALSE otherwise.
#'
#' @examples
#' # Example 1: Check if TRUE is a simple true value (TRUE)
#' isSimpleTrueOrNot0(TRUE)
#'
#' # Example 2: Check if 0 is not a simple true value (FALSE)
#' isSimpleTrueOrNot0(0)
#'
#' # Example 3: Check if 1 is a simple true value (TRUE)
#' isSimpleTrueOrNot0(1)
#'
#' # Example 4: Check if a boolean vector is a simple true value (FALSE)
#' isSimpleTrueOrNot0(c(TRUE, TRUE))
#'
#' @export
isSimpleTrueOrNot0 <- function(x) {
  is.atomic(x) && length(x) == 1 && !is.na(x) && !is.character(x) && x
}

#' Check if a value is a simple false value (FALSE) or zero (0).
#'
#' This function evaluates whether the input value is an atomic element, has a length of 1,
#' and is either a logical false value (FALSE) or zero (0). If these conditions are met,
#' the function returns TRUE; otherwise, it returns FALSE.
#'
#' @param x The value to be checked.
#'
#' @return TRUE if the input is a simple false value or zero, FALSE otherwise.
#'
#' @examples
#' # Example 1: Check if FALSE is a simple false value (TRUE)
#' isSimpleFalseOr0(FALSE)
#'
#' # Example 2: Check if 0 is a simple false value  (TRUE)
#' isSimpleFalseOr0(0)
#'
#' # Example 3: Check if 1 is not a simple false value (FALSE)
#' isSimpleFalseOr0(1)
#'
#' # Example 4: Check if a boolean vector is a simple true value (FALSE)
#' isSimpleTrueOrNot0(c(FALSE, FALSE))
#'
#' @export
isSimpleFalseOr0 <- function(x) {
  is.atomic(x) && length(x) == 1 && !is.na(x) && !is.character(x) && !x
}

#' Check if the Input is a Non-Empty, Simple Character String
#'
#' This function checks if the input `s` is a non-empty, simple character string. It verifies that the input is atomic, not `NA`,
#' of character type, and has a length greater than zero. This is useful for validating input parameters that are expected to be
#' simple character strings.
#'
#' @param s Input that will be checked if it is a non-empty, simple character string.
#' @return A logical value: `TRUE` if `s` is a non-empty, simple character string, otherwise `FALSE`.
#' @examples
#' isSimpleNotEmptyString("hello") # Returns TRUE
#' isSimpleNotEmptyString("")      # Returns FALSE
#' isSimpleNotEmptyString(NA)      # Returns FALSE
#' isSimpleNotEmptyString(123)     # Returns FALSE
#' @export
isSimpleNotEmptyString <- function(s) {
  is.atomic(s) && length(s) == 1 && !is.na(s) && is.character(s) && nchar(s) > 0
}

#'
#' Tests the passed object for being an error.
#'
#' This function checks whether the input object is an 'try-error'. If the object
#' is an error, the function returns TRUE; otherwise, it returns FALSE.
#'
#' @param obj The object to be tested for being an error.
#'
#' @return TRUE if the object is an 'try-error', FALSE otherwise.
#'
#' @examples
#' # Example 1: Check if an error is an error
#' result <- try(log("a"))
#' isError(result)
#'
#' # Example 2: Check if a numeric value is not an error
#' numeric_result <- 42
#' isError(numeric_result)
#'
#' @export
isError <- function(obj) !isSimpleNA(obj) && sum(class(obj) %in% "try-error") > 0

#'
#' Tests the passed object for being an atomic NA or an error.
#'
#' This function checks whether the input object is an 'try-error' or a simple NA.
#' If the object is an error or NA, the function returns TRUE; otherwise, it returns
#' FALSE.
#'
#' @param obj The object to be tested for being an error or NA.
#'
#' @return TRUE if the object is an 'try-error' or NA, FALSE otherwise.
#'
#' @examples
#' # Example 1: Check if an error is an error or NA
#' result <- try(log("a"))
#' isError(result)
#'
#' # Example 2: Check if a numeric value is not an error or NA
#' numeric_result <- 42
#' isError(numeric_result)
#'
#' # Example 3: Check if a NA value is not an error or NA
#' numeric_result <- NA
#' isError(numeric_result)
#'
#' @export
isSimpleNaOrError <- function(obj) isSimpleNA(obj) || sum(class(obj) %in% "try-error") > 0

#'
#' Tests the passed object for being not an error.
#'
#' This function checks whether the input object is not an 'try-error'. If the object
#' is not an error, the function returns FALSE; otherwise, it returns TRUE.
#'
#' @param obj The object to be tested for not being an error.
#'
#' @return FALSE if the object is an 'try-error', TRUE otherwise.
#'
#' @examples
#' # Example 1: Check if an error is not an error
#' result <- try(log("a"))
#' isOK(result)
#'
#' # Example 2: Check if a numeric value is an error
#' numeric_result <- 42
#' isOK(numeric_result)
#'
#' @export
isOK <- function(obj) !isError(obj)

#'
#' Check if debugging mode is enabled.
#'
#' This function checks if debugging mode is enabled by verifying the existence of the 'DEBUG' variable and if it is
#' set to TRUE. his can be used in code to enable code sections only if a global variable DEGUG is set to TRUE.
#'
#' @return TRUE if debugging mode is enabled, otherwise FALSE.
#'
isDebug <- function() exists('DEBUG') && DEBUG

#' Check for Errors
#'
#' This function checks if an error has occurred and executes the corresponding expression.
#'
#' @param potencial_error Any Type. In case of an error occurred it must contain try-error as class.
#' @param expr_ok An expression. This runs in case of no error.
#' @param expr_err An expression. This runs in case of an error.
#'
#' @return The result of either `expr_ok` or `expr_err` depending on the presence of an error.
#' @export
checkError <- function(potencial_error, expr_ok = {catOkMessage()}, expr_err = {catErrorMessage()}) {
  if (isError(potencial_error)) expr_err else expr_ok
}

#' Convert Numbers to Verbose Number Representations
#'
#' This function converts numbers to verbose number representations, such as "1st," "2nd," "3rd," or "th."
#'
#' @param n Numeric vector to be converted.
#'
#' @return A character vector representing the verbose number representation.
#' @export
convertVerboseNumbers <- function(n) {
  n[n < 1 | 3 < n] <- paste0(n[n < 1 | 3 < n], 'th')
  n[n == 1] <- '1st'
  n[n == 2] <- '2nd'
  n[n == 3] <- '3rd'
  n
}

#' Fix integer format in specified columns
#'
#' This function fixes the integer format in specified columns of a data table.
#'
#' @param dt A data table.
#' @param columns A character vector specifying the columns to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{columns} specifying the columns to be fixed. It converts the values in
#' the specified columns to integers using \code{as.integer}.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the integer format in the specified columns
#'
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   id = c("AAA", "2", "3", "4"))
#' convertIntegerFormat(dt, "id")
#' print(dt)
#'
#' @export
convertIntegerFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := as.integer((get(column)))]
  }
}

#' Fix decimal format in specified columns
#'
#' This function fixes the decimal format in specified columns of a data table.
#'
#' @param dt A data table.
#' @param columns A character vector specifying the columns to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{columns} specifying the columns to be fixed. It converts the values in
#' the specified columns to numeric using \code{as.numeric}.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the decimal format in the specified columns
#'
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   value = c("AAA", "20.7", "30.1", "40.0"))
#' convertIntegerFormat(dt, "value")
#' print(dt)
#'
#' @export
convertDecimalFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := as.numeric(get(column))]
  }
}

#' Fix boolean format in specified columns
#'
#' This function fixes the boolean format in specified columns of a data table.
#'
#' @param dt A data table.
#' @param columns A character vector specifying the columns to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{columns} specifying the columns to be fixed. It converts the values in
#' the specified columns to numeric, treating TRUE as 1 and FALSE as 0.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the boolean format in the specified columns
#'
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   status = c("0", "1", "FALSE", "TRUE"))
#' convertIntegerFormat(dt, "status")
#' print(dt)
#'
#' @export
convertBooleanFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := as.logical(get(column))]
  }
}

#' #'
#' #' Prints a variable or a list of variables via cat() in the style
#' #'      var1: value1
#' #' variable2: value2
#' #'     vari3: value3
#' #' @param ... list of variables which should be printed via cat
#' #'
#' catv <- function(...) {
#'   list <- list(...)
#'   var_names <- sys.call()[-1]
#'   catNamedList(list, var_names)
#' }
#'
#' #'
#' #' @param list the list to be printed
#' #'
#' catByVerboseist <- function(list) {
#'   if (VL_50_TABLES <= VERBOSE) {
#'     list_name <- paste0(sys.call()[2], '$')
#'     var_names <- paste0(list_name, names(list))
#'     catNamedList(list, var_names)
#'   }
#' }
#'
#' catNamedList <- function(list, var_names) {
#'   # find the lenght with the largest var name
#'   min_length <- max(nchar(var_names)) + 1 # add the length of ': '
#'   for (i in 1:length(list)) {
#'     var_name <- paste0(var_names[i], ':')
#'     var_name <- stringr::str_pad(var_name, min_length, 'left', ' ')
#'     cat(var_name, paste0(unlist(list[i])), '\n')
#'   }
#' }
#'
#' #' This function checks if the given 'code' matches any of the patterns in the 'patternList'.
#' #'
#' #' @param patternList A character vector containing the patterns to match against the 'code'.
#' #' @param code A character string to match against the patterns in 'patternList'.
#' #'
#' #' @return A logical value indicating if the 'code' matches any of the patterns in 'patternList'.
#' contains <- function(patternList, code) grepl(paste(patternList, collapse = "|"), code)
#'
#' #' This function checks if the given 'code' matches any of the patterns in the 'patternList'
#' #' and returns the result as a numeric value (1 if a match was found, 0 otherwise).
#' #'
#' #' @param patternList A character vector containing the patterns to match against the 'code'.
#' #' @param code A character string to match against the patterns in 'patternList'.
#' #'
#' #' @return A numeric value (1 if a match was found, 0 otherwise).
#' contains01 <- function(patternList, code) as.numeric(contains(patternList, code))
#'
#' #' This function checks if the given 'code' matches any of the patterns in the 'patternList'
#' #' and returns the result as a numeric value (1 if a match was found, 0 otherwise).
#' #'
#' #' @param patternList A list of character vectors, each containing the patterns to match against the 'code'.
#' #' @param code A character string to match against the patterns in 'patternList'.
#' #'
#' #' @return A numeric value (1 if a match was found in any of the pattern lists, 0 otherwise).
#' contains_any01 <- function(patternList, code) as.numeric(any(contains(patternList, code)))
#'
#' #' This function checks if the given 'resourceName' is in the list of required resources
#' #' (REQUIRED_RESOURCES_ALL).
#' #'
#' #' @param resourceName A character string representing the name of a resource.
#' #'
#' #' @return A logical value indicating if the given 'resourceName' is in the list of required resources.
#' must_merge <- function(resourceName) contains(REQUIRED_RESOURCES_ALL, resourceName)
#'
#' #' This function checks if the given 'resourceName' should be retrieved or not. This is
#' #' the case if the global snapshot retrieval shut be executes (RUN_GLOBAL_RETRIEVAL = TRUE)
#' #' or the resource is needed directly for the current workpackage.
#' #'
#' #' @param resourceName A character string representing the name of a resource.
#' #'
#' #' @return A logical value indicating if the given 'resourceName' should be retrieved.
#' must_retrieve <- function(resourceName) RUN_GLOBAL_RETRIEVAL || must_merge(resourceName)
#'
#' #'
#' #' Prints a contact list via cat.
#' #' @param contacts a list of key value pairs with a name as key and an email as value
#' #'
#' catContacts <- function(contacts) {
#'   contacts_name <- as.character(sys.call()[2]) # get parameter name
#'   catByVerbose(paste0(contacts_name, ':\n', paste0('  ', names(contacts), ': ', sapply(contacts, ansi, underline = TRUE), collapse = '\n')))
#' }
#'
#' #'
#' #' Check for duplicates in a given vector, list, or list of lists and log the results.
#' #'
#' #' This function checks whether the provided input, which can be a vector, list, or list of lists,
#' #' contains duplicate elements. The information about duplicates is logged using the 'cat()' function
#' #' and printed in a specific style.
#' #'
#' #' The function supports two main types of input:
#' #' 1. A vector or a simple list.
#' #' 2. A list of lists.
#' #'
#' #' If the input is a list of lists, the function checks for duplicates within each sublist and
#' #' logs the results accordingly.
#' #'
#' #' Example usage:
#' #'
#' #' # Check duplicates in a vector
#' #' checkDuplicates(c(1, 2, 2, 3, 4), "Duplicate numbers:")
#' #'
#' #' # Check duplicates in a list
#' #' checkDuplicates(list("A", "B", "C", "B", "D"), "Duplicate letters:")
#' #'
#' #' # Check duplicates in a list of lists
#' #' codeList <- list(
#' #'   ALT = c('76625-3', '1742-6', '1743-4', '1744-2', '48134-1', '77144-4', '76625-3'),
#' #'   AST = c('1920-8', '88112-8', '30239-8', '48136-6', '76625-3', '77144-4', '76625-3')
#' #' )
#' #' checkDuplicates(codeList, "Duplicate LOINC codes in sublists:")
#' #'
#' #' @param vectorOrList The input vector, list, or list of lists to check for duplicates.
#' #' @param titleMessage (Optional) A custom message to include as a title when logging duplicates.
#' #'
#' #' @return This function does not return a value but logs the duplicate information.
#' #'
#' checkDuplicates <- function(vectorOrList, titleMessage = NA) {
#'   titlePrinted <- FALSE             # prevent multiple title printing
#'   isList <- is.list(vectorOrList)   # TRUE if codeList is a list or list of lists
#'   listName <- paste0(sys.call()[2]) # get the parameter name
#'   # check if the list is a list of lists (then we have to check the sublists for
#'   # duplicates
#'   if (isList) {
#'     # if the unlisted list has more elements than the simple list, then it is a list
#'     # of lists. If the size is the same, then we take the unlisted list (= vector)
#'     # to distinguish it from a list of lists.
#'     unlisted <- unlist(vectorOrList)
#'     if (length(unlisted) == length(vectorOrList)) {
#'       vectorOrList <- unlisted # change the simple list to vector
#'     }
#'   }
#'   isList <- is.list(vectorOrList) # vector (= FALSE) or list of lists (= TRUE)
#'   if (!isList) {
#'     vectorOrList <- list(vectorOrList)
#'     names(vectorOrList) <- c(listName)
#'   }
#'   varNames <- names(vectorOrList)
#'   for (i in 1:length(vectorOrList)) {
#'     subList <- vectorOrList[i]
#'     multiples <- table(subList)
#'     multiples <- multiples[multiples > 1]
#'     if (length(multiples)) {
#'       if (!titlePrinted) {
#'         if (is.na(titleMessage)) {
#'           titleMessage <- paste0('Multiple Code in ', listName, ':')
#'         }
#'         titleMessage <- paste0(titleMessage, '\n')
#'         cat(titleMessage)
#'         titlePrinted <- TRUE
#'       }
#'       if (isList) {
#'         cat(paste0('    ', names(vectorOrList[i]), ' -> '))
#'       }
#'       cat(paste0(ifelse(isList, '', '    '), names(multiples), ' (',multiples, ' times)\n'))
#'     }
#'   }
#' }
#'
#'
