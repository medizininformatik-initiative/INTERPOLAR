getTestFallvignetteMapping <- function() {
  mapping_path <- getFallvignetteMappingPath(
    "WP8MRP_Liste_Daten_Mapping20260722.xlsx"
  )
  loadFallvignetteMapping(mapping_path)
}

testthat::test_that("loadFallvignetteMapping reads the WP8 mapping", {
  mapping <- getTestFallvignetteMapping()

  testthat::expect_s3_class(mapping, "data.table")
  testthat::expect_equal(nrow(mapping), 61L)
  testthat::expect_equal(data.table::uniqueN(mapping$target_field), 39L)
  testthat::expect_equal(
    mapping$source_field[mapping$target_field == "wp8_ret_notiz"],
    c("ret_notiz1", "ret_notiz2")
  )
})

testthat::test_that("createEmptyFallvignetteExport uses mapping order", {
  mapping <- getTestFallvignetteMapping()
  result <- createEmptyFallvignetteExport(mapping)

  testthat::expect_s3_class(result, "data.table")
  testthat::expect_equal(nrow(result), 0L)
  testthat::expect_identical(names(result), unique(mapping$target_field))
})

testthat::test_that("writeFallvignetteImportFiles writes equivalent files", {
  mapping <- getTestFallvignetteMapping()
  columns <- unique(mapping$target_field)
  fallvignettes <- data.table::as.data.table(
    stats::setNames(as.list(rep("", length(columns))), columns)
  )
  data.table::set(
    fallvignettes,
    j = "record_id",
    value = "Standort-1-MRP-1-Bewertung-1"
  )
  data.table::set(
    fallvignettes,
    j = "wp8_fv_diagnosen",
    value = "I10 Essentielle Hypertonie"
  )

  paths <- writeFallvignetteImportFiles(
    fallvignettes,
    tempdir(),
    file_name = "fallvignette-export-test",
    mapping = mapping
  )

  csv_result <- data.table::fread(paths$csv, encoding = "UTF-8")
  xlsx_result <- etlutils::readExcelFileAsTableList(paths$xlsx)[["Fallvignetten"]]

  testthat::expect_true(all(file.exists(unlist(paths))))
  testthat::expect_identical(names(csv_result), columns)
  testthat::expect_identical(names(xlsx_result), columns)
  testthat::expect_equal(csv_result$record_id, fallvignettes$record_id)
  testthat::expect_equal(xlsx_result$wp8_fv_diagnosen, fallvignettes$wp8_fv_diagnosen)
})

testthat::test_that("writeFallvignetteImportFiles validates record_id", {
  mapping <- getTestFallvignetteMapping()
  columns <- unique(mapping$target_field)
  fallvignettes <- data.table::as.data.table(
    stats::setNames(as.list(rep("", length(columns))), columns)
  )

  testthat::expect_error(
    writeFallvignetteImportFiles(fallvignettes, tempdir(), mapping = mapping),
    "non-empty record_id"
  )
})
