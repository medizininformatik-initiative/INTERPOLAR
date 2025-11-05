# change the working directory to the main directory
if (grepl('/cdstoolchain', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain', getwd())) setwd("../")

# Orchestrate building, installing, and running a multi-package R project
# Assumes working directory is the project root where relative paths work.

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

buildAndInstall <- function(pkg_dir) {
  # Build source tarball and install it (like R CMD INSTALL)
  withr::with_dir(pkg_dir, {
    if (!file.exists("DESCRIPTION")) {
      stop("No DESCRIPTION found in: ", normalizePath(pkg_dir))
    }
    desc <- readLines("DESCRIPTION", warn = FALSE)
    pkg_name <- sub("^Package:\\s*", "", grep("^Package:", desc, value = TRUE))

    logInfo("Processing package: ", pkg_name, " (", normalizePath(pkg_dir), ")")

    logInfo("  • Roxygenize")
    roxygen2::roxygenise()

    if (isTRUE(run_tests)) {
      logInfo("  • Testing")
      testthat::test_local()
    }

    logInfo("  • Building source tarball")
    tarball <- pkgbuild::build(path = ".", dest_path = tempdir(), binary = FALSE)

    logInfo("  • Installing from ", basename(tarball))
    install.packages(
      tarball,
      repos = NULL,
      type = "source",
      Ncpus = max(1L, parallel::detectCores(logical = TRUE) - 1L)
    )
  })
}

# ---- Orchestration (scoped so on.exit works) ---------------------------------
local({
  ensurePackages(c("withr", "roxygen2", "pkgbuild", "testthat"))

  start_time <- Sys.time()
  on.exit({
    total <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 1)
    logInfo("All done in ", total, "s")
  }, add = TRUE)

  for (pkg_dir in package_dirs) {
    buildAndInstall(pkg_dir)
  }
})

# ---- Run main script of last package in GLOBAL env ---------------------------
# DEBUG_START_SINGLE_MODULE <- "dataprocessor"
# DEBUG_SUBMODULE_DIR <- "./R-dataprocessor/submodules/02_MRP_Calculation"
# DEBUG_RUN_SINGLE_DAY_ONLY <- 2
source("R-cdstoolchain/StartDebugCDSToolChain.R", local = FALSE)
