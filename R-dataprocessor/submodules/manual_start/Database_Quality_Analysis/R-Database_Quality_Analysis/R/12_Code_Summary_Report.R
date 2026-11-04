#' Create the code-report tables and their source description
#'
#' Executes one aggregate query for all configured coding sources. No individual
#' IDs or raw observations are transferred to R or exported.
createCodeSummaryReports <- function(metadata, config, query_fun = etlutils::dbGetReadOnlyQuery,
                                     table_description = NULL) {
  if (is.null(table_description)) {
    table_description <- etlutils::loadTableDescriptionFile(
      table_description_path = config$code_summary_table_description
    )
  }
  sources <- resolveCodeSummarySources(metadata, config, table_description)
  links <- if (any(vapply(sources, function(source) source$resource == "Medication", logical(1)))) {
    resolveCodeSummaryMedicationLinks(metadata, table_description, config)
  } else {
    list()
  }
  query <- buildCodeSummaryQuery(sources, links, config$code_summary_systems, config$code_summary_normal_range)
  rows <- if (is.na(query)) data.table::data.table() else data.table::as.data.table(query_fun(
    query,
    lock_id = getDatabaseQualityAnalysisLockId(config, "calculate code summary")
  ))
  if (nrow(rows)) {
    link_counts <- c(
      MedicationRequest = "medication_request_count",
      MedicationAdministration = "medication_administration_count",
      MedicationStatement = "medication_statement_count"
    )
    available_links <- vapply(links, function(source) source$resource, character(1))
    missing_link_columns <- unname(link_counts[!names(link_counts) %in% available_links])
    for (column in missing_link_columns) rows[, (column) := NA_real_]
    if (length(missing_link_columns)) rows[, no_reference_count_to_medication := NA_real_]
  }
  columns <- c(
    "row_type", "version", "code", "count", "patient_count", "case_count", "no_case_count"
  )
  medication_columns <- c(
    "medication_count", "medication_request_count", "medication_administration_count",
    "medication_statement_count", "no_reference_count_to_medication"
  )
  loinc_columns <- c("unit", "unit_system", "median", "q1", "q3", "mean", "sd", "minimum", "maximum", "low", "high")
  result <- lapply(names(config$code_summary_systems), function(report_name) {
    output_columns <- c(
      columns,
      if (report_name == "LOINC") loinc_columns,
      if (report_name %in% c("ATC", "PZN", "ASK")) medication_columns
    )
    if (nrow(rows)) {
      report <- rows[report == report_name, ..output_columns]
    } else {
      report <- data.table::as.data.table(stats::setNames(
        lapply(output_columns, function(column) {
          if (column %in% c("row_type", "version", "code", "unit", "unit_system", "low", "high")) character() else numeric()
        }), output_columns
      ))
    }
    attr(report, "table_family") <- "Codes"
    report
  })
  names(result) <- names(config$code_summary_systems)
  source_lines <- vapply(sources, function(source) {
    paste0(
      source$resource, ": ", source$coding, " -> ", source$schema, ".", source$view, "; ",
      paste(names(source$fields), source$fields, sep = "=", collapse = ", ")
    )
  }, character(1))
  link_lines <- vapply(links, function(source) {
    paste0(
      source$resource, ": direct Medication reference -> ", source$schema, ".", source$view, "; ",
      paste(names(source$fields), source$fields, sep = "=", collapse = ", ")
    )
  }, character(1))
  attr(result, "description") <- c(
    "Database Quality Analysis: Code Summary",
    paste0("Configuration: ", config$code_summary_config_file),
    "Scope: configured FHIR last-version views, unfiltered; no additional date/status filter.",
    "Systems (exact URI filters):",
    vapply(names(config$code_summary_systems), function(name) {
      paste0(name, ": ", paste(config$code_summary_systems[[name]], collapse = "; "))
    }, character(1)),
    "Sources and resolved DB columns (NA: optional field unavailable):", source_lines, link_lines,
    "Skipped sources:", attr(sources, "skipped"), attr(links, "skipped"),
    "Counts for unavailable medication link sources are empty, not zero; reference-issue totals require all link sources.",
    "count: distinct resource type/ID; for ATC/PZN/ASK: distinct Medication IDs.",
    "Patient/case counts are deduplicated; cases use calculated main-encounter references only.",
    "no_case_count: counted resources with no valid case in any associated event of this group.",
    "total: independently deduplicated code-report total; do not sum per-code counts.",
    "other (count < 5): rare combinations pooled; IDs deduplicated again; no values/statistics exported.",
    "LOINC groups: version, code, unit code, unit system, normal reference limits.",
    "unit_system describes the measurement unit (not the LOINC coding system); it prevents ambiguous unit groups.",
    paste0(
      "Reference limits prefer referenceRange.type code=", config$code_summary_normal_range$code,
      " regardless of type system; fallback to missing type=", config$code_summary_normal_range$fallback_to_missing_type, "."
    ),
    "Selection is per observation/coding/measurement; all ranges at the preferred priority are retained.",
    "Other types do not supply reference limits. Coded observations without eligible ranges still count with empty limits.",
    "Statistics: distinct observation/value per group, numeric finite values, sample SD, continuous quartiles.",
    "Low/high limits are kept as supplied; multiple reference ranges may place an observation in several groups.",
    "Unresolved medication reference: missing or unresolvable direct Medication reference, no code assigned.",
    "These rows have empty count; reference-issue totals repeat in ATC/PZN/ASK and must not be added.",
    "In unresolved rows no_case_count refers to the unlinked Request/Administration/Statement IDs.",
    "A reference resolving to a Medication without a matching code is not an unresolved reference.",
    "Medication ingredient references are not traversed; ingredient CodeableConcept fields are configured explicitly.",
    "The additional global quality summary and clinical code categorization are outside this report."
  )
  result
}

#' Write the code summary using the shared DQA CSV/ZIP writer
writeCodeSummaryArchive <- function(code_summaries, filename_without_extension,
                                    timestamp = Sys.time(), subdir = "reports", target = c("global", "local")) {
  writeValueSummaryArchive(
    code_summaries, filename_without_extension,
    timestamp = timestamp, subdir = subdir,
    target = match.arg(target), suffix = "Code_Summary",
    description = attr(code_summaries, "description")
  )
}
