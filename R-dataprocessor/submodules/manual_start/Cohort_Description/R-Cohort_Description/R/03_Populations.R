#' Define site-specific study periods from validated ward configuration
#'
#' @param wards Table with ward_name, phase_a_start, phase_b_start, phase_b_end.
#' @param source Either regular or broad_consent.
#' @param timezone Time zone for the fixed TRS calendar boundaries.
#' @return One row per ward and selected study with inclusive start and
#'   exclusive end; CRS admission and discharge limits remain site-wide.
buildCohortPeriods <- function(wards, source = "regular", timezone = etlutils::GLOBAL_TIMEZONE) {
  if (!source %in% c("regular", "broad_consent")) stop("Unknown cohort data source.")
  wards <- data.table::copy(data.table::as.data.table(wards))
  if (
    !nrow(wards) || anyNA(wards[, .(ward_name, phase_a_start, phase_b_start, phase_b_end)]) ||
    anyDuplicated(wards$ward_name)
  ) {
    stop("Cohort periods require unique wards and complete phase dates.")
  }
  if (any(wards$phase_a_start >= wards$phase_b_start | wards$phase_b_start >= wards$phase_b_end)) {
    stop("Ward phase dates must be chronologically ordered.")
  }
  crs_start <- min(wards$phase_b_start) - as.difftime(28, units = "days")
  crs_end <- max(wards$phase_b_end)
  data.table::rbindlist(lapply(seq_len(nrow(wards)), function(i) {
    ward <- wards[i]
    if (source == "broad_consent") {
      trs_start <- as.POSIXct("2023-01-01", tz = timezone)
      trs_end <- as.POSIXct("2027-01-01", tz = timezone)
      return(data.table::data.table(
        ward_name = ward$ward_name, phase = c("TRS", "RES"),
        period_start = c(as.POSIXct(NA), ward$phase_b_start),
        period_end = c(as.POSIXct(NA), crs_end),
        admission_start = c(trs_start, crs_start),
        admission_end = c(trs_end, crs_end),
        discharge_limit = c(as.POSIXct(NA), crs_end + as.difftime(28, units = "days"))
      ))
    }
    data.table::data.table(
      ward_name = ward$ward_name,
      phase = c("BS", "CRS A", "CRS B"),
      period_start = c(ward$phase_a_start, crs_start, ward$phase_b_start),
      period_end = c(crs_start, ward$phase_b_start, crs_end),
      admission_start = c(ward$phase_a_start, rep(crs_start, 2)),
      admission_end = c(crs_start, rep(crs_end, 2)),
      discharge_limit = c(as.POSIXct(NA), rep(crs_end + as.difftime(28, units = "days"), 2))
    )
  }))
}

#' Assign complete case features to study periods and FAS populations
#'
#' @param cases One row per patient/case with ward_name, age, hospital_start/end,
#'   ip_start/end, has_completed_ip_meda and has_qualifying_manual_mrp.
#' @param periods Output of buildCohortPeriods().
#' @param timezone Time zone used to compare the first IP start and end dates.
#' @return One row per eligible case and phase with logical FAS membership flags.
assignCohortPopulations <- function(cases, periods, timezone) {
  cases <- data.table::copy(data.table::as.data.table(cases))
  if (anyDuplicated(cases, by = c("patient_id", "case_id"))) {
    stop("Population assignment requires one row per patient/case.")
  }
  if (any(!cases$ward_name %in% periods$ward_name)) {
    stop("Known IP stations are missing from the configured study periods.")
  }
  joined <- merge(cases, periods, by = "ward_name", allow.cartesian = TRUE, sort = FALSE)
  joined <- joined[!is.na(age) & age >= 18 &
    !is.na(ip_end) & as.Date(ip_end, tz = timezone) > as.Date(ip_start, tz = timezone) &
    hospital_start >= admission_start & hospital_start < admission_end &
    (is.na(period_start) | ip_start >= period_start) &
    (is.na(period_end) | ip_start < period_end) &
    (is.na(discharge_limit) | (!is.na(hospital_end) & hospital_end < discharge_limit))]
  joined[, `:=`(fas1 = TRUE, fas22 = has_completed_ip_meda %in% TRUE)]
  joined[, fas21 := fas22 | (!is.na(ip_end) & as.numeric(difftime(ip_end, ip_start, units = "hours")) >= 168)]
  joined[, fas3 := fas22 & has_qualifying_manual_mrp %in% TRUE]
  joined[, `:=`(
    fas4 = fas22 & has_reviewed_algorithmic_mrp %in% TRUE,
    fas41 = fas22 & has_irrelevant_algorithmic_mrp %in% TRUE,
    fas42 = fas22 & has_relevant_algorithmic_mrp %in% TRUE
  )]
  joined
}
