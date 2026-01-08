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
  "Drug_Drug",
  "Drug_DrugGroup",
  "Drug_Niereninsuffizienz"
)

#' Clean and Expand MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param mrp_definition A data.table containing the MRP definition table.
#' @param mrp_type A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
processExcelContentDrugCondition <- function(mrp_definition, mrp_type) {

  # Remove not necessary columns
  mrp_columnnames <- getRelevantColumnNames(mrp_type)
  mrp_definition <- mrp_definition[, ..mrp_columnnames]

  # Remove rows with all empty code columns
  code_column_names <- names(mrp_definition)[
    (grepl("PROXY|ATC|ICD", names(mrp_definition))) &
      !grepl("DISPLAY|INCLUSION|VALIDITY_DAYS", names(mrp_definition))
  ]
  mrp_definition <- etlutils::removeRowsWithNAorEmpty(mrp_definition, code_column_names)

  # ICD column:
  # remove white spaces around plus signs
  etlutils::replacePatternsInColumn(mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
  # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
  mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

  computeATCForCalculation(
    data_table = mrp_definition,
    primary_col = "ATC_PRIMARY",
    inclusion_col = "ATC_INCLUSION",
    output_col = "ATC_FOR_CALCULATION",
    secondary_cols = c("ATC_SYSTEMIC_SY", "ATC_DERMATIC_D", "ATC_OPHTHALMOLOGIC_OP", "ATC_INHALATIVE_I", "ATC_OTHER_OT")
  )

  # To prevent a large number of meaningless MRPs from being found, all lines for proxy codes that essentially
  # mean the same thing must be combined. The reason for this is that a short form of an ICD code (e.g., K70)
  # results in a large number of individual codes, which then all generate their own MRP for the LOINC proxy
  # because LOINC says that the patient has all these diseases.

  code_column_names <- c(code_column_names[!startsWith(code_column_names, "ATC")], "ATC_FOR_CALCULATION")
  # Create a new column for the full ATC list
  mrp_definition[, ATC_FULL_LIST := ATC_FOR_CALCULATION]
  # Create a new column for the full ICD list
  mrp_definition[, ICD_FULL_LIST := ICD]
  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  mrp_definition <- etlutils::splitColumnsToRows(mrp_definition, code_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(mrp_definition)
  # ICD column: remove tailing points from ICD codes
  etlutils::replacePatternsInColumn(mrp_definition, 'ICD', '\\.$', '')
  # remove rows with empty ICD code and empty proxy codes (ATC, LOINC, OPS) again.
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  mrp_definition <- etlutils::removeRowsWithNAorEmpty(mrp_definition, code_column_names)

  # Remove duplicate rows
  mrp_definition <- unique(mrp_definition)

  # Clean rows with NA or empty values in relevant code columns
  for (col in code_column_names) {
    mrp_definition[[col]] <- ifelse(
      is.na(mrp_definition[[col]]) |
        !nzchar(trimws(mrp_definition[[col]])),
      NA_character_,
      mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  invalid_atcs <- etlutils::getInvalidCodes(mrp_definition, "ATC_FOR_CALCULATION", etlutils::isATC)
  invalid_atcs_proxy <- etlutils::getInvalidCodes(mrp_definition, "ICD_PROXY_ATC", etlutils::isATC7orSmaller)

  # check column LOINC_PROXY for correct LOINC codes
  invalid_loincs <- etlutils::getInvalidCodes(mrp_definition, "LOINC_PRIMARY_PROXY", etlutils::isLOINC)

  error_messages <- c(
    formatCodeErrors(invalid_atcs, "ATC"),
    formatCodeErrors(invalid_atcs_proxy, "ATC_PROXY"),
    formatCodeErrors(invalid_loincs, "LOINC")
  )

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  # Apply the function to the 'ICD' column
  mrp_definition$ICD <- expandAndConcatenateICDs(mrp_definition$ICD)
  # Split concatenated ICD codes into separate rows
  mrp_definition <- etlutils::splitColumnsToRows(mrp_definition, "ICD")
  # Remove duplicate rows
  mrp_definition <- unique(mrp_definition)
  return(mrp_definition)
}

#
# Load all encounters for a time range
#
getEncountersWithTimeRangeFromDB <- function(start_time, end_time) {
  query <- paste0(
    "SELECT DISTINCT enc_id, enc_period_start, enc_period_end, enc_patient_ref\n",
    "FROM v_encounter_last_version\n",
    "WHERE enc_period_start >= '", format(start_time, "%Y-%m-%d %H:%M:%S"), "'\n",
    "AND enc_period_end <= '", format(end_time, "%Y-%m-%d %H:%M:%S"), "'\n",
    "AND enc_type_code = 'einrichtungskontakt'\n"
  )
  mrp_encounters <- etlutils::dbGetReadOnlyQuery(query, lock_id = paste0("getEncountersWithTimeRangeFromDB()"))
  mrp_encounters[, study_phase := "PhaseB"] # we must set the studyphase for all encounters to PhaseB to trigger the MRP calculation
  encounters_per_mrp_type <- list()
  for (mrp_type in MRP_TYPE) {
    encounters_per_mrp_type[[mrp_type]] <- mrp_encounters
  }
  encounters_per_mrp_type[["ALL_MRP_TYPES"]] <- mrp_encounters
  return(encounters_per_mrp_type)
}

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
  encounters[, study_phase := character()]

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
    fall_fe_enc_id <- unique(encs_fall_fe$fall_fhir_enc_id)
    encounters <- encounters[enc_id %in% fall_fe_enc_id]

    #
    # 2b.) Add the Study Phase to all remaining Encounters
    #
    for (current_enc_id in encounters$enc_id) {
      fall_fe_rows <- encs_fall_fe[fall_fhir_enc_id == current_enc_id]

      new_study_phase <- "PhaseA"

      # Aim: Calculate test MRP immediately if the current study phase last found
      # for the case is PhaseBTest. However, if the current study phase is not
      # PhaseBTest, then the study phase at admission applies. However, if this is
      # PhaseBTest, then PhaseA is set.
      if (nrow(fall_fe_rows) > 0) {
        fall_fe_row <- fall_fe_rows[.N]  # last row -> last study phase of the encounter
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
        study_phase = new_study_phase
      )]
    }
  }

  # TODO: Diese Funktion an die "richtige" Stelle verschieben
  getCurrentDate <- function() {
    if (exists("DEBUG_DAY")) {
      datetime <- DEBUG_DATES[DEBUG_DAY]
      return(etlutils::as.DateWithTimezone(datetime))
    }
    return(etlutils::as.DateWithTimezone(Sys.Date()))
  }

  #
  # 3.) Remove all Encounters with Study Phase "PhaseB" and an end date within the last 14 days
  #
  encounters <- encounters[!(study_phase %in% "PhaseB" & enc_period_end > (getCurrentDate() - DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS))]
  # Replace the sublists in encounters_per_mrp_type by the same encounters with study_phase from encounters
  for (mrp_type in names(encounters_per_mrp_type)) {
    encs <- encounters_per_mrp_type[[mrp_type]]
    # Merge with enriched encounters to get study_phase
    encs <- merge(encs, encounters[, .(enc_id, study_phase)], by = "enc_id")
    encounters_per_mrp_type[[mrp_type]] <- encs
  }

  encounters_per_mrp_type[["ALL_MRP_TYPES"]] <- encounters

  return(encounters_per_mrp_type)
}

#
# Load medikationsanalyse_fe from database
#
getMedicationAnalysesFromDB <- function(record_ids) {
  query_ids <- etlutils::fhirdbGetQueryList(record_ids$record_id)
  query <- paste0("SELECT * FROM v_medikationsanalyse_fe WHERE record_id in ", query_ids, "\n")
  medication_analyses <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getMedicationAnalysesFromDB()")
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
    status_column_name <- etlutils::fhirdbGetColumns(resource_name, "_status")
    where_clause <- paste0(where_clause, "  AND (", status_column_name, " IS NULL OR ", status_column_name, " NOT IN ", status_exclusion, ")\n")
  }

  if (!is.null(additional_conditions) && !etlutils::isSimpleNA(additional_conditions) && length(additional_conditions)) {
    additional_conditions <- paste(additional_conditions, collapse = "\n AND ")
    where_clause <- paste0(where_clause, "  AND ", additional_conditions, "\n")
  }

  query <- getQueryToLoadResourcesLastVersionFromDB(resource_name, column_names, where_clause)
  return(etlutils::dbGetReadOnlyQuery(query, lock_id = paste0("getResourcesFromDB(", resource_name, ")")))
}

