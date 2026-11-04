test_that("code report settings are loaded from the module or selected TOML", {
  fixture <- codeSummaryFixture()
  config <- fixture$config
  expect_true(file.exists(config$code_summary_config_file))
  expect_equal(basename(dirname(config$code_summary_config_file)), "Database_Quality_Analysis")
  expect_identical(config$code_summary_systems$ATC, "http://fhir.de/CodeSystem/bfarm/atc")
  expect_false("http://www.whocc.no/atc" %in% config$code_summary_systems$ATC)
  expect_false("SNOMED CT" %in% names(config$code_summary_systems))
  medication_sources <- Filter(
    function(source) source$resource == "Medication",
    loadCodeSummaryConfig(config$code_summary_config_file)$sources
  )
  expect_equal(medication_sources[[1]]$coding, "code/coding")
  expect_setequal(medication_sources[[1]]$reports, c("ATC", "PZN"))
  expect_equal(medication_sources[[2]]$coding, "ingredient/itemCodeableConcept/coding")
  expect_identical(medication_sources[[2]]$reports, "ASK")
  expect_error(loadCodeSummaryConfig(tempfile()), "TOML file not found")
  custom_file <- tempfile(fileext = ".toml")
  on.exit(unlink(custom_file), add = TRUE)
  custom_text <- readLines(config$code_summary_config_file)
  custom_text <- sub('unit = "valueQuantity/code"', 'unit = "valueQuantity/system"', custom_text, fixed = TRUE)
  writeLines(custom_text, custom_file)
  config_envir <- new.env(parent = emptyenv())
  config_envir$CODE_SUMMARY_CONFIG_FILE <- custom_file
  custom_config <- getConfig(envir = config_envir, command_arguments = character())
  sources <- resolveCodeSummarySources(fixture$metadata, custom_config, fixture$description)
  expect_equal(sources[[1]]$fields[["unit"]], "obs_unit_system")
  custom_config$code_summary_sources[[1]]$fields <- list(unit = "valueQuantity/code")
  sources <- resolveCodeSummarySources(fixture$metadata, custom_config, fixture$description)
  expect_equal(sources[[1]]$fields[["unit"]], "obs_unit")
  writeLines(sub("fallback_to_missing_type = true", 'fallback_to_missing_type = "true"',
    custom_text,
    fixed = TRUE
  ), custom_file)
  expect_error(loadCodeSummaryConfig(custom_file), "must be a TOML boolean")
  writeLines("[systems]\nLOINC = ['http://loinc.org']", custom_file)
  expect_error(loadCodeSummaryConfig(custom_file), "Missing code summary TOML sections")
})

test_that("code sources resolve FHIR paths and never fall back to raw encounter references", {
  fixture <- codeSummaryFixture()
  sources <- resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)
  expect_equal(sources[[1]]$fields[["code"]], "obs_code_code")
  expect_equal(sources[[1]]$fields[["unit"]], "obs_unit")
  expect_equal(sources[[1]]$fields[["case_id"]], "obs_encounter_calculated_ref")
  expect_equal(sources[[5]]$fields[["code"]], "med_ingredient_code")
  expect_true(all(is.na(sources[[4]]$fields[c("pid", "case_id")])))
  without_calculated <- fixture$metadata[COLUMN_NAME != "obs_encounter_calculated_ref"]
  sources <- resolveCodeSummarySources(without_calculated, fixture$config, fixture$description)
  expect_true(is.na(sources[[1]]$fields[["case_id"]]))
  expect_warning(resolveCodeSummarySources(
    fixture$metadata[COLUMN_NAME != "obs_code_code"], fixture$config, fixture$description
  ), "required columns unavailable")
  duplicate <- data.table::rbindlist(list(fixture$description, fixture$description[1]))
  expect_silent(resolveCodeSummarySources(fixture$metadata, fixture$config, duplicate))
  fixture$config$code_summary_sources[[1]]$columns <- list(unit = "obs_unit_system")
  sources <- resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)
  expect_equal(sources[[1]]$fields[["unit"]], "obs_unit_system")
  fixture$config$code_summary_sources[[1]]$columns <- list(unit = "nonexistent")
  expect_error(resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description), "override columns unavailable")
  fixture <- codeSummaryFixture()
  ambiguous <- data.table::rbindlist(list(fixture$description, data.table::data.table(
    RESOURCE = "Observation", FHIR_EXPRESSION = "valueQuantity/code", COLUMN_NAME = "obs_unit_system"
  )))
  expect_error(resolveCodeSummarySources(fixture$metadata, fixture$config, ambiguous), "Ambiguous Table Description path")
  fixture$config$code_summary_sources[[1]]$columns <- list(unit = "obs_unit")
  expect_silent(resolveCodeSummarySources(fixture$metadata, fixture$config, ambiguous))
})

