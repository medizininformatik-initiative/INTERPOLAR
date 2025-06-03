# Environment for saving resource data from DB
.resource_env <- new.env()

MRP_TABLE_COLUMN_NAMES <- list(
  "Drug-Disease" = etlutils::namedListByValue("SMPC_NAME",
                                              "SMPC_VERSION",
                                              "ATC_DISPLAY",
                                              "ATC_PRIMARY",
                                              "ATC_SYSTEMIC_SY",
                                              "ATC_DERMATIC_D",
                                              "ATC_OPHTHALMOLOGIC_OP",
                                              "ATC_INHALATIVE_I",
                                              "ATC_OTHER_OT",
                                              "ATC_INCLUSION",
                                              "CONDITION_DISPLAY",
                                              "CONDITION_DISPLAY_CLUSTER",
                                              "ICD",
                                              "ICD_VALIDITY_DAYS",
                                              "ICD_PROXY_ATC",
                                              "ICD_PROXY_ATC_VALIDITY_DAYS",
                                              "ICD_PROXY_OPS",
                                              "ICD_PROXY_OPS_VALIDITY_DAYS",
                                              "LOINC_PRIMARY_PROXY",
                                              "LOINC_UNIT",
                                              "LOINC_DISPLAY",
                                              "LOINC_VALIDITY_DAYS",
                                              "LOINC_CUTOFF_REFERENCE",
                                              "LOINC_CUTOFF_ABSOLUTE")

)

#' Validate ATC Codes in Multiple Columns
#'
#' This function checks whether the values in specified columns of a data table
#' are valid ATC7 codes and issues warnings for any invalid values.
#'
#' @param data A data table containing the columns to validate.
#' @param columns A character vector specifying the column names to check for ATC7 validity.
#'
#' @details The function filters out \code{NA} values and validates each value in the specified
#' columns using \code{etlutils::isATC7}. If invalid ATC7 codes are found, a warning is issued
#' for each column.
#'
#' @return This function does not return any value. It issues warnings for invalid codes.
#'
#' @examples
#' library(data.table)
#' drug_disease_mrp_definition <- data.table(
#'   ATC = c("A01AB07", "INVALID", NA),
#'   ATC_PROXY = c(NA, "WRONG", "B03AA02")
#' )
#' validateATCCodes(drug_disease_mrp_definition, c("ATC", "ATC_PROXY"))
#'
#' @export
validateATCCodes <- function(data, columns) {
  errors <- list()
  for (column in columns) {
    invalid_codes <- data[[column]][!etlutils::isATC7orSmaller(data[[column]]) & !is.na(data[[column]])]
    if (length(invalid_codes) > 0) {
      errors[[column]] <- invalid_codes
    }
  }
  return(errors)
}

#' Validate LOINC Codes in a Column
#'
#' This function validates whether all non-NA values in a specified column of a data table
#' conform to the standard LOINC format.
#'
#' @param data A data.table containing the column to validate.
#' @param column_name The name of the column to check for valid LOINC codes.
#'
#' @details A valid LOINC code matches the pattern `^\d{1,5}-\d$`:
#' - 1 to 5 digits
#' - Followed by a hyphen (`-`)
#' - Ending with exactly 1 digit.
#'
#' If invalid codes are found, the function will issue a warning with the invalid codes.
#'
#' @return The function does not return any value but will issue a warning
#' if invalid LOINC codes are found in the column.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   LOINC = c("12345-6", "67890-1", "INVALID", NA, "12321", "21312123-1")
#' )
#' validateLOINCCodes(dt, "LOINC")
#' # Warning: The following codes in column 'LOINC' are not valid LOINC codes: INVALID
#'
#' @export
validateLOINCCodes <- function(data, column_name) {
  column_values <- data[[column_name]]
  invalid_codes <- column_values[!etlutils::isLOINC(column_values) & !is.na(column_values)]
  if (length(invalid_codes) > 0) {
    return(setNames(list(invalid_codes), column_name))
  } else {
    return(list())
  }
}

