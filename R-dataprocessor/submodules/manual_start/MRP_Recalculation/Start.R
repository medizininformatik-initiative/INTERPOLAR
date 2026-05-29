etlutils::runLevel2("Additive MRP recalculation", {

  command_arguments <- NULL

  #Enable this block temporarily when running the module interactively.
  if (interactive()) {
    command_arguments <- "MRP_Recalculation start-date=2026-05-24 end-date=2026-05-28"
  }

  command_arguments <- etlutils::initCommandLineArguments(
    defaults = list(
      start_date = etlutils::as.POSIXctWithTimezone(Sys.Date()),
      end_date = etlutils::as.POSIXctWithTimezone(Sys.Date())
    ),
    command_arguments = command_arguments
  )

  start_date <- etlutils::as.POSIXctWithTimezone(command_arguments$start_date)
  end_date <- etlutils::as.POSIXctWithTimezone(command_arguments$end_date)

  if (start_date > end_date) {
    stop("Parameter end_date (", end_date, ") must be greater than start_date (", start_date, ").")
  }

  # The manual-start wrapper only parses arguments. The actual recalculation
  # logic lives in the submodule package to mirror the other manual-start modules.
  mrpRecalculation(start_date, end_date)
})
