# change the working directory to the main directory
if (grepl('/cdstoolchain', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain', getwd())) setwd("../")

# Orchestrate building, installing, and running a multi-package R project
# Assumes working directory is the project root where relative paths work.

# ---- Config ------------------------------------------------------------------

VM_PORT_INDEX <- 4 # will be set as port prefix in config files (1-5)

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

# Replace the single digit before fixed suffixes with VM_PORT_INDEX (minimal change)
patchConfigPorts <- function(VM_PORT_INDEX) {
  stopifnot(VM_PORT_INDEX %in% 1:5)

  # REDCap config: REDCAP_URL = "http://127.0.0.1:X8082/redcap/api/"
  redcap_path <- "R-db2frontend/db2frontend_config.toml"
  rc_lines <- readLines(redcap_path, warn = FALSE)
  rc_before <- grep('^\\s*REDCAP_URL\\s*=\\s*".*"', rc_lines, value = TRUE)

  rc_pattern <- '(REDCAP_URL\\s*=\\s*"http://127\\.0\\.0\\.1:)\\d(8082/redcap/api/")'
  rc_repl    <- paste0("\\1", VM_PORT_INDEX, "\\2")

  rc_lines2 <- sub(rc_pattern, rc_repl, rc_lines)
  rc_after  <- grep('^\\s*REDCAP_URL\\s*=\\s*".*"', rc_lines2, value = TRUE)

  writeLines(rc_lines2, redcap_path)
  logInfo("Patched REDCAP_URL in ", redcap_path,
          "\n  before: ", rc_before %||% "<not found>",
          "\n  after : ",  rc_after  %||% "<not found>")

  # DB config: DB_PORT = X5432
  db_path <- "cds_hub_db_config.toml"
  db_lines <- readLines(db_path, warn = FALSE)
  db_before <- grep('^\\s*DB_PORT\\s*=\\s*\\d+', db_lines, value = TRUE)

  db_pattern <- '(DB_PORT\\s*=\\s*)\\d(5432)\\b'
  db_repl    <- paste0("\\1", VM_PORT_INDEX, "\\2")

  db_lines2 <- sub(db_pattern, db_repl, db_lines)
  db_after  <- grep('^\\s*DB_PORT\\s*=\\s*\\d+', db_lines2, value = TRUE)

  writeLines(db_lines2, db_path)
  logInfo("Patched DB_PORT in ", db_path,
          "\n  before: ", db_before %||% "<not found>",
          "\n  after : ",  db_after  %||% "<not found>")
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

  # Patch configs upfront based on VM_PORT_INDEX
  patchConfigPorts(VM_PORT_INDEX)

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
source("R-cdstoolchain/StartDebugCDSToolChain.R", local = FALSE)
