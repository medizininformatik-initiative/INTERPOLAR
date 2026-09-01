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

test_that("dbCreateConnection applies shared connection settings", {
  connection_arguments <- NULL
  executed_statement <- NULL
  fake_connection <- structure(list(), class = "fake_db_connection")
  testthat::local_mocked_bindings(
    dbConnect = function(...) {
      connection_arguments <<- list(...)
      fake_connection
    },
    dbExecute = function(connection, statement) {
      expect_identical(connection, fake_connection)
      executed_statement <<- statement
      0L
    },
    dbDisconnect = function(connection) {
      fail("Successful connection must not be disconnected by the factory")
    },
    .package = "DBI"
  )

  result <- dbCreateConnection(
    dbname = "snapshot_source",
    host = "database-host",
    port = 5432,
    user = "snapshot_user",
    password = "snapshot_password",
    schema = "snapshot_schema"
  )

  expect_identical(result, fake_connection)
  expect_s4_class(connection_arguments[["drv"]], "PqDriver")
  expect_equal(connection_arguments[["dbname"]], "snapshot_source")
  expect_equal(connection_arguments[["host"]], "database-host")
  expect_equal(connection_arguments[["port"]], 5432)
  expect_equal(connection_arguments[["user"]], "snapshot_user")
  expect_equal(connection_arguments[["password"]], "snapshot_password")
  expect_equal(connection_arguments[["timezone"]], GLOBAL_TIMEZONE)
  expect_equal(connection_arguments[["options"]], "-c search_path=snapshot_schema")
  expect_equal(executed_statement, "set work_mem to '32MB';")
})

test_that("dbCreateConnection omits the search path without a schema", {
  connection_arguments <- NULL
  fake_connection <- structure(list(), class = "fake_db_connection")
  testthat::local_mocked_bindings(
    dbConnect = function(...) {
      connection_arguments <<- list(...)
      fake_connection
    },
    dbExecute = function(connection, statement) 0L,
    dbDisconnect = function(connection) NULL,
    .package = "DBI"
  )

  dbCreateConnection("snapshot", "database-host", 5432, "user", "password")

  expect_false("options" %in% names(connection_arguments))
})

test_that("dbCreateConnection closes connections after session setup errors", {
  disconnected <- FALSE
  fake_connection <- structure(list(), class = "fake_db_connection")
  testthat::local_mocked_bindings(
    dbConnect = function(...) fake_connection,
    dbExecute = function(connection, statement) stop("session setup failed"),
    dbDisconnect = function(connection) {
      expect_identical(connection, fake_connection)
      disconnected <<- TRUE
      TRUE
    },
    .package = "DBI"
  )

  expect_error(
    dbCreateConnection("snapshot", "database-host", 5432, "user", "password"),
    "session setup failed"
  )
  expect_true(disconnected)
})

test_that("dbGetCoordinationMode caches the detected mode per context", {
  detection_count <- 0L
  testthat::local_mocked_bindings(
    dbDetectCoordinationMode = function() {
      detection_count <<- detection_count + 1L
      DB_COORDINATION_MODE_NONE
    }
  )

  dbSetContext(
    "dataprocessor", "snapshot", "host", 5432, "user", "password",
    "schema_in", "schema_out", FALSE
  )
  expect_equal(dbGetCoordinationMode(), DB_COORDINATION_MODE_NONE)
  expect_equal(dbGetCoordinationMode(), DB_COORDINATION_MODE_NONE)
  expect_equal(detection_count, 1L)

  dbSetContext(
    "dataprocessor", "other_snapshot", "host", 5432, "user", "password",
    "schema_in", "schema_out", FALSE
  )
  expect_equal(dbGetCoordinationMode(), DB_COORDINATION_MODE_NONE)
  expect_equal(detection_count, 2L)
})

test_that("dbDetectCoordinationMode accepts read-only databases", {
  testthat::local_mocked_bindings(
    dbWithRetry = function(...) {
      data.frame(
        transaction_read_only = TRUE,
        has_transfer_functions = TRUE
      )
    }
  )

  expect_equal(dbDetectCoordinationMode(), DB_COORDINATION_MODE_NONE)
})

test_that("dbDetectCoordinationMode accepts complete transfer coordination", {
  detection_calls <- 0L
  detection_sql <- NULL
  testthat::local_mocked_bindings(
    dbWithRetry = function(db_call,
                           call_label,
                           sql,
                           readonly = FALSE,
                           params = NULL,
                           admin = FALSE) {
      detection_calls <<- detection_calls + 1L
      detection_sql <<- sql
      expect_false(admin)
      data.frame(
        transaction_read_only = FALSE,
        has_transfer_functions = TRUE
      )
    }
  )

  expect_equal(dbDetectCoordinationMode(), DB_COORDINATION_MODE_TRANSFER)
  expect_equal(detection_calls, 1L)
  expect_match(detection_sql, "EXISTS", fixed = TRUE)
  expect_match(detection_sql, "'data_transfer_reset_lock'", fixed = TRUE)
  expect_false(grepl("data_transfer_get_lock_module", detection_sql, fixed = TRUE))
  expect_false(grepl("cron.job", detection_sql, fixed = TRUE))
})

test_that("dbDetectCoordinationMode accepts databases without transfer functions", {
  testthat::local_mocked_bindings(
    dbWithRetry = function(...) {
      data.frame(
        transaction_read_only = FALSE,
        has_transfer_functions = FALSE
      )
    }
  )

  expect_equal(dbDetectCoordinationMode(), DB_COORDINATION_MODE_NONE)
})

test_that("database locks are no-ops without transfer coordination", {
  testthat::local_mocked_bindings(
    dbUsesTransferCoordination = function() FALSE,
    dbGetStatus = function() fail("status must not be read"),
    dbIsLockedByModule = function() fail("lock owner must not be read")
  )

  expect_null(dbLock("analysis"))
  expect_false(dbUnlock("analysis"))
  expect_false(dbResetLock())
})

test_that("read-only query results do not depend on transfer coordination", {
  query_result <- data.table::data.table(patient_id = c(1L, 2L))
  testthat::local_mocked_bindings(
    dbUsesTransferCoordination = function() FALSE,
    dbWithRetry = function(...) query_result
  )

  without_lock <- dbGetReadOnlyQuery("SELECT patient_id FROM v_patient")
  with_inactive_lock <- dbGetReadOnlyQuery(
    "SELECT patient_id FROM v_patient",
    lock_id = "analysis"
  )

  expect_equal(with_inactive_lock, without_lock)
})
