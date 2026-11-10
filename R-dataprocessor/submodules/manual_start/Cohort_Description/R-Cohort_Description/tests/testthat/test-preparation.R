test_that("preparation reads known assignments through the shared read-only utility", {
  assignments <- data.frame(
    ward_name = c("WARD_A", "WARD_B"),
    patient_id = c("patient-1", "patient-1"),
    encounter_id = c("encounter-1", "encounter-2")
  )
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) {
      expect_identical(query, paste(
        "SELECT DISTINCT ward_name, patient_id, encounter_id FROM v_pids_per_ward",
        "ORDER BY patient_id, encounter_id"
      ))
      expect_identical(lock_id, "Cohort Description: load known station assignments")
      assignments
    },
    .package = "etlutils"
  )
  expect_message(
    result <- withVisible(prepareCohortDescription()),
    "2 distinct station/patient/Encounter assignments loaded"
  )
  expect_identical(result$value, assignments)
  expect_false(result$visible)
})

test_that("preparation stops early for an empty assignment table", {
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(...) data.frame(),
    .package = "etlutils"
  )
  expect_error(prepareCohortDescription(), "pids_per_ward table is empty")
})

test_that("database errors propagate to the standard submodule error handling", {
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(...) stop("missing database view"),
    .package = "etlutils"
  )
  expect_error(prepareCohortDescription(), "missing database view")
})