test_that("code reports batch source reads and keep archive columns free of IDs", {
  fixture <- codeSummaryFixture()
  calls <- 0L
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      expect_equal(length(gregexpr('FROM "pg_temp"."observation"', query, fixed = TRUE)[[1]]), 1L)
      expect_match(query, "COUNT(DISTINCT g.count_key)", fixed = TRUE)
      data.table::data.table()
    }, table_description = fixture$description
  )
  expect_equal(calls, 1L)
  expect_named(summaries, names(fixture$config$code_summary_systems))
  expect_false(any(c("value", "system", "resource_id", "pid", "case_id") %in% names(summaries$LOINC)))
  expect_true("unit" %in% names(summaries$LOINC))
  expect_true("no_reference_count_to_medication" %in% names(summaries$ATC))
})

test_that("PostgreSQL deduplicates measurements and independently aggregates rare groups and totals", {
  fixture <- codeSummaryFixture()
  sources <- resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)
  links <- resolveCodeSummaryMedicationLinks(fixture$metadata, fixture$description, fixture$config)
  query <- buildCodeSummaryQuery(sources, links, fixture$config$code_summary_systems, fixture$config$code_summary_normal_range)
  rows <- runCodeSummaryFixtureQuery(fixture, query)
  loinc <- rows[report == "LOINC" & row_type == "detail"]
  expect_equal(loinc$count, 6)
  expect_equal(loinc$patient_count, 1)
  expect_equal(loinc$case_count, 1)
  expect_equal(loinc$no_case_count, 1)
  expect_equal(loinc$median, 3.5)
  expect_equal(loinc$mean, 3.5)
  expect_equal(loinc$sd, stats::sd(1:6))
  expect_equal(loinc$q1, 2.25)
  expect_equal(loinc$q3, 4.75)
  expect_equal(loinc$low, 1)
  rare <- rows[report == "LOINC" & row_type == "other (count < 5)"]
  expect_equal(rare$count, 2)
  expect_equal(rare$case_count, 1)
  expect_true(is.na(rare$mean))
  expect_true(is.na(rare$code))
  total <- rows[report == "LOINC" & row_type == "total"]
  expect_equal(total$count, 8)
  expect_equal(total$case_count, 1)
  atc <- rows[report == "ATC" & row_type == "other (count < 5)"]
  expect_equal(atc$count, 1)
  expect_equal(atc$medication_count, 1)
  expect_equal(atc$medication_request_count, 2)
  expect_equal(atc$medication_administration_count, 3)
  expect_equal(atc$case_count, 1)
  expect_equal(atc$no_case_count, 0)
  missing <- rows[report == "ATC" & row_type == "unresolved medication reference"]
  expect_equal(missing$no_reference_count_to_medication, 2)
  expect_equal(missing$no_case_count, 2)
  expect_true(is.na(missing$count))
  expect_equal(rows[report == "ATC" & row_type == "detail", count], 5)
  expect_equal(rows[report == "ATC" & row_type == "total", count], 6)
  expect_equal(rows[report == "ATC" & row_type == "total", patient_count], 1)
  expect_equal(rows[report == "ATC" & row_type == "total", case_count], 1)
  expect_equal(rows[report == "ATC" & row_type == "total", medication_request_count], 2)
  partial <- NULL
  expect_warning(partial <- createCodeSummaryReports(
    fixture$metadata[TABLE_NAME != "medicationstatement"], fixture$config,
    table_description = fixture$description, query_fun = function(...) data.table::copy(rows)
  ), "Skipped medication link sources")
  expect_true(all(is.na(partial$ATC$medication_statement_count)))
  expect_true(all(is.na(partial$ATC$no_reference_count_to_medication)))
})

