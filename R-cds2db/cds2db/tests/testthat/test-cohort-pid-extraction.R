##################################
### TEST cohort PID extraction ###
##################################

testthat::test_that("extractPIDsSplittedByCohortFromResourceTables extracts PIDs across resources", {
  cohort_filter_patterns <- list(
    "DUP 1" = list(
      Encounter = list(Condition_1 = list(status = "in-progress")),
      Observation = list(
        Condition_1 = list("code/coding/code" = "12345"),
        Condition_2 = list("code/coding/code" = "67890")
      )
    ),
    "DUP 2" = list(Observation = list(Condition_1 = list("code/coding/code" = "does-not-match")))
  )
  resource_tables <- list(
    Encounter = data.table::data.table(
      id = c("enc-1", "enc-2"),
      "subject/reference" = c("Patient/pat-1", "Patient/pat-ignored"),
      "patient/reference" = c(NA_character_, NA_character_),
      status = c("in-progress", "finished")
    ),
    Observation = data.table::data.table(
      id = c("obs-1", "obs-2", "obs-3", "obs-4"),
      "subject/reference" = c("Patient/pat-2", "Patient/pat-1", NA_character_, "Patient/pat-subject"),
      "patient/reference" = c(NA_character_, NA_character_, "Patient/pat-3", "Patient/pat-patient"),
      "code/coding/code" = c("12345", "67890", "12345", "12345")
    )
  )

  pids_splitted_by_cohort <- extractPIDsSplittedByCohortFromResourceTables(
    resource_tables,
    cohort_filter_patterns
  )

  testthat::expect_named(pids_splitted_by_cohort, c("DUP 1", "DUP 2"))
  testthat::expect_equal(
    pids_splitted_by_cohort[["DUP 1"]][, .(patient_id, source_resource_type, source_resource_id, encounter_id)],
    data.table::data.table(
      patient_id = c("pat-1", "pat-1", "pat-2", "pat-3", "pat-subject"),
      source_resource_type = c("Encounter", "Observation", "Observation", "Observation", "Observation"),
      source_resource_id = c("enc-1", "obs-2", "obs-1", "obs-3", "obs-4"),
      encounter_id = c("enc-1", NA_character_, NA_character_, NA_character_, NA_character_)
    )
  )
  testthat::expect_equal(nrow(pids_splitted_by_cohort[["DUP 2"]]), 0)
  testthat::expect_named(
    pids_splitted_by_cohort[["DUP 2"]],
    c("patient_id", "source_resource_type", "source_resource_id", "encounter_id")
  )
})

testthat::test_that("extractPIDsSplittedByCohortFromResourceTables ignores matched resources without PID", {
  cohort_filter_patterns <- list(
    "DUP 1" = list(Observation = list(Condition_1 = list("code/coding/code" = "12345")))
  )
  resource_tables <- list(
    Observation = data.table::data.table(
      id = "obs-1",
      "subject/reference" = NA_character_,
      "patient/reference" = NA_character_,
      "code/coding/code" = "12345"
    )
  )

  testthat::expect_output(
    pids_splitted_by_cohort <- extractPIDsSplittedByCohortFromResourceTables(
      resource_tables,
      cohort_filter_patterns
    ),
    "without subject/reference or patient/reference"
  )
  testthat::expect_equal(nrow(pids_splitted_by_cohort[["DUP 1"]]), 0)
})

testthat::test_that("extractPIDsSplittedByCohortFromResourceTables rejects overlapping cohort PIDs by default", {
  cohort_filter_patterns <- list(
    "DUP 1" = list(Observation = list(Condition_1 = list("code/coding/code" = "12345"))),
    "DUP 2" = list(Observation = list(Condition_1 = list("code/coding/code" = "12345")))
  )
  resource_tables <- list(
    Observation = data.table::data.table(
      id = "obs-1",
      "subject/reference" = "Patient/pat-1",
      "patient/reference" = NA_character_,
      "code/coding/code" = "12345"
    )
  )

  testthat::expect_error(
    extractPIDsSplittedByCohortFromResourceTables(resource_tables, cohort_filter_patterns),
    "assigned to multiple cohorts"
  )
})

testthat::test_that("extractPIDsSplittedByCohortFromResourceTables allows overlapping cohort PIDs", {
  cohort_filter_patterns <- list(
    "DUP 1" = list(Observation = list(Condition_1 = list("code/coding/code" = "12345"))),
    "DUP 2" = list(Observation = list(Condition_1 = list("code/coding/code" = "12345")))
  )
  resource_tables <- list(
    Observation = data.table::data.table(
      id = "obs-1",
      "subject/reference" = "Patient/pat-1",
      "patient/reference" = NA_character_,
      "code/coding/code" = "12345"
    )
  )

  pids_splitted_by_cohort <- extractPIDsSplittedByCohortFromResourceTables(
    resource_tables,
    cohort_filter_patterns,
    allow_patients_in_multiple_cohorts = TRUE
  )

  testthat::expect_equal(nrow(pids_splitted_by_cohort[["DUP 1"]]), 1)
  testthat::expect_equal(nrow(pids_splitted_by_cohort[["DUP 2"]]), 1)
  testthat::expect_equal(
    rbindPidsSplittedByCohort(pids_splitted_by_cohort)[, .(patient_id, cohort_name)],
    data.table::data.table(
      patient_id = c("pat-1", "pat-1"),
      cohort_name = c("DUP 1", "DUP 2")
    )
  )
})

testthat::test_that("extractPIDsSplittedByCohortFromResourceTables reports missing id columns", {
  cohort_filter_patterns <- list(
    "DUP 1" = list(Observation = list(Condition_1 = list("code/coding/code" = "12345")))
  )
  resource_tables <- list(Observation = data.table::data.table("code/coding/code" = "12345"))

  testthat::expect_error(
    extractPIDsSplittedByCohortFromResourceTables(resource_tables, cohort_filter_patterns),
    "missing required column"
  )
})
