testthat::test_that("getFallvignetteMappingPath selects the newest dated workbook", {
  mapping_dir <- tempfile("fallvignette-mapping-")
  dir.create(mapping_dir)
  on.exit(unlink(mapping_dir, recursive = TRUE), add = TRUE)

  testthat::expect_error(
    getFallvignetteMappingPath(mapping_dir),
    "No WP8MRP_Liste_Daten_Mapping<YYYYMMDD>.xlsx found"
  )
  file.create(file.path(
    mapping_dir,
    c(
      "WP8MRP_Liste_Daten_Mapping20260722.xlsx",
      "WP8MRP_Liste_Daten_Mapping20260819.xlsx",
      "unrelated.xlsx"
    )
  ))

  testthat::expect_equal(
    basename(getFallvignetteMappingPath(mapping_dir)),
    "WP8MRP_Liste_Daten_Mapping20260819.xlsx"
  )
})

testthat::test_that("loadFallvignetteMapping reads the WP8 mapping", {
  mapping <- getTestFallvignetteMapping()

  testthat::expect_s3_class(mapping, "data.table")
  testthat::expect_true(all(c(
    "record_id",
    "wp8_ret_id",
    "wp8_standort_id",
    "wp8_mrp_fachbereich",
    "wp8_ret_gewissheit",
    "wp8_ret_gewiss_grund_abl_01",
    "mrp_auswahl_complete"
  ) %in% mapping[["target_field"]]))
  testthat::expect_equal(
    mapping[["source_field"]][mapping[["target_field"]] == "wp8_ret_id"],
    "ret_id"
  )
  testthat::expect_false(any(grepl(
    "^wp8_ret_massn_(am|orga)___",
    mapping[["target_field"]]
  )))
  testthat::expect_equal(
    mapping[["fixed_value"]][
      mapping[["target_field"]] == "mrp_auswahl_complete"
    ],
    "0"
  )
  testthat::expect_equal(
    mapping$source_field[mapping$target_field == "wp8_ret_notiz"],
    c("ret_notiz1", "ret_notiz2")
  )
  testthat::expect_equal(
    mapping[["source_field"]][
      mapping[["target_field"]] == "wp8_ret_gewissheit"
    ],
    c("ret_gewissheit1", "ret_gewissheit2")
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
    j = "wp8_standort_id",
    value = "UKB"
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

testthat::test_that("writeFallvignetteImportFiles validates the site code", {
  mapping <- getTestFallvignetteMapping()
  columns <- unique(mapping$target_field)
  fallvignettes <- data.table::as.data.table(
    stats::setNames(as.list(rep("", length(columns))), columns)
  )
  data.table::set(fallvignettes, j = "record_id", value = "record-1")

  testthat::expect_error(
    writeFallvignetteImportFiles(fallvignettes, tempdir(), mapping = mapping),
    "non-empty wp8_standort_id"
  )
})

testthat::test_that("writeFallvignetteIdMappingFile writes local crosswalk", {
  id_mapping <- data.table::data.table(
    record_id = digest::digest(
      "UKB0001",
      algo = "sha256",
      serialize = FALSE
    ),
    local_record_id = "UKB0001",
    site_code = "UKB",
    evaluation_index = 1L,
    source_record_id = "source-1",
    fall_id = "fall-1",
    meda_id = "meda-1",
    ret_id = "ret-1"
  )

  path <- writeFallvignetteIdMappingFile(
    id_mapping,
    tempdir(),
    file_name = "fallvignette-id-mapping-test"
  )
  result <- etlutils::readExcelFileAsTableList(path)[["ID_Mapping"]]

  testthat::expect_true(file.exists(path))
  testthat::expect_equal(result[["record_id"]], id_mapping[["record_id"]])
  testthat::expect_equal(result[["local_record_id"]], "UKB0001")
  testthat::expect_equal(result[["ret_id"]], "ret-1")
})
