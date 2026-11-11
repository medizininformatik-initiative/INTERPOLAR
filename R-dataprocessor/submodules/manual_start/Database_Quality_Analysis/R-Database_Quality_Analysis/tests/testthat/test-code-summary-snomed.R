test_that("synthetic SNOMED data produce visible detail rows in all four reports", {
  fixture <- codeSummarySnomedFixture()
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
  expect_named(summaries, c("Observation", "Condition", "Procedure", "Medication"))
  totals <- c(Observation = 14, Condition = 10, Procedure = 11, Medication = 25)
  for (resource in names(totals)) {
    rows <- summaries[[resource]][system == "http://snomed.info/sct"]
    expect_true(nrow(rows[row_type == "detail"]) > 0L, info = resource)
    expect_true(all(rows[row_type == "detail", count] >= 5), info = resource)
    expect_equal(rows[row_type == "total", count], totals[[resource]], info = resource)
  }
  measurement <- summaries$Observation[system == "http://snomed.info/sct" &
    row_type == "detail" & code == "386661006"]
  expect_equal(measurement$mean, 36.35)
  expect_equal(measurement$median, 36.35)
  expect_equal(measurement$count, 6)
  expect_equal(measurement$patient_count, 6)
  expect_equal(measurement$case_count, 3)
  expect_equal(measurement$unit, "Cel")
  expect_false(any(summaries$Observation$coding_path == "method/coding", na.rm = TRUE))
  expect_false(any(summaries$Observation$code == "414564002", na.rm = TRUE))
  med <- summaries$Medication[system == "http://snomed.info/sct"]
  expect_false(any(med$coding_path == "ingredient/itemCodeableConcept/coding", na.rm = TRUE))
  direct <- med[row_type == "detail" & coding_path == "MedicationStatement/medicationCodeableConcept/coding"]
  expect_equal(direct$medication_count, 0)
  expect_equal(direct$medication_statement_count, 5)
  expect_equal(direct$count, 5)
  total <- med[row_type == "total"]
  expect_equal(total$medication_count, 10)
  expect_equal(total$medication_request_count, 11)
  expect_equal(total$medication_administration_count, 11)
  expect_equal(total$medication_statement_count, 5)
  expect_equal(total$unreferenced_medication_count, 4)
  expect_equal(med[row_type == "other (count < 5)", count], 4)
})
