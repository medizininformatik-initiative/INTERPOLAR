######################
# convertDateFormat  #
######################

test_that("convertDateFormat converts date representations correctly", {
  # Create a sample data table
  dt <- data.table(date_column = c("2022", "2023-02", "2024/03/18", "2025-04-20T12:30:45", NA))

  # Apply the function to the column
  convertDateFormat(dt, "date_column")

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
