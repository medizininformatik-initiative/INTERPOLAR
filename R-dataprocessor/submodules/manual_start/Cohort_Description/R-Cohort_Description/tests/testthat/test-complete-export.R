test_that("case metrics retain missingness, temporal boundaries and distinct codes", {
  cases <- cohortFixture()$cases
  p <- cases[patient_id == "p"]
  expect_equal(p$m67, 1)
  expect_equal(p$m85, 1)
  expect_equal(p$m87, 1)
  expect_true(p$m324)
  expect_false(p$m322)
  expect_true(p$m274)
  expect_true(p$m276)
  expect_false(p$m278)
  expect_true(p$m287)
  expect_equal(p$m339, 2L)
  expect_equal(p$m341, 1L)
  expect_equal(p$m345, 1L)
  expect_true(p$has_qualifying_manual_mrp)
  expect_equal(cases[patient_id == "q"]$m76, 0)
  missing <- cases[patient_id == "missing"]
  expect_true(is.na(missing$m65))
  expect_true(is.na(missing$m76))
  expect_true(is.na(missing$m291))
  expect_equal(missing$m339, 0)
})

test_that("every expanded result cell is mapped and all populations are exported", {
  fixture <- cohortFixture()
  specification <- data.table::fread(cohortAssetPath("cohort_rows.csv"), colClasses = c(mask = "character"))
  cells <- calculateCohortCells(fixture$cases, specification)
  expect_false(anyDuplicated(cells$address) > 0)
  expect_equal(cells[address == "C6"]$value, 3)
  expect_equal(cells[address == "C7"]$value, 3)
  expect_equal(cells[address == "C28"]$value, 1)
  expect_equal(cells[address == "B28"]$value, 1)
  directory <- tempfile("cohort-export-")
  on.exit(unlink(directory, recursive = TRUE))
  manifest <- exportCohortDescription(fixture$cases, fixture$wards, "UTC", "test", directory)
  expect_equal(nrow(manifest), 21L)
  expect_true(all(file.exists(file.path(directory, manifest$file))))
  expect_equal(manifest[phase == "BS"]$cases, c(3L, 3L, 1L, 1L, 0L, 0L, 0L))
  expect_true(all(manifest[phase != "BS"]$cases == 0))
  template <- utils::unzip(cohortAssetPath("cohort_template.xlsx"), list = TRUE)$Name
  original <- tempfile()
  output <- tempfile()
  dir.create(original)
  dir.create(output)
  on.exit(unlink(c(original, output), recursive = TRUE), add = TRUE)
  utils::unzip(cohortAssetPath("cohort_template.xlsx"), exdir = original)
  utils::unzip(file.path(directory, manifest$file[1]), exdir = output)
  expect_equal(
    readBin(file.path(original, "xl/styles.xml"), "raw", 1e7),
    readBin(file.path(output, "xl/styles.xml"), "raw", 1e7)
  )
  document <- xml2::read_xml(file.path(output, "xl/worksheets/sheet2.xml"))
  nodes <- xml2::xml_find_all(document, "//*[local-name()='c']")
  expect_false(any(xml2::xml_text(nodes) == "x"))
  workbook <- xml2::read_xml(file.path(output, "xl/workbook.xml"))
  expect_length(xml2::xml_find_all(workbook, "//*[local-name()='sheet']"), 1L)
  expect_false(any(xml2::xml_text(nodes) %in% c(fixture$cases$patient_id, fixture$cases$case_id)))
  date_cell <- xml2::xml_find_first(document, "//*[local-name()='c'][@r='H9']")
  expect_equal(xml2::xml_text(date_cell), "2025-01-01 00:00:00")
})

test_that("an IP stay must cross midnight in the configured time zone", {
  fixture <- cohortFixture()
  cases <- fixture$cases
  cases[, ip_end := ip_start + 3600]
  expect_equal(nrow(assignCohortPopulations(cases, buildCohortPeriods(fixture$wards), "UTC")), 0L)
  cases[, ip_start := hospital_start + 23 * 3600]
  cases[, ip_end := ip_start + 3600]
  expect_equal(nrow(assignCohortPopulations(cases, buildCohortPeriods(fixture$wards), "UTC")), 3L)
})

