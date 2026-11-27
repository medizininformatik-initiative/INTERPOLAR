test_that("both adult code scopes share classification and preserve counts, ages and measurements", {
  fixture <- codeSummaryAgeFixture()
  fixture$config$code_summary_exports$variants <- NULL
  queries <- character()
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      queries <<- c(queries, query)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_length(queries, 1L)
  expect_equal(lengths(regmatches(queries, gregexpr('FROM "pg_temp"."encounter"', queries, fixed = TRUE))), 1L)
  expect_equal(lengths(regmatches(queries, gregexpr("FROM raw_events e", queries, fixed = TRUE))), 1L)
  expect_equal(lengths(regmatches(queries, gregexpr('FROM "pg_temp"."observation"', queries, fixed = TRUE))), 1L)
  variants <- attr(reports, "variant_reports", exact = TRUE)
  expect_named(variants, c("all_cases", "interpolar_cases"))
  for (name in names(variants)) {
    local <- attr(variants[[name]], "local_reports", exact = TRUE)
    detail <- local$Observation[row_type == "detail" & code == "age-check"]
    expect_equal(detail$count, 1)
    expect_equal(detail$case_count, 1)
    expect_equal(detail$patient_count, 1)
    expect_equal(detail$no_case_count, 0)
    expect_equal(detail$mean, 2)
    expect_equal(detail$median, 2)
    expect_equal(variants[[name]]$Observation, local$Observation)
    expect_true(all(local$Medication$unreferenced_medication_count == 0))
    linked <- local$Medication[row_type == "detail" & code == "B01"]
    expect_equal(linked$medication_count, 1)
    expect_equal(linked$medication_request_count, 1)
    expect_equal(linked$medication_administration_count, 1)
  }
  fixture$config$code_summary_query_batching <- "resource"
  queries <- character()
  batched <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      queries <<- c(queries, query)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_length(queries, 4L)
  expect_equal(batched, reports)
})

