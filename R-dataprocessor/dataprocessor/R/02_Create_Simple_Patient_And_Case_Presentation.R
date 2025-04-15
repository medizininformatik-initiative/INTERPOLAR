#' Generate Location String from Encounter Data
#'
#' Creates a formatted location string using the most recent encounter location entries of type
#' "ro" (room) and "bd" (bed). The displayed values are taken from the column specified by the
#' global variable `FRONTEND_DISPLAYED_ROOM_AND_BED_ENCOUNTER_COLUMN`. The function only processes
#' encounters where `enc_location_physicaltype_code` is either "ro" or "bd", and within those only
#' the most recent entries based on `enc_period_start`.
#'
#' The function assumes that the required column exists in the input data. If not, an error is
#' raised intentionally and must be handled by the calling context.
#'
#' @param encounters A `data.table` containing encounter location records.
#'
#' @return A character string in the format "Zimmer: <room>; Bett: <bed>". If no matching entry
#' is found, "-" is used as fallback.
#'
#' @examples
#' \dontrun{
#' FRONTEND_DISPLAYED_ROOM_AND_BED_ENCOUNTER_COLUMN <- "location_display"
#' dt <- data.table::data.table(
#'   enc_location_physicaltype_code = c("ro", "bd"),
#'   enc_period_start = as.POSIXct(c("2024-01-01", "2024-01-01")),
#'   location_display = c("R12", "B3")
#' )
#' getLocationString(dt)
#' }
#'
getLocationString <- function(encounters) {
  room <- "-"
  bed <- "-"

  if (etlutils::isDefinedAndNotEmpty("FRONTEND_DISPLAYED_ROOM_AND_BED_ENCOUNTER_COLUMN")) {
    # Filter for relevant physical types
    encounters <- encounters[enc_location_physicaltype_code %in% c("ro", "bd")]

    if (nrow(encounters)) {
      # Keep only rows with latest period start
      encounters <- encounters[enc_period_start == max(enc_period_start)]

      col_name <- FRONTEND_DISPLAYED_ROOM_AND_BED_ENCOUNTER_COLUMN

      room_value <- encounters[enc_location_physicaltype_code == "ro"][1, get(col_name)]
      if (length(room_value)) room <- room_value

      bed_value <- encounters[enc_location_physicaltype_code == "bd"][1, get(col_name)]
      if (length(bed_value)) bed <- bed_value
    }
  }

  location_string <- sprintf("Zimmer: %s  Bett: %s", room, bed)
  return(location_string)
}

