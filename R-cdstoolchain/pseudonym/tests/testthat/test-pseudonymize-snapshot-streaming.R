test_that("processSnapshotChunkStream keeps only one chunk in the processing contract", {
  chunks <- list(
    data.table::data.table(value = 1:2),
    data.table::data.table(value = 3L)
  )
  chunk_index <- 0L
  requested_sizes <- integer()
  written_tables <- list()
  first_chunk_flags <- logical()
  review_writes <- 0L

  result <- processSnapshotChunkStream(
    fetch_chunk = function(chunk_size) {
      requested_sizes <<- c(requested_sizes, chunk_size)
      chunk_index <<- chunk_index + 1L
      chunks[[chunk_index]]
    },
    has_completed = function() chunk_index == length(chunks),
    enrich_chunk = function(chunk) {
      chunk[["enriched"]] <- TRUE
      chunk
    },
    pseudonymize_chunk = function(chunk, chunk_number) {
      output <- data.table::copy(chunk)
      output[["value"]] <- output[["value"]] * 10L
      list(
        table = output,
        summary = data.table::data.table(
          INPUT_ROWS = nrow(chunk),
          OUTPUT_ROWS = nrow(output),
          OUTPUT_COLUMNS = length(names(output)),
          CHUNK_NUMBER = chunk_number
        )
      )
    },
    write_chunk = function(output, first_chunk) {
      written_tables[[length(written_tables) + 1L]] <<- data.table::copy(output)
      first_chunk_flags <<- c(first_chunk_flags, first_chunk)
    },
    review_chunk = function(chunk) emptyMedicationReferenceReport(),
    write_review_chunk = function(review) {
      review_writes <<- review_writes + 1L
    },
    chunk_size = 2L,
    table_name = "example"
  )

  expect_equal(requested_sizes, c(2L, 2L))
  expect_equal(first_chunk_flags, c(TRUE, FALSE))
  expect_equal(vapply(written_tables, nrow, integer(1)), c(2L, 1L))
  expect_equal(unlist(lapply(written_tables, `[[`, "value")), c(10L, 20L, 30L))
  expect_equal(result$summary$INPUT_ROWS, 3L)
  expect_equal(result$summary$OUTPUT_ROWS, 3L)
  expect_equal(result$chunks, 2L)
  expect_equal(review_writes, 2L)
})

test_that("processSnapshotChunkStream writes an empty relation once", {
  fetched <- FALSE
  writes <- 0L

  result <- processSnapshotChunkStream(
    fetch_chunk = function(chunk_size) {
      fetched <<- TRUE
      data.table::data.table(value = integer())
    },
    has_completed = function() fetched,
    enrich_chunk = identity,
    pseudonymize_chunk = function(chunk, chunk_number) {
      list(
        table = chunk,
        summary = data.table::data.table(
          INPUT_ROWS = 0L,
          OUTPUT_ROWS = 0L,
          OUTPUT_COLUMNS = 1L
        )
      )
    },
    write_chunk = function(output, first_chunk) {
      writes <<- writes + 1L
      expect_true(first_chunk)
      expect_equal(nrow(output), 0L)
    },
    review_chunk = function(chunk) emptyMedicationReferenceReport(),
    write_review_chunk = function(review) NULL,
    chunk_size = 100L,
    table_name = "empty"
  )

  expect_equal(writes, 1L)
  expect_equal(result$summary$INPUT_ROWS, 0L)
  expect_equal(result$summary$OUTPUT_ROWS, 0L)
})

test_that("medication source query resolves codes in the source database", {
  spec <- getMedicationReferenceSpec("medicationrequest")
  query <- buildSnapshotMedicationSourceQuery(
    DBI::ANSI(),
    '"db2dataprocessor_out"."v_medicationrequest"',
    c("medreq_id", "medreq_medicationreference_ref"),
    '"db2dataprocessor_out"."v_medication"',
    spec
  )

  expect_match(query, "WITH medication_codes AS", fixed = TRUE)
  expect_match(query, "SELECT DISTINCT \"med_id\"::text", fixed = TRUE)
  expect_match(query, "^Medication/", fixed = TRUE)
  expect_match(query, "AS \"medreq_medication_system\"", fixed = TRUE)
  expect_match(query, "AS \"medreq_medication_code\"", fixed = TRUE)
  expect_match(query, "LEFT JOIN medication_codes", fixed = TRUE)
})

