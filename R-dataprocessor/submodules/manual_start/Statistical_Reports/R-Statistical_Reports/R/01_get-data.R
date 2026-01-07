#' Get Patient Data
#'
#' This function retrieves patient data—including patient IDs, birthdates, and metadata—
#' from a specified database table. It ensures data consistency by removing duplicate entries
#' and error the user if multiple records exist for the same patient ID or identifier.
#'
#' @param lock_id A character string specifying the lock ID for the database query.
#'   This ensures safe access to the database during query execution and may support concurrent
#'   processing.
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain at least the following columns: `pat_id`, `pat_identifier_type_code`,
#'   `pat_identifier_value` and `pat_birthdate`.
#'
#' @return A data frame containing:
#'   - `pat_id`: Patient FHIR identifier
#'   - `pat_identifier_type_code`: Type of identifier (should be MR for medical record number)
#'   - `pat_identifier_value`: cis (hospital system) patient identifier
#'   - `pat_birthdate`: Patient's birthdate (expected in `Date` format)
#'   - `pat_identifier_system`: System of the patient identifier
#'   - `pat_identifier_type_system`: System of the patient identifier type
#'   - `processing_exclusion_reason`: A column initialized with `NA` to log any processing exclusions
#'
#'   The result is sorted by `pat_id` and includes only distinct rows.
#'
#' @details
#' The function performs the following steps:
#' 1. Executes a SQL query to retrieve required patient-related columns from the specified table.
#' 2. Filters the results to include only rows where the following conditions are met, if defined:
#'     - `pat_identifier_system` matches the FHIR identifier system for patients displayed in the
#'        frontend.
#'     - `pat_identifier_type_system` matches the FHIR identifier type system for patients displayed
#'        in the frontend.
#'     - `pat_identifier_type_code` matches the FHIR identifier type code for patients displayed in
#'        the frontend.
#' The constants used for filtering are:
#' - `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM`
#' - `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM`
#' - `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE`
#' 3. filters unique entries for the selected variables and sorts the data by `pat_id`.
#' 4. Checks if the resulting data frame is empty and raises an error if so.
#'
#' @importFrom dplyr distinct arrange filter
#' @export
getPatientData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT pat_id, pat_identifier_system, pat_identifier_type_system, ",
    "pat_identifier_type_code, pat_identifier_value, pat_birthdate ",
    "FROM ", table_name, "\n"
  )

  patient_table_raw <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct()
  # DEBUG START-------------------------------
  # duplicate patient entries with different identifier systems/types to test the warnings
  if (DEBUG_TEST_REPORTING_WARNINGS) {
    patient_table_raw <- createPatientDataWarningsSituations(patient_table_raw)
  }
  # DEBUG END-------------------------------

  if (exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM") &
    !FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM %in% c(".*", "")) {
    patient_table_raw <- patient_table_raw |>
      dplyr::filter(
        grepl(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM, pat_identifier_system)
      ) |>
      dplyr::distinct()
  }
  if (exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM") &
    !FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM %in% c(".*", "")) {
    patient_table_raw <- patient_table_raw |>
      dplyr::filter(
        grepl(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM, pat_identifier_type_system)
      ) |>
      dplyr::distinct()
  }
  if (exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE") &
    !FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE %in% c(".*", "")) {
    patient_table_raw <- patient_table_raw |>
      dplyr::filter(
        grepl(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE, pat_identifier_type_code)
      ) |>
      dplyr::distinct()
  }
  patient_table <- patient_table_raw |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id)

  if (nrow(patient_table) == 0) {
    stop("The patient table is empty. Please check the data.")
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
#'
#' @param report_period_start A date object specifying the start date of the report period.
#'
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain the following columns:
#'   - `enc_id`, `enc_identifier_value`, `enc_patient_ref`
#'   - `enc_partof_calculated_ref`, `enc_main_encounter_calculated_ref`
#'   - `enc_class_code`
#'   - `enc_type_system`, `enc_type_code`
#'   - `enc_period_start`, `enc_period_end`, `enc_status`
#'   - `enc_identifier_system`
#'
#' @return A data frame with distinct encounter records, including:
#'   - IDs and references (`enc_id`, `enc_patient_ref`, `enc_partof_calculated_ref`, `enc_identifier_value`,
#'   `enc_identifier_system`)
#'   - Classification and type (`enc_class_code`, `enc_type_code_Kontaktebene`, `enc_type_code_Kontaktart`)
#'   - Service and hospitalization info (`enc_status`)
#'   - Encounter period (`enc_period_start`, `enc_period_end`)
#'   - `processing_exclusion_reason`: A column initialized with `NA` to log any processing exclusions
#'
#' @details
#' This function performs the following:
#' 1. Builds and runs a SQL query selecting the full encounter dataset from the specified table.
#' 2. Filters out encounters that do not match the expected FHIR identifier
#'    system for encounters (if defined as `COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM`).
#' 3. Filters encounters to include only those with a start date and end date within one year before
#'    the reporting_period_start or with missing dates to keep track of potentially relevant records.
#' 4. Filters out encounters with class codes "PRENC", "VR", or "HH" to exclude non-relevant records.
#' 5. Filters out encounters with statuses "planned", "cancelled", "entered-in-error" or "unknown"
#'    to focus on relevant records.
#' 6. Uses the `PivotWiderTwoSystems` function to expand encounter type codes into two separate
#'    columns based on specified systems and codes for Kontaktebene and Kontaktart.
#'    Then further filters out encounters of type "begleitperson".
#' 7. Sorts the data by patient reference, encounter ID, time-related fields, and status-related
#'    fields.
#' 8. Adds a `processing_exclusion_reason` column initialized with `NA` to log any processing exclusions.
#'    These will exist of strings where the reason as well as the level ( e.g. 'patient', 'main_encounter' 'sub_encounter')
#'    and the type of exclusion (e.g. 'not_in_inclusion_criteria', 'data_issues', 'linkage_issiues') are noted in a structured way.
#' 9. Checks for empty results and issuing errors if necessary.
#'
#'
#' @importFrom dplyr distinct arrange filter mutate if_else
#' @export

# TODO: check all variables in table _description_relevant for manifestations and importance to include them ------------
# (bottom variables not in use)

getEncounterData <- function(lock_id, table_name, report_period_start) {
  query <- paste0(
    "SELECT enc_id, enc_identifier_value, enc_patient_ref, enc_partof_calculated_ref, ",
    "enc_class_code, enc_type_code, enc_period_start, enc_period_end, enc_status, ",
    "enc_identifier_system, enc_type_system, enc_main_encounter_calculated_ref ",

    "FROM ", table_name, "\n"
  )

  encounter_table_raw <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct()

  # DEBUG START -------------------------------
  if (DEBUG_TEST_REPORTING_WARNINGS) {
    encounter_table_raw <- createRawEncounterDataWarningSituations(encounter_table_raw)
  }
  # DEBUG END-------------------------------

  if (nrow(encounter_table_raw) == 0) {
    stop("No encounter data downloaded from database. Please check the database.")
  }

  if (etlutils::isDefinedAndNotEmpty("COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM")) {
    encounter_table_raw <- encounter_table_raw |>
      dplyr::filter(enc_identifier_system %in% COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM) |>
      dplyr::distinct()
  }

  if (nrow(encounter_table_raw) == 0) {
    stop("The downloaded and identifier-filtered encounter table is empty. Please check (if defined)
    for the correct definition of COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM.")
  }

  encounter_table <- encounter_table_raw |>
    dplyr::filter(enc_period_start >= (as.POSIXct(report_period_start) - 365) | is.na(enc_period_start)) |>
    dplyr::filter(enc_period_end >= (as.POSIXct(report_period_start) - 365) | is.na(enc_period_end))

  if (nrow(encounter_table) == 0) {
    stop("The downloaded and date-filtered encounter table (only encounter data from one year before
    reporting period starts) is empty. Please check for enc_period_start dates being within the
         defined reporting period")
  }

  encounter_table <- encounter_table |>
    dplyr::mutate(processing_exclusion_reason = NA_character_) |>
    dplyr::filter(!enc_class_code %in% c("PRENC", "VR", "HH")) |>
    dplyr::filter(!enc_status %in% c("planned", "cancelled", "entered-in-error", "unknown")) |>
    dplyr::distinct() |>
    PivotWiderTwoSystems(
      system1 = "http://fhir.de/CodeSystem/Kontaktebene",
      codes1 = c(
        "einrichtungskontakt",
        "abteilungskontakt",
        "versorgungsstellenkontakt"
      ),
      system2 = "http://fhir.de/CodeSystem/kontaktart-de",
      codes2 = c(
        "begleitperson", "vorstationaer", "nachstationaer", "teilstationaer",
        "tagesklinik", "nachtklinik", "normalstationaer", "intensivstationaer",
        "ub", "konsil", "stationsaequivalent", "operation"
      ),
      var_code = "enc_type_code",
      var_system = "enc_type_system",
      var_new_system_1 = "enc_type_code_Kontaktebene",
      var_new_system_2 = "enc_type_code_Kontaktart",
      exclusion_reason = "undefined_kontaktebene_or_kontaktart",
      exclusion_level = "sub_encounter",
      exclusion_type = "data_issues",
      id_column = "enc_id"
    ) |>
    dplyr::filter(!enc_type_code_Kontaktart %in% c("begleitperson")) |>
    dplyr::distinct() |>
    dplyr::arrange(enc_patient_ref, enc_id, enc_period_start, enc_period_end, enc_status)

  if (nrow(encounter_table) == 0) {
    stop("The encounter table with extended filtering is empty. Please check the data for expected
    implementation of enc_class_code, enc_status, enc_type_code and enc_type_system.")
  }

  # DEBUG START -------------------------------
  # change one row for each processing_exclusion_reason with different changes to test the warnings
  if (DEBUG_TEST_REPORTING_WARNINGS) {
    encounter_table <- createEncounterDataWarningSituations(encounter_table)
  }
  # DEBUG END-------------------------------

  if (nrow(encounter_table |>
    dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt")) == 0) {
    print(encounter_table, width = Inf)
    stop("The encounter table with extended filtering does not contain any encounters of type 'einrichtungskontakt'.
         Please check the data for expected implementation of enc_type_code and enc_type_system.")
  }

  if (nrow(encounter_table |>
    dplyr::filter(enc_type_code_Kontaktebene == "versorgungsstellenkontakt")) == 0) {
    print(encounter_table, width = Inf)
    stop("The encounter table does not contain any encounters of type 'versorgungsstellenkontakt'.
         Please check the data for expected implementation of enc_type_code and enc_type_system.")
  }

  return(encounter_table)
}

#------------------------------------------------------------------------------#

#' Retrieve Patient IDs Per Ward Data
#'
#' This function retrieves patient data associated with wards, including the ward name,
#' patient ID, encounter ID.
#'
#' @param lock_id A character string specifying the lock ID for database access control.
#' @param table_name A character string specifying the name of the database table from which
#'   the data should be retrieved.
#'
#' @return A data frame containing distinct records with the following columns:
#'   - `ward_name`: The name of the ward.
#'   - `patient_id`: The unique identifier of the patient (FHIR)
#'   - `encounter_id`: The unique identifier of the encounter (FHIR)
#'
#' @details
#' This function performs the following steps:
#' 1. Constructs an SQL query to retrieve `ward_name`, `patient_id`, `encounter_id` from the specified table.
#' 2. Executes the query using `etlutils::dbGetReadOnlyQuery` with the provided `lock_id`.
#' 3. Ensures distinct records using `dplyr::distinct()`.
#' 4. Sorts the results by `patient_id`, `encounter_id`.
#' 5. Checks if the resulting data frame is empty and raises an error if so.
#'
#'
#' @importFrom dplyr distinct arrange
#' @export
getPidsPerWardData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT ward_name, patient_id, encounter_id ",
    "FROM ", table_name, "\n"
  )

  pids_per_ward_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(patient_id, encounter_id)

  if (nrow(pids_per_ward_table) == 0) {
    stop("The pids_per_ward table is empty. Please check the data.")
  }

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
#' This is important for managing concurrent data access in environments where multiple processes
#' might access the data simultaneously.
#' @param table_name A character string specifying the name of the database table to query.
#' This table should include columns `pat_id`, `record_id`.
#'
#' @return A dataframe (`patient_fe_table`) that includes patient data, cleaned to ensure distinct
#' entries per `pat_id`, arranged in order.
#'
#' @details The function constructs an SQL query to select relevant columns from the specified table,
#' retrieves the data while checking for read-only access, and processes it to remove duplicates and
#' arrange the records.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getPatientFeData <- function(lock_id, table_name) {
  query <- paste0("SELECT pat_id, record_id FROM ", table_name, "\n")

  patient_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id) |>
    dplyr::mutate(processing_exclusion_reason = NA_character_)

  if (nrow(patient_fe_table) == 0) {
    stop("The patient_fe table is empty. Please check the data.")
  }

  return(patient_fe_table)
}

#------------------------------------------------------------------------------#
#' Retrieve Fall Front-End Data from Database
#'
#' This function queries a specified database table to retrieve front-end data related to patient
#' encounters ("Fälle"). It fetches relevant fields such as encounter ID, patient ID, station,
#' dates, and metadata, and returns a cleaned version of the table with duplicates removed and
#' sorted by `record_id`.
#'
#' @param lock_id A database connection identifier (used by `etlutils::dbGetReadOnlyQuery`) to
#'                ensure read-only access.
#' @param table_name A character string specifying the name of the database table from which to
#'                   retrieve the data.
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
#'
#' @details
#' The function executes a SQL `SELECT` query on the specified `table_name`, retrieving all
#' expected columns. It then:
#' \enumerate{
#'   \item Removes exact duplicates.
#'   \item Sorts rows by `record_id` to ensure consistent ordering.
#' }
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange select
#' @export
getFallFeData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT record_id, fall_fhir_enc_id, fall_pat_id, ",
    "fall_id, fall_studienphase, fall_station, fall_aufn_dat ",
    "FROM ", table_name, "\n"
  )

  fall_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    # temporary remove fall_studienphase, since it is not used at the moment (transformation dependent on purpose)
    dplyr::select(-fall_studienphase) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id)

  # temporary deactivate, since fall_studienphase is not used at the moment

  # if (any(is.na(fall_fe_table$fall_studienphase))) {
  #   warning("The fall_fe table contains NA values in fall_studienphase.
  #           These will be replaced with 'PhaseA'.")
  #
  #   fall_fe_table <- fall_fe_table |>
  #     dplyr::mutate(fall_studienphase = dplyr::if_else(is.na(fall_studienphase),
  #       "PhaseA",
  #       fall_studienphase
  #     )) |>
  #     dplyr::distinct()
  # }

  if (nrow(fall_fe_table) == 0) {
    stop("The fall_fe table is empty. Please check the data.")
  }

  return(fall_fe_table)
}

