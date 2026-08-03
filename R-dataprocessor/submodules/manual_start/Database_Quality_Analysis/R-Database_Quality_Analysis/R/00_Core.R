DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS <- c(
  resource_id = "count per resource_id",
  pid = "count per PID",
  case_id = "count per Fall-Id"
)

DATABASE_QUALITY_ANALYSIS_CHECKED_VALUE <- "Checked"

DATABASE_QUALITY_ANALYSIS_FRONTEND_CHECKBOX_GROUPS <- list(
  mrpdokumentation_validierung_fe = list(
    mrp_pigrund = paste0("mrp_pigrund___", 1:27),
    mrp_massn_am = paste0("mrp_massn_am___", 1:10),
    mrp_massn_orga = paste0("mrp_massn_orga___", 1:8)
  ),
  retrolektive_mrpbewertung_fe = list(
    ret_gewiss_trigger1_falsch = paste0("ret_gewiss_trigger1_falsch___", 1:4),
    ret_gewiss_datengrundl1_1 = paste0("ret_gewiss_datengrundl1_1___", 1:4),
    ret_gewiss_datengrundl1_2 = paste0("ret_gewiss_datengrundl1_2___", 1:4),
    ret_gewiss_grund_abl_klin1_neg = "ret_gewiss_grund_abl_klin1_neg___1",
    ret_massn_am1 = paste0("ret_massn_am1___", 1:10),
    ret_massn_orga1 = paste0("ret_massn_orga1___", 1:8),
    ret_2ndbewertung = "ret_2ndbewertung___1",
    ret_gewiss_trigger2_falsch = paste0("ret_gewiss_trigger2_falsch___", 1:4),
    ret_gewiss_datengrundl2_1 = paste0("ret_gewiss_datengrundl2_1___", 1:4),
    ret_gewiss_datengrundl2_2 = paste0("ret_gewiss_datengrundl2_2___", 1:4),
    ret_gewiss_grund_abl_klin2_neg = "ret_gewiss_grund_abl_klin2_neg___1",
    ret_massn_am2 = paste0("ret_massn_am2___", 1:10),
    ret_massn_orga2 = paste0("ret_massn_orga2___", 1:8)
  )
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
