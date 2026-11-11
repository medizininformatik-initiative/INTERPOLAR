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
  med <- summaries$Medication
  pzn <- med[system == "http://fhir.de/CodeSystem/ifa/pzn"]
  ask <- med[system == "http://fhir.de/CodeSystem/ask"]
  for (report in list(pzn, ask)) {
    detail <- report[row_type == "detail"]
    expect_equal(nrow(detail), 1L)
    expect_equal(detail$version, "2025")
    expect_equal(detail$count, 5)
    expect_equal(detail$patient_count, 3)
    expect_equal(detail$case_count, 2)
    expect_equal(detail$no_case_count, 3)
    expect_false(any(grepl("wrong-", report$code), na.rm = TRUE))
  }
  expect_identical(pzn[row_type == "detail", code], "00123456")
  expect_identical(ask[row_type == "detail", code], "00001")
  expect_equal(pzn[row_type == "other (count < 5)", count], 1)
  expect_equal(pzn[row_type == "total", count], 6)
  expect_equal(pzn[row_type == "total", no_case_count], 4)
  expect_equal(ask[row_type == "other (count < 5)", count], 2)
  expect_equal(ask[row_type == "other (count < 5)", case_count], 2)
  expect_equal(ask[row_type == "other (count < 5)", no_case_count], 1)
  expect_equal(ask[row_type == "total", count], 5)
  expect_equal(med[system == "http://fhir.de/CodeSystem/bfarm/atc" & row_type == "total", count], 6)
  for (report in list(pzn, ask)) {
    expect_equal(report[row_type == "total", medication_request_count], 3)
    expect_equal(report[row_type == "total", medication_administration_count], 1)
    expect_equal(report[row_type == "total", medication_statement_count], 2)
    expect_equal(report[row_type == "detail", medication_count], 5)
  }
  expect_equal(med[row_type == "unresolved medication reference", count], 2)
})

test_that("inline medication codes and references count owning IDs once", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_code) SELECT 'inline'||n,'Patient/p'||n,'Encounter/e'||n,CASE WHEN n=1 THEN 'Medication/m1' END,'http://fhir.de/CodeSystem/bfarm/atc','A01' FROM generate_series(1,5) n;",
    "INSERT INTO medicationadministration (medadm_id,medadm_direct_system,medadm_direct_code) SELECT 'inline'||n,'http://fhir.de/CodeSystem/bfarm/atc','A01' FROM generate_series(1,5) n;",
    "INSERT INTO medicationstatement (medstat_id,medstat_direct_system,medstat_direct_code) SELECT 'inline'||n,'http://fhir.de/CodeSystem/ifa/pzn','00123456' FROM generate_series(1,5) n;",
    "INSERT INTO medicationrequest SELECT * FROM medicationrequest WHERE medreq_id LIKE 'inline%';"
  )
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  med <- summaries$Medication
  paths <- c(
    MedicationRequest = "medication_request_count",
    MedicationAdministration = "medication_administration_count", MedicationStatement = "medication_statement_count"
  )
  for (resource in names(paths)) {
    detail <- med[row_type == "detail" & coding_path == paste0(resource, "/medicationCodeableConcept/coding")]
    expect_equal(detail$count, 5, info = resource)
    expect_equal(detail[[paths[[resource]]]], 5, info = resource)
    expect_equal(detail$medication_count, if (resource == "MedicationRequest") 1 else 0)
    expect_equal(detail$unreferenced_medication_count, 0)
  }
  expect_equal(med[row_type == "unresolved medication reference", count], 2)
  atc <- med[system == "http://fhir.de/CodeSystem/bfarm/atc" & row_type == "total"]
  expect_equal(atc$count, 15)
  expect_equal(atc$medication_count, 6)
  expect_equal(atc$medication_request_count, 7)
  expect_equal(atc$medication_administration_count, 8)
  expect_identical(med[row_type == "detail" & medication_statement_count == 5, code], "00123456")
  expect_named(summaries, c("Observation", "Condition", "Procedure", "Medication"))
})

test_that("missing link views are unavailable rather than measured zero counts", {
  fixture <- codeSummaryFixture()
  expect_warning(expect_warning(summaries <- createCodeSummaryReports(
    fixture$metadata[TABLE_NAME != "medicationstatement"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Skipped code summary sources"), "Skipped medication link sources")
  expect_true(all(is.na(summaries$Medication$medication_statement_count)))
  expect_true(all(is.na(summaries$Medication$unreferenced_medication_count)))
})
