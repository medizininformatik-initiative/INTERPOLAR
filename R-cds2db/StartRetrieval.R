####################################################################################
# Preferences: The current working directory must be the main project directory.   #
#              In interactive setting this is the parent directory of the R-cds2db #
#              directory.                                                          #
####################################################################################

# chance the working directory to the main directory
if (grepl('/cds2db$', getwd())) setwd("../..")
if (grepl('/R-cds2db$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)

status <- cds2db::retrieve()
if (!interactive()) {
  quit(status = status, save = "no")
}
