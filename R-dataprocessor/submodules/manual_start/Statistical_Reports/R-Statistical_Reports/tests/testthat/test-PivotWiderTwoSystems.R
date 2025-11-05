# Load required package (within your package namespace or Suggests)
library(testthat)
library(dplyr)

test_that("PivotWiderTwoSystems correctly maps system1 and system2", {
  df <- data.frame(
    id = c(1, 2),
    enc_type_code = c("einrichtungskontakt", "normalstationaer"),
    enc_type_system = c(
      "http://fhir.de/CodeSystem/Kontaktebene",
      "http://fhir.de/CodeSystem/kontaktart-de"
    ),
    stringsAsFactors = FALSE
  )

  result <- PivotWiderTwoSystems(
    data = df,
    system1 = "http://fhir.de/CodeSystem/Kontaktebene",
    codes1 = c("einrichtungskontakt", "abteilungskontakt"),
    system2 = "http://fhir.de/CodeSystem/kontaktart-de",
    codes2 = c("normalstationaer"),
    var_code = "enc_type_code",
    var_system = "enc_type_system",
    var_new_system_1 = "sys1",
    var_new_system_2 = "sys2",
    exclusion_reason = "mapping_failed",
    id_column = "id"
  )

  expect_equal(result$sys1, c("einrichtungskontakt", NA))
  expect_equal(result$sys2, c(NA, "normalstationaer"))
  expect_true(all(is.na(result$processing_exclusion_reason)))
})

test_that("PivotWiderTwoSystems assigns exclusion_reason for unknown codes", {
  df <- data.frame(
    id = 1,
    enc_type_code = "unknown_code",
    enc_type_system = "http://fhir.de/CodeSystem/Kontaktebene",
    stringsAsFactors = FALSE
  )

  result <- suppressWarnings(
    PivotWiderTwoSystems(
      data = df,
      system1 = "http://fhir.de/CodeSystem/Kontaktebene",
      codes1 = c("einrichtungskontakt"),
      system2 = "http://fhir.de/CodeSystem/kontaktart-de",
      codes2 = c("normalstationaer"),
      var_code = "enc_type_code",
      var_system = "enc_type_system",
      var_new_system_1 = "sys1",
      var_new_system_2 = "sys2",
      exclusion_reason = "mapping_failed",
      id_column = "id"
    )
  )

  expect_equal(result$processing_exclusion_reason, "mapping_failed")
})

test_that("PivotWiderTwoSystems handles multiple values inside a group", {
  df <- data.frame(
    id = c(1, 1),
    enc_type_code = c("einrichtungskontakt", "abteilungskontakt"),
    enc_type_system = c(
      "http://fhir.de/CodeSystem/Kontaktebene",
      "http://fhir.de/CodeSystem/Kontaktebene"
    ),
    stringsAsFactors = FALSE
  )

  result <- suppressWarnings(
    PivotWiderTwoSystems(
      data = df,
      system1 = "http://fhir.de/CodeSystem/Kontaktebene",
      codes1 = c("einrichtungskontakt", "abteilungskontakt"),
      system2 = "http://fhir.de/CodeSystem/kontaktart-de",
      codes2 = c("normalstationaer"),
      var_code = "enc_type_code",
      var_system = "enc_type_system",
      var_new_system_1 = "sys1",
      var_new_system_2 = "sys2",
      exclusion_reason = "mapping_failed",
      id_column = "id"
    )
  )

  expect_equal(result$sys1, "MULTIPLE_VALUES")
  expect_equal(result$processing_exclusion_reason, "mapping_failed")
})
