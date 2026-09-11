getBroadConsentCurrentRelation <- function(connection, table_name, source_schema,
  source_view_prefix = "v_", last_version_suffix = SNAPSHOT_LAST_VERSION_SUFFIX) {
  last <- paste0(source_view_prefix, table_name, last_version_suffix)
  if (!snapshotRelationExists(connection, last, source_schema)) {
    stop("Consent evaluation requires a current-version view: ", last)
  }
  snapshotQualifiedName(connection, last, source_schema)
}

normalizeBroadConsentReference <- function(values, resource_type = "Patient") {
  values <- extractFhirReferenceId(values, resource_type)
  valid <- !is.na(values) & grepl("^[A-Za-z0-9.-]+$", values)
  values[!valid] <- NA_character_
  values
}

readBroadConsentProvisions <- function(rows) {
  columns <- c(
    consent_id = "cons_id", declared_at = "cons_datetime", status = "cons_status",
    system = "cons_provision_provision_code_system", code = "cons_provision_provision_code_code",
    type = "cons_provision_provision_type", start = "cons_provision_provision_period_start",
    end = "cons_provision_provision_period_end"
  )
  if (!all(unname(columns) %in% names(rows))) stop("Consent table lacks required provision columns.")
  result <- data.table::as.data.table(rows[, unname(columns), drop = FALSE])
  data.table::setnames(result, unname(columns), names(columns))
  # PostgreSQL timestamp columns arrive as POSIXct. Do not silently parse
  # unexpected text columns and risk losing precision or conversion failures.
  if (
    !inherits(result$declared_at, "POSIXct") || !inherits(result$start, "POSIXct") ||
    !inherits(result$end, "POSIXct")
  ) {
    stop("Expected timestamp columns in the Consent source.")
  }
  result$start <- as.Date(result$start, tz = "UTC")
  result$end <- as.Date(result$end, tz = "UTC")
  result
}

# The adapter uses keyset batches, not OFFSET or one query per patient.
# Current-version source views prevent superseded Consent versions from
# resurrecting permissions. Temporary results are connection-local only.
prepareBroadConsentSelection <- function(
  connection, source_schema, evaluation_date, chunk_size, review,
  source_view_prefix = "v_", last_version_suffix = SNAPSHOT_LAST_VERSION_SUFFIX
) {
  consent_relation <- getBroadConsentCurrentRelation(connection, "consent", source_schema, source_view_prefix, last_version_suffix)
  encounter_relation <- getBroadConsentCurrentRelation(connection, "encounter", source_schema, source_view_prefix, last_version_suffix)
  patient_relation <- getBroadConsentCurrentRelation(connection, "patient", source_schema, source_view_prefix, last_version_suffix)
  reference <- snapshotNormalizedReferenceExpression(connection, "cons_patient_ref", resource_type = "Patient")
  invalid_references <- DBI::dbGetQuery(connection, paste0(
    "SELECT COUNT(*) AS n FROM ", consent_relation,
    " WHERE (cons_status NOT IN ('draft', 'proposed', 'rejected', 'inactive', 'entered-in-error') ",
    "OR cons_status IS NULL) AND (",
    reference, " IS NULL OR ", reference, " !~ '^[A-Za-z0-9.-]+$')"
  ))$n
  if (invalid_references > 0) {
    stop("Potentially effective Consent resources have unresolvable patient references; restrictions cannot be assigned safely.")
  }
  snapshotAllowTemporarySourceTables(connection)
  table_name <- basename(tempfile("broad_consent_intervals_"))
  table <- snapshotQualifiedName(connection, table_name)
  DBI::dbExecute(connection, paste0(
    "CREATE TEMP TABLE ", table,
    " (patient_id text NOT NULL, start date NOT NULL, \"end\" date NOT NULL)"
  ))
  complete <- FALSE
  on.exit(if (!complete) DBI::dbExecute(connection, paste0("DROP TABLE IF EXISTS ", table)), add = TRUE)
  last_id <- NULL
  counts <- integer()
  names(counts) <- character()
  repeat {
    predicate <- if (is.null(last_id)) "" else paste0(
      " AND pat_id::text > ", DBI::dbQuoteString(connection, last_id)
    )
    ids <- DBI::dbGetQuery(connection, paste0(
      "SELECT DISTINCT pat_id::text AS patient_id FROM ", patient_relation,
      " WHERE pat_id IS NOT NULL", predicate, " ORDER BY patient_id LIMIT ", as.integer(chunk_size)
    ))$patient_id
    if (!length(ids)) break
    if (anyNA(normalizeBroadConsentReference(ids))) stop("Invalid Patient resource ID in source.")
    last_id <- tail(ids, 1L)
    values <- paste(DBI::dbQuoteString(connection, ids), collapse = ", ")
    source_rows <- DBI::dbGetQuery(connection, paste0(
      "SELECT DISTINCT cons_id, cons_datetime, cons_status, cons_patient_ref, ",
      "cons_provision_provision_code_system, cons_provision_provision_code_code, ",
      "cons_provision_provision_type, cons_provision_provision_period_start, ",
      "cons_provision_provision_period_end FROM ", consent_relation,
      " WHERE ", reference, " IN (", values, ")"
    ))
    encounter_reference <- snapshotNormalizedReferenceExpression(connection, "enc_patient_ref", resource_type = "Patient")
    encounter_rows <- DBI::dbGetQuery(connection, paste0(
      "SELECT DISTINCT enc_id, enc_patient_ref, enc_period_start, enc_period_end FROM ", encounter_relation,
      " WHERE ", encounter_reference, " IN (", values, ")"
    ))
    # Index each block once instead of scanning all rows again for every patient.
    source_indices <- split(seq_len(nrow(source_rows)), normalizeBroadConsentReference(source_rows$cons_patient_ref))
    encounter_indices <- split(seq_len(nrow(encounter_rows)), normalizeBroadConsentReference(encounter_rows$enc_patient_ref))
    intervals <- list()
    patient_reviews <- list()
    for (patient_id in ids) {
      provisions <- readBroadConsentProvisions(source_rows[source_indices[[patient_id]], , drop = FALSE])
      encounters <- encounter_rows[encounter_indices[[patient_id]], , drop = FALSE]
      encounters <- data.table::data.table(
        encounter_id = encounters$enc_id,
        start = as.Date(encounters$enc_period_start, tz = "UTC"),
        end = as.Date(encounters$enc_period_end, tz = "UTC")
      )
      result <- calculateBroadConsentPatient(provisions, encounters, evaluation_date)
      count <- counts[result$reason]
      counts[result$reason] <- if (is.na(count)) 1L else count + 1L
      if (isTRUE(review$details)) {
        patient_reviews[[length(patient_reviews) + 1L]] <- buildBroadConsentPatientReview(patient_id, provisions, result)
      }
      if (result$included) {
        periods <- data.table::copy(result$periods)
        periods$patient_id <- patient_id
        intervals[[length(intervals) + 1L]] <- periods[, c("patient_id", "start", "end"), with = FALSE]
      }
    }
    writeBroadConsentReviewBatch(review, patient_reviews)
    if (length(intervals)) DBI::dbAppendTable(connection, table_name, data.table::rbindlist(intervals))
  }
  DBI::dbExecute(connection, paste0("CREATE INDEX ON ", table, " (patient_id, start, \"end\")"))
  DBI::dbExecute(connection, paste0("ANALYZE ", table))
  summary <- data.table::data.table(reason = names(counts), patients = unname(counts))
  finishBroadConsentReview(review, summary)
  complete <- TRUE
  list(table_name = table_name, summary = summary, evaluation_date = evaluation_date)
}

