# Environment for saving resource data from DB
get_resources_env <- new.env()

#' Load and Process an MRP Table
#'
#' This function loads a specified MRP (Medication-Related Problem) table from an Excel file
#' and, if available, an expanded preprocessed version from an RDS file. If the RDS file does not exist,
#' the function preprocesses the table using the corresponding preprocessing function.
#'
#' @param table_name A character string specifying the name of the MRP table to load
#'   (e.g., `"Drug-Disease"`, `"Drug-Interaction"`).
#' @param path_to_mrp_tables A character string specifying the directory where the MRP Excel files are stored.
#'   Default is `"./Input-Repo"`.
#' @param path_to_expanded_mrp_table A character string specifying the path to the preprocessed RDS file.
#'   If `NULL`, the function constructs the path automatically using `table_name`. Default is `NULL`.
#'
#' @return A `data.table` containing the processed MRP table.
#'
#' @details
#' The function first attempts to load the preprocessed MRP table from an RDS file.
#' If the RDS file does not exist, it reads the table from an Excel file and preprocesses it
#' using a dynamically determined function (`cleanAndExpandDefinition_<table_name>`).
#'
#' @examples
#' # Load the Drug-Disease MRP table
#' drug_disease_mrp_table <- loadMRPTable("Drug-Disease")
#'
#' # Load another MRP table, e.g., Drug-Interaction
#' drug_interaction_mrp_table <- loadMRPTable("Drug-Interaction")
#'
loadMRPTable <- function(table_name, path_to_mrp_tables = "./Input-Repo") {
  # Path to expanded MRP table
  path_to_expanded_mrp_table <- file.path(path_to_mrp_tables, paste0(table_name, "_MRP_Table_Expanded.RData"))

  # Load MRP Definition
  mrp_definition <- etlutils::readFirstExcelFileAsTableList(path_to_mrp_tables, table_name)

  # Check if the RDS file exists and load it, otherwise preprocess the data
  if (file.exists(path_to_expanded_mrp_table)) {
    mrp_table <- readRDS(path_to_expanded_mrp_table)
  } else {
    message("Preprocessing ", table_name, " table...")
    preprocess_function <- get(paste0("cleanAndExpandDefinition", gsub("-", "", table_name)), mode = "function", inherits = TRUE)
    mrp_table <- preprocess_function(mrp_definition[[paste0(table_name, "-Pairs")]])
  }

  return(mrp_table)
}

#' Calculates the valid observation datetime based on the maximum LOINC validity period.
#'
#' This function determines the valid observation datetime by calculating the maximum number
#' of validity days (`LOINC_VALIDITY_DAYS`) from a given table and subtracting it from a specified
#' timestamp (`query_datetime`).
#'
#' @param data_table A `data.table` or `data.frame` containing a column with validity periods.
#' @param column_name A `character` string specifying the name of the column that contains validity periods.
#'   Default: `"LOINC_VALIDITY_DAYS"`.
#' @param query_datetime A `POSIXct` timestamp from which the maximum validity period will be subtracted.
#' @param default_loinc_validity_days An `integer` specifying the default validity period to be used
#'   for missing values in the validity column.
#'
#' @return A `character` string in the format `"%Y-%m-%d %H:%M:%S"`, representing the calculated
#'   valid observation datetime.
#'
#' @details
#' The function replaces missing values in the specified column with `default_loinc_validity_days`.
#' It then determines the maximum validity period and subtracts it from `query_datetime` to compute
#' the earliest valid observation datetime.
#'
#' @examples
#' df <- data.frame(LOINC_VALIDITY_DAYS = c(30, 60, NA, 90))
#' query_datetime <- as.POSIXct("2024-01-01 12:00:00")
#' calculateObservationDatetime(df, "LOINC_VALIDITY_DAYS", query_datetime, 45)
#'
calculateObservationDatetime <- function(data_table, column_name = "LOINC_VALIDITY_DAYS", query_datetime, default_loinc_validity_days) {
  # Fill missing values in the specified column with the default value
  data_table[[column_name]] <- ifelse(
    is.na(data_table[[column_name]]),
    default_loinc_validity_days,
    data_table[[column_name]]
  )

  # Find max value in the specified column
  max_loinc_validity_days <- max(data_table[[column_name]], na.rm = TRUE)
  # Calculate valid observation datetime
  observation_datetime <- lubridate::ymd_hms(query_datetime) - lubridate::days(as.integer(max_loinc_validity_days))

  return(format(observation_datetime, "%Y-%m-%d %H:%M:%S"))
}