#' Get Processed and Expanded MRP Definition Table
#'
#' This function loads a specific MRP (Medication-Related Problem) definition from an Excel file,
#' computes its content hash, and either returns a cached, already-processed version or processes
#' it using a dynamic cleaning/expansion function. The result is cached for future use.
#'
#' @param table_name A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#' @param path_to_mrp_tables A character string specifying the path to the directory containing the MRP Excel files.
#'
#' @return A data.table containing the processed and expanded MRP definition.
#'
getExpandedContent <- function(table_name, path_to_mrp_tables) {
  # Load the MRP definition from the Excel file
  mrp_columnnames <- MRP_TABLE_COLUMN_NAMES[[table_name]]
  mrp_definition <- etlutils::readFirstExcelFileSheet(path_to_mrp_tables, table_name, mrp_columnnames)
  if (is.null(mrp_definition)) {
    stop(paste0("No or empty ", table_name, " MRP definition table found in the specified path."))
  }
  # Compute the hash of the current MRP definition
  content_hash <- digest::digest(mrp_definition$excel_file_content, algo = "sha256")
  file_name <- mrp_definition$excel_file_name
  content <- mrp_definition$excel_file_content
  processed_content_hash <- getStoredProcessedContentHash(content_hash)

  if (is.null(processed_content_hash)) {
    # If the hash is not found, process the MRP definition
    preprocess_function_name <- paste0("cleanAndExpandDefinition", gsub("-", "", table_name))
    preprocess_function <- get(preprocess_function_name, mode = "function", inherits = TRUE)
    processed_content <- preprocess_function(mrp_definition$excel_file_content)
    processed_content_hash <- digest::digest(processed_content, algo = "sha256")

    # Write content and processed content to Excel files
    openxlsx::write.xlsx(content, file = file.path(path_to_mrp_tables, paste0(table_name, "_MRP_Table.xlsx")), overwrite = TRUE)
    openxlsx::write.xlsx(processed_content, file = file.path(path_to_mrp_tables, paste0(table_name, "_MRP_Table_processed.xlsx")), overwrite = TRUE)

    ################START: Replace with database functionality###################
    # Load or init storage tables
    #TODO: Replace with database functionality
    input_data_files <- readRDS("./Input-Repo/MRP_Drug_Disease/input_data_files.RData")
    input_data_files_processed_content <- readRDS("./Input-Repo/MRP_Drug_Disease/input_data_files_processed_content.RData")

    # Convert content and processed_content to base64-encoded serialized data
    content <- base64enc::base64encode(serialize(content, NULL))
    processed_content <- base64enc::base64encode(serialize(processed_content, NULL))

    new_input_data_file_row <- data.table::data.table(
      file_name = file_name,
      content_hash = content_hash,
      content = content,
      processed_content_hash = processed_content_hash
    )
    input_data_files <- rbind(
      input_data_files,
      new_input_data_file_row,
      use.names = TRUE,
      fill = TRUE
    )
    new_input_data_file_processed_content_row <- data.table::data.table(
      processed_content_hash = processed_content_hash,
      processed_content = processed_content
    )
    input_data_files_processed_content <- rbind(
      input_data_files_processed_content,
      new_input_data_file_processed_content_row,
      use.names = TRUE,
      fill = TRUE
    )

    # Save the updated data frames back to the RData file
    saveRDS(input_data_files, "./Input-Repo/MRP_Drug_Disease/input_data_files.RData")
    saveRDS(input_data_files_processed_content, "./Input-Repo/MRP_Drug_Disease/input_data_files_processed_content.RData")
    ################END: Replace with database functionality###################
  } else {
    # Load processed content
    #TODO: Replace with database functionality
    input_data_files_processed_content <- readRDS("./Input-Repo/MRP_Drug_Disease/input_data_files_processed_content.RData")
    matching_row <- input_data_files_processed_content[processed_content_hash == get("processed_content_hash")]
    processed_content <- unserialize(base64enc::base64decode(matching_row$processed_content))
  }
  # Return the processed content
  return(processed_content)
}

#' Retrieve Stored Processed Content Hash from Input Data File Table
#'
#' This function loads the input data file metadata table and returns the
#' corresponding `processed_content_hash` for a given `content_hash`, if available.
#'
#' @param content_hash A character string representing the content hash to look up.
#'
#' @return A character string containing the processed content hash if found; otherwise `NULL`.
#'
getStoredProcessedContentHash <- function(content_hash) {
  input_data_files <- readRDS("./Input-Repo/MRP_Drug_Disease/input_data_files.RData")
  matching_row <- input_data_files[content_hash == get("content_hash")]
  if (nrow(matching_row)) {
    return(matching_row$processed_content_hash)
  }
  return(NULL)
}

#' #' Calculates the valid observation datetime based on the maximum LOINC validity period
#' #'
#' #' This function determines the valid observation datetime by calculating the maximum number
#' #' of validity days (`LOINC_VALIDITY_DAYS`) from a given table and subtracting it from a specified
#' #' timestamp (`query_datetime`).
#' #'
#' #' @param data_table A `data.table` or `data.frame` containing a column with validity periods.
#' #' @param column_name A `character` string specifying the name of the column that contains validity periods.
#' #'   Default: `"LOINC_VALIDITY_DAYS"`.
#' #' @param query_datetime A `POSIXct` timestamp from which the maximum validity period will be subtracted.
#' #' @param default_loinc_validity_days An `integer` specifying the default validity period to be used
#' #'   for missing values in the validity column.
#' #'
#' #' @return A `character` string in the format `"%Y-%m-%d %H:%M:%S"`, representing the calculated
#' #'   valid observation datetime.
#' #'
#' calculateObservationDatetime <- function(data_table, column_name = "LOINC_VALIDITY_DAYS", query_datetime, default_loinc_validity_days) {
#'   # Fill missing values in the specified column with the default value
#'   data_table[is.na(get(column_name)), (column_name) := default_loinc_validity_days]
#'   # Find max value in the specified column
#'   max_loinc_validity_days <- as.integer(max(data_table[[column_name]], na.rm = TRUE))
#'   # Calculate valid observation datetime
#'   observation_datetime <- lubridate::ymd_hms(query_datetime) - lubridate::days(max_loinc_validity_days)
#'   return(format(observation_datetime, "%Y-%m-%d %H:%M:%S"))
#' }

