############################
### TEST createReferencesForResource ###
############################

createReferencesForResourceLegacy <- function(encounters, resource_name, resource_table, start_column_names) {
  calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
  if (calculated_ref_col_name %in% names(resource_table)) {
    resource_table <- resource_table[is.na(get(calculated_ref_col_name))]
  }
  if (!is.null(resource_table) && nrow(resource_table) > 0) {
    ref_col_name <- getEncounterReferenceColumnName(resource_name)
    if (!(calculated_ref_col_name %in% names(resource_table))) {
      resource_table[, (calculated_ref_col_name) := NA_character_]
    }
    if (!any(resource_table[, is.na(get(calculated_ref_col_name))])) {
      return(resource_table)
    }

    for (row_index in seq_len(nrow(resource_table))) {
      resource_encounter_ref <- resource_table[row_index, get(ref_col_name)]
      if (!is.na(resource_encounter_ref)) {
        resource_encounter_id <- etlutils::fhirdataExtractIDs(resource_encounter_ref)
        encounter_resource <- encounters[enc_id == resource_encounter_id]
        if (nrow(encounter_resource)) {
          encounter_row <- encounter_resource[
            !is.na(enc_main_encounter_calculated_ref) &
              trimws(enc_main_encounter_calculated_ref) != "invalid"
          ][seq_len(min(.N, 1))]

          if (nrow(encounter_row)) {
            encounter_ref <- encounter_row$enc_main_encounter_calculated_ref
            resource_table <- resource_table[row_index, (calculated_ref_col_name) := encounter_ref]
          }
        }
      }

      if (is.na(resource_table[row_index, get(calculated_ref_col_name)])) {
        resource_encounter_ref <- resource_table[row_index, get(ref_col_name)]
        if (!is.na(resource_encounter_ref)) {
          resource_encounter_id <- etlutils::fhirdataExtractIDs(resource_encounter_ref)
          encounter_resource <- encounters[enc_id == resource_encounter_id]

          parent_encounter_id <- NA_character_
          while (nrow(encounter_resource)) {
            encounter_resource <- encounter_resource[1]
            partof_ref <- encounter_resource$enc_partof_calculated_ref
            if (is.na(partof_ref)) {
              parent_encounter_id <- encounter_resource$enc_id
              break
            }
            parent_encounter_id <- etlutils::fhirdataExtractIDs(partof_ref)
            if (identical(parent_encounter_id, "invalid")) {
              parent_encounter_id <- NA_character_
              break
            }
            encounter_resource <- encounters[enc_id == parent_encounter_id]
          }
          if (!is.na(parent_encounter_id)) {
            encounter_ref <- etlutils::fhirdataGetEncounterReference(parent_encounter_id)
            resource_table[row_index, (calculated_ref_col_name) := encounter_ref]
          }
        }
      }

      if (is.na(resource_table[row_index, get(calculated_ref_col_name)])) {
        patient_ref_col_name <- etlutils::fhirdbGetColumns(resource_name, "_patient_ref")
        patient_ref <- resource_table[row_index, get(patient_ref_col_name)]
        candidate_encounters <- encounters[
          enc_patient_ref == patient_ref &
            enc_type_code == ENCOUNTER_TYPES[[1]] &
            enc_class_code %in% c("IMP", "SS")
        ]
        if (nrow(candidate_encounters)) {
          for (start_column_name in start_column_names) {
            resource_start_time <- resource_table[row_index, get(start_column_name)]
            if (!is.na(resource_start_time)) {
              candidate_encounters_filtered <- candidate_encounters[
                enc_period_start <= resource_start_time &
                  (is.na(enc_period_end) | enc_period_end >= resource_start_time)
              ]
              if (nrow(candidate_encounters_filtered)) {
                time_diff <- abs(as.numeric(difftime(
                  candidate_encounters_filtered$enc_period_start,
                  resource_start_time,
                  units = "secs"
                )))
                idx <- which.min(time_diff)
                best_fit_encounter <- candidate_encounters_filtered[idx]
                resource_table[row_index, (calculated_ref_col_name) := paste0("Encounter/", best_fit_encounter$enc_id)]
                break
              }
            }
          }
        }
      }

      if (is.na(resource_table[row_index, get(calculated_ref_col_name)])) {
        resource_table[row_index, (calculated_ref_col_name) := "invalid"]
      }
    }
  }

  resource_table
}

