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
  expect_named(
    result$timing,
    c(
      "FETCH_SECONDS",
      "ENRICH_SECONDS",
      "REVIEW_SECONDS",
      "PSEUDONYMIZE_SECONDS",
      "WRITE_SECONDS",
      "OTHER_SECONDS",
      "STREAM_SECONDS"
    )
  )
  expect_true(all(result$timing >= 0))
  expect_gte(
    result$timing[["STREAM_SECONDS"]] + 0.01,
    sum(result$timing[setdiff(names(result$timing), "STREAM_SECONDS")])
  )
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

test_that("shared medication resolution query traverses the reference graph", {
  root_queries <- c(
    "SELECT 'med-1'::text AS root_medication_id",
    "SELECT 'med-2'::text AS root_medication_id"
  )
  query <- buildSnapshotMedicationResolutionQuery(
    DBI::ANSI(),
    root_queries,
    '"db2dataprocessor_out"."v_medication"'
  )

  expect_match(query, "WITH RECURSIVE\nmedication_nodes AS", fixed = TRUE)
  expect_match(query, "UNION ALL", fixed = TRUE)
  expect_match(query, "medication_edges AS", fixed = TRUE)
  expect_match(query, "medication_walk(root_medication_id, medication_id)", fixed = TRUE)
  expect_match(query, "FROM medication_walk\n  JOIN medication_edges", fixed = TRUE)
  expect_match(query, "missing_medication", fixed = TRUE)
  expect_match(query, "no_reachable_code", fixed = TRUE)
})

test_that("medication source query joins the prepared shared resolution", {
  spec <- getMedicationReferenceSpec("medicationrequest")
  query <- buildSnapshotMedicationSourceQuery(
    DBI::ANSI(),
    '"db2dataprocessor_out"."v_medicationrequest"',
    c("medreq_id", "medreq_medicationreference_ref"),
    '"snapshot_medication_resolution_all"',
    spec
  )

  expect_false(grepl("WITH RECURSIVE", query, fixed = TRUE))
  expect_match(query, "^Medication/", fixed = TRUE)
  expect_match(query, "AS \"medreq_medication_system\"", fixed = TRUE)
  expect_match(query, "AS \"medreq_medication_code\"", fixed = TRUE)
  expect_match(query, "LEFT JOIN \"snapshot_medication_resolution_all\"", fixed = TRUE)
  expect_match(query, SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN, fixed = TRUE)
})

test_that("shared medication resolution keeps direct codes without ingredient references", {
  query <- buildSnapshotMedicationResolutionQuery(
    DBI::ANSI(),
    "SELECT 'med-1'::text AS root_medication_id",
    '"db2dataprocessor_out"."v_medication"',
    ingredient_reference_column = NULL
  )

  expect_match(query, "medication_edges AS", fixed = TRUE)
  expect_match(query, "WHERE FALSE", fixed = TRUE)
  expect_match(query, "medication_code_values AS", fixed = TRUE)
})

test_that("composed medication SQL keeps nested queries indented", {
  query <- buildSnapshotMedicationResolutionQuery(
    DBI::ANSI(),
    c(
      "SELECT 'med-1'::text AS root_medication_id",
      "SELECT 'med-2'::text AS root_medication_id"
    ),
    '"db2dataprocessor_out"."v_medication"'
  )

  expect_match(
    query,
    paste0(
      "medication_nodes AS (\n",
      "  SELECT DISTINCT \"med_id\"::text AS medication_id\n",
      "  FROM \"db2dataprocessor_out\".\"v_medication\""
    ),
    fixed = TRUE
  )
  expect_match(
    query,
    paste0(
      "FROM (\n",
      "    SELECT 'med-1'::text AS root_medication_id\n",
      "    UNION ALL\n",
      "    SELECT 'med-2'::text AS root_medication_id\n",
      "  ) medication_root_candidates"
    ),
    fixed = TRUE
  )
  expect_match(
    query,
    paste0(
      "LEFT JOIN medication_codes\n",
      "  ON medication_codes.root_medication_id = "
    ),
    fixed = TRUE
  )
})

test_that("medication source query supports every configured reference table", {
  for (i in seq_len(nrow(SNAPSHOT_MEDICATION_REFERENCE_SPECS))) {
    spec <- SNAPSHOT_MEDICATION_REFERENCE_SPECS[i, ]
    query <- buildSnapshotMedicationSourceQuery(
      DBI::ANSI(),
      '"db2dataprocessor_out"."v_source"',
      c("source_id", spec[["reference_column"]]),
      '"snapshot_medication_resolution_all"',
      spec
    )

    expect_match(
      query,
      paste0('AS "', spec[["system_column"]], '"'),
      fixed = TRUE
    )
    expect_match(
      query,
      paste0('AS "', spec[["code_column"]], '"'),
      fixed = TRUE
    )
  }
})

