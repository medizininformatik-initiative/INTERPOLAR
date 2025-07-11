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
    stop("No ward filter patterns found with prefix", filter_patterns_global_variable_name_prefix, "in toml file")
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
#' @param path_to_files The path to the files containing patient IDs and encounters.
#'
#' @return A unique, sorted list of patient IDs.
#'
loadInitialPatientsAndEncountersFromFiles <- function(path_to_files) {
  path_to_PID_list_file <- fhircrackr::paste_paths(path_to_files, "pids_per_ward_raw.RData")
  path_to_encounter_file <- fhircrackr::paste_paths(path_to_files, "initial_encounters.RData")

  # This should be only used for debug/tests.
  # Parse Patient_id from text file is deactivated. The code below this hunk is deactivated.
  # DIC should go the way of assigning the encounter/patients to the wards via the 3-stage encounter system.
  if (TRUE || endsWith(path_to_PID_list_file, ".RData")) {
    return(list(pids_per_ward = readRDS(path_to_PID_list_file),
                initial_encounters = readRDS(path_to_encounter_file)))
  }

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

#' Extract Patient IDs (PIDs) and Encounter IDs per Ward
#'
#' This function filters encounter data based on ward-specific patterns and extracts
#' a data.table containing unique PIDs and corresponding encounter IDs for each ward.
#'
#' @param encounters A data.frame or data.table containing encounter data.
#' @param all_wards_filter_patterns A named list of filtering patterns for different wards.
#'
#' @return A named list where each element is a data.table with `pid` and `encounter_id` for a specific ward.
#'
extractPIDsSplittedByWard <- function(encounters, all_wards_filter_patterns) {

  pids_splitted_by_ward <- list()

  for (i in seq_along(all_wards_filter_patterns)) {
    ward_filter_patterns <- all_wards_filter_patterns[[i]]

    # Filter encounters based on ward-specific patterns
    ward_encounters <- etlutils::filterResources(encounters, ward_filter_patterns)

    # Save filtered encounters
    etlutils::writeRData(ward_encounters, paste0("pid_source_encounter_filtered_", i))

    # Create a data.table with PID and Encounter ID
    dt <- data.table(
      patient_id = ward_encounters$`subject/reference`,
      encounter_id = ward_encounters$id
    )

    # Remove duplicates and sort by PID
    dt <- unique(dt[order(patient_id)])

    # Assign the ward name as the list key
    ward_name <- names(all_wards_filter_patterns)[i]
    pids_splitted_by_ward[[ward_name]] <- dt
  }

  # If DEBUG_FILTER_PIDS_PATTERN exists, filter PIDs based on the pattern
  if (exists("DEBUG_FILTER_PIDS_PATTERN", envir = .GlobalEnv)) {
    for (ward in names(pids_splitted_by_ward)) {
      pids_splitted_by_ward[[ward]] <- pids_splitted_by_ward[[ward]][grepl(DEBUG_FILTER_PIDS_PATTERN, patient_id)]
    }
  }

  return(pids_splitted_by_ward)
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

  runLevel3("Get Enconters", {

    # Refresh token, if defined
    etlutils::fhirsearchRefreshToken()

    resource <- "Encounter"

    runLevel3("Download and Crack Encounters", {

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
        if (!nchar(trimws(FHIR_SEARCH_ENCOUNTER_STATUS))) { # Intentionally empty status
          encounter_status <- NA_character_
        } else {
          encounter_status <- paste(FHIR_SEARCH_ENCOUNTER_STATUS, collapse = ",")
        }
      } else { # Default is "in-progress"
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
      if (exists("FHIR_SEARCH_ENCOUNTER_LOCATION_IDS")) {
        encounter_locations <- paste(FHIR_SEARCH_ENCOUNTER_LOCATION_IDS, collapse = ",")
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

      parameters <- etlutils::fhirsearchAddGlobalParams(parameters)

      request_encounter <- fhircrackr::fhir_url(
        url        = FHIR_SERVER_ENDPOINT,
        resource   = "Encounter",
        parameters = parameters
      )

      if (exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS")) {
        request_encounter <- paste0(request_encounter, FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS)
      }

      # stop the execution and print the current result of FHIR search request (DEBUG)
      etlutils::checkDebugTestError("DEBUG_FHIR_SEARCH_ENCOUNTER_REQUEST_TEST", request_encounter)

      table_enc <- etlutils::fhirsearchDownloadAndCrackResources(request = request_encounter,
                                                                 table_description = table_description,
                                                                 max_bundles = MAX_ENCOUNTER_BUNDLES,
                                                                 log_errors  = "enc_error.xml")

      if (etlutils::isSimpleNA(table_enc) || !nrow(table_enc)) {
        stop("The FHIR request did not return any available Encounter bundles.\nRequest: ",
             etlutils::formatStringStyle(request_encounter[[1]], fg = 2, underline = TRUE))
      }

    })

    runLevel3Line("Validate encounter subject reference", {
      invalid_encounters <- table_enc[is.na(subject.reference)]
      table_enc <- table_enc[!is.na(subject.reference)]
      if (!nrow(table_enc)) {
        stop("No valid Encounter found. All found encounters have no valid subject reference.\n",
             "Request: ", etlutils::formatStringStyle(request_encounter[[1]], fg = 2, underline = TRUE), "\n",
             "Encounters: ", paste0(invalid_encounters$id, collapse = ", "), "\n")
      } else if (nrow(invalid_encounters)) {
        etlutils::catWarningMessage(paste0("The following encounters have no valid subject reference:\n",
                                    paste0(invalid_encounters$id, collapse = ", ")), "\n")
      }
    })

    runLevel3Line("Change column classes", {
      table_enc <- table_enc[, lapply(.SD, as.character), ]
    })

    etlutils::printAllTables(table_enc)

    runLevel3Line("Save and Delete Encounters Table", {
      etlutils::writeRData(table_enc, "pid_source_encounter_unfiltered")
    })

  })

  return(table_enc)
}

#' Extracts the relevant patient IDs from download Encounter resources. If the file name parameter is NA then
#' the relevant patient IDs are extracted by Encounters downloaded from the FHIR server. If the file name
#' parameter is not NA then the patient IDs are loaded from the specified file (one PID per line).
#'
#' @param log_result logical indicating that the result of the functions should be logged via cat. Default is TRUE.
#'
#' @return the relevant patient IDs per ward
#'
getPIDsSplittedByWard <- function(log_result = TRUE) {

  read_pids_from_file <- exists("DEBUG_PATH_TO_RAW_RDATA_FILES")
  if (read_pids_from_file) {

    etlutils::runLevel3(paste("Get Patient IDs by file from path ", DEBUG_PATH_TO_RAW_RDATA_FILES), {
      file_data <- loadInitialPatientsAndEncountersFromFiles(DEBUG_PATH_TO_RAW_RDATA_FILES)
      pids_splitted_by_ward <- split(file_data$pids_per_ward[, !("ward_name"), with = FALSE], file_data$pids_per_ward$ward_name)
      encounters <- file_data$initial_encounters
    })
  } else {
    etlutils::runLevel3("Get Patient IDs by Encounters from FHIR Server", {
      etlutils::runLevel3("Load Encounters", {
        filter_patterns <- convertFilterPatterns()
        # the subject reference is needed in every case to extract them if the encounter matches the pattern
        # the period end is needed to check if the Encounter is still finished
        # maybe some other columns (state or something like this) could be important, so we had to add them here in future
        filter_enc_table_description <- getTableDescriptionColumnsFromFilterPatterns(filter_patterns,
                                                                                     "id",
                                                                                     "subject/reference",
                                                                                     "period/start",
                                                                                     "period/end",
                                                                                     "status",
                                                                                     "meta/lastUpdated")
        # Get current or debug datetime
        current_datetime <- getQueryDatetime()
        # Replace space with 'T' in timestamp for correct time format
        current_datetime <- gsub(" ", "T", current_datetime)
        # Download the Encounters and crack them in a table with the columns of the xpaths in
        # filter patterns + the additional paths above
        encounters <- getEncounters(filter_enc_table_description, current_datetime)
        # the fhircrackr does not accept same column names and xpath expessions but we need the xpath expressions as column
        # names for the filtering -> set them here
        names(encounters) <- filter_enc_table_description@cols@.Data
      })

      etlutils::runLevel3("Validate Encounter Filters", {
        # Check if any column except the period/end column has only NA values -> generate warning
        cols_to_check <- setdiff(names(encounters), "period/end")
        # find columns with all values NA
        na_columns <- cols_to_check[
          sapply(encounters[, ..cols_to_check], function(col) all(is.na(col)))
        ]
        if (length(na_columns)) {
          warning_message <- paste0("The following columns have only NA values:\n",
                                  paste(na_columns, collapse = ", "), "\n",
                                  "Please check the filter patterns in the toml file.\n",
                                  "This may indicate that invalid column names are specified in",
                                  " ENCOUNTER_FILTER_PATTERNS. Wards with such invalid Encounter",
                                  " column names will never be able to contain patients.\n")
          etlutils::catWarningMessage(warning_message)
        }
      })

      etlutils::runLevel3Line("Split Encounters to wards", {
        # now filter the encounters with the patterns and then extract the PIDs
        pids_splitted_by_ward <- extractPIDsSplittedByWard(encounters, filter_patterns)
      })
    })
  }

  # extract ID from references
  for (i in seq_along(pids_splitted_by_ward)) {
    pids_splitted_by_ward[[i]][, patient_id := etlutils::getAfterLastSlash(patient_id)]
  }

  etlutils::runLevel3("Ensure every Encounter/Patient ID is only assigned to one ward", {
    # Combine all patient IDs from the list into a data table with their corresponding stations
    pids_per_ward <- rbindPidsSplittedByWard(pids_splitted_by_ward)

    # Find patient IDs that appear in multiple different wards
    multi_ward_patients <- unique(pids_per_ward[, .(patient_id, ward_name)])[, .N, by = patient_id][N > 1, patient_id]
    # Keep only rows where patient_id appears in multiple different wards
    duplicates_pids_per_ward <- pids_per_ward[patient_id %in% multi_ward_patients]
    # Stop if duplicates pids are found
    if (nrow(duplicates_pids_per_ward)) {
      if (read_pids_from_file) {
        error_message_part <- paste0("Please fix it in the file '", path_to_PID_list_file, "'.\n")
      } else {
        error_message_part <- "Please fix the variables 'ENCOUNTER_FILTER_PATTERN' in the toml file.\n"
      }
      error_message <- paste0("Invalid patient_ids: The following patient_ids are assigned more than in one ward.\n",
                              error_message_part,
                              etlutils::getPrintString(duplicates_pids_per_ward), "\n",
                              "Hint: To ensure that a patient only has exactly one Encounter assigned to exactly one ward, all but one Encounter will be removed.\n",
                              "      Only the encounters with the latest start date are left.\n",
                              "      If there are several, then the lastUpdateDate of the Encounter is checked.\n",
                              "      If there are still several, the first Encounter in the list is simply left.\n")
      etlutils::catWarningMessage(error_message) # first this was an stop error but now it is a warning
    }
  })

  filterEncountersPerPatient <- function(pids_per_ward, encounters) {

    # Join encounter info (start + meta) to combined table
    pids_per_ward <- merge(
      pids_per_ward,
      encounters[, .(encounter_id = id, `period/start`, `meta/lastUpdated`)],
      by = "encounter_id",
      all.x = TRUE
    )

    # Step 1: Keep only the encounters with the **latest `period/start`** per patient_id
    pids_per_ward <- pids_per_ward[
      pids_per_ward[, .I[`period/start` == max(`period/start`, na.rm = TRUE)], by = patient_id]$V1
    ]

    # Step 2: If multiple entries per patient_id remain, keep those with latest meta-lastUpdateDate
    pids_per_ward <- pids_per_ward[
      pids_per_ward[, .I[`meta/lastUpdated` == max(`meta/lastUpdated`, na.rm = TRUE)], by = patient_id]$V1
    ]

    # Step 3: If still multiple per patient_id: keep only the first (arbitrary stable choice)
    pids_per_ward <- pids_per_ward[
      pids_per_ward[, .I[1], by = patient_id]$V1
    ]

    # Re-split into station-wise list
    pids_splitted_by_ward <- split(pids_per_ward[, .(patient_id, encounter_id, ward_name)], by = "ward_name")
    # Remove the ward_name column from all subtables
    pids_splitted_by_ward <- lapply(pids_splitted_by_ward, function(dt) dt[, ward_name := NULL])

    return(pids_splitted_by_ward)
  }

  pids_splitted_by_ward <- filterEncountersPerPatient(pids_per_ward, encounters)

  if (log_result) {
    no_wards <- !length(pids_splitted_by_ward)
    all_wards_empty <- all(sapply(pids_splitted_by_ward, function(set) length(set) == 0))
    if (!no_wards && !all_wards_empty) {
      cat("Found the following patient IDs for ward(s) '", paste0(names(pids_splitted_by_ward), collapse = "', '"), "':\n", sep = "")
      print(pids_splitted_by_ward)
    } else {
      searched_resource <- ifelse(read_pids_from_file, "Patient IDs", "Encounters")
      if (no_wards) {
        message <- paste0("No ward names and no ", searched_resource, "found ")
      } else if (all_wards_empty) {
        message <- paste0("No ", searched_resource, " found for ward(s) '", paste0(names(pids_splitted_by_ward), collapse = "', '"), "' ")
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
  return(pids_splitted_by_ward)
}
