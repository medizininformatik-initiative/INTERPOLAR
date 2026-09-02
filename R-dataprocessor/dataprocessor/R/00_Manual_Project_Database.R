DATAPROCESSOR_PROJECT_DATABASE_CONFIG <- "database.toml"

getCalledManualStartSubmoduleDirs <- function(
  command_line_args = NULL,
  manual_start_submodule_dirs = list.dirs(
    DATAPROCESSOR_MANUAL_START_PATH,
    recursive = FALSE
  )
) {
  if (is.null(command_line_args)) {
    command_line_args <- commandArgs(trailingOnly = TRUE)
  }
  normalized_arguments <- gsub(
    "-",
    "_",
    tolower(command_line_args),
    fixed = TRUE
  )
  manual_start_submodule_dirs[
    tolower(basename(manual_start_submodule_dirs)) %in% normalized_arguments
  ]
}

validateManualStartInvocation <- function(
  command_line_args,
  manual_start_submodule_dirs
) {
  called_submodule_dirs <- getCalledManualStartSubmoduleDirs(
    command_line_args,
    manual_start_submodule_dirs
  )
  if (length(called_submodule_dirs) > 1L) {
    stop(
      "Start exactly one manual Data Processor project per invocation. Selected: ",
      paste(basename(called_submodule_dirs), collapse = ", "),
      ".",
      call. = FALSE
    )
  }
  if (length(called_submodule_dirs)) {
    return(called_submodule_dirs)
  }

  positional_arguments <- command_line_args[
    !startsWith(command_line_args, "-") &
      !grepl("=", command_line_args, fixed = TRUE)
  ]
  if (length(positional_arguments)) {
    available_projects <- gsub(
      "_",
      "-",
      tolower(basename(manual_start_submodule_dirs)),
      fixed = TRUE
    )
    stop(
      "Unknown manual Data Processor project argument",
      if (length(positional_arguments) > 1L) "s" else "",
      ": ", paste(positional_arguments, collapse = ", "), ". ",
      "Available projects: ", paste(available_projects, collapse = ", "),
      ". Omit the project argument to run the regular Data Processor.",
      call. = FALSE
    )
  }
  if ("--force" %in% command_line_args) {
    stop(
      "--force is only valid when starting a manual Data Processor project.",
      call. = FALSE
    )
  }
  called_submodule_dirs
}

validateManualStartDatabaseConfig <- function(db_config, project_name) {
  required_parameters <- c(
    "DB_NAME",
    "DB_HOST",
    "DB_PORT",
    "DB_DATAPROCESSOR_USER",
    "DB_DATAPROCESSOR_PASSWORD",
    "DB_DATAPROCESSOR_SCHEMA_IN",
    "DB_DATAPROCESSOR_SCHEMA_OUT"
  )
  is_single_non_empty <- function(value) {
    length(value) == 1L &&
      !is.na(value) &&
      nzchar(trimws(as.character(value)))
  }
  invalid_parameters <- required_parameters[!vapply(
    db_config[required_parameters],
    is_single_non_empty,
    logical(1)
  )]
  if (length(invalid_parameters)) {
    stop(
      "The effective database configuration for manual project '",
      project_name,
      "' is incomplete. Missing or empty parameter",
      if (length(invalid_parameters) > 1L) "s" else "",
      ": ", paste(invalid_parameters, collapse = ", "), ". ",
      "Set DB_NAME in the project's database.toml; configure the remaining ",
      "connection values in the normal database configuration.",
      call. = FALSE
    )
  }

  db_port_text <- as.character(db_config[["DB_PORT"]])
  db_port <- suppressWarnings(as.integer(db_port_text))
  if (
    !grepl("^[0-9]+$", db_port_text) ||
    is.na(db_port) ||
    db_port < 1L ||
    db_port > 65535L
  ) {
    stop(
      "The effective DB_PORT for manual project '", project_name,
      "' must be an integer between 1 and 65535; got '",
      as.character(db_config[["DB_PORT"]]), "'.",
      call. = FALSE
    )
  }
  invisible(db_config)
}

