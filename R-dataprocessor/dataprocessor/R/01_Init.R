#' Load tables from RData files
#'
#' This function loads tables from RData files located in the specified directory.
#'
#' @param table_path The path to the directory containing the RData files.
#' @param name_pattern An optional regular expression pattern to filter table names.
#'
#' @return A list of loaded tables.
#'
#' @export
loadTables <- function(table_path, name_pattern = NA) {
  table_names <- sort(list.files(path = table_path))
  table_names <- list.files(path = table_path, pattern = '.\\.RData$')
  if (!is.na(name_pattern)) {
    table_names <- table_names[grep(name_pattern, table_names, ignore.case = TRUE)]
  }
  tables <- list()
  for (table_name in table_names) {
    full_table_path <- paste0(table_path, table_name)
    table <- try(readRDS(full_table_path), silent = TRUE)
    if (data.table::is.data.table(table)) {
      tables <- append(tables, list(table))
      names(tables)[length(tables)] <- gsub('\\.RData$', '', table_name)
    }
  }
  return(tables)
}

#' Get current resource tables from db
#'
#' This function loads the current resource tables from database.
#'
#' @param table_name A resource table name.
#'
#' @return A data structure containing the resource table.
#'
#' @export
loadResourceTable <- function(table_name) {
  readRDS(paste0("./outputLocal/kds2db/tables/", table_name, ".RData"))
}

#' Get current Patient IDs per ward from db
#'
#' This function loads the current Patient IDs per wards from database.
#'
#' @return A data structure containing the current Patient IDs per ward.
#'
#' @export
loadPIDsPerWard <- function() {
  loadResourceTable("pids_per_ward")
}

# Liste mit Ressourcenkürzel, wird später aus der Datenbank ausgelesen
resource_to_abbreviation <- list(
  encounter = "enc",
  patient = "pat",
  condition = "con",
  medication = "med",
  medicationrequest = "medreq",
  medicationadministration = "medadm",
  medicationstatement = "medstat",
  observation = "obs",
  diagnosticreport = "diagrep",
  servicerequest = "servreq",
  procedure = "proc"
)

#' Get Abbreviation for Resource Name
#'
#' This function retrieves the abbreviation for a given resource name.
#'
#' @param resource_name A character string representing the resource name.
#'
#' @return A character string containing the abbreviation for the specified resource name.
#'
#' @export
getResourceAbbreviation <- function(resource_name) {
  resource_name <- tolower(resource_name)
  resource_to_abbreviation[[resource_name]]
}

#' Get PID Column for Resource
#'
#' This function retrieves the name of the PID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the PID column for the specified resource.
#'
#' @export
getPIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  if (resource_name == "patient") {
    pid_column <- "id"
  } else {
    pid_column <- "patient_id"
  }
  pid_column <- paste0(getResourceAbbreviation(resource_name), "_", pid_column)
  return(pid_column)
}

#' Get ID Column for Resource
#'
#' This function retrieves the name of the ID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the ID column for the specified resource.
#'
#' @export
getIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  id_column <- paste0(getResourceAbbreviation(resource_name), "_id")
  return(id_column)
}

#' Get Resources for Specific Patient ID
#'
#' This function filters rows from a resource table based on a specific patient ID.
#'
#' @param resource_name A character string specifying the name of the resource.
#' @param pid A character string representing the specific patient ID to filter for.
#'
#' @return A filtered data.table containing resource information for the specified patient ID.
#'
#' @export
getResourcesByPID <- function(resource_name, pid) {
  # get resource table name
  resource_table_name <- paste0("resource_", resource_name)
  # get PID Column name
  pid_column_name <- getPIDColumn(resource_name)
  # load resource table
  resource_table <- loadResourceTable(resource_table_name)
  # only for resource patient relevant, append string "Patient/"
  if (tolower(resource_name) == "patient" && startsWith(pid, "Patient/")) {
    resource_table[, pat_id := paste0("Patient/", pat_id)]
  }
  # extract rows from resource table with match patient id
  return(resource_table[get(pid_column_name) == pid])
}

#' Get Resources for Specific Resource ID
#'
#' This function filters rows from a resource table based on a resource ID.
#'
#' @param resource_name A character string specifying the name of the resource.
#' @param id A character string representing the specific resource ID to filter for.
#'
#' @return A filtered data.table containing resource information for the resource ID.
#'
#' @export
getResourcesByID <- function(resource_name, id) {
  resource_table_name <- paste0("resource_", resource_name)
  id_column_name <- getIDColumn(resource_name)
  # load resource table
  resource_table <- loadResourceTable(resource_table_name)
  # We need a relative ID here without the resource name. If a resource name appears before the
  # actual ID, it is removed.
  id <- etlutils::getAfterLastSlash(id)
  # extract rows from resource table with match patient id
  return(resource_table[get(id_column_name) == id])
}

