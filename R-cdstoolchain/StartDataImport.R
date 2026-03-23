library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

etlutils::setProcess("DataImport")
.data_import_env <- new.env() # save Variables which should not be deleted in StartCDSToolChain$resetMemory()

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

.data_import_env$cache_files_count <- cds2db::initCache(delete_old_cache = skipPreviousDataImport())
TOOLCHAIN_DAY <- 1
source("./R-cdstoolchain/StartCDSToolChain.R")
if (status == 0) { # status is set by StartCDSToolChain.R
  .data_import_env$cache_files_count <- cds2db::deleteNextCacheFile()
}

for (cache_file_index in seq_len(.data_import_env$cache_files_count)) {
  TOOLCHAIN_DAY <- TOOLCHAIN_DAY + 1
  source("./R-cdstoolchain/StartCDSToolChain.R")
  if (status == 0) { # status is set by StartCDSToolChain.R
    cds2db::deleteNextCacheFile()
  } else {
    break
  }
}

if (status != 0 || etlutils::hasNextCacheFile()) {
  etlutils::catErrorMessage("An error occured during the data import. Please check the last log files of the submodules for details.")
}
