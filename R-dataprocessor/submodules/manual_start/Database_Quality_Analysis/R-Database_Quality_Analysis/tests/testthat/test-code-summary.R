test_that("code report settings are loaded from the module or selected TOML", {
  fixture <- codeSummaryFixture()
  config <- fixture$config
  expect_true(file.exists(config$code_summary_config_file))
  expect_equal(basename(dirname(config$code_summary_config_file)), "Database_Quality_Analysis")
  expect_identical(config$code_summary_systems$ATC, "http://fhir.de/CodeSystem/bfarm/atc")
  expect_false("http://www.whocc.no/atc" %in% config$code_summary_systems$ATC)
  expect_identical(config$code_summary_systems$SNOMED, "http://snomed.info/sct")
  expect_setequal(unique(vapply(config$code_summary_sources, `[[`, character(1), "resource")), c(
    "Observation", "Condition", "Procedure", "Medication", "MedicationRequest",
    "MedicationAdministration", "MedicationStatement"
  ))
  medication_sources <- Filter(
    function(source) source$resource == "Medication",
    loadCodeSummaryConfig(config$code_summary_config_file)$sources
  )
  expect_equal(medication_sources[[1]]$coding, "code/coding")
  expect_setequal(medication_sources[[1]]$reports, c("ATC", "PZN", "SNOMED"))
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

test_that("resource reports batch source reads and keep archive columns free of IDs", {
  fixture <- codeSummaryFixture()
  calls <- 0L
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      for (view in setdiff(unique(fixture$metadata$VIEW_NAME), c("patient", "encounter", "location"))) {
        expect_equal(sum(gregexpr(paste0('FROM "pg_temp"."', view, '"'), query, fixed = TRUE)[[1]] > 0L), 1L)
      }
      for (view in c("patient", "encounter", "location")) {
        expect_false(grepl(paste0('FROM "pg_temp"."', view, '"'), query, fixed = TRUE))
      }
      data.table::data.table()
    }, table_description = fixture$description
  )
  expect_equal(calls, 1L)
  expect_setequal(names(summaries), c("Observation", "Condition", "Procedure", "Medication"))
  expect_false(any(c("value", "resource_id", "pid", "case_id") %in% names(summaries$Observation)))
  expect_true(all(c("system", "coding_path", "unit") %in% names(summaries$Observation)))
  expect_true("unreferenced_medication_count" %in% names(summaries$Medication))
  expect_false("no_reference_count_to_medication" %in% names(summaries$Medication))
  expect_false("MedicationRequest" %in% names(summaries))
})

test_that("PostgreSQL deduplicates measurements, rare groups, systems and owning resources", {
  fixture <- codeSummaryFixture()
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  loinc <- summaries$Observation[row_type == "detail"]
  expect_equal(loinc$count, 6)
  expect_equal(loinc$patient_count, 1)
  expect_equal(loinc$case_count, 1)
  expect_equal(loinc$no_case_count, 1)
  expect_equal(loinc$median, 3.5)
  expect_equal(loinc$mean, 3.5)
  expect_equal(loinc$sd, stats::sd(1:6))
  expect_equal(loinc$q1, 2.25)
  expect_equal(loinc$q3, 4.75)
  expect_equal(loinc$low, "1")
  expect_equal(loinc$coding_path, "code/coding")
  rare <- summaries$Observation[row_type == "other (count < 5)"]
  expect_equal(rare$count, 2)
  expect_equal(rare$case_count, 1)
  expect_true(is.na(rare$mean))
  expect_true(is.na(rare$code))
  expect_equal(summaries$Observation[row_type == "total", count], 8)
  med <- summaries$Medication
  expect_equal(med[row_type == "detail", count], 5)
  expect_equal(med[row_type == "total", count], 6)
  expect_equal(med[row_type == "total", case_count], 1)
  expect_equal(med[row_type == "total", no_case_count], 5)
  rare_med <- med[row_type == "other (count < 5)"]
  expect_equal(rare_med$count, 1)
  expect_equal(rare_med$medication_count, 1)
  expect_equal(rare_med$medication_request_count, 2)
  expect_equal(rare_med$medication_administration_count, 3)
  missing <- med[row_type == "unresolved medication reference"]
  expect_equal(missing$count, 2)
  expect_equal(missing$medication_count, 0)
  expect_equal(missing$unreferenced_medication_count, 0)
  expect_equal(missing$no_case_count, 2)
  expect_true(is.na(missing$system))
  expect_equal(med[row_type == "total", medication_request_count], 2)
  expect_equal(med[row_type == "total", medication_administration_count], 3)
})

