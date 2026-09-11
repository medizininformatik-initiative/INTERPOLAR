test_that("current usage gate does not intersect historical collection periods", {
  result <- calculateBroadConsentPatient(consentDocumentFixture(), NULL, as.Date("2026-09-08"))
  expect_true(result$included)
  expect_equal(result$periods$start, as.Date("2020-01-01"))
  expect_equal(result$periods$end, as.Date("2025-12-31"))
  expect_true(calculateBroadConsentPatient(consentDocumentFixture(), NULL, as.Date("2050-01-01"))$included)
  expect_false(calculateBroadConsentPatient(consentDocumentFixture(), NULL, as.Date("2050-01-02"))$included)
  expect_false(calculateBroadConsentPatient(consentDocumentFixture(), NULL, as.Date("2019-12-31"))$included)
})

test_that("required permits must belong to the same document", {
  rows <- consentDocumentFixture()
  rows$consent_id[2L] <- "b"
  expect_identical(
    calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))$reason,
    "missing_complete_consent_document"
  )
})

test_that("cross-document retrospective revocation and renewed permits respect chronology", {
  for (permit_code in c("45", "46")) {
    for (deny_code in c("45", "46")) {
      rows <- data.table::rbindlist(list(consentDocumentFixture(), consentProvisionFixture(permit_code)))
      calculate <- function(x) calculateBroadConsentPatient(x, NULL, as.Date("2026-09-08"))
      expect_equal(calculate(rows)$periods$start, as.Date("1900-01-01"))
      rows <- data.table::rbindlist(list(rows, consentProvisionFixture(
        deny_code, "deny",
        consent_id = "b", declared_at = "2021-01-01 12:00:00"
      )))
      result <- calculate(rows)
      expect_equal(result$periods$start, as.Date("2020-01-01"))
      expect_equal(result$periods$end, as.Date("2025-12-31"))
      expect_true("retrospective_permit_revoked" %in% result$changes$action)
      rows <- data.table::rbindlist(list(
        rows,
        consentDocumentFixture("c", "2022-01-01 12:00:00"),
        consentProvisionFixture(permit_code, consent_id = "c", declared_at = "2022-01-01 12:00:00")
      ))
      expect_equal(calculate(rows)$periods$start, as.Date("1900-01-01"))
      expect_equal(calculate(rows[nrow(rows):1L, ])$periods, calculate(rows)$periods)
      # Another deny wins even when it shares the declaration timestamp.
      rows <- data.table::rbindlist(list(rows, consentProvisionFixture(
        deny_code, "deny",
        consent_id = "d", declared_at = "2022-01-01 12:00:00"
      )))
      expect_equal(calculate(rows)$periods$start, as.Date("2020-01-01"))
      expect_equal(calculate(rows[nrow(rows):1L, ])$periods, calculate(rows)$periods)
    }
  }
})

test_that("regular denies cut intervals and global usage deny excludes the patient", {
  rows <- data.table::rbindlist(list(consentDocumentFixture(), consentProvisionFixture(
    "6", "deny", "2022-01-01", "2022-12-31", "b", "2022-01-01 12:00:00"
  )))
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))
  expect_equal(result$periods$start, as.Date(c("2020-01-01", "2023-01-01")))
  expect_equal(result$periods$end, as.Date(c("2021-12-31", "2025-12-31")))
  rows <- data.table::rbindlist(list(rows, consentProvisionFixture("45")))
  expect_equal(
    calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))$periods$start,
    as.Date("1900-01-01")
  )
  rows <- data.table::rbindlist(list(rows, consentProvisionFixture(
    "8", "deny", "2026-01-01", "2050-01-01", "d", "2026-01-01 12:00:00"
  )))
  expect_false(calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))$included)
})

test_that("encounter adjustment changes only start and ignores open encounters", {
  encounters <- data.table::data.table(
    encounter_id = c("earliest", "other", "open", "later"),
    start = as.Date(c("2019-12-20", "2019-12-25", "2019-01-01", "2025-12-20")),
    end = as.Date(c("2020-01-05", "2020-01-01", NA, "2026-01-10"))
  )
  result <- calculateBroadConsentPatient(consentDocumentFixture(), encounters, as.Date("2026-09-08"))
  expect_equal(result$periods$start, as.Date("2019-12-20"))
  expect_equal(result$periods$end, as.Date("2025-12-31"))
  expect_equal(result$changes$related_id, "earliest")
})

test_that("incomplete restrictions cannot leave a patient permitted", {
  rows <- data.table::rbindlist(list(consentDocumentFixture(), consentProvisionFixture(
    "46", "deny",
    end = NA_character_, consent_id = "b"
  )))
  expect_identical(
    calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))$reason,
    "invalid_relevant_provision"
  )
  rows <- consentDocumentFixture()
  rows$declared_at[1L] <- NA
  expect_false(calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))$included)
  rows <- consentDocumentFixture()
  rows$status <- "inactive"
  expect_identical(calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-08"))$reason, "no_active_consent")
})

test_that("interval normalization retains gaps and merges adjacent days", {
  rows <- data.table::data.table(
    start = as.Date(c("2020-01-10", "2020-01-01", "2020-01-03", "2020-01-20")),
    end = as.Date(c("2020-01-15", "2020-01-09", "2020-01-05", "2020-01-25"))
  )
  result <- mergeBroadConsentPeriods(rows)
  expect_equal(result$start, as.Date(c("2020-01-01", "2020-01-20")))
  expect_equal(result$end, as.Date(c("2020-01-15", "2020-01-25")))
})
