# Environment for saving resource data from DB
.resource_env <- new.env()

#' Compute SHA-256 hash of a processed file
#'
#' Reads a file, applies a given processing function to extract relevant content,
#' and computes a SHA-256 hash of the processed content.
#'
#' @param file_path A string specifying the path to the file.
#' @param processing_fn A function that processes the file and extracts the relevant content.
#'
#' @return A string containing the SHA-256 hash of the processed content.
#'
computeFileHash <- function(file_path, processing_fn) {
  processed_content <- processing_fn(file_path)
  content_hash <- digest::digest(processed_content, algo = "sha256")
  return(content_hash)
}

#' Load existing file hashes from a PostgreSQL database
#'
#' Queries a PostgreSQL database to retrieve the stored file hashes, which
#' are used to detect changes in file content across runs.
#'
#' @return A data frame with columns `file_name` (file identifier) and `content_hash` (SHA-256 hash).
#'
loadExistingHashes <- function() {
  # Construct the SQL query to retrieve existing file hashes
  query <- paste("SELECT file_name, content_hash FROM input_data_file_info")

  # Execute the query and fetch the results
  #existing_hashes <- etlutils::dbGetReadOnlyQuery(query, lock_id = "loadExistingHashes()")
  etlutils::readRData("input_data_file_info", load_from_last_run = TRUE)

  return(existing_hashes)
}

#' Compare file hashes and detect changes
#'
#' Compares the computed hashes of files against stored database hashes to determine
#' which files have changed or are new.
#'
#' @param files A character vector containing file paths.
#' @param db_hashes A data frame with columns `file_name` and `content_hash`,
#'   representing stored hashes from the database.
#' @param processing_fn A function that processes a file and extracts its relevant content.
#'
#' @return A list where each element corresponds to a file that has changed or is new.
#'   Each entry contains `file_name` and `content_hash`.
#'
compareAndDetectChanges <- function(files, db_hashes, processing_fn) {
  files_to_process <- list()

  for (file in files) {
    file_name <- basename(file)
    content_hash <- computeFileHash(file, processing_fn)
    existing_hash <- db_hashes$content_hash[db_hashes$file_name == file_name]

    if (length(existing_hash) == 0 || existing_hash != content_hash) {
      files_to_process[[file]] <- list(file_name = file_name, content_hash = content_hash)
    }
  }

  return(files_to_process)
}

#' Store updated file hashes in a PostgreSQL database
#'
#' Saves or updates the file hashes in a specified PostgreSQL table.
#' Only stores hashes for files that have changed or are new.
#'
#' @param files_to_process A list where each element contains `file_name` and `content_hash`
#'   for files that have changed or are new.
#'
storeHashesInDb <- function(files_to_process) {
  if (length(files_to_process) == 0) return()

  input_data_file_info <- do.call(rbind, lapply(files_to_process, function(x) {
    data.frame(file_name = x$file_name, content_hash = x$content_hash)
  }))

  #etlutils::dbWriteTable(input_data_file_info, lock_id = "storeHashesInDb()")
  etlutils::writeRData(input_data_file_info)

}

#' Process files and determine which need to be updated
#'
#' Searches for files with a given prefix in specified directories,
#' computes their hashes after applying a processing function, and
#' compares them to stored database hashes to detect changes.
#' If changes are detected, the new hashes are stored in the database.
#'
#' @param prefix A string specifying the prefix that the files must start with.
#' @param directories A character vector specifying the directories to search in.
#' @param db_conn A valid database connection object (from `DBI::dbConnect`).
#' @param table_name A string specifying the name of the table storing file hashes.
#' @param processing_fn A function that processes a file and extracts its relevant content.
#' @param extension A string specifying the file extension (e.g., `"xlsx"`, `"csv"`).
#' Can be `NA` or `""` to disable extension filtering.
#' @param recursive Logical, indicating whether to search directories recursively.
#' Default is `FALSE`.
#'
#' @return A list containing files that have changed or are new.
#'
processFiles <- function(prefix, directories, db_conn, table_name, processing_fn, extension = NA, recursive = FALSE) {
  files <- getFilesByPrefix(prefix, directories, extension, recursive)
  if (length(files) == 0) return(list())

  existing_hashes <- loadExistingHashes(db_conn, table_name)
  files_to_process <- compareAndDetectChanges(files, existing_hashes, processing_fn)
  storeHashesInDb(db_conn, table_name, files_to_process)

  return(files_to_process)
}

