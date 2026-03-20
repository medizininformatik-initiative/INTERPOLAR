library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

etlutils::setProcess("DataImport")

mustFinishPreviousDataImport <- function() {
  # TODO: implementieren
  return(FALSE)
}

skipPreviousDataImport <- function() {
  skip <- FALSE
  args <- commandArgs(trailingOnly = TRUE)
  for (arg in args) {
    if (arg %in% c("--skipPreviousRun")) {
      skip <- TRUE
    } else if (!arg %in% c("--ignoreNewerDBVersion")) {
      stop("Unknown argument: ", arg, "\nAllowed arguments: --skipPreviousRun, --ignoreNewerDBVersion")
    }
  }
  skip
}

cds2db::registerCache("data_import_pids_splitted_by_ward")

if (skipPreviousDataImport()) {
  cds2db::deleteAllCacheFiles()
}

source("./R-cdstoolchain/StartCDSToolChain.R")
if (status == 0) { # status is set by StartCDSToolChain.R
  cds2db::deleteNextCacheFile()
}

cache_files_count <- cds2db::getCacheFilesCount()
for (cache_file_index in seq_len(cache_files_count)) {
  source("./R-cdstoolchain/StartCDSToolChain.R")
  if (status == 0) { # status is set by StartCDSToolChain.R
    cds2db::deleteNextCacheFile()
  } else {
    break
  }
}

if (status != 0 || cds2db::hasNextCacheFile()) {
  etlutils::catErrorMessage("An error occured during the data import. Please check the last log files of the submodules for details.")
}
