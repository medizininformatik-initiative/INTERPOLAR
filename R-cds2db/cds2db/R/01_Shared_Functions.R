#' Determine Current Query Time Range
#'
#' This function determines the datetime range used for queries. By default,
#' the start of the range is the current system time. If certain global
#' configuration parameters are defined, they override this behaviour.
#'
#' The following precedence is applied:
#'
#' 1. If `DATA_IMPORT_IS_ACTIVE` is defined and `TRUE`, the range is taken from
#'    `DATA_IMPORT_RANGE_START` and optionally `DATA_IMPORT_RANGE_END`.
#' 2. Otherwise, if debug parameters are defined, the range is taken from
#'    `DEBUG_ENCOUNTER_STARTS_AFTER` and optionally
#'    `DEBUG_ENCOUNTER_STARTS_AT_OR_BEFORE`.
#' 3. Otherwise, the current system time is used as `period_start` and
#'    `period_end` remains undefined.
#'
#' The returned vector also contains a flag indicating whether the start time
#' was set by configuration parameters instead of the current system time.
#'
#' @return A named vector containing:
#'   \item{period_start}{A POSIXct value representing the start of the query range.}
#'   \item{period_end}{A POSIXct value representing the end of the query range
#'     if defined, otherwise not present in the return value (`NULL`).}
#'   \item{period_start_is_set_by_param}{`NA` if the start time was set via
#'     parameters, otherwise not present in the return value (`NULL`).}
#'
getCurrentDatetime <- function() {
  period_start <- etlutils::as.POSIXctWithTimezone(Sys.time())
  period_end <- NULL
  period_start_is_set_by_param <- NULL
  if (etlutils::isDefinedAndTrue("DATA_IMPORT_IS_ACTIVE")) {
    period_start <- etlutils::parseTimestamp(DATA_IMPORT_RANGE_START)
    if (etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_END")) {
      period_end <- etlutils::parseTimestamp(DATA_IMPORT_RANGE_END)
    }
    period_start_is_set_by_param <- NA
  } else if (etlutils::isDefinedAndNotEmpty("DEBUG_ENCOUNTER_STARTS_AFTER")) {
    period_start <- etlutils::as.POSIXctWithTimezone(DEBUG_ENCOUNTER_STARTS_AFTER)
    if (etlutils::isDefinedAndNotEmpty("DEBUG_ENCOUNTER_STARTS_AT_OR_BEFORE")) {
      period_end <- etlutils::as.POSIXctWithTimezone(DEBUG_ENCOUNTER_STARTS_AT_OR_BEFORE)
    }
    period_start_is_set_by_param <- NA
  }
  return(c(period_start = period_start, period_end = period_end, period_start_is_set_by_param = period_start_is_set_by_param))
}

#' Format Datetime for SQL Queries
#'
#' This function formats a datetime value for use in SQL queries. If no datetime
#' is provided, the value returned by \code{getCurrentDatetime()} is used.
#' The datetime is formatted as "YYYY-MM-DD HH:MM:SS".
#'
#' @param datetime A POSIXct datetime value (or vector) to be formatted.
#'   Defaults to the value returned by \code{getCurrentDatetime()}.
#'
#' @return A character vector representing the formatted datetime(s) in
#'   "YYYY-MM-DD HH:MM:SS" format.
#'
getQueryDatetime <- function(datetime = getCurrentDatetime()) {
  format(datetime, "%Y-%m-%d %H:%M:%S")
}

#' Create a data.table with ward and patient ID per date.
#'
#' This function takes a list of patient IDs per ward and constructs a data.table
#' with columns for date_time, ward, and pid. Each row represents a unique combination
#' of date, ward, and patient ID extracted from the provided list.
#'
#' @param pids_splitted_by_ward A list of patient IDs, where each element corresponds to a ward.
#'
#' @return A data.table with columns date_time, ward, and pid, representing the date, ward,
#'   and patient ID for each combination extracted from the provided list.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#' # Example: A list of patient IDs per ward
#' pids_splitted_by_ward <- list(
#'   Ward_A = data.table(patient_id = c("PID_A001", "PID_A002", "PID_A003")),
#'   Ward_B = data.table(patient_id = c("PID_B001", "PID_B002")),
#'   Ward_C = data.table(patient_id = c("PID_C001", "PID_C002", "PID_C003", "PID_C004"))
#' )
#'
#' # Applying the function
#' result_table <- rbindPidsSplittedByWard(pids_splitted_by_ward)
#'
#' # Displaying the result
#' print(result_table)
#' }
#'
rbindPidsSplittedByWard <- function(pids_splitted_by_ward) {
  # Combine all ward tables into one data.table
  pids_per_ward <- data.table::rbindlist(
    lapply(names(pids_splitted_by_ward), function(ward) {
      dt <- pids_splitted_by_ward[[ward]]
      if (nrow(dt) > 0) {
        return(dt[, ward_name := ward])  # Add ward column
      }
      return(NULL)  # Skip empty tables
    }),
    use.names = TRUE, fill = TRUE
  )
  return(pids_per_ward)
}