test_that("shared medication resolution combines roots from all source resources", {
  plan <- data.table::data.table(
    BASE_TABLE_NAME = c(
      "medicationrequest",
      "medicationstatement",
      "medicationadministration"
    ),
    RULE_TABLE_NAME = c(
      "medicationrequest",
      "medicationstatement",
      "medicationadministration"
    ),
    RULE_SOURCE = NA_character_,
    SOURCE_RELATION = c(
      "v_medicationrequest",
      "v_medicationstatement",
      "v_medicationadministration"
    ),
    SNAPSHOT_RELATION_TYPE = "all"
  )
  rules <- data.table::rbindlist(lapply(
    seq_len(nrow(SNAPSHOT_MEDICATION_REFERENCE_SPECS)),
    function(row_index) {
      spec <- SNAPSHOT_MEDICATION_REFERENCE_SPECS[row_index, ]
      data.table::data.table(
        TABLE_OR_RESOURCE = spec[["table_name"]],
        SOURCE = NA_character_,
        COLUMN_NAME = c(
          spec[["reference_column"]],
          spec[["system_column"]],
          spec[["code_column"]]
        ),
        PSEUDONYMIZATION_RULE = "keep"
      )
    }
  ))
  testthat::local_mocked_bindings(
    snapshotRelationFields = function(connection, name, schema = NULL) {
      spec <- getMedicationReferenceSpec(sub("^v_", "", name))
      c("row_id", spec[["reference_column"]])
    }
  )

  queries <- getSnapshotMedicationRootQueries(
    DBI::ANSI(),
    plan,
    rules,
    relation_type = "all",
    source_schema = NULL
  )

  expect_length(queries, 3L)
  expect_true(all(vapply(
    plan$SOURCE_RELATION,
    function(relation_name) any(grepl(relation_name, queries, fixed = TRUE)),
    logical(1)
  )))
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
  expect_match(query, SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN, fixed = TRUE)
})

test_that("version-key preparation follows the technical row-ID convention", {
  statements <- character()
  testthat::local_mocked_bindings(
    snapshotRelationFields = function(connection, name, schema = NULL) {
      c("patient_id", "pat_id", "pat_meta_lastupdated")
    }
  )
  testthat::local_mocked_bindings(
    dbExecute = function(connection, statement) {
      statements <<- c(statements, statement)
      2L
    },
    .package = "DBI"
  )
  plan <- data.table::data.table(
    BASE_TABLE_NAME = c("patient", "patient"),
    SOURCE_RELATION = c("v_patient", "v_patient_last_version"),
    SNAPSHOT_RELATION_TYPE = c("old_versions", "last_version")
  )

  key_tables <- prepareSnapshotVersionKeyTables(
    DBI::ANSI(),
    plan,
    source_schema = "db2dataprocessor_out"
  )

  expect_named(key_tables, "patient")
  expect_match(statements[1L], "SELECT DISTINCT", fixed = TRUE)
  expect_match(statements[1L], 'snapshot_last_version."patient_id" AS "row_id"', fixed = TRUE)
  expect_match(statements[1L], 'FROM "db2dataprocessor_out"."v_patient_last_version"', fixed = TRUE)
  expect_match(statements[2L], "CREATE INDEX", fixed = TRUE)
  expect_match(statements[3L], "ANALYZE", fixed = TRUE)
})

test_that("old-version source excludes prepared last-version keys", {
  testthat::local_mocked_bindings(
    snapshotRelationFields = function(connection, name, schema = NULL) {
      c("patient_id", "pat_id", "pat_meta_lastupdated", "pat_name")
    }
  )
  plan_row <- data.table::data.table(
    SOURCE_RELATION = "v_patient",
    BASE_TABLE_NAME = "patient",
    SNAPSHOT_RELATION_TYPE = "old_versions"
  )

  source <- getSnapshotPartitionSource(
    DBI::ANSI(),
    plan_row,
    source_schema = "db2dataprocessor_out",
    source_view_prefix = "v_",
    version_key_tables = list(patient = "snapshot_patient_keys")
  )

  expect_equal(source$fields, c("patient_id", "pat_id", "pat_meta_lastupdated", "pat_name"))
  expect_match(source$relation, "WHERE NOT EXISTS", fixed = TRUE)
  expect_match(
    source$relation,
    'snapshot_partition_source."patient_id" = snapshot_version_keys."row_id"',
    fixed = TRUE
  )
})

