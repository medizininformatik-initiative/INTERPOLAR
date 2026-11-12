#' Match patient events to case windows, irrespective of their Encounter reference
#' @param cases Case rows with hospital_start and the selected end column.
#' @param events Patient events with start_datetime.
#' @param end_column Name of the inclusive window end column.
#' @return Event rows with case_row; one event may belong to concurrent cases.
matchCohortEvents <- function(cases, events, end_column) {
  events <- data.table::copy(data.table::as.data.table(events))
  events[, event_row := .I]
  windows <- cases[, .(
    patient_id,
    window_start = hospital_start,
    window_end = get(end_column), case_row = .I
  )]
  hits <- events[windows,
    on = .(
      patient_id, start_datetime >= window_start,
      start_datetime <= window_end
    ), nomatch = NULL, allow.cartesian = TRUE,
    .(event_row = x.event_row, case_row = i.case_row)
  ]
  result <- events[hits$event_row]
  result[, case_row := hits$case_row]
  result[, event_row := NULL]
  result
}

#' Calculate all code-based case features once for reuse across FAS and periods
#' @param cases One row per case with patient_id, age and code_cutoff.
#' @param diagnoses Normalised ICD events with code.
#' @param medications Normalised ATC events with code.
#' @param observations Normalised laboratory events with code, relevant, unit_ok,
#'   numeric_ok, abnormal, normal, egfr and value_reference.
#' @param procedures Prepared OPS events with proc_code_code and ops_terminal.
#' @return Case rows with metric columns named for the internal local specification row.
calculateCohortCodeFeatures <- function(cases, diagnoses, medications, observations, procedures) {
  cases <- data.table::copy(data.table::as.data.table(cases))
  # Aggregation depends on the availability of interpretable source data, not on
  # a positive finding. Missing source data must never silently become zero.
  put <- function(row, value) data.table::set(cases, j = paste0("m", row), value = value)
  count <- function(events, selected, available = rep(TRUE, nrow(events))) {
    result <- rep(NA_real_, nrow(cases))
    result[unique(events$case_row[which(available)])] <- 0
    chosen <- events[which(selected)]
    if (nrow(chosen)) {
      totals <- chosen[, .(value = data.table::uniqueN(code)), by = case_row]
      result[totals$case_row] <- totals$value
    }
    result
  }
  icd <- matchCohortEvents(cases, diagnoses, "hospital_end")
  icd <- icd[!is.na(code) & grepl("^[A-Z][0-9]{2}([.][0-9A-Z]{1,2})?[!+*]?$", code)]
  full <- count(icd, rep(TRUE, nrow(icd)))
  put(65, full > 0)
  put(67, full)
  truncated <- data.table::copy(icd)
  truncated[, code := substr(code, 1, 3)]
  put(69, full > 0)
  put(71, count(truncated, rep(TRUE, nrow(truncated))))
  # Reuse the complete diagnoses for the established Charlson implementation.
  cci <- rep(NA_real_, nrow(cases))
  if (nrow(icd)) {
    etlutils::addCharlsonScore(icd, "case_row", "code", cciColumnName = "cci")
    scores <- unique(icd[, .(case_row, cci)])
    cci[scores$case_row] <- scores$cci
  }
  put(76, cci)
  put(74, cci + pmin(4, pmax(0, floor(cases$age / 10) - 4)))
  atc <- matchCohortEvents(cases, medications, "code_cutoff")
  atc <- atc[!is.na(code) & grepl("^[ABCDGHJLMNPRSV]([0-9]{2}([A-Z]([A-Z]([0-9]{2})?)?)?)?$", code)]
  atc[, full := nchar(code) == 7L]
  put(80, count(atc, rep(TRUE, nrow(atc))) > 0)
  put(82, count(atc, atc$full) > 0)
  full_atc <- atc[full == TRUE]
  put(85, count(full_atc, rep(TRUE, nrow(full_atc))))
  full_atc[, code := substr(code, 1, 4)]
  put(87, count(full_atc, rep(TRUE, nrow(full_atc))))
  for (i in seq_along(strsplit("ABCDGHJLMNPRSV", "")[[1]])) {
    letter <- strsplit("ABCDGHJLMNPRSV", "")[[1]][i]
    selected <- startsWith(atc$code, letter)
    put(91 + (i - 1) * 5, count(atc, selected) > 0)
    put(93 + (i - 1) * 5, count(atc, selected & atc$full) > 0)
  }
  for (window in c("code_cutoff", "hospital_end")) {
    obs <- matchCohortEvents(cases, observations, window)
    obs <- obs[relevant == TRUE & !is.na(code) & grepl("^[0-9]+-[0-9]$", code)]
    if ("compatible_unit" %in% names(obs)) {
      obs[, `:=`(unit_ok = unit_ok & compatible_unit, numeric_ok = numeric_ok & is.finite(value_reference))]
    }
    offset <- if (window == "hospital_end") 12L else 0L
    criteria <- list(
      rep(TRUE, nrow(obs)), obs$unit_ok, obs$numeric_ok,
      obs$numeric_ok & obs$abnormal, obs$numeric_ok & obs$normal
    )
    rows <- c(0, 2, 4, 7, 9)
    for (i in seq_along(criteria)) {
      # Normality requires at least one assessable numeric reference range.
      available <- if (i > 3) obs$numeric_ok & (!is.na(obs$abnormal) | !is.na(obs$normal)) else rep(TRUE, nrow(obs))
      n <- count(obs, criteria[[i]], available)
      # Both template blocks use the agreed INTERPOLAR-relevant scope.
      for (base in c(162L, 210L)) {
        put(base + offset + rows[i], n > 0)
        put(base + 24 + offset + rows[i], n)
      }
    }
    renal <- obs[egfr == TRUE]
    valid <- renal$numeric_ok & is.finite(renal$value_reference)
    base <- if (window == "hospital_end") 264L else 257L
    put(base, count(renal, valid) > 0)
    put(base + 3, count(renal, valid & renal$abnormal, valid & !is.na(renal$abnormal)) > 0)
    put(base + 5, count(renal, valid & renal$normal, valid & !is.na(renal$normal)) > 0)
    base <- if (window == "hospital_end") 280L else 271L
    put(base, count(renal, valid) > 0)
    for (i in 1:3) {
      selected <- list(
        renal$value_reference < 90,
        renal$value_reference >= 90 & renal$value_reference <= 130,
        renal$value_reference > 130
      )[[i]]
      put(base + c(3, 5, 7)[i], count(renal, valid & selected, valid) > 0)
    }
  }
  ops <- matchCohortEvents(cases, procedures, "code_cutoff")
  ops[, code := proc_code_code]
  ops <- ops[!is.na(code) & grepl("^[135689]-[0-9a-z]{3}([.][0-9a-z]+)?$", code)]
  put(291, count(ops, rep(TRUE, nrow(ops))) > 0)
  put(293, count(ops, ops$ops_terminal, !is.na(ops$ops_terminal)) > 0)
  for (i in seq_along(c("1", "3", "5", "8", "9"))) {
    selected <- startsWith(ops$code, c("1", "3", "5", "8", "9")[i])
    put(297 + (i - 1) * 5, count(ops, selected) > 0)
    put(299 + (i - 1) * 5, count(ops, selected & ops$ops_terminal, !is.na(ops$ops_terminal)) > 0)
  }
  for (row in c(322, 324)) {
    prefixes <- if (row == 322) c("8-853", "8-854", "8-855", "8-857", "8-85a")
    else c("8-015.y", "8-017", "8-125", "5-450.3", "5-431.2")
    selected <- Reduce(`|`, lapply(prefixes, function(prefix) startsWith(ops$code, prefix)))
    put(row, count(ops, selected) > 0)
  }
  cases
}
