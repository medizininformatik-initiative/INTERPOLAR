####################
# isDefinedAndTrue #
####################

# Test if a variable is defined and TRUE
test_that("Variable is defined and TRUE", {
  var1 <- TRUE
  expect_true(isDefinedAndTrue("var1"))
})

# Test if a variable is defined and FALSE
test_that("Variable is defined and FALSE", {
  var2 <- FALSE
  expect_false(isDefinedAndTrue("var2"))
})

# Test if a variable is not defined
test_that("Variable is not defined", {
  expect_false(isDefinedAndTrue("var3"))
})

# Test if a variable is defined but not a logical value
test_that("Variable is defined but not a logical value", {
  var4 <- "TRUE"
  expect_false(isDefinedAndTrue("var4"))
})

# Test if a variable is defined and TRUE in a specified environment
test_that("Variable is defined and TRUE in a specified environment", {
  test_env <- new.env()
  assign("var5", TRUE, envir = test_env)
  expect_true(isDefinedAndTrue("var5", envir = test_env))
})

# Test if a variable is defined and FALSE in a specified environment
test_that("Variable is defined and FALSE in a specified environment", {
  test_env <- new.env()
  assign("var6", FALSE, envir = test_env)
  expect_false(isDefinedAndTrue("var6", envir = test_env))
})

# Test if a variable is not defined in a specified environment
test_that("Variable is not defined in a specified environment", {
  test_env <- new.env()
  expect_false(isDefinedAndTrue("var7", envir = test_env))
})

########################
# isDefinedAndNotEmpty #
########################

# Test if a variable is defined and not empty in a specified environment
test_that("Variable is defined and not empty in a specified environment", {
  test_env <- new.env()
  assign("var1", "some text", envir = test_env)
  expect_true(isDefinedAndNotEmpty("var1", envir = test_env))
})

# Test if a variable is empty in a specified environment
test_that("Variable is empty in a specified environment", {
  test_env <- new.env()
  assign("var2", "", envir = test_env)
  assign("var3", character(0), envir = test_env)
  expect_false(isDefinedAndNotEmpty("var2", envir = test_env))
  expect_false(isDefinedAndNotEmpty("var3", envir = test_env))
})

# Test if a variable is defined and not empty in a named list
test_that("Variable is defined and not empty in a named list", {
  test_config <- list(var1 = "some text", var2 = c("", "some text"))
  expect_true(isDefinedAndNotEmpty("var1", envir = test_config))
  expect_true(isDefinedAndNotEmpty("var2", envir = test_config))
})

# Test if a variable is empty or missing in a named list
test_that("Variable is empty or missing in a named list", {
  test_config <- list(var1 = "", var2 = character(0), var3 = list())
  expect_false(isDefinedAndNotEmpty("var1", envir = test_config))
  expect_false(isDefinedAndNotEmpty("var2", envir = test_config))
  expect_false(isDefinedAndNotEmpty("var3", envir = test_config))
  expect_false(isDefinedAndNotEmpty("var4", envir = test_config))
})

################
# checkVersion #
################

resetVersionCheck <- function() {
  .lib_envir_env[["VERSION_ALREADY_CHECKED"]] <- NULL
}

test_that("older database versions remain blocked by default", {
  resetVersionCheck()
  on.exit(resetVersionCheck())
  testthat::local_mocked_bindings(
    dbGetVersion = function() "2.0.0",
    getReleaseVersion = function() "2.1.0",
    .package = "etlutils"
  )

  expect_error(
    checkVersion(ignore_newer_db_version = FALSE),
    "database version '2.0.0' is older than the release version '2.1.0'"
  )
})

test_that("older database versions warn but continue for historical analyses", {
  resetVersionCheck()
  on.exit(resetVersionCheck())
  testthat::local_mocked_bindings(
    dbGetVersion = function() "2.0.0",
    getReleaseVersion = function() "2.1.0",
    .package = "etlutils"
  )

  expect_warning(
    checkVersion(
      ignore_newer_db_version = FALSE,
      allow_older_db_version = TRUE
    ),
    paste0(
      "database version '2.0.0' is older than the release version '2.1.0'. ",
      "Continuing with the manual analysis"
    )
  )
  expect_true(isDefinedAndTrue("VERSION_ALREADY_CHECKED", .lib_envir_env))
})

test_that("newer database versions remain blocked for historical analyses", {
  resetVersionCheck()
  on.exit(resetVersionCheck())
  testthat::local_mocked_bindings(
    dbGetVersion = function() "2.2.0",
    getReleaseVersion = function() "2.1.0",
    .package = "etlutils"
  )

  expect_error(
    checkVersion(
      ignore_newer_db_version = FALSE,
      allow_older_db_version = TRUE
    ),
    "database version '2.2.0' is newer than the release version '2.1.0'"
  )
})