test_that("version partitioning needs no per-table registry", {
  expect_equal(snapshotTechnicalRowIdColumn("patient"), "patient_id")
  expect_equal(snapshotTechnicalRowIdColumn("new_resource"), "new_resource_id")
})

test_that("version partitioning rejects sources without technical row ID", {
  testthat::local_mocked_bindings(
    snapshotRelationFields = function(connection, name, schema = NULL) {
      c("pat_id", "pat_meta_lastupdated")
    }
  )
  plan <- data.table::data.table(
    BASE_TABLE_NAME = c("patient", "patient"),
    SOURCE_RELATION = c("v_patient", "v_patient_last_version"),
    SNAPSHOT_RELATION_TYPE = c("old_versions", "last_version")
  )

  expect_error(
    prepareSnapshotVersionKeyTables(DBI::ANSI(), plan, source_schema = "db2dataprocessor_out"),
    "lacks conventional technical row ID: patient_id",
    fixed = TRUE
  )
})

test_that("last-version source projects the normal view schema", {
  testthat::local_mocked_bindings(
    snapshotRelationFields = function(connection, name, schema = NULL) {
      if (name == "v_patient_last_version") {
        return(c("pat_id", "pat_name", "id", "last_version_date"))
      }
      c("pat_id", "pat_name")
    }
  )
  plan_row <- data.table::data.table(
    SOURCE_RELATION = "v_patient_last_version",
    BASE_TABLE_NAME = "patient",
    SNAPSHOT_RELATION_TYPE = "last_version"
  )

  source <- getSnapshotPartitionSource(
    DBI::ANSI(),
    plan_row,
    source_schema = "db2dataprocessor_out",
    source_view_prefix = "v_",
    version_key_tables = list(patient = "snapshot_patient_keys")
  )

  expect_equal(source$fields, c("pat_id", "pat_name"))
  expect_match(source$relation, '"pat_id"', fixed = TRUE)
  expect_match(source$relation, '"pat_name"', fixed = TRUE)
  expect_false(grepl('"id"', source$relation, fixed = TRUE))
  expect_false(grepl('"last_version_date"', source$relation, fixed = TRUE))
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

test_that("streaming case enrichment keeps lookup columns until review", {
  context <- newSnapshotStreamingContext(NULL)
  fall <- data.table::data.table(
    fall_aufn_dat = as.Date("2026-07-22"),
    fall_gewicht_aktuell = 80,
    fall_gewicht_aktl_einheit = "kg",
    fall_groesse = 2,
    fall_groesse_einheit = "m"
  )
  fall[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]] <- as.Date("1986-07-22")
  fall[[SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN]] <- "patient-1"

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
  expect_equal(
    result[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]],
    as.Date("1986-07-22")
  )
  expect_equal(result[[SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN]], "patient-1")
})