test_that("birthdate source query supports fallback patient keys", {
  query <- buildSnapshotBirthdateMapQuery(
    DBI::ANSI(),
    '"db2dataprocessor_out"."v_fall_fe"',
    c("record_id", "patient_id_fk", "fall_pat_id", "fall_aufn_dat"),
    '"db2dataprocessor_out"."v_patient_fe"',
    c("patient_id_fk", "fall_pat_id"),
    c("record_id", "pat_id"),
    "pat_gebdat"
  )

  expect_match(query, "UNION ALL", fixed = TRUE)
  expect_match(query, "GROUP BY patient_key", fixed = TRUE)
  expect_match(query, "COALESCE(", fixed = TRUE)
  expect_match(query, SNAPSHOT_STREAMING_BIRTHDATE_COLUMN, fixed = TRUE)
})

test_that("source query omits enrichment joins not enabled by table description", {
  testthat::local_mocked_bindings(
    snapshotRelationFields = function(connection, name, schema = NULL) {
      if (name == "v_fall_fe") {
        return(c("fall_id", "patient_id_fk", "fall_aufn_dat"))
      }
      c("record_id", "pat_gebdat")
    },
    snapshotRelationExists = function(connection, name, schema = NULL) TRUE
  )
  plan_row <- data.table::data.table(
    SOURCE_RELATION = "v_fall_fe",
    BASE_TABLE_NAME = "fall_fe",
    SNAPSHOT_RELATION_TYPE = "all"
  )

  query_info <- getSnapshotStreamingSourceQuery(
    DBI::ANSI(),
    plan_row,
    source_schema = NULL,
    source_view_prefix = "v_",
    last_version_suffix = "_last_version",
    described_columns = c("fall_id", "patient_id_fk", "fall_aufn_dat")
  )

  expect_equal(query_info$query, "SELECT * FROM \"v_fall_fe\"")
  expect_false(grepl("patient_birthdates", query_info$query, fixed = TRUE))
})

test_that("streaming case enrichment removes its lookup column", {
  context <- newSnapshotStreamingContext(NULL)
  fall <- data.table::data.table(
    fall_aufn_dat = as.Date("2026-07-22"),
    fall_gewicht_aktuell = 80,
    fall_gewicht_aktl_einheit = "kg",
    fall_groesse = 2,
    fall_groesse_einheit = "m"
  )
  fall[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]] <- as.Date("1986-07-22")

  result <- enrichSnapshotStreamingChunk(
    fall,
    "fall_fe",
    context,
    described_columns = c(
      names(fall),
      "fall_age_at_admission",
      "fall_bmi"
    )
  )

  expect_equal(result$fall_age_at_admission, 40L)
  expect_equal(result$fall_bmi, 20)
  expect_false(SNAPSHOT_STREAMING_BIRTHDATE_COLUMN %in% names(result))
})

test_that("streaming enrichment only creates columns described by table description", {
  context <- newSnapshotStreamingContext(NULL)
  fall <- data.table::data.table(
    fall_aufn_dat = as.Date("2026-07-22"),
    fall_gewicht_aktuell = 80,
    fall_gewicht_aktl_einheit = "kg",
    fall_groesse = 2,
    fall_groesse_einheit = "m"
  )
  fall[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]] <- as.Date("1986-07-22")

  result <- enrichSnapshotStreamingChunk(
    fall,
    "fall_fe",
    context,
    described_columns = c("fall_aufn_dat", "fall_age_at_admission")
  )

  expect_equal(result$fall_age_at_admission, 40L)
  expect_false("fall_bmi" %in% names(result))
  expect_false(SNAPSHOT_STREAMING_BIRTHDATE_COLUMN %in% names(result))
})

test_that("missing described source columns leave enrichment targets empty", {
  context <- newSnapshotStreamingContext(NULL)
  fall <- data.table::data.table(
    fall_gewicht_aktuell = 80,
    fall_groesse = 2
  )

  result <- enrichSnapshotStreamingChunk(
    fall,
    "fall_fe",
    context,
    described_columns = c(
      "fall_gewicht_aktuell",
      "fall_groesse",
      "fall_bmi"
    )
  )

  expect_true(is.na(result$fall_bmi))
})

