test_that("review preserves source evidence and records final intervals", {
  rows <- data.table::rbindlist(list(
    consentDocumentFixture(), consentProvisionFixture("45"),
    consentProvisionFixture("46", "deny", consent_id = "b", declared_at = "2021-01-01 12:00:00")
  ))
  original <- data.table::copy(rows)
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))
  review <- newBroadConsentReview(tempfile(), as.Date("2026-09-08"), "synthetic", TRUE)
  on.exit(unlink(review$directory, recursive = TRUE))
  writeBroadConsentPatientReview(review, "p1", rows, result)
  finishBroadConsentReview(review, data.table::data.table(reason = "included", patients = 1L))
  expect_true(file.exists(file.path(review$directory, "COMPLETE")))
  expect_equal(rows, original)
  expect_equal(calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08")), result)
  intervals <- data.table::fread(file.path(review$directory, "intervals.csv"))
  expect_equal(as.Date(intervals$start), result$periods$start)
  expect_equal(as.Date(intervals$end), result$periods$end)
  changes <- data.table::fread(file.path(review$directory, "changes.csv"))
  revoked <- changes[changes$action == "retrospective_permit_revoked", ]
  expect_equal(revoked$consent_id, "a")
  expect_equal(revoked$related_id, "b")
})

test_that("summary-only review does not write patient details", {
  review <- newBroadConsentReview(tempfile(), as.Date("2026-09-08"), "synthetic", FALSE)
  on.exit(unlink(review$directory, recursive = TRUE))
  rows <- consentDocumentFixture()
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))
  writeBroadConsentPatientReview(review, "p1", rows, result)
  expect_false(file.exists(file.path(review$directory, "patients.csv")))
  expect_false(file.exists(file.path(review$directory, "COMPLETE")))
  expect_error(newBroadConsentReview(review$directory, as.Date("2026-09-08"), "synthetic"), "must be new")
})

test_that("batch review preserves patient evidence and writes each file once per block", {
  rows <- consentDocumentFixture()
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))
  reviews <- lapply(seq_len(3L), function(i) {
    buildBroadConsentPatientReview(paste0("p", i), rows, result)
  })
  batch <- newBroadConsentReview(tempfile(), as.Date("2026-09-08"), "synthetic", TRUE)
  single <- newBroadConsentReview(tempfile(), as.Date("2026-09-08"), "synthetic", TRUE)
  on.exit(unlink(c(batch$directory, single$directory), recursive = TRUE))
  for (i in seq_len(3L)) writeBroadConsentPatientReview(single, paste0("p", i), rows, result)
  calls <- character()
  original_append <- appendBroadConsentReviewTable
  testthat::local_mocked_bindings(appendBroadConsentReviewTable = function(review, name, rows) {
    calls <<- c(calls, name)
    original_append(review, name, rows)
  })
  writeBroadConsentReviewBatch(batch, reviews)
  expect_equal(calls, c("patients", "provisions", "changes", "intervals"))
  for (name in calls) {
    expect_identical(
      readLines(file.path(batch$directory, paste0(name, ".csv"))),
      readLines(file.path(single$directory, paste0(name, ".csv")))
    )
  }
})
