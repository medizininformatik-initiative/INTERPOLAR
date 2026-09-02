testthat::test_that("prepareFallvignetteWp7Definitions combines local rules", {
  mrp_pair_lists <- list(
    Drug_Disease = data.table::data.table(
      ICD = c("I10", NA_character_),
      ICD_VALIDITY_DAYS = c("unbegrenzt", "30"),
      LOINC_PRIMARY_PROXY = c("2160-0", NA_character_)
    ),
    Drug_Niereninsuffizienz = data.table::data.table(
      ICD = "N18.4",
      ICD_VALIDITY_DAYS = "365",
      LOINC_PRIMARY_PROXY = "33914-3"
    ),
    Drug_Drug = data.table::data.table(ATC_PRIMARY = "A01AA01")
  )
  mrp_pair_lists[c("Drug_Disease", "Drug_Niereninsuffizienz")] <- lapply(
    mrp_pair_lists[c("Drug_Disease", "Drug_Niereninsuffizienz")],
    function(processed_content) {
      list(processed_content = processed_content)
    }
  )
  loinc_mapping <- data.table::data.table(
    LOINC = c("2160-0", "33914-3"),
    LOINC_PRIMARY = c("2160-0", "33914-3"),
    GERMAN_NAME_LOINC_PRIMARY = c("Kreatinin", "eGFR")
  )

  result <- prepareFallvignetteWp7Definitions(
    mrp_pair_lists,
    loinc_mapping
  )

  testthat::expect_equal(result$diagnosis_rules$ICD, c("I10", "N18.4"))
  testthat::expect_equal(
    result$relevant_loinc_codes,
    c("2160-0", "33914-3")
  )
  testthat::expect_identical(result$loinc_mapping, loinc_mapping)
})

testthat::test_that("getFallvignetteEncountersFromDB requests KontaktArt", {
  received <- NULL
  resource_fun <- function(...) {
    received <<- list(...)
    data.table::data.table()
  }

  getFallvignetteEncountersFromDB("Patient/patient-1", resource_fun)

  testthat::expect_equal(received$resource_name, "Encounter")
  testthat::expect_equal(
    received$patient_references,
    "Patient/patient-1"
  )
  testthat::expect_null(received$lock_id)
  testthat::expect_true(all(c(
    "enc_type_system",
    "enc_type_code",
    "enc_period_start",
    "enc_period_end"
  ) %in% received$column_names))
})

testthat::test_that("prepareFallvignetteMedicationRequests retains fallback", {
  medication_requests <- data.table::data.table(
    medreq_id = c("atc-request", "pzn-request"),
    medreq_medicationcodeableconcept_system = c(
      "http://fhir.de/CodeSystem/bfarm/atc",
      "http://fhir.de/CodeSystem/ifa/pzn"
    ),
    medreq_medicationcodeableconcept_code = c("A01AA01", "12345678")
  )
  append_atc_fun <- function(medication_requests, medications) {
    result <- data.table::copy(medication_requests)[
      1,
      names(medication_requests),
      with = FALSE
    ]
    data.table::set(result, j = "atc_code", value = "A01AA01")
    data.table::set(result, j = "atc_display", value = "Wirkstoff")
    result
  }

  result <- prepareFallvignetteMedicationRequests(
    medication_requests,
    data.table::data.table(),
    append_atc_fun = append_atc_fun
  )

  testthat::expect_equal(result$medreq_id, c("atc-request", "pzn-request"))
  testthat::expect_equal(result$atc_code, c("A01AA01", NA_character_))
})