test_that("streaming enrichment calculates medication analysis BMI", {
  context <- newSnapshotStreamingContext(NULL)
  medication_analysis <- data.table::data.table(
    meda_gewicht_aktuell = 80,
    meda_gewicht_aktl_einheit = "kg",
    meda_groesse = 2,
    meda_groesse_einheit = "m",
    meda_bmi = NA_real_
  )

  result <- enrichSnapshotStreamingChunk(
    medication_analysis,
    "medikationsanalyse_fe",
    context,
    described_columns = names(medication_analysis)
  )

  expect_equal(result$meda_bmi, 20)
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
  expect_true(SNAPSHOT_STREAMING_BIRTHDATE_COLUMN %in% names(result))
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

test_that("snapshot enrichments preserve typed columns for empty partitions", {
  observation <- data.table::data.table(
    obs_code_system = character(),
    obs_code_code = character(),
    obs_valuequantity_value = numeric(),
    obs_valuequantity_code = character(),
    obs_valuequantity_unit = character()
  )
  mapping <- data.table::data.table(
    LOINC = "1234-5",
    LOINC_PRIMARY = "1234-5",
    UNIT = "mg",
    CONVERSION_FACTOR = NA_real_,
    CONVERSION_UNIT = NA_character_
  )

  enriched_observation <- enrichObservationWithLoincMapping(observation, mapping)
  enriched_fall <- enrichSnapshotFallChunk(data.table::data.table())
  enriched_encounter <- enrichSnapshotEncounterChunk(data.table::data.table())
  enriched_medication_analysis <- enrichSnapshotMedicationAnalysisChunk(data.table::data.table())
  enriched_medication <- enrichSnapshotStreamingChunk(
    data.table::data.table(),
    "medicationrequest",
    newSnapshotStreamingContext(NULL),
    described_columns = c("medreq_medication_system", "medreq_medication_code")
  )

  expect_equal(nrow(enriched_observation), 0L)
  expect_type(enriched_observation$analysis_loinc_code, "character")
  expect_type(enriched_observation$analysis_unit, "character")
  expect_type(enriched_observation$analysis_value, "double")
  expect_type(enriched_observation$analysis_value_status, "character")
  expect_type(enriched_fall$fall_age_at_admission, "integer")
  expect_type(enriched_fall$fall_bmi, "double")
  expect_type(enriched_encounter$enc_age_at_admission, "integer")
  expect_type(enriched_medication_analysis$meda_bmi, "double")
  expect_true(all(vapply(enriched_medication, is.character, logical(1))))
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
    described_columns = c(names(observation), "analysis_loinc_code")
  )

  expect_false("analysis_loinc_code" %in% names(without_target))
  expect_true(is.na(with_missing_sources$analysis_loinc_code))
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
    enrichment_columns = "analysis_loinc_code",
    source_columns = names(observation)
  )

  expect_equal(result$analysis_loinc_code, "1234-5")
  expect_false("analysis_value" %in% names(result))
  expect_false("analysis_unit" %in% names(result))
  expect_false("analysis_value_status" %in% names(result))
})

test_that("observation enrichment converts value groups without changing row order", {
  observation <- data.table::data.table(
    obs_id = c("first", "second", "third"),
    obs_code_system = "http://loinc.org",
    obs_code_code = c("mass", "amount", "mass"),
    obs_valuequantity_value = c(2, 3, 4),
    obs_valuequantity_code = c("mg", "mmol/L", "mg"),
    obs_valuequantity_unit = c("mg", "mmol/L", "mg")
  )
  mapping <- data.table::data.table(
    LOINC = c("mass", "amount"),
    LOINC_PRIMARY = c("mass", "amount"),
    UNIT = c("g", "umol/L"),
    CONVERSION_FACTOR = NA_real_,
    CONVERSION_UNIT = NA_character_
  )

  result <- enrichObservationWithLoincMapping(observation, mapping)

  expect_equal(result$obs_id, observation$obs_id)
  expect_equal(result$analysis_value, c(0.002, 3000, 0.004))
  expect_equal(result$analysis_unit, c("g", "umol/L", "g"))
  expect_equal(result$analysis_loinc_code, c("mass", "amount", "mass"))
  expect_equal(result$analysis_value_status, rep("converted", 3))
  expect_false(SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN %in% names(result))
})

test_that("observation enrichment converts grouped values through a mapping unit", {
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = "1975-2",
    obs_valuequantity_value = c(1, 2, NA_real_),
    obs_valuequantity_code = "mg/dL",
    obs_valuequantity_unit = "mg/dL"
  )
  mapping <- data.table::data.table(
    LOINC = "1975-2",
    LOINC_PRIMARY = "14631-6",
    UNIT = "umol/L",
    CONVERSION_FACTOR = 17.104,
    CONVERSION_UNIT = "mg/dL"
  )

  result <- enrichObservationWithLoincMapping(observation, mapping)

  expect_equal(result$analysis_value, c(17.104, 34.208, NA_real_))
  expect_equal(result$analysis_loinc_code, rep("14631-6", 3))
  expect_equal(result$analysis_value_status, c("converted", "converted", "missing_value"))
  expect_false(SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN %in% names(result))
})

