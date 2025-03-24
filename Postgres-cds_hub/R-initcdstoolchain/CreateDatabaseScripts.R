##############################################################################################
# Preferences: The current working directory must be the main project directory.             #
#              In interactive setting this is the parent directory of the R-initcdstoolchain #
#              directory.                                                                    #
##############################################################################################

# chance the working directory to the main directory
if (grepl('/initcdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-initcdstoolchain$', getwd())) setwd("../")
if (grepl('/Postgres-cds_hub$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(initcdstoolchain)

start <- Sys.time()
initcdstoolchain::initDatabaseScripts()
end <- Sys.time()
print(end - start)
