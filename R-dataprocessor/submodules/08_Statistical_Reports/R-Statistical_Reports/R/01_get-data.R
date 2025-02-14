#' Get Patient Data
#'
#' This function retrieves patient data, specifically patient IDs and birthdates,
#' from a specified database table. It ensures data consistency by checking for
#' duplicate birthdates for the same patient.
#'
#' @param lock_id A character string specifying the lock ID for the database query.
#'   This ensures safe access to the database during the query execution.
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain `pat_id` and `pat_birthdate` columns.
#'
#' @return A data frame containing unique patient IDs (`pat_id`) and birthdates
#'   (`pat_birthdate`), sorted by `pat_id`.
#'
#' @details
#' The function performs the following steps:
#' 1. Executes an SQL query to retrieve the `pat_id` and `pat_birthdate` columns
#'    from the specified `table_name`.
#' 2. Removes duplicate rows from the result.
#' 3. Sorts the table by `pat_id`.
#' 4. Checks for duplicate birthdates for the same patient using the
#'    `check_multiple_rows` function. If duplicates are found, a warning message is printed.
#'
#'
#' @importFrom dplyr distinct arrange
#' @export
get_patient_data <- function(lock_id, table_name) {

  query <- paste0("SELECT pat_id, pat_birthdate FROM ", table_name, "\n")

  patient_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    dplyr::arrange(pat_id)

  if (check_multiple_rows(patient_table, c("pat_id"))) {
    warning("The patient table contains multiple birth dates for the same patient. Please check the data.")
  }

  return(patient_table)
}

#------------------------------------------------------------------------------#

#' Get Encounter Data
#'
#' This function retrieves encounter data from a specified database table and returns a clean,
#' sorted data frame containing distinct encounter records.
#'
#' @param lock_id A character string specifying the lock ID for the database query.
#'   This ensures safe access to the database during the query execution.
#' @param table_name A character string specifying the name of the database table to query.
#'   The table must contain the following columns: `enc_id`, `enc_patient_ref`, `enc_partof_ref`,
#'   `enc_class_code`, `enc_type_code`, `enc_period_start`,
#'   `enc_period_end`, `enc_status`, `enc_servicetype_display`,
#'   `enc_location_ref`, `enc_location_display`, and `input_datetime`.
#'
#' @return A data frame containing distinct encounter records with the following columns:
#'   - `enc_id`: Encounter ID
#'   - `enc_patient_ref`: Reference to the patient associated with the encounter
#'   - `enc_partof_ref`: Reference to the parent encounter in the style: "Encounter/enc_id"
#'   - `enc_class_code`: Class code of the encounter i.e. IMP for inpatients
#'   - `enc_type_code`: Type code of the encounter i.e. einrichtungskontakt, versorgungsstellenkontakt
#'   - `enc_period_start`: Start date of the encounter period (for the entire stay or for the stay on the ward depending on enc_type_code)
#'   - `enc_period_end`: End date of the encounter period (for the entire stay or for the stay on the ward depending on enc_type_code)
#'   - `enc_status`: Status of the encounter i.e. 'in-progress', 'finished'
#'   - `enc_servicetype_display`: Display name of the service type associated with the encounter
#'   - `enc_location_ref`: Reference to the location where the encounter took place (ward)
#'   - `enc_location_display`: Display name of the location where the encounter took place (ward)
#'   - `input_datetime`: Date and time when the record was input
#'
#' @details
#' The function executes an SQL query to fetch the specified columns from the given table.
#' It removes duplicate rows from the result and sorts the table by
#' `enc_patient_ref`, `enc_partof_ref`, `enc_id`, `enc_period_start`, `enc_period_end`,
#' `enc_status`,`enc_servicetype_display`,`enc_location_ref`, `enc_location_display`, and `input_datetime`
#' to ensure the output is well-organized.
#'
#' @importFrom dplyr distinct arrange
#' @export
get_encounter_data <- function(lock_id, table_name) {

  query <- paste0("SELECT enc_id, enc_patient_ref, enc_partof_ref, enc_class_code, enc_type_code, ",
                  "enc_period_start, enc_period_end, enc_status, enc_servicetype_display, ",
                  "enc_location_ref, enc_location_display, input_datetime ",
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
#'   - `patient_id`: The unique identifier of the patient.
#'   - `encounter_id`: The unique identifier of the encounter.
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
get_pids_per_ward_data <- function(lock_id, table_name) {

  query <- paste0("SELECT ward_name, patient_id, encounter_id, input_datetime ",
                  "FROM ", table_name, "\n")

  pid_per_ward_table <- etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id) |>
    dplyr::distinct() |>
    select_newest_input(grouping_vars=c("patient_id", "encounter_id", "ward_name")) |>
    dplyr::arrange(patient_id, encounter_id, input_datetime)

  return(pid_per_ward_table)
}