test_that("CSV variants are selected before aggregation and written to the existing ZIP", {
  fixture <- codeSummaryAgeFixture()
  fixture$config$code_summary_exports$variants <- NULL
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO observation (obs_id,obs_encounter_calculated_ref,obs_code_system,obs_code_version,obs_code_code,obs_unit,obs_unit_system,obs_low,obs_value) VALUES ('rollup1','Encounter/e2','http://loinc.org','v1','rollup','mg/dL','http://unitsofmeasure.org','1',10),('rollup1','Encounter/e2','http://loinc.org','v2','rollup','mg/dL','http://unitsofmeasure.org','2',10),('rollup2','Encounter/e2','http://loinc.org','v2','rollup','mg/dL','http://unitsofmeasure.org','2',30),('rollup1','Encounter/e2','http://loinc.org','v1','rollup',NULL,NULL,NULL,10),('rollup1','Encounter/e2','http://loinc.org','v1','rollup','mg/dL','urn:other-unit',NULL,10);",
    "INSERT INTO observation (obs_id,obs_encounter_calculated_ref,obs_code_system,obs_code_version,obs_code_code,obs_unit,obs_unit_system,obs_low,obs_value) VALUES ('rollup1','Encounter/e2','http://snomed.info/sct','v1','rollup','mg/dL','http://unitsofmeasure.org','1',10),('rollup1','Encounter/e2','http://snomed.info/sct','v2','rollup','mg/dL','http://unitsofmeasure.org','2',10);",
    "UPDATE observation SET obs_patient_ref='Patient/p1' WHERE obs_code_code='rollup';",
    "INSERT INTO condition (con_id,con_encounter_calculated_ref,con_code_system,con_code_version,con_code_code) VALUES ('dx1','Encounter/e2','http://fhir.de/CodeSystem/bfarm/icd-10-gm','v1','I10'),('dx1','Encounter/e2','http://fhir.de/CodeSystem/bfarm/icd-10-gm','v2','I10'),('dx2','Encounter/e2','http://fhir.de/CodeSystem/bfarm/icd-10-gm','v2','I10');",
    "INSERT INTO medication (med_id,med_code_system,med_code_version,med_code_code) VALUES ('rollup-med','http://fhir.de/CodeSystem/bfarm/atc','v1','rollup-atc'),('rollup-med','http://fhir.de/CodeSystem/bfarm/atc','v2','rollup-atc');",
    "INSERT INTO medicationrequest (medreq_id,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_version,medreq_direct_code) VALUES ('rollup-request','Encounter/e2','Medication/rollup-med','http://fhir.de/CodeSystem/bfarm/atc','v1','rollup-atc'),('rollup-request','Encounter/e2','Medication/rollup-med','http://fhir.de/CodeSystem/bfarm/atc','v3','rollup-atc');"
  )
  root <- tempfile("code-age-scopes-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  old_dirs <- if (exists("MODULE_DIRS", inherits = TRUE)) get("MODULE_DIRS", inherits = TRUE) else NULL
  assign("MODULE_DIRS", list(global_dir = file.path(root, "global"), local_dir = file.path(root, "local")), envir = .GlobalEnv)
  on.exit(
    {
      if (is.null(old_dirs)) rm("MODULE_DIRS", envir = .GlobalEnv) else assign("MODULE_DIRS", old_dirs, envir = .GlobalEnv)
    },
    add = TRUE
  )
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  for (target in c("global", "local")) {
    archive <- writeCodeSummaryArchive(reports, "DQA", target = target)
    members <- utils::unzip(archive, list = TRUE)$Name
    expected <- unlist(lapply(c("all", "interpolar"), function(scope) {
      paste0("Codes/", names(reports), "_", scope, ".csv")
    }))
    expected_no_version <- unlist(lapply(c("all", "interpolar"), function(scope) {
      paste0("Codes_no_version/", names(reports), "_", scope, "_no_version.csv")
    }))
    expect_setequal(members[endsWith(members, ".csv")], c(expected, expected_no_version))
    output <- file.path(root, target, "unpacked")
    utils::unzip(archive, exdir = output)
    for (scope in c("all", "interpolar")) {
      readCompact <- function(resource) {
        data.table::fread(file.path(output, "Codes_no_version", paste0(resource, "_", scope, "_no_version.csv")))
      }
      observation <- readCompact("Observation")
      detailed <- data.table::fread(file.path(output, "Codes", paste0("Observation_", scope, ".csv")))
      count_columns <- c("system", "count", "patient_count", "case_count", "no_case_count")
      expect_equal(observation[row_type == "total", ..count_columns], detailed[row_type == "total", ..count_columns])
      expect_named(observation, setdiff(names(reports$Observation), c("version", codeSummaryReferenceRangeColumns())))
      same_unit <- observation[code == "rollup" & unit_system == "http://unitsofmeasure.org"]
      expect_setequal(same_unit$system, c("http://loinc.org", "http://snomed.info/sct"))
      expect_equal(same_unit[system == "http://snomed.info/sct", count], if (target == "global") "<5" else 1L)
      rollup <- same_unit[system == "http://loinc.org"]
      expect_equal(rollup$count, if (target == "global") "<5" else 2L)
      expect_equal(rollup$patient_count, if (target == "global") "<5" else 1L)
      expect_equal(rollup$case_count, if (target == "global") "<5" else 1L)
      expect_equal(nrow(observation[code == "rollup" & system == "http://loinc.org"]), 3L)
      if (target == "global") {
        expect_true(all(is.na(rollup[, .(median, q1, q3, mean, sd, minimum, maximum)])))
      } else {
        expect_equal(rollup$median, 20)
        expect_equal(rollup$q1, 15)
        expect_equal(rollup$q3, 25)
        expect_equal(rollup$mean, 20)
        expect_equal(rollup$sd, sqrt(200), tolerance = 1e-12)
        expect_equal(rollup$minimum, 10)
        expect_equal(rollup$maximum, 30)
      }
      condition <- readCompact("Condition")
      expect_false("version" %in% names(condition))
      expect_equal(
        condition[code == "I10" & row_type == "detail", count],
        if (target == "global") "<5" else 2L
      )
      medication <- readCompact("Medication")
      expect_equal(
        medication[
          code == "rollup-atc" & coding_path == "MedicationRequest/medicationCodeableConcept/coding",
          .(count, medication_count, medication_request_count)
        ],
        if (target == "global") data.table::data.table(count = "<5", medication_count = "<5", medication_request_count = "<5")
        else data.table::data.table(count = 1L, medication_count = 1L, medication_request_count = 1L)
      )
    }
  }
  chunk_fixture <- fixture
  chunk_fixture$config$code_summary_processing <- list(enabled = TRUE, target_rows_per_chunk = 6, max_codes_per_chunk = 2L)
  chunked <- createCodeSummaryReports(chunk_fixture$metadata, chunk_fixture$config,
    table_description = chunk_fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(chunk_fixture, query)
  )
  for (scope in c("all_cases", "interpolar_cases")) {
    base_scope <- attr(reports, "variant_reports")[[scope]]
    chunk_scope <- attr(chunked, "variant_reports")[[scope]]
    expect_equal(attr(chunk_scope, "no_version_reports"), attr(base_scope, "no_version_reports"))
    expect_equal(
      attr(attr(chunk_scope, "local_reports"), "no_version_reports"),
      attr(attr(base_scope, "local_reports"), "no_version_reports")
    )
  }
  expect_warning(reports <- createCodeSummaryReports(fixture$metadata[COLUMN_NAME != "enc_age_at_admission"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) stop("No unavailable scope should be queried")
  ), "Age-specific code exports skipped")
  for (target in c("global", "local")) {
    archive <- writeCodeSummaryArchive(reports, "DQA", target = target)
    expect_equal(utils::unzip(archive, list = TRUE)$Name, "README.txt")
  }
})

