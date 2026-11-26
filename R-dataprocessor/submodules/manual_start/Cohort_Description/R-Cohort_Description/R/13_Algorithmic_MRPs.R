#' Load stored MRP counts and completed REDCap reviews
#' @param record_ids REDCap record IDs with patient_id.
#' @return Counts by case and MedA, and completed reviews by patient and MedA.
loadCohortAlgorithmicReviews <- function(record_ids) {
  calculations <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT DISTINCT enc_id AS case_id, meda_id, ret_id, dp_mrp_calculations_id ",
      "FROM v_dp_mrp_calculations WHERE meda_id IS NOT NULL"
    ),
    lock_id = "Cohort Description: algorithmic MRPs"
  )
  reviews <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT DISTINCT record_id, ret_meda_id AS meda_id, ret_id, ",
      "ret_gewissheit1, ret_gewiss_grund1_abl, ret_gewiss_grund1_abl_01 ",
      "FROM v_retrolektive_mrpbewertung_fe_last_version ",
      "WHERE retrolektive_mrpbewertung_complete = 'Complete'"
    ),
    lock_id = "Cohort Description: completed MRP reviews"
  )
  list(calculations = calculations, reviews = merge(reviews, record_ids, by = "record_id", sort = FALSE))
}

#' Add FAS 4 flags and counts for the first completed MedA of the hospital case
#' @param cases Case features.
#' @param first First completed MedA of the case, with its location.
#' @param first_ip First completed MedA during the first IP stay.
#' @param evidence Stored calculations and completed reviews, or NULL.
#' @return Case features with FAS evidence and MRP counts.
addCohortAlgorithmicMRPFlags <- function(cases, first, first_ip, evidence) {
  cases[, `:=`(
    has_reviewed_algorithmic_mrp = FALSE,
    has_irrelevant_algorithmic_mrp = FALSE,
    has_relevant_algorithmic_mrp = FALSE,
    first_meda_location = NA_character_, first_meda_mrps = 0L
  )]
  cases[first$case_row, first_meda_location := first$meda_location]
  if (is.null(evidence) || !nrow(evidence$calculations)) return(cases)

  calculations <- evidence$calculations
  meda_key <- c("case_id", "meda_id")
  counts <- merge(first[, c(meda_key, "case_row"), with = FALSE], calculations, by = meda_key)
  counts <- counts[, .(n = data.table::uniqueN(ret_id[!is.na(ret_id) & nzchar(ret_id)]) +
    data.table::uniqueN(dp_mrp_calculations_id[is.na(ret_id) | !nzchar(ret_id)], na.rm = TRUE)),
  by = case_row
  ]
  cases[counts$case_row, first_meda_mrps := counts$n]

  eligible <- merge(first_ip[, .(patient_id, case_id, meda_id, case_row)], calculations, by = meda_key)
  review_key <- c("patient_id", "meda_id")
  reviewed <- merge(unique(eligible[, .(patient_id, meda_id, case_row)]),
    unique(evidence$reviews[, ..review_key]),
    by = review_key
  )
  # FAS 4 requires both kinds of evidence on the same MedA. Only the subgroups
  # require the completed review to identify the same calculated MRP.
  cases[unique(reviewed$case_row), has_reviewed_algorithmic_mrp := TRUE]
  matched <- merge(
    unique(eligible[!is.na(ret_id) & nzchar(ret_id), .(patient_id, meda_id, case_row, ret_id)]),
    evidence$reviews,
    by = c(review_key, "ret_id"), allow.cartesian = TRUE
  )
  irrelevant <- "MRP sachlich richtig, aber klinisch nicht relevant"
  matched[, `:=`(
    is_irrelevant = ret_gewissheit1 %in% "MRP nicht bestätigt" &
      (ret_gewiss_grund1_abl %in% irrelevant | ret_gewiss_grund1_abl_01 %in% irrelevant),
    is_relevant = ret_gewissheit1 %in% c(
      "MRP bestätigt", "MRP bestätigt und von Stationsapotheker vorher identifiziert"
    )
  )]
  # Contradictory reviews of one MRP provide neither subgroup classification.
  flags <- matched[, .(irrelevant = any(is_irrelevant), relevant = any(is_relevant)),
    by = .(case_row, ret_id)
  ]
  cases[unique(flags[irrelevant & !relevant, case_row]), has_irrelevant_algorithmic_mrp := TRUE]
  cases[unique(flags[relevant & !irrelevant, case_row]), has_relevant_algorithmic_mrp := TRUE]
  cases
}

writeCohortMRPByMedALocation <- function(populations, periods, directory) {
  locations <- c("before_first_ip", "first_ip", "after_subsequent_ip", "after_non_ip")
  grid <- periods[, .(first_meda_location = locations), by = .(ward_name, phase)]
  counts <- populations[!is.na(first_meda_location), .(
    cases_with_first_completed_meda = .N,
    cases_with_algorithmic_mrp = sum(first_meda_mrps > 0L),
    algorithmic_mrps = sum(first_meda_mrps)
  ), by = .(ward_name, phase, first_meda_location)]
  keys <- c("ward_name", "phase", "first_meda_location")
  result <- counts[grid, on = keys]
  for (column in setdiff(names(result), keys)) data.table::setnafill(result, fill = 0L, cols = column)
  data.table::fwrite(result, file.path(directory, "algorithmic_mrps_by_first_meda_timing.csv"))
}