#' #' Get Patient IDs (PIDs) from the PIDs per Ward Table with Caching
#' #'
#' #' This function retrieves the most recently imported dataset from the
#' #' "pids_per_ward" table in the database. It filters out rows with missing
#' #' patient IDs and ensures the table is not empty. If the data has already
#' #' been loaded, the function returns the cached version unless
#' #' `force_reload = TRUE` is specified.
#' #'
#' #' @param force_reload Logical. If `TRUE`, forces a reload of the data from
#' #'        the database. Default is `FALSE`, which returns the cached version
#' #'        if available.
#' #'
#' #' @return A `data.table` containing the non-empty rows from the "pids_per_ward" table,
#' #'         where `patient_id` is not missing.
#' #'
#' getPIDs <- function(force_reload = FALSE) {
#'   # Check if PIDs have already been loaded and force_reload is not TRUE
#'   if (!force_reload && exists("pids_per_ward", envir = .resource_env)) {
#'     message("Returning cached PIDs.")
#'     return(.resource_env$pids_per_ward)
#'   }
#'   # Load pids_per_ward
#'   pids_per_ward_table_name <- etlutils::getViewTableName("pids_per_ward")
#'   pids_per_ward <- etlutils::loadLastImportedDatasetsFromDB(pids_per_ward_table_name)
#'   pids_per_ward <- pids_per_ward[!is.na(patient_id)]
#'   # Check if the table is empty
#'   if (!nrow(pids_per_ward)) {
#'     message <- getErrorOrWarningMessage(
#'       text = "WARNING: The pids_per_ward table is empty.\n",
#'       tables = "pids_per_ward")
#'     stop(message)
#'   }
#'   patient_ids <- unique(pids_per_ward$patient_id)
#'   # Store the loaded data in the environment
#'   .resource_env[["pids_per_ward"]] <- patient_ids
#'   return(patient_ids)
#' }

#' #' Load Encounters for All PIDs with Caching and Optional Class Filtering
#' #'
#' #' This function retrieves encounters from the database for a given list of patient IDs.
#' #' It filters encounters based on their start and end dates relative to the provided query datetime.
#' #' If the data has already been loaded, the function returns the cached version unless
#' #' `force_reload = TRUE` is specified. The filtering by encounter class can be optionally applied.
#' #'
#' #' @param patient_ids A string vector containing patient_ids.
#' #' @param query_datetime A timestamp specifying the query time, typically retrieved using
#' #'        `etlutils::getQueryDatetime()`.
#' #' @param force_reload Logical. If `TRUE`, forces a reload of the data from
#' #'        the database. Default is `FALSE`, which returns the cached version
#' #'        if available.
#' #' @param apply_class_filter Logical. If `TRUE`, applies a filter for encounter class codes
#' #'        if `FRONTEND_DISPLAYED_ENCOUNTER_CLASS` exists and is not empty. Default is `FALSE`.
#' #'
#' #' @return A `data.table` containing the encounters that match the specified criteria.
#' #'
#' loadEncounters <- function(patient_ids, query_datetime, force_reload = FALSE, apply_class_filter = FALSE) {
#'   # Check if encounters exist in the environment and if the patient IDs match
#'   if (!force_reload && exists("encounters", envir = .resource_env) &&
#'       exists("encounters_pids", envir = .resource_env) &&
#'       identical(.resource_env$encounters_pids, patient_ids) &&
#'       identical(.resource_env$query_datetime, query_datetime)) {
#'     message("Returning cached encounters.")
#'     return(.resource_env$encounters)
#'   }
#'
#'   # Get formatted patient IDs for SQL query
#'   query_ids <- etlutils::getQueryList(patient_ids)
#'   # Get encounter table name
#'   table_name <- etlutils::getViewTableName("encounter")
#'   # Construct base SQL query
#'   query <- paste0(
#'     "SELECT * FROM ", table_name, "\n",
#'     "  WHERE enc_patient_ref IN (", query_ids, ")\n",
#'     "    AND (enc_period_end IS NULL OR enc_period_end > '", query_datetime, "')\n",
#'     "    AND enc_period_start <= '", query_datetime, "'"
#'   )
#'
#'   # Apply encounter class filtering if applicable and enabled
#'   if (apply_class_filter && exists("FRONTEND_DISPLAYED_ENCOUNTER_CLASS")) {
#'     enc_class_codes <- FRONTEND_DISPLAYED_ENCOUNTER_CLASS
#'     if (enc_class_codes != "") {
#'       additional_class_code_condition <- paste0(
#'         " AND enc_class_code IN ('", paste(enc_class_codes, collapse = "', '"), "')"
#'       )
#'       query <- paste0(query, additional_class_code_condition)
#'     }
#'   }
#'
#'   # Execute query and retrieve encounters
#'   encounters <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[1]")
#'
#'   # Store the loaded data and patient IDs in the environment
#'   .resource_env[["encounters"]] <- encounters
#'   .resource_env[["encounters_pids"]] <- patient_ids  # Store patient IDs for comparison
#'
#'   return(encounters)
#' }

