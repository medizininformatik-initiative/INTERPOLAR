#' Create a data.table with ward and patient ID per date.
#'
#' This function takes a list of patient IDs per ward and constructs a data.table
#' with columns for date_time, ward, and pid. Each row represents a unique combination
#' of date, ward, and patient ID extracted from the provided list.
#'
#' @param patient_ids_per_ward A list of patient IDs, where each element corresponds to a ward.
#'
#' @return A data.table with columns date_time, ward, and pid, representing the date, ward,
#'   and patient ID for each combination extracted from the provided list.
#'
#' @examples
#' \dontrun{
#'   library(data.table)
#'   # Example: A list of patient IDs per ward
#'   patient_ids_per_ward <- list(
#'     Ward_A = c("PID_A001", "PID_A002", "PID_A003"),
#'     Ward_B = c("PID_B001", "PID_B002"),
#'     Ward_C = c("PID_C001", "PID_C002", "PID_C003", "PID_C004")
#'   )
#'
#'   # Applying the function
#'   result_table <- createWardPatientIDPerDateTable(patient_ids_per_ward)
#'
#'   # Displaying the result
#'   print(result_table)
#' }
#'
createWardPatientIDPerDateTable <- function(patient_ids_per_ward) {
  ward_names <- names(patient_ids_per_ward)
  patient_ids <- unlist(patient_ids_per_ward)
  ward_patient_id_per_date <- data.table::data.table(
    ward_name = rep(ward_names, lengths(patient_ids_per_ward)),
    patient_id = patient_ids
  )
  return(ward_patient_id_per_date)
}

#' Get Current Datetime
#'
#' This function returns the current datetime. If the global variable `DEBUG_CURRENT_DATETIME_START` exists, it returns its value as a POSIXct object.
#' Otherwise, it returns the current system time.
#'
#' @return A POSIXct object representing the current datetime or the value of `DEBUG_CURRENT_DATETIME_START` if it exists.
#'
getCurrentDatetime <- function() {
  start_datetime <- as.POSIXct(Sys.time())
  if (exists('DEBUG_CURRENT_DATETIME_START')) {
    start_datetime <- as.POSIXct(DEBUG_CURRENT_DATETIME_START)
    if (exists('DEBUG_CURRENT_DATETIME_END')) {
      end_datetime <- as.POSIXct(DEBUG_CURRENT_DATETIME_END)
      return(c(start_datetime = start_datetime, end_datetime = end_datetime))
    }
  }
  return(c(start_datetime = start_datetime))
}

#' Get the current datetime formatted for SQL queries
#'
#' This function retrieves the current datetime using the \code{getCurrentDatetime} function
#' and formats it as a string in the "YYYY-MM-DD HH:MM:SS" format, which is appropriate for SQL queries.
#' It handles both regular and debug modes, depending on the environment.
#'
#' @return A character string representing the current datetime, formatted for SQL queries.
#'
getQueryDatetime <- function() {
  format(getCurrentDatetime(), "%Y-%m-%d %H:%M:%S")
}

#' Get active encounter patient IDs from the database
#'
#' This function retrieves patient IDs from encounters that are active based on the current query date.
#' An encounter is considered active if its start date is less than or equal to the current date and
#' either has no end date or its end date is greater than the current date.
#'
#' The function retrieves the current datetime using \code{getQueryDatetime()} and then constructs and executes
#' a SQL query to fetch the active patient IDs from the database.
#'
#' @return A vector of patient IDs with active encounters.
#'
getActiveEncounterPIDsFromDB <- function() {
  # Get current or debug datetime
  query_datetime <- getQueryDatetime()

  # Create the SQL-Query
  query <- paste0("SELECT enc_patient_id FROM v_encounter_all\n",
                  "   WHERE enc_period_start <= '", query_datetime[["start_datetime"]], "' AND\n",
                  "   (enc_period_end is NULL OR enc_period_end > '",
                  query_datetime[["start_datetime"]], "');")
  # Run the SQL query and return patient IDs
  patient_ids_active <- getQueryFromDatabase(query)

  return(patient_ids_active$enc_patient_id)
}

