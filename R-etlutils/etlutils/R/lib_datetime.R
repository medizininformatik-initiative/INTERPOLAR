#' Normalize POSIXct Time to UTC
#'
#' @param time A POSIXct date-time object.
#' @return POSIXct date-time object in UTC timezone.
#' @examples
#' time1 <- as.POSIXct("2023-03-10 12:00:00", tz = "America/New_York")
#' normalizeTimeToUTC(time1)
#' @export
normalizeTimeToUTC <- function(time) {
  # Converts the provided POSIXct object to the UTC format
  normalized_time <- as.POSIXct(format(time, tz = "UTC"), tz = "UTC")
  return(normalized_time)
}

#' Normalize Specified Column of Data.Table to UTC
#'
#' This function modifies the specified column in a given data.table by converting
#' all datetime entries to UTC format. The column is expected to contain POSIXct
#' datetime objects.
#'
#' @param dt A data.table object containing at least one column with POSIXct datetime objects.
#' @param column The name of the column to be normalized to UTC.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(time = as.POSIXct(c("2023-03-10 12:00:00",
#'                                      "2023-03-11 15:00:00"), tz = "America/New_York"))
#' normalizeTableColumnToUTC(dt, "time")
#' print(dt)
#'
#' @export
normalizeTableColumnToUTC <- function(dt, column) {
  dt[, (column) := as.POSIXct(format(.SD[[..column]], tz = "UTC"), tz = "UTC"), .SDcols = column]
}

#' Normalize All POSIXct Columns in a Data.Table to UTC
#'
#' This function automatically detects all POSIXct columns in a given data.table
#' and normalizes their time values to the UTC timezone. It modifies the data.table
#' in place.
#'
#' @param dt A data.table object that potentially contains one or more columns
#'   of POSIXct datetime objects.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(time1 = as.POSIXct(c("2023-03-10 12:00:00",
#'                                       "2023-03-11 15:00:00"), tz = "America/New_York"),
#'                  time2 = as.POSIXct(c("2023-03-10 11:00:00",
#'                                       "2023-03-11 14:00:00"), tz = "Europe/Berlin"))
#' normalizeAllPOSIXctToUTC(dt)
#' print(dt)
#'
#' @export
normalizeAllPOSIXctToUTC <- function(dt) {
  # Identify all columns of type POSIXct
  posixct_cols <- sapply(dt, function(x) inherits(x, "POSIXct"))

  # Run through all POSIXct columns and convert them to UTC
  for (col in names(posixct_cols[posixct_cols])) {
    dt[, (col) := as.POSIXct(format(.SD[[col]], tz = "UTC"), tz = "UTC"), .SDcols = col]
  }
  # The function modifies the data.table directly, so no return is necessary
}

#' Convert Time Format
#'
#' This function converts the time format of columns in a data table.
#'
#' @param dt A data table.
#' @param columns The name of the columns whose time format needs to be converted.
#'
#' @details This function takes a data table \code{dt} and the names of columns \code{columns}
#' as input. It converts the time format for every single column of the specified columns using
#' the following steps:
#' - Parse the column values as POSIXct objects using \code{strptime}.
#' - Format the POSIXct objects to the desired time format using \code{format}.
#' - Update the column values in the data table with the formatted time values.
#'
#' @return This function modifies the input data table \code{dt} by converting the time format
#' of the specified columns.
#'
#' @export
convertTimeFormat <- function(dt, columns) {
  for (column in columns) {
    # Convert string in POSIXct object
    dt[, (column) := as.POSIXct(.SD[[..column]], format = "%H:%M:%S", tz = "UTC"), .SDcols = column]
    # Set date to '1970-01-01'
    dt[!is.na(dt[[column]]), (column) := as.POSIXct(paste0("1970-01-01 ", format(get(column), "%H:%M:%S")), tz = "UTC")]
  }
}

#' Convert Date Format
#'
#' This function converts the date format of columns in a data table.
#'
#' @param dt A data table.
#' @param columns Vector with names of the columns whose date format needs to be converted.
#'
#' @details This function takes a data table \code{dt} and the names of columns \code{columns}
#' as input. It converts the date format for every single column of the specified columns in
#' the following steps:
#' - Convert the column to character type.
#' - Remove time information (if any) from the column values.
#' - Replace '/' with '-' in the column values.
#' - If the values match the pattern YYYY, append '-01-01' to represent the complete date.
#' - If the values match the pattern YYYY-MM, append '-01' to represent the complete date.
#' - Finally, convert the column to date type using \code{lubridate::as_date}.
#'
#' @return This function modifies the input data table \code{dt} by converting the date format
#' of the specified columns.
#'
#' @export
convertDateFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := as.character(get(column))]
    dt[, (column) := gsub('T.+$', '', get(column))]
    dt[, (column) := gsub('/', '-', get(column))]
    # Set a regular expression pattern for matching YYYY format
    incomplete_date_pattern <- '^[0-9]{4}$'
    years <- grepl(incomplete_date_pattern, dt[[column]])
    dt[years, (column) := paste0(dt[years, get(column)], '-01-01')]

    # Set a regular expression pattern for matching YYYY-MM format
    incomplete_date_pattern <- '^[0-9]{4}-[0-9]{2}$'
    months <- grepl(incomplete_date_pattern, dt[[column]])
    dt[months, (column) := paste0(dt[months, get(column)], '-01')]

    dt[, (column) := lubridate::as_date(get(column))]
  }
}

#' Fix datetime format in specified columns
#'
#' This function fixes the date format in specified columns of a data table.
#'
#' @param dt A data table.
#' @param columns A character vector specifying the columns to fix.
#'
#' @details This function expects a data table \code{dt} and a character vector
#' \code{column} specifying the column to be fixed. It converts the values in
#' the specified column to date-time objects with the format \code{ymd_hms},
#' truncating the time to minutes and setting the timezone to "Europe/Berlin".
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the date format in the specified column
#'
#' @export
convertDateTimeFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := lubridate::ymd_hms(get(column), truncated = 5, tz = "Europe/Berlin")]
  }
}