#' #' Load Resources from the Database with Caching
#' #'
#' #' This function retrieves data from the database for a specified resource type,
#' #' filtering by a given column and a list of query IDs. The results are cached
#' #' in an environment to avoid redundant database queries, unless `force_reload`
#' #' is set to `TRUE`.
#' #'
#' #' @param resource_name A character string specifying the name of the resource to load
#' #'   (e.g., `"MedicationRequest"`, `"Observation"`).
#' #' @param column_name A character string specifying the column used for filtering
#' #'   (e.g., `"medstat_encounter_ref"`, `"obs_patient_ref"`).
#' #' @param query_ids A vector of query IDs used for filtering the resource.
#' #' @param force_reload A logical value indicating whether to force reloading data
#' #'   from the database even if cached data is available. Default is `FALSE`.
#' #' @param remove_ref_type A logical value indicating whether to remove reference prefixes
#' #'   (e.g., `"Encounter/"`) from `query_ids`. Default is `FALSE`.
#' #' @param additional_query_parameter An optional SQL condition (as a character string)
#' #'   that can be appended to the `WHERE` clause for further filtering. Default is `NULL`.
#' #' @param lock_id A character string used as an identifier for the database query lock.
#' #'   Default is `"loadResourcesFromDB()"`.
#' #'
#' #' @return A `data.table` containing the queried resource data.
#' #'
#' loadResourcesFromDB <- function(resource_name, column_name, query_ids, force_reload = FALSE, remove_ref_type = FALSE, additional_query_parameter = NULL, lock_id = "loadResourcesFromDB()") {
#'   # Dynamic key for saved Query-IDs
#'   query_ids_key <- paste0(resource_name, "_query_ids")
#'
#'   # Check if the resource is already loaded and query_ids match
#'   if (!force_reload && exists(resource_name, envir = .resource_env) &&
#'       exists(query_ids_key, envir = .resource_env) &&
#'       identical(.resource_env$query_ids_key, query_ids)) {
#'     message("Returning cached ", resource_name, " .")
#'     return(.resource_env$resource_name)
#'   }
#'
#'   query_ids_sql <- etlutils::getQueryList(query_ids, remove_ref_type = remove_ref_type)
#'   table_name <- etlutils::getViewTableName(resource_name)
#'   query <- paste0(
#'     "SELECT * FROM ", table_name, "\n",
#'     "  WHERE ", column_name, " IN (", query_ids_sql, ")\n"
#'   )
#'   # Append extra conditions if provided
#'   if (!is.null(additional_query_parameter) && additional_query_parameter != "") {
#'     query <- paste0(query, " AND (", additional_query_parameter, ")")
#'   }
#'   result <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)
#'
#'   # Store result and corresponding query_ids in the environment
#'   assign(resource_name, result, envir = .resource_env)
#'   assign(query_ids_key, query_ids, envir = .resource_env)  # Store query_ids under specific key
#'
#'   return(result)
#' }

#' #' Set the Query Datetime in the Resource Environment
#' #'
#' #' This function retrieves the current query datetime using `etlutils::getQueryDatetime()`
#' #' and stores it in the `.resource_env` environment under the variable `query_datetime`.
#' #'
#' #' @details
#' #' The function ensures that the query datetime is available globally within the
#' #' `.resource_env` environment, allowing other functions to access it without
#' #' needing to repeatedly fetch it.
#' #'
#' #' @return This function does not return a value. It assigns `query_datetime` in `.resource_env`.
#' #'
#' setQueryDatetime <- function() {
#'   assign("query_datetime", etlutils::getQueryDatetime(), envir = .resource_env)
#' }
#'
#' #' Retrieve the Query Datetime from the Resource Environment
#' #'
#' #' This function fetches the stored `query_datetime` value from the `.resource_env`
#' #' environment. The datetime must have been previously set using `setQueryDatetime()`.
#' #'
#' #' @return The stored query datetime.
#' #'
#' getQueryDatetime <- function() {
#'   get("query_datetime", envir = .resource_env)
#' }

#' #' Create an Empty Data Table Based on a Database Mapping
#' #'
#' #' This function generates an empty `data.table` with the correct column names and R data types,
#' #' based on a database schema mapping provided in `mapping_table`. The function automatically
#' #' assigns the generated table to the global environment.
#' #'
#' #' @param mapping_table A `data.table` or `data.frame` containing the database schema mapping.
#' #' It must have the following columns:
#' #'   - `TABLE_NAME` (character): The name of the table (should contain only one unique value).
#' #'   - `COLUMN_NAME` (character): The names of the columns.
#' #'   - `COLUMN_TYPE` (character): The corresponding database column types (e.g., "int", "varchar").
#' #'
#' #' @return A `data.table` with the correct column names and R data types. Each column is initialized
#' #' with `NA` values of the appropriate R type.
#' #'
#' #' @details
#' #' - The function ensures that `TABLE_NAME` contains only a single unique value.
#' #' - It retrieves the appropriate R data type using `etlutils::dbGetRType()`, which converts
#' #'   database types to their corresponding R types.
#' #' - The resulting table is created as a `data.table` and is automatically assigned to the global environment
#' #'   using the extracted `TABLE_NAME` as its variable name.
#' #'
#' #' @examples
#' #' \dontrun{
#' #' # Example database mapping table
#' #' mapping_table <- data.table::data.table(
#' #'   TABLE_NAME = rep("my_table", 3),
#' #'   COLUMN_NAME = c("id", "name", "created_at"),
#' #'   COLUMN_TYPE = c("int", "varchar", "timestamp")
#' #' )
#' #'
#' #' # Create the empty table
#' #' result <- createEmptyTable(mapping_table)
#' #' print(result)
#' #' }
#' #'
#' createEmptyTable <- function(mapping_table) {
#'   # Extract the desired table name from TABLE_NAME
#'   table_name <- unique(mapping_table$TABLE_NAME)
#'
#'   # Ensure that TABLE_NAME contains only a single unique value
#'   if (length(table_name) != 1) {
#'     stop("The TABLE_NAME column should contain only one unique value!")
#'   }
#'
#'   # Extract column names from COLUMN_NAME
#'   column_names <- mapping_table$COLUMN_NAME
#'
#'   # Initialize columns with correct data types
#'   columns <- setNames(vector("list", length(column_names)), column_names)
#'
#'   for (i in seq_along(column_names)) {
#'     col_type <- mapping_table$COLUMN_TYPE[i]
#'
#'     # Use dbGetRType() to get the correct NA value of the corresponding R type
#'     columns[[i]] <- etlutils::dbGetRType(col_type)
#'   }
#'
#'   # Convert to a data.table with one row (all values NA but correct types)
#'   result_table <- data.table::as.data.table(columns)
#'
#'   # Assign the table to the global environment with the correct table name
#'   assign(table_name, result_table, envir = .GlobalEnv)
#'
#'   return(result_table)
#' }

