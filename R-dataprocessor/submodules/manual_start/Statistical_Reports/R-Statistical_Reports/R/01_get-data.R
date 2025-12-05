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
#' 2. Filters the results to include only rows where one or more of the following conditions are met:
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
#' 4. Checks for potential duplicates in:
#'    - `pat_id`: should uniquely identify patients in FHIR
#'    - `pat_identifier_value`: should uniquely identify patients in the hospital system
#'    If duplicates are found, warnings are issued for manual inspection.
#'
#' @importFrom dplyr distinct arrange filter
#' @export
getPatientData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT pat_id, pat_identifier_system, pat_identifier_type_system, ",
    "pat_identifier_type_code, pat_identifier_value, pat_birthdate ",
    "FROM ", table_name, "\n"
  )

  patient_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::filter(
      (exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM") &
        !FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM %in% c(".*", "") &
        grepl(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM, pat_identifier_system)) |
        (exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM") &
          !FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM %in% c(".*", "") &
          grepl(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM, pat_identifier_type_system)) |
        (exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE") &
          !FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE %in% c(".*", "") &
          grepl(FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE, pat_identifier_type_code)) |
        # keep all rows if all filters are inactive or missing
        ((!exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM") |
          FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM %in% c(".*", "")) &
          (!exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM") |
            FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM %in% c(".*", "")) &
          (!exists("FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE") |
            FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE %in% c(".*", ""))
        )
    ) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id) |>
    dplyr::mutate(processing_exclusion_reason = NA_character_)

  if (nrow(patient_table) == 0) {
    stop("The patient table is empty. Please check the data.")
  }

  if (checkMultipleRows(patient_table, c("pat_id"))) {
    warning("The patient table contains multiple rows for the same pat_id(FHIR).
            Please check the data.")
    patient_table <- patient_table |>
      addMultipleRowsProcessingExclusionReason(c("pat_id"), "multiple_rows_per_pat_id")
  }

  if (checkMultipleRows(patient_table, c("pat_identifier_value"))) {
    warning("The patient table contains multiple rows for the same patient identifier (cis).
            Please check the data.")
    patient_table <- patient_table |>
      addMultipleRowsProcessingExclusionReason(
        c("pat_identifier_value"),
        "multiple_rows_per_pat_identifier_value"
      )
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
#'   - `enc_id`, `enc_identifier_value`, `enc_patient_ref`, `enc_partof_calculated_ref`
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
#' 2. Filters out einrichtungskontakt encounters that do not match the expected FHIR identifier
#'    system for encounters (if defined as `COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM`).
#' 3. Filters encounters to include only those with a start date within one year before the reporting_period_start
#' 4. Filters out encounters with class codes "PRENC", "VR", or "HH" to exclude non-relevant records.
#' 5. Filters out encounters with statuses "planned", "cancelled", "entered-in-error" or "unknown"
#'    to focus on relevant records.
#' 6. Uses the `PivotWiderTwoSystems` function to expand encounter type codes into two separate
#'    columns based on specified systems and codes for Kontaktebene and Kontaktart.
#'    Then further filters out encounters of type "begleitperson".
#' 7. Sorts the data by patient reference, encounter ID, time-related fields, and status-related
#'    fields.
#' 8. Adds a `processing_exclusion_reason` column initialized with `NA` to log any processing exclusions.
#' 9. Checks for empty results and unexpected status values, issuing errors or warnings if necessary.
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
    "enc_identifier_system, enc_type_system ",
    "FROM ", table_name, "\n"
  )

  encounter_table_raw <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct()

  if (nrow(encounter_table_raw) == 0) {
    stop("No encounter data downloaded from database. Please check the database.")
  }

  if (etlutils::isDefinedAndNotEmpty("COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM")) {
    encounter_table_raw <- encounter_table_raw |>
      dplyr::filter(!(enc_type_code == "einrichtungskontakt" &
        !enc_identifier_system %in% COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM))
  }

  if (nrow(encounter_table_raw) == 0) {
    stop("The downloaded and identifier-filtered encounter table is empty. Please check (if defined)
    for the correct definition of COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM (especially for 'einrichtungskontakte').")
  }

  encounter_table <- encounter_table_raw |>
    dplyr::filter(enc_period_start >= (as.POSIXct(report_period_start) - 365) | is.na(enc_period_start))

  if (nrow(encounter_table) == 0) {
    stop("The downloaded and date-filtered encounter table (only encounter data from one year before
    reporting period starts) is empty. Please check for enc_period_start dates being within the
         defined reporting period")
  }

  encounter_table <- encounter_table |>
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
      id_column = "enc_id"
    ) |>
    dplyr::filter(!enc_type_code_Kontaktart %in% c("begleitperson")) |>
    dplyr::distinct() |>
    dplyr::arrange(enc_patient_ref, enc_id, enc_period_start, enc_period_end, enc_status)

  if (nrow(encounter_table) == 0) {
    stop("The encounter table with extended filtering is empty. Please check the data for expected
    implementation of enc_class_code, enc_status, enc_type_code and enc_type_system.")
  }

  if (any(is.na(encounter_table$enc_period_start))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(is.na(enc_period_start) &
        is.na(processing_exclusion_reason), "missing_start_date", processing_exclusion_reason))
    print(encounter_table |>
      dplyr::filter(is.na(enc_period_start)), width = Inf)
    warning("The encounter table contains NA values in enc_period_start.
            Relevant encounter data may be missed. Please check the data")
  }

  if (any(!is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
    (is.na(encounter_table$enc_type_code_Kontaktebene)))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(processing_exclusion_reason) &
          !is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
          is.na(encounter_table$enc_type_code_Kontaktebene),
        "missing_kontaktebene_for_imp_encounter", processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter(enc_class_code == "IMP" & is.na(enc_type_code_Kontaktebene)), width = Inf)
    warning("The encounter table with extended filtering contains inpatient encounters with missing
    type codes for Kontaktebene. Please check the data for expected implementation of enc_type_code
            and enc_type_system.")
  }

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

  if (any(!is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
    (is.na(encounter_table$enc_status) | !encounter_table$enc_status %in% c(
      "finished", "in-progress", "onleave"
    )))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(enc_class_code == "IMP" &
        (is.na(encounter_table$enc_status) | !enc_status %in% c("finished", "in-progress", "onleave")) &
        is.na(processing_exclusion_reason),
      "unexpected_imp_status", processing_exclusion_reason
      ))
    print(
      encounter_table |>
        dplyr::filter(enc_class_code == "IMP" & (is.na(enc_status) | !enc_status %in% c(
          "finished", "in-progress",
          "onleave"
        ))),
      width = Inf
    )
    warning("The encounter table contains inpatient encounters with unexpected or NA status values.
            Please check the data.")
  }

  if (any(!is.na(encounter_table$enc_class_code) & encounter_table$enc_class_code == "IMP" &
    (!is.na(encounter_table$enc_status) &
      encounter_table$enc_status == "finished") & is.na(encounter_table$enc_period_end))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(enc_class_code == "IMP" &
        enc_status == "finished" & is.na(enc_period_end) &
        is.na(processing_exclusion_reason),
      "imp_finished_without_end_date", processing_exclusion_reason
      ))
    print(
      encounter_table |>
        dplyr::filter(enc_class_code == "IMP" & enc_status == "finished" &
          is.na(encounter_table$enc_period_end)),
      width = Inf
    )
    warning("The encounter table contains finished IMP encounters without an end date.
         Please check the data.")
  }

  if (any((!encounter_table$enc_class_code %in% c("AMB", "SS", "IMP")) &
    !is.na(encounter_table$enc_class_code))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else((!enc_class_code %in%
        c("AMB", "SS", "IMP")) &
        !is.na(enc_class_code) &
        is.na(processing_exclusion_reason),
      "unexpected_class_code", processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter((!encounter_table$enc_class_code %in% c("AMB", "SS", "IMP")) &
        !is.na(encounter_table$enc_class_code)), width = Inf)
    warning("The encounter table contains class codes with unexpected values.
            Please check the data.")
  }

  if (any((!encounter_table$enc_type_code_Kontaktart %in% c(
    "vorstationaer", "nachstationaer",
    "teilstationaer", "tagesklinik",
    "nachtklinik", "normalstationaer",
    "intensivstationaer", "ub", "konsil",
    "stationsaequivalent", "operation"
  )) &
    !is.na(encounter_table$enc_type_code_Kontaktart))) {
    encounter_table <- encounter_table |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else((!enc_type_code_Kontaktart %in% c(
        "vorstationaer", "nachstationaer",
        "teilstationaer", "tagesklinik",
        "nachtklinik", "normalstationaer",
        "intensivstationaer", "ub", "konsil",
        "stationsaequivalent", "operation"
      )) &
        !is.na(enc_type_code_Kontaktart) &
        is.na(processing_exclusion_reason),
      "unexpected_kontaktart_code", processing_exclusion_reason
      ))
    print(encounter_table |>
      dplyr::filter((!enc_type_code_Kontaktart %in% c(
        "vorstationaer", "nachstationaer",
        "teilstationaer", "tagesklinik",
        "nachtklinik", "normalstationaer",
        "intensivstationaer", "ub", "konsil",
        "stationsaequivalent", "operation"
      )) &
        !is.na(enc_type_code_Kontaktart)), width = Inf)
    warning("The encounter table contains type codes for Kontaktart with unexpected values.
            Please check the data.")
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
#' This table should include columns `pat_id`, `pat_cis_pid`, `record_id`.
#'
#' @return A dataframe (`patient_fe_table`) that includes patient data, cleaned to ensure distinct
#' entries per `pat_id`, arranged in order.
#'
#' @details The function constructs an SQL query to select relevant columns from the specified table,
#' retrieves the data while checking for read-only access, and processes it to remove duplicates and
#' arrange the records. If there are multiple rows for a single `pat_id`
#' (related to the FHIR identifier) or `pat_cis_pid` (related to the cis identifier), errors are
#' issued to indicate potential data issues.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getPatientFeData <- function(lock_id, table_name) {
  query <- paste0("SELECT pat_id, pat_cis_pid, record_id FROM ", table_name, "\n")

  patient_fe_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id) |>
    dplyr::mutate(processing_exclusion_reason = NA_character_)

  if (nrow(patient_fe_table) == 0) {
    stop("The patient_fe table is empty. Please check the data.")
  }

  if (checkMultipleRows(patient_fe_table, c("pat_id"))) {
    patient_fe_table <- patient_fe_table |>
      addMultipleRowsProcessingExclusionReason(c("pat_id"), "multiple_rows_per_pat_id_in_fe")
    warning("The patient_fe table contains multiple rows for the same pat_id(FHIR).
            Please check the data.")
  }

  if (checkMultipleRows(patient_fe_table, c("pat_cis_pid"))) {
    patient_fe_table <- patient_fe_table |>
      addMultipleRowsProcessingExclusionReason(
        c("pat_cis_pid"),
        "multiple_rows_per_pat_identifier_in_fe"
      )
    warning("The patient_fe table contains multiple rows for the same patient identifier (cis).
            Please check the data.")
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
#'   \item `meda_nieren_insuf_chron` – Flag indicating if the patient has chronic kidney
#'                                     insufficiency.
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
  query <- paste0(
    "SELECT record_id, meda_anlage, meda_edit, fall_meda_id, ",
    "meda_id, meda_typ, meda_dat, meda_gewicht_aktuell, meda_gewicht_aktl_einheit, ",
    "meda_groesse, meda_groesse_einheit, meda_nieren_insuf_chron, meda_nieren_insuf_ausmass, ",
    "meda_nieren_insuf_dialysev, meda_leber_insuf, meda_leber_insuf_ausmass, meda_schwanger_mo, ",
    "meda_ma_thueberw, meda_mrp_detekt, meda_aufwand_zeit, meda_notiz, ",
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
#' - Identifiers: `record_id`, `mrp_anlage`, `mrp_edit`, `mrp_meda_id`, `mrp_id`
#' - Descriptors: `mrp_kurzbeschr`, `mrp_hinweisgeber`, `mrp_hinweisgeber_oth`
#' - Medication fields: `mrp_wirkstoff`, `mrp_atc1` to `mrp_atc5`
#' - Product-related fields: `mrp_med_prod`, `mrp_med_prod_sonst`
#' - Problem indicators: `mrp_pigrund___1` to `mrp_pigrund___27`
#' - Intervention categories: `mrp_ip_klasse_01`, `mrp_ip_klasse_disease`, `mrp_ip_klasse_nieren_insuf`
#' - Measures taken (AM and organizational): `mrp_massn_am___1` to `mrp_massn_am___10`,
#'   `mrp_massn_orga___1` to `mrp_massn_orga___8`
#' - MRP details and intervention realization: `mrp_notiz`, `mrp_dokup_hand_emp_akz`, `mrp_merp`,
#'   and completion status
#'
#' The function ensures uniqueness using `distinct()` and sorts results by `record_id`,
#' `mrp_meda_id`, and `mrp_id` for easier downstream processing.
#'
#' @importFrom etlutils dbGetReadOnlyQuery
#' @importFrom dplyr distinct arrange
#' @export
getMRPDokumentationValidierungFeData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT record_id, mrp_anlage, mrp_edit, ",
    "mrp_meda_id, mrp_id, mrp_kurzbeschr, mrp_hinweisgeber, mrp_hinweisgeber_oth, ",
    "mrp_wirkstoff, ",
    paste0("mrp_atc", 1:5, collapse = ", "), ", ",
    "mrp_med_prod, mrp_med_prod_sonst, ",
    paste0("mrp_pigrund___", 1:27, collapse = ", "), ", ",
    "mrp_ip_klasse_01, mrp_ip_klasse_disease, mrp_ip_klasse_nieren_insuf, ",
    paste0("mrp_massn_am___", 1:10, collapse = ", "), ", ",
    paste0("mrp_massn_orga___", 1:8, collapse = ", "), ", ",
    "mrp_notiz, mrp_dokup_hand_emp_akz, mrp_merp, mrpdokumentation_validierung_complete ",
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
