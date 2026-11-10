test_that("all and IP case code reports share one query and aggregate independently", {
  fixture <- codeSummaryFilteredFixture()
  calls <- 0L
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      expect_equal(sum(gregexpr('FROM "pg_temp"."observation"', query, fixed = TRUE)[[1]] > 0L), 1L)
      expect_equal(sum(gregexpr('FROM "pg_temp"."encounter"', query, fixed = TRUE)[[1]] > 0L), 1L)
      expect_equal(sum(gregexpr('JOIN "pg_temp"."pids_per_ward"', query, fixed = TRUE)[[1]] > 0L), 1L)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  filtered <- attr(reports, "filtered_reports", exact = TRUE)
  expect_named(filtered, c("Observation", "Condition", "Procedure", "Medication"))
  expect_equal(attr(filtered, "scope_label"), "INTERPOLAR")
  expect_equal(reports$Observation[row_type == "total", count], 14)
  expect_equal(reports$Observation[row_type == "detail" & code == "common", mean], 3.5)
  expect_equal(filtered$Observation[row_type == "total", count], 2)
  expect_equal(filtered$Observation[row_type == "total", patient_count], 1)
  expect_equal(filtered$Observation[row_type == "total", case_count], 1)
  expect_equal(filtered$Observation[row_type == "total", no_case_count], 0)
  expect_false(any(filtered$Observation$row_type == "detail"))
  expect_equal(filtered$Observation[row_type == "other (count < 5)", count], 2)
  local <- attr(filtered, "local_reports", exact = TRUE)
  expect_equal(local$Observation[row_type == "detail", code], "common")
  expect_equal(local$Observation[row_type == "detail", count], 2)
  expect_equal(local$Observation[row_type == "detail", mean], 1.5)
  expect_equal(local$Observation[row_type == "detail", sd], stats::sd(1:2))
  expect_false(any(local$Observation$code == "outside-only", na.rm = TRUE))
  total <- filtered$Medication[row_type == "total"]
  expect_equal(total$count, 6)
  expect_equal(total$medication_count, 1)
  expect_equal(total$medication_request_count, 1)
  expect_equal(total$medication_administration_count, 1)
  expect_equal(total$medication_statement_count, 5)
  expect_equal(total$no_reference_count_to_medication, 5)
  expect_equal(total$no_case_count, 0)
  detail <- filtered$Medication[row_type == "detail"]
  expect_equal(detail$code, "direct-ip")
  expect_equal(detail$medication_count, 0)
  expect_equal(detail$medication_statement_count, 5)
  linked <- local$Medication[row_type == "detail" & code == "B01"]
  expect_equal(linked$count, 1)
  expect_equal(linked$medication_request_count, 1)
  expect_equal(linked$medication_administration_count, 1)
  missing <- filtered$Medication[row_type == "unresolved medication reference"]
  expect_equal(missing$count, 1)
  expect_equal(missing$medication_request_count, 1)
  expect_equal(missing$no_reference_count_to_medication, 1)
  expect_true(any(grepl("pids_per_ward", attr(filtered, "description"), fixed = TRUE)))
})

test_that("disabled or unavailable scope metadata never falls back to unfiltered data", {
  fixture <- codeSummaryFilteredFixture()
  fixture$config$filtered_scope_sheet_names <- character()
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_false(grepl("scope_cases AS", query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_null(attr(reports, "filtered_reports", exact = TRUE))
  fixture$config$filtered_scope_sheet_names <- "FHIR"
  expect_warning(reports <- createCodeSummaryReports(
    fixture$metadata[TABLE_NAME != "pids_per_ward"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Filtered code export skipped")
  expect_null(attr(reports, "filtered_reports", exact = TRUE))
  expect_equal(reports$Observation[row_type == "total", count], 14)
})

test_that("an empty IP selection yields header-only reports with no false zero totals", {
  fixture <- codeSummaryFilteredFixture()
  fixture$extra_sql <- c(fixture$extra_sql, "DELETE FROM pids_per_ward;")
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  filtered <- attr(reports, "filtered_reports", exact = TRUE)
  expect_equal(vapply(filtered, nrow, integer(1)), stats::setNames(rep(0L, 4), names(filtered)))
  expect_true(all(vapply(attr(filtered, "local_reports", exact = TRUE), nrow, integer(1)) == 0L))
  expect_equal(reports$Observation[row_type == "total", count], 14)
})

test_that("scope case references use the same whitespace normalization as events", {
  fixture <- codeSummaryFilteredFixture()
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "UPDATE encounter SET enc_main_encounter_calculated_ref=' Encounter/e2 ' WHERE enc_id IN ('ward1','ward2');"
  )
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  filtered <- attr(reports, "filtered_reports", exact = TRUE)
  expect_equal(filtered$Observation[row_type == "total", count], 2)
})

test_that("missing resource case fields never fall back to the IP patient cohort", {
  fixture <- codeSummaryFilteredFixture()
  reports <- createCodeSummaryReports(
    fixture$metadata[COLUMN_NAME != "obs_encounter_calculated_ref"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  filtered <- attr(reports, "filtered_reports", exact = TRUE)
  expect_equal(reports$Observation[row_type == "total", count], 14)
  expect_equal(nrow(filtered$Observation), 0L)
  expect_equal(filtered$Medication[row_type == "total", count], 6)
})

test_that("one archive contains separate CSVs for complete database and IP cases", {
  fixture <- codeSummaryFilteredFixture()
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  root <- tempfile("code-summary-scopes-")
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
  timestamp <- as.POSIXct("2026-11-10", tz = "UTC")
  global <- writeCodeSummaryArchive(reports, "DQA", timestamp = timestamp)
  local <- writeCodeSummaryArchive(reports, "DQA", timestamp = timestamp, target = "local")
  expect_match(basename(global), "_Code_Summary_2026", fixed = TRUE)
  expect_equal(basename(global), basename(local))
  for (archive in c(global, local)) {
    members <- utils::unzip(archive, list = TRUE)$Name
    expected_names <- c(names(reports), paste0(names(reports), "_INTERPOLAR"))
    expect_setequal(members[endsWith(members, ".csv")], paste0("Codes/", expected_names, ".csv"))
  }
  expect_equal(length(list.files(file.path(root, "global", "reports"))), 1L)
  expect_equal(length(list.files(file.path(root, "local", "reports"))), 1L)
  utils::unzip(local, exdir = file.path(root, "extracted"))
  observation <- data.table::fread(file.path(root, "extracted", "Codes", "Observation_INTERPOLAR.csv"))
  expect_equal(observation[row_type == "detail", count], 2)
  expect_equal(observation[row_type == "detail", mean], 1.5)
  all_observations <- data.table::fread(file.path(root, "extracted", "Codes", "Observation.csv"))
  expect_equal(all_observations[row_type == "total", count], 14)
  utils::unzip(global, exdir = file.path(root, "global-extracted"))
  global_ip <- data.table::fread(file.path(root, "global-extracted", "Codes", "Observation_INTERPOLAR.csv"))
  expect_equal(global_ip[row_type == "other (count < 5)", count], 2)
})
