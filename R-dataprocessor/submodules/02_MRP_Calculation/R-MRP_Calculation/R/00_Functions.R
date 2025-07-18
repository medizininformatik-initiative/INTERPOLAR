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
MRP_TYPE <- etlutils::namedVectorByParam(
  "Drug_Disease",
  "Drug_Drug"#,
  #"Drug_DrugGroup",
  #"Drug_Niereninsuffizienz""
)

#
# Load Einrichtungskontakt Encounters without retrolective MRP evaluation
#
getEncountersWithoutRetrolectiveMRPEvaluationFromDB <- function() {

  encounters_per_mrp_type <- list()
  #
  # 1.) Get all Einrichtungskontakt encounters that ended before now and do not
  #     have a retrolective MRP evaluation for a given type
  #

  for (mrp_type in names(MRP_TYPE)) {
    query <- paste0(
      "SELECT DISTINCT enc_id, enc_period_start, enc_period_end, enc_patient_ref\n",
      "FROM v_encounter_last_version\n",
      "WHERE enc_period_end <= '", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "'\n",
      "AND enc_type_code = 'einrichtungskontakt'\n",
      "AND enc_id NOT IN (\n",
      "  SELECT enc_id FROM v_dp_mrp_calculations\n",
      "  WHERE mrp_calculation_type = '", mrp_type, "'\n",
      ")"
    )
    mrp_encounters <- etlutils::dbGetReadOnlyQuery(query, lock_id = paste0("getEncountersWithoutRetrolectiveMRPEvaluationFromDB() - ", mrp_type))
    encounters_per_mrp_type[[mrp_type]] <- mrp_encounters
  }

  encounters <- unique(data.table::rbindlist(encounters_per_mrp_type, use.names = TRUE))
  encounters[, `:=`(study_phase = character(), ward_name = character())]

  if (nrow(encounters)) {

    #
    # 2.) Add the Study Phase to all Encounters
    #
    column_names <- c("fall_fe_id",
                      "input_datetime",
                      "record_id",
                      "fall_fhir_enc_id",
                      "fall_pat_id",
                      "fall_id",
                      "fall_studienphase",
                      "fall_station")
    query <- paste0(
      "SELECT ", paste(column_names, collapse = ", "), " \n",
      "FROM v_fall_fe\n",
      "WHERE fall_fhir_enc_id IN ", etlutils::fhirdbGetQueryList(encounters$enc_id), "\n",
      "ORDER BY input_datetime"
    )
    encs_fall_fe <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getEncountersWithoutRetrolectiveMRPEvaluationFromDB()_enc_fall_fe")

    #
    # 2a.) Remove all Encounters which were never on a relevant ward (their FHIR ID is not in the fall_fe table)
    #
    encounters <- encounters[enc_id %in% encs_fall_fe$fall_fhir_enc_id]

    #
    # 2b.) Add the Study Phase to all remaining Encounters
    #
    for (current_enc_id in encounters$enc_id) {
      fall_fe_rows <- encs_fall_fe[fall_fhir_enc_id == current_enc_id]

      new_study_phase <- "PhaseA"
      new_ward_name <- NA_character_

      # Aim: Calculate test MRP immediately if the current study phase last found
      # for the case is PhaseBTest. However, if the current study phase is not
      # PhaseBTest, then the study phase at admission applies. However, if this is
      # PhaseBTest, then PhaseA is set.
      if (nrow(fall_fe_rows) > 0) {
        fall_fe_row <- fall_fe_rows[.N]  # last row -> last study phase of the encounter
        new_ward_name <- fall_fe_row$fall_station
        if (fall_fe_row$fall_studienphase %in% "PhaseBTest") {
          new_study_phase <- "PhaseBTest"
        } else {
          fall_fe_row <- fall_fe_rows[1]  # first row -> study phase at admission
          # no study phase or test phase at admission -> PhaseA
          if (is.na(fall_fe_row$fall_studienphase) || fall_fe_row$fall_studienphase == "PhaseBTest") {
            new_study_phase <- "PhaseA"
          } else {
            new_study_phase <- fall_fe_row$fall_studienphase # can be PhaseA or PhaseB
          }
        }
      }
      encounters[enc_id %in% current_enc_id, `:=`(
        study_phase = new_study_phase,
        ward_name = new_ward_name
      )]
    }
  }

  #
  # 3.) Remove all Encounters with Study Phase "Phase_B" and an end date within the last 14 days
  #
  encounters <- encounters[!(study_phase %in% "Phase_B" & enc_period_end > (Sys.Date() - DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS))]
  # Replace the sublists in encounters_per_mrp_type by the same encounters with study_phase and ward_name from encounters
  for (mrp_type in names(encounters_per_mrp_type)) {
    encs <- encounters_per_mrp_type[[mrp_type]]
    # Merge with enriched encounters to get study_phase and ward_name
    encs <- merge(encs, encounters[, .(enc_id, study_phase, ward_name)], by = "enc_id", all.x = TRUE)
    encounters_per_mrp_type[[mrp_type]] <- encs
  }

  encounters_per_mrp_type[["ALL_TYPES"]] <- encounters

  return(encounters_per_mrp_type)
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
                                                             "medreq_authoredon",
                                                             "medreq_doseinstruc_timing_repeat_boundsperiod_start",
                                                             "medreq_doseinstruc_timing_repeat_boundsperiod_end"),
                                            patient_references = patient_references,
                                            status_exclusion = c("cancelled", "entered-in-error", "stopped") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2832805)
  )
  medication_requests <- addMedicationIdColumn(medication_requests)

  medication_requests[, start_date := data.table::fifelse(
    !is.na(medreq_doseinstruc_timing_repeat_boundsperiod_start),
    medreq_doseinstruc_timing_repeat_boundsperiod_start,
    medreq_authoredon
  )]
  medication_requests <- medication_requests[!is.na(start_date)]
  medication_requests[, end_date := data.table::fifelse(
    !is.na(medreq_doseinstruc_timing_repeat_boundsperiod_end),
    medreq_doseinstruc_timing_repeat_boundsperiod_end,
    NA
  )]
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
                                                                    "medadm_effectiveperiod_start",
                                                                    "medadm_effectiveperiod_end"),
                                                   patient_references = patient_references,
                                                   status_exclusion = c("not-done", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2831577
  )
  medication_administrations <- addMedicationIdColumn(medication_administrations)
  medication_administrations[, start_date := pmin(medadm_effectivedatetime, medadm_effectiveperiod_start, na.rm = TRUE)]
  medication_administrations <- medication_administrations[!is.na(start_date)]
  medication_administrations[, end_date := data.table::fifelse(
    !is.na(medadm_effectiveperiod_end),
    medadm_effectiveperiod_end,
    NA
  )]
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
                                                               "medstat_effectiveperiod_start",
                                                               "medstat_effectiveperiod_end"),
                                              patient_references = patient_references,
                                              status_exclusion = c("entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834331
  )
  medication_statements <- addMedicationIdColumn(medication_statements)
  medication_statements[, start_date := pmin(medstat_effectivedatetime, medstat_effectiveperiod_start, na.rm = TRUE)]
  medication_statements <- medication_statements[!is.na(start_date)]
  medication_statements[, end_date := data.table::fifelse(
    !is.na(medstat_effectiveperiod_end),
    medstat_effectiveperiod_end,
    NA
  )]
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
                                                      "obs_effectivedatetime"),
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
                                                    "proc_performedperiod_start",
                                                    "proc_performedperiod_end"),
                                   patient_references = patient_references,
                                   status_exclusion = c("entered-in-error"), # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834739
                                   additional_conditions = "proc_code_system = 'http://fhir.de/CodeSystem/bfarm/ops'"
  )
  procedures[, start_date := pmin(proc_performeddatetime, proc_performedperiod_start, na.rm = TRUE)]
  procedures <- procedures[!is.na(start_date)]
  procedures[, end_date := data.table::fifelse(
    !is.na(proc_performedperiod_end),
    proc_performedperiod_end,
    NA
  )]
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
      matched_meds <- medications[med_id %in% current_med_id]

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

