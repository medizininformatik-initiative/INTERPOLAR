# Environment for saving the db_connnections
.db_connections_env <- new.env()

getDatabaseConnection <- function(schema_name) {
  connection_env_identifier <- as.character(sys.call()[2]) # get the schema variable name
  db_connection <- .db_connections_env[[connection_env_identifier]]
  if (is.null(db_connection)) {
    db_connection <- etlutils::dbConnect(dbname = DB_GENERAL_NAME,
                                         host = DB_GENERAL_HOST,
                                         port = DB_GENERAL_PORT,
                                         user = DB_DATAPROCESSOR_USER,
                                         password = DB_DATAPROCESSOR_PASSWORD,
                                         schema = schema_name)
    .db_connections_env[[connection_env_identifier]] <- db_connection
  }
  return(db_connection)
}

getDatabaseReadConnection <- function() getDatabaseConnection(DB_DATAPROCESSOR_SCHEMA_OUT)
getDatabaseWriteConnection <- function() getDatabaseConnection(DB_DATAPROCESSOR_SCHEMA_IN)

closeAllDatabaseConnections <- function() {
  for (db_connection_variable_name in ls(.db_connections_env)) {
    db_connection <- get(db_connection_variable_name, envir = .db_connections_env)
    etlutils::dbDisconnect(db_connection)
    rm(list = db_connection_variable_name, envir = .db_connections_env)
  }
}

getTablesWithNamePart <- function(db_connection, name_part) {
  name_part <- tolower(name_part)
  table_names <- etlutils::dbListTableNames(db_connection, FALSE)
  return(grep(name_part, table_names, fixed = TRUE, value = TRUE))
}

getFirstTableWithNamePart <- function(db_connection, name_part, stop_on_empty_result = TRUE) {
  table_names <- getTablesWithNamePart(db_connection, name_part)
  if (length(table_names) == 1) {
    return(table_names[1])
  } else if (length(table_names) > 1) {
    connection_display <- etlutils::getPrintString(db_connection)
    etlutils::stopWithError("There are multiple tables with name part '", name_part, "' found for DB connection ", connection_display, "\n",
                            "Tables: ", paste0(table_names, collapse = ","), "\n",
                            "Hint: choose the namepart so that the result tablename is unique.")
  } else if (stop_on_empty_result) {
    connection_display <- etlutils::getPrintString(db_connection)
    etlutils::stopWithError("No table with name part '", name_part, "' found for DB connection ", connection_display, "\n")
  }
}

loadAllDataWithLastTimestampFromDB <- function(table_name_part) {
  db_connection_read <- getDatabaseReadConnection()
  table_name <- getFirstTableWithNamePart(db_connection_read, table_name_part)
  statement <- paste0("SELECT * FROM ", table_name, "\n",
                      "   WHERE COALESCE(last_check_datetime, input_datetime) =\n",
                      "      (SELECT MAX(COALESCE(last_check_datetime, input_datetime)) FROM ", table_name, ");")
  etlutils::dbGetQuery(db_connection_read, statement)
}

getCurrentDatetime <- function() {
  if (exists("CURRENT_DATETIME")) {
    return(as.POSIXct(CURRENT_DATETIME))
  }
  return(as.POSIXct(Sys.time()))
}

getQueryDatetime <- function() {
  format(getCurrentDatetime(), "%Y-%m-%d %H:%M:%S")
}

extractIDsFromReferences <- function(references) {
  etlutils::getAfterLastSlash(references)
}

getQueryList <- function(collection, remove_ref_type = FALSE) {
  if (remove_ref_type) {
    collection <- extractIDsFromReferences(collection)
  }
  paste0("'", collection, "'", collapse = ", ")
}

parseQueryList <- function(list_string, split = " ") {
  splitted <- unlist(strsplit(list_string, split))
  getQueryList(splitted)
}

####################################################
# Load Resources by ID (= own ID or PID or Enc ID) #
####################################################

getLoadResourcesLastStatusFromDBQuery <- function(resource_name, filter = "") {
  db_connection_read <- getDatabaseReadConnection()
  table_name <- getFirstTableWithNamePart(db_connection_read, paste0(resource_name, "_all"))
  id_column <- getIDColumn(resource_name)
  statement <-paste0(
    "SELECT * FROM ", table_name, " a,\n",
    "(\n",
    "  SELECT max(COALESCE(last_check_datetime, input_datetime)) last_date, ", id_column, "\n",
    "  FROM ", table_name, " GROUP BY ", id_column, "\n",
    ") b\n",
    "WHERE b.last_date = COALESCE(a.last_check_datetime, a.input_datetime) and a.", id_column, " = b.", id_column,
    if (nchar(filter)) paste0("\n", filter) else "",
    ";\n"
  )
  return(statement)
}

