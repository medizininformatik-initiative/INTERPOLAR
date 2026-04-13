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
# Extract values for a given key from a list of character vectors. Each element of the list is expected to be a character vector of lines containing key-value pairs.
# Returns a character vector of values corresponding to the key, excluding any NA values.
#
extractValues <- function(list_with_string_vector, key) {
  values <- c()
  for (i in seq_along(list_with_string_vector)) {
    lines <- list_with_string_vector[[i]][[1]]
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

  # get the index of the ward phase definition for the given ward name, return -1 if not found
  getWardPhaseIndex <- function(ward_phases, ward_name) {
    # Build regex allowing arbitrary whitespace around '='
    pattern <- paste0("ward_name\\s*=\\s*'", ward_name, "'")
    for (i in seq_along(ward_phases)) {
      lines <- ward_phases[[i]]
      if (any(grepl(pattern, lines, perl = TRUE))) {
        return(i)
      }
    }
    return(-1)
  }

  # determine the phase for the given ward and date_time based on the ward phases defined in the configuration.
  # If no phase is active for the given date_time, return "NoPhaseActive".
  phase <- NA_character_ # indicates that the ward is not defined in the configuration
  ward_phases <- etlutils::getGlobalVariablesByPrefix("PHASES_WARD")
  phase_def_index <- getWardPhaseIndex(ward_phases, ward_name)
  if (phase_def_index != -1L) {
    phase <- "NoPhaseActive" # indicates that the ward is defined in the configuration but no phase is active for the given date_time
    lines <- ward_phases[[phase_def_index]]
    phase_b_start <- etlutils::parseTimestamp(extractSingleEntryLinesValue(lines, "phase_b_start"))
    if (!is.na(phase_b_start) && date_time >= phase_b_start) {
      phase <- "PhaseB"
    } else {
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
# Check if the study has Phase B wards defined in the configuration.
#
isPhaseBActive <- function(timestamp =  etlutils::as.POSIXctWithTimezone(Sys.time())) {
  # get all phase_b_start values from the ward phases and check if any is before the given timestamp
  ward_phases <- etlutils::getGlobalVariablesByPrefix("PHASES_WARD")
  phase_b_starts <- extractValues(ward_phases, "phase_b_start")
  # convert to timestamp via parseTimestamp and check if any is before the given timestamp
  # the timestamp cannot be empty or invalid format because this is already checked in validateWardPhase
  # which is called in before this function is called
  for (phase_b_start in phase_b_starts) {
    phase_b_start <- etlutils::parseTimestamp(phase_b_start)
    if (phase_b_start <= timestamp) {
      return(TRUE)
    }
  }
  return(FALSE)
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