test_that("SNOMED separates Coding roles, preserves resource boundaries and deduplicates totals", {
  fixture <- codeSummaryFixture()
  # Other resource types remain configurable, but are outside the default report.
  fixture$config$code_summary_sources <- c(fixture$config$code_summary_sources, list(
    list(resource = "Observation", coding = "*", reports = "SNOMED", measurement = FALSE),
    list(resource = "Patient", coding = "*", reports = "SNOMED"),
    list(resource = "Encounter", coding = "*", reports = "SNOMED")
  ))
  fixture$extra_sql <- c(
    "UPDATE medicationrequest SET medreq_medicationreference_ref='https://example.org/fhir/Medication/example' WHERE medreq_id='q1';",
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_code,obs_value,obs_unit) VALUES ('rare1','Patient/p1','Encounter/e1','http://loinc.org','r2',100,'g/L');",
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit,obs_method_system,obs_method_code) SELECT 'snomed'||n,'http://snomed.info/sct','123',n,'mg','http://snomed.info/sct','123' FROM generate_series(1,5) n;",
    "INSERT INTO condition (con_id,con_code_system,con_code_code) SELECT 'snomed'||n,'http://snomed.info/sct','123' FROM generate_series(1,5) n;",
    "INSERT INTO observation (obs_id,obs_method_system,obs_method_code) VALUES ('method-rare','http://snomed.info/sct','rare');",
    "INSERT INTO condition (con_id,con_code_system,con_code_code) VALUES ('unknown','urn:unconfigured','123');",
    "INSERT INTO patient (pat_id,pat_code_system,pat_code_code) SELECT 'p'||n,'http://snomed.info/sct','123' FROM generate_series(1,5) n;",
    "INSERT INTO encounter (enc_id,enc_code_system,enc_code_code,enc_main_encounter_calculated_ref) SELECT 'e'||n,'http://snomed.info/sct','123','Encounter/main1' FROM generate_series(1,5) n;"
  )
  summaries <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  obs <- summaries$Observation
  snomed <- obs[system == "http://snomed.info/sct" & row_type == "detail"]
  expect_setequal(snomed$coding_path, c("code/coding", "method/coding"))
  expect_equal(snomed$count, c(5, 5))
  expect_equal(snomed[coding_path == "code/coding", mean], 3)
  expect_true(is.na(snomed[coding_path == "method/coding", mean]))
  expect_equal(obs[system == "http://snomed.info/sct" & row_type == "total", count], 6)
  expect_equal(obs[system == "http://loinc.org" & row_type == "total", count], 8)
  expect_equal(obs[system == "http://snomed.info/sct" & row_type == "other (count < 5)", coding_path], "method/coding")
  expect_equal(summaries$Condition[row_type == "total", count], 5)
  expect_equal(summaries$Patient[row_type == "total", patient_count], 5)
  expect_equal(summaries$Patient[row_type == "total", case_count], 0)
  expect_equal(summaries$Encounter[row_type == "detail", coding_path], "class")
  expect_equal(summaries$Encounter[row_type == "total", count], 5)
  expect_equal(summaries$Encounter[row_type == "total", case_count], 1)
  expect_equal(summaries$Medication[row_type == "total", medication_request_count], 2)
  expect_false(any(c("summary_id", "event_key", "count_key", "report") %in% names(obs)))
})

test_that("code ZIP includes one CSV per resource and system/source documentation", {
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
  contents <- utils::unzip(file, list = TRUE)$Name
  expect_setequal(contents[endsWith(contents, ".csv")], paste0("Codes/", names(summaries), ".csv"))
  expect_true("README.txt" %in% contents)
  utils::unzip(file, exdir = file.path(root, "extracted"))
  header <- data.table::fread(file.path(root, "extracted", "Codes", "Observation.csv"))
  expect_true(all(c("system", "coding_path", "unit") %in% names(header)))
  testthat::local_mocked_bindings(zip = function(...) 1L, .package = "utils")
  expect_error(writeCodeSummaryArchive(summaries, "FailedArchive"), "Could not write Code_Summary archive")
})

test_that("direct medication codes survive unavailable Medication reference sources", {
  fixture <- codeSummaryFixture()
  available_metadata <- fixture$metadata[TABLE_NAME != "medication"]
  fixture$extra_sql <- paste0(
    "INSERT INTO medicationrequest (medreq_id,medreq_direct_system,medreq_direct_code) ",
    "SELECT 'inline'||n,'http://fhir.de/CodeSystem/bfarm/atc','direct' FROM generate_series(1,5) n;"
  )
  expect_warning(summaries <- createCodeSummaryReports(
    available_metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Skipped code summary sources")
  expect_equal(summaries$Medication[row_type == "detail", count], 5)
  expect_equal(summaries$Medication[row_type == "detail", medication_count], 0)
  expect_equal(summaries$Medication[row_type == "detail", medication_request_count], 5)
  expect_true(all(is.na(summaries$Medication$unreferenced_medication_count)))
})