test_that("general-labelled laboratory blocks also exclude non-INTERPOLAR codes", {
  cases <- cohortFixture()$cases
  empty <- data.table::data.table(patient_id = character(), start_datetime = as.POSIXct(character()), code = character())
  ops <- data.table::copy(empty)
  ops[, `:=`(proc_code_code = character(), ops_terminal = logical())]
  obs <- data.table::data.table(
    patient_id = "p", start_datetime = cases$hospital_start[1],
    code = "12345-6", relevant = FALSE, unit_ok = TRUE, numeric_ok = TRUE,
    abnormal = FALSE, normal = TRUE, egfr = FALSE, value_reference = 1
  )
  result <- calculateCohortCodeFeatures(cases, empty, empty, obs, ops)
  expect_true(all(is.na(result$m162)))
  expect_true(all(is.na(result$m210)))
  expect_true(all(is.na(result$m198)))
})

test_that("date SD is based on elapsed time across daylight-saving changes", {
  fixture <- cohortFixture()
  cases <- fixture$cases[1:2]
  cases[, hospital_start := as.POSIXct(c("2025-03-29 12:00:00", "2025-03-30 12:00:00"), tz = "Europe/Berlin")]
  specification <- data.table::fread(cohortAssetPath("cohort_rows.csv"), colClasses = c(mask = "character"))[metric_row == 9]
  result <- calculateCohortCells(cases, specification)
  expect_equal(result[address == "L9"]$value, stats::sd(c(0, 23 / 24)), tolerance = 1e-10)
})

test_that("workbooks can be written to relative output paths and overwritten", {
  template <- normalizePath(cohortAssetPath("cohort_template.xlsx"), mustWork = TRUE)
  directory <- tempfile("cohort-relative-")
  dir.create(directory)
  previous <- setwd(directory)
  on.exit(
    {
      setwd(previous)
      unlink(directory, recursive = TRUE)
    },
    add = TRUE
  )
  destination <- file.path("outputGlobal", "dataprocessor", "reports", "cohort_description", "example.xlsx")
  for (header in c("first run", "second run")) {
    result <- writeCohortWorkbook(
      template,
      data.table::data.table(address = character(), value = numeric()),
      c(header, "period", "ward"), destination, "UTC"
    )
    expect_identical(result, destination)
    expect_true(file.exists(destination))
    expect_identical(getwd(), normalizePath(directory))
    xml <- utils::unzip(destination, files = "xl/worksheets/sheet2.xml", exdir = tempfile("read-xlsx-"))
    document <- xml2::read_xml(xml)
    expect_equal(xml2::xml_text(xml2::xml_find_first(document, "//*[local-name()='c'][@r='B1']")), header)
    unlink(dirname(dirname(dirname(xml))), recursive = TRUE)
  }
})

test_that("bounded feature batches preserve metric values and case order", {
  time <- as.POSIXct("2025-01-01", tz = "UTC")
  patients <- paste0("p", seq_len(260L))
  cases <- data.table::data.table(
    patient_id = c(patients, patients[1]), age = 60,
    hospital_start = time, hospital_end = time + 86400, code_cutoff = time + 3600
  )
  events <- data.table::data.table(patient_id = patients[seq(1L, 260L, 2L)], start_datetime = time)
  diagnoses <- data.table::copy(events)[, `:=`(code = "E11.90", icd_terminal = TRUE)]
  medications <- data.table::copy(events)[, code := "A10BA02"]
  observations <- data.table::copy(events)[, `:=`(
    code = "62238-1", relevant = TRUE, unit_ok = TRUE, numeric_ok = TRUE,
    abnormal = TRUE, normal = FALSE, egfr = TRUE, value_reference = 80, compatible_unit = TRUE
  )]
  procedures <- data.table::copy(events)[, `:=`(proc_code_code = "8-853", ops_terminal = TRUE)]
  expect_equal(
    calculateCohortCodeFeatures(cases, diagnoses, medications, observations, procedures),
    calculateCohortCodeFeatureBatch(cases, diagnoses, medications, observations, procedures)
  )
})
