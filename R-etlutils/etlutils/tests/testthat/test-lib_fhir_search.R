###########################
# fhirsearchCombineParams #
###########################

# Test basic usage with existing and new parameters as vector
test_that("Basic usage with existing and new parameters (vector)", {
  existing_params <- c("_summary" = "count", "gender" = "male")
  new_params <- c("age" = "30", "gender" = "female")  # gender will appear twice
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "_summary=count&gender=male&age=30&gender=female")
})

# Test basic usage with existing and new parameters as list
test_that("Basic usage with existing and new parameters (list)", {
  existing_params <- list("_summary" = "count", "gender" = "male")
  new_params <- list("age" = "30", "gender" = "female")  # gender will appear twice
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "_summary=count&gender=male&age=30&gender=female")
})

# Test handling of NA values in vector parameters
test_that("Handling NA values (vector)", {
  existing_params <- c("_summary" = "count", "gender" = NA)
  new_params <- c("age" = "30", "gender" = "female")
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "_summary=count&age=30&gender=female")
})

# Test handling of NA values in list parameters
test_that("Handling NA values (list)", {
  existing_params <- list("_summary" = "count", "gender" = NA)
  new_params <- list("age" = "30", "gender" = "female")
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "_summary=count&age=30&gender=female")
})

# Test handling of NULL values in vector parameters
test_that("Handling NULL values (vector)", {
  existing_params <- c("_summary" = "count")
  new_params <- c("age" = NULL, "gender" = "female")
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "_summary=count&gender=female")
})

# Test handling of NULL values in list parameters
test_that("Handling NULL values (list)", {
  existing_params <- list("_summary" = "count")
  new_params <- list("age" = NULL, "gender" = "female")
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "_summary=count&gender=female")
})

# Test case with only existing parameters provided as vector
test_that("Only existing parameters (vector)", {
  existing_params <- c("gender" = "male")
  expect_equal(fhirsearchCombineParams(existing_params),
               "gender=male")
})

# Test case with only existing parameters provided as list
test_that("Only existing parameters (list)", {
  existing_params <- list("gender" = "male")
  expect_equal(fhirsearchCombineParams(existing_params),
               "gender=male")
})

# Test case with no parameters provided
test_that("No parameters provided", {
  expect_equal(fhirsearchCombineParams(), "")
})

########################
# fhirsearchLogRequest #
########################

test_that("fhirsearchLogRequest can write a request without duplicating console output", {
  log_directory <- tempfile("fhir-request-log-")
  dir.create(log_directory)
  on.exit(unlink(log_directory, recursive = TRUE))
  testthat::local_mocked_bindings(
    getBundlesDirectory = function() log_directory,
    .package = "etlutils"
  )

  output <- capture.output(
    fhirsearchLogRequest(
      VL_90_FHIR_RESPONSE,
      "Observation",
      "patient=123",
      print_to_console = FALSE
    )
  )

  expect_length(output, 0)
  expect_equal(
    readLines(file.path(log_directory, "cds2db_total_bundles.txt")),
    "patient=123"
  )
})

test_that("fhirsearchResourceHasEntries requests only the resource total", {
  requests <- character()
  testthat::local_mocked_bindings(
    executeFHIRSearchVariation = function(request, ...) {
      requests <<- c(requests, toString(request))
      list(xml2::read_xml("<Bundle><total value=\"2\"/></Bundle>"))
    },
    .package = "etlutils"
  )

  expect_true(fhirsearchResourceHasEntries("https://example.test/fhir", "Observation"))
  expect_equal(
    requests,
    "https://example.test/fhir/Observation?_summary=count"
  )
})

test_that("fhirsearchResourceHasEntries distinguishes empty resources and failed checks", {
  testthat::local_mocked_bindings(
    executeFHIRSearchVariation = function(...) {
      list(xml2::read_xml("<Bundle><total value=\"0\"/></Bundle>"))
    },
    .package = "etlutils"
  )
  expect_false(fhirsearchResourceHasEntries("https://example.test/fhir", "Observation"))

  testthat::local_mocked_bindings(
    executeFHIRSearchVariation = function(...) stop("FHIR server unavailable"),
    .package = "etlutils"
  )
  expect_true(is.na(fhirsearchResourceHasEntries("https://example.test/fhir", "Observation")))
})

test_that("fhirsearchMultipleResourcesByPID skips searches after one zero total", {
  global_names <- c("FHIR_SERVER_ENDPOINT", "VERBOSE")
  global_exists <- vapply(global_names, exists, logical(1), envir = .GlobalEnv, inherits = FALSE)
  global_values <- mget(global_names[global_exists], envir = .GlobalEnv, inherits = FALSE)
  on.exit({
    remove(list = global_names, envir = .GlobalEnv)
    list2env(global_values, envir = .GlobalEnv)
  })
  assign("FHIR_SERVER_ENDPOINT", "https://example.test/fhir", envir = .GlobalEnv)
  assign("VERBOSE", 0, envir = .GlobalEnv)

  availability_checks <- 0
  testthat::local_mocked_bindings(
    fhirsearchResourceHasEntries = function(...) {
      availability_checks <<- availability_checks + 1
      FALSE
    },
    fhirsearchResourcesByPID = function(...) stop("Unexpected filtered FHIR search"),
    .package = "etlutils"
  )
  table_description <- fhircrackr::fhir_table_description(
    resource = "Observation",
    cols = fhircrackr::fhir_columns(c(obs_id = "id"))
  )
  pids <- c("PID1", "PID2")
  names(pids) <- c("2026-05-21", "2026-06-01")

  result <- fhirsearchMultipleResourcesByPID(
    pids,
    list(Observation = table_description),
    patient_age_at_enc_start = 0
  )

  expect_equal(availability_checks, 1)
  expect_equal(nrow(result$raw_fhir_resources$Observation), 0)
})

