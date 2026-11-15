#' Resolve OPS catalogue versions and terminal status
#'
#' @param procedures Procedure rows with proc_code_version/code, proc_patient_ref,
#'   proc_encounter_calculated_ref and start_datetime.
#' @param encounters Latest origin-case rows with enc_id, enc_patient_ref,
#'   enc_class_code and enc_period_start. Conflicting origin rows remain unresolved.
#' @param catalogue Terminal OPS codes loaded once through etlutils.
#' @param timezone Time zone used to derive calendar years.
#' @return Procedure rows with ops_requested_year, ops_catalogue_year,
#'   ops_year_source, ops_year_approximated and ops_terminal. Missing versions use
#'   the origin inpatient admission year, or outpatient procedure year. The target
#'   cohort case is never used to infer the version of an unrelated procedure.
prepareCohortOPS <- function(procedures, encounters, catalogue, timezone) {
  prepareCohortCoding(procedures, encounters, catalogue, timezone, "proc", "ops")
}

# Resolve documented versions and origin-case fallback identically for ICD and OPS.
prepareCohortCoding <- function(procedures, encounters, catalogue, timezone, resource_prefix, coding) {
  result <- data.table::copy(data.table::as.data.table(procedures))
  origins <- data.table::copy(data.table::as.data.table(encounters))
  origins[, patient_id := etlutils::fhirdataExtractIDs(enc_patient_ref, unique = FALSE)]
  origins <- unique(origins[, .(patient_id, enc_id, enc_class_code, enc_period_start)])
  ambiguous <- duplicated(origins, by = c("patient_id", "enc_id")) |
    duplicated(origins, by = c("patient_id", "enc_id"), fromLast = TRUE)
  origins <- origins[!ambiguous & !is.na(patient_id) & !is.na(enc_id)]
  result[, `.coding_row` := seq_len(.N)]
  result[, patient_id := etlutils::fhirdataExtractIDs(get(paste0(resource_prefix, "_patient_ref")), unique = FALSE)]
  result[, origin_id := etlutils::fhirdataExtractIDs(get(paste0(resource_prefix, "_encounter_calculated_ref")), unique = FALSE)]
  result <- merge(result, origins,
    by.x = c("patient_id", "origin_id"),
    by.y = c("patient_id", "enc_id"), all.x = TRUE, sort = FALSE
  )
  version <- trimws(as.character(result[[paste0(resource_prefix, "_code_version")]]))
  missing <- is.na(version) | !nzchar(version)
  valid <- !missing & grepl("^[0-9]{4}$", version)
  result[, `:=`(coding_requested_year = NA_integer_, coding_year_source = "unresolved")]
  result[valid, `:=`(coding_requested_year = as.integer(version[valid]), coding_year_source = "documented")]
  result[!missing & !valid, coding_year_source := "invalid_documented_version"]
  inpatient <- missing & result$enc_class_code %in% c("IMP", "ACUTE", "NONAC") &
    !is.na(result$enc_period_start)
  outpatient <- missing & result$enc_class_code %in% c("AMB", "EMER") &
    !is.na(result$start_datetime)
  result[inpatient, `:=`(
    coding_requested_year = as.integer(format(enc_period_start, "%Y", tz = timezone)),
    coding_year_source = "origin_admission"
  )]
  result[outpatient, `:=`(
    coding_requested_year = as.integer(format(start_datetime, "%Y", tz = timezone)),
    coding_year_source = "event_date"
  )]
  available <- sort(unique(catalogue$year))
  if (!length(available) || anyNA(available)) stop("Catalogue has no valid years.")
  requested <- unique(stats::na.omit(result$coding_requested_year))
  selected <- vapply(requested, function(year) available[which.min(abs(available - year))], numeric(1))
  result[, coding_catalogue_year := as.integer(selected[match(coding_requested_year, requested)])]
  result[, coding_year_approximated := !is.na(coding_requested_year) & coding_requested_year != coding_catalogue_year]
  if (any(result$coding_year_approximated)) {
    warning(sum(result$coding_year_approximated),
      paste0(" ", toupper(coding), " coding row(s) use the nearest available annual catalogue; inspect aggregate quality counts."),
      call. = FALSE
    )
  }
  check_terminal <- if (coding == "ops") etlutils::isTerminalOPS else etlutils::isTerminalICD
  result[, coding_terminal := check_terminal(get(paste0(resource_prefix, "_code_code")), coding_catalogue_year, catalogue)]
  data.table::setorder(result, .coding_row)
  result[, c(".coding_row", "origin_id", "enc_class_code", "enc_period_start") := NULL]
  if (coding == "ops") result[coding_year_source == "event_date", coding_year_source := "procedure_date"]
  columns <- grep("^coding_", names(result), value = TRUE)
  data.table::setnames(result, columns, sub("^coding_", paste0(coding, "_"), columns))
  result
}
