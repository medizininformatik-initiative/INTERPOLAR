pseudonymizationReviewHasBlockingProblems <- function(review_report) {
  nrow(review_report[["todo_rules"]]) > 0 ||
    nrow(review_report[["unsupported_rules"]]) > 0 ||
    nrow(review_report[["duplicate_columns"]]) > 0 ||
    any(isPseudonymMappingStatusProblem(review_report[["mapping_rules"]][["MAPPING_STATUS"]]))
}

summarizePseudonymizationReviewProblems <- function(review_report) {
  c(
    paste0("TODO rules: ", nrow(review_report[["todo_rules"]])),
    paste0("Unsupported rules: ", nrow(review_report[["unsupported_rules"]])),
    paste0("Duplicate columns: ", nrow(review_report[["duplicate_columns"]])),
    paste0(
      "Mapping problems: ",
      sum(isPseudonymMappingStatusProblem(review_report[["mapping_rules"]][["MAPPING_STATUS"]]))
    )
  )
}

summarizePseudonymizationMappingProblemDetails <- function(review_report, detail_limit = 10L) {
  mapping_rules <- review_report[["mapping_rules"]]
  problem_rows <- isPseudonymMappingStatusProblem(mapping_rules[["MAPPING_STATUS"]])
  mapping_problems <- mapping_rules[which(problem_rows), ]
  if (nrow(mapping_problems) == 0) {
    return(character())
  }

  details <- data.table::data.table(
    SHEET_NAME = ifelse(
      is.na(mapping_problems[["SHEET_NAME"]]) |
        !nzchar(mapping_problems[["SHEET_NAME"]]),
      "<not specified>",
      mapping_problems[["SHEET_NAME"]]
    ),
    MAPPING_STATUS = ifelse(
      is.na(mapping_problems[["MAPPING_STATUS"]]) |
        !nzchar(mapping_problems[["MAPPING_STATUS"]]),
      "<not specified>",
      mapping_problems[["MAPPING_STATUS"]]
    ),
    ERROR = ifelse(
      is.na(mapping_problems[["ERROR"]]) |
        !nzchar(mapping_problems[["ERROR"]]),
      "<no error detail>",
      gsub("[\r\n]+", " ", mapping_problems[["ERROR"]])
    )
  )
  group_columns <- c("SHEET_NAME", "MAPPING_STATUS", "ERROR")
  data.table::setorderv(details, group_columns)
  group_ids <- data.table::rleidv(details, group_columns)
  first_group_rows <- !duplicated(group_ids)
  details <- data.table::data.table(
    SHEET_NAME = details[["SHEET_NAME"]][first_group_rows],
    MAPPING_STATUS = details[["MAPPING_STATUS"]][first_group_rows],
    ERROR = details[["ERROR"]][first_group_rows],
    AFFECTED_RULE_N = tabulate(group_ids)
  )

  detail_limit <- min(as.integer(detail_limit), nrow(details))
  result <- c(
    "Mapping problem details:",
    vapply(seq_len(detail_limit), function(i) {
      paste0(
        "- sheet \"", details[["SHEET_NAME"]][i], "\": ",
        details[["MAPPING_STATUS"]][i],
        " (", details[["AFFECTED_RULE_N"]][i], " affected rule(s)): ",
        details[["ERROR"]][i]
      )
    }, character(1))
  )
  omitted_detail_n <- nrow(details) - detail_limit
  if (omitted_detail_n > 0) {
    result <- c(
      result,
      paste0(
        "- ", omitted_detail_n,
        " additional distinct mapping problem(s); see the review report."
      )
    )
  }
  result
}

pseudonymizationMappingProblemAction <- function(review_report) {
  mapping_rules <- review_report[["mapping_rules"]]
  problem_rows <- isPseudonymMappingStatusProblem(mapping_rules[["MAPPING_STATUS"]])
  mapping_problems <- mapping_rules[which(problem_rows), ]
  if (nrow(mapping_problems) == 0) {
    return(character())
  }

  result <- c(
    "Required action for mapping problems:",
    paste0(
      "- The mapping workbook is generated as pseudo_mapping.xlsx in the ",
      "INPUT_REPO_PATH configured in R-dataprocessor/dataprocessor_config.toml."
    ),
    paste0(
      "- Fill every referenced sheet with KEY and PSEUDONYM values. ",
      "Neither column may contain empty values or duplicate KEY values."
    )
  )
  if ("frontend_users" %in% mapping_problems[["SHEET_NAME"]]) {
    result <- c(
      result,
      paste0(
        "- In sheet \"frontend_users\", replace the example rows: KEY must contain ",
        "the original frontend user names and PSEUDONYM their desired replacements."
      )
    )
  }
  c(result, "- Correct the reported problem and restart the snapshot pseudonymization.")
}

