source(testthat::test_path("../../../submodules/00_Submodules_Shared_Functions/Study_Phases.R"))

testthat::test_that("Phase B activity is evaluated per ward", {
  assign(
    "PHASES_WARD_1",
    c(
      "ward_name = 'Ended ward'",
      "phase_a_start = '2026-01-01'",
      "phase_b_start = '2026-02-01'",
      "phase_b_end = '2026-03-01'"
    ),
    envir = .GlobalEnv
  )
  assign(
    "PHASES_WARD_2",
    c(
      "ward_name = 'Active ward'",
      "phase_a_start = '2026-01-01'",
      "phase_b_start = '2026-02-01'"
    ),
    envir = .GlobalEnv
  )
  on.exit(
    rm(list = c("PHASES_WARD_1", "PHASES_WARD_2"), envir = .GlobalEnv),
    add = TRUE
  )

  timestamp <- etlutils::parseTimestamp("2026-04-01")
  testthat::expect_false(isPhaseBActiveForWard("Ended ward", timestamp))
  testthat::expect_true(isPhaseBActiveForWard("Active ward", timestamp))

  ended_ward_rows <- data.frame(
    fall_studienphase = "NoPhaseActive",
    fall_station = "Ended ward"
  )
  active_ward_rows <- data.frame(
    fall_studienphase = "PhaseB",
    fall_station = "Active ward"
  )
  testthat::expect_false(isMRPCalculationActiveForFallFeRows(ended_ward_rows, timestamp))
  testthat::expect_true(isMRPCalculationActiveForFallFeRows(active_ward_rows, timestamp))
  testthat::expect_true(isMRPCalculationActiveForFallFeRows(
    rbind(ended_ward_rows, active_ward_rows),
    timestamp
  ))
})

testthat::test_that("PhaseBTest rows remain eligible", {
  fall_fe_rows <- data.frame(
    fall_studienphase = "PhaseBTest",
    fall_station = "Unconfigured test ward"
  )
  testthat::expect_true(isMRPCalculationActiveForFallFeRows(fall_fe_rows))
})
