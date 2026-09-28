test_that("failed downloads report missing FHIR bundles for every authentication mode", {
  for (auth_mode in c("none", "token", "basic")) {
    testthat::local_mocked_bindings(
      isDefinedAndNotEmpty = function(name, ...) {
        if (auth_mode == "token") name == "FHIR_TOKEN" else auth_mode == "basic"
      },
      .package = "etlutils"
    )
    testthat::local_mocked_bindings(
      fhir_search = function(...) fhircrackr::fhir_bundle_list(list()),
      .package = "fhircrackr"
    )
    expect_error(
      executeFHIRSearchVariation(
        request = "https://example.test/fhir/Encounter", max_bundles = 1, verbose = 0
      ),
      "FHIR retrieval failed: no FHIR bundles were received.*server may be unavailable"
    )
  }
})

test_that("a valid FHIR bundle with zero matches is returned unchanged", {
  bundles <- fhircrackr::fhir_bundle_list(list(xml2::read_xml(
    '<Bundle xmlns="http://hl7.org/fhir"><type value="searchset"/><total value="0"/></Bundle>'
  )))
  testthat::local_mocked_bindings(
    fhir_search = function(...) bundles,
    .package = "fhircrackr"
  )
  expect_identical(
    executeFHIRSearchVariation(
      request = "https://example.test/fhir/Encounter", max_bundles = 1, verbose = 0
    ),
    bundles
  )
})

test_that("saving bundles to disk may return NULL", {
  testthat::local_mocked_bindings(
    combineBundlePaths = identity,
    .package = "etlutils"
  )
  testthat::local_mocked_bindings(
    fhir_search = function(save_to_disc, ...) {
      expect_identical(save_to_disc, "bundles")
      NULL
    },
    .package = "fhircrackr"
  )
  expect_null(executeFHIRSearchVariation(
    request = "https://example.test/fhir/Encounter", max_bundles = 1, verbose = 0,
    save_to_disc = "bundles"
  ))
})

test_that("original request errors survive and HTTP configuration is reset", {
  reset_calls <- 0L
  original_reset <- httr::reset_config
  testthat::local_mocked_bindings(
    reset_config = function() {
      reset_calls <<- reset_calls + 1L
      original_reset()
    },
    .package = "httr"
  )
  testthat::local_mocked_bindings(
    fhir_search = function(...) stop("HTTP 503 Service Unavailable"),
    .package = "fhircrackr"
  )
  expect_error(
    executeFHIRSearchVariation(
      request = "https://example.test/fhir/Encounter", max_bundles = 1, verbose = 0
    ),
    "HTTP 503 Service Unavailable"
  )
  expect_equal(reset_calls, 1L)
})


test_that("an HTTP 503 outage retains its warning and ends with an actionable retrieval error", {
  original_search <- fhircrackr::fhir_search
  testthat::local_mocked_bindings(
    fhir_search = function(...) original_search(..., delay_between_attempts = 0),
    .package = "fhircrackr"
  )
  testthat::local_mocked_bindings(
    GET = function(...) structure(
      list(
        status_code = 503L,
        headers = list("content-type" = "text/plain"),
        content = charToRaw("Service Unavailable"),
        url = "https://example.test/fhir/Encounter"
      ),
      class = "response"
    ),
    .package = "httr"
  )
  expect_warning(
    expect_message(
      expect_error(
        executeFHIRSearchVariation(
          request = "https://example.test/fhir/Encounter", max_bundles = 1, verbose = 0
        ),
        "FHIR retrieval failed: no FHIR bundles were received"
      ),
      "Download interrupted"
    ),
    "server error, HTTP code 503"
  )
})
