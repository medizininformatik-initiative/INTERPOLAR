library(testthat)
source("R-cdstoolchain/Snapshot_Pseudonymization_Cli.R")
source("R-cdstoolchain/Database_Connection_Diagnostics.R")

test_that("diagnostics use the snapshot connector and set keepalives on both sessions", {
  calls <- list()
  statements <- character()
  scope <- new.env(parent = globalenv())
  scope$connectSnapshotPseudonymizationDatabase <- function(...) {
    calls[[length(calls) + 1L]] <<- list(...)
    "connection"
  }
  connect <- databaseDiagnosticConnection
  environment(connect) <- scope
  config <- list(DB_NAME = "snapshot", DB_HOST = "cds_hub")
  execute <- function(connection, sql) {
    expect_identical(connection, "connection")
    statements <<- c(statements, sql)
  }
  expect_identical(connect(config, execute = execute), "connection")
  expect_identical(connect(config, target = TRUE, execute = execute), "connection")
  expect_identical(statements, rep("SET tcp_keepalives_idle = 600", 2))
  expect_identical(calls[[1]]$command_arguments, list())
  expect_identical(calls[[1]]$db_config, config)
  expect_identical(calls[[1]]$dbname, "snapshot")
  expect_identical(calls[[1]]$user_argument, "source_db_user")
  expect_identical(calls[[2]]$user_argument, "target_db_user")
  expect_identical(calls[[2]]$password_argument, "target_db_password")
  closed <- FALSE
  expect_error(connect(config,
    execute = function(...) stop("setting failed"),
    disconnect = function(connection) { closed <<- TRUE }
  ), "setting failed")
  expect_true(closed)
})

test_that("parallel workers preserve success and error results", {
  skip_on_os("windows")
  result <- runDatabaseDiagnosticJobs(list(
    success = function() 42L,
    failure = function() stop("synthetic connection failure")
  ), timeout = 5, poll_seconds = 0.01)
  expect_identical(result$success$value, 42L)
  expect_identical(result$failure$status, "error")
  expect_match(result$failure$message, "synthetic connection failure")
  expect_gte(result$failure$elapsed_seconds, 0)
  expect_true(nzchar(result$failure$finished_at_utc))
})

test_that("a blocked worker is stopped while completed results survive", {
  skip_on_os("windows")
  pid_file <- tempfile()
  on.exit(unlink(pid_file))
  started <- proc.time()[["elapsed"]]
  result <- runDatabaseDiagnosticJobs(list(
    fast = function() "done",
    blocked = function() {
      writeLines(as.character(Sys.getpid()), pid_file)
      Sys.sleep(60)
    }
  ), timeout = 0.5, poll_seconds = 0.01)
  expect_lt(proc.time()[["elapsed"]] - started, 5)
  expect_identical(result$fast$value, "done")
  expect_identical(result$blocked$status, "timeout")
  if (requireNamespace("ps", quietly = TRUE)) {
    Sys.sleep(0.1)
    pid <- as.integer(readLines(pid_file))
    running <- tryCatch(ps::ps_is_running(ps::ps_handle(pid)), error = function(error) FALSE)
    expect_false(running)
  }
})

test_that("tests reuse their session and close it after success or failure", {
  events <- character()
  connect <- function(config) { events <<- c(events, "connect"); "session" }
  probe <- function(connection) {
    expect_identical(connection, "session")
    events <<- c(events, "probe")
    123L
  }
  disconnect <- function(connection) { events <<- c(events, "close") }
  query <- function(connection, sql) {
    events <<- c(events, "query")
    expect_match(sql, "pg_sleep(0)", fixed = TRUE)
    stop("canceling statement due to statement timeout")
  }
  value <- testDatabaseDiagnosticConnection(list(), "idle", 0, connect, probe, disconnect, query)
  expect_identical(value$before, value$after)
  expect_identical(events, c("connect", "probe", "probe", "close"))
  events <- character()
  expect_error(testDatabaseDiagnosticConnection(list(), "query", 0, connect, probe, disconnect, query),
    "statement timeout"
  )
  expect_identical(events, c("connect", "probe", "query", "close"))
})

test_that("report redacts configured secrets literally", {
  config <- list(DB_DATAPROCESSOR_PASSWORD = "a.*$b", DB_HOST = "cds_hub", TOKEN = "secret-token")
  expect_identical(redactDatabaseDiagnostic("a.*$b secret-token cds_hub", config),
    "[REDACTED] [REDACTED] cds_hub"
  )
})