test_that("encounter enrichment tolerates an omitted admission date", {
  context <- newSnapshotStreamingContext(NULL)
  encounter <- data.table::data.table(enc_patient_ref = "Patient/pat-1")

  result <- enrichSnapshotStreamingChunk(
    encounter,
    "encounter",
    context,
    described_columns = c("enc_patient_ref", "enc_age_at_admission")
  )

  expect_true(is.na(result$enc_age_at_admission))
})

test_that("observation enrichment is optional for missing sources and targets", {
  context <- newSnapshotStreamingContext(NULL)
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = "1234-5"
  )

  without_target <- enrichSnapshotStreamingChunk(
    observation,
    "observation",
    context,
    described_columns = names(observation)
  )
  with_missing_sources <- enrichSnapshotStreamingChunk(
    observation,
    "observation",
    context,
    described_columns = c(names(observation), "primary_loinc_code")
  )

  expect_false("primary_loinc_code" %in% names(without_target))
  expect_true(is.na(with_missing_sources$primary_loinc_code))
  expect_null(context$loinc_mapping)
})

test_that("observation enrichment keeps only described target columns", {
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = "1234-5",
    obs_valuequantity_value = 2,
    obs_valuequantity_code = "mg",
    obs_valuequantity_unit = "mg"
  )
  mapping <- data.table::data.table(
    LOINC = "1234-5",
    LOINC_PRIMARY = "1234-5",
    UNIT = "mg",
    CONVERSION_FACTOR = NA_real_,
    CONVERSION_UNIT = NA_character_
  )

  result <- enrichObservationWithLoincMapping(
    observation,
    mapping,
    enrichment_columns = "primary_loinc_code",
    source_columns = names(observation)
  )

  expect_equal(result$primary_loinc_code, "1234-5")
  expect_false("value_in_reference_unit" %in% names(result))
  expect_false("reference_unit" %in% names(result))
})

test_that("medication enrichment only creates described targets", {
  context <- newSnapshotStreamingContext(NULL)
  medication_request <- data.table::data.table(
    medreq_medicationreference_ref = "Medication/med-1"
  )

  without_target <- enrichSnapshotStreamingChunk(
    medication_request,
    "medicationrequest",
    context,
    described_columns = names(medication_request)
  )
  with_missing_source <- enrichSnapshotStreamingChunk(
    data.table::data.table(medreq_id = "request-1"),
    "medicationrequest",
    context,
    described_columns = c("medreq_id", "medreq_medication_code")
  )

  expect_false("medreq_medication_system" %in% names(without_target))
  expect_false("medreq_medication_code" %in% names(without_target))
  expect_true(is.na(with_missing_source$medreq_medication_code))
  expect_false("medreq_medication_system" %in% names(with_missing_source))
})

test_that("streaming medication review keeps exact counts and bounded examples", {
  spec <- getMedicationReferenceSpec("medicationrequest")
  chunk <- data.table::data.table(
    medreq_medicationreference_ref = c("Medication/missing", "Medication/ok"),
    medreq_medication_system = c(NA_character_, "http://atc"),
    medreq_medication_code = c(NA_character_, "A01")
  )
  report <- getUnmatchedMedicationReferencesFromEnrichedTable(
    chunk,
    "medicationrequest",
    spec
  )
  context <- newBoundedMedicationReferenceReview(detail_limit = 1L)
  recordBoundedMedicationReferenceReview(context, report)
  recordBoundedMedicationReferenceReview(context, report)
  result <- finalizeBoundedMedicationReferenceReview(context)

  expect_equal(result$summary$UNMATCHED_ROWS, 2)
  expect_equal(nrow(result$unmatched_reference_examples), 1L)
  expect_equal(result$unmatched_reference_examples$MEDICATION_ID, "missing")
})

test_that("snapshot chunk size must be positive", {
  expect_equal(validateSnapshotChunkSize(NULL), DEFAULT_SNAPSHOT_CHUNK_SIZE)
  expect_equal(validateSnapshotChunkSize("25000"), 25000L)
  expect_error(validateSnapshotChunkSize(0), "positive integer")
  expect_error(validateSnapshotChunkSize(NA), "positive integer")
})
