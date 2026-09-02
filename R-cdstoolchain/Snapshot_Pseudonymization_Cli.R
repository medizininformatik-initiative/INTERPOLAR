setSnapshotPseudonymizationWorkingDirectory <- function() {
  if (grepl("/cdstoolchain$", getwd())) setwd("../..")
  if (grepl("/R-cdstoolchain$", getwd())) setwd("../")
}

readSnapshotPseudonymizationArguments <- function(defaults) {
  etlutils::initCommandLineArguments(
    defaults = utils::modifyList(
      list(
        path_to_db_config_toml = "./cds_hub_db_config.toml",
        path_to_dataprocessor_config_toml = "./R-dataprocessor/dataprocessor_config.toml",
        project_root = ".",
        source_schema = "db2dataprocessor_out",
        review_report_file = NA_character_
      ),
      defaults
    )
  )
}

stopOnMissingSnapshotPseudonymizationArguments <- function(command_arguments, required_arguments, example) {
  missing_arguments <- required_arguments[
    !required_arguments %in% names(command_arguments) |
      !nzchar(as.character(command_arguments[required_arguments]))
  ]
  if (length(missing_arguments) > 0) {
    stop(
      "Missing required argument(s): ",
      paste(missing_arguments, collapse = ", "),
      "\nExample: ", example
    )
  }
}

initSnapshotPseudonymizationModule <- function(
  module_name,
  command_arguments,
  defaults = list(INPUT_REPO_PATH = "./Input-Repo"),
  mandatory_parameters = c("INPUT_REPO_PATH", "PATH_TO_DB_CONFIG_TOML")
) {
  module_config <- etlutils::initModule(
    module_name,
    db_schema_base_name = "dataprocessor",
    path_to_toml = command_arguments[["path_to_dataprocessor_config_toml"]],
    defaults = utils::modifyList(
      list(
        VERBOSE = 10,
        MAX_DIR_COUNT = 5,
        PATH_TO_DB_CONFIG_TOML = command_arguments[["path_to_db_config_toml"]]
      ),
      defaults
    ),
    mandatory_parameters = mandatory_parameters
  )
  etlutils::startModule(module_config, hide_value_pattern = "TOKEN|PASSWORD|SALT")
  module_config
}

readSnapshotPseudonymizationDbConfig <- function(command_arguments) {
  etlutils::readTomlAsNamedList(command_arguments[["path_to_db_config_toml"]])
}

snapshotPseudonymizationConfigValue <- function(command_arguments, db_config, name, default = NULL) {
  if (name %in% names(command_arguments) && nzchar(as.character(command_arguments[[name]]))) {
    return(command_arguments[[name]])
  }
  config_name <- toupper(name)
  if (config_name %in% names(db_config)) {
    return(db_config[[config_name]])
  }
  default
}

connectSnapshotPseudonymizationDatabase <- function(
  command_arguments,
  db_config,
  dbname,
  user_argument,
  password_argument
) {
  configValue <- function(name, default = NULL) {
    snapshotPseudonymizationConfigValue(command_arguments, db_config, name, default)
  }
  etlutils::dbCreateConnection(
    dbname = dbname,
    host = configValue("db_host", "cds_hub"),
    port = configValue("db_port", 5432),
    user = configValue(user_argument, configValue("db_dataprocessor_user")),
    password = configValue(password_argument, configValue("db_dataprocessor_password"))
  )
}
