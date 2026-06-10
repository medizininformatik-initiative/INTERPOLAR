###########################################
### TEST cohort filter resource loading ###
###########################################

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

testthat::test_that("getCohortFilterResourceRequest builds generic resource requests", {
  localSetGlobal("FHIR_SERVER_ENDPOINT", "http://example.test/fhir")
  localSetGlobal("COUNT_PER_BUNDLE", 17)

  request <- getCohortFilterResourceRequest("Observation", "status=final&code=12345")

  testthat::expect_equal(
    as.character(request),
    "http://example.test/fhir/Observation?_count=17&status=final&code=12345"
  )
})

testthat::test_that("loadCohortFilterResourceTablesFromFHIRServer downloads filter resources", {
  localSetGlobal("FHIR_SERVER_ENDPOINT", "http://example.test/fhir")
  localSetGlobal("COUNT_PER_BUNDLE", 17)
  localSetGlobal("MAX_ENCOUNTER_BUNDLES", 3)
  calls <- list()
  downloadFunction <- function(request, table_description, max_bundles, log_errors) {
    calls[[length(calls) + 1]] <<- list(
      request = as.character(request),
      max_bundles = max_bundles,
      log_errors = log_errors
    )
    table <- data.table::data.table(
      id = "obs-1",
      subject.reference = "Patient/pat-1",
      patient.reference = NA_character_,
      code.coding.code = "12345"
    )
    data.table::setnames(table, table_description@cols@names)
    table
  }
  refresh_count <- 0

  table_descriptions <- list(
    Observation = fhircrackr::fhir_table_description(
      resource = "Observation",
      cols = c("id", "subject/reference", "patient/reference", "code/coding/code"),
      sep = SEP,
      brackets = NULL
    )
  )

  resource_tables <- loadCohortFilterResourceTablesFromFHIRServer(
    table_descriptions = table_descriptions,
    resources_add_search_parameter = list(Observation = "status=final"),
    download_function = downloadFunction,
    refresh_token_function = function() refresh_count <<- refresh_count + 1
  )

  testthat::expect_equal(refresh_count, 1)
  testthat::expect_equal(length(calls), 1)
  testthat::expect_equal(calls[[1]]$request, "http://example.test/fhir/Observation?_count=17&status=final")
  testthat::expect_equal(calls[[1]]$max_bundles, 3)
  testthat::expect_equal(calls[[1]]$log_errors, "observation_cohort_filter_error.xml")
  testthat::expect_named(resource_tables, "Observation")
  testthat::expect_named(resource_tables$Observation, c("id", "subject/reference", "patient/reference", "code/coding/code"))
  testthat::expect_equal(resource_tables$Observation[["subject/reference"]], "Patient/pat-1")
})

testthat::test_that("loadCohortFilterResourceTablesFromFHIRServer honors empty debug downloads", {
  localSetGlobal("MAX_ENCOUNTER_BUNDLES", 3)
  download_count <- 0
  table_descriptions <- list(
    Observation = fhircrackr::fhir_table_description(
      resource = "Observation",
      cols = c("id", "subject/reference", "patient/reference", "code/coding/code"),
      sep = SEP,
      brackets = NULL
    )
  )

  resource_tables <- loadCohortFilterResourceTablesFromFHIRServer(
    table_descriptions = table_descriptions,
    resources_add_search_parameter = list(Observation = ""),
    download_function = function(...) download_count <<- download_count + 1,
    refresh_token_function = function() NULL
  )

  testthat::expect_equal(download_count, 0)
  testthat::expect_equal(nrow(resource_tables$Observation), 0)
  testthat::expect_named(resource_tables$Observation, table_descriptions$Observation@cols@names)
})

testthat::test_that("getPIDsSplittedByCohort loads resources and extracts matching PIDs", {
  localSetGlobal("VERBOSE", 0)
  etlutils::createClock()
  variable_name <- "COHORT_FILTER_PATTERN_1"
  on.exit(rm(list = variable_name, envir = .GlobalEnv), add = TRUE)
  assign(
    variable_name,
    c(
      "cohort_name = 'DUP 1'",
      "resource = 'Observation' + code/coding/code = '12345'"
    ),
    envir = .GlobalEnv
  )

  loadResourceTables <- function(table_descriptions) {
    testthat::expect_named(table_descriptions, "Observation")
    list(
      Observation = data.table::data.table(
        id = "obs-1",
        "subject/reference" = "Patient/pat-1",
        "patient/reference" = NA_character_,
        "code/coding/code" = "12345"
      )
    )
  }

  pids_splitted_by_cohort <- getPIDsSplittedByCohort(
    log_result = FALSE,
    load_resource_tables_function = loadResourceTables
  )

  testthat::expect_named(pids_splitted_by_cohort, "DUP 1")
  testthat::expect_equal(
    pids_splitted_by_cohort[["DUP 1"]][, .(patient_id, source_resource_type, source_resource_id)],
    data.table::data.table(
      patient_id = "pat-1",
      source_resource_type = "Observation",
      source_resource_id = "obs-1"
    )
  )
})
