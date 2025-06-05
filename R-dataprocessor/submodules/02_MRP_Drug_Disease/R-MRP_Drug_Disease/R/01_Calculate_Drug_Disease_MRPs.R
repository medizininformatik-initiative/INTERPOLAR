formatCodeErrors <- function(error_list, code_type_label) {
  if (length(error_list) == 0) return(character())

  messages <- c(sprintf("The following errors were found in %s codes:", code_type_label))
  for (col in names(error_list)) {
    messages <- c(messages,
                  sprintf("  Column '%s': %s", col, paste(error_list[[col]], collapse = ", ")))
  }
  return(messages)
}

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

  # remove rows with empty ICD code and empty proxy codes (ATC, LOINC, OPS)
  proxy_column_names <- proxy_column_names <- names(drug_disease_mrp_definition)[
    grepl("PROXY", names(drug_disease_mrp_definition)) &
      !grepl("VALIDITY_DAYS", names(drug_disease_mrp_definition))
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
      input_icds <- unlist(strsplit(icd, '\\+'))
      # Handle single ICD code case
      if (length(input_icds) == 1) {
        return(paste(etlutils::interpolar_expandICDs(input_icds), collapse = ' '))
      }
      # Handle multiple ICD codes separated by '+'
      if (length(input_icds) > 1) {
        icd_1 <- etlutils::interpolar_expandICDs(input_icds[[1]])
        icd_2 <- etlutils::interpolar_expandICDs(input_icds[[2]])
        # Create combinations and concatenate
        combinations <- outer(icd_1, icd_2, paste, sep = '+')
        return(trimws(paste(c(combinations), collapse = ' ')))
      }
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

#' Calculate Drug-Disease Medication-Related Problems (MRPs)
#'
#' This function retrieves all necessary patient-related data, including encounters,
#' medication requests, medications, observations, and conditions, to analyze potential
#' drug-disease medication-related problems (MRPs).
#'
#' @param drug_disease_mrp_definition A data structure (e.g., a list or data.table)
#'   defining the rules for identifying drug-disease MRPs.
#'
#' @return This function return table with all calculated drug-disease MRPs.
#'
calculateDrugDiseaseMRPs <- function() {

  etlutils::runLevel2("Load and expand Drug-Disease Definition", {
    drug_disease_mrp_tables <- getExpandedContent("Drug_Disease", MRP_PAIR_LISTS_PATHS)
  })

  # Load all active PIDs
  patient_ids <- getPIDs()

  # Save and retrieve query datetime
  setQueryDatetime()
  query_datetime <- getQueryDatetime()

  # Load encounters by PIDs
  encounters <- loadEncounters(patient_ids, query_datetime)

  # Load MedicationRequest resources referenced by Encounters
  encounter_ids <- paste0("Encounter/", unique(encounters$enc_id))
  medication_requests <- loadResourcesFromDB(
    resource_name = MEDICATION_REQUEST_RESOURCE,
    column_name = MEDICATION_REQUEST_RESOURCE_ENCOUNTER_REFERENCE_COLUMN_NAME,
    query_ids = encounter_ids
  )

  # Load Medication resources referenced by MedicationRequest
  medication_ids <- medication_requests[, unique(get(MEDICATION_REQUEST_RESOURCE_MEDICATION_REFERENCE_COLUMN_NAME))]
  medications <- loadResourcesFromDB(
    resource_name = "Medication",
    column_name = "med_id",
    query_ids = medication_ids,
    remove_ref_type = TRUE
  )

  # Fill column LOINC_VALIDITY_DAYS and find max value
  observation_datetime <- calculateObservationDatetime(drug_disease_mrp_tables[[1]], "LOINC_VALIDITY_DAYS", query_datetime, DEFAULT_LOINC_VALIDITY_DAYS)
  # Load Observation resources referenced by Patient
  observations <- loadResourcesFromDB(
    resource_name = "observation",
    column_name = "obs_patient_ref",
    query_ids = patient_ids,
    additional_query_parameter = paste0("obs_effectivedatetime >= '", observation_datetime, "'\n")
  )

  # Load Condition resources referenced by Patient
  conditions <- loadResourcesFromDB(
    resource_name = "condition",
    column_name = "con_patient_ref",
    query_ids = patient_ids
  )

  # Load Procedures resources referenced by Encounter
  encounter_ids <- paste0("Encounter/", unique(encounters$enc_id))
  procedures <- loadResourcesFromDB(
    resource_name = "procedure",
    column_name = "proc_encounter_ref",
    query_ids = encounter_ids
  )

  # Load mrp_drug_disease template table
  mrp_drug_disease_path <- "./R-dataprocessor/submodules/02_MRP_Drug_Disease/R-MRP_Drug_Disease/inst/extdata/mrp_drug_disease.xlsx"
  mrp_drug_disease_tables <- etlutils::getTableDescriptionSplittedByTableName(mrp_drug_disease_path, "mrp_drug_disease")

  # Initialize table for calculated drug disease MRPs
  calculated_drug_disease_mrps <- createEmptyTable(mrp_drug_disease_tables$mrp_drug_disease)

  browser()

}


#' calculateDrugDiseaseMRPs <- function(drug_disease_mrp_definition) {
#'   calculateMRPsInternal <- function(drug_disease_mrp_definition_expanded) {
#'     # load current relevant patient IDS per Ward
#'     pids_per_ward <- loadPIDsPerWard()
#'
#'     result_mrps <- data.table()
#'     for (pid in pids_per_ward$patient_id) {
#'
#'       # MEDICATION_REQUEST_RESOURCE = "MedicationAdministration"
#'       # MEDICATION_REQUEST_RESOURCE_TIMESTAMP_COLUMN_NAME = "medreq_doseinstruc_timing_event"
#'       # MEDICATION_REQUEST_RESOURCE_PERIOD_START_COLUMN_NAME = "medreq_doseinstruc_timing_repeat_boundsperiod_start"
#'       # MEDICATION_REQUEST_RESOURCE_PERIOD_END_COLUMN_NAME = "medreq_doseinstruc_timing_repeat_boundsperiod_end"
#'
#'       getCurrentMedication <- function(pid, drug_disease_mrp_definition_expanded, current_time = Sys.time()) {
#'
#'         # TODO: Diese Funktion wird ziemlich sicher auch in den anderen MRP-Berechnungen gebraucht -> nach 01 verlegen
#'         # Encounter has a start date before or on the given date and is not yet completed on the given date.
#'         #
#'         # @param pid the patient ID
#'         # @param current_time datetime for which all active encounters are to be found
#'         #
#'         # @return data.table with all current Encounters for the given patient at the given datetime
#'         #
#'         getCurrentEncounters <- function(pid, current_time) {
#'           encounters <- getEncounterResources(pid)
#'           encounters <- encounters[enc_period_start <= current_time & (is.na(enc_period_end) | enc_period_end > current_time)]
#'           return(encounters)
#'         }
#'
#'         # Calculates which of the given MedicationRequests belongs to one of the given encounters based on the date.
#'         #
#'         # @param medication_requests data.table with the MedicationRequests to check
#'         # @param current_encounters data.table with all Encounters in whose runtime the given MedicationRequests should
#'         #        lie
#'         #
#'         # @return data.table with the matching MedicationRequests
#'         #
#'         getCurrentMedicationsByDateMatching <- function(medication_requests, current_encounters) {
#'           # 5.2 Now all remaining MedicationRequests with matching dates must be found. I.e.
#'           #    a. There is a timing event that is at or after the start of an encounter and before its end, if
#'           #       this encounter end is not NA.
#'           current_medication_requests <- medication_requests[{
#'             start_time <- get(MEDICATION_REQUEST_RESOURCE_TIMESTAMP_COLUMN_NAME)
#'             any(start_time >= encounters$enc_period_start) | any(start_time < encounters$enc_period_end)
#'           }]
#'           #       remove all MedicationRequest from the remaining which we found in step a.
#'           medication_requests <- medication_requests[!current_medication_requests, on = names(medication_requests), nomatch = 0]
#'
#'           #    b. Same check as a. only for period start
#'           more_current_medication_request <- medication_requests[{
#'             start_time <- get(MEDICATION_REQUEST_RESOURCE_PERIOD_START_COLUMN_NAME)
#'             any(start_time >= encounters$enc_period_start) | any(start_time < encounters$enc_period_end)
#'           }]
#'           #       add the matching MedicationRequests to the result
#'           current_medication_requests <- rbind(current_medication_requests, more_current_medication_request)
#'           #       remove all MedicationRequest from the remaining which we found in step b.
#'           medication_requests <- medication_requests[!current_medication_requests, on = names(medication_requests), nomatch = 0]
#'
#'           #    c. Period end is after the start date of the Encounter but before or on the end
#'           #       date of the Encounter if this Encounter end is not NA.
#'           more_current_medication_request <- medication_requests[{
#'             end_time <- get(MEDICATION_REQUEST_RESOURCE_PERIOD_END_COLUMN_NAME)
#'             any(end_time > encounters$enc_period_start) & any(end_time <= encounters$enc_period_end)
#'           }]
#'           #       add the matching MedicationRequests to the result
#'           current_medication_requests <- rbind(current_medication_requests, more_current_medication_request)
#'           #       remove all MedicationRequest from the remaining which we found in step b.
#'           medication_requests <- medication_requests[!current_medication_requests, on = names(medication_requests), nomatch = 0]
#'
#'           #    d. Period start is before the Encounter start and period end is after the
#'           #       Encounter end if this counter end is not NA.
#'           more_current_medication_request <- medication_requests[{
#'             start_time <- get(MEDICATION_REQUEST_RESOURCE_PERIOD_START_COLUMN_NAME)
#'             end_time <- get(MEDICATION_REQUEST_RESOURCE_PERIOD_END_COLUMN_NAME)
#'             any(start_time < encounters$enc_period_start) & any(end_time > encounters$enc_period_end)
#'           }]
#'           #       add the matching MedicationRequests to the result
#'           current_medication_requests <- rbind(current_medication_requests, more_current_medication_request)
#'           return(current_medication_requests)
#'         }
#'
#'         # Calculates for a given MedicationRequest whether a medication will be applied on the given date.
#'         #
#'         # @param medication_requests data.table with the MedicationRequest to check
#'         # @param date date (day) that should be checked whether the medication is applied at
#'         #
#'         # @return vector with TRUE/FALSE values for every MedicationRequest in the same order as in medication_request
#'         #
#'         willBeAppliedAt <- function(medication_requests, date) {
#'
#'         }
#'
#'         # all resource datetimes are nromalized to UTC by the getResource() function -> normalize current_time too
#'         current_time <- etlutils::normalizeTimeToUTC(current_time)
#'         # 1. Take all Encounters of the patient with pid whose start date is before current_time and whose end date
#'         #    is after current_time or is not set at all
#'         encounters <- getCurrentEncounters(pid, current_time)
#'         # 2. Get all MedicationRequests of the patient that have ever been made
#'         medication_requests <- getResources(MEDICATION_REQUEST_RESOURCE, pid)
#'         #    2.1 Remove unnecessary columns
#'         medication_needed_column_names <- unlist(getGlobalVariablesByPrefix("MEDICATION_REQUEST_RESOURCE_"))
#'         etlutils::retainColumns(medication_requests, medication_needed_column_names)
#'         # 3. Remove all MedicationRequests that were ordered in the future
#'         medication_requests <- medication_requests[get(MEDICATION_REQUEST_RESOURCE_TIMESTAMP_COLUMN_NAME) <= current_time]
#'         # 4. Collect all remaining MedicationRequests in a new list that directly reference one of the encounters from 1.
#'         current_medication_requests <- medication_requests[etlutils::getAfterLastSlash(get(MEDICATION_REQUEST_RESOURCE_ENCOUNTER_REFERENCE_COLUMN_NAME)) %in% encounters$enc_id]
#'         # 5. For all remaining MedicationRequests that have not ended up in the new list, check the date to see if they
#'         #    match one of the current Encounters. If so, add them to the new list as well.
#'         #    5.1 Remove the MedicationRequest with encounter references from the original list
#'         current_encounter_IDs <- current_medication_requests[[MEDICATION_REQUEST_RESOURCE_ENCOUNTER_REFERENCE_COLUMN_NAME]]
#'         medication_requests <- medication_requests[!(get(MEDICATION_REQUEST_RESOURCE_ENCOUNTER_REFERENCE_COLUMN_NAME) %in% current_encounter_IDs)]
#'
#'
#'         # library(data.table)
#'         # encounters <- data.table(enc_period_start = as.POSIXct(c("2023-03-10 12:00:00",
#'         #                                                          "2023-03-11 15:00:00")))
#'         # start_time <- as.POSIXct("2023-03-10 12:00:01")
#'
#'
#'         #    5.2. Jetzt müssen alle übrigen MedicationRequest rausgefunden werden, bei denen das Datm passt. D.h.
#'         #       a. Es gibt ein timing event, das am oder nach dem Start eines Encounter liegt und vor dessen Ende, wenn
#'         #          dieses Encounterende nicht NA ist.
#'         more_current_encounters <- medication_requests[{
#'           start_time <- get(MEDICATION_REQUEST_RESOURCE_TIMESTAMP_COLUMN_NAME)
#'           any(start_time >= encounters$enc_period_start) | any(start_time < encounters$enc_period_end)
#'         }]
#'         #       b. Denselben Check wie a. nur für period start
#'         #       c. Period end liegt nach dem Startdatum des Encounters aber vor oder am Enddatum des Encounters, wenn
#'         #          dieses Encounterende nicht NA ist.
#'         #       d. Period start liegt vor dem Encounterstart und period end liegt nach dem Encounternende, wenn dieses
#'         #          Encounterende nicht NA ist.
#'
#'         #    5.2 Add all time matching Medicationrequest to the current list
#'         # for (i in seq_len(nrow(medication_requests))) {
#'         #   medication_request <- medication_requests[i]
#'         #   if (isCurrentMedicationByDateMatching(medication_request, encounters)) {
#'         #     current_medication_requests <- rbind(current_medication_requests, medication_request)
#'         #   }
#'         # }
#'
#'         current_medication_requests <- rbind(current_medication_requests, getCurrentMedicationsByDateMatching(medication_request))
#'
#'         # 6. Merge the Medications to the remaining MedicationRequest to get the ATC codes for the requests
#'         getMedicationResources(current_medication_requests[[]])
#'         # 7. Run them through the willBeApplyedAt() function and use it to fill the 30-day matrix.
#'
#'       }
#'
#'       getCurrentDiagnosesByLoinc <- function(pid, drug_disease_mrp_definition_expanded) {
#'         # analog getCurrentDiagnosesByIcd but determine the ICD code via LOINC
#'       }
#'
#'       # patient_resource <- getPatientResources(pid)
#'       # encounter_resources <- getEncounterResources(pid)
#'
#'       #medication_resources <- getMedicationResource(pid)
#'       # medicationadministration_resources <- getMedicationAdministrationResources(pid)
#'       # medicationstatement_resources <- getMedicationStatementResources(pid)
#'
#'
#'       getCurrentDiagnosesByICD <- function(pid, drug_disease_mrp_definition_expanded, current_time = Sys.time()) {
#'         # all resource datetimes are nromalized to UTC by the getResource() function -> normalize current_time too
#'         current_time <- etlutils::normalizeTimeToUTC(current_time)
#'         # 0. Get the table with all diagnoses ever made for the patient
#'         conditions <- getConditionResources(pid)
#'         # 1. Remove all irrelevant conditions (not contained in the MRP lists)
#'         diagnoses <- unique(na.omit(drug_disease_mrp_definition_expanded$ICD))
#'         diagnoses <- sort(unique(unlist(strsplit(diagnoses, "\\+"))))
#'         conditions <- conditions[con_code_code %in% diagnoses]
#'         #TODO: Wenn wir die Stati "completed, "inactive" etc. als mögliches Ende einer vorher gestellten Diagose beachten wollen, dürfen wir das wegwerfen aller nicht-"active" Diagnosen nicht machen
#'         # 2. Remove all diagnoses that have a clinicalStatus and this is not 'active'
#'         conditions <- conditions[is.na(con_clinicalstatus_code) || con_clinicalstatus_code == "active"]
#'         # 3. Remove all diagnoses with a start time in the future (recordeddate is a datetime)
#'         conditions <- conditions[con_recordeddate <= current_time]
#'         # 4. Remove all diagnosis with an abatement time in the past
#'         conditions <- conditions[is.na(con_abatementdatetime) || con_abatementdatetime >= current_time]
#'         # 5. Remove all diagnoses that are no longer valid
#'         #TODO: Wir müssen hier auch nach Diagnosen suchen, die durch ihren Status vorher gestellte Diagnosen der gleichen ICD beenden (siehe TODO an 2.). Es kann zu mehreren Zeitintervallen für eine Diagnose kommen.
#'         #   Extract for every diagnosis code the validity period (duration) in days
#'         diagnoses_durations <- drug_disease_mrp_definition_expanded[ICD %in% conditions$con_code_code]
#'         diagnoses_durations <- etlutils::retainColumns(diagnoses_durations, c("ICD", "Geltungsdauer"))
#'         diagnoses_durations[, Geltungsdauer := as.integer(Geltungsdauer)]
#'         diagnoses_durations <- unique(diagnoses_durations)
#'         #   Filter diagnoses_durations to only keep the longest duration for each ICD code (if there are conflicting durations for the same code)
#'         diagnoses_durations[is.na(Geltungsdauer), Geltungsdauer := Inf] # Replace NA with Inf
#'         diagnoses_durations <- diagnoses_durations[, .SD[which.max(Geltungsdauer)], by = ICD]
#'         #   Perform a join between conditions and diagnoses_durations to add the duration to each diagnosis in conditions
#'         conditions <- merge(conditions, diagnoses_durations, by.x = "con_code_code", by.y = "ICD", all.x = TRUE)
#'         #   Calculate the validity end date for each diagnosis in conditions and filter based on a given current_time
#'         #      R's Integer values have 32 bit. To calculate with dates by Integer values the absolut maximum date is
#'         #      "2038-01-19 04:14:07 CET". To express infinite diagnosis duration we select a slightly lower date in the
#'         #      far away future.
#'         conditions[, con_validity_end := as.POSIXct(ifelse(is.infinite(Geltungsdauer), "9999-12-31 23:59:59", as.integer(con_recordeddate + Geltungsdauer * 3600 * 24)))]
#'         conditions[, con_validity_end := as.POSIXct(ifelse(is.na(con_abatementdatetime), con_validity_end, min(con_abatementdatetime, con_validity_end)))]
#'         #   remove all no longer valid conditions (con_validity_end in the past -> drop them)
#'         conditions <- conditions[con_validity_end >= current_time]
#'
#'         # every interval will end MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE days in the from current_time
#'         general_diagnosis_max_time <- getMaxTimeInFutureToCheckForMRPs(current_time)
#'         # 6. Determine for every diagnosis from current_time until general_diagnosis_max_time which diagnoses applies
#'         #   Create a list of vectors with the diagnosis code as name for the list elements and an interval for the
#'         #   validity period of the diagnosis.
#'         current_conditions <- list()
#'         for (i in seq_len(nrow(conditions))) {
#'           condition <- conditions[i]
#'           diagnosis_min_time <- max(condition$con_recordeddate, current_time)
#'           diagnosis_max_time <- min(general_diagnosis_max_time, condition$con_validity_end)
#'           current_conditions[[condition$con_code_code]] <- lubridate::interval(diagnosis_min_time, diagnosis_max_time)
#'         }
#'         return(current_conditions)
#'       }
#'       current_conditions <- getCurrentDiagnosesByICD(pid, drug_disease_mrp_definition_expanded, as.POSIXct("2019-01-01 12:00:00", tz = "CET"))
#'       #current_medication <- getCurrentMedication(pid, drug_disease_mrp_definition_expanded, as.POSIXct("2019-01-01 12:00:00", tz = "CEST"))
#'
#'     }
#'     return(result_mrps)
#'   }
#'
#'   etlutils::runLevel3("Check if drug_disease_mrp_definition must be expanded", {
#'     # Check if drug_disease_mrp_definition must be expanded
#'     # set must_expand to FALSE
#'     must_expand <- FALSE
#'     # load file info for drug-disease-mrp excel
#'     file_info_drug_disease_mrp_definition <- file.info(readExcelFilePath(MRP_DEFINITION_FILE_DRUG_DISEASE))
#'     # check if .RData files not exists or modification time is not equal -> set must_expand to TRUE
#'     if (!etlutils::existsLocalRdataFile("mrp_definition_file_status") || !etlutils::existsLocalRdataFile("drug_disease_mrp_definition_expanded")) {
#'       must_expand <- TRUE
#'       mrp_definition_file_status <- list()
#'     } else {
#'       mrp_definition_file_status <- etlutils::polar_read_rdata("mrp_definition_file_status")
#'       drug_disease_last_update <- mrp_definition_file_status[["drug_disease_last_update"]]
#'       if (is.null(drug_disease_last_update) || file_info_drug_disease_mrp_definition$mtime != drug_disease_last_update) {
#'         must_expand <- TRUE
#'       }
#'     }
#'   })
#'
#'   etlutils::runLevel3("Expand drug_disease_mrp_definition", {
#'     if (must_expand) {
#'       # read drug-disease-mrp excel as table list
#'       drug_disease_mrp_definition <- readExcelFileAsTableListFromExtData(MRP_DEFINITION_FILE_DRUG_DISEASE)[["Drug_Disease_Pairs"]]
#'       # clean and expand table list
#'       drug_disease_mrp_definition_expanded <- cleanAndExpandDefinition(drug_disease_mrp_definition)
#'       polar_write_rdata(drug_disease_mrp_definition_expanded)
#'       # set modification date of drug-disease-mrp excel file to new list with drug_disease_last_update
#'       mrp_definition_file_status[["drug_disease_last_update"]] <- file_info_drug_disease_mrp_definition$mtime
#'       polar_write_rdata(mrp_definition_file_status)
#'     }
#'   })
#'
#'   etlutils::runLevel3("Load expanded drug_disease_mrp_definition from file", {
#'     if (!exists("drug_disease_mrp_definition_expanded")) {
#'       drug_disease_mrp_definition_expanded <- etlutils::polar_read_rdata("drug_disease_mrp_definition_expanded")
#'     }
#'   })
#'
#'   etlutils::runLevel3("Calculate Drug Disease MRPs internal", {
#'     mrps <- calculateMRPsInternal(drug_disease_mrp_definition_expanded)
#'     message(mrps)
#'   })
#'
#'   etlutils::runLevel3("Create Drug Disease MRP Table", {
#'     # TODO weitere Spalten wie medreq_ID, medreq_startdate, con_datetime, obs_datetime
#'     # wie Hauptdiagnose bestimmen
#'     mrp_drug_disease <- data.table::data.table(
#'       pid = c("IP_123", "IP_123" ),
#'       mrp_calculation_time = c("2024-04-23 10:19:32 UTC", "2024-04-24 10:19:32 UTC"),
#'       mrp_description = c("Antithrombin-Mangel", "Hyperthyreose"),
#'       atc1 = c("G03FA15", "N06BA12"),
#'       atc1_active_component = c("Dienogest und Estrogen", "Lisdexamfetamin"),
#'       icd = c(NA, "E05"),
#'       proxy_atc2 = c("B01AB02", NA),
#'       proxy_loinc = c(NA, NA)
#'     )
#'   })
#'
#'   etlutils::runLevel3("Write MRP Tables to DB", {
#'     writeResourceTablesToDatabase <- function(tables, table_names = NA, clear_before_insert = FALSE) {
#'
#'       # write all tables (table_names == NA) or only tables with the given names
#'       if (is.na(table_names)) {
#'         table_names <- names(tables)
#'       }
#'
#'       db_connection <- etlutils::dbConnect(
#'         user = DB_KDS2DB_USER,
#'         password = DB_KDS2DB_PASSWORD,
#'         dbname = DB_GENERAL_NAME,
#'         host = DB_GENERAL_HOST,
#'         port = DB_GENERAL_PORT,
#'         schema = DB_KDS2DB_SCHEMA_IN
#'       )
#'
#'       db_table_names <- etlutils::dbListTables(db_connection)
#'       # Display the table names
#'       print(paste("The following tables are found in database:", paste(db_table_names, collapse = ", ")))
#'       if (is.null(db_table_names)) {
#'         warning("There is no tables found in database")
#'       }
#'
#'       # write tables to DB
#'       for (table_name in table_names) {
#'         if (tolower(table_name) %in% db_table_names) {
#'           table <- tables[[table_name]]
#'           if (clear_before_insert) {
#'             etlutils::dbDeleteContent(db_connection, table_name)
#'           }
#'           # Check column widths of table content
#'           etlutils::dbCheckContent(db_connection, table_name, table)
#'           # Add table content to DB
#'           etlutils::dbAddContent(db_connection, table_name, table)
#'         } else {
#'           warning(paste("Table", table_name, "not found in database"))
#'         }
#'       }
#'       etlutils::dbDisconnect(db_connection)
#'     }
#'   })
#'
#' }
