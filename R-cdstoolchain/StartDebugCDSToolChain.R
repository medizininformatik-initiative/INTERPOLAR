# change the working directory to the main directory
if (grepl('/cdstoolchain', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

# Reset error status
options(error = NULL)

start_full <- Sys.time()

# Create a vector of debug dates from now - count days in the past until now
initDebugDates <- function(count) {
  now <- Sys.time()
  count <- as.integer(count)
  count <- max(1, count)  # Ensure count is at least 1
  dates <- c()
  for (i in 1:count - 1) {
    # Create a date that is i days before now
    date <- now - as.difftime(i, units = "days")
    dates <- c(date, dates)
  }
  day_names <- c()
  for (i in length(dates):1) {
    day_names <- c(day_names, paste0("datetime_minus_", i - 1, "_days"))
  }
  names(dates) <- day_names
  return(dates)
}

############################
### START TEST DEFINITON ###
############################

#################
# Replace the single digit before fixed suffixes with DEBUG_VM_PORT_INDEX (minimal change)
#################
DEBUG_VM_PORT_INDEX <- 4

#################
# DEBUG_MODULES_PATH_TO_CONFIG_TOML can contain for every module a path to
# a config file. If the path is not set, then only the default config file
# is used and no default values are overwritten by the debug config file.
#################
DEBUG_MODULES_PATH_TO_CONFIG_TOML <- c(
  cds2db = "./R-cds2db/test/test_cds2db_config.toml",
  dataprocessor = "",
  db2frontend = ""
)

#################
# If this parameter is given, then no request is sent to the FHIR server, but
# all data is loaded from this folder from RData files
#################
DEBUG_PATH_TO_RAW_RDATA_FILES <- "./R-cds2db/test/tables/"

#################
# This variable should be set to change the downloaded RAW data for DEBUG
# purposes. It contains a path to a script that is sourced after the downloaded
# and cracking of the FHIR RAW data.
#################
DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME <- "./R-cds2db/test/test_04_change_RAW_Data.R"

#################
# This variable can be used to define the path where REDCap mock data are stored.
# In the difference to the variable DEBUG_PATH_TO_RAW_RDATA_FILES nothing happens,
# if this variable is defined or not defined. It must be used explicitly in the
# code to load the REDCap mock data from this path.
#################
DEBUG_PATH_TO_REDCAP_RDATA_FILES <- "./R-cds2db/test/tables/"

#################
# If the data that should be exported to REDCap must be changed for test or debug
# purposes, then this variable can be used to define a path to a script that
# is sourced when the data is prepared for REDCap export.
#################
DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME <- "./R-cds2db/test/test_04_change_REDCap_Data.R"

##########################
### END TEST DEFINITON ###
##########################

# Source all change RAW data scripts. They must define DEBUG_DAYS_COUNT and run
# the real test code only if DEBUG_DATES is defnied!
if (exists("DEBUG_DATES")) {
  rm("DEBUG_DATES")
}
for (script_name in DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME) {
  source(script_name, local = TRUE)
}
DEBUG_DATES <- initDebugDates(DEBUG_DAYS_COUNT)

day_times <- c()

for (debug_day_index in seq_along(DEBUG_DATES)) {
  DEBUG_DAY <- debug_day_index

  start_day <- Sys.time()
  source("./R-cdstoolchain/StartCDSToolChain.R")
  end_day <- Sys.time()
  diff <- capture.output(print(end_day - start_day))
  day_times <- append(day_times, paste("Day", debug_day_index, "took", diff))
  print(day_times[debug_day_index])
#  browser()
}
end_full <- Sys.time()

cat("\nAll days took:")
for (debug_day_index in seq_along(day_times)) {
  print(day_times[debug_day_index])
}

diff <- capture.output(print(end_full - start_full))
print(paste("All days took", diff))
