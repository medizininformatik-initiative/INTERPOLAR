test_that("FAS 4 uses reviewed algorithmic MRPs from all completed first-IP MedAs", {
  cases <- data.table::data.table(patient_id = c("p", "q"), case_id = c("c", "d"))
  completed <- data.table::data.table(
    patient_id = "p", case_id = "c", meda_id = c("first", "second", "later"),
    on_first_ip = c(TRUE, TRUE, FALSE)
  )
  reviews <- data.table::data.table(
    patient_id = c("p", "p", "p", "q"), case_id = c("c", "c", "c", "d"),
    meda_id = c("second", "second", "later", "first"), ret_id = letters[1:4],
    ret_gewissheit1 = c(
      "MRP bestätigt und von Stationsapotheker vorher identifiziert",
      "MRP nicht bestätigt", "MRP bestätigt", "MRP bestätigt"
    ),
    ret_gewiss_grund1_abl = NA_character_,
    ret_gewiss_grund1_abl_01 = c(NA, "MRP sachlich richtig, aber klinisch nicht relevant", NA, NA)
  )
  result <- addCohortAlgorithmicMRPFlags(cases, completed, reviews)
  expect_equal(result$has_reviewed_algorithmic_mrp, c(TRUE, FALSE))
  expect_equal(result$has_irrelevant_algorithmic_mrp, c(TRUE, FALSE))
  expect_equal(result$has_relevant_algorithmic_mrp, c(TRUE, FALSE))
  later <- addCohortAlgorithmicMRPFlags(cases, completed, reviews[3:4])
  expect_false(any(later$has_reviewed_algorithmic_mrp))
  reviews[1, ret_gewissheit1 := "MRP nicht bestätigt"]
  reviews[1, ret_gewiss_grund1_abl := "MRP sachlich falsch (keine Kontraindikation)"]
  other <- addCohortAlgorithmicMRPFlags(cases, completed, reviews[1])
  expect_true(other$has_reviewed_algorithmic_mrp[1])
  expect_false(any(other$has_relevant_algorithmic_mrp | other$has_irrelevant_algorithmic_mrp))
})

test_that("review loading requires completed reviews of the same calculated MRP and MedA", {
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) {
      expect_match(query, "c.ret_id = r.ret_id AND c.meda_id = r.ret_meda_id", fixed = TRUE)
      expect_match(query, "retrolektive_mrpbewertung_complete = 'Complete'", fixed = TRUE)
      data.table::data.table(record_id = c("r", "outside"), case_id = "c", meda_id = "m")
    }, .package = "etlutils"
  )
  result <- loadCohortAlgorithmicReviews(data.table::data.table(record_id = "r", patient_id = "p"))
  expect_equal(result$patient_id, "p")
  expect_equal(nrow(result), 1L)
})

test_that("BC periods include the full last TRS day and retain CRS B limits for RES", {
  fixture <- cohortFixture()
  periods <- buildCohortPeriods(fixture$wards, "broad_consent", "Europe/Berlin")
  expect_equal(periods$phase, c("TRS", "RES"))
  expect_equal(periods[phase == "TRS"]$period_end, as.POSIXct("2027-01-01", tz = "Europe/Berlin"))
  regular <- buildCohortPeriods(fixture$wards, "regular", "Europe/Berlin")
  for (column in c("period_start", "period_end", "admission_start", "admission_end", "discharge_limit")) {
    expect_equal(as.numeric(periods[phase == "RES"][[column]]), as.numeric(regular[phase == "CRS B"][[column]]))
  }
  cases <- fixture$cases[1]
  cases[, `:=`(
    hospital_start = as.POSIXct("2026-12-31 00:00:00", tz = "Europe/Berlin"),
    hospital_end = as.POSIXct(NA),
    ip_start = as.POSIXct("2026-12-31 01:00:00", tz = "Europe/Berlin"),
    ip_end = as.POSIXct("2027-01-01 01:00:00", tz = "Europe/Berlin")
  )]
  expect_equal(assignCohortPopulations(cases, periods, "Europe/Berlin")$phase, "TRS")
  cases[, ip_start := as.POSIXct("2027-01-01", tz = "Europe/Berlin")]
  cases[, ip_end := ip_start + 86400]
  expect_equal(nrow(assignCohortPopulations(cases, periods, "Europe/Berlin")), 0L)
})

test_that("BC export includes all seven FAS for both studies, including empty subsets", {
  fixture <- cohortFixture()
  directory <- tempfile("cohort-bc-export-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  testthat::local_mocked_bindings(
    writeCohortWorkbook = function(...) NULL,
    calculateCohortCells = function(...) data.table::data.table(),
    .package = "CohortDescription"
  )
  capture.output(manifest <- exportCohortDescription(
    fixture$cases, fixture$wards, "UTC", "site", directory, "broad_consent"
  ))
  expect_equal(nrow(manifest), 14L)
  expect_setequal(manifest$phase, c("TRS", "RES"))
  expect_setequal(manifest$fas, c("FAS 1", "FAS 2.1", "FAS 2.2", "FAS 3", "FAS 4", "FAS 4.1", "FAS 4.2"))
  expect_true(all(manifest$source == "broad_consent"))
  expect_true(all(manifest[phase == "TRS"]$definition_status == "provisional"))
  expect_true(all(manifest[startsWith(fas, "FAS 4")]$cases == 0L))
})

test_that("cohort entry rejects an incomplete full-source configuration before analysis", {
  script <- normalizePath(file.path(dirname(dirname(cohortAssetPath("cohort_rows.csv"))), "..", "..", "Start.R"), mustWork = TRUE)
  testthat::local_mocked_bindings(runLevel2 = function(description, code) force(code), .package = "etlutils")
  called <- character()
  env <- list2env(list(
    manual_database_source = "regular", manual_database_sources = "regular",
    manual_database_partial = FALSE,
    createCohortDescription = function(source) called <<- c(called, source)
  ))
  expect_error(sys.source(script, env), "requires both")
  expect_length(called, 0L)
  env$manual_database_partial <- TRUE
  sys.source(script, env)
  expect_equal(called, "regular")
})
