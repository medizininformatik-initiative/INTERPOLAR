test_that("progress messages include timestamp, timezone and readable elapsed durations", {
  output <- capture.output(logProgress("example step"))
  expect_match(output, "^\\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} .+\\] \\[Database Quality Analysis\\] example step$")
  start <- as.POSIXct("2026-01-01", tz = "UTC")
  expect_equal(formatDuration(start, start + 3661.25), "1h 1m 1.25s")
  expect_equal(formatDuration(start, start + 3600.14), "1h 0m 0.14s")
  expect_equal(formatDuration(start, start + 0.25), "0.25s")
})

test_that("timed queries preserve query, lock, return value and original errors", {
  expected <- data.table::data.table(count = 3L)
  calls <- 0L
  output <- capture.output(result <- runLoggedQuery(
    "SELECT 3",
    lock_id = "test-lock",
    label = "test step", config = list(progress_interval_seconds = 0),
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      expect_equal(query, "SELECT 3")
      expect_equal(lock_id, "test-lock")
      expected
    }
  ))
  expect_identical(result, expected)
  expect_equal(calls, 1L)
  expect_match(paste(output, collapse = "\n"), "test step: started", fixed = TRUE)
  expect_match(paste(output, collapse = "\n"), "aggregate rows", fixed = TRUE)
  output <- capture.output(expect_error(runLoggedQuery(
    "bad query",
    config = list(progress_interval_seconds = 0),
    query_fun = function(query, lock_id) stop("original database error")
  ), "original database error"))
  expect_match(paste(output, collapse = "\n"), "stopped after", fixed = TRUE)
  expect_error(runLoggedQuery("SELECT 3", config = list(progress_interval_seconds = -1)), "PROGRESS_INTERVAL_SECONDS")
  expect_equal(codeSummaryFixture()$config$progress_interval_seconds, 60)
})

test_that("blocking queries emit status and clean up timer processes on success and failure", {
  skip_on_os("windows")
  core_file <- normalizePath(testthat::test_path("..", "..", "R", "00_Core.R"))
  script <- tempfile(fileext = ".R")
  on.exit(unlink(script), add = TRUE)
  writeLines(c(
    paste0("source(", encodeString(core_file, quote = '"'), ")"),
    "config <- list(progress_interval_seconds=0.02)",
    "result <- runLoggedQuery('test',config=config,query_fun=function(query,lock_id){Sys.sleep(0.12);data.frame(count=1L)})",
    "stopifnot(result$count==1L,is.null(parallel::mccollect(wait=FALSE)))",
    "error <- try(runLoggedQuery('test',config=config,query_fun=function(query,lock_id){Sys.sleep(0.08);stop('failure-test')}),silent=TRUE)",
    "stopifnot(inherits(error,'try-error'),grepl('failure-test',error),is.null(parallel::mccollect(wait=FALSE)))"
  ), script)
  output <- system2(file.path(R.home("bin"), "Rscript"), shQuote(script), stdout = TRUE, stderr = TRUE)
  expect_null(attr(output, "status"))
  expect_true(any(grepl("still running after", output, fixed = TRUE)))
  expect_true(any(grepl("stopped after", output, fixed = TRUE)))
})
