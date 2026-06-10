#' Brackets for the fhir table descriptions used for the indices of multi value entries.
#'
#' @details If a xpath expression returns more than 1 value (if it is a list of multiple values (e.g.
#' list of codes and corresponding code systems), then all
#'
BRACKETS <- c("[", "]")

#' Brackets for the fhir table descriptions
SEP      <- " ~ "

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
  table_description <- etlutils::loadTableDescriptionFile()
  # remove all rows with NA in column 'FHIR_EXPRESSION'
  table_description <- table_description[!is.na(FHIR_EXPRESSION), ]
  # fill RESOURCE NA column with the last valid (non NA) value above
  table_description[, RESOURCE := RESOURCE[1], .(cumsum(!is.na(RESOURCE)))]
  # remove unneccesary columns
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
    table_description_table <- getTableDescriptionsTable(c("RESOURCE", "COLUMN_NAME", "FHIR_EXPRESSION", "REFERENCE_TYPES"))
  }

  # Filter fhir resources (starts with capital letter in column resource in the table_description_table)
  fhir_table_description_table <- table_description_table[-grep("^[a-z]", RESOURCE)]
  # Grouping by 'RESOURCE' and creating lists of fhircrackr::fhir_table_description() objects
  table_descriptions <- lapply(split(fhir_table_description_table, fhir_table_description_table$RESOURCE), function(subset) {
    resource_name <- unique(subset$RESOURCE)
    col_names <- subset$COLUMN_NAME
    fhir_expressions <- subset$FHIR_EXPRESSION

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
      pid_dependant[[resource_name]] <- table_description
    } else {
      pid_independant[[resource_name]] <- table_description
    }
  }
  reference_types <- table_description_table[!is.na(REFERENCE_TYPES)]
  # Returning the list of fhircrackr::fhir_table_description() objects
  return(list(pid_dependant = pid_dependant, pid_independant = pid_independant, reference_types = reference_types))
}

#' Get PID-dependent resource types allowed for data import
#'
#' @param table_description_table TableDescription rows with RESOURCE and FHIR_EXPRESSION.
#' @return A character vector of allowed FHIR resource types.
getDataImportPIDDependantResourceTypes <- function(table_description_table = getTableDescriptionsTable(c("RESOURCE", "FHIR_EXPRESSION"))) {
  data_import_resource_types <- etlutils::getResourcesWithFHIRExpressions(
    table_description_table,
    c("subject/reference", "patient/reference")
  )
  # Encounter is loaded by the case-based data import and must not be reloaded as a PID-dependent resource.
  data_import_resource_types <- setdiff(data_import_resource_types, "Encounter")
  return(data_import_resource_types)
}

#' Get referenced PID-independent resource types allowed for data import
#'
#' @param table_description_table TableDescription rows with RESOURCE, FHIR_EXPRESSION and REFERENCE_TYPES.
#' @return A character vector of allowed referenced FHIR resource types.
getDataImportReferencedResourceTypes <- function(
  table_description_table = getTableDescriptionsTable(c("RESOURCE", "FHIR_EXPRESSION", "REFERENCE_TYPES"))
) {
  fhir_resource_types <- unique(table_description_table[!grepl("^[a-z]", RESOURCE)]$RESOURCE)
  referenced_resource_types <- unique(etlutils::extractWords(na.omit(table_description_table$REFERENCE_TYPES)))
  referenced_resource_types <- referenced_resource_types[referenced_resource_types %in% fhir_resource_types]
  pid_dependant_resource_types <- getDataImportPIDDependantResourceTypes(table_description_table)
  referenced_resource_types <- setdiff(referenced_resource_types, c(pid_dependant_resource_types, "Encounter", "Patient"))
  return(referenced_resource_types)
}

#' Get resource types allowed for data import
#'
#' @param table_description_table TableDescription rows with RESOURCE, FHIR_EXPRESSION and REFERENCE_TYPES.
#' @return A character vector of allowed FHIR resource types.
getDataImportAllowedResourceTypes <- function(
  table_description_table = getTableDescriptionsTable(c("RESOURCE", "FHIR_EXPRESSION", "REFERENCE_TYPES"))
) {
  data_import_resource_types <- unique(c(
    getDataImportPIDDependantResourceTypes(table_description_table),
    getDataImportReferencedResourceTypes(table_description_table)
  ))
  return(data_import_resource_types)
}

#' Get resource types selected for data import
#'
#' @param allowed_resource_types Allowed FHIR resource types.
#' @return A character vector of selected FHIR resource types.
getDataImportResourceTypes <- function(allowed_resource_types = getDataImportAllowedResourceTypes()) {
  if (etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RESOURCE_TYPES")) {
    requested_resource_types <- unique(DATA_IMPORT_RESOURCE_TYPES)
    invalid_resource_types <- setdiff(tolower(requested_resource_types), tolower(allowed_resource_types))
    if (length(invalid_resource_types)) {
      invalid_resource_types <- requested_resource_types[tolower(requested_resource_types) %in% invalid_resource_types]
      stop(
        "DATA_IMPORT_RESOURCE_TYPES contains invalid or unsupported resource types: ",
        paste(invalid_resource_types, collapse = ", ")
      )
    }
    return(allowed_resource_types[match(tolower(requested_resource_types), tolower(allowed_resource_types))])
  }

  return(allowed_resource_types)
}

#' Filter FHIR table descriptions for resource type data import
#'
#' @param fhir_table_descriptions Grouped FHIR table descriptions.
#' @return Filtered grouped FHIR table descriptions.
filterFhirTableDescriptionsForDataImport <- function(fhir_table_descriptions) {
  data_import_resource_types <- getDataImportResourceTypes()
  pid_dependant_resource_types <- intersect(data_import_resource_types, names(fhir_table_descriptions$pid_dependant))
  pid_independant_resource_types <- intersect(data_import_resource_types, names(fhir_table_descriptions$pid_independant))

  fhir_table_descriptions$pid_dependant <- fhir_table_descriptions$pid_dependant[pid_dependant_resource_types]
  fhir_table_descriptions$data_import_pid_independant_resource_types <- pid_independant_resource_types
  formatResourceTypes <- function(resource_types) {
    if (length(resource_types)) {
      return(paste(resource_types, collapse = ", "))
    }
    return("none")
  }
  etlutils::catInfoMessage(paste0(
    "Info: Data import selected PID-dependent resource types: ",
    formatResourceTypes(pid_dependant_resource_types),
    "\n"
  ))
  etlutils::catInfoMessage(paste0(
    "Info: Data import selected referenced PID-independent resource types: ",
    formatResourceTypes(pid_independant_resource_types),
    "\n"
  ))
  return(fhir_table_descriptions)
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
