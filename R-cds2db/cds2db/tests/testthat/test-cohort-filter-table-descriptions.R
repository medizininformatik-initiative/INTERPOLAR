#############################################
### TEST cohort filter table descriptions ###
#############################################

testthat::test_that("getCohortFilterPIDExpressions returns generic PID candidates", {
  testthat::expect_identical(
    getCohortFilterPIDExpressions("Observation"),
    c("subject/reference", "patient/reference")
  )
  testthat::expect_identical(
    getCohortFilterPIDExpressions("DeviceUseStatement"),
    c("subject/reference", "patient/reference")
  )
  testthat::expect_identical(
    getCohortFilterPIDExpressions("Patient"),
    c("subject/reference", "patient/reference")
  )
})

testthat::test_that("getCohortFilterTableDescriptions builds one minimal description per resource", {
  table_description_table <- data.table::data.table(
    RESOURCE = c("Encounter", "Observation", "Patient"),
    FHIR_EXPRESSION = c("subject/reference", "subject/reference", "id")
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
      ),
      Patient = list(Condition_1 = list(gender = "female"))
    ),
    "DUP 2" = list(Observation = list(Condition_1 = list("code/coding/code" = "67890")))
  )

  table_descriptions <- getCohortFilterTableDescriptions(
    cohort_filter_patterns,
    table_description_table
  )

  testthat::expect_named(table_descriptions, c("Encounter", "Observation", "Patient"))
  testthat::expect_identical(table_descriptions$Encounter@resource@.Data, "Encounter")
  testthat::expect_setequal(
    table_descriptions$Encounter@cols@.Data,
    c("id", "subject/reference", "patient/reference", "location/location/reference")
  )
  testthat::expect_identical(table_descriptions$Observation@resource@.Data, "Observation")
  testthat::expect_setequal(
    table_descriptions$Observation@cols@.Data,
    c("id", "subject/reference", "patient/reference", "code/coding/code", "effectiveDateTime")
  )
  testthat::expect_identical(table_descriptions$Patient@resource@.Data, "Patient")
  testthat::expect_setequal(
    table_descriptions$Patient@cols@.Data,
    c("id", "subject/reference", "patient/reference", "gender")
  )
})
