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
  is.atomic(x) && length(x) == 1 && x
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
  is.atomic(x) && length(x) == 1 && !x
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

#'
#' Check if debugging mode is enabled.
#'
#' This function checks if debugging mode is enabled by verifying the existence of the 'DEBUG' variable and if it is
#' set to TRUE. his can be used in code to enable code sections only if a global variable DEGUG is set to TRUE.
#'
#' @return TRUE if debugging mode is enabled, otherwise FALSE.
#'
isDebug <- function() exists('DEBUG') && DEBUG

#' Execute an outer script with a specified message and process
#'
#' This function runs an outer script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the outer script.
#' @param process A function representing the outer script to be executed.
#'
#' @export
run_out <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_20_OUTER_SCRIPTS
  )}

#' Execute an inner script with a specified message and process
#'
#' This function runs an inner script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the inner script.
#' @param process A function representing the inner script to be executed.
#'
#' @export
run_in <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_30_INNER_SCRIPTS
  )}

#' Execute an inner script info with a specified message and process
#'
#' This function runs an inner script info with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the inner script info.
#' @param process A function representing the inner script info to be executed.
#'
#' @export
run_in_in <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_40_INNER_SCRIPTS_INFOS
  )}

#' Execute an inner script info with a specified message and process
#'
#' This function runs an inner script info with the provided message and process, controlling
#' the verbosity level. If an error occurs, it is ignored.
#'
#' @param message A character string describing the purpose of the inner script info.
#' @param process A function representing the inner script info to be executed.
#'
#' @export
run_in_in_ignore_error <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_40_INNER_SCRIPTS_INFOS,
    throw_exception = FALSE
  )}

#' Execute a script with specified message, process, and verbosity level
#'
#' This function runs a script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the script.
#' @param process A function representing the script to be executed.
#' @param verbose An integer specifying the verbosity level.
#' @param throw_exception if TRUE the execution of the current expression will be stopped
#'
#' @export
run <- function(message, process, verbose, throw_exception = TRUE) {
  polar_run(
    message = message,
    process = process,
    verbose = VERBOSE - verbose + 1,
    single_line = VERBOSE <= verbose,
    throw_exception = throw_exception
  )}

#' Execute an outer script with specified message and process (single line)
#'
#' This function runs an outer script with the provided message and process, controlling
#' the verbosity level. Unlike `runs`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the outer script.
#' @param process A function representing the outer script to be executed.
#'
#' @export
runs_out <- function(message, process) {
  runs(
    message = message,
    process = process,
    verbose = VL_20_OUTER_SCRIPTS
  )}

#' Execute an inner script with specified message and process (single line)
#'
#' This function runs an inner script with the provided message and process, controlling
#' the verbosity level. Unlike `runs`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the inner script.
#' @param process A function representing the inner script to be executed.
#'
#' @export
runs_in <- function(message, process) {
  runs(
    message = message,
    process = process,
    verbose = VL_30_INNER_SCRIPTS
  )}

#' Execute an inner script info with specified message and process (single line)
#'
#' This function runs an inner script info with the provided message and process, controlling
#' the verbosity level. Unlike `runs`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the inner script info.
#' @param process A function representing the inner script info to be executed.
#'
#' @export
runs_in_in <- function(message, process) {
  runs(
    message = message,
    process = process,
    verbose = VL_40_INNER_SCRIPTS_INFOS
  )}

#' Execute a script with specified message, process, and verbosity level (single line)
#'
#' This function runs a script with the provided message and process, controlling
#' the verbosity level. Unlike `run`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the script.
#' @param process A function representing the script to be executed.
#' @param verbose An integer specifying the verbosity level.
#'
#' @export
runs <- function(message, process, verbose) {
  polar_run(
    message = message,
    process = process,
    verbose = VERBOSE - verbose + 1,
    single_line = TRUE
  )}

#' Conditional Print to Console (for tables) based on verbosity level
#'
#' This function prints the provided content to the console only if the global
#' verbosity level is equal to or greater than `VL_50_TABLES`.
#'
#' @param ... Objects to be printed to the console.
#'
#' @export
catl <- function(...) {
  if (VL_50_TABLES <= VERBOSE) {
    cat(..., '\n')
  }
}