test_that("observation enrichment aggregates incompatible units without warnings", {
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = rep("1975-2", 3),
    obs_valuequantity_value = c(1, 2, 3),
    obs_valuequantity_code = "mg",
    obs_valuequantity_unit = "milligram"
  )
  mapping <- data.table::data.table(
    LOINC = "1975-2",
    LOINC_PRIMARY = "14631-6",
    UNIT = "umol/L",
    CONVERSION_FACTOR = 17.104,
    CONVERSION_UNIT = "mg/dL"
  )

  output <- utils::capture.output(result <- enrichObservationWithLoincMapping(observation, mapping))
  review <- getLoincUnitConversionReview(result, "observation")
  context <- newLoincUnitConversionReview()
  expect_message(
    recordLoincUnitConversionReview(context, review),
    'LOINC 1975-2; verwendete Einheit "mg"',
    fixed = TRUE
  )
  expect_silent(recordLoincUnitConversionReview(context, review))
  last_version_review <- data.table::copy(review)
  last_version_review[["TABLE_NAME"]] <- "observation_last_version"
  expect_silent(recordLoincUnitConversionReview(context, last_version_review))
  combined_review <- finalizeLoincUnitConversionReview(context)
  stripped <- stripSnapshotStreamingReviewColumns(data.table::copy(result))

  expect_length(output, 0)
  expect_equal(result$analysis_value, observation$obs_valuequantity_value)
  expect_equal(result$analysis_unit, rep("mg", 3))
  expect_equal(result$analysis_loinc_code, rep("14631-6", 3))
  expect_equal(result$analysis_value_status, rep("source_conversion_failed", 3))
  expect_equal(review$LOINC_CODE, "1975-2")
  expect_equal(review$SOURCE_UNIT_CODE, "mg")
  expect_equal(review$SOURCE_UNIT_DISPLAY, "milligram")
  expect_equal(review$USED_SOURCE_UNIT, "mg")
  expect_equal(review$MAPPING_CONVERSION_UNIT, "mg/dL")
  expect_equal(review$TARGET_UNIT, "umol/L")
  expect_equal(review$AFFECTED_ROWS, 3)
  expect_equal(nrow(combined_review), 2)
  expect_equal(sum(combined_review$AFFECTED_ROWS), 9)
  expect_false(SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN %in% names(stripped))
  expect_false(SNAPSHOT_LOINC_MAPPING_UNIT_COLUMN %in% names(stripped))
  expect_false(SNAPSHOT_LOINC_TARGET_UNIT_COLUMN %in% names(stripped))
})

test_that("observation enrichment uses source values when no mapping exists", {
  observation <- data.table::data.table(
    obs_code_system = c("http://loinc.org", "http://loinc.org"),
    obs_code_code = c("unmapped", "missing"),
    obs_valuequantity_value = c(7, NA_real_),
    obs_valuequantity_code = c("mg/L", NA_character_),
    obs_valuequantity_unit = c("mg/L", NA_character_)
  )
  mapping <- data.table::data.table(
    LOINC = character(),
    LOINC_PRIMARY = character(),
    UNIT = character(),
    CONVERSION_FACTOR = numeric(),
    CONVERSION_UNIT = character()
  )

  result <- enrichObservationWithLoincMapping(observation, mapping)

  expect_equal(result$analysis_value, c(7, NA_real_))
  expect_equal(result$analysis_unit, c("mg/L", NA_character_))
  expect_equal(result$analysis_loinc_code, c("unmapped", "missing"))
  expect_equal(result$analysis_value_status, c("source_no_mapping", "missing_value"))
})

test_that("observation enrichment marks values already in the reference unit", {
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = "same",
    obs_valuequantity_value = 7,
    obs_valuequantity_code = "mg/L",
    obs_valuequantity_unit = "mg/L"
  )
  mapping <- data.table::data.table(
    LOINC = "same",
    LOINC_PRIMARY = "primary",
    UNIT = "mg/L",
    CONVERSION_FACTOR = NA_real_,
    CONVERSION_UNIT = NA_character_
  )

  result <- enrichObservationWithLoincMapping(observation, mapping)

  expect_equal(result$analysis_value, 7)
  expect_equal(result$analysis_unit, "mg/L")
  expect_equal(result$analysis_loinc_code, "primary")
  expect_equal(result$analysis_value_status, "already_reference_unit")
})

test_that("observation enrichment falls back when the mapping target unit is missing", {
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = "mapped-without-unit",
    obs_valuequantity_value = 7,
    obs_valuequantity_code = "mg/L",
    obs_valuequantity_unit = "mg/L"
  )
  mapping <- data.table::data.table(
    LOINC = "mapped-without-unit",
    LOINC_PRIMARY = "primary",
    UNIT = NA_character_,
    CONVERSION_FACTOR = NA_real_,
    CONVERSION_UNIT = NA_character_
  )

  result <- enrichObservationWithLoincMapping(observation, mapping)
  review <- getLoincUnitConversionReview(result, "observation")

  expect_equal(result$analysis_loinc_code, "primary")
  expect_equal(result$analysis_unit, "mg/L")
  expect_equal(result$analysis_value, 7)
  expect_equal(result$analysis_value_status, "source_mapping_missing_unit")
  expect_equal(review$TARGET_UNIT, NA_character_)
  expect_equal(review$AFFECTED_ROWS, 1)
})

