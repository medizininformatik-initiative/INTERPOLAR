source(testthat::test_path("../../../submodules/00_Submodules_Shared_Functions/Study_Phases.R"))

testthat::test_that("phase_b_end does not stop Phase B behavior", {
  assign(
    "PHASES_WARD_1",
    c(
      "ward_name = 'Station 1'",
      "phase_a_start = '2026-01-01'",
      "phase_b_start = '2026-02-01'",
      "phase_b_end = '2026-03-01'"
    ),
    envir = .GlobalEnv
  )
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)

  testthat::expect_identical(
    getStudyPhase("Station 1", etlutils::parseTimestamp("2026-01-15")),
    "PhaseA"
  )
  testthat::expect_identical(
    getStudyPhase("Station 1", etlutils::parseTimestamp("2026-02-01")),
    "PhaseB"
  )
  testthat::expect_identical(
    getStudyPhase("Station 1", etlutils::parseTimestamp("2026-04-01")),
    "PhaseB"
  )
  testthat::expect_true(isPhaseBActive(etlutils::parseTimestamp("2026-04-01")))
})
