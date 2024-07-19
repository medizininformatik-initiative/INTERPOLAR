##############
# isSimpleNA #
##############

# Test for simple NA
test_that("isSimpleNA returns TRUE for a simple NA", {
  x <- NA
  expect_true(isSimpleNA(x))
})

# Test for vector with multiple elements including NA
test_that("isSimpleNA returns FALSE for a vector with multiple elements", {
  y <- c(1, NA, 3)
  expect_false(isSimpleNA(y))
})

# Test for non-NA values
test_that("isSimpleNA returns FALSE for non-NA values", {
  z <- 1
  expect_false(isSimpleNA(z))
  a <- "Hello"
  expect_false(isSimpleNA(a))
})

# Test for other types of NA values
test_that("isSimpleNA handles other types of NA values correctly", {
  na_int <- NA_integer_
  expect_true(isSimpleNA(na_int))
  na_real <- NA_real_
  expect_true(isSimpleNA(na_real))
  na_char <- NA_character_
  expect_true(isSimpleNA(na_char))
})

# Test for empty values or NULL
test_that("isSimpleNA returns FALSE for empty values or NULL", {
  empty_vec <- numeric(0)
  expect_false(isSimpleNA(empty_vec))
  null_val <- NULL
  expect_false(isSimpleNA(null_val))
})

######################
# isSimpleTrueOrNot0 #
######################

# Test for simple TRUE
test_that("isSimpleTrueOrNot0 returns TRUE for a simple TRUE", {
  expect_true(isSimpleTrueOrNot0(TRUE))
})

# Test for non-zero numeric value
test_that("isSimpleTrueOrNot0 returns TRUE for a non-zero numeric value", {
  expect_true(isSimpleTrueOrNot0(1))
  expect_true(isSimpleTrueOrNot0(-1))
})

# Test for 0 as input value
test_that("isSimpleTrueOrNot0 returns FALSE for 0", {
  expect_false(isSimpleTrueOrNot0(0))
})

# Test for vector with multiple elements
test_that("isSimpleTrueOrNot0 returns FALSE for a vector with multiple elements", {
  expect_false(isSimpleTrueOrNot0(c(TRUE, TRUE)))
})

# Test for false values and other data types
test_that("isSimpleTrueOrNot0 returns FALSE for FALSE and other data types", {
  expect_false(isSimpleTrueOrNot0(FALSE))
  expect_false(isSimpleTrueOrNot0("TRUE"))
  expect_false(isSimpleTrueOrNot0(NA))
})

####################
# isSimpleFalseOr0 #
####################

# Test for simple FALSE
test_that("isSimpleFalseOr0 returns TRUE for a simple FALSE", {
  expect_true(isSimpleFalseOr0(FALSE))
})

# Test for 0 as input value
test_that("isSimpleFalseOr0 returns TRUE for 0", {
  expect_true(isSimpleFalseOr0(0))
})

# Test for non-zero numeric value
test_that("isSimpleFalseOr0 returns FALSE for a non-zero numeric value", {
  expect_false(isSimpleFalseOr0(1))
  expect_false(isSimpleFalseOr0(-1))
})

# Test for vector with multiple elements
test_that("isSimpleFalseOr0 returns FALSE for a vector with multiple elements", {
  expect_false(isSimpleFalseOr0(c(FALSE, FALSE)))
})

# Test for true values and other data types
test_that("isSimpleFalseOr0 returns FALSE for TRUE and other data types", {
  expect_false(isSimpleFalseOr0(TRUE))
  expect_false(isSimpleFalseOr0("FALSE"))
  expect_false(isSimpleFalseOr0(NA))
})

##########################
# isSimpleNotEmptyString #
##########################

# Test for non-empty character string
test_that("isSimpleNotEmptyString returns TRUE for a non-empty character string", {
  expect_true(isSimpleNotEmptyString("hello"))
})

# Test for empty character string
test_that("isSimpleNotEmptyString returns FALSE for an empty character string", {
  expect_false(isSimpleNotEmptyString(""))
})

