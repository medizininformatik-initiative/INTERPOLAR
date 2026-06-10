###########################
### TEST load resources ###
###########################

localSetGlobal <- function(name, value) {
  if (exists(name, envir = .GlobalEnv, inherits = FALSE)) {
    old_value <- get(name, envir = .GlobalEnv)
    assign(name, value, envir = .GlobalEnv)
    withr::defer(assign(name, old_value, envir = .GlobalEnv), envir = parent.frame())
  } else {
    assign(name, value, envir = .GlobalEnv)
    withr::defer(rm(list = name, envir = .GlobalEnv), envir = parent.frame())
  }
}

testthat::test_that("loadResourcesFromFHIRServer can create a cohort PID table", {
  localSetGlobal("DEBUG_PATH_TO_RAW_RDATA_FILES", tempdir())
  localSetGlobal("PROCESS", "CDSToolChain")
  table_descriptions <- list(pid_dependant = list(), pid_independant = list())

  resource_tables <- loadResourcesFromFHIRServer(
    pids_splitted_by_cohort = list("DUP 1" = data.table::data.table(patient_id = "pat-1")),
    table_descriptions = table_descriptions,
    pid_table_name = "pids_per_cohort",
    bind_pids_function = rbindPidsSplittedByCohort,
    empty_pid_table = data.table::data.table(patient_id = "EMPTY_DATA", cohort_name = NA_character_)
  )

  testthat::expect_named(resource_tables, "pids_per_cohort")
  testthat::expect_equal(
    resource_tables$pids_per_cohort,
    data.table::data.table(patient_id = "pat-1", cohort_name = "DUP 1")
  )
})

testthat::test_that("loadResourcesFromFHIRServer keeps the legacy ward PID table by default", {
  localSetGlobal("DEBUG_PATH_TO_RAW_RDATA_FILES", tempdir())
  localSetGlobal("PROCESS", "CDSToolChain")
  table_descriptions <- list(pid_dependant = list(), pid_independant = list())

  resource_tables <- loadResourcesFromFHIRServer(
    pids_splitted_by_cohort = list("Station 1" = data.table::data.table(patient_id = "pat-1")),
    table_descriptions = table_descriptions
  )

  testthat::expect_named(resource_tables, "pids_per_ward")
  testthat::expect_equal(
    resource_tables$pids_per_ward,
    data.table::data.table(patient_id = "pat-1", ward_name = "Station 1")
  )
})

testthat::test_that("loadResourcesFromFHIRServer uses the configured empty PID table", {
  localSetGlobal("DEBUG_PATH_TO_RAW_RDATA_FILES", tempdir())
  localSetGlobal("PROCESS", "CDSToolChain")
  table_descriptions <- list(pid_dependant = list(), pid_independant = list())

  resource_tables <- loadResourcesFromFHIRServer(
    pids_splitted_by_cohort = list("DUP 1" = data.table::data.table(patient_id = character())),
    table_descriptions = table_descriptions,
    pid_table_name = "pids_per_cohort",
    bind_pids_function = rbindPidsSplittedByCohort,
    empty_pid_table = data.table::data.table(patient_id = "EMPTY_DATA", cohort_name = NA_character_)
  )

  testthat::expect_equal(
    resource_tables$pids_per_cohort,
    data.table::data.table(patient_id = "EMPTY_DATA", cohort_name = NA_character_)
  )
})
