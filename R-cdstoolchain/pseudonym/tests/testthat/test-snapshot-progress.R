test_that("snapshot progress reaches stdout and the existing log sink", {
  log_path <- tempfile()
  log_connection <- file(log_path, open = "wt")
  on.exit({
    close(log_connection)
    unlink(log_path)
  })
  output <- utils::capture.output({
    sink(log_connection, split = TRUE)
    tryCatch(snapshotProgress("Processed table patient: ", 5L, " rows"),
      finally = sink()
    )
  })
  flush(log_connection)
  expect_match(output, "Processed table patient: 5 rows", fixed = TRUE)
  expect_identical(readLines(log_path), output)
})

test_that("snapshot phases use the standard logger and its clock", {
  clock <- getFromNamespace("Clock", "etlutils")$new()
  testthat::local_mocked_bindings(getClock = function() clock, .package = "etlutils")
  had_verbose <- exists("VERBOSE", envir = .GlobalEnv, inherits = FALSE)
  old_verbose <- if (had_verbose) get("VERBOSE", envir = .GlobalEnv) else NULL
  assign("VERBOSE", 100L, envir = .GlobalEnv)
  on.exit({
    if (had_verbose) assign("VERBOSE", old_verbose, envir = .GlobalEnv) else
      rm("VERBOSE", envir = .GlobalEnv)
  })
  count <- 0L
  output <- utils::capture.output(result <- runPseudonymizationLogStep(2L, "Test phase", {
    count <- count + 1L
    runPseudonymizationLogStep(3L, "Test table", list(value = 7L))
  }))
  expect_identical(count, 1L)
  expect_identical(result, list(value = 7L))
  expect_true(any(grepl("Test phase", output, fixed = TRUE)))
  history <- clock$complete()
  steps <- history[history$msg %in% c("Test phase", "Test table"), ]
  expect_equal(nrow(steps), 2L)
  expect_true(all(steps$state == "OK"))
  expect_true(all(!is.na(steps$start) & !is.na(steps$end)))
  expect_true(all(steps$end >= steps$start))
})
