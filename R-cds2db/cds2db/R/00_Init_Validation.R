#' Validate encounter filter pattern definitions
#'
#' This function validates encounter filter pattern definitions. It checks that
#' every subcondition has a valid formal structure, that each definition contains
#' exactly one non-empty `ward_name`, that `ward_name` is not combined with other
#' subconditions using `+`, and that all ward names are globally unique.
#'
#' @param encounter_filter_patterns A list of named lists containing encounter
#'   filter pattern definitions.
#'
#' @return Invisibly returns `TRUE` if all definitions are valid. Otherwise, the
#'   function stops with an error describing the first invalid definition found.
#'
#' @examples
#' encounter_filter_patterns <- list(
#'   list(
#'     ENCOUNTER_FILTER_PATTERN_1 = c(
#'       "ward_name = 'Station 1'",
#'       "location/location/reference = 'Location/location_id_1'"
#'     )
#'   ),
#'   list(
#'     ENCOUNTER_FILTER_PATTERN_2 = c(
#'       "ward_name = 'Station 2'",
#'       "location/location/reference = 'Location/location_id_2' + type/coding/code = 'Y'"
#'     )
#'   )
#' )
#'
#' validateEncounterFilterPatterns(encounter_filter_patterns)
#'
#' @export
validateEncounterFilterPatterns <- function(encounter_filter_patterns) {
  parsed_records <- etlutils::parseStructuredConfigDefinitions(
    definitions = encounter_filter_patterns,
    allowed_key_pattern = "ward_name|[A-Za-z/]+",
    allow_plus = TRUE
  )

  if (length(parsed_records) == 0L) {
    return(invisible(TRUE))
  }

  definition_names <- unique(vapply(parsed_records, `[[`, "", "definition_name"))
  ward_names <- character()

  for (definition_name in definition_names) {
    definition_records <- parsed_records[
      vapply(parsed_records, `[[`, "", "definition_name") == definition_name
    ]

    keys <- vapply(definition_records, `[[`, "", "key")
    ward_name_records <- definition_records[keys == "ward_name"]
    ward_name_count <- length(ward_name_records)

    if (ward_name_count != 1L) {
      stop("Definition ", definition_name, " must contain exactly one ward_name, but contains ", ward_name_count, ".", call. = FALSE)
    }

    ward_name_record <- ward_name_records[[1]]

    if (trimws(ward_name_record$value) == "") {
      stop("ward_name must not be empty in ", ward_name_record$definition_name, " / ", ward_name_record$entry_name, " / line ", ward_name_record$line_index, call. = FALSE)
    }

    if (ward_name_record$part_count_in_line > 1L) {
      stop("ward_name must not be combined with other subconditions using '+' in ", ward_name_record$definition_name, " / ", ward_name_record$entry_name, " / line ", ward_name_record$line_index, call. = FALSE)
    }

    if (ward_name_record$value %in% ward_names) {
      stop("Duplicate ward_name found: '", ward_name_record$value, "'.", call. = FALSE)
    }

    ward_names <- c(ward_names, ward_name_record$value)
  }

  invisible(TRUE)
}

#' Normalize legacy encounter filter patterns to cohort filter patterns
#'
#' Converts legacy `ward_name` marker lines to `cohort_name` while preserving all
#' other condition lines unchanged.
#'
#' @param encounter_filter_patterns A list of legacy encounter filter pattern definitions.
#'
#' @return A list of cohort-compatible filter pattern definitions.
normalizeLegacyEncounterFilterPatterns <- function(encounter_filter_patterns) {
  lapply(encounter_filter_patterns, function(definition) {
    lapply(definition, function(entry) {
      sub("^\\s*ward_name\\s*=", "cohort_name =", entry)
    })
  })
}

#' Get configured cohort filter pattern definitions
#'
#' Reads the configured filter pattern family from an environment. New
#' `COHORT_FILTER_PATTERN` definitions are preferred, while legacy
#' `ENCOUNTER_FILTER_PATTERN` definitions are accepted only if no cohort
#' definitions are present.
#'
#' @param envir Environment containing loaded module configuration values.
#'
#' @return A list with normalized `definitions`, the `source_prefix`, and a
#'   logical `legacy` flag.
getConfiguredCohortFilterPatterns <- function(envir = .GlobalEnv) {
  cohort_filter_pattern_prefix <- "COHORT_FILTER_PATTERN"
  legacy_filter_pattern_prefix <- "ENCOUNTER_FILTER_PATTERN"

  cohort_filter_patterns <- etlutils::getVariablesByPrefix(
    cohort_filter_pattern_prefix,
    envir = envir
  )
  encounter_filter_patterns <- etlutils::getVariablesByPrefix(
    legacy_filter_pattern_prefix,
    envir = envir
  )

  has_cohort_filter_patterns <- length(cohort_filter_patterns) > 0L
  has_encounter_filter_patterns <- length(encounter_filter_patterns) > 0L

  if (has_cohort_filter_patterns && has_encounter_filter_patterns) {
    stop(
      "Define either COHORT_FILTER_PATTERN or ENCOUNTER_FILTER_PATTERN, not both.",
      call. = FALSE
    )
  }

  if (has_cohort_filter_patterns) {
    return(list(
      definitions = cohort_filter_patterns,
      source_prefix = cohort_filter_pattern_prefix,
      legacy = FALSE
    ))
  }

  if (has_encounter_filter_patterns) {
    return(list(
      definitions = normalizeLegacyEncounterFilterPatterns(encounter_filter_patterns),
      source_prefix = legacy_filter_pattern_prefix,
      legacy = TRUE
    ))
  }

  stop("No cohort filter patterns found. Define COHORT_FILTER_PATTERN or legacy ENCOUNTER_FILTER_PATTERN in the toml file.", call. = FALSE)
}

