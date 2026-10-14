# Synthetic input files suffice: the scaffold deliberately does not parse Excel contents.
source("global-analysis/R/input.R")
test_root <- tempfile("global-analysis-test-")
dir.create(test_root)

runTests <- function(test_root) {
  input_dir <- file.path(test_root, "input")
  export_dir <- file.path(input_dir, "SITE_A", "export_1", "outputGlobal", "tables")
  dir.create(export_dir, recursive = TRUE)
  source_file <- file.path(export_dir, "mrp.xlsx")
  writeLines("synthetic input for file validation", source_file)
  config_file <- file.path(test_root, "sites.csv")
  selection <- data.frame(
    site_id = "SITE_A", export_id = "export_1", mrp_check_file = "tables/mrp.xlsx"
  )
  writeSelection <- function(value) utils::write.csv(value, config_file, row.names = FALSE)
  expectFailure <- function(expression, pattern) {
    error <- tryCatch(
      {
        force(expression)
        NULL
      },
      error = identity
    )
    stopifnot(inherits(error, "error"), grepl(pattern, conditionMessage(error)))
  }
  writeSelection(selection)
  result <- loadGlobalAnalysisInputs(config_file, input_dir)
  stopifnot(
    nrow(result) == 1L,
    identical(result$source_file, normalizePath(source_file)),
    identical(result$source_md5, unname(tools::md5sum(source_file)))
  )
  writeSelection(rbind(selection, selection))
  expectFailure(loadGlobalAnalysisInputs(config_file, input_dir), "exactly one export")
  invalid <- selection
  invalid$mrp_check_file <- "../mrp.xlsx"
  writeSelection(invalid)
  expectFailure(loadGlobalAnalysisInputs(config_file, input_dir), "relative path")
  invalid$mrp_check_file <- "tables/missing.xlsx"
  writeSelection(invalid)
  expectFailure(loadGlobalAnalysisInputs(config_file, input_dir), "file not found")
  invalid$site_id <- " "
  writeSelection(invalid)
  expectFailure(loadGlobalAnalysisInputs(config_file, input_dir), "blank values")
  writeSelection(selection[0, ])
  expectFailure(loadGlobalAnalysisInputs(config_file, input_dir), "must contain rows")
  writeSelection(selection)
  writeLines(character(), source_file)
  expectFailure(loadGlobalAnalysisInputs(config_file, input_dir), "zero bytes")
  expectFailure(loadGlobalAnalysisInputs(file.path(test_root, "missing.csv"), input_dir), "selection not found")

  # Exercise the real console entry point in an isolated project directory.
  project_dir <- file.path(test_root, "project")
  dir.create(project_dir)
  project_analysis <- file.path(project_dir, "global-analysis")
  dir.create(project_analysis)
  stopifnot(file.copy("global-analysis/R", project_analysis, recursive = TRUE))
  central_dir <- file.path(project_analysis, "central", "mrp-check")
  dir.create(file.path(central_dir, "config"), recursive = TRUE)
  stopifnot(file.copy("global-analysis/central/mrp-check/Start.R", central_dir))
  dir.create(file.path(project_dir, "inputGlobal"), recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(file.path(input_dir, "SITE_A"), file.path(project_dir, "inputGlobal"), recursive = TRUE))
  writeLines("synthetic input", file.path(
    project_dir, "inputGlobal", "SITE_A", "export_1", "outputGlobal", "tables", "mrp.xlsx"
  ))
  file.copy(config_file, file.path(project_analysis, "central", "mrp-check", "config", "sites.csv"), overwrite = TRUE)
  previous_wd <- getwd()
  on.exit(setwd(previous_wd), add = TRUE)
  setwd(project_dir)
  script <- "global-analysis/central/mrp-check/Start.R"
  stopifnot(system2(file.path(R.home("bin"), "Rscript"), c(script, "--help")) == 0L)
  stopifnot(system2(file.path(R.home("bin"), "Rscript"), script) == 0L)
  stopifnot(system2(file.path(R.home("bin"), "Rscript"), script) == 0L)
  manifests <- list.files("outputCentral", "input-manifest.csv", recursive = TRUE, full.names = TRUE)
  stopifnot(length(manifests) == 2L)
  manifest <- utils::read.csv(manifests[[1L]])
  stopifnot(nrow(manifest) == 1L, manifest$site_id == "SITE_A", nzchar(manifest$source_md5))
  stopifnot(system2(file.path(R.home("bin"), "Rscript"), c(script, "missing.csv"), stdout = FALSE, stderr = FALSE) != 0L)
  stopifnot(length(list.files("outputCentral", "input-manifest.csv", recursive = TRUE)) == 2L)
}

tryCatch(runTests(test_root), finally = unlink(test_root, recursive = TRUE))
cat("Global analysis input and console checks passed.\n")