#' Review Broad Consent Without Creating a Snapshot
#'
#' Evaluates current Consent resources and Encounter periods from an activated
#' snapshot. Writes patient decisions, source provisions, effective changes and
#' final data intervals. Clinical resources are not scanned or copied.
#'
#' @param source_connection DBI connection to the source snapshot.
#' @param project_root Project root containing the local output directory.
#' @param source_schema Schema containing current-version source views.
#' @param chunk_size Maximum number of patients read per database batch.
#' @param report_dir New output directory. If `NULL`, creates a unique directory
#'   below `outputLocal/broad_consent_review`.
#' @param evaluation_date Explicit evaluation date, defaulting to the current
#'   date captured once at the start of this invocation.
#'
#' @return The review directory, evaluation date and patient summary.
#' @export
reviewBroadConsentSnapshot <- function(
  source_connection, project_root = ".", source_schema = "db2dataprocessor_out",
  chunk_size = DEFAULT_SNAPSHOT_CHUNK_SIZE, report_dir = NULL, evaluation_date = Sys.Date()
) {
  force(evaluation_date)
  chunk_size <- validateSnapshotChunkSize(chunk_size)
  if (is.null(report_dir)) {
    report_dir <- tempfile(
      pattern = paste0(format(Sys.time(), "%Y%m%d_%H%M%S"), "_"),
      tmpdir = file.path(project_root, "outputLocal", "broad_consent_review")
    )
  }
  source_name <- DBI::dbGetQuery(source_connection, "SELECT current_database() AS name")$name
  review <- newBroadConsentReview(report_dir, evaluation_date, source_name, details = TRUE)
  selection <- prepareBroadConsentSelection(
    source_connection, source_schema, evaluation_date, chunk_size, review
  )
  DBI::dbRemoveTable(source_connection, selection$table_name)
  list(directory = report_dir, evaluation_date = evaluation_date, summary = selection$summary)
}
