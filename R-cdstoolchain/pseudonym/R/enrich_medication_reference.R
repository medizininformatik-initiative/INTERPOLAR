SNAPSHOT_MEDICATION_REFERENCE_SPECS <- data.frame(
  table_name = c(
    "medicationrequest",
    "medicationadministration",
    "medicationstatement"
  ),
  reference_column = c(
    "medreq_medicationreference_ref",
    "medadm_medicationreference_ref",
    "medstat_medicationreference_ref"
  ),
  system_column = c(
    "medreq_medication_system",
    "medadm_medication_system",
    "medstat_medication_system"
  ),
  code_column = c(
    "medreq_medication_code",
    "medadm_medication_code",
    "medstat_medication_code"
  ),
  stringsAsFactors = FALSE
)

extractMedicationReferenceId <- function(references) {
  references <- as.character(references)
  references[is.na(references) | !nzchar(references)] <- NA_character_
  references <- sub("^\\[[^]]+\\]", "", references)
  references <- sub("^Medication/", "", references)
  references
}

getMedicationCodeMap <- function(medication) {
  required_columns <- c("med_id", "med_code_system", "med_code_code")
  missing_columns <- setdiff(required_columns, names(medication))
  if (length(missing_columns) > 0) {
    stop(
      "Medication table is missing required columns for medication-code enrichment: ",
      paste(missing_columns, collapse = ", ")
    )
  }

  medication <- as.data.frame(data.table::copy(medication), stringsAsFactors = FALSE)
  medication_codes <- unique(medication[, required_columns, drop = FALSE])
  medication_codes <- medication_codes[
    !is.na(medication_codes[["med_id"]]) &
      nzchar(medication_codes[["med_id"]]) &
      !is.na(medication_codes[["med_code_system"]]) &
      nzchar(medication_codes[["med_code_system"]]) &
      !is.na(medication_codes[["med_code_code"]]) &
      nzchar(medication_codes[["med_code_code"]]), ,
    drop = FALSE
  ]
  split(medication_codes, medication_codes[["med_id"]], drop = TRUE)
}

enrichMedicationReferenceTable <- function(table, medication_code_map, reference_column, system_column, code_column) {
  table <- as.data.frame(data.table::copy(table), stringsAsFactors = FALSE)
  if (!reference_column %in% names(table)) {
    return(data.table::as.data.table(table))
  }
  if (!system_column %in% names(table)) {
    table[[system_column]] <- rep(NA_character_, nrow(table))
  }
  if (!code_column %in% names(table)) {
    table[[code_column]] <- rep(NA_character_, nrow(table))
  }
  if (nrow(table) == 0) {
    return(data.table::as.data.table(table))
  }

  reference_ids <- extractMedicationReferenceId(table[[reference_column]])
  enriched_rows <- vector("list", nrow(table))
  for (i in seq_len(nrow(table))) {
    medication_codes <- medication_code_map[[reference_ids[i]]]
    if (is.null(medication_codes) || nrow(medication_codes) == 0) {
      row <- table[i, , drop = FALSE]
      row[[system_column]] <- NA_character_
      row[[code_column]] <- NA_character_
      enriched_rows[[i]] <- row
      next
    }

    row <- table[rep(i, nrow(medication_codes)), , drop = FALSE]
    row[[system_column]] <- medication_codes[["med_code_system"]]
    row[[code_column]] <- medication_codes[["med_code_code"]]
    enriched_rows[[i]] <- row
  }

  data.table::as.data.table(do.call(rbind, enriched_rows))
}

emptyMedicationReferenceReport <- function() {
  data.table::data.table(
    TABLE_NAME = character(),
    REFERENCE_COLUMN = character(),
    REFERENCE_VALUE = character(),
    MEDICATION_ID = character(),
    N = integer()
  )
}

