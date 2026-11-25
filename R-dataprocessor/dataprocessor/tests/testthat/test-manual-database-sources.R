test_that("named sources require both databases by default and isolate explicit partial runs", {
  directory <- tempfile("manual-sources-")
  project <- file.path(directory, "Example")
  dir.create(project, recursive = TRUE)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  base <- file.path(directory, "base.toml")
  writeLines(c(
    'DB_NAME = "live"', 'DB_HOST = "cds_hub"', "DB_PORT = 5432",
    'DB_DATAPROCESSOR_USER = "reader"', 'DB_DATAPROCESSOR_PASSWORD = "synthetic"',
    'DB_DATAPROCESSOR_SCHEMA_IN = "db2dataprocessor_in"',
    'DB_DATAPROCESSOR_SCHEMA_OUT = "db2dataprocessor_out"'
  ), base)
  path <- file.path(project, "database.toml")
  write_config <- function(bc) writeLines(c(
    "[sources.regular]", 'DB_NAME = "ip_regular"',
    "[sources.broad_consent]", paste0('DB_NAME = "', bc, '"')
  ), path)
  connections <- character()
  context <- NULL
  testthat::local_mocked_bindings(
    setManualStartDatabaseContext = function(db_config) context <<- db_config$DB_NAME,
    validateManualStartDatabaseConnection = function(db_config, project_name) {
      expect_equal(db_config$DB_NAME, context)
      connections <<- c(connections, context)
      if (context == "unavailable") stop("database unavailable")
    },
    getManualStartDatabaseContentType = function() "pseudonymized_snapshot",
    .package = "dataprocessor"
  )
  run <- function(args = character()) configureManualStartDatabase(
    list(PATH_TO_DB_CONFIG_TOML = base), c("example", args), project
  )
  write_config("")
  expect_error(run(), "non-empty DB_NAME")
  expect_length(connections, 0L)
  expect_equal(run("database-source=regular")$DB_NAME, "ip_regular")
  write_config("ip_bc")
  connections <- character()
  result <- run()
  expect_setequal(connections, c("ip_regular", "ip_bc"))
  expect_equal(context, result$DB_NAME)
  expect_setequal(names(attr(result, "sources")), c("regular", "broad_consent"))
  expect_equal(run("database-source=broad_consent")$DB_NAME, "ip_bc")
  expect_error(run("database-source=typo"), "Unknown database-source")
  expect_error(run(rep("database-source=regular", 2)), "only once")
  write_config("ip_regular")
  expect_error(run(), "distinct databases")
  write_config("unavailable")
  expect_error(run(), "database unavailable")
  # A deliberate regular-only run must not try to connect to the unavailable BC DB.
  connections <- character()
  run("database-source=regular")
  expect_equal(connections, "ip_regular")
})

test_that("processing switches source context before loading and running each project", {
  config <- list()
  attr(config, "manual_sources") <- list(regular = list(DB_NAME = "normal"), broad_consent = list(DB_NAME = "bc"))
  context <- NULL
  calls <- character()
  testthat::local_mocked_bindings(
    startDataprocessorModule = function(...) config,
    getCalledManualStartSubmoduleDirs = function(...) "Example",
    setManualStartDatabaseContext = function(db_config) context <<- db_config$DB_NAME,
    sourceDataprocessorSubmodules = function(...) calls <<- c(calls, paste("load", context)),
    runSubmodules = function(command_line_args, database_source, database_sources) {
      expect_equal(database_sources, c("regular", "broad_consent"))
      calls <<- c(calls, paste(database_source, context))
    }, .package = "dataprocessor"
  )
  testthat::local_mocked_bindings(
    runLevel1 = function(description, code) force(code),
    runLevel2 = function(description, code) force(code),
    dbCloseAllConnections = function() context <<- NULL,
    generateFinishMessage = function() "finished", finalize = function(...) 0L,
    .package = "etlutils"
  )
  expect_equal(processData(command_line_args = "example"), 0L)
  expect_equal(calls, c("load normal", "regular normal", "load bc", "broad_consent bc"))
  expect_null(context)
})


test_that("source selection cannot accidentally start the automatic processor", {
  expect_error(validateManualStartInvocation("database-source=regular", character()), "only valid")
})
