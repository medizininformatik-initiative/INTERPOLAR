#'
#' Validate configuration parameters for the data import process
#'
validateConfig <- function() {
  # Get the list of pattern vectors
  encounter_filter_patterns <- etlutils::getGlobalVariablesByPrefix("ENCOUNTER_FILTER_PATTERN")

  ###
  # Check the correct structure of encounter filter patterns
  ###
  etlutils::validateEncounterFilterPatterns(encounter_filter_patterns)

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
