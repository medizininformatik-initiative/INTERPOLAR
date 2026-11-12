test_that("report types require an explicit supported type for every configured report", {
  fixture <- codeSummaryFixture()
  config <- fixture$config
  expect_identical(config$code_summary_report_types[["LOINC"]], "coding")
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
  toml <- sub('reports = ["ATC", "PZN", "SNOMED"]', 'reports = ["ATC", "PZN", "SNOMED", "ProductCodes"]', toml, fixed = TRUE)
  toml <- sub('reports = ["ICD", "SNOMED"]', 'reports = ["ICD", "SNOMED", "LocalDiagnoses"]', toml, fixed = TRUE)
  config_file <- tempfile(fileext = ".toml")
  on.exit(unlink(config_file), add = TRUE)
  writeLines(toml, config_file)
  config_envir <- new.env(parent = emptyenv())
  config_envir$CODE_SUMMARY_CONFIG_FILE <- config_file
  fixture$config <- getConfig(envir = config_envir, command_arguments = character())
  fixture$config$code_summary_processing$enabled <- FALSE
  fixture$config$code_summary_exports$variants <- c("all", "filtered")
  fixture$extra_sql <- c(
    "INSERT INTO medication (med_id,med_code_system,med_code_code) SELECT 'custom-product'||n,'urn:example:product-codes','custom-med' FROM generate_series(1,5) n;",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref) VALUES ('custom-r','Patient/custom','Encounter/custom','Medication/custom-product1');",
    "INSERT INTO condition (con_id,con_code_system,con_code_code) SELECT 'custom-diagnosis'||n,'urn:example:diagnoses','custom-condition' FROM generate_series(1,5) n;"
  )
  calls <- 0L
  unresolved_queries <- 0L
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      unresolved_queries <<- unresolved_queries + as.integer(grepl("unresolved_links AS MATERIALIZED", query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 4L)
  expect_equal(unresolved_queries, 1L)
  lab <- summaries$Observation[row_type == "detail"]
  expect_equal(lab$count, 6)
  expect_equal(lab$mean, 3.5)
  expect_equal(lab$median, 3.5)
  product <- summaries$Medication[system == "urn:example:product-codes" & row_type == "detail"]
  expect_equal(product$count, 5)
  expect_equal(product$case_count, 1)
  expect_equal(product$no_case_count, 4)
  expect_equal(summaries$Medication[system == "urn:example:product-codes" & row_type == "total", medication_request_count], 1)
  diagnosis <- summaries$Condition[row_type == "detail"]
  expect_equal(diagnosis$count, 5)
  expect_false(any(c("mean", "unit", "medication_count") %in% names(diagnosis)))
  expect_equal(summaries$Medication[row_type == "unresolved medication reference", count], 2)
})

test_that("plain coding sources do not read unrelated medication views or measurements", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_sources <- fixture$config$code_summary_sources[2:3]
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_false(grepl('"pg_temp"."medicationrequest"', query, fixed = TRUE))
      expect_false(grepl("unresolved_links", query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_named(summaries, c("Condition", "Procedure"))
  expect_false(any(c("mean", "unit", "low") %in% names(summaries$Condition)))
})

test_that("wildcards expand only imported Coding fields and explicit mappings take precedence", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_sources <- c(fixture$config$code_summary_sources, list(
    list(resource = "Observation", coding = "*", reports = "SNOMED", measurement = FALSE)
  ))
  sources <- resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)
  primary <- Filter(function(source) source$resource == "Observation" && source$coding == "code/coding", sources)
  expect_length(primary, 1L)
  expect_setequal(primary[[1]]$reports, c("LOINC", "SNOMED"))
  expect_true(primary[[1]]$measurement)
  method <- Filter(function(source) source$resource == "Observation" && source$coding == "method/coding", sources)
  expect_length(method, 1L)
  expect_false(method[[1]]$measurement)
  # Runtime validation checks the real view; missing required fields are reported.
  expect_warning(resolveCodeSummarySources(
    fixture$metadata[COLUMN_NAME != "obs_method_code"], fixture$config, fixture$description
  ), "required columns unavailable")
})
