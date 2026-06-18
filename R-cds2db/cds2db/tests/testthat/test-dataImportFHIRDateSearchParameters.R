testthat::test_that("Consent ignores the data import date range", {
  parameter_names <- c("DATA_IMPORT_RANGE_START", "DATA_IMPORT_RANGE_END")
  previous_values <- lapply(parameter_names, function(name) {
    if (exists(name, envir = .GlobalEnv, inherits = FALSE)) {
      get(name, envir = .GlobalEnv, inherits = FALSE)
    } else {
      NULL
    }
  })
  names(previous_values) <- parameter_names
  previously_defined <- vapply(
    parameter_names,
    exists,
    logical(1),
    envir = .GlobalEnv,
    inherits = FALSE
  )
  on.exit({
    for (name in parameter_names) {
      if (previously_defined[[name]]) {
        assign(name, previous_values[[name]], envir = .GlobalEnv)
      } else if (exists(name, envir = .GlobalEnv, inherits = FALSE)) {
        rm(list = name, envir = .GlobalEnv)
      }
    }
  })

  assign("DATA_IMPORT_RANGE_START", "2025-01-01 00:00:00", envir = .GlobalEnv)
  assign("DATA_IMPORT_RANGE_END", "2025-12-31 23:59:59", envir = .GlobalEnv)

  testthat::expect_null(getDataImportFHIRDateSearchParameters("Consent"))
  testthat::expect_identical(
    addDataImportFHIRDateSearchParameters(list(Consent = TRUE), NULL),
    list()
  )
})