#' Validate cohort filter pattern definitions
#'
#' Checks the formal structure of cohort filter definitions. Each definition must
#' contain exactly one non-empty `cohort_name`. Resource-scoped condition lines
#' can be required for new-style cohort patterns and relaxed for normalized
#' legacy encounter patterns.
#'
#' @param cohort_filter_patterns A list of cohort filter pattern definitions.
#' @param require_resource Logical. If `TRUE`, every condition line must contain
#'   exactly one `resource` subcondition.
#'
#' @return Invisibly returns `TRUE` for valid definitions.
validateCohortFilterPatterns <- function(cohort_filter_patterns, require_resource = TRUE) {
  parsed_records <- etlutils::parseStructuredConfigDefinitions(
    definitions = cohort_filter_patterns,
    allowed_key_pattern = "cohort_name|resource|[A-Za-z/]+",
    allow_plus = TRUE
  )

  if (length(parsed_records) == 0L) {
    return(invisible(TRUE))
  }

  definition_names <- unique(vapply(parsed_records, `[[`, "", "definition_name"))
  cohort_names <- character()

  for (definition_name in definition_names) {
    definition_records <- parsed_records[
      vapply(parsed_records, `[[`, "", "definition_name") == definition_name
    ]

    keys <- vapply(definition_records, `[[`, "", "key")
    cohort_name_records <- definition_records[keys == "cohort_name"]
    cohort_name_count <- length(cohort_name_records)

    if (cohort_name_count != 1L) {
      stop("Definition ", definition_name, " must contain exactly one cohort_name, but contains ", cohort_name_count, ".", call. = FALSE)
    }

    cohort_name_record <- cohort_name_records[[1]]

    if (trimws(cohort_name_record$value) == "") {
      stop("cohort_name must not be empty in ", cohort_name_record$definition_name, " / ", cohort_name_record$entry_name, " / line ", cohort_name_record$line_index, call. = FALSE)
    }

    if (cohort_name_record$part_count_in_line > 1L) {
      stop("cohort_name must not be combined with other subconditions using '+' in ", cohort_name_record$definition_name, " / ", cohort_name_record$entry_name, " / line ", cohort_name_record$line_index, call. = FALSE)
    }

    if (cohort_name_record$value %in% cohort_names) {
      stop("Duplicate cohort_name found: '", cohort_name_record$value, "'.", call. = FALSE)
    }

    cohort_names <- c(cohort_names, cohort_name_record$value)

    condition_line_ids <- unique(vapply(definition_records, function(record) {
      paste(record$entry_name, record$line_index, sep = "\r")
    }, ""))

    for (condition_line_id in condition_line_ids) {
      line_records <- definition_records[
        vapply(definition_records, function(record) {
          paste(record$entry_name, record$line_index, sep = "\r") == condition_line_id
        }, logical(1))
      ]

      line_keys <- vapply(line_records, `[[`, "", "key")
      if (identical(line_keys, "cohort_name")) {
        next
      }

      resource_count <- sum(line_keys == "resource")
      if (require_resource && resource_count != 1L) {
        stop(
          "Condition line in ",
          line_records[[1]]$definition_name,
          " / ",
          line_records[[1]]$entry_name,
          " / line ",
          line_records[[1]]$line_index,
          " must contain exactly one resource, but contains ",
          resource_count,
          ".",
          call. = FALSE
        )
      }
    }
  }

  invisible(TRUE)
}

