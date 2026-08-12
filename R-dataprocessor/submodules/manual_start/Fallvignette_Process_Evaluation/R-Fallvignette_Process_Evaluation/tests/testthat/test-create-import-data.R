getTestWardDefinitions <- function() {
  list(
    PHASES_WARD_1 = c(
      "ward_name = 'Station 1'",
      "phase_a_start = '2026-01-11'",
      "department = '0100 Innere Medizin; 0300 Kardiologie'",
      "ward_type = 'internistic'"
    ),
    PHASES_WARD_2 = c(
      "ward_name = 'Station 2'",
      "phase_a_start = '2026-01-11'",
      "department = '1500 Allgemeine Chirurgie'",
      "ward_type = 'surgical'"
    )
  )
}

getTestFallvignetteSourceData <- function(mapping) {
  mapping_source_fields <- mapping[["source_field"]]
  source_fields <- unique(mapping_source_fields[
    !is.na(mapping_source_fields) &
      nzchar(mapping_source_fields) &
      !mapping[["target_field"]] %in% c(
        "record_id",
        "wp8_standort_id",
        "wp8_mrp_fachbereich"
      )
  ])
  source_data <- data.table::as.data.table(stats::setNames(
    lapply(source_fields, function(source_field) {
      rep(NA_character_, 2L)
    }),
    source_fields
  ))
  data.table::set(
    source_data,
    j = "fall_station",
    value = c("Station 1", "Station 2")
  )
  data.table::set(
    source_data,
    j = "fall_age_at_admission",
    value = c("72", "65")
  )
  data.table::set(
    source_data,
    j = "pat_geschlecht",
    value = c("female", "male")
  )
  data.table::set(
    source_data,
    j = "meda_gewicht_aktuell",
    value = c("63.5", "81")
  )
  data.table::set(
    source_data,
    j = "meda_schwanger_mo",
    value = c("0", NA_character_)
  )
  data.table::set(
    source_data,
    j = "wp8_fv_diagnosen",
    value = c("Diagnosen A", "Diagnosen B")
  )
  data.table::set(
    source_data,
    j = "ret_kurzbeschr",
    value = c("MRP A", "MRP B")
  )
  data.table::set(
    source_data,
    j = "ret_gewissheit1",
    value = c("Bewertung A", "Bewertung B")
  )
  data.table::set(
    source_data,
    j = "ret_gewiss_grund1_abl_01",
    value = c("3", "3")
  )
  data.table::set(
    source_data,
    j = "ret_gewiss_grund2_abl_01",
    value = c("1", "3")
  )
  data.table::set(
    source_data,
    j = "ret_notiz1",
    value = c("Erstbewertung A", "Erstbewertung B")
  )
  data.table::set(
    source_data,
    j = "ret_notiz2",
    value = c("Zweitbewertung A", "Zweitbewertung B")
  )
  source_data[]
}

testthat::test_that("generateFallvignetteRecordIds creates UUID version 4 IDs", {
  record_ids <- generateFallvignetteRecordIds(10L)

  testthat::expect_length(record_ids, 10L)
  testthat::expect_equal(anyDuplicated(record_ids), 0L)
  testthat::expect_true(all(grepl(
    "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    record_ids
  )))
})

testthat::test_that("createFallvignetteImportData creates evaluation rows", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)
  record_id_fun <- function(row_count) {
    paste0("site-independent-id-", seq_len(row_count))
  }

  result <- createFallvignetteImportData(
    source_data,
    mapping,
    getTestWardDefinitions(),
    site_code = "UKB",
    record_id_fun = record_id_fun
  )

  testthat::expect_identical(names(result), unique(mapping$target_field))
  testthat::expect_equal(
    result$record_id,
    paste0("site-independent-id-", 1:3)
  )
  testthat::expect_equal(
    result$wp8_standort_id,
    rep(
      "f64bca78aea5629a60d34fba5940dfe3a544e71a54955cad2ac1f2c3ebc3bb66",
      3L
    )
  )
  testthat::expect_equal(
    result$wp8_mrp_fachbereich,
    c(
      "0100 Innere Medizin; 0300 Kardiologie",
      "1500 Allgemeine Chirurgie",
      "1500 Allgemeine Chirurgie"
    )
  )
  testthat::expect_equal(result$wp8_fv_alter, c("72", "65", "65"))
  testthat::expect_equal(
    result$wp8_fv_geschlecht,
    c("female", "male", "male")
  )
  testthat::expect_equal(result$wp8_fv_gewicht, c("63.5", "81", "81"))
  testthat::expect_equal(
    result$wp8_fv_schwanger_mo,
    c("0", NA_character_, NA_character_)
  )
  testthat::expect_equal(
    result$wp8_fv_diagnosen,
    c("Diagnosen A", "Diagnosen B", "Diagnosen B")
  )
  testthat::expect_equal(
    result$wp8_ret_kurzbeschr,
    c("MRP A", "MRP B", "MRP B")
  )
  testthat::expect_equal(
    result$wp8_ret_gewissheit,
    c("Bewertung A", "Bewertung B", "Bewertung B")
  )
  testthat::expect_equal(
    result$wp8_ret_notiz,
    c("Erstbewertung A", "Erstbewertung B", "Zweitbewertung B")
  )
  testthat::expect_equal(
    result$wp8_ret_gewiss_grund_abl_01,
    rep("3", 3L)
  )
})

testthat::test_that("createFallvignetteImportData rejects unknown wards", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)
  source_data <- source_data[
    1L,
    names(source_data),
    with = FALSE
  ]
  data.table::set(
    source_data,
    j = "fall_station",
    value = "Station unbekannt"
  )

  testthat::expect_error(
    createFallvignetteImportData(
      source_data,
      mapping,
      getTestWardDefinitions(),
      site_code = "UKB"
    ),
    "No department configured for fall_station: Station unbekannt"
  )
})

testthat::test_that("createFallvignetteImportData validates generated IDs", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)

  testthat::expect_error(
    createFallvignetteImportData(
      source_data,
      mapping,
      getTestWardDefinitions(),
      site_code = "UKB",
      record_id_fun = function(row_count) rep("duplicate", row_count)
    ),
    "one unique, non-empty character ID per row"
  )
})

testthat::test_that("createFallvignetteImportData validates the site code", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)

  testthat::expect_error(
    createFallvignetteImportData(
      source_data,
      mapping,
      getTestWardDefinitions(),
      site_code = " "
    ),
    "site_code must be one non-empty string"
  )
})

testthat::test_that("hashFallvignetteSiteCode uses pseudonymization SHA-256", {
  testthat::expect_identical(
    hashFallvignetteSiteCode("UKB"),
    "f64bca78aea5629a60d34fba5940dfe3a544e71a54955cad2ac1f2c3ebc3bb66"
  )
})