#' Adjusts the names of a vector or list by removing a specified prefix and matching them
#' to a list of valid names with correct capitalization.
#'
#' This function processes the names of a named vector or list by removing a specified
#' prefix and then matching the resulting names to a provided vector of valid names. If a
#' match is found, the function replaces the name with the corresponding name from the
#' valid names vector, preserving the correct capitalization.
#'
#' @param variables A named vector or list whose names need to be adjusted.
#' @param prefix A character string representing the prefix to be removed from the names.
#' @param valid_names A character vector containing valid names to match against, used to
#' format the names correctly.
#'
#' @return A named vector or list with adjusted names, where the specified prefix has been
#' removed and names are replaced with the corresponding valid names from the `valid_names`
#' vector, preserving case.
#'
adjustNames <- function(variables, prefix, valid_names) {
  # Internal helper function to process individual names
  process_name <- function(name) {
    # Remove the specified prefix
    name <- sub(paste0("^", prefix), "", name)
    # Find the corresponding name in valid_names (case-insensitive matching)
    match_index <- match(tolower(name), tolower(valid_names))

    # If a match is found, use the valid name with correct casing
    if (!is.na(match_index)) {
      name <- valid_names[match_index]
    }
    return(name)
  }
  # Apply the helper function to all names
  names(variables) <- sapply(names(variables), process_name)
  # Return the modified vector or list
  return(variables)
}

#' Load FHIR resources for a given set of patient IDs and create a table of ward-patient ID per date.
#'
#' This function takes a list of patient IDs per ward, extracts unique patient IDs,
#' loads FHIR resources for those patient IDs from the FHIR server using the provided
#' `TABLE_DESCRIPTION`, and creates an additional table of ward-patient ID per date. The
#' result is a list of data.tables, where each element contains FHIR resources for a specific
#' patient, and the last element is a table representing the ward and patient ID per date.
#'
#' @param patient_ids_per_ward A list of patient IDs, where each element corresponds to a ward.
#' @param table_descriptions the fhircrackr table descriptions of the result tables
#' @return A list of data.tables, each containing FHIR resources for a specific patient,
#'   and the last element is a table representing the ward and patient ID per date.
#'
loadResourcesByPatientIDFromFHIRServer <- function(patient_ids_per_ward, table_descriptions) {

  # Get active encounter patient IDs from the database
  patient_ids_active <- getActiveEncounterPIDsFromDB()
  # Unify and unique all patient IDs
  patient_ids <- unique(unlist(patient_ids_per_ward))
  patient_ids <- unique(c(patient_ids, patient_ids_active))

  # This parameter should only be changed via DEBUG variables to set additional test filters for
  # the FHIR-search request.
  resources_add_search_parameter <- NA

  #########################
  # START: FOR DEBUG ONLY #
  #########################

  # Find the additional test filters for the FHIR-search request to set resources_add_search_parameter

  # Define the prefix for global debug filter variables
  global_debug_filter_variable_prefix <- "DEBUG_ADD_FHIR_SEARCH_"
  # Get global filter variables with the specified prefix
  global_filter_variables <- etlutils::getGlobalVariablesByPrefix(global_debug_filter_variable_prefix, astype = "vector")

  # Load FHIR resources based on the presence of global filter variables
  if (length(global_filter_variables)) {
    resources_add_search_parameter <- adjustNames(global_filter_variables, global_debug_filter_variable_prefix, names(table_descriptions))
    if (exists("DEBUG_ADD_FHIR_SEARCH_GENERAL")) {
      # Prepend value of 'GENERAL' for all resources
      for (name in names(table_descriptions)) {
        full_value <- resources_add_search_parameter[["GENERAL"]]
        if (name %in% names(resources_add_search_parameter)) {
          full_value <- paste0(full_value, "&", resources_add_search_parameter[[name]])
        }
        resources_add_search_parameter[[name]] <- full_value
      }
    }
  }
  #######################
  # END: FOR DEBUG ONLY #
  #######################

  resource_tables <- etlutils::loadMultipleFHIRResourcesByPID(patient_ids, table_descriptions, resources_add_search_parameter)

  # Get the date for every PID when the Patient resource was written to the database the last time
  getLastPatientUpdateDate <- function(patient_ids) {

    # Ensure these are IDs and not references
    patient_ids <- getAfterLastSlash(patient_ids)

    # Create the query for the last insert/update date for every ID
    query <- paste0(
      "SELECT pat_id,\n",
      "       COALESCE(MAX(last_check_datetime), MAX(input_datetime)) AS last_insert_datetime\n",
      "FROM v_patient_all\n",
      "WHERE pat_id = ANY($1::text[])\n",
      "GROUP BY pat_id;"
    )

    # Create the corrct format for the Postgres Parameter Array
    params <- list(paste0("{", paste(patient_ids, collapse = ","), "}"))
    # Execute the SQL query to retrieve the data, passing the list of IDs as a single parameter
    result <- getQueryFromDatabase(query, params = params)

    # Create an empty result vector with NAs for patient IDs not found in the database
    last_insert_dates <- as.Date(rep(NA, length(patient_ids)))

    # Map the retrieved data to the corresponding patient IDs
    for (i in seq_along(patient_ids)) {
      matching_row <- result[result$pat_id == patient_ids[i], ]
      if (nrow(matching_row)) { # Keep NA for IDs without a last_updated date and not -Inf
        last_insert_dates[i] <- as.Date(as.POSIXct(max(matching_row$last_insert_datetime)))
      }
    }

    # Reduce the original date by at least 1 day to prevent time gaps
    last_insert_dates <- last_insert_dates - 1

    setNames(as.list(patient_ids), last_insert_dates)
  }

  # Get the date for every PID when the Patient resource was written to the database the last time
  pids_with_last_updated <- getLastPatientUpdateDate(patient_ids)

  # Load all data of relevant patients from FHIR server
  resource_tables <- etlutils::loadMultipleFHIRResourcesByPID(pids_with_last_updated, table_descriptions)

  # Add additional table of ward-patient ID per date
  resource_tables[["pids_per_ward"]] <- createWardPatientIDPerDateTable(patient_ids_per_ward)

  return(resource_tables)
}

