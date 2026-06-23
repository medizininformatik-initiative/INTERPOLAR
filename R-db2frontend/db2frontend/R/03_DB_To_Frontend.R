#' Copy Database Content to Frontend
#'
#' This function retrieves data from the view or table in a database
#' (defined in the schema `_out`) and imports this data into an existing REDCap project.
#' It establishes a connection to a PostgreSQL database, fetches relevant data for
#' each table defined in `getDBTableAndColumnNames`, then connects to the REDCap project
#' using API credentials and imports the data.
#'
#' Note: Database and REDCap connection details (e.g., credentials, table names) are
#' required to be predefined or passed as arguments (not included in this example for
#' security reasons).
#'
#' @return Invisible. The function is called for its side effects: importing data
#' into REDCap and does not return a value.
#'
importDB2Redcap <- function() {

  tryRedcap <- function(redcap_process) {
    tryCatch({
      redcap_process()
    }, error = function(e) {
      message("This error may have occurred because the user preferences in the Redcap project ",
              "have been changed. Use the default values if possible.")
      stop(e$message)
    })
  }

  writeTablesAsExcel <- function(tables, suffix = "") {
    table_names <- names(tables)
    for (i in seq_along(table_names)) {
      table_filename_prefix <- if (exists("TOOLCHAIN_DAY")) paste0("TOOLCHAIN_DAY_", TOOLCHAIN_DAY, "_") else ""
      table_name <- table_names[i]
      etlutils::writeDebugExcelFile(tables[[table_name]], paste0(table_filename_prefix, "db2frontend_", table_name, suffix))
    }
  }

  moveRecordIdToFirstColumn <- function(import_data) {
    if ("record_id" %in% names(import_data)) {
      return(import_data[, c("record_id", setdiff(names(import_data), "record_id")), with = FALSE])
    }
    return(import_data)
  }

  prepareRedcapImport <- function(table_name, import_data) {
    import_data <- moveRecordIdToFirstColumn(import_data)

    # Keep the historic import semantics: db2frontend hands raw values to REDCap and lets
    # importRecords() perform only its own import checks. In particular, dynamic REDCap SQL
    # fields must not be pre-cast because castForImport() can turn valid pipeline IDs into NA.
    attr(import_data, "castForImport") <- TRUE
    return(import_data)
  }

  importRecordsToRedcap <- function(table_name, import_data, overwriteBehavior = "normal") {
    prepared_data <- data.table::as.data.table(prepareRedcapImport(table_name, import_data))
    redcap_import_batch_size <- 1000L

    normalizeImportResult <- function(import_result) {
      if (is.data.frame(import_result)) {
        return(data.table::as.data.table(import_result))
      }

      import_result <- as.character(import_result)
      import_result <- import_result[nzchar(import_result)]

      if (any(grepl("<[^>]+>|Fatal error|Allowed memory size|\"error\"", import_result))) {
        stop(paste(import_result, collapse = "\n"), call. = FALSE)
      }

      csv_response <- grepl("[\r\n]", import_result)
      if (any(csv_response)) {
        return(data.table::rbindlist(lapply(import_result, function(response) {
          data.table::as.data.table(utils::read.csv(
            text = response,
            stringsAsFactors = FALSE,
            check.names = FALSE
          ))
        }), use.names = TRUE, fill = TRUE))
      }

      data.table::data.table(import_result = import_result)
    }

    import_result <- redcapAPI::importRecords(
      rcon = frontend_connection,
      data = prepared_data,
      overwriteBehavior = overwriteBehavior,
      returnContent = "ids",
      batch.size = if (nrow(prepared_data) > redcap_import_batch_size) redcap_import_batch_size else -1L
    )
    import_result <- normalizeImportResult(import_result)

    import_count <- nrow(import_result)
    message("REDCap import for table '", table_name, "' returned ", import_count, " record id(s).")

    etlutils::writeDebugExcelFile(import_result, paste0("db2frontend_", table_name, "_redcap_import_result"))
    return(import_result)
  }

  etlutils::runLevel2Line("Update frontend data from DB", {

    # Connect to REDCap
    frontend_connection <- getRedcapConnection()

    # Check if any ward is in PhaseB in fall_fe
    phaseB_active <- etlutils::dbGetReadOnlyQuery(
      "SELECT EXISTS (
        SELECT 1
        FROM v_fall_fe
        WHERE fall_studienphase = 'PhaseB'
      ) AS phaseb_active",
      lock_id = "importDB2Redcap_check_phaseB"
    )$phaseb_active

    is_phaseB_active <- isTRUE(phaseB_active)

    ret_ids_to_empty <- integer(0)

    if (is_phaseB_active) {

      # Get ret_ids of all PhaseBTest MRPs which are not new in this run
      ret_ids_to_clear <- etlutils::dbGetReadOnlyQuery(
        "SELECT DISTINCT ret_id
         FROM v_retrolektive_mrpbewertung_fe_last_version
         WHERE ret_kurzbeschr ILIKE '*TEST*%'",
        lock_id = "importDB2Redcap_phaseBTestMRP"
      )$ret_id

      if (length(ret_ids_to_clear)) {
        # Fetch all retrolektive_mrpbewertung instances for the ret_ids to empty
        mrp_instances <- suppressWarnings(redcapAPI::exportRecordsTyped(
          rcon = frontend_connection,
          forms = "retrolektive_mrpbewertung"
        ))

        mrp_instances <- data.table::as.data.table(mrp_instances)
        # Filter to only the instances which are not new in this run
        mrp_instances <- mrp_instances[ret_id %in% ret_ids_to_clear]

        if (nrow(mrp_instances)) {

          # Keep only the ID columns and the _complete column, set all other columns to NA
          needed_cols <- c("record_id", "redcap_repeat_instrument", "redcap_repeat_instance", "retrolektive_mrpbewertung_complete")
          mrp_instances[, (setdiff(names(mrp_instances), c(needed_cols))) := NA]
          # For unknown reasons, redcap_repeat_instrument is not the correct string in the dt from redcapAPI
          mrp_instances[, redcap_repeat_instrument := as.character("retrolektive_mrpbewertung")]
          mrp_instances[, redcap_repeat_instance  := as.integer(redcap_repeat_instance)]

          # Set the ret_kurzbeschr to indicate that this MRP evaluation has been cleared
          mrp_instances[, ret_kurzbeschr := "Diese retrolektive MRP-Bewertung wurde geleert, weil der Fall in PhaseBTest war."]
          mrp_instances[, retrolektive_mrpbewertung_complete := "Unverified"]

          # Import the cleared instances back to REDCap
          return_ids <- importRecordsToRedcap("retrolektive_mrpbewertung_cleared", mrp_instances, overwriteBehavior = "overwrite")
        }
      }
    }

    # Get splitted frontend table descriptions
    table_description <- getFrontendTableDescription()

    table_names <- names(table_description)

    # Get REDCap metadata to retrieve valid field names
    valid_fields <- tryRedcap(function() getRedcapFieldNames(frontend_connection))

    # Exclude "risikofaktor", "trigger" always and medikationsanalyse and mrpdokumentation_validierung
    # in normal run (= not debug). In debug runs we must change the last state of medikationsanalyse
    # and mrpdokumentation_validierung, so we need to import them.
    excluded_tables <- c("risikofaktor", "trigger")
    if (!etlutils::isProcess("DebugCDSToolchain")) {
      # In debug mode, do not exclude medikationsanalyse and mrpdokumentation_validierung
      excluded_tables <- c(excluded_tables, "medikationsanalyse", "mrpdokumentation_validierung")
    }
    table_names <- setdiff(table_names, excluded_tables)

    data_to_import <- list()
    # Iterate over tables and columns to fetch and send data
    for (i in seq_along(table_names)) {

      table_name <- table_names[i]

      db_generated_id_col_name <- paste0(table_name, "_fe_id")
      columns <- c(db_generated_id_col_name, table_description[[table_name]]$COLUMN_NAME)

      # Create SQL query dynamically based on columns
      query <- sprintf("SELECT %s FROM v_%s_fe_last_version", paste(columns, collapse = ", "), table_name)

      # Fetch data from the database
      data_from_db <- etlutils::dbGetReadOnlyQuery(query, lock_id = "importDB2Redcap()")
      # Keep only columns that exist in REDCap
      data_from_db <- data_from_db[, names(data_from_db) %in% valid_fields, with = FALSE]

      # Escape double quotes in character columns (CSV-compliant escaping)
      char_cols <- names(data_from_db)[sapply(data_from_db, is.character)]
      toml_cols <- char_cols[grepl("_additional_values$", char_cols)]

      for (col_name in char_cols) {
        # redcap can sometimes misinterpret double quotation marks, even if they are CSV-compliant
        # escaped. Therefore, we replace them with single quotation marks in all text fields.
        if (!(col_name %in% toml_cols)) {
          data_from_db[[col_name]] <- gsub('"', '\'', data_from_db[[col_name]], fixed = TRUE)
        } else {
          # Additional_value fields are toml files that require double quotation marks, so it is
          # important to ensure that these are retained.
          data_from_db[[col_name]] <- etlutils::redcapEscape(data_from_db[[col_name]])
        }
      }

      # If PhaseB is active, exclude all new PhaseBTest MRPs from the data to import
      if (is_phaseB_active && table_name == "retrolektive_mrpbewertung") {

        # Get ret_ids of all PhaseBTest MRPs which are new in this run
        ret_ids_to_delete <- etlutils::dbGetReadOnlyQuery(
          "SELECT DISTINCT ret_id
          FROM v_retrolektive_mrpbewertung_fe_last_version
          WHERE ret_kurzbeschr ILIKE '*TEST%'",
          lock_id = "importDB2Redcap_phaseBTestMRP")$ret_id

        # Filter out these ret_ids from the data to import
        data_from_db <- data_from_db[!ret_id %in% ret_ids_to_delete]
      }

      data_to_import[[table_name]] <- data_from_db

      if (table_name %in% "fall") {
        record_ids_with_data_access_group <- unique(data_from_db[, c("record_id", "fall_station")])
      }
    }
    writeTablesAsExcel(data_to_import)
  })

  #########################
  # START: FOR DEBUG ONLY #
  #########################
  if (etlutils::isDefinedAndNotEmpty("DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME")) {
    for (script_name in DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME) {
      source(script_name, local = TRUE) # this should change the data_to_import list
    }
    writeTablesAsExcel(data_to_import, suffix = "_debugchanged")
  }
  #######################
  # END: FOR DEBUG ONLY #
  #######################

  etlutils::runLevel2Line("Import data into frontend", {
    # Import data into REDCap
    for (table_name in names(data_to_import)) {
      tryRedcap(function() importRecordsToRedcap(table_name, data_to_import[[table_name]]))
    }
  })

  etlutils::runLevel2Line("Update data access groups", {

    if (exists("record_ids_with_data_access_group") && nrow(record_ids_with_data_access_group)) {

      ward_names <- unique(record_ids_with_data_access_group$fall_station)

      # Get all data access groups from Redcap
      data_access_groups <- data.table::setDT((suppressWarnings(redcapAPI::exportDags(rcon = frontend_connection))))

      # Get all ward names not present in data access group name
      new_ward_names <- ward_names[!ward_names %in% data_access_groups$data_access_group_name]

      # If there are new ward names, create new data access groups
      if (length(new_ward_names)) {
        new_data_access_groups <- data.table::data.table(
          data_access_group_name = new_ward_names,
          unique_group_name = NA_character_
        )

        suppressWarnings(redcapAPI::importDags(rcon = frontend_connection, data = new_data_access_groups))
      }

      # Get all data access groups from Redcap inclusive the new data access groups
      data_access_groups <- suppressWarnings(redcapAPI::exportDags(rcon = frontend_connection))

      # Join the record_ids with the unique_group_names
      record_ids_with_data_access_group <- data.table::merge.data.table(
        record_ids_with_data_access_group,
        data_access_groups,
        by.x = "fall_station",
        by.y = "data_access_group_name"
      )

      # Reformat the table in the needed structure (remaining columns are record_id
      # and the renamed column redcap_data_access_group)
      record_ids_with_data_access_group <- record_ids_with_data_access_group[, .(record_id, redcap_data_access_group = unique_group_name)]
    }

    etlutils::runLevel2Line("Write data to Redcap", {
      # Set the data access groups in Redcap
      etlutils::writeDebugExcelFile(record_ids_with_data_access_group, "db2frontend_record_ids_with_data_access_group")
      importRecordsToRedcap("record_ids_with_data_access_group", record_ids_with_data_access_group)
    })

  })
}
