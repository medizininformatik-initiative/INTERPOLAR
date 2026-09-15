test_that("convertLabUnits keeps existing units package conversions unchanged", {
  expect_equal(etlutils::convertLabUnits(1, "mmol/L", "umol/L"), 1000)
  expect_equal(etlutils::convertLabUnits(1, "mg/dL", "mg/L"), 10)
  expect_equal(etlutils::convertLabUnits(1, "10*9/L", "10^9/L"), 1)
  expect_true(etlutils::isValidUnit("10*9/L"))
  expect_true(etlutils::isValidUnit("10^9/L"))
})

test_that("convertLabUnits converts vectors through a mapping unit", {
  expect_equal(
    etlutils::convertLabUnits(
      c(1, 2, NA_real_),
      "mg/dL",
      "umol/L",
      conversion_factor = 17.104,
      conversion_unit = "mg/dL"
    ),
    c(17.104, 34.208, NA_real_)
  )
})

test_that("convertLabUnits keeps legacy missing and invalid unit behavior", {
  expect_equal(etlutils::convertLabUnits(7, "mg/L", NA), 7)
  expect_equal(etlutils::convertLabUnits(7, "mg/L", ""), 7)
  expect_true(is.na(etlutils::convertLabUnits(7, "foo", "mg/L")))
  expect_equal(etlutils::convertLabUnits(c(7, 8), "foo", "mg/L"), c(NA_real_, NA_real_))
  expect_false(etlutils::isValidUnit("foo"))
})

test_that("convertLabUnits converts simple international unit quotients", {
  expect_equal(etlutils::convertLabUnits(1, "mU/L", "U/L"), 0.001)
  expect_equal(etlutils::convertLabUnits(1, "U/L", "mU/L"), 1000)
  expect_equal(etlutils::convertLabUnits(1, "mU/L", "uU/mL"), 1)
  expect_equal(etlutils::convertLabUnits(1, "m[IU]/L", "u[IU]/mL"), 1)
  expect_equal(etlutils::convertLabUnits(1, "m[iU]/L", "u[iU]/mL"), 1)
  expect_equal(etlutils::convertLabUnits(1, "\u00b5U/mL", "mU/L"), 1)
})

test_that("convertLabUnits keeps the international unit fallback narrow", {
  expect_true(is.na(etlutils::convertLabUnits(1, "mm/U", "m/U")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "mg/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mfoo/L", "foo/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "/L", "mU/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "/M", "mU/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mM/", "mU/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "m/", "mU/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mM", "mU/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "foo", "mU/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "/M")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "mM/")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "m/")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "mM")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mU/L", "foo")))
  expect_equal(etlutils::convertLabUnits(1, "mU/L", NA), 1)
  expect_equal(etlutils::convertLabUnits(1, "mU/L", ""), 1)
})

test_that("isValidUnit accepts units supported by convertLabUnits", {
  expect_true(etlutils::isValidUnit("mU/L"))
  expect_true(etlutils::isValidUnit("U/L"))
  expect_true(etlutils::isValidUnit("uU/mL"))
  expect_true(etlutils::isValidUnit("m[IU]/L"))
  expect_true(etlutils::isValidUnit("m[iU]/L"))
  expect_true(etlutils::isValidUnit("\u00b5U/mL"))
  expect_true(etlutils::isValidUnit("mmol/L"))
  expect_false(etlutils::isValidUnit("foo"))
  expect_false(etlutils::isValidUnit("mM/"))
})


test_that("unit caches reuse successful and unsuccessful parses across calls", {
  cache <- new.env(parent = emptyenv())
  values <- c("mg/dL", "U/L", "unsupportedunit", NA_character_, "", "mg/dL")
  expected <- etlutils::isValidUnit(values)
  expect_identical(etlutils::isValidUnit(values, cache), expected)
  expect_length(ls(cache), 3L)
  testthat::local_mocked_bindings(
    parseConvertibleUnitUncached = function(...) stop("Unexpected repeated parsing"),
    .package = "etlutils"
  )
  expect_identical(etlutils::isValidUnit(rev(values), cache), rev(expected))
  expect_equal(etlutils::convertLabUnits(c(1, NA, 3), "mg/dL", "mg/dL", unit_cache = cache), c(1, NA, 3))
  expect_true(is.na(etlutils::convertLabUnits(1, "unsupportedunit", "mg/dL", unit_cache = cache)))
})