#
# Extract new column 'med_id' from medication reference
#
# dt <- data.table(x_medicationreference_ref = c("abc/123", NA, "def/456"))
# dt <- addMedicationIdColumn(dt)
#
addMedicationIdColumn <- function(medication_resources) {
  med_ref_col_name <- colnames(medication_resources)[endsWith(colnames(medication_resources), "_medicationreference_ref")]
  medication_resources[, med_id := vapply(
    get(med_ref_col_name),
    function(x) if (is.na(x) || trimws(x) == "") NA_character_ else etlutils::fhirdataExtractIDs(x, unique = FALSE),
    character(1) # return value is always single string
  )]
  medication_resources <- medication_resources[!is.na(med_id) & nzchar(trimws(med_id))]
  return(medication_resources)
}

#
# MedicationRequest
#
getMedicationRequestsFromDB <- function(patient_references) {
  medication_requests <- getResourcesFromDB(resource_name = "MedicationRequest",
                                            column_names = c("medreq_id",
                                                             "medreq_encounter_calculated_ref",
                                                             "medreq_patient_ref",
                                                             "medreq_medicationreference_ref",
                                                             "medreq_authoredon",
                                                             "medreq_doseinstruc_timing_event",
                                                             "medreq_doseinstruc_timing_repeat_boundsperiod_start",
                                                             "medreq_doseinstruc_timing_repeat_boundsperiod_end"),
                                            patient_references = patient_references,
                                            status_exclusion = c("on-hold", "cancelled", "entered-in-error", "stopped") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2832805)
  )
  medication_requests <- addMedicationIdColumn(medication_requests)

  # calculate the start_datetime
  medication_requests[, start_datetime := data.table::fifelse(
    !is.na(medreq_doseinstruc_timing_repeat_boundsperiod_start),
    medreq_doseinstruc_timing_repeat_boundsperiod_start,
    data.table::fifelse(
      !is.na(medreq_doseinstruc_timing_event),
      medreq_doseinstruc_timing_event,
      medreq_authoredon)
  )]

  # for all medication analyses with a valid start_datetime calculate end_datetime
  medication_requests <- medication_requests[!is.na(start_datetime)]
  # because of the function getStartOfNextDay we need to create end_datetime column before, otherwise
  # in case of 0 rows the column end_datetime will not created
  medication_requests[, end_datetime := NA]
  if (nrow(medication_requests)) { # we must check nrow here, otherwise data.table::fifelse fails with 0 rows -> Error
    medication_requests[, end_datetime := data.table::fifelse(
      !is.na(medreq_doseinstruc_timing_repeat_boundsperiod_end),
      etlutils::getStartOfNextDay(medreq_doseinstruc_timing_repeat_boundsperiod_end),
      data.table::fifelse(
        !is.na(medreq_doseinstruc_timing_event),
        etlutils::getStartOfNextDay(medreq_doseinstruc_timing_event),
        NA)
    )]
  }
  # remove all now irrelevant timing and DB ID columns ()
  medication_requests[, c(
    "medicationrequest_id","medreq_doseinstruc_timing_event",
    "medreq_doseinstruc_timing_repeat_boundsperiod_start",
    "medreq_doseinstruc_timing_repeat_boundsperiod_end") := NULL]
  # for each medreq_id keep only the earliest start_datetime and the latest
  # end_datetime (if the timestamps are definied via multiple timing_events)
  medication_requests[
    ,
    `:=`(
      start_datetime = etlutils::getMinDatetime(start_datetime),
      end_datetime = if (anyNA(end_datetime)) NA else getMaxDatetime(end_datetime)
    ),
    by = medreq_id
  ]
  # keep only the relevant information once per medreq_id
  medication_requests <- unique(medication_requests)
  return(medication_requests)
}