getUnmatchedMedicationReferencesForTable <- function(table, medication_code_map, table_name, reference_column) {
  if (is.null(table) || !reference_column %in% names(table)) {
    return(emptyMedicationReferenceReport())
  }
  table <- data.table::as.data.table(data.table::copy(table))
  if (nrow(table) == 0) {
    return(emptyMedicationReferenceReport())
  }

  references <- as.character(table[[reference_column]])
  medication_ids <- extractMedicationReferenceId(references)
  unmatched_rows <- !is.na(medication_ids) &
    nzchar(medication_ids) &
    !medication_ids %in% names(medication_code_map)
  if (!any(unmatched_rows)) {
    return(emptyMedicationReferenceReport())
  }

  report <- data.table::data.table(
    TABLE_NAME = table_name,
    REFERENCE_COLUMN = reference_column,
    REFERENCE_VALUE = references[unmatched_rows],
    MEDICATION_ID = medication_ids[unmatched_rows]
  )
  report <- data.table::as.data.table(stats::aggregate(
    x = list(N = rep(1L, nrow(report))),
    by = as.data.frame(report)[
      ,
      c("TABLE_NAME", "REFERENCE_COLUMN", "REFERENCE_VALUE", "MEDICATION_ID"),
      drop = FALSE
    ],
    FUN = sum
  ))
  data.table::setorder(report, TABLE_NAME, REFERENCE_COLUMN, MEDICATION_ID, REFERENCE_VALUE)
  report[]
}

#' Enrich Snapshot Medication Reference Tables with Medication Codes
#'
#' Adds snapshot-specific medication code columns to resources that reference
#' `Medication`. Rows are repeated when the referenced medication has multiple
#' distinct `(system, code)` pairs.
#'
#' @param tables Named list of snapshot source tables.
#'
#' @return The table list with enriched medication-reference tables.
#' @export
enrichSnapshotMedicationReferenceTables <- function(tables) {
  for (i in seq_len(nrow(SNAPSHOT_MEDICATION_REFERENCE_SPECS))) {
    spec <- SNAPSHOT_MEDICATION_REFERENCE_SPECS[i, ]
    for (suffix in c("", "_last_version")) {
      table_name <- paste0(spec[["table_name"]], suffix)
      medication_table_name <- paste0("medication", suffix)
      if (is.null(tables[[table_name]]) || is.null(tables[[medication_table_name]])) {
        next
      }

      medication_code_map <- getMedicationCodeMap(tables[[medication_table_name]])
      tables[[table_name]] <- enrichMedicationReferenceTable(
        tables[[table_name]],
        medication_code_map,
        reference_column = spec[["reference_column"]],
        system_column = spec[["system_column"]],
        code_column = spec[["code_column"]]
      )
    }
  }

  tables
}

#' Review Medication References Used by Snapshot Enrichment
#'
#' Reports medication references for which the snapshot enrichment cannot find
#' a referenced `Medication` code/system pair. This is diagnostic only and does
#' not block pseudonymized snapshot creation.
#'
#' @param tables Named list of snapshot source tables.
#'
#' @return A data.table with unmatched medication references.
#' @export
getSnapshotMedicationReferenceReview <- function(tables) {
  report <- emptyMedicationReferenceReport()
  for (i in seq_len(nrow(SNAPSHOT_MEDICATION_REFERENCE_SPECS))) {
    spec <- SNAPSHOT_MEDICATION_REFERENCE_SPECS[i, ]
    for (suffix in c("", "_last_version")) {
      table_name <- paste0(spec[["table_name"]], suffix)
      medication_table_name <- paste0("medication", suffix)
      if (is.null(tables[[table_name]]) || is.null(tables[[medication_table_name]])) {
        next
      }

      medication_code_map <- getMedicationCodeMap(tables[[medication_table_name]])
      report <- data.table::rbindlist(list(
        report,
        getUnmatchedMedicationReferencesForTable(
          tables[[table_name]],
          medication_code_map,
          table_name = table_name,
          reference_column = spec[["reference_column"]]
        )
      ))
    }
  }

  report[]
}
