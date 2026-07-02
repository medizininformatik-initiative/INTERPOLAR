# change the working directory to the main directory
if (grepl("/cdstoolchain", getwd())) setwd("../..")
if (grepl("/R-cdstoolchain", getwd())) setwd("../")

# Orchestrate building, installing, and running a multi-package R project
# Assumes working directory is the project root where relative paths work.

rm(list = ls())

# ---- Config ------------------------------------------------------------------

package_dirs <- c(
  "R-etlutils/etlutils",
  "R-cds2db/cds2db",
  "R-dataprocessor/dataprocessor",
  "R-db2frontend/db2frontend",
  "R-cdstoolchain/cdstoolchain"   # last package; will be run
)

run_tests <- FALSE

# ---- Utilities ---------------------------------------------------------------

`%||%` <- function(x, y) if (is.null(x)) y else x

ensurePackages <- function(pkgs) {
  # Install missing build-time packages
  missing <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(missing)) install.packages(missing)
}

logInfo <- function(...) {
  # Simple logger
  cat(paste0("[", format(Sys.time(), "%H:%M:%S"), "] ", paste0(...), "\n"))
}

install_from_rscript <- function(tarball) {

  rscript <- file.path(R.home("bin"), "Rscript")

  ncpus <- max(1L, parallel::detectCores(logical = TRUE) - 1L)

  script <- tempfile(fileext = ".R")

  writeLines(
    sprintf(
      "install.packages(%s, repos = NULL, type = 'source', Ncpus = %d)",
      shQuote(normalizePath(tarball, winslash = "/")),
      ncpus
    ),
    script
  )

  system2(rscript, script)
}

buildAndInstall <- function(pkg_dir) {
  # Build source tarball and install it (like R CMD INSTALL)
  withr::with_dir(pkg_dir, {
    if (!file.exists("DESCRIPTION")) {
      stop("No DESCRIPTION found in: ", pkg_dir)
    }
    desc <- readLines("DESCRIPTION", warn = FALSE)
    pkg_name <- sub("^Package:\\s*", "", grep("^Package:", desc, value = TRUE))

    logInfo("Processing package: ", pkg_name, " (", pkg_dir, ")")

    logInfo("  • Roxygenize")
    roxygen2::roxygenise()

    if (isTRUE(run_tests)) {
      logInfo("  • Testing")
      testthat::test_local()
    }

    logInfo("  • Building source tarball")
    tarball <- pkgbuild::build(path = ".", dest_path = tempdir(), binary = FALSE)

    logInfo("  • Installing from ", basename(tarball))

    cat("Tarball:", tarball, "\n")
    cat("Exists :", file.exists(tarball), "\n")

    install_from_rscript(tarball)
  })
}

# ---- Orchestration (scoped so on.exit works) ---------------------------------
local({
  ensurePackages(c("withr", "roxygen2", "pkgbuild", "testthat"))

  start_time <- Sys.time()
  on.exit(
    {
      total <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 1)
      logInfo("All done in ", total, "s")
    },
    add = TRUE
  )

  for (pkg_dir in package_dirs) {
    buildAndInstall(pkg_dir)
  }
})


############################
### START TEST DEFINITON ###
############################
###
# Set the index of the virtual machine that should be used for the debug run.
###
DEBUG_VM_INDEX <- 9
############################
### END TEST DEFINITON   ###
############################

DEBUG_VM_CONFIGS <- list(
  `0` = list(db_port = 5432,  redcap_port = 80,    redcap_token = "35784E25CB814491E49EE51641966B50", db_admin_password = "2389673289479283"), # local-VM
  `1` = list(db_port = 5432,  redcap_port = 8082,  redcap_token = "",                                 db_admin_password = "2389673289479283"), # MR
  `2` = list(db_port = 25432, redcap_port = 28082, redcap_token = "5DD4ECFDC245D8FC955B13D894875F62", db_admin_password = "2389673289479283"), # FS+AXS
  `3` = list(db_port = 35432, redcap_port = 8091,  redcap_token = "DFC537547BAC8ED8278EAB70BEA1BFF8", db_admin_password = "4432252352232"), # TB
  `4` = list(db_port = 45432, redcap_port = 48082, redcap_token = "",                                 db_admin_password = "2389673289479283"), # FS+AXS
  `5` = list(db_port = 55432, redcap_port = 58082, redcap_token = "",                                 db_admin_password = "2389673289479283"), # FS+AXS
  `6` = list(db_port = 25436, redcap_port = 28087, redcap_token = "35784E25CB814491E49EE51641966B50", db_admin_password = "2389673289479283"), # FS+AXS
  `7` = list(db_port = 15433, redcap_port = 8083,  redcap_token = "DBE20FDCAAECD5399C1691AD4ECF59C7", db_admin_password = "999987632746324"),  # TOP
  `8` = list(db_port = 1543,  redcap_port = 1082,  redcap_token = "5DD4ECFDC245D8FC955B13D894875F62", db_admin_password = "2389673289479283"), # local-R-FS
  `9` = list(db_port = 55435, redcap_port = 5085,  redcap_token = "35784E25CB814491E49EE51641966B50", db_admin_password = "2389673289479283")  # local-R-AXS
)

debug_vm_config <- DEBUG_VM_CONFIGS[[as.character(DEBUG_VM_INDEX)]]

DEBUG_DB_HOST <- if (DEBUG_VM_INDEX == 0L) "cds_hub" else "127.0.0.1"
DEBUG_DB_PORT <- debug_vm_config$db_port
if (!is.null(debug_vm_config$db_admin_password)) {
  DEBUG_DB_ADMIN_PASSWORD <- debug_vm_config$db_admin_password
} else if (exists("DEBUG_DB_ADMIN_PASSWORD")) {
  rm(DEBUG_DB_ADMIN_PASSWORD)
}
DEBUG_REDCAP_HOST <- if (DEBUG_VM_INDEX == 0L) "redcap" else "127.0.0.1"
DEBUG_REDCAP_PORT <- debug_vm_config$redcap_port
DEBUG_REDCAP_TOKEN <- debug_vm_config$redcap_token


# ---- Run main script of last package in GLOBAL env ---------------------------
# DEBUG_START_SINGLE_MODULE <- "dataprocessor" # wenn man das ausführt, dann wird nicht nochmal die Testdatei gesourct, weil das nur in cds2db passiert!
# DEBUG_SUBMODULE_DIR <- "./R-dataprocessor/submodules/02_MRP_Calculation"
# DEBUG_RUN_SINGLE_DAY_ONLY <- 2
# source("R-cdstoolchain/DeleteDBAndREDCap.R", local = FALSE)
# source("R-cdstoolchain/StartDebugCDSToolChain.R", local = FALSE)
# source("R-cdstoolchain/StartDataImport.R", local = FALSE)
# source("R-cdstoolchain/StartCDSToolChain.R", local = FALSE)
# source("R-cdstoolchain/StartDebugDataImport.R", local = FALSE)
# source("R-cdstoolchain/StartMRPRecalculation.R", local = FALSE)