test_that("observation enrichment distinguishes missing source units", {
  observation <- data.table::data.table(
    obs_code_system = "http://loinc.org",
    obs_code_code = c("mapped", "unmapped"),
    obs_valuequantity_value = c(7, 8),
    obs_valuequantity_code = NA_character_,
    obs_valuequantity_unit = NA_character_
  )
  mapping <- data.table::data.table(
    LOINC = "mapped",
    LOINC_PRIMARY = "primary",
    UNIT = "mg/L",
    CONVERSION_FACTOR = NA_real_,
    CONVERSION_UNIT = NA_character_
  )

  result <- enrichObservationWithLoincMapping(observation, mapping)

  expect_equal(result$analysis_loinc_code, c("primary", "unmapped"))
  expect_equal(result$analysis_unit, c(NA_character_, NA_character_))
  expect_equal(result$analysis_value, c(7, 8))
  expect_equal(
    result$analysis_value_status,
    c("source_missing_unit", "source_no_mapping_missing_unit")
  )
})

test_that("medication enrichment only creates described targets", {
  context <- newSnapshotStreamingContext(NULL)
  medication_request <- data.table::data.table(medreq_medicationreference_ref = "Medication/med-1")

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
  expect_equal(result$summary$ISSUE_TYPE, "no_reachable_code")
  expect_equal(nrow(result$unmatched_reference_examples), 1L)
  expect_equal(result$unmatched_reference_examples$MEDICATION_ID, "missing")
})

test_that("streaming medication review expands multiple graph issues once", {
  spec <- getMedicationReferenceSpec("medicationrequest")
  chunk <- data.table::data.table(
    medreq_medicationreference_ref = c(
      "Medication/mixture",
      "Medication/mixture"
    ),
    medreq_medication_system = c("http://atc", "http://snomed"),
    medreq_medication_code = c("A01", "C01")
  )
  chunk[[SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN]] <- c(
    paste(
      "missing_medication\tmissing-a",
      "missing_medication\tmissing-b",
      sep = "\n"
    ),
    NA_character_
  )

  report <- getUnmatchedMedicationReferencesFromEnrichedTable(
    chunk,
    "medicationrequest",
    spec
  )

  expect_equal(nrow(report), 2L)
  expect_equal(report$RELATED_MEDICATION_ID, c("missing-a", "missing-b"))
  expect_equal(report$N, c(1L, 1L))
})

test_that("streaming review columns are removed before pseudonymization", {
  fetched <- FALSE
  captured <- new.env(parent = emptyenv())
  captured$reviewed_issue <- NULL
  pseudonymized_names <- NULL
  written_names <- NULL
  chunk <- data.table::data.table(value = 1L)
  chunk[[SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN]] <-
    "missing_medication\tmissing"

  processSnapshotChunkStream(
    fetch_chunk = function(chunk_size) {
      fetched <<- TRUE
      chunk
    },
    has_completed = function() fetched,
    enrich_chunk = identity,
    pseudonymize_chunk = function(chunk, chunk_number) {
      pseudonymized_names <<- names(chunk)
      list(
        table = chunk,
        summary = data.table::data.table(
          INPUT_ROWS = nrow(chunk),
          OUTPUT_ROWS = nrow(chunk),
          OUTPUT_COLUMNS = ncol(chunk)
        )
      )
    },
    write_chunk = function(output, first_chunk) {
      written_names <<- names(output)
    },
    review_chunk = function(chunk) {
      captured$reviewed_issue <- paste(
        chunk[[SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN]],
        collapse = "\n"
      )
      emptyMedicationReferenceReport()
    },
    write_review_chunk = function(review) {
      force(review)
    },
    chunk_size = 1L,
    table_name = "example",
    strip_review_columns = stripSnapshotStreamingReviewColumns
  )

  expect_equal(captured$reviewed_issue, "missing_medication\tmissing")
  expect_equal(pseudonymized_names, "value")
  expect_equal(written_names, "value")
})

test_that("snapshot chunk size must be positive", {
  expect_equal(validateSnapshotChunkSize(NULL), 5000L)
  expect_equal(validateSnapshotChunkSize("25000"), 25000L)
  expect_error(validateSnapshotChunkSize(0), "positive integer")
  expect_error(validateSnapshotChunkSize(NA), "positive integer")
})
