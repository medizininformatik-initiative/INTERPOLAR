####################################################################################
# Preferences: The current working directory must be the main project directory.   #
#              In interactive setting this is the parent directory of the R-cds2db #
#              directory.                                                          #
####################################################################################

# chance the working directory to the main directory
if (grepl('/dbcreate$', getwd())) setwd("../..")
if (grepl('/R-dbcreate$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(dbcreate)

#cds2db::initDatabaseScripts()
