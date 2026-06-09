test_that("parallelNormalizeCoreNumber returns an integer core count", {
  expect_identical(parallelNormalizeCoreNumber(3.7, max_cores = 0), 2L)
  expect_identical(parallelNormalizeCoreNumber(3.7, max_cores = 2), 2L)
})

test_that("parallelNormalizeCoreNumber reserves one core when MAX_CORES is unlimited", {
  expect_identical(parallelNormalizeCoreNumber(8, max_cores = 0), 7L)
  expect_identical(parallelNormalizeCoreNumber(1, max_cores = 0), 1L)
})

test_that("parallelNormalizeCoreNumber defaults max_cores to unlimited", {
  expect_identical(parallelNormalizeCoreNumber(8), 7L)
})

test_that("parallelNormalizeCoreNumber respects positive MAX_CORES limits", {
  expect_identical(parallelNormalizeCoreNumber(8, max_cores = 4), 4L)
  expect_identical(parallelNormalizeCoreNumber(2, max_cores = 4), 2L)
  expect_identical(parallelNormalizeCoreNumber(8, max_cores = 0.7), 7L)
})

test_that("parallelNormalizeCoreNumber falls back to one core for invalid values", {
  expect_identical(parallelNormalizeCoreNumber(NA, max_cores = 0), 1L)
  expect_identical(parallelNormalizeCoreNumber(8, max_cores = NA), 7L)
})
