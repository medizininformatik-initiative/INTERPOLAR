#' Convert configured cohort filter patterns by resource
#'
#' Converts configured cohort filter patterns into the resource-scoped internal
#' representation needed for generic PID selection. Each condition list contains
#' AND-connected subconditions; multiple condition lists per resource are
#' OR-connected.
#'
#' @param filter_patterns_global_variable_name_prefix Optional prefix for test or
#'   compatibility callers. If `NULL`, the configured cohort or legacy encounter
#'   filter family is selected automatically.
#'
#' @return A named list of converted filter conditions by cohort and resource.
convertCohortFilterPatterns <- function(filter_patterns_global_variable_name_prefix = NULL) {
  if (is.null(filter_patterns_global_variable_name_prefix)) {
    configured_filter_patterns <- getConfiguredCohortFilterPatterns()
    cohort_filter_patterns <- configured_filter_patterns$definitions
    source_prefix <- configured_filter_patterns$source_prefix
    legacy_patterns <- configured_filter_patterns$legacy
  } else {
    cohort_filter_patterns <- etlutils::getGlobalVariablesByPrefix(filter_patterns_global_variable_name_prefix)
    source_prefix <- filter_patterns_global_variable_name_prefix
    legacy_patterns <- grepl("ENCOUNTER_FILTER_PATTERN", filter_patterns_global_variable_name_prefix, fixed = TRUE)
    if (legacy_patterns) {
      cohort_filter_patterns <- normalizeLegacyEncounterFilterPatterns(cohort_filter_patterns)
    }
  }

  if (!length(cohort_filter_patterns)) {
    stop("No cohort filter patterns found with prefix ", source_prefix, " in toml file")
  }

  parsed_filter_patterns <- etlutils::parseStructuredConfigDefinitions(
    definitions = cohort_filter_patterns,
    allowed_key_pattern = "cohort_name|resource|[A-Za-z/]+",
    allow_plus = TRUE
  )

  getConditionLineID <- function(filter_pattern) {
    paste(filter_pattern$entry_name, filter_pattern$line_index, sep = "\r")
  }

  converted_filter_patterns <- list()
  definition_names <- unique(vapply(parsed_filter_patterns, `[[`, "", "definition_name"))

  for (definition_name in definition_names) {
    definition_filter_patterns <- parsed_filter_patterns[
      vapply(parsed_filter_patterns, `[[`, "", "definition_name") == definition_name
    ]

    cohort_name <- definition_filter_patterns[[which(
      vapply(definition_filter_patterns, `[[`, "", "key") == "cohort_name"
    )[1]]]$value
    converted_filter_patterns[[cohort_name]] <- list()
    condition_line_ids <- unique(vapply(definition_filter_patterns, getConditionLineID, ""))

    for (condition_line_id in condition_line_ids) {
      line_filter_patterns <- definition_filter_patterns[
        vapply(definition_filter_patterns, getConditionLineID, "") == condition_line_id
      ]

      line_keys <- vapply(line_filter_patterns, `[[`, "", "key")
      if (identical(line_keys, "cohort_name")) {
        next
      }

      resource_filter_pattern <- line_filter_patterns[line_keys == "resource"]
      if (length(resource_filter_pattern) == 1L) {
        resource_name <- resource_filter_pattern[[1]]$value
      } else if (legacy_patterns) {
        resource_name <- "Encounter"
      } else {
        stop(
          "Condition line in ",
          line_filter_patterns[[1]]$definition_name,
          " / ",
          line_filter_patterns[[1]]$entry_name,
          " / line ",
          line_filter_patterns[[1]]$line_index,
          " must contain exactly one resource.",
          call. = FALSE
        )
      }

      and_conditions <- list()
      for (filter_pattern in line_filter_patterns) {
        if (filter_pattern$key == "resource") {
          next
        }
        and_conditions[[filter_pattern$key]] <- filter_pattern$value
      }

      if (is.null(converted_filter_patterns[[cohort_name]][[resource_name]])) {
        converted_filter_patterns[[cohort_name]][[resource_name]] <- list()
      }
      resource_condition_index <- length(converted_filter_patterns[[cohort_name]][[resource_name]]) + 1L
      converted_filter_patterns[[cohort_name]][[resource_name]][[paste0("Condition_", resource_condition_index)]] <- and_conditions
    }
  }

  converted_filter_patterns
}

