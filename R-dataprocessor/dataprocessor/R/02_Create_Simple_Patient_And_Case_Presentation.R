#' Retrieve the Last Processing Number from the Database
#'
#' This function connects to the database and retrieves the maximum `last_processing_nr`
#' from the `data_import_hist` table within the `db_log` schema. It specifically looks
#' for records where the `function_name` is `'copy_type_cds_in_to_db_log'` and the
#' `table_name` does not contain `'_raw'`.
#'
#' @return A data frame containing the maximum `last_processing_nr` from the specified
#'         records in the `db_log.data_import_hist` table.
#'
getLastProcessingNumber <- function() {
  db_connection_read <- getDatabaseReadConnection()
  statement <- "SELECT MAX(last_processing_nr)
                FROM db_log.data_import_hist
                WHERE function_name = 'copy_type_cds_in_to_db_log'
                  AND schema_name = 'db_log' AND table_name NOT LIKE '%_raw';"
  etlutils::dbGetQuery(db_connection_read, statement)
}

#' Load All Data with Last Timestamp from Database
#'
#' This function loads all data from a database table that has the most recent timestamp.
#' It constructs a SQL query to fetch records where the timestamp is the latest in the table.
#'
#' @param table_name_part A string representing part of the table name to search for.
#' @return A data frame containing the records with the most recent timestamp from the specified table.
#'
loadLastImportedDatasetsFromDB <- function(table_name_part) {
  db_connection_read <- getDatabaseReadConnection()
  table_name <- getFirstTableWithNamePart(db_connection_read, table_name_part)
  last_processing_nr <- getLastProcessingNumber()
  # Create the SQL query to get the records with the maximum last_processing_nr
  statement <- paste0("SELECT * FROM ", table_name, "\n",
                      " WHERE last_processing_nr = ", last_processing_nr, ";")
  etlutils::dbGetQuery(db_connection_read, statement)
}

#' Get Current Datetime
#'
#' This function returns the current datetime. If the global variable `DEBUG_CURRENT_DATETIME` exists, it returns its value as a POSIXct object.
#' Otherwise, it returns the current system time.
#'
#' @return A POSIXct object representing the current datetime or the value of `DEBUG_CURRENT_DATETIME` if it exists.
#'
getCurrentDatetime <- function() {
  if (exists("DEBUG_CURRENT_DATETIME")) {
    return(as.POSIXct(DEBUG_CURRENT_DATETIME))
  }
  return(as.POSIXct(Sys.time()))
}

#' Get Query Datetime
#'
#' This function returns the current datetime formatted for SQL queries.
#' It retrieves the current datetime using the \code{getCurrentDatetime} function and formats it as a string in "YYYY-MM-DD HH:MM:SS" format.
#'
#' @return A character string representing the current datetime formatted for SQL queries.
#'
getQueryDatetime <- function() {
  format(getCurrentDatetime(), "%Y-%m-%d %H:%M:%S")
}

#' Extract IDs from References
#'
#' This function extracts IDs from a vector of references by getting the substring after the last slash in each reference.
#'
#' @param references A character vector of references from which to extract IDs.
#' @return A character vector containing the extracted IDs.
#'
extractIDsFromReferences <- function(references) {
  etlutils::getAfterLastSlash(references)
}

#' Get Query List
#'
#' This function takes a collection and optionally removes reference types
#' to create a query list. It concatenates the elements of the collection
#' into a single string, each enclosed in single quotes and separated by commas.
#'
#' @param collection The collection from which to create the query list.
#' @param remove_ref_type Logical indicating whether to remove reference types.
#' Default is \code{FALSE}.
#'
getQueryList <- function(collection, remove_ref_type = FALSE) {
  if (remove_ref_type) {
    collection <- extractIDsFromReferences(collection)
  }
  paste0("'", collection, "'", collapse = ", ")
}

#' Parse Query List
#'
#' This function takes a query list string and splits it based on a specified delimiter
#' to create a vector of elements. It utilizes the \code{getQueryList} function to
#' create the vector.
#'
#' @param list_string The query list string to parse.
#' @param split The delimiter used to split the query list string. Default is a space.
#'
#' @return A vector containing the parsed elements from the query list string.
#'
parseQueryList <- function(list_string, split = " ") {
  splitted <- unlist(strsplit(list_string, split))
  getQueryList(splitted)
}

