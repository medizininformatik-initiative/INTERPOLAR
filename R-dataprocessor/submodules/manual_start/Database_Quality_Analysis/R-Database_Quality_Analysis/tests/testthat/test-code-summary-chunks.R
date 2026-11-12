expectCodeSummaryTablesEqual <- function(actual, expected) {
  compareScope <- function(a, e) {
    normalize <- function(scope) lapply(scope, function(table) {
      table <- data.table::copy(table)
      normalizeCodeSummaryGroupKeys(table, c("low", "high", "code", "version", "unit"))
      columns <- intersect(c("system", "coding_path", "row_type", "version", "code", "unit", "unit_system", "low", "high"), names(table))
      data.table::setorderv(table, columns, na.last = TRUE)
      table
    })
    expect_equal(normalize(a), normalize(e), tolerance = 1e-12)
    expect_equal(normalize(attr(a, "local_reports")), normalize(attr(e, "local_reports")), tolerance = 1e-12)
  }
  compareScope(actual, expected)
  if (!is.null(attr(expected, "filtered_reports"))) compareScope(attr(actual, "filtered_reports"), attr(expected, "filtered_reports"))
  for (name in names(attr(expected, "variant_reports"))) {
    compareScope(attr(actual, "variant_reports")[[name]], attr(expected, "variant_reports")[[name]])
  }
}

test_that("code chunks preserve every detail count and statistic across report variants", {
  fixture <- codeSummaryAgeFixture()
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type) VALUES ('same-id','Patient/p1',NULL,'http://loinc.org','0001',10,'mg','0.00','20.00','normal'),('same-id','Patient/p1','Encounter/e2','http://loinc.org','0002',50,'mg','0','20','normal'),('same-id','Patient/p1','Encounter/e2','http://loinc.org','0002',50,'mg','2','18',NULL),('same-id','Patient/p1','Encounter/e2','http://loinc.org','0002',50,'mg','1','19','normal');",
    "INSERT INTO observation (obs_id,obs_encounter_calculated_ref,obs_code_system,obs_code_code,obs_value,obs_unit) VALUES ('quoted','Encounter/e2','http://loinc.org','O''code',2,'mg');",
    "INSERT INTO medication (med_id,med_code_system,med_code_code,med_ingredient_system,med_ingredient_code) VALUES ('example','http://fhir.de/CodeSystem/ifa/pzn','00123456','http://fhir.de/CodeSystem/ask','0123'),('m1','http://snomed.info/sct','372687004',NULL,NULL);",
    "INSERT INTO medicationrequest (medreq_id,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_code) VALUES ('cross-chunk','Encounter/e2',NULL,'http://fhir.de/CodeSystem/bfarm/atc','B01'),('cross-chunk','Encounter/e1','Medication/example',NULL,NULL),('no-ref-direct','Encounter/e2',NULL,NULL,NULL),('no-ref-direct','Encounter/e1',NULL,'http://fhir.de/CodeSystem/bfarm/atc','outside-direct');"
  )
  fixture$config$code_summary_processing <- list(enabled = FALSE, target_rows_per_chunk = 3, max_codes_per_chunk = 1L)
  run <- function() createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  for (selection in list(fixture$config$code_summary_exports$variants, "filtered_age_ge18", c("all_age_lt18", "filtered_age_ge18"), "all")) {
    fixture$config$code_summary_exports$variants <- selection
    fixture$config$code_summary_processing$enabled <- FALSE
    fixture$config$code_summary_query_batching <- "all"
    expected <- run()
    fixture$config$code_summary_processing$enabled <- TRUE
    for (batching in c("all", "resource")) {
      fixture$config$code_summary_query_batching <- batching
      actual <- run()
      expectCodeSummaryTablesEqual(actual, expected)
    }
  }
})

test_that("code chunk planning isolates hot codes and never divides a code group", {
  catalog <- data.table::data.table(system = "s", code = c("hot", "a", "b", "c", "d"), source_rows = c(1000, 8, 7, 3, 2))
  processing <- list(target_rows_per_chunk = 10, max_codes_per_chunk = 2L)
  chunks <- planCodeSummaryChunks(catalog, processing)
  expect_equal(chunks[[1]]$code, "hot")
  expect_setequal(unlist(lapply(chunks, `[[`, "code")), catalog$code)
  expect_equal(sum(vapply(chunks, nrow, integer(1))), nrow(catalog))
  expect_true(all(vapply(chunks[-1], function(chunk) sum(chunk$source_rows) <= 10 && nrow(chunk) <= 2, logical(1))))
  expect_length(planCodeSummaryChunks(catalog[0], processing), 0L)
  expect_error(planCodeSummaryChunks(data.table::copy(catalog)[1, source_rows := Inf], processing), "row estimates")
  expect_error(parseCodeSummaryProcessing(list(target_rows_per_chunk = 0)), "positive integer")
  expect_error(parseCodeSummaryProcessing(list(max_codes_per_chunk = 1.5)), "positive integer")
  expect_error(parseCodeSummaryProcessing(list(enabled = "true")), "TOML boolean")
})

test_that("empty selected scopes and missing optional Medication sources work with chunks", {
  fixture <- codeSummaryAgeFixture()
  fixture$config$code_summary_processing <- list(enabled = TRUE, target_rows_per_chunk = 2, max_codes_per_chunk = 1L)
  fixture$config$code_summary_exports$variants <- "filtered_age_ge18"
  fixture$extra_sql <- c(fixture$extra_sql, "DELETE FROM pids_per_ward;")
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  scope <- attr(reports, "variant_reports")$filtered_age_ge18
  expect_true(all(vapply(scope, nrow, integer(1)) == 0L))
  fixture <- codeSummaryFilteredFixture()
  fixture$config$code_summary_exports$variants <- "filtered"
  fixture$config$code_summary_sources <- Filter(function(source) source$resource != "Medication", fixture$config$code_summary_sources)
  fixture$config$code_summary_processing <- list(enabled = FALSE, target_rows_per_chunk = 2, max_codes_per_chunk = 1L)
  run <- function() createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  expected <- run()
  fixture$config$code_summary_processing$enabled <- TRUE
  expectCodeSummaryTablesEqual(run(), expected)
})

test_that("chunked automatic SNOMED statistics preserve non-finite values and unit systems", {
  fixture <- codeSummarySnomedFixture()
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_version,obs_code_code,obs_value,obs_unit,obs_unit_system,obs_low,obs_high,obs_range_type) VALUES ('nonfinite','http://snomed.info/sct','demo-v1','386661006','Infinity','Cel','http://unitsofmeasure.org','36','38','normal'),('other-unit','http://snomed.info/sct','demo-v1','386661006',37,'Cel','urn:other-units','36.0','38.0','normal');"
  )
  fixture$config$code_summary_processing <- list(enabled = FALSE, target_rows_per_chunk = 5, max_codes_per_chunk = 1L)
  run <- function() createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  expected <- run()
  fixture$config$code_summary_processing$enabled <- TRUE
  actual <- run()
  expectCodeSummaryTablesEqual(actual, expected)
  local <- attr(actual, "local_reports")$Observation
  expect_equal(local[code == "386661006" & unit_system == "http://unitsofmeasure.org" & row_type == "detail", count], 7)
  expect_equal(local[code == "386661006" & unit_system == "urn:other-units" & row_type == "detail", low], "36.0")
})
