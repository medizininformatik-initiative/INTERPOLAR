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
    pids <- etlutils::extractIDsFromReferences(pids)
    patients <- etlutils::loadResourcesLastStatusByOwnIDFromDB("Patient", pids)
    return(patients)
  }

  # This function creates a table for frontend display containing patient information
  # based on the provided patient IDs per ward. It retrieves patient information from
  # the database and constructs the frontend table.
  createPatientFrontendTable <- function(patients) {

    pids <- unique(patients$pat_id)
    pids_count <- length(pids)

    # Initialize an empty data table to store patient information
    patient_frontend_table <- data.table::data.table(
      record_id = rep(NA_character_, times = pids_count), # v_patient -> patient_id
      patient_fe_id = NA_character_, # v_patient -> patient_id
      pat_id = NA_character_, # v_patient -> pat_id
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
    enc_frontend_table <- data.table::data.table(
      record_id	= character(), # v_patient -> patient_id
      fall_id	= character(), # v_encounter -> enc_id
      fall_pat_id	= character(), # v_patient -> pat_id
      patient_id_fk	= character(), # v_patient -> patient_id
      fall_fe_id	= character(), # v_encounter -> encounter_id
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

    # load Encounters for all PIDs
    query_datetime <- etlutils::getQueryDatetime()
    query_ids <- etlutils::getQueryList(pids_per_ward$patient_id)
    table_name <- etlutils::getViewTableName("encounter")

    query <- paste0( "SELECT * FROM ", table_name, "\n",
                     "  WHERE enc_patient_ref IN (", query_ids, ")\n",
                     "    AND enc_partof_ref IS NULL\n",
                     "    AND (enc_period_end IS NULL OR enc_period_end > '", query_datetime, "')\n",
                     "    AND enc_period_start <= '", query_datetime, "'"
    )

    if (exists("FRONTEND_DISPLAYED_ENCOUNTER_CLASS")) {
      enc_class_codes <- FRONTEND_DISPLAYED_ENCOUNTER_CLASS
      # create additional condition if there are class codes defined for the accepted encounters
      if (enc_class_codes == "") {
        additional_class_code_query <- ""
      } else {
        # Additional condition only if enc_class_codes is not empty
        additional_class_code_query <- paste0(" AND enc_class_code IN ('", paste(enc_class_codes, collapse = "', '"), "');")
      }
      query <- paste0(query, additional_class_code_query)
    }

    encounters <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[1]")

    if (exists("FRONTEND_DISPLAYED_ENCOUNTER_FILTER")) {
      #TODO AXS prüfen ob dieser Code durch die Funktion convertFilterPatterns aus cds2db ersetzt werden kann
      encounter_filter_patterns <- etlutils::getVarByNameOrDefaultIfMissing("FRONTEND_DISPLAYED_ENCOUNTER_FILTER")
      filter_patterns <- list()
      for (filter_pattern in encounter_filter_patterns) {
        and_conditions <- list()
        filter_pattern_conditions <- unlist(strsplit(filter_pattern, "\\+"))
        for (condition in filter_pattern_conditions) { # condition <- filter_pattern_conditions[1]
          condition_key_value <- unlist(strsplit(condition, "="))
          condition_column <- trimws(condition_key_value[1])
          condition_value <- etlutils::getBetweenQuotes(condition_key_value[2])
          and_conditions[[condition_column]] <- condition_value
        }
        filter_patterns[[paste0("Condition_", length(filter_patterns) + 1)]] <- and_conditions
      }
      encounters <- etlutils::filterResources(encounters, filter_patterns)
    }

    # load Conditions referenced by Encounters
    condition_ids <- encounters$enc_diagnosis_condition_id
    query_ids <- etlutils::getQueryList(condition_ids, remove_ref_type = TRUE)
    table_name <- etlutils::getViewTableName("condition")
    query <- paste0("SELECT * FROM ", table_name, "\n",
                    "  WHERE con_id IN (", query_ids, ")\n")

    conditions <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[2]")

    for (pid_index in seq_len(nrow(pids_per_ward))) {

      pid <- pids_per_ward$patient_id[pid_index]
      pid_encounters <- encounters[enc_patient_ref == pid]

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

      pid_patient <- patients[pat_id == etlutils::extractIDsFromReferences(pid)]

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
        enc_identifier_value <- pid_encounters[[i]]$enc_identifier_value[1]
        enc_period_start <- pid_encounters[[i]]$enc_period_start[1]
        enc_period_end <- pid_encounters[[i]]$enc_period_end[1]
        enc_status <- pid_encounters[[i]]$enc_status[1]
        data.table::set(enc_frontend_table, target_index, "record_id", pid_patient$patient_id)
        data.table::set(enc_frontend_table, target_index, "fall_id", enc_identifier_value)
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
        admission_diagnoses <- etlutils::extractIDsFromReferences(admission_diagnoses)
        admission_diagnoses <- conditions[con_id %in% admission_diagnoses]
        admission_diagnoses <- unique(admission_diagnoses$con_code_text)
        admission_diagnoses <- paste0(admission_diagnoses, collapse = "; ")
        data.table::set(enc_frontend_table, target_index, "fall_aufn_diag", admission_diagnoses)

        # Function to extract specific observations for the encounter
        getObservation <- function(codes, system, target_column_value, target_column_unit = NA) {
          codes <- etlutils::parseQueryList(codes)
          table_name <- etlutils::getViewTableName("observation")
          # Extract the Observations by direct encounter references
          query <- paste0("SELECT * FROM ", table_name, "\n",
                          "  WHERE obs_encounter_ref = 'Encounter/", enc_id, "' AND\n",
                          "        obs_code_code IN (", codes, ") AND\n",
                          "        obs_code_system = '", system, "' AND\n",
                          "        obs_effectivedatetime < '", query_datetime, "'\n")
          observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[1]")

          # we found no Observations with the direct encounter link so identify potencial
          # Observations by time overlap with the encounter period start and current date
          if (!nrow(observations)) {
            query <- paste0("SELECT * FROM ", table_name, "\n",
                            "  WHERE obs_patient_ref = '", pid, "' AND\n",
                            "        obs_code_code IN (", codes, ") AND\n",
                            "        obs_code_system = '", system, "' AND\n",
                            "        obs_effectivedatetime > '", enc_period_start, "' AND\n",
                            "        obs_effectivedatetime < '", query_datetime, "'\n")
            observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[2]")
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
  pids_per_ward_table_name <- etlutils::getViewTableName("pids_per_ward")
  pids_per_ward <- etlutils::loadLastImportedDatasetsFromDB(pids_per_ward_table_name)
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

  # make sure that it is a single patient resource by choosing the last of the potencial list
  # if there are multiple rows then all differen values of a column will be pasted as stings
  # delimited by "; " in one row
  patients_from_database <- etlutils::collapseRowsByGroup(patients_from_database, group_col = "pat_id")

  patient_fe <- createPatientFrontendTable(patients_from_database)
  fall_fe <- createEncounterFrontendTable(pids_per_ward, patients_from_database)
  # Create and write frontend table for patients and encounters
  etlutils::dbWriteTables(
    tables = etlutils::namedListByParam(patient_fe, fall_fe),
    lock_id = "createFrontendTables()",
    stop_if_table_not_empty = TRUE)

}
