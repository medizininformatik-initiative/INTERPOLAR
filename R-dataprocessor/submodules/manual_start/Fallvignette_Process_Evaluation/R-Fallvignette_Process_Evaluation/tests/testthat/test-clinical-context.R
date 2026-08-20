# Tests for diagnoses, medications and observations in the clinical context.

testthat::test_that("addFallvignetteDiagnoses applies case and WP7 rules", {
  source_data <- data.table::data.table(
    pat_id = "patient-1",
    fall_fhir_enc_id = "current-case",
    meda_dat = as.POSIXct("2026-02-01 12:00:00", tz = "UTC")
  )
  conditions <- data.table::data.table(
    con_patient_ref = rep("Patient/patient-1", 9L),
    con_encounter_calculated_ref = c(
      "Encounter/old-case",
      "Encounter/current-case",
      "Encounter/current-case",
      "Encounter/current-case",
      "Encounter/old-case",
      "Encounter/current-case",
      "Encounter/old-case",
      "Encounter/old-case",
      "Encounter/current-case"
    ),
    con_code_code = c(
      "A01",
      "X01",
      "D01",
      "D01",
      "C03",
      "Z99",
      "B02",
      "C03",
      "F01"
    ),
    con_code_system = rep(
      "http://fhir.de/CodeSystem/bfarm/icd-10-gm",
      9L
    ),
    con_code_display = c(
      "Alpha historisch",
      NA_character_,
      "Doppelte Diagnose",
      "Doppelte Diagnose",
      "Gamma gueltig",
      "Zeta aktuell",
      "Nicht aufnehmen",
      "Abgelaufen",
      "Zukuenftig"
    ),
    start_datetime = as.POSIXct(c(
      "2020-01-01 08:00:00",
      NA,
      "2026-01-29 10:00:00",
      "2026-01-30 10:00:00",
      "2026-01-15 09:00:00",
      "2026-01-31 11:00:00",
      "2026-01-20 10:00:00",
      "2025-12-01 10:00:00",
      "2026-02-02 10:00:00"
    ), tz = "UTC")
  )
  conditions <- data.table::rbindlist(list(
    conditions,
    conditions[3L, names(conditions), with = FALSE]
  ))
  diagnosis_rules <- data.table::data.table(
    ICD = c("A01", "C03"),
    ICD_VALIDITY_DAYS = c("unbegrenzt", "30")
  )

  result <- addFallvignetteDiagnoses(
    source_data,
    conditions,
    diagnosis_rules
  )

  testthat::expect_equal(
    result$wp8_fv_diagnosen,
    paste(
      c(
        "Alpha historisch (ICD: A01) [2020-01-01 08:00:00]",
        "Doppelte Diagnose (ICD: D01) [2026-01-29 10:00:00]",
        "Doppelte Diagnose (ICD: D01) [2026-01-30 10:00:00]",
        "Gamma gueltig (ICD: C03) [2026-01-15 09:00:00]",
        "Zeta aktuell (ICD: Z99) [2026-01-31 11:00:00]",
        "NA (ICD: X01)"
      ),
      collapse = "\n"
    )
  )
  testthat::expect_false(any(grepl(
    "Nicht aufnehmen|Abgelaufen|Zukuenftig",
    result$wp8_fv_diagnosen
  )))
})

testthat::test_that("addFallvignetteDiagnoses does not modify source data", {
  source_data <- data.table::data.table(
    pat_id = "patient-1",
    fall_fhir_enc_id = "current-case",
    meda_dat = as.POSIXct("2026-02-01 12:00:00", tz = "UTC")
  )
  original_source_data <- data.table::copy(source_data)
  conditions <- data.table::data.table(
    con_patient_ref = character(),
    con_encounter_calculated_ref = character(),
    con_code_code = character(),
    con_code_system = character(),
    con_code_display = character(),
    start_datetime = as.POSIXct(character(), tz = "UTC")
  )
  diagnosis_rules <- data.table::data.table(
    ICD = character(),
    ICD_VALIDITY_DAYS = character()
  )

  result <- addFallvignetteDiagnoses(
    source_data,
    conditions,
    diagnosis_rules
  )

  testthat::expect_identical(source_data, original_source_data)
  testthat::expect_true(is.na(result$wp8_fv_diagnosen))
})

