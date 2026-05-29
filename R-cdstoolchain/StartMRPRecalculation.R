library(etlutils)
library(dataprocessor)

etlutils::setProcess("MRPRecalculation")

# Change the working directory to the main project directory.
if (grepl("/cdstoolchain$", getwd())) setwd("../..")
if (grepl("/R-cdstoolchain$", getwd())) setwd("../")

# Force the dataprocessor to execute only the dedicated manual-start module.
DEBUG_SUBMODULE_DIR <- "./R-dataprocessor/submodules/manual_start/MRP_Recalculation"

status <- dataprocessor::processData()
if (!interactive()) {
  quit(status = status, save = "no")
}
