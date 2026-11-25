test_that("default queries retain all columns and deduplicate the combined case data", {
  seed <- data.table::data.table(
    enc_id = c("ward", "missing", "invalid"),
    enc_main_encounter_calculated_ref = c("Encounter/main", NA_character_, "invalid"),
    extra = c("keep", "missing", "invalid")
  )
  related <- data.table::rbindlist(list(seed[1], seed[1], data.table::data.table(
    enc_id = "main", enc_main_encounter_calculated_ref = "Encounter/main", extra = "main"
  )))
  calls <- character()
  local_mocked_bindings(dbGetReadOnlyQuery = function(query, lock_id) {
    calls <<- c(calls, query)
    expect_match(query, "^SELECT \\* FROM v_encounter_last_version")
    if (length(calls) == 1L) {
      expect_identical(lock_id, "getAllEncounters.main[test]")
      seed
    } else {
      expect_identical(lock_id, "getAllEncounters.cases[test]")
      expect_match(query, "WHERE enc_main_encounter_calculated_ref IN ('Encounter/main')", fixed = TRUE)
      related
    }
  })
  expected <- unique(data.table::rbindlist(list(related, seed[2:3], seed)))
  expect_equal(fhirdataGetAllEncounters(seed$enc_id, "test"), expected)
  expect_length(calls, 2L)
})

test_that("selected columns use DISTINCT in both queries and retain required linking columns", {
  projected <- data.table::data.table(
    enc_patient_ref = "Patient/p1", enc_id = "ward",
    enc_main_encounter_calculated_ref = "Encounter/main"
  )
  calls <- 0L
  local_mocked_bindings(dbGetReadOnlyQuery = function(query, lock_id) {
    calls <<- calls + 1L
    expect_true(startsWith(query, paste0(
      'SELECT DISTINCT "enc_patient_ref", "enc_id", "enc_main_encounter_calculated_ref"',
      " FROM v_encounter_last_version\n"
    )))
    projected
  })
  result <- fhirdataGetAllEncounters("ward", "test", c("enc_patient_ref", "enc_id", "enc_patient_ref"))
  expect_equal(result, projected)
  expect_equal(nrow(result), 1L)
  expect_identical(calls, 2L)
})

test_that("empty results and seeds without a main reference do not trigger a case query", {
  calls <- 0L
  rows <- data.table::data.table(enc_id = character(), enc_main_encounter_calculated_ref = character())
  local_mocked_bindings(dbGetReadOnlyQuery = function(...) {
    calls <<- calls + 1L
    rows
  })
  expect_equal(fhirdataGetAllEncounters(character(), "test"), data.table::data.table())
  expect_identical(calls, 0L)
  expect_equal(fhirdataGetAllEncounters("absent", "test", "enc_id"), rows)
  expect_identical(calls, 1L)
  rows <- data.table::data.table(enc_id = c("a", "a", "b"), enc_main_encounter_calculated_ref = c(NA, NA, "invalid"))
  expect_equal(fhirdataGetAllEncounters(c("a", "b"), "test", "enc_id"), unique(rows))
  expect_identical(calls, 2L)
})

test_that("invalid column selections fail before database access", {
  local_mocked_bindings(dbGetReadOnlyQuery = function(...) stop("unexpected database access"))
  for (columns in list(NULL, character(), NA_character_, "", " ", 1, c("*", "enc_id"))) {
    expect_error(fhirdataGetAllEncounters("ward", "test", columns), "column_names must be")
  }
})
