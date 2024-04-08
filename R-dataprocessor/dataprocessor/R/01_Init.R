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
