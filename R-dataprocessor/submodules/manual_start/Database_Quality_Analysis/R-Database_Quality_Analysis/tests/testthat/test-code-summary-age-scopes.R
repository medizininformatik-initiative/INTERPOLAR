test_that("all six code scopes share classification and preserve counts, ages and measurements", {
  fixture <- codeSummaryAgeFixture()
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
  expect_named(variants, c("all_age_ge18", "all_age_lt18", "filtered_age_ge18", "filtered_age_lt18"))
  for (name in names(variants)) {
    local <- attr(variants[[name]], "local_reports", exact = TRUE)
    adults <- endsWith(name, "ge18")
    detail <- local$Observation[row_type == "detail" & code == "age-check"]
    expect_equal(detail$count, if (adults) 1 else 2)
    expect_equal(detail$case_count, if (adults) 1 else 2)
    expect_equal(detail$patient_count, 1)
    expect_equal(detail$no_case_count, 0)
    expect_equal(detail$mean, if (adults) 2 else 2.5)
    expect_equal(detail$median, if (adults) 2 else 2.5)
    expect_equal(variants[[name]]$Observation, local$Observation)
    expect_true(all(local$Medication$unreferenced_medication_count == 0))
    linked <- local$Medication[row_type == "detail" & code == "B01"]
    expect_equal(linked$medication_count, 1)
    expect_equal(linked$medication_request_count, if (adults) 1 else 2)
    expect_equal(linked$medication_administration_count, if (adults) 1 else 3)
  }
  legacy <- fixture
  legacy$config$code_summary_exports$variants <- c("all", "filtered")
  expected <- createCodeSummaryReports(legacy$metadata, legacy$config,
    table_description = legacy$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(legacy, query)
  )
  for (resource in names(expected)) {
    expect_equal(reports[[resource]], expected[[resource]])
    expect_equal(attr(reports, "filtered_reports")[[resource]], attr(expected, "filtered_reports")[[resource]])
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
  for (selection in list(fixture$config$code_summary_exports$variants, c("all_age_lt18", "filtered_age_ge18"))) {
    fixture$config$code_summary_exports$variants <- selection
    reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
      table_description = fixture$description,
      query_fun = function(query, lock_id) {
        if (!"all" %in% selection) expect_false(grepl("THEN 'all' END", query, fixed = TRUE))
        if (!"filtered" %in% selection) expect_false(grepl("THEN 'filtered' END", query, fixed = TRUE))
        runCodeSummaryFixtureQuery(fixture, query)
      }
    )
    suffixes <- c(
      all = "", all_age_ge18 = "_AGE_GE18", all_age_lt18 = "_AGE_LT18", filtered = "_INTERPOLAR",
      filtered_age_ge18 = "_INTERPOLAR_AGE_GE18", filtered_age_lt18 = "_INTERPOLAR_AGE_LT18"
    )
    for (target in c("global", "local")) {
      archive <- writeCodeSummaryArchive(reports, "DQA", target = target)
      members <- utils::unzip(archive, list = TRUE)$Name
      expected <- unlist(lapply(suffixes[selection], function(suffix) paste0("Codes/", names(reports), suffix, ".csv")))
      expect_setequal(members[endsWith(members, ".csv")], unname(expected))
    }
  }
  fixture$config$code_summary_exports$variants <- "all_age_ge18"
  expect_warning(reports <- createCodeSummaryReports(fixture$metadata[COLUMN_NAME != "enc_age_at_admission"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) stop("No unavailable scope should be queried")
  ), "Age-specific code exports skipped")
  for (target in c("global", "local")) {
    archive <- writeCodeSummaryArchive(reports, "DQA", target = target)
    expect_equal(utils::unzip(archive, list = TRUE)$Name, "README.txt")
  }
})

test_that("missing age and disabled IP metadata skip only unavailable variants", {
  fixture <- codeSummaryAgeFixture()
  expect_warning(reports <- createCodeSummaryReports(fixture$metadata[COLUMN_NAME != "enc_age_at_admission"], fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Age-specific code exports skipped")
  expect_equal(attr(reports, "export_variants"), c("all", "filtered"))
  expect_length(attr(reports, "variant_reports"), 0L)
  fixture$config$filtered_scope_sheet_names <- character()
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_false(grepl('"pids_per_ward"', query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(attr(reports, "export_variants"), c("all", "all_age_ge18", "all_age_lt18"))
  expect_null(attr(reports, "filtered_reports"))
  fixture$config$code_summary_exports$variants <- "all"
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      expect_false(grepl('"encounter"', query, fixed = TRUE))
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(attr(reports, "export_variants"), "all")
})

test_that("export settings accept legacy TOMLs and reject ambiguous selections", {
  expect_equal(parseCodeSummaryExports()$variants, c("all", "filtered"))
  config <- getConfig(envir = new.env(parent = emptyenv()), command_arguments = character())
  expect_equal(config$code_summary_exports$variants, "filtered_age_ge18")
  for (variants in list(character(), c("all", "all"), "adults", NA_character_, TRUE)) {
    expect_error(parseCodeSummaryExports(list(variants = variants)), "unique CSV variants")
  }
  expect_error(parseCodeSummaryExports(list(age_column = "")), "non-empty database column")
  expect_error(parseCodeSummaryExports(list(unrecognized = TRUE)), "Unknown code summary")
  expect_error(parseCodeSummaryExports(list(fallback_to_birthdate = "true")), "must be a TOML boolean")
})

test_that("absent age columns use calendar age at main-case admission with one Patient scan", {
  fixture <- codeSummaryAgeFixture()
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
    expect_equal(detail$count, if (endsWith(name, "ge18")) 1 else 2)
    expect_equal(detail$mean, if (endsWith(name, "ge18")) 2 else 2.5)
  }
  expected <- variants$filtered_age_ge18
  fixture$config$code_summary_exports$variants <- "filtered_age_ge18"
  selected <- createCodeSummaryReports(metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      prefix <- strsplit(query, "\nSELECT c.summary_id", fixed = TRUE)[[1]][[1]]
      stage <- runCodeSummaryFixtureQuery(fixture, paste0(prefix, "\nSELECT count(*) AS n FROM source_1"))
      expect_equal(stage$n, 6)
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  actual <- attr(selected, "variant_reports")$filtered_age_ge18
  expect_equal(lapply(actual, identity), lapply(expected, identity))
  expect_equal(lapply(attr(actual, "local_reports"), identity), lapply(attr(expected, "local_reports"), identity))
  fixture$config$code_summary_exports$fallback_to_birthdate <- FALSE
  expect_warning(createCodeSummaryReports(metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  ), "Age-specific code exports skipped")
})

test_that("available but unknown main-case ages produce empty age reports without changing other scopes", {
  fixture <- codeSummaryAgeFixture()
  fixture$extra_sql <- c(fixture$extra_sql, "UPDATE encounter SET enc_age_at_admission=NULL;")
  reports <- createCodeSummaryReports(fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
  )
  expect_equal(reports$Observation[row_type == "total", count], 22)
  expect_equal(attr(reports, "filtered_reports")$Observation[row_type == "total", count], 16)
  variants <- attr(reports, "variant_reports")
  expect_length(variants, 4L)
  for (variant in variants) {
    expect_true(all(vapply(variant, nrow, integer(1)) == 0L))
    expect_true(all(vapply(attr(variant, "local_reports"), nrow, integer(1)) == 0L))
    expect_true("count" %in% names(variant$Observation))
  }
})
