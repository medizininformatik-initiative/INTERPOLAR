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
initTableDescription <- function() {
  expandTableDescription()
}

#' Creates all Database Scrpts
#'
#' The prerequisite is that the Table_Description_Definition Excel file is available in the
#' 'inst/extdata' directory.
#'
#' @export
initDatabaseScripts <- function() {
  createDatabaseScriptsFromTemplates()
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
  table_description <- etlutils::removeTableHeader(table_description, c("resource", "column_name", "fhir_expression"))
  table_description <- etlutils::removeRowsWithNAorEmpty(table_description)
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
#'
getTableDescriptionSplittedByResource <- function() {
  table_description <- loadTableDescriptionFile()
  table_description[, resource := tolower(resource)]
  table_description <- etlutils::splitTableToList(table_description, "resource")
  return(table_description)
}
