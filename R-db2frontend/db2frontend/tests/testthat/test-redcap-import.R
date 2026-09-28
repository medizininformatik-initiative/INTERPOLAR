test_that("batched import responses retain IDs and respect the configured delimiter", {
  for (separator in c(",", ";")) {
    response <- paste0('"id"', separator, '"note"\n"00123"', separator, '"a', separator, 'b"\n')
    result <- normalizeRedcapImportResult(c(response, response), separator)
    expect_identical(result$id, c("00123", "00123"))
    expect_identical(result$note, rep(paste0("a", separator, "b"), 2))
  }
  expect_identical(normalizeRedcapImportResult('"id"\n"NA"\n', ",")$id, "NA")
  expect_identical(normalizeRedcapImportResult(data.frame(id = "00123"), ";")$id, "00123")
  expect_equal(nrow(normalizeRedcapImportResult(character(), ",")), 0L)
  expect_error(normalizeRedcapImportResult(c('"id"\n"1"', "<html>Fatal error</html>"), ","), "Fatal error")
})

test_that("error responses are distinguished from literal identifiers", {
  expect_error(normalizeRedcapImportResult('{"error":"Import failed"}', ","), "Import failed")
  expect_identical(normalizeRedcapImportResult('"id"\n"error"\n"<html>"\n', ",")$id, c("error", "<html>"))
})

test_that("imports preserve raw identifiers and batch large tables", {
  captured <- NULL
  testthat::local_mocked_bindings(
    importRecords = function(rcon, data, overwriteBehavior, returnContent, batch.size) {
      captured <<- list(data = data, overwrite = overwriteBehavior, content = returnContent, batch = batch.size)
      '"id"\n"00123"\n'
    },
    .package = "redcapAPI"
  )
  testthat::local_mocked_bindings(writeDebugExcelFile = function(...) NULL, .package = "etlutils")
  rcon <- list(csv_delimiter = function() ";")
  import_data <- data.table::data.table(sql_choice = "0007", record_id = "00123")
  result <- importRecordsToRedcap(rcon, "form", import_data)
  expect_identical(names(captured$data), c("record_id", "sql_choice"))
  expect_identical(captured$data$sql_choice, "0007")
  expect_identical(names(import_data), c("sql_choice", "record_id"))
  expect_identical(result$id, "00123")
  expect_identical(captured$batch, -1L)
  expect_identical(captured$content, "ids")
  importRecordsToRedcap(rcon, "form", import_data[rep(1L, 1001)], overwriteBehavior = "overwrite")
  expect_identical(captured$batch, 1000L)
  expect_identical(captured$overwrite, "overwrite")
})

test_that("importable fields come from metadata including checkbox and repeat fields", {
  testthat::local_mocked_bindings(
    exportFieldNames = function(...) data.frame(export_field_name = c("record_id", "choice___1", "calculated")),
    exportMetaData = function(...) data.frame(field_name = c("record_id", "choice", "calculated"), field_type = c("text", "checkbox", "calc")),
    exportInstruments = function(...) data.frame(instrument_name = "form"),
    .package = "redcapAPI"
  )
  expect_setequal(getRedcapFieldNames(NULL), c(
    "record_id", "choice___1", "redcap_repeat_instrument", "redcap_repeat_instance",
    "redcap_data_access_group", "form_complete"
  ))
})
