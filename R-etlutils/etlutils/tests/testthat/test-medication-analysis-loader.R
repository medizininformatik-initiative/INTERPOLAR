test_that("shared MedA loader retains reporting deduplication and ordering", {
  source <- data.frame(
    record_id = c("b", "a", "a", "a"),
    fall_meda_id = c("c2", "c1", "c1", "c1"),
    meda_id = c("m2", "m1", "m1", "m0"),
    meda_dat = as.POSIXct(c("2026-01-02", "2026-01-01", "2026-01-01", NA), tz = "UTC"),
    medikationsanalyse_complete = c("Complete", "Incomplete", "Incomplete", "Complete"),
    meda_mrp_detekt = "Nein", last_processing_nr = 1:4, redcap_repeat_instance = 1:4
  )
  testthat::local_mocked_bindings(dbGetReadOnlyQuery = function(query, lock_id) source)
  result <- getMedikationsanalyseFeData("test", "v_medikationsanalyse_fe_last_version")
  expected <- unique(source[, setdiff(names(source), "last_processing_nr")])
  expected <- expected[order(expected$record_id, expected$fall_meda_id, expected$meda_dat, na.last = TRUE), ]
  expect_equal(as.data.frame(result), expected, ignore_attr = TRUE)
  expect_equal(result$medikationsanalyse_complete, c("Incomplete", "Incomplete", "Complete", "Complete"))
})

test_that("discarding creation order retains the former reporting result", {
  source <- data.frame(
    record_id = "r", fall_meda_id = "c", meda_id = "m",
    meda_dat = as.POSIXct("2026-01-01", tz = "UTC"), medikationsanalyse_complete = "Complete",
    meda_mrp_detekt = "Ja", last_processing_nr = 1:2, redcap_repeat_instance = 1:2
  )
  local_mocked_bindings(dbGetReadOnlyQuery = function(...) source)
  result <- getMedikationsanalyseFeData("test", "view") |>
    dplyr::select(-redcap_repeat_instance) |> dplyr::distinct()
  expected <- unique(source[, setdiff(names(source), c("last_processing_nr", "redcap_repeat_instance"))])
  expect_equal(as.data.frame(result), expected, ignore_attr = TRUE)
})