####################################################
# Load Resources by ID (= own ID or PID or Enc ID) #
####################################################

#' Get Load Resources Last Status From Database Query
#'
#' This function constructs a SQL statement to retrieve the last status of load resources
#' from a specified table in the database. It utilizes various helper functions to
#' determine the table name, ID column, and apply optional filtering conditions.
#'
#' @param resource_name The name of the resource for which to retrieve the last status.
#' @param filter Additional filtering conditions to apply to the query. Default is an empty string.
#'
#' @return A character string representing the SQL query.
#'
getLoadResourcesLastStatusFromDBQuery <- function(resource_name, filter = "") {
  db_connection_read <- getDatabaseReadConnection()
  last_processing_nr <- getLastProcessingNumber()
  # this should be view tables named in a style like 'v_patient_all' for resource_name Patient
  table_name <- getFirstTableWithNamePart(db_connection_read, paste0(resource_name, "_all"))
  id_column <- getIDColumn(resource_name)
  statement <-paste0(
    "SELECT * FROM ", table_name, " a\n",
    " WHERE last_processing_nr = ", last_processing_nr,
    if (nchar(filter)) paste0("\n", filter) else "",
    ";\n"
  )
  return(statement)
}

#' Generate a filter statement for a SQL query.
#'
#' This function generates a filter statement to be used in a SQL query based on the
#' provided filter column and filter column values. It quotes each value and collapses
#' them into a comma-separated string. If the filter column is the resource ID column,
#' it adjusts the filter column values accordingly to handle references.
#'
#' @param resource_name The name of the resource table.
#' @param filter_column The column on which to apply the filter.
#' @param filter_column_values A vector of values to filter on.
#'
#' @return A character string representing the filter statement for the SQL query.
#'
getStatementFilter <- function(resource_name, filter_column, filter_column_values) {
  resource_id_column <- getIDColumn(resource_name)
  if (filter_column == resource_id_column) {
    # remove resource name and the slash if the IDs are references and not pure IDs
    filter_column_values <- gsub(paste0("^", resource_name, "/"), "", filter_column_values)
  }
  # quote every pid and collapse the vector comma separated
  filter_column_values <- paste0("'", filter_column_values, "'", collapse = ",")
  filter_line <- paste0("AND a.", filter_column, " IN (", filter_column_values, ")\n")
  return(filter_line)
}

#' Execute a SQL query to retrieve data from the database.
#'
#' This function constructs and executes a SQL query to retrieve data from the database
#' based on the provided resource name, filter column, and IDs. It utilizes helper functions
#' to generate the filter statement and the main query statement.
#'
#' @param resource_name The name of the resource table.
#' @param filter_column The column on which to apply the filter.
#' @param ids A vector of IDs to filter on.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#' @return A data frame containing the results of the SQL query.
#'
runQuery <- function(resource_name, filter_column, ids, log = TRUE) {
  filter <- getStatementFilter(resource_name, filter_column, ids)
  statement <- getLoadResourcesLastStatusFromDBQuery(resource_name, filter)
  db_connection_read <- getDatabaseReadConnection()
  etlutils::dbGetQuery(db_connection_read, statement, log)
}

#' Retrieve the last status of load resources from the database.
#'
#' This function executes a SQL query to retrieve the last status of load resources
#' from the database, based on the provided resource name. It utilizes a helper function
#' to construct the query statement.
#'
#' @param resource_name The name of the resource table.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusFromDB <- function(resource_name, log = TRUE) {
  statement <- getLoadResourcesLastStatusFromDBQuery(resource_name, filter = "")
  db_connection_read <- getDatabaseReadConnection()
  etlutils::dbGetQuery(db_connection_read, statement, log)
}

#' Retrieve the last status of load resources from the database by their own IDs.
#'
#' This function retrieves the last status of load resources from the database
#' based on their own IDs. It constructs and executes a SQL query using the provided
#' resource name and IDs, leveraging a helper function.
#'
#' @param resource_name The name of the resource table.
#' @param ids A vector of IDs to retrieve the last status for.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids, log = TRUE) {
  id_column <- getIDColumn(resource_name)
  runQuery(resource_name, id_column, ids, log)
}

