#' Get the most relevant current datetime
#'
#' This function retrieves the latest encounter end datetime from the `encounters` table.
#' If no valid end datetime is available, it defaults to the current system time (`Sys.time()`).
#' The result is converted to a `POSIXct` object with the appropriate timezone.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records,
#'                   where `enc_period_end` represents the encounter end timestamps.
#'
#' @return A `POSIXct` object representing the most recent encounter end datetime
#'         or the current system time if no valid datetime is found.
#'
#' @export
getCurrentDatetime <- function(encounters) {
  encounters_end <- na.omit(encounters$enc_period_end)
  datetime <- if (length(encounters_end)) min(encounters_end) - 1 else Sys.time()
  return(etlutils::as.POSIXctWithTimezone(datetime))
}

#' Format datetime for SQL queries
#'
#' This function formats the datetime returned by `getCurrentDatetime()` into an SQL-compatible
#' timestamp string in the format `"YYYY-MM-DD HH:MM:SS"`.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records.
#'                   Used to determine the latest encounter end datetime.
#'
#' @return A character string representing the formatted SQL datetime.
#'
#' @export
getQueryDatetime <- function(encounters) {
  format(getCurrentDatetime(encounters), "%Y-%m-%d %H:%M:%S")
}

#' Extract IDs from References
#'
#' This function extracts IDs from a vector of references by getting the
#' substring after the last slash in each reference.Optionally, duplicate IDs
#' can be removed.
#'
#' @param references A character vector of references from which to extract IDs.
#' @param unique A logical value indicating whether to return only unique IDs.
#' Default is TRUE.
#' @return A character vector containing the extracted IDs, optionally unique.
#'
extractIDsFromReferences <- function(references, unique = TRUE) {
  ids <- etlutils::getAfterLastSlash(na.omit(references))
  if (unique) {
    ids <- unique(ids)
  }
  return(ids)
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
  collection <- unique(na.omit(collection))
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

#' Load Resources Last Status From Database Query
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
getQueryToLoadResourcesLastStatusFromDB <- function(resource_name, filter = "") {
  # this should be view tables named in a style like 'v_patient' for resource_name Patient
  query <-paste0(
    "SELECT * FROM v_", resource_name, "_last_version\n",
    if (nchar(filter)) paste0("\n", filter) else "",
    ";\n"
  )
  return(query)
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
getStatementFilter <- function(resource_name, filter_column = NA, filter_column_values = NA) {
  if (is.na(filter_column) || is.na(filter_column_values)) {
    return("")
  }
  resource_id_column <- etlutils::getIDColumn(resource_name)
  if (filter_column == resource_id_column) {
    # remove resource name and the slash if the IDs are references and not pure IDs
    filter_column_values <- gsub(paste0("^", resource_name, "/"), "", filter_column_values)
  }
  # quote every pid and collapse the vector comma separated
  filter_column_values <- paste0("'", filter_column_values, "'", collapse = ",")
  filter_line <- paste0("WHERE ", filter_column, " IN (", filter_column_values, ")\n")
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
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @return A data frame containing the results of the SQL query.
#'
loadResourcesFromDB <- function(resource_name, filter_column = NA, ids = NA, lock_id) {
  filter <- getStatementFilter(resource_name, filter_column, ids)
  query <- getQueryToLoadResourcesLastStatusFromDB(resource_name, filter)
  etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)
}

#' Retrieve the last status of load resources from the database.
#'
#' This function executes a SQL query to retrieve the last status of load resources
#' from the database, based on the provided resource name. It utilizes a helper function
#' to construct the query statement.
#'
#' @param resource_name The name of the resource table.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusFromDB <- function(resource_name) {
  query <- getQueryToLoadResourcesLastStatusFromDB(resource_name)
  etlutils::dbGetReadOnlyQuery(query, lock_id = paste0("loadResourcesLastStatusFromDB(", resource_name, ")"))
}

#' Retrieve the last status of load resources from the database by their own IDs.
#'
#' This function retrieves the last status of load resources from the database
#' based on their own IDs. It constructs and executes a SQL query using the provided
#' resource name and IDs, leveraging a helper function.
#'
#' @param resource_name The name of the resource table.
#' @param ids A vector of IDs to retrieve the last status for.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids) {
  id_column <- etlutils::getIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = id_column,
    ids = ids,
    lock_id = paste0("loadResourcesLastStatusByOwnIDFromDB(", resource_name, ")"))
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
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids) {
  if (tolower(resource_name) %in% "patient") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids))
  }
  pid_column <- etlutils::getPIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = pid_column,
    ids = pids,
    lock_id = paste0("loadResourcesLastStatusByPIDFromDB(",resource_name,")"))
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
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids) {
  if (tolower(resource_name) %in% "encounter") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids))
  }
  enc_id_column <- etlutils::getEncIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = enc_id_column,
    ids = enc_ids,
    lock_id = paste0("loadResourcesLastStatusByEncIDFromDB(", resource_name, ")"))
}

