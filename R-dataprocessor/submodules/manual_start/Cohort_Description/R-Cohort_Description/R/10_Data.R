#' Build one case record from the first known IP stay and hospital Encounter
#' @param first First-contact selections.
#' @param contacts All linked known IP assignments.
#' @param encounters Latest related Encounter rows.
#' @param patients Latest Patient demographics.
#' @param timezone Analysis time zone.
#' @return Unique case rows with demographics and basic stay metrics.
buildCohortCases <- function(first, contacts, encounters, patients, timezone) {
  e <- data.table::copy(data.table::as.data.table(encounters))
  has_snapshot_age <- "enc_age_at_admission" %in% names(e)
  e[, patient_id := etlutils::fhirdataExtractIDs(enc_patient_ref, unique = FALSE)]
  if (!"enc_age_at_admission" %in% names(e)) e[, enc_age_at_admission := NA_real_]
  hospital <- unique(e[, .(
    patient_id,
    case_id = enc_id,
    hospital_start = enc_period_start, hospital_end = enc_period_end,
    age = enc_age_at_admission
  )])
  hospital <- hospital[case_id %in% first$case_id]
  if (anyDuplicated(hospital, by = c("patient_id", "case_id")))
    stop("Conflicting hospital intervals or admission ages.")
  cases <- merge(
    first[, .(patient_id, case_id, ward_name, encounter_id,
      ip_start = enc_period_start, ip_end = enc_period_end
    )], hospital,
    by = c("patient_id", "case_id"), all.x = TRUE, sort = FALSE
  )
  patients <- unique(data.table::as.data.table(patients)[
    ,
    .(patient_id = pat_id, birthdate = pat_birthdate, gender = pat_gender)
  ])
  if (anyDuplicated(patients$patient_id)) stop("Conflicting patient demographics.")
  cases <- merge(cases, patients, by = "patient_id", all.x = TRUE, sort = FALSE)
  # Use exact admission ages from snapshots; raw databases use the same
  # 365.25-day convention as the established reporting/snapshot calculations.
  if (!has_snapshot_age) cases[, age := floor(as.numeric(difftime(as.Date(hospital_start, tz = timezone),
    as.Date(birthdate),
    units = "days"
  )) / 365.25)]
  cases[age < 0, age := NA_real_]
  cases[!gender %in% c("male", "female", "other", "unknown"), gender := NA_character_]
  cases[, gender := data.table::fifelse(gender %in% c("other", "unknown"), "other", gender)]
  counts <- contacts[, .(
    m17 = data.table::uniqueN(encounter_id),
    m18 = data.table::uniqueN(ward_name)
  ), by = .(patient_id, case_id)]
  cases <- merge(cases, counts, by = c("patient_id", "case_id"), all.x = TRUE, sort = FALSE)
  cases[, `:=`(
    m15 = as.numeric(difftime(ip_start, hospital_start, units = "days")),
    m43 = as.numeric(difftime(hospital_end, hospital_start, units = "days")),
    m62 = as.numeric(difftime(ip_end, ip_start, units = "days"))
  )]
  cases
}

