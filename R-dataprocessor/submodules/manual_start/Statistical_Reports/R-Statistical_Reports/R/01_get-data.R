#' Get Patient Data
#'
#' This function retrieves patient data—including patient IDs, birthdates, and metadata—
#' from a specified database table. It ensures data consistency by removing duplicate entries
#' and error the user if multiple records exist for the same patient ID or identifier.
#'
#' @param lock_id A character string specifying the lock ID for the database query.
#'   This ensures safe access to the database during query execution and may support concurrent processing.
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain at least the following columns: `pat_id`, `pat_identifier_type_code`, `pat_identifier_value`,
#'   `pat_birthdate`, `pat_gender` ,`pat_deceaseddatetime`, `pat_meta_lastupdated`, and `input_datetime`.
#'
#' @return A data frame containing:
#'   - `pat_id`: Patient FHIR identifier
#'   - `pat_identifier_type_code`: Type of identifier (should be MR for medical record number)
#'   - `pat_identifier_value`: cis (hospital system) patient identifier
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
#' 2. Filters the results to include only rows where `pat_identifier_type_code` is "MR" (medical record number).
#' 3. filters unique entries for the selected variables and sorts the data by `pat_id`.
#' 4. Checks for potential duplicates in:
#'    - `pat_id`: should uniquely identify patients in FHIR
#'    - `pat_identifier_value`: should uniquely identify patients in the hospital system
#'    If duplicates are found, errors are issued for manual inspection.
#'
#' @importFrom dplyr distinct arrange
#' @export
getPatientData <- function(lock_id, table_name) {

  query <- paste0("SELECT pat_id, pat_identifier_type_code, pat_identifier_value, pat_birthdate, pat_gender, ",
  "pat_deceaseddatetime, ",
  "pat_meta_lastupdated, input_datetime FROM ", table_name, "\n")

  patient_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::filter(pat_identifier_type_code == "MR") |>
    dplyr::select(-pat_identifier_type_code) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id)

  if (checkMultipleRows(patient_table, c("pat_id"))) {
    stop("The patient table contains multiple rows for the same pat_id(FHIR). Please check the data.")
  }

  if (checkMultipleRows(patient_table, c("pat_identifier_value"))) {
    stop("The patient table contains multiple rows for the same patient identifier (cis). Please check the data.")
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
#' patient IDs and issues errors if duplicates are found based on either the FHIR or cis identifiers.
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
#' or `pat_cis_pid` (related to the cis identifier), errors are issued to indicate potential data issues.
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
    stop("The patient_fe table contains multiple rows for the same patient identifier (cis). Please check the data.")
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
#'   \item{fall_id}{Fall ID from the hospital intern system (cis)}
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

#------------------------------------------------------------------------------#
#' Retrieve Medikationsanalyse Front-End Data
#'
#' This function queries a database table containing front-end documentation of medication analyses
#' and returns a cleaned and ordered data frame.
#'
#' @param lock_id A database lock identifier used to manage access when querying data via `etlutils::dbGetReadOnlyQuery()`.
#' @param table_name A character string specifying the name of the database table to query.
#'
#' @return A tibble or data frame containing distinct rows of medication analysis data,
#' ordered by `record_id`, `fall_meda_id`, and `meda_dat`.
#'
#' @details
#' The following columns are retrieved from the specified table:
#' \itemize{
#'   \item `record_id` – Unique identifier for the patient record.
#'   \item `meda_anlage` – identifier of the person who created the medication analysis.
#'   \item `meda_edit` – identifier of the person who last edited the medication analysis.
#'   \item `fall_meda_id` – Identifier linking to the specific encounter (cis id).
#'   \item `meda_id` – Identifier for the medication analysis instance.
#'   \item `meda_typ` – Type of medication analysis.
#'   \item `meda_dat` – Date of the medication analysis.
#'   \item `meda_gewicht_aktuell` – Current weight of the patient at the time of analysis.
#'   \item `meda_gewicht_aktl_einheit` – Unit of measurement for the current weight.
#'   \item `meda_groesse` – Height of the patient at the time of analysis.
#'   \item `meda_groesse_einheit` – Unit of measurement for the height.
#'   \item `meda_nieren_insuf_chron` – Flag indicating if the patient has chronic kidney insufficiency.
#'   \item `meda_nieren_insuf_ausmass` – Degree of chronic kidney insufficiency.
#'   \item `meda_nieren_insuf_dialysev` – Flag indicating if the patient is on dialysis.
#'   \item `meda_leber_insuf` – Flag indicating if the patient has liver insufficiency.
#'   \item `meda_leber_insuf_ausmass` – Degree of liver insufficiency.
#'   \item `meda_schwanger_mo` – Flag indicating if the patient is pregnant.
#'   \item `meda_ma_thueberw` – Flag indicating if medication analysis is marked for representment
#'   \item `meda_mrp_detekt` – Flag indicating if a medication-related problem (MRP) was detected.
#'   \item `meda_aufwand_zeit` – Time spent on the medication analysis.
#'   \item `meda_notiz` – Additional notes related to the medication analysis.
#'   \item `medikationsanalyse_complete` – Completion status of the form.
#' }
#'
#' Duplicate entries are removed using `dplyr::distinct()` and the result is sorted by `record_id`,
#' `fall_meda_id`, and `meda_dat`.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getMedikationsanalyseFeData <- function(lock_id, table_name) {

  query <- paste0("SELECT record_id, meda_anlage, meda_edit, fall_meda_id, ",
                  "meda_id, meda_typ, meda_dat, meda_gewicht_aktuell, meda_gewicht_aktl_einheit, ",
                  "meda_groesse, meda_groesse_einheit, meda_nieren_insuf_chron, meda_nieren_insuf_ausmass, ",
                  "meda_nieren_insuf_dialysev, meda_leber_insuf, meda_leber_insuf_ausmass, meda_schwanger_mo, ",
                  "meda_ma_thueberw, meda_mrp_detekt, meda_aufwand_zeit, meda_notiz, ",
                  "medikationsanalyse_complete FROM ", table_name, "\n")

  medikationsanalyse_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id, fall_meda_id, meda_dat)

  return(medikationsanalyse_fe_table)
}

