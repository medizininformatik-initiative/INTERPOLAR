test_that("binary summaries preserve missing values and use Wilson intervals", {
  result <- summariseCohortValues(c(TRUE, FALSE, NA), letters[1:3], 1260L)
  expect_equal(result$missing_information, 1)
  expect_equal(result$N, 2)
  expect_equal(result$n, 1)
  expect_equal(result$proportion, 0.5)
  expect_equal(result$ci_low, 0.09453121, tolerance = 1e-7)
  expect_equal(result$ci_high, 0.90546879, tolerance = 1e-7)
  expect_true(is.na(summariseCohortValues(logical(), character(), 1260L)$proportion))
})

test_that("continuous summaries use type 7 quartiles and sample SD", {
  result <- summariseCohortValues(c(1, 2, 3, 4, NA), letters[1:5], 1260L)
  expect_equal(c(result$q1, result$median, result$q3), c(1.75, 2.5, 3.25))
  expect_equal(result$sd, stats::sd(1:4))
  expect_equal(result$N, 4)
  expect_equal(result$missing_information, 1)
})

test_that("patient bootstrap is reproducible and preserves caller RNG state", {
  set.seed(17)
  before <- .Random.seed
  a <- summariseCohortValues(c(TRUE, TRUE, FALSE), c("p", "p", "q"), 1260L)
  expect_identical(.Random.seed, before)
  b <- summariseCohortValues(c(FALSE, TRUE, TRUE), c("q", "p", "p"), 1260L)
  expect_equal(a, b)
  expect_equal(c(a$ci_low, a$ci_high), c(0, 1))
})
