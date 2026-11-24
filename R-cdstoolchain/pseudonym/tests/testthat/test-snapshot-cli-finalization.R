test_that("snapshot CLIs finalize logs and performance on success and failure", {
  repo_root <- normalizePath(testthat::test_path("../../../.."))
  worker <- normalizePath(testthat::test_path("../fixtures/snapshot-cli-finalization.R"))
  root <- tempfile("snapshot_cli_finalization_")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE))
  scripts <- c(
    "StartSnapshotPseudonymization.R", "StartSnapshotPseudonymizationPreflight.R",
    "StartBroadConsentSnapshot.R"
  )
  for (script in scripts) {
    for (scenario in c("success", "error")) {
      output_root <- file.path(root, paste0(script, "_", scenario))
      dir.create(output_root)
      console <- file.path(output_root, "console.txt")
      status <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
        shQuote(c(worker, repo_root, script, scenario, output_root)),
        stdout = console, stderr = console
      ))
      info <- paste(script, scenario)
      expect_equal(status, if (scenario == "error") 1L else 0L, info = info)
      logs <- list.files(file.path(output_root, "local", "log"), full.names = TRUE)
      expect_equal(length(logs), 1L, info = info)
      if (script %in% c("StartSnapshotPseudonymization.R", "StartSnapshotPseudonymizationPreflight.R")) {
        expect_equal(basename(logs), "snapshot_pseudonymization-log.txt", info = info)
      }
      if (script == "StartSnapshotPseudonymizationPreflight.R") {
        expect_equal(
          readLines(file.path(output_root, "review-path.txt")),
          "./outputLocal/snapshot_pseudonymization/reports/pseudonymization_rule_review.xlsx",
          info = info
        )
      }
      if (length(logs) != 1L) next
      log <- readLines(logs[[1L]], warn = FALSE)
      expect_false(any(grepl("\033", log, fixed = TRUE)), info = info)
      expect_true(any(grepl("Synthetic progress", log, fixed = TRUE)), info = info)
      expect_true(any(grepl("For more information, check the log file:", readLines(console), fixed = TRUE)), info = info)
      for (scope in c("local", "global")) {
        performance <- file.path(output_root, scope, "performance", "Performance_informations.tsv")
        expect_true(file.exists(performance), info = info)
        if (!file.exists(performance)) next
        timings <- utils::read.delim(performance)
        expect_true("Synthetic snapshot phase" %in% timings$msg, info = info)
      }
      if (script == "StartSnapshotPseudonymization.R" && scenario == "success") {
        expect_true(any(grepl("INFO: Snapshot pseudonymization completed successfully: 1000 input rows processed, 1200 output rows written.", log, fixed = TRUE)))
        expect_true(any(grepl("20 lab values retained with source value and unit; 3 medication reference issues; 2 age values could not be calculated.", log, fixed = TRUE)))
        expect_false(any(grepl("WARNING:", log, fixed = TRUE)))
      }
      if (scenario == "error") {
        expect_true(any(grepl("Synthetic workload failure", log, fixed = TRUE)), info = info)
      }
    }
  }
})


test_that("successive pseudonymization starts retain reports through normal archiving", {
  root <- tempfile("snapshot_output_")
  dir.create(root)
  old_working_directory <- setwd(root)
  had_module_dirs <- exists("MODULE_DIRS", envir = .GlobalEnv, inherits = FALSE)
  old_module_dirs <- if (had_module_dirs) get("MODULE_DIRS", envir = .GlobalEnv) else NULL
  on.exit({
    setwd(old_working_directory)
    unlink(root, recursive = TRUE)
    if (had_module_dirs) {
      assign("MODULE_DIRS", old_module_dirs, envir = .GlobalEnv)
    } else if (exists("MODULE_DIRS", envir = .GlobalEnv, inherits = FALSE)) {
      rm("MODULE_DIRS", envir = .GlobalEnv)
    }
  })

  first <- etlutils::createDIRS("snapshot_pseudonymization")
  for (scope in c("local", "global")) {
    writeLines("previous report", file.path(first[[paste0(scope, "_dir")]], "reports", "report.txt"))
  }
  second <- etlutils::createDIRS("snapshot_pseudonymization")
  for (scope in c("local", "global")) {
    current <- second[[paste0(scope, "_dir")]]
    archived <- second[[paste0("last_", scope, "_dir")]]
    expect_equal(current, first[[paste0(scope, "_dir")]])
    expect_true(dir.exists(file.path(current, "reports")))
    expect_false(file.exists(file.path(current, "reports", "report.txt")))
    expect_equal(readLines(file.path(archived, "reports", "report.txt")), "previous report")
  }
})
