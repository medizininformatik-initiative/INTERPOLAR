#' Copy REDCap Content to Database
#'
#' This function retrieves data from an existing REDCap project and imports this data into
#' the table in a database (defined in the schema `_in`).
#' It establishes a connection to the REDCap project using API credentials and fetches relevant
#' patient, case, medication analysis and MRP data,
#' then connects a PostgreSQL database  to  import the data into it.
#'
#' Note: Database and REDCap connection details (e.g., credentials, table names) are
#' required to be predefined or passed as arguments (not included in this example for
#' security reasons).
#'
#' @return Invisible. The function is called for its side effects: exporting data
#' out of REDCap and does not return a value.
#'
importRedcap2DB <- function() {

  # Connect to REDCap
  frontend_connection <- getRedcapConnection()

  # form names are the names of the elements in the splitted frontend table description
  form_names <- names(getFrontendTableDescription())

  tables2Export <- list()

  # Get data from REDCap
  for (i in seq_along(form_names)) {
    form_name <- form_names[i]

    #TODO: Die Instanzen Risikofaktoren und Trigger werden nicht korrekt aus dem REDCap exportiert.
    # Aktuelle Lösung: Die Tabellen Risikofaktoren und Trigger werden nicht in das Frontend importiert.
    # Ob diese Instanzen überhaupt eine Relevanz haben, muss noch geklärt werden.
    if (!(form_name %in% c("risikofaktor", "trigger"))) {
      data_from_redcap <- data.table::setDT(suppressWarnings(redcapAPI::exportRecordsTyped(rcon = frontend_connection, forms = form_name)))

      # Remove all columns, that start with "db_filter_" (they are only for frontend view filtering)
      data_from_redcap[, grep("^db_filter_", names(data_from_redcap), value = TRUE) := NULL]

      # Remove the redcap_data_access_group values, as they are not needed in the database
      data_from_redcap[, redcap_data_access_group := NA]

      # Ensure that the redcap_repeat_instrument column is set to the form name
      # For unknown reasons, Redcap sometimes creates invalid entries where the
      # redcap_repeat_instrument column is not NA but does not contain the form name.
      data.table::set(data_from_redcap, j = "redcap_repeat_instrument", value = ifelse(!is.na(data_from_redcap$redcap_repeat_instrument), form_name, NA))

      # Redcap creates invalid entries for unknown reasons where the _complete column is NA, which
      # should never be and leads to an error when we transfer these records back to Redcap. We
      # therefore delete them here.
      complete_column_name <- paste0(form_name, "_complete")
      data_from_redcap <- data_from_redcap[!is.na(data_from_redcap[[complete_column_name]]), ]

      # remove all columns that start with "db_filter" (they are only for frontend view filtering)
      data_from_redcap[, grep("^db_filter", names(dt), value = TRUE) := NULL]

      # Filter out records with an invalid fall_meda_id (sometimes REDCap creates
      # empty instruments when the record_id is created)
      if (form_name == "medikationsanalyse") {
        data_from_redcap <- data_from_redcap[!is.na(data_from_redcap$fall_meda_id), ]
      }

      colname <- paste0(form_name, "_additional_values")
      if (colname %in% names(data_from_redcap)) {
        data_from_redcap[[colname]] <- etlutils::redcapUnescape(data_from_redcap[[colname]])
      }

      table_filename_prefix <- if (exists("DEBUG_DAY")) paste0(DEBUG_DAY, "_") else ""
      etlutils::writeRData(data_from_redcap, paste0(table_filename_prefix, "frontend2db_", i, "_", form_name))

      tables2Export[[form_name]] <- data_from_redcap
    }
  }

  # Write tables to database
  tables <- list()
  for (i in seq_along(tables2Export)) {
    table_name <- paste0(names(tables2Export)[i], "_fe")
    tables2Export[[i]] <- etlutils::dbConvertToDBTypes(tables2Export[[i]], table_name)
    tables[[table_name]] <- tables2Export[[i]]
  }
  etlutils::dbWriteTables(tables, lock_id = "importRedcap2DB()", ignore_missing_db_columns = TRUE)
}
