# chance the working directory to the main directory
if (grepl('/db2frontend$', getwd())) setwd("../..")
if (grepl('/R-db2frontend$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(db2frontend)

db2frontend::retrieve()
