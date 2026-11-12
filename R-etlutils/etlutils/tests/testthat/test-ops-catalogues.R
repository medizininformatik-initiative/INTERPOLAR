test_that("bundled OPS catalogues contain complete official annual expansions", {
  catalogue <- loadOPSCatalogues()
  expect_equal(as.integer(table(catalogue$year)), c(33337L, 33786L, 34213L, 34753L))
  expect_false(anyDuplicated(catalogue[c("year", "code")]) > 0L)
  expect_false(anyNA(catalogue))
  selected <- loadOPSCatalogues(c("2026", "2023", "2023"))
  expect_equal(sort(unique(selected$year)), c(2023L, 2026L))
  expect_error(loadOPSCatalogues(2022), "available")
  expect_error(loadOPSCatalogues(2023.5), "available")
  expect_error(loadOPSCatalogues(NA), "available")
  expect_error(loadOPSCatalogues(integer()), "available")
})

test_that("terminal status depends on catalogue membership rather than code length", {
  catalogue <- loadOPSCatalogues(2026)
  expect_identical(isTerminalOPS(
    c("8-016", "8-017", "8-017.0", "8-011.3", "8-011.30", "8-015.y", "not-an-ops"),
    2026, catalogue
  ), c(TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, FALSE))
  expect_identical(isTerminalOPS(
    c(NA_character_, "", " ", "8-016"),
    c(2026, 2026, 2026, NA), catalogue
  ), rep(NA, 4))
  expect_identical(isTerminalOPS(character(), integer(), catalogue), logical())
  expect_error(isTerminalOPS("8-016", 2025, catalogue), "not been loaded")
  expect_error(isTerminalOPS("8-016", "2026.0.0", catalogue), "four-digit")
  expect_error(isTerminalOPS(c("8-016", "8-017"), 2023:2025, catalogue), "one year")
})

test_that("year-specific checks do not accept a union of annual codes", {
  catalogue <- loadOPSCatalogues(c(2023, 2026))
  new_codes <- setdiff(catalogue$code[catalogue$year == 2026], catalogue$code[catalogue$year == 2023])
  expect_gt(length(new_codes), 0L)
  expect_identical(isTerminalOPS(rep(new_codes[1], 2), c(2023, 2026), catalogue), c(FALSE, TRUE))
})
