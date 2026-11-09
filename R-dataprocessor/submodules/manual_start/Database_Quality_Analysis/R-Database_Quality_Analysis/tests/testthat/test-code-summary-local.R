test_that("one query returns global suppression and complete local counts and statistics", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- paste0(
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,",
    "obs_code_system,obs_code_code,obs_value,obs_unit) VALUES ",
    "('rare1','Patient/p1','Encounter/e1','http://loinc.org','r2',100,'g/L');"
  )
  calls <- 0L
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      expect_equal(sum(gregexpr('FROM "pg_temp"."observation"', query, fixed = TRUE)[[1]] > 0L), 1L)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  local <- attr(reports, "local_reports", exact = TRUE)
  expect_named(local, names(reports))
  global_rare <- reports$Observation[row_type == "other (count < 5)"]
  expect_equal(global_rare$count, 2)
  expect_true(is.na(global_rare$code))
  expect_true(is.na(global_rare$mean))
  expect_false(any(local$Observation$row_type == "other (count < 5)"))
  rare <- local$Observation[row_type == "detail" & code %in% c("r1", "r2")]
  expect_equal(rare[code == "r1", count], 1)
  expect_equal(rare[code == "r1", mean], 100)
  expect_equal(rare[code == "r1", median], 100)
  expect_equal(rare[code == "r2", count], 2)
  expect_equal(rare[code == "r2", mean], 150)
  expect_equal(rare[code == "r2", sd], stats::sd(c(100, 200)))
  expect_true(all(rare$unit == "g/L"))
  expect_equal(local$Observation[row_type == "total", count], reports$Observation[row_type == "total", count])
  expect_equal(local$Observation[row_type == "detail" & code == "common", mean], 3.5)
  med <- local$Medication[row_type == "detail" & code == "B01"]
  expect_equal(med$count, 1)
  expect_equal(med$medication_count, 1)
  expect_equal(med$medication_request_count, 2)
  expect_equal(med$medication_administration_count, 3)
  expect_false(any(c("export_target", "own_id", "pid", "case_id", "value") %in% names(rare)))
})

test_that("local SNOMED detail retains codes and measurements below five", {
  fixture <- codeSummarySnomedFixture()
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  local <- attr(reports, "local_reports", exact = TRUE)
  rare <- local$Observation[row_type == "detail" & code == "267036007"]
  expect_equal(rare$count, 2)
  expect_equal(rare$mean, 1.5)
  expect_equal(rare$no_case_count, 2)
  medication <- local$Medication[row_type == "detail" & code == "372507007"]
  expect_equal(medication$count, 4)
  expect_equal(medication$medication_count, 4)
  expect_equal(medication$version, "demo-v1")
  expect_false(any(vapply(local, function(rows) any(rows$row_type == "other (count < 5)"), logical(1))))
})

test_that("archive target selects local details without exposing them in the global ZIP", {
  fixture <- codeSummaryFixture()
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  root <- tempfile("code-summary-targets-")
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
  timestamp <- as.POSIXct("2026-11-09", tz = "UTC")
  global_zip <- writeCodeSummaryArchive(reports, "DQA", timestamp = timestamp)
  local_zip <- writeCodeSummaryArchive(reports, "DQA", timestamp = timestamp, target = "local")
  expect_equal(basename(local_zip), basename(global_zip))
  expect_false(identical(local_zip, global_zip))
  for (target in c("global", "local")) {
    archive <- if (target == "global") global_zip else local_zip
    folder <- file.path(root, paste0(target, "-extracted"))
    utils::unzip(archive, exdir = folder)
    rows <- data.table::fread(file.path(folder, "Codes", "Observation.csv"), na.strings = "")
    expect_equal(any(rows$code == "r1", na.rm = TRUE), target == "local")
    expect_equal(any(rows$row_type == "other (count < 5)"), target == "global")
    if (target == "local") expect_equal(rows[code == "r1", mean], 100)
  }
  attr(reports, "local_reports") <- NULL
  expect_error(writeCodeSummaryArchive(reports, "DQA", target = "local"), "Local code details unavailable")
})
