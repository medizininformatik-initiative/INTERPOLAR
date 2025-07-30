####################################################################################
# Preferences: The current working directory must be the main project directory.   #
#              In interactive setting this is the parent directory of the          #
#              R-dataprocessor directory.                                          #
####################################################################################

# chance the working directory to the main directory
if (grepl("/dataprocessor$", getwd())) setwd("../..")
if (grepl("/R-dataprocessor$", getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(dataprocessor)

# retrieve submodule names for manual start from the command line arguments
# for test purposes, the submodule name can be set manually when running the script interactively
if (!interactive()) {
  START_DATA_PROCESSOR_ARGS <- commandArgs(trailingOnly = TRUE)
} else {
  START_DATA_PROCESSOR_ARGS <- as.character(c())
}

status <- dataprocessor::processData()
if (!interactive()) {
  quit(status = status, save = "no")
}
