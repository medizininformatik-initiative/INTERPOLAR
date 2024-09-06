#' Loads a configuration toml file and sets all variables in this file in the global
#' context.
#'
#' @param path_to_toml path to the configuration toml file.
#' @param defaults a vector with default values. The names of the elements are the variables names. If the variable
#'                 is not found in the global context after the initialization with the toml file, then this default
#'                 values will be set.
#' @param envir the environment in which the variables should be loaded. Default is .GlobalEnv.
#'
#' @export
initConstants <- function(path_to_toml, defaults = c(), envir = .GlobalEnv) {
  # normalize relative path for error message
  path_to_toml <- normalizePath(path_to_toml)
  # load the config toml file in the global environment
  CONFIG <<- RcppTOML::parseToml(path_to_toml)
  # Take nested list CONFIG and flattens it into a single-level list
  # Remove parent names from variable names
  # And assign list values to the global environment
  flattenConfig <- flattenList(CONFIG)
  # Extract variable names from flattenConfig
  variable_names <- names(flattenConfig)
  # Assign values to variables from flattenConfig
  for (variable_name in variable_names) {
    assign(variable_name, flattenConfig[[variable_name]], envir = envir)
  }

  # the result dir can be extended by an timestamp. For debug reasons we have not deactivated
  # this functionality. To enable timestamp suffixes at the result dir set
  # the variable USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX = true in the config toml file.
  PROJECT_TIME_STAMP <<- if (exists('USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX') && USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX) {
    format(Sys.time(), '-%Y-%m%d-%H%M%S')
  } else {
    ''
  }

  # for all missing variables with a given default value -> set the default in the global environment
  for (i in seq_along(defaults)) {
    variable_name <- names(defaults)[i]
    if (!exists(variable_name, envir = envir)) {
      assign(variable_name, defaults[i], envir = envir)
    }
  }

}

#' Get Global Variables by Prefix
#'
#' This function retrieves all global variables from the environment that match a given prefix and returns them as either a list or a vector.
#'
#' @param prefix A string representing the prefix to search for in the global environment variable names.
#' @param astype A character string indicating the return type. It can be either `"list"` (default) or `"vector"`.
#'
#' @return Returns either a list or a vector of global variables that match the given prefix.
#'   - If `astype = "list"`, returns a list where each element is named after the global variable, containing the corresponding value.
#'   - If `astype = "vector"`, returns a vector of the global variable values.
#'
#' @examples
#' # Assuming global variables exist in the environment:
#' DEBUG_VAR1 <- 1
#' DEBUG_VAR2 <- 2
#' getGlobalVariablesByPrefix("DEBUG_", "list")
#'
#' @export
getGlobalVariablesByPrefix <- function(prefix, astype = c("list", "vector")) {
  astype <- match.arg(astype)
  global_vars <- ls(globalenv()) # Get all global variables
  matching_vars <- grep(paste0("^", prefix), global_vars, value = TRUE) # Match variables with the prefix
  result_list <- lapply(matching_vars, function(var_name) {
    var_value <- get(var_name, envir = globalenv()) # Get the variable value
    setNames(list(var_value), var_name) # Create a named list element
  })
  # Return as vector if specified
  if (astype %in% "vector") {
    return(unlist(result_list))
  }
  return(result_list) # Default return as list
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

#' Check if a Variable is Defined and True
#'
#' This function checks if a given variable is defined in the specified environment and if its value is `TRUE`.
#'
#' @param variable_name The name of the variable to check, provided as a string.
#' @param envir The environment in which to check for the variable. Defaults to the current environment.
#'
#' @return TRUE if the variable is defined and its value is `TRUE`, otherwise FALSE.
#'
#' @examples
#' var1 <- TRUE
#' var2 <- FALSE
#' isDefinedAndTrue("var1")  # Returns TRUE
#' isDefinedAndTrue("var2")  # Returns FALSE
#' isDefinedAndTrue("var3")  # Returns FALSE, since var3 is not defined
#'
#' @export
isDefinedAndTrue <- function(variable_name, envir = parent.frame()) {
  return(exists(variable_name, envir = envir) && isTRUE(get(variable_name, envir = envir)))
}
