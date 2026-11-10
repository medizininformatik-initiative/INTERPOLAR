testthat::test_that("filtering preserves order, AND/OR matching and removed rows", {
  resources <- data.table::data.table(
    id = c(4L, 2L, 3L, 1L, 5L, 6L),
    location = c("Location/A", "LOCATION/A", "Location/B ~ Location/C", "Location/D", NA, ""),
    type = c("ward", "department", "ward", "ward", "ward", "ward")
  )
  patterns <- list(
    list(location = "^Location/A$", type = "^WARD$"),
    list(location = "Location/C", type = "ward")
  )
  result <- filterResources(resources, patterns, return_removed = TRUE)
  testthat::expect_identical(result$kept_resources$id, c(4L, 3L))
  testthat::expect_identical(result$removed_resources$id, c(2L, 1L, 5L, 6L))
  testthat::expect_identical(names(result$kept_resources), c("id", "location", "type"))
  testthat::expect_identical(names(result$removed_resources), c("id", "location", "type"))
  # Keep the existing by-reference bookkeeping behavior for callers holding aliases.
  testthat::expect_identical(resources$Filter_Column_Keep, c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE))
  testthat::expect_identical(resources$Filter_Column_Keep_Subcondition, rep(FALSE, 6L))
})

testthat::test_that("empty patterns and empty input retain their existing result shapes", {
  resources <- data.table::data.table(id = integer(), value = character())
  for (removed in c(FALSE, TRUE)) {
    testthat::expect_identical(filterResources(resources, list(), removed), resources)
  }
  result <- filterResources(data.table::copy(resources), list(list(value = "x")), TRUE)
  testthat::expect_identical(result, list(kept_resources = resources, removed_resources = resources))
  testthat::expect_identical(
    filterResources(data.table::copy(resources), list(list()), TRUE),
    list(kept_resources = resources, removed_resources = resources)
  )
})

testthat::test_that("short-circuiting skips unreachable expressions", {
  resources <- data.table::data.table(value = c("A", "b"))
  testthat::expect_identical(
    filterResources(data.table::copy(resources), list(list(value = ".*"), list(value = "[")))$value,
    resources$value
  )
  testthat::expect_equal(
    nrow(filterResources(data.table::copy(resources), list(list(value = "never", missing = "[")))),
    0L
  )
  testthat::expect_error(filterResources(data.table::copy(resources), list(list(missing = "x"))))
  testthat::expect_error(filterResources(data.table::copy(resources), list(list())))
})

testthat::test_that("repeated column conditions and Perl patterns remain supported", {
  resources <- data.table::data.table(id = 1:4, value = c("AB", "AC", "XB", NA))
  patterns <- list(stats::setNames(list("^A", "B$"), c("value", "value")))
  testthat::expect_identical(filterResources(data.table::copy(resources), patterns)$id, 1L)
  testthat::expect_identical(
    filterResources(data.table::copy(resources), list(list(value = "(?<=A)B")))$id,
    1L
  )
})
