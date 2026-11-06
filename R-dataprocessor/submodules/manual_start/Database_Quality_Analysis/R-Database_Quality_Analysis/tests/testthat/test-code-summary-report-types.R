test_that("report types require an explicit supported type for every configured report", {
  fixture <- codeSummaryFixture()
  config <- fixture$config
  expect_identical(config$code_summary_report_types[["LOINC"]], "measurement")
  expect_identical(config$code_summary_report_types[["ICD"]], "coding")
  expect_identical(config$code_summary_report_types[["PZN"]], "medication")
  expect_error(parseCodeSummaryReportTypes(list(LOINC = "unknown"), "LOINC"), "Report types must be")
  expect_error(parseCodeSummaryReportTypes(list(LOINC = c("coding", "measurement")), "LOINC"), "exactly one type")
  expect_error(parseCodeSummaryReportTypes(list(LOINC = "coding"), c("LOINC", "ICD")), "every configured report")
  expect_error(parseCodeSummaryReportTypes(list(LOINC = "coding", extra = "coding"), "LOINC"), "every configured report")
  config$code_summary_report_types[["LOINC"]] <- "medication"
  expect_error(resolveCodeSummarySources(fixture$metadata, config, fixture$description), "require a Medication source")
})

test_that("new medication and coding reports and renamed measurements use configured types", {
  fixture <- codeSummaryFixture()
  # Rename the measurement report and add two code systems through TOML only.
  # Insert into existing tables, keeping report definitions independent of order.
  toml <- readLines(fixture$config$code_summary_config_file)
  toml <- gsub("LOINC", "Laboratory", toml, fixed = TRUE)
  toml <- sub("[report_types]",
    'ProductCodes = ["urn:example:product-codes"]\nLocalDiagnoses = ["urn:example:diagnoses"]\n\n[report_types]',
    toml,
    fixed = TRUE
  )
  toml <- sub("[fields]", 'ProductCodes = "medication"\nLocalDiagnoses = "coding"\n\n[fields]', toml, fixed = TRUE)
  toml <- sub('reports = ["ATC", "PZN"]', 'reports = ["ATC", "PZN", "ProductCodes"]', toml, fixed = TRUE)
  toml <- sub('reports = ["ICD"]', 'reports = ["ICD", "LocalDiagnoses"]', toml, fixed = TRUE)
  config_file <- tempfile(fileext = ".toml")
  on.exit(unlink(config_file), add = TRUE)
  writeLines(toml, config_file)
  config_envir <- new.env(parent = emptyenv())
  config_envir$CODE_SUMMARY_CONFIG_FILE <- config_file
  fixture$config <- getConfig(envir = config_envir, command_arguments = character())
  fixture$extra_sql <- c(
    "INSERT INTO medication (med_id,med_code_system,med_code_code) SELECT 'custom-product'||n,'urn:example:product-codes','custom-med' FROM generate_series(1,5) n;",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref) VALUES ('custom-r','Patient/custom','Encounter/custom','Medication/custom-product1');",
    "INSERT INTO condition (con_id,con_code_system,con_code_code) SELECT 'custom-diagnosis'||n,'urn:example:diagnoses','custom-condition' FROM generate_series(1,5) n;"
  )
  calls <- 0L
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      expect_equal(sum(gregexpr("NOT EXISTS", query, fixed = TRUE)[[1]] > 0L), 1L)
      expect_match(query, "unresolved_links AS MATERIALIZED", fixed = TRUE)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  expect_false("LOINC" %in% names(summaries))
  lab <- summaries$Laboratory[row_type == "detail"]
  expect_equal(lab$count, 6)
  expect_equal(lab$mean, 3.5)
  expect_equal(lab$median, 3.5)
  product <- summaries$ProductCodes[row_type == "detail"]
  expect_equal(product$count, 5)
  expect_equal(product$medication_count, 5)
  expect_equal(product$medication_request_count, 1)
  expect_equal(product$case_count, 1)
  expect_equal(product$no_case_count, 4)
  expect_equal(summaries$ProductCodes[row_type == "unresolved medication reference", no_reference_count_to_medication], 2)
  diagnosis <- summaries$LocalDiagnoses[row_type == "detail"]
  expect_equal(diagnosis$count, 5)
  expect_false(any(c("mean", "unit", "medication_count") %in% names(diagnosis)))
  # Reference-issue totals are shared, including for the newly configured report.
  for (report_name in c("ATC", "PZN", "ASK", "ProductCodes")) {
    expect_equal(summaries[[report_name]][row_type == "unresolved medication reference", no_reference_count_to_medication], 2)
  }
})

test_that("plain coding reports do not read medication links or calculate measurement statistics", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_report_types[] <- "coding"
  sources <- resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)
  expect_true(is.na(sources[[1]]$fields[["value"]]))
  expect_true(is.na(sources[[1]]$fields[["unit"]]))
  links <- resolveCodeSummaryMedicationLinks(fixture$metadata, fixture$description, fixture$config)
  query <- buildCodeSummaryQuery(
    sources, links, fixture$config$code_summary_systems,
    fixture$config$code_summary_normal_range, fixture$config$code_summary_report_types
  )
  expect_false(grepl("unresolved_links", query, fixed = TRUE))
  expect_false(grepl('"pg_temp"."medicationrequest"', query, fixed = TRUE))
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_false(grepl('"pg_temp"."medicationrequest"', query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(summaries$ATC[row_type == "total", count], 6)
  expect_equal(summaries$ATC[row_type == "total", case_count], 0)
  expect_false(any(c("medication_count", "no_reference_count_to_medication") %in% names(summaries$ATC)))
  expect_false(any(c("mean", "unit", "low") %in% names(summaries$LOINC)))
})
