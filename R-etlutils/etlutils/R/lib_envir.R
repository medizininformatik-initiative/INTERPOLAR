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
#' @param db_schema_base_name The base name of the database schema. If NULL the module name is used.
#' @param path_to_toml A string specifying the path to the primary configuration TOML file.
#' @param defaults A named vector of default values for variables. Missing variables after loading
#'        the TOML file are initialized with these values.
#' @param envir The environment where variables should be assigned. Default is `.GlobalEnv`.
#' @param init_constants_only A logical value indicating whether only module constants
#' should be initialized (`TRUE`) or if the full module setup (including directory creation,
#' logging, and process clock initialization) should be performed (`FALSE`).
#'
#' @return A list containing all initialized constants, including updated values from the debug file
#'         and merged constants from the database configuration, if provided.
#'
#' @export
initModuleConstants <- function(module_name, db_schema_base_name = NULL, path_to_toml, defaults = c(), envir = .GlobalEnv, init_constants_only) {

  # Set the project name in the specified environment
  assign("MODULE_NAME", module_name, envir = envir)
  assign("MODULE_NAME", module_name, envir = .GlobalEnv)

  # Initialize constants from the main TOML file
  constants <- initConstants(path_to_toml, defaults, envir)

  # Optionally load and add debug constants if provided
  if (exists("DEBUG_PATH_TO_CONFIG_TOML") && nchar(DEBUG_PATH_TO_CONFIG_TOML)) {
    constants <- addConstants(DEBUG_PATH_TO_CONFIG_TOML, constants, envir)
  }

  # Initialize the project timestamp if not already set
  if (!exists("MODULE_TIME_STAMP", envir = envir)) {
    project_time_stamp <- ""
    if (isDefinedAndTrue("USE_TIMESTAMP_AS_RESULT_DIR_SUFFIX", envir = envir)) {
      project_time_stamp <- format(Sys.time(), "-%Y-%m%d-%H%M%S")
    }
    assign("MODULE_TIME_STAMP", project_time_stamp, envir = envir)
  }
  # Initialize the database context if the database TOML path is provided
  path_to_db_toml <- constants[["PATH_TO_DB_CONFIG_TOML"]]
  if (!is.null(path_to_db_toml)) {
    log_db <- exists("VERBOSE") && VERBOSE >= VL_90_FHIR_RESPONSE
    if (is.null(db_schema_base_name)) {
      db_schema_base_name <- module_name
    }
    dbInitModuleContext(db_schema_base_name, path_to_db_toml, log_db)
  }

  return(constants)
}

#' Get the module name from the internal package environment
#'
#' @return A character string containing the module name stored in the package environment
#'
#' @export
getModuleName <- function() {
  get("MODULE_NAME", envir = .GlobalEnv)
}

#' Set the submodule name in the specified environment
#'
#' @param submodule_name A character string specifying the submodule name to store
#'
#' @return No return value, called for side effects
#'
#' @export
setSubmoduleName <- function(submodule_name) {
  # Set the submodule name in the specified environment
  assign("SUBMODULE_NAME", submodule_name, envir = .GlobalEnv)
}

#' Get the submodule name from the specified environment
#'
#' @return A character string containing the submodule name or an empty string if not set
#'
#' @export
getSubmoduleName <- function() {
  # Get the submodule name from the specified environment
  if (exists("SUBMODULE_NAME", envir = .GlobalEnv)) {
    return(get("SUBMODULE_NAME", envir = .GlobalEnv))
  }
  return("")
}

#' Remove the submodule name from the specified environment
#'
#' @return No return value, called for side effects
#'
#' @export
removeSubmoduleName <- function() {
  # Remove the submodule name from the specified environment
  if (exists("SUBMODULE_NAME", envir = .GlobalEnv)) {
    rm("SUBMODULE_NAME", envir = .GlobalEnv)
  }
}

#' Initialize Submodule Constants from TOML Files
#'
#' This function initializes constants for a submodule by loading one or multiple TOML files.
#' If `path_to_toml` is a directory, all files ending in `_config.toml` within the directory
#' are loaded. If `path_to_toml` is a file, only that specific file is loaded.
#'
#' @param path_to_toml A string specifying the path to the TOML file or directory.
#' @param defaults A named vector of default values for variables. Missing variables after loading
#'        the TOML files are initialized with these values.
#' @param envir The environment where the constants should be assigned. Default is `.GlobalEnv`.
#'
#' @return A named list containing all initialized constants, including those loaded from the TOML files.
#'
#' @export
initSubmoduleConstants <- function(path_to_toml, defaults = c(), envir = .GlobalEnv) {
  constants <- list()
  if (file.info(path_to_toml)$isdir) {
    # If path_to_toml is a directory -> list all files with ending "_config\\.toml"
    toml_files <- list.files(path_to_toml, pattern = "_config\\.toml$", full.names = TRUE)
  } else {
    # If path_to_toml is a file -> read only this file
    toml_files <- c(path_to_toml)
  }
  for (toml_file in toml_files) {
    constants <- addConstants(toml_file, constants, envir)
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

#' Check if a Variable is Defined and Not Empty
#'
#' This function checks if a given variable is defined in the specified environment and whether its
#' value is neither an empty string (i.e., `""`) nor an empty vector (i.e., `character(0)` or `numeric(0)`).
#'
#' @param variable_name The name of the variable to check, provided as a string.
#' @param envir The environment in which to check for the variable. Defaults to the current environment.
#'
#' @return TRUE if the variable is defined and contains at least one non-empty value, otherwise FALSE.
#'
#' @examples
#' var1 <- "some text"
#' var2 <- ""
#' var3 <- character(0)
#' var4 <- list()
#' isDefinedAndNotEmpty("var1")  # Returns TRUE
#' isDefinedAndNotEmpty("var2")  # Returns FALSE
#' isDefinedAndNotEmpty("var3")  # Returns FALSE
#' isDefinedAndNotEmpty("var4")  # Returns FALSE
#' isDefinedAndNotEmpty("varX")  # Returns FALSE, since varX is not defined
#'
#' @export
isDefinedAndNotEmpty <- function(variable_name, envir = parent.frame()) {
  if (!exists(variable_name, envir = envir)) {
    return(FALSE)
  }
  val <- get(variable_name, envir = envir)
  return(length(val) > 0 && any(nzchar(val)))
}

#' Check for the existence of mandatory parameters
#'
#' This function verifies whether all specified mandatory parameters exist in the current environment.
#' If any of the parameters are missing, an error is raised, listing the missing parameters.
#'
#' @param mandatory_parameters A character vector containing the names of the parameters to check.
#'
#' @return None. The function stops execution if any mandatory parameters are missing.
#'
checkMandatoryParameters <- function(mandatory_parameters) {
  missing_parameters <- c()
  for (param in mandatory_parameters) {
    if (!exists(param)) {
      missing_parameters <- c(missing_parameters, param)
    }
  }
  if (length(missing_parameters)) {
    stop("The following parameters are mandatory and must be defined in the modules toml file:\n     ", paste0(missing_parameters, collapse = "\n     "))
  }
}