#' Find Related Partof Encounters for a Main Encounter
#'
#' This function identifies valid part encounters that are associated with a given main encounter.
#' A part encounter is considered valid if:
#' - It starts on or after the main encounter's start time.
#' - If both the main and part encounters have an end time, the part encounter must end on or before the main encounter's end time.
#'
#' @param main_encounter A **data.table** containing a single row with the main encounter information.
#' It should include `enc_period_start` and optionally `enc_period_end`.
#' @param pid_part_of_encounters A **data.table** with multiple part encounters, each having
#' `enc_period_start` and optionally `enc_period_end`.
#'
#' @return A filtered **data.table** containing only the part encounters that meet the conditions.
#'
findPartOfEncounters <- function(main_encounter, pid_part_of_encounters) {
  # Condition 1: The part encounter must start on or after the main encounter starts
  condition_start <- pid_part_of_encounters$enc_period_start >= main_encounter$enc_period_start

  # Condition 2: Compare enc_period_end only if both values are not NA
  condition_end <- is.na(main_encounter$enc_period_end) |
    is.na(pid_part_of_encounters$enc_period_end) |
    (pid_part_of_encounters$enc_period_end <= main_encounter$enc_period_end)

  result <- pid_part_of_encounters[condition_start & condition_end]
}

#' Function to filter rows and combine `enc_identifier_value` for multiple `location_codes`
#'
#' This function filters rows from the provided data based on multiple `location_codes`
#' and combines their corresponding `enc_identifier_value` into a single string.
#' The function supports configurable labels for each location code.
#'
#' @param data A data frame or data table that contains columns `enc_location_physicaltype_code` and `enc_identifier_value`.
#' @param location_labels A named vector where names correspond to `location_codes` and values are the labels.
#'
#' @details This function applies filtering to each `location_code` provided in `location_labels`. It extracts values
#' from the `enc_identifier_value` column based on the `enc_location_physicaltype_code` column and combines
#' the non-empty, non-NA values into a single string, separated by commas. Each filtered and combined value is
#' associated with its corresponding label from `location_labels`.
#'
#' @return A single string containing all filtered and combined values, grouped by location labels, separated by semicolons.
#'
#' @examples
#' \dontrun{
#' # Example data
#' library(data.table)
#' FRONTEND_DISPLAYED_ROOM_AND_BED_PATH <- "enc_location_display"
#' pid_part_of_encounters <- data.table(
#'   enc_location_physicaltype_code = c("wa", "ro", "bd", "bd", "bd"),
#'   enc_location_display = c("ID_001", "ID_002", "ID_003", "ID_004", "ID_004")
#' )
#' location_labels <- c(wa = "Station", ro = "Room", bd = "Bed")
#' locations <- combineEncounterLocations(pid_part_of_encounters, location_labels)
#' location_labels <- c(ro = "Room", bd = "Bed")
#' combineEncounterLocations(pid_part_of_encounters, location_labels)
#' }
#'
combineEncounterLocations <- function(data, location_labels) {
  if (!exists("FRONTEND_DISPLAYED_ROOM_AND_BED_PATH")) {
    return("")
  }
  location_codes <- names(location_labels)
  # Apply the filtering and combining for each location_code and concatenate the results
  combined_results <- sapply(location_codes, function(location_code) {
    # Filter rows based on the specified location_code in enc_location_physicaltype_code
    filtered_values <- data[
      enc_location_physicaltype_code == location_code,  # Filter condition
      get(FRONTEND_DISPLAYED_ROOM_AND_BED_PATH) # Extract the values from enc_identifier_value
    ]
    # Check if there are valid values and filter out NA or empty values
    valid_values <- filtered_values[!is.na(filtered_values) & filtered_values != ""]
    # Remove duplicated values
    unique_values <- unique(valid_values)
    # Combine die einzigartigen Werte in eine Zeichenkette
    combined_values <- paste(unique_values, collapse = ", ")
    # Get the corresponding label for the location_code from the location_labels mapping
    location_label <- location_labels[location_code]
    # If there is a label, return the formatted result with the label and combined values
    if (!is.null(location_label) && length(unique_values)) {
      return(paste0(location_label, ": ", combined_values))
    }
  })
  # Remove any NULL values if no valid values for a particular location_code
  combined_results <- combined_results[!sapply(combined_results, is.null)]
  # Combine all results into a single string, separated by semicolons
  final_result <- paste(combined_results, collapse = "; ")
  return(final_result)
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
  getErrorOrWarningMessage <- function(text, tables = NA, readonly = TRUE) {
    tables <- if (!etlutils::isSimpleNA(tables)) paste0(" Table(s): ", paste0(tables, collapse = ", "), ";") else ""
    db_connection <- if (!etlutils::isSimpleNA(readonly)) etlutils::dbGetInfo(readonly) else ""
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

  loadExistingRecordIDsFromDB <- function(pat_ids, default = NULL) {
    query_ids <- getQueryList(pat_ids)
    query <- paste0("SELECT pat_id, record_id FROM v_patient_fe WHERE pat_id IN (", query_ids, ")")
    existing_record_ids <- etlutils::dbGetReadOnlyQuery(query, lock_id = "cacheExistingRecordIDs()")
    return(existing_record_ids)
  }

  getExistingRecordID <- function(pat_id, default = NA_character_, existing_record_ids) {
    existing_record_id <- existing_record_ids[pat_id == pat_id, record_id]
    if (!length(existing_record_id)) {
      existing_record_id <- default
    }
    return(existing_record_id)
  }

  # This function creates a table for frontend display containing patient information
  # based on the provided patient IDs per ward. It retrieves patient information from
  # the database and constructs the frontend table.
  createPatientFrontendTable <- function(patients, existing_record_ids) {

    pids <- unique(patients$pat_id)
    pids_count <- length(pids)

    # Initialize an empty data table to store patient information
    patient_frontend_table <- data.table(
      record_id = rep(NA_character_, times = pids_count), # v_patient -> patient_id
      patient_fe_id = NA_character_, # v_patient -> patient_id
      pat_id = NA_character_, # v_patient -> pat_id
      pat_cis_pid = NA_character_,
      pat_name = NA_character_,
      pat_vorname = NA_character_,
      pat_gebdat = etlutils::as.DateWithTimezone(NA),
      pat_geschlecht = NA_character_,
      patient_complete = NA_character_
    )

    # Iterate over each unique patient ID to populate the frontend table
    for (i in seq_len(pids_count)) {

      patient <- patients[pat_id %in% pids[i]]

      # Get an existing record_id for the patient from the database patient_fe
      # table via the pat_id. If there is no record_id for the pat_id, then the
      # existing_record_id will be patient$patient_id.
      record_id <- getExistingRecordID(pids[i], default = patient$patient_id, existing_record_ids)
      patient_frontend_table$record_id[i] <- record_id
      patient_frontend_table$patient_fe_id[i] <- record_id
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
  createEncounterFrontendTable <- function(pids_per_ward, patients, existing_record_ids) {
    # Initialize an empty data table to store encounter information
    enc_frontend_table <- data.table(
      record_id	= character(), # v_patient -> patient_id
      fall_id	= character(), # v_encounter -> enc_id
      fall_pat_id	= character(), # v_patient -> pat_id
      patient_id_fk	= character(), # v_patient -> patient_id
      redcap_repeat_instrument = character(),
      redcap_repeat_instance = character(),
      fall_studienphase = character(),
      fall_station = character(),
      fall_aufn_dat = etlutils::as.POSIXctWithTimezone(character()),
      fall_aufn_diag = character(),
      fall_zimmernr = character(),
      fall_gewicht_aktuell = numeric(),
      fall_gewicht_aktl_einheit = character(),
      fall_groesse = numeric(),
      fall_groesse_einheit = character(),
      #fall_bmi = numeric(),
      fall_status = character(),
      fall_ent_dat = etlutils::as.POSIXctWithTimezone(character()),
      fall_complete = character()
    )

    # load Encounters for all PIDs from pids_per_ward database table
    query_ids <- getQueryList(pids_per_ward$encounter_id)

    query <- paste0( "SELECT * FROM v_encounter_last_version\n",
                     "  WHERE encounter_raw_id in (\n",
                     "    SELECT MAX(encounter_raw_id) FROM v_encounter\n",
                     "      WHERE enc_id IN (", query_ids, ")\n",
                     "      GROUP BY enc_id\n",
                     "  )"
    )

    if (exists("FRONTEND_DISPLAYED_ENCOUNTER_CLASS")) {
      enc_class_codes <- FRONTEND_DISPLAYED_ENCOUNTER_CLASS
      # create additional condition if there are class codes defined for the accepted encounters
      if (enc_class_codes != "") {
        # Additional condition only if enc_class_codes is not empty
        additional_class_code_condition <- paste0(" AND enc_class_code IN ('", paste(enc_class_codes, collapse = "', '"), "')")
        query <- paste0(query, additional_class_code_condition)
      }
    }

    # Get encounters from database
    encounters <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[1]")

    query_datetime <- getQueryDatetime(encounters)

    # Create a new table with rows where enc_partof_ref is NOT NA
    part_of_encounters <- encounters[!is.na(enc_partof_ref)]

    # Second way to find all partof encounters if there are no partof references
    if (!length(part_of_encounters)) {
      part_of_encounters <- encounters[enc_type_code != "einrichtungskontakt"]
    }

    # Remove the rows that exist in part_of_encounters from encounters
    main_encounters <- encounters[!enc_id %in% part_of_encounters$enc_id]

    # load Conditions referenced by Encounters
    query_ids <- getQueryList(main_encounters$enc_diagnosis_condition_ref, remove_ref_type = TRUE)

    query <- paste0("SELECT * FROM v_condition\n",
                    "  WHERE con_id IN (", query_ids, ")\n")

    conditions <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[2]")

    # Create a new data.table with only pid and ward_name, ensuring unique rows
    unique_pid_ward <- unique(pids_per_ward[, .(patient_id, ward_name)])

    for (pid_index in seq_len(nrow(unique_pid_ward))) {

      pid <- unique_pid_ward$patient_id[pid_index]
      pid_ref <- etlutils::getFHIRPatientReference(pid)
      pid_encounters <- main_encounters[enc_patient_ref == pid_ref]
      pid_part_of_encounters <- part_of_encounters[enc_patient_ref == pid_ref]

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

      pid_patient <- patients[pat_id == pid]

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

        pid_encounter <- pid_encounters[[i]]
        # There can be multiple lines for the same Encounter if there are multiple conditions
        # present for the case which were splitted by fhir_melt (in cds2db) to multiple lines.
        # Take the common data (ID, start, end, status) from the first line
        enc_id <- pid_encounter$enc_id[1]
        enc_identifier_value <- pid_encounter$enc_identifier_value[1]
        enc_period_start <- etlutils::as.POSIXctWithTimezone(pid_encounter$enc_period_start[1])
        enc_period_end <- etlutils::as.POSIXctWithTimezone(pid_encounter$enc_period_end[1])
        enc_status <- pid_encounter$enc_status[1]

        record_id <- getExistingRecordID(pid_patient$pat_id, default = pid_patient$patient_id, existing_record_ids)
        data.table::set(enc_frontend_table, target_index, "record_id", record_id)
        data.table::set(enc_frontend_table, target_index, "fall_id", enc_identifier_value)
        data.table::set(enc_frontend_table, target_index, "fall_pat_id", pid_patient$pat_id)
        data.table::set(enc_frontend_table, target_index, "patient_id_fk", record_id)
        data.table::set(enc_frontend_table, target_index, "redcap_repeat_instrument", "fall")
        data.table::set(enc_frontend_table, target_index, "fall_aufn_dat", enc_period_start)
        data.table::set(enc_frontend_table, target_index, "fall_ent_dat", enc_period_end)
        data.table::set(enc_frontend_table, target_index, "fall_status", enc_status)

        # set fall_complete (derived from FHIR Encounter.status)
        # see https://github.com/medizininformatik-initiative/INTERPOLAR/issues/274
        fall_complete <- grepl("^finished$|^cancelled$|^entered-in-error$", enc_status, ignore.case = TRUE)
        fall_complete <- ifelse(fall_complete, "Complete", "Incomplete")
        data.table::set(enc_frontend_table, target_index, "fall_complete", fall_complete)

        # Extract ward name from unique_pid_ward table
        data.table::set(enc_frontend_table, target_index, "fall_station", unique_pid_ward$ward_name[pid_index])

        # Extract the admission diagnosis
        admission_diagnoses <- pid_encounter[enc_diagnosis_use_code == "AD"]$enc_diagnosis_condition_id
        admission_diagnoses <- unique(admission_diagnoses)
        admission_diagnoses <- extractIDsFromReferences(admission_diagnoses)
        admission_diagnoses <- conditions[con_id %in% admission_diagnoses]
        admission_diagnoses <- unique(admission_diagnoses$con_code_text)
        admission_diagnoses <- paste0(admission_diagnoses, collapse = "; ")
        data.table::set(enc_frontend_table, target_index, "fall_aufn_diag", admission_diagnoses)

        #####Start: Find Locations for column 'fall_zimmernr'#####
        # Check if any partof reference NA, so find partof encounters via start- and enddate
        # Else find partof encounters via partof reference
        if (any(is.na(pid_part_of_encounters$enc_partof_ref))) {
          # Find related part encounters for a main encounter
          filtered_pid_part_of_encounters <- findPartOfEncounters(pid_encounter, pid_part_of_encounters)
        } else {
          searched_encounter <- paste0("Encounter/", enc_id)
          filtered_pid_part_of_encounters <- pid_part_of_encounters[grepl(searched_encounter, enc_partof_ref)]
        }

        # Filter for newest encounter locations
        # 1. Filter out rows where 'enc_location_physicaltype_code' is NA and only keep rows where
        # 'enc_location_physicaltype_code' is "ro" or "bd"
        filtered_pid_part_of_encounters <- filtered_pid_part_of_encounters[
          !is.na(enc_location_physicaltype_code) &
            enc_location_physicaltype_code %in% c("ro", "bd")
        ]
        # 2. Select all rows with the maximum 'enc_period_start'
        if (nrow(filtered_pid_part_of_encounters)) {
        filtered_pid_part_of_encounters <- filtered_pid_part_of_encounters[enc_period_start == max(enc_period_start), ]
        # 3. For each type ("ro" and "bd"), select the first row based on the original order
        first_room_row <- filtered_pid_part_of_encounters[enc_location_physicaltype_code == "ro"][1, ]
        first_bed_row <- filtered_pid_part_of_encounters[enc_location_physicaltype_code == "bd"][1, ]
        # 4. Combine the results: first room row, and first bed row
        filtered_pid_part_of_encounters <- rbind(first_room_row, first_bed_row)

        # Define the mapping of location codes to labels
        location_labels <- c("ro" = "Zimmer", "bd" = "Bett")
        # Call the function with the filtered_pid_part_of_encounters data and the location_labels
        combined_location_results <- combineEncounterLocations(filtered_pid_part_of_encounters, location_labels)
        data.table::set(enc_frontend_table, target_index, "fall_zimmernr", combined_location_results)
        } else {
          data.table::set(enc_frontend_table, target_index, "fall_zimmernr", NA_character_)
        }
        #####End: Find Locations for column 'fall_zimmernr'#####

        # Function to extract specific observations for the encounter
        getObservation <- function(codes, system, target_column_value, target_column_unit = NA, obs_by_pid = FALSE) {
          codes <- parseQueryList(codes)

          # Query template to get desired Observations from DB
          query_template <- paste0("SELECT * FROM v_observation\n",
                                   "  WHERE obs_code_code IN (", codes, ") AND\n",
                                   "        obs_code_system = '", system, "' AND\n",
                                   "        obs_effectivedatetime < '", query_datetime, "' AND\n")

          if (isFALSE(obs_by_pid)) {
            # Extract the Observations by direct encounter references
            additional_query_condition <- paste0("        obs_encounter_ref = 'Encounter/", enc_id, "'\n")
            query <- paste0(query_template, additional_query_condition)

            observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[1]")

            # If no Observations found with the direct encounter link, so identify potencial
            # Observations by time overlap with the encounter period start and current date
            if (!nrow(observations)) {
              additional_query_condition <- paste0("        obs_patient_ref = 'Patient/", pid, "' AND\n",
                                                   "        obs_effectivedatetime > '", enc_period_start, "'\n")
              query <- paste0(query_template, additional_query_condition)

              observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[2]")
            }

          } else {
            # Extract Observations by patient ID, but without any references to the encounter
            additional_query_condition <- paste0("        obs_patient_ref = 'Patient/", pid, "'\n")
            query <- paste0(query_template, additional_query_condition)

            observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[3]")
          }

          if (nrow(observations)) {
            # take the very first Observation with the latest date (should be only 1 but sure is sure)
            observations <- observations[obs_effectivedatetime == max(obs_effectivedatetime)][1]
            data.table::set(enc_frontend_table, target_index, target_column_value, observations$obs_valuequantity_value)
            if (!is.na(target_column_unit)) {
              data.table::set(enc_frontend_table, target_index, target_column_unit, observations$obs_valuequantity_code)
            }
          }
        }

        getObservation(OBSERVATION_BODY_WEIGHT_CODES, OBSERVATION_BODY_WEIGHT_SYSTEM, "fall_gewicht_aktuell", "fall_gewicht_aktl_einheit")
        getObservation(OBSERVATION_BODY_HEIGHT_CODES, OBSERVATION_BODY_HEIGHT_SYSTEM, "fall_groesse", "fall_groesse_einheit", obs_by_pid = TRUE)
        # For unknown reasons, a BMI written to the RedCap is always written back from the
        # RedCap to the database as an empty value, which duplicates the entire data record.
        # As the cause could not be found, we have simply deactivated the field for the time
        # being. It is not currently displayed in the RedCap anyway.
        #getObservation(OBSERVATION_BMI_CODES, OBSERVATION_BMI_SYSTEM, "fall_bmi")

      }

      # Fill redcap_repeat_instance column in table enc_frontend_table
      # Sort the data table by fall_pat_id and fall_aufn_dat
      data.table::setorder(enc_frontend_table, fall_pat_id, fall_aufn_dat)
      # Grouping and numbering based on fall_pat_id and fall_aufn_dat
      enc_frontend_table[, redcap_repeat_instance := seq_len(.N), by = .(fall_pat_id)]

    }
    return(enc_frontend_table)
  }

  pids_per_ward <- etlutils::dbGetReadOnlyQuery(
    query = paste0("SELECT * FROM v_pids_per_ward_last\n"),
    lock_id = "load last imported datasets from pids_per_ward")
  pids_per_ward <- pids_per_ward[!is.na(patient_id)]

  if (!nrow(pids_per_ward)) {
    message <- getErrorOrWarningMessage(
      text = "WARNING: The pids_per_ward table is empty.\n",
      tables = "pids_per_ward")
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

  # make sure that it is a single patient resource by choosing the last of the potential list
  # if there are multiple rows then all different values of a column will be pasted as stings
  # delimited by "; " in one row
  # TODO: Wenn dieser Fall auftritt, dann muss hier mit einem harten Fehler abgebrochen werden. Ein Patient darf immer nur genau einen gültigen Datensatz haben.
  patients_from_database <- etlutils::collapseRowsByGroup(patients_from_database, group_col = "pat_id")

  # Load the existing record IDs from the database
  existing_record_ids <- loadExistingRecordIDsFromDB(patients_from_database$pat_id)
  patient_fe <- createPatientFrontendTable(patients_from_database, existing_record_ids)
  fall_fe <- createEncounterFrontendTable(pids_per_ward, patients_from_database, existing_record_ids)
  # Create and write frontend table for patients and encounters
  etlutils::dbWriteTables(
    tables = etlutils::namedListByParam(patient_fe, fall_fe),
    lock_id = "createFrontendTables()",
    stop_if_table_not_empty = TRUE)

}
