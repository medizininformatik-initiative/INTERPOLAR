library(DBI)
library(RPostgres)
library(etlutils)

invisible(etlutils::setProcess("BroadConsentSnapshot"))

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
    chunk_size = NULL,
    report_file = NA_character_
  )
)

required_arguments <- c("source_db", "target_db")
missing_arguments <- required_arguments[
  !required_arguments %in% names(command_arguments) |
    !nzchar(as.character(command_arguments[required_arguments]))
]
if (length(missing_arguments) > 0L) {
  stop(
    "Missing required argument(s): ",
    paste(missing_arguments, collapse = ", "),
    "\nExample: Rscript R-cdstoolchain/StartBroadConsentSnapshot.R ",
    "source-db=ip_snap01_20260812_pseud ",
    "target-db=ip_snap01_20260812_pseud_broad_consent_build"
  )
}

dataprocessor_config <- etlutils::initModule(
  "broad_consent_snapshot",
  db_schema_base_name = "dataprocessor",
  path_to_toml = command_arguments[["path_to_dataprocessor_config_toml"]],
  defaults = list(
    VERBOSE = 10,
    MAX_DIR_COUNT = 5,
    PATH_TO_DB_CONFIG_TOML = command_arguments[["path_to_db_config_toml"]]
  ),
  mandatory_parameters = "PATH_TO_DB_CONFIG_TOML"
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
invisible(tryCatch(
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

    broad_consent_result <- pseudonym::createBroadConsentSnapshotDatabase(
      source_connection = source_connection,
      target_connection = target_connection,
      project_root = command_arguments[["project_root"]],
      source_schema = command_arguments[["source_schema"]],
      target_table_schema = command_arguments[["target_table_schema"]],
      target_view_schema = command_arguments[["target_view_schema"]],
      chunk_size = command_arguments[["chunk_size"]],
      report_file = command_arguments[["report_file"]],
      log_steps = TRUE
    )
    invisible(broad_consent_result)
  },
  error = function(error) {
    status <<- 1L
    if (!etlutils::isErrorOccured()) {
      etlutils::catErrorMessage(conditionMessage(error))
    }
  },
  finally = {
    if (!is.null(source_connection) && DBI::dbIsValid(source_connection)) {
      DBI::dbDisconnect(source_connection)
    }
    if (!is.null(target_connection) && DBI::dbIsValid(target_connection)) {
      DBI::dbDisconnect(target_connection)
    }
  }
))

if (!interactive()) {
  quit(status = status, save = "no")
}