#
# MedicationAdministration
#
getMedicationAdministrationsFromDB <- function(patient_references) {
  medication_administrations <- getResourcesFromDB(resource_name = "MedicationAdministration",
                                                   column_names = c("medadm_id",
                                                                    "medadm_encounter_calculated_ref",
                                                                    "medadm_patient_ref",
                                                                    "medadm_medicationreference_ref",
                                                                    "medadm_effectivedatetime",
                                                                    "medadm_effectiveperiod_start",
                                                                    "medadm_effectiveperiod_end"),
                                                   patient_references = patient_references,
                                                   status_exclusion = c("not-done", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2831577
  )
  medication_administrations <- addMedicationIdColumn(medication_administrations)
  medication_administrations[, start_datetime := pmin(medadm_effectivedatetime, medadm_effectiveperiod_start, na.rm = TRUE)]
  medication_administrations <- medication_administrations[!is.na(start_datetime)]
  medication_administrations[, end_datetime := data.table::fifelse(
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
                                                               "medstat_encounter_calculated_ref",
                                                               "medstat_patient_ref",
                                                               "medstat_medicationreference_ref",
                                                               "medstat_effectivedatetime",
                                                               "medstat_effectiveperiod_start",
                                                               "medstat_effectiveperiod_end"),
                                              patient_references = patient_references,
                                              status_exclusion = c("entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834331
  )
  medication_statements <- addMedicationIdColumn(medication_statements)
  medication_statements[, start_datetime := pmin(medstat_effectivedatetime, medstat_effectiveperiod_start, na.rm = TRUE)]
  medication_statements <- medication_statements[!is.na(start_datetime)]
  medication_statements[, end_datetime := data.table::fifelse(
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
                                                                     "med_code_code",
                                                                     "med_code_display"),
                                                    filter = where_clause)
  medications <- etlutils::dbGetReadOnlyQuery(query, lock_id = "getATCMedicationsFromDB()")
  return(medications)
}

#
# Observation
#
getObservationsFromDB <- function(patient_references) {
  observations <- getResourcesFromDB(resource_name = "Observation",
                                     column_names = c("obs_id",
                                                      "obs_encounter_calculated_ref",
                                                      "obs_patient_ref",
                                                      "obs_code_system",
                                                      "obs_code_code",
                                                      "obs_code_display",
                                                      "obs_effectivedatetime",
                                                      "obs_valuequantity_value",
                                                      "obs_valuequantity_code",
                                                      "obs_referencerange_low_value",
                                                      "obs_referencerange_high_value",
                                                      "obs_referencerange_low_code",
                                                      "obs_referencerange_high_code",
                                                      "obs_referencerange_low_system",
                                                      "obs_referencerange_high_system",
                                                      "obs_referencerange_type_code"),
                                     patient_references = patient_references,
                                     status_exclusion = c("on-hold", "registered", "cancelled", "entered-in-error"), # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2999037
                                     additional_conditions = c("obs_category_code = 'laboratory'",
                                                               "obs_code_system = 'http://loinc.org'")
  )
  observations[, start_datetime := obs_effectivedatetime]
  return(observations)
}

#
# Procedure
#
getProceduresFromDB <- function(patient_references) {
  procedures <- getResourcesFromDB(resource_name = "Procedure",
                                   column_names = c("proc_id",
                                                    "proc_encounter_calculated_ref",
                                                    "proc_patient_ref",
                                                    "proc_code_code",
                                                    "proc_code_display",
                                                    "proc_code_system",
                                                    "proc_performeddatetime",
                                                    "proc_performedperiod_start",
                                                    "proc_performedperiod_end"),
                                   patient_references = patient_references,
                                   status_exclusion = c("entered-in-error"), # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834739
                                   additional_conditions = "proc_code_system = 'http://fhir.de/CodeSystem/bfarm/ops'"
  )
  procedures[, start_datetime := pmin(proc_performeddatetime, proc_performedperiod_start, na.rm = TRUE)]
  procedures <- procedures[!is.na(start_datetime)]
  procedures[, end_datetime := data.table::fifelse(
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
                                                    "con_encounter_calculated_ref",
                                                    "con_patient_ref",
                                                    "con_code_code",
                                                    "con_code_system",
                                                    "con_code_display",
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
  conditions[, start_datetime := pmin(con_onsetperiod_start, con_recordeddate, na.rm = TRUE)]
  return(conditions)
}

#
# Extract ATC code of referenced Medication. If not exists then remove the resource.
#
appendATCColumns <- function(medication_resources, medications) {
  # Perform join: match each medication_resource to its medication by med_id
  result <- medication_resources[
    medications,
    on = .(med_id),
    allow.cartesian = TRUE
  ]

  # Rename joined columns
  data.table::setnames(result, c("med_code_code", "med_code_display"), c("atc_code", "atc_display"))

  # Keep only resource columns and the renamed ATC columns
  keep_cols <- c(names(medication_resources), "atc_code", "atc_display")
  result <- result[, ..keep_cols]

  # Drop rows without ATC code
  result <- result[!is.na(atc_code)]

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

    # meda_dat can be NA but we always need this value -> remove rows with NA
    # and ignore all medication analyses with a not "Complete" form status
    encounter_medication_analyses <- medication_analyses[record_id %in% target_record_id & !is.na(meda_dat) & medikationsanalyse_complete %in% "Complete"]

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

  # 5.) Add study_phase from the corresponding Encounter (matched via enc_id == fall_fhir_enc_id)
  #     to the medication analysis
  for (main_enc_id in names(encounters_first_medication_analysis)) {
    medication_analysis <- encounters_first_medication_analysis[[main_enc_id]]

    if (!is.null(medication_analysis)) {
      matching_encounter <- main_encounters[enc_id %in% main_enc_id]

      if (nrow(matching_encounter) >= 1) {
        medication_analysis$study_phase <- matching_encounter$study_phase[1]
      }

      encounters_first_medication_analysis[[main_enc_id]] <- medication_analysis
    }
  }

  # 6.) Get existing ret_id's for the medication analyses
  getExistingRetrolectiveMRPEvaluationIDs <- function(medication_analyses_ids) {
    query <- paste0(
      "SELECT DISTINCT meda_id, ret_id, ret_redcap_repeat_instance\n",
      "FROM v_dp_mrp_calculations\n",
      "WHERE ret_id IS NOT NULL AND meda_id IN ", etlutils::fhirdbGetQueryList(medication_analyses_ids))
    return(etlutils::dbGetReadOnlyQuery(query, lock_id = "getExistingRetrolectiveMRPEvaluationIDs()"))
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
  medication_requests <- appendATCColumns(medication_requests, medications)
  medication_administrations <- appendATCColumns(medication_administrations, medications)
  medication_statements <- appendATCColumns(medication_statements, medications)

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

#' Filter active MedicationRequests for an encounter within a specific time window
#'
#' @param medication_requests A \code{data.table} of MedicationRequest resources. Must contain columns \code{medreq_encounter_ref} and \code{medreq_authoredon}.
#' @param enc_period_start POSIXct. The start datetime of the encounter period.
#' @param meda_datetime POSIXct. The datetime of the medication analysis (cutoff point).
#'
#' @return A \code{data.table} with filtered active medication requests for the given encounter and time range.
#'
#' @export
getActiveATCs <- function(medication_requests, enc_period_start, enc_period_end, meda_datetime) {

  # ensure medreq_authoredon is filled with a non NA value
  medication_requests[is.na(medreq_authoredon),
                      medreq_authoredon := pmin(start_datetime, meda_datetime, na.rm = TRUE)]

  # ensure medreq_authoredon is not after start_datetime (can be if MedicationRequest is changed after first application)
  medication_requests[medreq_authoredon > start_datetime, medreq_authoredon := start_datetime]

  # ensure MedicationRequest end datetime is filled, if encounter end is NA
  if (is.na(enc_period_end)) {
    enc_period_end <- meda_datetime + lubridate::days(30)
  }
  medication_requests[is.na(end_datetime), end_datetime := enc_period_end]

  # remove all medication requests where calculated start_datetime is before medreq_authoredon
  medication_requests <- medication_requests[
    start_datetime >= medreq_authoredon & (is.na(end_datetime) | end_datetime >= start_datetime)
  ]
  # ensure medication start is not before encounter start
  active_requests <- medication_requests[
    medreq_authoredon >= enc_period_start &
      start_datetime >= enc_period_start &
      medreq_authoredon <= meda_datetime
  ]

  # keep only relevant columns and aggregate to get the overall start and end datetime per atc_code
  active_atc <- active_requests[, c("atc_code", "start_datetime", "end_datetime")]
  active_atc <- active_atc[, .(
    start_datetime = etlutils::getMinDatetime(start_datetime),
    end_datetime = end_datetime[1]
  ), by = .(atc_code, end_datetime)]

  # Combine all medication requests that are less than 1 day apart.
  # 1. sort, 2. group and 3. aggregate overlapping or subsequent time periods per atc_code
  # 1. sort
  data.table::setorder(active_atc, atc_code, start_datetime)
  # 2. group
  active_atc[, grp := cumsum(
    c(TRUE, diff(start_datetime) > 1) | c(TRUE, atc_code[-1] != atc_code[-.N])
  ), by = atc_code]
  # 3. aggregate
  active_atc <- active_atc[
    , .(
      start_datetime = etlutils::getMinDatetime(start_datetime),
      end_datetime = etlutils::getMaxDatetime(end_datetime)
    ),
    by = .(atc_code, grp)
  ]
  active_atc[, grp := NULL]

  return(active_atc)
}

#' Get relevant patient conditions up to a given date
#'
#' Filters the list of Condition resources to return conditions for a specific patient
#' that occurred on or before the given medication analysis date. If the condition has a
#' \code{con_recordeddate}, it is used for filtering; otherwise, \code{con_onsetperiod_start}
#' is used as a fallback.
#'
#' @param conditions A \code{data.table} of FHIR Condition resources, including columns \code{pat_id},
#' \code{con_recordeddate}, and \code{con_onsetperiod_start}.
#' @param patient_id A character string identifying the patient whose conditions should be returned.
#' @param meda_datetime A POSIXct timestamp representing the medication analysis date.
#'
#' @return A \code{data.table} of conditions that match the patient and date criteria.
#'
getRelevantConditions <- function(conditions, patient_id, meda_datetime) {

  # Filter conditions by patient ID and ensure recorded date is before or on meda_datetime
  relevant_conditions <- conditions[
    con_patient_ref == paste0("Patient/", patient_id) & !is.na(start_datetime) & start_datetime <= meda_datetime]

  relevant_cols <- c("con_patient_ref", "con_code_code", "con_code_system", "con_code_display", "start_datetime")
  relevant_conditions <- relevant_conditions[, ..relevant_cols]

  return(relevant_conditions)
}
