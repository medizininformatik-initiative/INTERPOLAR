#' Converts a filter pattern list from the toml file into an internal representation
#' as a list of lists. Every subcondition in a sublist must be fulfilled to fulfill
#' the whole condition represented by the sublist (AND connected). Lines of the table
#' can be accepted by the filter if at least one of the main conditions (which consists
#' of these subconditions) in the main list is fulfilled (OR connected).
#'
#' @param filter_patterns_global_variable_name_prefix name of the variable in the glogbal environment which
#' contains the filter patterns from the toml file
#'
#' @return the filter patterns which are converted to a list of lists
#'
convertFilterPatterns <- function(filter_patterns_global_variable_name_prefix = "ENCOUNTER_FILTER_PATTERN") {
  ward_pids_filter_patterns <- etlutils::getGlobalVariablesByPrefix(filter_patterns_global_variable_name_prefix)

  if (!length(ward_pids_filter_patterns)) {
    stopWithError("No ward filter patterns found with prefix", filter_patterns_global_variable_name_prefix, "in toml file")
  }

  # Initializes an empty list to store the final converted filter patterns. Each element in this list
  # corresponds to a ward, with the ward name as the key. The value for each ward is another list that
  # contains the AND-connected filter conditions (sub-conditions). Multiple groups of such conditions
  # are stored as separate elements, representing the OR-connected groups of filters for the ward.
  converted_filter_patterns <- list()
  ward_index <- 1
  for (ward_filter_patterns in ward_pids_filter_patterns) {
    single_ward_converted_filter_patterns <- list()
    ward_name <- paste("Station", ward_index)
    for (filter_patterns in ward_filter_patterns) { # filter_patterns <- ward_pids_filter_patterns[[1]]
      for (filter_pattern in filter_patterns) { # filter_pattern <- filter_patterns$value[2]
        if (startsWith(filter_pattern, "ward_name")) {
          ward_name <- etlutils::getBetweenQuotes(filter_pattern)
        } else {
          and_conditions <- list()
          filter_pattern_conditions <- unlist(strsplit(filter_pattern, "\\+"))
          for (condition in filter_pattern_conditions) { # condition <- filter_pattern_conditions[1]
            condition_key_value <- unlist(strsplit(condition, "="))
            condition_column <- trimws(condition_key_value[1])
            condition_value <- etlutils::getBetweenQuotes(condition_key_value[2])
            and_conditions[[condition_column]] <- condition_value
          }
          single_ward_converted_filter_patterns[[paste0("Condition_", length(single_ward_converted_filter_patterns) + 1)]] <- and_conditions
        }
      }
      converted_filter_patterns[[length(converted_filter_patterns) + 1]] <- single_ward_converted_filter_patterns
      names(converted_filter_patterns)[length(converted_filter_patterns)] <- ward_name
    }
  }
  converted_filter_patterns
}

#' Get FHIR table description based on filter patterns.
#'
#' This function takes a list of filter patterns and extracts unique column names
#' from them to create a FHIR table description for the 'Encounter' resource.
#'
#' @param filter_patterns A list of filter patterns, where each pattern is a list of conditions.
#'   Each condition is expected to have named elements representing column names.
#' @param ... Additional columns to be included in the FHIR table description.
#'
#' @return A FHIR table description object for the 'Encounter' resource with columns based
#'   on the unique names extracted from the filter patterns, including additional columns.
#'
getTableDescriptionColumnsFromFilterPatterns <- function(filter_patterns, ...) {
  cols_vector <- c()
  for (ward_conditions in filter_patterns) {
    for (condition in ward_conditions) {
      cols_vector <- c(cols_vector, names(condition))
    }
  }
  cols_vector <- c(cols_vector, ...)
  cols_vector <- sort(unique(cols_vector))
  fhir_table_desc <- fhircrackr::fhir_table_description(
    resource = "Encounter",
    cols = cols_vector,
    sep = SEP,
    brackets = NULL
  )
}

