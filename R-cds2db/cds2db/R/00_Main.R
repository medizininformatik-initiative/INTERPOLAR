#' Starts the ETL retrieval process from FHIR to the database
#'
#' This is the main entry point for the ETL process. It initializes the module,
#' validates mandatory parameters, and starts the data retrieval workflow from
#' the FHIR API to the database. If `reset_lock_only` is set to `TRUE`, only
#' the lock is reset and the function exits without running the ETL process.
#'
#' @param reset_lock_only Logical. If TRUE, only resets the ETL lock and exits. Default is FALSE.
#'
#' @export
retrieve <- function(reset_lock_only = FALSE) {

  # Initialize and start module
  etlutils::startModule("cds2db",
                        path_to_toml = "./R-cds2db/cds2db_config.toml",
                        hide_value_pattern = "^FHIR_(?!SEARCH_).+",
                        init_constants_only = reset_lock_only)

  if (reset_lock_only) {
    etlutils::dbResetLock()
    return()
  }

  try(etlutils::runLevel1("Run Retrieve", {

    # Reset database lock from unfinished previous cds2db run
    etlutils::runLevel2("Reset database lock from unfinished previous run", {
      etlutils::dbResetLock()
    })

    # Extract Patient IDs
    etlutils::runLevel2("Extract Patient IDs", {
      pids_splitted_by_ward <- getPIDsSplittedByWard()
      all_wards_empty <- !length(unlist(pids_splitted_by_ward))
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
        resource_tables <- loadResourcesFromFHIRServer(pids_splitted_by_ward, fhir_table_descriptions)
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
          etlutils::dbWriteTables(
            tables = resource_tables,
            lock_id = "Write RAW tables to database",
            stop_if_table_not_empty = TRUE)
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

        resource_tables_raw_diff <- etlutils::dbReadTables(
          table_names = all_table_names_raw_diff,
          lock_id = "Load untyped RAW tables from database")

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
          etlutils::dbWriteTables(
            tables = resource_tables,
            lock_id = "Write typed tables to database",
            stop_if_table_not_empty = TRUE)
        })

      }
    }

  }))

  # Reset lock and close all database connections. Do not surround this with runLevelX!
  etlutils::dbCloseAllConnections()

  # Generate finish message
  finish_message <- etlutils::generateFinishMessage()
  if (!etlutils::isErrorOccured() &&
      (etlutils::isDefinedAndTrue("all_wards_empty") ||
       etlutils::isDefinedAndTrue("all_empty_fhir") ||
       etlutils::isDefinedAndTrue("all_empty_raw"))) {
    finish_message <- paste0(
      "\nModule '", MODULE_NAME, "' finished with no errors but the result was empty (see warnings above).\n"
    )
  }

  # Add warning if any DEBUG_ variables are active
  finish_message <- etlutils::appendDebugWarning(finish_message)

  etlutils::finalize(finish_message)

}
