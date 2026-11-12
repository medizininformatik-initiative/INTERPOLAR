test_that("global CSVs mask eligible small counts and retain exact diagnostic counts in every scope", {
  count_columns <- c("count", "patient_count", "case_count", "no_case_count", "medication_count", "medication_request_count", "medication_administration_count", "medication_statement_count", "unreferenced_medication_count")
  values <- c(0, 1, 4, 5, NA_real_)
  rows <- data.table::data.table(row_type = "detail", code = paste0("000", seq_along(values)), mean = 1:5)
  for (column in count_columns) data.table::set(rows, j = column, value = values)
  attr(rows, "table_family") <- "Codes"
  original <- data.table::copy(rows)
  reports <- list(Medication = rows)
  attr(reports, "local_reports") <- list(Medication = rows)
  variants <- c("all", "filtered", "all_age_ge18", "all_age_lt18", "filtered_age_ge18", "filtered_age_lt18")
  attr(reports, "export_variants") <- variants
  scopes <- lapply(variants[-1], function(variant) {
    scope <- list(Medication = rows)
    attr(scope, "local_reports") <- list(Medication = rows)
    attr(scope, "scope_label") <- toupper(variant)
    scope
  })
  names(scopes) <- variants[-1]
  attr(reports, "variant_reports") <- scopes
  root <- tempfile("code-mask-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  old_dirs <- if (exists("MODULE_DIRS", inherits = TRUE)) get("MODULE_DIRS", inherits = TRUE) else NULL
  assign("MODULE_DIRS", list(global_dir = file.path(root, "global"), local_dir = file.path(root, "local")), envir = .GlobalEnv)
  on.exit(
    {
      if (is.null(old_dirs)) rm("MODULE_DIRS", envir = .GlobalEnv) else assign("MODULE_DIRS", old_dirs, envir = .GlobalEnv)
    },
    add = TRUE
  )
  for (target in c("global", "local")) {
    archive <- writeCodeSummaryArchive(reports, "DQA", timestamp = as.POSIXct("2026-11-12", tz = "UTC"), target = target)
    folder <- file.path(root, paste0(target, "-csv"))
    utils::unzip(archive, exdir = folder)
    csvs <- list.files(file.path(folder, "Codes"), full.names = TRUE)
    expect_length(csvs, 6L)
    for (csv in csvs) {
      exported <- data.table::fread(csv, colClasses = "character", na.strings = "")
      expect_equal(exported$code, rows$code)
      expect_equal(exported$mean, as.character(rows$mean))
      for (column in count_columns) {
        expect_equal(exported[[column]], if (target == "global" && !column %in% c("no_case_count", "unreferenced_medication_count")) c("0", "<5", "<5", "5", NA_character_) else as.character(values))
      }
    }
  }
  expect_equal(rows, original)
  expect_equal(reports$Medication, original)
  expect_equal(attr(reports, "local_reports")$Medication, original)
})

test_that("small code batches retain rare details without rare-pool SQL", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_exports$variants <- "all"
  run <- function() createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_false(grepl("frequencies AS|rare_groups|other \\(count < 5\\)", query))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  reference <- run()
  fixture$config$code_summary_processing <- list(enabled = TRUE, target_rows_per_chunk = 5, max_codes_per_chunk = 1L)
  batched <- run()
  for (resource in names(reference)) {
    normalize <- function(rows) {
      rows <- data.table::copy(rows)
      data.table::setorderv(rows, intersect(c("system", "coding_path", "row_type", "code", "low", "high"), names(rows)), na.last = TRUE)
      rows
    }
    expect_equal(normalize(batched[[resource]]), normalize(reference[[resource]]), tolerance = 1e-12)
    expect_equal(batched[[resource]], attr(batched, "local_reports")[[resource]])
  }
  expect_equal(batched$Observation[row_type == "detail" & code == "r1", count], 1)
  expect_equal(batched$Medication[row_type == "detail" & code == "B01", count], 1)
})
