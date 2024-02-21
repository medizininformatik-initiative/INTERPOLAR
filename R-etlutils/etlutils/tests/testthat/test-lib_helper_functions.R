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
# convertDateInformation  #
###########################
#' @importFrom lubridate today

test_that("convertDateInformation converts date representations correctly", {
  # Test case 1: YYYY format
  date_column_YYYY <- c("2022", "1990", "1980")
  result_YYYY <- convertDateInformation(date_column_YYYY)
  expect_equal(result_YYYY, lubridate::as_date(c("2022-01-01", "1990-01-01", "1980-01-01")))

  # Test case 2: YYYY-MM format
  date_column_YYYY_MM <- c("2022-12", "1990-05", "1980-11")
  result_YYYY_MM <- convertDateInformation(date_column_YYYY_MM)
  expect_equal(result_YYYY_MM, lubridate::as_date(c("2022-12-01", "1990-05-01", "1980-11-01")))

  # Test case 3: Date with time, should be cleaned
  date_column_with_time <- c("2022-12-01T15:30:00", "1990-05-01T08:45:00")
  result_with_time <- convertDateInformation(date_column_with_time)
  expect_equal(result_with_time, lubridate::as_date(c("2022-12-01", "1990-05-01")))

  # Test case 4: Date with '/' separator, should be replaced with '-'
  date_column_slash_separator <- c("2022/12/01", "1990/05/01")
  result_slash_separator <- convertDateInformation(date_column_slash_separator)
  expect_equal(result_slash_separator, lubridate::as_date(c("2022-12-01", "1990-05-01")))
})

##################
# fixDateFormat  #
##################

test_that("fixDateFormat fixes uncommon date formats", {
  # Erstellen Sie einen Beispiel-Datensatz
  dt <- data.table::data.table(
    date1 = c("2022", "1990-05", "1980-11"),
    date2 = c("2022-12", "1990-05", "1980-11"),
    value = c(1, 2, 3)
  )

  # Testen Sie die Funktion mit der Zeit beizubehalten
  fixDateFormat(dt, c("date1", "date2"), preserve_time = TRUE)

  # Erwartete Ergebnisse für date1_timespec und date2_timespec
  expected_time_cols <- data.table::data.table(
    date1_timespec = c("00:00:00", "00:00:00", "00:00:00"),
    date2_timespec = c("00:00:00", "00:00:00", "00:00:00")
  )

  # Überprüfen Sie, ob die Zeit-Spalten korrekt hinzugefügt wurden
  expect_equal(dt[, .(date1_timespec, date2_timespec)], expected_time_cols)

  # Erwartete Ergebnisse für date1 und date2
  expected_date_cols <- data.table::data.table(
    date1 = as.Date(c("2022-01-01", "1990-05-01", "1980-11-01")),
    date2 = as.Date(c("2022-12-01", "1990-05-01", "1980-11-01")),
    value = c(1, 2, 3)
  )

  # Überprüfen Sie, ob die Datum-Spalten korrekt hinzugefügt wurden
  expect_equal(dt[, .(date1, date2, value)], expected_date_cols)
})

#########################
# convertTimeToPOSIXct  #
#########################

test_that("convertTimeToPOSIXct converts polar time representations to POSIXct", {
  # Test case 1: Valid time representation
  time_column_valid <- c("12:30:45", "08:15:00", "23:59:59")
  result_valid <- convertTimeToPOSIXct(time_column_valid)
  expect_equal(result_valid, c("12:30:45", "08:15:00", "23:59:59"))

  # Test case 2: NA input, should return NA
  time_column_na <- c(NA, NA, NA)
  result_na <- convertTimeToPOSIXct(time_column_na)
  expect_equal(result_na, c(NA_character_, NA_character_, NA_character_))

  # Test case 3: Empty string input, should throw an error
  time_column_empty <- c("", NA, "")
  result_na <- convertTimeToPOSIXct(time_column_empty)
  expect_equal(result_na, c(NA_character_, NA_character_, NA_character_))
})
