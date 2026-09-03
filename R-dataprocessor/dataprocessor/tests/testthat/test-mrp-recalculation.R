test_that("MRP recalculation ignores presentation-only changes", {
  key_cols <- c(
    "record_id",
    "ret_meda_id",
    "ret_atc1",
    "ret_ip_klasse_01",
    "ret_ip_klasse_disease",
    "ret_atc2"
  )
  existing <- data.table::data.table(
    record_id = 1L,
    ret_meda_id = "meda-1",
    ret_meda_dat_referenz = as.POSIXct("2026-01-01 12:00:00", tz = "UTC"),
    ret_kurzbeschr = "Old evidence",
    ret_atc1 = "A01AA01",
    ret_ip_klasse_01 = "Drug-Disease",
    ret_ip_klasse_disease = "Disease cluster",
    ret_atc2 = NA_character_
  )
  current <- data.table::copy(existing)
  current[, `:=`(
    ret_meda_dat_referenz = as.POSIXct("2026-01-01 12:00:01", tz = "UTC"),
    ret_kurzbeschr = "Newly loaded evidence"
  )]

  result <- filterExistingMRPRows(
    current,
    existing,
    key_cols,
    c(key_cols, "ret_meda_dat_referenz", "ret_kurzbeschr")
  )

  expect_equal(nrow(result), 0L)
})

test_that("MRP recalculation keeps clinically distinct candidates", {
  key_cols <- c(
    "record_id",
    "ret_meda_id",
    "ret_atc1",
    "ret_ip_klasse_01",
    "ret_ip_klasse_disease",
    "ret_atc2"
  )
  existing <- data.table::data.table(
    record_id = 1L,
    ret_meda_id = "meda-1",
    ret_atc1 = "A01AA01",
    ret_ip_klasse_01 = "Drug-Disease",
    ret_ip_klasse_disease = "Disease cluster",
    ret_atc2 = NA_character_
  )
  current <- data.table::copy(existing)
  current[, ret_atc1 := "A01AA02"]

  result <- filterExistingMRPRows(current, existing, key_cols)

  expect_equal(nrow(result), 1L)
  expect_equal(result$ret_atc1, "A01AA02")
})

test_that("MRP recalculation preserves fixed rules sharing the visible key", {
  key_cols <- c(
    "record_id",
    "ret_meda_id",
    "ret_atc1",
    "ret_ip_klasse_01",
    "ret_ip_klasse_disease",
    "ret_atc2"
  )
  current <- data.table::data.table(
    record_id = c(1L, 1L),
    ret_meda_id = c("meda-1", "meda-1"),
    ret_kurzbeschr = c("Direct diagnosis", "New proxy evidence"),
    ret_atc1 = c("A01AA01", "A01AA01"),
    ret_ip_klasse_01 = c("Drug-Disease", "Drug-Disease"),
    ret_ip_klasse_disease = c("Disease cluster", "Disease cluster"),
    ret_atc2 = c(NA_character_, NA_character_)
  )

  result <- filterExistingMRPRows(current, data.table::data.table(), key_cols)

  expect_equal(nrow(result), 2L)
  expect_false(".mrp_recalculation_key" %in% names(result))
})

test_that("MRP recalculation subtracts legacy rows by key cardinality", {
  key_cols <- c(
    "record_id",
    "ret_meda_id",
    "ret_atc1",
    "ret_ip_klasse_01",
    "ret_ip_klasse_disease",
    "ret_atc2"
  )
  existing <- data.table::data.table(
    record_id = 1L,
    ret_id = "meda-1-r1",
    ret_meda_id = "meda-1",
    ret_meda_dat_referenz = as.POSIXct("2026-01-01 12:00:00", tz = "UTC"),
    ret_kurzbeschr = "Existing fixed rule",
    ret_atc1 = "A01AA01",
    ret_ip_klasse_01 = "Drug-Disease",
    ret_ip_klasse_disease = "Disease cluster",
    ret_atc2 = NA_character_
  )
  current <- data.table::rbindlist(list(
    data.table::copy(existing)[, ret_id := "temporary-r1"],
    data.table::copy(existing)[, `:=`(
      ret_id = "temporary-r2",
      ret_kurzbeschr = "Newly triggered fixed rule"
    )]
  ))

  result <- filterExistingMRPRows(
    current,
    existing,
    key_cols,
    c(key_cols, "ret_meda_dat_referenz", "ret_kurzbeschr")
  )

  expect_equal(nrow(result), 1L)
  expect_equal(result$ret_kurzbeschr, "Newly triggered fixed rule")
})

test_that("MRP history versions do not inflate the legacy count", {
  key_cols <- c("record_id", "ret_meda_id", "ret_atc1")
  existing <- data.table::data.table(
    record_id = c(1L, 1L),
    ret_id = c("meda-1-r1", "meda-1-r1"),
    ret_meda_id = c("meda-1", "meda-1"),
    ret_atc1 = c("A01AA01", "A01AA01"),
    ret_kurzbeschr = c("Old version", "New version")
  )
  current <- data.table::data.table(
    record_id = c(1L, 1L),
    ret_id = c("temporary-r1", "temporary-r2"),
    ret_meda_id = c("meda-1", "meda-1"),
    ret_atc1 = c("A01AA01", "A01AA01"),
    ret_kurzbeschr = c("Changed first rule", "Second fixed rule")
  )

  result <- filterExistingMRPRows(current, existing, key_cols)

  expect_equal(nrow(result), 1L)
})

test_that("MRP record IDs are chunked without splitting or repeating records", {
  chunks <- splitMRPRecordIds(c(3L, 1L, 2L, 3L, NA_integer_, 4L, 5L), chunk_size = 2L)

  expect_equal(unname(lengths(chunks)), c(2L, 2L, 1L))
  expect_equal(unname(unlist(chunks)), c(3L, 1L, 2L, 4L, 5L))
})
