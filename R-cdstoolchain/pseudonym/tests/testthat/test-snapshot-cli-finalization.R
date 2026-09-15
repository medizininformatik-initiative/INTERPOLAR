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
      if (scenario == "error") {
        expect_true(any(grepl("Synthetic workload failure", log, fixed = TRUE)), info = info)
      }
    }
  }
})
