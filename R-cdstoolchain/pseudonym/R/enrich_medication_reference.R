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

SNAPSHOT_MEDICATION_INGREDIENT_REFERENCE_COLUMN <-
  "med_ingredient_itemreference_ref"
SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN <-
  ".snapshot_medication_reference_issues"

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
    ISSUE_TYPE = character(),
    RELATED_MEDICATION_ID = character(),
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
      "MEDICATION_ID",
      "ISSUE_TYPE",
      "RELATED_MEDICATION_ID"
    ),
    value_column = "N",
    result_column = "N"
  )
}

getUnmatchedMedicationReferencesFromEnrichedTable <- function(
  table,
  table_name,
  spec
) {
  reference_column <- spec[["reference_column"]]
  system_column <- spec[["system_column"]]
  code_column <- spec[["code_column"]]
  if (!reference_column %in% names(table) || nrow(table) == 0) {
    return(emptyMedicationReferenceReport())
  }

  references <- as.character(table[[reference_column]])
  medication_ids <- extractMedicationReferenceId(references)
  if (SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN %in% names(table)) {
    issue_values <- as.character(table[[SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN]])
    issue_rows <- which(!is.na(issue_values) & nzchar(issue_values))
    reports <- lapply(issue_rows, function(row_index) {
      issues <- strsplit(issue_values[row_index], "\n", fixed = TRUE)[[1]]
      issue_parts <- strsplit(issues, "\t", fixed = TRUE)
      data.table::data.table(
        TABLE_NAME = table_name,
        REFERENCE_COLUMN = reference_column,
        REFERENCE_VALUE = references[row_index],
        MEDICATION_ID = medication_ids[row_index],
        ISSUE_TYPE = vapply(issue_parts, `[`, character(1), 1),
        RELATED_MEDICATION_ID = vapply(issue_parts, `[`, character(1), 2),
        N = 1L
      )
    })
    if (length(reports) == 0) {
      return(emptyMedicationReferenceReport())
    }
    return(aggregateMedicationReferenceReport(data.table::rbindlist(reports)))
  }

  required_code_columns <- c(system_column, code_column)
  if (!all(required_code_columns %in% names(table))) {
    return(emptyMedicationReferenceReport())
  }
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

  aggregateMedicationReferenceReport(data.table::data.table(
    TABLE_NAME = table_name,
    REFERENCE_COLUMN = reference_column,
    REFERENCE_VALUE = references[unmatched_rows],
    MEDICATION_ID = medication_ids[unmatched_rows],
    ISSUE_TYPE = "no_reachable_code",
    RELATED_MEDICATION_ID = medication_ids[unmatched_rows],
    N = 1L
  ))
}

aggregateMedicationReferenceSummary <- function(summary) {
  sumDataTableColumnBy(
    summary,
    group_columns = c("TABLE_NAME", "REFERENCE_COLUMN", "ISSUE_TYPE"),
    value_column = "UNMATCHED_ROWS",
    result_column = "UNMATCHED_ROWS"
  )
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
    ISSUE_TYPE = character(),
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
    group_columns = c("TABLE_NAME", "REFERENCE_COLUMN", "ISSUE_TYPE"),
    value_column = "N",
    result_column = "UNMATCHED_ROWS"
  )
  context$summary <- aggregateMedicationReferenceSummary(
    data.table::rbindlist(list(context$summary, chunk_summary))
  )

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
  data.table::setorderv(
    context$summary,
    c("TABLE_NAME", "REFERENCE_COLUMN", "ISSUE_TYPE")
  )
  data.table::setorderv(
    context$examples,
    c(
      "TABLE_NAME",
      "REFERENCE_COLUMN",
      "ISSUE_TYPE",
      "MEDICATION_ID",
      "RELATED_MEDICATION_ID",
      "REFERENCE_VALUE"
    )
  )
  list(
    summary = context$summary[],
    unmatched_reference_examples = context$examples[]
  )
}
