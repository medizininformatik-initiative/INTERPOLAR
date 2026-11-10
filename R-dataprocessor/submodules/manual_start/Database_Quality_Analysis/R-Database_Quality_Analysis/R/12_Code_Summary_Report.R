#' Create the code-report tables and their source description
#'
#' Executes one aggregate query for all configured coding sources. No individual
#' IDs or raw observations are transferred to R or exported. Global tables pool
#' rare combinations; the local_reports attribute retains all aggregate details.
createCodeSummaryReports <- function(metadata, config, query_fun = etlutils::dbGetReadOnlyQuery,
                                     table_description = NULL) {
  if (is.null(table_description)) {
    table_description <- etlutils::loadTableDescriptionFile(
      table_description_path = config$code_summary_table_description
    )
  }
  sources <- resolveCodeSummarySources(metadata, config, table_description)
  report_types <- parseCodeSummaryReportTypes(config$code_summary_report_types, names(config$code_summary_systems))
  link_resources <- vapply(config$code_summary_medication_links, `[[`, character(1), "resource")
  links <- if (any(vapply(sources, function(source) source$resource %in% c("Medication", link_resources), logical(1)))) {
    resolveCodeSummaryMedicationLinks(metadata, table_description, config)
  } else {
    list()
  }
  case_scope_query <- NULL
  scope_note <- "Filtered code export disabled: FHIR is not configured in FILTERED_SCOPE_SHEET_NAMES."
  if (isFilteredScopeSheetConfigured("FHIR", config)) {
    candidate <- getFilteredScopeMainEncounterSubquery(metadata)
    if (is.na(candidate)) {
      scope_note <- "Filtered code export skipped: required Encounter/pids_per_ward metadata unavailable."
      warning(scope_note, call. = FALSE)
    } else {
      case_scope_query <- candidate
      scope_note <- "Filtered code export enabled: main cases selected through Encounter and pids_per_ward."
    }
  }
  query <- buildCodeSummaryQuery(
    sources, links, config$code_summary_systems, config$code_summary_normal_range, report_types,
    case_scope_query = case_scope_query
  )
  rows <- if (is.na(query)) data.table::data.table() else data.table::as.data.table(query_fun(
    query,
    lock_id = getDatabaseQualityAnalysisLockId(config, "calculate code summary")
  ))
  columns <- c(
    "row_type", "system", "coding_path", "version", "code", "count", "patient_count", "case_count", "no_case_count"
  )
  measurement_columns <- c("unit", "unit_system", "median", "q1", "q3", "mean", "sd", "minimum", "maximum", "low", "high")
  source_resources <- vapply(sources, `[[`, character(1), "resource")
  report_names <- unique(ifelse(source_resources %in% link_resources, "Medication", source_resources))
  medication_columns <- c(
    "medication_count", "medication_request_count", "medication_administration_count",
    "medication_statement_count", "no_reference_count_to_medication"
  )
  if (nrow(rows) && "Medication" %in% report_names) {
    count_columns <- stats::setNames(medication_columns[2:4], c("MedicationRequest", "MedicationAdministration", "MedicationStatement"))
    available_links <- vapply(links, `[[`, character(1), "resource")
    missing_columns <- unname(count_columns[!names(count_columns) %in% available_links])
    for (column in missing_columns) rows[, (column) := NA_real_]
    if (length(missing_columns)) rows[, no_reference_count_to_medication := NA_real_]
  }
  buildReports <- function(output_target, output_scope = "all") {
    result <- lapply(report_names, function(report_name) {
      resource_sources <- Filter(function(source) source$resource == report_name, sources)
      output_columns <- c(
        columns,
        if (any(vapply(resource_sources, function(source) isTRUE(source$measurement), logical(1)))) measurement_columns,
        if (report_name == "Medication") medication_columns
      )
      if (nrow(rows)) {
        report <- rows[report_scope == output_scope & export_target == output_target & report == report_name, ..output_columns]
      } else {
        report <- data.table::as.data.table(stats::setNames(
          lapply(output_columns, function(column) {
            if (column %in% c("row_type", "system", "coding_path", "version", "code", "unit", "unit_system", "low", "high")) character() else numeric()
          }), output_columns
        ))
      }
      attr(report, "table_family") <- "Codes"
      report
    })
    names(result) <- report_names
    result
  }
  result <- buildReports("global")
  local_reports <- buildReports("local")
  source_lines <- vapply(sources, function(source) {
    paste0(
      source$resource, ": ", source$coding, " -> ", source$schema, ".", source$view, "; ",
      paste(names(source$fields), source$fields, sep = "=", collapse = ", "),
      "; measurement=", source$measurement, " (", source$measurement_mode, ")"
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
    scope_note,
    "Systems (exact URI filters):",
    vapply(names(config$code_summary_systems), function(name) {
      paste0(name, ": ", paste(config$code_summary_systems[[name]], collapse = "; "))
    }, character(1)),
    "Report types:", paste(names(report_types), report_types, sep = ": "),
    "Sources and resolved DB columns (NA: optional field unavailable):", source_lines, link_lines,
    "Skipped sources:", attr(sources, "skipped"), attr(links, "skipped"),
    "One CSV per resource type. system is the exact source URI; coding_path identifies the Coding field.",
    "count: distinct resource IDs; Medication uses Medication IDs plus direct usage IDs without a matching referenced code.",
    "Patient/case counts are deduplicated; cases use calculated main-encounter references only.",
    "no_case_count: counted resources with no valid case in any associated event of this group.",
    "total: independently deduplicated per resource/system, across all Coding paths; coding_path is empty.",
    "Global other (count < 5): pooled per resource/system/Coding path; IDs deduplicated again; no statistics exported.",
    "Local output: every coded combination is a detail row, including count < 5, with its available statistics.",
    "Detail groups: resource, system, coding_path, version, code; measurement sources also group by unit and limits.",
    "unit_system describes the measurement unit (not the coding system); it prevents ambiguous unit groups.",
    paste0(
      "Reference limits prefer referenceRange.type code=", config$code_summary_normal_range$code,
      " regardless of type system; fallback to missing type=", config$code_summary_normal_range$fallback_to_missing_type, "."
    ),
    "Selection is per observation/coding/measurement; all ranges at the preferred priority are retained.",
    "Other types do not supply reference limits. Coded observations without eligible ranges still count with empty limits.",
    "Statistics: distinct observation/value per group, numeric finite values, sample SD, continuous quartiles.",
    "Low/high limits are kept as supplied; multiple reference ranges may place an observation in several groups.",
    "Medication.csv combines Medication codes, linked usage counts and direct medicationCodeableConcept codes.",
    "Direct usage Coding paths have a resource-type prefix; linked counts use the Medication Coding path.",
    "medication_count counts actual Medication IDs; direct codes without Medication have medication_count=0.",
    "Request/Administration/Statement counts use their own IDs; patient/case counts include those direct and linked resources.",
    "The rare threshold uses count, including direct usage fallback IDs; matching direct/reference identities deduplicate in totals.",
    "Unresolved medication reference: no selected direct medicationCodeableConcept code and missing/unresolvable Medication reference.",
    "Unresolved rows occur once in Medication.csv with empty system/code/path; count is the affected usage resource count.",
    "A reference resolving to a Medication without a matching code is not an unresolved reference.",
    "Medication ingredient references are not traversed; ingredient CodeableConcept fields are configured explicitly.",
    "The additional global quality summary and clinical code categorization are outside this report."
  )
  attr(local_reports, "description") <- c(
    "LOCAL CODE SUMMARY: includes all aggregate combinations, including counts below five.",
    attr(result, "description")
  )
  attr(result, "local_reports") <- local_reports
  if (!is.null(case_scope_query)) {
    scope_label <- getFilteredScopeLabel(config)
    if (length(scope_label) != 1L || is.na(scope_label) || !nzchar(scope_label)) scope_label <- "FILTERED"
    filtered <- buildReports("global", "filtered")
    filtered_local <- buildReports("local", "filtered")
    scope_description <- c(
      paste0("Scope: ", scope_label, "; main cases selected through Encounter and pids_per_ward."),
      "Only events with a matching main-case reference contribute; other cases of the same patient are excluded.",
      "Medication codes contribute through their selected usage events; patient/case/usage counts use those events only."
    )
    description <- c(
      scope_description,
      attr(result, "description")[!startsWith(attr(result, "description"), "Scope:")]
    )
    attr(filtered, "description") <- description
    attr(filtered_local, "description") <- c(
      "LOCAL CODE SUMMARY: includes all aggregate combinations, including counts below five.", description
    )
    attr(filtered, "local_reports") <- filtered_local
    attr(filtered, "scope_label") <- scope_label
    attr(filtered, "scope_description") <- scope_description
    attr(result, "filtered_reports") <- filtered
  }
  result
}

#' Write the code summary using the shared DQA CSV/ZIP writer
writeCodeSummaryArchive <- function(code_summaries, filename_without_extension,
                                    timestamp = Sys.time(), subdir = "reports", target = c("global", "local")) {
  target <- match.arg(target)
  filtered <- attr(code_summaries, "filtered_reports", exact = TRUE)
  scope_label <- if (!is.null(filtered)) sanitizeValueSummaryFileName(attr(filtered, "scope_label", exact = TRUE))
  scope_description <- attr(filtered, "scope_description", exact = TRUE)
  if (target == "local") {
    code_summaries <- attr(code_summaries, "local_reports", exact = TRUE)
    if (is.null(code_summaries)) {
      stop("Local code details unavailable; regenerate the code summaries.", call. = FALSE)
    }
    if (!is.null(filtered)) {
      filtered <- attr(filtered, "local_reports", exact = TRUE)
      if (is.null(filtered)) stop("Local filtered code details unavailable; regenerate the code summaries.", call. = FALSE)
    }
  }
  description <- attr(code_summaries, "description")
  if (!is.null(filtered)) {
    names(filtered) <- paste0(names(filtered), "_", scope_label)
    if (any(names(filtered) %in% names(code_summaries))) {
      stop("Filtered code CSV names collide with complete-database report names.", call. = FALSE)
    }
    code_summaries <- c(code_summaries, filtered)
    description <- c(
      "CSV layout: plain resource names describe the complete database.",
      paste0("CSV names ending in _", scope_label, " describe the selected main cases."),
      description, "", "Filtered CSV scope:", scope_description
    )
  }
  writeValueSummaryArchive(
    code_summaries, filename_without_extension,
    timestamp = timestamp, subdir = subdir,
    target = target, suffix = "Code_Summary",
    description = description
  )
}
