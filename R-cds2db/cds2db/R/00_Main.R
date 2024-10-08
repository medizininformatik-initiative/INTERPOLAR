#'
#' Starts the retrieval for this project. This is the main start function start the ETL job
#' from FHIR to Database
#'
#' @export
retrieve <- function() {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- "./R-cds2db/cds2db_config.toml"
  config <- etlutils::initConstants(path2config_toml)

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
  etlutils::catList(config, "Configuration:\n--------------\n", "\n", "^FHIR_")

  try(etlutils::runLevel1("Run Retrieve", {

    # Extract Patient IDs
    etlutils::runLevel2("Extract Patient IDs", {
      patient_IDs_per_ward <- getPatientIDsPerWard(ifelse(exists("PATH_TO_PID_LIST_FILE"), PATH_TO_PID_LIST_FILE, NA))
    })

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
      all_empty_fhir <- all(sapply(resource_tables, function(dt) nrow(dt) == 0))
      if (all_empty_fhir) {
        etlutils::catWarningMessage("No FHIR resources found.")
      }
      names(resource_tables) <- tolower(paste0(names(resource_tables), "_raw"))
    })

    if (!all_empty_fhir) {
      # Write raw tables to database
      etlutils::runLevel2("Write raw tables to database", {
        writeTablesToDatabase(resource_tables, clear_before_insert = TRUE)
      })

      # Wait until the copy cron job runs after insertion
      etlutils::runLevel2(paste0("Wait until the cron job in database has moved data from input schema to database core (", DELAY_MINUTES_BETWEEN_RAW_INSERT_AND_START_TYPING, " minute(s))") , {
        start <- as.numeric(Sys.time())
        while (start + DELAY_MINUTES_BETWEEN_RAW_INSERT_AND_START_TYPING * 60 + 10 > as.numeric(Sys.time())) {
          cat(".")
          Sys.sleep(10)
        }
        cat("\n")
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
      all_table_names_raw <- unique(c(all_current_run_table_names, all_resource_raw_table_names))

      all_table_names_raw <- sub("_raw", "", all_table_names_raw)
      all_table_names_raw <- paste0("v_", all_table_names_raw)

      resource_tables <- readTablesFromDatabase(all_table_names_raw)
      all_empty_raw <- all(sapply(resource_tables, function(dt) nrow(dt) == 0))
      if (all_empty_raw) {
        etlutils::catWarningMessage("No (new) untyped RAW tables found in database")
        cat("Note: This warning only means that only data already in the database has been loaded from the FHIR server.\n")
      }
    })

    if (!all_empty_raw) {

      etlutils::runLevel2("Convert RAW tables to typed tables", {
        fhir_table_descriptions <- extractTableDescriptionsList(fhir_table_descriptions)
        resource_tables <- convertTypes(resource_tables, fhir_table_descriptions)
      })

      etlutils::runLevel2("Write typed tables to database", {
        writeTablesToDatabase(resource_tables, clear_before_insert = FALSE)
      })

    }

  }))

  if (etlutils::isErrorOccured()) {
    if (etlutils::isIntentionallyDebugTestError()) {
      finish_message <- "\nModule 'cds2db' Debug Test Message:\n"
    } else {
      finish_message <- "\nModule 'cds2db' finished with errors (see details above).\n"
    }
    # Remove the irrelevant part from the error message, that the error occurs in our checkError()
    # function. This message part is the begiining of the error message and ends with a " : ".
    error_message <- sub("^[^:]*: ", "", etlutils::getErrorMessage())
    finish_message <- paste0(finish_message, error_message)
  } else if (all_empty_fhir && all_empty_raw) {
    finish_message <- "Module 'cds2db' finished with no errors but the result was empty (see warnings above).\n"
  } else {
    finish_message <- "Module 'cds2db' finished with no errors.\n"
  }

  etlutils::finalize(finish_message)

}