testthat::test_that("addFallvignetteMedications selects active ATC and PZN", {
  source_data <- data.table::data.table(
    pat_id = "patient-1",
    fall_fhir_enc_id = "case-1",
    fall_aufn_dat = as.POSIXct("2026-01-01 00:00:00", tz = "UTC"),
    fall_ent_dat = as.POSIXct("2026-02-10 00:00:00", tz = "UTC"),
    meda_dat = as.POSIXct("2026-02-01 12:00:00", tz = "UTC")
  )
  medication_requests <- data.table::data.table(
    medreq_id = paste0("request-", 1:5),
    medreq_patient_ref = rep("Patient/patient-1", 5L),
    medreq_encounter_calculated_ref = c(
      "Encounter/case-1",
      "Encounter/case-1",
      "Encounter/case-1",
      "Encounter/case-1",
      "Encounter/other-case"
    ),
    medreq_medicationcodeableconcept_system = c(
      NA,
      "http://fhir.de/CodeSystem/ifa/pzn",
      NA,
      NA,
      NA
    ),
    medreq_medicationcodeableconcept_code = c(
      NA, "12345678", NA, NA, NA
    ),
    medreq_medicationcodeableconcept_display = c(
      NA, "Zubereitung", NA, NA, NA
    ),
    medreq_authoredon = as.POSIXct(c(
      "2026-01-10 08:00:00",
      "2026-01-20 08:00:00",
      "2026-01-20 08:00:00",
      "2026-01-20 08:00:00",
      "2025-12-20 08:00:00"
    ), tz = "UTC"),
    start_datetime = as.POSIXct(c(
      "2026-01-11 10:00:00",
      "2026-01-21 10:00:00",
      "2026-01-21 10:00:00",
      "2026-02-02 10:00:00",
      "2025-12-21 10:00:00"
    ), tz = "UTC"),
    end_datetime = as.POSIXct(c(
      NA,
      NA,
      "2026-01-25 10:00:00",
      NA,
      NA
    ), tz = "UTC"),
    atc_code = c("B01AB01", NA, "A01AA01", "C01AA01", "D01AA01"),
    atc_display = c(NA, NA, "Abgesetzt", "Zukuenftig", "Anderer Fall")
  )
  medication_requests <- data.table::rbindlist(list(
    medication_requests,
    medication_requests[
      1L, names(medication_requests), with = FALSE
    ]
  ))

  active_atc_fun <- function(
    medication_requests,
    enc_period_start,
    enc_period_end,
    meda_datetime
  ) {
    requests <- data.table::copy(medication_requests)
    data.table::set(
      requests,
      i = which(is.na(requests[["end_datetime"]])),
      j = "end_datetime",
      value = enc_period_end
    )
    active <- requests[["medreq_authoredon"]] >= enc_period_start &
      requests[["start_datetime"]] >= enc_period_start &
      requests[["medreq_authoredon"]] <= meda_datetime &
      requests[["end_datetime"]] >= meda_datetime
    data.table::data.table(
      fhir_id = requests[["medreq_id"]][active],
      atc_code = requests[["atc_code"]][active],
      start_datetime = requests[["start_datetime"]][active],
      end_datetime = requests[["end_datetime"]][active]
    )
  }

  result <- addFallvignetteMedications(
    source_data,
    medication_requests,
    active_atc_fun = active_atc_fun
  )

  testthat::expect_equal(
    result$wp8_fv_medikation,
    paste(
      c(
        "Zubereitung (PZN: 12345678) [2026-01-21 10:00:00]",
        "NA (ATC: B01AB01) [2026-01-11 10:00:00]"
      ),
      collapse = "\n"
    )
  )
})

