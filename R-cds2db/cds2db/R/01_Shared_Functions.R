#' Determine Current Query Time Range
#'
#' This function determines the datetime range used for queries. By default,
#' the start of the range is the current system time. If certain global
#' configuration parameters are defined, they override this behaviour.
#'
#' The following precedence is applied:
#'
#' 1. If the process `DataImport` is active and `DATA_IMPORT_RANGE_START`
#'    is defined, the range is taken from `DATA_IMPORT_RANGE_START` and
#'    optionally `DATA_IMPORT_RANGE_END`.
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
  if (isProcess("DataImport") && etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_START")) {
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

#' Create a data.table with cohort and patient ID per date.
#'
#' This function takes a list of patient IDs per cohort and constructs a
#' data.table with an additional cohort name column.
#'
#' @param pids_splitted_by_cohort A list of patient IDs, where each element
#'   corresponds to a cohort.
#'
#' @return A data.table with patient IDs and cohort names.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#' # Example: A list of patient IDs per cohort
#' pids_splitted_by_cohort <- list(
#'   Cohort_A = data.table(patient_id = c("PID_A001", "PID_A002", "PID_A003")),
#'   Cohort_B = data.table(patient_id = c("PID_B001", "PID_B002")),
#'   Cohort_C = data.table(patient_id = c("PID_C001", "PID_C002", "PID_C003", "PID_C004"))
#' )
#'
#' # Applying the function
#' result_table <- rbindPidsSplittedByCohort(pids_splitted_by_cohort)
#'
#' # Displaying the result
#' print(result_table)
#' }
#'
rbindPidsSplittedByCohort <- function(pids_splitted_by_cohort) {
  pids_per_cohort <- data.table::rbindlist(
    lapply(names(pids_splitted_by_cohort), function(cohort) {
      dt <- pids_splitted_by_cohort[[cohort]]
      if (nrow(dt) > 0) {
        dt <- data.table::copy(dt)
        return(dt[, cohort_name := cohort])
      }
      return(NULL)
    }),
    use.names = TRUE,
    fill = TRUE
  )
  if (is.null(pids_per_cohort) || !ncol(pids_per_cohort)) {
    pids_per_cohort <- data.table::data.table(
      patient_id = character(),
      cohort_name = character()
    )
  }
  return(pids_per_cohort)
}

#' Create a data.table with ward and patient ID per date.
#'
#' This compatibility wrapper keeps the legacy ward-shaped PID table while the
#' generic cohort representation is introduced.
#'
#' @param pids_splitted_by_ward A list of patient IDs, where each element
#'   corresponds to a ward.
#'
#' @return A data.table with patient IDs and ward names.
rbindPidsSplittedByWard <- function(pids_splitted_by_ward) {
  pids_per_ward <- rbindPidsSplittedByCohort(pids_splitted_by_ward)
  data.table::setnames(pids_per_ward, "cohort_name", "ward_name")
  return(pids_per_ward)
}

#' Get PID assignment table settings for the configured filter family
#'
#' Chooses the legacy ward-shaped PID assignment table for
#' `ENCOUNTER_FILTER_PATTERN` definitions and the generic cohort-shaped table
#' for `COHORT_FILTER_PATTERN` definitions.
#'
#' @param configured_filter_patterns Configured cohort filter pattern metadata.
#'
#' @return A list with PID assignment table settings.
getPIDAssignmentTableSpec <- function(
  configured_filter_patterns = getConfiguredCohortFilterPatterns()
) {
  if (configured_filter_patterns$legacy) {
    return(list(
      table_name = "pids_per_ward",
      raw_table_name = "pids_per_ward_raw",
      bind_pids_function = rbindPidsSplittedByWard,
      empty_table = data.table::data.table(
        patient_id = "EMPTY_DATA",
        encounter_id = "EMPTY_DATA",
        ward_name = NA_character_
      ),
      legacy = TRUE
    ))
  }

  return(list(
    table_name = "pids_per_cohort",
    raw_table_name = "pids_per_cohort_raw",
    bind_pids_function = rbindPidsSplittedByCohort,
    empty_table = data.table::data.table(
      patient_id = "EMPTY_DATA",
      cohort_name = NA_character_,
      source_resource_type = NA_character_,
      source_resource_id = NA_character_,
      encounter_id = NA_character_
    ),
    legacy = FALSE
  ))
}
