source(
  testthat::test_path("..", "..", "..", "test", "test_common_data_preparation.R"),
  local = TRUE
)

testthat::test_that("test encounter templates do not retain removed diagnoses", {
  testSetResourceTables(list(
    Patient = data.table::data.table(
      pat_id = "[1]P1",
      pat_identifier_value = "[1.1]P1",
      pat_name_family = "[1]Patient"
    ),
    Encounter = data.table::data.table(
      enc_id = "[1]P1-E-1",
      enc_identifier_value = "[1.1]P1-E-1",
      enc_patient_ref = "[1.1]Patient/P1",
      enc_partof_ref = NA_character_,
      enc_status = "[1]finished",
      enc_period_end = "[1]2025-01-01T00:00:00Z",
      enc_diagnosis_condition_ref = "[1.1.1]Condition/P1-E-1-C-1",
      enc_diagnosis_use_code = "[1.1.1.1]AD"
    ),
    MedicationRequest = data.table::data.table(
      medreq_id = "[1]P1-E-1-MR-1",
      medreq_patient_ref = "[1.1]Patient/P1"
    ),
    Medication = data.table::data.table(med_id = "[1]M1"),
    Condition = data.table::data.table(
      con_id = "[1]P1-E-1-C-1",
      con_patient_ref = "[1.1]Patient/P1"
    ),
    Observation = data.table::data.table(
      obs_id = "[1]O1",
      obs_patient_ref = "[1.1]Patient/P1"
    ),
    Procedure = data.table::data.table(
      proc_id = "[1]PR1",
      proc_patient_ref = "[1.1]Patient/P1"
    ),
    pids_per_ward = data.table::data.table(
      patient_id = "P1",
      encounter_id = "P1-E-1",
      ward_name = "Station 1"
    )
  ))

  testPrepareRAWResources("Patient/P1")

  encounter_templates <- get("enc_templates", envir = .test_env)
  testthat::expect_true(all(is.na(encounter_templates$enc_diagnosis_condition_ref)))
  testthat::expect_true(all(is.na(encounter_templates$enc_diagnosis_use_code)))
})

testthat::test_that("duplicatePatients updates all diagnosis Condition references", {
  testSetResourceTables(list(
    Patient = data.table::data.table(
      pat_id = "[1]P1",
      pat_identifier_value = "[1.1]P1",
      pat_name_family = "[1]Patient"
    ),
    Encounter = data.table::data.table(
      enc_id = "[1]P1-E-1",
      enc_identifier_value = "[1.1]P1-E-1",
      enc_patient_ref = "[1.1]Patient/P1",
      enc_partof_ref = NA_character_,
      enc_diagnosis_condition_ref = paste(
        "[1.1.1]Condition/P1-E-1-C-1",
        "[2.1.1]Condition/P1-E-1-C-2",
        sep = " ~ "
      )
    ),
    Condition = data.table::data.table(
      con_id = c("[1]P1-E-1-C-1", "[1]P1-E-1-C-2"),
      con_identifier_value = c("[1.1]P1-E-1-C-1", "[1.1]P1-E-1-C-2"),
      con_patient_ref = "[1.1]Patient/P1",
      con_encounter_ref = "[1.1]Encounter/P1-E-1"
    )
  ))

  duplicatePatients(1)

  resource_tables <- testGetResourceTables()
  duplicated_encounter <- resource_tables$Encounter[enc_id == "[1]P1_1-E-1"]
  duplicated_condition_ids <- resource_tables$Condition[
    grepl("^\\[1\\]P1_1-E-1-C-", con_id),
    con_id
  ]

  testthat::expect_identical(
    duplicated_encounter$enc_diagnosis_condition_ref,
    paste(
      "[1.1.1]Condition/P1_1-E-1-C-1",
      "[2.1.1]Condition/P1_1-E-1-C-2",
      sep = " ~ "
    )
  )
  testthat::expect_setequal(
    duplicated_condition_ids,
    c("[1]P1_1-E-1-C-1", "[1]P1_1-E-1-C-2")
  )
})
