###########################
# combineFHIRSearchParams #
###########################

# Test basic usage with existing and new parameters as vector
test_that("Basic usage with existing and new parameters (vector)", {
  existing_params <- c("_summary" = "count", "gender" = "male")
  new_params <- c("age" = "30", "gender" = "female")  # gender will appear twice
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "_summary=count&gender=male&age=30&gender=female")
})

# Test basic usage with existing and new parameters as list
test_that("Basic usage with existing and new parameters (list)", {
  existing_params <- list("_summary" = "count", "gender" = "male")
  new_params <- list("age" = "30", "gender" = "female")  # gender will appear twice
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "_summary=count&gender=male&age=30&gender=female")
})

# Test handling of NA values in vector parameters
test_that("Handling NA values (vector)", {
  existing_params <- c("_summary" = "count", "gender" = NA)
  new_params <- c("age" = "30", "gender" = "female")
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "_summary=count&age=30&gender=female")
})

# Test handling of NA values in list parameters
test_that("Handling NA values (list)", {
  existing_params <- list("_summary" = "count", "gender" = NA)
  new_params <- list("age" = "30", "gender" = "female")
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "_summary=count&age=30&gender=female")
})

# Test handling of NULL values in vector parameters
test_that("Handling NULL values (vector)", {
  existing_params <- c("_summary" = "count")
  new_params <- c("age" = NULL, "gender" = "female")
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "_summary=count&gender=female")
})

# Test handling of NULL values in list parameters
test_that("Handling NULL values (list)", {
  existing_params <- list("_summary" = "count")
  new_params <- list("age" = NULL, "gender" = "female")
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "_summary=count&gender=female")
})

# Test case with only existing parameters provided as vector
test_that("Only existing parameters (vector)", {
  existing_params <- c("gender" = "male")
  expect_equal(combineFHIRSearchParams(existing_params),
               "gender=male")
})

# Test case with only existing parameters provided as list
test_that("Only existing parameters (list)", {
  existing_params <- list("gender" = "male")
  expect_equal(combineFHIRSearchParams(existing_params),
               "gender=male")
})

# Test case with no parameters provided
test_that("No parameters provided", {
  expect_equal(combineFHIRSearchParams(), "")
})

# Test new_params provided as a single string
test_that("new_params as a single string", {
  existing_params <- c("status" = "active")
  new_params <- "gender=male"
  expect_equal(combineFHIRSearchParams(existing_params, new_params),
               "status=active&gender=male")
})
