#' Get active encounter patient IDs from the database
#'
#' This function retrieves patient IDs from encounters that are active based on
#' the current query date. An encounter is considered active if its start date
#' is less than or equal to the current date and either has no end date or its
#' end date is greater than the current date.
#'
#' The function retrieves the current datetime using \code{getQueryDatetime()}
#' and then constructs and executes a SQL query to fetch the active patient IDs
#' from the database.
#'
#' @return A vector of patient IDs with active encounters.
#'
getActiveEncounterPIDsFromDB <- function() {
  # Get current or debug datetime
  query_datetime <- getQueryDatetime()
  datetime <- query_datetime[["period_start"]]

  encounter_class_condition <- ""
  if (exists("FHIR_SEARCH_ENCOUNTER_CLASS")) {
    encounter_class_condition <- paste0("  AND enc_class_code IN (", paste0("'", strsplit(FHIR_SEARCH_ENCOUNTER_CLASS, ",")[[1]], "'", collapse = ", "), ")\n")
  }

  query <- paste0(
    "SELECT DISTINCT enc_patient_ref\n",
    "FROM v_encounter_last_version\n",
    "WHERE enc_status = 'in-progress'\n",
    encounter_class_condition,
    "  AND enc_period_start <= '", datetime, "'\n",
    "  AND (enc_period_end IS NULL OR enc_period_end > '", datetime, "');\n"
  )

  # Run the SQL query and return patient IDs
  patient_ids_active <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getActiveEncounterPIDsFromDB()")

  print(paste0(
    "Active patient IDs in encounter table:\n",
    paste0(patient_ids_active$enc_patient_ref, collapse = ", ")
  ))

  return(patient_ids_active$enc_patient_ref)
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
      return(valid_names[match_index])
    }
    return(NULL)
  }

  # Apply the helper function to all names
  new_names <- lapply(names(variables), process_name)

  # Filter out NULL names and update variables
  valid_indices <- !sapply(new_names, is.null)  # Check which names are not NULL
  variables <- variables[valid_indices]         # Keep only valid variables
  names(variables) <- unlist(new_names[valid_indices]) # Assign valid names

  # Return the modified vector or list
  return(variables)
}