#'
#' Validate configuration parameters for the data import process
#'
validateConfig <- function() {
  ###
  # Check the correct structure of cohort filter patterns
  ###
  configured_filter_patterns <- getConfiguredCohortFilterPatterns()
  validateCohortFilterPatterns(
    configured_filter_patterns$definitions,
    require_resource = !configured_filter_patterns$legacy
  )

  if (exists("ALLOW_PATIENTS_IN_MULTIPLE_COHORTS")) {
    if (!is.logical(ALLOW_PATIENTS_IN_MULTIPLE_COHORTS) || length(ALLOW_PATIENTS_IN_MULTIPLE_COHORTS) != 1L || is.na(ALLOW_PATIENTS_IN_MULTIPLE_COHORTS)) {
      stop("ALLOW_PATIENTS_IN_MULTIPLE_COHORTS must be defined as a single logical value.")
    }
    if (configured_filter_patterns$legacy && isTRUE(ALLOW_PATIENTS_IN_MULTIPLE_COHORTS)) {
      stop("ALLOW_PATIENTS_IN_MULTIPLE_COHORTS cannot be TRUE with legacy ENCOUNTER_FILTER_PATTERN definitions. Ward assignments are always exclusive.")
    }
  }

  if (exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS") && length(FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS) > 1) {
    stop("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS must be defined as single string.")
  }

  has_addition_parameters_with_date <- exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS") && grepl("&date=", FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS, fixed = TRUE)

  ###
  # Validate data import parameters
  ###
  if (isProcess("DataImport")) {
    ###
    # Remove all DEBUG parameters from global context if the data export is running to prevent any side effects
    # but not if the developers start an debug run via BuildAndStartDebugRun.R (then the parameter "DEBUG_VM_INDEX" is set)
    ###
    if (!etlutils::isDefinedAndNotEmpty("DEBUG_VM_INDEX")) {
      debug_parameters <- grep("^DEBUG_", ls(.GlobalEnv), value = TRUE)
      if (length(debug_parameters)) {
        etlutils::catWarningMessage("In data import all debug parameters are ignored!")
      }
      rm(list = debug_parameters, envir = .GlobalEnv)
    }

    ###
    # Validate the date range parameters for data import
    ###
    has_data_import_range_start <- etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_START")
    has_data_import_range_end <- etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_END")
    has_data_import_fhir_pids <- etlutils::isDefinedAndNotEmpty("DATA_IMPORT_FHIR_PIDS")
    has_data_import_resource_types <- etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RESOURCE_TYPES")

    if (has_data_import_range_start && !etlutils::isValidTimestampString(DATA_IMPORT_RANGE_START)) {
      stop("DATA_IMPORT_RANGE_START must be a valid timestamp string in the format 'YYYY-MM-DD HH:MM:SS'.")
    }
    if (has_data_import_range_end) {
      if (!has_data_import_range_start) {
        stop("DATA_IMPORT_RANGE_END requires DATA_IMPORT_RANGE_START.")
      }
      if (!etlutils::isValidTimestampString(DATA_IMPORT_RANGE_END)) {
        stop("DATA_IMPORT_RANGE_END must be valid timestamp strings in the format 'YYYY-MM-DD HH:MM:SS'.")
      } else if (DATA_IMPORT_RANGE_START >= DATA_IMPORT_RANGE_END) { # we can use the string order here
        stop("DATA_IMPORT_RANGE_END must be greater than DATA_IMPORT_RANGE_START for the data import..")
      }
    }

    if (etlutils::isSubProcess("DataImport.All") && !has_data_import_range_start && !has_data_import_fhir_pids) {
      stop("DataImport.All requires DATA_IMPORT_RANGE_START or DATA_IMPORT_FHIR_PIDS.")
    }

    ###
    # Ensure FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS does not contain &date= if data import is running
    ###
    if (has_addition_parameters_with_date) {
      stop("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS can not contain '&date=' if data import is active.")
    }

    if (has_data_import_resource_types && !is.character(DATA_IMPORT_RESOURCE_TYPES)) {
      stop("DATA_IMPORT_RESOURCE_TYPES must be defined as a list of resource type strings.")
    }

    if (has_data_import_fhir_pids && !is.character(DATA_IMPORT_FHIR_PIDS)) {
      stop("DATA_IMPORT_FHIR_PIDS must be defined as a list of FHIR PID strings.")
    }

    if (has_data_import_resource_types) {
      allowed_resource_types <- getDataImportAllowedResourceTypes()
      invalid_resource_types <- setdiff(tolower(DATA_IMPORT_RESOURCE_TYPES), tolower(allowed_resource_types))
      if (length(invalid_resource_types)) {
        invalid_resource_types <- DATA_IMPORT_RESOURCE_TYPES[tolower(DATA_IMPORT_RESOURCE_TYPES) %in% invalid_resource_types]
        stop(
          "DATA_IMPORT_RESOURCE_TYPES contains invalid or unsupported resource types: ",
          paste(invalid_resource_types, collapse = ", ")
        )
      }
    }

    if (has_data_import_fhir_pids && (has_data_import_range_start || has_data_import_range_end || has_data_import_resource_types)) {
      stop("DATA_IMPORT_FHIR_PIDS must be defined alone and must not be combined with DATA_IMPORT_RANGE_START, DATA_IMPORT_RANGE_END or DATA_IMPORT_RESOURCE_TYPES.")
    }

  }

  ###
  # Ensure FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS does not contain &date= if debug dates are given
  ###
  if (etlutils::isDefinedAndNotEmpty("DEBUG_ENCOUNTER_STARTS_AT_OR_BEFORE") || etlutils::isDefinedAndNotEmpty("DEBUG_ENCOUNTER_STARTS_AFTER")) {
    if (has_addition_parameters_with_date) {
      stop("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS can not contain '&date=' if degub encouter start dates are defined.")
    }
  }

}