#' Parse and interpolate patient IDs from a file.
#'
#' This function reads patient IDs from a file specified by the provided path.
#' The patient IDs are then returned as a unique, sorted list.
#'
#' @param path_to_PID_list_file The path to the file containing patient IDs.
#'
#' @return A unique, sorted list of patient IDs.
#'
parsePatientIDsPerWardFromFile <- function(path_to_PID_list_file) {

  # Helper function to process the PIDs of a single ward
  processWardPIDs <- function(single_ward_pids, ward_name, pids_per_ward) {
    if (!is.na(ward_name) && length(single_ward_pids) > 0) {
      single_ward_pids <- lapply(unique(single_ward_pids), convertStringToPrefixedFormat, prefix = "Patient", separator = "/")
      pids_per_ward[[ward_name]] <- etlutils::sortListByValue(single_ward_pids)
    }
    return(pids_per_ward)
  }

  pids_per_ward <- list()
  lines <- readLines(path_to_PID_list_file)
  single_ward_pids <- list()
  ward_name <- NA

  for (line in lines) {
    line <- trimws(sub("#.*$", "", line)) # remove comments (starts with '#')
    if (nchar(line)) {
      if (startsWith(line, "ward_name")) {
        pids_per_ward <- processWardPIDs(single_ward_pids, ward_name, pids_per_ward)
        single_ward_pids <- list()
        ward_name <- etlutils::getBetweenQuotes(line)
      } else {
        single_ward_pids[[length(single_ward_pids) + 1]] <- line
      }
    }
  }
  pids_per_ward <- processWardPIDs(single_ward_pids, ward_name, pids_per_ward)

  return(pids_per_ward)
}

#' Get unique patient IDs per ward based on filter patterns.
#'
#' This function takes a list of encounters and a corresponding list of filter patterns for each ward.
#' It filters the encounters for each ward based on the provided filter patterns and extracts unique
#' patient IDs ('subject/reference'). The result is a list where each element corresponds to a ward,
#' and the values are unique patient IDs for that ward.
#'
#' @param encounters A list of encounter to filter.
#' @param all_wards_filter_patterns A list of filter patterns, where each element corresponds to a ward.
#'
#' @return A list where each element corresponds to a ward, and the values are unique patient IDs for that ward.
#'   The list is structured such that each outer list represents a ward, and the inner lists contain
#'   unique patient IDs for that ward.
#'
getPIDsPerWard <- function(encounters, all_wards_filter_patterns) {
  pids_per_ward <- list()
  for (i in seq_along(all_wards_filter_patterns)) {
    ward_filter_patterns <- all_wards_filter_patterns[[i]]
    ward_encounters <- etlutils::filterResources(encounters, ward_filter_patterns)
    writeRData(ward_encounters, "pid_source_encounter_filtered")
    pids_per_ward[[i]] <- unique(sort(ward_encounters$'subject/reference')) # PID is always in 'subject/reference'
    names(pids_per_ward)[i] <- names(all_wards_filter_patterns)[i]
  }

  if (exists("DEBUG_FILTER_PIDS_PATTERN")) {
    for (ward in names(pids_per_ward)) {
      pids_per_ward[[ward]] <- pids_per_ward[[ward]][grepl(DEBUG_FILTER_PIDS_PATTERN, pids_per_ward[[ward]])]
    }
  }
  return(pids_per_ward)
}

