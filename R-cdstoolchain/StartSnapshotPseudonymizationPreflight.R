library(etlutils)
library(pseudonym)

etlutils::setProcess("SnapshotPseudonymizationPreflight")

# Change the working directory to the main project directory.
if (grepl("/cdstoolchain$", getwd())) setwd("../..")
if (grepl("/R-cdstoolchain$", getwd())) setwd("../")

command_arguments <- etlutils::initCommandLineArguments(
  defaults = list(
    path_to_db_config_toml = "./cds_hub_db_config.toml",
    path_to_dataprocessor_config_toml = "./R-dataprocessor/dataprocessor_config.toml",
    project_root = ".",
    review_report_file = paste0(
      "./outputLocal/snapshot_pseudonymization_preflight/reports/",
      "pseudonymization_rule_review.xlsx"
    )
  )
)

dataprocessor_config <- etlutils::initModule(
  "snapshot_pseudonymization_preflight",
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

status <- 0L
tryCatch(
  {
    rule_sources <- pseudonym::getDefaultSnapshotPseudonymizationRuleSources(
      project_root = command_arguments[["project_root"]]
    )
    pseudonym::pseudonymizeSnapshotTables(
      tables = list(preflight_placeholder = data.frame()),
      table_descriptions = rule_sources[["table_descriptions"]],
      snapshot_extensions = rule_sources[["snapshot_extensions"]],
      input_repo_path = dataprocessor_config[["INPUT_REPO_PATH"]],
      fail_on_review_problems = TRUE,
      write_review_report = TRUE,
      review_report_file = command_arguments[["review_report_file"]],
      keep_unmatched_columns = TRUE,
      log_steps = FALSE
    )
  },
  error = function(error) {
    status <<- 1L
    etlutils::catErrorMessage(conditionMessage(error))
  }
)

quit(save = "no", status = status)
