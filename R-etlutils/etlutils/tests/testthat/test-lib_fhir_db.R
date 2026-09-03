testthat::test_that("incomplete cases are split into unique ward lists", {
  incomplete_cases <- data.table::data.table(
    ward_name = c("Ward A", "Ward A", "Ward B"),
    patient_id = c("patient-1", "patient-1", "patient-2"),
    encounter_id = c("encounter-1", "encounter-1", "encounter-2")
  )

  result <- fhirdbSplitIncompleteCasesByWard(incomplete_cases)

  testthat::expect_named(result, c("Ward A", "Ward B"))
  testthat::expect_equal(
    result[["Ward A"]],
    data.table::data.table(
      patient_id = "patient-1",
      encounter_id = "encounter-1"
    )
  )
  testthat::expect_equal(
    result[["Ward B"]],
    data.table::data.table(
      patient_id = "patient-2",
      encounter_id = "encounter-2"
    )
  )
})

testthat::test_that("no incomplete cases produce an empty list", {
  incomplete_cases <- data.table::data.table(
    ward_name = character(),
    patient_id = character(),
    encounter_id = character()
  )

  testthat::expect_identical(
    fhirdbSplitIncompleteCasesByWard(incomplete_cases),
    list()
  )
})

testthat::test_that("database context initialization does not change the global environment", {
  config_path <- tempfile(fileext = ".toml")
  writeLines(
    c(
      'DB_NAME = "test_db"',
      'DB_HOST = "localhost"',
      "DB_PORT = 5432",
      'DB_TESTMODULE_USER = "test_user"',
      'DB_TESTMODULE_PASSWORD = "test_password"',
      'DB_TESTMODULE_SCHEMA_IN = "test_in"',
      'DB_TESTMODULE_SCHEMA_OUT = "test_out"',
      'DB_ADMIN_USER = "admin"',
      'DB_ADMIN_PASSWORD = "admin_password"',
      'DB_ADMIN_SCHEMAS = "public"'
    ),
    config_path
  )
  on.exit(unlink(config_path), add = TRUE)

  global_names_before <- setdiff(
    ls(envir = .GlobalEnv, all.names = TRUE),
    ".Random.seed"
  )

  dbInitModuleContext(
    module_name = "testmodule",
    path_to_db_toml = config_path,
    log = FALSE
  )

  testthat::expect_setequal(
    setdiff(ls(envir = .GlobalEnv, all.names = TRUE), ".Random.seed"),
    global_names_before
  )
})
