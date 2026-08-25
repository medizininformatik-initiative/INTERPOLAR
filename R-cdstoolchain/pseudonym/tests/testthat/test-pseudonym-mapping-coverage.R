mappingCoverageTestRules <- function() {
  data.table::data.table(
    SOURCE = "fhir",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "Table_Description.xlsx",
    SOURCE_SHEET = "table_description",
    TABLE_OR_RESOURCE = "pids_per_ward",
    COLUMN_NAME = c("ward_name", "patient_id"),
    PSEUDONYMIZATION_RULE_RAW = c(
      'pseudonym(sheet = "wards")',
      'pseudonym(sheet = "patients")'
    ),
    PSEUDONYMIZATION_RULE = c(
      'pseudonym(sheet = "wards")',
      'pseudonym(sheet = "patients")'
    ),
    EMPTY_RULE = FALSE
  )
}

mappingCoverageTestPlan <- function() {
  data.table::data.table(
    SOURCE_RELATION = c("v_pids_per_ward", "v_pids_per_ward_last_version"),
    RULE_TABLE_NAME = "pids_per_ward",
    RULE_SOURCE = "fhir",
    SNAPSHOT_RELATION_TYPE = c("all", "last_version")
  )
}

test_that("static rule review defers missing mapping workbooks", {
  report <- getPseudonymizationRuleReviewReport(
    mappingCoverageTestRules(),
    input_repo_path = tempfile("missing-input-repo-"),
    validate_mapping_files = FALSE
  )

  expect_equal(unique(report$mapping_rules$MAPPING_STATUS), "not_checked")
  expect_false(pseudonymizationReviewHasBlockingProblems(report))
  expect_equal(sum(report$summary$MAPPING_PROBLEM_N), 0L)
})

test_that("mapping coverage includes frontend user columns before chunking", {
  rules <- data.table::data.table(
    SOURCE = "frontend",
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = "medikationsanalyse",
    COLUMN_NAME = c("meda_anlage", "meda_edit"),
    PSEUDONYMIZATION_RULE = 'pseudonym(sheet = "frontend_users")'
  )
  plan <- data.table::data.table(
    SOURCE_RELATION = c(
      "v_medikationsanalyse_fe",
      "v_medikationsanalyse_fe_last_version"
    ),
    RULE_TABLE_NAME = "medikationsanalyse",
    RULE_SOURCE = "frontend",
    SNAPSHOT_RELATION_TYPE = c("old_versions", "last_version")
  )

  requests <- getPseudonymMappingCoverageRequests(rules, plan)

  expect_equal(nrow(requests), 2L)
  expect_setequal(
    paste(requests$SOURCE_RELATION, requests$COLUMN_NAME),
    c(
      "v_medikationsanalyse_fe meda_anlage",
      "v_medikationsanalyse_fe meda_edit"
    )
  )
  expect_true(all(requests$SHEET_NAME == "frontend_users"))
})

test_that("mapping coverage creates sheets with sorted distinct database keys", {
  input_repo_path <- tempfile("mapping-coverage-")
  dir.create(input_repo_path)
  reader <- function(
    connection,
    source_relation,
    column_name,
    source_schema = NULL
  ) {
    values <- list(
      v_pids_per_ward = list(
        ward_name = c("Ward Z", "ward a", "Ward Z\nWard B"),
        patient_id = c("Patient 2", "Patient 1", "Patient 3")
      ),
      v_pids_per_ward_last_version = list(
        ward_name = c("Ward B\r\nward a", "ward a"),
        patient_id = c("Patient 1", "Patient 3")
      )
    )
    values[[source_relation]][[column_name]]
  }

  expect_error(
    ensurePseudonymMappingCoverage(
      connection = NULL,
      rules = mappingCoverageTestRules(),
      materialization_plan = mappingCoverageTestPlan(),
      input_repo_path = input_repo_path,
      distinct_value_reader = reader
    ),
    "Snapshot pseudonymization is paused"
  )

  mapping_file <- file.path(input_repo_path, "pseudo_mapping.xlsx")
  expect_true(file.exists(mapping_file))
  expect_setequal(openxlsx::getSheetNames(mapping_file), c("patients", "wards"))
  wards <- openxlsx::read.xlsx(mapping_file, sheet = "wards")
  patients <- openxlsx::read.xlsx(mapping_file, sheet = "patients")
  expect_equal(wards$KEY, c("ward a", "Ward B", "Ward Z"))
  expect_true(all(is.na(wards$PSEUDONYM)))
  expect_equal(patients$KEY, c("Patient 1", "Patient 2", "Patient 3"))
  expect_true(all(is.na(patients$PSEUDONYM)))
})

test_that("mapping coverage preserves filled pseudonyms and completes", {
  input_repo_path <- tempfile("mapping-complete-")
  dir.create(input_repo_path)
  mapping_file <- file.path(input_repo_path, "pseudo_mapping.xlsx")
  workbook <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(workbook, "wards")
  openxlsx::writeData(
    workbook,
    "wards",
    data.table::data.table(
      KEY = c("Ward Z", "Ward A"),
      PSEUDONYM = c("Z", "A")
    )
  )
  openxlsx::addWorksheet(workbook, "patients")
  openxlsx::writeData(
    workbook,
    "patients",
    data.table::data.table(
      KEY = c("Patient 2", "Patient 1"),
      PSEUDONYM = c("P2", "P1")
    )
  )
  openxlsx::saveWorkbook(workbook, mapping_file)
  reader <- function(
    connection,
    source_relation,
    column_name,
    source_schema = NULL
  ) {
    if (column_name == "ward_name") {
      return(c("Ward Z", "Ward A"))
    }
    c("Patient 1", "Patient 2")
  }

  result <- ensurePseudonymMappingCoverage(
    connection = NULL,
    rules = mappingCoverageTestRules(),
    materialization_plan = mappingCoverageTestPlan(),
    input_repo_path = input_repo_path,
    distinct_value_reader = reader
  )

  expect_equal(result$STATUS, c("complete", "complete"))
  expect_equal(
    openxlsx::read.xlsx(mapping_file, sheet = "wards")$PSEUDONYM,
    c("A", "Z")
  )
  expect_equal(
    openxlsx::read.xlsx(mapping_file, sheet = "patients")$PSEUDONYM,
    c("P1", "P2")
  )
})
