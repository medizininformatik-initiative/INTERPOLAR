#' @importFrom lubridate today

test_that("polar_as_date converts date representations correctly", {
  # Test case 1: YYYY format
  date_column_YYYY <- c("2022", "1990", "1980")
  result_YYYY <- polar_as_date(date_column_YYYY)
  expect_equal(result_YYYY, lubridate::as_date(c("2022-01-01", "1990-01-01", "1980-01-01")))

  # Test case 2: YYYY-MM format
  date_column_YYYY_MM <- c("2022-12", "1990-05", "1980-11")
  result_YYYY_MM <- polar_as_date(date_column_YYYY_MM)
  expect_equal(result_YYYY_MM, lubridate::as_date(c("2022-12-01", "1990-05-01", "1980-11-01")))

  # Test case 3: Date with time, should be cleaned
  date_column_with_time <- c("2022-12-01T15:30:00", "1990-05-01T08:45:00")
  result_with_time <- polar_as_date(date_column_with_time)
  expect_equal(result_with_time, lubridate::as_date(c("2022-12-01", "1990-05-01")))

  # Test case 4: Date with '/' separator, should be replaced with '-'
  date_column_slash_separator <- c("2022/12/01", "1990/05/01")
  result_slash_separator <- polar_as_date(date_column_slash_separator)
  expect_equal(result_slash_separator, lubridate::as_date(c("2022-12-01", "1990-05-01")))
})


test_that("polar_fix_dates fixes uncommon date formats", {
  # Erstellen Sie einen Beispiel-Datensatz
  dt <- data.table::data.table(
    date1 = c("2022", "1990-05", "1980-11"),
    date2 = c("2022-12", "1990-05", "1980-11"),
    value = c(1, 2, 3)
  )

  # Testen Sie die Funktion mit der Zeit beizubehalten
  polar_fix_dates(dt, c("date1", "date2"), preserve_time = TRUE)

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


test_that("polar_as_time converts polar time representations to POSIXct", {
  # Test case 1: Valid time representation
  time_column_valid <- c("12:30:45", "08:15:00", "23:59:59")
  result_valid <- polar_as_time(time_column_valid)
  expect_equal(result_valid, c("12:30:45", "08:15:00", "23:59:59"))

  # Test case 2: NA input, should return NA
  time_column_na <- c(NA, NA, NA)
  result_na <- polar_as_time(time_column_na)
  expect_equal(result_na, c(NA_character_, NA_character_, NA_character_))

  # Test case 3: Empty string input, should throw an error
  time_column_empty <- c("", NA, "")
  result_na <- polar_as_time(time_column_empty)
  expect_equal(result_na, c(NA_character_, NA_character_, NA_character_))
})
