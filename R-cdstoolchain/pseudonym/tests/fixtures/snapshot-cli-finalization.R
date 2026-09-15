# Run the real CLI in a separate process: logging sinks and quit() must not
# interfere with testthat. Only configuration, database access and workload
# are stubbed; finalize(), the clock, log writing and cleanup are real.
args <- commandArgs(trailingOnly = TRUE)
repo_root <- args[[1L]]
script <- args[[2L]]
scenario <- args[[3L]]
output_root <- args[[4L]]
setwd(repo_root)
pkgload::load_all("R-etlutils/etlutils", quiet = TRUE)
pkgload::load_all("R-cdstoolchain/pseudonym", quiet = TRUE)

runCli <- function() {
  testthat::local_mocked_bindings(
    initCommandLineArguments = function(defaults) {
      utils::modifyList(defaults, list(source_db = "synthetic", target_db = "synthetic_target"))
    },
    initModule = function(module_name, ...) {
      assign("MODULE_NAME", module_name, envir = .GlobalEnv)
      list(INPUT_REPO_PATH = "synthetic")
    },
    startModule = function(...) {
      assign("VERBOSE", 100L, envir = .GlobalEnv)
      dirs <- list(local_dir = file.path(output_root, "local"), global_dir = file.path(output_root, "global"))
      assign("MODULE_DIRS", dirs, envir = .GlobalEnv)
      for (dir in c(
        file.path(dirs$local_dir, "log"), file.path(dirs$local_dir, "performance"),
        file.path(dirs$global_dir, "performance")
      )) dir.create(dir, recursive = TRUE)
      etlutils::createClock()
      etlutils::startLogging(get("MODULE_NAME", envir = .GlobalEnv))
    },
    readTomlAsNamedList = function(...) list(),
    dbCreateConnection = function(...) NULL,
    .package = "etlutils"
  )
  workload <- function(...) {
    etlutils::runLevel2("Synthetic snapshot phase", {
      cat("\033[31mSynthetic progress\033[0m\n")
      TRUE
    })
    # The CLI catches this error, but the logger has no ERROR state. Its
    # successful finalization must not turn the CLI exit status back to zero.
    if (scenario == "error") stop("Synthetic workload failure")
    list(issue_report = list(
      medication_issue_summary = list(UNMATCHED_ROWS = 0L),
      age_issue_summary = list(AFFECTED_ROWS = 0L),
      loinc_unit_conversion_issues = list(AFFECTED_ROWS = 0L)
    ))
  }
  testthat::local_mocked_bindings(
    preflightSnapshotPseudonymization = workload,
    pseudonymizeSnapshotDatabase = workload,
    createBroadConsentSnapshotDatabase = workload,
    .package = "pseudonym"
  )
  source(file.path("R-cdstoolchain", script), local = new.env(parent = .GlobalEnv))
}
runCli()