testthat::test_that("addFallvignetteLaboratoryValues applies WP7 and time window", {
  source_data <- data.table::data.table(
    pat_id = "patient-1",
    meda_dat = as.POSIXct("2026-02-08 12:00:00", tz = "UTC")
  )
  observations <- data.table::data.table(
    obs_patient_ref = rep("Patient/patient-1", 5L),
    obs_code_system = c(
      "http://loinc.org",
      "http://loinc.org",
      "http://loinc.org",
      "http://loinc.org",
      "other-system"
    ),
    obs_code_code = c("2160-0", "718-7", "9999-9", "2160-0", "2160-0"),
    obs_code_display = c(
      NA_character_,
      "Haemoglobin",
      "Irrelevant",
      "Too old",
      "Wrong system"
    ),
    obs_valuequantity_value = c(1.2, 12.5, 3, 1.0, 1.1),
    obs_valuequantity_code = c("mg/dL", "g/dL", "x", "mg/dL", "mg/dL"),
    obs_valuequantity_unit = c("mg/dL", "g/dL", "x", "mg/dL", "mg/dL"),
    start_datetime = as.POSIXct(c(
      "2026-02-07 09:00:00",
      "2026-02-06 08:00:00",
      "2026-02-07 08:00:00",
      "2026-01-31 11:59:59",
      "2026-02-07 10:00:00"
    ), tz = "UTC")
  )
  observations <- data.table::rbindlist(list(
    observations,
    observations[1L, names(observations), with = FALSE]
  ))
  loinc_mapping <- data.table::data.table(
    LOINC = c("2160-0", "718-7"),
    LOINC_PRIMARY = c("2160-0", "718-7"),
    GERMAN_NAME_LOINC_PRIMARY = c("Kreatinin", "Haemoglobin")
  )

  result <- addFallvignetteLaboratoryValues(
    source_data,
    observations,
    loinc_mapping,
    relevant_loinc_codes = c("2160-0", "718-7")
  )

  testthat::expect_equal(
    result$wp8_fv_laborparameter,
    paste(
      c(
        "Haemoglobin (LOINC: 718-7): 12.5 g/dL [2026-02-06 08:00:00]",
        "NA (LOINC: 2160-0): 1.2 mg/dL [2026-02-07 09:00:00]"
      ),
      collapse = "\n"
    )
  )
})

testthat::test_that("addFallvignetteOperationStatus combines Encounter and OPS", {
  source_data <- data.table::data.table(
    pat_id = paste0("patient-", 1:4),
    meda_dat = as.POSIXct(
      rep("2026-02-01 12:00:00", 4L),
      tz = "UTC"
    )
  )
  procedures <- data.table::data.table(
    proc_patient_ref = c(
      "Patient/patient-1",
      "Patient/patient-3",
      "Patient/patient-4"
    ),
    proc_code_system = rep(
      "http://fhir.de/CodeSystem/bfarm/ops",
      3L
    ),
    proc_code_code = c("5-123.4", "8-987.0", "5-123.4"),
    start_datetime = as.POSIXct(c(
      "2026-01-15 10:00:00",
      "2026-01-20 10:00:00",
      "2025-12-20 10:00:00"
    ), tz = "UTC")
  )
  encounters <- data.table::data.table(
    enc_patient_ref = c(
      "Patient/patient-2",
      "Patient/patient-3",
      "Patient/patient-4"
    ),
    enc_type_system = rep(
      "http://fhir.de/CodeSystem/kontaktart-de",
      3L
    ),
    enc_type_code = c("operation", "konsil", "operation"),
    enc_period_start = as.POSIXct(c(
      "2025-12-20 10:00:00",
      "2026-01-20 10:00:00",
      "2026-02-02 10:00:00"
    ), tz = "UTC"),
    enc_period_end = as.POSIXct(c(
      "2026-01-10 10:00:00",
      "2026-01-20 11:00:00",
      "2026-02-02 11:00:00"
    ), tz = "UTC")
  )

  result <- addFallvignetteOperationStatus(
    source_data,
    procedures,
    encounters
  )

  testthat::expect_equal(result$wp8_fv_op, c("1", "1", "0", "0"))
})