#' Extract Admission Diagnoses as a Formatted String
#'
#' This function extracts all diagnoses with the use code \code{"AD"} (admission diagnoses)
#' from an encounter data table, resolves the referenced condition IDs, and matches them
#' to the corresponding condition entries. The diagnoses are then formatted as a single
#' character string. If the diagnosis text is available, it is used along with the code in
#' parentheses; otherwise, only the code is used.
#'
#' @param encounter A \code{data.table} containing encounter diagnosis information.
#'                  Must include the columns \code{enc_diagnosis_use_code} and \code{enc_diagnosis_condition_ref}.
#' @param conditions A \code{data.table} containing condition details.
#'                   Must include the columns \code{con_id}, \code{con_code_text}, and \code{con_code_code}.
#'
#' @return A single \code{character} string with all admission diagnoses separated by \code{"; "}.
#'         If no diagnoses are found, or no usable text/code is available, returns \code{NA_character_}.
#'
getAdmissionDiagnoses <- function(encounter, conditions) {
  admission_diagnoses <- encounter[enc_diagnosis_use_code == "AD"]$enc_diagnosis_condition_ref
  admission_diagnoses <- unique(admission_diagnoses)
  admission_diagnoses <- etlutils::fhirdataExtractIDs(admission_diagnoses)
  admission_diagnoses <- conditions[con_id %in% admission_diagnoses, .(con_code_text, con_code_code)]
  admission_diagnoses <- unique(admission_diagnoses)

  return_value <- character()
  for (i in seq_len(nrow(admission_diagnoses))) {
    row <- admission_diagnoses[i]
    if (!is.na(row$con_code_text) && nzchar(trimws(row$con_code_text))) {
      diagnosis_text <- paste0(row$con_code_text, " (", row$con_code_code, ")")
    } else {
      diagnosis_text <- row$con_code_code
    }
    return_value <- c(return_value, diagnosis_text)
  }

  return_value <- paste0(return_value, collapse = "\n")
  return(if (nzchar(return_value)) return_value else NA_character_)
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
    pids <- etlutils::fhirdataExtractIDs(pids)
    patients <- loadResourcesLastStatusByOwnIDFromDB("Patient", pids)
    return(patients)
  }

  # Function to load existing record IDs from the database for a list of patient IDs
  loadExistingRecordIDsFromDB <- function(pat_ids) {
    query_ids <- etlutils::fhirdbGetQueryList(pat_ids)
    query <- paste0("SELECT pat_id, record_id FROM v_patient_fe WHERE pat_id IN (", query_ids, ")")
    existing_record_ids <- etlutils::dbGetReadOnlyQuery(query, lock_id = "cacheExistingRecordIDs()")
    return(existing_record_ids)
  }

  # Function to retrieve an existing record_id for a given patient ID
  getExistingRecordID <- function(pat_id, default = NA_character_, existing_record_ids) {
    # Remove duplicates and keep the first record_id for each pat_id
    existing_record_ids <- existing_record_ids[order(record_id)][, .SD[1], by = pat_id]
    specific_pat_id <- pat_id
    # Get existing_record_id for the specific pat_id
    existing_record_id <- unique(existing_record_ids[pat_id == specific_pat_id, record_id])

    if (!length(existing_record_id)) {
      # If the default value is a vector, take the lowest value
      existing_record_id <- sort(default)[1]
    }
    return(existing_record_id)
  }

  # This function creates a table for frontend display containing patient information
  # based on the provided patient IDs per ward. It retrieves patient information from
  # the database and constructs the frontend table.
  createPatientFrontendTable <- function(patients, existing_record_ids) {

    pids <- unique(patients$pat_id)
    pids_count <- length(pids)

    # Initialize an empty data table with a fix number of rows to store patient information
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
      patient_frontend_table$pat_id[i] <- etlutils::getFirstNonNAValue(patient$pat_id)
      patient_frontend_table$pat_cis_pid[i] <- etlutils::getFirstNonNAValue(patient$pat_identifier_value)
      patient_frontend_table$pat_vorname[i] <- etlutils::getFirstNonNAValue(patient$pat_name_given)
      patient_frontend_table$pat_name[i] <- etlutils::getFirstNonNAValue(patient$pat_name_family)
      patient_frontend_table$pat_gebdat[i] <- etlutils::getFirstNonNAValue(patient$pat_birthdate)
      patient_frontend_table$pat_geschlecht[i] <- etlutils::getFirstNonNAValue(patient$pat_gender)
      # see https://github.com/medizininformatik-initiative/INTERPOLAR/issues/274
      patient_frontend_table$patient_complete[i] <- 'Complete'
    }
    return(patient_frontend_table)
  }

  # This function creates a table for frontend display containing encounter information
  # based on the provided patient IDs per ward. It retrieves encounter information from
  # the database and constructs the frontend table.
  createEncounterFrontendTable <- function(pids_per_ward, patients, existing_record_ids) {
    # Initialize an empty data table with no rows to store encounter information.
    # The rows will be added later via rbind in the function addEmptyRows().
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
    encounters <- etlutils::fhirdataGetAllEncounters(pids_per_ward$encounter_id, "CreateEncounterFrontendTable()_")

    query_datetime <- getQueryDatetime(encounters)

    # Create a new table with rows where enc_partof_ref is NOT NA
    part_of_encounters <- encounters[!is.na(enc_partof_ref)]

    # Second way to find all partof encounters
    part_of_encounters_2 <- encounters[enc_type_code != "einrichtungskontakt"]
    part_of_encounters_2 <- data.table::fsetdiff(part_of_encounters_2, part_of_encounters)
    if (nrow(part_of_encounters_2)) {
      part_of_encounters <- rbind(part_of_encounters, part_of_encounters_2)
    }

    # Remove the rows that exist in part_of_encounters from encounters
    main_encounters <- encounters[!enc_id %in% part_of_encounters$enc_id]

    # load Conditions referenced by Encounters
    query_ids <- etlutils::fhirdbGetQueryList(encounters$enc_diagnosis_condition_ref,
                                              remove_ref_type = TRUE)
    query <- paste0("SELECT * FROM v_condition\n",
                    "  WHERE con_id IN (", query_ids, ")\n")
    conditions <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[2]")

    # Create a new data.table with only pid and ward_name, ensuring unique rows
    unique_pid_ward <- unique(pids_per_ward[, .(patient_id, ward_name)])

    for (pid_index in seq_len(nrow(unique_pid_ward))) {

      pid <- unique_pid_ward$patient_id[pid_index]
      pid_ref <- etlutils::fhirdataGetPatientReference(pid)
      pid_main_encounters <- main_encounters[enc_patient_ref == pid_ref]
      pid_part_of_encounters <- part_of_encounters[enc_patient_ref == pid_ref]

      # check possible errors
      if (!nrow(pid_main_encounters)) { # no encounter for PID found
        etlutils::catErrorMessage(paste0("No Einrichtungskontakt found for PID ", pid))
        next
      }

      # Extract unique encounter IDs for the current patient
      unique_encounter_IDs <- unique(pid_main_encounters$enc_id)
      # if there are errors in the data then there can be more than one encounter
      if (length(unique_encounter_IDs) > 1) {
        etlutils::catErrorMessage(paste0("Multiple Encounters found for PID ", pid, "\n",
                                         "  Encounter-IDs: ", paste0(unique_encounter_IDs, collapse = ", "), "\n"))
      }

      # Create a list of data.tables, each containing the rows for a specific encounter
      pid_main_encounters <- split(pid_main_encounters, pid_main_encounters$enc_id)

      # Get the patient lines for the current PID
      pid_patient <- patients[pat_id == pid]

      # Check errors no patient resource found for PID
      if (!nrow(pid_patient)) { # no Patient resource found for PID
        etlutils::catErrorMessage(paste0("No Patient resources found for PID ", pid))
        next
      }

      # Initialize start index for adding rows to the frontend table
      start_index <- nrow(enc_frontend_table)
      enc_frontend_table <- etlutils::addEmptyRows(enc_frontend_table, length(unique_encounter_IDs), "end")

      # Iterate over each encounter for the current patient
      for (i in 1:length(pid_main_encounters)) {
        target_index <- start_index + i

        pid_encounter <- pid_main_encounters[[i]]
        # There can be multiple lines for the same Encounter if there are multiple conditions
        # present for the case which were splitted by fhir_melt (in cds2db) to multiple lines.
        # Take the common data (ID, start, end, status) from the first line
        enc_id               <- etlutils::getFirstNonNAValue(pid_encounter$enc_id)
        enc_period_start     <- etlutils::as.POSIXctWithTimezone(etlutils::getFirstNonNAValue(pid_encounter$enc_period_start))
        enc_period_end       <- etlutils::as.POSIXctWithTimezone(etlutils::getFirstNonNAValue(pid_encounter$enc_period_end))
        enc_status           <- etlutils::getFirstNonNAValue(pid_encounter$enc_status)
        record_id <- getExistingRecordID(etlutils::getFirstNonNAValue(pid_patient$pat_id),
                                         default = etlutils::getFirstNonNAValue(pid_patient$patient_id),
                                         existing_record_ids)

        # Extract the FHIR identifier value for the frontend table
        # There can be multiple rows with different identifier systems, so we need to filter them
        # out first and then combine the values into a single string, if there are multiple values.
        if (exists("FRONTEND_DISPLAYED_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM") &&
            nzchar(FRONTEND_DISPLAYED_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM)) {
          filtered_rows <- pid_encounter[grepl(FRONTEND_DISPLAYED_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM, enc_identifier_system)]
          if (nrow(filtered_rows)) {
            enc_identifier_value <- paste(unique(filtered_rows$enc_identifier_value), collapse = ", ")
          } else {
            enc_identifier_value <- NA_character_
          }
        } else {
          enc_identifier_value <- etlutils::getFirstNonNAValue(pid_encounter$enc_identifier_value)
        }

        # Set the values for the encounter frontend table
        data.table::set(enc_frontend_table, target_index, "record_id", record_id)
        data.table::set(enc_frontend_table, target_index, "fall_id", enc_identifier_value)
        # There can be multiple lines for pat_id, but the value should be always the same.
        data.table::set(enc_frontend_table, target_index, "fall_pat_id", etlutils::getFirstNonNAValue(pid_patient$pat_id))
        data.table::set(enc_frontend_table, target_index, "fall_fhir_enc_id", enc_id)
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

        # Extract the admission diagnoses
        admission_diagnoses <- getAdmissionDiagnoses(pid_encounter, conditions)
        data.table::set(enc_frontend_table, target_index, "fall_aufn_diag", admission_diagnoses)

        # Call the function with the filtered_pid_part_of_encounters data and the location_labels
        room_and_bed <- getLocationString(pid_part_of_encounters)
        data.table::set(enc_frontend_table, target_index, "fall_zimmernr", room_and_bed)

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

  # Read the latest imported datasets from the pids_per_ward table
  pids_per_ward <- etlutils::dbGetReadOnlyQuery(
    query = paste0("SELECT * FROM v_pids_per_ward_last_import\n"),
    lock_id = "load last imported datasets from pids_per_ward")
  pids_per_ward <- pids_per_ward[!is.na(patient_id)]

  # No pids_per_ward table found -> stop
  if (!nrow(pids_per_ward)) {
    message <- getErrorOrWarningMessage(
      text = "WARNING: The pids_per_ward table is empty.\n",
      tables = "pids_per_ward")
    stop(message)
  }

  # Load the Patient resources from database
  patients_from_database <- getPatientsFromDatabase(pids_per_ward)

  # Check error no Patient exists in the current patient database table
  if (!nrow(patients_from_database)) { #
    etlutils::catErrorMessage(paste0("No Patient resources found."))
    return(NA)
  }

  # Apply the filterRows function for each identifier system and return NA if no patients are left
  if (etlutils::isSimpleNA(patients_from_database <- etlutils::dtFilterRows(patients_from_database, "pat_identifier_system", FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM))) return(NA)
  if (etlutils::isSimpleNA(patients_from_database <- etlutils::dtFilterRows(patients_from_database, "pat_identifier_type_system", FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM))) return(NA)
  if (etlutils::isSimpleNA(patients_from_database <- etlutils::dtFilterRows(patients_from_database, "pat_identifier_type_code", FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE))) return(NA)

  # If a patient has been given any list value, e.g. an additional identifier to an existing
  # identifier that is not changed, then at least 2 data records are created in the patient table
  # after the fhir_melt, whereby one was already present in the DB and the other is newly added.
  # Now it can happen, for whatever reason, that the same patient has several different values
  # ('Identifier.value' or 'name.given') after filtering via the Identifier.system.
  # In this case, we assume that the first value (= the one with the lowest 'patient_id') is the
  # valid one. We now remove all lines per patient with an 'Identifier.value' that is not the same
  # as the last added 'Identifier.value'.
  # We then set the minimum (= last valid) 'patient_id' for all remaining lines per 'pat_id', as
  # this must be the data record ID from which all information is derived.

  # only keep the lines of a 'pat_id' where the 'pat_identifier_value' is the same as in the
  # respective line with the minimum = 'patient_id'. Minimum because if the patient has multiple
  # names (e.g. an administrative and a birth name) then there is the highest chance that the very
  # first line contains the administrative name because the DIC should put this most important name
  # as first name in FHIR.
  patients_from_database <- patients_from_database[, .SD[pat_identifier_value == pat_identifier_value[which.min(patient_id)]], by = pat_id]

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
