# Environment for saving current states
.lib_envir_env <- new.env()

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

#' Check if a Variable is Defined and False
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
#' isDefinedAndFalse("var1")  # Returns FALSE
#' isDefinedAndFalse("var2")  # Returns TRUE
#' isDefinedAndFalse("var3")  # Returns FALSE, since var3 is not defined
#'
#' @export
isDefinedAndFalse <- function(variable_name, envir = parent.frame()) {
  return(exists(variable_name, envir = envir) && !isTRUE(get(variable_name, envir = envir)))
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

#' Initialize command-line arguments as key-value list or global variables
#'
#' Parses command-line arguments in the form `key=value` or `-flag` and returns a named list of
#' parsed key-value pairs. Optionally, variables can be written into the global environment.
#' Supports type conversion (date, timestamp, numeric, integer, boolean) and default values.
#'
#' @param argument2global_variable_name Named character vector or list to map argument names
#'   to variable names. E.g. c("input" = "input_file"). Keys are normalized to lower_snake_case.
#' @param defaults Named list or vector of default values for variables (by final variable name).
#' @param command_arguments Character vector or single string of CLI arguments.
#'   Default: commandArgs(trailingOnly = TRUE)
#' @param store_as_global Logical. If TRUE, variables are assigned in the global environment.
#'   Default is FALSE.
#' @param timezone Timezone to use for parsing timestamps (POSIXct). Defaults to GLOBAL_TIMEZONE if set,
#'   otherwise "Europe/Berlin".
#'
#' @return Named list of parsed and defaulted arguments.
#'
#' @export
initCommandLineArguments <- function(argument2global_variable_name = c(),
                                     defaults = list(),
                                     command_arguments = NULL,
                                     store_as_global = FALSE,
                                     timezone = if (exists("GLOBAL_TIMEZONE", inherits = TRUE)) GLOBAL_TIMEZONE else "Europe/Berlin") {
  #
  # Normalize input string to character vector
  #
  if (is.null(command_arguments)) {
    command_arguments <- commandArgs(trailingOnly = TRUE)
  } else if (length(command_arguments) == 1L) {
    command_arguments <- strsplit(command_arguments, " +")[[1]]
  }

  #
  # Standardize mapping keys (lowercase, dashes to underscores)
  #
  if (length(argument2global_variable_name)) {
    names(argument2global_variable_name) <- tolower(gsub("-", "_", names(argument2global_variable_name)))
  }

  #
  # Helper function to parse value with type conversion
  #
  parseValue <- function(value_raw, timezone) {
    if (grepl("[ T]", value_raw) && grepl(":", value_raw)) {
      # Likely a timestamp
      tryCatch({
        val <- as.POSIXct(value_raw, tz = timezone)
        if (!is.na(val)) return(val)
      }, error = function(e) NULL)
    } else {
      # Likely a date
      tryCatch({
        val <- as.Date(value_raw)
        if (!is.na(val)) return(val)
      }, error = function(e) NULL)
    }

    if (grepl("^\\d+$", value_raw)) {
      return(as.integer(value_raw))
    }

    if (grepl("^\\d+\\.\\d+$", value_raw)) {
      return(as.numeric(value_raw))
    }

    if (tolower(value_raw) %in% c("true", "false")) {
      return(tolower(value_raw) == "true")
    }

    return(value_raw)
  }

  initialized_variables <- list()

  for (arg in command_arguments) {
    name <- NULL
    value_raw <- NULL

    if (grepl("=", arg, fixed = TRUE)) {
      split_arg <- strsplit(arg, "=", fixed = TRUE)[[1]]
      if (length(split_arg) != 2 || nchar(split_arg[1]) == 0) next
      name <- split_arg[1]
      value_raw <- split_arg[2]
    } else if (grepl("^-[^-]", arg)) {
      name <- sub("^-+", "", arg)
      value_raw <- "TRUE"
    } else {
      next
    }

    # Normalize the key: lowercase and replace "-" with "_"
    name <- tolower(gsub("-", "_", name))

    # Apply mapping if available
    final_name <- if (!is.null(argument2global_variable_name[[name]])) {
      argument2global_variable_name[[name]]
    } else {
      name
    }

    value <- parseValue(value_raw, timezone)

    initialized_variables[[final_name]] <- value
  }

  # Fill in defaults if not already set
  for (default_name in names(defaults)) {
    if (!default_name %in% names(initialized_variables)) {
      initialized_variables[[default_name]] <- defaults[[default_name]]
    }
  }

  # Optional: assign to global environment
  if (isTRUE(store_as_global)) {
    for (var_name in names(initialized_variables)) {
      assign(var_name, initialized_variables[[var_name]], envir = .GlobalEnv)
    }
  }

  return(initialized_variables)
}

####
# Version
####

#' Compare two semantic version strings
#'
#' Compares two version strings using semantic versioning rules. The versions do
#' not need to have the same number of components. Missing components are treated
#' as zero. The comparison is performed component-wise from left to right.
#'
#' @param version_a Character scalar. First version string to compare, e.g.
#'   \code{"1.5.0"}.
#' @param version_b Character scalar. Second version string to compare, e.g.
#'   \code{"1.10"}.
#'
#' @return Integer scalar indicating the comparison result: \code{-1L} if
#'   \code{version_a} is smaller than \code{version_b}, \code{0L} if both versions
#'   are equal, and \code{1L} if \code{version_a} is greater than
#'   \code{version_b}.
#'
#' @examples
#' compareVersionsSemver("1.5.0", "1.5")      # 0
#' compareVersionsSemver("1.5.0", "1.6.0")    # -1
#' compareVersionsSemver("2.0", "1.9.9")      # 1
#'
#' @export
compareVersionsSemver <- function(version_a, version_b) {
  # split versions into numeric components
  parse_version <- function(version) {
    parts <- strsplit(version, "\\.", fixed = FALSE)[[1]]
    as.integer(parts)
  }

  a <- parse_version(version_a)
  b <- parse_version(version_b)

  # compare component-wise up to the longest version
  max_len <- max(length(a), length(b))

  for (i in seq_len(max_len)) {
    a_i <- if (i <= length(a)) a[i] else 0L
    b_i <- if (i <= length(b)) b[i] else 0L

    if (a_i < b_i) return(-1L)
    if (a_i > b_i) return(1L)
  }

  return(0L)
}

#' Read the release version from file
#'
#' Reads the release version string from the first line of the
#' \code{release-version.txt} file located in the project root directory. Leading
#' and trailing whitespace is removed. If the version string starts with a
#' leading \code{"v"} (case-insensitive), it is stripped.
#'
#' @return Character scalar containing the normalized release version string,
#'   e.g. \code{"1.5.0"}.
#'
getReleaseVersion <- function() {
  release_version <- readLines("./release-version.txt", n = 1L)
  release_version <- trimws(release_version)
  # if the release version starts with "v", remove it
  if (startsWith(tolower(release_version), "v")) {
    release_version <- substring(release_version, 2L)
  }
  return(release_version)
}

#' Check database version against the release version
#'
#' Compares the database schema version stored in the database with the release
#' version expected by the R project and enforces compatibility rules.
#'
#' If the database version is older than the release version, execution is
#' stopped and the user is instructed to run the required database migrations.
#'
#' If the database version is newer than the release version, execution is
#' stopped unless explicitly allowed. Allowing newer database versions is
#' intended for rollback scenarios where the database schema is assumed to be
#' backward-compatible with older releases.
#'
#' The version check is performed only once per R session.
#'
#' @param ignore_newer_db_version Logical flag indicating whether execution
#'   should continue when the database version is newer than the release
#'   version. If \code{FALSE}, execution is stopped and the user is instructed
#'   to explicitly force the run. If \code{TRUE}, newer database versions are
#'   accepted.
#'
#' @return Invisibly returns \code{NULL}. This function is called for its side
#'   effects and will stop execution with an error if version compatibility
#'   requirements are not met.
#'
#' @export
checkVersion <- function(ignore_newer_db_version) {
  if (!isDefinedAndTrue("VERSION_ALREADY_CHECKED", .lib_envir_env)) {
    db_version <- dbGetVersion()
    # read the first line of the release-version.txt file in the main directory
    release_version <- getReleaseVersion()
    compare_result <- compareVersionsSemver(db_version, release_version)
    if (compare_result < 0L) { # DB is older than release version -> stop execution
      stop(paste0("The database version '", db_version, "' is older than the release version '", release_version, "'. Please update the database via migration. Run\n",
                  "  docker compose exec -w /cds_hub-initdb.d cds_hub psql -U cds_hub_db_admin -d cds_hub_db -f ./migration/migration.sql\n",
                  "  or see https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/749 for more details."))
    } else if (compare_result > 0L) { # DB is newer than release version -> allow force run
      if (!ignore_newer_db_version) {
        stop(paste0("The database version '", db_version, "' is newer than the release version '", release_version, "'. If you know what you are doing:",
                    " You can force the run anyway, if you start the full toolchain with the parameter '--ignoreNewerDBVersion'. This works not for single modules!"))
      }
    }
    .lib_envir_env[["VERSION_ALREADY_CHECKED"]] <- TRUE
  }
}