getManualStartDatabaseError <- function(error) {
  error_message <- conditionMessage(error)
  error_message <- sub("(?s)^.*Last error:\\n", "", error_message, perl = TRUE)
  sub("(?s)\\nSQL:\\n.*$", "", error_message, perl = TRUE)
}

getManualStartDatabaseErrorHint <- function(error_message) {
  normalized_error <- tolower(error_message)
  if (grepl("database .* does not exist", normalized_error)) {
    return("The database name is not available on the selected server.")
  }
  if (grepl("password authentication failed|no password supplied", normalized_error)) {
    return("Authentication failed; check the configured user and password.")
  }
  if (grepl("no pg_hba.conf entry", normalized_error, fixed = TRUE)) {
    return("The PostgreSQL server does not permit this host/user/database connection.")
  }
  if (grepl("could not translate host name|name or service not known", normalized_error)) {
    return("The configured database host cannot be resolved.")
  }
  if (grepl("connection refused", normalized_error, fixed = TRUE)) {
    return("The database server is not reachable on the configured host and port.")
  }
  if (grepl("timed out|timeout", normalized_error)) {
    return("The connection to the database server timed out.")
  }
  if (grepl("too many connections|remaining connection slots", normalized_error)) {
    return("The database server currently has no connection slot available.")
  }
  "Check the selected database and its effective connection configuration."
}

validateManualStartDatabaseConnection <- function(db_config, project_name) {
  connection_details <- tryCatch(
    etlutils::dbGetReadOnlyQuery(
      paste0(
        "SELECT current_database() AS database_name,\n",
        "       current_user AS database_user,\n",
        "       current_schema() AS output_schema,\n",
        "       to_regclass('v_db_parameter') IS NOT NULL AS has_version_view,\n",
        "       COALESCE(has_table_privilege(current_user, ",
        "to_regclass('v_db_parameter'), 'SELECT'), FALSE) AS can_read_version_view"
      ),
      lock_id = NULL
    ),
    error = function(error) {
      database_error <- getManualStartDatabaseError(error)
      stop(
        "Manual Data Processor project '", project_name,
        "' cannot connect to selected database '", db_config[["DB_NAME"]],
        "' at ", db_config[["DB_HOST"]], ":", db_config[["DB_PORT"]],
        " as user '", db_config[["DB_DATAPROCESSOR_USER"]], "'. ",
        getManualStartDatabaseErrorHint(database_error), " ",
        "Database error: ", database_error,
        call. = FALSE
      )
    }
  )

  expected_columns <- c(
    "database_name",
    "database_user",
    "output_schema",
    "has_version_view",
    "can_read_version_view"
  )
  if (nrow(connection_details) != 1L || !all(expected_columns %in% names(connection_details))) {
    stop(
      "Could not validate selected database '", db_config[["DB_NAME"]],
      "' for manual project '", project_name,
      "': the database returned incomplete connection metadata.",
      call. = FALSE
    )
  }
  if (!identical(connection_details$database_name[[1]], db_config[["DB_NAME"]])) {
    stop(
      "Manual Data Processor project '", project_name,
      "' connected to database '", connection_details$database_name[[1]],
      "' instead of selected database '", db_config[["DB_NAME"]], "'.",
      call. = FALSE
    )
  }
  if (!identical(
    connection_details$database_user[[1]],
    db_config[["DB_DATAPROCESSOR_USER"]]
  )) {
    stop(
      "Manual Data Processor project '", project_name,
      "' connected as database user '", connection_details$database_user[[1]],
      "' instead of configured Data Processor user '",
      db_config[["DB_DATAPROCESSOR_USER"]], "'.",
      call. = FALSE
    )
  }
  if (!identical(
    connection_details$output_schema[[1]],
    db_config[["DB_DATAPROCESSOR_SCHEMA_OUT"]]
  )) {
    stop(
      "Selected database '", db_config[["DB_NAME"]],
      "' does not provide the configured Data Processor output schema '",
      db_config[["DB_DATAPROCESSOR_SCHEMA_OUT"]],
      "' for manual project '", project_name, "'.",
      call. = FALSE
    )
  }
  if (!isTRUE(connection_details$has_version_view[[1]])) {
    stop(
      "Selected database '", db_config[["DB_NAME"]],
      "' is not a compatible INTERPOLAR analysis database: required view '",
      db_config[["DB_DATAPROCESSOR_SCHEMA_OUT"]],
      ".v_db_parameter' is missing.",
      call. = FALSE
    )
  }
  if (!isTRUE(connection_details$can_read_version_view[[1]])) {
    stop(
      "The configured Data Processor user '",
      db_config[["DB_DATAPROCESSOR_USER"]],
      "' cannot read required view '",
      db_config[["DB_DATAPROCESSOR_SCHEMA_OUT"]],
      ".v_db_parameter' in selected database '", db_config[["DB_NAME"]],
      "'. Check the user's database permissions.",
      call. = FALSE
    )
  }
  invisible(connection_details)
}

