############################
### TEST validateWardPhases ###
############################

testthat::test_that("validateWardPhases returns TRUE for valid definitions", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'",
        "phase_b_start = '2026-01-21 10:00:00'"
      )
    ),
    list(
      PHASES_WARD_2 = c(
        "ward_name = 'Station 2'",
        "phase_a_start = '2026-01-11'",
        "phase_b_start = '2026-01-12'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateWardPhases(ward_phases, timezone = "UTC")))
})

testthat::test_that("validateWardPhases accepts missing phase_b_start", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateWardPhases(ward_phases, timezone = "UTC")))
})

testthat::test_that("validateWardPhases accepts date without time and date with minutes only", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11'",
        "phase_b_start = '2026-01-11 10:00'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateWardPhases(ward_phases, timezone = "UTC")))
})

testthat::test_that("validateWardPhases accepts equal phase_a_start and phase_b_start", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'",
        "phase_b_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateWardPhases(ward_phases, timezone = "UTC")))
})

testthat::test_that("validateWardPhases accepts whitespace variations", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "   ward_name     =    'Station 1'   ",
        " phase_a_start   =   '2026-01-11 10:00' ",
        " phase_b_start = '2026-01-21 10:00:00'   "
      )
    )
  )

  testthat::expect_true(isTRUE(validateWardPhases(ward_phases, timezone = "UTC")))
})

testthat::test_that("validateWardPhases accepts plus in quoted values", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1+'",
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateWardPhases(ward_phases, timezone = "UTC")))
})

testthat::test_that("validateWardPhases rejects invalid keys", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_c_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "Invalid subcondition"
  )
})

testthat::test_that("validateWardPhases rejects plus outside quoted values", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00' + phase_b_start = '2026-01-21 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "Character '\\+' is not allowed"
  )
})

testthat::test_that("validateWardPhases rejects missing ward_name", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "must contain exactly one ward_name, but contains 0"
  )
})

testthat::test_that("validateWardPhases rejects multiple ward_name definitions", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "ward_name = 'Station 1b'",
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "must contain exactly one ward_name, but contains 2"
  )
})

testthat::test_that("validateWardPhases rejects empty ward_name", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = ''",
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "ward_name must not be empty"
  )
})

testthat::test_that("validateWardPhases rejects duplicate ward names across definitions", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    ),
    list(
      PHASES_WARD_2 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-02-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "Duplicate ward_name found: 'Station 1'"
  )
})

testthat::test_that("validateWardPhases rejects missing phase_a_start", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "must contain exactly one phase_a_start, but contains 0"
  )
})

testthat::test_that("validateWardPhases rejects multiple phase_a_start definitions", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'",
        "phase_a_start = '2026-01-12 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "must contain exactly one phase_a_start, but contains 2"
  )
})

testthat::test_that("validateWardPhases rejects multiple phase_b_start definitions", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'",
        "phase_b_start = '2026-01-12 10:00:00'",
        "phase_b_start = '2026-01-13 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "must contain at most one phase_b_start, but contains 2"
  )
})

testthat::test_that("validateWardPhases rejects invalid phase_a_start values", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026/01/11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "phase_a_start is not a valid date/time"
  )
})

testthat::test_that("validateWardPhases rejects invalid phase_b_start values", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'",
        "phase_b_start = '2026/01/12 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "phase_b_start is not a valid date/time"
  )
})

testthat::test_that("validateWardPhases rejects phase_b_start earlier than phase_a_start", {
  ward_phases <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'",
        "phase_b_start = '2026-01-10 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    validateWardPhases(ward_phases, timezone = "UTC"),
    "phase_b_start must not be earlier than phase_a_start"
  )
})
