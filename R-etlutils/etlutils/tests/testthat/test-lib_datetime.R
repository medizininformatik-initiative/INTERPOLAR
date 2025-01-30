###########################
# as.POSIXctWithTimezone  #
###########################

test_that("as.POSIXctWithTimezone works with default format", {
  global_timezone <- "Europe/Berlin"
  # Test with default format (auto-detection)
  result <- as.POSIXctWithTimezone("2025-01-01 12:00:00")
  expect_equal(result, as.POSIXct("2025-01-01 12:00:00", tz = global_timezone))

  # Test with date-only input
  result <- as.POSIXctWithTimezone("2025-01-01")
  expect_equal(result, as.POSIXct("2025-01-01", tz = global_timezone))
})

test_that("as.POSIXctWithTimezone works with a specified format", {
  global_timezone <- "Europe/Berlin"
  # Test with a custom format
  result <- as.POSIXctWithTimezone("01/01/2025 12:00:00", format = "%d/%m/%Y %H:%M:%S")
  expect_equal(result, as.POSIXct("2025-01-01 12:00:00", tz = global_timezone))

  # Test with another custom format
  result <- as.POSIXctWithTimezone("2025.01.01 12:00", format = "%Y.%m.%d %H:%M")
  expect_equal(result, as.POSIXct("2025-01-01 12:00:00", tz = global_timezone))
})

test_that("as.POSIXctWithTimezone handles NA inputs correctly", {
  global_timezone <- "Europe/Berlin"
  # Test with NA input
  result <- as.POSIXctWithTimezone(NA)
  expect_true(is.na(result))
})

test_that("as.POSIXctWithTimezone respects timezone parameter", {
  # Test with a different timezone
  result <- as.POSIXctWithTimezone("2025-01-01 12:00:00", tz = "UTC")
  expect_equal(result, as.POSIXct("2025-01-01 12:00:00", tz = "UTC"))

  result <- as.POSIXctWithTimezone("2025-01-01 12:00:00", tz = "America/New_York")
  expect_equal(result, as.POSIXct("2025-01-01 12:00:00", tz = "America/New_York"))
})

test_that("as.POSIXctWithTimezone works with numeric input", {
  global_timezone <- "Europe/Berlin"
  # Test with numeric input (seconds since epoch)
  result <- as.POSIXctWithTimezone(1672449600) # Corresponds to 2023-01-01 12:00:00 UTC
  expect_equal(result, as.POSIXct(1672449600, origin = "1970-01-01", tz = global_timezone))
})

########################
# as.DateWithTimezone  #
########################

test_that("as.DateWithTimezone works with default format", {
  global_timezone <- "Europe/Berlin"
  # Test with default format (auto-detection)
  result <- as.DateWithTimezone("2025-01-01")
  expect_equal(result, as.Date("2025-01-01"))

  # Test with a date-time string
  result <- as.DateWithTimezone("2025-01-01 12:00:00")
  expect_equal(result, as.Date("2025-01-01"))
})

test_that("as.DateWithTimezone works with a specified format", {
  global_timezone <- "Europe/Berlin"
  # Test with a custom format
  result <- as.DateWithTimezone("01/01/2025", format = "%d/%m/%Y")
  expect_equal(result, as.Date("2025-01-01"))

  # Test with another custom format
  result <- as.DateWithTimezone("2025.01.01", format = "%Y.%m.%d")
  expect_equal(result, as.Date("2025-01-01"))
})

test_that("as.DateWithTimezone works with POSIXct input", {
  global_timezone <- "Europe/Berlin"
  # Test with POSIXct input
  input <- as.POSIXct("2025-01-01 12:00:00", tz = "UTC")
  result <- as.DateWithTimezone(input, tz = global_timezone)
  expect_equal(result, as.Date("2025-01-01"))
})

test_that("as.DateWithTimezone handles NA inputs correctly", {
  global_timezone <- "Europe/Berlin"
  # Test with NA input
  result <- as.DateWithTimezone(NA)
  expect_true(is.na(result))
})