getStatementFilter <- function(resource_name, filter_column, filter_column_values) {
  resource_id_column <- getIDColumn(resource_name)
  if (filter_column == resource_id_column) {
    # remove reosurce name and the slash if the IDs are references and not pure IDs
    filter_column_values <- gsub(paste0("^", resource_name, "/"), "", filter_column_values)
  }
  # quote every pid and collapse the vector comma separated
  filter_column_values <- paste0("'", filter_column_values, "'", collapse = ",")
  filter_line <- paste0("AND a.", filter_column, " IN (", filter_column_values, ")\n")
  return(filter_line)
}

runQuery <- function(resource_name, filter_column, ids, log = TRUE) {
  filter <- getStatementFilter(resource_name, filter_column, ids)
  statement <- getLoadResourcesLastStatusFromDBQuery(resource_name, filter)
  db_connection_read <- getDatabaseReadConnection()
  etlutils::dbGetQuery(db_connection_read, statement, log)
}

loadResourcesLastStatusFromDB <- function(resource_name, log = TRUE) {
  statement <- getLoadResourcesLastStatusFromDBQuery(resource_name, filter = "")
  db_connection_read <- getDatabaseReadConnection()
  etlutils::dbGetQuery(db_connection_read, statement, log)
}

loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids, log = TRUE) {
  id_column <- getIDColumn(resource_name)
  runQuery(resource_name, id_column, ids, log)
}

loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids, log = TRUE) {
  if (tolower(resource_name) %in% "patient") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids, log))
  }
  pid_column <- getPIDColumn(resource_name)
  runQuery(resource_name, pid_column, pids, log)
}

loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids, log = TRUE) {
  if (tolower(resource_name) %in% "encounter") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids, log))
  }
  enc_id_column <- getPIDColumn(resource_name)
  runQuery(resource_name, enc_id_column, enc_ids, log)
}

