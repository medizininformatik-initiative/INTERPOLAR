###########
# General #
###########

MRP_CALCULATION_TYPE <- etlutils::namedListByValue(
  "Drug_Disease",
  "Drug_Drug",
  "Drug_DrugGroup",
  "Drug_Kidney"
)

# TODO: comment
getEncountersWithoutRetrolectiveMRPEvaluation <- function(mrp_calculation_type) {
  # Get all Einrichtungskontakt encounters that ended at leas 14 days ago and do not have a retrolective MRP evaluation
  query_date <- Sys.Date() - DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS
  query <- paste0(
    "SELECT DISTINCT enc_id, enc_period_start FROM encounter\n",
    "WHERE enc_period_end <= '", query_date, "'\n",
    "AND enc_type_code = 'einrichtungskontakt'\n",
    "AND enc_id NOT IN (SELECT enc_id FROM dp_mrp_calculations)\n",
    "AND mrp_calculation_type = '", mrp_calculation_type, "'\n"
  )
  encounters <- etlutils::dbGetReadOnlyQuery(query)
}

# TODO: comment
getMedicationAnalyses <- function(record_ids) {
  query_ids <- etlutils::fhirdbGetQueryList(record_ids$record_id)
  query <- paste0("SELECT * FROM medikationsanalyse_fe WHERE record_id in ", query_ids, "\n")
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
getResourcesFromDB <- function(resource_name, patient_references, status_exclusion = NULL) {
  patient_ref_column_name <- etlutils::fhirdbGetPIDColumn(resource_name)
  patient_references <- etlutils::fhirdataGetPatientReference(patient_references)
  patient_references <- etlutils::fhirdbGetQueryList(patient_references)
  status_exclusion <- etlutils::fhirdbGetQueryList(status_exclusion)

  where_clause <- paste0("WHERE ", patient_ref_column_name, " IN ", patient_references, "\n")

  if (!is.null(status_exclusion) && !etlutils::isSimpleNA(status_exclusion) && length(status_exclusion)) {
    resource_column_prefix <- etlutils::fhirdbGetResourceAbbreviation(resource_name)
    where_clause <- paste0(where_clause, "AND ", resource_column_prefix, "_status NOT IN ", status_exclusion, "\n")
  }

  query <- getQueryToLoadResourcesLastVersionFromDB(resource_name, where_clause)
  etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)
}

#
# MedicationRequest
#
getMedicationRequests <- function(patient_references) {
  getResourcesFromDB(resource_name = "MedicationRequest",
                     patient_references = patient_references,
                     status_exclusion = c("cancelled", "entered-in-error", "stopped") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2832805)
  )
}

