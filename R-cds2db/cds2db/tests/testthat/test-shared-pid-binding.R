###############################
### TEST shared PID binding ###
###############################

testthat::test_that("rbindPidsSplittedByCohort combines non-empty cohort tables", {
  pids_splitted_by_cohort <- list(
    "DUP 1" = data.table::data.table(
      patient_id = c("pat-1", "pat-2"),
      source_resource_type = c("Encounter", "Observation")
    ),
    "DUP 2" = data.table::data.table(
      patient_id = "pat-3",
      source_resource_type = "Patient"
    )
  )

  pids_per_cohort <- rbindPidsSplittedByCohort(pids_splitted_by_cohort)

  testthat::expect_equal(
    pids_per_cohort,
    data.table::data.table(
      patient_id = c("pat-1", "pat-2", "pat-3"),
      source_resource_type = c("Encounter", "Observation", "Patient"),
      cohort_name = c("DUP 1", "DUP 1", "DUP 2")
    )
  )
})

testthat::test_that("rbindPidsSplittedByCohort skips empty cohorts without modifying input tables", {
  dup_1 <- data.table::data.table(patient_id = "pat-1")
  pids_splitted_by_cohort <- list(
    "DUP 1" = dup_1,
    "DUP 2" = data.table::data.table(patient_id = character())
  )

  pids_per_cohort <- rbindPidsSplittedByCohort(pids_splitted_by_cohort)

  testthat::expect_equal(
    pids_per_cohort,
    data.table::data.table(patient_id = "pat-1", cohort_name = "DUP 1")
  )
  testthat::expect_named(dup_1, "patient_id")
})

testthat::test_that("rbindPidsSplittedByCohort returns a typed empty table", {
  pids_per_cohort <- rbindPidsSplittedByCohort(list(
    "DUP 1" = data.table::data.table(patient_id = character())
  ))

  testthat::expect_equal(nrow(pids_per_cohort), 0)
  testthat::expect_named(pids_per_cohort, c("patient_id", "cohort_name"))
})

testthat::test_that("rbindPidsSplittedByWard keeps legacy ward column", {
  pids_per_ward <- rbindPidsSplittedByWard(list(
    "Station 1" = data.table::data.table(patient_id = "pat-1")
  ))

  testthat::expect_equal(
    pids_per_ward,
    data.table::data.table(patient_id = "pat-1", ward_name = "Station 1")
  )
})