#########################
# START: FOR DEBUG ONLY #
#########################
debugSetResourcesAddSearchParameter <- function(
  global_debug_filter_variable_prefix = "DEBUG_ADD_FHIR_SEARCH_",
  table_descriptions,
  debug_general_variable = "DEBUG_ADD_FHIR_SEARCH_GENERAL"
) {
  # Get global filter variables with the specified prefix
  global_filter_variables <- etlutils::getGlobalVariablesByPrefix(global_debug_filter_variable_prefix, astype = "vector")

  # Initialize result
  resources_add_search_parameter <- NULL

  # Load FHIR resources based on the presence of global filter variables
  if (length(global_filter_variables)) {
    # Adjust the names of the global variables
    resources_add_search_parameter <- adjustNames(global_filter_variables, global_debug_filter_variable_prefix, names(table_descriptions))

    # Check if the general debug variable exists
    if (exists(debug_general_variable)) {
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

  # Return the resulting resource search parameters
  return(resources_add_search_parameter)
}
#######################
# END: FOR DEBUG ONLY #
#######################

#' Check if a data import date range is configured.
#'
#' DATA_IMPORT_RANGE_END cannot be defined without DATA_IMPORT_RANGE_START, so
#' we only test the start value.
#'
#' @return TRUE if DATA_IMPORT_RANGE_START is set.
hasDataImportDateRange <- function() {
  etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_START")
}

#' Build FHIR date search parameters for PID-dependent resource type data import
#'
#' @param resource_name FHIR resource type.
#' @param diagnostic_report_date_parameter Date search parameter for DiagnosticReport.
#' @return A named character vector of FHIR date search parameters, or NULL.
getDataImportFHIRDateSearchParameters <- function(resource_name, diagnostic_report_date_parameter = "date") {
  date_search_parameters <- c(
    Condition = "recorded-date",
    DiagnosticReport = diagnostic_report_date_parameter,
    MedicationAdministration = "effective-time",
    MedicationRequest = "authoredon",
    MedicationStatement = "effective",
    Observation = "date",
    Procedure = "date",
    ServiceRequest = "authored"
  )

  date_search_parameter <- date_search_parameters[[resource_name]]
  if (is.null(date_search_parameter)) {
    return(NULL)
  }

  search_parameters <- c()
  if (etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_START")) {
    search_parameters <- c(
      search_parameters,
      setNames(paste0("ge", gsub(" ", "T", DATA_IMPORT_RANGE_START, fixed = TRUE)), date_search_parameter)
    )
  }
  if (etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RANGE_END")) {
    search_parameters <- c(
      search_parameters,
      setNames(paste0("le", gsub(" ", "T", DATA_IMPORT_RANGE_END, fixed = TRUE)), date_search_parameter)
    )
  }

  return(search_parameters)
}

#' Add FHIR date search parameters to selected resources
#'
#' @param table_descriptions FHIR table descriptions keyed by resource type.
#' @param resources_add_search_parameter Existing additional search parameters.
#' @param diagnostic_report_date_parameter Date search parameter for DiagnosticReport.
#' @return Updated additional search parameters.
addDataImportFHIRDateSearchParameters <- function(table_descriptions,
                                                  resources_add_search_parameter,
                                                  diagnostic_report_date_parameter = "date") {
  if (!hasDataImportDateRange()) {
    return(resources_add_search_parameter)
  }
  if (is.null(resources_add_search_parameter) || all(is.na(resources_add_search_parameter))) {
    resources_add_search_parameter <- list()
  }

  for (resource_name in names(table_descriptions)) {
    date_search_parameters <- getDataImportFHIRDateSearchParameters(
      resource_name,
      diagnostic_report_date_parameter = diagnostic_report_date_parameter
    )
    if (is.null(date_search_parameters)) {
      next
    }
    resources_add_search_parameter[[resource_name]] <- c(
      resources_add_search_parameter[[resource_name]],
      date_search_parameters
    )
  }

  return(resources_add_search_parameter)
}

#' Load FHIR resources for a given set of patient IDs and create a table of ward-patient ID per date.
#'
#' This function takes a list of patient IDs per ward, extracts unique patient IDs,
#' loads FHIR resources for those patient IDs from the FHIR server using the provided
#' `TABLE_DESCRIPTION`, and creates an additional table of ward-patient ID per date. The
#' result is a list of data.tables, where each element contains FHIR resources for a specific
#' patient, and the last element is a table representing the ward and patient ID per date.
#'
#' @param pids_splitted_by_ward A list of patient IDs, where each element corresponds to a ward.
#' @param table_descriptions the fhircrackr table descriptions of the result tables
#' @return A list of data.tables, each containing FHIR resources for a specific patient,
#'   and the last element is a table representing the ward and patient ID per date.
#'
loadResourcesByPatientIDFromFHIRServer <- function(pids_splitted_by_ward, table_descriptions) {
  patient_ids <- unique(unlist(data.table::rbindlist(pids_splitted_by_ward, use.names = TRUE, fill = TRUE)[, .(patient_id)]))

  if (!isProcess("DataImport")) {
    # Load all encounters from the database which, according to the database, have not yet ended on the
    # ‘current’ date and determine the PIDs.
    # Background: We want to track all cases that have ever been on a relevant station until they are completed.
    patient_ids_db <- getActiveEncounterPIDsFromDB()

    if (!length(patient_ids_db)) {
      etlutils::catWarningMessage(paste(
        "No active patient IDs in encounter table found in database. \n",
        "HINT: This message appears if no active encounters were written to the database during",
        "the last run of the CDS tool chain. This should only happen if the CDS tool chain is",
        "running for the first time."
      ))
    }

    # Unify and unique all patient IDs
    patient_ids <- unique(c(patient_ids, patient_ids_db))
  }

  # This parameter should only be changed via DEBUG variables to set additional test filters for
  # the FHIR-search request.
  resources_add_search_parameter <- NA

  #########################
  # START: FOR DEBUG ONLY #
  #########################

  # Find additional test filters for the FHIR search request.
  resources_add_search_parameter <- debugSetResourcesAddSearchParameter(table_descriptions = table_descriptions)
  debug_resources_add_search_parameter <- resources_add_search_parameter

  #######################
  # END: FOR DEBUG ONLY #
  #######################

  if (etlutils::isSubProcess("DataImport.ResourceTypes")) {
    resources_add_search_parameter <- addDataImportFHIRDateSearchParameters(
      table_descriptions,
      resources_add_search_parameter
    )
  }

  # Get the date for every PID when the Patient resource was written to the database the last time
  getLastPatientUpdateDate <- function(patient_ids) {
    # Ensure these are IDs and not references
    patient_ids <- getAfterLastSlash(patient_ids)

    # Create the query for the last insert/update date for every ID
    query <- paste0(
      "SELECT pat_id, MAX(last_check_datetime) AS last_insert_datetime\n",
      "FROM v_patient\n",
      "WHERE pat_id = ANY($1::text[])\n",
      "GROUP BY pat_id;"
    )

    # Create the correct format for the Postgres Parameter Array
    params <- list(paste0("{", paste(patient_ids, collapse = ","), "}"))
    # Execute the SQL query to retrieve the data, passing the list of IDs as a single parameter
    result <- etlutils::dbGetReadOnlyQuery(query, params = params, lock_id = "getLastPatientUpdateDate()[1]")

    # Create an empty result vector with NAs for patient IDs not found in the database
    last_insert_dates <- etlutils::as.DateWithTimezone(rep(NA, length(patient_ids)))

    if (!etlutils::isDefinedAndTrue("DEBUG_IGNORE_LAST_UPDATE_DATE")) {
      # Map the retrieved data to the corresponding patient IDs
      for (i in seq_along(patient_ids)) {
        matching_row <- result[result$pat_id == patient_ids[i], ]
        if (nrow(matching_row)) { # Keep NA for IDs without a last_updated date and not -Inf
          last_insert_dates[i] <- etlutils::as.DateWithTimezone(max(matching_row$last_insert_datetime))
        }
      }
    }

    # Reduce the original date by at least 1 day to prevent time gaps
    last_insert_dates <- last_insert_dates - 1

    setNames(as.list(patient_ids), last_insert_dates)
  }

  # Get the date for every PID when the Patient resource was written to the database the last time.
  # In resource type data import mode, the Patient resource is intentionally not downloaded.
  if (etlutils::isSubProcess("DataImport.ResourceTypes")) {
    pids_with_last_updated <- setNames(as.list(patient_ids), rep(NA, length(patient_ids)))
  } else {
    pids_with_last_updated <- getLastPatientUpdateDate(patient_ids)
  }

  etlutils::catList(
    pids_with_last_updated,
    prefix = "Date for every PID when the Patient resource was written to the database the last time:\n",
    suffix = "\n",
    na_replacement = "Not present in DB"
  )

  # the parameter FHIR_SEARCH_PIDS_BY_SUBJECT decides if the patient IDs are
  # passed by subject or patient in the FHIR search request
  id_param_str <- ifelse(etlutils::isDefinedAndTrue("FHIR_SEARCH_PIDS_BY_SUBJECT"), "subject", "patient")

  # Load all data of relevant patients from FHIR server
  resource_tables_fhir <- etlutils::fhirsearchMultipleResourcesByPID(
    pids_with_last_updated,
    table_descriptions,
    id_param_str,
    resources_add_search_parameter
  )

  raw_fhir_resources <- resource_tables_fhir$raw_fhir_resources
  # The pids_with_last_updated now only contains persons who were older than MIN_PATIENT_AGE at
  # enc_period_start if the parameter MIN_PATIENT_AGE is specified.
  pids_with_last_updated <- resource_tables_fhir$pids_with_last_updated

  # THIS EXCEPTION MUST BE GENERALIZED OR REMOVED HERE! FHIR resource names should not be used here.
  if (
    etlutils::isSubProcess("DataImport.ResourceTypes") &&
    hasDataImportDateRange() &&
    "DiagnosticReport" %in% names(table_descriptions) &&
    (!("DiagnosticReport" %in% names(raw_fhir_resources)) || !nrow(raw_fhir_resources[["DiagnosticReport"]]))
  ) {
    catInfoMessage("Info: No DiagnosticReport resources found with date search parameter. Retrying with issued.\n")
    diagnostic_report_add_search_parameter <- addDataImportFHIRDateSearchParameters(
      table_descriptions["DiagnosticReport"],
      debug_resources_add_search_parameter,
      diagnostic_report_date_parameter = "issued"
    )
    diagnostic_report_tables_fhir <- etlutils::fhirsearchMultipleResourcesByPID(
      pids_with_last_updated,
      table_descriptions["DiagnosticReport"],
      id_param_str,
      diagnostic_report_add_search_parameter
    )
    raw_fhir_resources[["DiagnosticReport"]] <- diagnostic_report_tables_fhir$raw_fhir_resources[["DiagnosticReport"]]
  }

  valid_pids <- unlist(pids_with_last_updated, use.names = FALSE)
  # Iterate over each ward and filter the pids_splitted_by_ward based on valid_pids
  pids_splitted_by_ward <- lapply(pids_splitted_by_ward, function(dt) dt[patient_id %in% valid_pids])

  # Loop through each table name in the `raw_fhir_resources` list
  for (table_name in names(raw_fhir_resources)) {
    # Extract the column names from the corresponding entry in `table_descriptions`
    table_columns <- table_descriptions[[table_name]]@cols@names
    # Subset the columns of the current table in `raw_fhir_resources` to match the columns from `table_descriptions`
    raw_fhir_resources[[table_name]] <- raw_fhir_resources[[table_name]][, ..table_columns]
  }

  if (etlutils::isSubProcess("DataImport.All") || !isProcess("DataImport")) {
    # Add additional table of ward-patient ID per date
    raw_fhir_resources[["pids_per_ward"]] <- rbindPidsSplittedByWard(pids_splitted_by_ward)
  }

  return(raw_fhir_resources)
}

#' Get normalized referenced FHIR IDs
#'
#' @param ids A character vector of FHIR IDs or references.
#' @param sep Separator used for multi-value FHIR-crackr columns.
#'
#' @return A character vector of normalized FHIR IDs.
getNormalizedReferencedIDs <- function(ids, sep) {
  ids <- unique(na.omit(ids))
  if (!length(ids)) {
    return(character())
  }

  ids <- unlist(strsplit(ids, sep, fixed = TRUE), use.names = FALSE)
  ids <- etlutils::fhirdataRemoveIndices(getAfterLastSlash(ids))
  ids <- unique(ids[nchar(ids) > 0])
  return(ids)
}

#' Merge existing and newly loaded resource tables
#'
#' @param existing_resources Existing resource table or NULL.
#' @param new_resources Newly loaded resource table.
#'
#' @return A merged resource table without rows already present in the existing table.
mergeResourceTables <- function(existing_resources, new_resources) {
  if (is.null(existing_resources) || !nrow(existing_resources)) {
    return(new_resources)
  }
  if (!nrow(new_resources)) {
    return(existing_resources)
  }
  new_resources <- new_resources[!existing_resources, on = names(new_resources)]
  combined_resources <- rbind(existing_resources, new_resources)
  return(combined_resources)
}

#' Get table description rows that reference a resource type
#'
#' @param table_descriptions Grouped FHIR table descriptions.
#' @param reference_type FHIR resource type used as reference target.
#'
#' @return A data.table with reference rows for the given resource type.
getReferenceRowsForType <- function(table_descriptions, reference_type) {
  whole_word_pattern <- paste0("\\b", reference_type, "\\b")
  reference_rows <- table_descriptions$reference_types[
    grepl(whole_word_pattern, REFERENCE_TYPES)
  ]
  return(reference_rows)
}

#' Check whether referenced resource download is disabled by debug configuration
#'
#' @param reference_type FHIR resource type used as reference target.
#' @param resources_add_search_parameter Additional FHIR search parameters keyed by resource type.
#'
#' @return TRUE if the resource type has an empty debug search parameter.
shouldSkipReferencedResourceDownload <- function(reference_type, resources_add_search_parameter) {
  skip_download <- reference_type %in% names(resources_add_search_parameter) &&
    nchar(resources_add_search_parameter[[reference_type]]) == 0
  return(skip_download)
}

#' Load a referenced resource type by FHIR IDs
#'
#' @param table_descriptions Grouped FHIR table descriptions.
#' @param resource_tables Current resource table list.
#' @param reference_type FHIR resource type used as reference target.
#' @param referenced_ids FHIR IDs to load.
#' @param resources_add_search_parameter Additional FHIR search parameters keyed by resource type.
#'
#' @return An updated resource table list.
loadReferencedResourceByIDs <- function(table_descriptions,
                                        resource_tables,
                                        reference_type,
                                        referenced_ids,
                                        resources_add_search_parameter) {
  referenced_table_description <- table_descriptions$pid_independant[[reference_type]]
  if (!shouldSkipReferencedResourceDownload(reference_type, resources_add_search_parameter)) {
    new_resources <- etlutils::fhirsearchResourcesByOwnID(
      referenced_ids,
      referenced_table_description,
      additional_search_parameter = resources_add_search_parameter[[reference_type]]
    )
    existing_resources <- resource_tables[[reference_type]] %||% NULL
    resource_tables[[reference_type]] <- mergeResourceTables(existing_resources, new_resources)
  } else {
    resource_tables <- etlutils::fhirdataCreateResourceTable(
      referenced_table_description,
      resource_key = reference_type,
      resource_collection = resource_tables
    )
  }
  return(resource_tables)
}

#' Print the download result for a referenced resource type
#'
#' @param reference_type FHIR resource type used as reference target.
#' @param resource_tables Current resource table list.
#' @param resources_add_search_parameter Additional FHIR search parameters keyed by resource type.
#'
#' @return NULL, invisibly.
printReferencedResourceDownloadResult <- function(reference_type,
                                                  resource_tables,
                                                  resources_add_search_parameter) {
  if (!is.null(resource_tables[[reference_type]]) && nrow(resource_tables[[reference_type]])) {
    printAllTables(resource_tables[[reference_type]], reference_type)
  } else if (shouldSkipReferencedResourceDownload(reference_type, resources_add_search_parameter)) {
    catInfoMessage(paste(
      "Info: No",
      reference_type,
      "resources downloaded because DEBUG_ADD_FHIR_SEARCH_ for the given resource is empty.\n"
    ))
  } else {
    catInfoMessage(paste(
      "Info: No",
      reference_type,
      "resources found for the given reference IDs.\n"
    ))
  }
  return(invisible(NULL))
}

#' Load selected PID-independent data import resources from database references
#'
#' @param table_descriptions Grouped FHIR table descriptions.
#' @param resource_tables Current resource table list.
#'
#' @return An updated resource table list including selected referenced resources.
loadDataImportReferencedResourcesFromDB <- function(table_descriptions, resource_tables) {
  data_import_resource_types <- table_descriptions$data_import_pid_independant_resource_types %||%
    character()
  if (!length(data_import_resource_types)) {
    return(resource_tables)
  }

  getReferencedIDsFromDB <- function(reference_type, sep) {
    reference_rows <- getReferenceRowsForType(table_descriptions, reference_type)
    referenced_ids <- c()
    for (i in seq_len(nrow(reference_rows))) {
      resource_name <- reference_rows[i]$RESOURCE
      column_name <- reference_rows[i]$COLUMN_NAME
      query <- paste0(
        "SELECT DISTINCT ", column_name, " AS referenced_id\n",
        "FROM v_", tolower(resource_name), "_last_version\n",
        "WHERE ", column_name, " IS NOT NULL\n",
        "  AND ", column_name, " <> '';\n"
      )
      new_referenced_ids <- etlutils::dbGetReadOnlyQuery(
        query,
        lock_id = paste0("getReferencedIDsFromDB(", reference_type, ")")
      )
      referenced_ids <- c(referenced_ids, new_referenced_ids$referenced_id)
    }

    referenced_ids <- getNormalizedReferencedIDs(referenced_ids, sep)
    return(referenced_ids)
  }

  #########################
  # START: FOR DEBUG ONLY #
  #########################

  resources_add_search_parameter <- debugSetResourcesAddSearchParameter(
    table_descriptions = table_descriptions$pid_independant
  )

  #######################
  # END: FOR DEBUG ONLY #
  #######################

  for (reference_type in data_import_resource_types) {
    referenced_table_description <- table_descriptions$pid_independant[[reference_type]]
    referenced_ids <- getReferencedIDsFromDB(reference_type, referenced_table_description@sep)
    catInfoMessage(paste0(
      "Info: Found ",
      length(referenced_ids),
      " existing database reference ID",
      etlutils::getPluralSuffix(length(referenced_ids)),
      " for resource type ",
      reference_type,
      ".\n"
    ))
    resource_tables <- loadReferencedResourceByIDs(
      table_descriptions,
      resource_tables,
      reference_type,
      referenced_ids,
      resources_add_search_parameter
    )
    printReferencedResourceDownloadResult(
      reference_type,
      resource_tables,
      resources_add_search_parameter
    )
  }

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
loadReferencedResourcesByOwnIDFromFHIRServer <- function(table_descriptions, resource_tables) {
  # table_descriptions$REFERENCE_TYPES can be a comma or whitespace separated list like
  # "MedicationStatement, MedicationAdministration". We need the all unique different
  # resource names in this column
  reference_types <- unique(etlutils::extractWords(
    table_descriptions$reference_types$REFERENCE_TYPES
  ))
  reference_types <- reference_types[reference_types %in% names(table_descriptions$pid_independant)]

  getLoadedIDsByResource <- function() {
    loaded_ids_by_resource <- list()
    for (reference_type in reference_types) {
      resource_table <- resource_tables[[reference_type]]
      if (is.null(resource_table) || !nrow(resource_table)) {
        loaded_ids_by_resource[[reference_type]] <- character()
        next
      }
      id_column <- etlutils::fhirdbGetIDColumn(reference_type)
      if (!(id_column %in% names(resource_table))) {
        loaded_ids_by_resource[[reference_type]] <- character()
        next
      }
      referenced_table_description <- table_descriptions$pid_independant[[reference_type]]
      loaded_ids_by_resource[[reference_type]] <- getNormalizedReferencedIDs(
        resource_table[[id_column]],
        referenced_table_description@sep
      )
    }
    return(loaded_ids_by_resource)
  }

  getReferencedIDsByResource <- function() {
    referenced_ids_by_resource <- list()
    for (reference_type in reference_types) {
      referenced_table_description <- table_descriptions$pid_independant[[reference_type]]
      reference_rows <- getReferenceRowsForType(table_descriptions, reference_type)
      referenced_ids <- c()
      for (i in seq_len(nrow(reference_rows))) {
        resource_name <- reference_rows[i]$RESOURCE
        column_name <- reference_rows[i]$COLUMN_NAME
        resource_table <- resource_tables[[resource_name]]
        if (is.null(resource_table) || !(column_name %in% names(resource_table))) {
          next
        }
        referenced_ids <- c(referenced_ids, resource_table[[column_name]])
      }
      referenced_ids_by_resource[[reference_type]] <- getNormalizedReferencedIDs(
        referenced_ids,
        referenced_table_description@sep
      )
    }
    return(referenced_ids_by_resource)
  }

  getNewReferencedIDsByResource <- function(referenced_ids_by_resource,
                                            loaded_ids_by_resource,
                                            attempted_ids_by_resource) {
    new_ids_by_resource <- list()
    for (reference_type in names(referenced_ids_by_resource)) {
      known_ids <- unique(c(
        loaded_ids_by_resource[[reference_type]],
        attempted_ids_by_resource[[reference_type]]
      ))
      new_ids_by_resource[[reference_type]] <- setdiff(
        referenced_ids_by_resource[[reference_type]],
        known_ids
      )
    }
    return(new_ids_by_resource)
  }

  hasAnyIDs <- function(ids_by_resource) {
    any(lengths(ids_by_resource) > 0)
  }

  #########################
  # START: FOR DEBUG ONLY #
  #########################

  # Find the additional test filters for the FHIR-search request to set resources_add_search_parameter
  resources_add_search_parameter <- debugSetResourcesAddSearchParameter(
    table_descriptions = table_descriptions$pid_independant
  )

  #######################
  # END: FOR DEBUG ONLY #
  #######################

  attempted_ids_by_resource <- list()
  reference_download_iteration <- 0L
  repeat {
    referenced_ids_by_resource <- getReferencedIDsByResource()
    loaded_ids_by_resource <- getLoadedIDsByResource()
    new_ids_by_resource <- getNewReferencedIDsByResource(
      referenced_ids_by_resource,
      loaded_ids_by_resource,
      attempted_ids_by_resource
    )

    if (!hasAnyIDs(new_ids_by_resource)) {
      break
    }

    reference_download_iteration <- reference_download_iteration + 1L
    new_id_counts <- lengths(new_ids_by_resource)
    new_id_counts <- new_id_counts[new_id_counts > 0]
    catInfoMessage(paste0(
      "Info: Referenced resource download iteration ",
      reference_download_iteration,
      " found new IDs: ",
      paste(paste0(names(new_id_counts), "=", new_id_counts), collapse = ", "),
      ".\n"
    ))

    for (reference_type in names(new_ids_by_resource)) {
      referenced_ids <- new_ids_by_resource[[reference_type]]
      if (!length(referenced_ids)) {
        next
      }
      attempted_ids_by_resource[[reference_type]] <- unique(c(
        attempted_ids_by_resource[[reference_type]],
        referenced_ids
      ))

      resource_tables <- loadReferencedResourceByIDs(
        table_descriptions,
        resource_tables,
        reference_type,
        referenced_ids,
        resources_add_search_parameter
      )
      printReferencedResourceDownloadResult(reference_type, resource_tables, resources_add_search_parameter)
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
#' @param pids_splitted_by_ward A list of patient IDs, where each element corresponds to a ward and
#'   contains patient IDs associated with that ward.
#' @param table_descriptions A list containing two elements: `pid_dependant` and
#'   `pid_independant`, each of which describes table structures for resources that are dependent
#'   and independent of patient IDs, respectively.
#'
#' @details The function iterates through all resources loaded in both steps and saves them as
#'   RData files using `writeRData`. The filenames are derived by converting the names of the
#'   resources in the `resource_tables` list to lowercase.
#'
loadResourcesFromFHIRServer <- function(pids_splitted_by_ward, table_descriptions) {
  ### DEBUG START ###
  # Load Resources from RData files
  if (exists("DEBUG_PATH_TO_RAW_RDATA_FILES")) {
    resource_names <- c(names(table_descriptions$pid_dependant), names(table_descriptions$pid_independant))
    resource_tables <- list()
    for (res in resource_names) {
      file_path <- fhircrackr::paste_paths(DEBUG_PATH_TO_RAW_RDATA_FILES, paste0(tolower(res), "_raw.RData"))
      if (file.exists(file_path)) {
        resource_tables[[res]] <- readRDS(file_path)
      }
    }
    # Add additional table of ward-patient ID per date
    resource_tables[["pids_per_ward"]] <- rbindPidsSplittedByWard(pids_splitted_by_ward)
    ### DEBUG END ###
  } else {
    resource_tables <- loadResourcesByPatientIDFromFHIRServer(pids_splitted_by_ward, table_descriptions$pid_dependant)
    resource_tables <- loadDataImportReferencedResourcesFromDB(table_descriptions, resource_tables)
    resource_tables <- loadReferencedResourcesByOwnIDFromFHIRServer(table_descriptions, resource_tables)
  }

  # If there are no new patients in the pids_per_ward table, create an empty table with the correct columns.
  # Resource type data import reads PIDs from the patient table and must not write pids_per_ward.
  if ((etlutils::isSubProcess("DataImport.All") || !isProcess("DataImport")) && !nrow(resource_tables[["pids_per_ward"]])) {
    resource_tables[["pids_per_ward"]] <- data.table(
      patient_id = "EMPTY_DATA",
      encounter_id = "EMPTY_DATA",
      ward_name = NA_character_
    )
  }

  #########################
  # START: FOR DEBUG ONLY #
  #########################

  # This variable should be set to change the downloaded RAW data for DEBUG
  # purposes. It contains paths to scripts that is sourced at this point in the given order.
  if (etlutils::isDefinedAndNotEmpty("DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME")) {
    source(DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME, local = TRUE)
  }

  # Prefix of all global debug variables. One for each FHIR resources.
  global_debug_filter_variable_prefix <- "DEBUG_FILTER_"
  # Get global variables by prefix
  global_filter_variables <- etlutils::getGlobalVariablesByPrefix(global_debug_filter_variable_prefix, astype = "vector")
  if (length(global_filter_variables)) {
    resource_table_names <- names(resource_tables)
    resource_filter_patterns <- adjustNames(global_filter_variables, global_debug_filter_variable_prefix, resource_table_names)
    different_resources <- setdiff(names(resource_filter_patterns), resource_table_names)
    if (length(different_resources)) {
      catInfoMessage(paste0(
        "Note: The following debug filter resources are not in the resource table: ",
        paste(
          different_resources,
          collapse = ", "
        ),
        ". Fix it in cds2db_config.toml."
      ))
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
            invalid_indices_string <- paste0(
              paste0(
                invalid_indices[1:5],
                collapse = ", "
              ), " ... ",
              paste0(invalid_indices[(l - 5):l], collapse = ", ")
            )
          }
          etlutils::catWarningMessage(paste0(
            "Check '", debug_parameter_name, "': The following indices in debug filter are invalid for resource ",
            name, ". The table has only ", rows_count, " rows. Invalid indices: ",
            paste(invalid_indices_string, collapse = ", ")
          ))
        }
        valid_indices <- setdiff(indices, invalid_indices)
        # Update the resource table with valid indices
        resource_tables[[name]] <- resource_tables[[name]][valid_indices, ]
      }
    }
  }

  if (exists("DEBUG_RESOURCE_COUNT_OBSERVATION_RAW")) {
    required_obs_count <- as.numeric(DEBUG_RESOURCE_COUNT_OBSERVATION_RAW)

    if (nrow(resource_tables$Observation) == 0) {
      stop("There are no Observations to duplicate ", required_obs_count, " times!")
    }

    # Extend Observation Table
    #
    # This function ensures that a given observation table (`table_obs`) has exactly
    # `debug_resource_count` rows. If the table has fewer rows, it duplicates the rows
    # of the table to meet the required count. If the table has more rows, it truncates
    # it to the required size. Duplicated rows will have a modified `obs_id` to ensure
    # uniqueness by appending a `_DUP_` suffix with a unique number. Existing rows with
    # `_DUP_` in their `obs_id` are preserved and not further modified.
    #
    # @param table_obs A data.table containing observations with a column named `obs_id`.
    #                  The `obs_id` column is used as a unique identifier for each row.
    # @param debug_resource_count An integer specifying the required number of rows
    #                              in the output table.
    # @return A data.table with exactly `debug_resource_count` rows. Rows are either
    #         truncated or duplicated to meet the required count, and new rows are
    #         assigned unique `obs_id` values.
    #
    extendObservationTable <- function(table_obs, debug_resource_count) {
      # Calculate the number of rows needed
      original_rows <- nrow(table_obs)
      required_rows <- debug_resource_count
      if (original_rows == required_rows) {
        return(table_obs) # Return as-is if the row count matches
      }
      if (original_rows > required_rows) {
        return(table_obs[1:required_rows]) # Truncate superfluous rows
      }

      # Separate rows without and with `DUP` in their `obs_id`
      is_dup <- grepl("_DUP_\\d+$", table_obs$obs_id)
      original_table <- table_obs[!is_dup]  # Rows without DUP suffix
      dup_table <- table_obs[is_dup]       # Rows with DUP suffix

      # Determine the highest existing DUP number
      max_dup_number <- ifelse(
        nrow(dup_table) > 0,
        max(as.integer(gsub(".*_DUP_(
          \\d+)$", "\\1", dup_table$obs_id)), na.rm = TRUE),
        0
      )

      # Calculate full duplications and remaining rows needed
      original_rows <- nrow(original_table)
      num_full_copies <- (required_rows - original_rows) %/% original_rows
      remainder <- (required_rows - original_rows) %% original_rows

      # Duplicate rows from the original table to meet the required count
      duplication_indices <- rep(seq_len(original_rows), times = num_full_copies + 1)[1:(required_rows - original_rows)]
      duplicated_table <- original_table[duplication_indices]

      # Generate new unique `obs_id` values for duplicated rows
      duplicated_table[, obs_id := paste0(obs_id, "_DUP_", seq_len(.N) + max_dup_number)]

      # Combine the original table, existing DUP rows, and newly duplicated rows
      extended_table <- rbind(table_obs, duplicated_table)

      return(extended_table)
    }

    resource_tables$Observation <- extendObservationTable(resource_tables$Observation, required_obs_count)
  }


  #######################
  # END: FOR DEBUG ONLY #
  #######################

  for (i in seq_along(resource_tables)) {
    etlutils::writeDebugExcelFile(resource_tables[[i]], tolower(paste0(names(resource_tables)[i], "_raw")))
  }
  return(resource_tables)
}
