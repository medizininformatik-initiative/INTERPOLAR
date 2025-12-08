mrpCheck <- function() {
  etlutils::runLevel2("MRP Calculation", {

    command_arguments <- NULL

    # use this for debugging
    # if (interactive()) {
    #   command_arguments <- "mrp-check start-date=2025-12-01 end-date=2025-12-03"
    # }

    # load the command line arguments and rename them
    command_arguments <- etlutils::initCommandLineArguments(
      defaults = c(
        start_date = Sys.Date() - 60,
        end_date = Sys.time()
      ),
      command_arguments = command_arguments
    )
    mrp_table_lists_all <- calculateMRPs(command_arguments$start_date, command_arguments$end_date, return_used_resources = "record_ids")
  })

  etlutils::runLevel2("Create local MRP result table", {
    names(mrp_table_lists_all$dp_mrp_calculations)
    mrp_table_lists_all$retrolektive_mrpbewertung_fe[, c("retrolektive_mrpbewertung_complete",
                                                         "redcap_repeat_instrument",
                                                         "redcap_repeat_instance") := NULL]
    mrp_table_lists_all$dp_mrp_calculations[, c("ret_redcap_repeat_instance",
                                                "input_file_processed_content_hash",
                                                "ward_name") := NULL]
    result <- mrp_table_lists_all$dp_mrp_calculations[mrp_table_lists_all$retrolektive_mrpbewertung_fe, on = "ret_id"]
    result[, record_id := as.character(record_id)]
    result <- mrp_table_lists_all$record_ids[result, on = "record_id"]
  })

  etlutils::runLevel2("Save calculated MRPs as local Excel files", {
    etlutils::writeExcelFileLocal(result, "MRP_Check_Result_local")
  })

  etlutils::runLevel2("Create global MRP result table", {
    id_cols <- grep("_id$", names(result), value = TRUE)
    for (col in id_cols) {
      # Create unique integer IDs per column while preserving consistency
      result[, (col) := .GRP, by = col]
    }
  })

  etlutils::runLevel2("Save calculated MRPs as local Excel files", {
    etlutils::writeExcelFileGlobal(result, "MRP_Check_Result_global")
  })

}
