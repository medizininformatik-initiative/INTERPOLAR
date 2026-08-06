writeRuleInputTestWorkbook <- function(table, sheet_name) {
  file <- tempfile(fileext = ".xlsx")
  table_with_header <- etlutils::addTextHeaderToTable(
    table,
    header = c("Hint", "test table description"),
    insert_column_names_below_header = TRUE
  )
  etlutils::writeExcelFile(
    stats::setNames(list(table_with_header), sheet_name),
    file,
    with_column_names = FALSE
  )
  file
}

findRepositoryRootForPseudonymTests <- function() {
  path <- normalizePath(getwd(), mustWork = TRUE)
  marker <- file.path(DEFAULT_FHIR_TABLE_DESCRIPTION_PATH)

  repeat {
    if (file.exists(file.path(path, marker))) {
      return(path)
    }
    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Could not find INTERPOLAR repository root for pseudonym tests.")
    }
    path <- parent
  }
}

test_that("loadPseudonymizationRules loads table descriptions and snapshot extensions", {
  table_description_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = c("observation", NA_character_),
      COLUMN_NAME = c("obs_id", "obs_value"),
      COLUMN_DESCRIPTION = c("Observation id", "Observation value"),
      COLUMN_TYPE = c("varchar", "double precision"),
      PSEUDONYMIZATION_RULE = c("cryptoHash", "keep")
    ),
    "table_description"
  )
  extension_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "medicationrequest",
      COLUMN_NAME = "medreq_medication_code",
      COLUMN_DESCRIPTION = "Code der referenzierten Medication",
      COLUMN_TYPE = "varchar",
      PSEUDONYMIZATION_RULE = "keep"
    ),
    "snapshot_extension"
  )

  rules <- loadPseudonymizationRules(
    table_descriptions = data.table::data.table(
      SOURCE = "fhir",
      PATH = table_description_file,
      SHEET_NAME = "table_description"
    ),
    snapshot_extensions = data.table::data.table(
      SOURCE = "observation_extensions",
      PATH = extension_file,
      SHEET_NAME = "snapshot_extension"
    )
  )

  expect_equal(nrow(rules), 3)
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_id", ][["SOURCE_TYPE"]],
    "table_description"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_id", ][["PSEUDONYMIZATION_RULE"]],
    "cryptoHash"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_value", ][["TABLE_OR_RESOURCE"]],
    "observation"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_value", ][["PSEUDONYMIZATION_RULE"]],
    "keep"
  )
  expect_false(rules[rules$COLUMN_NAME == "obs_value", ][["EMPTY_RULE"]])
  expect_equal(
    rules[rules$COLUMN_NAME == "medreq_medication_code", ][["SOURCE_TYPE"]],
    "snapshot_extension"
  )
})

test_that("loadPseudonymizationRules keeps snapshot-only TODO markers visible", {
  extension_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "medicationrequest",
      COLUMN_NAME = "medreq_medication_code",
      COLUMN_DESCRIPTION = "Code der referenzierten Medication",
      COLUMN_TYPE = "varchar",
      PSEUDONYMIZATION_RULE = "### TODO: NEW COLUMN ###"
    ),
    "snapshot_extension"
  )

  rules <- loadPseudonymizationRules(
    table_descriptions = NULL,
    snapshot_extensions = extension_file
  )

  expect_equal(rules$SOURCE_TYPE, "snapshot_extension")
  expect_equal(rules$PSEUDONYMIZATION_RULE, "### TODO: NEW COLUMN ###")
  expect_false(rules$EMPTY_RULE)
})

test_that("default snapshot rule sources name all current rule workbooks", {
  sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root = "/repo")

  expect_equal(
    sources$table_descriptions$SOURCE,
    c("fhir", "dataprocessor_submodules", "frontend")
  )
  expect_equal(
    sources$table_descriptions$SHEET_NAME,
    c("table_description", "table_description", "frontend_table_description")
  )
  expect_equal(sources$snapshot_extensions$SHEET_NAME, "snapshot_extension")
  expect_true(any(grepl("Frontend_Table_Description.xlsx$", sources$table_descriptions$PATH)))
})

