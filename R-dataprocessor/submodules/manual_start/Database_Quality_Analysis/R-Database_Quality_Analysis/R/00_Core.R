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

logProgress <- function(...) {
  cat("[Database Quality Analysis] ", ..., "\n", sep = "")
}

formatDuration <- function(start_time, end_time = Sys.time()) {
  paste0(round(as.numeric(difftime(end_time, start_time, units = "secs")), 2), "s")
}

formatCountLabel <- function(count, singular, plural = paste0(singular, "s")) {
  paste(count, if (identical(as.integer(count), 1L)) singular else plural)
}
