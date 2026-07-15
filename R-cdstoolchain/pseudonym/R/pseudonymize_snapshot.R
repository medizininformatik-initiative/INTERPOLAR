pseudonymizationReviewHasBlockingProblems <- function(review_report) {
  nrow(review_report[["todo_rules"]]) > 0 ||
    nrow(review_report[["unsupported_rules"]]) > 0 ||
    nrow(review_report[["duplicate_columns"]]) > 0 ||
    any(review_report[["mapping_rules"]][["MAPPING_STATUS"]] != "ok", na.rm = TRUE)
}

summarizePseudonymizationReviewProblems <- function(review_report) {
  c(
    paste0("TODO rules: ", nrow(review_report[["todo_rules"]])),
    paste0("Unsupported rules: ", nrow(review_report[["unsupported_rules"]])),
    paste0("Duplicate columns: ", nrow(review_report[["duplicate_columns"]])),
    paste0(
      "Mapping problems: ",
      sum(review_report[["mapping_rules"]][["MAPPING_STATUS"]] != "ok", na.rm = TRUE)
    )
  )
}

#' Pseudonymize Snapshot Tables from Rule Source Specifications
#'
#' This function is the DB-neutral orchestration core for snapshot
#' pseudonymization. It loads all rule sources, creates a review report, can
#' write that report to `outputLocal/<MODULE>/reports`, optionally aborts on
#' blocking review problems, and pseudonymizes the provided tables.
#'
#' @param tables Named list of source tables.
#' @param table_descriptions Character vector or data.frame/data.table with
#'   normal table-description files.
#' @param snapshot_extensions Optional character vector or data.frame/data.table
#'   with snapshot-extension files.
#' @param rules Optional preloaded rules. If supplied, `table_descriptions` and
#'   `snapshot_extensions` are not loaded again.
#' @param salt Salt used for `cryptoHash` and `pseudonymize(...)` rules.
#' @param input_repo_path TOML-configured input repository directory used for
#'   `pseudonym(sheet = ...)` mapping rules.
#' @param fail_on_review_problems If `TRUE`, abort when the review report
#'   contains TODO rules, unsupported rules, duplicate columns, or mapping
#'   validation problems.
#' @param write_review_report If `TRUE`, write the review workbook.
#' @param review_report_file Optional explicit report path. If `NA`, the report
#'   is written to `outputLocal/<MODULE>/reports`.
#' @param keep_unmatched_columns Passed to `pseudonymizeTables()`.
#' @param log_steps If `TRUE` and module logging is initialized, wrap the
#'   process in the existing `etlutils::runLevel...` logging.
#'
#' @return A list with `tables`, `summary`, `rules`, and `review_report`.
#' @export
pseudonymizeSnapshotTables <- function(
    tables,
    table_descriptions,
    snapshot_extensions = NULL,
    rules = NULL,
    salt = NULL,
    input_repo_path = NULL,
    fail_on_review_problems = TRUE,
    write_review_report = TRUE,
    review_report_file = NA,
    keep_unmatched_columns = FALSE,
    log_steps = TRUE) {
  result <- list()

  runPseudonymizationLogStep(2L, "Load pseudonymization rules", {
    if (is.null(rules)) {
      result[["rules"]] <- loadPseudonymizationRules(
        table_descriptions = table_descriptions,
        snapshot_extensions = snapshot_extensions
      )
    } else {
      result[["rules"]] <- data.table::as.data.table(data.table::copy(rules))
    }
  }, log_steps = log_steps)

  runPseudonymizationLogStep(2L, "Review pseudonymization rules", {
    result[["review_report"]] <- getPseudonymizationRuleReviewReport(
      result[["rules"]],
      input_repo_path = input_repo_path
    )
    if (isTRUE(write_review_report)) {
      writePseudonymizationRuleReviewReport(
        result[["rules"]],
        file_name = review_report_file,
        input_repo_path = input_repo_path
      )
    }
    if (isTRUE(fail_on_review_problems) &&
        pseudonymizationReviewHasBlockingProblems(result[["review_report"]])) {
      stop(
        "Pseudonymization rule review contains blocking problems:\n",
        paste(summarizePseudonymizationReviewProblems(result[["review_report"]]), collapse = "\n")
      )
    }
  }, log_steps = log_steps)

  table_result <- pseudonymizeTables(
    tables = tables,
    rules = result[["rules"]],
    salt = salt,
    input_repo_path = input_repo_path,
    keep_unmatched_columns = keep_unmatched_columns,
    log_steps = log_steps
  )
  result[["tables"]] <- table_result[["tables"]]
  result[["summary"]] <- table_result[["summary"]]

  result
}
