test_that("OPS loader retrieves missing origins once and preserves source version", {
  time <- as.POSIXct("2024-01-01", tz = "UTC")
  encounters <- data.table::data.table(
    enc_id = "in", enc_patient_ref = "Patient/p",
    enc_class_code = "IMP", enc_period_start = time - 86400
  )
  queries <- character()
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) {
      queries <<- c(queries, query)
      data.table::data.table(
        proc_id = c("one", "two"), proc_patient_ref = "Patient/p",
        proc_encounter_calculated_ref = c("Encounter/in", "Encounter/out"),
        proc_code_system = "http://fhir.de/CodeSystem/bfarm/ops", proc_code_version = NA_character_,
        proc_code_code = "8-016", proc_performeddatetime = time, proc_performedperiod_start = time
      )
    },
    fhirdataGetAllEncounters = function(encounter_ids, lock_id_extension, column_names) {
      expect_equal(encounter_ids, "out")
      expect_true("enc_class_code" %in% column_names)
      data.table::data.table(
        enc_id = "out", enc_patient_ref = "Patient/p",
        enc_class_code = "AMB", enc_period_start = time
      )
    }, .package = "etlutils"
  )
  result <- loadCohortProcedureData("p", encounters, etlutils::loadOPSCatalogues(), "UTC")
  expect_length(queries, 1L)
  expect_match(queries[1], "proc_code_version")
  expect_equal(result$procedures$ops_catalogue_year, c(2023L, 2024L))
  expect_equal(nrow(result$encounters), 2L)
})
