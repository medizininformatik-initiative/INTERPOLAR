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