#' Convert configured cohort filter patterns into Encounter filter conditions
#'
#' Converts configured cohort filter patterns into the internal representation
#' used by the existing Encounter PID selection. Each condition list contains
#' AND-connected subconditions; multiple condition lists are OR-connected.
#'
#' @param filter_patterns_global_variable_name_prefix Optional prefix for test or
#'   compatibility callers. If `NULL`, the configured cohort or legacy encounter
#'   filter family is selected automatically.
#'
#' @return A named list of converted Encounter filter conditions per cohort.
convertFilterPatterns <- function(filter_patterns_global_variable_name_prefix = NULL) {
  cohort_filter_patterns <- convertCohortFilterPatterns(filter_patterns_global_variable_name_prefix)
  encounter_filter_patterns <- list()

  for (cohort_name in names(cohort_filter_patterns)) {
    cohort_resources <- cohort_filter_patterns[[cohort_name]]
    unsupported_resources <- setdiff(names(cohort_resources), "Encounter")

    if (length(unsupported_resources)) {
      stop(
        "Only Encounter cohort filter resources are supported in the current PID selection implementation, but found ",
        paste(unsupported_resources, collapse = ", "),
        ".",
        call. = FALSE
      )
    }

    encounter_filter_patterns[[cohort_name]] <- if ("Encounter" %in% names(cohort_resources)) {
      cohort_resources[["Encounter"]]
    } else {
      list()
    }
  }

  encounter_filter_patterns
}

#' Get FHIR expression names from converted filter patterns
#'
#' Collects the FHIR expression names used as filter keys in a converted filter
#' pattern list.
#'
#' @param filter_patterns Converted filter pattern conditions.
#' @param ... Additional FHIR expressions to include.
#'
#' @return A sorted character vector of unique FHIR expressions.
getFilterPatternFHIRExpressions <- function(filter_patterns, ...) {
  cols_vector <- c()
  for (cohort_conditions in filter_patterns) {
    for (condition in cohort_conditions) {
      cols_vector <- c(cols_vector, names(condition))
    }
  }
  cols_vector <- c(cols_vector, ...)
  sort(unique(cols_vector))
}

#' Get PID FHIR expression candidates for a cohort filter resource
#'
#' Determines the FHIR expressions that may contain patient IDs or references in
#' a resource used in cohort filtering.
#'
#' @param resource_name FHIR resource type.
#'
#' @return FHIR expression candidates containing patient IDs/references.
getCohortFilterPIDExpressions <- function(resource_name) {
  c("subject/reference", "patient/reference")
}

#' Get FHIR table description for one cohort filter resource
#'
#' Builds a minimal `fhircrackr::fhir_table_description()` for cohort PID
#' filtering of one resource.
#'
#' @param resource_name FHIR resource type.
#' @param filter_patterns Converted filter conditions for one resource.
#' @param table_description_table Table Description rows with `RESOURCE` and
#'   `FHIR_EXPRESSION`.
#'
#' @return A `fhircrackr::fhir_table_description()` object.
getCohortFilterTableDescription <- function(
  resource_name,
  filter_patterns,
  table_description_table = getTableDescriptionsTable(c("RESOURCE", "FHIR_EXPRESSION"))
) {
  pid_expressions <- getCohortFilterPIDExpressions(resource_name)
  cols_vector <- getFilterPatternFHIRExpressions(filter_patterns, "id", pid_expressions)

  fhircrackr::fhir_table_description(
    resource = resource_name,
    cols = cols_vector,
    sep = SEP,
    brackets = NULL
  )
}

#' Get FHIR table descriptions for cohort filter resources
#'
#' Builds minimal table descriptions for all resources used in converted cohort
#' filter patterns.
#'
#' @param cohort_filter_patterns Converted cohort filter patterns grouped by
#'   cohort and resource.
#' @param table_description_table Table Description rows with `RESOURCE` and
#'   `FHIR_EXPRESSION`.
#'
#' @return A named list of `fhircrackr::fhir_table_description()` objects.
getCohortFilterTableDescriptions <- function(
  cohort_filter_patterns,
  table_description_table = getTableDescriptionsTable(c("RESOURCE", "FHIR_EXPRESSION"))
) {
  resource_names <- unique(unlist(lapply(cohort_filter_patterns, names), use.names = FALSE))
  table_descriptions <- list()

  for (resource_name in resource_names) {
    resource_filter_patterns <- lapply(cohort_filter_patterns, function(cohort_resources) {
      resource_conditions <- cohort_resources[[resource_name]]
      if (is.null(resource_conditions)) {
        return(list())
      }
      resource_conditions
    })
    table_descriptions[[resource_name]] <- getCohortFilterTableDescription(
      resource_name,
      resource_filter_patterns,
      table_description_table
    )
  }

  table_descriptions
}

