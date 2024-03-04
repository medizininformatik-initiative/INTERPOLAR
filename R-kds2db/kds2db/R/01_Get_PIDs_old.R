#' #' Checks whether this start of the application is the very first start.
#' #'
#' #' @return TRUE when this application fills the database for the first time. This is recognized by whether the
#' #' Encounter table is still completely empty. If there is already something in this table, FALSE is returned,
#' #' as this cannot be the initial start.
#' #'
#' isEncounterTableEmpty <- function() {
#'   # TODO: implement check if Encounter table in database is empty
#'   TRUE
#' }
#'
#' #' Initialize encounter retrieval period for downloading.
#' #'
#' #' This function initializes the period for downloading encounters based on various conditions.
#' #' If debugging period start and end are provided, those values are used. Otherwise, it checks
#' #' if encounter data exists. If not, it sets the period in the past based on the initial days;
#' #' otherwise, it sets the period based on the usual days. If debugging period start is provided,
#' #' it adjusts the start date by subtracting the initial days; otherwise, it uses the current time.
#' #'
#' initEncounterPeriodToDownload <- function() {
#'   # the debug parameters are given both
#'   if (exists('DEBUG_FIXED_DATE')) {
#'     period_end <- as.Date(DEBUG_FIXED_DATE)
#'   } else {
#'     period_end <- as.Date(Sys.time())
#'   }
#'   if (isEncounterTableEmpty()) {
#'     PERIOD_START <<- period_end - INITIAL_ENCOUNTER_START_DATE_IN_PAST_DAYS
#'   } else {
#'     PERIOD_START <<- period_end - USUAL_ENCOUNTER_START_DATE_IN_PAST_DAYS
#'   }
#'   if (exists('DEBUG_FIXED_DATE')) {
#'     # we only need an end date if we are in DEBUG mode
#'     PERIOD_END <<- period_end
#'   }
#' }
#'
#' #' Converts a filter pattern list from the toml file into an internal representation
#' #' as a list of lists. Every subcondition in a sublist must be fulfilled to fulfill
#' #' the whole condition represented by the sublist (AND connected). Lines of the table
#' #' can be accepted by the filter if at least one of the main conditions (which consists
#' #' of these subconditions) in the main list is fulfilled (OR connected).
#' #'
#' #' @param filter_patterns_global_variable_name_prefix name of the variable in the glogbal environment which
#' #' contains the filter patterns from the toml file
#' #'
#' #' @return the filter patterns which are converted to a list of lists
#' #'
#' convertFilterPatterns <- function(filter_patterns_global_variable_name_prefix = 'ENCOUNTER_FILTER_PATTERN') {
#'   ward_pids_filter_patterns <- etlutils::getGlobalVariablesByPrefix(filter_patterns_global_variable_name_prefix)
#'
#'   if (!length(ward_pids_filter_patterns)) {
#'     stopOnError('No ward filter patterns found with prefix', filter_patterns_global_variable_name_prefix, 'in toml file')
#'   }
#'
#'   #
#'   # @param condition_without_reference
#'   #
#'   parseAtomicConditions <- function(condition_without_reference) {
#'     parsed_atomic_conditions <- list()
#'     atomic_conditions <- unlist(strsplit(condition_without_reference, '\\+'))
#'     for (condition in atomic_conditions) { # condition <- atomic_conditions[1]
#'       condition_key_value <- unlist(strsplit(condition, '='))
#'       condition_column <- trimws(condition_key_value[1])
#'       condition_value <- etlutils::getBetweenQuotes(trimws(condition_key_value[2]))
#'       parsed_atomic_conditions[[length(parsed_atomic_conditions) + 1]] <- condition_value
#'       # if there are multple references to the same object, then the names are
#'       # equals -> don't set the value via name but via index!
#'       names(parsed_atomic_conditions)[length(parsed_atomic_conditions)] <- condition_column
#'     }
#'     return(parsed_atomic_conditions)
#'   }
#'
#'   #
#'   # @param ward_conditions
#'   # @param condition
#'   # @param conditions_name_start_index
#'   # @param reference_name_start_index
#'   #
#'   addCondition <- function(ward_conditions, condition, conditions_name_start_index, reference_name_start_index) {
#'     # define regular expression to find the content of the most inner brackets
#'     pattern <- "\\[[^\\[]*?\\]"
#'     # find the contents in most inner brackets
#'     matches <- gregexpr(pattern, condition, perl = TRUE)[[1]]
#'     match_positions <- matches[1]
#'     # if at least one valid position of a bracket was found
#'     while(match_positions != -1) {
#'       match_lengths <- attr(matches, "match.length")
#'       for (i in 1:length(match_positions)) {
#'         reference <- substr(condition, match_positions[i] + 1, match_positions[i] + match_lengths[i] - 2)
#'         reference <- parseAtomicConditions(reference)
#'         reference_name <- paste0("reference", reference_name_start_index)
#'         reference_name_start_index <- reference_name_start_index + 1
#'         ward_conditions[[reference_name]] <- reference
#'         condition_start <- trimws(substr(condition, 0, match_positions[i] - 1))
#'         condition_end <- trimws(substr(condition, match_positions[i] + match_lengths[i], nchar(condition)))
#'         condition <- paste0(condition_start, " = ", reference_name, condition_end)
#'       }
#'       # find the contents in most inner brackets
#'       matches <- gregexpr(pattern, condition, perl = TRUE)[[1]]
#'       match_positions <- matches[1]
#'     }
#'     condition <- parseAtomicConditions(condition)
#'     ward_conditions[[paste0('Condition_', conditions_name_start_index)]] <- condition
#'     return(ward_conditions)
#'   }
#'
#'   # the result list with all
#'   converted_filter_patterns <- list()
#'   ward_index <- 1
#'   for (ward_filter_patterns in ward_pids_filter_patterns) {
#'     single_ward_converted_filter_patterns <- list()
#'     ward_name <- paste('Station', ward_index)
#'     conditions_name_start_index <- 1
#'     reference_name_start_index <- 1
#'     for (filter_patterns in ward_filter_patterns) { # filter_patterns <- ward_pids_filter_patterns[[1]]
#'       for (filter_pattern in filter_patterns) { # filter_pattern <- filter_patterns$value[2]
#'         if (startsWith(filter_pattern, 'ward_name')) {
#'           ward_name <- etlutils::getBetweenQuotes(filter_pattern)
#'         } else {
#'           full_lenght <- length(single_ward_converted_filter_patterns)
#'           single_ward_converted_filter_patterns <- addCondition(single_ward_converted_filter_patterns, filter_pattern, conditions_name_start_index, reference_name_start_index)
#'           new_full_lenght <- length(single_ward_converted_filter_patterns)
#'           conditions_name_start_index <- conditions_name_start_index + 1
#'           reference_name_start_index <- reference_name_start_index + new_full_lenght - full_lenght - 1
#'         }
#'       }
#'       converted_filter_patterns[[ward_name]] <- single_ward_converted_filter_patterns
#'     }
#'   }
#'
#'   return(converted_filter_patterns)
#' }
#'
#' #' Extract Unique XPaths for Each Resource from a Vector of References, Including "id" as First Element
#' #'
#' #' This function takes a vector of references in the format 'Resource/xpath' and returns a list.
#' #' Each list element corresponds to a unique resource name. The element itself is a vector containing
#' #' unique XPath expressions associated with that resource. "id" is always included as the first element
#' #' in each vector, followed by the unique XPath expressions. This ensures a consistent format across all
#' #' resources.
#' #'
#' #' @param references A character vector of references in the format 'Resource/xpath'.
#' #' @return A list where each element is named by the resource and contains a vector of XPaths for that resource,
#' #'         with "id" always as the first element.
#' #' @examples
#' #' references <- c('Location/name', 'Patient/gender/code', 'Medication/code', 'Location/name')
#' #' extractUniqueXpaths(references)
#' #'
#' #' @export
#' extractUniqueXpaths <- function(references) {
#'   # Split each reference into resource and xpath
#'   split_references <- strsplit(references, "/")
#'
#'   # Create a list to hold the unique xpaths for each resource
#'   resource_list <- list()
#'
#'   # Loop through each split reference
#'   for(ref in split_references) {
#'     resource <- ref[1]
#'     xpath <- paste(ref[-1], collapse="/")
#'
#'     # Check if the resource already exists in the list
#'     if(!is.null(resource_list[[resource]])) {
#'       # Add the xpath to the existing resource's vector if it's not already there
#'       # Ensure "id" is always the first element, if not, add it
#'       if(!"id" %in% resource_list[[resource]]) {
#'         resource_list[[resource]] <- c("id", resource_list[[resource]])
#'       }
#'       resource_list[[resource]] <- unique(c(resource_list[[resource]], xpath))
#'     } else {
#'       # Create a new vector for the resource with "id" always as the first element followed by the current xpath
#'       resource_list[[resource]] <- c("id", xpath)
#'     }
#'   }
#'
#'   # Return the list of unique xpaths for each resource
#'   return(resource_list)
#' }
#'
#' #' Get FHIR Table Description Based on Filter Patterns and References
#' #'
#' #' This function constructs a FHIR table description for the 'Encounter' resource based on a list of filter patterns.
#' #' It extracts unique column names from the filter patterns to determine the columns of the 'Encounter' table.
#' #' Additionally, it identifies and processes references to other resources, preparing a separate table description
#' #' for each referenced resource. The function ensures the inclusion of essential columns ('id', 'subject/reference',
#' #' 'period/start', 'period/end') in the 'Encounter' table and incorporates unique xpaths for referenced resources
#' #' into their respective tables.
#' #'
#' #' @param filter_patterns A list of filter patterns, where each pattern is a list of conditions.
#' #'   Each condition is expected to have named elements representing potential column names for the 'Encounter' table.
#' #'   Conditions may also include references to other FHIR resources, indicated by a colon (":").
#' #'
#' #' @return A list of FHIR table descriptions. The list contains a table description for the 'Encounter' resource,
#' #'   including additional essential columns, and separate table descriptions for each referenced resource.
#' #'   Each table description includes unique column names (or xpaths for referenced resources) relevant to the resource.
#' #'
#' #' @examples
#' #' filter_patterns <- list(
#' #'   `Station 1` = list(
#' #'     Condition_1 = list(
#' #'       `serviceType/coding/code` = "1600",
#' #'       `class/code` = "station|IMP|inpatient|emer|ACUTE|NONAC"
#' #'     ),
#' #'     Condition_2 = list(
#' #'       `location/location/reference:Location/name` = "Relevante Station 1"
#' #'     ),
#' #'     Condition_3 = list(
#' #'       `subject/reference:Patient/name/given` = "^Max"
#' #'     )
#' #'   ),
#' #'   `Station 2` = list(
#' #'     Condition_1 = list(
#' #'       `serviceType/coding/code` = "1600",
#' #'       `class/code` = "station|IMP|inpatient|emer|ACUTE|NONAC"
#' #'     ),
#' #'     Condition_2 = list(
#' #'       `serviceType/coding/display` = "Unfallchirurgie",
#' #'       `class/code` = "station|IMP|inpatient|emer|ACUTE|NONAC"
#' #'     )
#' #'   )
#' #' )
#' #' table_descriptions <- getTableDescriptionsColumnsFromFilterPatterns(filter_patterns)
#' #' print(table_descriptions)
#' #'
#' #' @export
#' getTableDescriptionsColumnsFromFilterPatterns <- function(filter_patterns) {
#'   encounter_cols <- c()
#'
#'   for (ward_conditions in filter_patterns) {
#'     for (condition in ward_conditions) {
#'       encounter_cols <- c(encounter_cols, names(condition))
#'     }
#'   }
#'   # additional columns to be included in every FHIR table description idependently from the user defined columns
#'   encounter_cols <- c(encounter_cols, c('id', 'subject/reference', 'period/start', 'period/end'))
#'   encounter_cols <- sort(unique(encounter_cols))
#'
#'   references <- c()
#'   # Extract the other tables from references. A line with a reference is structured like this:
#'   # location/location/reference:Location/name
#'   # So we cut the line for the Encounter at the colon and collect the parts after the colon
#'   # to create the table description for the referenced resouces
#'
#'   for (i in seq_along(encounter_cols)) {
#'     # get the part after the colon
#'     reference <- trimws(ifelse(grepl(":", encounter_cols[i]), sub(".*:", "", encounter_cols[i]), ""))
#'     if (nchar(reference)) {
#'       encounter_cols[i] <- trimws(substr(encounter_cols[i], 1, nchar(encounter_cols[i]) - nchar(reference) - 1))
#'       references <- c(references, reference)
#'     }
#'   }
#'
#'   # Unique again, because after the remove of references there can be duplicates in encounter_cols again
#'   encounter_cols <- sort(unique(encounter_cols))
#'
#'   # Add the table description for the Encounters as first to the return list
#'   fhir_table_descriptions <- list(
#'     Encounter = fhircrackr::fhir_table_description(
#'       resource = 'Encounter',
#'       cols = encounter_cols,
#'       sep = SEP,
#'       brackets = NULL
#'     )
#'   )
#'
#'   references_with_xpaths <- extractUniqueXpaths(references)
#'   for (i in seq_along(references_with_xpaths)) {
#'     resource_name <- names(references_with_xpaths)[i]
#'     fhir_table_descriptions[[resource_name]] <- fhircrackr::fhir_table_description(
#'       resource = resource_name,
#'       cols = references_with_xpaths[[i]],
#'       sep = SEP,
#'       brackets = NULL
#'     )
#'   }
#'
#'   return(fhir_table_descriptions)
#' }
#'
#' #' Filters the given resources table by the given filter patterns.
#' #'
#' #' This function filters a resources table based on the provided filter patterns.
#' #'
#' #' @param resources A data.table representing the resources table to be filtered.
#' #' @param filter_patterns A list of filter conditions. Each condition is a character string containing multiple
#' #' subconditions separated by '+'.
#' #'
#' #' @return A filtered data.table based on the given filter patterns.
#' #'
#' #' @details
#' #' This function applies an OR operation across the filter patterns, meaning that a row will be retained if at
#' #' least one condition is fulfilled.
#' #' However, within each individual condition (subconditions separated by '+'), an AND operation is applied,
#' #' requiring all subconditions to be met for the condition to be satisfied.
#' #'
#' filterResources <- function(resources, filter_patterns) {
#'
#'   # first list are the elements to filter
#'   resources_to_filter <- resources[[1]]
#'
#'   # Temporarily stores which columns should be kept (initialized with FALSE, meaning all columns should be removed)
#'   resources_to_filter[, Filter_Column_Keep := FALSE]
#'
#'   # Check if a row fulfills a given condition
#'   #
#'   # This function checks if a row meets a given condition based on grep patterns for each column.
#'   #
#'   # @param row A row (list or data.frame) to be checked against the condition.
#'   # @param condition A list where each element is a grep pattern, and the name corresponds to the column in the row.
#'   # @return TRUE if the row fulfills the condition, FALSE otherwise.
#'   #
#'   fulfills_condition <- function(row, condition) {
#'     subConditionColumns <- names(condition)
#'     for (i in 1:length(condition)) { # i <- 1
#'       subConditionColumn <- subConditionColumns[[i]]
#'       subCondition <- condition[[i]]
#'       if (grepl("/reference:", subConditionColumn)) {
#'         # test strings
#'         # strings <- "subject/reference:Patient[name/family"
#'         # get all after first "/reference:": "subject/reference:Patient/name/family" -> "Patient/name/family"
#'         reference <- sub("^.*/reference:", "", strings)
#'         # get all before the first slash "Patient/name/family" -> "Patient"
#'         referenced_resource <- sub("/.*", "", reference)
#'         referenced_resource_path <- sub("^[^/]*/", "", reference)
#'       }
#'       if (!grepl(subCondition, row[[subConditionColumn]], ignore.case = TRUE, perl = TRUE)) {
#'         return(FALSE)
#'       }
#'     }
#'     return(TRUE)
#'   }
#'
#'   # filterPatterns can have a list of conditions in this style:
#'   # "type/coding/code = 'Abteilungskontakt' + serviceType/coding/code = '0100|0500' + class/code = 'station|IMP|inpatient|emer|ACUTE|NONAC'"
#'   # Such a condition means that 3 subconditions must be fulfilled (separated by '+').
#'   for (condition in filter_patterns) { # condition <- filter_patterns[[1]]
#'     resources_to_filter[, Filter_Column_Keep_Subcondition := FALSE]
#'     for (i in seq_len(nrow(resources_to_filter))) {
#'       resources_to_filter[i, Filter_Column_Keep := resources_to_filter[i, Filter_Column_Keep] || fulfills_condition(resources_to_filter[i], condition)]
#'     }
#'   }
#'
#'   resources_to_filter[, Filter_Column_Keep_Subcondition := NULL]
#'   filtered_resources <- resources_to_filter[Filter_Column_Keep == TRUE]
#'   filtered_resources[, Filter_Column_Keep := NULL]
#'   resources_to_filter[, Filter_Column_Keep := NULL]
#'   return(filtered_resources)
#' }
#'
#' #' Parse and interpolate patient IDs from a file.
#' #'
#' #' This function reads patient IDs from a file specified by the provided path.
#' #' The patient IDs are then returned as a unique, sorted list.
#' #'
#' #' @param path_to_PID_list_file The path to the file containing patient IDs.
#' #'
#' #' @return A unique, sorted list of patient IDs.
#' #'
#' parsePatientIDsPerWardFromFile <- function(path_to_PID_list_file) {
#'   pids_per_ward <- list()
#'   lines <- readLines(path_to_PID_list_file)
#'   single_ward_pids <- list()
#'   ward_name <- NA
#'   for (line in lines) {
#'     line <- trimws(sub("#.*$", "", line)) # remove comments (starts with '#')
#'     if (nchar(line)) {
#'       if (startsWith(line, 'ward_name')) {
#'         if (!is.na(ward_name)) {
#'           pids_per_ward[[ward_name]] <- etlutils::sortListByValue(unique(single_ward_pids))
#'           single_ward_pids <- list()
#'         }
#'         ward_name <- etlutils::getBetweenQuotes(line)
#'       } else {
#'         single_ward_pids[[length(single_ward_pids) + 1]] <- line
#'       }
#'     }
#'   }
#'   if (!is.na(ward_name)) {
#'     pids_per_ward[[ward_name]] <- etlutils::sortListByValue(unique(single_ward_pids))
#'   }
#'   return(pids_per_ward)
#' }
#'
#' #' Get unique patient IDs per ward based on filter patterns.
#' #'
#' #' This function takes a list of encounters and a corresponding list of filter patterns for each ward.
#' #' It filters the encounters for each ward based on the provided filter patterns and extracts unique
#' #' patient IDs ('subject/reference'). The result is a list where each element corresponds to a ward,
#' #' and the values are unique patient IDs for that ward.
#' #'
#' #' @param resources A list of list with encounters to filter and the referenced resources.
#' #' @param all_wards_filter_patterns A list of filter patterns, where each element corresponds to a ward.
#' #'
#' #' @return A list where each element corresponds to a ward, and the values are unique patient IDs for that ward.
#' #'   The list is structured such that each outer list represents a ward, and the inner lists contain
#' #'   unique patient IDs for that ward.
#' #'
#' filterPIDsPerWard <- function(resources, all_wards_filter_patterns) {
#'   pids_per_ward <- list()
#'   for (i in seq_along(all_wards_filter_patterns)) {
#'     ward_filter_patterns <- all_wards_filter_patterns[[i]]
#'     ward_encounters <- filterResources(resources, ward_filter_patterns)
#'     polar_write_rdata(ward_encounters, 'pid_source_encounter_filtered')
#'     pids_per_ward[[names(all_wards_filter_patterns)[i]]] <- unique(sort(ward_encounters$'subject/reference')) # PID is always in 'subject/reference'
#'   }
#'   return(pids_per_ward)
#' }
#'
#' #' Extracts the relevant patient IDs from download Encounter resources. If the file name parameter is NA then
#' #' the relevant patient IDs are extracted by Encounters downloaded from the FHIR server. If the file name
#' #' parameter is not NA then the patient IDs are loaded from the specified file (one PID per line).
#' #'
#' #' @param path_to_PID_list_file file name if the list of patient IDs should be loaded from a file (if not then NA)
#' #'
#' #' @return the relevant patient IDs per ward
#' #'
#' getPatientIDsPerWard <- function(path_to_PID_list_file = NA) {
#'
#'   pids_per_ward <- list()
#'
#'   etlutils::run_in_in(paste('Get Patient IDs by file', path_to_PID_list_file), {
#'     if (!is.na(path_to_PID_list_file)) {
#'       return(parsePatientIDsPerWardFromFile(path_to_PID_list_file))
#'     }
#'   })
#'
#'   etlutils::run_in_in('Get Patient IDs by Encounters from FHIR Server', {
#'     initEncounterPeriodToDownload()
#'     filter_patterns <- convertFilterPatterns()
#'     # the subject reference is needed in every case to extract them if the encounter matches the pattern
#'     # the period end is needed to check if the Encounter is still finsihed
#'     # maybe some other columns (state or something like this) could be importent, so we had to add them here in future
#'     encounter_filter_table_descriptions <- getTableDescriptionsColumnsFromFilterPatterns(filter_patterns)
#'
#'     # download the Encounters and crack them in a table with the columns of the xpaths in filter patterns + the
#'     # additional paths above
#'     resources <<- list(
#'       Encounter = etlutils::get_encounters(encounter_filter_table_descriptions$Encounter)
#'     )
#'     # the fhircrackr does not accept same column names and xpath expessions but we need the xpath expressions as column
#'     # names for the filtering -> set them here
#'     names(resources$Encounter) <- encounter_filter_table_descriptions$Encounter@cols@.Data
#'
#'     for (i in seq_along(encounter_filter_table_descriptions)) {
#'       table_description <- encounter_filter_table_descriptions[[i]]
#'       resource <- names(encounter_filter_table_descriptions)[i]
#'       if (resource != 'Encounter') {
#'
#'         getEncounterColumnsWithResourceIDs <- function(resource, filter_patterns) {
#'           resource_id_columns <- c()
#'           for (filter_pattern in filter_patterns) {
#'             for (conditions in filter_pattern) {
#'               for (c in seq_along(conditions)) {
#'                 condition_column <- names(conditions)[c]
#'                 if (grepl(paste0('/reference:', resource, '/'), condition_column)) {
#'                   resource_id_columns <- c(resource_id_columns, sub("^(.*?):.*$", "\\1", condition_column))
#'                 }
#'               }
#'             }
#'           }
#'           return(resource_id_columns)
#'         }
#'
#'         getResourceIDsToLoad <- function(encounter_table, resource_id_columns) {
#'           resource_ids <- c()
#'           for (column_name in resource_id_columns) {
#'             resource_ids <- c(resource_ids, encounter_table[[column_name]])
#'           }
#'           resource_ids <- unique(sort(resource_ids))
#'           resource_ids <- etlutils::getAfterLastSlash(resource_ids)
#'           return(resource_ids)
#'         }
#'
#'         encounter_columns_with_ids <- getEncounterColumnsWithResourceIDs(resource, filter_patterns)
#'
#'         resource_ids_to_load <- getResourceIDsToLoad(resources$Encounter, encounter_columns_with_ids)
#'
#'         table_description <<- table_description
#'         resources[[resource]] <- etlutils::polar_download_by_ids_and_crack_parallel(
#'           resource = resource,
#'           ids = resource_ids_to_load,
#'           table_description = encounter_filter_table_descriptions[[resource]],
#'           id_param_str = '_id'
#'         )
#'       }
#'     }
#'
#'     # now filter the encounters with the patterns and then extract the PIDs
#'     pidsPerWard <- filterPIDsPerWard(resources, filter_patterns)
#'     return(pidsPerWard)
#'   })
#'
#' }
