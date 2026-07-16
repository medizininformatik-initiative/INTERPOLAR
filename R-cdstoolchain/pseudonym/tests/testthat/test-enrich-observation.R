test_that("enrichSnapshotObservationTables adds LOINC reference values", {
  input_repo_path <- file.path(tempdir(), paste0("input-repo-", as.integer(runif(1, 1, 1e9))))
  mapping_dir <- file.path(input_repo_path, "LOINC_Mapping", "LOINC_Mapping_content")
  dir.create(mapping_dir, recursive = TRUE)
  mapping <- data.table::data.table(
    LOINC = "1234-5",
    LOINC_PRIMARY = "9999-9",
    UNIT = "umol/L",
    CONVERSION_FACTOR = NA_character_,
    CONVERSION_UNIT = NA_character_
  )
  etlutils::writeExcelFile(
    list(mapping),
    file.path(mapping_dir, "LOINC_Mapping_Table_processed.xlsx"),
    with_column_names = TRUE
  )

  observation <- data.table::data.table(
    obs_id = c("obs-1", "obs-2", "obs-3"),
    obs_code_system = c("http://loinc.org", "http://loinc.org", "http://example.org"),
    obs_code_code = c("1234-5", "7777-7", "1234-5"),
    obs_valuequantity_value = c(1, 2, 3),
    obs_valuequantity_code = c("mmol/L", "mmol/L", "mmol/L"),
    obs_valuequantity_unit = c("millimole per liter", "millimole per liter", "millimole per liter")
  )
  tables <- list(
    observation = observation,
    observation_last_version = observation[1],
    patient = data.table::data.table(pat_id = "pat-1")
  )

  result <- enrichSnapshotObservationTables(tables, input_repo_path)

  expect_equal(result$observation$value_in_reference_unit[1], 1000)
  expect_equal(result$observation$reference_unit[1], "umol/L")
  expect_equal(result$observation$primary_loinc_code[1], "9999-9")
  expect_true(is.na(result$observation$value_in_reference_unit[2]))
  expect_true(is.na(result$observation$value_in_reference_unit[3]))
  expect_equal(result$observation_last_version$value_in_reference_unit[1], 1000)
  expect_false("value_in_reference_unit" %in% names(result$patient))
})

test_that("enrichSnapshotObservationTables is a no-op without observation tables", {
  tables <- list(patient = data.table::data.table(pat_id = "pat-1"))

  result <- enrichSnapshotObservationTables(tables, input_repo_path = NA_character_)

  expect_equal(result, tables)
})