#' Retrieve the last status of load resources from the database by PID.
#'
#' This function retrieves the last status of load resources from the database
#' based on Patient ID (PID) if the resource is patient-related; otherwise, it
#' retrieves based on the provided PID column name. It constructs and executes
#' a SQL query using the provided resource name and PID(s), leveraging helper functions.
#'
#' @param resource_name The name of the resource table.
#' @param pids A vector of Patient IDs (PIDs) or related IDs to retrieve the last status for.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids, log = TRUE) {
  if (tolower(resource_name) %in% "patient") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids, log))
  }
  pid_column <- getPIDColumn(resource_name)
  runQuery(resource_name, pid_column, pids, log)
}

#' Load Resources Last Status By Encounter ID From Database
#'
#' Retrieve the last status of load resources from the database by Encounter ID.
#'
#' This function retrieves the last status of load resources from the database
#' based on Encounter ID if the resource is encounter-related; otherwise, it
#' retrieves based on the provided Encounter ID column name. It constructs and
#' executes a SQL query using the provided resource name and Encounter ID(s),
#' leveraging helper functions.
#'
#' @param resource_name The name of the resource table.
#' @param enc_ids A vector of Encounter IDs to retrieve the last status for.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids, log = TRUE) {
  if (tolower(resource_name) %in% "encounter") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids, log))
  }
  enc_id_column <- getPIDColumn(resource_name)
  runQuery(resource_name, enc_id_column, enc_ids, log)
}

