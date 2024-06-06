#' Brackets for the fhir table descriptions used for the indices of multi value entries.
#'
#' @details If a xpath expression returns more than 1 value (if it is a list of multiple values (e.g.
#' list of codes and corresponding code systems), then all
#'
BRACKETS <- c("[", "]")

#' Brackets for the fhir table descriptions
SEP      <- " ~ "

#' Load Table Description Excel File
#'
#' This function loads a table description excel file
#'
#' @return A data table with table descriptions
#'
loadTableDescriptionFile <- function() {
  table_description_file_path <- system.file("extdata", "Table_Description.xlsx", package = "cds2db")
  table_description <- etlutils::readExcelFileAsTableList(table_description_file_path)[['table_description']]
  return(table_description)
}

#' Get a table with the Table Descriptions for all fhir resources from Excel file
#'
#' This function reads the "Table_Description.xlsx" file from the "extdata" directory
#' in the package and returns the data as a data table.
#'
#' @param columns column names which should be in the return table. If NA then no column
#' will be removed.
#'
#' @return A data table with the table descriptions.
#'
getTableDescriptionsTable <- function(columns = NA) {
  table_description <- loadTableDescriptionFile()
  # remove all rows with NA in column 'fhir_expression'
  table_description <- table_description[!is.na(fhir_expression), ]
  # fill resource NA column with the last valid (non NA) value above
  table_description[, resource := resource[1], .(cumsum(!is.na(resource)))]
  #remove unneccesary columns
  etlutils::retainColumns(table_description, columns)
  return(table_description)
}

#' Get a list of fhircrackr::fhir_table_description() objects based on a table description.
#'
#' This function takes a table description table, typically obtained from
#' `getTableDescriptionsTable()`, and creates a list of
#' `fhircrackr::fhir_table_description()` objects, each corresponding to a resource
#' group in the table.
#'
#' @param table_description_table A data table containing information about
#'   resources, column names, and FHIR expressions. If not provided, it
#'   defaults to the result of calling `getTableDescriptionsTable()`.
#'
#' @return A list of `fhircrackr::fhir_table_description()` objects, where each object
#'   represents a resource group, and its elements correspond to the specified columns
#'   and FHIR expressions.
#'
#' @examples
#' \dontrun{
#'   # Example usage:
#'   table_desc <- getFhircrackrTableDescriptions()
#'   # Access the fhir_table_description() object for a specific resource group (e.g., "Encounter")
#'   encounter_description <- table_desc[["Encounter"]]
#' }
#'
#' @seealso
#' \code{\link{getTableDescriptionsTable}}, \code{\link[fhircrackr]{fhir_table_description}}
#'
#' @keywords data manipulation
getFhircrackrTableDescriptions <- function(table_description_table = NA) {
  isPIDDependant <- function(table_description) {
    resource_name <- table_description@resource@.Data
    return(resource_name == "Patient" || "subject/reference" %in% table_description@cols@.Data || "patient/reference" %in% table_description@cols@.Data)
  }
  if (is.na(table_description_table)) {
    table_description_table <- getTableDescriptionsTable(c("resource", "column_name", "fhir_expression", "reference_types"))
  }

  # Grouping by 'resource' and creating lists of fhircrackr::fhir_table_description() objects
  table_descriptions <- lapply(split(table_description_table, table_description_table$resource), function(subset) {
    resource_name <- unique(subset$resource)
    col_names <- subset$column_name
    fhir_expressions <- subset$fhir_expression

    # Creating a named vector for the 'cols' argument
    cols_vector <- setNames(as.list(fhir_expressions), col_names)

    # Creating fhircrackr::fhir_table_description() for the current 'resource'
    fhir_table_desc <- fhircrackr::fhir_table_description(
      resource = resource_name,
      cols = cols_vector,
      sep = SEP,
      brackets = BRACKETS
    )
    return(fhir_table_desc)
  })
  pid_dependant <- list()
  pid_independant <- list()
  for (table_description in table_descriptions) {
    resource_name <- table_description@resource@.Data
    if (isPIDDependant(table_description)) {
      pid_dependant[resource_name] <- table_description
    } else {
      pid_independant[resource_name] <- table_description
    }
  }
  reference_types <- table_description_table[!is.na(reference_types)]
  # Returning the list of fhircrackr::fhir_table_description() objects
  return(list(pid_dependant = pid_dependant, pid_independant = pid_independant, reference_types = reference_types))
}

#' Extract Table Descriptions List
#'
#' This function extracts table descriptions from a given list of FHIR table descriptions.
#' It combines the `pid_dependant` and `pid_independant` elements into a single list.
#'
#' @param fhir_table_descriptions_grouped A list containing FHIR table descriptions
#'        with `pid_dependant` and `pid_independant` elements.
#' @return A list combining the `pid_dependant` and `pid_independant` elements.
#'
extractTableDescriptionsList <- function(fhir_table_descriptions_grouped) {
  as.list(c(fhir_table_descriptions_grouped$pid_dependant, fhir_table_descriptions_grouped$pid_independant))
}