test_that("default snapshot rule sources allow a missing snapshot extension sheet", {
  project_root <- tempfile("snapshot-rule-sources-")
  table_description_path <- file.path(
    project_root,
    DEFAULT_FHIR_TABLE_DESCRIPTION_PATH
  )
  dir.create(dirname(table_description_path), recursive = TRUE)
  workbook <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(workbook, "table_description")
  openxlsx::writeData(
    workbook,
    "table_description",
    data.table::data.table(TABLE_NAME = "Patient", COLUMN_NAME = "pat_id")
  )
  openxlsx::saveWorkbook(workbook, table_description_path)

  sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root)

  expect_s3_class(sources$snapshot_extensions, "data.table")
  expect_equal(nrow(sources$snapshot_extensions), 0L)
})

test_that("default snapshot extensions come from the generated table description", {
  sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root = "/repo")

  expect_equal(
    sources$snapshot_extensions$PATH,
    file.path("/repo", DEFAULT_FHIR_TABLE_DESCRIPTION_PATH)
  )
})

test_that("default snapshot rule sources can load current repository files", {
  sources <- getDefaultSnapshotPseudonymizationRuleSources(
    project_root = findRepositoryRootForPseudonymTests()
  )

  rules <- loadPseudonymizationRules(
    table_descriptions = sources$table_descriptions,
    snapshot_extensions = sources$snapshot_extensions
  )

  expect_true(nrow(rules) > 0)
  expect_setequal(
    unique(rules$SOURCE),
    c("fhir", "dataprocessor_submodules", "frontend", "snapshot_extension")
  )
  expect_false(any(rules$EMPTY_RULE))
})

test_that("rule review report flags empty todo unsupported and duplicate rules", {
  rules <- data.table::data.table(
    SOURCE = "manual",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "manual.xlsx",
    SOURCE_SHEET = "table_description",
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = c("id", "id", "note", "new_col"),
    PSEUDONYMIZATION_RULE_RAW = c(NA_character_, "blur", "keep", "### TODO: NEW COLUMN ###"),
    PSEUDONYMIZATION_RULE = c(NA_character_, "blur", "keep", "### TODO: NEW COLUMN ###"),
    EMPTY_RULE = c(TRUE, FALSE, FALSE, FALSE)
  )

  report <- getPseudonymizationRuleReviewReport(rules)

  expect_equal(report$summary$N, 4L)
  expect_equal(report$summary$EMPTY_RULE_N, 1L)
  expect_equal(report$empty_rules$COLUMN_NAME, "id")
  expect_equal(report$summary$TODO_N, 1L)
  expect_equal(nrow(report$unsupported_rules), 2L)
  expect_setequal(report$unsupported_rules$RULE_PART, c("blur", "### TODO: NEW COLUMN ###"))
  expect_equal(report$duplicate_columns$COLUMN_NAME, "id")
  expect_equal(report$duplicate_columns$N, 2L)
  expect_true(pseudonymizationReviewHasBlockingProblems(report))
})

