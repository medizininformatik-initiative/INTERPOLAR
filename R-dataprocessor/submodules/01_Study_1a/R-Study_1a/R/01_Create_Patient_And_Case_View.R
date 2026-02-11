#' Generate Location String from Encounter Data
#'
#' Creates a formatted location string using the most recent encounter location entries of type
#' "ro" (room) and "bd" (bed). The displayed values are taken from the column specified by the
#' global variable `FRONTEND_DISPLAYED_ROOM_AND_BED_COLUMN`. The function only processes
#' encounters where `enc_location_physicaltype_code` is either "ro" or "bd", and within those only
#' the most recent entries based on `enc_period_start`.
#'
#' The function assumes that the required column exists in the input data. If not, an error is
#' raised intentionally and must be handled by the calling context.
#'
#' @param encounters A `data.table` containing encounter location records.
#' @param locations A `data.table` containing location details.
#'
#' @return A character string in the format "Zimmer: <room>; Bett: <bed>". If no matching entry
#' is found, "-" is used as fallback.
#'
#' @examples
#' \dontrun{
#' FRONTEND_DISPLAYED_ROOM_AND_BED_COLUMN <- "location_display"
#' dt <- data.table::data.table(
#'   enc_location_physicaltype_code = c("ro", "bd"),
#'   enc_period_start = as.POSIXct(c("2024-01-01", "2024-01-01")),
#'   location_display = c("R12", "B3")
#' )
#' getLocationString(dt)
#' }
#'
getLocationString <- function(encounters, locations) {
  room <- "-"
  bed <- "-"

  if (etlutils::isDefinedAndNotEmpty("FRONTEND_DISPLAYED_ROOM_AND_BED_COLUMN")) {

    # Filter for relevant physical types
    encounters <- encounters[enc_location_physicaltype_code %in% c("ro", "bd")]

    if (nrow(encounters) & !all(is.na(encounters$enc_period_start))) {
      room_value <- NA_character_
      bed_value <- NA_character_
      # Keep only rows with latest period start
      encounters <- encounters[enc_period_start %in% etlutils::getMaxDatetime(enc_period_start)]

      room_encounter <- encounters[enc_location_physicaltype_code %in% "ro"]
      room_encounter <- if (nrow(room_encounter)) room_encounter[1] else NULL

      bed_encounter <- encounters[enc_location_physicaltype_code %in% "bd"]
      bed_encounter <- if (nrow(bed_encounter)) bed_encounter[1] else NULL

      col_name <- FRONTEND_DISPLAYED_ROOM_AND_BED_COLUMN

      if (startsWith(col_name, "loc_")) {
        # Room
        if (!is.null(room_encounter)) {
          room_location_ref <- room_encounter[, get("enc_location_ref")]
          room_location_id <- etlutils::fhirdataExtractIDs(room_location_ref)
          room_value <- tryCatch(
            locations[loc_id %in% room_location_id, get(col_name)],
            error = function(e) NA_character_
          )
        }
        # Bed
        if (!is.null(bed_encounter)) {
          bed_location_ref <- bed_encounter[, get("enc_location_ref")]
          bed_location_id <- etlutils::fhirdataExtractIDs(bed_location_ref)
          bed_value <- tryCatch(
            locations[loc_id %in% bed_location_id, get(col_name)],
            error = function(e) NA_character_
          )
        }
      } else if (startsWith(col_name, "enc_")) {
        # Room
        if (!is.null(room_encounter) && !is.null(col_name)) {
          room_value <- tryCatch(room_encounter[, get(col_name)], error = function(e) NA_character_)
        }
        # Bed
        if (!is.null(bed_encounter) && !is.null(col_name)) {
          bed_value <- tryCatch(bed_encounter[, get(col_name)], error = function(e) NA_character_)
        }
      }
      if (etlutils::isSimpleNotEmptyString(room_value)) room <- room_value
      if (etlutils::isSimpleNotEmptyString(bed_value)) bed <- bed_value
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
  admission_diagnoses <- encounter[enc_diagnosis_use_code %in% "AD"]$enc_diagnosis_condition_ref
  if (!any(encounter$enc_diagnosis_use_code %in% "AD")) return(NA_character_)
  admission_diagnoses <- unique(admission_diagnoses)
  admission_diagnoses <- etlutils::fhirdataExtractIDs(admission_diagnoses)
  admission_diagnoses <- conditions[con_id %in% admission_diagnoses, .(con_code_text, con_code_code, con_code_display)]
  admission_diagnoses <- unique(admission_diagnoses)

  return_value <- character()
  for (i in seq_len(nrow(admission_diagnoses))) {
    row <- admission_diagnoses[i]
    if (!is.na(row$con_code_text) && nzchar(trimws(row$con_code_text))) {
      diagnosis_text <- row$con_code_text
    } else if (!is.na(row$con_code_display) && nzchar(trimws(row$con_code_display))) {
      diagnosis_text <- row$con_code_display
    } else {
      diagnosis_text <- NULL
    }
    if (!is.null(diagnosis_text)) {
      diagnosis_text <- paste0(diagnosis_text, " (", row$con_code_code, ")")
    } else {
      diagnosis_text <- row$con_code_code
    }
    return_value <- c(return_value, diagnosis_text)
  }

  return_value <- paste0(return_value, collapse = "\n")
  return(if(nzchar(return_value)) return_value else NA_character_)
}

getObservations <- function(encounters, query_datetime, obs_codes, obs_system, obs_by_pid = FALSE) {

  obs_codes <- parseQueryList(obs_codes)
  # Query template to get desired Observations from DB
  query_template <- paste0("SELECT * FROM v_observation\n",
                           "  WHERE obs_code_code IN ", obs_codes, " AND\n",
                           "        obs_code_system = '", obs_system, "' AND\n",
                           "        obs_effectivedatetime < '", query_datetime, "' AND\n")

  enc_patient_refs <- unique(encounters$enc_patient_ref)

  if (isFALSE(obs_by_pid)) {
    enc_refs <- fhirdataGetReference("Encounter", (unique(encounters$enc_id)))
    enc_query_refs <- etlutils::fhirdbGetQueryList(enc_refs)
    # Extract the Observations by direct encounter references
    additional_query_condition <- paste0("        obs_encounter_calculated_ref IN ", enc_query_refs, "\n")
    query <- paste0(query_template, additional_query_condition)
    observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[1]")
  } else {
    pat_query_refs <- etlutils::fhirdbGetQueryList(enc_patient_refs)
    # Extract Observations by patient ID, but without any references to the encounter
    additional_query_condition <- paste0("        obs_patient_ref IN ", pat_query_refs, "\n")
    query <- paste0(query_template, additional_query_condition)

    observations <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getObservation()[3]")
  }

  # keep the very first Observation with the latest date (should be only 1 but sure is sure)
  # for every patient
  if (nrow(observations)) {
    unique_pat_refs <- unique(observations$obs_patient_ref)
    result <- data.table::data.table(
      obs_id = character(),
      obs_patient_ref = character(),
      obs_encounter_calculated_ref = character(),
      obs_code_code = character(),
      obs_code_system = character(),
      obs_effectivedatetime = as.POSIXct(character()),
      obs_valuequantity_value = numeric(),
      obs_valuequantity_code = character(),
      obs_valuequantity_unit = character()
    )
    for (pat_ref in unique_pat_refs) {
      patient_obs <- observations[obs_patient_ref %in% pat_ref & !is.na(obs_effectivedatetime)]
      # Select the first Observation with the latest effective date
      if (nrow(patient_obs) > 0) {
        selected_obs <- patient_obs[obs_effectivedatetime %in% max(obs_effectivedatetime, na.rm = TRUE)][1]
        # Only keep columns matching the result table structure
        selected_obs <- selected_obs[, names(result), with = FALSE]
        result <- rbind(result, selected_obs, use.names = TRUE)
      }
    }
    observations <- result
  }
  return(observations)
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
    pids <- pids[!is.na(pids) & pids != "EMPTY_DATA"]
    patients <- loadResourcesLastVersionByOwnIDFromDB("Patient", pids)
    return(patients)
  }

  # Restore pids_per_ward from previous runs from frontend data (to find encounters, which were not finished in the previous run)
  getPreviousPidsPerWard <- function() {
    query <- paste0(
      "SELECT DISTINCT t1.fall_station, t1.fall_pat_id, t1.fall_fhir_enc_id, t1.last_processing_nr\n",
      "FROM v_fall_fe t1\n",
      "WHERE NOT EXISTS (\n",
      "  SELECT 1\n",
      "  FROM v_fall_fe t2\n",
      "  WHERE t2.fall_pat_id = t1.fall_pat_id\n",
      "    AND t2.fall_fhir_enc_id = t1.fall_fhir_enc_id\n",
      "    AND t2.fall_status = 'finished'\n",
      ")"
    )
    previous_pids <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getPidsFromDatabase()")
    previous_pids_per_ward <- previous_pids[, .SD[which.max(last_processing_nr)], by = .(fall_pat_id, fall_fhir_enc_id)]
    previous_pids_per_ward[, last_processing_nr := NULL]
    data.table::setnames(previous_pids_per_ward,
                         old = c("fall_station", "fall_pat_id", "fall_fhir_enc_id"),
                         new = c("ward_name", "patient_id", "encounter_id"))
    return(previous_pids_per_ward)
  }

  # Read the latest imported datasets from the pids_per_ward table
  getPidsPerWard <- function() {
    pids_per_ward <- etlutils::dbGetReadOnlyQuery(
      query = paste0("SELECT ward_name, patient_id, encounter_id FROM v_pids_per_ward_last_import\n"),
      lock_id = "load last imported datasets from pids_per_ward")
    pids_per_ward <- pids_per_ward[!is.na(patient_id)]
    previous_pids_per_ward <- getPreviousPidsPerWard()
    # Filter all rows from previous_pids_per_ward where the patient_id does not appear in the table pids_per_ward.
    previous_pids_per_ward_filtered <- previous_pids_per_ward[
      !patient_id %in% pids_per_ward$patient_id
    ]
    pids_per_ward <- unique(rbind(pids_per_ward, previous_pids_per_ward_filtered, use.names = TRUE))
    return(pids_per_ward)
  }

  # Function to retrieve an existing record_id for a given patient ID
  getExistingRecordID <- function(pat_id, default = NA_character_, existing_record_ids) {
    # Remove duplicates and keep the first record_id for each pat_id
    existing_record_ids <- existing_record_ids[order(record_id)][, .SD[1], by = pat_id]
    specific_pat_id <- pat_id
    # Get existing_record_id for the specific pat_id
    existing_record_id <- unique(existing_record_ids[pat_id %in% specific_pat_id, record_id])

    if (!length(existing_record_id)) {
      # If the default value is a vector, take the lowest value
      existing_record_id <- sort(default, na.last = TRUE)[1]
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
    patient_frontend_table <- data.table::data.table(
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
    enc_frontend_table <- data.table::data.table(
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
      fall_additional_values = character(),
      fall_complete = character()
    )

    getExistingFallFeRedcapRepeatInstance <- function(existing_record_ids) {
      column_names <- c("record_id",
                        "fall_fhir_enc_id",
                        "redcap_repeat_instance")
      query <- paste0(
        "SELECT ", paste(column_names, collapse = ", "), " \n",
        "FROM v_fall_fe\n",
        "WHERE record_id IN ", etlutils::fhirdbGetQueryList(existing_record_ids$record_id), "\n"
      )
      existing_fallfe_redcap_repeat_instance <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getExistingFallFeRedcapRepeatInstance()")
      return(existing_fallfe_redcap_repeat_instance)
    }

    existing_repeat_instances <- getExistingFallFeRedcapRepeatInstance(existing_record_ids)

    encounters <- etlutils::fhirdataGetAllEncounters(encounter_ids = unique(pids_per_ward$encounter_id),
                                                     lock_id_extension = "CreateEncounterFrontendTable()_")

    # If the CDS-conform 3-level encounter system has been implemented, then enc_type_system must
    # contain "http://fhir.de/CodeSystem/Kontaktebene"
    encounters <- encounters[enc_type_system %in% "http://fhir.de/CodeSystem/Kontaktebene" | enc_type_code %in% c("einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt")]
    if (!nrow(encounters)) {
      stop("All Encounters has not CDS conform Encounter system. If the CDS-conform 3-level encounter system has been implemented, then enc_type_system must contain 'http://fhir.de/CodeSystem/Kontaktebene'")
    }

    location_refs <- na.omit(unique(encounters$enc_location_ref))
    locations <- loadResourcesLastVersionByOwnIDFromDB("Location", location_refs)

    query_datetime_obs <- getObservationQueryDatetime(encounters)

    # Create a new table with rows where enc_partof_ref is NOT NA
    part_of_encounters <- encounters[!is.na(enc_partof_calculated_ref)]

    # Remove the rows that exist in part_of_encounters from encounters
    main_encounters <- encounters[!enc_id %in% part_of_encounters$enc_id & enc_type_code %in% "einrichtungskontakt"]

    # load Conditions referenced by Encounters
    query_ids <- etlutils::fhirdbGetQueryList(encounters$enc_diagnosis_condition_ref,
                                              remove_ref_type = TRUE)
    query <- paste0("SELECT * FROM v_condition\n",
                    "  WHERE con_id IN ", query_ids, "\n")
    conditions <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[2]")

    observations_weight <- getObservations(encounters, query_datetime_obs, OBSERVATION_BODY_WEIGHT_CODES, OBSERVATION_BODY_WEIGHT_SYSTEM)
    observations_height <- getObservations(encounters, query_datetime_obs, OBSERVATION_BODY_HEIGHT_CODES, OBSERVATION_BODY_HEIGHT_SYSTEM, obs_by_pid = TRUE)

    # Create a new data.table with only pid and ward_name, ensuring unique rows
    unique_pid_ward <- unique(pids_per_ward[, .(patient_id, ward_name)])

    main_encounters_ids <- paste0("('", paste(unique(main_encounters$enc_id), collapse = "','"), "')")
    column_names <- c("fall_fhir_enc_id",
                      "fall_studienphase")

    query <- paste0(
      "SELECT DISTINCT ON (fall_fhir_enc_id) ",
      paste(column_names, collapse = ", "), "\n",
      "FROM v_fall_fe\n",
      "WHERE fall_fhir_enc_id IN ", main_encounters_ids, "\n",
      "ORDER BY fall_fhir_enc_id, input_datetime ASC"
    )

    enc_studyphase_at_admission <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createEncounterFrontendTable()[3]")

    for (pid_index in seq_len(nrow(unique_pid_ward))) {

      pid <- unique_pid_ward$patient_id[pid_index]
      pid_ref <- etlutils::fhirdataGetPatientReference(pid)
      pid_main_encounters <- main_encounters[enc_patient_ref %in% pid_ref]
      pid_part_of_encounters <- part_of_encounters[enc_patient_ref %in% pid_ref]

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

      # This is used to print it in the additional values to check the correctness
      pid_main_encounter_ids <- unique(pid_main_encounters$enc_id)

      # Create a list of data.tables, each containing the rows for a specific encounter
      pid_main_encounters <- split(pid_main_encounters, pid_main_encounters$enc_id)

      # Get the patient lines for the current PID
      pid_patient <- patients[pat_id %in% pid]

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
        if (etlutils::isDefinedAndNotEmpty("COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM")) {
          filtered_rows <- pid_encounter[enc_identifier_system %in% COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM]
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

        # Store all known Encounter IDs in toml syntax in the additional values
        fall_additional_values <- ""
        fall_additional_values <- etlutils::tomlAppendVector(fall_additional_values,
                                                             pid_main_encounter_ids,
                                                             key = "main_encounters",
                                                             comment = "FHIR ID of all main Encounter(s) for the medical case (should be exactly one)")
        fall_additional_values <- etlutils::tomlAppendVector(fall_additional_values,
                                                             unique(pid_part_of_encounters$enc_id),
                                                             key = "part_encounters",
                                                             comment = "FHIR ID of all Encounters for the medical case at this point which are not the main Encounter")
        data.table::set(enc_frontend_table, target_index, "fall_additional_values", fall_additional_values)

        # set fall_complete (derived from FHIR Encounter.status)
        # see https://github.com/medizininformatik-initiative/INTERPOLAR/issues/274
        fall_complete <- grepl("^finished$|^cancelled$|^entered-in-error$", enc_status, ignore.case = TRUE)
        fall_complete <- ifelse(fall_complete, "Complete", "Incomplete")
        data.table::set(enc_frontend_table, target_index, "fall_complete", fall_complete)

        # Extract ward name from unique_pid_ward table
        ward_name <- unique_pid_ward$ward_name[pid_index]
        data.table::set(enc_frontend_table, target_index, "fall_station", ward_name)

        study_phase <- NA_character_

        if(nrow(enc_studyphase_at_admission)) {
          # Get the study phase at admission for the Encounter if it exists in the database (fall_fe table)
          study_phase <- enc_studyphase_at_admission[
            fall_fhir_enc_id == enc_id,
            fall_studienphase
          ][1L]
        }

        # Get the current study phase for the ward of the Encounter
        if (!etlutils::isSimpleNotEmptyString(study_phase)) {
          study_phase <- getStudyPhase(ward_name)
        }

        if (is.na(study_phase)) {
          stop("ERROR: No study phase found for ward '", ward_name, "'.\n",
               "Please check the study phase configuration in the dataprocessor_config.toml for parameters WARDS_PHASE_A, WARDS_PHASE_B_TEST and WARDS_PHASE_B.")
        }
        data.table::set(enc_frontend_table, target_index, "fall_studienphase", study_phase)

        # Extract the admission diagnoses
        admission_diagnoses <- getAdmissionDiagnoses(pid_encounter, conditions)
        data.table::set(enc_frontend_table, target_index, "fall_aufn_diag", admission_diagnoses)

        # Call the function with the filtered_pid_part_of_encounters data and the location_labels
        room_and_bed <- getLocationString(pid_part_of_encounters, locations)
        data.table::set(enc_frontend_table, target_index, "fall_zimmernr", room_and_bed)

        obs_weight <- observations_weight[obs_patient_ref %in% pid_ref]
        if (nrow(obs_weight)) {
          data.table::set(enc_frontend_table, target_index, "fall_gewicht_aktuell", obs_weight$obs_valuequantity_value)
          data.table::set(enc_frontend_table,
                          target_index,
                          "fall_gewicht_aktl_einheit",
                          data.table::fifelse(
                            etlutils::isValidUnit(obs_weight$obs_valuequantity_code),
                            obs_weight$obs_valuequantity_code,
                            obs_weight$obs_valuequantity_unit
                          )
          )

        }
        obs_height <- observations_height[obs_patient_ref %in% pid_ref]
        if (nrow(obs_height)) {
          data.table::set(enc_frontend_table, target_index, "fall_groesse", obs_height$obs_valuequantity_value)
          data.table::set(enc_frontend_table,
                          target_index,
                          "fall_groesse_einheit",
                          data.table::fifelse(
                            etlutils::isValidUnit(obs_height$obs_valuequantity_code),
                            obs_height$obs_valuequantity_code,
                            obs_height$obs_valuequantity_unit
                          )
          )
        }

        # For unknown reasons, a BMI written to the RedCap is always written back from the
        # RedCap to the database as an empty value, which duplicates the entire data record.
        # As the cause could not be found, we have simply deactivated the field for the time
        # being. It is not currently displayed in the RedCap anyway.
        #getObservation(OBSERVATION_BMI_CODES, OBSERVATION_BMI_SYSTEM, "fall_bmi")

        # Fill redcap_repeat_instance column in table enc_frontend_table
        enc_redcap_repeat_instance <- unique(na.omit(existing_repeat_instances[fall_fhir_enc_id == enc_id, redcap_repeat_instance]))

        if (length(enc_redcap_repeat_instance)) {
          # Case 1: The enc_id already appears as fall_fhir_enc_id → use the corresponding max instance
          enc_redcap_repeat_instance <- max(as.integer(enc_redcap_repeat_instance)) # should be exactly 1, but max() ensures this...
        } else {
          # Case 2: The enc_id does not appear → determine max + 1 within the group (grouped by record_id)
          enc_record_id <- record_id  # rename to use this variable in data.table syntax
          enc_redcap_repeat_instance <- na.omit(existing_repeat_instances[record_id == enc_record_id, redcap_repeat_instance])
          if (length(enc_redcap_repeat_instance)) {
            enc_redcap_repeat_instance <- max(as.integer(enc_redcap_repeat_instance)) + 1
          } else {
            enc_redcap_repeat_instance <- 1
          }
          existing_repeat_instances <- etlutils::addTableRow(existing_repeat_instances, record_id, enc_id, enc_redcap_repeat_instance)
        }
        data.table::set(enc_frontend_table, target_index, "redcap_repeat_instance", enc_redcap_repeat_instance)
      }

    }
    return(enc_frontend_table)
  }

  # Load the pids_per_ward table from the database and combine it with the previous pids_per_ward table
  pids_per_ward <- getPidsPerWard()

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

  # some simple test data for the following function
  # patients_from_database <- data.table(
  #   pat_id = c(1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6),
  #   patient_id = c(101, 102, 201, 202, 301, 302, 401, 501, 502, 601, 602),
  #   pat_name_use = c("official", "usual", "official", "official", NA, NA, NA, NA, NA, NA, "official"),
  #   pat_name_given = c("John", "", "", "Anna", "", "Paul", "Lara", NA, NA, NA, NA),
  #   pat_identifier_value = c("A1", "A1", "B1", "B2", "C1", "C1", "D1", "E1", "E1", "F1", "F2")
  # )

  getUniquePatientsRowWithNameIfExists <- function(patient_rows_from_database_for_single_pat_id) {
    pat_rows <- patient_rows_from_database_for_single_pat_id
    # Check if the column 'pat_name_use' exists and contains any "official" entries
    if ("pat_name_use" %in% names(pat_rows)
        && any(pat_rows$pat_name_use %in% "official", na.rm = TRUE)) {
      # Filter rows where name is "official" and there is a non-empty, non-NA given name
      official_rows <- pat_rows[pat_name_use %in% "official" & pat_name_given != "" & !is.na(pat_name_given)]
      # If such official rows exist, return the one with the smallest patient_id
      if (nrow(official_rows)) {
        return(official_rows[which.min(patient_id)])
      }
    }
    # If no "official" name exists or the column doesn't exist, fall back to row with smallest patient_id
    rows_with_name <- pat_rows[pat_name_given != "" & !is.na(pat_name_given)]
    if (nrow(rows_with_name)) {
      return(rows_with_name[which.min(patient_id)])
    }
    # If no rows with a name exist, return the row with the smallest patient_id
    return(pat_rows[which.min(patient_id)])
  }

  # The following code is a workaround for the problem that the same patient can have multiple
  # identifiers or names in the database, which can lead to multiple entries in the patient table.
  # The code filters the patients based on the pat_name_use = "offical". If there is a official name,
  # it keeps only the first occurrence of that name. If there is no official name, it keeps the
  # occurrence with the minimum patient_id. This is done to ensure that only one entry per patient
  # is kept in the patient table.
  # Fallback: Keep only the rows of each 'pat_id' where the 'pat_identifier_value' matches the
  # respective row with the minimum 'patient_id'.
  patients_from_database <- patients_from_database[, getUniquePatientsRowWithNameIfExists(.SD), by = pat_id]

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
