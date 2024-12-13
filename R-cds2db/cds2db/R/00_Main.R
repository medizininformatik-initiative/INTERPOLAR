#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @param debug_path2config_toml Debug parameter for loading an optional debug config.toml file
#'
#' @export
retrieve <- function(debug_path2config_toml = NA) {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- "./R-cds2db/cds2db_config.toml"
  config <- etlutils::initConstants(path2config_toml)

  ###
  # Add global DB log variable
  ###
  if (!exists("LOG_DB_QUERIES", envir = .GlobalEnv)) {
    assign("LOG_DB_QUERIES", VERBOSE >= VL_90_FHIR_RESPONSE, envir = .GlobalEnv)
  }

  ###
  # Read the optional given debug config.toml file.
  ###
  if (!is.na(debug_path2config_toml)) {
    debug_config <- etlutils::initConstants(debug_path2config_toml)
    for (i in seq_along(debug_config)) {
      config[[names(debug_config)[i]]] <- debug_config[[i]]
    }
  }

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Set the project name to 'cds2db'
  PROJECT_NAME <<- "cds2db"
  ###

  etlutils::createDIRS(PROJECT_NAME)

  ###
  # Create globally used process_clock
  ###
  etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::startLogging(PROJECT_NAME)

  # log all configuration parameters but hide value with parameter name starts with "FHIR_"
  etlutils::catList(config, "Configuration:\n--------------\n", "\n", "^FHIR_(?!SEARCH_).+")

  try(etlutils::runLevel1("Run Retrieve", {

    # Reset lock from unfinished previous cds2db run
    etlutils::runLevel2("Reset lock from unfinished previous cds2db run", {
      resetRemainingDatabaseLock()
    })

    # Extract Patient IDs
    etlutils::runLevel2("Extract Patient IDs", {
      patient_IDs_per_ward <- getPatientIDsPerWard(ifelse(exists("PATH_TO_PID_LIST_FILE"), PATH_TO_PID_LIST_FILE, NA))
      all_wards_empty <- length(unlist(patient_IDs_per_ward)) == 0
    })

    if (!all_wards_empty) {
      # Load Table Description
      etlutils::runLevel2("Load Table Description", {
        fhir_table_descriptions <- getFhircrackrTableDescriptions()
      })

      # Download and crack resources by Patient IDs per ward
      etlutils::runLevel2("Download and crack resources by Patient IDs per ward", {
        # loadResourcesFromFHIRServer() returns a list of tables with the downloades resources and
        # the pids_per_ward table. But it contains only tables which have at least 1 row. Tables
        # for resources which could not be downloaded (generally missing or not present for the
        # current date) are not included here.
        resource_tables <- loadResourcesFromFHIRServer(patient_IDs_per_ward, fhir_table_descriptions)
        all_empty_fhir <- all(sapply(names(resource_tables), function(name) {
          if (name == "pids_per_ward") TRUE else nrow(resource_tables[[name]]) == 0
        }))
        if (all_empty_fhir) {
          etlutils::catWarningMessage("No FHIR resources found.")
        }
        names(resource_tables) <- tolower(paste0(names(resource_tables), "_raw"))
      })

      if (!all_empty_fhir) {
        # Write raw tables to database
        etlutils::runLevel2("Write RAW tables to database", {
          writeTablesToDatabase(
            tables = resource_tables,
            stop_if_table_not_empty = TRUE,
            lock_id = createLockID("Write RAW tables to database"))
        })
      }

      # Convert Column Types in resource tables
      etlutils::runLevel2("Load untyped RAW tables from database", {
        # it could be that some resources could not be downloaded in the current run but in the last
        # run, but the melt and type process was interrupted for any reason -> try not to download
        # only the resources from this run from the database, but also all other resources to melt
        # and type them. And the second point is that the resource_tables contains the pids_per_ward
        # table which is not a resource from the FHIR server -> so we have to join and unique the
        # name set:
        all_resource_names <- c(names(fhir_table_descriptions[["pid_dependant"]]), names(fhir_table_descriptions[["pid_independant"]]))
        # add "_raw" prefix to the resource table names to match the identical names from the raw tables
        all_resource_raw_table_names <- paste0(tolower(all_resource_names), "_raw")
        all_current_run_table_names <- names(resource_tables)
        all_table_names_raw_diff <- unique(c(all_current_run_table_names, all_resource_raw_table_names))
        all_table_names_raw_diff <- paste0("v_", all_table_names_raw_diff, "_diff")

        resource_tables_raw_diff <- readTablesFromDatabase(
          table_names = all_table_names_raw_diff,
          lock_id = createLockID("Load untyped RAW tables from database"))

        all_empty_raw <- all(sapply(resource_tables_raw_diff, function(dt) nrow(dt) == 0))
        if (all_empty_raw) {
          etlutils::catWarningMessage("No (new) untyped RAW tables found in database")
          cat("Note: This warning only means that only data already in the database has been loaded from the FHIR server.\n")
        }
      })

      if (!all_empty_raw) {

        etlutils::runLevel2("Convert RAW tables to typed tables", {
          fhir_table_descriptions <- extractTableDescriptionsList(fhir_table_descriptions)
          resource_tables <- convertTypes(resource_tables_raw_diff, fhir_table_descriptions)
        })

        etlutils::runLevel2("Write typed tables to database", {
          writeTablesToDatabase(
            tables = resource_tables,
            stop_if_table_not_empty = TRUE,
            lock_id = createLockID("Write typed tables to database"))
        })

      }
    }

  }))

  try(etlutils::runLevel1(paste("Finishing", PROJECT_NAME), {
    etlutils::runLevel2("Close database connections", {
      closeAllDatabaseConnections()
    })
  }))

  if (etlutils::isErrorOccured()) {
    if (etlutils::isDebugTestError()) {
      finish_message <- "\nModule 'cds2db' Debug Test Message:\n"
    } else {
      finish_message <- "\nModule 'cds2db' finished with ERRORS (see details above).\n"
    }
    # Remove the irrelevant part from the error message, that the error occurs in our checkError()
    # function. This message part is the beginning of the error message and ends with a " : \n  ".
    error_message <- sub("^[^:]*: \n  ", "", etlutils::getErrorMessage())
    finish_message <- paste0(finish_message, error_message)
  } else if (all_wards_empty || all_empty_fhir || all_empty_raw) {
    finish_message <- "Module 'cds2db' finished with no errors but the result was empty (see warnings above).\n"
  } else {
    finish_message <- "Module 'cds2db' finished with no errors.\n"
  }

  etlutils::finalize(finish_message)

}
