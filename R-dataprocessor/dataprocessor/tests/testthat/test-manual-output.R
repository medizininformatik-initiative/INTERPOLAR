test_that("manual filenames distinguish live, snapshot types and UTC run time", {
  run_time <- as.POSIXct("2026-11-12 12:30:00", tz = "Europe/Berlin")
  context <- function(database, type = NA_character_) {
    buildManualOutputContext(database, type, "2.1.0-rc.1", run_time)
  }
  expect_identical(
    context("cds_hub_db"),
    "run-2026-11-12_11-30-00Z_toolchain-2.1.0-rc.1_live"
  )
  expect_match(
    context("ip_snapshot_20260903"),
    "_snapshot$"
  )
  expect_match(
    context("ip_snapshot_20260903_pseud"),
    "_pseudonymized_snapshot$"
  )
  expect_match(
    context("ip_snapshot_20260903_pseud_broad_consent"),
    "_pseudonymized_snapshot$"
  )
  expect_match(
    context("custom_snapshot", "pseudonymized_snapshot"),
    "_pseudonymized_snapshot$"
  )
  expect_match(context("custom_database"), "_unknown$")
  expect_false(grepl("2026-09-03|20260903", context("ip_snapshot_20260903_pseud")))
  expect_match(
    context("ip_snapshot_20260903_pseud", "unpseudonymized_snapshot"),
    "_snapshot$"
  )
  expect_error(
    buildManualOutputContext("cds_hub_db", NA_character_, "../secret", run_time),
    "Invalid toolchain release version"
  )
})

test_that("only outputs written by the current run receive provenance", {
  root <- tempfile("manual-output-")
  on.exit(unlink(root, recursive = TRUE))
  module_dirs <- list(global_dir = file.path(root, "global"), local_dir = file.path(root, "local"))
  global_reports <- file.path(module_dirs$global_dir, "reports")
  local_tables <- file.path(module_dirs$local_dir, "tables")
  dir.create(global_reports, recursive = TRUE)
  dir.create(local_tables, recursive = TRUE)
  old_report <- file.path(global_reports, "old.xlsx")
  overwritten_report <- file.path(global_reports, "overwrite.xlsx")
  writeLines("old report", old_report)
  writeLines("old report", overwritten_report)
  before <- getManualOutputFiles(module_dirs)
  writeLines("replaced with new report content", overwritten_report)
  new_report <- file.path(global_reports, "summary.zip")
  local_report <- file.path(local_tables, "Example_Check_Result_local.xlsx")
  writeLines("new report", new_report)
  writeLines("local report", local_report)
  context <- "run-2026-11-12_11-30-00Z_toolchain-2.1.0_live"
  expect_message(paths <- nameManualOutputs(before, module_dirs, context), "Manual output:")
  expect_length(paths, 3L)
  expect_true(all(file.exists(paths)))
  expect_true(all(endsWith(paths, paste0(context, ".", tools::file_ext(paths)))))
  expect_true(file.exists(old_report))
  expect_false(any(file.exists(c(new_report, local_report, overwritten_report))))
  expect_identical(readLines(paths[grepl("overwrite", paths)]), "replaced with new report content")
  expect_length(nameManualOutputs(getManualOutputFiles(module_dirs), module_dirs, context), 0L)
})

test_that("manual output collisions never overwrite an existing release", {
  root <- tempfile("manual-collision-")
  on.exit(unlink(root, recursive = TRUE))
  module_dirs <- list(global_dir = root, local_dir = file.path(root, "local"))
  dir.create(file.path(root, "reports"), recursive = TRUE)
  before <- getManualOutputFiles(module_dirs)
  writeLines("new", file.path(root, "reports", "report.csv"))
  writeLines("existing", file.path(root, "reports", "report_context.csv"))
  expect_error(nameManualOutputs(before, module_dirs, "context"), "filename collision")
  expect_identical(readLines(file.path(root, "reports", "report_context.csv")), "existing")
  expect_true(file.exists(file.path(root, "reports", "report.csv")))
})

test_that("manual provenance is applied by the loader only after a successful run", {
  root <- tempfile("manual-loader-")
  on.exit(unlink(root, recursive = TRUE))
  manual_dir <- file.path(root, "manual", "Example_Analysis")
  automatic_dir <- file.path(root, "automatic")
  dir.create(manual_dir, recursive = TRUE)
  dir.create(automatic_dir)
  module_dirs <- list(global_dir = file.path(root, "global"), local_dir = file.path(root, "local"))
  dir.create(file.path(module_dirs$global_dir, "reports"), recursive = TRUE)
  report_path <- file.path(module_dirs$global_dir, "reports", "report.csv")
  writeLines(
    sprintf("writeLines('report', %s)", encodeString(report_path, quote = '"')),
    file.path(manual_dir, "Start.R")
  )
  testthat::local_mocked_bindings(
    DATAPROCESSOR_SUBMODULES_PATH = automatic_dir,
    DATAPROCESSOR_MANUAL_START_PATH = dirname(manual_dir),
    sourceAllSubmodules = function() NULL,
    sourceSubmoduleRFiles = function(...) NULL,
    getManualOutputContext = function() "context"
  )
  testthat::local_mocked_bindings(
    setSubmoduleName = function(...) NULL,
    removeSubmoduleName = function(...) NULL,
    initSubmoduleConstants = function(...) list(),
    catList = function(...) NULL,
    runLevel1 = function(label, code) force(code),
    .package = "etlutils"
  )
  rlang::local_bindings(MODULE_DIRS = module_dirs, .env = .GlobalEnv)
  expect_message(runSubmodules("example-analysis"), "Manual output:")
  expect_true(file.exists(file.path(module_dirs$global_dir, "reports", "report_context.csv")))
  expect_false(file.exists(report_path))

  writeLines(c(
    sprintf("writeLines('partial report', %s)", encodeString(report_path, quote = '"')),
    "stop('analysis failed')"
  ), file.path(manual_dir, "Start.R"))
  expect_error(runSubmodules("example-analysis"), "analysis failed")
  expect_true(file.exists(report_path))
  expect_true(file.exists(file.path(module_dirs$global_dir, "reports", "report_context.csv")))
})


test_that("provenance reads the selected database and the executing code version", {
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) {
      expect_match(query, "current_database()", fixed = TRUE)
      expect_match(query, "database_content_type", fixed = TRUE)
      expect_null(lock_id)
      data.frame(
        database_name = "ip_example_20260903_pseud",
        database_content_type = "pseudonymized_snapshot"
      )
    },
    getReleaseVersion = function() "2.2.0",
    .package = "etlutils"
  )
  expect_match(
    getManualOutputContext(),
    "_toolchain-2.2.0_pseudonymized_snapshot$"
  )
})