####################################
########Hashing Functions###########
####################################

#' #' Compute SHA-256 hash of a processed file
#' #'
#' #' Reads a file, applies a given processing function to extract relevant content,
#' #' and computes a SHA-256 hash of the processed content.
#' #'
#' #' @param file_path A string specifying the path to the file.
#' #' @param processing_fn A function that processes the file and extracts the relevant content.
#' #'
#' #' @return A string containing the SHA-256 hash of the processed content.
#' #'
#' computeFileHash <- function(file_path, processing_fn) {
#'   processed_content <- processing_fn(file_path)
#'   content_hash <- digest::digest(processed_content, algo = "sha256")
#'   return(content_hash)
#' }

#' #' Load existing file hashes from a PostgreSQL database
#' #'
#' #' Queries a PostgreSQL database to retrieve the stored file hashes, which
#' #' are used to detect changes in file content across runs.
#' #'
#' #' @param file_name A string specifying the name of the table storing file hashes.
#' #'
#' #' @return A data frame with columns `file_name` (file identifier) and `content_hash` (SHA-256 hash).
#' #'
#' loadExistingHashes <- function(file_name) {
#'   # Construct the SQL query to retrieve existing file hashes
#'   query <- paste("SELECT", file_name, "content_hash FROM input_data_file_info")
#'
#'   # Execute the query and fetch the results
#'   #existing_hashes <- etlutils::dbGetReadOnlyQuery(query, lock_id = "loadExistingHashes()")
#'   existing_hashes <- etlutils::readRData("input_data_file_info", load_from_last_run = TRUE)
#'
#'   return(existing_hashes)
#' }

#' #' Compare file hashes and detect changes
#' #'
#' #' Compares the computed hashes of files against stored database hashes to determine
#' #' which files have changed or are new.
#' #'
#' #' @param files A character vector containing file paths.
#' #' @param db_hashes A data frame with columns `file_name` and `content_hash`,
#' #'   representing stored hashes from the database.
#' #' @param processing_fn A function that processes a file and extracts its relevant content.
#' #'
#' #' @return A list where each element corresponds to a file that has changed or is new.
#' #'   Each entry contains `file_name` and `content_hash`.
#' #'
#' compareAndDetectChanges <- function(files, db_hashes, processing_fn) {
#'   files_to_process <- list()
#'
#'   for (file in files) {
#'     file_name <- basename(file)
#'     content_hash <- computeFileHash(file, processing_fn)
#'     existing_hash <- db_hashes$content_hash[db_hashes$file_name == file_name]
#'
#'     if (length(existing_hash) == 0 || existing_hash != content_hash) {
#'       files_to_process[[file]] <- list(file_name = file_name, content_hash = content_hash)
#'     }
#'   }
#'
#'   return(files_to_process)
#' }

#' #' Store updated file hashes in a PostgreSQL database
#' #'
#' #' Saves or updates the file hashes in a specified PostgreSQL table.
#' #' Only stores hashes for files that have changed or are new.
#' #'
#' #' @param files_to_process A list where each element contains `file_name` and `content_hash`
#' #'   for files that have changed or are new.
#' #'
#' storeHashesInDb <- function(files_to_process) {
#'   if (length(files_to_process) == 0) return()
#'
#'   input_data_file_info <- do.call(rbind, lapply(files_to_process, function(x) {
#'     data.frame(file_name = x$file_name, content_hash = x$content_hash)
#'   }))
#'   #etlutils::dbWriteTable(input_data_file_info, lock_id = "storeHashesInDb()")
#'   etlutils::writeRData(input_data_file_info)
#' }

#' #' Process files and determine which need to be updated
#' #'
#' #' Searches for files with a given prefix in specified directories,
#' #' computes their hashes after applying a processing function, and
#' #' compares them to stored database hashes to detect changes.
#' #' If changes are detected, the new hashes are stored in the database.
#' #'
#' #' @param prefix A string specifying the prefix that the files must start with.
#' #' @param directories A character vector specifying the directories to search in.
#' #' @param db_conn A valid database connection object (from `DBI::dbConnect`).
#' #' @param table_name A string specifying the name of the table storing file hashes.
#' #' @param processing_fn A function that processes a file and extracts its relevant content.
#' #' @param extension A string specifying the file extension (e.g., `"xlsx"`, `"csv"`).
#' #' Can be `NA` or `""` to disable extension filtering.
#' #' @param recursive Logical, indicating whether to search directories recursively.
#' #' Default is `FALSE`.
#' #'
#' #' @return A list containing files that have changed or are new.
#' #'
#' processFiles <- function(prefix, directories, db_conn, table_name, processing_fn, extension = NA, recursive = FALSE) {
#'   files <- getFilesByPrefix(prefix, directories, extension, recursive)
#'   if (length(files) == 0) return(list())
#'
#'   existing_hashes <- loadExistingHashes(table_name)
#'   files_to_process <- compareAndDetectChanges(files, existing_hashes, processing_fn)
#'   storeHashesInDb(files_to_process)
#'
#'   return(files_to_process)
#' }