# This function constructs an error or warning message with optional additional
# information such as related tables and database connection details. It can be
# used to provide more context when reporting errors or warnings.
getErrorOrWarningMessage <- function(text, tables = NA, readonly = TRUE) {
  tables <- if (!etlutils::isSimpleNA(tables)) paste0(" Table(s): ", paste0(tables, collapse = ", "), ";") else ""
  db_connection <- if (!etlutils::isSimpleNA(readonly)) etlutils::dbGetInfo(readonly) else ""
  text <- paste0(text, tables, db_connection)
  return(text)
}

#' Get Patient IDs (PIDs) from the PIDs per Ward Table with Caching
#'
#' This function retrieves the most recently imported dataset from the
#' "pids_per_ward" table in the database. It filters out rows with missing
#' patient IDs and ensures the table is not empty. If the data has already
#' been loaded, the function returns the cached version unless
#' `force_reload = TRUE` is specified.
#'
#' @param force_reload Logical. If `TRUE`, forces a reload of the data from
#'        the database. Default is `FALSE`, which returns the cached version
#'        if available.
#'
#' @return A `data.table` containing the non-empty rows from the "pids_per_ward" table,
#'         where `patient_id` is not missing.
#'
getPIDs <- function(force_reload = FALSE) {
  # Check if PIDs have already been loaded and force_reload is not TRUE
  if (!force_reload && exists("pids_per_ward", envir = get_resources_env)) {
    message("Returning cached PIDs.")
    return(get_resources_env$pids_per_ward)
  }
  # Load pids_per_ward
  pids_per_ward_table_name <- etlutils::getViewTableName("pids_per_ward")
  pids_per_ward <- etlutils::loadLastImportedDatasetsFromDB(pids_per_ward_table_name)
  pids_per_ward <- pids_per_ward[!is.na(patient_id)]
  # Check if the table is empty
  if (!nrow(pids_per_ward)) {
    message <- getErrorOrWarningMessage(
      text = "WARNING: The pids_per_ward table is empty.\n",
      tables = "pids_per_ward")
    stop(message)
  }
  patient_ids <- unique(pids_per_ward$patient_id)
  # Store the loaded data in the environment
  get_resources_env$pids_per_ward <- patient_ids
  return(patient_ids)
}

#' Load Encounters for All PIDs with Caching and Optional Class Filtering
#'
#' This function retrieves encounters from the database for a given list of patient IDs.
#' It filters encounters based on their start and end dates relative to the provided query datetime.
#' If the data has already been loaded, the function returns the cached version unless
#' `force_reload = TRUE` is specified. The filtering by encounter class can be optionally applied.
#'
#' @param patient_ids A string vector containing patient_ids.
#' @param query_datetime A timestamp specifying the query time, typically retrieved using
#'        `etlutils::getQueryDatetime()`.
#' @param force_reload Logical. If `TRUE`, forces a reload of the data from
#'        the database. Default is `FALSE`, which returns the cached version
#'        if available.
#' @param apply_class_filter Logical. If `TRUE`, applies a filter for encounter class codes
#'        if `FRONTEND_DISPLAYED_ENCOUNTER_CLASS` exists and is not empty. Default is `FALSE`.
#'
#' @return A `data.table` containing the encounters that match the specified criteria.
#' @export
loadEncounters <- function(patient_ids, query_datetime, force_reload = FALSE, apply_class_filter = FALSE) {
  # Check if encounters exist in the environment and if the patient IDs match
  if (!force_reload && exists("encounters", envir = get_resources_env) &&
      exists("encounters_pids", envir = get_resources_env) &&
      identical(get_resources_env$encounters_pids, patient_ids)) {
      identical(.resource_env$query_datetime, query_datetime)) {
    message("Returning cached encounters.")
    return(get_resources_env$encounters)
  }

  # Get formatted patient IDs for SQL query
  query_ids <- etlutils::getQueryList(patient_ids)
  # Get encounter table name
  table_name <- etlutils::getViewTableName("encounter")
  # Construct base SQL query
  query <- paste0(
    "SELECT * FROM ", table_name, "\n",
    "  WHERE enc_patient_ref IN (", query_ids, ")\n",
    "    AND (enc_period_end IS NULL OR enc_period_end > '", query_datetime, "')\n",
    "    AND enc_period_start <= '", query_datetime, "'"
  )

  # Apply encounter class filtering if applicable and enabled
  if (apply_class_filter && exists("FRONTEND_DISPLAYED_ENCOUNTER_CLASS")) {
    enc_class_codes <- FRONTEND_DISPLAYED_ENCOUNTER_CLASS
    if (enc_class_codes != "") {
      additional_class_code_condition <- paste0(
        " AND enc_class_code IN ('", paste(enc_class_codes, collapse = "', '"), "')"
      )
      query <- paste0(query, additional_class_code_condition)
    }
  }

  # Execute query and retrieve encounters
  encounters <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[1]")

  # Store the loaded data and patient IDs in the environment
  get_resources_env$encounters <- encounters
  get_resources_env$encounters_pids <- patient_ids  # Store patient IDs for comparison

  return(encounters)
}

