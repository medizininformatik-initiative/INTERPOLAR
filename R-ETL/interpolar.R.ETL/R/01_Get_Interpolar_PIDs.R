
#' Converts a filter pattern list from the toml file into an internal representation
#' as a list of lists. Every subcondition in a sublist must be fulfilled to fulfill
#' the whole condition represented by the sublist (AND connected). Lines of the table
#' can be accepted by the filter if at least one of the main conditions (which consists
#' of these subconditions) in the main list is fulfilled (OR connected).
#'
#' @param table_description the table descrption that corresponds to the same resource
#' like the defined filter patterns
#' @param filter_patterns_name name of the variable in the glogbal environment which
#' contains the filter patterns from the toml file
#'
#' @return the filter patterns which are converted to a list of lists
#'
convertFilterPatterns <- function(table_description, filter_patterns_name) {

  table_description_col_names <- table_description@cols@names
  table_description_xpath_expressions <- table_description@cols@.Data

  converted_filter_patterns <- NA
  if (exists(filter_patterns_name)) {
    converted_filter_patterns <- list() # the result list with all
    resource_filter_patterns <- get(filter_patterns_name)
    for (filter_patterns in resource_filter_patterns) {
      and_conditions <- list()
      filter_pattern_conditions <- unlist(strsplit(filter_patterns, '\\+'))
      for (condition in filter_pattern_conditions) {
        condition_key_value <- unlist(strsplit(condition, '='))

        condition_column <- trimws(condition_key_value[1])
        xpath_index <- match(condition_column, table_description_xpath_expressions)
        if (!is.na(xpath_index)) {
          condition_column <- table_description_col_names[xpath_index]
        }
        condition_value <- trimws(condition_key_value[2])
        # remove the single quotes at the beginning and the end
        condition_value <- substr(condition_value, start = 2, stop = nchar(condition_value) - 1)
        and_conditions[[condition_column]] <- condition_value
      }
      converted_filter_patterns[[paste0('Condition_', length(converted_filter_patterns) + 1)]] <- and_conditions
    }
  }
  converted_filter_patterns
}


#' Extracts the Interploar relevant patient IDs from download Encounter resources. If the file name parameter
#' is NA then the relevant patient IDs are extracted by Encounters downloaded from the FHIR server. If the file
#' name parameter is not NA then the patient IDs are loaded from the specified file (one PID per line).
#'
#' @param path_to_PID_list_file file name if the list of patient IDs should be loaded from a file (if not then NA)
#'
#' @return the Interploar relevant patient IDs
#'
#' @export
getInterpolarPatientIDs <- function(path_to_PID_list_file = NA) {

  interpolar.R.utils::run_in_in('Get Patient IDs by file', {
    if (!is.na(path_to_PID_list_file)) {
      pids <- readLines(path_to_PID_list_file)
      return(unique(sort(pids)))
    }
  })

  interpolar.R.utils::run_in_in('Get Encounters', {
    PERIOD_START <<- "2019-01-01"
    PERIOD_END <<- "2019-01-02"
    encounters <- interpolar.R.utils::get_encounters()
  })

  interpolar.R.utils::runs_in_in('Filter Interpolar relevant encounters', {
    converted_filter_patterns <- convertFilterPatterns(TABLE_DESCRIPTION$Encounter, 'ENCOUNTER_FILTER_PATTERNS')
    encounters <- interpolar.R.utils::filterResources(encounters, converted_filter_patterns)
    return(unique(sort(encounters$Enc.Pat.ID)))
  })

}
