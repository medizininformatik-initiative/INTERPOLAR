#######################
# normalizeTimeToUTC  #
#######################

# Test case 1: Convert time from different timezones to UTC
test_that("normalizeTimeToUTC converts time from different timezones to UTC", {
  # Example with New York time
  time1 <- as.POSIXct("2023-03-10 12:00:00", tz = "America/New_York")
  expected1 <- as.POSIXct("2023-03-10 17:00:00", tz = "UTC")  # Converted to UTC

  result1 <- normalizeTimeToUTC(time1)
  expect_equal(result1, expected1)

  # Example with Tokyo time
  time2 <- as.POSIXct("2023-03-10 12:00:00", tz = "Asia/Tokyo")
  expected2 <- as.POSIXct("2023-03-10 03:00:00", tz = "UTC")  # Converted to UTC

  result2 <- normalizeTimeToUTC(time2)
  expect_equal(result2, expected2)
})

# Test case 2: Convert already UTC time
test_that("normalizeTimeToUTC does not modify time already in UTC", {
  time_utc <- as.POSIXct("2023-03-10 12:00:00", tz = "UTC")
  expected <- time_utc

  result <- normalizeTimeToUTC(time_utc)
  expect_equal(result, expected)
})

##############################
# normalizeTableColumnToUTC  #
##############################

# Test case 1: Convert single column from different timezones to UTC
test_that("normalizeTableColumnToUTC converts column from different timezones to UTC", {
  dt <- data.table(
    time = as.POSIXct(c("2023-03-10 12:00:00", "2023-03-11 15:00:00"), tz = "America/New_York")
  )
  expected <- data.table(
    time = as.POSIXct(c("2023-03-10 17:00:00", "2023-03-11 20:00:00"), tz = "UTC")
  )

  normalizeTableColumnToUTC(dt, "time")
  expect_equal(dt, expected)
})

# Test case 2: Convert already UTC column
test_that("normalizeTableColumnToUTC does not modify column already in UTC", {
  dt <- data.table(
    time = as.POSIXct(c("2023-03-10 12:00:00", "2023-03-11 15:00:00"), tz = "UTC")
  )
  expected <- data.table::copy(dt)

  normalizeTableColumnToUTC(dt, "time")
  expect_equal(dt, expected)
})

#############################
# normalizeAllPOSIXctToUTC  #
#############################

# Test: Convert multiple POSIXct columns to UTC
test_that("normalizeAllPOSIXctToUTC converts all POSIXct columns to UTC", {
  dt <- data.table(
    time1 = as.POSIXct(c("2023-03-10 12:00:00", "2023-03-11 15:00:00"), tz = "America/New_York"),
    time2 = as.POSIXct(c("2023-03-10 11:00:00", "2023-03-11 14:00:00"), tz = "Europe/Berlin")
  )
  expected <- data.table(
    time1 = as.POSIXct(c("2023-03-10 17:00:00", "2023-03-11 20:00:00"), tz = "UTC"),
    time2 = as.POSIXct(c("2023-03-10 10:00:00", "2023-03-11 13:00:00"), tz = "UTC")
  )

  normalizeAllPOSIXctToUTC(dt)
  expect_equal(dt, expected)
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

test_that("convertTimeFormat converts polar time representations to POSIXct", {
  # Create a test data.table
  dt <- data.table(time_column = c("12:30:45", "08:15:00", "23:59:59", "13:45:22.123456789", NA, ""))
  # Call the function
  suppressMessages(convertTimeFormat(dt, "time_column"))
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
