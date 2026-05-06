library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

etlutils::setProcess("DataImport")
.data_import_env <- new.env() # save Variables which should not be deleted in StartCDSToolChain$resetMemory()

config_cds2db <- cds2db::init(validate_config = FALSE)
if (etlutils::isDefinedAndNotEmpty("DATA_IMPORT_RESOURCE_TYPES", envir = config_cds2db)) {
  etlutils::setSubProcess("DataImport.PIDDependant")
} else {
  etlutils::setSubProcess("DataImport.All")
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

.data_import_env$cache_files_count <- 0

if (etlutils::isSubProcess("DataImport.PIDDependant")) {
  source("./R-cdstoolchain/StartCDSToolChain.R")
} else if (etlutils::isSubProcess("DataImport.All")) {
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
}

if (status != 0 || (etlutils::isSubProcess("DataImport.All") && etlutils::hasNextCacheFile())) {
  etlutils::catErrorMessage("An error occured during the data import. Please check the last log files of the submodules for details.")
}
