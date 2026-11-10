#' Prepare known INTERPOLAR station assignments for cohort description
#'
#' Loads distinct station, patient and Encounter assignments from `v_pids_per_ward`
#' in the database selected by the shared manual-project workflow. These assignments
#' identify known INTERPOLAR contacts; their chronological order is determined later
#' from the documented Encounter timestamps.
#'
#' @return Invisibly, a data.table with `ward_name`, `patient_id` and `encounter_id`.
#'
#' @export
prepareCohortDescription <- function() {
  pids_per_ward <- etlutils::getPidsPerWardData(
    lock_id = "Cohort Description: load known station assignments",
    table_name = "v_pids_per_ward"
  )
  message(
    "Cohort Description initialized: ", nrow(pids_per_ward),
    " distinct station/patient/Encounter assignments loaded."
  )
  invisible(pids_per_ward)
}