test_that("absolute references, unit systems, rare memberships and unconfigured systems are handled", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    "UPDATE medicationrequest SET medreq_medicationreference_ref='https://example.org/fhir/Medication/example' WHERE medreq_id='q1';",
    "UPDATE medicationadministration SET medadm_encounter_calculated_ref='https://example.org/fhir/Encounter/e1';",
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_code,obs_value,obs_unit) VALUES ('rare1','Patient/p1','Encounter/e1','http://loinc.org','r2',100,'g/L');",
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_version,obs_code_code,obs_value,obs_unit,obs_unit_system,obs_low,obs_high,obs_range_type,obs_range_system) SELECT 'new'||n,'http://loinc.org','v1','common',1,'mg/dL','https://example.org/other-unit-system','1','10','normal','http://terminology.hl7.org/CodeSystem/referencerange-meaning' FROM generate_series(1,5) n;",
    "INSERT INTO condition (con_id,con_code_system,con_code_code) VALUES ('same-id','http://snomed.info/sct','123');",
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code) VALUES ('same-id','http://snomed.info/sct','123');"
  )
  rows <- NULL
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      rows <<- runCodeSummaryFixtureQuery(fixture, query)
      rows
    }
  )
  loinc <- summaries$LOINC[row_type == "detail"]
  expect_equal(nrow(loinc), 2L)
  expect_setequal(loinc$unit_system, c("http://unitsofmeasure.org", "https://example.org/other-unit-system"))
  expect_equal(loinc[unit_system == "https://example.org/other-unit-system", mean], 1)
  expect_equal(summaries$LOINC[row_type == "other (count < 5)", count], 2)
  expect_equal(summaries$LOINC[row_type == "total", count], 13)
  expect_equal(summaries$ATC[row_type == "other (count < 5)", medication_request_count], 2)
  expect_equal(summaries$ATC[row_type == "other (count < 5)", case_count], 1)
  expect_equal(summaries$ATC[row_type == "unresolved medication reference", no_reference_count_to_medication], 2)
  expect_false("SNOMED CT" %in% names(summaries))
  expect_false(any(rows$report == "SNOMED CT"))
  expect_false(any(c("summary_id", "event_key", "count_key") %in% names(summaries$LOINC)))
})

test_that("code ZIP includes six CSVs and system/source documentation", {
  fixture <- codeSummaryFixture()
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    query_fun = function(...) data.table::data.table(), table_description = fixture$description
  )
  root <- tempfile("code-summary-archive-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  old_dirs <- if (exists("MODULE_DIRS", inherits = TRUE)) get("MODULE_DIRS", inherits = TRUE) else NULL
  assign("MODULE_DIRS", list(global_dir = root, local_dir = root), envir = .GlobalEnv)
  on.exit(
    {
      if (is.null(old_dirs)) rm("MODULE_DIRS", envir = .GlobalEnv) else assign("MODULE_DIRS", old_dirs, envir = .GlobalEnv)
    },
    add = TRUE
  )
  file <- writeCodeSummaryArchive(summaries, "DQA", timestamp = as.POSIXct("2026-11-04", tz = "UTC"))
  expect_match(basename(file), "_Code_Summary_")
  contents <- utils::unzip(file, list = TRUE)$Name
  expect_equal(sum(endsWith(contents, ".csv")), 6)
  expect_false("Codes/SNOMED_CT.csv" %in% contents)
  expect_true("README.txt" %in% contents)
})
