#' Read a TOML File into a Named List
#'
#' This function reads a TOML configuration file and returns its content as a
#' flattened named list. Nested structures in the TOML file are flattened, and
#' parent names are removed from the variable names for easier access.
#'
#' @param path_to_toml A character string specifying the path to the TOML file.
#'                     The path is normalized for better error messages.
#'
#' @return A named list containing the flattened configuration values from the
#'         TOML file.
#' @export
readTomlAsNamedList <- function(path_to_toml) {
  # Normalize relative path for error message
  path_to_toml <- normalizePath(path_to_toml)
  # Load the config TOML file
  toml_content <- RcppTOML::parseToml(path_to_toml)
  # Flatten nested list and remove parent names from variable names
  flatten_config <- flattenList(toml_content)
  return(flatten_config)
}


#' Initialize Constants from a TOML File
#'
#' This function reads configuration values from a TOML file and assigns them
#' as variables in the specified environment. If any expected variables are missing,
#' default values provided in the `defaults` parameter are used.
#'
#' @param path_to_toml A character string specifying the path to the TOML file.
#' @param defaults A named character vector of default values. If variables from the
#'        TOML file are missing, these defaults will be assigned.
#' @param envir The environment where the constants should be assigned. Default is
#'        the global environment (`.GlobalEnv`).
#'
#' @return A named list containing the flattened configuration constants.
#'
initConstants <- function(path_to_toml, defaults = c(), envir = .GlobalEnv) {
  # Read and flatten the TOML configuration file
  constants <- readTomlAsNamedList(path_to_toml)

  # Assign constants to the specified environment
  for (variable_name in names(constants)) {
    assign(variable_name, constants[[variable_name]], envir = envir)
  }

  # Assign default values for missing variables
  for (i in seq_along(defaults)) {
    variable_name <- names(defaults)[i]
    if (!exists(variable_name, envir = envir)) {
      assign(variable_name, defaults[i], envir = envir)
    }
  }

  return(constants)
}

#' Add Constants from a TOML File to an Existing List
#'
#' This function reads constants from a specified TOML file and adds them to an
#' existing list of constants. If variables in the TOML file have the same names
#' as those in the existing list, their values will be overwritten.
#'
#' @param path_to_toml A character string specifying the path to the TOML file.
#' @param existing_constants A named list of constants to which new constants
#'        from the TOML file will be added. Default is an empty list.
#' @param envir The environment where the constants should be assigned. Default
#'        is the global environment (`.GlobalEnv`).
#'
#' @return A named list containing the merged constants, with values from the
#'         TOML file overriding existing ones if there are duplicates.
#'
addConstants <- function(path_to_toml, existing_constants = list(), envir = .GlobalEnv) {
  # Read constants from the TOML file
  constants <- initConstants(path_to_toml, envir = envir)

  # Merge constants into the existing list
  for (i in seq_along(constants)) {
    existing_constants[[names(constants)[i]]] <- constants[[i]]
  }

  return(existing_constants)
}

#' Initialize Module Constants from Multiple TOML Files
#'
#' This function initializes constants from a primary TOML file, an optional debug TOML file,
#' and an optional database TOML file. It assigns these constants to a specified environment,
#' typically the global environment. Additionally, the project name and timestamp are set
#' based on configuration values. Default values can also be specified for missing variables.
#'
#' @param module_name A string specifying the name of the module being initialized.
#' @param path_to_toml A string specifying the path to the primary configuration TOML file.
#' @param debug_path_to_config_toml An optional string specifying the path to a debug TOML file.
#' @param defaults A named vector of default values for variables. Missing variables after loading
#'        the TOML file are initialized with these values.
#' @param envir The environment where variables should be assigned. Default is `.GlobalEnv`.
#'
#' @return A list containing all initialized constants, including updated values from the debug file
#'         and merged constants from the database configuration, if provided.
#'
#' @export
initModuleConstants <- function(module_name, path_to_toml, debug_path_to_config_toml = NA,
                                defaults = c(), envir = .GlobalEnv) {

  # Set the project name in the specified environment
  assign("PROJECT_NAME", module_name, envir = envir)

  # Initialize constants from the main TOML file
  constants <- initConstants(path_to_toml, defaults, envir)

  # Optionally load debug constants if provided
  if (!isSimpleNA(debug_path_to_config_toml)) {
    constants <- addConstants(debug_path_to_config_toml, constants, envir)
  }

  # Initialize the project timestamp if not already set
  if (!exists("PROJECT_TIME_STAMP", envir = envir)) {
    project_time_stamp <- ""
    if (isDefinedAndTrue("USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX", envir = envir)) {
      project_time_stamp <- format(Sys.time(), "-%Y-%m%d-%H%M%S")
    }
    assign("PROJECT_TIME_STAMP", project_time_stamp, envir = envir)
  }
  # Initialize the database context if the database TOML path is provided
  path_to_db_toml <- constants[["PATH_TO_DB_CONFIG_TOML"]]
  if (!is.null(path_to_db_toml)) {
    log_db <- exists("VERBOSE") && VERBOSE >= VL_90_FHIR_RESPONSE
    dbInitModuleContext(module_name, path_to_db_toml, log_db)
  }

  return(constants)
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