#------------------------------------------------------------------------------#

#' Retrieve MRP Documentation Validation Data from Front-End Table
#'
#' This function queries the specified front-end database table for MRP (Medication-Related Problems)
#' documentation validation data. It returns detailed metadata for each MRP entry, including
#' associated medication, indication, product, and intervention classifications.
#'
#' @param lock_id A string identifier used to access the read-only connection to the database.
#'   Typically used to lock the appropriate source for ETL processing.
#' @param table_name A string representing the name of the front-end table to query (e.g.,
#'   `"v_mrp_dokumentation_validierung_fe"`).
#'
#' @return A `data.frame` containing the selected MRP documentation validation variables,
#'   arranged by `record_id`, `mrp_meda_id`, and `mrp_id`.
#'
#' @details
#' The function fetches and returns the following:
#' - Identifiers: `record_id`, `mrp_anlage`, `mrp_edit`, `mrp_meda_id`, `mrp_id`
#' - Descriptors: `mrp_kurzbeschr`, `mrp_hinweisgeber`, `mrp_hinweisgeber_oth`
#' - Medication fields: `mrp_wirkstoff`, `mrp_atc1` to `mrp_atc5`
#' - Product-related fields: `mrp_med_prod`, `mrp_med_prod_sonst`
#' - Problem indicators: `mrp_pigrund___1` to `mrp_pigrund___27`
#' - Intervention categories: `mrp_ip_klasse_01`, `mrp_ip_klasse_disease`, `mrp_ip_klasse_nieren_insuf`
#' - Measures taken (AM and organizational): `mrp_massn_am___1` to `mrp_massn_am___10`,
#'   `mrp_massn_orga___1` to `mrp_massn_orga___8`
#' - MRP details and intervention realization: `mrp_notiz`, `mrp_dokup_hand_emp_akz`, `mrp_merp`, and completion status
#'
#' The function ensures uniqueness using `distinct()` and sorts results by `record_id`,
#' `mrp_meda_id`, and `mrp_id` for easier downstream processing.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getMRPDokumentationValidierungFeData <- function(lock_id, table_name) {

  query <- paste0("SELECT record_id, mrp_anlage, mrp_edit, ",
                  "mrp_meda_id, mrp_id, mrp_kurzbeschr, mrp_hinweisgeber, mrp_hinweisgeber_oth, ",
                  "mrp_wirkstoff, ",
                  paste0("mrp_atc", 1:5, collapse = ", "), ", ",
                  "mrp_med_prod, mrp_med_prod_sonst, ",
                  paste0("mrp_pigrund___", 1:27, collapse = ", "), ", ",
                  "mrp_ip_klasse_01, mrp_ip_klasse_disease, mrp_ip_klasse_nieren_insuf, ",
                  paste0("mrp_massn_am___", 1:10, collapse = ", "), ", ",
                  paste0("mrp_massn_orga___", 1:8, collapse = ", "), ", ",
                  "mrp_notiz, mrp_dokup_hand_emp_akz, mrp_merp, mrpdokumentation_validierung_complete ",
                  "FROM ", table_name, "\n")

  mrp_dokumentation_validierung_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id, mrp_meda_id, mrp_id)
  return(mrp_dokumentation_validierung_fe_table)
}
