###########
# General #
###########

#
# Days after encounter end to check for MRP evaluations
#
if (!exists("DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS")) {
  # Default value if not set
  DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS <- 14
}

#
# Type of MRP
#
MRP_CALCULATION_TYPE <- etlutils::namedListByValue(
  "Drug_Disease",
  "Drug_Drug",
  "Drug_DrugGroup",
  "Drug_Kidney"
)

#
# Load Einrichtungskontakt Encounters without retrolective MRP evaluation
#
getEncountersWithoutRetrolectiveMRPEvaluationFromDB <- function(mrp_calculation_type) {
  # Get all Einrichtungskontakt encounters that ended at least 14 days ago and do not have a retrolective MRP evaluation
  query_date <- Sys.Date() - DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS
  query <- paste0(
    "SELECT DISTINCT enc_id, enc_period_start, enc_patient_ref\n",
    "FROM v_encounter_last_version\n",
    "WHERE enc_period_end <= '", query_date, "'\n",
    "AND enc_type_code = 'einrichtungskontakt'\n",
    "AND enc_id NOT IN (\n",
    "  SELECT enc_id FROM v_dp_mrp_calculations\n",
    "  WHERE mrp_type = '", mrp_calculation_type, "'\n",
    ")"
  )
  encounters <- etlutils::dbGetReadOnlyQuery(query)
}

#
# Get the study phase for a unique ward_name from defined toml parameters.
#
getStudyPhase <- fuction(ward_name) {
  if (ward_name %in$ WARDS_PHASE_A) {
    return("PhaseA")
  } else if (ward_name %in% WARDS_PHASE_B_TEST) {
    return("PhaseBTest")
  } else if (ward_name %in% WARDS_PHASE_B) {
    return("PhaseB")
  }
  return(NULL)
}

#
# Load medikationsanalyse_fe from database
#
getMedicationAnalysesFromDB <- function(record_ids) {
  query_ids <- etlutils::fhirdbGetQueryList(record_ids$record_id)
  query <- paste0("SELECT * FROM v_medikationsanalyse_fe WHERE record_id in ", query_ids, "\n")
  medication_analyses <- etlutils::dbGetReadOnlyQuery(query)
  data.table::setorder(medication_analyses, meda_dat)
  return(medication_analyses)
}

###############################
# Load FHIR resources from DB #
###############################

#
# General function to load resources by PID
#
getResourcesFromDB <- function(resource_name, column_names, patient_references, status_exclusion = NULL, additional_conditions = NULL) {
  patient_ref_column_name <- etlutils::fhirdbGetPIDColumn(resource_name)
  patient_references <- etlutils::fhirdataGetPatientReference(patient_references)
  patient_references <- etlutils::fhirdbGetQueryList(patient_references)
  status_exclusion <- etlutils::fhirdbGetQueryList(status_exclusion, return_NA_if_empty = TRUE)

  where_clause <- paste0("WHERE ", patient_ref_column_name, " IN ", patient_references, "\n")

  if (!is.null(status_exclusion) && !is.na(status_exclusion) && !etlutils::isSimpleNA(status_exclusion) && length(status_exclusion)) {
    resource_column_prefix <- etlutils::fhirdbGetResourceAbbreviation(resource_name)
    where_clause <- paste0(where_clause, "  AND (", resource_column_prefix, "_status IS NULL OR ", resource_column_prefix, "_status NOT IN ", status_exclusion, ")\n")
  }

  if (!is.null(additional_conditions) && !etlutils::isSimpleNA(additional_conditions) && length(additional_conditions)) {
    additional_conditions <- paste(additional_conditions, collapse = "\n AND ")
    where_clause <- paste0(where_clause, "  AND ", additional_conditions, "\n")
  }

  query <- getQueryToLoadResourcesLastVersionFromDB(resource_name, column_names, where_clause)

  etlutils::dbGetReadOnlyQuery(query)
}

