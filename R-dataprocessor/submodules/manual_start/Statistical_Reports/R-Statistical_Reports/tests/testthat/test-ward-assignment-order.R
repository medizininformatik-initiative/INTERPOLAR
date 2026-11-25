test_that("SQL assignment loading preserves all six active reporting summaries", {
  raw_assignments <- tibble::tibble(
    ward_name = c("B", "A", "B", "C", "A", "B", NA_character_, "A"),
    patient_id = c("p1", "p1", "p1", "p1", "p2", "p2", "p3", "p4"),
    encounter_id = c("e1", "e1", "e1", "e2", "e3", "e4", "e5", "e6")
  )
  encounters <- tibble::tibble(
    enc_id = paste0("e", 1:6),
    pat_id = c("p1", "p1", "p2", "p2", "p3", "p4"),
    main_enc_id = c("m1", "m1", "m2", "m2", "m3", "m4"),
    enc_period_start = as.POSIXct("2026-01-01", tz = "UTC") + c(0, 86400, 0, 0, 0, 0),
    enc_type_code_Kontaktebene = c(rep("versorgungsstellenkontakt", 5), "einrichtungskontakt"),
    curated_enc_period_end = as.POSIXct("2026-01-10", tz = "UTC"),
    enc_period_end = curated_enc_period_end,
    main_enc_period_start = as.POSIXct("2026-01-01", tz = "UTC"),
    enc_identifier_value = enc_id,
    record_id = pat_id,
    fall_id_cis = main_enc_id,
    age_at_hospitalization = 50,
    enc_status = "finished",
    processing_exclusion_reason = NA_character_
  )
  frontend <- tibble::tibble(
    pat_id = c("p1", "p1", "p1", "p2", "p2", "p3", "p4"),
    fall_fhir_main_enc_id = c("m1", "m1", "m1", "m2", "m2", "m3", "m4"),
    fall_station = c("A", "B", "C", "A", "B", "A", "A"),
    fall_aufn_dat = as.POSIXct("2026-01-01", tz = "UTC")
  )
  # Eight independent copies keep regular groups above the privacy threshold.
  expandFixture <- function(data, id_columns) {
    dplyr::bind_rows(lapply(seq_len(8L), function(i) {
      data |>
        dplyr::mutate(dplyr::across(dplyr::all_of(id_columns), ~ paste0(i, "-", .x)))
    }))
  }
  raw_assignments <- expandFixture(raw_assignments, c("patient_id", "encounter_id"))
  old_assignments <- raw_assignments |>
    dplyr::distinct() |>
    dplyr::arrange(patient_id, encounter_id)
  encounters <- expandFixture(encounters, c("enc_id", "pat_id", "main_enc_id"))
  frontend <- expandFixture(frontend, c("pat_id", "fall_fhir_main_enc_id")) |>
    dplyr::mutate(
      fall_ent_dat = as.POSIXct("2026-01-10", tz = "UTC"),
      patient_complete = "Complete", fall_complete = "Complete",
      actual_fall_studienphase = "PhaseB",
      processing_exclusion_reason = NA_character_,
      meda_id = paste0(pat_id, "-1"), medikationsanalyse_complete = "Complete",
      meda_mrp_detekt = "Ja", mrp_id = paste0(pat_id, "-mrp"),
      mrpdokumentation_validierung_complete = "Complete",
      mrp_pigrund___21 = "Checked", mrp_ip_klasse_01 = "Drug-Drug",
      mrp_dokup_hand_emp_akz = "Intervention vorgeschlagen und umgesetzt",
      ret_id = paste0(pat_id, "-ret"), retrolektive_mrpbewertung_complete = "Complete",
      ret_ip_klasse_01 = "Drug-Disease", ret_gewissheit1 = "MRP nicht bestätigt",
      ret_gewiss_grund1_abl = NA_character_, ret_gewiss_grund1_abl_01 = NA_character_,
      ret_gewiss_grund_abl_klin1_neg___1 = "Unchecked",
      MDAT_wissenschaftlich_nutzen = TRUE
    ) |>
    dplyr::filter(fall_station != "C" | pat_id %in% paste0(1:3, "-p1")) |>
    dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
      pat_id == "1-p2", "fixture|main_encounter|data_issues", processing_exclusion_reason
    ))
  # A second MedA must be removed only by the first-stay/first-MedA variant.
  frontend <- dplyr::bind_rows(frontend, frontend |>
    dplyr::mutate(meda_id = paste0(pat_id, "-2")))
  testthat::local_mocked_bindings(getWardStartsAndEnds = function() {
    data.frame(
      ward_name = c("A", "B", "C"),
      ward_start = as.Date("2025-12-01"), ward_end = as.Date("2026-03-01")
    )
  })
  canonical <- function(data) {
    data |>
      dplyr::ungroup() |>
      dplyr::arrange(dplyr::across(dplyr::everything()))
  }
  report <- function(assignments) {
    joined <- addWardName(encounters, assignments)
    linked <- addVersorgungsstellenkontaktToFeData(frontend, joined)
    hospital <- prepareFeSummaryData(
      linked, "2025-12-01", "2026-02-01",
      report_period_boundary = "hospital_stay",
      calendar_week_reference_date_col = fall_aufn_dat
    )
    ward <- prepareFeSummaryData(
      linked, "2025-12-01", "2026-02-01",
      report_period_boundary = "ward_stay",
      calendar_week_reference_date_col = first_enc_period_start_per_main_enc
    )
    first <- prepareFeSummaryData(
      linked, "2025-12-01", "2026-02-01",
      report_period_boundary = "ward_stay",
      calendar_week_reference_date_col = first_enc_period_start_per_main_enc,
      first_ward_stay_and_meda_filter = TRUE
    )
    lapply(list(
      linked = linked, hospital = hospital, ward = ward, first = first,
      hospital_summary = calculateFeSummary(hospital),
      hospital_weekly = calculateFeSummary(hospital, c("ward_name", "calendar_week")),
      ward_summary = calculateFeSummary(ward),
      ward_weekly = calculateFeSummary(ward, c("ward_name", "calendar_week")),
      first_summary = calculateFeSummary(first, includeFAS2_1_counting = TRUE),
      first_weekly = calculateFeSummary(first, c("ward_name", "calendar_week"), TRUE)
    ), canonical)
  }
  expected <- report(old_assignments)
  expect_true(any(expected$hospital_summary$patients > 0))
  expect_true(any(expected$hospital$main_enc_any_processing_exclusion_fe))
  expect_true(all(expected$ward$ward_count_less_than_5[expected$ward$ward_name == "C"]))
  expect_equal(expected$ward_summary$patients[expected$ward_summary$ward_name == "C"], 0L)
  expect_false("C" %in% expected$first$ward_name)
  expect_true(any(grepl("-2$", expected$ward$meda_id)))
  expect_false(any(grepl("-2$", expected$first$meda_id)))
  expect_true(any(expected$first_summary$encounters_FAS2_1 > 0))
  # Exercise tie order and different database collation without a site database.
  for (indices in list(seq_len(nrow(old_assignments)), rev(seq_len(nrow(old_assignments))))) {
    sql_assignments <- old_assignments[indices, ]
    testthat::local_mocked_bindings(
      dbGetReadOnlyQuery = function(query, lock_id) {
        expect_identical(query, paste(
          "SELECT DISTINCT ward_name, patient_id, encounter_id FROM v_pids_per_ward",
          "ORDER BY patient_id, encounter_id"
        ))
        sql_assignments
      },
      .package = "etlutils"
    )
    actual <- etlutils::getPidsPerWardData("report regression", "v_pids_per_ward")
    expect_equal(report(actual), expected)
  }
})
