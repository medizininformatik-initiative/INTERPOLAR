######################
# validateWardPhases #
######################

testthat::test_that("loadFachabteilungsschluessel combines Code and Display", {
  result <- loadFachabteilungsschluessel()

  testthat::expect_length(result, 148L)
  testthat::expect_true("0100 Innere Medizin" %in% result)
  testthat::expect_true("0102 Innere Medizin/Schwerpunkt Geriatrie" %in% result)
})

# Accepts multiple valid definitions
testthat::test_that("validateWardPhases returns TRUE for valid definitions", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "phase_b_start = '2026-01-21 10:00:00'", "phase_b_end = '2026-04-21 10:00:00'", "department = '0100 Innere Medizin'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  assign("PHASES_WARD_2", c("ward_name = 'Station 2'", "phase_a_start = '2026-01-11'", "phase_b_start = '2026-01-12'", "phase_b_end = '2026-04-12'", "department = '1500 Allgemeine Chirurgie'", "ward_type = 'surgical'"), envir = .GlobalEnv)
  on.exit(rm(list = c("PHASES_WARD_1", "PHASES_WARD_2"), envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

# Accepts missing phase_b_start
testthat::test_that("validateWardPhases accepts missing phase_b_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "department = '0100 Innere Medizin'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

# Accepts date-only and minute-only timestamps
testthat::test_that("validateWardPhases accepts date without time and date with minutes only", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "phase_b_start = '2026-01-11 10:00'", "phase_b_end = '2026-04-21'", "department = '2316 Orthopädie und Unfallchirurgie'", "ward_type = 'surgical'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

# Rejects equal phase_a_start and phase_b_start
testthat::test_that("validateWardPhases rejects equal phase_a_start and phase_b_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "phase_b_start = '2026-01-11 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "phase_a_start must be earlier than phase_b_start")
})

# Accepts whitespace variations
testthat::test_that("validateWardPhases accepts whitespace variations", {
  assign("PHASES_WARD_1", c("   ward_name     =    'Station 1'   ", " phase_a_start   =   '2026-01-11 10:00' ", " phase_b_start = '2026-01-21 10:00:00'   ", " phase_b_end = '2026-04-21 10:00:00'   ", " department = '0100 Innere Medizin' ", " ward_type = 'internistic' "), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

# Accepts plus in quoted values
testthat::test_that("validateWardPhases accepts plus in quoted values", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1+'", "phase_a_start = '2026-01-11 10:00:00'", "department = '0100 Innere Medizin'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

testthat::test_that("validateWardPhases accepts regex metacharacters in ward names", {
  assign("PHASES_WARD_1", c("ward_name = 'Station (A) [1].*+'", "phase_a_start = '2026-01-11 10:00:00'", "department = '0100 Innere Medizin'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

# Rejects invalid keys
testthat::test_that("validateWardPhases rejects invalid keys", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_c_start = '2026-01-11 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "Invalid subcondition")
})

# Rejects plus outside quoted values
testthat::test_that("validateWardPhases rejects plus outside quoted values", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00' + phase_b_start = '2026-01-21 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "Character '\\+' is not allowed")
})

# Rejects missing ward_name
testthat::test_that("validateWardPhases rejects missing ward_name", {
  assign("PHASES_WARD_1", c("phase_a_start = '2026-01-11 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain exactly one ward_name")
})

# Rejects multiple ward_name definitions
testthat::test_that("validateWardPhases rejects multiple ward_name definitions", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "ward_name = 'Station 1b'", "phase_a_start = '2026-01-11 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain exactly one ward_name")
})

# Rejects empty ward_name
testthat::test_that("validateWardPhases rejects empty ward_name", {
  assign("PHASES_WARD_1", c("ward_name = ''", "phase_a_start = '2026-01-11 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "ward_name must not be empty")
})

# Rejects duplicate ward names across definitions
testthat::test_that("validateWardPhases rejects duplicate ward names across definitions", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "department = '0100 Innere Medizin'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  assign("PHASES_WARD_2", c("ward_name = 'Station 1'", "phase_a_start = '2026-02-11 10:00:00'", "department = '1500 Allgemeine Chirurgie'", "ward_type = 'surgical'"), envir = .GlobalEnv)
  on.exit(rm(list = c("PHASES_WARD_1", "PHASES_WARD_2"), envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "Duplicate ward_name found: 'Station 1'")
})

# Rejects missing phase_a_start
testthat::test_that("validateWardPhases rejects missing phase_a_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain exactly one phase_a_start")
})

# Rejects multiple phase_a_start definitions
testthat::test_that("validateWardPhases rejects multiple phase_a_start definitions", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "phase_a_start = '2026-01-12 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain exactly one phase_a_start")
})

# Rejects multiple phase_b_start definitions
testthat::test_that("validateWardPhases rejects multiple phase_b_start definitions", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "phase_b_start = '2026-01-12 10:00:00'", "phase_b_start = '2026-01-13 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain at most one phase_b_start")
})

# Rejects invalid phase_a_start values
testthat::test_that("validateWardPhases rejects invalid phase_a_start values", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026/01/11 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "phase_a_start is not a valid timestamp")
})

# Rejects invalid phase_b_start values
testthat::test_that("validateWardPhases rejects invalid phase_b_start values", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "phase_b_start = '2026/01/12 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "phase_b_start is not a valid timestamp")
})

# Rejects phase_b_start earlier than phase_a_start
testthat::test_that("validateWardPhases rejects phase_b_start earlier than phase_a_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11 10:00:00'", "phase_b_start = '2026-01-10 10:00:00'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "phase_a_start must be earlier than phase_b_start")
})