#########################################
########OLD Functions TO CHECK###########
#########################################

#' #' Get Abbreviation for Resource Name
#' #'
#' #' This function retrieves the abbreviation for a given resource name.
#' #'
#' #' @param resource_name A character string representing the resource name.
#' #'
#' #' @return A character string containing the abbreviation for the specified resource name.
#' #'
#' #' @export
#' getResourceAbbreviation <- function(resource_name) {
#'   resource_name <- tolower(resource_name)
#'   resource_to_abbreviation[[resource_name]]
#' }
#'
#' #' Get ID Column for Resource
#' #'
#' #' This function retrieves the name of the ID column for a given resource.
#' #'
#' #' @param resource_name A character string representing the name of the resource.
#' #'
#' #' @return A character string containing the name of the ID column for the specified resource.
#' #'
#' #' @export
#' getIDColumn <- function(resource_name) {
#'   resource_name <- tolower(resource_name)
#'   id_column <- paste0(getResourceAbbreviation(resource_name), "_id")
#'   return(id_column)
#' }
#'
#' #' Get Foreign ID Column for Resource
#' #'
#' #' This function retrieves the name of the foreign ID column for a given resource and a
#' #' specified foreign resource. If the resource and foreign resource are the same, it returns
#' #' the ID column for the resource itself.
#' #'
#' #' @param resource_name A character string representing the name of the primary resource.
#' #' @param foreign_resource_name A character string representing the name of the foreign
#' #' resource for which the ID column should be retrieved.
#' #'
#' #' @return A character string containing the name of the foreign ID column for the
#' #' specified resource pair.
#' #'
#' getForeignIDColumn <- function(resource_name, foreign_resource_name) {
#'   resource_name <- tolower(resource_name)
#'   foreign_resource_name <- tolower(foreign_resource_name)
#'   # returns not a real foreign ID if the resource name and the foreign_resource_name are equals
#'   if (resource_name == foreign_resource_name) {
#'     getIDColumn(resource_name)
#'   }
#'   foreign_id_column <- paste0(foreign_resource_name, "_ref")
#'   foreign_id_column <- paste0(getResourceAbbreviation(resource_name), "_", foreign_id_column)
#'   return(pid_column)
#' }
#'
#' #' Get PID Column for Resource
#' #'
#' #' This function retrieves the name of the PID column for a given resource.
#' #'
#' #' @param resource_name A character string representing the name of the resource.
#' #'
#' #' @return A character string containing the name of the PID column for the specified resource.
#' #'
#' #' @export
#' getPIDColumn <- function(resource_name) {
#'   getForeignIDColumn(resource_name, "patient")
#' }
#'
#' #' Get Encounter ID/Reference Column for Resource
#' #'
#' #' This function retrieves the name of the column with the reference to Encounters for a given
#' #' resource type.
#' #'
#' #' @param resource_name A character string representing the name of the resource.
#' #'
#' #' @return A character string containing the name of the Encounter ID column for the specified resource.
#' #'
#' #' @export
#' getEncIDColumn <- function(resource_name) {
#'   getForeignIDColumn(resource_name, "encounter")
#' }
#'
#' #' Extract IDs from References
#' #'
#' #' This function extracts IDs from a vector of references by getting the substring after the last slash in each reference.
#' #'
#' #' @param references A character vector of references from which to extract IDs.
#' #' @return A character vector containing the extracted IDs.
#' #'
#' #' @export
#' extractIDsFromReferences <- function(references) {
#'   etlutils::getAfterLastSlash(references)
#' }
#'
#' #' Get Query List
#' #'
#' #' This function takes a collection and optionally removes reference types
#' #' to create a query list. It concatenates the elements of the collection
#' #' into a single string, each enclosed in single quotes and separated by commas.
#' #'
#' #' @param collection The collection from which to create the query list.
#' #' @param remove_ref_type Logical indicating whether to remove reference types.
#' #' Default is \code{FALSE}.
#' #'
#' #' @export
#' getQueryList <- function(collection, remove_ref_type = FALSE) {
#'   if (remove_ref_type) {
#'     collection <- extractIDsFromReferences(collection)
#'   }
#'   paste0("'", collection, "'", collapse = ", ")
#' }
#'
#' #' Get Full Table Name for Resource
#' #'
#' #' This function constructs the full table name for a given resource by converting the
#' #' resource name to lowercase and appending it to a prefix and suffix.
#' #'
#' #' @param resource_name A character string representing the name of the resource.
#' #'
#' #' @return A character string containing the full table name for the specified resource.
#' #'
#' #' @export
#' getViewTableName <- function(resource_name) paste0("v_", tolower(resource_name))
#'
#' #' Load Resources Last Status From Database Query
#' #'
#' #' This function constructs a SQL statement to retrieve the last status of load resources
#' #' from a specified table in the database. It utilizes various helper functions to
#' #' determine the table name, ID column, and apply optional filtering conditions.
#' #'
#' #' @param resource_name The name of the resource for which to retrieve the last status.
#' #' @param filter Additional filtering conditions to apply to the query. Default is an empty string.
#' #'
#' #' @return A character string representing the SQL query.
#' #'
#' #' @export
#' getQueryToLoadResourcesLastStatusFromDB <- function(resource_name, filter = "") {
#'   last_processing_nr <- getLastProcessingNumber()
#'   # this should be view tables named in a style like 'v_patient' for resource_name Patient
#'   table_name <- getViewTableName(resource_name)
#'   id_column <- getIDColumn(resource_name)
#'   query <-paste0(
#'     "SELECT * FROM ", table_name, " a\n",
#'     " WHERE last_processing_nr = ", last_processing_nr,
#'     if (nchar(filter)) paste0("\n", filter) else "",
#'     ";\n"
#'   )
#'   return(query)
#' }
#'
#' #' Generate a filter statement for a SQL query.
#' #'
#' #' This function generates a filter statement to be used in a SQL query based on the
#' #' provided filter column and filter column values. It quotes each value and collapses
#' #' them into a comma-separated string. If the filter column is the resource ID column,
#' #' it adjusts the filter column values accordingly to handle references.
#' #'
#' #' @param resource_name The name of the resource table.
#' #' @param filter_column The column on which to apply the filter.
#' #' @param filter_column_values A vector of values to filter on.
#' #'
#' #' @return A character string representing the filter statement for the SQL query.
#' #'
#' #' @export
#' getStatementFilter <- function(resource_name, filter_column, filter_column_values) {
#'   resource_id_column <- getIDColumn(resource_name)
#'   if (filter_column == resource_id_column) {
#'     # remove resource name and the slash if the IDs are references and not pure IDs
#'     filter_column_values <- gsub(paste0("^", resource_name, "/"), "", filter_column_values)
#'   }
#'   # quote every pid and collapse the vector comma separated
#'   filter_column_values <- paste0("'", filter_column_values, "'", collapse = ",")
#'   filter_line <- paste0("AND a.", filter_column, " IN (", filter_column_values, ")\n")
#'   return(filter_line)
#' }
#'
#' #' Retrieve the last status of load resources from the database.
#' #'
#' #' This function executes a SQL query to retrieve the last status of load resources
#' #' from the database, based on the provided resource name. It utilizes a helper function
#' #' to construct the query statement.
#' #'
#' #' @param resource_name The name of the resource table.
#' #'
#' #' @return A data frame containing the last status of load resources.
#' #'
#' #' @export
#' loadResourcesLastStatusFromDB <- function(resource_name) {
#'   query <- getQueryToLoadResourcesLastStatusFromDB(resource_name, filter = "")
#'   etlutils::dbGetReadOnlyQuery(query, lock_id = "loadResourcesLastStatusFromDB()")
#' }
#'
#' #' Retrieve the last status of load resources from the database by their own IDs.
#' #'
#' #' This function retrieves the last status of load resources from the database
#' #' based on their own IDs. It constructs and executes a SQL query using the provided
#' #' resource name and IDs, leveraging a helper function.
#' #'
#' #' @param resource_name The name of the resource table.
#' #' @param ids A vector of IDs to retrieve the last status for.
#' #'
#' #' @return A data frame containing the last status of load resources.
#' #'
#' #' @export
#' loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids) {
#'   id_column <- getIDColumn(resource_name)
#'   loadResourcesFromDB(
#'     resource_name = resource_name,
#'     filter_column = id_column,
#'     ids = ids,
#'     lock_id = paste0("loadResourcesLastStatusByOwnIDFromDB(", resource_name, ")"))
#' }
#'
#' #' Retrieve the last status of load resources from the database by PID.
#' #'
#' #' This function retrieves the last status of load resources from the database
#' #' based on Patient ID (PID) if the resource is patient-related; otherwise, it
#' #' retrieves based on the provided PID column name. It constructs and executes
#' #' a SQL query using the provided resource name and PID(s), leveraging helper functions.
#' #'
#' #' @param resource_name The name of the resource table.
#' #' @param pids A vector of Patient IDs (PIDs) or related IDs to retrieve the last status for.
#' #' @return A data frame containing the last status of load resources.
#' #'
#' #' @export
#' loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids) {
#'   if (tolower(resource_name) %in% "patient") {
#'     return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids))
#'   }
#'   pid_column <- getPIDColumn(resource_name)
#'   loadResourcesFromDB(
#'     resource_name = resource_name,
#'     filter_column = pid_column,
#'     ids = pids,
#'     lock_id = paste0("loadResourcesLastStatusByPIDFromDB(",resource_name,")"))
#' }
#'
#' #' Load Resources Last Status By Encounter ID From Database
#' #'
#' #' Retrieve the last status of load resources from the database by Encounter ID.
#' #'
#' #' This function retrieves the last status of load resources from the database
#' #' based on Encounter ID if the resource is encounter-related; otherwise, it
#' #' retrieves based on the provided Encounter ID column name. It constructs and
#' #' executes a SQL query using the provided resource name and Encounter ID(s),
#' #' leveraging helper functions.
#' #'
#' #' @param resource_name The name of the resource table.
#' #' @param enc_ids A vector of Encounter IDs to retrieve the last status for.
#' #' @return A data frame containing the last status of load resources.
#' #'
#' #' @export
#' loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids) {
#'   if (tolower(resource_name) %in% "encounter") {
#'     return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids))
#'   }
#'   enc_id_column <- getPIDColumn(resource_name)
#'   loadResourcesFromDB(
#'     resource_name = resource_name,
#'     filter_column = enc_id_column,
#'     ids = enc_ids,
#'     lock_id = paste0("loadResourcesLastStatusByEncIDFromDB(",resource_name,")"))
#' }
#'
#' #' Checks whether strings in a vector of ICD codes match specified patterns.
#' #'
#' #' This function takes a vector of ICD (International Classification of Diseases)
#' #' codes and checks whether the strings in this vector match predefined patterns.
#' #' The patterns are retrieved from an external data frame named SIMPLE_ICD_PATTERN.
#' #'
#' #' @param codes A vector of strings containing the ICD codes to be checked.
#' #' @return A logical vector that returns TRUE for strings that match the patterns
#' #' and FALSE for strings that do not match the patterns.
#' #' @seealso SIMPLE_ICD_PATTERN This data frame contains the predefined patterns
#' #' for ICD codes.
#' #'
#' #' @examples
#' #' codes <- c('H77+M55.2', 'H77', 'XXX', 'X+X', 'X+XXXXX')
#' #' isICDCode(codes)
#' #'
#' #' @export
#' isICDCode <- function(codes) {
#'   icd_pattern <- paste(paste0('(', SIMPLE_ICD_PATTERN$ICD1, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD2_3, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD4_6, ')'), sep = '|')
#'   full_icd_pattern <- paste0('(','^','(', icd_pattern,')', '$', ')', '|', '(', '^', '(', icd_pattern,')', '\\+{1}', '(', icd_pattern, '){1}', '$', ')')
#'   grepl(full_icd_pattern, codes, perl = TRUE)
#' }
#'
#' #' Clean and Validate ICD Code
#' #'
#' #' This function cleans and validates an ICD code by converting it to uppercase,
#' #' removing trailing non-alphanumeric characters, and checking if the resulting
#' #' code is a valid ICD code.
#' #'
#' #' @param icd A character vector representing the ICD code.
#' #'
#' #' @return A character vector containing the cleaned and validated ICD code,
#' #'         or NULL if the input is not a valid ICD code.
#' #' @examples
#' #' cleanICD("A11")
#' #' cleanICD(" B1.2 ")
#' #' cleanICD("C23-") # This will return NULL as it's not a valid ICD code.
#' #'
#' #' @export
#' cleanICD <- function(icd) {
#'   icd <- toupper(etlutils::removeLastCharsIfNotAlphanumeric(trimws(icd)))
#'   icd[isICDCode(icd)]
#' }
#'
#' #' Reads the file path of an Excel file
#' #'
#' #' This function constructs the file path for an Excel file with the given file name.
#' #'
#' #' @param simpleExcelFileName The name of the Excel file without file extension.
#' #'
#' #' @return The full file path of the Excel file.
#' #'
#' #' @export
#' readExcelFilePath <- function(simpleExcelFileName) {
#'   paste0("./R-dataprocessor/dataprocessor/inst/extdata/", simpleExcelFileName, ".xlsx")
#' }
#'
#' #' Read an Excel file and import each sheet as a separate data.table.
#' #'
#' #' This function reads an Excel file specified by the 'simpleExcelFileName' parameter
#' #' from internal directory './inst/extdata/' and imports each sheet as a separate
#' #' data.table. It returns a list of imported sheets.
#' #'
#' #' @param simpleExcelFileName The file name of the Excel file without extension.
#' #'
#' #' @return A list of imported sheets as data.tables.
#' #'
#' #' @export
#' readExcelFileAsTableListFromExtData <- function(simpleExcelFileName) {
#'   etlutils::readExcelFileAsTableList(readExcelFilePath(simpleExcelFileName))
#' }
#'
#' #' Calculate Maximum Future Time to Check for MRPs
#' #'
#' #' This function calculates the maximum future time to check for Medication-Related Problems (MRPs)
#' #' based on the current time and a defined number of days into the future. The number of days to look ahead
#' #' is specified in the configuration file (`dataprocessor_config.toml`). This configuration sets
#' #' the interval end as a certain number of days from the current time, converted to seconds.
#' #'
#' #' @param current_time The current time as a POSIXct object, representing the starting point
#' #'   for the calculation.
#' #'
#' #' @return Returns a POSIXct object representing the maximum future time up to which MRPs should
#' #'   be checked, based on the current time and the configuration.
#' #'
#' #' @examples
#' #' MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE <- 30
#' #' current_time <- Sys.time()
#' #' future_time <- getMaxTimeInFutureToCheckForMRPs(current_time)
#' #' print(paste(current_time, " -> ", future_time))
#' #'
#' #' @export
#' getMaxTimeInFutureToCheckForMRPs <- function(current_time) {
#'   # MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE is defined in the dataprocessor_config.toml file
#'   max_seconds_checked_for_mrps_in_future <- MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE * 3600 * 24
#'   # every interval will end MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE days in the from current_time
#'   general_max_time <- current_time + max_seconds_checked_for_mrps_in_future
#'   return(general_max_time)
#' }

