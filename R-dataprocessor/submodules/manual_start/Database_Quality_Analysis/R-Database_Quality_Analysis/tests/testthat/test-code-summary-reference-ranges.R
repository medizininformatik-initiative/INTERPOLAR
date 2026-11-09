test_that("LOINC reference ranges prefer normal types and otherwise keep all untyped ranges", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    # Each measurement has two normal ranges plus an untyped and a therapeutic range.
    # Type systems intentionally differ: MRP priority uses the type code alone.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type,obs_range_system) SELECT 'normal'||n,'http://loinc.org','normal-priority',n,'mg/dL',r.low,r.high,r.type,r.system FROM generate_series(1,6) n CROSS JOIN (VALUES ('1','9','normal','https://example.org/other-system'),('0','10','normal',NULL),('2','8',NULL,NULL),('3','7','therapeutic',NULL)) r(low,high,type,system);",
    # Without an explicitly normal range, keep both untyped reference ranges.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type) SELECT 'fallback'||n,'http://loinc.org','missing-type',n,'mg/dL',r.low,r.high,r.type FROM generate_series(1,6) n CROSS JOIN (VALUES ('2','8',NULL),('4','6',' '),('3','7','therapeutic')) r(low,high,type);",
    # Keep observations with other range types in the report, without their limits.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type) SELECT 'other'||n,'http://loinc.org','other-types',n,'mg/dL',r.low,r.high,r.type FROM generate_series(1,6) n CROSS JOIN (VALUES ('3','7','therapeutic'),('2','8','critical')) r(low,high,type);",
    # Preference must be per observation, not across all observations of a code.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type) SELECT 'mixed-normal'||n,'http://loinc.org','mixed',n,'mg/dL','1','9','normal' FROM generate_series(1,5) n;",
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high) SELECT 'mixed-untyped'||n,'http://loinc.org','mixed',n,'mg/dL','2','8' FROM generate_series(1,5) n;",
    "INSERT INTO observation SELECT * FROM observation WHERE obs_code_code IN ('normal-priority','missing-type','other-types','mixed');"
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
  detail <- summaries$Observation[row_type == "detail"]
  normal <- detail[code == "normal-priority"]
  expect_equal(nrow(normal), 2L)
  expect_setequal(as.character(normal$low), c("0", "1"))
  expect_setequal(as.character(normal$high), c("9", "10"))
  expect_equal(normal$count, c(6, 6))
  expect_equal(normal$mean, c(3.5, 3.5))
  expect_equal(normal$sd, rep(stats::sd(1:6), 2))
  missing <- detail[code == "missing-type"]
  expect_equal(nrow(missing), 2L)
  expect_setequal(as.character(missing$low), c("2", "4"))
  expect_setequal(as.character(missing$high), c("6", "8"))
  expect_equal(missing$count, c(6, 6))
  expect_equal(missing$median, c(3.5, 3.5))
  other <- detail[code == "other-types"]
  expect_equal(nrow(other), 1L)
  expect_true(is.na(other$low))
  expect_true(is.na(other$high))
  expect_equal(other$count, 6)
  expect_equal(other$mean, 3.5)
  mixed <- detail[code == "mixed"]
  expect_equal(nrow(mixed), 2L)
  expect_setequal(as.character(mixed$low), c("1", "2"))
  expect_equal(mixed$count, c(5, 5))
  # Totals count each observation once, even when two preferred ranges survive.
  expect_equal(summaries$Observation[row_type == "total", count], 36)

  fixture$config$code_summary_normal_range$fallback_to_missing_type <- FALSE
  strict <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )$Observation
  expect_true(all(is.na(strict[row_type == "detail" & code == "missing-type", low])))
  expect_equal(strict[row_type == "total", count], 36)
  expect_equal(nrow(strict[row_type == "detail" & code == "normal-priority"]), 2L)
})

test_that("measurement unit systems remain separate for the same code and unit", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- paste0(
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_version,obs_code_code,",
    "obs_value,obs_unit,obs_unit_system,obs_low,obs_high,obs_range_type) ",
    "SELECT 'other-unit'||n,'http://loinc.org','v1','common',1,'mg/dL',",
    "'urn:other-units','1','10','normal' FROM generate_series(1,5) n;"
  )
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  detail <- summaries$Observation[row_type == "detail"]
  expect_equal(nrow(detail), 2L)
  expect_setequal(detail$unit_system, c("http://unitsofmeasure.org", "urn:other-units"))
  expect_equal(detail[unit_system == "urn:other-units", mean], 1)
  expect_equal(summaries$Observation[row_type == "total", count], 13)
})