testthat::test_that("validateWardPhases accepts phase_b_end after phase_b_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "phase_b_start = '2026-01-12'", "phase_b_end = '2026-04-21'", "department = '3700 Sonstige Fachabteilung'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

testthat::test_that("validateWardPhases rejects phase_b_end without phase_b_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "phase_b_end = '2026-04-21'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain phase_b_start")
})

testthat::test_that("validateWardPhases rejects invalid phase_b_end", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "phase_b_start = '2026-01-12'", "phase_b_end = 'invalid'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "phase_b_end is not a valid timestamp")
})

testthat::test_that("validateWardPhases rejects phase_b_end at phase_b_start", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "phase_b_start = '2026-01-12'", "phase_b_end = '2026-01-12'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "phase_b_start must be earlier than phase_b_end")
})


testthat::test_that("validateWardPhases rejects missing phase_b_end", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "phase_b_start = '2026-01-12'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain phase_b_end when phase_b_start is set")
})

testthat::test_that("validateWardPhases requires department", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain department with one or more semicolon-separated values")
})

testthat::test_that("validateWardPhases accepts multiple departments", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "department = '0100 Innere Medizin; 3500 Zahn- und Kieferheilkunde, Mund- und Kieferchirurgie'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_true(validateWardPhases(timezone = "UTC"))
})

testthat::test_that("validateWardPhases rejects repeated department parameters", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "department = '0100 Innere Medizin'", "department = '1500 Allgemeine Chirurgie'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain only one department parameter; separate multiple values with semicolons")
})

testthat::test_that("validateWardPhases rejects invalid department", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "department = '010 Innere Medizin'", "ward_type = 'internistic'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  error <- tryCatch(validateWardPhases(timezone = "UTC"), error = identity)

  testthat::expect_s3_class(error, "error")
  testthat::expect_match(
    conditionMessage(error),
    getFachabteilungsschluesselPath(),
    fixed = TRUE
  )
})

testthat::test_that("validateWardPhases requires exactly one ward_type", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "department = '0100 Innere Medizin'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain exactly one ward_type")
})

testthat::test_that("validateWardPhases rejects duplicate ward_type", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "department = '0100 Innere Medizin'", "ward_type = 'internistic'", "ward_type = 'surgical'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must contain exactly one ward_type")
})

testthat::test_that("validateWardPhases rejects invalid ward_type", {
  assign("PHASES_WARD_1", c("ward_name = 'Station 1'", "phase_a_start = '2026-01-11'", "department = '0100 Innere Medizin'", "ward_type = 'internistisch'"), envir = .GlobalEnv)
  on.exit(rm(list = "PHASES_WARD_1", envir = .GlobalEnv), add = TRUE)
  testthat::expect_error(validateWardPhases(timezone = "UTC"), "must be either 'surgical' or 'internistic'")
})
