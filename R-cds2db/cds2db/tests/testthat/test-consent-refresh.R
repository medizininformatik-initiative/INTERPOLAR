testthat::test_that("Consent refresh covers known patients without date or age restrictions", {
  calls <- list()
  testthat::local_mocked_bindings(
    getActiveEncounterPIDsFromDB = function() character(),
    debugSetResourcesAddSearchParameter = function(...) list(Consent = "status=active")
  )
  testthat::local_mocked_bindings(
    isProcess = function(...) FALSE,
    isSubProcess = function(...) FALSE,
    catList = function(...) invisible(NULL),
    catWarningMessage = function(...) invisible(NULL),
    dbGetReadOnlyQuery = function(...) data.table::data.table(
      pat_id = character(), last_insert_datetime = as.POSIXct(character())
    ),
    runLevel3 = function(title, expr, ...) eval(substitute(expr), parent.frame()),
    fhirsearchMultipleResourcesByPID = function(pids_with_last_updated, table_descriptions,
                                                id_param_str, resources_add_search_parameter = NA,
                                                patient_age_at_enc_start = NULL, ...) {
      calls[[length(calls) + 1L]] <<- list(
        ids = unlist(pids_with_last_updated, use.names = FALSE),
        dates = names(pids_with_last_updated), resources = names(table_descriptions),
        filters = resources_add_search_parameter, age = patient_age_at_enc_start
      )
      tables <- if ("Consent" %in% names(table_descriptions)) {
        list(Consent = data.table::data.table(cons_id = "withdrawal"))
      } else list()
      list(raw_fhir_resources = tables, pids_with_last_updated = pids_with_last_updated)
    },
    .package = "etlutils"
  )
  descriptions <- list(
    Consent = fhircrackr::fhir_table_description(
      resource = "Consent", cols = fhircrackr::fhir_columns(c(cons_id = "id"))
    ),
    Observation = fhircrackr::fhir_table_description(
      resource = "Observation", cols = fhircrackr::fhir_columns(c(obs_id = "id"))
    )
  )
  for (ward_ids in list("new-patient", character())) {
    calls <- list()
    result <- loadResourcesByPatientIDFromFHIRServer(
      list(ward = data.table::data.table(patient_id = ward_ids)), descriptions,
      known_patient_ids = c("Patient/former-patient", "former-patient")
    )
    testthat::expect_identical(calls[[1]]$resources, "Observation")
    testthat::expect_equal(as.character(calls[[1]]$ids), ward_ids)
    testthat::expect_setequal(calls[[2]]$ids, c("former-patient", ward_ids))
    testthat::expect_identical(calls[[2]]$resources, "Consent")
    testthat::expect_true(all(is.na(calls[[2]]$dates)))
    testthat::expect_true(is.na(calls[[2]]$filters))
    testthat::expect_identical(calls[[2]]$age, 0L)
    testthat::expect_identical(result$Consent$cons_id, "withdrawal")
  }
})

testthat::test_that("resource-specific import retains the mandatory Consent refresh", {
  testthat::local_mocked_bindings(getDataImportResourceTypes = function() "Observation")
  result <- filterFhirTableDescriptionsForDataImport(list(
    pid_dependant = list(Patient = TRUE, Observation = TRUE, Consent = TRUE),
    pid_independant = list(Medication = TRUE)
  ))
  testthat::expect_setequal(names(result$pid_dependant), c("Observation", "Consent"))
})