#' This function creates frontend tables for displaying patient and encounter information.
#'
#' The function retrieves data from the database regarding patient and encounter information
#' and constructs frontend tables suitable for display in a user interface. It first loads
#' patient and encounter data per ward from the database. Then it constructs the patient
#' frontend table, which contains patient information such as ID, name, date of birth, and gender.
#' Subsequently, it constructs the encounter frontend table, which includes information about
#' patient encounters such as ID, admission date, discharge date, diagnosis, weight, height, BMI,
#' and status.
#'
#' The patient frontend table is then written to the database table "patient_fe", and the
#' encounter frontend table is written to the database table "fall_fe". If no data is available
#' for processing, an error message is generated and the function stops execution.
#'
createFrontendTables <- function() {

  # This function constructs an error or warning message with optional additional
  # information such as related tables and database connection details. It can be
  # used to provide more context when reporting errors or warnings.
  getErrorOrWarningMessage <- function(text, tables = NA, db_connection = getDatabaseReadConnection()) {
    tables <- if (!etlutils::isSimpleNA(tables)) sapply(tables, function(table_name_part) getFirstTableWithNamePart(db_connection, table_name_part)) else NA
    tables <- if (!etlutils::isSimpleNA(tables)) paste0(" Table(s): ", paste0(tables, collapse = ", "), ";") else ""
    db_connection <- if (!etlutils::isSimpleNA(db_connection)) paste0(" DB connection: ", etlutils::getPrintString(db_connection)) else ""
    text <- paste0(text, tables, db_connection)
    return(text)
  }

  # This functions loads the last version of a patient.
  # NOTE: THIS IS ALWAYS THE VERY LAST VERSION. THE current_date IS CURRENTLY IGNORED HERE.
  # If there will be
  getPatientsFromDatabase <- function(pids_per_ward) {
    # if there are the same pids multiple in the pids per ward table (same patient on different
    # wards or multiple in the same ward, then the result will contain this patient multiple times
    # too! This error has to be fixed by the DIZ at the beginning of the process (preventing same
    # patient multiple times on the same or different wards)
    pids <- unique(pids_per_ward$patient_id)
    pids <- extractIDsFromReferences(pids)
    patients <- loadResourcesLastStatusByOwnIDFromDB("Patient", pids)
    return(patients)
  }


  # This function creates a table for frontend display containing patient information
  # based on the provided patient IDs per ward. It retrieves patient information from
  # the database and constructs the frontend table.
  createPatientFrontendTable <- function(patients) {

    pids <- unique(patients$pat_id)
    pids_count <- length(pids)

    # Initialize an empty data table to store patient information
    patient_frontend_table <- data.table(
      record_id = rep(NA_character_, times = pids_count), # v_patient_all -> patient_id
      patient_fe_id = NA_character_, # v_patient_all -> patient_id
      pat_id = NA_character_, # v_patient_all -> pat_id
      pat_cis_pid = NA_character_,
      pat_name = NA_character_,
      pat_vorname = NA_character_,
      pat_gebdat = as.POSIXct.Date(NA),
      pat_geschlecht = NA_character_,
      patient_complete = NA_character_
    )

    # Iterate over each unique patient ID to populate the frontend table
    for (i in seq_len(pids_count)) {
      patient <- patients[pat_id %in% pids[i]]
      patient_frontend_table$record_id[i] <- patient$patient_id
      patient_frontend_table$patient_fe_id[i] <- patient$patient_id
      patient_frontend_table$pat_id[i] <- patient$pat_id
      patient_frontend_table$pat_cis_pid[i] <- patient$pat_identifier_value
      patient_frontend_table$pat_vorname[i] <- patient$pat_name_given
      patient_frontend_table$pat_name[i] <- patient$pat_name_family
      patient_frontend_table$pat_gebdat[i] <- patient$pat_birthdate
      patient_frontend_table$pat_geschlecht[i] <- patient$pat_gender
      # see https://github.com/medizininformatik-initiative/INTERPOLAR/issues/274
      patient_frontend_table$patient_complete[i] <- 'Complete'
    }
    return(patient_frontend_table)
  }

  # This function creates a table for frontend display containing encounter information
  # based on the provided patient IDs per ward. It retrieves encounter information from
  # the database and constructs the frontend table.
  createEncounterFrontendTable <- function(pids_per_ward, patients) {
    # Initialize an empty data table to store encounter information
    enc_frontend_table <- data.table(
      record_id	= character(), # v_patient_all -> patient_id
      fall_id	= character(), # v_encounter_all -> enc_id
      fall_pat_id	= character(), # v_patient_all -> pat_id
      patient_id_fk	= character(), # v_patient_all -> patient_id
      fall_fe_id	= character(), # v_encounter_all -> encounter_id
      redcap_repeat_instrument = character(),
      redcap_repeat_instance = character(),
      fall_studienphase = character(),
      fall_station = character(),
      fall_aufn_dat = as.POSIXct(character()),
      fall_aufn_diag = character(),
      fall_gewicht_aktuell = numeric(),
      fall_gewicht_aktl_einheit = character(),
      fall_groesse = numeric(),
      fall_groesse_einheit = character(),
      fall_bmi = numeric(),
      fall_status = character(),
      fall_ent_dat = as.POSIXct(character()),
      fall_complete = character()
    )

    # Enable/Disable query log
    query_log <- if (VERBOSE >= 9) TRUE else FALSE

    # load Encounters for all PIDs
    query_datetime <- getQueryDatetime()
    query_ids <- getQueryList(pids_per_ward$patient_id)
    db_read_connection <- getDatabaseReadConnection()
    table_name <- getFirstTableWithNamePart(db_read_connection, "encounter_all")
    query <- paste0("SELECT * FROM ", table_name, "\n",
                    "  WHERE enc_patient_id IN (", query_ids, ") AND\n",
                    "  enc_partof_id IS NULL AND\n",
                    "  (enc_period_end IS NULL OR enc_period_end > '", query_datetime, "') AND\n",
                    "  enc_period_start <= '", query_datetime, "'\n")
    encounters <- etlutils::dbGetQuery(db_read_connection, query, query_log)

    # load Conditions referenced by Encounters
    condition_ids <- encounters$enc_diagnosis_condition_id
    query_ids <- getQueryList(condition_ids, remove_ref_type = TRUE)
    table_name <- getFirstTableWithNamePart(db_read_connection, "condition_all")
    query <- paste0("SELECT * FROM ", table_name, "\n",
                    "  WHERE con_id IN (", query_ids, ")\n")
    conditions <- etlutils::dbGetQuery(db_read_connection, query, query_log)

    for (pid_index in seq_len(nrow(pids_per_ward))) {

      pid <- pids_per_ward$patient_id[pid_index]
      pid_encounters <- encounters[enc_patient_id == pid]

      # check possible errors
      if (!nrow(pid_encounters)) { # no encounter for PID found
        etlutils::catErrorMessage(paste0("No Encounter found for PID ", pid))
        next
      }

      # Extract unique encounter IDs for the current patient
      unique_encounter_IDs <- unique(pid_encounters$enc_id)
      # if there are errors in the data then there can be more than one encounter
      if (length(unique_encounter_IDs) > 1) {
        etlutils::catErrorMessage(paste0("Multiple Encounters found for PID ", pid, "\n",
                                         "  Encounter-IDs: ", paste0(unique_encounter_IDs, collapse = ", "), "\n"))
      }

      # If the data is incorrect and a patient has more than one active Encounter, this will be
      # highlighted here.
      pid_encounters <- split(pid_encounters, pid_encounters$enc_id)

      pid_patient <- patients[pat_id == extractIDsFromReferences(pid)]

      # check errors no patient resource found for PID
      if (!nrow(pid_patient)) { # no Patient resource found for PID
        etlutils::catErrorMessage(paste0("No Patient resources found for PID ", pid))
        next
      }

      # Initialize start index for adding rows to the frontend table
      start_index <- nrow(enc_frontend_table)
      enc_frontend_table <- etlutils::addEmptyRows(enc_frontend_table, length(unique_encounter_IDs), "end")

      # Iterate over each encounter for the current patient
      for (i in 1:length(pid_encounters)) {
        target_index <- start_index + i

        # There can be multiple lines for the same Encounter if there are multiple conditions
        # present for the case which were splitted by fhir_melt (in cds2db) to multiple lines.
        # Take the common data (ID, start, end, status) from the first line
        enc_id <- pid_encounters[[i]]$enc_id[1]
        enc_period_start <- pid_encounters[[i]]$enc_period_start[1]
        enc_period_end <- pid_encounters[[i]]$enc_period_end[1]
        enc_status <- pid_encounters[[i]]$enc_status[1]
        data.table::set(enc_frontend_table, target_index, "record_id", pid_patient$patient_id)
        data.table::set(enc_frontend_table, target_index, "fall_id", enc_id)
        data.table::set(enc_frontend_table, target_index, "fall_pat_id", pid_patient$pat_id)
        data.table::set(enc_frontend_table, target_index, "patient_id_fk", pid_patient$patient_id)
        data.table::set(enc_frontend_table, target_index, "redcap_repeat_instrument", "fall")
        data.table::set(enc_frontend_table, target_index, "fall_fe_id", pid_encounters[[i]]$encounter_id[1])
        data.table::set(enc_frontend_table, target_index, "fall_aufn_dat", enc_period_start)
        data.table::set(enc_frontend_table, target_index, "fall_ent_dat",enc_period_end)
        data.table::set(enc_frontend_table, target_index, "fall_status", enc_status)

        # set fall_complete (derived from FHIR Encounter.status)
        # see https://github.com/medizininformatik-initiative/INTERPOLAR/issues/274
        fall_complete <- grepl("^finished$|^cancelled$|^entered-in-error$", enc_status, ignore.case = TRUE)
        fall_complete <- ifelse(fall_complete, "Complete", NA)
        data.table::set(enc_frontend_table, target_index, "fall_complete", fall_complete)

        # Extract ward name from pids_per_ward table
        data.table::set(enc_frontend_table, target_index, "fall_station", pids_per_ward$ward_name[pid_index])

        # Extract the admission diagnosis
        admission_diagnoses <- pid_encounters[[i]][enc_diagnosis_use_code == "AD"]$enc_diagnosis_condition_id
        admission_diagnoses <- unique(admission_diagnoses)
        admission_diagnoses <- extractIDsFromReferences(admission_diagnoses)
        admission_diagnoses <- conditions[con_id %in% admission_diagnoses]
        admission_diagnoses <- unique(admission_diagnoses$con_code_text)
        admission_diagnoses <- paste0(admission_diagnoses, collapse = "; ")
        data.table::set(enc_frontend_table, target_index, "fall_aufn_diag", admission_diagnoses)

        # Function to extract specific observations for the encounter
        getObservation <- function(codes, system, target_column_value, target_column_unit = NA) {
          codes <- parseQueryList(codes)
          table_name <- getFirstTableWithNamePart(db_read_connection, "observation_all")
          # Extract the Observations by direct encounter references
          query <- paste0("SELECT * FROM ", table_name, "\n",
                          "  WHERE obs_encounter_id = 'Encounter/", enc_id, "' AND\n",
                          "        obs_code_code IN (", codes, ") AND\n",
                          "        obs_code_system = '", system, "' AND\n",
                          "        obs_effectivedatetime < '", query_datetime, "'\n")
          observations <- etlutils::dbGetQuery(getDatabaseReadConnection(), query, query_log)
          # we found no Observations with the direct encounter link so identify potencial
          # Observations by time overlap with the encounter period start and current date
          if (!nrow(observations)) {
            query <- paste0("SELECT * FROM ", table_name, "\n",
                            "  WHERE obs_patient_id = '", pid, "' AND\n",
                            "        obs_code_code IN (", codes, ") AND\n",
                            "        obs_code_system = '", system, "' AND\n",
                            "        obs_effectivedatetime > '", enc_period_start, "' AND\n",
                            "        obs_effectivedatetime < '", query_datetime, "'\n")
            observations <- etlutils::dbGetQuery(getDatabaseReadConnection(), query, query_log)
          }
          if (nrow(observations)) {
            # take the very frist Observation with the latest date (should be only 1 but sure is sure)
            observations <- observations[obs_effectivedatetime == max(obs_effectivedatetime)][1]
            data.table::set(enc_frontend_table, target_index, target_column_value, observations$obs_valuequantity_value)
            if (!is.na(target_column_unit)) {
              data.table::set(enc_frontend_table, target_index, target_column_unit, observations$obs_valuequantity_code)
            }
          }
        }

        getObservation(OBSERVATION_BODY_WEIGHT_CODES, OBSERVATION_BODY_WEIGHT_SYSTEM, "fall_gewicht_aktuell", "fall_gewicht_aktl_einheit")
        getObservation(OBSERVATION_BODY_HEIGHT_CODES, OBSERVATION_BODY_HEIGHT_SYSTEM, "fall_groesse", "fall_groesse_einheit")
        getObservation(OBSERVATION_BMI_CODES, OBSERVATION_BMI_SYSTEM, "fall_bmi")

      }

      # Fill redcap_repeat_instance column in table enc_frontend_table
      # Sort the data table by fall_pat_id and fall_aufn_dat
      data.table::setorder(enc_frontend_table, fall_pat_id, fall_aufn_dat)
      # Grouping and numbering based on fall_pat_id and fall_aufn_dat
      enc_frontend_table[, redcap_repeat_instance := seq_len(.N), by = .(fall_pat_id)]

    }
    return(enc_frontend_table)
  }

  pids_per_ward <- loadLastImportedDatasetsFromDB("pids_per_ward")
  pids_per_ward <- pids_per_ward[!is.na(patient_id)]

  if (!nrow(pids_per_ward)) {
    message <- paste0("WARNING: The pids_per_ward table is empty.\n",
                                "Hint: Please ensure there was enoungh time between the 'cds2db' module and the 'dataprocessor' module. At least a little bit more than 1 minute.")
    message <- getErrorOrWarningMessage(message, "pids_per_ward")
    stop(message)
  }

  # Load the Patient resources from database
  patients_from_database <- getPatientsFromDatabase(pids_per_ward)

  #########################
  # START: FOR DEBUG ONLY #
  #########################
  # Set parameter DEBUG_ADD_MULTIPLE_DIFFERENT_PATIENT_LINES = true in dataprocessor_config.toml
  # Add new rows with a changed postal code to test the following code line which should
  # identify one valid Identifier.value from one patient_id (= source record ID).
  if (etlutils::isDefinedAndTrue("DEBUG_ADD_MULTIPLE_DIFFERENT_PATIENT_LINES")) {
    patients_from_database <- debugAddMultiplePatientLines(patients_from_database)
  }
  #######################
  # END: FOR DEBUG ONLY #
  #######################

  # check error no Patient exists in the current patinet database table
  if (!nrow(patients_from_database)) { #
    etlutils::catErrorMessage(paste0("No Patient resources found."))
    return(NA)
  }

  # filter rows in the patients_from_database table by the given filter patterns for the
  # Identifier
  filterRows <- function(pattern, column_name) {
    # If the pattern is empty (same as any string) or matches any string, return the original table
    if (pattern %in% c("", ".*")) {
      return(patients_from_database)
    }
    # remove rows for the patient where row does not match the pattern
    patients_from_database <- patients_from_database[grepl(pattern, get(column_name))]
    # check error no Patient left after identifier filtering
    if (!nrow(patients_from_database)) { #
      etlutils::catErrorMessage(paste0("No Patient resources found with a '", column_name, "' matching pattern '", pattern, "'"))
      return(NA)
    }
    return(patients_from_database)
  }

  # Apply the filterRows function for each identifier system and return NA if no patients are left
  if (etlutils::isSimpleNA(patients_from_database <- filterRows(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM , "pat_identifier_system"))) return(NA)
  if (etlutils::isSimpleNA(patients_from_database <- filterRows(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM , "pat_identifier_type_system"))) return(NA)
  if (etlutils::isSimpleNA(patients_from_database <- filterRows(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE , "pat_identifier_type_code"))) return(NA)

  # If a patient has been given any list value, e.g. an additional identifier to an existing
  # identifier that is not changed, then at least 2 data records are created in the patient table
  # after the fhir_melt, whereby one was already present in the DB and the other is newly added.
  # Now it can happen, for whatever reason, that the same patient has several different values
  # ('Identifier.value') after filtering via the Identifier.system.
  # In this case, we assume that the last value (= the one with the highest 'patient_id') is the
  # valid one. We now remove all lines per patient with an 'Identifier.value' that is not the same
  # as the last added 'Identifier.value'.
  # We then set the maximum (= last valid) 'patient_id' for all remaining lines per 'pat_id', as
  # this must be the data record ID from which all information is derived.

  # only keep the lines of a 'pat_id' where the 'pat_identifier_value' is the same as in the
  # respective line with the maximum = last created 'patient_id'.
  # Alternative notation:
  #patients_from_database <- patients_from_database[, .SD[pat_identifier_value == .SD[which.max(patient_id), pat_identifier_value]], by = pat_id]
  patients_from_database <- patients_from_database[, .SD[pat_identifier_value == pat_identifier_value[which.max(patient_id)]], by = pat_id]

  # set the maximum (= last valid) 'patient_id' for all remaining lines per 'pat_id'
  patients_from_database[, patient_id := max(patient_id), by = pat_id]

  # make sure that it is a single patient resource by choosing the last of the potencial list
  # if there are multiple rows then all differen values of a column will be pasted as stings
  # delimited by "; " in one row
  patients_from_database <- etlutils::collapseRowsByGroup(patients_from_database, group_col = "pat_id")

  # Create frontend table for patients
  patient_frontend_table <- createPatientFrontendTable(patients_from_database)
  # Write patient frontend table to the database
  etlutils::writeTableToDatabase(patient_frontend_table,
                                 getDatabaseWriteConnection(),
                                 table_name = "patient_fe",
                                 clear_before_insert = TRUE)

  # Create frontend table for encounters
  encounter_frontend_table <- createEncounterFrontendTable(pids_per_ward, patients_from_database)
  # Write encounter frontend table to the database
  etlutils::writeTableToDatabase(encounter_frontend_table,
                                 getDatabaseWriteConnection(),
                                 table_name = "fall_fe",
                                 clear_before_insert = TRUE)
}

