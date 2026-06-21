test_that("setFhirPseudonymizationRules maps explicit and default redact semantics", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: Patient.birthDate",
    "    method: generalize",
    "    cases:",
    paste0(
      "      \"$this\": \"$this.toString().replaceMatches('",
      "(?<year>\\\\\\\\d{2,4})-(?<month>\\\\\\\\d{2})-(?<day>\\\\\\\\d{2})\\\\\\\\b",
      "', '${year}-${month}')\""
    ),
    "  - path: nodesByType('HumanName')",
    "    method: redact",
    "  - path: Resource.id",
    "    method: cryptoHash"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA, NA, NA, NA),
    COLUMN_NAME = c(
      "pat_id",
      "pat_birthdate",
      "pat_name_family",
      "pat_gender",
      "pat_unknown"
    ),
    FHIR_EXPRESSION = c("id", "birthDate", "name/family", "gender", "foo"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(result$PSEUDONYMIZATION_RULE, c(
    "cryptoHash",
    "generalize(YYYY-MM)",
    "redact",
    NA_character_,
    NA_character_
  ))
})

test_that("specific resource rules win over broad node type rules", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: Patient.address.postalCode",
    "    method: generalize",
    "    cases:",
    "      \"$this\": \"$this.toString().substring(0,2)\"",
    "  - path: nodesByType('Address')",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = "Patient",
    COLUMN_NAME = "pat_address_postalcode",
    FHIR_EXPRESSION = "address/postalCode",
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(result$PSEUDONYMIZATION_RULE, "generalize(postalCode2)")
  expect_equal(nrow(attr(result, "pseudonymization_conflicts")), 1)
})
