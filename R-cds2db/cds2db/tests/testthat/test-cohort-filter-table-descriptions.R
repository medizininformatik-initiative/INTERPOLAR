#############################################
### TEST cohort filter table descriptions ###
#############################################

testthat::test_that("getCohortFilterPIDExpression finds subject and patient references", {
  table_description_table <- data.table::data.table(
    RESOURCE = c("Observation", "DeviceUseStatement", "Patient"),
    FHIR_EXPRESSION = c("subject/reference", "patient/reference", "id")
  )

  testthat::expect_identical(
    getCohortFilterPIDExpression("Observation", table_description_table),
    "subject/reference"
  )
  testthat::expect_identical(
    getCohortFilterPIDExpression("DeviceUseStatement", table_description_table),
    "patient/reference"
  )
  testthat::expect_identical(
    getCohortFilterPIDExpression("Patient", table_description_table),
    "id"
  )
})

testthat::test_that("getCohortFilterPIDExpression rejects resources without PID expression", {
  table_description_table <- data.table::data.table(
    RESOURCE = "Medication",
    FHIR_EXPRESSION = "id"
  )

  testthat::expect_error(
    getCohortFilterPIDExpression("Medication", table_description_table),
    "has no supported patient ID expression"
  )
})

testthat::test_that("getCohortFilterTableDescriptions builds one minimal description per resource", {
  table_description_table <- data.table::data.table(
    RESOURCE = c("Encounter", "Observation"),
    FHIR_EXPRESSION = c("subject/reference", "subject/reference")
  )
  cohort_filter_patterns <- list(
    "DUP 1" = list(
      Encounter = list(
        Condition_1 = list("location/location/reference" = "Location/location_id_1")
      ),
      Observation = list(
        Condition_1 = list(
          "code/coding/code" = "12345",
          effectiveDateTime = "2025-01-01"
        )
      )
    ),
    "DUP 2" = list(
      Observation = list(
        Condition_1 = list("code/coding/code" = "67890")
      )
    )
  )

  table_descriptions <- getCohortFilterTableDescriptions(
    cohort_filter_patterns,
    table_description_table
  )

  testthat::expect_named(table_descriptions, c("Encounter", "Observation"))
  testthat::expect_identical(table_descriptions$Encounter@resource@.Data, "Encounter")
  testthat::expect_setequal(
    table_descriptions$Encounter@cols@.Data,
    c("id", "subject/reference", "location/location/reference")
  )
  testthat::expect_identical(table_descriptions$Observation@resource@.Data, "Observation")
  testthat::expect_setequal(
    table_descriptions$Observation@cols@.Data,
    c("id", "subject/reference", "code/coding/code", "effectiveDateTime")
  )
})
