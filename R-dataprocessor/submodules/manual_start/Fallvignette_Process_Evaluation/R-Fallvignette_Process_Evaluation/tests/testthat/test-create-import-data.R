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
    j = "source_record_id",
    value = c("source-1", "source-2")
  )
  data.table::set(
    source_data,
    j = "pat_id",
    value = c("patient-1", "patient-2")
  )
  data.table::set(
    source_data,
    j = "fall_id",
    value = c("fall-1", "fall-2")
  )
  data.table::set(
    source_data,
    j = "meda_id",
    value = c("meda-1", "meda-2")
  )
  data.table::set(
    source_data,
    j = "ret_id",
    value = c("ret-1", "ret-2")
  )
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
    j = "ret_ip_klasse_01",
    value = c("Drug-Drug", "Drug-Disease")
  )
  data.table::set(
    source_data,
    j = "ret_atc1",
    value = c(
      "J05AF06 - Abacavir",
      "C09DA06 - Candesartan und Diuretika"
    )
  )
  data.table::set(
    source_data,
    j = "ret_atc2",
    value = c("A04AA01 - Ondansetron", NA_character_)
  )
  data.table::set(
    source_data,
    j = "ret_gewissheit1",
    value = rep("MRP nicht bestätigt", 2L)
  )
  data.table::set(
    source_data,
    j = "ret_gewissheit2",
    value = rep("MRP nicht bestätigt", 2L)
  )
  data.table::set(
    source_data,
    j = "ret_gewiss_grund1_abl_01",
    value = rep(
      "MRP sachlich richtig, aber klinisch nicht relevant",
      2L
    )
  )
  data.table::set(
    source_data,
    j = "ret_gewiss_grund2_abl_01",
    value = c(
      "MRP sachlich falsch (keine Kontraindikation)",
      "MRP sachlich richtig, aber klinisch nicht relevant"
    )
  )
  data.table::set(
    source_data,
    j = "ret_gewiss_grund_abl_klin1_neg___1",
    value = c("Unchecked", "Checked")
  )
  data.table::set(
    source_data,
    j = "ret_gewiss_grund_abl_klin2_neg___1",
    value = c("Checked", "Unchecked")
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

testthat::test_that("record IDs hash the site-specific running number", {
  result <- generateFallvignetteRecordIdMapping(3L, "UKB")

  testthat::expect_equal(
    result[["local_record_id"]],
    c("UKB0001", "UKB0002", "UKB0003")
  )
  testthat::expect_equal(
    result[["record_id"]],
    unname(vapply(
      result[["local_record_id"]],
      digest::digest,
      character(1),
      algo = "sha256",
      serialize = FALSE
    ))
  )
})

testthat::test_that("createFallvignetteImportData creates evaluation rows", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)
  record_id_mapping_fun <- function(row_count, site_code) {
    data.table::data.table(
      local_record_id = paste0(site_code, sprintf("%04d", seq_len(row_count))),
      record_id = paste0("site-independent-id-", seq_len(row_count))
    )
  }

  result <- createFallvignetteImportData(
    source_data,
    mapping,
    getTestWardDefinitions(),
    site_code = "UKB",
    record_id_mapping_fun = record_id_mapping_fun
  )

  testthat::expect_identical(names(result), unique(mapping$target_field))
  testthat::expect_equal(
    result[["record_id"]],
    paste0("site-independent-id-", 1:3)
  )
  testthat::expect_equal(
    result[["wp8_ret_id"]],
    c("ret-1", "ret-2", "ret-2")
  )
  id_mapping <- attr(result, "fallvignette_id_mapping")
  testthat::expect_equal(
    id_mapping[["local_record_id"]],
    c("UKB0001", "UKB0002", "UKB0003")
  )
  testthat::expect_equal(
    id_mapping[["source_record_id"]],
    c("source-1", "source-2", "source-2")
  )
  testthat::expect_equal(
    id_mapping[["evaluation_index"]],
    c(1L, 1L, 2L)
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
    result$wp8_ret_ip_klasse_01,
    c("1", "2", "2")
  )
  testthat::expect_equal(
    result$wp8_ret_atc1_2026,
    c("J05AF06", "C09DA06", "C09DA06")
  )
  testthat::expect_equal(
    result$wp8_ret_atc2_2026,
    c("A04AA01", NA_character_, NA_character_)
  )
  testthat::expect_equal(
    result$wp8_ret_gewissheit,
    rep("3", 3L)
  )
  testthat::expect_equal(
    result$wp8_ret_notiz,
    c("Erstbewertung A", "Erstbewertung B", "Zweitbewertung B")
  )
  testthat::expect_equal(
    result$wp8_ret_gewiss_grund_abl_01,
    rep("3", 3L)
  )
  testthat::expect_equal(
    result$wp8_ret_gewiss_grund_abl_klin_neg___1,
    c("0", "1", "0")
  )
  testthat::expect_equal(result[["mrp_auswahl_complete"]], rep("0", 3L))
})

testthat::test_that("createFallvignetteImportData rejects invalid checkbox values", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)
  data.table::set(
    source_data,
    i = 1L,
    j = "ret_gewiss_grund_abl_klin1_neg___1",
    value = "invalid"
  )

  testthat::expect_error(
    createFallvignetteImportData(
      source_data,
      mapping,
      getTestWardDefinitions(),
      site_code = "UKB"
    ),
    "must contain only Unchecked, Checked or NA: invalid",
    fixed = TRUE
  )
})

testthat::test_that("createFallvignetteImportData rejects invalid REDCap values", {
  mapping <- getTestFallvignetteMapping()
  source_data <- getTestFallvignetteSourceData(mapping)
  data.table::set(
    source_data,
    i = 1L,
    j = "ret_ip_klasse_01",
    value = "invalid"
  )

  testthat::expect_error(
    createFallvignetteImportData(
      source_data,
      mapping,
      getTestWardDefinitions(),
      site_code = "UKB"
    ),
    "contains invalid MRP classes: invalid",
    fixed = TRUE
  )

  source_data <- getTestFallvignetteSourceData(mapping)
  data.table::set(
    source_data,
    i = 1L,
    j = "ret_atc1",
    value = "not-an-atc"
  )

  testthat::expect_error(
    createFallvignetteImportData(
      source_data,
      mapping,
      getTestWardDefinitions(),
      site_code = "UKB"
    ),
    "contains invalid ATC values: not-an-atc",
    fixed = TRUE
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
      record_id_mapping_fun = function(row_count, site_code) {
        data.table::data.table(
          local_record_id = rep(paste0(site_code, "0001"), row_count),
          record_id = rep("duplicate", row_count)
        )
      }
    ),
    "one unique, non-empty local_record_id"
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
