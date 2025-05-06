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

dataprocessor::processData()
