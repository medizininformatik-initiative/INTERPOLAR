#' Creates the full expanded Table Description and all Database Scripts.
#'
#' Expands the Table Description Definition Excel file of the FHIR resources to the
#' Table Description Excel file, which is the basis for the fhirckrackr to flatten
#' the FHIR resources into tables and is the basis for the database tables. In a
#' further step this funtion creates the full database scripts for this tables.
#'
#' @export
initTableDescriptionAndDatabaseScripts <- function() {
  expandTableDescription()
  createDatabaseScriptsFromTemplates()
}

#' Creates the full expanded Table Description but not the Database Scripts.
#'
#' Expands the Table Description Definition Excel file of the FHIR resources to the
#' Table Description Excel file, which is the basis for the fhirckrackr to flatten
#' the FHIR resources into tables and is the basis for the database tables.
#'
#' @export
initTableDescriptionOnly <- function() {
  expandTableDescription()
}

#' Load Table Description Excel File
#'
#' This function loads a table description excel file
#'
#' @return A data table with table descriptions
#'
loadTableDescriptionFile <- function() {
  table_description_file_path <- system.file("extdata", "Table_Description.xlsx", package = "cds2db")
  table_description <- etlutils::readExcelFileAsTableList(table_description_file_path)[["table_description"]]
  # remove all full NA rows
  table_description <- table_description[rowSums(is.na(table_description)) != ncol(table_description)]
  return(table_description)
}

#' Get Table Description Split by Resource
#'
#' This function loads a table description from an Excel file, removes rows that
#' are fully NA, and splits the table description by resource. The result is a list
#' where each element is a subset of the table description corresponding to a specific
#' resource.
#'
#' @return A list of data tables, each containing the table description for a specific resource.
#' @export
getTableDescriptionSplittedByResource <- function() {
  table_description <- loadTableDescriptionFile()
  table_description <- table_description[rowSums(is.na(table_description)) != ncol(table_description)]

  splitted_table_description <- list()

  table_description[, resource := tolower(resource)]

  row <- 1
  last_tablename <- NA
  while (row <= nrow(table_description)) {
    tablename <- table_description$resource[row]
    if (!is.na(tablename)) {
      if (!tablename %in% last_tablename) {
        last_tablename <- tablename
        row2 <- row
        while (row2 <= nrow(table_description)) {
          next_tablename <- table_description$resource[row2]
          new_tablename_found <- !is.na(next_tablename) && next_tablename != tablename
          reached_last_row <- row2 == nrow(table_description)
          if (new_tablename_found || reached_last_row) {
            if (!reached_last_row) row2 <- row2 - 1
            single_table_description <- table_description[row:row2]
            single_table_description[, resource := resource[1]]
            splitted_table_description[[tablename]] <- single_table_description
            row <- if (reached_last_row) Inf  else row2 + 1
            row2 <- Inf
          }
          row2 <- row2 + 1
        }
      }
    }
  }
  return(splitted_table_description)
}