#
# Extract new column 'med_id' from medication reference
#
addMedicationIdColumn <- function(medication_resources) {
  med_ref_col_name <- colnames(medication_resources)[endsWith(colnames(medication_resources), "_medicationreference_ref")]
  medication_resources[, med_id := etlutils::fhirdataExtractIDs(get(med_ref_col_name), unique = FALSE)]
  return(medication_resources)
}

#
# MedicationRequest
#
getMedicationRequestsFromDB <- function(patient_references) {
  medication_requests <- getResourcesFromDB(resource_name = "MedicationRequest",
                                            column_names = c("medreq_id",
                                                             "medreq_encounter_ref",
                                                             "medreq_patient_ref",
                                                             "medreq_medicationreference_ref",
                                                             "medreq_authoredon"),
                                            patient_references = patient_references,
                                            status_exclusion = c("cancelled", "entered-in-error", "stopped") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2832805)
  )
  medication_requests <- addMedicationIdColumn(medication_requests)
  medication_requests[, start_date := medreq_authoredon]
  return(medication_requests)
}

#
# MedicationAdministration
#
getMedicationAdministrationsFromDB <- function(patient_references) {
  medication_administrations <- getResourcesFromDB(resource_name = "MedicationAdministration",
                                                   column_names = c("medadm_id",
                                                                    "medadm_encounter_ref",
                                                                    "medadm_patient_ref",
                                                                    "medadm_medicationreference_ref",
                                                                    "medadm_effectivedatetime",
                                                                    "medadm_effectiveperiod_start"),
                                                   patient_references = patient_references,
                                                   status_exclusion = c("not-done", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2831577
  )
  medication_administrations <- addMedicationIdColumn(medication_administrations)
  medication_administrations[, start_date := pmin(medadm_effectivedatetime, medadm_effectiveperiod_start, na.rm = TRUE)]
  return(medication_administrations)
}

#
# MedicationStatement
#
getMedicationStatementsFromDB <- function(patient_references) {
  medication_statements <- getResourcesFromDB(resource_name = "MedicationStatement",
                                              column_names = c("medstat_id",
                                                               "medstat_encounter_ref",
                                                               "medstat_patient_ref",
                                                               "medstat_medicationreference_ref",
                                                               "medstat_effectivedatetime",
                                                               "medstat_effectiveperiod_start"),
                                              patient_references = patient_references,
                                              status_exclusion = c("entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834331
  )
  medication_statements <- addMedicationIdColumn(medication_statements)
  medication_statements[, start_date := pmin(medstat_effectivedatetime, medstat_effectiveperiod_start, na.rm = TRUE)]
  return(medication_statements)
}

#
# Medication (filtered by Medications with ATC)
#
getATCMedicationsFromDB <- function(medication_request, medication_administrations, medication_statements) {
  medication_ids <- etlutils::fhirdataExtractIDs(unique(c(
    medication_request$medreq_medicationreference_ref,
    medication_administrations$medadm_medicationreference_ref,
    medication_statements$medstat_medicationreference_ref)))

  medication_ids <- etlutils::fhirdbGetQueryList(medication_ids)
  where_clause <- paste0("WHERE med_id IN ", medication_ids, "\n",
                         "AND med_code_system = 'http://fhir.de/CodeSystem/bfarm/atc'\n")
  query <- getQueryToLoadResourcesLastVersionFromDB(resource_name = "Medication",
                                                    column_names = c("med_id",
                                                                     "med_code_code"),
                                                    filter = where_clause)
  medications <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getATCMedicationsFromDB()")
}

#
# Observation
#
getObservationsFromDB <- function(patient_references) {
  observations <- getResourcesFromDB(resource_name = "Observation",
                     column_names = c("obs_id",
                                      "obs_encounter_ref",
                                      "obs_patient_ref",
                                      "obs_code_system",
                                      "obs_code_code",
                                      "obs_effectivedatetime",
                                      "obs_issued",
                                      "obs_valuerange_low_value",
                                      "obs_valuerange_low_unit",
                                      "obs_valuerange_low_system",
                                      "obs_valuerange_low_code",
                                      "obs_valuerange_high_value",
                                      "obs_valuerange_high_unit",
                                      "obs_valuerange_high_system",
                                      "obs_valuerange_high_code",
                                      "obs_valueratio_numerator_value",
                                      "obs_valueratio_numerator_comparator",
                                      "obs_valueratio_numerator_unit",
                                      "obs_valueratio_numerator_system",
                                      "obs_valueratio_numerator_code",
                                      "obs_valueratio_denominator_value",
                                      "obs_valueratio_denominator_comparator",
                                      "obs_valueratio_denominator_unit",
                                      "obs_valueratio_denominator_system",
                                      "obs_valueratio_denominator_code",
                                      "obs_valuequantity_value",
                                      "obs_valuequantity_comparator",
                                      "obs_valuequantity_unit",
                                      "obs_valuequantity_system",
                                      "obs_valuequantity_code",
                                      "obs_valuecodeableconcept_system",
                                      "obs_valuecodeableconcept_version",
                                      "obs_valuecodeableconcept_code",
                                      "obs_valuecodeableconcept_display",
                                      "obs_valuecodeableconcept_text",
                                      "obs_referencerange_low_value",
                                      "obs_referencerange_low_unit",
                                      "obs_referencerange_low_system",
                                      "obs_referencerange_low_code",
                                      "obs_referencerange_high_value",
                                      "obs_referencerange_high_unit",
                                      "obs_referencerange_high_system",
                                      "obs_referencerange_high_code",
                                      "obs_referencerange_type_system",
                                      "obs_referencerange_type_version",
                                      "obs_referencerange_type_code",
                                      "obs_referencerange_type_display",
                                      "obs_referencerange_type_text",
                                      "obs_referencerange_appliesto_system",
                                      "obs_referencerange_appliesto_version",
                                      "obs_referencerange_appliesto_code",
                                      "obs_referencerange_appliesto_display",
                                      "obs_referencerange_appliesto_text",
                                      "obs_referencerange_age_low_value",
                                      "obs_referencerange_age_low_unit",
                                      "obs_referencerange_age_low_system",
                                      "obs_referencerange_age_low_code",
                                      "obs_referencerange_age_high_value",
                                      "obs_referencerange_age_high_unit",
                                      "obs_referencerange_age_high_system",
                                      "obs_referencerange_age_high_code",
                                      "obs_referencerange_text"),
                     patient_references = patient_references,
                     status_exclusion = c("registered", "cancelled", "entered-in-error"), # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834407
                     additional_conditions = c("obs_category_code = 'laboratory'",
                                               "obs_code_system = 'http://loinc.org'")
  )
  observations[, start_date := obs_effectivedatetime]
  return(observations)
}

#
# Procedure
#
getProceduresFromDB <- function(patient_references) {
  procedures <- getResourcesFromDB(resource_name = "Procedure",
                     column_names = c("proc_id",
                                      "proc_encounter_ref",
                                      "proc_patient_ref",
                                      "proc_code_code",
                                      "proc_performeddatetime",
                                      "proc_performedperiod_start"),
                     patient_references = patient_references,
                     status_exclusion = c("entered-in-error"), # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834739
                     additional_conditions = "proc_code_system = 'http://fhir.de/CodeSystem/bfarm/ops'"
  )
  procedures[, start_date := pmin(proc_performeddatetime, proc_performedperiod_start, na.rm = TRUE)]
  return(procedures)
}

#
# Condition
#
getConditionsFromDB <- function(patient_references) {
  conditions <- getResourcesFromDB(resource_name = "Condition",
                     column_names = c("con_id",
                                      "con_encounter_ref",
                                      "con_patient_ref",
                                      "con_code_code",
                                      "con_code_system",
                                      "con_onsetperiod_start",
                                      "con_recordeddate"),
                     patient_references = patient_references,
                     status_exclusion = NULL, # Status is considered in additional_conditions
                     # clinical_status c("inactive") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2833668
                     # verification status c("refuted", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2831601
                     additional_conditions = c("con_code_system = 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'",
                                               #"(con_clinicalstatus_code IS NULL OR con_clinicalstatus_code <> 'inactive')",
                                               "(con_verificationstatus_code IS NULL OR con_verificationstatus_code NOT IN ('refuted', 'entered-in-error'))")
  )
  conditions[, start_date := pmin(con_onsetperiod_start, con_recordeddate, na.rm = TRUE)]
  return(conditions)
}

#
# Extract ATC code of referenced Medication. If not exists then remove the resource.
#
appendATCColumn <- function(medications, medication_resources) {
  result <- medication_resources[0]
  result[, atc_code := character()]

  for (i in seq_len(nrow(medication_resources))) {
    medication_resource <- medication_resources[i]
    current_med_id <- medication_resource[["med_id"]]

    # return resources only if they have a reference to an ATC medication
    # (means: ignore all others)
    if (!is.na(current_med_id) && nzchar(current_med_id)) {
      matched_meds <- medications[med_id == current_med_id]

      if (nrow(matched_meds) > 0) {
        expanded <- medication_resource[rep(1L, nrow(matched_meds))]
        expanded[, atc_code := matched_meds$med_code_code]
        result <- rbind(result, expanded, use.names = TRUE, fill = TRUE)
      }
    }
  }

  return(result)
}

#########################################
# Prepare Resources for MRP Calculation #
#########################################

getResourcesForMRPCalculation <- function(mrp_calculation_type) {

  # 1.) Get all Einrichtungskontakt encounters that ended at least 14 days ago
  #     and do not have a retrolective MRP evaluation for Drug_Disease
  main_encounters <- getEncountersWithoutRetrolectiveMRPEvaluationFromDB(mrp_calculation_type)

  if (!nrow(main_encounters)) {
    etlutils::catWarningMessage(paste0(
      "No Einrichtungskontakt encounters found that ended at least ",
      DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS,
      " days ago and do not have a retrolective MRP evaluation for type '",
      mrp_calculation_type, "'.\n"
    ))
    return(list())
  }

  # 2.) Load all record IDs for the patient IDs of the Encounter from the DB
  record_ids <- loadExistingRecordIDsFromDB(main_encounters$enc_patient_ref)

  # 3.) Load all medication analyses for these record IDs from the DB
  medication_analyses <- getMedicationAnalysesFromDB(record_ids)

  # 4.) For each Encounter ID, keep only the very first medication analyses
  encounters_first_medication_analysis <- list()
  for (row in seq_len(nrow(main_encounters))) {

    # Get the encounter
    main_encounter <- main_encounters[row]

    # Get the specific record ID for the patient of the main encounter
    patient_id <- etlutils::fhirdataExtractIDs(main_encounter$enc_patient_ref)
    target_record_id <- record_ids[pat_id == patient_id, record_id][1]

    encounter_medication_analyses <- medication_analyses[record_id == target_record_id]

    # Get the first medication analysis
    encounters_first_medication_analysis[[main_encounter$enc_id]] <- if (nrow(encounter_medication_analyses)) {
      encounter_medication_analyses[1]
    } else {
      NULL
    }
  }

  # get patient references
  patient_references <- main_encounters$enc_patient_ref

  # extract Medication resources
  medication_requests <- getMedicationRequestsFromDB(patient_references)
  medication_administrations <- getMedicationAdministrationsFromDB(patient_references)
  medication_statements <- getMedicationStatementsFromDB(patient_references)
  medications <- getATCMedicationsFromDB(medication_requests, medication_administrations, medication_statements)

  # Add ATC codes as separate column and remove all medication resources without ATC
  medication_requests <- appendATCColumn(medications, medication_requests)
  medication_administrations <- appendATCColumn(medications, medication_administrations)
  medication_statements <- appendATCColumn(medications, medication_statements)

  # 5.) Get all necessary resources for the MRP calculation for these Encounters
  return(list(
    main_encounters = main_encounters,
    record_ids = record_ids,
    encounters_first_medication_analysis = encounters_first_medication_analysis,
    medication_requests = medication_requests,
    medication_administrations = medication_administrations,
    medication_statements = medication_statements,
    medications = medications,
    observations = getObservationsFromDB(patient_references),
    procedures = getProceduresFromDB(patient_references),
    conditions = getConditionsFromDB(patient_references)
  ))

}