# Test for NA value
test_that("isSimpleNotEmptyString returns FALSE for NA", {
  expect_false(isSimpleNotEmptyString(NA))
})

# Test for numeric value
test_that("isSimpleNotEmptyString returns FALSE for a numeric value", {
  expect_false(isSimpleNotEmptyString(123))
})

# Test for vector with multiple elements
test_that("isSimpleNotEmptyString returns FALSE for a vector with multiple elements", {
  expect_false(isSimpleNotEmptyString(c("hello", "world")))
})

###########
# isError #
###########

# Test case 1: Object is a try-error
test_that("isError returns TRUE for try-error object", {
  result <- try(log("a"), silent = TRUE)
  expect_true(isError(result))
})

# Test case 2: Object is not a try-error
test_that("isError returns FALSE for non-try-error object", {
  numeric_result <- 42
  expect_false(isError(numeric_result))
})

# Test case 3: Object is NA
test_that("isError returns FALSE for NA", {
  expect_false(isError(NA))
})

########
# isOK #
########

# Test case 1: Object is an error (try-error)
test_that("isOK returns FALSE for try-error object", {
  result <- try(log("a"), silent = TRUE)
  expect_false(isOK(result))
})

# Test case 2: Object is not an error (non-try-error)
test_that("isOK returns TRUE for non-try-error object", {
  numeric_result <- 42
  expect_true(isOK(numeric_result))
})

###########
# isDebug #
###########

# Test case 1: Debugging mode enabled (DEBUG = TRUE)
test_that("isDebug returns TRUE when DEBUG variable is TRUE", {
  assign("DEBUG", TRUE, envir = .GlobalEnv)
  expect_true(isDebug())
})

# Test case 2: Debugging mode disabled (DEBUG not set or FALSE)
test_that("isDebug returns FALSE when DEBUG variable is not set or FALSE", {
  if (exists("DEBUG", envir = .GlobalEnv)) remove("DEBUG", envir = .GlobalEnv)
  expect_false(isDebug())

  assign("DEBUG", FALSE, envir = .GlobalEnv)
  expect_false(isDebug())
})

# Clean up after tests
if (exists("DEBUG", envir = .GlobalEnv)) remove("DEBUG", envir = .GlobalEnv)

##############
# checkError #
##############

# Test case 1: No Error Case
test_that("checkError returns result of expr_ok for non-error object", {
  result <- checkError(42, "No error", "Error occurred")
  expect_equal(result, "No error")
})

# Test case 2: Error Case
test_that("checkError returns result of expr_err for try-error object", {
  result <- checkError(try(log("a"), silent = TRUE), "No error", "Error occurred")
  expect_equal(result, "Error occurred")
})

# Test case 3: Custom Expressions
test_that("checkError handles custom expressions correctly", {
  result_ok <- checkError("some_value", "OK", "Error")
  result_err <- checkError(try(log("a"), silent = TRUE), "OK", "Error occurred")
  expect_equal(result_ok, "OK")
  expect_equal(result_err, "Error occurred")
})

#########################
# convertVerboseNumbers #
#########################

# Test for positive numbers less than or equal to 3
test_that("convertVerboseNumbers converts numbers correctly (1st, 2nd, 3rd)", {
  input <- c(1, 2, 3)
  expected <- c("1st", "2nd", "3rd")
  result <- convertVerboseNumbers(input)
  expect_equal(result, expected)
})

# Test for numbers greater than 3
test_that("convertVerboseNumbers converts numbers greater than 3 to 'th'", {
  input <- c(4, 5, 6)
  expected <- c("4th", "5th", "6th")
  result <- convertVerboseNumbers(input)
  expect_equal(result, expected)
})

# Test for numbers less than 1
test_that("convertVerboseNumbers converts numbers less than 1 to 'th'", {
  input <- c(-1, 0)
  expected <- c("-1th", "0th")
  result <- convertVerboseNumbers(input)
  expect_equal(result, expected)
})

