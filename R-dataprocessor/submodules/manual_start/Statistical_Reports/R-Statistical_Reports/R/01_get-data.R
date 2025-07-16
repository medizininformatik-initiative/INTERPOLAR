#' Get Patient Data
#'
#' This function retrieves patient data—including patient IDs, birthdates, and metadata—
#' from a specified database table. It ensures data consistency by removing duplicate entries
#' and error the user if multiple records exist for the same patient ID or identifier.
#'
#' @param lock_id A character string specifying the lock ID for the database query.
#'   This ensures safe access to the database during query execution and may support concurrent processing.
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain at least the following columns: `pat_id`, `pat_identifier_value`,
#'   `pat_birthdate`, `pat_gender` ,`pat_deceaseddatetime`, `pat_meta_lastupdated`, and `input_datetime`.
#'
#' @return A data frame containing:
#'   - `pat_id`: Patient FHIR identifier
#'   - `pat_identifier_value`: KIS (hospital system) patient identifier
#'   - `pat_birthdate`: Patient's birthdate (expected in `Date` format)
#'   - `pat_gender`: patient's gender
#'   - `pat_deceaseddatetime`: Date and time of death, if available
#'   - `pat_meta_lastupdated`: Timestamp of last update to patient data
#'   - `input_datetime`: Timestamp of data input
#'   The result is sorted by `pat_id` and includes only distinct rows.
#'
#' @details
#' The function performs the following steps:
#' 1. Executes a SQL query to retrieve required patient-related columns from the specified table.
#' 2. Removes any exact duplicate rows from the result.
#' 3. Sorts the data by `pat_id`.
#' 4. Checks for potential duplicates in:
#'    - `pat_id`: should uniquely identify patients in FHIR
#'    - `pat_identifier_value`: should uniquely identify patients in the hospital system
#'    If duplicates are found, errors are issued for manual inspection.
#'
#' @importFrom dplyr distinct arrange
#' @export
getPatientData <- function(lock_id, table_name) {

  query <- paste0("SELECT pat_id, pat_identifier_value, pat_birthdate, pat_gender, ",
  "pat_deceaseddatetime, ",
  "pat_meta_lastupdated, input_datetime FROM ", table_name, "\n")

  patient_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id)

  if (checkMultipleRows(patient_table, c("pat_id"))) {
    stop("The patient table contains multiple rows for the same pat_id(FHIR). Please check the data.")
  }

  if (checkMultipleRows(patient_table, c("pat_identifier_value"))) {
    stop("The patient table contains multiple rows for the same patient identifier (KIS). Please check the data.")
  }

  return(patient_table)
}

#------------------------------------------------------------------------------#

#' Get Encounter Data
#'
#' This function retrieves detailed encounter data from a specified database table and
#' returns a clean, sorted data frame containing distinct encounter records.
#'
#' @param lock_id A character string specifying the lock ID for the database query.
#'   This ensures safe and consistent access to the database during query execution.
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain the following columns (at a minimum):
#'   - `enc_id`, `enc_identifier_value`, `enc_patient_ref`, `enc_partof_ref`
#'   - `enc_class_system`, `enc_class_code`
#'   - `enc_type_system`, `enc_type_code`
#'   - `enc_servicetype_system`, `enc_servicetype_code`
#'   - `enc_period_start`, `enc_period_end`, `enc_status`
#'   - `enc_hospitalization_admitsource_system`, `enc_hospitalization_admitsource_code`
#'   - `enc_hospitalization_dischargedisposition_system`, `enc_hospitalization_dischargedisposition_code`
#'   - `enc_location_ref`, `enc_location_identifier_value`, `enc_location_status`
#'   - `enc_location_physicaltype_system`, `enc_location_physicaltype_code`
#'   - `enc_serviceprovider_identifier_type_system`, `enc_serviceprovider_identifier_type_code`
#'   - `enc_serviceprovider_identifier_system`, `enc_serviceprovider_identifier_value`
#'   - `enc_meta_lastupdated`, `input_datetime`
#'
#' @return A data frame with distinct encounter records, including:
#'   - IDs and references (`enc_id`, `enc_patient_ref`, `enc_partof_ref`, `enc_identifier_value`)
#'   - Classification and type (`enc_class_*`, `enc_type_*`)
#'   - Service and hospitalization info (`enc_servicetype_*`, `enc_status`, `enc_hospitalization_*`)
#'   - Encounter period (`enc_period_start`, `enc_period_end`)
#'   - Location and physical type (`enc_location_*`, `enc_location_physicaltype_*`)
#'   - Service provider identifiers (`enc_serviceprovider_*`)
#'   - Metadata (`enc_meta_lastupdated`, `input_datetime`)
#'
#' @details
#' This function performs the following:
#' 1. Builds and runs a SQL query selecting the full encounter dataset from the specified table.
#' 2. Removes any exact duplicates using `dplyr::distinct()`.
#' 3. Sorts the data by patient reference, encounter ID, time-related fields, and status-related fields
#'    to ensure consistency and clarity in downstream processing.
#'
#' Note:
#' - The function assumes that all required columns exist in the source table.
#' - It is recommended to inspect the schema if issues arise due to missing columns or mismatched field types.
#'
#' @importFrom dplyr distinct arrange
#' @export

