test_that("readExcelFileAsTableList retains sheet names, values and read limits", {
  path <- tempfile(fileext = ".xlsx")
  on.exit(unlink(path), add = TRUE)
  sheets <- list(first = data.frame(id = 1:2, text = c("a", "b")), second = data.frame(value = 3L))
  openxlsx::write.xlsx(sheets, path)
  result <- readExcelFileAsTableList(path)
  expect_identical(names(result), names(sheets))
  expect_true(all(vapply(result, data.table::is.data.table, logical(1))))
  expect_equal(lapply(result, as.data.frame), sheets)
  expect_equal(readExcelFileAsTableList(path, 1), result[1])
  expect_identical(readExcelFileAsTableList(path, 0), list())
  expect_equal(readExcelFileAsTableList(path, 10), result)
})

test_that("readExcelFileAsTableList preserves the workbook error", {
  testthat::local_mocked_bindings(
    getSheetNames = function(...) stop("original workbook failure"),
    .package = "openxlsx"
  )
  expect_error(
    readExcelFileAsTableList("test.xlsx"),
    "Could not read Excel workbook 'test.xlsx': original workbook failure",
    fixed = TRUE
  )
})

test_that("readExcelFileAsTableList fails with sheet context instead of returning partial data", {
  requested_sheets <- character()
  testthat::local_mocked_bindings(
    getSheetNames = function(...) c("first", "broken", "last"),
    read.xlsx = function(xlsxFile, sheet, skipEmptyRows, colNames) {
      requested_sheets <<- c(requested_sheets, sheet)
      expect_false(skipEmptyRows)
      expect_true(colNames)
      if (sheet == "broken") stop("original sheet failure")
      data.frame(id = 1L)
    },
    .package = "openxlsx"
  )
  expect_error(
    readExcelFileAsTableList("test.xlsx"),
    "Could not read Excel workbook 'test.xlsx', sheet 'broken': original sheet failure",
    fixed = TRUE
  )
  expect_identical(requested_sheets, c("first", "broken"))
})