#' Get FHIR table description based on filter patterns.
#'
#' This function takes a list of filter patterns and extracts unique column names
#' from them to create a FHIR table description for the 'Encounter' resource.
#'
#' @param filter_patterns A list of filter patterns, where each pattern is a list of conditions.
#'   Each condition is expected to have named elements representing column names.
#' @param ... Additional columns to be included in the FHIR table description.
#'
#' @return A FHIR table description object for the 'Encounter' resource with columns based
#'   on the unique names extracted from the filter patterns, including additional columns.
#'
getTableDescriptionColumnsFromFilterPatterns <- function(filter_patterns, ...) {
  cols_vector <- getFilterPatternFHIRExpressions(filter_patterns, ...)
  fhir_table_desc <- fhircrackr::fhir_table_description(
    resource = "Encounter",
    cols = cols_vector,
    sep = SEP,
    brackets = NULL
  )
}

#' Extract patient IDs from cohort filter resource tables
#'
#' Applies converted cohort filter patterns to already cracked FHIR resource
#' tables and extracts matching patient IDs per cohort.
#'
#' @param resource_tables Named list of cracked FHIR resource tables keyed by
#'   resource type.
#' @param cohort_filter_patterns Converted cohort filter patterns grouped by
#'   cohort and resource.
#' @param table_description_table Table Description rows with `RESOURCE` and
#'   `FHIR_EXPRESSION`.
#'
#' @return A named list of data.tables with `patient_id`,
#'   `source_resource_type`, `source_resource_id`, and optional `encounter_id`.
extractPIDsSplittedByCohortFromResourceTables <- function(
  resource_tables,
  cohort_filter_patterns
) {
  addCohortPatientIDColumn <- function(resource_table, resource_name) {
    if (!("id" %in% names(resource_table))) {
      stop("Cohort filter resource table for ", resource_name, " is missing required column(s): id.", call. = FALSE)
    }

    if (tolower(resource_name) == "patient") {
      resource_table[, patient_id := id]
      return(resource_table)
    }

    if (!("subject/reference" %in% names(resource_table))) {
      resource_table[, "subject/reference" := NA_character_]
    }
    if (!("patient/reference" %in% names(resource_table))) {
      resource_table[, "patient/reference" := NA_character_]
    }

    subject_reference <- resource_table[["subject/reference"]]
    patient_reference <- resource_table[["patient/reference"]]
    resource_table[, patient_id := ifelse(!is.na(subject_reference) & nzchar(subject_reference), subject_reference, patient_reference)]
    resource_table[, patient_id := etlutils::getAfterLastSlash(patient_id)]

    return(resource_table)
  }

  pids_splitted_by_cohort <- list()
  empty_cohort_table <- data.table::data.table(
    patient_id = character(),
    source_resource_type = character(),
    source_resource_id = character(),
    encounter_id = character()
  )

  for (cohort_name in names(cohort_filter_patterns)) {
    cohort_pids <- empty_cohort_table

    for (resource_name in names(cohort_filter_patterns[[cohort_name]])) {
      if (is.null(resource_tables[[resource_name]])) {
        next
      }

      resource_table <- data.table::as.data.table(data.table::copy(resource_tables[[resource_name]]))
      resource_table <- addCohortPatientIDColumn(resource_table, resource_name)
      resource_filter_patterns <- cohort_filter_patterns[[cohort_name]][[resource_name]]
      filtered_resources <- etlutils::filterResources(resource_table, resource_filter_patterns)

      if (!nrow(filtered_resources)) {
        next
      }

      resources_without_patient_id <- filtered_resources[is.na(patient_id) | !nzchar(patient_id)]
      if (nrow(resources_without_patient_id)) {
        etlutils::catWarningMessage(paste0(
          "Ignoring ",
          nrow(resources_without_patient_id),
          " matched ",
          resource_name,
          " cohort filter resource(s) without subject/reference or patient/reference."
        ))
        filtered_resources <- filtered_resources[!is.na(patient_id) & nzchar(patient_id)]
      }
      if (!nrow(filtered_resources)) {
        next
      }

      cohort_resource_pids <- data.table::data.table(
        patient_id = filtered_resources[["patient_id"]],
        source_resource_type = resource_name,
        source_resource_id = filtered_resources[["id"]]
      )
      if (tolower(resource_name) == "encounter") {
        cohort_resource_pids[, encounter_id := source_resource_id]
      }

      cohort_pids <- data.table::rbindlist(
        list(cohort_pids, cohort_resource_pids),
        use.names = TRUE,
        fill = TRUE
      )
    }

    cohort_pids <- unique(cohort_pids[order(patient_id, source_resource_type, source_resource_id)])
    if (etlutils::isDefinedAndNotEmpty("DEBUG_FILTER_PIDS_PATTERN")) {
      cohort_pids <- cohort_pids[grepl(DEBUG_FILTER_PIDS_PATTERN, patient_id)]
    }
    pids_splitted_by_cohort[[cohort_name]] <- cohort_pids
  }

  return(pids_splitted_by_cohort)
}