test_that("summary distinguishes failed existing and fresh connections", {
  ok <- list(status = "ok")
  failed <- list(status = "timeout")
  expect_match(summarizeDatabaseDiagnostic(list(idle = ok, query = ok), ok), "nicht reproduziert")
  expect_match(summarizeDatabaseDiagnostic(list(idle = failed, query = ok), ok), "neue Verbindung erfolgreich")
  expect_match(summarizeDatabaseDiagnostic(list(idle = failed, query = ok), failed), "Auch die neue Verbindung")
})

test_that("configuration errors still produce a readable report", {
  root <- tempfile()
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE))
  report <- runDatabaseConnectionDiagnostics(root, wait_seconds = 0)
  expect_true(file.exists(report))
  expect_match(paste(readLines(report), collapse = "\n"), "nicht vollständig ausgeführt")
})

test_that("PostgreSQL produces a complete report and distinguishes a query timeout", {
  skip_if(Sys.info()[["sysname"]] != "Linux", "Run DB integration in the Linux R image.")
  port <- Sys.getenv("INTERPOLAR_DIAGNOSTIC_TEST_PORT")
  skip_if(!nzchar(port), "An isolated PostgreSQL test server was not supplied.")
  config <- list(
    DB_HOST = "127.0.0.1", DB_PORT = as.integer(port), DB_NAME = "postgres",
    DB_DATAPROCESSOR_USER = "postgres", DB_DATAPROCESSOR_PASSWORD = "diagnostic-test-secret"
  )
  root <- tempfile()
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE))
  writeLines(c(
    'DB_HOST = "127.0.0.1"', paste0("DB_PORT = ", port), 'DB_NAME = "postgres"',
    'DB_DATAPROCESSOR_USER = "postgres"', 'DB_DATAPROCESSOR_PASSWORD = "diagnostic-test-secret"'
  ), file.path(root, "cds_hub_db_config.toml"))
  report <- runDatabaseConnectionDiagnostics(root, wait_seconds = 1L)
  content <- paste(readLines(report), collapse = "\n")
  expect_match(content, "Alle Langzeittests und die neue Verbindung erfolgreich")
  expect_match(content, "Snapshot-Streaming")
  expect_match(content, "tcp_keepalives_idle")
  expect_false(grepl("diagnostic-test-secret", content, fixed = TRUE))
  settings <- readDatabaseDiagnosticSettings(config)$settings
  expect_identical(settings$setting[settings$name == "work_mem"], "32768")
  expect_identical(settings$setting[settings$name == "tcp_keepalives_idle"], "600")
  expect_identical(settings$source[settings$name == "tcp_keepalives_idle"], "session")
  target <- databaseDiagnosticConnection(config, target = TRUE)
  expect_identical(DBI::dbGetQuery(target, "SHOW tcp_keepalives_idle")[[1]], "600")
  DBI::dbDisconnect(target)
  expect_identical(settings$setting[settings$name == "TimeZone"],
    getFromNamespace("GLOBAL_TIMEZONE", "etlutils"))
  streamed <- testDatabaseDiagnosticConnection(config, "stream", 0)
  expect_equal(streamed$stream$rows, 10001L)
  expect_equal(streamed$stream$chunks, 3L)
  expect_identical(streamed$before$backend_pid, streamed$after$backend_pid)
  expect_identical(streamed$stream$target_before$backend_pid, streamed$stream$target_after$backend_pid)
  expect_false(streamed$before$backend_pid == streamed$stream$target_before$backend_pid)

  admin <- databaseDiagnosticConnection(config)
  DBI::dbExecute(admin, "ALTER ROLE postgres SET statement_timeout = '50ms'")
  DBI::dbDisconnect(admin)
  on.exit({
    cleanup <- databaseDiagnosticConnection(config)
    DBI::dbExecute(cleanup, "ALTER ROLE postgres RESET statement_timeout")
    DBI::dbDisconnect(cleanup)
  }, add = TRUE)
  result <- runDatabaseDiagnosticJobs(list(
    query = function() testDatabaseDiagnosticConnection(config, "query", 1L)
  ), timeout = 5)
  expect_identical(result$query$status, "error")
  expect_match(result$query$message, "statement timeout")
  fresh <- testDatabaseDiagnosticConnection(config, "fresh", 0)
  expect_identical(fresh$before$backend_pid, fresh$after$backend_pid)
})
