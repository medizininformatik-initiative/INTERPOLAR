test_that("report dates follow the MRP_Check argument convention", {
  arguments <- c("statistical-reports", "start-date=2025-09-01", "end-date=2025-09-08")
  shared <- etlutils::initCommandLineArguments(command_arguments = arguments)
  parsed <- parseNamedArgs(arguments)
  expect_identical(parsed[["REPORT_PERIOD_START"]], as.character(shared$start_date))
  expect_identical(parsed[["REPORT_PERIOD_END"]], as.character(shared$end_date))
  expect_false("WRITE_TABLE_LOCAL" %in% names(parsed))
})

test_that("existing reporting arguments remain compatible", {
  current <- parseNamedArgs(c("start-date=2025-09-01", "end-date=2025-09-08", "--local"))
  legacy <- parseNamedArgs(c(
    "REPORT_PERIOD_START=2025-09-01", "REPORT_PERIOD_END=2025-09-08", "WRITE_TABLE_LOCAL=TRUE"
  ))
  expect_identical(current, legacy)
  expect_identical(
    parseNamedArgs("REPORT_PERIOD_START=2025/09/01")[["REPORT_PERIOD_START"]],
    "2025-09-01"
  )
  expect_identical(parseNamedArgs("WRITE_TABLE_LOCAL=FALSE")[["WRITE_TABLE_LOCAL"]], "FALSE")
  expect_identical(parseNamedArgs(character()), character())
  expect_identical(parseNamedArgs("statistical-reports"), character())
})

test_that("explicit local output and repeated date arguments have defined precedence", {
  for (arguments in list(
    c("--local", "WRITE_TABLE_LOCAL=FALSE"),
    c("WRITE_TABLE_LOCAL=FALSE", "--local")
  )) {
    expect_identical(parseNamedArgs(arguments)[["WRITE_TABLE_LOCAL"]], "TRUE")
  }
  expect_identical(
    parseNamedArgs(c("REPORT_PERIOD_START=2025-01-01", "start-date=2025-02-01"))[["REPORT_PERIOD_START"]],
    "2025-02-01"
  )
  expect_identical(
    parseNamedArgs(c("end-date=2025-02-01", "REPORT_PERIOD_END=2025-03-01"))[["REPORT_PERIOD_END"]],
    "2025-03-01"
  )
})

test_that("the reporting entry point applies CLI arguments and preserves defaults", {
  original_parser <- parseNamedArgs
  arguments <- character()
  observed <- NULL
  testthat::local_mocked_bindings(
    parseNamedArgs = function() original_parser(arguments),
    getFirstWardStart = function() as.Date("2025-01-01"),
    getLastWardEnd = function() as.Date("2025-12-31"),
    getWardStartsAndEnds = function() data.frame(),
    getPatientData = function(...) {
      frame <- parent.frame()
      observed <<- list(
        start = frame$REPORT_PERIOD_START, end = frame$REPORT_PERIOD_END,
        local = frame$WRITE_TABLE_LOCAL
      )
      stop("stop before database access")
    }
  )
  for (arguments in list(
    character(),
    c("start-date=2025-09-01", "end-date=2025-09-08", "--local"),
    c("REPORT_PERIOD_START=2025-09-01", "REPORT_PERIOD_END=2025-09-08", "WRITE_TABLE_LOCAL=TRUE"),
    "WRITE_TABLE_LOCAL=FALSE"
  )) {
    expect_error(suppressMessages(capture.output(createStatisticalReport())), "stop before database access")
    if (length(arguments) > 1L) {
      expect_identical(observed, list(start = "2025-09-01", end = "2025-09-08", local = TRUE))
    } else {
      expect_identical(observed, list(
        start = "2025-01-01",
        end = as.character(min(as.Date("2025-12-31"), Sys.Date())), local = FALSE
      ))
    }
  }
})