test_that("the DQA start omits unavailable INTERPOLAR cases and rejects configurable variants", {
  fixture <- codeSummaryAgeFixture()
  config <- fixture$config
  config$code_summary_exports$variants <- NULL
  config$filtered_scope_sheet_names <- character()
  reports <- createCodeSummaryReports(fixture$metadata, config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  expect_equal(attr(reports, "export_variants"), c("all_cases", "interpolar_cases"))
  expect_warning(reports <- createCodeSummaryReports(fixture$metadata[TABLE_NAME != "pids_per_ward"], config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "INTERPOLAR code report skipped")
  expect_equal(attr(reports, "export_variants"), "all_cases")
  for (variants in list("all_age_lt18", "filtered_age_lt18", "all", "filtered", "all_cases")) {
    expect_error(parseCodeSummaryExports(list(variants = variants)), "Unknown code summary")
  }
  expect_error(parseCodeSummaryExports(list(age_column = "")), "non-empty database column")
  expect_error(parseCodeSummaryExports(list(fallback_to_birthdate = "true")), "must be a TOML boolean")
})

test_that("absent age columns use calendar age at main-case admission with one Patient scan", {
  fixture <- codeSummaryAgeFixture()
  fixture$config$code_summary_exports$variants <- NULL
  additions <- data.table::data.table(
    RESOURCE = c("Encounter", "Patient"), FHIR_EXPRESSION = c("period/start", "birthDate"),
    COLUMN_NAME = c("enc_period_start", "pat_birthdate")
  )
  fixture$description <- data.table::rbindlist(list(fixture$description, additions))
  fixture$metadata <- data.table::rbindlist(list(fixture$metadata, additions[, .(
    TABLE_FAMILY = "FHIR", TABLE_NAME = tolower(RESOURCE), VIEW_SCHEMA = "pg_temp", VIEW_NAME = tolower(RESOURCE),
    COLUMN_NAME, DATA_TYPE = c("timestamp without time zone", "date"), ORDINAL_POSITION = 30L
  )]))
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO patient (pat_id,pat_birthdate) VALUES ('p1','2008-06-15'),('p1','2008-06-15'),('newborn','2026-06-15'),('future','2027-01-01');",
    "UPDATE encounter SET enc_patient_ref='Patient/p1', enc_period_start='2026-06-14' WHERE enc_id='e1';",
    "UPDATE encounter SET enc_patient_ref='https://example.org/fhir/Patient/p1', enc_period_start='2026-06-15' WHERE enc_id='e2';",
    "UPDATE encounter SET enc_patient_ref='Patient/newborn', enc_period_start='2026-06-15' WHERE enc_id='e4';",
    "UPDATE encounter SET enc_patient_ref='Patient/future', enc_period_start='2026-06-15' WHERE enc_id='e5';"
  )
  metadata <- fixture$metadata[COLUMN_NAME != "enc_age_at_admission"]
  reports <- createCodeSummaryReports(metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_equal(sum(gregexpr('FROM "pg_temp"."patient"', query, fixed = TRUE)[[1]] > 0L), 1L)
      expect_equal(sum(gregexpr('FROM "pg_temp"."encounter"', query, fixed = TRUE)[[1]] > 0L), 1L)
      expect_false(grepl('"enc_age_at_admission"', query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  variants <- attr(reports, "variant_reports")
  for (name in names(variants)) {
    local <- attr(variants[[name]], "local_reports")$Observation
    detail <- local[row_type == "detail" & code == "age-check"]
    expect_equal(detail$count, 1)
    expect_equal(detail$mean, 2)
  }
  expected <- variants$interpolar_cases
  selected <- buildCodeSummaryReports(metadata, fixture$config,
    export_variants = "interpolar_cases",
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      prefix <- strsplit(query, "\nSELECT c.", fixed = TRUE)[[1]][[1]]
      stage <- runCodeSummaryFixtureQuery(fixture, paste0(prefix, "\nSELECT count(*) AS n FROM source_1"))
      expect_equal(stage$n, 6)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  actual <- attr(selected, "variant_reports")$interpolar_cases
  expect_equal(lapply(actual, identity), lapply(expected, identity))
  expect_equal(lapply(attr(actual, "local_reports"), identity), lapply(attr(expected, "local_reports"), identity))
  fixture$config$code_summary_exports$fallback_to_birthdate <- FALSE
  expect_warning(createCodeSummaryReports(metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Age-specific code exports skipped")
})

test_that("available but unknown main-case ages produce empty age reports for both selections", {
  fixture <- codeSummaryAgeFixture()
  fixture$config$code_summary_exports$variants <- NULL
  fixture$extra_sql <- c(fixture$extra_sql, "UPDATE encounter SET enc_age_at_admission=NULL;")
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  variants <- attr(reports, "variant_reports")
  expect_length(variants, 2L)
  for (variant in variants) {
    expect_true(all(vapply(variant, nrow, integer(1)) == 0L))
    expect_true(all(vapply(attr(variant, "local_reports"), nrow, integer(1)) == 0L))
    expect_true("count" %in% names(variant$Observation))
  }
})