# Test for fixed numbers
test_that("convertVerboseNumbers converts mixed numbers correctly", {
  input <- c(1, 2, 3, 4, 5, 6, -1, 0)
  expected <- c("1st", "2nd", "3rd", "4th", "5th", "6th", "-1th", "0th")
  result <- convertVerboseNumbers(input)
  expect_equal(result, expected)
})

# Test for empty input
test_that("convertVerboseNumbers returns empty vector for empty input", {
  input <- numeric(0)
  expected <- character(0)
  result <- convertVerboseNumbers(input)
  expect_equal(result, expected)
})

#########################
# convertIntegerFormat  #
#########################

test_that("convertIntegerFormat function works correctly", {
  # Test case 1: Valid integer conversion
  dt <- data.table(column1 = c("1", "2", "3", "4"),
                   column2 = c(NA, "6", "", "8"))
  convertIntegerFormat(dt, "column1")
  convertIntegerFormat(dt, "column2")
  expect_equal(as.integer(dt$column1), c(1, 2, 3, 4))
  expect_equal(as.integer(dt$column2), c(NA, 6, NA, 8))

  # Test case 2: Empty input, should not throw an error
  dt <- data.table(column1 = character(0),
                   column2 = character(0))
  convertIntegerFormat(dt, "column1")
  convertIntegerFormat(dt, "column2")
  expect_equal(nrow(dt), 0)

  # Test case 3: NA input, should not throw an error
  dt <- data.table(column1 = NA_character_,
                   column2 = NA_character_)
  convertIntegerFormat(dt, "column1")
  convertIntegerFormat(dt, "column2")
  expect_equal(nrow(dt), 1)
})

#########################
# convertDecimalFormat  #
#########################

test_that("convertDecimalFormat converts strings to decimals", {
  # Test case 1: Valid decimal conversion
  dt <- data.table(column1 = c("1.5", "2.3", NA, "4"),
                   column2 = c("1", "6.2", "", "8.9"))
  convertDecimalFormat(dt, "column1")
  convertDecimalFormat(dt, "column2")
  expect_equal(as.numeric(dt$column1), c(1.5, 2.3, NA, 4))
  expect_equal(as.numeric(dt$column2), c(1, 6.2, NA, 8.9))

  # Test case 2: Empty input, should not throw an error
  dt <- data.table(column1 = character(0),
                   column2 = character(0))
  convertDecimalFormat(dt, "column1")
  convertDecimalFormat(dt, "column2")
  expect_equal(nrow(dt), 0)

  # Test case 3: NA input, should not throw an error
  dt <- data.table(column1 = NA_character_,
                   column2 = NA_character_)
  convertDecimalFormat(dt, "column1")
  convertDecimalFormat(dt, "column2")
  expect_equal(nrow(dt), 1)
})

#########################
# convertBooleanFormat  #
#########################

test_that("convertBooleanFormat converts strings to boolean values", {
  # Test case 1: Valid boolean conversion
  dt <- data.table(column1 = c("TRUE", "FALSE", "TRUE", NA),
                   column2 = c("NA", "TRUE", "", "FALSE"))
  convertBooleanFormat(dt, "column1")
  convertBooleanFormat(dt, "column2")
  expect_equal(as.logical(dt$column1), c(TRUE, FALSE, TRUE, NA))
  expect_equal(as.logical(dt$column2), c(NA, TRUE, NA, FALSE))

  # Test case 2: Empty input, should not throw an error
  dt <- data.table(column1 = character(0),
                   column2 = character(0))
  convertBooleanFormat(dt, "column1")
  convertBooleanFormat(dt, "column2")
  expect_equal(nrow(dt), 0)

  # Test case 3: NA input, should not throw an error
  dt <- data.table(column1 = NA_character_,
                   column2 = NA_character_)
  convertBooleanFormat(dt, "column1")
  convertBooleanFormat(dt, "column2")
  expect_equal(nrow(dt), 1)
})