testthat::test_that("referenced PZN is added only without an ATC", {
  medication_requests <- data.table::data.table(
    medreq_id = c("atc-request", "pzn-request"),
    med_id = c("med-atc", "med-pzn"),
    medreq_medicationcodeableconcept_system = NA_character_,
    medreq_medicationcodeableconcept_code = NA_character_,
    medreq_medicationcodeableconcept_display = NA_character_
  )
  pzn_medications <- data.table::data.table(
    med_id = "med-pzn",
    med_code_system = "http://fhir.de/CodeSystem/ifa/pzn",
    med_code_code = "12345678",
    med_code_display = "Zubereitung"
  )
  append_atc_fun <- function(medication_requests, medications) {
    result <- data.table::copy(medication_requests)[
      1,
      names(medication_requests),
      with = FALSE
    ]
    data.table::set(result, j = "atc_code", value = "A01AA01")
    data.table::set(result, j = "atc_display", value = "Wirkstoff")
    result
  }

  result <- prepareFallvignetteMedicationRequests(
    medication_requests,
    data.table::data.table(),
    pzn_medications,
    append_atc_fun
  )

  testthat::expect_equal(
    result$medreq_medicationcodeableconcept_code,
    c(NA_character_, "12345678")
  )
  testthat::expect_equal(
    result$medreq_medicationcodeableconcept_display,
    c(NA_character_, "Zubereitung")
  )
})

testthat::test_that("run uses the database context selected before WP8 starts", {
  calls <- character()
  mapping <- getTestFallvignetteMapping()
  mapped_source_fields <- unique(mapping[["source_field"]])
  mapped_source_fields <- mapped_source_fields[
    !is.na(mapped_source_fields) & nzchar(mapped_source_fields)
  ]
  empty_source <- data.table::as.data.table(stats::setNames(
    rep(list(character()), length(mapped_source_fields)),
    mapped_source_fields
  ))
  data.table::set(empty_source, j = "fall_station", value = character())
  load_mrp_fun <- function() {
    calls <<- c(calls, "wp7_mrp")
    list(Drug_Disease = data.table::data.table(
      ICD = "I10",
      ICD_VALIDITY_DAYS = "unbegrenzt",
      LOINC_PRIMARY_PROXY = "2160-0"
    ))
  }
  load_loinc_fun <- function() {
    calls <<- c(calls, "wp7_loinc")
    list(processed_content = data.table::data.table(
      LOINC = "2160-0",
      LOINC_PRIMARY = "2160-0",
      GERMAN_NAME_LOINC_PRIMARY = "Kreatinin"
    ))
  }
  get_source_fun <- function(mapping, lock_id) {
    calls <<- c(calls, "source")
    testthat::expect_null(lock_id)
    empty_source
  }
  write_fun <- function(...) {
    arguments <- list(...)
    calls <<- c(calls, "write")
    testthat::expect_equal(
      arguments[["file_name"]],
      "WP8_Fallvignetten_Import"
    )
    list(csv = "output.csv", xlsx = "output.xlsx")
  }
  write_id_mapping_fun <- function(id_mapping, output_dir, file_name) {
    calls <<- c(calls, "id_mapping")
    testthat::expect_equal(output_dir, "local-output")
    testthat::expect_equal(
      file_name,
      "WP8_Fallvignetten_ID_Mapping"
    )
    "local-output/local-id-mapping.xlsx"
  }

  result <- runFallvignetteProcessEvaluation(
    output_dir = tempdir(),
    id_mapping_output_dir = "local-output",
    site_code = "UKB",
    ward_definitions = list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11'",
        "department = '0100 Innere Medizin'",
        "ward_type = 'internistic'"
      )
    ),
    load_mrp_fun = load_mrp_fun,
    load_loinc_fun = load_loinc_fun,
    get_source_fun = get_source_fun,
    get_resources_fun = function(...) {
      testthat::fail("Resources must not be loaded without source rows.")
    },
    write_fun = write_fun,
    write_id_mapping_fun = write_id_mapping_fun
  )

  testthat::expect_equal(
    calls,
    c("wp7_mrp", "wp7_loinc", "source", "id_mapping", "write")
  )
  testthat::expect_equal(result[["csv"]], "output.csv")
  testthat::expect_equal(
    result[["id_mapping"]],
    "local-output/local-id-mapping.xlsx"
  )
})