pseudonymizationReviewReportHint <- function(write_review_report, review_report_file) {
  if (!isTRUE(write_review_report)) {
    return("Detailed pseudonymization rule review report was not written.")
  }
  report_file <- if (
    length(review_report_file) == 1 &&
      !is.na(review_report_file) &&
      nzchar(as.character(review_report_file))
  ) {
    as.character(review_report_file)
  } else {
    "outputLocal/snapshot_pseudonymization*/reports/pseudonymization_rule_review.xlsx"
  }
  paste0(
    "Full details: ", report_file,
    " (relevant sheets: todo_rules, unsupported_rules, duplicate_columns, mapping_rules)."
  )
}

getPseudonymizationReviewErrorMessage <- function(
  review_report,
  write_review_report,
  review_report_file
) {
  paste(
    c(
      "Pseudonymization rule review contains blocking problems:",
      summarizePseudonymizationReviewProblems(review_report),
      summarizePseudonymizationMappingProblemDetails(review_report),
      pseudonymizationMappingProblemAction(review_report),
      pseudonymizationReviewReportHint(write_review_report, review_report_file)
    ),
    collapse = "\n"
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
#' @param input_repo_path TOML-configured input repository directory used for
#'   `pseudonym(sheet = ...)` mapping rules.
#' @param validate_mapping_files If `FALSE`, defer mapping workbook validation
#'   until a snapshot database is available.
#' @param fail_on_review_problems If `TRUE`, abort when the review report
#'   contains TODO rules, unsupported rules, duplicate columns, or mapping
#'   validation problems.
#' @param write_review_report If `TRUE`, write the review workbook.
#' @param review_report_file Optional explicit report path. If `NA`, the report
#'   is written to `outputLocal/<MODULE>/reports`.
#' @param keep_unmatched_columns Passed to `pseudonymizeTables()`. The default
#'   keeps original source columns without a loaded rule unchanged.
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
  input_repo_path = NULL,
  validate_mapping_files = TRUE,
  fail_on_review_problems = TRUE,
  write_review_report = TRUE,
  review_report_file = NA,
  keep_unmatched_columns = TRUE,
  log_steps = TRUE) {
  result <- list()

  runPseudonymizationLogStep(2L,
    "Load pseudonymization rules",
    {
      if (is.null(rules)) {
        result[["rules"]] <- loadPseudonymizationRules(
          table_descriptions = table_descriptions,
          snapshot_extensions = snapshot_extensions
        )
      } else {
        result[["rules"]] <- data.table::as.data.table(data.table::copy(rules))
      }
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Review pseudonymization rules",
    {
      result[["review_report"]] <- getPseudonymizationRuleReviewReport(
        result[["rules"]],
        input_repo_path = input_repo_path,
        validate_mapping_files = validate_mapping_files
      )
      if (isTRUE(write_review_report)) {
        writePseudonymizationRuleReviewReport(
          result[["rules"]],
          file_name = review_report_file,
          input_repo_path = input_repo_path,
          validate_mapping_files = validate_mapping_files
        )
      }
      if (
        isTRUE(fail_on_review_problems) &&
        pseudonymizationReviewHasBlockingProblems(result[["review_report"]])
      ) {
        stop(
          getPseudonymizationReviewErrorMessage(
            result[["review_report"]],
            write_review_report,
            review_report_file
          )
        )
      }
    },
    log_steps = log_steps
  )

  table_result <- pseudonymizeTables(
    tables = tables,
    rules = result[["rules"]],
    input_repo_path = input_repo_path,
    keep_unmatched_columns = keep_unmatched_columns,
    log_steps = log_steps
  )
  result[["tables"]] <- table_result[["tables"]]
  result[["summary"]] <- table_result[["summary"]]

  result
}
