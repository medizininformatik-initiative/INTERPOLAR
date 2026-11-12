#' Create the code-report tables and their source description
#'
#' Executes one aggregate query per resource report, sharing all output scopes. No individual
#' IDs or raw observations are transferred to R or exported. Global tables pool
#' rare combinations; the local_reports attribute retains all aggregate details.
createCodeSummaryReports <- function(metadata, config, query_fun = etlutils::dbGetReadOnlyQuery,
                                     table_description = NULL) {
  started <- Sys.time()
  logProgress("Code summary: resolving configured sources and available database columns.")
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
  exports <- parseCodeSummaryExports(config$code_summary_exports)
  export_variants <- exports$variants
  case_scope_query <- NULL
  scope_note <- if (any(startsWith(export_variants, "filtered"))) {
    "Filtered code export disabled: FHIR is not configured in FILTERED_SCOPE_SHEET_NAMES."
  } else "Filtered code export disabled by exports.variants."
  if (any(startsWith(export_variants, "filtered")) && isFilteredScopeSheetConfigured("FHIR", config)) {
    candidate <- getFilteredScopeMainEncounterSubquery(metadata)
    if (is.na(candidate)) {
      scope_note <- "Filtered code export skipped: required Encounter/pids_per_ward metadata unavailable."
      warning(scope_note, call. = FALSE)
    } else {
      case_scope_query <- candidate
      scope_note <- "Filtered code export enabled: main cases selected through Encounter and pids_per_ward."
    }
  }
  if (is.null(case_scope_query)) export_variants <- export_variants[!startsWith(export_variants, "filtered")]
  case_groups_query <- NULL
  age_source <- paste0("main Encounter.", exports$age_column)
  if (any(grepl("_age_", export_variants, fixed = TRUE))) {
    candidate <- buildCodeSummaryCaseGroupsQuery(metadata, exports, !is.null(case_scope_query), table_description)
    if (is.na(candidate)) {
      warning("Age-specific code exports skipped: Encounter age/birthdate metadata unavailable (", exports$age_column, ").", call. = FALSE)
      export_variants <- export_variants[!grepl("_age_", export_variants, fixed = TRUE)]
    } else {
      case_groups_query <- candidate
      age_source <- attr(candidate, "age_source", exact = TRUE)
      logProgress("Code summary age source: ", age_source, ".")
    }
  }
  logProgress("Code summary CSV variants: ", paste(export_variants, collapse = ", "), ".")
  if (length(export_variants) && !"all" %in% export_variants) {
    logProgress("Code summary: filtering source rows by selected cases before materialization and Coding/range processing; retaining narrow global Medication identities.")
  }
  logProgress(
    "Code summary: resolved ", length(sources), " Coding sources and ", length(links),
    " medication link sources in ", formatDuration(started), ". ", scope_note
  )
  for (source in sources) {
    logProgress(
      "Code source ", source$resource, ": ", source$schema, ".", source$view,
      "; Coding=", source$coding, "; systems=", paste(source$reports, collapse = ","),
      "; measurement=", source$measurement, "."
    )
  }
  source_resources <- vapply(sources, `[[`, character(1), "resource")
  source_reports <- ifelse(source_resources %in% link_resources, "Medication", source_resources)
  report_names <- unique(source_reports)
  batching <- config$code_summary_query_batching
  if (is.null(batching)) batching <- "resource"
  if (length(batching) != 1L || is.na(batching) || !batching %in% c("resource", "all")) {
    stop("CODE_SUMMARY_QUERY_BATCHING must be 'resource' or 'all'.", call. = FALSE)
  }
  batches <- if (batching == "all" && length(sources)) {
    list(All = sources)
  } else {
    lapply(stats::setNames(report_names, report_names), function(report) sources[source_reports == report])
  }
  query_rows <- lapply(seq_along(batches), function(index) {
    batch_sources <- batches[[index]]
    # Medication and its usage sources stay together. Other resources never
    # scan medication views; each actual resource view is read by one batch.
    batch_links <- if (any(vapply(batch_sources, function(source) source$resource %in% c("Medication", link_resources), logical(1)))) links else list()
    query <- buildCodeSummaryQuery(
      batch_sources, batch_links, config$code_summary_systems, config$code_summary_normal_range, report_types,
      case_scope_query = if (is.null(case_groups_query)) case_scope_query else NULL,
      case_groups_query = case_groups_query, export_variants = export_variants
    )
    if (is.na(query)) return(data.table::data.table())
    data.table::as.data.table(runLoggedQuery(
      query,
      query_fun = query_fun, config = config,
      label = paste0(
        "Code summary SQL ", names(batches)[[index]], " (", index, "/", length(batches),
        "; global/local and configured case scopes)"
      ),
      lock_id = getDatabaseQualityAnalysisLockId(config, "calculate code summary")
    ))
  })
  rows <- data.table::rbindlist(query_rows, use.names = TRUE, fill = TRUE)
  columns <- c(
    "row_type", "system", "coding_path", "version", "code", "count", "patient_count", "case_count", "no_case_count"
  )
  measurement_columns <- c("unit", "unit_system", "median", "q1", "q3", "mean", "sd", "minimum", "maximum", "low", "high")
  medication_columns <- c(
    "medication_count", "medication_request_count", "medication_administration_count",
    "medication_statement_count", "unreferenced_medication_count"
  )
  if (nrow(rows) && "Medication" %in% report_names) {
    count_columns <- stats::setNames(medication_columns[2:4], c("MedicationRequest", "MedicationAdministration", "MedicationStatement"))
    available_links <- vapply(links, `[[`, character(1), "resource")
    missing_columns <- unname(count_columns[!names(count_columns) %in% available_links])
    for (column in missing_columns) rows[, (column) := NA_real_]
    if (length(missing_columns) || !any(source_resources == "Medication")) {
      rows[, unreferenced_medication_count := NA_real_]
    }
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
    paste0("Requested CSV variants: ", paste(exports$variants, collapse = ", ")),
    paste0("Available CSV variants: ", paste(export_variants, collapse = ", ")),
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
    "unreferenced_medication_count: actual Medication IDs without a recognized incoming reference from the configured usage resources.",
    "Reference existence is independent of usage codes and case assignment; identical codes without a reference do not link IDs.",
    "With default mappings, unreferenced Medications have no case association and occur only in complete-database CSVs.",
    "Unreferenced counts are unavailable (empty) if the Medication source or a required usage source is unavailable.",
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
  if ("filtered" %in% export_variants) {
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
  scope_label <- getFilteredScopeLabel(config)
  if (length(scope_label) != 1L || is.na(scope_label) || !nzchar(scope_label)) scope_label <- "FILTERED"
  age_variants <- export_variants[grepl("_age_", export_variants, fixed = TRUE)]
  variant_reports <- lapply(age_variants, function(variant) {
    filtered <- startsWith(variant, "filtered")
    adult <- endsWith(variant, "ge18")
    suffix <- paste0(if (filtered) paste0(scope_label, "_") else "", if (adult) "AGE_GE18" else "AGE_LT18")
    description <- c(
      paste0("Scope: ", if (filtered) paste0(scope_label, "; ") else "", "main-case age at admission ", if (adult) ">=18" else "<18", "."),
      paste0("Age source: ", age_source, "; missing, negative or invalid ages and conflicting age groups are excluded from age-specific CSVs."),
      "Only events linked to the matching main case contribute; Medication codes use their associated usage events.",
      attr(result, "description")[!startsWith(attr(result, "description"), "Scope:")]
    )
    reports <- buildReports("global", variant)
    local <- buildReports("local", variant)
    attr(reports, "description") <- description
    attr(local, "description") <- c("LOCAL CODE SUMMARY: includes all aggregate combinations, including counts below five.", description)
    attr(reports, "local_reports") <- local
    attr(reports, "scope_label") <- suffix
    attr(reports, "scope_description") <- description[1:3]
    reports
  })
  names(variant_reports) <- age_variants
  attr(result, "variant_reports") <- variant_reports
  attr(result, "export_variants") <- export_variants
  scoped_reports <- c(
    if ("all" %in% export_variants) list(all = result),
    if ("filtered" %in% export_variants) list(filtered = attr(result, "filtered_reports", exact = TRUE)),
    variant_reports
  )
  for (scope in names(scoped_reports)) {
    scoped <- scoped_reports[[scope]]
    for (resource in report_names) {
      logProgress(
        "Code summary ", resource, " [", scope, "]: ", nrow(scoped[[resource]]), " global rows, ",
        nrow(attr(scoped, "local_reports", exact = TRUE)[[resource]]), " local rows."
      )
    }
  }
  logProgress("Code summary: finished in ", formatDuration(started), ".")
  result
}

#' Write the code summary using the shared DQA CSV/ZIP writer
writeCodeSummaryArchive <- function(code_summaries, filename_without_extension,
                                    timestamp = Sys.time(), subdir = "reports", target = c("global", "local")) {
  target <- match.arg(target)
  export_variants <- attr(code_summaries, "export_variants", exact = TRUE)
  filtered <- attr(code_summaries, "filtered_reports", exact = TRUE)
  variants <- attr(code_summaries, "variant_reports", exact = TRUE)
  if (!is.null(filtered)) variants <- c(list(filtered = filtered), variants)
  base <- if (target == "local") attr(code_summaries, "local_reports", exact = TRUE) else code_summaries
  if (is.null(base)) stop("Local code details unavailable; regenerate the code summaries.", call. = FALSE)
  description <- attr(base, "description")
  if (!is.null(export_variants) && !"all" %in% export_variants) {
    description <- description[!startsWith(description, "Scope:")]
  }
  reports <- if (is.null(export_variants) || "all" %in% export_variants) base else list()
  for (variant in variants) {
    scope_label <- sanitizeValueSummaryFileName(attr(variant, "scope_label", exact = TRUE))
    scope_description <- attr(variant, "scope_description", exact = TRUE)
    tables <- if (target == "local") attr(variant, "local_reports", exact = TRUE) else variant
    if (is.null(tables)) stop("Local scoped code details unavailable; regenerate the code summaries.", call. = FALSE)
    names(tables) <- paste0(names(tables), "_", scope_label)
    if (any(names(tables) %in% names(reports))) {
      stop("Scoped code CSV names collide with other report names.", call. = FALSE)
    }
    reports <- c(reports, tables)
    description <- c(description, "", paste0("CSV suffix _", scope_label, ":"), scope_description)
  }
  code_summaries <- reports
  writeValueSummaryArchive(
    code_summaries, filename_without_extension,
    timestamp = timestamp, subdir = subdir,
    target = target, suffix = "Code_Summary",
    description = description
  )
}
