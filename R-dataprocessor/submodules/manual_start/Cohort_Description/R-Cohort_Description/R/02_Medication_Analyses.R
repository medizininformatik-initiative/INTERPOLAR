#' Derive case and first-contact medication analysis selections
#'
#' @param cases One row per patient/case with hospital_start/end and ip_start/end.
#' @param analyses Patient-linked latest MedA versions with patient_id, meda_id,
#'   meda_dat and medikationsanalyse_complete. Earlier incomplete forms are ignored.
#' @return All completed MedAs within each hospital case plus the first completed
#'   MedA of the case and the first completed MedA within its first known IP stay.
#'   Hospital bounds are inclusive; IP intervals include start and exclude end.
prepareCohortMedicationAnalyses <- function(cases, analyses) {
  cases <- data.table::copy(data.table::as.data.table(cases))
  analyses <- data.table::copy(data.table::as.data.table(analyses))
  join_columns <- c("patient_id", intersect("case_id", names(analyses)))
  if (!"redcap_repeat_instance" %in% names(analyses)) analyses[, redcap_repeat_instance := NA_integer_]
  columns <- c(join_columns, "meda_id", "meda_dat", "redcap_repeat_instance")
  analyses <- unique(analyses[
    medikationsanalyse_complete %in% "Complete" & !is.na(meda_dat),
    ..columns
  ])
  if (anyDuplicated(analyses, by = c("patient_id", "meda_id"))) {
    stop("Latest MedA versions contain conflicting dates for the same analysis.")
  }
  # A patient can have concurrent cases; retain each qualifying case/MedA pair.
  joined <- merge(cases[, .(patient_id, case_id, hospital_start, hospital_end, ip_start, ip_end)],
    analyses,
    by = join_columns, allow.cartesian = TRUE, sort = FALSE
  )
  # BS eligibility does not require hospital discharge. A case-linked MedA can
  # still be assigned to a closed first IP interval when that discharge is absent.
  joined <- joined[meda_dat >= hospital_start & (is.na(hospital_end) | meda_dat <= hospital_end)]
  joined[, on_first_ip := !is.na(ip_end) & meda_dat >= ip_start & meda_dat < ip_end]
  joined[, redcap_repeat_instance := suppressWarnings(as.integer(redcap_repeat_instance))]
  data.table::setorderv(joined, c("patient_id", "case_id", "meda_dat", "redcap_repeat_instance"), na.last = TRUE)
  # Tied first analyses can carry different MRPs: never decide by hashed MedA ID.
  checkFirstTies <- function(x) {
    dates <- unique(x[, .(patient_id, case_id, meda_dat)])
    first_dates <- dates[!duplicated(dates, by = c("patient_id", "case_id"))]
    candidates <- merge(x, first_dates, by = c("patient_id", "case_id", "meda_dat"))
    tied <- duplicated(candidates, by = c("patient_id", "case_id")) |
      duplicated(candidates, by = c("patient_id", "case_id"), fromLast = TRUE)
    if (
      any(tied & is.na(candidates$redcap_repeat_instance)) ||
      anyDuplicated(candidates, by = c("patient_id", "case_id", "redcap_repeat_instance"))
    ) {
      stop("MedAs sharing the earliest timestamp lack an unambiguous REDCap instance order.")
    }
    data.table::setorderv(candidates, c("patient_id", "case_id", "redcap_repeat_instance"), na.last = TRUE)
    candidates[!duplicated(candidates, by = c("patient_id", "case_id"))]
  }
  list(
    all_completed = joined, first_case = checkFirstTies(joined),
    first_ip = checkFirstTies(joined[on_first_ip == TRUE])
  )
}

#' Classify completed MedAs relative to known INTERPOLAR stays
#'
#' @param completed Case-linked analyses returned as `all_completed` by
#'   prepareCohortMedicationAnalyses().
#' @param contacts Known IP intervals with patient_id, case_id, enc_period_start
#'   and enc_period_end, including subsequent stays on the same ward.
#' @return A copy of completed with meda_location. Known intervals include their
#'   start and exclude their end. Overlapping contacts never multiply analyses.
classifyCohortMedicationAnalyses <- function(completed, contacts
) {
  completed <- data.table::copy(data.table::as.data.table(completed))
  contacts <- data.table::as.data.table(contacts)
  completed[, meda_location := data.table::fcase(
    on_first_ip, "first_ip",
    meda_dat < ip_start, "before_first_ip",
    meda_dat >= ip_end, "after_non_ip",
    default = NA_character_
  )]
  # Only later analyses need an interval lookup. Ward identity is deliberately
  # irrelevant: returning to the same ward is another IP stay as well.
  later_rows <- which(completed$meda_location == "after_non_ip")
  later <- completed[later_rows, .(patient_id, case_id, meda_dat)]
  later[, analysis_row := later_rows]
  intervals <- unique(contacts[
    !is.na(enc_period_start) & !is.na(enc_period_end) & enc_period_end > enc_period_start,
    .(patient_id, case_id, enc_period_start, enc_period_end)
  ])
  if (nrow(later) && nrow(intervals)) {
    matches <- intervals[later,
      on = .(patient_id, case_id, enc_period_start <= meda_dat, enc_period_end > meda_dat),
      nomatch = NULL, allow.cartesian = TRUE, .(analysis_row = i.analysis_row)
    ]
    completed[unique(matches$analysis_row), meda_location := "after_subsequent_ip"]
  }
  completed
}
