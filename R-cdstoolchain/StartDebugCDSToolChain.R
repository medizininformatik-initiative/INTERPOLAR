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


############################
### START TEST DEFINITON ###
############################

###
# Set the index of the test that should be run. This is used to determine the
# script names to load/change the RAW and REDCap data.
###
DEBUG_TEST_INDEX <- 2

###
# Set the index of the virtual machine that should be used for the debug run.
###
DEBUG_VM_PORT_INDEX <- 2

##########################
### END TEST DEFINITON ###
##########################

###
# For test_index = 4 this returns file name "./R-cds2db/test/test_04_change_RAW_Data.R"
# or "./R-cds2db/test/test_04_change_REDCap_Data.R".
###
getChangeDataFileName <- function(test_index, change_data_type = c("RAW", "REDCap")) {
  change_data_type <- match.arg(change_data_type)

  # do not overwite the debug script name if it is already defined
  if (change_data_type == "RAW" && exists("DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME")) {
    return(DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME)
  }
  if (change_data_type == "REDCap" && exists("DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME")) {
    return(DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME)
  }

  # calculate the variable test_index as string with length 2 (if DEBUG_TEST_INDEX < 10 then add a leading 0)
  test_index <- if (DEBUG_TEST_INDEX < 10) paste0("0", DEBUG_TEST_INDEX) else as.character(DEBUG_TEST_INDEX)
  change_data_file_name <- paste0("./R-cds2db/test/test_", test_index, "_change_", change_data_type, "_Data.R")
  if (!file.exists(change_data_file_name)) {
    change_data_file_name <- NA
  }
  return(change_data_file_name)
}

###
# This variable should be set to change the downloaded RAW data for DEBUG
# purposes. It contains a path to a script that is sourced after the downloaded
# and cracking of the FHIR RAW data.
###
DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME <- getChangeDataFileName(DEBUG_TEST_INDEX, "RAW")

###
# If the data that should be exported to REDCap must be changed for test or debug
# purposes, then this variable can be used to define a path to a script that
# is sourced when the data is prepared for REDCap export.
###
DEBUG_CHANGE_REDCAP_DATA_SCRIPT_NAME <- getChangeDataFileName(DEBUG_TEST_INDEX, "REDCap")

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

# Source the "change RAW data" script. It must define DEBUG_DAYS_COUNT and run
# the real test code only if DEBUG_DATES is defnied!
if (exists("DEBUG_DATES")) {
  rm("DEBUG_DATES")
}
source(DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME, local = TRUE) # defines DEBUG_DAYS_COUNT
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
  #browser()
}
end_full <- Sys.time()

cat("\nAll days took:")
for (debug_day_index in seq_along(day_times)) {
  print(day_times[debug_day_index])
}

diff <- capture.output(print(end_full - start_full))
print(paste("All days took", diff))
