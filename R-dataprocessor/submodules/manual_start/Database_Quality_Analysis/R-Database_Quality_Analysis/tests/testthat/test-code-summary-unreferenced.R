test_that("unreferenced Medications are counted independently of usage codes and case assignment", {
  fixture <- codeSummaryFilteredFixture()
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO medication (med_id,med_code_system,med_code_code,med_ingredient_system,med_ingredient_code) VALUES ('orphan','http://fhir.de/CodeSystem/bfarm/atc','A02AH01','http://fhir.de/CodeSystem/ask','ingredient-one'),('orphan','http://fhir.de/CodeSystem/bfarm/atc','A02AH01','http://fhir.de/CodeSystem/ask','ingredient-two');",
    "INSERT INTO medication SELECT * FROM medication WHERE med_id='orphan';",
    "INSERT INTO medication (med_id,med_code_system,med_code_code) VALUES ('ref-no-case','http://fhir.de/CodeSystem/bfarm/atc','referenced-no-case'),('ref-admin','http://fhir.de/CodeSystem/bfarm/atc','via-admin'),('ref-statement','http://fhir.de/CodeSystem/bfarm/atc','via-statement'),('ref-no-id','http://fhir.de/CodeSystem/bfarm/atc','reference-without-own-id');",
    "INSERT INTO medicationrequest (medreq_id,medreq_medicationreference_ref) VALUES ('ref-no-case','https://example.org/fhir/Medication/ref-no-case'),(NULL,'Medication/ref-no-id');",
    "INSERT INTO medicationadministration (medadm_id,medadm_encounter_calculated_ref,medadm_medicationreference_ref) VALUES ('ref-admin','Encounter/e1','Medication/ref-admin');",
    "INSERT INTO medicationstatement (medstat_id,medstat_medicationreference_ref) VALUES ('ref-statement','Medication/ref-statement');",
    "INSERT INTO medicationrequest (medreq_id,medreq_direct_system,medreq_direct_code) VALUES ('same-code-unlinked','http://fhir.de/CodeSystem/bfarm/atc','A02AH01');",
    "INSERT INTO medicationrequest SELECT * FROM medicationrequest WHERE medreq_id='ref-no-case';"
  )
  for (mode in c("all", "resource")) {
    fixture$config$code_summary_query_batching <- mode
    calls <- 0L
    reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
      table_description = fixture$description,
      query_fun = function(query, lock_id) {
        calls <<- calls + 1L
        runCodeSummaryFixtureQuery(fixture, query)
      }
    )
    expect_equal(calls, if (mode == "all") 1L else 4L)
    local <- attr(reports, "local_reports", exact = TRUE)$Medication
    expect_false("no_reference_count_to_medication" %in% names(local))
    expect_false("no_reference_count_to_medication" %in% names(reports$Medication))
    orphan <- local[code == "A02AH01" & coding_path == "code/coding" & row_type == "detail"]
    expect_equal(orphan$count, 1)
    expect_equal(orphan$medication_count, 1)
    expect_equal(orphan$unreferenced_medication_count, 1)
    expect_equal(orphan$no_case_count, 1)
    direct <- local[code == "A02AH01" & coding_path == "MedicationRequest/medicationCodeableConcept/coding"]
    expect_equal(direct$medication_count, 0)
    expect_equal(direct$unreferenced_medication_count, 0)
    expect_equal(direct$medication_request_count, 1)
    for (code_value in c("referenced-no-case", "via-admin", "via-statement", "reference-without-own-id")) {
      expect_equal(local[code == code_value & row_type == "detail", unreferenced_medication_count], 0, info = code_value)
    }
    expect_equal(local[code == "referenced-no-case", no_case_count], 1)
    expect_equal(local[code == "referenced-no-case", medication_request_count], 1)
    expect_equal(local[code == "reference-without-own-id", medication_request_count], 0)
    ask <- local[system == "http://fhir.de/CodeSystem/ask"]
    expect_equal(ask[row_type == "detail", unreferenced_medication_count], c(1, 1))
    expect_equal(ask[row_type == "total", unreferenced_medication_count], 1)
    global_ask <- reports$Medication[system == "http://fhir.de/CodeSystem/ask"]
    expect_equal(global_ask[row_type == "detail", unreferenced_medication_count], c(1, 1))
    expect_equal(local[system == "http://fhir.de/CodeSystem/bfarm/atc" & row_type == "total", unreferenced_medication_count], 6)
    expect_true(all(local[row_type == "unresolved medication reference", unreferenced_medication_count] == 0))
    ip <- attr(reports, "filtered_reports", exact = TRUE)
    expect_true(all(ip$Medication$unreferenced_medication_count == 0))
    expect_true(all(attr(ip, "local_reports", exact = TRUE)$Medication$unreferenced_medication_count == 0))
    expect_false("unreferenced_medication_count" %in% names(attr(reports, "local_reports", exact = TRUE)$Observation))
  }
})

test_that("unreferenced counts are unavailable if a required usage source is missing", {
  fixture <- codeSummaryFixture()
  expect_warning(expect_warning(reports <- createCodeSummaryReports(
    fixture$metadata[TABLE_NAME != "medicationstatement"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Skipped code summary sources"), "Skipped medication link sources")
  expect_gt(nrow(reports$Medication), 0)
  expect_true(all(is.na(reports$Medication$unreferenced_medication_count)))
  expect_true(all(is.na(attr(reports, "local_reports", exact = TRUE)$Medication$unreferenced_medication_count)))
})

test_that("usage-only code reports cannot claim a measured unreferenced Medication count", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_sources <- Filter(function(source) source$resource != "Medication", fixture$config$code_summary_sources)
  fixture$extra_sql <- "INSERT INTO medicationrequest (medreq_id,medreq_direct_system,medreq_direct_code) SELECT 'only-direct'||n,'http://fhir.de/CodeSystem/bfarm/atc','direct' FROM generate_series(1,5) n;"
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  expect_gt(nrow(reports$Medication), 0)
  expect_true(all(is.na(reports$Medication$unreferenced_medication_count)))
  expect_equal(reports$Medication[row_type == "detail", medication_count], 0)
})
