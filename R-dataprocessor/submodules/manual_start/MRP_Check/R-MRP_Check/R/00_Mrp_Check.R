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
    mrp_table_lists_all <- calculateMRPs(command_arguments$start_date, command_arguments$end_date)
  })

  etlutils::runLevel2("Save calculated MRPs as Excel files", {
    etlutils::writeExcelFileLocal(mrp_table_lists_all, "MRP_Check_Result")
  })

}