#' Load Resources from the Database with Caching
#'
#' This function retrieves data from the database for a specified resource type,
#' filtering by a given column and a list of query IDs. The results are cached
#' in an environment to avoid redundant database queries, unless `force_reload`
#' is set to `TRUE`.
#'
#' @param resource_name A character string specifying the name of the resource to load
#'   (e.g., `"MedicationRequest"`, `"Observation"`).
#' @param column_name A character string specifying the column used for filtering
#'   (e.g., `"medstat_encounter_ref"`, `"obs_patient_ref"`).
#' @param query_ids A vector of query IDs used for filtering the resource.
#' @param force_reload A logical value indicating whether to force reloading data
#'   from the database even if cached data is available. Default is `FALSE`.
#' @param remove_ref_type A logical value indicating whether to remove reference prefixes
#'   (e.g., `"Encounter/"`) from `query_ids`. Default is `FALSE`.
#' @param additional_query_parameter An optional SQL condition (as a character string)
#'   that can be appended to the `WHERE` clause for further filtering. Default is `NULL`.
#' @param lock_id A character string used as an identifier for the database query lock.
#'   Default is `"loadResourcesFromDB()"`.
#'
#' @return A `data.table` containing the queried resource data.
loadResourcesFromDB <- function(resource_name, column_name, query_ids, force_reload = FALSE, remove_ref_type = FALSE, additional_query_parameter = NULL, lock_id = "loadResourcesFromDB()") {
  # Dynamic key for saved Query-IDs
  query_ids_key <- paste0(resource_name, "_query_ids")

  # Check if the resource is already loaded and query_ids match
  if (!force_reload && exists(resource_name, envir = get_resources_env) &&
      exists(query_ids_key, envir = get_resources_env) &&
      identical(get_resources_env$query_ids_key, query_ids)) {
    message("Returning cached ", resource_name, " .")
    return(get_resources_env$resource_name)
  }

  query_ids_sql <- etlutils::getQueryList(query_ids, remove_ref_type = remove_ref_type)
  table_name <- etlutils::getViewTableName(resource_name)
  query <- paste0(
    "SELECT * FROM ", table_name, "\n",
    "  WHERE ", column_name, " IN (", query_ids_sql, ")\n"
  )
  # Append extra conditions if provided
  if (!is.null(additional_query_parameter) && additional_query_parameter != "") {
    query <- paste0(query, " AND (", additional_query_parameter, ")")
  }
  result <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)

  # Store result and corresponding query_ids in the environment
  assign(resource_name, result, envir = get_resources_env)
  assign(query_ids_key, query_ids, envir = get_resources_env)  # Store query_ids under specific key

  return(result)
}

#' Set the Query Datetime in the Resource Environment
#'
#' This function retrieves the current query datetime using `etlutils::getQueryDatetime()`
#' and stores it in the `.resource_env` environment under the variable `query_datetime`.
#'
#' @details
#' The function ensures that the query datetime is available globally within the
#' `.resource_env` environment, allowing other functions to access it without
#' needing to repeatedly fetch it.
#'
#' @return This function does not return a value. It assigns `query_datetime` in `.resource_env`.
#'
setQueryDatetime <- function() {
  assign("query_datetime", etlutils::getQueryDatetime(), envir = .resource_env)
}

#' Retrieve the Query Datetime from the Resource Environment
#'
#' This function fetches the stored `query_datetime` value from the `.resource_env`
#' environment. The datetime must have been previously set using `setQueryDatetime()`.
#'
#' @return The stored query datetime.
#'
getQueryDatetime <- function() {
  get("query_datetime", envir = .resource_env)
}
