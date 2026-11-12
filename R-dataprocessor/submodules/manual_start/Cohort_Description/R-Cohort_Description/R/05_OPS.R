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
  result <- data.table::copy(data.table::as.data.table(procedures))
  origins <- data.table::copy(data.table::as.data.table(encounters))
  origins[, patient_id := etlutils::fhirdataExtractIDs(enc_patient_ref, unique = FALSE)]
  origins <- unique(origins[, .(patient_id, enc_id, enc_class_code, enc_period_start)])
  ambiguous <- duplicated(origins, by = c("patient_id", "enc_id")) |
    duplicated(origins, by = c("patient_id", "enc_id"), fromLast = TRUE)
  origins <- origins[!ambiguous & !is.na(patient_id) & !is.na(enc_id)]
  result[, `.ops_row` := seq_len(.N)]
  result[, patient_id := etlutils::fhirdataExtractIDs(proc_patient_ref, unique = FALSE)]
  result[, origin_id := etlutils::fhirdataExtractIDs(proc_encounter_calculated_ref, unique = FALSE)]
  result <- merge(result, origins,
    by.x = c("patient_id", "origin_id"),
    by.y = c("patient_id", "enc_id"), all.x = TRUE, sort = FALSE
  )
  version <- trimws(as.character(result$proc_code_version))
  missing <- is.na(version) | !nzchar(version)
  valid <- !missing & grepl("^[0-9]{4}$", version)
  result[, `:=`(ops_requested_year = NA_integer_, ops_year_source = "unresolved")]
  result[valid, `:=`(ops_requested_year = as.integer(version[valid]), ops_year_source = "documented")]
  result[!missing & !valid, ops_year_source := "invalid_documented_version"]
  inpatient <- missing & result$enc_class_code %in% c("IMP", "ACUTE", "NONAC") &
    !is.na(result$enc_period_start)
  outpatient <- missing & result$enc_class_code %in% c("AMB", "EMER") &
    !is.na(result$start_datetime)
  result[inpatient, `:=`(
    ops_requested_year = as.integer(format(enc_period_start, "%Y", tz = timezone)),
    ops_year_source = "origin_admission"
  )]
  result[outpatient, `:=`(
    ops_requested_year = as.integer(format(start_datetime, "%Y", tz = timezone)),
    ops_year_source = "procedure_date"
  )]
  available <- sort(unique(catalogue$year))
  if (!length(available) || anyNA(available)) stop("OPS catalogue has no valid years.")
  requested <- unique(stats::na.omit(result$ops_requested_year))
  selected <- vapply(requested, function(year) available[which.min(abs(available - year))], numeric(1))
  result[, ops_catalogue_year := as.integer(selected[match(ops_requested_year, requested)])]
  result[, ops_year_approximated := !is.na(ops_requested_year) & ops_requested_year != ops_catalogue_year]
  if (any(result$ops_year_approximated)) {
    warning(sum(result$ops_year_approximated),
      " OPS coding row(s) use the nearest available annual catalogue; inspect aggregate quality counts.",
      call. = FALSE
    )
  }
  result[, ops_terminal := etlutils::isTerminalOPS(proc_code_code, ops_catalogue_year, catalogue)]
  data.table::setorder(result, .ops_row)
  result[, c(".ops_row", "origin_id", "enc_class_code", "enc_period_start") := NULL]
  result
}
