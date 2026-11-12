test_that("database preparation feeds case features without per-row resource reads", {
  time <- as.POSIXct("2025-01-01", tz = "UTC")
  encounters <- data.table::data.table(
    enc_id = c("ward", "case"), enc_patient_ref = "Patient/p",
    enc_main_encounter_calculated_ref = "Encounter/case", enc_period_start = time + c(86400, 0),
    enc_period_end = time + c(8, 10) * 86400, enc_class_code = "IMP"
  )
  assignments <- data.table::data.table(
    patient_id = "p", encounter_id = "ward", ward_name = "A",
    input_datetime = time, pids_per_ward_id = 1L
  )
  prepared <- list(encounters = encounters, known_ip_contacts = linkCohortStationContacts(assignments, encounters))
  testthat::local_mocked_bindings(
    loadExistingRecordIDsFromDB = function(...) data.table::data.table(pat_id = "p", record_id = "r"),
    .package = "dataprocessor"
  )
  testthat::local_mocked_bindings(
    getMedikationsanalyseFeData = function(...) data.table::data.table(
      record_id = "r", fall_meda_id = "hospital-number",
      meda_id = "m", meda_dat = time + 2 * 86400, medikationsanalyse_complete = "Complete", redcap_repeat_instance = 1L
    ),
    dbGetReadOnlyQuery = function(query, lock_id) {
      if (grepl("v_fall_fe_last_version", query)) return(data.table::data.table(
        record_id = "r",
        fall_meda_id = "hospital-number", case_id = "case"
      ))
      if (grepl("v_mrpdokumentation", query)) return(data.table::data.table(
        record_id = "r", meda_id = "m",
        mrp_id = "mrp", outcome = "Problem nicht gelöst"
      ))
      stop("Unexpected query")
    }, .package = "etlutils"
  )
  # Automatic submodule functions are sourced by the standard manual workflow.
  # This isolated environment supplies their boundary results, without changing globals.
  environment <- new.env(parent = environment(loadCohortAnalysisData))
  calls <- character()
  environment$getResourcesFromDB <- function(resource_name, ...) {
    calls <<- c(calls, resource_name)
    if (resource_name == "Patient") return(data.table::data.table(
      pat_id = "p",
      pat_birthdate = as.Date("1980-01-01"), pat_gender = "male"
    ))
    data.table::data.table(
      enc_id = c("old", "case", "future"), enc_patient_ref = "Patient/p",
      enc_period_start = time + c(-100, 0, 100) * 86400
    )
  }
  environment$getConditionsFromDB <- function(...) data.table::data.table(
    con_patient_ref = "Patient/p",
    con_code_code = "Z00.0", start_datetime = time
  )
  environment$getMedicationRequestsFromDB <- function(..., status_exclusion) {
    expect_false("stopped" %in% status_exclusion)
    data.table::data.table(medreq_patient_ref = character(), atc_code = character(), start_datetime = time[FALSE])
  }
  environment$getATCMedicationsFromDB <- function(...) NULL
  environment$appendATCColumns <- function(requests, ...) requests
  environment$getObservationsFromDB <- function(...) NULL
  environment$getLOINCMapping <- function(...) list(processed_content = NULL)
  environment$prepareCohortLaboratory <- function(...) data.table::data.table(
    patient_id = character(),
    start_datetime = time[FALSE], code = character(), relevant = logical(), unit_ok = logical(),
    numeric_ok = logical(), abnormal = logical(), normal = logical(), egfr = logical(), value_reference = numeric()
  )
  environment$loadCohortProcedureData <- function(...) list(procedures = data.table::data.table(
    patient_id = character(),
    start_datetime = time[FALSE], proc_code_code = character(), ops_terminal = logical(),
    ops_year_approximated = logical(), ops_catalogue_year = integer()
  ))
  run <- loadCohortAnalysisData
  environment(run) <- environment
  result <- run(prepared, "UTC")
  expect_equal(calls, c("Patient", "Encounter"))
  expect_equal(nrow(result$cases), 1L)
  expect_equal(result$cases$m360, 1L)
  expect_equal(result$cases$m339, 1L)
  expect_equal(result$cases$code_cutoff, time + 2 * 86400)
  expect_true(result$cases$has_qualifying_manual_mrp)
  expect_equal(result$cases$m76, 0)
  expect_setequal(names(result$quality), c("check", "count"))
})
