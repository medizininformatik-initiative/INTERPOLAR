test_that("restricted sources discard measurements before materialization, casting and range ranking", {
  fixture <- codeSummaryAgeFixture()
  fixture$config$code_summary_exports$variants <- "filtered_age_ge18"
  fixture$metadata[COLUMN_NAME == "obs_value", DATA_TYPE := "text"]
  fixture$config$code_summary_sources[[1]]$measurement <- TRUE
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO observation (obs_id,obs_encounter_calculated_ref,obs_code_system,obs_code_code,obs_value) VALUES ('excluded-value','Encounter/e1','http://loinc.org','excluded','not numeric');"
  )
  stages <- NULL
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      # Query the actual SQL stages, rather than just checking for a WHERE string.
      prefix <- strsplit(query, "\nSELECT c.summary_id", fixed = TRUE)[[1]][[1]]
      stage_query <- paste0(
        prefix,
        "\nSELECT 'source' AS stage,count(*) AS n FROM source_1 UNION ALL ",
        "SELECT 'raw',count(*) FROM raw_codings WHERE kind='Observation' UNION ALL ",
        "SELECT 'normalized',count(*) FROM codings WHERE kind='Observation'"
      )
      stages <<- runCodeSummaryFixtureQuery(fixture, stage_query)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(stages[stage == "source", n], 6)
  expect_equal(stages[stage == "raw", n], 3)
  expect_equal(stages[stage == "normalized", n], 3)
  local <- attr(attr(reports, "variant_reports")$filtered_age_ge18, "local_reports")$Observation
  expect_setequal(local[row_type == "detail", code], c("common", "age-check"))
  expect_equal(local[row_type == "total", count], 3)
})

test_that("restricted reports retain global medication identities and diagnostics across case rows", {
  fixture <- codeSummaryAgeFixture()
  fixture$metadata <- data.table::rbindlist(list(fixture$metadata, data.table::data.table(
    TABLE_FAMILY = "FHIR", TABLE_NAME = "medication", VIEW_SCHEMA = "pg_temp", VIEW_NAME = "medication",
    COLUMN_NAME = "med_case", DATA_TYPE = "text", ORDINAL_POSITION = 20L
  )))
  for (index in which(vapply(fixture$config$code_summary_sources, function(source) source$resource == "Medication", logical(1)))) {
    fixture$config$code_summary_sources[[index]]$columns <- list(case_id = "med_case")
  }
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO medication (med_id,med_code_system,med_code_code,med_case) VALUES ('cross-med','http://fhir.de/CodeSystem/bfarm/atc','cross-code',NULL),('outside-ref','http://fhir.de/CodeSystem/bfarm/atc','outside-reference','Encounter/e2');",
    "INSERT INTO medicationrequest (medreq_id,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_code) VALUES ('cross-usage','Encounter/e2',NULL,'http://fhir.de/CodeSystem/bfarm/atc','cross-code'),('cross-usage','Encounter/e1','Medication/cross-med',NULL,NULL),('global-coded','Encounter/e2',NULL,NULL,NULL),('global-coded','Encounter/e1',NULL,'http://fhir.de/CodeSystem/bfarm/atc','outside-code'),('resolved-no-code','Encounter/e2','Medication/no-code',NULL,NULL),(NULL,'Encounter/e1','Medication/outside-ref',NULL,NULL);"
  )
  run <- function() createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  reference <- run()
  for (selection in list("filtered_age_ge18", "filtered", c("all_age_lt18", "filtered_age_ge18"))) {
    fixture$config$code_summary_exports$variants <- selection
    for (batching in c("all", "resource")) {
      fixture$config$code_summary_query_batching <- batching
      actual <- run()
      for (variant in selection) {
        expected <- if (variant == "filtered") attr(reference, "filtered_reports") else attr(reference, "variant_reports")[[variant]]
        selected <- if (variant == "filtered") attr(actual, "filtered_reports") else attr(actual, "variant_reports")[[variant]]
        expect_equal(lapply(selected, identity), lapply(expected, identity))
        expect_equal(lapply(attr(selected, "local_reports"), identity), lapply(attr(expected, "local_reports"), identity))
      }
    }
  }
  adult <- attr(attr(reference, "variant_reports")$filtered_age_ge18, "local_reports")$Medication
  expect_equal(adult[row_type == "detail" & code == "cross-code", count], 2)
  expect_equal(adult[row_type == "detail" & code == "outside-reference", unreferenced_medication_count], 0)
})

test_that("restricted exports respect different coding and link case fields and absent Medication sources", {
  fixture <- codeSummaryAgeFixture()
  fixture$metadata <- data.table::rbindlist(list(fixture$metadata, data.table::data.table(
    TABLE_FAMILY = "FHIR", TABLE_NAME = "medicationrequest", VIEW_SCHEMA = "pg_temp", VIEW_NAME = "medicationrequest",
    COLUMN_NAME = "direct_case", DATA_TYPE = "text", ORDINAL_POSITION = 20L
  )))
  index <- which(vapply(fixture$config$code_summary_sources, function(source) source$resource == "MedicationRequest", logical(1)))
  fixture$config$code_summary_sources[[index]]$columns <- list(case_id = "direct_case")
  fixture$extra_sql <- c(
    fixture$extra_sql,
    "INSERT INTO medicationrequest (medreq_id,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_code,direct_case) VALUES ('different-cases','Encounter/e1','Medication/example','http://fhir.de/CodeSystem/bfarm/atc','B01','Encounter/e2');"
  )
  for (include_medication in c(TRUE, FALSE)) {
    if (!include_medication) fixture$config$code_summary_sources <- Filter(function(source) source$resource != "Medication", fixture$config$code_summary_sources)
    fixture$config$code_summary_exports$variants <- c("all", "filtered_age_ge18")
    run <- function() createCodeSummaryReports(fixture$metadata, fixture$config,
      table_description = fixture$description,
      query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
    )
    expected <- attr(run(), "variant_reports")$filtered_age_ge18
    fixture$config$code_summary_exports$variants <- "filtered_age_ge18"
    actual <- attr(run(), "variant_reports")$filtered_age_ge18
    expect_equal(lapply(actual, identity), lapply(expected, identity))
    expect_equal(lapply(attr(actual, "local_reports"), identity), lapply(attr(expected, "local_reports"), identity))
    expect_true(nrow(attr(actual, "local_reports")$Medication[code == "B01" & row_type == "detail"]) > 0L)
  }
})
