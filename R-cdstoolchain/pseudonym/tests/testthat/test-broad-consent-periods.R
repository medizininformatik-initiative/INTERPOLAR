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
      expect_false(result$included)
      expect_equal(nrow(result$periods), 0L)
      expect_true("retrospective_history_reset" %in% result$changes$action)
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
      expect_false(calculate(rows)$included)
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
    as.Date(c("1900-01-01", "2023-01-01"))
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

test_that("encounters extend permits without moving later collection deny boundaries", {
  rows <- consentDocumentFixture("a", "2026-03-10 12:00:00")
  rows$start[rows$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2026-03-10")
  rows$end[rows$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2026-03-20")
  rows <- data.table::rbindlist(list(rows, consentProvisionFixture(
    "6", "deny", "2026-03-10", "2026-03-15", "b", "2026-03-11 12:00:00"
  )))
  encounters <- data.table::data.table(
    encounter_id = "stay", start = as.Date("2026-03-01"), end = as.Date("2026-03-20")
  )
  result <- calculateBroadConsentPatient(rows, encounters, as.Date("2026-09-15"))
  expect_true(result$included)
  expect_equal(result$periods, data.table::data.table(
    start = as.Date(c("2026-03-01", "2026-03-16")),
    end = as.Date(c("2026-03-09", "2026-03-20"))
  ))
  expect_equal(result$changes$action, "encounter_start_applied")
  expect_equal(result$changes$consent_id, "a")
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

test_that("future declarations cannot grant rights or leave other grants effective", {
  evaluation_date <- as.Date("2026-09-11")
  future <- "2026-09-12 00:00:00"
  result <- calculateBroadConsentPatient(consentDocumentFixture(declared_at = future), NULL, evaluation_date)
  expect_false(result$included)
  expect_identical(result$reason, "future_consent_declaration")
  expect_equal(nrow(result$periods), 0L)
  for (type in c("permit", "deny")) {
    for (code in c("6", "8", "45", "46")) {
      rows <- data.table::rbindlist(list(consentDocumentFixture(), consentProvisionFixture(
        code, type,
        consent_id = "future", declared_at = future
      )))
      result <- calculateBroadConsentPatient(rows, NULL, evaluation_date)
      expect_identical(result$reason, "future_consent_declaration")
      expect_false(result$included)
      expect_equal(nrow(result$periods), 0L)
      expect_equal(nrow(result$changes), 0L)
    }
  }
  # Evaluation uses the project calendar, including declarations near midnight.
  for (declared_at in c("2026-09-10 23:59:59", "2026-09-11 21:59:59")) {
    expect_true(calculateBroadConsentPatient(
      consentDocumentFixture(declared_at = declared_at), NULL, evaluation_date
    )$included)
  }
  next_berlin_day <- consentDocumentFixture()
  next_berlin_day$declared_at <- as.POSIXct("2026-09-12 00:30:00", tz = "Europe/Berlin")
  expect_false(calculateBroadConsentPatient(next_berlin_day, NULL, evaluation_date)$included)
  ignored <- consentProvisionFixture("6", "deny", consent_id = "inactive", declared_at = future, status = "inactive")
  expect_true(calculateBroadConsentPatient(
    data.table::rbindlist(list(consentDocumentFixture(), ignored)), NULL, evaluation_date
  )$included)
  ignored$status <- "active"
  ignored$code <- "unrelated-policy"
  expect_true(calculateBroadConsentPatient(
    data.table::rbindlist(list(consentDocumentFixture(), ignored)), NULL, evaluation_date
  )$included)
})


test_that("later collection and usage declarations replace earlier decisions in their periods", {
  for (code in c("6", "8")) {
    rows <- data.table::rbindlist(list(consentDocumentFixture(), consentProvisionFixture(
      code, "deny", "2023-01-01", "2050-01-01", "b", "2023-01-01 00:00:00"
    )))
    calculate <- function(x) calculateBroadConsentPatient(x, NULL, as.Date("2026-09-15"))
    if (code == "6") {
      expect_equal(calculate(rows)$periods$end, as.Date("2022-12-31"))
    } else {
      expect_false(calculate(rows)$included)
    }
    renewed <- consentDocumentFixture("c", "2024-01-01 00:00:00")
    rows <- data.table::rbindlist(list(rows, renewed))
    expect_true(calculate(rows)$included)
    expect_equal(calculate(rows)$periods, calculate(consentDocumentFixture())$periods)
    expect_equal(calculate(rows[nrow(rows):1L, ]), calculate(rows))
  }
})

test_that("collection deny cuts retro grants and later partial grants restore only their own period", {
  rows <- data.table::rbindlist(list(
    consentDocumentFixture(), consentProvisionFixture("45"),
    consentProvisionFixture("6", "deny", "2023-01-01", "2025-12-31", "b", "2023-01-01 00:00:00")
  ))
  calculate <- function(x) calculateBroadConsentPatient(x, NULL, as.Date("2026-09-15"))
  expect_equal(calculate(rows)$periods, data.table::data.table(
    start = as.Date("1900-01-01"), end = as.Date("2022-12-31")
  ))
  renewed <- consentDocumentFixture("c", "2024-01-01 00:00:00")
  renewed$start[renewed$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2024-01-01")
  renewed$end[renewed$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2024-12-31")
  rows <- data.table::rbindlist(list(rows, renewed))
  expect_equal(calculate(rows)$periods, data.table::data.table(
    start = as.Date(c("1900-01-01", "2024-01-01")),
    end = as.Date(c("2022-12-31", "2024-12-31"))
  ))
})

test_that("retro deny resets regular history and retains only the new document's grants", {
  for (code in c("45", "46")) {
    original <- consentDocumentFixture()
    original$end[original$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2023-12-31")
    restriction <- consentProvisionFixture(
      code, "deny", "2025-01-01", "2028-12-31", "b", "2025-01-01 00:00:00"
    )
    calculate <- function(x) calculateBroadConsentPatient(x, NULL, as.Date("2026-09-15"))
    rows <- data.table::rbindlist(list(original, restriction))
    expect_false(calculate(rows)$included)
    renewed <- consentDocumentFixture("b", "2025-01-01 00:00:00")
    renewed$start[renewed$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2025-01-01")
    renewed$end[renewed$code == paste0(BROAD_CONSENT_CODE_PREFIX, "6")] <- as.Date("2028-12-31")
    rows <- data.table::rbindlist(list(rows, renewed))
    expect_equal(calculate(rows)$periods, data.table::data.table(
      start = as.Date("2025-01-01"), end = as.Date("2028-12-31")
    ))
    expect_equal(calculate(rows[nrow(rows):1L, ]), calculate(rows))
  }
})

test_that("a standalone retro permit never resets or extends another document", {
  rows <- data.table::rbindlist(list(consentDocumentFixture(), consentProvisionFixture(
    "45",
    consent_id = "b", declared_at = "2021-01-01 00:00:00"
  )))
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-15"))
  expect_equal(result$periods, data.table::data.table(
    start = as.Date("2020-01-01"), end = as.Date("2025-12-31")
  ))
})

test_that("simultaneous denies win independently of document IDs and row order", {
  for (code in c("6", "8", "45", "46")) {
    for (deny_id in c("0", "z")) {
      rows <- data.table::rbindlist(list(
        consentDocumentFixture(), consentProvisionFixture("45"),
        consentProvisionFixture(code, "deny", "1900-01-01", "2050-01-01", deny_id)
      ))
      result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-15"))
      expect_false(result$included)
      expect_equal(calculateBroadConsentPatient(rows[nrow(rows):1L, ], NULL, as.Date("2026-09-15")), result)
    }
  }
})

test_that("same-document retro restriction reduces extension but preserves all regular grants", {
  rows <- data.table::rbindlist(list(
    consentDocumentFixture(), consentProvisionFixture("45"),
    consentProvisionFixture("46", "deny", "1900-01-01", "2018-12-31"),
    consentProvisionFixture("6", start = "2027-01-01", end = "2027-12-31")
  ))
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-15"))
  expect_equal(result$periods, data.table::data.table(
    start = as.Date(c("2019-01-01", "2027-01-01")),
    end = as.Date(c("2025-12-31", "2027-12-31"))
  ))
  rows <- data.table::rbindlist(list(rows, consentProvisionFixture("6", "deny", "2022-01-01", "2022-12-31")))
  result <- calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-15"))
  expect_equal(result$periods, data.table::data.table(
    start = as.Date(c("2019-01-01", "2023-01-01", "2027-01-01")),
    end = as.Date(c("2021-12-31", "2025-12-31", "2027-12-31"))
  ))
})

test_that("incomplete later documents cannot restore collection or usage permissions", {
  for (code in c("6", "8")) {
    rows <- data.table::rbindlist(list(
      consentDocumentFixture(),
      consentProvisionFixture(code, "deny", "1900-01-01", "2050-01-01", "b", "2021-01-01 00:00:00"),
      consentProvisionFixture(code, "permit", "1900-01-01", "2050-01-01", "c", "2022-01-01 00:00:00")
    ))
    expect_false(calculateBroadConsentPatient(rows, NULL, as.Date("2026-09-15"))$included)
  }
})
