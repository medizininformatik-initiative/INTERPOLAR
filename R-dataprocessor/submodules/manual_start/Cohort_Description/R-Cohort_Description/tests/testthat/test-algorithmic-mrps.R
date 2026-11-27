test_that("FAS 4 uses the first completed IP MedA and permits a different reviewed MRP", {
  cases <- data.table::data.table(patient_id = c("p", "q"), case_id = c("c", "d"))
  first_ip <- data.table::data.table(
    patient_id = c("p", "q"), case_id = c("c", "d"),
    meda_id = c("ip", "q_ip"), case_row = 1:2, meda_location = "first_ip"
  )
  first <- data.table::copy(first_ip)
  first[1, `:=`(meda_id = "earlier", meda_location = "before_first_ip")]
  calculations <- data.table::data.table(
    case_id = c("c", "c", "c", "d"), meda_id = c("ip", "earlier", "earlier", "q_ip"),
    ret_id = c("a", "b", "b", "c"), dp_mrp_calculations_id = 1:4
  )
  reviews <- data.table::data.table(
    patient_id = c("p", "q"), meda_id = c("ip", "q_later"), ret_id = c("different", "c"),
    ret_gewissheit1 = "MRP bestätigt", ret_gewiss_grund1_abl = NA_character_,
    ret_gewiss_grund1_abl_01 = NA_character_
  )
  evaluate <- function() addCohortAlgorithmicMRPFlags(
    data.table::copy(cases), first, first_ip,
    list(calculations = calculations, reviews = reviews)
  )
  result <- evaluate()
  expect_equal(result$has_reviewed_algorithmic_mrp, c(TRUE, FALSE))
  expect_false(any(result$has_relevant_algorithmic_mrp))
  expect_equal(result$first_meda_mrps, c(1L, 1L))
  reviews[1, ret_id := "a"]
  expect_equal(evaluate()$has_relevant_algorithmic_mrp, c(TRUE, FALSE))
  irrelevant <- data.table::copy(reviews[1])
  irrelevant[, `:=`(
    ret_gewissheit1 = "MRP nicht bestätigt",
    ret_gewiss_grund1_abl = "MRP sachlich richtig, aber klinisch nicht relevant"
  )]
  reviews <- data.table::rbindlist(list(reviews, irrelevant))
  conflict <- evaluate()
  expect_true(conflict$has_reviewed_algorithmic_mrp[1])
  expect_false(conflict$has_relevant_algorithmic_mrp[1] || conflict$has_irrelevant_algorithmic_mrp[1])
  reviews[3, ret_id := "new_mrp"]
  calculations <- data.table::rbindlist(list(calculations, calculations[1][, `:=`(
    ret_id = "new_mrp", dp_mrp_calculations_id = 5L
  )]))
  overlap <- evaluate()
  expect_true(overlap$has_relevant_algorithmic_mrp[1] && overlap$has_irrelevant_algorithmic_mrp[1])
})

test_that("BC periods include the full last TRS day and retain CRS B limits for RES", {
  fixture <- cohortFixture()
  periods <- buildCohortPeriods(fixture$wards, "broad_consent", "Europe/Berlin")
  expect_equal(periods$phase, c("TRS", "RES"))
  expect_equal(periods[phase == "TRS"]$admission_end, as.POSIXct("2027-01-01", tz = "Europe/Berlin"))
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
  expect_equal(assignCohortPopulations(cases, periods, "Europe/Berlin")$phase, "TRS")
  cases[, hospital_start := as.POSIXct("2027-01-01", tz = "Europe/Berlin")]
  expect_equal(nrow(assignCohortPopulations(cases, periods, "Europe/Berlin")), 0L)
  cases[, hospital_start := as.POSIXct("2022-12-31 23:59:59", tz = "Europe/Berlin")]
  expect_equal(nrow(assignCohortPopulations(cases, periods, "Europe/Berlin")), 0L)
  cases[, hospital_start := as.POSIXct("2023-01-01", tz = "Europe/Berlin")]
  expect_equal(assignCohortPopulations(cases, periods, "Europe/Berlin")$phase, "TRS")
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
  summary <- data.table::fread(file.path(directory, "algorithmic_mrps_by_first_meda_timing.csv"))
  expect_equal(nrow(summary), 8L)
  expect_setequal(summary$phase, c("TRS", "RES"))
  expect_equal(sort(summary$cases_with_first_completed_meda), sort(c("<5", rep("0", 7L))))
  expect_true(all(summary$algorithmic_mrps == 0L))
  expect_equal(nrow(manifest), 14L)
  expect_setequal(manifest$phase, c("TRS", "RES"))
  expect_setequal(manifest$fas, c("FAS 1", "FAS 2.1", "FAS 2.2", "FAS 3", "FAS 4", "FAS 4.1", "FAS 4.2"))
  expect_true(all(manifest$source == "broad_consent"))
  expect_true(all(manifest[phase == "TRS"]$definition_status == "agreed"))
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
