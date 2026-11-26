#' Derive medication-analysis metrics and cutoff from one prepared MedA set
#' @param cases Hospital cases with first known IP interval.
#' @param analyses Patient-linked MedA forms.
#' @param contacts Known IP contacts with case_id.
#' @param validations Patient-linked manual MRP forms with meda_id and outcome.
#' @param algorithmic_reviews Stored calculations and completed reviews.
#' @return Case rows with selection flags, cutoff and all MedA metric columns.
calculateCohortMedAFeatures <- function(cases, analyses, contacts, validations, algorithmic_reviews = NULL) {
  cases <- data.table::copy(data.table::as.data.table(cases))
  selection <- prepareCohortMedicationAnalyses(cases, analyses)
  completed <- classifyCohortMedicationAnalyses(selection$all_completed, contacts)
  first <- classifyCohortMedicationAnalyses(selection$first_case, contacts)
  key <- c("patient_id", "case_id")
  cases[, case_row := .I]
  completed <- merge(completed, cases[, c(key, "case_row"), with = FALSE], by = key)
  first <- merge(first, cases[, c(key, "case_row"), with = FALSE], by = key)
  first_ip <- merge(selection$first_ip, cases[, c(key, "case_row"), with = FALSE], by = key)
  cases[, `:=`(
    has_completed_ip_meda = FALSE, has_qualifying_manual_mrp = FALSE,
    code_cutoff = ip_start + as.difftime(3, units = "days")
  )]
  cases[first_ip$case_row, `:=`(has_completed_ip_meda = TRUE, code_cutoff = first_ip$meda_dat)]
  cases[code_cutoff > hospital_end, code_cutoff := as.POSIXct(NA)]
  outcomes <- c(
    "Intervention vorgeschlagen und umgesetzt",
    "Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation)",
    "Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung)",
    "Problem nicht gelöst"
  )
  qualifying <- unique(validations[
    outcome %in% outcomes & !is.na(mrp_id) & nzchar(mrp_id),
    .(patient_id, meda_id)
  ])
  eligible <- merge(first_ip, qualifying, by = c("patient_id", "meda_id"))
  cases[eligible$case_row, has_qualifying_manual_mrp := TRUE]
  locations <- c("all", "first_ip", "before_first_ip", "after_subsequent_ip", "after_non_ip")
  for (i in seq_along(locations)) {
    location <- locations[i]
    f <- if (location == "all") first else first[meda_location == location]
    a <- if (location == "all") completed else completed[meda_location == location]
    values <- rep(FALSE, nrow(cases))
    values[f$case_row] <- TRUE
    data.table::set(cases, j = paste0("m", 328 + (i - 1) * 2), value = values)
    values <- integer(nrow(cases))
    counts <- a[, .(count = data.table::uniqueN(meda_id)), by = case_row]
    values[counts$case_row] <- counts$count
    data.table::set(cases, j = paste0("m", 339 + (i - 1) * 2), value = values)
  }
  for (row in c(350, 352, 355, 357)) {
    selected <- if (row >= 355) first[on_first_ip == TRUE] else first
    origin <- if (row %in% c(350, 355)) selected$hospital_start else selected$ip_start
    values <- rep(NA_real_, nrow(cases))
    values[selected$case_row] <- as.numeric(difftime(selected$meda_dat, origin, units = "days"))
    data.table::set(cases, j = paste0("m", row), value = values)
  }
  cases <- addCohortAlgorithmicMRPFlags(cases, first, first_ip, algorithmic_reviews)
  cases[, case_row := NULL]
  cases
}