setManualStartDatabaseContext <- function(db_config) {
  etlutils::dbSetModuleContext(
    module_name = "dataprocessor",
    db_config = db_config,
    db_schema_base_name = "dataprocessor",
    log = FALSE
  )
}

readManualStartDatabaseConfig <- function(base_config_path, project_config_path) {
  etlutils::dbReadConfigWithOverrides(
    path_to_db_toml = base_config_path,
    path_to_override_toml = project_config_path,
    mandatory_override_parameters = "DB_NAME"
  )
}

configureManualStartDatabase <- function(
  config,
  command_line_args = NULL,
  manual_start_submodule_dirs = list.dirs(
    DATAPROCESSOR_MANUAL_START_PATH,
    recursive = FALSE
  )
) {
  if (is.null(command_line_args)) {
    command_line_args <- commandArgs(trailingOnly = TRUE)
  }
  called_submodule_dirs <- validateManualStartInvocation(
    command_line_args,
    manual_start_submodule_dirs
  )
  if (!length(called_submodule_dirs)) {
    return(invisible(NULL))
  }
  project_name <- basename(called_submodule_dirs[[1]])

  project_db_config_path <- file.path(
    called_submodule_dirs[[1]],
    DATAPROCESSOR_PROJECT_DATABASE_CONFIG
  )
  if (!file.exists(project_db_config_path)) {
    stop(
      "Manual Data Processor projects require a database.toml file in their ",
      "project directory. Copy R-dataprocessor/submodules/manual_start/",
      "database_example.toml to ", project_db_config_path, " and set DB_NAME.",
      call. = FALSE
    )
  }

  db_config <- tryCatch(
    readManualStartDatabaseConfig(
      config[["PATH_TO_DB_CONFIG_TOML"]],
      project_db_config_path
    ),
    error = function(error) {
      stop(
        "Invalid database configuration for manual project '",
        project_name, "': ", conditionMessage(error),
        call. = FALSE
      )
    }
  )
  validateManualStartDatabaseConfig(db_config, project_name)
  force_original_database <- "--force" %in% command_line_args
  if (
    identical(db_config[["DB_NAME"]], "cds_hub_db") &&
    !force_original_database
  ) {
    stop(
      "Manual Data Processor projects must not run on cds_hub_db by default. ",
      "Use --force only when running this project on the original database is intentional.",
      call. = FALSE
    )
  }

  setManualStartDatabaseContext(db_config)
  validateManualStartDatabaseConnection(db_config, project_name)
  message(
    "Manual Data Processor project '", project_name,
    "' database verified: ", db_config[["DB_NAME"]]
  )
  invisible(db_config)
}
