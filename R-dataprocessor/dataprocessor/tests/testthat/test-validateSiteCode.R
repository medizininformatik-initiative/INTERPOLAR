testthat::test_that("loadSiteCodes reads configured site codes", {
  site_codes <- loadSiteCodes()

  testthat::expect_true(all(c("UKB", "UKEr", "UKFr", "UKGi", "UKSH") %in% site_codes))
  testthat::expect_equal(anyDuplicated(site_codes), 0L)
})

testthat::test_that("validateSiteCode accepts a listed site code", {
  testthat::expect_true(validateSiteCode("UKB"))
  testthat::expect_true(validateSiteCode("UKEr"))
})

testthat::test_that("validateSiteCode rejects an unknown site code with path", {
  error <- tryCatch(
    validateSiteCode("UNKNOWN"),
    error = identity
  )

  testthat::expect_s3_class(error, "error")
  testthat::expect_match(
    conditionMessage(error),
    getSiteCodePath(),
    fixed = TRUE
  )
  testthat::expect_match(conditionMessage(error), "UNKNOWN", fixed = TRUE)
})
