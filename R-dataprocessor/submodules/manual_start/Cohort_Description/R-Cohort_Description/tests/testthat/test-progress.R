test_that("step progress preserves values, caller assignments and error conditions", {
  assigned <- NULL
  output <- capture.output(result <- runCohortStep("Example", {
    assigned <- 42
    invisible(assigned)
  }))
  expect_equal(assigned, 42)
  expect_equal(result, 42)
  expect_match(output[1], "Example.*starting")
  expect_match(output[2], "Example.*completed.*\\(.+\\)")
  output <- capture.output(visible <- withVisible(runCohortStep("Invisible", invisible(42))))
  expect_false(visible$visible)
  failure <- simpleError("original failure")
  output <- capture.output(result <- tryCatch(runCohortStep("Failure", stop(failure)), error = identity))
  expect_identical(result, failure)
  expect_match(output[2], "Failure.*failed.*\\(.+\\)")
  expect_false(any(grepl("completed", output)))
})

test_that("export reports every workbook with a site-wide counter and population labels", {
  fixture <- cohortFixture()
  wards <- data.table::rbindlist(list(fixture$wards, data.table::copy(fixture$wards)[, ward_name := "B"]))
  directory <- tempfile("cohort-progress-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  writes <- 0L
  testthat::local_mocked_bindings(
    calculateCohortCells = function(...) data.table::data.table(),
    writeCohortWorkbook = function(...) {
      writes <<- writes + 1L
    },
    .package = "CohortDescription"
  )
  output <- capture.output(manifest <- exportCohortDescription(fixture$cases, wards, "UTC", "site", directory))
  starts <- output[grepl("starting", output)]
  finishes <- output[grepl("completed", output)]
  expect_length(starts, 42L)
  expect_length(finishes, 42L)
  expect_equal(writes, 42L)
  expect_equal(nrow(manifest), 42L)
  expect_match(starts[1], "File 1 of 42: A / BS / FAS 1")
  expect_match(starts[22], "File 22 of 42: B / BS / FAS 1")
  expect_match(finishes[42], "File 42 of 42: B / CRS B / FAS 4.2.*completed")
  expect_false(any(grepl("remaining|ETA", output)))
})