test_that("rule review report validates pseudonym mapping sheets", {
  input_repo_path <- tempfile("input-repo-")
  dir.create(input_repo_path, recursive = TRUE, showWarnings = FALSE)
  etlutils::writeExcelFile(
    list(frontend_users = data.table::data.table(
      KEY = c("Name 1", "Name 2"),
      PSEUDONYM = c("Pseudonym 1", "Pseudonym 2")
    )),
    file.path(input_repo_path, "pseudo_mapping.xlsx"),
    with_column_names = TRUE
  )
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Frontend_Table_Description.xlsx",
    SOURCE_SHEET = "table_description",
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = "meda_anlage",
    PSEUDONYMIZATION_RULE_RAW = 'pseudonym(sheet = "frontend_users")',
    PSEUDONYMIZATION_RULE = 'pseudonym(sheet = "frontend_users")',
    EMPTY_RULE = FALSE
  )

  report <- getPseudonymizationRuleReviewReport(rules, input_repo_path = input_repo_path)

  expect_equal(report$mapping_rules$SHEET_NAME, "frontend_users")
  expect_equal(report$mapping_rules$MAPPING_STATUS, "ok")
  expect_true(is.na(report$mapping_rules$ERROR))
  expect_equal(report$summary$MAPPING_RULE_N, 1L)
  expect_equal(report$summary$MAPPING_PROBLEM_N, 0L)
})

test_that("rule review report reports missing mapping input path", {
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Frontend_Table_Description.xlsx",
    SOURCE_SHEET = "table_description",
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = "meda_anlage",
    PSEUDONYMIZATION_RULE_RAW = 'pseudonym("frontend_users")',
    PSEUDONYMIZATION_RULE = 'pseudonym("frontend_users")',
    EMPTY_RULE = FALSE
  )

  report <- getPseudonymizationRuleReviewReport(rules)

  expect_equal(report$mapping_rules$SHEET_NAME, "frontend_users")
  expect_equal(report$mapping_rules$MAPPING_STATUS, "missing_input_repo_path")
  expect_match(report$mapping_rules$ERROR, "input_repo_path")
  expect_equal(report$summary$MAPPING_PROBLEM_N, 1L)
})

test_that("rule review report can be written as Excel workbook", {
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Frontend_Table_Description.xlsx",
    SOURCE_SHEET = "frontend_table_description",
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = "meda_anlage",
    PSEUDONYMIZATION_RULE_RAW = 'pseudonym("frontend_users")',
    PSEUDONYMIZATION_RULE = 'pseudonym("frontend_users")',
    EMPTY_RULE = FALSE
  )
  file_name <- tempfile(fileext = ".xlsx")

  report <- writePseudonymizationRuleReviewReport(rules, file_name)
  workbook <- etlutils::readExcelFileAsTableList(file_name)

  expect_true(file.exists(file_name))
  expect_setequal(
    names(workbook),
    c(
      "README",
      "summary",
      "todo_rules",
      "empty_rules",
      "unsupported_rules",
      "duplicate_columns",
      "mapping_rules"
    )
  )
  expect_equal(report$summary$MAPPING_PROBLEM_N, 1L)
  expect_equal(workbook$mapping_rules$MAPPING_STATUS, "missing_input_repo_path")
})

test_that("rule review report defaults to outputLocal reports directory", {
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Frontend_Table_Description.xlsx",
    SOURCE_SHEET = "frontend_table_description",
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = "meda_anlage",
    PSEUDONYMIZATION_RULE_RAW = "keep",
    PSEUDONYMIZATION_RULE = "keep",
    EMPTY_RULE = FALSE
  )
  old_module_dirs <- if (exists("MODULE_DIRS", envir = .GlobalEnv)) {
    get("MODULE_DIRS", envir = .GlobalEnv)
  } else {
    NULL
  }
  test_output_dir <- tempfile("outputLocal-")
  assign(
    "MODULE_DIRS",
    list(local_dir = file.path(test_output_dir, "pseudonym")),
    envir = .GlobalEnv
  )
  on.exit(
    {
      if (is.null(old_module_dirs)) {
        rm("MODULE_DIRS", envir = .GlobalEnv)
      } else {
        assign("MODULE_DIRS", old_module_dirs, envir = .GlobalEnv)
      }
    },
    add = TRUE
  )

  writePseudonymizationRuleReviewReport(
    rules,
    filename_without_extension = "review_test"
  )

  expect_true(file.exists(file.path(
    test_output_dir,
    "pseudonym",
    "reports",
    "review_test.xlsx"
  )))
})