#' Load and Process an MRP Table
#'
#' This function loads a specified MRP (Medication-Related Problem) table from an Excel file
#' and, if available, an expanded preprocessed version from an RDS file. If the RDS file does not exist,
#' the function preprocesses the table using the corresponding preprocessing function.
#'
#' @param table_name A character string specifying the name of the MRP table to load
#'   (e.g., `"Drug-Disease"`, `"Drug-Interaction"`).
#' @param paths_to_mrp_tables A character string specifying the directory where the MRP Excel files are stored.
#'   Default is `"./Input-Repo"`.
#'
#' @return A `data.table` containing the processed MRP table.
#'
#' @details
#' The function first attempts to load the preprocessed MRP table from an RDS file.
#' If the RDS file does not exist, it reads the table from an Excel file and preprocesses it
#' using a dynamically determined function (`cleanAndExpandDefinition_<table_name>`).
#'
loadMRPTables <- function(table_name, paths_to_mrp_tables = "") {

  mrp_tables <- list()
  for (path in paths_to_mrp_tables) {
    # Path to expanded MRP table
    expanded_table_path <- file.path(path, paste0(table_name, "_MRP_Table_Expanded.RData"))

    # Load MRP Definition from Excel
    mrp_definition <- etlutils::readFirstExcelFileAsTableList(path, table_name)

    # Check if the RDS file exists and load it, otherwise preprocess the data
    if (file.exists(expanded_table_path)) {
      mrp_table <- readRDS(expanded_table_path)
    } else {
      message("Preprocessing ", table_name, " table...")
      preprocess_function_name <- paste0("cleanAndExpandDefinition_", gsub("-", "", table_name))

      if (!exists(preprocess_function_name, mode = "function", inherits = TRUE)) {
        stop("Preprocessing function '", preprocess_function_name, "' not found!")
      }

      preprocess_function <- get(preprocess_function_name, mode = "function", inherits = TRUE)
      mrp_table <- preprocess_function(mrp_definition[[paste0(table_name, "-Pairs")]])
    }

    # Store the processed table in the result list
    mrp_tables[[path]] <- mrp_table
  }

  return(mrp_tables)
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
#' \dontrun{
#' df <- data.frame(LOINC_VALIDITY_DAYS = c(30, 60, NA, 90))
#' query_datetime <- as.POSIXct("2024-01-01 12:00:00")
#' calculateObservationDatetime(df, "LOINC_VALIDITY_DAYS", query_datetime, 45)
#' }
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
  if (!force_reload && exists("pids_per_ward", envir = .resource_env)) {
    message("Returning cached PIDs.")
    return(.resource_env$pids_per_ward)
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
  .resource_env[["pids_per_ward"]] <- patient_ids
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
#'
loadEncounters <- function(patient_ids, query_datetime, force_reload = FALSE, apply_class_filter = FALSE) {
  # Check if encounters exist in the environment and if the patient IDs match
  if (!force_reload && exists("encounters", envir = .resource_env) &&
      exists("encounters_pids", envir = .resource_env) &&
      identical(.resource_env$encounters_pids, patient_ids) &&
      identical(.resource_env$query_datetime, query_datetime)) {
    message("Returning cached encounters.")
    return(.resource_env$encounters)
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
  .resource_env[["encounters"]] <- encounters
  .resource_env[["encounters_pids"]] <- patient_ids  # Store patient IDs for comparison

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
#'
loadResourcesFromDB <- function(resource_name, column_name, query_ids, force_reload = FALSE, remove_ref_type = FALSE, additional_query_parameter = NULL, lock_id = "loadResourcesFromDB()") {
  # Dynamic key for saved Query-IDs
  query_ids_key <- paste0(resource_name, "_query_ids")

  # Check if the resource is already loaded and query_ids match
  if (!force_reload && exists(resource_name, envir = .resource_env) &&
      exists(query_ids_key, envir = .resource_env) &&
      identical(.resource_env$query_ids_key, query_ids)) {
    message("Returning cached ", resource_name, " .")
    return(.resource_env$resource_name)
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
  assign(resource_name, result, envir = .resource_env)
  assign(query_ids_key, query_ids, envir = .resource_env)  # Store query_ids under specific key

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

#' Create an Empty Data Table Based on a Database Mapping
#'
#' This function generates an empty `data.table` with the correct column names and R data types,
#' based on a database schema mapping provided in `mapping_table`. The function automatically
#' assigns the generated table to the global environment.
#'
#' @param mapping_table A `data.table` or `data.frame` containing the database schema mapping.
#' It must have the following columns:
#'   - `TABLE_NAME` (character): The name of the table (should contain only one unique value).
#'   - `COLUMN_NAME` (character): The names of the columns.
#'   - `COLUMN_TYPE` (character): The corresponding database column types (e.g., "int", "varchar").
#'
#' @return A `data.table` with the correct column names and R data types. Each column is initialized
#' with `NA` values of the appropriate R type.
#'
#' @details
#' - The function ensures that `TABLE_NAME` contains only a single unique value.
#' - It retrieves the appropriate R data type using `etlutils::dbGetRType()`, which converts
#'   database types to their corresponding R types.
#' - The resulting table is created as a `data.table` and is automatically assigned to the global environment
#'   using the extracted `TABLE_NAME` as its variable name.
#'
#' @examples
#' \dontrun{
#' # Example database mapping table
#' mapping_table <- data.table::data.table(
#'   TABLE_NAME = rep("my_table", 3),
#'   COLUMN_NAME = c("id", "name", "created_at"),
#'   COLUMN_TYPE = c("int", "varchar", "timestamp")
#' )
#'
#' # Create the empty table
#' result <- createEmptyTable(mapping_table)
#' print(result)
#' }
#'
createEmptyTable <- function(mapping_table) {
  # Extract the desired table name from TABLE_NAME
  table_name <- unique(mapping_table$TABLE_NAME)

  # Ensure that TABLE_NAME contains only a single unique value
  if (length(table_name) != 1) {
    stop("The TABLE_NAME column should contain only one unique value!")
  }

  # Extract column names from COLUMN_NAME
  column_names <- mapping_table$COLUMN_NAME

  # Initialize columns with correct data types
  columns <- setNames(vector("list", length(column_names)), column_names)

  for (i in seq_along(column_names)) {
    col_type <- mapping_table$COLUMN_TYPE[i]

    # Use dbGetRType() to get the correct NA value of the corresponding R type
    columns[[i]] <- etlutils::dbGetRType(col_type)
  }

  # Convert to a data.table with one row (all values NA but correct types)
  result_table <- data.table::as.data.table(columns)

  # Assign the table to the global environment with the correct table name
  assign(table_name, result_table, envir = .GlobalEnv)

  return(result_table)
}