#' Load and prepare source data once through established manual-submodule helpers
#' @param prepared Encounter preparation result.
#' @param timezone Analysis time zone.
#' @return Cases, normalised clinical events and aggregate quality diagnostics.
loadCohortAnalysisData <- function(prepared, timezone) {
  contacts <- prepared$known_ip_contacts
  contacts[, case_id := etlutils::fhirdataExtractIDs(enc_main_encounter_calculated_ref, unique = FALSE)]
  first <- selectFirstCohortContacts(contacts)
  patients <- getResourcesFromDB(
    "Patient", c("pat_id", "pat_birthdate", "pat_gender"),
    unique(first$patient_id)
  )
  cases <- buildCohortCases(first, contacts, prepared$encounters, patients, timezone)
  record_ids <- unique(dataprocessor::loadExistingRecordIDsFromDB(unique(cases$patient_id)))
  data.table::setnames(record_ids, "pat_id", "patient_id")
  if (anyDuplicated(record_ids$record_id)) stop("REDCap records map to multiple patients.")
  analyses <- etlutils::getMedikationsanalyseFeData(
    "Cohort Description: MedA",
    "v_medikationsanalyse_fe_last_version"
  )
  analyses <- merge(analyses, record_ids, by = "record_id", sort = FALSE)
  case_links <- etlutils::dbGetReadOnlyQuery(
    "SELECT DISTINCT record_id, fall_id AS fall_meda_id, fall_fhir_enc_id AS case_id FROM v_fall_fe_last_version",
    lock_id = "Cohort Description: MedA case links"
  )
  if (anyDuplicated(case_links, by = c("record_id", "fall_meda_id")))
    stop("Ambiguous MedA hospital-case links.")
  analyses <- merge(analyses, case_links, by = c("record_id", "fall_meda_id"), sort = FALSE)
  validations <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT DISTINCT record_id, mrp_meda_id AS meda_id, mrp_id, ",
      "mrp_dokup_hand_emp_akz AS outcome FROM v_mrpdokumentation_validierung_fe_last_version"
    ),
    lock_id = "Cohort Description: manual MRP validation"
  )
  validations <- merge(validations, record_ids, by = "record_id", sort = FALSE)
  cases <- calculateCohortMedAFeatures(cases, analyses, contacts, validations)
  # Historical hospital admissions are fetched once for all patients, not once per case.
  history <- getResourcesFromDB("Encounter", c("enc_id", "enc_patient_ref", "enc_period_start"),
    unique(cases$patient_id),
    additional_conditions = c(
      "enc_type_code = 'fallkontakt'", "enc_class_code IN ('IMP', 'ACUTE', 'NONAC')"
    )
  )
  history[, `:=`(
    patient_id = etlutils::fhirdataExtractIDs(enc_patient_ref, unique = FALSE),
    start_datetime = enc_period_start
  )]
  history <- unique(history[, .(patient_id, enc_id, start_datetime)])
  windows <- cases[, .(patient_id, ip_start, case_id, case_row = .I)]
  previous <- history[windows,
    on = .(patient_id, start_datetime <= ip_start),
    nomatch = NULL, allow.cartesian = TRUE, .(case_row = i.case_row, current_case = i.case_id, enc_id)
  ]
  previous <- previous[enc_id != current_case, .(n = data.table::uniqueN(enc_id)), by = case_row]
  cases[, m360 := 0L]
  cases[previous$case_row, m360 := previous$n]
  patient_ids <- unique(cases$patient_id)
  diagnoses <- getConditionsFromDB(patient_ids)
  encounters <- loadCohortOriginEncounters(diagnoses$con_encounter_calculated_ref, prepared$encounters)
  diagnoses <- prepareCohortCoding(
    diagnoses, encounters, etlutils::loadICDCatalogues(), timezone, "con", "icd"
  )
  diagnoses[, `:=`(
    patient_id = etlutils::fhirdataExtractIDs(con_patient_ref, unique = FALSE),
    code = con_code_code
  )]
  requests <- getMedicationRequestsFromDB(patient_ids, status_exclusion = c("cancelled", "entered-in-error"))
  medications <- getATCMedicationsFromDB(requests, data.table::data.table(), data.table::data.table())
  medications <- appendATCColumns(requests, medications)
  medications[, `:=`(patient_id = etlutils::fhirdataExtractIDs(medreq_patient_ref, unique = FALSE), code = atc_code)]
  observations <- prepareCohortLaboratory(getObservationsFromDB(patient_ids), getLOINCMapping()$processed_content)
  ops <- loadCohortProcedureData(patient_ids, encounters, etlutils::loadOPSCatalogues(), timezone)
  quality <- data.table::data.table(
    check = c(
      "known_ip_contacts", "cases_before_eligibility", "cases_missing_hospital_start",
      "cases_missing_hospital_end", "cases_missing_age", "ops_catalogue_approximated",
      "ops_catalogue_unresolved", "icd_catalogue_approximated", "icd_catalogue_unresolved", "observations_missing_event_start", "diagnoses_missing_event_start"
    ),
    count = c(
      data.table::uniqueN(contacts, by = c("patient_id", "encounter_id")), nrow(cases),
      sum(is.na(cases$hospital_start)), sum(is.na(cases$hospital_end)), sum(is.na(cases$age)),
      sum(ops$procedures$ops_year_approximated), sum(is.na(ops$procedures$ops_catalogue_year)),
      sum(diagnoses$icd_year_approximated), sum(is.na(diagnoses$icd_catalogue_year)),
      sum(is.na(observations$start_datetime)), sum(is.na(diagnoses$start_datetime))
    )
  )
  list(
    cases = calculateCohortCodeFeatures(cases, diagnoses, medications, observations, ops$procedures),
    quality = quality
  )
}
