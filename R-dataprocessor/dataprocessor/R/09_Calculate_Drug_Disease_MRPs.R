#' calculateDrugDiseaseMRPs <- function(drug_disease_mrp_definition) {
#'
#'   #' Clean and Expand Drug_Disease_MRP Definition Table
#'   #'
#'   #' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#'   #' splitting and trimming values, and expanding concatenated ICD codes.
#'   #'
#'   #' @param drug_disease_mrp_definition A data.table containing the MRP definition table.
#'   #'
#'   #' @return A cleaned and expanded data.table containing the MRP definition table.
#'   #'
#'   #' @export
#'   cleanAndExpandDefinition <- function(drug_disease_mrp_definition) {
#'
#'     # remove table without the needed column names
#'     columnnames <- c('ATC_WIRKSTOFF', 'Mit Drug codierbar', 'Mit ICD-10 codierbar')
#'     if (!all(columnnames %in% names(drug_disease_mrp_definition))) {
#'       drug_disease_mrp_definition <- etlutils::removeTableHeader(drug_disease_mrp_definition, columnnames)
#'       if (!etlutils::isValidTable(drug_disease_mrp_definition)) {
#'         stop("drug_disease_mrp_definition table has invalid structure")
#'       }
#'     }
#'     # rename the columns
#'     new_columnnames <- c('ATC', 'ATC_FOR_ICD', 'ICD')
#'     for (i in seq_along(columnnames)) {
#'       old_col <- columnnames[i]
#'       new_col <- new_columnnames[i]
#'       if (old_col %in% names(drug_disease_mrp_definition)) {
#'         data.table::setnames(drug_disease_mrp_definition, old_col, new_col)
#'       }
#'     }
#'     # remove rows with empty ICD code and empty ATC_FOR_ICD codes
#'     drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, c('ICD', 'ATC_FOR_ICD'))
#'     # check column ATC for length 7
#'     if (sum(nchar(drug_disease_mrp_definition$ATC) != 7)) {
#'       warning("There are rows in column ATC in drug_disease_mrp_definition with more or less 7 digits. Please Check!")
#'     }
#'
#'     # ICD column:
#'     # remove white spaces around plus signs
#'     etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
#'     # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
#'     # (lapply changes the type of the column to list. sapply leaves the type of the column to character.)
#'     drug_disease_mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]
#'
#'     # SPLIT and TRIM: ICD and ATC_FOR_ICD column:
#'     # split the whitespace separated lists in ICD column in a single row per ICD code
#'     drug_disease_mrp_definition <- etlutils::splitColumnToRows(drug_disease_mrp_definition, 'ICD')
#'     # split the whitespace separated lists in ATC_FOR_ICD column in a single row per ATC code
#'     drug_disease_mrp_definition <- etlutils::splitColumnToRows(drug_disease_mrp_definition, 'ATC_FOR_ICD')
#'     # trim all values in the whole table
#'     etlutils::trimTableValues(drug_disease_mrp_definition)
#'
#'     # ICD column: remove tailing points from ICD codes
#'     etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\.$', '')
#'
#'     # Remove rows with empty ICD code and empty ATC_FOR_ICD codes again.
#'     # After the replacing of special signs with an empty string their can be new empty rows in this both columns
#'     drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, c('ICD', 'ATC_FOR_ICD'))
#'
#'     # Remove duplicate rows
#'     drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)
#'
#'     # This loop Expand and concatenate ICD codes. If there are multiple
#'     # ICD codes separated by "+", each code is expanded separately, and combinations of expanded codes are concatenated.
#'     # ICD Codes must be have at least 3 digits.
#'     for (j in seq_len(nrow(drug_disease_mrp_definition))) {
#'       # Extract and split ICD codes, if there is a '+'
#'       icd <- drug_disease_mrp_definition$ICD[j]
#'       input_icds <- unlist(strsplit(icd, '\\+'))
#'
#'       # Check if there is only one ICD code
#'       if (length(input_icds) == 1 && !is.na(input_icds)) {
#'         # Expand and concatenate ICD code
#'         icds <- paste(etlutils::interpolar_expandICDs(input_icds), collapse = ' ')
#'       }
#'       if (length(input_icds) > 1) {
#'         # Expand each ICD code separately and concatenate combinations
#'         icd_1 <- etlutils::interpolar_expandICDs(input_icds[[1]])
#'         icd_2 <- etlutils::interpolar_expandICDs(input_icds[[2]])
#'         icds <- ''
#'         for (r in 1:length(icd_1)) {
#'           icds <- paste0(icds, paste(icd_1[r], icd_2, sep = '+'), ' ')
#'         }
#'         icds <- trimws(paste0(icds, collapse = ''))
#'       }
#'       if (all(is.na(input_icds)) || length(input_icds) == 0) {
#'         icds <- NA_character_
#'       }
#'       # Assign the concatenated ICD codes back to the column 'ICD'
#'       drug_disease_mrp_definition$ICD[j] <- icds
#'     }
#'     # Split concatenated ICD codes into separate rows
#'     drug_disease_mrp_definition <- etlutils::splitColumnToRows(drug_disease_mrp_definition, "ICD")
#'
#'     # Remove duplicate rows
#'     drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)
#'
#'     return(drug_disease_mrp_definition)
#'   }
#'
#'   calculateMRPsInternal <- function(drug_disease_mrp_definition_expanded) {
#'     # load current relevant patient IDS per Ward
#'     pids_per_ward <- loadPIDsPerWard()
#'
#'     result_mrps <- data.table()
#'     for (pid in pids_per_ward$patient_id) {
#'
#'       getCurrentDiagnosesByICD <- function(pid, drug_disease_mrp_definition_expanded, current_time = Sys.time()) {
#'
#'
#'         getCurrentDiagnosesByICD <- function(pid, drug_disease_mrp_definition_expanded, current_time = Sys.time()) {
#'           # all resource datetimes are nromalized to UTC by the getResource() function -> normalize current_time too
#'           current_time <- etlutils::normalizeTimeToUTC(current_time)
#'           # 0. Get the table with all diagnoses ever made for the patient
#'           conditions <- getConditionResources(pid)
#'           # 1. Remove all irrelevant conditions (not contained in the MRP lists)
#'           diagnoses <- unique(na.omit(drug_disease_mrp_definition_expanded$ICD))
#'           diagnoses <- sort(unique(unlist(strsplit(diagnoses, "\\+"))))
#'           conditions <- conditions[con_code_code %in% diagnoses]
#'           #TODO: Wenn wir die Stati "completed, "inactive" etc. als mögliches Ende einer vorher gestellten Diagose beachten wollen, dürfen wir das wegwerfen aller nicht-"active" Diagnosen nicht machen
#'           # 2. Remove all diagnoses that have a clinicalStatus and this is not 'active'
#'           conditions <- conditions[is.na(con_clinicalstatus_code) || con_clinicalstatus_code == "active"]
#'           # 3. Remove all diagnoses with a start time in the future (recordeddate is a datetime)
#'           conditions <- conditions[con_recordeddate <= current_time]
#'           # 4. Remove all diagnosis with an abatement time in the past
#'           conditions <- conditions[is.na(con_abatementdatetime) || con_abatementdatetime >= current_time]
#'           # 5. Remove all diagnoses that are no longer valid
#'           #TODO: Wir müssen hier auch nach Diagnosen suchen, die durch ihren Status vorher gestellte Diagnosen der gleichen ICD beenden (siehe TODO an 2.). Es kann zu mehreren Zeitintervallen für eine Diagnose kommen.
#'           #   Extract for every diagnosis code the validity period (duration) in days
#'           diagnoses_durations <- drug_disease_mrp_definition_expanded[ICD %in% conditions$con_code_code]
#'           diagnoses_durations <- etlutils::retainColumns(diagnoses_durations, c("ICD", "Geltungsdauer"))
#'           diagnoses_durations[, Geltungsdauer := as.integer(Geltungsdauer)]
#'           diagnoses_durations <- unique(diagnoses_durations)
#'           #   Filter diagnoses_durations to only keep the longest duration for each ICD code (if there are conflicting durations for the same code)
#'           diagnoses_durations[is.na(Geltungsdauer), Geltungsdauer := Inf] # Replace NA with Inf
#'           diagnoses_durations <- diagnoses_durations[, .SD[which.max(Geltungsdauer)], by = ICD]
#'           #   Perform a join between conditions and diagnoses_durations to add the duration to each diagnosis in conditions
#'           conditions <- merge(conditions, diagnoses_durations, by.x = "con_code_code", by.y = "ICD", all.x = TRUE)
#'           #   Calculate the validity end date for each diagnosis in conditions and filter based on a given current_time
#'           #      R's Integer values have 32 bit. To calculate with dates by Integer values the absolut maximum date is
#'           #      "2038-01-19 04:14:07 CET". To express infinite diagnosis duration we select a slightly lower date in the
#'           #      far away future.
#'           conditions[, con_validity_end := as.POSIXct(ifelse(is.infinite(Geltungsdauer), "9999-12-31 23:59:59", as.integer(con_recordeddate + Geltungsdauer * 3600 * 24)))]
#'           conditions[, con_validity_end := as.POSIXct(ifelse(is.na(con_abatementdatetime), con_validity_end, min(con_abatementdatetime, con_validity_end)))]
#'           #   remove all no longer valid conditions (con_validity_end in the past -> drop them)
#'           conditions <- conditions[con_validity_end >= current_time]
#'
#'           # every interval will end MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE days in the from current_time
#'           general_diagnosis_max_time <- getMaxTimeInFutureToCheckForMRPs(current_time)
#'           # 6. Determine for every diagnosis from current_time until general_diagnosis_max_time which diagnoses applies
#'           #   Create a list of vectors with the diagnosis code as name for the list elements and an interval for the
#'           #   validity period of the diagnosis.
#'           current_conditions <- list()
#'           for (i in seq_len(nrow(conditions))) {
#'             condition <- conditions[i]
#'             diagnosis_min_time <- max(condition$con_recordeddate, current_time)
#'             diagnosis_max_time <- min(general_diagnosis_max_time, condition$con_validity_end)
#'             current_conditions[[condition$con_code_code]] <- lubridate::interval(diagnosis_min_time, diagnosis_max_time)
#'           }
#'           return(current_conditions)
#'         }
#'
#'         current_conditions <- getCurrentDiagnosesByICD(pid, drug_disease_mrp_definition_expanded)
#'       }
#'       return(result_mrps)
#'     }
#'
#'     etlutils::run_in_in("Check if drug_disease_mrp_definition must be expanded", {
#'       # Check if drug_disease_mrp_definition must be expanded
#'       # set must_expand to FALSE
#'       must_expand <- FALSE
#'       # load file info for drug-disease-mrp excel
#'       file_info_drug_disease_mrp_definition <- file.info(readExcelFilePath(MRP_DEFINITION_FILE_DRUG_DISEASE))
#'       # check if .RData files not exists or modification time is not equal -> set must_expand to TRUE
#'       if (!etlutils::existsLocalRdataFile("mrp_definition_file_status") || !etlutils::existsLocalRdataFile("drug_disease_mrp_definition_expanded")) {
#'         must_expand <- TRUE
#'         mrp_definition_file_status <- list()
#'       } else {
#'         mrp_definition_file_status <- etlutils::polar_read_rdata("mrp_definition_file_status")
#'         drug_disease_last_update <- mrp_definition_file_status[["drug_disease_last_update"]]
#'         if (is.null(drug_disease_last_update) || file_info_drug_disease_mrp_definition$mtime != drug_disease_last_update) {
#'           must_expand <- TRUE
#'         }
#'       }
#'     })
#'
#'     etlutils::run_in_in("Expand drug_disease_mrp_definition", {
#'       if (must_expand) {
#'         # read drug-disease-mrp excel as table list
#'         drug_disease_mrp_definition <- readExcelFileAsTableListFromExtData(MRP_DEFINITION_FILE_DRUG_DISEASE)[["Drug_Disease_Pairs"]]
#'         # clean and expand table list
#'         drug_disease_mrp_definition_expanded <- cleanAndExpandDefinition(drug_disease_mrp_definition)
#'         polar_write_rdata(drug_disease_mrp_definition_expanded)
#'         # set modification date of drug-disease-mrp excel file to new list with drug_disease_last_update
#'         mrp_definition_file_status[["drug_disease_last_update"]] <- file_info_drug_disease_mrp_definition$mtime
#'         polar_write_rdata(mrp_definition_file_status)
#'       }
#'     })
#'
#'     etlutils::run_in_in("Load expanded drug_disease_mrp_definition from file", {
#'       if (!exists("drug_disease_mrp_definition_expanded")) {
#'         drug_disease_mrp_definition_expanded <- etlutils::polar_read_rdata("drug_disease_mrp_definition_expanded")
#'       }
#'     })
#'
#'     etlutils::run_in_in("Calculate Drug Disease MRPs internal", {
#'       calculateMRPsInternal(drug_disease_mrp_definition_expanded)
#'     })
#'
#'   }
#' }
