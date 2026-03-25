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

#'
#' Validate configuration parameters for the data import process
#'
validateConfig <- function() {
  # Get the list of pattern vectors
  encounter_filter_patterns <- etlutils::getGlobalVariablesByPrefix("ENCOUNTER_FILTER_PATTERN")

  ###
  # Check the correct structure of encounter filter patterns
  ###
  validateEncounterFilterPatterns(encounter_filter_patterns)

  if (exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS") && length(FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS) > 1) {
    stop("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS must be defined as single string.")
  }

  has_addition_parameters_with_date <- exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS") && grepl("&date=", FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS, fixed = TRUE)

  ###
  # Validate data import parameters
  ###
  if (isProcess("DataImport")) {

    ###
    # Remove all DEBUG parameters from global conext if the data export is running to prevent any side effects
    ###
    debug_parameters <- grep("^DEBUG_", ls(.GlobalEnv), value = TRUE)
    if (length(debug_parameters)) {
      etlutils::catWarningMessage("In data import all debug parameters are ignored!")
    }
    rm(list = debug_parameters, envir = .GlobalEnv)

    ###
    # Validate the date range parameters for data import
    ###
    if (!etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_START") || !etlutils::isValidTimestampString(DATA_IMPORT_RANGE_START)) {
      stop("DATA_IMPORT_RANGE_START must be valid timestamp strings in the format 'YYYY-MM-DD HH:MM:SS' for the data import.")
    }
    if (etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_END")) {
      if (!etlutils::isValidTimestampString(DATA_IMPORT_RANGE_END)) {
        stop("DATA_IMPORT_RANGE_END must be valid timestamp strings in the format 'YYYY-MM-DD HH:MM:SS'.")
      } else if (DATA_IMPORT_RANGE_START >= DATA_IMPORT_RANGE_END) { # we can use the string order here
        stop("DATA_IMPORT_RANGE_END must be greater than DATA_IMPORT_RANGE_START for the data import..")
      }
    }

    ###
    # Ensure FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS does not contain &date= if data import is running
    ###
    if (has_addition_parameters_with_date) {
      stop("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS can not contain '&date=' if data import is active.")
    }

    ###
    # Check, if the following parameters are defined and not empty but not defined, if any of the others is defined and not empty:
    ###
    params <- c(
      "DATA_IMPORT_PATH_TO_FHIR_PIDS",
      "DATA_IMPORT_PATH_TO_FHIR_ENC_IDS",
      "DATA_IMPORT_PATH_TO_FHIR_IDENTIFIERS",
      "DATA_IMPORT_FHIR_PIDS",
      "DATA_IMPORT_FHIR_ENC_IDS",
      "DATA_IMPORT_FHIR_IDENTIFIERS"
    )
    defined <- vapply(
      params,
      etlutils::isDefinedAndNotEmpty,
      logical(1)
    )
    if (sum(defined) > 1) {
      stop("The following parameters are mutually exclusive and only one may be defined with non empty values:\n    ",
           paste(params[defined], collapse = "\n    "))
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