#' Extract Patient IDs (PIDs) and Encounter IDs per Ward
#'
#' This function filters encounter data based on ward-specific patterns and extracts
#' a data.table containing unique PIDs and corresponding encounter IDs for each ward.
#'
#' @param encounters A data.frame or data.table containing encounter data.
#' @param all_wards_filter_patterns A named list of filtering patterns for different wards.
#'
#' @return A named list where each element is a data.table with `pid` and `encounter_id` for a specific ward.
#'
extractPIDsSplittedByWard <- function(encounters, all_wards_filter_patterns) {

  pids_splitted_by_ward <- list()

  for (i in seq_along(all_wards_filter_patterns)) {
    ward_filter_patterns <- all_wards_filter_patterns[[i]]

    # Filter encounters based on ward-specific patterns
    ward_encounters <- etlutils::filterResources(encounters, ward_filter_patterns)

    # Save filtered encounters
    etlutils::writeDebugExcelFile(ward_encounters, paste0("pid_source_encounter_filtered_", i))

    # Create a data.table with PID and Encounter ID
    dt <- data.table::data.table(
      patient_id = ward_encounters$`subject/reference`,
      encounter_id = ward_encounters$id
    )

    # Remove duplicates and sort by PID
    dt <- unique(dt[order(patient_id)])

    # Assign the ward name as the list key
    ward_name <- names(all_wards_filter_patterns)[i]
    pids_splitted_by_ward[[ward_name]] <- dt
  }

  # If DEBUG_FILTER_PIDS_PATTERN exists, filter PIDs based on the pattern
  if (exists("DEBUG_FILTER_PIDS_PATTERN", envir = .GlobalEnv)) {
    for (ward in names(pids_splitted_by_ward)) {
      pids_splitted_by_ward[[ward]] <- pids_splitted_by_ward[[ward]][grepl(DEBUG_FILTER_PIDS_PATTERN, patient_id)]
    }
  }

  return(pids_splitted_by_ward)
}

