test_that("the full cohort command checks both sources and runs one worker per source", {
  root <- tempfile("cohort-cli-")
  project <- file.path(root, "Cohort_Description")
  dir.create(project, recursive = TRUE)
  on.exit(unlink(root, recursive = TRUE))
  writeLines(c(
    "[sources.regular]", 'DB_NAME = "regular"',
    "[sources.broad_consent]", 'DB_NAME = "bc"'
  ), file.path(project, "database.toml"))
  calls <- character()
  failed_source <- ""
  preflight_fails <- FALSE
  testthat::local_mocked_bindings(
    validateManualStartInvocation = function(...) project,
    init = function() list(),
    configureManualStartDatabase = function(config, args) {
      calls <<- c(calls, "preflight")
      if (preflight_fails) stop("Source not reachable")
    },
    runDataProcessorWorker = function(script_path, args) {
      source <- tail(args, 1L)
      calls <<- c(calls, source)
      if (source == failed_source) 137L else 0L
    },
    processData = function(command_line_args) {
      calls <<- c(calls, "direct")
      0L
    }
  )
  testthat::local_mocked_bindings(
    dbCloseAllConnections = function() calls <<- c(calls, "close"),
    .package = "etlutils"
  )
  run <- function(...) processDataCommandLine("StartDataProcessor.R", c("cohort-description", ...))
  expect_equal(run(), 0L)
  expect_identical(calls[1:2], c("preflight", "close"))
  expect_setequal(calls[3:4], c("database-source=regular", "database-source=broad_consent"))
  failed_source <- calls[3]
  calls <- character()
  expect_equal(run(), 137L)
  expect_identical(calls, c("preflight", "close", failed_source))
  calls <- character()
  expect_equal(run("database-source=regular"), 0L)
  expect_identical(calls, "direct")
  calls <- character()
  preflight_fails <- TRUE
  expect_error(run(), "Source not reachable")
  expect_identical(calls, c("preflight", "close"))
})

test_that("the worker uses a separate R process and preserves its exit code", {
  directory <- tempfile("cohort worker ")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE))
  script <- file.path(directory, "test worker.R")
  writeLines(c(
    "args <- commandArgs(trailingOnly = TRUE)",
    'stopifnot(identical(args[1], "two words"), Sys.getpid() != as.integer(args[2]))',
    'quit(status = 19L, save = "no")'
  ), script)
  expect_equal(runDataProcessorWorker(script, c("two words", as.character(Sys.getpid()))), 19L)
})