#' Get Resources by ID or PID
#'
#' This function retrieves resource information based on either a resource ID or a patient ID.
#'
#' @param resource_name A character string specifying the name of the resource.
#' @param id_or_pid A character string representing either a resource ID or a patient ID.
#'
#' @return A filtered data.table containing resource information based on the provided ID or PID.
#'
#' @export
getResources <- function(resource_name, id_or_pid) {
  if (startsWith(id_or_pid, "Patient/")) {
    return(getResourcesByPID(resource_name, id_or_pid))
  }
  return(getResourcesByID(resource_name, id_or_pid))
}

#' Get Patient Resource Information for Specific Patient ID
#'
#' This function retrieves resource information for a specific patient ID from the resource_patient table.
#'
#' @param id_or_pid A character string representing the specific patient ID to retrieve resource information for.
#'
#' @return A data.table containing resource information for the specified patient ID.
#'
#' @export
getPatientResource <- function(id_or_pid) {
  getResources("Patient", id_or_pid)
}

#' Get Encounter Resource Information for Specific Encounter ID
#'
#' This function retrieves resource information for a specific encounter ID from the resource_encounter table.
#'
#' @param id_or_pid A character string representing the specific encounter ID to retrieve resource information for.
#'
#' @return A data.table containing resource information for the specified encounter ID.
#'
#' @export
getEncounterResource <- function(id_or_pid) {
  getResources("Encounter", id_or_pid)
}

#' Get Condition Resource Information for Specific Condition ID
#'
#' This function retrieves resource information for a specific condition ID from the resource_condition table.
#'
#' @param id_or_pid A character string representing the specific condition ID to retrieve resource information for.
#'
#' @return A data.table containing resource information for the specified condition ID.
#'
#' @export
getConditionResource <- function(id_or_pid) {
  getResources("Condition", id_or_pid)
}

#' Get Medication Resource Information for Specific Medication ID
#'
#' This function retrieves resource information for a specific medication ID from the resource_medication table.
#'
#' @param id A character string representing the specific medication ID to retrieve resource information for.
#'
#' @return A data.table containing resource information for the specified medication ID.
#'
#' @export
getMedicationResource <- function(id) {
  getResources("Medication", id)
}

#' Get MedicationAdministration Resource Information for Specific Medication Administration ID
#'
#' This function retrieves resource information for a specific medication administration ID from the resource_medicationadministration table.
#'
#' @param id_or_pid A character string representing the specific medication administration ID to retrieve resource information for.
#'
#' @return A data.table containing resource information for the specified medication administration ID.
#'
#' @export
getMedicationAdministrationResource <- function(id_or_pid) {
  getResources("Medicationadministration", id_or_pid)
}

#' Get MedicationStatement Resource Information for Specific Medication Statement ID
#'
#' This function retrieves resource information for a specific medication statement ID from the resource_medicationstatement table.
#'
#' @param id_or_pid A character string representing the specific medication statement ID to retrieve resource information for.
#'
#' @return A data.table containing resource information for the specified medication statement ID.
#'
#' @export
getMedicationStatementResource <- function(id_or_pid) {
  getResources("Medicationstatement", id_or_pid)
}

#' Checks whether strings in a vector of ICD codes match specified patterns.
#'
#' This function takes a vector of ICD (International Classification of Diseases)
#' codes and checks whether the strings in this vector match predefined patterns.
#' The patterns are retrieved from an external data frame named SIMPLE_ICD_PATTERN.
#'
#' @param codes A vector of strings containing the ICD codes to be checked.
#' @return A logical vector that returns TRUE for strings that match the patterns
#' and FALSE for strings that do not match the patterns.
#' @seealso SIMPLE_ICD_PATTERN This data frame contains the predefined patterns
#' for ICD codes.
#'
#' @examples
#' codes <- c('H77+M55.2', 'H77', 'XXX', 'X+X', 'X+XXXXX')
#' isICDCode(codes)
#'
#' @export
isICDCode <- function(codes) {
  icd_pattern <- paste(paste0('(', SIMPLE_ICD_PATTERN$ICD1, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD2_3, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD4_6, ')'), sep = '|')
  full_icd_pattern <- paste0('(','^','(', icd_pattern,')', '$', ')', '|', '(', '^', '(', icd_pattern,')', '\\+{1}', '(', icd_pattern, '){1}', '$', ')')
  grepl(full_icd_pattern, codes, perl = TRUE)
}

#' Clean and Validate ICD Code
#'
#' This function cleans and validates an ICD code by converting it to uppercase,
#' removing trailing non-alphanumeric characters, and checking if the resulting
#' code is a valid ICD code.
#'
#' @param icd A character vector representing the ICD code.
#'
#' @return A character vector containing the cleaned and validated ICD code,
#'         or NULL if the input is not a valid ICD code.
#' @examples
#' cleanICD("A11")
#' cleanICD(" B1.2 ")
#' cleanICD("C23-") # This will return NULL as it's not a valid ICD code.
#'
#' @export
cleanICD <- function(icd) {
  icd <- toupper(etlutils::removeLastCharsIfNotAlphanumeric(trimws(icd)))
  icd[isICDCode(icd)]
}

