library(DBI)
library(etlutils)

invisible(etlutils::setProcess("SnapshotPseudonymization"))

source_file <- if (file.exists("R-cdstoolchain/Snapshot_Pseudonymization_Cli.R")) {
  "R-cdstoolchain/Snapshot_Pseudonymization_Cli.R"
} else if (file.exists("../Snapshot_Pseudonymization_Cli.R")) {
  "../Snapshot_Pseudonymization_Cli.R"
} else {
  "Snapshot_Pseudonymization_Cli.R"
}
source(source_file, local = TRUE)

setSnapshotPseudonymizationWorkingDirectory()
command_arguments <- readSnapshotPseudonymizationArguments(
  defaults = list(
    target_table_schema = "db_log",
    target_view_schema = "db2dataprocessor_out",
    chunk_size = NULL
  )
)

stopOnMissingSnapshotPseudonymizationArguments(
  command_arguments,
  required_arguments = "source_db",
  example = paste0(
    "Rscript R-cdstoolchain/StartSnapshotPseudonymization.R ",
    "source-db=ip_snap01_20260716"
  )
)
run_preflight_only <- !(
  "target_db" %in% names(command_arguments) &&
    nzchar(as.character(command_arguments[["target_db"]]))
)

dataprocessor_config <- initSnapshotPseudonymizationModule(
  "snapshot_pseudonymization",
  command_arguments
)
db_config <- readSnapshotPseudonymizationDbConfig(command_arguments)

source_connection <- NULL
target_connection <- NULL
status <- 0L
invisible(tryCatch(
  {
    source_connection <- connectSnapshotPseudonymizationDatabase(
      command_arguments = command_arguments,
      db_config = db_config,
      dbname = command_arguments[["source_db"]],
      user_argument = "source_db_user",
      password_argument = "source_db_password"
    )

    if (run_preflight_only) {
      message("\nNo target-db provided. Running snapshot pseudonymization preflight only.")
      pseudonym::preflightSnapshotPseudonymization(
        project_root = command_arguments[["project_root"]],
        input_repo_path = dataprocessor_config[["INPUT_REPO_PATH"]],
        source_connection = source_connection,
        source_schema = command_arguments[["source_schema"]],
        review_report_file = command_arguments[["review_report_file"]],
        log_steps = TRUE
      )
    } else {
      target_connection <- connectSnapshotPseudonymizationDatabase(
        command_arguments = command_arguments,
        db_config = db_config,
        dbname = command_arguments[["target_db"]],
        user_argument = "target_db_user",
        password_argument = "target_db_password"
      )

      pseudonymization_result <- pseudonym::pseudonymizeSnapshotDatabase(
        source_connection = source_connection,
        target_connection = target_connection,
        project_root = command_arguments[["project_root"]],
        input_repo_path = dataprocessor_config[["INPUT_REPO_PATH"]],
        source_schema = command_arguments[["source_schema"]],
        target_table_schema = command_arguments[["target_table_schema"]],
        target_view_schema = command_arguments[["target_view_schema"]],
        chunk_size = command_arguments[["chunk_size"]],
        review_report_file = command_arguments[["review_report_file"]],
        log_steps = TRUE
      )
      report_dir <- file.path(get("MODULE_DIRS", envir = .GlobalEnv)[["local_dir"]], "reports")
      issue_report <- pseudonymization_result[["issue_report"]]
      medication_issue_summary <- issue_report[["medication_issue_summary"]]
      age_issue_summary <- issue_report[["age_issue_summary"]]
      loinc_unit_issues <- issue_report[["loinc_unit_conversion_issues"]]
      summary <- pseudonymization_result[["pseudonymization"]][["summary"]]
      issue_report_file <- file.path(report_dir, "snapshot_pseudonymization_issues.xlsx")
      etlutils::catInfoMessage(paste0(
        "INFO: Snapshot pseudonymization completed successfully: ",
        sum(summary[["INPUT_ROWS"]]), " input rows processed, ",
        sum(summary[["OUTPUT_ROWS"]]), " output rows written.\n",
        "INFO: Additional data enrichment: ",
        sum(loinc_unit_issues[["AFFECTED_ROWS"]], na.rm = TRUE),
        " lab values retained with source value and unit; ",
        sum(medication_issue_summary[["UNMATCHED_ROWS"]], na.rm = TRUE),
        " medication reference issues; ",
        sum(age_issue_summary[["AFFECTED_ROWS"]], na.rm = TRUE),
        " age values could not be calculated.\n",
        "INFO: Enrichment report: ", issue_report_file, "\n"
      ))
      invisible(pseudonymization_result)
    }
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

# Preserve errors caught outside runLevel while using the standard module finalization.
status <- max(status, etlutils::finalize())

if (!interactive()) {
  quit(status = status, save = "no")
}
