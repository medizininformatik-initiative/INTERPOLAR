etlutils::runLevel2("Calculate MRPs", {

  command_arguments <- NULL

  # # use this for debugging
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

  if (command_arguments$start_date > command_arguments$end_date) {
    stop("Parameter end_date (", command_arguments$end_date, ") must be greater than start_date (", command_arguments$start_date, ").")
  }

  mrpCheck(command_arguments$start_date, command_arguments$end_date)

})
