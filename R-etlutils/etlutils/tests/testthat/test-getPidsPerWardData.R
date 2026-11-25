test_that("station assignments are read distinctly and ordered in SQL", {
  assignments <- data.table::data.table(
    ward_name = c("WARD_B", "WARD_A", NA_character_),
    patient_id = c("p1", "p1", "p2"),
    encounter_id = c("e1", "e1", "e2")
  )
  local_mocked_bindings(dbGetReadOnlyQuery = function(query, lock_id) {
    expect_identical(query, paste(
      "SELECT DISTINCT ward_name, patient_id, encounter_id FROM v_pids_per_ward",
      "ORDER BY patient_id, encounter_id"
    ))
    expect_identical(lock_id, "test ward assignments")
    assignments
  })
  expect_identical(getPidsPerWardData("test ward assignments", "v_pids_per_ward"), assignments)
})

test_that("empty assignments and database failures retain their errors", {
  local_mocked_bindings(dbGetReadOnlyQuery = function(...) data.table::data.table())
  expect_error(getPidsPerWardData("test", "v_pids_per_ward"), "The pids_per_ward table is empty")
  local_mocked_bindings(dbGetReadOnlyQuery = function(...) stop("database unavailable"))
  expect_error(getPidsPerWardData("test", "v_pids_per_ward"), "database unavailable")
})

test_that("registration metadata can be selected without changing reporting defaults", {
  local_mocked_bindings(dbGetReadOnlyQuery = function(query, lock_id) {
    expect_match(query, "SELECT DISTINCT ward_name, patient_id, encounter_id, input_datetime, pids_per_ward_id FROM")
    data.frame(
      ward_name = "A", patient_id = "p", encounter_id = "e",
      input_datetime = as.POSIXct("2026-01-01", tz = "UTC"), pids_per_ward_id = 1L
    )
  })
  result <- getPidsPerWardData("test", "v_pids_per_ward", c("input_datetime", "pids_per_ward_id"))
  expect_equal(result$pids_per_ward_id, 1L)
  expect_error(getPidsPerWardData("test", "v_pids_per_ward", "*"), "Invalid")
})
