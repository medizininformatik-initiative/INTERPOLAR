test_that("snapshot source session permits temporary resolution tables", {
  captured <- new.env(parent = emptyenv())
  testthat::local_mocked_bindings(
    dbExecute = function(connection, statement) {
      captured$connection <- connection
      captured$statement <- statement
      0L
    },
    .package = "DBI"
  )

  snapshotAllowTemporarySourceTables("source-connection")

  expect_equal(captured$connection, "source-connection")
  expect_equal(captured$statement, "SET SESSION default_transaction_read_only = off")
})

test_that("getSnapshotReleaseVersion reads exactly one source version", {
  captured_statement <- NULL
  testthat::local_mocked_bindings(
    dbGetQuery = function(connection, statement) {
      captured_statement <<- statement
      data.frame(parameter_value = "2.1.0")
    },
    .package = "DBI"
  )

  result <- getSnapshotReleaseVersion(DBI::ANSI(), "db2dataprocessor_out")

  expect_equal(result, "2.1.0")
  expect_match(
    captured_statement,
    'FROM "db2dataprocessor_out"."v_db_parameter"',
    fixed = TRUE
  )
})

test_that("getSnapshotReleaseVersion rejects missing or empty versions", {
  version_rows <- data.frame(parameter_value = character())
  testthat::local_mocked_bindings(
    dbGetQuery = function(connection, statement) version_rows,
    .package = "DBI"
  )

  expect_error(getSnapshotReleaseVersion(DBI::ANSI()), "exactly one release_version")

  version_rows <- data.frame(parameter_value = "")
  expect_error(getSnapshotReleaseVersion(DBI::ANSI()), "must not be empty")
})

test_that("getSnapshotDatabaseContentType preserves an optional source marker", {
  content_type_rows <- data.frame(parameter_value = "pseudonymized_snapshot")
  captured_statement <- NULL
  testthat::local_mocked_bindings(
    dbGetQuery = function(connection, statement) {
      captured_statement <<- statement
      content_type_rows
    },
    .package = "DBI"
  )

  expect_equal(
    getSnapshotDatabaseContentType(DBI::ANSI(), "db2dataprocessor_out"),
    "pseudonymized_snapshot"
  )
  expect_match(
    captured_statement,
    'FROM "db2dataprocessor_out"."v_db_parameter"',
    fixed = TRUE
  )

  content_type_rows <- data.frame(parameter_value = character())
  expect_null(getSnapshotDatabaseContentType(DBI::ANSI()))
})

test_that("getSnapshotDatabaseContentType rejects invalid source markers", {
  content_type_rows <- data.frame(parameter_value = c("first", "second"))
  testthat::local_mocked_bindings(
    dbGetQuery = function(connection, statement) content_type_rows,
    .package = "DBI"
  )

  expect_error(getSnapshotDatabaseContentType(DBI::ANSI()), "at most one")

  content_type_rows <- data.frame(parameter_value = "")
  expect_error(getSnapshotDatabaseContentType(DBI::ANSI()), "must not be empty")
})

test_that("createSnapshotVersionView publishes the source release version", {
  statements <- character()
  testthat::local_mocked_bindings(
    snapshotRelationExists = function(connection, name, schema = NULL) FALSE
  )
  testthat::local_mocked_bindings(
    dbExecute = function(connection, statement) {
      statements <<- c(statements, statement)
      0L
    },
    .package = "DBI"
  )

  summary <- createSnapshotVersionView(DBI::ANSI(), "2.1'0")

  expect_equal(summary$VIEW_NAME, "v_db_parameter")
  view_statement <- statements[grepl("CREATE VIEW", statements, fixed = TRUE)]
  expect_length(view_statement, 1L)
  expect_match(view_statement, "CAST('2.1''0' AS varchar)", fixed = TRUE)
  expect_match(view_statement, "AS parameter_value", fixed = TRUE)
})

test_that("createSnapshotVersionView can mark pseudonymized snapshot databases", {
  statements <- character()
  testthat::local_mocked_bindings(
    snapshotRelationExists = function(connection, name, schema = NULL) FALSE
  )
  testthat::local_mocked_bindings(
    dbExecute = function(connection, statement) {
      statements <<- c(statements, statement)
      0L
    },
    .package = "DBI"
  )

  createSnapshotVersionView(DBI::ANSI(), "2.1.0", database_content_type = "pseudonymized_snapshot")

  view_statement <- statements[grepl("CREATE VIEW", statements, fixed = TRUE)]
  expect_match(view_statement, "CAST('database_content_type' AS varchar)", fixed = TRUE)
  expect_match(view_statement, "CAST('pseudonymized_snapshot' AS varchar)", fixed = TRUE)
})

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

