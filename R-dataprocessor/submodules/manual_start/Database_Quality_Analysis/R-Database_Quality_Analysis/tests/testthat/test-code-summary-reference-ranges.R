test_that("LOINC retains every reference range and deduplicates totals", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    # Each measurement has two normal ranges plus an untyped and a therapeutic range.
    # Type systems and missing types remain visible.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type,obs_range_system) SELECT 'normal'||n,'http://loinc.org','normal-priority',n,'mg/dL',r.low,r.high,r.type,r.system FROM generate_series(1,6) n CROSS JOIN (VALUES ('1','9','normal','https://example.org/other-system'),('0','10','normal',NULL),('2','8',NULL,NULL),('3','7','therapeutic',NULL)) r(low,high,type,system);",
    # Untyped and therapeutic ranges coexist.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type) SELECT 'fallback'||n,'http://loinc.org','missing-type',n,'mg/dL',r.low,r.high,r.type FROM generate_series(1,6) n CROSS JOIN (VALUES ('2','8',NULL),('4','6',' '),('3','7','therapeutic')) r(low,high,type);",
    # Keep other range types with their limits.
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_low,obs_high,obs_range_type) SELECT 'other'||n,'http://loinc.org','other-types',n,'mg/dL',r.low,r.high,r.type FROM generate_series(1,6) n CROSS JOIN (VALUES ('3','7','therapeutic'),('2','8','critical')) r(low,high,type);",
    # Different observations may supply different ranges for the same code.
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
  expect_equal(nrow(normal), 4L)
  expect_setequal(as.character(normal$low), c("0", "1", "2", "3"))
  expect_setequal(as.character(normal$high), c("7", "8", "9", "10"))
  expect_equal(normal$count, rep(6, 4))
  expect_equal(normal$mean, rep(3.5, 4))
  expect_equal(normal$sd, rep(stats::sd(1:6), 4))
  missing <- detail[code == "missing-type"]
  expect_equal(nrow(missing), 3L)
  expect_setequal(as.character(missing$low), c("2", "3", "4"))
  expect_setequal(as.character(missing$high), c("6", "7", "8"))
  expect_equal(missing$count, rep(6, 3))
  expect_equal(missing$median, rep(3.5, 3))
  other <- detail[code == "other-types"]
  expect_equal(nrow(other), 2L)
  expect_setequal(other$low, c("2", "3"))
  expect_setequal(other$high, c("7", "8"))
  expect_equal(other$count, c(6, 6))
  expect_equal(other$mean, c(3.5, 3.5))
  mixed <- detail[code == "mixed"]
  expect_equal(nrow(mixed), 2L)
  expect_setequal(as.character(mixed$low), c("1", "2"))
  expect_equal(mixed$count, c(5, 5))
  # Totals count each observation once, even when multiple ranges survive.
  expect_equal(summaries$Observation[row_type == "total", count], 36)
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
  detail <- summaries$Observation[row_type == "detail" & code == "common"]
  expect_equal(nrow(detail), 2L)
  expect_setequal(detail$unit_system, c("http://unitsofmeasure.org", "urn:other-units"))
  expect_equal(detail[unit_system == "urn:other-units", mean], 1)
  expect_equal(summaries$Observation[row_type == "total", count], 13)
})


test_that("range types and ages preserve exact counts in adult scopes and chunks", {
  fixture <- codeSummaryRangeFixture()
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  for (variant in attr(reports, "variant_reports")) {
    rows <- attr(variant, "local_reports")$Observation
    detail <- rows[row_type == "detail" & code == "2345-7"]
    expect_equal(nrow(detail), 5L)
    expect_equal(detail$count, rep(6, 5))
    expect_equal(detail$patient_count, rep(3, 5))
    expect_equal(detail$case_count, rep(2, 5))
    expect_equal(detail$no_case_count, rep(0, 5))
    expect_equal(detail$mean, rep(87.5, 5))
    expect_equal(detail$sd, rep(stats::sd(seq(75, 100, 5)), 5))
    expect_setequal(detail$range_type, c("normal", "therapeutic"))
    expect_setequal(detail$range_type_system, c("http://terminology.hl7.org/CodeSystem/referencerange-meaning", "urn:example:range-types"))
    expect_equal(detail[age_low_code == "mo", age_low], "216")
    expect_equal(detail[age_low_code == "mo", age_high], "780")
    expect_true(is.na(detail[age_low == "65", age_high]))
    expect_equal(rows[row_type == "total", count], 14)
    expect_equal(rows[row_type == "total", patient_count], 9)
    expect_equal(rows[row_type == "total", case_count], 2)
    expect_equal(rows[code == "synthetic-zero" & row_type == "detail", mean], 0)
  }
  fixture$config$code_summary_processing$enabled <- TRUE
  fixture$config$code_summary_processing$max_codes_per_chunk <- 1L
  chunked <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  for (scope in names(attr(reports, "variant_reports"))) {
    expect_equal(
      attr(chunked, "variant_reports")[[scope]]$Observation,
      attr(reports, "variant_reports")[[scope]]$Observation
    )
    expect_equal(
      attr(attr(chunked, "variant_reports")[[scope]], "local_reports")$Observation,
      attr(attr(reports, "variant_reports")[[scope]], "local_reports")$Observation
    )
  }
})