# TODO: check all variables in table _description_relevant for manifestations and importance to include them ------------

getEncounterData <- function(lock_id, table_name) {

  query <- paste0("SELECT enc_id, enc_identifier_value, ",

                  "enc_patient_ref, enc_partof_ref, enc_class_system, enc_class_code, ",
                  "enc_type_system, enc_type_code, enc_servicetype_system, enc_servicetype_code, ",
                  "enc_period_start, enc_period_end, enc_status, ",
                  "enc_hospitalization_admitsource_system, enc_hospitalization_admitsource_code, ",
                  "enc_hospitalization_dischargedisposition_system, enc_hospitalization_dischargedisposition_code, ",
                  "enc_location_ref, enc_location_identifier_value, enc_location_status, ",
                  "enc_location_physicaltype_system, enc_location_physicaltype_code, ",
                  "enc_serviceprovider_identifier_type_system, enc_serviceprovider_identifier_type_code, ",
                  "enc_serviceprovider_identifier_system, enc_serviceprovider_identifier_value, ",
                  "enc_meta_lastupdated, input_datetime ",
                  "FROM ", table_name, "\n")

  encounter_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(enc_patient_ref, enc_id, enc_period_start, enc_period_end, enc_status, input_datetime)

  return(encounter_table)
}

#------------------------------------------------------------------------------#

#' Retrieve Patient IDs Per Ward Data
#'
#' This function retrieves patient data associated with wards, including the ward name,
#' patient ID, encounter ID, and the input timestamp.
#'
#' @param lock_id A character string specifying the lock ID for database access control.
#' @param table_name A character string specifying the name of the database table from which
#'   the data should be retrieved.
#'
#' @return A data frame containing distinct records with the following columns:
#'   - `ward_name`: The name of the ward.
#'   - `patient_id`: The unique identifier of the patient (FHIR)
#'   - `encounter_id`: The unique identifier of the encounter (FHIR)
#'   - `input_datetime`: The timestamp of when the record was entered.
#'
#' @details
#' This function performs the following steps:
#' 1. Constructs an SQL query to retrieve `ward_name`, `patient_id`, `encounter_id`,
#'    and `input_datetime` from the specified table.
#' 2. Executes the query using `etlutils::dbGetReadOnlyQuery` with the provided `lock_id`.
#' 3. Ensures distinct records using `dplyr::distinct()`.
#' 4. Sorts the results by `patient_id`, `encounter_id`, and `input_datetime`.
#'
#'
#' @importFrom dplyr distinct arrange
#' @export
getPidsPerWardData <- function(lock_id, table_name) {

  query <- paste0("SELECT ward_name, patient_id, encounter_id, input_datetime ",
                  "FROM ", table_name, "\n")

  pids_per_ward_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(patient_id, encounter_id, input_datetime)

  return(pids_per_ward_table)
}

#------------------------------------------------------------------------------#