#' Refresh FHIR Token
#'
#' This function refreshes the FHIR token if it is defined.
#'
#' @details
#' If the FHIR_TOKEN is defined, the function attempts to refresh it using the \code{polar_refresh_token} function.
#'
#' @export
refreshFhirToken <- function() {
  #refresh token, if defined
  if (FHIR_TOKEN != '') {
    run_in_in_ignore_error('Refresh FHIR_TOKEN', {
      FHIR_TOKEN <- polar_refresh_token()
    })
  }
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
flatten_list <- function(x, prefix = NULL) {
  result <- list()
  for (name in names(x)) {
    new_prefix <- ifelse(is.null(prefix), name, paste0(prefix, "_", name))
    if (is.list(x[[name]])) {
      result <- c(result, flatten_list(x[[name]], new_prefix))
    } else {
      result[[name]] <- x[[name]]
    }
  }
  result
}

#'
#' Loads a configuration toml file and sets all variables in this file in the global
#' context.
#'
#' @param path_to_toml path to the configuration toml file.
#'
#' @export
initConstants <- function(path_to_toml) {
  # load the config toml file in the global environment
  CONFIG <<- RcppTOML::parseToml(path_to_toml)
  # Take nested list CONFIG and flattens it into a single-level list
  # Remove parent names from variable names
  # And assign list values to the global environment
  flattenConfig <- flatten_list(CONFIG)
  # Extract variable names from flattenConfig
  variable_names <- names(flattenConfig)
  # Assign values to variables from flattenConfig
  for (variable_name in variable_names) {
    assign(variable_name, flattenConfig[[variable_name]], envir = .GlobalEnv)
  }

  # the result dir can be extended by an timestamp. this is not neccessary
  # in Interploar but was used in Polar. For debug reasons we have not deactivated
  # this functionality. To enable timestamp suffixes at the result dir set
  # the variable USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX = true in the config toml file.
  PROJECT_TIME_STAMP <<- if (exists('USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX') && USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX) {
    format(Sys.time(), '-%Y-%m%d-%H%M%S')
  } else {
    ''
  }
}


#' Print a table if VERBOSE level allows.
#'
#' This function prints a summary for the specified table if the VERBOSE level is
#' greater than or equal to VL_50_TABLES (= 5). It uses the `print_table_summary` function
#' for generating the summary.
#'
#' @param table The input table to print. For example, you can use the mtcars dataset.
#'
#' @details
#' This function checks the VERBOSE level (assumed to be a global variable) and
#' prints a summary for the specified table only if the VERBOSE level is greater than
#' or equal to VL_50_TABLES. The table_name is obtained from the calling function's name.
#'
#' @seealso
#' \code{\link{print_table_summary}}
#'
#' @export
#'
#' @examples
#' # Load required packages
#' library(datasets)
#' library(data.table)
#'
#' #' # Load the mtcars dataset and convert it to a data.table
#' data(mtcars)
#' setDT(mtcars)
#'
#' # Set VL_50_TABLES and VERBOSE to appropriate values
#' VL_50_TABLES <- 5
#' VERBOSE <- 7
#'
#' # Assuming VERBOSE and VL_50_TABLES are defined
#' print_table(mtcars)
#'
print_table <- function(table) {
  if (VERBOSE >= VL_50_TABLES) {
    table_name <- as.character(sys.call()[2]) # get parameter names
    print_table_summary(table, table_name)
  }
}

#' Print a table if VERBOSE level allows.
#'
#' This function prints a summary for the specified table if the VERBOSE level is
#' greater than or equal to VL_60_ALL_TABLES (= 6). It uses the `print_table_summary` function
#' for generating the summary.
#'
#' @param table The input table to print. For example, you can use the mtcars dataset.
#'
#' @details
#' This function checks the VERBOSE level (assumed to be a global variable) and
#' prints a summary for the specified table only if the VERBOSE level is greater than
#' or equal to VL_60_ALL_TABLES The table_name is obtained from the calling function's name.
#'
#' @seealso
#' \code{\link{print_table_summary}}
#'
#' @export
#'
#' @examples
#' # Load required packages
#' library(datasets)
#' library(data.table)
#'
#' # Load the mtcars dataset and convert it to a data.table
#' data(mtcars)
#' setDT(mtcars)
#'
#' # Set VL_60_ALL_TABLES and VERBOSE to appropriate values
#' VL_60_ALL_TABLES <- 6
#' VERBOSE <- 7
#'
#' # Assuming VERBOSE and VL_60_ALL_TABLES are defined
#' print_table_if_all(mtcars)
#'
print_table_if_all <- function(table) {
  if (VERBOSE >= VL_60_ALL_TABLES) {
    table_name <- as.character(sys.call()[2]) # get parameter name
    print_table_summary(table, table_name)
  }
}


#' Get a list of global variables with a specified prefix.
#'
#' This function searches for global variables in the current workspace whose names
#' start with the specified prefix and returns a list containing variable names
#' along with their values.
#'
#' @param prefix The prefix to match in variable names.
#'
#' @return A list containing the names and values of global variables with the given prefix.
#'
#' @examples
#' \dontrun{
#' prefix <- "my_prefix"
#' result <- getGlobalVariablesByPrefix(prefix)
#' print(result)
#' }
#'
#' @seealso
#' \code{\link{ls}}, \code{\link{eapply}}
#'
#' @keywords global variables workspace prefix
#'
#' @export
getGlobalVariablesByPrefix <- function(prefix) {
  global_vars <- ls(globalenv())
  matching_vars <- grep(paste0("^", prefix), global_vars, value = TRUE)
  result_list <- lapply(matching_vars, function(var_name) {
    var_value <- get(var_name, envir = globalenv())
    setNames(list(var_value), var_name)
  })
  return(result_list)
}

#' Get the value of a variable by name or a default value if the variable is missing.
#'
#' This function checks if a variable with the specified name exists. If it does,
#' it returns the value of the variable; otherwise, it returns the specified default value.
#'
#' @param var_name A character string specifying the name of the variable.
#' @param default The default value to be returned if the variable is missing. Defaults to NA.
#'
#' @return The value of the variable if it exists; otherwise, the specified default value.
#'
#' @examples
#' # Set a variable
#' my_variable <- 123
#'
#' # Use getVarByNameOrDefaultIfMissing to retrieve the value
#' result <- getVarByNameOrDefaultIfMissing("my_variable", default = 42)
#' print(result)  # Output: 123
#'
#' # Try with a non-existing variable
#' result_missing <- getVarByNameOrDefaultIfMissing("nonexistent_variable", default = "Not found")
#' print(result_missing)  # Output: "Not found"
#'
#' @export
getVarByNameOrDefaultIfMissing <- function(var_name, default = NA) if (exists(var_name)) get(var_name) else default

#' Extracts the local, relative part from absolute references.
#'
#' This function takes a character vector of absolute references and removes the leading part
#' to return only the local, relative portion of each reference.
#'
#' @param references A character vector containing absolute references.
#' @return A character vector with only the local, relative part of each reference.
#'
#' @examples
#' absolute <- c('Patient/PID_001', 'Encounter/EID_001', 'Condition/CID_001')
#' relative <- makeRelative(absolute)
#' print(relative)
#'
#' @export
makeRelative <- function(references) {
  return(sub(".*/", "", references))
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
#' result_single <- getStringBetweenQuotes("This is a 'sample' string.")
#' result_double <- getStringBetweenQuotes('Another "example" string.')
#' print(result_single)  # Output: "sample"
#' print(result_double)  # Output: "example"
#'
#' @export
getStringBetweenQuotes <- function(x) gsub(".*?['\"](.*?)['\"].*", "\\1", as.character(x))

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
#' catList <- function(list) {
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
#'   catl(paste0(contacts_name, ':\n', paste0('  ', names(contacts), ': ', sapply(contacts, ansi, underline = TRUE), collapse = '\n')))
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
#' #'
#' #' Perform a case-insensitive pattern search using `grepl` with Perl patterns (perl = TRUE).
#' #'
#' #' @param pattern A pattern to search for.
#' #' @param x A list or table where the pattern should be searched.
#' #' @param whole_word If TRUE, the pattern will be treated as a whole word and matched accordingly.
#' #'                   It adds '^' to the beginning and '$' to the end of the pattern if they don't exist.
#' #' @param perl If TRUE, uses Perl-compatible regular expressions for pattern matching (default is TRUE).
#' #' @seealso grepl
#' #'
#' #' This function performs case-insensitive pattern searches using `grepl` with Perl patterns. If `whole_word` is set to TRUE,
#' #' the pattern is treated as a whole word, and '^' is added to the beginning and '$' to the end of the pattern if they are missing.
#' #' When `perl` is TRUE, Perl-compatible regular expressions are used for pattern matching.
#' #'
#' #' @examples
#' #' pattern <- 'AAA|BBB'
#' #' greplic(pattern, 'I am a sentence with AAAA and CCC.', whole_word = TRUE) # FALSE
#' #' greplic(pattern, 'I am a sentence with AAA and CCC.', whole_word = TRUE) # TRUE
#' #'
#' greplic <- function(pattern, x, whole_word = FALSE, perl = TRUE) {
#'   if (whole_word) {
#'     subPatterns <- unlist(strsplit(pattern, '\\|'))
#'     subPatterns <- lapply(subPatterns, function(subPattern) subPattern <- paste0('(?<!\\S)', subPattern, '(?!\\S)'))
#'     pattern <- paste0(subPatterns, collapse = '|')
#'   }
#'   grepl(pattern, x, ignore.case = TRUE, perl)
#' }
#'
#' #' Remove the last character from a string if it is not alphanumeric.
#' #'
#' #' This function takes a character vector and removes the last character
#' #' from each string element if it is not alphanumeric (i.e., not a letter or a number).
#' #'
#' #' @param text A character vector containing strings.
#' #'
#' #' @return A character vector with the last character removed from each element if it is not alphanumeric.
#' #'
#' #' @examples
#' #' # Example data.table
#' #' library(data.table)
#' #' dt <- data.table(
#' #'   ID = 1:4,
#' #'   Text = c("abc123!", "hello-", "world9", "example")
#' #' )
#' #'
#' #' # Apply the function to the "Text" column
#' #' dt[, Text := lapply(Text, removeLastCharsIfNotAlphanumeric)]
#' #' print(dt)
#' #'
#' #' @export
#' removeLastCharsIfNotAlphanumeric <- function(text) {
#'   for (i in seq_len(length(text))) {
#'     while (nchar(text[i]) & !grepl("[A-Za-z0-9]$", text[i])) {
#'       text[i] <- substr(text[i], 1, nchar(text[i]) - 1)
#'     }
#'   }
#'   return(text)
#' }
#'
