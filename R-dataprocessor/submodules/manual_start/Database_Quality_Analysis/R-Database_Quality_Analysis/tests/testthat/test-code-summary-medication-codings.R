test_that("PZN and ASK use their own Coding fields and deduplicate linked medications", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    # One product code and one ingredient code on each of five medications.
    "INSERT INTO medication (med_id,med_code_system,med_code_version,med_code_code,med_ingredient_system,med_ingredient_version,med_ingredient_code) SELECT 'product'||n,'http://fhir.de/CodeSystem/ifa/pzn','2025','00123456','http://fhir.de/CodeSystem/ask','2025','00001' FROM generate_series(1,5) n;",
    # Two medications have a second ingredient. This must not multiply PZN counts.
    "INSERT INTO medication SELECT med_id,med_code_system,med_code_version,med_code_code,med_ingredient_system,med_ingredient_version,'00002' FROM medication WHERE med_id IN ('product1','product3');",
    "INSERT INTO medication SELECT * FROM medication WHERE med_id LIKE 'product%';",
    # The same product code in a different version is a separate rare combination.
    "INSERT INTO medication (med_id,med_code_system,med_code_version,med_code_code) VALUES ('product-new-version','http://fhir.de/CodeSystem/ifa/pzn','2026','00123456');",
    # Codes in the wrong Coding field must not enter the corresponding report.
    "INSERT INTO medication (med_id,med_code_system,med_code_code) SELECT 'wrong-ask'||n,'http://fhir.de/CodeSystem/ask','wrong-primary' FROM generate_series(1,5) n;",
    "INSERT INTO medication (med_id,med_ingredient_system,med_ingredient_code) SELECT 'wrong-atc'||n,'http://fhir.de/CodeSystem/bfarm/atc','wrong-ingredient' FROM generate_series(1,5) n;",
    "INSERT INTO medication (med_id,med_ingredient_system,med_ingredient_code) SELECT 'wrong-pzn'||n,'http://fhir.de/CodeSystem/ifa/pzn','wrong-ingredient' FROM generate_series(1,5) n;",
    # Two medications share a case; one medication belongs to two cases.
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref) VALUES ('product-r1','Patient/p1','Encounter/e1','Medication/product1'),('product-r2','Patient/p1','Encounter/e1','Medication/product2'),('product-r3','Patient/p2','Encounter/e2','Medication/product1'),('wrong-field-r','Patient/other','Encounter/other','Medication/wrong-ask1');",
    "INSERT INTO medicationadministration (medadm_id,medadm_patient_ref,medadm_encounter_calculated_ref,medadm_medicationreference_ref) VALUES ('product-a1','Patient/p1','Encounter/e1','Medication/product2');",
    "INSERT INTO medicationstatement (medstat_id,medstat_patient_ref,medstat_encounter_calculated_ref,medstat_medicationreference_ref) VALUES ('product-s1','Patient/p2','Encounter/e2','Medication/product1'),('product-s2','Patient/p3','invalid','Medication/product3');",
    "INSERT INTO medicationrequest SELECT * FROM medicationrequest WHERE medreq_id LIKE 'product-%';",
    "INSERT INTO medicationadministration SELECT * FROM medicationadministration WHERE medadm_id LIKE 'product-%';",
    "INSERT INTO medicationstatement SELECT * FROM medicationstatement WHERE medstat_id LIKE 'product-%';"
  )
  calls <- 0L
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  expected_counts <- c(
    count = 5, medication_count = 5, patient_count = 3, case_count = 2,
    no_case_count = 3, medication_request_count = 3,
    medication_administration_count = 1, medication_statement_count = 2
  )
  for (report_name in c("PZN", "ASK")) {
    detail <- summaries[[report_name]][row_type == "detail"]
    expect_equal(nrow(detail), 1L, info = report_name)
    expect_equal(detail$version, "2025", info = report_name)
    for (column in names(expected_counts)) {
      expect_equal(detail[[column]], expected_counts[[column]], info = paste(report_name, column))
    }
    missing <- summaries[[report_name]][row_type == "unresolved medication reference"]
    # A resolvable reference to a medication with no report code is not an error.
    expect_equal(missing$no_reference_count_to_medication, 2)
    expect_false(any(grepl("wrong-", summaries[[report_name]]$code), na.rm = TRUE))
  }
  expect_identical(summaries$PZN[row_type == "detail", code], "00123456")
  expect_identical(summaries$ASK[row_type == "detail", code], "00001")
  expect_equal(summaries$PZN[row_type == "other (count < 5)", count], 1)
  expect_equal(summaries$PZN[row_type == "total", count], 6)
  expect_equal(summaries$PZN[row_type == "total", no_case_count], 4)
  ask_rare <- summaries$ASK[row_type == "other (count < 5)"]
  expect_equal(ask_rare$count, 2)
  expect_equal(ask_rare$case_count, 2)
  expect_equal(ask_rare$patient_count, 3)
  expect_equal(ask_rare$no_case_count, 1)
  expect_true(is.na(ask_rare$code))
  expect_equal(summaries$ASK[row_type == "total", count], 5)
  expect_equal(summaries$ASK[row_type == "total", case_count], 2)
  expect_equal(summaries$ASK[row_type == "total", no_case_count], 3)
  # ATC from an ingredient field is excluded even with five matching medications.
  expect_equal(summaries$ATC[row_type == "total", count], 6)
})