test_that("as.DateWithTimezone ignores tz for character input", {
  global_timezone <- "Europe/Berlin"
  # The `tz` parameter has no effect on character input
  result1 <- as.DateWithTimezone("2025-01-01", tz = "UTC")
  result2 <- as.DateWithTimezone("2025-01-01", tz = "America/New_York")
  expect_equal(result1, result2)
  expect_equal(result1, as.Date("2025-01-01"))
})

######################
# convertDateFormat  #
######################

test_that("convertDateFormat converts date representations correctly", {
  # Create a sample data table
  dt <- data.table(date_column = c("2022", "2023-02", "2024/03/18", "2025-04-20T12:30:45", NA))

  # Apply the function to the column
  suppressMessages(convertDateFormat(dt, "date_column"))

  # Check the results
  expect_equal(dt$date_column, as.Date(c("2022-01-01", "2023-02-01", "2024-03-18", "2025-04-20", NA)))
})

#####################
# convertTimeFormat #
#####################

test_that("convertTimeFormat correctly converts valid time strings", {
  dt <- data.table(
    id = 1:3,
    time_column = c("08:00:00", "15:30:00", "12:45:00")
  )
  convertTimeFormat(dt, "time_column")
  # Check that the time_column is now of class "hms"
  expect_true(inherits(dt$time_column, "hms"))
  # Check that the values are correctly converted
  expect_equal(as.character(dt$time_column), c("08:00:00", "15:30:00", "12:45:00"))
})

test_that("convertTimeFormat handles invalid time strings", {
  dt <- data.table(
    id = 1:3,
    time_column = c("08:00:00", "invalid_time", "15:30:00")
  )
  suppressWarnings(convertTimeFormat(dt, "time_column"))
  # Check that invalid values are converted to NA
  expect_true(is.na(dt$time_column[2]))
  # Check that valid values remain unchanged
  expect_equal(as.character(dt$time_column[c(1, 3)]), c("08:00:00", "15:30:00"))
})

test_that("convertTimeFormat works with multiple columns", {
  dt <- data.table(
    id = 1:3,
    time_column1 = c("08:00:00", "15:30:00", "12:45:00"),
    time_column2 = c("20:00:00", "invalid_time", "23:15:00")
  )
  suppressWarnings(convertTimeFormat(dt, c("time_column1", "time_column2")))
  # Check that both columns are of class "hms"
  expect_true(inherits(dt$time_column1, "hms"))
  expect_true(inherits(dt$time_column2, "hms"))
  # Check that valid values are correctly converted
  expect_equal(as.character(dt$time_column1), c("08:00:00", "15:30:00", "12:45:00"))
  expect_equal(as.character(dt$time_column2[c(1, 3)]), c("20:00:00", "23:15:00"))
  # Check that invalid values are NA
  expect_true(is.na(dt$time_column2[2]))
})

test_that("convertTimeFormat retains original data table structure", {
  dt <- data.table(
    id = 1:3,
    time_column = c("08:00:00", "15:30:00", "12:45:00"),
    another_column = c("A", "B", "C")
  )
  convertTimeFormat(dt, "time_column")
  # Check that other columns remain unchanged
  expect_equal(dt$another_column, c("A", "B", "C"))
  # Check that the data table structure is preserved
  expect_equal(names(dt), c("id", "time_column", "another_column"))
})

#########################
# convertDateTimeFormat #
#########################

test_that("convertDateTimeFormat function converts datetime columns correctly", {
  # Test case 1: Valid time representation
  dt <- data.table(datetime_column = c("2018", "1973-06", "1905-08-23",
                                       "2015-02-07T13:28:17+01:00", "2015-02-07T13:28:17+03:00",
                                       "2017-01-01T00:00:00.000Z", NA))
  suppressMessages(convertDateTimeFormat(dt, "datetime_column"))
  # Check if the datetime columns are converted properly
  expect_equal(dt$datetime_column[1], as.POSIXct("2018-01-01 00:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[2], as.POSIXct("1973-06-01 00:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[3], as.POSIXct("1905-08-23 00:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[4], as.POSIXct("2015-02-07 13:28:17", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[5], as.POSIXct("2015-02-07 11:28:17", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[6], as.POSIXct("2017-01-01 01:00:00", tz = "Europe/Berlin"))
  expect_equal(dt$datetime_column[7], as.POSIXct(NA, tz = "Europe/Berlin"))
})