# Test new_params provided as a single string
test_that("new_params as a single string", {
  existing_params <- c("status" = "active")
  new_params <- "gender=male"
  expect_equal(fhirsearchCombineParams(existing_params, new_params),
               "status=active&gender=male")
})

##################
# mapDatesToPids #
##################

# Test: Mapping of unique dates to patient IDs with comparator
test_that("mapDatesToPids correctly maps PIDs to the earliest date with a comparator", {
  # Test input data
  pids_with_last_updated <- c("PID1", "PID2", "PID3", "PID4", "PID5", "PID1", "PID6", "PID6")
  names(pids_with_last_updated) <- c("2024-01-01", "2024-01-02", NA,
                                     "2024-01-01", NA, NA, "2024-01-01", "2024-12-31")

  # Run the function
  result <- mapDatesToPids(pids_with_last_updated)

  # Check that there are exactly three groups
  expect_equal(length(result), 3)

  # Check that there are three groups: "gt2024-01-01", "gt2024-01-02", and NA
  expect_true("gt2024-01-01" %in% names(result))
  expect_true("gt2024-01-02" %in% names(result))
  expect_true(any(is.na(names(result))))

  # Check that PIDs are correctly grouped
  # Access the NA group using is.na on names
  expect_equal(sort(result[is.na(names(result))][[1]]), sort(c("PID1", "PID3", "PID5")))

  # PID6 should only be in the group for "gt2024-01-01" since it's the minimal date for PID6
  expect_equal(sort(result[["gt2024-01-01"]]), sort(c("PID4", "PID6")))

  # PID2 should only appear in "gt2024-01-02"
  expect_equal(result[["gt2024-01-02"]], "PID2")
})

# Test: Mapping of unique dates to patient IDs when no names are provided
test_that("mapDatesToPids handles PIDs without names by setting all names to NA", {
  # Test input data: PIDs without names
  pids_with_last_updated <- c("PID1", "PID2", "PID3", "PID4", "PID5")

  # Expect that names are all NA
  result <- mapDatesToPids(pids_with_last_updated)

  # Check that there is only one group: NA
  expect_true(length(result) == 1)
  expect_true(is.na(names(result)[1]))

  # Check that all PIDs are in the NA group
  expect_equal(sort(result[[1]]), sort(c("PID1", "PID2", "PID3", "PID4", "PID5")))
})

##############################
# fhirsearchAddGlobalParams  #
##############################

# Test: Add common parameters (_count and _sort) to FHIR request
test_that("fhirsearchAddGlobalParams correctly adds common parameters", {
  # Temporarily set global variables for the tests
  COUNT_PER_BUNDLE <<- "50"  # Set as a numeric value, not as a string
  SORT <<- "date"

  # Test case 1: No _count or _sort provided, global variables exist
  parameters <- list('_id' = '12345')
  result <- fhirsearchAddGlobalParams(parameters)

  expect_equal(result[["_count"]], "50")
  expect_equal(result[["_sort"]], 'date')
  expect_equal(result[["_id"]], '12345')

  # Test case 2a: _count is provided, _sort is missing
  parameters <- list('_id' = '12345', '_count' = 100)
  result <- fhirsearchAddGlobalParams(parameters)

  # _count should remain as 100
  expect_equal(result[["_count"]], 100)
  expect_equal(result[["_sort"]], 'date')

  # Test case 2b: _count is provided as string, _sort is missing
  parameters <- list('_id' = '12345', '_count' = "100")
  result <- fhirsearchAddGlobalParams(parameters)

  # _count should remain as 100
  expect_equal(result[["_count"]], "100")
  expect_equal(result[["_sort"]], 'date')

  # Test case 3: _sort is provided, _count is missing
  parameters <- list('_id' = '12345', '_sort' = 'name')
  result <- fhirsearchAddGlobalParams(parameters)

  # _sort should remain as 'name'
  expect_equal(result[["_count"]], "50")
  expect_equal(result[["_sort"]], 'name')

  # Test case 4: Both _count and _sort are already provided
  parameters <- list('_id' = '12345', '_count' = 200, '_sort' = 'name')
  result <- fhirsearchAddGlobalParams(parameters)

  # Neither should be overwritten
  expect_equal(result[["_count"]], 200)
  expect_equal(result[["_sort"]], 'name')

  # Test case 5: NULL parameters, global variables exist
  result <- fhirsearchAddGlobalParams(NULL)

  expect_equal(result[["_count"]], "50")  # Expect string comparison
  expect_equal(result[["_sort"]], 'date')

  # Test case 6: Empty parameters, no global variables
  COUNT_PER_BUNDLE <<- NULL
  SORT <<- NULL
  parameters <- list()
  result <- fhirsearchAddGlobalParams(parameters)

  expect_false('_count' %in% names(result))
  expect_false('_sort' %in% names(result))
})
