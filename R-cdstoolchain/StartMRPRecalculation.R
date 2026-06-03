library(etlutils)
library(dataprocessor)
library(db2frontend)

etlutils::setProcess("MRPRecalculation")

# Change the working directory to the main project directory.
if (grepl("/cdstoolchain$", getwd())) setwd("../..")
if (grepl("/R-cdstoolchain$", getwd())) setwd("../")

command_line_args <- commandArgs(trailingOnly = TRUE)
ignore_newer_db_version <- "--ignoreNewerDBVersion" %in% command_line_args
command_line_args <- setdiff(command_line_args, "--ignoreNewerDBVersion")

# Enable this block temporarily when running the script interactively.
# if (interactive()) {
#   # command_line_args <- c("start-date=2026-05-24", "end-date=2026-05-28")
#   command_line_args <- c("start-date=2026-05-24")
# }

if (!any(grepl("^start-date=", command_line_args))) {
  stop("Parameter start-date must be set for MRP Recalculation, e.g. start-date=2026-05-24")
}

command_arguments <- etlutils::initCommandLineArguments(
  defaults = list(
    end_date = etlutils::as.POSIXctWithTimezone(Sys.Date())
  ),
  command_arguments = command_line_args
)

status <- dataprocessor::recalculateMRPs(
  start_date = command_arguments$start_date,
  end_date = command_arguments$end_date,
  ignore_newer_db_version = ignore_newer_db_version,
  validate_config = FALSE
)

if (status == 0) {
  status <- db2frontend::startDB2Frontend(
    ignore_newer_db_version = ignore_newer_db_version,
    validate_config = FALSE
  )
}

if (!interactive()) {
  quit(status = status, save = "no")
}
