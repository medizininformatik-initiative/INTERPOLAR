DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS <- c(
  resource_id = "count per resource_id",
  pid = "count per PID",
  case_id = "count per Fall-Id"
)

DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS <- c(
  first_import = "first value import datetime",
  last_import = "last value import datetime",
  first_meta_last_updated = "first value meta last updated",
  last_meta_last_updated = "last value meta last updated"
)

DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN <- "USED_AS_GROUPING_FOR"

#' Print a database quality analysis progress message
#'
#' Prefixes a message with the module label and writes it to the console.
logProgress <- function(...) {
  cat("[Database Quality Analysis] ", ..., "\n", sep = "")
}

#' Format an elapsed duration
#'
#' Converts a start and end timestamp into a compact seconds label.
formatDuration <- function(start_time, end_time = Sys.time()) {
  paste0(round(as.numeric(difftime(end_time, start_time, units = "secs")), 2), "s")
}

#' Format a count with a singular or plural label
#'
#' Returns a human-readable count label for progress messages.
formatCountLabel <- function(count, singular, plural = paste0(singular, "s")) {
  paste(count, if (identical(as.integer(count), 1L)) singular else plural)
}

#' Get a database lock ID for the current DQA configuration
#'
#' Returns the given lock ID only when database locks are explicitly enabled for
#' the report. Database quality analysis is read-only, so locks are disabled by
#' default to avoid waiting for the transfer semaphore during site-side reports.
getDatabaseQualityAnalysisLockId <- function(config, lock_id) {
  if (isTRUE(config$use_database_locks)) {
    return(lock_id)
  }
  NULL
}