createFrontendTables <- function() {

  getErrorOrWarningMessage <- function(text, tables = NA, db_connection = getDatabaseReadConnection()) {
    tables <- if (!etlutils::isSimpleNA(tables)) sapply(tables, function(table_name_part) getFirstTableWithNamePart(db_connection, table_name_part)) else NA
    tables <- if (!etlutils::isSimpleNA(tables)) paste0(" Table(s): ", paste0(tables, collapse = ", "), ";") else ""
    db_connection <- if (!etlutils::isSimpleNA(db_connection)) paste0(" DB connection: ", etlutils::getPrintString(db_connection)) else ""
    text <- paste0(text, tables, db_connection)
    return(text)
  }

  createPatientFrontendTable <- function(pids_per_ward) {
    # if there are the same pids multiple in the pids per ward table (same patient on different
    # wards or multiple in the same ward, then the result will contain this patient multiple times
    # too! This error has to be fixed by the DIZ at the beginning of the process (preventing same
    # patient multiple times on the same or different wards)
    pids <- unique(pids_per_ward$patient_id)
    pids <- extractIDsFromReferences(pids)
    patients <- loadResourcesLastStatusByOwnIDFromDB("Patient", pids)

    pids_count <- length(pids)

    patient_frontend_table <- data.table(
      pat_id = rep(NA_character_, times = pids_count),
      pat_name = NA_character_,
      pat_vorname = NA_character_,
      pat_gebdat = as.POSIXct.Date(NA),
      pat_geschlecht = NA_character_
    )

    for (i in seq_len(pids_count)) {
      patient <- patients[pat_id %in% pids[i]]
      patient_frontend_table$pat_id[i] <- patient$pat_id
      patient_frontend_table$pat_vorname[i] <- patient$pat_name_given
      patient_frontend_table$pat_name[i] <- patient$pat_name_family
      patient_frontend_table$pat_gebdat[i] <- patient$pat_birthdate
      patient_frontend_table$pat_geschlecht[i] <- patient$pat_gender
    }
    return(patient_frontend_table)
  }

  createEncounterFrontendTable <- function(pids_per_ward) {
    enc_frontend_table <- data.table(
      fall_id = character(),
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
      fall_ent_dat = as.POSIXct(character())
    )

    # load Encounters for all PIDs
    query_date <- getQueryDatetime()
    query_ids <- getQueryList(pids_per_ward$patient_id)
    query <- paste0("SELECT * FROM db2dataprocessor_out.v_encounter_all_data\n",
                    "  WHERE enc_patient_id IN (", query_ids, ") AND\n",
                    "  enc_partof_id IS NULL AND\n",
                    "  (enc_period_end IS NULL OR enc_period_end > '", query_date, "') AND\n",
                    "  enc_period_start <= '", query_date, "'\n")
    encounters <- etlutils::dbGetQuery(getDatabaseReadConnection(), query)

    # load Conditions referenced by Encounters
    condition_ids <- encounters$enc_diagnosis_condition_id
    query_ids <- getQueryList(condition_ids, remove_ref_type = TRUE)
    query <- paste0("SELECT * FROM db2dataprocessor_out.v_condition_all_data\n",
                    "  WHERE con_id IN (", query_ids, ")\n")
    conditions <- etlutils::dbGetQuery(getDatabaseReadConnection(), query)

    for (pid_index in seq_len(nrow(pids_per_ward))) {
      pid <- pids_per_ward$patient_id[pid_index]
      pid_encounters <- encounters[enc_patient_id == pid]

      # check possible errors
      if (!nrow(pid_encounters)) { # no encounter for PID found
        etlutils::cat_error(paste0("No encounter found for PID ", pid))
        next
      }

      unique_encounter_IDs <- unique(pid_encounters$enc_id)
      # if there are errors in the data then there can be more than one encounter
      if (length(unique_encounter_IDs) > 1) {
        etlutils::cat_error(paste0("Multiple encounters found for PID ", pid, "\n",
                                   "  Encounter-IDs: ", paste0(unique_encounter_IDs, collapse = ", "), "\n"))
      }

      # If the data is incorrect and a patient has more than one active Encounter, this will be
      # highlighted here.
      pid_encounters <- split(pid_encounters, pid_encounters$enc_id)

      start_index <- nrow(enc_frontend_table)
      enc_frontend_table <- etlutils::addEmptyRows(enc_frontend_table, length(unique_encounter_IDs))

      for (i in 1:length(pid_encounters)) {
        target_index <- start_index + i

        # There can be multiple lines for the same Encounter if there are multiple conditions
        # present for the case which were splitted by fhir_melt (in cds2db) to multiple lines.
        # Take the common data (ID, start, end, status) from the first line
        encounter_id <- pid_encounters[[i]]$enc_id[1]
        encounter_start <- pid_encounters[[i]]$enc_period_start[1]
        encounter_end <- pid_encounters[[i]]$enc_period_end[1]
        data.table::set(enc_frontend_table, target_index, 'fall_id', encounter_id)
        data.table::set(enc_frontend_table, target_index, 'fall_aufn_dat', encounter_start)
        data.table::set(enc_frontend_table, target_index, 'fall_ent_dat',encounter_end)
        data.table::set(enc_frontend_table, target_index, 'fall_status', pid_encounters[[i]]$enc_status[1])

        # extract ward name from pids_per_ward table
        data.table::set(enc_frontend_table, target_index, 'fall_station', pids_per_ward$ward_name[pid_index])

        # Extract the admission diagnosis
        admission_diagnoses <- pid_encounters[[i]][enc_diagnosis_use_code == "AD"]$enc_diagnosis_condition_id
        admission_diagnoses <- unique(admission_diagnoses)
        admission_diagnoses <- extractIDsFromReferences(admission_diagnoses)
        admission_diagnoses <- conditions[con_id %in% admission_diagnoses]
        admission_diagnoses <- unique(admission_diagnoses$con_code_text)
        admission_diagnoses <- paste0(admission_diagnoses, collapse = "; ")
        data.table::set(enc_frontend_table, target_index, 'fall_aufn_diag', admission_diagnoses)

        getObservation <- function(codes, system, target_column_value, target_column_unit = NA) {
          # Extract the observations for weigth
          query <- paste0("SELECT * FROM v_observation_all_data\n",
                          "  WHERE obs_encounter_id = 'Encounter/", encounter_id, "' AND\n",
                          "        obs_code_code IN (", parseQueryList(codes), ") AND\n",
                          "        obs_code_system = '", system, "' AND\n",
                          "        obs_effectivedatetime < '", query_date, "'\n")
          observations <- etlutils::dbGetQuery(getDatabaseReadConnection(), query)
          # we found no Observations with the direct encounter link so identify potencial
          # Observations by time overlap with the encounter period start and current date
          if (!nrow(observations)) {
            query <- paste0("SELECT * FROM v_observation_all_data\n",
                            "  WHERE obs_patient_id = '", pid, "' AND\n",
                            "        obs_code_code IN (", parseQueryList(codes), ") AND\n",
                            "        obs_code_system = '", system, "' AND\n",
                            "        obs_effectivedatetime > '", encounter_start, "' AND\n",
                            "        obs_effectivedatetime < '", query_date, "'\n")
            observations <- etlutils::dbGetQuery(getDatabaseReadConnection(), query)
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
    }
    return(enc_frontend_table)
  }

  pids_per_ward <- loadAllDataWithLastTimestampFromDB("pids_per_ward")
  pids_per_ward <- pids_per_ward[!is.na(patient_id)]

  if (!nrow(pids_per_ward)) {
    message <- "The pids_per_ward table is empty."
    message <- getErrorOrWarningMessage(message, "pids_per_ward")
    etlutils::stopWithError(message)
  }

  patient_frontend_table <- createPatientFrontendTable(pids_per_ward)
  etlutils::writeTableToDatabase(patient_frontend_table,
                                 getDatabaseWriteConnection(),
                                 table_name = "patient_fe",
                                 clear_before_insert = TRUE)

  encounter_frontend_table <- createEncounterFrontendTable(pids_per_ward)
  etlutils::writeTableToDatabase(encounter_frontend_table,
                                 getDatabaseWriteConnection(),
                                 table_name = "fall_fe",
                                 clear_before_insert = TRUE)
}

# Liste mit Ressourcenkürzel, wird später aus der Datenbank ausgelesen
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
#' @export
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

# https://stackoverflow.com/questions/69947452/regex-boundary-to-also-exclude-special-characters
# These are PERL Patterns -> works only for grep with perl = TRUE
SIMPLE_ICD_PATTERN <- list(
  ICD1 = '[A-Z]',
  ICD2_3 = '[A-Z][0-9]{1,2}',
  ICD4_6 = '[A-Z][0-9]{2}\\.[0-9]{0,2}'
)

#' Checks whether strings in a vector of ICD codes match specified patterns.
#'
#' This function takes a vector of ICD (International Classification of Diseases)
#' codes and checks whether the strings in this vector match predefined patterns.
#' The patterns are retrieved from an external data frame named SIMPLE_ICD_PATTERN.
#'
#' @param codes A vector of strings containing the ICD codes to be checked.
#' @return A logical vector that returns TRUE for strings that match the patterns
#' and FALSE for strings that do not match the patterns.
#' @seealso SIMPLE_ICD_PATTERN This data frame contains the predefined patterns
#' for ICD codes.
#'
#' @examples
#' codes <- c('H77+M55.2', 'H77', 'XXX', 'X+X', 'X+XXXXX')
#' isICDCode(codes)
#'
#' @export
isICDCode <- function(codes) {
  icd_pattern <- paste(paste0('(', SIMPLE_ICD_PATTERN$ICD1, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD2_3, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD4_6, ')'), sep = '|')
  full_icd_pattern <- paste0('(','^','(', icd_pattern,')', '$', ')', '|', '(', '^', '(', icd_pattern,')', '\\+{1}', '(', icd_pattern, '){1}', '$', ')')
  grepl(full_icd_pattern, codes, perl = TRUE)
}

#' Clean and Validate ICD Code
#'
#' This function cleans and validates an ICD code by converting it to uppercase,
#' removing trailing non-alphanumeric characters, and checking if the resulting
#' code is a valid ICD code.
#'
#' @param icd A character vector representing the ICD code.
#'
#' @return A character vector containing the cleaned and validated ICD code,
#'         or NULL if the input is not a valid ICD code.
#' @examples
#' cleanICD("A11")
#' cleanICD(" B1.2 ")
#' cleanICD("C23-") # This will return NULL as it's not a valid ICD code.
#'
#' @export
cleanICD <- function(icd) {
  icd <- toupper(etlutils::removeLastCharsIfNotAlphanumeric(trimws(icd)))
  icd[isICDCode(icd)]
}
