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

  etlutils::runLevel2Line("Update frontend data from DB", {

    # Connect to REDCap
    frontend_connection <- getRedcapConnection()

    # Get splitted frontend table descriptions
    table_description <- getFrontendTableDescription()

    table_names <- names(table_description)

    # Get REDCap metadata to retrieve valid field names
    valid_fields <- tryRedcap(function() getRedcapFieldNames(frontend_connection))

    # Exclude medikationsanalyse and mrpdokumentation_validierung
    excluded_tables <- c("medikationsanalyse", "mrpdokumentation_validierung", "risikofaktor", "trigger")
    table_names <- setdiff(table_names, excluded_tables)

    # Iterate over tables and columns to fetch and send data
    for (i in seq_along(table_names)) {

      table_name <- table_names[i]

      db_generated_id_column_name <- paste0(table_name, "_fe_id")
      columns <- c(db_generated_id_column_name, table_description[[table_name]]$COLUMN_NAME)

      # Create SQL query dynamically based on columns
      query <- sprintf("SELECT %s FROM v_%s", paste(columns, collapse = ", "), table_name)

      # Fetch data from the database
      data_from_db <- etlutils::dbGetReadOnlyQuery(query, lock_id = "importDB2Redcap()")

      table_filename_prefix <- if (exists("DEBUG_DAY")) paste0(DEBUG_DAY, "_") else ""
      etlutils::writeRData(data_from_db, paste0(table_filename_prefix, "db2frontend_", i, "_", table_name))

      # Import data to REDCap
      # Keep only columns that exist in REDCap
      data_from_db <- data_from_db[, names(data_from_db) %in% valid_fields, with = FALSE]

      # Escape double quotes in character columns (CSV-compliant escaping)
      char_cols <- names(data_from_db)[sapply(data_from_db, is.character)]
      toml_cols <- char_cols[grepl("_additional_values$", char_cols)]

      for (colname in char_cols) {
        # redcap can sometimes misinterpret double quotation marks, even if they are CSV-compliant
        # escaped. Therefore, we replace them with single quotation marks in all text fields.
        if (!(colname %in% toml_cols)) {
          data_from_db[[colname]] <- gsub('"', '\'', data_from_db[[colname]], fixed = TRUE)
        } else {
          # Additional_value fields are toml files that require double quotation marks, so it is
          # important to ensure that these are retained.
          data_from_db[[colname]] <- etlutils::redcapEscape(data_from_db[[colname]])
        }
      }

      tryRedcap(function() redcapAPI::importRecords(rcon = frontend_connection, data = data_from_db))

      if (table_name %in% "fall") {
        record_ids_with_data_access_group <- unique(data_from_db[, c("record_id", "fall_station")])
      }
    }
  })

  etlutils::runLevel2Line("Update data access groups", {

    if (exists("record_ids_with_data_access_group") && nrow(record_ids_with_data_access_group)) {

      ward_names <- unique(record_ids_with_data_access_group$fall_station)

      # Get all data access groups from Redcap
      data_access_groups <- data.table::setDT((redcapAPI::exportDags(rcon = frontend_connection)))

      # Get all ward names not present in data access group name
      new_ward_names <- ward_names[!ward_names %in% data_access_groups$data_access_group_name]

      # If there are new ward names, create new data access groups
      if (length(new_ward_names)) {
        new_data_access_groups <- data.table::data.table(
          data_access_group_name = new_ward_names,
          unique_group_name = NA_character_
        )

        redcapAPI::importDags(rcon = frontend_connection, data = new_data_access_groups)
      }

      # Get all data access groups from Redcap inclusive the new data access groups
      data_access_groups <- redcapAPI::exportDags(rcon = frontend_connection)

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
      redcapAPI::importRecords(rcon = frontend_connection, data = record_ids_with_data_access_group)
    })

  })
}
