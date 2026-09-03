testthat::test_that("createReferences loads only distinct reference data for affected patients", {
  reference_columns <- unname(getEncounterColNamesForReferenceCalculation())
  encounter <- data.table::data.table(
    enc_id = "main-1",
    enc_type_code = "einrichtungskontakt",
    enc_patient_ref = "Patient/p1",
    enc_period_start = as.POSIXct("2026-01-01", tz = "UTC"),
    enc_period_end = as.POSIXct("2026-01-02", tz = "UTC"),
    enc_identifier_system = "system",
    enc_identifier_value = "case-1",
    enc_class_code = "IMP",
    enc_partof_ref = NA_character_,
    enc_partof_calculated_ref = NA_character_,
    enc_main_encounter_calculated_ref = "Encounter/main-1"
  )
  encounter <- encounter[, ..reference_columns]
  captured_query <- NULL
  captured_encounters <- NULL

  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, ...) {
      captured_query <<- query
      data.table::rbindlist(list(encounter, encounter))
    },
    runLevel2 = function(message, process) force(process),
    runLevel2Line = function(message, process) force(process),
    isDefinedAndTrue = function(...) FALSE,
    isDefinedAndNotEmpty = function(...) FALSE,
    .package = "etlutils"
  )
  testthat::local_mocked_bindings(
    createReferencesForEncounters = function(encounters, ...) {
      captured_encounters <<- data.table::copy(encounters)
      encounters
    },
    .package = "cds2db"
  )

  createReferences(
    resource_tables = list(encounter = data.table::copy(encounter)),
    common_encounter_fhir_identifier_system = NA_character_
  )

  selected_columns <- strsplit(captured_query, " FROM ", fixed = TRUE)[[1]][1]
  selected_columns <- sub("^SELECT DISTINCT ", "", selected_columns)
  selected_columns <- strsplit(selected_columns, ", ", fixed = TRUE)[[1]]
  testthat::expect_setequal(selected_columns, reference_columns)
  testthat::expect_match(captured_query, "enc_patient_ref IN \\('Patient/p1'\\)")
  testthat::expect_match(captured_query, "enc_type_code IN")
  testthat::expect_equal(nrow(captured_encounters), 1L)
})

testthat::test_that("createReferencesForEncounters resolves duplicated encounter hierarchies", {
  encounters <- data.table::data.table(
    enc_id = c("main-1", "department-1", "ward-1"),
    enc_type_code = ENCOUNTER_TYPES,
    enc_patient_ref = "Patient/p1",
    enc_period_start = as.POSIXct("2026-01-01", tz = "UTC"),
    enc_period_end = as.POSIXct("2026-01-02", tz = "UTC"),
    enc_identifier_system = "system",
    enc_identifier_value = "case-1",
    enc_class_code = "IMP",
    enc_partof_ref = c(NA, "Encounter/main-1", "Encounter/department-1"),
    enc_partof_calculated_ref = NA_character_,
    enc_main_encounter_calculated_ref = NA_character_
  )
  encounters <- encounters[rep(seq_len(.N), each = 20L)]

  testthat::local_mocked_bindings(
    runLevel2 = function(message, process) force(process),
    catWarningMessage = function(...) invisible(NULL),
    .package = "etlutils"
  )

  result <- createReferencesForEncounters(
    encounters = data.table::copy(encounters),
    common_encounter_fhir_identifier_system = NA_character_
  )

  testthat::expect_equal(nrow(result), nrow(encounters))
  testthat::expect_setequal(
    unique(result$enc_main_encounter_calculated_ref),
    "Encounter/main-1"
  )
})

testthat::test_that("joinCalculatedRefColumsToEncounter uses one last reference row per encounter", {
  full_encounters <- data.table::data.table(
    enc_id = rep(c("main-1", "main-2"), each = 100L),
    flattened_value = seq_len(200L)
  )
  calculated_encounters <- data.table::data.table(
    enc_id = rep(c("main-1", "main-2"), each = 100L),
    enc_partof_calculated_ref = paste0("Encounter/parent-", seq_len(200L)),
    enc_main_encounter_calculated_ref = paste0("Encounter/main-", seq_len(200L))
  )

  result <- joinCalculatedRefColumsToEncounter(
    full_enc_table = data.table::copy(full_encounters),
    enc_table_with_calculated_refs = calculated_encounters
  )

  testthat::expect_equal(nrow(result), nrow(full_encounters))
  testthat::expect_identical(
    unique(result[enc_id == "main-1", enc_partof_calculated_ref]),
    "Encounter/parent-100"
  )
  testthat::expect_identical(
    unique(result[enc_id == "main-1", enc_main_encounter_calculated_ref]),
    "Encounter/main-100"
  )
  testthat::expect_identical(
    unique(result[enc_id == "main-2", enc_partof_calculated_ref]),
    "Encounter/parent-200"
  )
  testthat::expect_identical(
    unique(result[enc_id == "main-2", enc_main_encounter_calculated_ref]),
    "Encounter/main-200"
  )
})
