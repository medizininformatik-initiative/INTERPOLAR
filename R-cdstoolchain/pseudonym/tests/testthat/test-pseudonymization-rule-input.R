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

test_that("loadPseudonymizationRules loads table descriptions and snapshot extensions", {
  table_description_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = c("observation", NA_character_),
      COLUMN_NAME = c("obs_id", "obs_value"),
      COLUMN_DESCRIPTION = c("Observation id", "Observation value"),
      COLUMN_TYPE = c("varchar", "double precision"),
      PSEUDONYMIZATION_RULE = c("cryptoHash", NA_character_)
    ),
    "table_description"
  )
  extension_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "observation",
      COLUMN_NAME = "value_ref_unit",
      COLUMN_DESCRIPTION = "Wert in Referenzeinheit",
      COLUMN_TYPE = "double precision",
      PSEUDONYMIZATION_RULE = "keep"
    ),
    "snapshot_extensions"
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
      SHEET_NAME = "snapshot_extensions"
    )
  )

  expect_equal(nrow(rules), 3)
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_id", "SOURCE_TYPE", drop = TRUE],
    "table_description"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_id", "PSEUDONYMIZATION_RULE", drop = TRUE],
    "cryptoHash"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_value", "TABLE_OR_RESOURCE", drop = TRUE],
    "observation"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_value", "PSEUDONYMIZATION_RULE", drop = TRUE],
    "keep"
  )
  expect_true(rules[rules$COLUMN_NAME == "obs_value", "IMPLICIT_KEEP", drop = TRUE])
  expect_equal(
    rules[rules$COLUMN_NAME == "value_ref_unit", "SOURCE_TYPE", drop = TRUE],
    "snapshot_extension"
  )
})

test_that("loadPseudonymizationRules keeps snapshot-only TODO markers visible", {
  extension_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "observation",
      COLUMN_NAME = "primary_loinc_code",
      COLUMN_DESCRIPTION = "Primary LOINC",
      COLUMN_TYPE = "varchar",
      PSEUDONYMIZATION_RULE = "### TODO: NEW COLUMN ###"
    ),
    "snapshot_extensions"
  )

  rules <- loadPseudonymizationRules(
    table_descriptions = NULL,
    snapshot_extensions = extension_file
  )

  expect_equal(rules$SOURCE_TYPE, "snapshot_extension")
  expect_equal(rules$PSEUDONYMIZATION_RULE, "### TODO: NEW COLUMN ###")
  expect_false(rules$IMPLICIT_KEEP)
})

test_that("rule review report flags todo implicit keep unsupported and duplicates", {
  rules <- data.table::data.table(
    SOURCE = "manual",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "manual.xlsx",
    SOURCE_SHEET = "table_description",
    TABLE_OR_RESOURCE = "frontend",
    COLUMN_NAME = c("id", "id", "note", "new_col"),
    PSEUDONYMIZATION_RULE_RAW = c(NA_character_, "blur", "keep", "### TODO: NEW COLUMN ###"),
    PSEUDONYMIZATION_RULE = c("keep", "blur", "keep", "### TODO: NEW COLUMN ###"),
    IMPLICIT_KEEP = c(TRUE, FALSE, FALSE, FALSE)
  )

  report <- getPseudonymizationRuleReviewReport(rules)

  expect_equal(report$summary$N, 4L)
  expect_equal(report$summary$IMPLICIT_KEEP_N, 1L)
  expect_equal(report$summary$TODO_N, 1L)
  expect_equal(nrow(report$unsupported_rules), 2L)
  expect_setequal(report$unsupported_rules$RULE_PART, c("blur", "### TODO: NEW COLUMN ###"))
  expect_equal(report$duplicate_columns$COLUMN_NAME, "id")
  expect_equal(report$duplicate_columns$N, 2L)
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
    IMPLICIT_KEEP = FALSE
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
    IMPLICIT_KEEP = FALSE
  )

  report <- getPseudonymizationRuleReviewReport(rules)

  expect_equal(report$mapping_rules$SHEET_NAME, "frontend_users")
  expect_equal(report$mapping_rules$MAPPING_STATUS, "missing_input_repo_path")
  expect_match(report$mapping_rules$ERROR, "input_repo_path")
  expect_equal(report$summary$MAPPING_PROBLEM_N, 1L)
})