#
# MedicationAdministration
#
getMedicationAdministrations <- function(patient_references) {
  getResourcesFromDB(resource_name = "MedicationAdministration",
                     patient_references = patient_references,
                     status_exclusion = c("not-done", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2831577
  )
}

#
# MedicationStatement
#
getMedicationStatements <- function(patient_references) {
  getResourcesFromDB(resource_name = "MedicationStatement",
                     patient_references = patient_references,
                     status_exclusion = c("entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834331
  )
}

#
# Medication
#
getMedications <- function(medication_request, medication_administrations, medication_statements) {
  medication_ids <- etlutils::fhirdataExtractIDs(unique(c(
    medication_request$medreq_medicationreference_ref,
    medication_administrations$medadm_medicationreference_ref,
    medication_statements$medstat_medicationreference_ref)))

  medication_ids <- etlutils::fhirdbGetQueryList(medication_ids)
  where_clause <- paste0("WHERE ", med_id, " IN ", medication_ids, "\n")
  query <- getQueryToLoadResourcesLastVersionFromDB("Medication", where_clause)
  etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)
}

#
# Observation
#
getObservations <- function(patient_references) {
  getResourcesFromDB(resource_name = "Observation",
                     patient_references = patient_references,
                     status_exclusion = c("registered", "cancelled", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834407
  )
}

#
# Procedure
#
getProcedures <- function(patient_references) {
  getResourcesFromDB(resource_name = "Procedure",
                     patient_references = patient_references,
                     status_exclusion = c("entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2834739
  )
}

#
# Condition
#
getConditions <- function(patient_references) {
  getResourcesFromDB(resource_name = "Conditions",
                     patient_references = patient_references,
                     status_exclusion = NULL # TODO: Status von Conditions beachten
                     # clinical_status c("inactive") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2833668
                     # verification status c("refuted", "entered-in-error") # https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/2831601
  )
}

#########################################
# Prepare Resources for MRP Calculation #
#########################################

getResourcesForMRPCalculation <- function(mrp_calculation_type) {

  # 1.) Get all Einrichtungskontakt encounters that ended at least 14 days ago
  #     and do not have a retrolective MRP evaluation for Drug_Disease
  main_encounters <- getEncountersWithoutRetrolectiveMRPEvaluation(mrp_calculation_type)

  # 2.) Load all record IDs for the patient IDs of the Encounter from the DB
  record_ids <- loadExistingRecordIDsFromDB(main_encounters$patient_ref)

  # 3.) Load all medication analyses for these record IDs from the DB
  medication_analyses <- getMedicationAnalyses(record_ids)

  # 4.) For each Encounter ID, keep only the very first medication analyses
  encounters_first_medication_analysis <- list()
  for (row in seqlen(nrow(main_encounters))) {

    # Get the encounter
    main_encounter <- main_encounters[row]

    # Get the specific record ID for the patient of the main encounter
    patient_id <- etlutils::fhirdataExtractIDs(main_encounter$enc_patient_ref)
    record_id <- record_ids[pat_id == ..patient_id, record_id][1]

    encounter_medication_analyses <- medication_analyses[record_id == ..record_id]

    # Get the first medication analysis
    encounters_first_medication_analysis[[main_encounter$enc_id]] <- if (nrow(encounter_medication_analyses)) {
      encounter_medication_analyses[1]
    } else {
      NULL
    }
  }

  patient_references <- main_encounters$enc_patient_ref

  medication_requests = getMedicationRequests(patient_references),
  medication_administrations = getMedicationAdministrations(patient_references),
  medication_statements = getMedicationStatements(patient_references),

  # 5.) Get all necessary resources for the MRP calculation for these Encounters
  return(list(
    main_encounters = main_encounters,
    record_ids = record_ids,
    encounters_first_medication_analysis = encounters_first_medication_analysis,
    medication_requests = medication_requests,
    medication_administrations = medication_administrations,
    medication_statements = medication_statements,
    medications = getMedications(medication_request, medication_administrations, medication_statements),
    observations = getObservations(patient_references),
    procedures = getProcedures(patient_references),
    conditions = getConditions(patient_references)
  ))

}

################
# Drug Disease #
################

#' Clean and Expand Drug_Disease_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_disease_mrp_definition A data.table containing the MRP definition table.
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
cleanAndExpandDefinitionDrugDisease <- function(drug_disease_mrp_definition) {

  # Remove not nesessary columns
  drug_disease_mrp_definition <- drug_disease_mrp_definition[, c("SMPC_NAME", "SMPC_VERSION") := NULL]

  # Remove comment and full empty rows
  drug_disease_mrp_definition <- etlutils::dtRemoveCommentRows(drug_disease_mrp_definition)

  # Remove rows with all empty code columns
  proxy_column_names <- names(drug_disease_mrp_definition)[
    (grepl("PROXY|ATC", names(drug_disease_mrp_definition))) &
      !grepl("DISPLAY|INCLUSION|VALIDITY_DAYS", names(drug_disease_mrp_definition))
  ]
  relevant_column_names <- c("ICD", proxy_column_names)
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, relevant_column_names)

  # ICD column:
  # remove white spaces around plus signs
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
  # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
  drug_disease_mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, relevant_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_disease_mrp_definition)

  # ICD column: remove tailing points from ICD codes
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\.$', '')

  # remove rows with empty ICD code and empty proxy codes (ATC, LOINC, OPS) again.
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, relevant_column_names)

  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  # Clean rows with NA or empty values in relevant columns
  for (col in relevant_column_names) {
    drug_disease_mrp_definition[[col]] <- ifelse(
      is.na(drug_disease_mrp_definition[[col]]) |
        !nzchar(trimws(drug_disease_mrp_definition[[col]])),
      NA_character_,
      drug_disease_mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  atc_columns <- grep("ATC(?!.*(DISPLAY|INCLUSION|VALIDITY_DAYS))", names(drug_disease_mrp_definition), value = TRUE, perl = TRUE)
  atc_errors <- validateATCCodes(drug_disease_mrp_definition, atc_columns)

  # check column LOINC_PROXY for correct LOINC codes
  loinc_errors <- validateLOINCCodes(drug_disease_mrp_definition, "LOINC_PRIMARY_PROXY")

  error_messages <- c(
    formatCodeErrors(atc_errors, "ATC"),
    formatCodeErrors(loinc_errors, "LOINC")
  )

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  # Expand and concatenate ICD codes in a vectorized manner.
  # If there are multiple ICD codes separated by "+", each code is expanded separately, and
  # combinations of expanded codes are concatenated. ICD Codes must be have at least 3 digits.
  expandAndConcatenateICDs <- function(icd_column) {
    # Function to process a single ICD code
    processICD <- function(icd) {
      if (is.na(icd) || icd == "") {
        return(NA_character_)
      }
      if (!grepl("+", icd, fixed = TRUE)) {
        # Handle single ICD code case
        return(paste(etlutils::expandICDs(icd), collapse = ' '))

      }
      # Handle multiple ICD codes separated by '+'
      input_icds <- unlist(strsplit(icd, '\\+'))
      icd_1 <- etlutils::expandICDs(input_icds[[1]])
      icd_2 <- etlutils::expandICDs(input_icds[[2]])
      # Create combinations and concatenate
      combinations <- outer(icd_1, icd_2, paste, sep = '+')
      return(trimws(paste(c(combinations), collapse = ' ')))

    }
    # Apply the function to the entire column
    sapply(icd_column, processICD)
  }

  # Apply the function to the 'ICD' column
  drug_disease_mrp_definition$ICD <- expandAndConcatenateICDs(drug_disease_mrp_definition$ICD)

  # Split concatenated ICD codes into separate rows
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, "ICD")

  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  return(drug_disease_mrp_definition)
}
