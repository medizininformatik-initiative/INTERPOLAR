#' Locate the code-report TOML in the DQA module directory
#'
#' Normal module starts run from the repository root. Package development/tests
#' can also locate the same file next to the package source directory.
getCodeSummaryConfigPath <- function() {
  module_file <- file.path(
    "R-dataprocessor", "submodules", "manual_start", "Database_Quality_Analysis", "code_summary.toml"
  )
  if (file.exists(module_file)) return(normalizePath(module_file))
  package_namespace <- topenv(environment())
  if (isNamespace(package_namespace)) {
    package_path <- getNamespaceInfo(package_namespace, "path")
    source_file <- file.path(dirname(package_path), "code_summary.toml")
    if (file.exists(source_file)) return(normalizePath(source_file))
  }
  module_file
}

#' Load code systems, source fields and reference rules from TOML
#'
#' Uses the shared parser without flattening nested field/source tables.
loadCodeSummaryConfig <- function(path) {
  if (length(path) != 1L || is.na(path) || !nzchar(path) || !file.exists(path)) {
    stop("Code summary TOML file not found: ", path, call. = FALSE)
  }
  config <- etlutils::tomlParseString(paste(readLines(path, warn = FALSE), collapse = "\n"))
  required <- c("systems", "report_types", "sources", "fields", "medication_links", "normal_range")
  missing <- setdiff(required, names(config))
  if (length(missing)) {
    stop("Missing code summary TOML sections: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  config$exports <- parseCodeSummaryExports(config$exports)
  config$processing <- parseCodeSummaryProcessing(config$processing)
  config$report_types <- parseCodeSummaryReportTypes(config$report_types, names(config$systems))
  required_fields <- c(
    "resource_id", "system", "version", "code", "pid", "case_id", "value",
    "unit", "unit_system", "low", "high", "range_type"
  )
  if (
    !all(required_fields %in% names(config$fields)) ||
    !all(c("code", "fallback_to_missing_type") %in% names(config$normal_range))
  ) {
    stop("Incomplete code summary field paths or normal-range rule in TOML.", call. = FALSE)
  }
  if (
    !is.logical(config$normal_range$fallback_to_missing_type) ||
    length(config$normal_range$fallback_to_missing_type) != 1L ||
    is.na(config$normal_range$fallback_to_missing_type)
  ) {
    stop("normal_range.fallback_to_missing_type must be a TOML boolean.", call. = FALSE)
  }
  config
}

#' Validate code-group execution limits without changing report semantics
parseCodeSummaryProcessing <- function(processing = NULL) {
  defaults <- list(enabled = TRUE, target_rows_per_chunk = 500000, max_codes_per_chunk = 500L)
  if (is.null(processing)) return(defaults)
  if (
    !is.list(processing) || (length(processing) && is.null(names(processing))) || anyDuplicated(names(processing)) ||
    length(setdiff(names(processing), names(defaults)))
  ) {
    stop("Unknown code summary processing setting.", call. = FALSE)
  }
  processing <- utils::modifyList(defaults, processing)
  if (!is.logical(processing$enabled) || length(processing$enabled) != 1L || is.na(processing$enabled)) {
    stop("processing.enabled must be a TOML boolean.", call. = FALSE)
  }
  for (name in c("target_rows_per_chunk", "max_codes_per_chunk")) {
    processing[[name]] <- validatePositiveIntegerConfig(processing[[name]], paste0("processing.", name))
  }
  processing
}

#' Validate the requested CSV variants and the main-encounter age column
#'
#' Older TOMLs without an exports section retain the two original variants.
parseCodeSummaryExports <- function(exports = NULL) {
  defaults <- list(variants = c("all", "filtered"), age_column = "enc_age_at_admission", fallback_to_birthdate = TRUE)
  if (is.null(exports)) return(defaults)
  if (!is.list(exports) || length(setdiff(names(exports), names(defaults)))) {
    stop("Unknown code summary exports setting.", call. = FALSE)
  }
  exports <- utils::modifyList(defaults, exports)
  allowed <- c("all", "all_age_ge18", "all_age_lt18", "filtered", "filtered_age_ge18", "filtered_age_lt18")
  variants <- exports$variants
  if (
    !is.character(variants) || !length(variants) || anyNA(variants) ||
    anyDuplicated(variants) || !all(variants %in% allowed)
  ) {
    stop("exports.variants must contain unique CSV variants from: ", paste(allowed, collapse = ", "), call. = FALSE)
  }
  if (
    !is.character(exports$age_column) || length(exports$age_column) != 1L ||
    is.na(exports$age_column) || !nzchar(trimws(exports$age_column))
  ) {
    stop("exports.age_column must be a non-empty database column name.", call. = FALSE)
  }
  if (
    !is.logical(exports$fallback_to_birthdate) || length(exports$fallback_to_birthdate) != 1L ||
    is.na(exports$fallback_to_birthdate)
  ) {
    stop("exports.fallback_to_birthdate must be a TOML boolean.", call. = FALSE)
  }
  exports
}

#' Validate and normalize configured report types
#'
#' Used for TOML input and programmatically supplied report configurations.
#' The legacy measurement label is accepted; sources detect numeric values
#' independently of their report type unless explicitly overridden.
parseCodeSummaryReportTypes <- function(report_types, report_names) {
  if (
    is.null(names(report_types)) || anyDuplicated(names(report_types)) ||
    !setequal(names(report_types), report_names) ||
    any(lengths(report_types) != 1L)
  ) {
    stop("report_types must define exactly one type for every configured report.", call. = FALSE)
  }
  types <- unlist(report_types, use.names = TRUE)
  if (
    !is.character(types) || anyNA(types) ||
    !all(types %in% c("coding", "measurement", "medication"))
  ) {
    stop("Report types must be coding, measurement or medication.", call. = FALSE)
  }
  types[report_names]
}

#' Resolve one FHIR path to an available database column
resolveCodeSummaryPath <- function(resource_description, table_metadata, path) {
  columns <- intersect(
    unique(resource_description[FHIR_EXPRESSION == path, COLUMN_NAME]),
    table_metadata$COLUMN_NAME
  )
  if (length(columns) > 1L) {
    stop("Ambiguous Table Description path: ", path, call. = FALSE)
  }
  if (length(columns)) columns[[1]] else NA_character_
}

#' Resolve configured FHIR fields and explicit DB-column overrides for one source
resolveCodeSummaryFields <- function(source, resource_description, table_metadata, paths,
                                     exclude_fields = character()) {
  paths <- utils::modifyList(paths, if (is.null(source$fields)) list() else source$fields)
  if (!all(names(source$columns) %in% names(paths))) {
    stop("Unknown code source column override for ", source$resource, call. = FALSE)
  }
  field_names <- setdiff(names(paths), exclude_fields)
  fields <- stats::setNames(vapply(field_names, function(name) {
    if (name %in% names(source$columns)) return(as.character(source$columns[[name]]))
    candidates <- paths[[name]]
    if (!is.null(source$coding)) candidates <- gsub("{coding}", source$coding, candidates, fixed = TRUE)
    for (path in candidates) {
      column <- resolveCodeSummaryPath(resource_description, table_metadata, path)
      if (!is.na(column)) return(column)
    }
    NA_character_
  }, character(1)), field_names)
  # Calculated main-encounter columns take precedence over path candidates.
  main_column <- paste0(sub("_id$", "", fields[["resource_id"]]), "_main_encounter_calculated_ref")
  if (main_column %in% table_metadata$COLUMN_NAME && !"case_id" %in% names(source$columns)) {
    fields[["case_id"]] <- main_column
  }
  overrides <- unlist(source$columns, use.names = FALSE)
  missing_columns <- setdiff(overrides[!is.na(overrides)], table_metadata$COLUMN_NAME)
  if (length(missing_columns)) {
    stop("Code source override columns unavailable: ", paste(missing_columns, collapse = ", "), call. = FALSE)
  }
  fields
}

#' Expand configured wildcard Coding sources from the maintained Table Description
#'
#' Only imported FHIR resources and Coding paths with system/code mappings qualify.
#' Explicit sources take precedence for the same resource/path/system family.
expandCodeSummarySources <- function(sources, table_description) {
  explicit_sources <- Filter(function(source) source$resource != "*" && source$coding != "*", sources)
  result <- explicit_sources
  coding_paths <- unique(table_description[
    grepl("^[A-Z]", RESOURCE) & grepl("/system$", FHIR_EXPRESSION),
    .(RESOURCE, coding = sub("/system$", "", FHIR_EXPRESSION))
  ])
  # Direct Coding elements such as Encounter.class have no /coding suffix.
  # Their code plus version/display mappings distinguish them from Quantities.
  coding_paths <- coding_paths[vapply(seq_len(nrow(coding_paths)), function(index) {
    paths <- table_description[RESOURCE == coding_paths$RESOURCE[[index]], FHIR_EXPRESSION]
    path <- coding_paths$coding[[index]]
    paste0(path, "/code") %in% paths && (endsWith(path, "/coding") ||
      any(paste0(path, c("/version", "/display")) %in% paths))
  }, logical(1))]
  for (source in sources) {
    if (source$resource != "*" && source$coding != "*") next
    candidates <- coding_paths[
      (source$resource == "*" | RESOURCE == source$resource) &
        (source$coding == "*" | coding == source$coding)
    ]
    for (index in seq_len(nrow(candidates))) {
      expanded <- source
      expanded$resource <- candidates$RESOURCE[[index]]
      expanded$coding <- candidates$coding[[index]]
      configured <- Filter(function(other) {
        other$resource == expanded$resource && other$coding == expanded$coding
      }, result)
      expanded$reports <- setdiff(expanded$reports, unlist(lapply(configured, `[[`, "reports")))
      if (length(expanded$reports)) result[[length(result) + 1L]] <- expanded
    }
  }
  result
}

#' Resolve code-report source fields against the maintained Table Description
#'
#' Reuses the shared loader and fill-down helper. Missing optional fields are
#' represented as NULL in SQL; absent required fields skip that source with a
#' warning and are recorded in the archive description. Measurement statistics
#' default to an available mapped numeric value field, with optional overrides.
resolveCodeSummarySources <- function(metadata, config, table_description = NULL) {
  if (is.null(table_description)) {
    table_description <- etlutils::loadTableDescriptionFile(
      table_description_path = config$code_summary_table_description
    )
  }
  table_description <- data.table::copy(table_description)
  etlutils::fillNAWithLastRowValue(table_description, "RESOURCE")
  sources <- expandCodeSummarySources(config$code_summary_sources, table_description)
  systems <- config$code_summary_systems
  report_types <- parseCodeSummaryReportTypes(config$code_summary_report_types, names(systems))
  if (is.null(sources) || is.null(systems) || !length(systems)) {
    stop("Code summary requires sources and code systems.", call. = FALSE)
  }
  if (
    is.null(names(systems)) || any(!nzchar(names(systems))) || anyDuplicated(names(systems)) ||
    any(vapply(systems, function(values) !length(values) || anyNA(values) || any(!nzchar(values)), logical(1)))
  ) {
    stop("Code summary systems require unique report names and non-empty URIs.", call. = FALSE)
  }
  all_systems <- unlist(systems, use.names = FALSE)
  if (anyDuplicated(all_systems)) {
    stop("A code system URI must belong to exactly one report.", call. = FALSE)
  }
  result <- list()
  skipped <- character()
  for (source in sources) {
    if (
      length(source$resource) != 1L || is.na(source$resource) || !nzchar(source$resource) ||
      length(source$coding) != 1L || is.na(source$coding) || !nzchar(source$coding) ||
      !length(source$reports) || anyNA(source$reports)
    ) {
      stop("Each code source requires resource, coding path and report names.", call. = FALSE)
    }
    if (!all(source$reports %in% names(systems))) {
      stop("Unknown code report in source configuration: ", source$resource, call. = FALSE)
    }
    resource_name <- source$resource
    medication_resources <- c("Medication", vapply(config$code_summary_medication_links, `[[`, character(1), "resource"))
    if (any(report_types[source$reports] == "medication") && !resource_name %in% medication_resources) {
      stop("Medication reports require a Medication source or configured medication link: ", resource_name, call. = FALSE)
    }
    table_metadata <- metadata[TABLE_FAMILY == "FHIR" & TABLE_NAME == tolower(resource_name)]
    if (!nrow(table_metadata)) {
      skipped <- c(skipped, paste(resource_name, source$coding, "view unavailable"))
      next
    }
    resource_description <- table_description[RESOURCE == resource_name]
    measurement_override <- source[["measurement"]]
    if (
      !is.null(measurement_override) && (!is.logical(measurement_override) ||
          length(measurement_override) != 1L || is.na(measurement_override))
    ) {
      stop("Source measurement must be a TOML boolean.", call. = FALSE)
    }
    measurement_fields <- c("value", "unit", "unit_system", "low", "high", "range_type")
    paths <- config$code_summary_fields
    # Resolve the mapped value first. Unrelated or ambiguous optional unit/range
    # paths must not prevent an ordinary coding source from being counted.
    fields <- resolveCodeSummaryFields(
      source, resource_description, table_metadata, paths,
      exclude_fields = if (isFALSE(measurement_override)) measurement_fields else setdiff(measurement_fields, "value")
    )
    source$measurement_mode <- if (is.null(measurement_override)) "auto" else "explicit"
    if (is.null(measurement_override)) {
      value_column <- fields[["value"]]
      value_types <- if (length(value_column) == 1L && !is.na(value_column) && "DATA_TYPE" %in% names(table_metadata)) {
        unique(table_metadata[COLUMN_NAME == value_column, DATA_TYPE])
      } else character()
      source$measurement <- length(value_types) == 1L && !is.na(value_types) &&
        getValueSummaryType(value_types[[1]]) == "numeric"
    }
    if (source$measurement) {
      fields <- resolveCodeSummaryFields(source, resource_description, table_metadata, paths)
    }
    if (!source$measurement) fields[measurement_fields] <- NA_character_
    if (anyNA(fields[c("resource_id", "system", "code")])) {
      skipped <- c(skipped, paste(resource_name, source$coding, "required columns unavailable"))
      next
    }
    source$fields <- fields
    source$schema <- table_metadata$VIEW_SCHEMA[[1]]
    source$view <- table_metadata$VIEW_NAME[[1]]
    result[[length(result) + 1L]] <- source
  }
  if (length(skipped)) {
    warning("Skipped code summary sources: ", paste(skipped, collapse = "; "), call. = FALSE)
  }
  attr(result, "skipped") <- skipped
  result
}

#' Resolve medication reference sources using the same Table Description
resolveCodeSummaryMedicationLinks <- function(metadata, table_description, config) {
  table_description <- data.table::copy(table_description)
  etlutils::fillNAWithLastRowValue(table_description, "RESOURCE")
  result <- list()
  skipped <- character()
  for (source in config$code_summary_medication_links) {
    resource_name <- source$resource
    table_metadata <- metadata[TABLE_FAMILY == "FHIR" & TABLE_NAME == tolower(resource_name)]
    if (!nrow(table_metadata)) {
      skipped <- c(skipped, paste(resource_name, "view unavailable"))
      next
    }
    resource_description <- table_description[RESOURCE == resource_name]
    paths <- config$code_summary_fields[c("resource_id", "pid", "case_id")]
    fields <- resolveCodeSummaryFields(source, resource_description, table_metadata, paths)
    if (anyNA(fields[c("resource_id", "medication_ref")])) {
      skipped <- c(skipped, paste(resource_name, "required fields unavailable"))
      next
    }
    result[[length(result) + 1L]] <- list(
      resource = resource_name, fields = fields,
      schema = table_metadata$VIEW_SCHEMA[[1]], view = table_metadata$VIEW_NAME[[1]]
    )
  }
  if (length(skipped)) {
    warning("Skipped medication link sources: ", paste(skipped, collapse = "; "), call. = FALSE)
  }
  attr(result, "skipped") <- skipped
  result
}