#' Load Referenced Resources by Own ID from FHIR Server
#'
#' This function loads FHIR resources referenced by other resources from a FHIR server. It takes
#' a set of table descriptions and a list of resource tables, identifies all unique resource names
#' in the `reference_types` column of the table descriptions, and loads the referenced resources
#' for each unique resource name. The result is an updated list of resource tables including the
#' newly loaded referenced resources.
#'
#' @param table_descriptions A list containing the fhircrackr table descriptions for the result
#'   tables, including `reference_types` which lists all resources that reference other resources.
#' @param resource_tables A list of data.tables, each containing FHIR resources for specific
#'   patients. This list is updated with the referenced resources.
#'
#' @return An updated list of data.tables including the referenced resources.
#'
loadReferencedResourcesByOwnIDFromFHIRServer <- function(table_descriptions, resource_tables) {
  # table_descriptions$REFERENCE_TYPES can be a comma or whitespace separated list like
  # "MedicationStatement, MedicationAdministration". We need the all unique different
  # resource names in this column
  reference_types <- unique(etlutils::extractWords(table_descriptions$reference_types$REFERENCE_TYPES))
  for (reference_type in reference_types) {
    referenced_table_description <- table_descriptions$pid_independant[[reference_type]]
    if (!is.null(referenced_table_description)) {
      # now extract all rows where the single reference_type is in the reference_types column as whole word
      whole_word_pattern <- paste0("\\b", reference_type, "\\b")
      sub_reference_type <- table_descriptions$reference_types[grepl(whole_word_pattern, REFERENCE_TYPES)]

      referenced_ids <- c()
      for (i in seq_len(nrow(sub_reference_type))) {
        resource_name <- sub_reference_type[i]$RESOURCE
        column_name <- sub_reference_type[i]$COLUMN_NAME
        new_referenced_ids <- resource_tables[[resource_name]][[column_name]]
        new_referenced_ids <- unique(na.omit(new_referenced_ids))
        referenced_ids <- c(referenced_ids, new_referenced_ids)
      }
      table_description_sep <- referenced_table_description@sep
      referenced_ids <- unlist(strsplit(referenced_ids, table_description_sep, fixed = TRUE))
      referenced_ids <- getAfterLastSlash(referenced_ids)
      referenced_ids <- unique(referenced_ids)

      resource_tables[[reference_type]] <- etlutils::loadFHIRResourcesByOwnID(referenced_ids, referenced_table_description)
    }
  }
  return(resource_tables)
}

