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

###

 # Hier fehlen noch Tests für viele Funktionen

##

###########################
# replacePatternsInString #
###########################

# Test for case-insensitive replacement
test_that("replacePatternsInString performs case-insensitive replacement correctly", {
  patternsAndReplacements <- list("HELLO" = "hi", "WORLD" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello World!", ignore.case = TRUE)
  expect_equal(result, "hi earth!")
})

# Test for case-sensitive replacement
test_that("replacePatternsInString performs case-sensitive replacement correctly", {
  patternsAndReplacements <- list("Hello" = "hi", "World" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello World!", ignore.case = FALSE)
  expect_equal(result, "hi earth!")
})

# Test for Perl-compatible regex usage
test_that("replacePatternsInString handles Perl-compatible regexps correctly", {
  patternsAndReplacements <- list("\\bworld\\b" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello world!", perl = TRUE)
  expect_equal(result, "Hello earth!")
})

# Test for combination of ignore.case and perl
test_that("replacePatternsInString handles combination of ignore.case and perl correctly", {
  patternsAndReplacements <- list("\\bWORLD\\b" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello WORLD!", ignore.case = TRUE, perl = TRUE)
  expect_equal(result, "hello earth!")
})

# Test when no matches are found
test_that("replacePatternsInString returns the original string when no matches are found", {
  patternsAndReplacements <- list("xyz" = "abc")
  result <- replacePatternsInString(patternsAndReplacements, "hello world!", ignore.case = FALSE)
  expect_equal(result, "hello world!")
})

###########################
# convertDateFormat  #
###########################

test_that("convertDateFormat converts date representations correctly", {
  # Create a sample data table
  dt <- data.table(date_column = c("2022", "2023-02", "2024/03/18", "2025-04-20T12:30:45", NA))

  # Apply the function to the column
  convertDateFormat(dt, "date_column")

  # Check the results
  expect_equal(dt$date_column, as.Date(c("2022-01-01", "2023-02-01", "2024-03-18", "2025-04-20", NA)))
})

#########################
# convertTimeFormat     #
#########################

test_that("convertTimeFormat converts polar time representations to POSIXct", {
  # Create a test data.table
  dt <- data.table(time_column = c("12:30:45", "08:15:00", "23:59:59", "13:45:22.123456789", NA, ""))
  # Call the function
  convertTimeFormat(dt, "time_column")
  # Check specific time values
  expect_equal(dt$time_column[1], as.POSIXct("1970-01-01 12:30:45", tz = "UTC"))
  expect_equal(dt$time_column[2], as.POSIXct("1970-01-01 08:15:00", tz = "UTC"))
  expect_equal(dt$time_column[3], as.POSIXct("1970-01-01 23:59:59", tz = "UTC"))
  expect_equal(dt$time_column[4], as.POSIXct("1970-01-01 13:45:22", tz = "UTC"))
  expect_true(is.na(dt$time_column[5]))  # Check NA value
  expect_true(is.na(dt$time_column[6]))  # Check NA value
})

#########################
# convertDateTimeFormat #
#########################

test_that("convertDateTimeFormat function converts datetime columns correctly", {
  # Test case 1: Valid time representation
  dt <- data.table(datetime_column = c("2018", "1973-06", "1905-08-23",
                               "2015-02-07T13:28:17+01:00", "2015-02-07T13:28:17+03:00",
                               "2017-01-01T00:00:00.000Z", NA))
  convertDateTimeFormat(dt, "datetime_column")
  # Check if the datetime columns are converted properly
  expect_equal(dt$datetime_column[1], as.POSIXct("2018-01-01 00:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[2], as.POSIXct("1973-06-01 00:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[3], as.POSIXct("1905-08-23 00:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[4], as.POSIXct("2015-02-07 13:28:17", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[5], as.POSIXct("2015-02-07 11:28:17", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[6], as.POSIXct("2017-01-01 01:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[7], as.POSIXct(NA, tz = "Europe/Berlin"))
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