#' Reads the file path of an Excel file
#'
#' This function constructs the file path for an Excel file with the given file name.
#'
#' @param simpleExcelFileName The name of the Excel file without file extension.
#'
#' @return The full file path of the Excel file.
#'
#' @export
readExcelFilePath <- function(simpleExcelFileName) {
  paste0("./R-dataprocessor/dataprocessor/inst/extdata/", simpleExcelFileName, ".xlsx")
}

#' Read an Excel file and import each sheet as a separate data.table.
#'
#' This function reads an Excel file specified by the 'simpleExcelFileName' parameter
#' from internal directory './inst/extdata/' and imports each sheet as a separate
#' data.table. It returns a list of imported sheets.
#'
#' @param simpleExcelFileName The file name of the Excel file without extension.
#'
#' @return A list of imported sheets as data.tables.
#'
#' @export
readExcelFileAsTableListFromExtData <- function(simpleExcelFileName) {
  etlutils::readExcelFileAsTableList(readExcelFilePath(simpleExcelFileName))
}

# https://stackoverflow.com/questions/69947452/regex-boundary-to-also-exclude-special-characters
# These are PERL Patterns -> works only for grep with perl = TRUE
patternw <- function(pattern) paste0('(?<!\\S)', pattern, '(?!\\S)')

# All patterns for valid ATC codes.
# https://www.wido.de/publikationen-produkte/analytik/arzneimittel-klassifikation/
SIMPLE_ATC_PATTERN <- list(
  ATC1 = '[A-Z]',
  #ATC2 is not a valid ATC code
  ATC3 = '[A-Z][0-9]{2}',
  ATC4_5 = '[A-Z][0-9]{2}[A-Z]{1,2}',
  #ATC6 is not a valid ATC code
  ATC7 = '[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}'
)

# All patterns for valid ATC codes in word boundaries.
WORD_ATC_PATTERN <- list(
  ATC1 = patternw(SIMPLE_ATC_PATTERN$ATC1),
  #ATC2 is not a valid ATC code
  ATC3 = patternw(SIMPLE_ATC_PATTERN$ATC3),
  ATC4_5 = patternw(SIMPLE_ATC_PATTERN$ATC4_5),
  #ATC6 is not a valid ATC code
  ATC7 = patternw(SIMPLE_ATC_PATTERN$ATC7)
)

# https://stackoverflow.com/questions/69947452/regex-boundary-to-also-exclude-special-characters
# These are PERL Patterns -> works only for grep with perl = TRUE
SIMPLE_ICD_PATTERN <- list(
  ICD1 = '[A-Z]',
  ICD2_3 = '[A-Z][0-9]{1,2}',
  ICD4_6 = '[A-Z][0-9]{2}\\.[0-9]{0,2}'
)

WORD_ICD_PATTERN <- list(
  ICD1 = patternw(SIMPLE_ICD_PATTERN$ICD1),
  ICD2_3 = patternw(SIMPLE_ICD_PATTERN$ICD2_3),
  ICD4_6 = patternw(SIMPLE_ICD_PATTERN$ICD4_6)
)


ICD_CODES_PATTERN <- list(
  ICD6orSmaller = paste(WORD_ICD_PATTERN$ICD4_6, WORD_ICD_PATTERN$ICD2_3, WORD_ICD_PATTERN$ICD1, sep = '|')
)

# medication codes pattern list
# used in scrips merge_medications_statements/administrations and in function polar_stats_med_code
MED_CODES_PATTERN <- list(
  ATCsystem = "atc",
  ATC7 = WORD_ATC_PATTERN$ATC7,
  ATCsmaller7 = paste(WORD_ATC_PATTERN$ATC4_5, WORD_ATC_PATTERN$ATC3, WORD_ATC_PATTERN$ATC1, sep = '|'),
  ATCgreater7 = patternw('[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}\\S+'), # accepts more chars after a valid ATC7 code which are not whitespaces
  ATC7orSmaller = paste(WORD_ATC_PATTERN$ATC7, WORD_ATC_PATTERN$ATC4_5, WORD_ATC_PATTERN$ATC3, WORD_ATC_PATTERN$ATC1, sep = '|'),
  PZNsystem = 'pzn',
  PZN8 = patternw('[0-9]{8}'),
  PZN8orSmaller = patternw('[0-9]{7,8}')
)

init <- function() {
  tables <<- loadTables('./outputLocal/kds2db/tables/')
}

loadTablesFromDatabase <- function(table_name) {
  return(tables[[table_name]])
}
