# Load only the actual error handler, without starting the toolchain or connecting to services.
loadToolchainErrorHandler <- function(env) {
  expressions <- parse(testthat::test_path("..", "..", "..", "StartCDSToolChain.R"))
  handlers <- Filter(function(expr) {
    is.call(expr) && identical(expr[[1]], as.name("tryCatch")) && "error" %in% names(expr)
  }, as.list(expressions))
  stopifnot(length(handlers) == 1L)
  eval(handlers[[1]][["error"]], envir = env)
}

test_that("expected column errors return without requiring a debug loop", {
  env <- new.env(parent = baseenv())
  handler <- loadToolchainErrorHandler(env)
  for (debug_index in list(NULL, 1L, 2L)) {
    env$i <- debug_index
    env$DEBUG_DATES <- c("day1", "day2")
    expect_message(
      expect_null(handler(simpleError("column foo of relation bar does not exist"))),
      "Ignoring expected error: column foo of relation bar does not exist",
      fixed = TRUE
    )
  }
})

test_that("unexpected toolchain errors retain their message and failure exit status", {
  logged <- NULL
  exit_status <- NULL
  testthat::local_mocked_bindings(
    isErrorOccured = function() FALSE,
    catErrorMessage = function(msg) logged <<- msg,
    .package = "etlutils"
  )
  env <- new.env(parent = baseenv())
  env$quit <- function(status, save) {
    exit_status <<- status
    expect_identical(save, "no")
  }
  handler <- loadToolchainErrorHandler(env)
  handler(simpleError("original error"))
  expect_identical(logged, "original error")
  expect_identical(exit_status, 1)
})

test_that("already logged module errors return to the existing final status handling", {
  testthat::local_mocked_bindings(
    isErrorOccured = function() TRUE,
    catErrorMessage = function(...) stop("must not log twice"),
    .package = "etlutils"
  )
  env <- new.env(parent = baseenv())
  env$quit <- function(...) stop("must not quit inside the handler")
  expect_null(loadToolchainErrorHandler(env)(simpleError("module error")))
})