#------------------------------------------------------------------------------#
#' Retrieve Medikationsanalyse Front-End Data
#'
#' This function queries a database table containing front-end documentation of medication analyses
#' and returns a cleaned and ordered data frame.
#'
#' @param lock_id A database lock identifier used to manage access when querying data via
#' `etlutils::dbGetReadOnlyQuery()`.
#' @param table_name A character string specifying the name of the database table to query.
#'
#' @return A tibble or data frame containing distinct rows of medication analysis data,
#' ordered by `record_id`, `fall_meda_id`, and `meda_dat`.
#'
#' @details
#' The following columns are retrieved from the specified table:
#' \itemize{
#'   \item `record_id` – Unique identifier for the patient record.
#'   \item `fall_meda_id` – Identifier linking to the specific encounter (cis id).
#'   \item `meda_id` – Identifier for the medication analysis instance.
#'   \item `meda_dat` – Date of the medication analysis.
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
  query <- paste0(
    "SELECT record_id, fall_meda_id, meda_id, meda_dat, ",
    "medikationsanalyse_complete FROM ", table_name, "\n"
  )

  medikationsanalyse_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id, fall_meda_id, meda_dat)

  if (nrow(medikationsanalyse_fe_table) == 0) {
    stop("The medikationsanalyse_fe table is empty. Please check the data.")
  }

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
#' - Identifiers: `record_id`, `mrp_meda_id`, `mrp_id`
#' - Problem indicators: `mrp_pigrund___21` for contraindications
#' - contraindication categories: `mrp_ip_klasse_01`
#' - MRP details and intervention realization: `mrp_dokup_hand_emp_akz` and completion status
#'
#' The function ensures uniqueness using `distinct()` and sorts results by `record_id`,
#' `mrp_meda_id`, and `mrp_id` for easier downstream processing.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getMRPDokumentationValidierungFeData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT record_id, mrp_meda_id, mrp_id, mrp_pigrund___21, ",
    "mrp_ip_klasse_01, mrp_dokup_hand_emp_akz, mrpdokumentation_validierung_complete ",
    "FROM ", table_name, "\n"
  )

  mrp_dokumentation_validierung_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id, mrp_meda_id, mrp_id)

  if (nrow(mrp_dokumentation_validierung_fe_table) == 0) {
    stop("The mrp_dokumentation_validierung_fe table is empty. Please check the data.")
  }

  return(mrp_dokumentation_validierung_fe_table)
}