#' Load Resources and Referenced Resources from FHIR Server
#'
#' This function loads resources for a given set of patient IDs per ward from a FHIR server and
#' then loads any additional referenced resources. It uses two steps: first, loading resources
#' directly associated with patient IDs using `loadResourcesByPatientIDFromFHIRServer`, and second,
#' loading resources referenced by the initially loaded resources using
#' `loadReferencedResourcesByOwnIDFromFHIRServer`. The results are then saved as RData files, with
#' filenames derived from the resource names.
#'
#' @param patient_ids_per_ward A list of patient IDs, where each element corresponds to a ward and
#'   contains patient IDs associated with that ward.
#' @param table_descriptions A list containing two elements: `pid_dependant` and
#'   `pid_independant`, each of which describes table structures for resources that are dependent
#'   and independent of patient IDs, respectively.
#'
#' @details The function iterates through all resources loaded in both steps and saves them as
#'   RData files using `writeRData`. The filenames are derived by converting the names of the
#'   resources in the `resource_tables` list to lowercase.
#'
loadResourcesFromFHIRServer <- function(patient_ids_per_ward, table_descriptions) {
  resource_tables <- loadResourcesByPatientIDFromFHIRServer(patient_ids_per_ward, table_descriptions$pid_dependant)
  resource_tables <- loadReferencedResourcesByOwnIDFromFHIRServer(table_descriptions, resource_tables)

  #########################
  # START: FOR DEBUG ONLY #
  #########################
  # Prefix of all global debug variables. One for each FHIR resources.
  global_debug_filter_variable_prefix <- "DEBUG_FILTER_"
  # Get global variables by prefix
  global_filter_variables <- etlutils::getGlobalVariablesByPrefix(global_debug_filter_variable_prefix, astype = "vector")
  if (length(global_filter_variables)) {
    resource_table_names <- names(resource_tables)
    resource_filter_patterns <- adjustNames(global_filter_variables, global_debug_filter_variable_prefix, resource_table_names)
    different_resources <- setdiff(names(resource_filter_patterns), resource_table_names)
    if (length(different_resources)) {
      catInfoMessage(paste0("Note: The following debug filter resources are not in the resource table: ",
                            paste(different_resources, collapse = ", "),
                            ". Fix it in cds2db_config.toml."))
    }
    # Find common names between resource names and resource table names
    common_names <- intersect(names(resource_filter_patterns), resource_table_names)
    # Iterate over each common name
    for (name in common_names) {
      # Find the full resource names that match the current common name
      matching_indices <- which(name == names(resource_filter_patterns))
      # Take the first match, if multiple
      debug_parameter_name <- names(global_filter_variables)[matching_indices]
      # Get indices using the full resource name
      indices <- etlutils::getIndices(get(debug_parameter_name))
      # Check if indices is NA
      if (all(is.na(indices))) {
        # Set the table to be empty if indices is NA
        resource_tables[[name]] <- resource_tables[[name]][0, ]
      } else {
        rows_count <- nrow(resource_tables[[name]])
        # Check for valid indices (e.g., within the range of the number of rows in the resource table)
        invalid_indices <- indices[indices < 1 | indices > rows_count]
        # Only proceed if there are valid indices
        if (length(invalid_indices) > 0) {
          l <- length(invalid_indices)
          # If there are more than 10 invalid indices, just the first 5 and the last 5 entries are displayed
          # separately between 3 dots
          if (l <= 10) {
            invalid_indices_string <- invalid_indices
          } else {
            invalid_indices_string <- paste0(paste0(invalid_indices[1:5], collapse = ", "), " ... ",
                                             paste0(invalid_indices[(l-5):l], collapse = ", "))
          }
          etlutils::catWarningMessage(paste0(
            "Check '", debug_parameter_name, "': The following indices are invalid for resource ",
            name, ". The table has only ", rows_count, " rows. Invalid indices: ",
            paste(invalid_indices_string, collapse = ", ")))
        }
        valid_indices <- setdiff(indices, invalid_indices)
        # Update the resource table with valid indices
        resource_tables[[name]] <- resource_tables[[name]][valid_indices, ]
      }
    }
  }
  #######################
  # END: FOR DEBUG ONLY #
  #######################

  for (i in seq_along(resource_tables)) {
    writeRData(resource_tables[[i]], tolower(paste0(names(resource_tables)[i], "_raw")))
  }
  return(resource_tables)
}
