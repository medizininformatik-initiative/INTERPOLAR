test_that("flattened medication links preserve direct-code identities and null-version matching", {
  fixture <- codeSummaryFilteredFixture()
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO medication (med_id,med_code_system,med_code_code) VALUES ('identity-med','http://fhir.de/CodeSystem/bfarm/atc','identity-code');",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_version,medreq_direct_code) SELECT 'identity-r'||n,'Patient/p1','Encounter/e2','Medication/identity-med','http://fhir.de/CodeSystem/bfarm/atc',NULL,'identity-code' FROM generate_series(1,6) n CROSS JOIN generate_series(1,100) duplicates;",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_version,medreq_direct_code) VALUES ('identity-different-version','Patient/p1','Encounter/e2','Medication/identity-med','http://fhir.de/CodeSystem/bfarm/atc','v2','identity-code');"
  )
  calls <- 0L
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  for (scope in list(reports, attr(reports, "filtered_reports", exact = TRUE))) {
    local <- attr(scope, "local_reports", exact = TRUE)$Medication
    total <- local[system == "http://fhir.de/CodeSystem/bfarm/atc" & row_type == "total"]
    primary <- local[code == "identity-code" & coding_path == "code/coding" & row_type == "detail"]
    direct <- local[code == "identity-code" & coding_path == "MedicationRequest/medicationCodeableConcept/coding" & row_type == "detail"]
    expect_equal(primary$medication_count, 1)
    expect_equal(primary$medication_request_count, 7)
    expect_equal(direct[is.na(version), count], 1)
    expect_equal(direct[is.na(version), medication_count], 1)
    expect_equal(direct[is.na(version), medication_request_count], 6)
    expect_equal(direct[version == "v2", count], 1)
    expect_equal(direct[version == "v2", medication_count], 0)
    expect_true(all(direct$no_reference_count_to_medication == 0))
    expect_true(nrow(total) == 1L)
  }
})

test_that("resource batches preserve all results and read only their own resource views", {
  for (fixture_fun in list(codeSummaryFixture, codeSummarySnomedFixture, codeSummaryFilteredFixture)) {
    fixture <- fixture_fun()
    fixture$config$code_summary_query_batching <- "all"
    expected <- createCodeSummaryReports(fixture$metadata, fixture$config,
      table_description = fixture$description,
      query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
    )
    fixture$config$code_summary_query_batching <- "resource"
    queries <- character()
    actual <- createCodeSummaryReports(fixture$metadata, fixture$config,
      table_description = fixture$description,
      query_fun = function(query, lock_id) {
        queries <<- c(queries, query)
        runCodeSummaryFixtureQuery(fixture, query)
      }
    )
    expect_equal(length(queries), 4L)
    expect_equal(actual, expected)
    for (view in c("observation", "condition", "procedure", "medication", "medicationrequest", "medicationadministration", "medicationstatement")) {
      needle <- paste0('FROM "pg_temp"."', view, '"')
      expect_equal(sum(vapply(queries, function(query) sum(gregexpr(needle, query, fixed = TRUE)[[1]] > 0L), integer(1))), 1L)
    }
    for (query in queries[1:3]) expect_false(grepl('FROM "pg_temp"."medication', query, fixed = TRUE))
  }
  config <- getConfig(envir = new.env(parent = emptyenv()), command_arguments = character())
  expect_equal(config$code_summary_query_batching, "resource")
})
