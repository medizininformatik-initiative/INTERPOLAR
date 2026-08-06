pseudonymizationReviewHasBlockingProblems <- function(review_report) {
  nrow(review_report[["empty_rules"]]) > 0 ||
    nrow(review_report[["todo_rules"]]) > 0 ||
    nrow(review_report[["unsupported_rules"]]) > 0 ||
    nrow(review_report[["duplicate_columns"]]) > 0 ||
    any(isPseudonymMappingStatusProblem(review_report[["mapping_rules"]][["MAPPING_STATUS"]]))
}

summarizePseudonymizationReviewProblems <- function(review_report) {
  c(
    paste0("Empty rules: ", nrow(review_report[["empty_rules"]])),
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
        "- In sheet \"frontend_users\", KEY contains the original frontend user names; ",
        "enter their desired replacements in PSEUDONYM."
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
    " (relevant sheets: empty_rules, todo_rules, unsupported_rules, ",
    "duplicate_columns, mapping_rules)."
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

reviewPseudonymizationRules <- function(
  rules,
  input_repo_path,
  validate_mapping_files,
  fail_on_review_problems,
  write_review_report,
  review_report_file
) {
  review_report <- getPseudonymizationRuleReviewReport(
    rules,
    input_repo_path = input_repo_path,
    validate_mapping_files = validate_mapping_files
  )
  if (isTRUE(write_review_report)) {
    writePseudonymizationRuleReviewReport(
      rules,
      file_name = review_report_file,
      input_repo_path = input_repo_path,
      validate_mapping_files = validate_mapping_files
    )
  }
  if (
    isTRUE(fail_on_review_problems) &&
    pseudonymizationReviewHasBlockingProblems(review_report)
  ) {
    stop(
      getPseudonymizationReviewErrorMessage(
        review_report,
        write_review_report,
        review_report_file
      )
    )
  }
  review_report
}

#' Check Snapshot Pseudonymization Prerequisites
#'
#' Loads the default snapshot pseudonymization rules, writes their review report,
#' and aborts on blocking rule problems. If a source database connection is
#' supplied, the function also updates and validates the data-dependent mapping
#' coverage before a pseudonymized target database is created.
#'
#' @param project_root Repository root used to resolve rule sources.
#' @param input_repo_path TOML-configured input repository directory.
#' @param source_connection Optional open DBI connection to the restored source
#'   database.
#' @param source_schema Optional schema containing source views.
#' @param source_view_prefix Prefix used for source view names.
#' @param last_version_suffix Suffix used for last-version source views.
#' @param tables Optional character vector limiting tables to inspect.
#' @param review_report_file Optional explicit report path. If `NA`, the report
#'   is written to `outputLocal/<MODULE>/reports`.
#' @param log_steps If `TRUE` and module logging is initialized, wrap the
#'   process in the existing `etlutils::runLevel...` logging.
#'
#' @return A list containing the loaded `rules` and their `review_report`.
#' @export
preflightSnapshotPseudonymization <- function(
  project_root = ".",
  input_repo_path = NULL,
  source_connection = NULL,
  source_schema = NULL,
  source_view_prefix = "v_",
  last_version_suffix = "_last_version",
  tables = NULL,
  review_report_file = NA,
  log_steps = TRUE
) {
  rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root)
  result <- list()

  runPseudonymizationLogStep(2L,
    "Load pseudonymization rules",
    {
      result[["rules"]] <- loadPseudonymizationRules(
        table_descriptions = rule_sources[["table_descriptions"]],
        snapshot_extensions = rule_sources[["snapshot_extensions"]]
      )
    },
    log_steps = log_steps
  )
  runPseudonymizationLogStep(2L,
    "Review pseudonymization rules",
    {
      mapping_file <- if (
        !is.null(input_repo_path) && length(input_repo_path) == 1L &&
          !is.na(input_repo_path) && nzchar(input_repo_path)
      ) {
        getPseudonymMappingFilePath(input_repo_path)
      } else {
        NA_character_
      }
      result[["review_report"]] <- reviewPseudonymizationRules(
        result[["rules"]],
        input_repo_path = input_repo_path,
        validate_mapping_files = !is.na(mapping_file) && file.exists(mapping_file),
        fail_on_review_problems = TRUE,
        write_review_report = TRUE,
        review_report_file = review_report_file
      )
    },
    log_steps = log_steps
  )

  if (!is.null(source_connection)) {
    runPseudonymizationLogStep(2L,
      "Plan snapshot source relations",
      {
        result[["materialization_plan"]] <- getExistingSnapshotMaterializationPlan(
          source_connection,
          rules = result[["rules"]],
          source_schema = source_schema,
          source_view_prefix = source_view_prefix,
          last_version_suffix = last_version_suffix,
          tables = tables
        )
      },
      log_steps = log_steps
    )
    runPseudonymizationLogStep(2L,
      "Prepare and validate pseudonym mapping workbook",
      {
        result[["mapping_coverage"]] <- ensurePseudonymMappingCoverage(
          connection = source_connection,
          rules = result[["rules"]],
          materialization_plan = result[["materialization_plan"]],
          input_repo_path = input_repo_path,
          source_schema = source_schema
        )
      },
      log_steps = log_steps
    )
    runPseudonymizationLogStep(2L,
      "Validate pseudonym mapping workbook",
      {
        result[["review_report"]] <- reviewPseudonymizationRules(
          result[["rules"]],
          input_repo_path = input_repo_path,
          validate_mapping_files = TRUE,
          fail_on_review_problems = TRUE,
          write_review_report = TRUE,
          review_report_file = review_report_file
        )
      },
      log_steps = log_steps
    )
  }

  result
}
