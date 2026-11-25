#' Load completed reviews linked to calculated MRPs for the selected patients
#' @param record_ids REDCap record IDs with patient_id.
#' @return Algorithmic MRP reviews with patient, case and MedA keys.
loadCohortAlgorithmicReviews <- function(record_ids) {
  # Existing MRP workflows link calculation evidence and frontend reviews by ret_id.
  # Read only completed reviews; patient, case and MedA keys also guard the join.
  reviews <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT DISTINCT r.record_id, c.enc_id AS case_id, c.meda_id, r.ret_id, ",
      "r.ret_gewissheit1, r.ret_gewiss_grund1_abl, r.ret_gewiss_grund1_abl_01 ",
      "FROM v_retrolektive_mrpbewertung_fe_last_version r ",
      "JOIN v_dp_mrp_calculations c ON c.ret_id = r.ret_id AND c.meda_id = r.ret_meda_id ",
      "WHERE r.retrolektive_mrpbewertung_complete = 'Complete'"
    ),
    lock_id = "Cohort Description: completed algorithmic MRP reviews"
  )
  merge(reviews, record_ids, by = "record_id", sort = FALSE)
}

#' Assign provisional FAS 4 evidence from completed first-IP medication analyses
#' @param cases Case features.
#' @param completed Completed case-linked MedAs with on_first_ip.
#' @param reviews Completed reviews linked to algorithmic calculations, or NULL.
#' @return Case features with three algorithmic MRP flags.
addCohortAlgorithmicMRPFlags <- function(cases, completed, reviews) {
  cases <- data.table::copy(data.table::as.data.table(cases))
  cases[, `:=`(
    has_reviewed_algorithmic_mrp = FALSE,
    has_irrelevant_algorithmic_mrp = FALSE,
    has_relevant_algorithmic_mrp = FALSE
  )]
  if (is.null(reviews) || !nrow(reviews)) return(cases)
  # Pending scientific confirmation: all completed MedAs during the first IP stay,
  # and their completed reviews available in the snapshot, including later reviews.
  eligible <- merge(
    unique(completed[on_first_ip == TRUE, .(patient_id, case_id, meda_id)]),
    reviews,
    by = c("patient_id", "case_id", "meda_id"), sort = FALSE
  )
  irrelevant <- "MRP sachlich richtig, aber klinisch nicht relevant"
  eligible[, `:=`(
    is_irrelevant = ret_gewissheit1 %in% "MRP nicht bestätigt" &
      (ret_gewiss_grund1_abl %in% irrelevant | ret_gewiss_grund1_abl_01 %in% irrelevant),
    is_relevant = ret_gewissheit1 %in% c(
      "MRP bestätigt", "MRP bestätigt und von Stationsapotheker vorher identifiziert"
    )
  )]
  flags <- eligible[, .(
    has_reviewed_algorithmic_mrp = TRUE,
    has_irrelevant_algorithmic_mrp = any(is_irrelevant),
    has_relevant_algorithmic_mrp = any(is_relevant)
  ), by = .(patient_id, case_id)]
  cases[flags, on = .(patient_id, case_id), `:=`(
    has_reviewed_algorithmic_mrp = i.has_reviewed_algorithmic_mrp,
    has_irrelevant_algorithmic_mrp = i.has_irrelevant_algorithmic_mrp,
    has_relevant_algorithmic_mrp = i.has_relevant_algorithmic_mrp
  )]
  cases
}
