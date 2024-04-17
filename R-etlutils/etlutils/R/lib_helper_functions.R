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

#'
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

#'
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
isError <- function(obj) sum(class(obj) %in% "try-error") > 0

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
#' @param err Any Type. In case of an error occurred it must contain try-error as class
#' @param expr_ok An expression. This runs in case of no error.
#' @param expr_err An expression. This runs in case of an error.
#'
#' @return err
#' @export
checkError <- function(err, expr_ok = {cat_ok()}, expr_err = {cat_error()}) {
  if (!inherits(err, 'try-error')) {
    expr_ok
  } else {
    expr_err
  }
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

#' Normalize POSIXct Time to UTC
#'
#' @param time A POSIXct date-time object.
#' @return POSIXct date-time object in UTC timezone.
#' @examples
#' time1 <- as.POSIXct("2023-03-10 12:00:00", tz = "America/New_York")
#' normalizeTimeToUTC(time1)
#' @export
normalizeTimeToUTC <- function(time) {
  # Converts the provided POSIXct object to the UTC format
  normalized_time <- as.POSIXct(format(time, tz = "UTC"), tz = "UTC")
  return(normalized_time)
}

#' Normalize Specified Column of Data.Table to UTC
#'
#' This function modifies the specified column in a given data.table by converting
#' all datetime entries to UTC format. The column is expected to contain POSIXct
#' datetime objects.
#'
#' @param dt A data.table object containing at least one column with POSIXct datetime objects.
#' @param column The name of the column to be normalized to UTC.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(time = as.POSIXct(c("2023-03-10 12:00:00",
#'                                      "2023-03-11 15:00:00"),
#'                                      tz = "America/New_York"))
#' normalizeTableColumnToUTC(dt, "time")
#' print(dt)
#'
#' @export
normalizeTableColumnToUTC <- function(dt, column) {
  dt[, (column) := as.POSIXct(format(.SD[[..column]], tz = "UTC"), tz = "UTC"), .SDcols = column]
}

#' Convert Time Format
#'
#' This function converts the time format of a column in a data table.
#'
#' @param dt A data table.
#' @param column The name of the column whose time format needs to be converted.
#'
#' @details This function takes a data table \code{dt} and the name of a column \code{column}
#' as input. It converts the time format of the specified column using the following steps:
#' - Parse the column values as POSIXct objects using \code{strptime}.
#' - Format the POSIXct objects to the desired time format using \code{format}.
#' - Update the column values in the data table with the formatted time values.
#'
#' @return This function modifies the input data table \code{dt} by converting the time format
#' of the specified column.
#'
#' @export
convertTimeFormat <- function(dt, column) {
  # Convert string in POSIXct object
  dt[, (column) := as.POSIXct(.SD[[..column]], format = "%H:%M:%S", tz = "UTC"), .SDcols = column]
  # Set date to '1970-01-01'
  dt[!is.na(dt[[column]]), (column) := as.POSIXct(paste0("1970-01-01 ", format(get(column), "%H:%M:%S")), tz = "UTC")]
}

#' Convert Date Format
#'
#' This function converts the date format of a column in a data table.
#'
#' @param dt A data table.
#' @param column The name of the column whose date format needs to be converted.
#'
#' @details This function takes a data table \code{dt} and the name of a column \code{column}
#' as input. It converts the date format of the specified column in the following steps:
#' - Convert the column to character type.
#' - Remove time information (if any) from the column values.
#' - Replace '/' with '-' in the column values.
#' - If the values match the pattern YYYY, append '-01-01' to represent the complete date.
#' - If the values match the pattern YYYY-MM, append '-01' to represent the complete date.
#' - Finally, convert the column to date type using \code{lubridate::as_date}.
#'
#' @return This function modifies the input data table \code{dt} by converting the date format
#' of the specified column.
#'
#' @export
convertDateFormat <- function(dt, column) {
  dt[, (column) := as.character(get(column))]
  dt[, (column) := gsub('T.+$', '', get(column))]
  dt[, (column) := gsub('/', '-', get(column))]
  # Set a regular expression pattern for matching YYYY format
  incomplete_date_pattern <- '^[0-9]{4}$'
  years <- grepl(incomplete_date_pattern, dt[[column]])
  dt[years, (column) := paste0(dt[years, get(column)], '-01-01')]

  # Set a regular expression pattern for matching YYYY-MM format
  incomplete_date_pattern <- '^[0-9]{4}-[0-9]{2}$'
  months <- grepl(incomplete_date_pattern, dt[[column]])
  dt[months, (column) := paste0(dt[months, get(column)], '-01')]

  dt[, (column) := lubridate::as_date(get(column))]
}

#' Fix datetime format in specified columns
#'
#' This function fixes the date format in specified columns of a data table.
#'
#' @param dt A data table.
#' @param column A character vector specifying the column to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{column} specifying the column to be fixed. It converts the values in
#' the specified column to date-time objects with the format \code{ymd_hms},
#' truncating the time to minutes and setting the timezone to "Europe/Berlin".
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the date format in the specified column
#'
#' @export
convertDateTimeFormat <- function(dt, column) {
  dt[, (column) := lubridate::ymd_hms(get(column), truncated = 5, tz = "Europe/Berlin")]
}

#' Fix integer format in specified column
#'
#' This function fixes the integer format in specified column of a data table.
#'
#' @param dt A data table.
#' @param column A character vector specifying the column to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{column} specifying the column to be fixed. It converts the values in
#' the specified column to integers using \code{as.integer}.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the integer format in the specified column
#'
#' @export
convertIntegerFormat <- function(dt, column) {
  dt[, (column) := as.integer((get(column)))]
}

#' Fix decimal format in specified column
#'
#' This function fixes the decimal format in specified column of a data table.
#'
#' @param dt A data table.
#' @param column A character vector specifying the column to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{column} specifying the column to be fixed. It converts the values in
#' the specified column to numeric using \code{as.numeric}.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the decimal format in the specified column
#'
#' @export
convertDecimalFormat <- function(dt, column) {
  dt[, (column) := as.numeric(get(column))]
}

#' Fix boolean format in specified column
#'
#' This function fixes the boolean format in specified column of a data table.
#'
#' @param dt A data table.
#' @param column A character vector specifying the column to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{column} specifying the column to be fixed. It converts the values in
#' the specified column to numeric, treating TRUE as 1 and FALSE as 0.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the boolean format in the specified column
#'
#' @export
convertBooleanFormat <- function(dt, column) {
  dt[, (column) := as.logical(get(column))]
}

#' Stop execution with Error message
#'
#' This function stops execution and prints the concatenated error message.
#'
#' @param ... Character vectors to be concatenated and printed as an error message.
#'
#' @export
stopWithError <- function(...) {
  stop(cat_red(paste(c(...))))
}

#' Stop on Error
#'
#' This function checks if the provided argument is an error. If it is, the
#' function stops the execution.
#'
#' @param potential_error The object to check for being an error.
#'
#' @seealso stop
#' @export
stopOnError <- function(potential_error) {
  if (isError(potential_error)) stop()
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
