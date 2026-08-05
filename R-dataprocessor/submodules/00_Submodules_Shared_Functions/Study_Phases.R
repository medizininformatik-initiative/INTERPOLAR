.dataprocessor_shared_functions_env <- new.env()

#
# Extract the value for a given key from a character vector of lines. The key-value pairs are expected to be in the format "key = 'value'". Returns NA if the key is not found.
#
extractSingleEntryLinesValue <- function(entry_lines, key) {
  pattern <- paste0("^\\s*", key, "\\s*=\\s*'([^']*)'\\s*$")
  for (line in entry_lines) {
    m <- regexec(pattern, line, perl = TRUE)
    reg <- regmatches(line, m)[[1]]
    if (length(reg) == 2L) return(reg[2])
  }
  NA_character_
}

#
# Return the phase definition for a ward, or NULL if the ward is not configured.
#
getWardPhaseDefinition <- function(ward_name) {
  ward_phases <- etlutils::getGlobalVariablesByPrefix("PHASES_WARD")
  for (ward_phase in ward_phases) {
    configured_ward_name <- extractSingleEntryLinesValue(ward_phase, "ward_name")
    if (identical(configured_ward_name, ward_name)) {
      return(ward_phase)
    }
  }
  return(NULL)
}

#
# Extract values for a given key from a list of character vectors. Each element of the list is expected to be a character vector of lines containing key-value pairs.
# Returns a character vector of values corresponding to the key, excluding any NA values.
#
extractValues <- function(list_with_string_vector, key) {
  values <- c()
  for (i in seq_along(list_with_string_vector)) {
    lines <- list_with_string_vector[[i]]
    value <- extractSingleEntryLinesValue(lines, key)
    if (!is.na(value)) {
      values <- c(values, value)
    }
  }
  return(values)
}

#
# Get the study phase for a unique ward_name from defined toml parameters for a specific timestamp
#
getStudyPhase <- function(ward_name, date_time) {
  # if the ward is defined as a Phase B test ward, return "PhaseBTest" without checking the date,
  # because this is used for testing purposes and should not be affected by the date
  if (etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B_TEST") && ward_name %in% WARDS_PHASE_B_TEST) {
    return("PhaseBTest")
  }

  # determine the phase for the given ward and date_time based on the ward phases defined in the configuration.
  # If no phase is active for the given date_time, return "NoPhaseActive".
  phase <- NA_character_ # indicates that the ward is not defined in the configuration
  ward_phase <- getWardPhaseDefinition(ward_name)
  if (!is.null(ward_phase)) {
    phase <- "NoPhaseActive" # indicates that the ward is defined in the configuration but no phase is active for the given date_time
    lines <- ward_phase
    phase_b_start <- etlutils::parseTimestamp(extractSingleEntryLinesValue(lines, "phase_b_start"))
    phase_b_end <- etlutils::parseTimestamp(extractSingleEntryLinesValue(lines, "phase_b_end"))
    if (
      !is.na(phase_b_start) && date_time >= phase_b_start &&
      (is.na(phase_b_end) || date_time < phase_b_end)
    ) {
      phase <- "PhaseB"
    } else if (is.na(phase_b_start) || date_time < phase_b_start) {
      phase_a_start <- etlutils::parseTimestamp(extractSingleEntryLinesValue(lines, "phase_a_start"))
      if (date_time >= phase_a_start) {
        phase <- "PhaseA"
      }
    }
  }
  # phase can be "PhaseA", "PhaseB", "NoPhaseActive" (if the ward is defined but no phase is active for the given date_time) or NA (if the ward is not defined in the configuration)
  return(phase)
}

#
# Check whether Phase B is active for a ward at a timestamp.
#
isPhaseBActiveForWard <- function(ward_name, timestamp = etlutils::as.POSIXctWithTimezone(Sys.time())) {
  if (etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B_TEST") && ward_name %in% WARDS_PHASE_B_TEST) {
    return(TRUE)
  }

  ward_phase <- getWardPhaseDefinition(ward_name)
  if (is.null(ward_phase)) {
    return(FALSE)
  }

  phase_b_start <- etlutils::parseTimestamp(
    extractSingleEntryLinesValue(ward_phase, "phase_b_start")
  )
  phase_b_end <- etlutils::parseTimestamp(extractSingleEntryLinesValue(ward_phase, "phase_b_end"))
  return(
    !is.na(phase_b_start) && phase_b_start <= timestamp &&
      (is.na(phase_b_end) || timestamp < phase_b_end)
  )
}

#
# Check whether MRP calculation is active for any ward represented by fall_fe rows.
#
isMRPCalculationActiveForFallFeRows <- function(
  fall_fe_rows,
  timestamp = etlutils::as.POSIXctWithTimezone(Sys.time())
) {
  study_phases <- fall_fe_rows$fall_studienphase
  if (any(!is.na(study_phases) & study_phases == "PhaseBTest")) {
    return(TRUE)
  }

  ward_names <- unique(stats::na.omit(fall_fe_rows$fall_station))
  return(any(vapply(ward_names, isPhaseBActiveForWard, logical(1), timestamp = timestamp)))
}

#
# Check if the study has Phase B wards defined in the configuration.
#
isPhaseBActive <- function(timestamp = etlutils::as.POSIXctWithTimezone(Sys.time())) {
  ward_phases <- etlutils::getGlobalVariablesByPrefix("PHASES_WARD")
  ward_names <- extractValues(ward_phases, "ward_name")
  return(any(vapply(ward_names, isPhaseBActiveForWard, logical(1), timestamp = timestamp)))
}

#
# Check if the study has no or not only Phase A wards defined in the configuration.
#
hasPhaseBOrBTestWards <- function(timestamp =  etlutils::as.POSIXctWithTimezone(Sys.time())) {
  if (etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B_TEST")) {
    return(TRUE)
  }
  return(isPhaseBActive(timestamp))
}
