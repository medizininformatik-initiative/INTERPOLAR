test_that("dbReadConfigForTarget applies target database values", {
  db_config_file <- tempfile(fileext = ".toml")
  writeLines(c(
    "DB_NAME = \"source_db\"",
    "DB_HOST = \"source-host\"",
    "DB_PORT = \"5432\"",
    "DB_ANALYSIS_NAME = \"analysis_db\"",
    "DB_ANALYSIS_HOST = \"analysis-host\"",
    "DB_ANALYSIS_PORT = \"15432\"",
    "DB_ADMIN_PASSWORD = \"source-admin-password\"",
    "DB_ANALYSIS_ADMIN_PASSWORD = \"analysis-admin-password\"",
    "DB_DATAPROCESSOR_USER = \"dp_user\"",
    "DB_DATAPROCESSOR_PASSWORD = \"dp_password\"",
    "DB_DATAPROCESSOR_SCHEMA_IN = \"dp_in\"",
    "DB_DATAPROCESSOR_SCHEMA_OUT = \"dp_out\""
  ), db_config_file)

  result <- dbReadConfigForTarget(db_config_file, target_prefix = "DB_ANALYSIS")

  expect_equal(result$DB_NAME, "analysis_db")
  expect_equal(result$DB_HOST, "analysis-host")
  expect_equal(result$DB_PORT, "15432")
  expect_equal(result$DB_ADMIN_PASSWORD, "analysis-admin-password")
  expect_equal(result$DB_DATAPROCESSOR_USER, "dp_user")
  expect_equal(result$DB_DATAPROCESSOR_SCHEMA_OUT, "dp_out")
})

test_that("dbReadConfigForTarget falls back to base database values", {
  db_config_file <- tempfile(fileext = ".toml")
  writeLines(c(
    "DB_NAME = \"source_db\"",
    "DB_HOST = \"source-host\"",
    "DB_PORT = \"5432\"",
    "DB_ANALYSIS_NAME = \"\"",
    "DB_ANALYSIS_HOST = \"\"",
    "DB_ANALYSIS_PORT = \"\""
  ), db_config_file)

  result <- dbReadConfigForTarget(db_config_file, target_prefix = "DB_ANALYSIS")

  expect_equal(result$DB_NAME, "source_db")
  expect_equal(result$DB_HOST, "source-host")
  expect_equal(result$DB_PORT, "5432")
})

test_that("dbSetModuleContextFromEnvironment handles missing path variable", {
  envir <- new.env(parent = emptyenv())

  result <- dbSetModuleContextFromEnvironment("dataprocessor", envir = envir)

  expect_false(result)
})
