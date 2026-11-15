#' Load patient procedures once and resolve their original OPS catalogue
#'
#' @param patient_ids Patients selected for cohort preparation.
#' @param encounters Already loaded latest Encounter records. Related origin
#'   encounters are fetched only if absent, including concurrent outpatient cases.
#' @param catalogue Annual terminal OPS catalogues from etlutils.
#' @param timezone Analysis time zone.
#' @return A list with prepared procedures and the reusable enriched Encounter set.
loadCohortProcedureData <- function(patient_ids, encounters, catalogue, timezone) {
  columns <- c(
    "proc_id", "proc_patient_ref", "proc_encounter_calculated_ref",
    "proc_code_system", "proc_code_version", "proc_code_code",
    "proc_performeddatetime", "proc_performedperiod_start"
  )
  patient_refs <- etlutils::fhirdataGetPatientReference(patient_ids)
  filter <- paste0(
    "WHERE proc_patient_ref IN ", etlutils::fhirdbGetQueryList(patient_refs),
    " AND (proc_status IS NULL OR proc_status <> 'entered-in-error')",
    " AND proc_code_system IN ('http://fhir.de/CodeSystem/bfarm/ops',",
    " 'http://fhir.de/CodeSystem/dimdi/ops', 'https://terminologien.bfarm.de/fhir/CodeSystem/ops')"
  )
  procedures <- data.table::as.data.table(etlutils::dbGetReadOnlyQuery(
    dataprocessor::getQueryToLoadResourcesLastVersionFromDB("Procedure", columns, filter),
    lock_id = "Cohort Description: patient OPS"
  ))
  procedures[, start_datetime := pmin(proc_performeddatetime, proc_performedperiod_start, na.rm = TRUE)]
  encounters <- loadCohortOriginEncounters(procedures$proc_encounter_calculated_ref, encounters)
  list(
    procedures = prepareCohortOPS(procedures, encounters, catalogue, timezone),
    encounters = encounters
  )
}

# Reuse already loaded origins across diagnoses and procedures, including parallel cases.
loadCohortOriginEncounters <- function(references, encounters) {
  origins <- etlutils::fhirdataExtractIDs(references)
  missing_origins <- setdiff(origins[!is.na(origins) & nzchar(origins)], encounters$enc_id)
  if (length(missing_origins)) {
    more <- etlutils::fhirdataGetAllEncounters(
      missing_origins,
      lock_id_extension = "Cohort Description: coding origin encounters",
      column_names = c(
        "enc_id", "enc_patient_ref", "enc_main_encounter_calculated_ref",
        "enc_class_code", "enc_period_start", "enc_period_end"
      )
    )
    encounters <- unique(data.table::rbindlist(list(encounters, more), use.names = TRUE, fill = TRUE))
  }
  encounters
}
