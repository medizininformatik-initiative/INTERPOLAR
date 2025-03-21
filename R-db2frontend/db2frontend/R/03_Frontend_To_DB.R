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

      dt <- data.table::setDT(redcapAPI::exportRecordsTyped(rcon = frontend_connection, forms = form_name))
      redcapAPI::reviewInvalidRecords(dt)
      data.table::set(dt, j = "redcap_repeat_instrument", value = ifelse(!is.na(dt$redcap_repeat_instrument), form_name, NA))

      # Redcap creates invalid entries for unknown reasons where the _complete column is NA, which
      # should never be and leads to an error when we transfer these records back to Redcap. We
      # therefore delete them here.
      complete_column_name <- paste0(form_name, "_complete")
      dt <- dt[!is.na(dt[[complete_column_name]]), ]

      table_filename_prefix <- if (exists("DEBUG_DAY")) paste0(DEBUG_DAY, "_") else ""
      etlutils::writeRData(dt, paste0(table_filename_prefix, "frontend2db_", i, "_", form_name))

      tables2Export[[form_name]] <- dt
    }

    # Write tables to database
    tables <- list()
    for (i in seq_along(tables2Export)) {
      table_name <- paste0(names(tables2Export)[i], "_fe")
      tables2Export[[i]] <- etlutils::dbConvertToDBTypes(tables2Export[[i]], table_name)
      tables[[table_name]] <- tables2Export[[i]]
    }
    etlutils::dbWriteTables(tables, lock_id = "importRedcap2DB()")
}