#' Download and preprocess encounter data from FHIR server
#'
#' This function retrieves encounter data from a FHIR server, applies various filters,
#' and performs data processing tasks.
#'
#' @param table_description the fhir crackr table description with the columns definition
#' of the returned table.
#' @param current_datetime the current datetime or debug datetime
#'
#' @details
#' The function handles the download of encounter data, filtering based on date ranges,
#' and additional processing steps such as fixing dates, adding columns, and handling
#' exclusion criteria.
#'
#' @return
#' The processed encounter data is saved, and relevant tables are returned and/or
#' saved as RData files.
#'
getEncounters <- function(table_description, current_datetime) {

  etlutils::runLevel3("Get Enconters", {

    # Refresh token, if defined
    refreshFHIRToken()

    resource <- "Encounter"

    etlutils::runLevel3("Download and Crack Encounters", {

      # Only if both parameters exist then we search with starts after (sa) and ends before (eb)
      # and only then the current_datetime is a vector with 2 entries (start date at 1 and end date
      # at 2)
      if (exists("DEBUG_ENCOUNTER_DATETIME_START") && exists("DEBUG_ENCOUNTER_DATETIME_END") && nchar(DEBUG_ENCOUNTER_DATETIME_END) > 0) {
        encounter_dates <- c(
          "date"   = paste0("sa", current_datetime[["start_datetime"]]),
          "date"   = paste0("eb", current_datetime[["end_datetime"]])
        )
      # If there is no end date given, but a start date, then we search with 'lower than' (lt).
      # If in the toml file a start date is given (parameter DEBUG_ENCOUNTER_DATETIME_START) then
      # this date replaces the current date of the system.
      } else {
        encounter_dates <- c(
          "date"   = paste0("lt", current_datetime)
        )
      }

      # default encounter status "in-progress" can be replaced in the toml file  by the
      # parameter FHIR_SEARCH_ENCOUNTER_STATUS. If it is given as vector then the values
      # will be comma separated pasted together.
      if (exists("FHIR_SEARCH_ENCOUNTER_STATUS")) {
        encounter_status <- paste(FHIR_SEARCH_ENCOUNTER_STATUS, collapse = ",")
      } else {
        encounter_status <- "in-progress"
      }

      # same as the status with the parameter FHIR_SEARCH_ENCOUNTER_CLASS for the FHIR search
      # parameter 'class'
      encounter_class <- NA
      if (exists("FHIR_SEARCH_ENCOUNTER_CLASS")) {
        encounter_class <- paste(FHIR_SEARCH_ENCOUNTER_CLASS, collapse = ",")
      }

      # filtering for the IDs of referenced Locations in the Encounters
      encounter_locations <- NA
      if (exists("FHIR_SEARCH_LOCATION_IDS")) {
        encounter_locations <- paste(FHIR_SEARCH_LOCATION_IDS, collapse = ",")
      }

      parameters <- c(
        encounter_dates,
        "status" = encounter_status,
        "class" = encounter_class,
        "location" = encounter_locations)

      if (exists("DEBUG_ENCOUNTER_ACCEPTED_PIDS") && length(DEBUG_ENCOUNTER_ACCEPTED_PIDS) > 0) {
        encounter_pids <- DEBUG_ENCOUNTER_ACCEPTED_PIDS
        encounter_pids <- ifelse(grepl("/", encounter_pids), encounter_pids, paste0("Patient/", encounter_pids))
        encounter_pids <- paste(encounter_pids, collapse = ",")
        parameters <- c(parameters, "subject" = encounter_pids)
      }

      parameters <- etlutils::addParamToFHIRRequest(parameters)

      request_encounter <- fhircrackr::fhir_url(
        url        = FHIR_SERVER_ENDPOINT,
        resource   = "Encounter",
        parameters = parameters
      )

      # stop the execution and print the current result of FHIR search request (DEBUG)
      checkDebugTestError("DEBUG_ENCOUNTER_REQUEST_TEST", request_encounter)

      table_enc <- etlutils::downloadAndCrackFHIRResources(request = request_encounter,
                                                           table_description = table_description,
                                                           max_bundles = MAX_ENCOUNTER_BUNDLES,
                                                           log_errors  = "enc_error.xml")

      if (etlutils::isSimpleNA(table_enc)) {
        stop("The FHIR request did not return any available Encounter bundles.\n Request: ",
             etlutils::formatStringStyle(request_encounter[[1]], fg = 2, underline = TRUE))
      }

    })

    etlutils::runLevel3Line("Change column classes", {
      table_enc <- table_enc[, lapply(.SD, as.character), ]
    })

    etlutils::printAllTables(table_enc)

    etlutils::runLevel3Line("Save and Delete Encounters Table", {
      etlutils::writeRData(table_enc, "pid_source_encounter_unfiltered")
    })

  })

  return(table_enc)
}