#' Retrieve and Process Patient Front-End Data
#'
#' This function retrieves patient data from a specified database table and processes it by
#' filtering out duplicate entries and arranging the data. It performs checks for duplicate
#' patient IDs and issues errors if duplicates are found based on either the FHIR or KIS identifiers.
#'
#' @param lock_id A character string used to lock the database table and ensure safe data retrieval.
#' This is important for managing concurrent data access in environments where multiple processes might access
#' the data simultaneously.
#' @param table_name A character string specifying the name of the database table to query. This table
#' should include columns `pat_id`, `pat_cis_pid`, `record_id`, and `input_datetime`.
#'
#' @return A dataframe (`patient_fe_table`) that includes patient data, cleaned to ensure distinct
#' entries per `pat_id`, arranged in order.
#'
#' @details The function constructs an SQL query to select relevant columns from the specified table,
#' retrieves the data while checking for read-only access, and processes it to remove duplicates and
#' arrange the records. If there are multiple rows for a single `pat_id` (related to the FHIR identifier)
#' or `pat_cis_pid` (related to the KIS identifier), errors are issued to indicate potential data issues.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getPatientFeData <- function(lock_id, table_name) {

  query <- paste0("SELECT pat_id, pat_cis_pid, record_id, ",
                  "input_datetime FROM ", table_name, "\n")

  patient_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id)

  if (checkMultipleRows(patient_fe_table, c("pat_id"))) {
    stop("The patient_fe table contains multiple rows for the same pat_id(FHIR). Please check the data.")
  }

  if (checkMultipleRows(patient_fe_table, c("pat_cis_pid"))) {
    stop("The patient_fe table contains multiple rows for the same patient identifier (KIS). Please check the data.")
  }

  return(patient_fe_table)
}

#------------------------------------------------------------------------------#
#' Retrieve Fall Front-End Data from Database
#'
#' This function queries a specified database table to retrieve front-end data related to patient encounters ("Fälle").
#' It fetches relevant fields such as encounter ID, patient ID, station, dates, and metadata, and returns a cleaned version
#' of the table with duplicates removed and sorted by `record_id` and `input_datetime`.
#'
#' @param lock_id A database connection identifier (used by `etlutils::dbGetReadOnlyQuery`) to ensure read-only access.
#' @param table_name A character string specifying the name of the database table from which to retrieve the data.
#'
#' @return A data frame or tibble containing the cleaned and de-duplicated fall front-end data.
#'   The returned columns include:
#'   \item{record_id}{Unique record identifier for the patient in RedCap}
#'   \item{fall_fhir_enc_id}{FHIR-based encounter ID}
#'   \item{fall_pat_id}{FHIR-based Patient ID}
#'   \item{fall_id}{Fall ID from the hospital intern system (KIS)}
#'   \item{fall_studienphase}{Study phase associated with the case}
#'   \item{fall_station}{INTERPOLAR-ward fromt he pids_per_ward table}
#'   \item{fall_aufn_dat}{Admission date of the main encounter}
#'   \item{fall_status}{Status of the encounter}
#'   \item{fall_ent_dat}{Discharge date of the main encounter}
#'   \item{fall_additional_values}{information on associated sub-encounters}
#'   \item{fall_complete}{flag indicating completeness}
#'
#' @details
#' The function executes a SQL `SELECT` query on the specified `table_name`, retrieving all expected columns. It then:
#' \enumerate{
#'   \item Removes exact duplicates.
#'   \item Sorts rows by `record_id` and `input_datetime` to ensure consistent ordering.
#'   \item Removes the `input_datetime` column before final output.
#' }
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange select
#' @export
getFallFeData <- function(lock_id, table_name) {

  query <- paste0("SELECT record_id, fall_fhir_enc_id, fall_pat_id, ",
                  "fall_id, fall_studienphase, fall_station, fall_aufn_dat, ",
                  "fall_status, fall_ent_dat, fall_additional_values, ",
                  "fall_complete, input_datetime FROM ", table_name, "\n")

  fall_fe_table_raw <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id, input_datetime)

  fall_fe_table <- fall_fe_table_raw |>
    dplyr::select(-input_datetime) |>
    dplyr::distinct()

  return(fall_fe_table)
}
