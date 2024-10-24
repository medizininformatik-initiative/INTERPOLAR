##########################
# addParamToFHIRRequest  #
##########################

# Test: Add common parameters (_count and _sort) to FHIR request
test_that("addParamToFHIRRequest correctly adds common parameters", {
  # Temporarily set global variables for the tests
  COUNT_PER_BUNDLE <<- "50"  # Set as a numeric value, not as a string
  SORT <<- "date"

  # Test case 1: No _count or _sort provided, global variables exist
  parameters <- list('_id' = '12345')
  result <- addParamToFHIRRequest(parameters)

  expect_equal(result[["_count"]], "50")
  expect_equal(result[["_sort"]], 'date')
  expect_equal(result[["_id"]], '12345')

  # Test case 2a: _count is provided, _sort is missing
  parameters <- list('_id' = '12345', '_count' = 100)
  result <- addParamToFHIRRequest(parameters)

  # _count should remain as 100
  expect_equal(result[["_count"]], 100)
  expect_equal(result[["_sort"]], 'date')

  # Test case 2b: _count is provided as string, _sort is missing
  parameters <- list('_id' = '12345', '_count' = "100")
  result <- addParamToFHIRRequest(parameters)

  # _count should remain as 100
  expect_equal(result[["_count"]], "100")
  expect_equal(result[["_sort"]], 'date')

  # Test case 3: _sort is provided, _count is missing
  parameters <- list('_id' = '12345', '_sort' = 'name')
  result <- addParamToFHIRRequest(parameters)

  # _sort should remain as 'name'
  expect_equal(result[["_count"]], "50")
  expect_equal(result[["_sort"]], 'name')

  # Test case 4: Both _count and _sort are already provided
  parameters <- list('_id' = '12345', '_count' = 200, '_sort' = 'name')
  result <- addParamToFHIRRequest(parameters)

  # Neither should be overwritten
  expect_equal(result[["_count"]], 200)
  expect_equal(result[["_sort"]], 'name')

  # Test case 5: NULL parameters, global variables exist
  result <- addParamToFHIRRequest(NULL)

  expect_equal(result[["_count"]], "50")  # Expect string comparison
  expect_equal(result[["_sort"]], 'date')

  # Test case 6: Empty parameters, no global variables
  COUNT_PER_BUNDLE <<- NULL
  SORT <<- NULL
  parameters <- list()
  result <- addParamToFHIRRequest(parameters)

  expect_false('_count' %in% names(result))
  expect_false('_sort' %in% names(result))
})