#' Download and preprocess encounter data from FHIR server
#'
#' This function retrieves encounter data from a FHIR server, applies various filters,
#' and performs data processing tasks.
#'
#' @param table_description the fhir crackr table description with the columns definition
#' of the returned table.
#' @param current_datetime the current datetime or debug datetime
#'
#' @details
#' The function handles the download of encounter data, filtering based on date ranges,
#' and additional processing steps such as fixing dates, adding columns, and handling
#' exclusion criteria.
#'
#' @return
#' The processed encounter data is saved, and relevant tables are returned and/or
#' saved as RData files.
#'
getEncounters <- function(table_description, current_datetime) {

  runLevel3("Get Enconters", {
    # Refresh token, if defined
    etlutils::fhirsearchRefreshToken()

    resource <- "Encounter"

    runLevel3("Download and Crack Encounters", {
      # current_date_time contains the NA value with the name period_start_is_set_by_param
      # if the start date is not Sys.time() but explicitly set by a toml parameter like
      # DEBUG_ENCOUNTER_STARTS_AFTER or DATA_IMPORT_RANGE_START
      if ("period_start_is_set_by_param" %in% names(current_datetime)) {
        encounter_dates <- c("date" = paste0("sa", current_datetime[["period_start"]]))
        if ("period_end" %in% names(current_datetime)) {
          encounter_dates <- c(encounter_dates, "date" = paste0("le", current_datetime[["period_end"]]))
        }
      } else if (!exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS") || !grepl("&date=", FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS, fixed = TRUE)) {
        encounter_dates <- c("date" = paste0("lt", current_datetime))
      } else if (exists("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS") && grepl("&date=", FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS, fixed = TRUE)) {
        # Extract all date parameters from FHIR search string
        date_values <- unlist(
          regmatches(
            FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS,
            gregexpr("(?<=&date=)[^&]+", FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS, perl = TRUE)
          )
        )
        # Build named vector (multiple date params allowed)
        encounter_dates <- setNames(date_values, rep("date", length(date_values)))
        # Remove all &date=... parameters from FHIR search string
        FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS <- gsub("&date=[^&]+", "", FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS)
      }

      # default encounter status "in-progress" can be replaced in the toml file  by the
      # parameter FHIR_SEARCH_ENCOUNTER_STATUS. If it is given as vector then the values
      # will be comma separated pasted together.
      if (exists("FHIR_SEARCH_ENCOUNTER_STATUS")) {
        if (!nchar(trimws(FHIR_SEARCH_ENCOUNTER_STATUS))) { # Intentionally empty status
          encounter_status <- NA_character_
        } else {
          encounter_status <- paste(FHIR_SEARCH_ENCOUNTER_STATUS, collapse = ",")
        }
      } else { # Default is "in-progress"
        encounter_status <- "in-progress"
      }

      if (isProcess("DataImport")) {
        if (!grepl("finished", encounter_status)) {
          if (is.na(encounter_status) || !nzchar(encounter_status)) {
            encounter_status <- "finished"
          } else {
            encounter_status <- paste0(encounter_status, ",finished")
          }
        }
      }

      # same as the status with the parameter FHIR_SEARCH_ENCOUNTER_CLASS for the FHIR search
      # parameter 'class'
      encounter_class <- NA
      if (exists("FHIR_SEARCH_ENCOUNTER_CLASS")) {
        encounter_class <- paste(FHIR_SEARCH_ENCOUNTER_CLASS, collapse = ",")
      }

      # filtering for the IDs of referenced Locations in the Encounters
      encounter_locations <- NA
      if (exists("FHIR_SEARCH_ENCOUNTER_LOCATION_IDS")) {
        encounter_locations <- paste(FHIR_SEARCH_ENCOUNTER_LOCATION_IDS, collapse = ",")
      }

      parameters <- c(
        encounter_dates,
        "status" = encounter_status,
        "class" = encounter_class,
        "location" = encounter_locations
      )

      selected_encounter_pids <- NULL
      if (etlutils::isDefinedAndNotEmpty("DEBUG_ENCOUNTER_ACCEPTED_PIDS")) {
        selected_encounter_pids <- DEBUG_ENCOUNTER_ACCEPTED_PIDS
      } else if (etlutils::isSubProcess("DataImport.All") && etlutils::isDefinedAndNotEmpty("DATA_IMPORT_FHIR_PIDS")) {
        selected_encounter_pids <- DATA_IMPORT_FHIR_PIDS
      }

      if (!is.null(selected_encounter_pids)) {
        selected_encounter_pids <- ifelse(
          grepl("/", selected_encounter_pids),
          selected_encounter_pids,
          paste0("Patient/", selected_encounter_pids)
        )
        selected_encounter_pids <- paste(selected_encounter_pids, collapse = ",")
        parameters <- c(parameters, "subject" = selected_encounter_pids)
      }

      parameters <- etlutils::fhirsearchAddGlobalParams(parameters)

      request_encounter <- fhircrackr::fhir_url(
        url        = FHIR_SERVER_ENDPOINT,
        resource   = "Encounter",
        parameters = parameters
      )

      if (etlutils::isDefinedAndNotEmpty("FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS")) {
        request_encounter <- paste0(request_encounter, FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS)
      }

      # stop the execution and print the current result of FHIR search request (DEBUG)
      etlutils::checkDebugTestError("FHIR_SEARCH_ENCOUNTER_REQUEST_TEST", request_encounter)

      table_enc <- etlutils::fhirsearchDownloadAndCrackResources(
        request = request_encounter,
        table_description = table_description,
        max_bundles = MAX_ENCOUNTER_BUNDLES,
        log_errors  = "enc_error.xml"
      )

      if (etlutils::isSimpleNA(table_enc) || !nrow(table_enc)) {
        stop(
          "The FHIR request did not return any available Encounter bundles.\nRequest: ",
          etlutils::formatStringStyle(request_encounter[[1]], fg = 2, underline = TRUE)
        )
      }

    })

    runLevel3Line("Validate encounter subject reference", {
      invalid_encounters <- table_enc[is.na(subject.reference)]
      table_enc <- table_enc[!is.na(subject.reference)]
      if (!nrow(table_enc)) {
        stop(
          "No valid Encounter found. All found encounters have no valid subject reference.\n",
          "Request: ", etlutils::formatStringStyle(
            request_encounter[[1]],
            fg = 2, underline = TRUE
          ), "\n",
          "Encounters: ", paste0(invalid_encounters$id, collapse = ", "), "\n"
        )
      } else if (nrow(invalid_encounters)) {
        etlutils::catWarningMessage(paste0(
          "The following encounters have no valid subject reference:\n",
          paste0(invalid_encounters$id, collapse = ", ")
        ), "\n")
      }
    })

    runLevel3Line("Change column classes", {
      table_enc <- table_enc[, lapply(.SD, as.character), ]
    })

    etlutils::printAllTables(table_enc)
    etlutils::writeDebugExcelFile(table_enc, "pid_source_encounter_unfiltered", runLevel3Message = "Save Encounters Table as local Excel files")
  })

  return(table_enc)
}

