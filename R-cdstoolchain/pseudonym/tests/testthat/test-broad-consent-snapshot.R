test_that("Broad Consent chunk stream copies rows without changing them", {
  chunks <- list(
    data.table::data.table(patient_id = 1:2, pat_id = c("p1", "p2")),
    data.table::data.table(patient_id = 3L, pat_id = "p3")
  )
  chunk_index <- 0L
  requested_sizes <- integer()
  written_tables <- list()
  first_chunk_flags <- logical()

  result <- copyBroadConsentChunkStream(
    fetch_chunk = function(chunk_size) {
      requested_sizes <<- c(requested_sizes, chunk_size)
      chunk_index <<- chunk_index + 1L
      chunks[[chunk_index]]
    },
    has_completed = function() chunk_index == length(chunks),
    write_chunk = function(chunk, first_chunk) {
      written_tables[[length(written_tables) + 1L]] <<- data.table::copy(chunk)
      first_chunk_flags <<- c(first_chunk_flags, first_chunk)
    },
    chunk_size = 2L,
    table_name = "patient"
  )

  expect_equal(requested_sizes, c(2L, 2L))
  expect_equal(first_chunk_flags, c(TRUE, FALSE))
  expect_equal(data.table::rbindlist(written_tables), data.table::rbindlist(chunks))
  expect_equal(result$input_rows, 3L)
  expect_equal(result$output_rows, 3L)
  expect_equal(result$output_columns, 2L)
  expect_equal(result$chunks, 2L)
  expect_true(result$stream_seconds >= 0)
})

test_that("Broad Consent chunk stream creates an empty relation", {
  fetched <- FALSE
  writes <- 0L

  result <- copyBroadConsentChunkStream(
    fetch_chunk = function(chunk_size) {
      fetched <<- TRUE
      data.table::data.table(patient_id = integer(), pat_id = character())
    },
    has_completed = function() fetched,
    write_chunk = function(chunk, first_chunk) {
      writes <<- writes + 1L
      expect_true(first_chunk)
      expect_equal(nrow(chunk), 0L)
    },
    chunk_size = 100L,
    table_name = "patient"
  )

  expect_equal(writes, 1L)
  expect_equal(result$input_rows, 0L)
  expect_equal(result$output_rows, 0L)
  expect_equal(result$output_columns, 2L)
})

test_that("Broad Consent report writes an xlsx workbook", {
  file_name <- tempfile(fileext = ".xlsx")
  summary <- data.table::data.table(
    TABLE_NAME = "patient",
    FILTER_ACTION = "broad_consent_selected",
    INPUT_ROWS = 3L,
    OUTPUT_ROWS = 3L
  )

  result <- writeBroadConsentSnapshotReport(summary, file_name = file_name)

  expect_true(file.exists(file_name))
  expect_equal(result, summary)
})