testthat::test_that("createReferencesForResource matches the legacy implementation", {
  resource_name <- "observation"
  ref_col_name <- getEncounterReferenceColumnName(resource_name)
  calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
  patient_ref_col_name <- etlutils::fhirdbGetColumns(resource_name, "_patient_ref")
  start_column_names <- c("obs_effectivedatetime")

  encounters <- data.table::data.table(
    enc_id = c("main-1", "dept-1", "ward-1", "main-2", "main-2b", "dept-invalid"),
    enc_patient_ref = c(
      "Patient/p1",
      "Patient/p1",
      "Patient/p1",
      "Patient/p2",
      "Patient/p2",
      "Patient/p3"
    ),
    enc_type_code = c(
      "einrichtungskontakt",
      "abteilungskontakt",
      "versorgungsstellenkontakt",
      "einrichtungskontakt",
      "einrichtungskontakt",
      "abteilungskontakt"
    ),
    enc_class_code = c("IMP", "IMP", "IMP", "IMP", "SS", "IMP"),
    enc_period_start = as.POSIXct(
      c(
        "2026-01-01 00:00:00",
        "2026-01-02 00:00:00",
        "2026-01-02 12:00:00",
        "2026-02-01 00:00:00",
        "2026-02-03 00:00:00",
        "2026-03-01 00:00:00"
      ),
      tz = "UTC"
    ),
    enc_period_end = as.POSIXct(
      c(
        "2026-01-10 00:00:00",
        "2026-01-04 00:00:00",
        "2026-01-03 00:00:00",
        "2026-02-10 00:00:00",
        "2026-02-04 00:00:00",
        "2026-03-02 00:00:00"
      ),
      tz = "UTC"
    ),
    enc_partof_calculated_ref = c(NA, "Encounter/main-1", "Encounter/dept-1", NA, NA, "invalid"),
    enc_main_encounter_calculated_ref = c(
      "Encounter/main-1",
      "Encounter/main-1",
      "invalid",
      "Encounter/main-2",
      "Encounter/main-2b",
      "invalid"
    )
  )

  resource_table <- data.table::data.table(
    obs_id = c(
      "direct-main",
      "partof-chain",
      "timestamp-first-start-column",
      "timestamp-second-start-column",
      "invalid-reference",
      "invalid-missing"
    ),
    obs_effectivedatetime = as.POSIXct(
      c(
        NA,
        NA,
        "2026-02-03 12:00:00",
        NA,
        NA,
        "2026-04-01 00:00:00"
      ),
      tz = "UTC"
    ),
    obs_issued = as.POSIXct(
      c(
        NA,
        NA,
        NA,
        "2026-02-02 12:00:00",
        NA,
        NA
      ),
      tz = "UTC"
    )
  )
  resource_table[, (ref_col_name) := c(
    "Encounter/dept-1",
    "Encounter/ward-1",
    NA_character_,
    NA_character_,
    "Encounter/dept-invalid",
    NA_character_
  )]
  resource_table[, (patient_ref_col_name) := c(
    "Patient/p1",
    "Patient/p1",
    "Patient/p2",
    "Patient/p2",
    "Patient/p3",
    "Patient/p4"
  )]

  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(...) data.table::data.table(),
    runLevel2Line = function(message, process) force(process),
    .package = "etlutils"
  )

  legacy_result <- createReferencesForResourceLegacy(
    encounters = data.table::copy(encounters),
    resource_name = resource_name,
    resource_table = data.table::copy(resource_table),
    start_column_names = c("obs_effectivedatetime", "obs_issued")
  )
  current_result <- createReferencesForResource(
    encounters = data.table::copy(encounters),
    resource_name = resource_name,
    resource_table = data.table::copy(resource_table),
    start_column_names = c("obs_effectivedatetime", "obs_issued")
  )

  testthat::expect_identical(names(current_result), names(legacy_result))
  testthat::expect_equal(nrow(current_result), nrow(legacy_result))
  testthat::expect_identical(
    current_result[[calculated_ref_col_name]],
    legacy_result[[calculated_ref_col_name]]
  )
  testthat::expect_identical(
    current_result[[calculated_ref_col_name]],
    c(
      "Encounter/main-1",
      "Encounter/main-1",
      "Encounter/main-2b",
      "Encounter/main-2",
      "invalid",
      "invalid"
    )
  )
})

