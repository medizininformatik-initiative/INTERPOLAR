# Activate this only if you know what you are doing!
I_KNOW_THAT_THE_DATABASE_AND_REDCAP_WILL_BE_DELETED = FALSE

# change the working directory to the main directory
if (grepl('/cdstoolchain', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain', getwd())) setwd("../")

if (!I_KNOW_THAT_THE_DATABASE_AND_REDCAP_WILL_BE_DELETED) {
  stop("You must set I_KNOW_THAT_THE_DATABASE_AND_REDCAP_WILL_BE_DELETED = TRUE to run this script!")
}

library(etlutils)
library(cds2db)

etlutils::setProcess("DebugDataImport")
.start_debug_data_import_env <- new.env()

# Reset error status
options(error = NULL)

.start_debug_data_import_env$start_full <- Sys.time()

if (I_KNOW_THAT_THE_DATABASE_AND_REDCAP_WILL_BE_DELETED) {
  source("./R-cdstoolchain/DeleteDBAndREDCap.R", local = FALSE)
}

############################
### START TEST DEFINITON ###
############################

###
# Set the index of the data-import test that should be run.
###
DEBUG_TEST_INDEX <- 1

DEBUG_TEST_FILE_SUFFIX <- ""

##########################
### END TEST DEFINITON ###
##########################

getCheckDataImportFileName <- function(test_index, test_file_suffix = "") {
  if (exists("DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME")) {
    return(DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME)
  }

  test_index <- sprintf("%02d", as.integer(test_index))
  check_data_import_file_name <- paste0(
    "./R-cds2db/test/test_",
    test_index,
    test_file_suffix,
    "_check_Data_Import.R"
  )

  if (!file.exists(check_data_import_file_name)) {
    stop("Data-import test file not found: ", check_data_import_file_name)
  }

  check_data_import_file_name
}

debug_test_file_suffix <- if (exists("DEBUG_TEST_FILE_SUFFIX")) DEBUG_TEST_FILE_SUFFIX else ""
DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME <- getCheckDataImportFileName(DEBUG_TEST_INDEX, debug_test_file_suffix)

normalizeDebugDataImportTargets <- function(envir = .GlobalEnv) {
  if (!exists("DEBUG_DATA_IMPORT_TARGETS", envir = envir)) {
    stop("The data-import test file must define DEBUG_DATA_IMPORT_TARGETS.")
  }

  targets <- get("DEBUG_DATA_IMPORT_TARGETS", envir = envir)
  if (!is.list(targets) || !length(targets)) {
    stop("DEBUG_DATA_IMPORT_TARGETS must be a non-empty list.")
  }

  normalized_targets <- lapply(seq_along(targets), function(i) {
    target <- targets[[i]]
    if (!is.list(target) || is.null(target$resource) || is.null(target$columns)) {
      stop("Each DEBUG_DATA_IMPORT_TARGETS entry must define 'resource' and 'columns'. Invalid entry index: ", i)
    }
    resource <- as.character(target$resource)[1]
    columns <- unique(as.character(target$columns))
    columns <- columns[nzchar(columns)]
    if (!nzchar(resource) || !length(columns)) {
      stop("Each DEBUG_DATA_IMPORT_TARGETS entry must contain one non-empty resource and at least one non-empty column. Invalid entry index: ", i)
    }
    list(resource = resource, columns = columns)
  })
  normalized_targets
}

flattenDebugDataImportTargets <- function(targets) {
  flattened_targets <- list()
  for (target in targets) {
    for (column_name in target$columns) {
      flattened_targets[[length(flattened_targets) + 1L]] <- list(
        resource = target$resource,
        column = column_name
      )
    }
  }
  flattened_targets
}

# Source the test file once to load its configuration variables. The file must
# not execute its RAW manipulation logic unless resource_tables exists.
source(DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME, local = FALSE)

.start_debug_data_import_env$targets <- normalizeDebugDataImportTargets()
.start_debug_data_import_env$flat_targets <- flattenDebugDataImportTargets(.start_debug_data_import_env$targets)

countFilledRows <- function(resource_type, column_name) {
  cds2db::init(validate_config = FALSE)
  query <- paste0(
    "SELECT COUNT(*) AS filled_rows\n",
    "FROM v_", tolower(resource_type), "_last_version\n",
    "WHERE ", column_name, " IS NOT NULL;\n"
  )
  result <- etlutils::dbGetReadOnlyQuery(
    query,
    lock_id = paste0("StartDebugDataImport.countFilledRows(", resource_type, ".", column_name, ")")
  )
  as.integer(result$filled_rows[[1]])
}

getFilledRowsCounts <- function(step_label, flat_targets) {
  counts <- integer(length(flat_targets))
  count_names <- character(length(flat_targets))
  output_lines <- character(length(flat_targets))

  for (i in seq_along(flat_targets)) {
    target <- flat_targets[[i]]
    counts[[i]] <- countFilledRows(target$resource, target$column)
    count_names[[i]] <- paste0(target$resource, "$", target$column)
    output_lines[[i]] <- paste0(
      "[", step_label, "] Filled rows for ",
      count_names[[i]], ": ",
      counts[[i]]
    )
  }

  names(counts) <- count_names
  cat("\n", paste(output_lines, collapse = "\n"), "\n", sep = "")
  counts
}

if (!exists("DEBUG_DATA_IMPORT_RUN_ONLY_CDS2DB") || isTRUE(DEBUG_DATA_IMPORT_RUN_ONLY_CDS2DB)) {
  assign("DEBUG_START_SINGLE_MODULE", "cds2db", envir = .GlobalEnv)
}

# Step 1: regular import (StartCDSToolChain) with forced NA in the selected RAW column.
source("./R-cdstoolchain/StartCDSToolChain.R", local = FALSE)
.start_debug_data_import_env$filled_rows_before <- getFilledRowsCounts(
  "after initial import",
  .start_debug_data_import_env$flat_targets
)

# Step 2: resource type data import (StartDataImport).
rm(
  list = c("DEBUG_CHANGE_RAW_DATA_SCRIPT_NAME"),
  envir = .GlobalEnv
)
source("./R-cdstoolchain/StartDataImport.R", local = FALSE)
.start_debug_data_import_env$filled_rows_after <- getFilledRowsCounts(
  "after data import",
  .start_debug_data_import_env$flat_targets
)

improved_targets <- .start_debug_data_import_env$filled_rows_after > .start_debug_data_import_env$filled_rows_before

if (all(improved_targets)) {
  cat(
    "\nDataImport test succeeded for all configured targets.\n"
  )
} else {
  failed_targets <- names(improved_targets)[!improved_targets]
  cat(
    paste0(
      "\nDataImport test did not show an increase for: ",
      paste(failed_targets, collapse = ", "),
      ". Check logs, selected resource type, and whether the source data actually contains the field.\n"
    )
  )
}

.start_debug_data_import_env$end_full <- Sys.time()
diff <- capture.output(print(.start_debug_data_import_env$end_full - .start_debug_data_import_env$start_full))
print(paste("All steps took", diff))
