test_that("getSnapshotSourceViewPlan uses described table sources only", {
  rules <- data.table::data.table(
    SOURCE_TYPE = c("table_description", "snapshot_extension", "table_description"),
    TABLE_OR_RESOURCE = c("patient", "observation", "observation")
  )

  plan <- getSnapshotSourceViewPlan(rules)

  expect_equal(plan$BASE_TABLE_NAME, c("patient", "observation", "patient", "observation"))
  expect_equal(
    plan$MATERIALIZED_TABLE_NAME,
    c("patient", "observation", "patient_last_version", "observation_last_version")
  )
  expect_equal(
    plan$SOURCE_RELATION,
    c("v_patient", "v_observation", "v_patient_last_version", "v_observation_last_version")
  )
  expect_equal(plan$TARGET_VIEW_NAME, plan$SOURCE_RELATION)
})

test_that("getSnapshotSourceViewPlan can limit tables", {
  rules <- data.table::data.table(
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = c("patient", "observation", "encounter")
  )

  plan <- getSnapshotSourceViewPlan(rules, tables = c("Observation", "unknown"))

  expect_equal(plan$BASE_TABLE_NAME, c("observation", "observation"))
  expect_equal(plan$MATERIALIZED_TABLE_NAME, c("observation", "observation_last_version"))
  expect_equal(plan$SOURCE_RELATION, c("v_observation", "v_observation_last_version"))
})

test_that("getSnapshotSourceViewPlan maps frontend rule names to frontend DB tables", {
  rules <- data.table::data.table(
    SOURCE = c("frontend", "fhir"),
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = c("fall", "Patient")
  )

  plan <- getSnapshotSourceViewPlan(rules)

  expect_equal(plan$BASE_TABLE_NAME, c("fall_fe", "patient", "fall_fe", "patient"))
  expect_equal(plan$RULE_TABLE_NAME, c("fall", "patient", "fall", "patient"))
  expect_equal(
    plan$SOURCE_RELATION,
    c("v_fall_fe", "v_patient", "v_fall_fe_last_version", "v_patient_last_version")
  )
})

test_that("pseudonymizeTableForSnapshot keeps matching snapshot extension columns", {
  rules <- data.table::data.table(
    SOURCE = c("fhir", rep("snapshot_extension", 3)),
    SOURCE_TYPE = c("table_description", rep("snapshot_extension", 3)),
    TABLE_OR_RESOURCE = rep("observation", 4),
    COLUMN_NAME = c(
      "obs_id",
      "value_in_reference_unit",
      "reference_unit",
      "primary_loinc_code"
    ),
    PSEUDONYMIZATION_RULE = "keep"
  )
  observation <- data.table::data.table(
    obs_id = "obs-1",
    value_in_reference_unit = 1000,
    reference_unit = "umol/L",
    primary_loinc_code = "9999-9"
  )

  result <- pseudonymizeTableForSnapshot(
    observation,
    rules,
    table_name = "observation",
    rule_source = "fhir",
    input_repo_path = NULL
  )

  expect_equal(names(result$table), names(observation))
  expect_equal(result$table$value_in_reference_unit, 1000)
  expect_equal(result$table$reference_unit, "umol/L")
  expect_equal(result$table$primary_loinc_code, "9999-9")
})

test_that("pseudonymizeTableForSnapshot keeps unmatched source columns", {
  rules <- data.table::data.table(
    SOURCE = "fhir",
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = "patient",
    COLUMN_NAME = "pat_id",
    PSEUDONYMIZATION_RULE = "cryptoHash"
  )
  patient <- data.table::data.table(
    pat_id = "Patient/1",
    pat_raw_id = 17L,
    pat_insert_datetime = "2026-07-20 10:00:00"
  )

  result <- pseudonymizeTableForSnapshot(
    patient,
    rules,
    table_name = "patient",
    rule_source = "fhir",
    input_repo_path = NULL
  )

  expect_equal(names(result$table), names(patient))
  expect_equal(result$table$pat_raw_id, 17L)
  expect_equal(result$table$pat_insert_datetime, "2026-07-20 10:00:00")
  expect_false(identical(result$table$pat_id, patient$pat_id))
})

test_that("writeSnapshotPostprocessingReport writes an xlsx report", {
  file_name <- tempfile(fileext = ".xlsx")
  summary <- data.table::data.table(
    TABLE_NAME = "fall_fe",
    ORIGINAL_COLUMNS_REMOVED = 0L,
    DUPLICATE_ROWS_REMOVED = 0L
  )

  result <- writeSnapshotPostprocessingReport(summary, file_name = file_name)

  expect_true(file.exists(file_name))
  expect_equal(result, summary)
})

test_that("writeSnapshotIssueReport writes bounded issue sheets", {
  file_name <- tempfile(fileext = ".xlsx")
  report <- list(
    medication_issue_summary = data.table::data.table(
      TABLE_NAME = "medicationrequest",
      UNMATCHED_ROWS = 5
    ),
    medication_issue_examples = data.table::data.table(
      TABLE_NAME = "medicationrequest",
      MEDICATION_ID = "missing"
    ),
    age_issue_summary = data.table::data.table(
      TABLE_NAME = "encounter",
      ISSUE_TYPE = "reference_date_before_birthdate",
      AFFECTED_ROWS = 1
    ),
    age_issue_examples = data.table::data.table(
      TABLE_NAME = "encounter",
      FHIR_PATIENT_ID = "pat-1",
      FHIR_ENCOUNTER_ID = "enc-1",
      BIRTHDATE = as.Date("1980-01-01"),
      REFERENCE_DATE = as.Date("1979-01-01")
    )
  )

  result <- writeSnapshotIssueReport(report, file_name = file_name)

  expect_true(file.exists(file_name))
  expect_equal(names(etlutils::readExcelFileAsTableList(file_name)), names(report))
  expect_equal(result, report)
})

test_that("writeSnapshotIssueReport uses the issue report filename by default", {
  old_module_dirs <- if (exists("MODULE_DIRS", envir = .GlobalEnv)) {
    get("MODULE_DIRS", envir = .GlobalEnv)
  } else {
    NULL
  }
  output_dir <- tempfile("snapshot-issue-report-")
  assign("MODULE_DIRS", list(local_dir = output_dir), envir = .GlobalEnv)
  on.exit({
    if (is.null(old_module_dirs)) {
      rm("MODULE_DIRS", envir = .GlobalEnv)
    } else {
      assign("MODULE_DIRS", old_module_dirs, envir = .GlobalEnv)
    }
  })
  report <- list(
    age_issue_summary = data.table::data.table(
      TABLE_NAME = "encounter",
      ISSUE_TYPE = "missing_birthdate",
      AFFECTED_ROWS = 1
    )
  )

  writeSnapshotIssueReport(report)

  expect_true(file.exists(file.path(
    output_dir,
    "reports",
    "snapshot_pseudonymization_issues.xlsx"
  )))
})