testthat::test_that("createReferencesForResource keeps the legacy filtering of existing calculated refs", {
  resource_name <- "observation"
  ref_col_name <- getEncounterReferenceColumnName(resource_name)
  calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
  patient_ref_col_name <- etlutils::fhirdbGetColumns(resource_name, "_patient_ref")

  encounters <- data.table::data.table(
    enc_id = "main-1",
    enc_patient_ref = "Patient/p1",
    enc_type_code = "einrichtungskontakt",
    enc_class_code = "IMP",
    enc_period_start = as.POSIXct("2026-01-01 00:00:00", tz = "UTC"),
    enc_period_end = as.POSIXct("2026-01-10 00:00:00", tz = "UTC"),
    enc_partof_calculated_ref = NA_character_,
    enc_main_encounter_calculated_ref = "Encounter/main-1"
  )

  resource_table <- data.table::data.table(
    obs_id = c("existing", "missing"),
    obs_effectivedatetime = as.POSIXct(c(NA, NA), tz = "UTC")
  )
  resource_table[, (ref_col_name) := c("Encounter/main-1", "Encounter/main-1")]
  resource_table[, (patient_ref_col_name) := c("Patient/p1", "Patient/p1")]
  resource_table[, (calculated_ref_col_name) := c("Encounter/already-done", NA_character_)]

  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(...) data.table::data.table(),
    runLevel2Line = function(message, process) force(process),
    .package = "etlutils"
  )

  legacy_result <- createReferencesForResourceLegacy(
    encounters = data.table::copy(encounters),
    resource_name = resource_name,
    resource_table = data.table::copy(resource_table),
    start_column_names = "obs_effectivedatetime"
  )
  current_result <- createReferencesForResource(
    encounters = data.table::copy(encounters),
    resource_name = resource_name,
    resource_table = data.table::copy(resource_table),
    start_column_names = "obs_effectivedatetime"
  )

  testthat::expect_identical(current_result, legacy_result)
  testthat::expect_identical(current_result$obs_id, "missing")
})

testthat::test_that("createReferencesForResource recalculates invalid calculated refs", {
  resource_name <- "observation"
  ref_col_name <- getEncounterReferenceColumnName(resource_name)
  calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
  patient_ref_col_name <- etlutils::fhirdbGetColumns(resource_name, "_patient_ref")

  encounters <- data.table::data.table(
    enc_id = "main-1",
    enc_patient_ref = "Patient/p1",
    enc_type_code = "einrichtungskontakt",
    enc_class_code = "IMP",
    enc_period_start = as.POSIXct("2026-01-01 00:00:00", tz = "UTC"),
    enc_period_end = as.POSIXct("2026-01-10 00:00:00", tz = "UTC"),
    enc_partof_calculated_ref = NA_character_,
    enc_main_encounter_calculated_ref = "Encounter/main-1"
  )

  resource_table <- data.table::data.table(
    obs_id = c("existing", "invalid"),
    obs_effectivedatetime = as.POSIXct(c(NA, NA), tz = "UTC")
  )
  resource_table[, (ref_col_name) := c("Encounter/main-1", "Encounter/main-1")]
  resource_table[, (patient_ref_col_name) := c("Patient/p1", "Patient/p1")]
  resource_table[, (calculated_ref_col_name) := c("Encounter/already-done", "invalid")]

  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(...) data.table::data.table(),
    runLevel2Line = function(message, process) force(process),
    .package = "etlutils"
  )

  current_result <- createReferencesForResource(
    encounters = data.table::copy(encounters),
    resource_name = resource_name,
    resource_table = data.table::copy(resource_table),
    start_column_names = "obs_effectivedatetime"
  )

  testthat::expect_identical(current_result$obs_id, "invalid")
  testthat::expect_identical(
    current_result[[calculated_ref_col_name]],
    "Encounter/main-1"
  )
})

testthat::test_that("createReferencesForEncounters recalculates invalid calculated refs", {
  encounters <- data.table::data.table(
    enc_id = c("main-1", "dept-1"),
    enc_type_code = c("einrichtungskontakt", "abteilungskontakt"),
    enc_patient_ref = c("Patient/p1", "Patient/p1"),
    enc_period_start = as.POSIXct(
      c("2026-01-01 00:00:00", "2026-01-02 00:00:00"),
      tz = "UTC"
    ),
    enc_period_end = as.POSIXct(
      c("2026-01-10 00:00:00", "2026-01-03 00:00:00"),
      tz = "UTC"
    ),
    enc_identifier_system = c("system", "system"),
    enc_identifier_value = c("case-1", "case-1"),
    enc_class_code = c("IMP", "IMP"),
    enc_partof_ref = c(NA_character_, "Encounter/main-1"),
    enc_partof_calculated_ref = c(NA_character_, "invalid"),
    enc_main_encounter_calculated_ref = c("invalid", "invalid")
  )

  testthat::local_mocked_bindings(
    runLevel2 = function(message, process) force(process),
    catWarningMessage = function(...) invisible(NULL),
    .package = "etlutils"
  )

  current_result <- createReferencesForEncounters(
    encounters = data.table::copy(encounters),
    common_encounter_fhir_identifier_system = NA_character_
  )

  testthat::expect_identical(
    current_result[enc_id == "main-1", unique(enc_main_encounter_calculated_ref)],
    "Encounter/main-1"
  )
  testthat::expect_identical(
    current_result[enc_id == "dept-1", unique(enc_partof_calculated_ref)],
    "Encounter/main-1"
  )
  testthat::expect_identical(
    current_result[enc_id == "dept-1", unique(enc_main_encounter_calculated_ref)],
    "Encounter/main-1"
  )
})