getResourcesForMRPCalculation <- function(main_encounters) {

  if (!nrow(main_encounters)) {
    etlutils::catWarningMessage(paste0(
      "No Einrichtungskontakt encounters found that ended at least ",
      DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS,
      " days ago and do not have any retrolective MRP evaluation.\n"
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
    target_record_id <- record_ids[pat_id %in% patient_id, record_id][1]

    encounter_medication_analyses <- medication_analyses[record_id %in% target_record_id]

    encounters_first_medication_analysis[[main_encounter$enc_id]] <- NULL
    if (nrow(encounter_medication_analyses)) {
      # Find the first medication analysis with a date in the encounters period
      # sort medication analyses by date
      encounter_medication_analyses <- encounter_medication_analyses[order(meda_dat)]
      # all main encounters here must have an end date
      encounter_medication_analyses <- encounter_medication_analyses[meda_dat >= main_encounter$enc_period_start & meda_dat <= main_encounter$enc_period_end]

      # if there is at least one medication analyses, take the first one
      if (nrow(encounter_medication_analyses)) {
        encounters_first_medication_analysis[[main_encounter$enc_id]] <- encounter_medication_analyses[1]
      }
    }
  }

  # 5.) Add study_phase and ward_name from the corresponding Encounter (matched via enc_id == fall_fhir_enc_id)
  #     to the medication analysis
  for (main_enc_id in names(encounters_first_medication_analysis)) {
    medication_analysis <- encounters_first_medication_analysis[[main_enc_id]]

    if (!is.null(medication_analysis)) {
      matching_encounter <- main_encounters[enc_id %in% main_enc_id]

      if (nrow(matching_encounter) >= 1) {
        medication_analysis$study_phase <- matching_encounter$study_phase[1]
        medication_analysis$ward_name <- matching_encounter$ward_name[1]
      }

      encounters_first_medication_analysis[[main_enc_id]] <- medication_analysis
    }
  }

  # 6.) Get existing ret_id's for the medication analyses
  getExistingRetrolectiveMRPEvaluationIDs <- function(medication_analyses_ids) {
    query <- paste0(
      "SELECT meda_id, ret_id, redcap_repeat_instance\n",
      "FROM v_dp_mrp_calculations\n",
      "WHERE meda_id IN ", etlutils::fhirdbGetQueryList(medication_analyses_ids))
    return(etlutils::dbGetReadOnlyQuery(query))
  }
  medication_analyses_ids <- unlist(lapply(encounters_first_medication_analysis, function(dt) if (!is.null(dt)) dt$meda_id else NULL), use.names = FALSE)
  existing_retrolective_mrp_evaluation_ids <- getExistingRetrolectiveMRPEvaluationIDs(medication_analyses_ids)

  # 7.) Get all necessary resources for the MRP calculation for these Encounters and return them as a list
  # Get patient references

  patient_references <- main_encounters[enc_id %in% names(encounters_first_medication_analysis)]$enc_patient_ref

  # Extract Medication resources
  medication_requests <- getMedicationRequestsFromDB(patient_references)
  medication_administrations <- getMedicationAdministrationsFromDB(patient_references)
  medication_statements <- getMedicationStatementsFromDB(patient_references)
  medications <- getATCMedicationsFromDB(medication_requests, medication_administrations, medication_statements)

  # Add ATC codes as separate column and remove all medication resources without ATC
  medication_requests <- appendATCColumn(medications, medication_requests)
  medication_administrations <- appendATCColumn(medications, medication_administrations)
  medication_statements <- appendATCColumn(medications, medication_statements)

  return(list(
    main_encounters = main_encounters,
    record_ids = record_ids,
    encounters_first_medication_analysis = encounters_first_medication_analysis,
    existing_retrolective_mrp_evaluation_ids = existing_retrolective_mrp_evaluation_ids,
    medication_requests = medication_requests,
    medication_administrations = medication_administrations,
    medication_statements = medication_statements,
    medications = medications,
    observations = getObservationsFromDB(patient_references),
    procedures = getProceduresFromDB(patient_references),
    conditions = getConditionsFromDB(patient_references)
  ))

}
