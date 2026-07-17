library(DBI)
library(RPostgres)
library(etlutils)
library(pseudonym)

etlutils::setProcess("SnapshotPseudonymization")

# Change the working directory to the main project directory.
if (grepl("/cdstoolchain$", getwd())) setwd("../..")
if (grepl("/R-cdstoolchain$", getwd())) setwd("../")

command_arguments <- etlutils::initCommandLineArguments(
  defaults = list(
    path_to_db_config_toml = "./cds_hub_db_config.toml",
    path_to_dataprocessor_config_toml = "./R-dataprocessor/dataprocessor_config.toml",
    project_root = ".",
    source_schema = "db2dataprocessor_out",
    target_table_schema = "db_log",
    target_view_schema = "db2dataprocessor_out",
    review_report_file = NA_character_
  )
)

required_arguments <- c("source_db", "target_db")
missing_arguments <- required_arguments[
  !required_arguments %in% names(command_arguments) |
    !nzchar(as.character(command_arguments[required_arguments]))
]
if (length(missing_arguments) > 0) {
  stop(
    "Missing required argument(s): ",
    paste(missing_arguments, collapse = ", "),
    "\nExample: Rscript R-cdstoolchain/StartSnapshotPseudonymization.R ",
    "source-db=ip_snap01_20260716 target-db=ip_snap01_20260716_pseud"
  )
}

dataprocessor_config <- etlutils::initModule(
  "snapshot_pseudonymization",
  db_schema_base_name = "dataprocessor",
  path_to_toml = command_arguments[["path_to_dataprocessor_config_toml"]],
  defaults = list(
    VERBOSE = 10,
    MAX_DIR_COUNT = 5,
    PATH_TO_DB_CONFIG_TOML = command_arguments[["path_to_db_config_toml"]],
    INPUT_REPO_PATH = "./Input-Repo"
  ),
  mandatory_parameters = c("INPUT_REPO_PATH", "PATH_TO_DB_CONFIG_TOML")
)
etlutils::startModule(dataprocessor_config, hide_value_pattern = "TOKEN|PASSWORD|SALT")

db_config <- etlutils::readTomlAsNamedList(command_arguments[["path_to_db_config_toml"]])

dbConfigValue <- function(name, default = NULL) {
  if (name %in% names(command_arguments) && nzchar(as.character(command_arguments[[name]]))) {
    return(command_arguments[[name]])
  }
  config_name <- toupper(name)
  if (config_name %in% names(db_config)) {
    return(db_config[[config_name]])
  }
  default
}

connectSnapshotDatabase <- function(dbname, user, password) {
  DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = dbname,
    host = dbConfigValue("db_host", "cds_hub"),
    port = dbConfigValue("db_port", 5432),
    user = user,
    password = password,
    timezone = "Europe/Berlin"
  )
}

source_connection <- NULL
target_connection <- NULL
status <- 0L
tryCatch(
  {
    source_connection <- connectSnapshotDatabase(
      dbname = command_arguments[["source_db"]],
      user = dbConfigValue("source_db_user", dbConfigValue("db_dataprocessor_user")),
      password = dbConfigValue("source_db_password", dbConfigValue("db_dataprocessor_password"))
    )
    target_connection <- connectSnapshotDatabase(
      dbname = command_arguments[["target_db"]],
      user = dbConfigValue("target_db_user", dbConfigValue("db_dataprocessor_user")),
      password = dbConfigValue("target_db_password", dbConfigValue("db_dataprocessor_password"))
    )

    pseudonymization_result <- pseudonym::pseudonymizeSnapshotDatabase(
      source_connection = source_connection,
      target_connection = target_connection,
      project_root = command_arguments[["project_root"]],
      input_repo_path = dataprocessor_config[["INPUT_REPO_PATH"]],
      source_schema = command_arguments[["source_schema"]],
      target_table_schema = command_arguments[["target_table_schema"]],
      target_view_schema = command_arguments[["target_view_schema"]],
      fail_on_review_problems = TRUE,
      write_review_report = TRUE,
      review_report_file = command_arguments[["review_report_file"]],
      keep_unmatched_columns = FALSE,
      enrich_tables = function(tables) {
        pseudonym::enrichSnapshotMedicationReferenceTables(tables)
      },
      overwrite_tables = FALSE,
      replace_views = FALSE,
      log_steps = TRUE
    )
    invisible(pseudonymization_result)
  },
  error = function(error) {
    status <<- 1L
    etlutils::catErrorMessage(conditionMessage(error))
  },
  finally = {
    if (!is.null(source_connection) && DBI::dbIsValid(source_connection)) {
      DBI::dbDisconnect(source_connection)
    }
    if (!is.null(target_connection) && DBI::dbIsValid(target_connection)) {
      DBI::dbDisconnect(target_connection)
    }
  }
)

if (!interactive()) {
  quit(status = status, save = "no")
}
