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
    if(!(form_name %in% c("risikofaktor", "trigger"))) {

      dt <- data.table::setDT(redcapAPI::exportRecordsTyped(rcon = frontend_connection, forms = form_name))

      # Remove the redcap_data_access_group values, as they are not needed in the database
      dt[, redcap_data_access_group := NA]

      # Ensure that the redcap_repeat_instrument column is set to the form name
      # For unknown reasons, Redcap sometimes creates invalid entries where the
      # redcap_repeat_instrument column is not NA but does not contain the form name.
      data.table::set(dt, j = "redcap_repeat_instrument", value = ifelse(!is.na(dt$redcap_repeat_instrument), form_name, NA))

      # Redcap creates invalid entries for unknown reasons where the _complete column is NA, which
      # should never be and leads to an error when we transfer these records back to Redcap. We
      # therefore delete them here.
      complete_column_name <- paste0(form_name, "_complete")
      dt <- dt[!is.na(dt[[complete_column_name]]), ]

      rdata_filename <- paste0(table_filename_prefix, "frontend2db_", i, "_", form_name)

      # Add additional values for specific forms
      if (form_name == "retrolektive_mrpbewertung") {
        rdata_filename_before_additional_values <- paste0(rdata_filename, "_before_additional_values")
        etlutils::writeRData(dt, rdata_filename_before_additional_values)
        for (i in nrow(dt):1) {
          tryCatch({
            additional_values <- RcppTOML::parseTOML(text = dt$ret_additional_values[i])
            dt$db_ret_main_enc_id[i] <- additional_values$db_ret_main_enc_id
            dt$db_ret_medical_case_id[i] <- additional_values$db_ret_medical_case_id
          }, error = function(e) {
            catErrorMessage("Error in retrolektive_mrpbewertung by parsing ret_additional_values for row ",
                            i, ": ", e$message, "Check table in ", rdata_filename_before_additional_values, "\n")
            dt <- dt[-i]
          })
        }
      }

      table_filename_prefix <- if (exists("DEBUG_DAY")) paste0(DEBUG_DAY, "_") else ""

      etlutils::writeRData(dt, rdata_filename)

      tables2Export[[form_name]] <- dt
    }
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
