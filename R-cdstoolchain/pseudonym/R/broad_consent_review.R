newBroadConsentReview <- function(output_dir, evaluation_date, source_name, details = FALSE) {
  if (!dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)) {
    stop("Consent review directory must be new: ", output_dir)
  }
  writeLines(c(
    "Broad Consent review (incomplete until COMPLETE exists)",
    paste("Source:", source_name), paste("Evaluation date:", evaluation_date),
    "patients.csv: final patient inclusion and exclusion reason.",
    "provisions.csv: source provisions used for calculation; declared_at determines chronology.",
    "changes.csv: effective changes and the responsible Consent/Encounter ID.",
    "intervals.csv: final inclusive data periods for included patients.",
    "IDs are taken from the source snapshot; no depseudonymization is performed.",
    "The consent-only review does not validate individual clinical resources.",
    "Original intervals remain in provisions.csv; changes.csv records adjusted intervals.",
    "retrospective_permit_revoked: a later or simultaneous .45/.46 deny wins.",
    "retrospective_start_applied: a surviving modifier extends .6 to 1900-01-01.",
    "encounter_start_applied: .6 starts at the earlier enclosing Encounter start."
  ), file.path(output_dir, "README.txt"))
  list(directory = output_dir, details = details)
}

appendBroadConsentReviewTable <- function(review, name, rows) {
  file <- file.path(review$directory, paste0(name, ".csv"))
  data.table::fwrite(rows, file, append = file.exists(file), dateTimeAs = "ISO", na = "NA")
}

buildBroadConsentPatientReview <- function(patient_id, provisions, result) {
  tables <- list(patients = data.table::data.table(
    patient_id = patient_id, included = result$included, reason = result$reason
  ))
  for (name in c("provisions", "changes", "intervals")) {
    rows <- switch(
      name,
      provisions = provisions,
      changes = result$changes,
      intervals = result$periods
    )
    rows <- data.table::copy(rows)
    rows$patient_id <- rep(patient_id, nrow(rows))
    data.table::setcolorder(rows, c("patient_id", setdiff(names(rows), "patient_id")))
    tables[[name]] <- rows
  }
  tables
}

writeBroadConsentReviewBatch <- function(review, patients) {
  if (!isTRUE(review$details) || !length(patients)) return(invisible(NULL))
  for (name in c("patients", "provisions", "changes", "intervals")) {
    rows <- data.table::rbindlist(lapply(patients, `[[`, name))
    appendBroadConsentReviewTable(review, name, rows)
  }
  invisible(NULL)
}

writeBroadConsentPatientReview <- function(review, patient_id, provisions, result) {
  if (!isTRUE(review$details)) return(invisible(NULL))
  writeBroadConsentReviewBatch(review, list(buildBroadConsentPatientReview(patient_id, provisions, result)))
  invisible(NULL)
}

finishBroadConsentReview <- function(review, summary) {
  appendBroadConsentReviewTable(review, "summary", summary)
  writeLines("Consent calculation completed.", file.path(review$directory, "COMPLETE"))
  invisible(review$directory)
}
