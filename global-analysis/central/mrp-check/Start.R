# Run from the repository root, on the host or in the r-env container.
arguments <- commandArgs(trailingOnly = TRUE)
if (identical(arguments, "--help")) {
  cat("Usage: Rscript global-analysis/central/mrp-check/Start.R [selection.csv]\n",
    "Checks selected input files and writes an input manifest; does not aggregate MRPs.\n",
    sep = ""
  )
  quit(status = 0L, save = "no")
}
if (length(arguments) > 1L || any(startsWith(arguments, "--"))) {
  stop("Expected an optional selection CSV path; use --help for usage.", call. = FALSE)
}

analysis_dir <- file.path("global-analysis")
source(file.path(analysis_dir, "R", "input.R"))
config_file <- if (length(arguments)) arguments[[1L]] else {
  file.path(analysis_dir, "central", "mrp-check", "config", "sites.csv")
}
input_dir <- "inputGlobal"
results_dir <- file.path("outputCentral", "mrp-check")

manifest <- loadGlobalAnalysisInputs(config_file, input_dir)
manifest$checked_at_utc <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
manifest$selection_md5 <- unname(tools::md5sum(config_file))
# Available through the existing read-only .git mount; absence is recorded explicitly.
code_commit <- suppressWarnings(tryCatch(
  system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
  error = function(error) character()
))
manifest$code_commit <- if (length(code_commit) == 1L &&
  grepl("^[a-f0-9]{40}$", code_commit)) code_commit else "unavailable"

dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
# tempfile supplies a unique run directory even for repeated calls in the same second.
run_dir <- tempfile(
  pattern = paste0(format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC"), "-"),
  tmpdir = results_dir
)
if (!dir.create(run_dir)) stop("Could not create result directory: ", run_dir)
manifest_file <- file.path(run_dir, "input-manifest.csv")
utils::write.csv(manifest, manifest_file, row.names = FALSE, na = "")
cat("Checked", nrow(manifest), "selected site export(s).\n")
cat("Input manifest:", manifest_file, "\n")
cat("Input check only: Excel contents and MRP results have not been evaluated.\n")
