testthat::test_that("buildFallvignetteSourceQuery selects the mapped source fields", {
  mapping <- getTestFallvignetteMapping()
  query <- buildFallvignetteSourceQuery(mapping)

  testthat::expect_match(
    query,
    "patient_fe.pat_geschlecht AS pat_geschlecht",
    fixed = TRUE
  )
  testthat::expect_match(
    query,
    "meda_fe.meda_gewicht_aktuell AS meda_gewicht_aktuell",
    fixed = TRUE
  )
  testthat::expect_match(
    query,
    "ret_fe.ret_kurzbeschr AS ret_kurzbeschr",
    fixed = TRUE
  )
  testthat::expect_match(
    query,
    "fall_fe.fall_age_at_admission AS fall_age_at_admission",
    fixed = TRUE
  )
  testthat::expect_false(grepl("EXTRACT(YEAR FROM age", query, fixed = TRUE))
  testthat::expect_match(
    query,
    paste(
      "ret_fe.ret_gewiss_grund_abl_klin2_neg___1 AS",
      "ret_gewiss_grund_abl_klin2_neg"
    ),
    fixed = TRUE
  )
})

testthat::test_that("buildFallvignetteSourceQuery restricts the eligible population", {
  mapping <- getTestFallvignetteMapping()
  query <- buildFallvignetteSourceQuery(mapping)

  testthat::expect_match(
    query,
    paste(
      "ret_fe.ret_gewiss_grund1_abl_01 =",
      "'MRP sachlich richtig, aber klinisch nicht relevant'"
    ),
    fixed = TRUE
  )
  testthat::expect_match(
    query,
    paste(
      "ret_fe.ret_gewiss_grund2_abl_01 =",
      "'MRP sachlich richtig, aber klinisch nicht relevant'"
    ),
    fixed = TRUE
  )
  testthat::expect_match(
    query,
    "v_mrpdokumentation_validierung_fe_last_version",
    fixed = TRUE
  )
  testthat::expect_match(
    query,
    "mrp_fe.mrp_meda_id = ret_fe.ret_meda_id",
    fixed = TRUE
  )
  testthat::expect_false(grepl("v_consent_last_version", query, fixed = TRUE))
  testthat::expect_match(
    query,
    "ret_fe.ret_id NOT LIKE '%-TEST-%'",
    fixed = TRUE
  )
})

testthat::test_that("getFallvignetteSourceData executes a read-only query", {
  mapping <- getTestFallvignetteMapping()
  seen_query <- NULL
  seen_lock_id <- NULL
  query_fun <- function(query, lock_id = NULL) {
    seen_query <<- query
    seen_lock_id <<- lock_id
    data.frame(source_record_id = "patient-1")
  }

  result <- getFallvignetteSourceData(
    mapping,
    lock_id = "fallvignette-test",
    query_fun = query_fun
  )

  testthat::expect_s3_class(result, "data.table")
  testthat::expect_equal(result$source_record_id, "patient-1")
  testthat::expect_match(
    seen_query,
    "FROM v_retrolektive_mrpbewertung_fe_last_version",
    fixed = TRUE
  )
  testthat::expect_equal(seen_lock_id, "fallvignette-test")
})

testthat::test_that("buildFallvignetteSourceQuery rejects unsupported sources", {
  mapping <- getTestFallvignetteMapping()
  mapping$source_field[mapping$target_field == "wp8_fv_alter"] <- "fall_unknown"

  testthat::expect_error(
    buildFallvignetteSourceQuery(mapping),
    "unsupported source fields: fall_unknown"
  )
})