#' Extracts the relevant patient IDs from download Encounter resources. If the file name parameter is NA then
#' the relevant patient IDs are extracted by Encounters downloaded from the FHIR server. If the file name
#' parameter is not NA then the patient IDs are loaded from the specified file (one PID per line).
#'
#' @param path_to_PID_list_file file name if the list of patient IDs should be loaded from a file (if not then NA)
#' @param log_result logical indicating that the result of the functions should be logged via cat. Default is TRUE.
#'
#' @return the relevant patient IDs per ward
#'
getPatientIDsPerWard <- function(path_to_PID_list_file = NA, log_result = TRUE) {
  read_pids_from_file <- !is.na(path_to_PID_list_file)
  if (read_pids_from_file) {
    etlutils::runLevel3(paste("Get Patient IDs by file", path_to_PID_list_file), {
      pids_per_ward <- parsePatientIDsPerWardFromFile(path_to_PID_list_file)
    })
  } else {
    etlutils::runLevel3("Get Patient IDs by Encounters from FHIR Server", {
      filter_patterns <- convertFilterPatterns()
      # the subject reference is needed in every case to extract them if the encounter matches the pattern
      # the period end is needed to check if the Encounter is still finished
      # maybe some other columns (state or something like this) could be important, so we had to add them here in future
      filter_enc_table_description <- getTableDescriptionColumnsFromFilterPatterns(filter_patterns, "id", "subject/reference", "period/start", "period/end", "status")
      # Get current or debug datetime
      current_datetime <- etlutils::getQueryDatetime()
      # Replace space with 'T' in timestamp for correct time format
      current_datetime <- gsub(" ", "T", current_datetime)
      # Download the Encounters and crack them in a table with the columns of the xpaths in
      # filter patterns + the additional paths above
      encounters <- getEncounters(filter_enc_table_description, current_datetime)
      # the fhircrackr does not accept same column names and xpath expessions but we need the xpath expressions as column
      # names for the filtering -> set them here
      names(encounters) <- filter_enc_table_description@cols@.Data
      # now filter the encounters with the patterns and then extract the PIDs
      pids_per_ward <- getPIDsPerWard(encounters, filter_patterns)
    })
  }

  #
  etlutils::runLevel3("Ensure every Encounter/Patient ID is only assigned to one ward", {
    # Combine all patient IDs from the list into a data table with their corresponding stations
    pids_per_ward_combinations <- unique(data.table::rbindlist(
      lapply(names(pids_per_ward), function(ward) {
        data.table::data.table(patient_id = pids_per_ward[[ward]], ward = ward)
      }),
      use.names = TRUE, fill = TRUE
    ))
    # Find duplicated pids
    duplicates_pids_per_ward <- pids_per_ward_combinations[patient_id %in% names(which(table(patient_id) > 1))]
    # Stop if duplicates pids are found
    if (nrow(duplicates_pids_per_ward)) {
      if (read_pids_from_file) {
        error_message_part <- paste0("Please fix it in the file '", path_to_PID_list_file, "'.\n")
      } else {
        error_message_part <- "Please fix the variables 'ENCOUNTER_FILTER_PATTERN' in the toml file.\n"
      }
      error_message <- paste0("Invalid patient_ids: The following patient_ids are assigned more than in one ward in file '", path_to_PID_list_file, "'.\n",
                              error_message_part,
                              etlutils::getPrintString(duplicates_pids_per_ward))
      stop(error_message)
    }
  })

  if (log_result) {
    no_wards <- !length(pids_per_ward)
    all_wards_empty <- all(sapply(pids_per_ward, function(set) length(set) == 0))
    if (!no_wards && !all_wards_empty) {
      cat("Found the following patient IDs for ward(s) '", paste0(names(pids_per_ward), collapse = "', '"), "':\n", sep = "")
      print(pids_per_ward)
    } else {
      searched_resource <- ifelse(read_pids_from_file, "Patient IDs", "Encounters")
      if (no_wards) {
        message <- paste0("No ward names and no ", searched_resource, "found ")
      } else if (all_wards_empty) {
        message <- paste0("No ", searched_resource, " found for ward(s) '", paste0(names(pids_per_ward), collapse = "', '"), "' ")
      }
      if (read_pids_from_file) {
        message <- paste0(message, "in file '", path_to_PID_list_file, "'.\n")
      } else {
        # current_datetime can be only a start date or a vector with an start and end date (in DEBUG mode)
        current_datetime_display <- ifelse(length(current_datetime) == 1, current_datetime, paste0("start ", paste0(current_datetime, collapse = " to end ")))
        message <- paste0(message, "on FHIR server for timestamp ", current_datetime_display, ".\n")
      }
      etlutils::catWarningMessage(message)
    }
  }
  return(pids_per_ward)
}
