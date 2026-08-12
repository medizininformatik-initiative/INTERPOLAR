test_that("preflight checks rules without running database pseudonymization", {
  captured <- new.env(parent = emptyenv())
  rules <- data.table::data.table(COLUMN_NAME = "id")
  review_report <- list(summary = data.table::data.table(N = 1L))
  mockDefaultSources <- function(project_root) {
    captured$project_root <- project_root
    list(
      table_descriptions = "table-description",
      snapshot_extensions = "snapshot-extension"
    )
  }
  mockLoadRules <- function(table_descriptions, snapshot_extensions) {
    captured$table_descriptions <- table_descriptions
    captured$snapshot_extensions <- snapshot_extensions
    rules
  }
  mockReviewRules <- function(
    rules,
    input_repo_path,
    validate_mapping_files,
    fail_on_review_problems,
    write_review_report,
    review_report_file
  ) {
    captured$review_arguments <- list(
      rules = rules,
      input_repo_path = input_repo_path,
      validate_mapping_files = validate_mapping_files,
      fail_on_review_problems = fail_on_review_problems,
      write_review_report = write_review_report,
      review_report_file = review_report_file
    )
    review_report
  }

  testthat::local_mocked_bindings(
    getDefaultSnapshotPseudonymizationRuleSources = mockDefaultSources,
    loadPseudonymizationRules = mockLoadRules,
    reviewPseudonymizationRules = mockReviewRules,
    .package = "pseudonym"
  )

  result <- preflightSnapshotPseudonymization(
    project_root = "/project",
    input_repo_path = "/input",
    review_report_file = "/reports/review.xlsx",
    log_steps = FALSE
  )

  expect_equal(captured$project_root, "/project")
  expect_equal(captured$table_descriptions, "table-description")
  expect_equal(captured$snapshot_extensions, "snapshot-extension")
  expect_false(captured$review_arguments$validate_mapping_files)
  expect_true(captured$review_arguments$fail_on_review_problems)
  expect_true(captured$review_arguments$write_review_report)
  expect_equal(captured$review_arguments$review_report_file, "/reports/review.xlsx")
  expect_equal(result$rules, rules)
  expect_equal(result$review_report, review_report)
  expect_false("tables" %in% names(result))
})

test_that("preflight validates existing mappings and database coverage before a target exists", {
  captured <- new.env(parent = emptyenv())
  captured$review_calls <- list()
  rules <- data.table::data.table(COLUMN_NAME = "user")
  plan <- data.table::data.table(SOURCE_RELATION = "v_users")
  coverage <- data.table::data.table(SHEET_NAME = "users", STATUS = "complete")
  input_repo_path <- tempfile("snapshot-preflight-")
  dir.create(input_repo_path)
  file.create(file.path(input_repo_path, "pseudo_mapping.xlsx"))

  mockReviewRules <- function(
    rules,
    input_repo_path,
    validate_mapping_files,
    fail_on_review_problems,
    write_review_report,
    review_report_file
  ) {
    captured$review_calls[[length(captured$review_calls) + 1L]] <- list(
      validate_mapping_files = validate_mapping_files,
      input_repo_path = input_repo_path
    )
    list(summary = data.table::data.table(N = 1L))
  }
  mockPlan <- function(
    connection,
    rules,
    source_schema,
    source_view_prefix,
    last_version_suffix,
    tables
  ) {
    captured$plan_connection <- connection
    plan
  }
  mockCoverage <- function(
    connection,
    rules,
    materialization_plan,
    input_repo_path,
    source_schema
  ) {
    captured$coverage_connection <- connection
    captured$coverage_plan <- materialization_plan
    coverage
  }

  testthat::local_mocked_bindings(
    getDefaultSnapshotPseudonymizationRuleSources = function(project_root) {
      list(table_descriptions = "table-description", snapshot_extensions = "snapshot-extension")
    },
    loadPseudonymizationRules = function(table_descriptions, snapshot_extensions) rules,
    reviewPseudonymizationRules = mockReviewRules,
    getExistingSnapshotMaterializationPlan = mockPlan,
    ensurePseudonymMappingCoverage = mockCoverage,
    .package = "pseudonym"
  )

  result <- preflightSnapshotPseudonymization(
    input_repo_path = input_repo_path,
    source_connection = "source-connection",
    source_schema = "source-schema",
    log_steps = FALSE
  )

  expect_length(captured$review_calls, 2L)
  expect_true(all(vapply(
    captured$review_calls,
    function(call) call$validate_mapping_files,
    logical(1)
  )))
  expect_equal(captured$plan_connection, "source-connection")
  expect_equal(captured$coverage_connection, "source-connection")
  expect_equal(captured$coverage_plan, plan)
  expect_equal(result$mapping_coverage, coverage)
})

