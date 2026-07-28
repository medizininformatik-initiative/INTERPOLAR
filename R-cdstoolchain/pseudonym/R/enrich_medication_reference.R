SNAPSHOT_MEDICATION_REFERENCE_SPECS <- data.table::data.table(
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
  )
)

extractMedicationReferenceId <- function(references) {
  references <- as.character(references)
  references[is.na(references) | !nzchar(references)] <- NA_character_
  references <- sub("^\\[[^]]+\\]", "", references)
  references <- sub("^Medication/", "", references)
  references
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

getMedicationReferenceSpec <- function(table_name) {
  matches <- SNAPSHOT_MEDICATION_REFERENCE_SPECS[
    SNAPSHOT_MEDICATION_REFERENCE_SPECS[["table_name"]] == table_name,
  ]
  if (nrow(matches) == 0) {
    return(NULL)
  }
  matches[1L, ]
}

sumDataTableColumnBy <- function(table, group_columns, value_column, result_column) {
  table <- data.table::copy(data.table::as.data.table(table))
  data.table::setorderv(table, group_columns)
  group_ids <- data.table::rleidv(table, group_columns)
  first_group_rows <- !duplicated(group_ids)
  result <- data.table::as.data.table(stats::setNames(
    lapply(group_columns, function(column) table[[column]][first_group_rows]),
    group_columns
  ))
  group_sums <- as.numeric(rowsum(
    as.numeric(table[[value_column]]),
    group_ids,
    reorder = FALSE
  ))
  data.table::set(result, j = result_column, value = group_sums)
  result
}

aggregateMedicationReferenceReport <- function(report) {
  sumDataTableColumnBy(
    report,
    group_columns = c(
      "TABLE_NAME",
      "REFERENCE_COLUMN",
      "REFERENCE_VALUE",
      "MEDICATION_ID"
    ),
    value_column = "N",
    result_column = "N"
  )
}

getUnmatchedMedicationReferencesFromEnrichedTable <- function(table, table_name, spec) {
  reference_column <- spec[["reference_column"]]
  system_column <- spec[["system_column"]]
  code_column <- spec[["code_column"]]
  required_columns <- c(reference_column, system_column, code_column)
  if (!all(required_columns %in% names(table)) || nrow(table) == 0) {
    return(emptyMedicationReferenceReport())
  }

  references <- as.character(table[[reference_column]])
  medication_ids <- extractMedicationReferenceId(references)
  unmatched_rows <- !is.na(medication_ids) &
    nzchar(medication_ids) &
    (
      is.na(table[[system_column]]) |
        !nzchar(as.character(table[[system_column]])) |
        is.na(table[[code_column]]) |
        !nzchar(as.character(table[[code_column]]))
    )
  if (!any(unmatched_rows)) {
    return(emptyMedicationReferenceReport())
  }

  report <- data.table::data.table(
    TABLE_NAME = table_name,
    REFERENCE_COLUMN = reference_column,
    REFERENCE_VALUE = references[unmatched_rows],
    MEDICATION_ID = medication_ids[unmatched_rows],
    N = 1L
  )
  aggregateMedicationReferenceReport(report)
}

newBoundedMedicationReferenceReview <- function(detail_limit = 1000L) {
  detail_limit <- suppressWarnings(as.integer(detail_limit))
  if (length(detail_limit) != 1 || is.na(detail_limit) || detail_limit < 1) {
    stop("detail_limit must be a positive integer.")
  }
  context <- new.env(parent = emptyenv())
  context$detail_limit <- detail_limit
  context$summary <- data.table::data.table(
    TABLE_NAME = character(),
    REFERENCE_COLUMN = character(),
    UNMATCHED_ROWS = numeric()
  )
  context$examples <- emptyMedicationReferenceReport()
  context
}

recordBoundedMedicationReferenceReview <- function(context, report) {
  if (nrow(report) == 0) {
    return(invisible())
  }

  chunk_summary <- sumDataTableColumnBy(
    report,
    group_columns = c("TABLE_NAME", "REFERENCE_COLUMN"),
    value_column = "N",
    result_column = "UNMATCHED_ROWS"
  )
  for (i in seq_len(nrow(chunk_summary))) {
    matching_row <- context$summary[["TABLE_NAME"]] == chunk_summary[["TABLE_NAME"]][i] &
      context$summary[["REFERENCE_COLUMN"]] == chunk_summary[["REFERENCE_COLUMN"]][i]
    if (any(matching_row)) {
      context$summary[["UNMATCHED_ROWS"]][matching_row] <-
        context$summary[["UNMATCHED_ROWS"]][matching_row] +
        chunk_summary[["UNMATCHED_ROWS"]][i]
    } else {
      context$summary <- data.table::rbindlist(list(
        context$summary,
        chunk_summary[i, ]
      ))
    }
  }

  remaining_examples <- context$detail_limit - nrow(context$examples)
  if (remaining_examples > 0) {
    context$examples <- data.table::rbindlist(list(
      context$examples,
      utils::head(report, remaining_examples)
    ))
  }
  invisible()
}

finalizeBoundedMedicationReferenceReview <- function(context) {
  data.table::setorderv(context$summary, c("TABLE_NAME", "REFERENCE_COLUMN"))
  list(
    summary = context$summary[],
    unmatched_reference_examples = context$examples[]
  )
}
