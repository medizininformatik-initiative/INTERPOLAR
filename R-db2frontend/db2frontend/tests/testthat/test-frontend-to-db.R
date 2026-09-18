test_that("importRedcap2DB preserves export errors without a matching form list", {
  testthat::local_mocked_bindings(
    getRedcapConnection = function() NULL,
    getFrontendTableDescription = function() list(medikationsanalyse = NULL)
  )

  for (original_message in c("API request failed", "Invalid forms: {'patient','fall'}")) {
    testthat::local_mocked_bindings(
      exportRecordsTyped = function(...) stop(original_message),
      .package = "redcapAPI"
    )

    expect_error(
      importRedcap2DB(),
      paste0("Error exporting records for REDCap form name 'medikationsanalyse': ", original_message),
      fixed = TRUE
    )
  }
})

test_that("importRedcap2DB retains the form name fallback", {
  testthat::local_mocked_bindings(
    getRedcapConnection = function() NULL,
    getFrontendTableDescription = function() list(medikationsanalyse = NULL)
  )
  requested_forms <- character()
  testthat::local_mocked_bindings(
    exportRecordsTyped = function(rcon, forms) {
      requested_forms <<- c(requested_forms, forms)
      if (length(requested_forms) == 1L) {
        stop("Invalid forms: {'patient','medikationsanalyse,Medikationsanalyse'}")
      }
      # Stop before downstream processing to test the export retry in isolation.
      stop("Retry reached")
    },
    .package = "redcapAPI"
  )

  expect_error(importRedcap2DB(), "Retry reached", fixed = TRUE)
  expect_identical(requested_forms, c("medikationsanalyse", "medikationsanalyse,Medikationsanalyse"))
})
