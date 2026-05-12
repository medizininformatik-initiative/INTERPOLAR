library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

etlutils::setProcess("DeleteDBAndREDCap")

# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")


# Reset error status
options(error = NULL)

start_full <- Sys.time()

if (interactive()) {
  # reset locks
  cds2db::resetLock()
  dataprocessor::resetLock()
  db2frontend::resetLockFrontend2DB()
  db2frontend::resetLockDB2Frontend()

  # delete DB
  config_cds2db <- cds2db::init()
  etlutils::dbReset()

  # delete REDCap
  config_db2frontend <- db2frontend::initFrontend2DB()
  db2frontend::deleteRedcapContent()

}

end_full <- Sys.time()
cat("DeleteDBAndREDCap took ", capture.output(print(end_full - start_full)), "\n")
quit(status = 1, save = "no")
