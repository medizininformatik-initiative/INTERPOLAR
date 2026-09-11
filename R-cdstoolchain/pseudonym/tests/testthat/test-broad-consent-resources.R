test_that("resource date metadata distinguishes empty, missing and choice mappings", {
  rules <- data.table::data.table(
    RESOURCE = "Observation",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_effectivedatetime"),
    FHIR_EXPRESSION = c("id", "subject/reference", "effectiveDateTime")
  )
  spec <- getBroadConsentResourceSpec(rules, rules$COLUMN_NAME)
  expect_equal(spec$point, "obs_effectivedatetime")
  expect_equal(spec$patient, "obs_patient_ref")
  rules$RESOURCE <- "Patient"
  expect_identical(getBroadConsentResourceSpec(rules, rules$COLUMN_NAME)$date_path, "")
  rules$RESOURCE <- "Location"
  expect_true(is.na(getBroadConsentResourceSpec(rules, rules$COLUMN_NAME)$date_path))
  expect_equal(buildBroadConsentDatePredicate(
    DBI::ANSI(),
    getBroadConsentResourceSpec(rules, rules$COLUMN_NAME), "intervals"
  )$covered, "FALSE")
})

test_that("resource periods and patient ownership are checked across flattened versions", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  intervals <- basename(tempfile("bc_intervals_"))
  rows <- basename(tempfile("bc_resources_"))
  on.exit(DBI::dbRemoveTable(connection, intervals), add = TRUE)
  on.exit(DBI::dbRemoveTable(connection, rows), add = TRUE)
  DBI::dbWriteTable(connection, intervals, data.frame(
    patient_id = "p1",
    start = as.Date("2026-03-01"), end = as.Date("2026-03-15")
  ), temporary = TRUE)
  data <- data.frame(
    encounter_id = 1:7, enc_id = c("main", "ward", "bad", "mixed", "mixed", "old", "old"),
    enc_meta_versionid = c("1", "1", "1", "1", "1", "1", "2"),
    enc_patient_ref = c("Patient/p1", "p1", "p1", "p1", "p2", "p1", "p1"),
    enc_period_start = as.POSIXct(rep("2026-03-05", 7), tz = "UTC"),
    enc_period_end = as.POSIXct(c("2026-03-20", "2026-03-10", NA, "2026-03-10", "2026-03-10", "2026-03-20", "2026-03-10"), tz = "UTC")
  )
  DBI::dbWriteTable(connection, rows, data, temporary = TRUE)
  spec <- list(
    resource = "Encounter", id = "enc_id", version = "enc_meta_versionid", patient = "enc_patient_ref",
    date_path = "period", point = NA_character_, start = "enc_period_start", end = "enc_period_end"
  )
  query <- buildBroadConsentFhirDecisionQuery(
    connection, snapshotQualifiedName(connection, rows),
    "encounter_id", spec, snapshotQualifiedName(connection, intervals)
  )
  decisions <- DBI::dbGetQuery(connection, query)
  expect_setequal(decisions$row_id[decisions$reason == "included"], c("2", "7"))
  expect_true(all(decisions$reason[decisions$resource_id == "mixed"] == "unresolved_patient"))
  expect_equal(DBI::dbReadTable(connection, rows), data)
})
