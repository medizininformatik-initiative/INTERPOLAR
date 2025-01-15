#' Convert Input to POSIXct with a Specified Timezone
#'
#' A wrapper around `as.POSIXct` that allows specifying a default or custom timezone and an optional input format.
#'
#' @param x A character vector, numeric vector, or Date object that can be converted to a `POSIXct` object.
#' @param tz A character string specifying the timezone to set. Defaults to the global variable `global_timezone`.
#' @param format An optional character string specifying the input format for `x`. Defaults to `NULL`, allowing `as.POSIXct` to infer the format automatically.
#' @return A `POSIXct` object with the specified timezone applied.
#' @details
#' This function simplifies the conversion of various input types to `POSIXct` while allowing for an explicitly defined timezone.
#' If `format` is provided, it will be used to parse the input; otherwise, the function will attempt to infer the format.
#'
#' The timezone `tz` defaults to the globally defined variable `global_timezone`, which must be set before calling this function.
#'
#' @examples
#' GLOBAL_TIMEZONE <- "Europe/Berlin"
#' as.POSIXctWithTimezone("1949-12-31 UTC")
#' as.POSIXct("1949-12-31 CET", tz = "UTC")
#'
#' @export
as.POSIXctWithTimezone <- function(x, tz = GLOBAL_TIMEZONE, format = NULL) {
  if (is.null(format)) {
    as.POSIXct(x, tz = tz)
  } else {
    as.POSIXct(x, tz = tz, format = format)
  }
}

#' Convert Input to Date with a Specified Timezone
#'
#' A wrapper around `as.Date` that allows specifying a timezone and an optional format for parsing
#' the input.
#'
#' @param x A character vector, numeric vector, or `POSIXt` object that can be converted to a `Date`
#' object.
#' @param tz A character string specifying the timezone to set. Defaults to the global variable
#' `global_timezone`.
#' @param format An optional character string specifying the input format for `x`. If `NULL`, the
#' function allows `as.Date` to infer the format automatically. Defaults to `NULL`.
#' @param origin A character string specifying the origin date for numeric input. Required if `x`
#' is numeric. Default is `NULL`.
#'
#' @return A `Date` object with the specified timezone applied.
#'
#' @examples
#' \dontrun{
#' GLOBAL_TIMEZONE <- "Europe/Berlin"
#' as.DateWithTimezone("2025-01-01", origin = "1971-01-01")
#' as.DateWithTimezone("01/01/2025", format = "%d/%m/%Y")
#' as.DateWithTimezone(as.POSIXct("2025-01-01 00:00:00", tz = "UTC"))
#' as.DateWithTimezone(as.POSIXctWithTimezone("2020-08-14 23:00:00+05:00"))
#' as.DateWithTimezone("1949-12-31 CET")
#' as.DateWithTimezone("1949-12-31 UTC")
#' }
#' @export
as.DateWithTimezone <- function(x, tz = GLOBAL_TIMEZONE, format = NULL, origin = NULL) {
  if (is.null(format)) {
    as.Date(x, tz = tz, origin = origin)
  } else {
    as.Date(x, tz = tz, format = format, origin = origin)
  }
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
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   id = 1:3,
#'   time_column = c("08:00:00", "15:30:00", "invalid_time")
#' )
#' convertTimeFormat(dt, "time_column")
#' print(dt)
#'
#' @export
convertTimeFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := {
      # Convert each value individually while preserving the hms class
      result <- sapply(get(column), function(x) {
        tryCatch(
          hms::as_hms(x),  # Attempt to convert the value to hms
          error = function(e) {
            warning(sprintf("Conversion failed for value '%s': %s", x, e$message))
            NA  # Assign NA for invalid or unparsable values
          }
        )
      })
      # Ensure the column retains the hms class
      data.table::setattr(result, "class", c("hms", "difftime"))
      # Set the units for the hms object as "secs"
      data.table::setattr(result, "units", "secs")
      result
    }]
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
#' @examples
#' library(data.table)
#' # Single column conversion
#' dt <- data.table(date = c('2020', '2021-05', '2022/12/25', '2023-07-01'))
#' convertDateFormat(dt, 'date')
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
#' The function supports various datetime formats, including:
#' - ISO 8601 format with \code{T} separating date and time, e.g., \code{"2020-08-14T02:00:00+03:00"}.
#' - Formats with or without explicit time zones.
#' - UTC timestamps indicated by a trailing \code{"Z"}, e.g., \code{"2011-09-15T06:31:34Z"}.
#'
#' The \code{Z} at the end of a timestamp stands for "Zulu Time", which is equivalent to UTC (Coordinated Universal Time).
#' It indicates that the timestamp is in UTC and does not require additional time zone conversion.
#'
#' @return This function modifies the input data table \code{dt} in place by
#' fixing the date format in the specified column
#'
#' @examples
#' library(data.table)
#' # Converting a datetime column
#' dt <- data.table(id = 1:4, enc_period_end = c("2020-08-14T02:00:00+03:00",
#' "2021-09-10T12:30:00+02:00", "2022-03-15 18:45:00+02:00", "2011-09-15T06:31:34Z"))
#' convertDateTimeFormat(dt, columns = c("enc_period_end"))
#'
#' @export
convertDateTimeFormat <- function(dt, columns) {
  for (column in columns) {
    dt[, (column) := lubridate::ymd_hms(get(column), truncated = 5, tz = GLOBAL_TIMEZONE)]
  }
}