test_that("existing last-version sources split snapshot storage", {
  rules <- data.table::data.table(
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = c("patient", "observation")
  )
  testthat::local_mocked_bindings(
    snapshotRelationExists = function(connection, name, schema = NULL) {
      name %in% c("v_patient", "v_patient_last_version", "v_observation")
    }
  )

  plan <- getExistingSnapshotMaterializationPlan(
    "connection",
    rules,
    source_schema = NULL,
    source_view_prefix = "v_",
    last_version_suffix = "_last_version",
    tables = NULL
  )

  expect_equal(
    plan$MATERIALIZED_TABLE_NAME,
    c("patient_old_versions", "observation", "patient_last_version")
  )
  expect_equal(
    plan$TARGET_VIEW_NAME,
    c("v_patient_old_versions", "v_observation", "v_patient_last_version")
  )
  expect_equal(plan$SNAPSHOT_RELATION_TYPE, c("old_versions", "all", "last_version"))
})

test_that("snapshot views combine disjoint partitions through passthrough views", {
  statements <- character()
  testthat::local_mocked_bindings(
    snapshotRelationExists = function(connection, name, schema = NULL) FALSE
  )
  testthat::local_mocked_bindings(
    dbExecute = function(connection, statement) {
      statements <<- c(statements, statement)
      0L
    },
    .package = "DBI"
  )
  plan <- data.table::data.table(
    BASE_TABLE_NAME = c("patient", "patient"),
    MATERIALIZED_TABLE_NAME = c("patient_old_versions", "patient_last_version"),
    TARGET_VIEW_NAME = c("v_patient_old_versions", "v_patient_last_version"),
    SNAPSHOT_RELATION_TYPE = c("old_versions", "last_version")
  )

  summary <- createSnapshotPassthroughViews(
    DBI::ANSI(),
    plan,
    table_schema = "db_log",
    view_schema = "db2dataprocessor_out"
  )

  expect_equal(
    summary$VIEW_NAME,
    c("v_patient_old_versions", "v_patient_last_version", "v_patient")
  )
  combined_statement <- statements[grepl(
    'CREATE VIEW "db2dataprocessor_out"."v_patient"',
    statements,
    fixed = TRUE
  )]
  expect_length(combined_statement, 1L)
  expect_match(
    combined_statement,
    'SELECT * FROM "db2dataprocessor_out"."v_patient_old_versions"',
    fixed = TRUE
  )
  expect_match(
    combined_statement,
    'UNION ALL SELECT * FROM "db2dataprocessor_out"."v_patient_last_version"',
    fixed = TRUE
  )
})

test_that("pseudonymizeTableForSnapshot keeps matching snapshot extension columns", {
  rules <- data.table::data.table(
    SOURCE = c("fhir", rep("snapshot_extension", 4)),
    SOURCE_TYPE = c("table_description", rep("snapshot_extension", 4)),
    TABLE_OR_RESOURCE = rep("observation", 5),
    COLUMN_NAME = c(
      "obs_id",
      "analysis_loinc_code",
      "analysis_unit",
      "analysis_value",
      "analysis_value_status"
    ),
    PSEUDONYMIZATION_RULE = "keep"
  )
  observation <- data.table::data.table(
    obs_id = "obs-1",
    analysis_loinc_code = "9999-9",
    analysis_unit = "umol/L",
    analysis_value = 1000,
    analysis_value_status = "converted"
  )

  result <- pseudonymizeTableForSnapshot(
    observation,
    rules,
    table_name = "observation",
    rule_source = "fhir",
    input_repo_path = NULL
  )

  expect_equal(names(result$table), names(observation))
  expect_equal(result$table$analysis_value, 1000)
  expect_equal(result$table$analysis_unit, "umol/L")
  expect_equal(result$table$analysis_loinc_code, "9999-9")
  expect_equal(result$table$analysis_value_status, "converted")
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
    ),
    loinc_unit_conversion_issues = data.table::data.table(
      TABLE_NAME = "observation",
      LOINC_CODE = "1975-2",
      USED_SOURCE_UNIT = "mg",
      TARGET_UNIT = "umol/L",
      AFFECTED_ROWS = 5
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