test_that("pseudonym exports only external workflow entry points", {
  expect_setequal(
    getNamespaceExports("pseudonym"),
    c(
      "createBroadConsentSnapshotDatabase",
      "preflightSnapshotPseudonymization",
      "pseudonymizeSnapshotDatabase",
      "setFhirPseudonymizationRules"
    )
  )
})

test_that("blocking mapping review error reports deduplicated details and workbook path", {
  rule_n <- 8L
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Frontend_Table_Description.xlsx",
    SOURCE_SHEET = "frontend_table_description",
    TABLE_NAME = "frontend",
    RESOURCE = NA_character_,
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = paste0("user_column_", seq_len(rule_n)),
    COLUMN_DESCRIPTION = "Frontend user",
    COLUMN_TYPE = "varchar",
    FHIR_EXPRESSION = NA_character_,
    PSEUDONYMIZATION_RULE_RAW = 'pseudonym(sheet = "frontend_users")',
    PSEUDONYMIZATION_RULE = 'pseudonym(sheet = "frontend_users")',
    EMPTY_RULE = FALSE
  )
  report_file <- tempfile(fileext = ".xlsx")

  error <- tryCatch(
    reviewPseudonymizationRules(
      rules,
      input_repo_path = NULL,
      validate_mapping_files = TRUE,
      fail_on_review_problems = TRUE,
      write_review_report = TRUE,
      review_report_file = report_file
    ),
    error = identity
  )
  message <- conditionMessage(error)

  expect_s3_class(error, "error")
  expect_true(file.exists(report_file))
  expect_match(message, 'sheet "frontend_users"', fixed = TRUE)
  expect_match(message, "missing_input_repo_path", fixed = TRUE)
  expect_match(message, "8 affected rule(s)", fixed = TRUE)
  expect_match(message, "mapping workbook is generated", fixed = TRUE)
  expect_match(message, "original frontend user names", fixed = TRUE)
  expect_match(message, report_file, fixed = TRUE)
})

test_that("incomplete mapping error only reports the required user action", {
  input_repo_path <- tempfile("incomplete-mapping-")
  dir.create(input_repo_path)
  mapping_file <- file.path(input_repo_path, "pseudo_mapping.xlsx")
  etlutils::writeExcelFile(
    list(frontend_users = data.table::data.table(KEY = "site_admin", PSEUDONYM = NA_character_)),
    mapping_file,
    with_column_names = TRUE
  )
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Frontend_Table_Description.xlsx",
    SOURCE_SHEET = "frontend_table_description",
    TABLE_NAME = "frontend",
    RESOURCE = NA_character_,
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = "meda_anlage",
    COLUMN_DESCRIPTION = "Frontend user",
    COLUMN_TYPE = "varchar",
    FHIR_EXPRESSION = NA_character_,
    PSEUDONYMIZATION_RULE_RAW = 'pseudonym(sheet = "frontend_users")',
    PSEUDONYMIZATION_RULE = 'pseudonym(sheet = "frontend_users")',
    EMPTY_RULE = FALSE
  )

  error <- tryCatch(
    reviewPseudonymizationRules(
      rules,
      input_repo_path = input_repo_path,
      validate_mapping_files = TRUE,
      fail_on_review_problems = TRUE,
      write_review_report = FALSE,
      review_report_file = NA_character_
    ),
    error = identity
  )
  message <- conditionMessage(error)

  expect_match(message, "Pseudonymisierungsmapping muss ausgefüllt werden", fixed = TRUE)
  expect_match(message, mapping_file, fixed = TRUE)
  expect_match(message, '"frontend_users"', fixed = TRUE)
  expect_match(message, "Spalte PSEUDONYM", fixed = TRUE)
  expect_false(grepl("Empty rules", message, fixed = TRUE))
  expect_false(grepl("TODO rules", message, fixed = TRUE))
  expect_false(grepl("Mapping problems", message, fixed = TRUE))
  expect_false(grepl("Full details", message, fixed = TRUE))
})
