test_that("preparation reads known assignments through the shared read-only utility", {
  assignments <- data.frame(
    ward_name = c("WARD_A", "WARD_B"),
    patient_id = c("patient-1", "patient-1"),
    encounter_id = c("encounter-1", "encounter-2")
  )
  encounters <- data.table::data.table(
    enc_id = assignments$encounter_id,
    enc_patient_ref = "Patient/patient-1",
    enc_main_encounter_calculated_ref = "Encounter/main-1",
    enc_period_start = as.POSIXct(c("2026-01-02", "2026-01-01"), tz = "UTC"),
    enc_period_end = as.POSIXct("2026-01-10", tz = "UTC"),
    enc_type_system = "http://fhir.de/CodeSystem/Kontaktebene",
    enc_type_code = "versorgungsstellenkontakt",
    enc_class_code = "IMP"
  )
  testthat::local_mocked_bindings(
    dbGetTableColumnTypes = function(...) data.frame(column_name = names(encounters)),
    getPidsPerWardData = function(lock_id, table_name, column_names) {
      expect_identical(table_name, "v_pids_per_ward")
      assignments
    },
    fhirdataGetAllEncounters = function(encounter_ids, lock_id_extension, column_names) {
      expect_identical(encounter_ids, assignments$encounter_id)
      expect_identical(column_names, names(encounters))
      encounters
    },
    .package = "etlutils"
  )
  expect_message(result <- withVisible(prepareCohortDescription()), "2 distinct")
  expect_false(result$visible)
  expect_equal(result$value$encounters, encounters)
  expect_setequal(result$value$known_ip_contacts$encounter_id, assignments$encounter_id)
  expect_true(all(result$value$known_ip_contacts$encounter_found))
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
