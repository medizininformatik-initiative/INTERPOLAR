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
    "Snapshot creation also writes masked_references.csv and run.csv outside the database.",
    "masked_references.csv: removed references per copied row; enriched copies can repeat entries.",
    "run.csv: source database, evaluation date and completion time of database creation.",
    "IDs are taken from the source snapshot; no depseudonymization is performed.",
    "The consent-only review does not validate individual clinical resources.",
    "Original intervals remain in provisions.csv; changes.csv records adjusted intervals.",
    "retrospective_history_reset: .45/.46 deny discards prior .6 grants, not just the stated period.",
    "retrospective_start_applied: a modifier extends .6; subsequent restrictions can reduce it.",
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

# Only the failing decision group is read. Identifiers stay in the local review
# directory; the error message contains aggregate conditions and a file path.
writeBroadConsentConflictEvidence <- function(connection, query, review, base_table, relation) {
  name <- paste0("decision_conflicts_", base_table)
  partial_name <- paste0(name, "_incomplete")
  partial <- file.path(review$directory, paste0(partial_name, ".csv"))
  destination <- file.path(review$directory, paste0(name, ".csv"))
  on.exit(unlink(partial), add = TRUE)
  if (!file.create(partial) || !Sys.chmod(partial, mode = "0600")) {
    stop("Could not prepare local conflict evidence.")
  }
  result <- DBI::dbSendQuery(connection, paste0(query, " ORDER BY row_id, patient_id, reason"))
  on.exit(DBI::dbClearResult(result), add = TRUE)
  rows <- 0L
  missing_consent <- 0L
  inconsistent_reference <- 0L
  repeat {
    chunk <- DBI::dbFetch(result, n = DEFAULT_SNAPSHOT_CHUNK_SIZE)
    chunk$source_relation <- rep(relation, nrow(chunk))
    # The existing writer appends to an existing file, so write the first header explicitly.
    if (rows == 0L) {
      data.table::fwrite(chunk, partial, dateTimeAs = "ISO", na = "NA")
    } else {
      appendBroadConsentReviewTable(review, partial_name, chunk)
    }
    rows <- rows + nrow(chunk)
    missing_consent <- missing_consent + sum(chunk$patient_has_consent %in% FALSE)
    inconsistent_reference <- inconsistent_reference + sum(chunk$patient_reference_consistent %in% FALSE)
    if (DBI::dbHasCompleted(result)) break
  }
  if (!file.rename(partial, destination)) stop("Could not complete local conflict evidence.")
  paste0(
    "\nConflicting source/decision rows exported=", rows,
    if ("patient_has_consent" %in% names(chunk)) paste0(
      "\nRows without patient consent=", missing_consent,
      "\nRows with inconsistent patient reference=", inconsistent_reference
    ) else "",
    "\nConflicting identities cannot share one selection decision. Snapshot creation stopped.",
    "\nLocal conflict evidence: ", destination,
    "\nContains source identifiers; keep this file local and do not include it in data exports."
  )
}