#' Extracts the relevant patient IDs from downloaded Encounter resources.
#'
#' @param create_single_pids_per_ward If TRUE then ... else ...
#' @param wards_min_encounter_start_date a map from a ward name to the minimum encounter start date of encounters which
#' should be considered for the assignment of patients to this ward. If NULL then no filtering by encounter start date is applied.
#' @param log_result logical indicating that the result of the functions should be logged via cat. Default is TRUE.
#'
#' @return the relevant patient IDs per ward
#'
getPIDsSplittedByWard <- function(create_single_pids_per_ward, wards_min_encounter_start_date = NULL, log_result = TRUE) {

  read_pids_from_debug_rdata_files <- exists("DEBUG_PATH_TO_RAW_RDATA_FILES")

  if (read_pids_from_debug_rdata_files) {
    etlutils::runLevel3(paste("Get Patient IDs from debug RData files in ", DEBUG_PATH_TO_RAW_RDATA_FILES), {
      file_data <- loadDebugInitialPatientsAndEncountersFromRDataFiles(DEBUG_PATH_TO_RAW_RDATA_FILES)
      pids_splitted_by_ward <- split(file_data$pids_per_ward[, !("ward_name"), with = FALSE], file_data$pids_per_ward$ward_name)
      encounters <- file_data$initial_encounters
    })
  } else {
    etlutils::runLevel3("Get Patient IDs by Encounters from FHIR Server", {
      etlutils::runLevel3("Load Encounters", {
        filter_patterns <- convertFilterPatterns()
        # the subject reference is needed in every case to extract them if the encounter matches the pattern
        # the period end is needed to check if the Encounter is still finished
        # maybe some other columns (state or something like this) could be important, so we had to add them here in future
        filter_enc_table_description <- getTableDescriptionColumnsFromFilterPatterns(
          filter_patterns,
          "id",
          "subject/reference",
          "period/start",
          "period/end",
          "status",
          "meta/lastUpdated"
        )
        # Get current or debug datetime
        current_datetime <- getQueryDatetime()
        # Replace space with 'T' in timestamp for correct time format
        current_datetime <- gsub(" ", "T", current_datetime)
        # Download the Encounters and crack them in a table with the columns of the xpaths in
        # filter patterns + the additional paths above
        encounters <- getEncounters(filter_enc_table_description, current_datetime)
        # the fhircrackr does not accept same column names and xpath expessions but we need the xpath expressions as column
        # names for the filtering -> set them here
        names(encounters) <- filter_enc_table_description@cols@.Data
      })

      etlutils::runLevel3("Check downloaded Encounters have values in filter columns", {
        # Check if any column except the period/end column has only NA values -> generate warning
        cols_to_check <- setdiff(names(encounters), "period/end")
        # find columns with all values NA
        na_columns <- cols_to_check[
          sapply(encounters[, ..cols_to_check], function(col) all(is.na(col)))
        ]
        if (length(na_columns)) {
          warning_message <- paste0(
            "The following columns have only NA values:\n",
            paste(
              na_columns,
              collapse = ", "
            ), "\n",
            "Please check the filter patterns in the toml file.\n",
            "This may indicate that invalid column names are specified in",
            " ENCOUNTER_FILTER_PATTERNS. Wards with such invalid Encounter",
            " column names will never be able to contain patients.\n"
          )
          etlutils::catWarningMessage(warning_message)
        }
      })

      etlutils::runLevel3Line("Split Encounters to wards", {
        # now filter the encounters with the patterns and then extract the PIDs
        pids_splitted_by_ward <- extractPIDsSplittedByWard(encounters, filter_patterns)
      })
    })
  }

  ###
  ### START helper functions ###
  ###

  joinPidsPerWardAndEnconters <- function(pids_per_ward, encounters) {
    # Join encounter info (start + meta) to combined table
    pids_per_ward_with_encounter_details <- merge(
      pids_per_ward,
      encounters[, .(
        encounter_id = id, `period/start`, `meta/lastUpdated`
      )],
      by = "encounter_id",
      all.x = TRUE
    )
    pids_per_ward_with_encounter_details
  }

  removeMultipleEncountersForPid <- function(pids_per_ward_with_encounter_details) {
    dt <- pids_per_ward_with_encounter_details # conveniencename for the used table
    # Step 1: Keep only the encounters with the **latest `period/start`** per patient_id
    dt <- dt[dt[, .I[`period/start` == etlutils::getMaxDatetime(`period/start`)], by = patient_id]$V1]
    # Step 2: If multiple entries per patient_id remain, keep those with latest meta-lastUpdateDate
    dt <- dt[dt[, .I[`meta/lastUpdated` == etlutils::getMaxDatetime(`meta/lastUpdated`)], by = patient_id]$V1]
    # Step 3: If still multiple per patient_id: keep only the first (arbitrary stable choice)
    dt <- dt[dt[, .I[1], by = patient_id]$V1]
    # Step 4: Remove full NA rows
    dt <- na.omit(dt)
    return(dt) # return the filtered pids_per_ward_with_encounter_details
  }

  splitPidsPerWardByWard <- function(pids_per_ward_with_encounter_details) {
    # Re-split into station-wise list
    pids_splitted_by_ward <- split(pids_per_ward_with_encounter_details[, .(patient_id, encounter_id, ward_name)], by = "ward_name")
    # Remove the ward_name column from all subtables
    pids_splitted_by_ward <- lapply(pids_splitted_by_ward, function(dt) dt[, ward_name := NULL])
    return(pids_splitted_by_ward)
  }

  splitPidsPerWardByWardForUniquePidsAndEncounterStart <- function(pids_per_ward_with_encounter_details) {
    # Sort by patient and start time
    data.table::setorder(pids_per_ward_with_encounter_details, `period/start`, patient_id)

    list_of_pids_splitted_by_wards <- list()
    single_pids_per_ward <- pids_per_ward_with_encounter_details[0]

    row_count <- nrow(pids_per_ward_with_encounter_details)

    for (i in seq_len(row_count)) {
      row <- pids_per_ward_with_encounter_details[i]

      # Set to TRUE when the same patient already exists in the current subset
      # with an earlier encounter start.
      contains_row <- single_pids_per_ward[patient_id == row[["patient_id"]] & `period/start` < row[["period/start"]], .N] > 0

      if (contains_row) {
        single_pids_per_ward <- removeMultipleEncountersForPid(single_pids_per_ward)
        single_pids_splitted_by_ward <- splitPidsPerWardByWard(single_pids_per_ward)
        list_of_pids_splitted_by_wards[[length(list_of_pids_splitted_by_wards) + 1]] <- single_pids_splitted_by_ward
        single_pids_per_ward <- pids_per_ward_with_encounter_details[0]
      }

      single_pids_per_ward <- data.table::rbindlist(list(single_pids_per_ward, row), use.names = TRUE)

      if (i == row_count) {
        single_pids_splitted_by_ward <- splitPidsPerWardByWard(single_pids_per_ward)
        list_of_pids_splitted_by_wards[[length(list_of_pids_splitted_by_wards) + 1]] <- single_pids_splitted_by_ward
      }
    }

    return(list_of_pids_splitted_by_wards)
  }

  ###
  ### END helper functions ###
  ###

  etlutils::runLevel3(paste("Generate single pids_per_ward"), {
    # extract ID from references
    for (i in seq_along(pids_splitted_by_ward)) {
      pids_splitted_by_ward[[i]][, patient_id := etlutils::getAfterLastSlash(patient_id)]
    }
    # Combine all patient IDs from the list into a data table with their corresponding stations
    pids_per_ward <- rbindPidsSplittedByWard(pids_splitted_by_ward)
    pids_per_ward_with_encounter_details <- joinPidsPerWardAndEnconters(pids_per_ward, encounters)
  })

  etlutils::runLevel3("Remove all Encounter/Patient IDs which start before the phaseA start of the current ward", {
    if (!is.null(wards_min_encounter_start_date)) {
      for (ward in names(wards_min_encounter_start_date)) {
        min_start_date <- wards_min_encounter_start_date[[ward]]
        pids_per_ward_with_encounter_details <- pids_per_ward_with_encounter_details[!(ward_name == ward & `period/start` < min_start_date)]
      }
    }
  })

  etlutils::runLevel3("Warn if Encounter/Patient ID is assigned more than one ward", {
    # Find patient IDs that appear in multiple different wards
    multi_ward_patients <- unique(pids_per_ward[, .(patient_id, ward_name)])[, .N, by = patient_id][N > 1, patient_id]
    # Keep only rows where patient_id appears in multiple different wards
    duplicates_pids_per_ward <- pids_per_ward[patient_id %in% multi_ward_patients]
    # Stop if duplicates pids are found
    if (nrow(duplicates_pids_per_ward)) {
      if (read_pids_from_debug_rdata_files) {
        error_message_part <- paste0("Please fix the debug RData files in '", DEBUG_PATH_TO_RAW_RDATA_FILES, "'.\n")
      } else {
        error_message_part <- "Please fix the variables 'ENCOUNTER_FILTER_PATTERN' in the toml file.\n"
      }
      error_message <- paste0(
        "Invalid patient_ids: The following patient_ids are assigned more than in one ward.\n",
        error_message_part,
        etlutils::getPrintString(duplicates_pids_per_ward), "\n",
        "Hint: To ensure that a patient only has exactly one Encounter assigned to exactly one ward, all but one Encounter will be removed.\n",
        "      Only the encounters with the latest start date are left.\n",
        "      If there are several, then the lastUpdateDate of the Encounter is checked.\n",
        "      If there are still several, the first Encounter in the list is simply left.\n"
      )
      etlutils::catWarningMessage(error_message) # first this was an stop error but now it is a warning
    }
  })

  etlutils::runLevel3("Create the final list_of_pids_splitted_by_ward or pids_splitted_by_ward", {
    if (!create_single_pids_per_ward) {
      list_of_pids_splitted_by_ward <- splitPidsPerWardByWardForUniquePidsAndEncounterStart(pids_per_ward_with_encounter_details)
      pids_splitted_by_ward <- unlist(list_of_pids_splitted_by_ward, recursive = FALSE) # needed only for logging in the next part
    } else {
      pids_per_ward_with_encounter_details <- removeMultipleEncountersForPid(pids_per_ward_with_encounter_details)
      pids_splitted_by_ward <- splitPidsPerWardByWard(pids_per_ward_with_encounter_details)
    }
  })

  if (log_result) {
    etlutils::runLevel3("Log getPIDsSplittedByWard() result", {
      no_wards <- !length(pids_splitted_by_ward)
      all_wards_empty <- all(sapply(pids_splitted_by_ward, function(set) length(set) == 0))
      if (!no_wards && !all_wards_empty) {
        cat("Found the following patient IDs for ward(s) '", paste0(names(pids_splitted_by_ward), collapse = "', '"), "':\n", sep = "")
        print(pids_splitted_by_ward)
      } else {
        searched_resource <- ifelse(read_pids_from_debug_rdata_files, "Patient IDs", "Encounters")
        if (no_wards) {
          message <- paste0("No ward names and no ", searched_resource, "found ")
        } else if (all_wards_empty) {
          message <- paste0("No ", searched_resource, " found for ward(s) '", paste0(names(pids_splitted_by_ward), collapse = "', '"), "' ")
        }
        if (read_pids_from_debug_rdata_files) {
          message <- paste0(message, "in debug RData files in '", DEBUG_PATH_TO_RAW_RDATA_FILES, "'.\n")
        } else {
          # current_datetime can be only a start date or a vector with an start and end date (in DEBUG mode)
          current_datetime_display <- ifelse(length(current_datetime) == 1, current_datetime, paste0("start ", paste0(current_datetime, collapse = " to end ")))
          message <- paste0(message, "on FHIR server for timestamp ", current_datetime_display, ".\n")
        }
        etlutils::catWarningMessage(message)
      }
    })
  }
  return(if (exists("list_of_pids_splitted_by_ward")) list_of_pids_splitted_by_ward else pids_splitted_by_ward)
}

#' Get existing FHIR PIDs from the database
#'
#' @return A named list with one data.table containing existing FHIR patient IDs.
getDataImportPIDsFromDB <- function() {
  etlutils::runLevel3("Get data import Patient IDs from patient table", {
    query <- paste0(
      "SELECT DISTINCT pat_id AS patient_id\n",
      "FROM v_patient\n",
      "WHERE pat_id IS NOT NULL;"
    )
    patient_ids <- etlutils::dbGetReadOnlyQuery(
      query,
      lock_id = "getDataImportPIDsFromDB()"
    )

    patient_ids <- data.table::as.data.table(patient_ids)
    if (!nrow(patient_ids)) {
      stop("No FHIR PIDs found in v_patient. PID-dependent data import requires PIDs that already exist in the patient table.")
    }

    patient_ids[, patient_id := etlutils::getAfterLastSlash(patient_id)]
    pids_splitted_by_ward <- list(DataImport = unique(patient_ids))
  })

  etlutils::runLevel3("Log getDataImportPIDsFromDB() result", {
    cat("Found the following existing patient IDs in patient table for data import:\n")
    print(pids_splitted_by_ward)
  })

  pids_splitted_by_ward
}
