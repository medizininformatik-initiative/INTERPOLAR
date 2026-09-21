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

test_that("UCUM pressure-column families preserve prefixes and inverse conversions", {
  prefixes <- c("", "k", "h", "da", "d", "c", "m", "u", "n")
  factors <- 10^c(0, 3, 2, 1, -1, -2, -3, -6, -9)
  for (i in seq_along(prefixes)) {
    mercury <- paste0(prefixes[i], "m[Hg]")
    water <- paste0(prefixes[i], "m[H2O]")
    expect_equal(etlutils::convertLabUnits(1, mercury, "mmHg"), factors[i] * 1000)
    expect_equal(etlutils::convertLabUnits(factors[i] * 1000, "mmHg", mercury), 1)
    expect_equal(etlutils::convertLabUnits(1, water, "Pa"), factors[i] * 9806.65)
    expect_equal(etlutils::convertLabUnits(factors[i] * 9806.65, "Pa", water), 1)
  }
  expect_equal(etlutils::convertLabUnits(c(0, 17, NA), "mm[Hg]", "mmHg"), c(0, 17, NA))
  expect_true(is.na(etlutils::convertLabUnits(1, "mm[Hg]", "mmol/L")))
  expect_false(etlutils::isValidUnit("mm[HG]"))
  expect_false(etlutils::isValidUnit("mm[Unknown]"))
})

test_that("UCUM annotations and osmole families support the laboratory variants", {
  expect_equal(etlutils::convertLabUnits(c(1, 2, NA), "{INR}", "1"), c(1, 2, NA))
  expect_equal(etlutils::convertLabUnits(50, "%{vol}", "1"), 0.5)
  expect_equal(etlutils::convertLabUnits(1, "mosm/kg", "osm/kg"), 0.001)
  expect_equal(etlutils::convertLabUnits(1, "uosm/mL", "mosm/L"), 1)
  expect_true(is.na(etlutils::convertLabUnits(1, "{INR}", "mg/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "mosm/kg", "mosm/L")))
  expect_false(etlutils::isValidUnit("{{INR}}"))
  expect_false(etlutils::isValidUnit("mysteryosm/L"))
})

test_that("international-unit prefixes and mapping factors preserve numeric magnitudes", {
  expect_equal(etlutils::convertLabUnits(1, "m[iU]/uL", "U/L"), 1000)
  expect_equal(etlutils::convertLabUnits(1, "nU/mL", "uU/L"), 1)
  expect_equal(etlutils::convertLabUnits(1, "k[IU]/dl", "U/L"), 10000)
  expect_equal(etlutils::convertLabUnits(c(60, 120, NA), "U/L", "ukat/L", 1 / 60, "U/L"), c(1, 2, NA))
  expect_equal(etlutils::convertLabUnits(60, "mU/mL", "ukat/L", 1 / 60, "U/L"), 1)
  expect_equal(etlutils::convertLabUnits(1, "ukat/L", "U/L", 60, "ukat/L"), 60)
  expect_true(is.na(etlutils::convertLabUnits(1, "U/L", "ukat/L")))
  expect_true(is.na(etlutils::convertLabUnits(1, "U/L", "ukat/L", 1 / 60, "mg/L")))
})


test_that("explicit mapping input uses the same UCUM parser", {
  # Synthetic mapping: this tests the declared factor, not a clinical relationship.
  expect_equal(etlutils::convertLabUnits(c(1, 2, NA), "mmHg", "mg/L", 2, "mm[Hg]"), c(2, 4, NA))
  expect_equal(etlutils::convertLabUnits(1, "mmHg", "mg/L", 2, "cm[Hg]"), 0.2)
  expect_true(is.na(etlutils::convertLabUnits(1, "mmHg", "mg/L", 2, "mmol/L")))
})