# List with resource abbreviations
resource_to_abbreviation <- list(
  condition = "con",
  consent = "cons",
  diagnosticreport = "diagrep",
  encounter = "enc",
  location = "loc",
  medication = "med",
  medicationadministration = "medadm",
  medicationrequest = "medreq",
  medicationstatement = "medstat",
  observation = "obs",
  patient = "pat",
  procedure = "proc",
  servicerequest = "servreq"
)

#' Get Abbreviation for Resource Name
#'
#' This function retrieves the abbreviation for a given resource name.
#'
#' @param resource_name A character string representing the resource name.
#'
#' @return A character string containing the abbreviation for the specified resource name.
#'
getResourceAbbreviation <- function(resource_name) {
  resource_name <- tolower(resource_name)
  resource_to_abbreviation[[resource_name]]
}

#' Get PID Column for Resource
#'
#' This function retrieves the name of the PID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the PID column for the specified resource.
#'
getPIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  if (resource_name == "patient") {
    pid_column <- "id"
  } else {
    pid_column <- "patient_id"
  }
  pid_column <- paste0(getResourceAbbreviation(resource_name), "_", pid_column)
  return(pid_column)
}

#' Get ID Column for Resource
#'
#' This function retrieves the name of the ID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the ID column for the specified resource.
#'
getIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  id_column <- paste0(getResourceAbbreviation(resource_name), "_id")
  return(id_column)
}

#' Get Encounter ID/Reference Column for Resource
#'
#' This function retrieves the name of the column with the reference to Encounters for a given
#' resource type.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the Encounter ID column for the specified resource.
#'
getEncIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  if (resource_name == "encounter") {
    enc_id_column <- "id"
  } else {
    enc_id_column <- "encounter_id"
  }
  enc_id_column <- paste0(getResourceAbbreviation(resource_name), "_", enc_id_column)
  return(enc_id_column)
}
