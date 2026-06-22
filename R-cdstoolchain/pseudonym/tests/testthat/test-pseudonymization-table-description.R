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

test_that("rule report includes summary and contextual conflicts", {
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
  report <- getFhirPseudonymizationRuleReport(result)

  expect_named(report, c(
    "summary",
    "yaml_rules",
    "unmatched_table_rows",
    "selected_rules",
    "conflicts",
    "candidates"
  ))
  expect_equal(report$conflicts$RESOURCE, "Patient")
  expect_equal(report$conflicts$COLUMN_NAME, "pat_address_postalcode")
  expect_equal(report$summary$N, 1)
})

test_that("rule report includes YAML match counts and unmatched table rows", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: Patient.id",
    "    method: cryptoHash",
    "  - path: Patient.birthDate",
    "    method: keep"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA),
    COLUMN_NAME = c("pat_id", "pat_gender"),
    FHIR_EXPRESSION = c("id", "gender"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)
  report <- getFhirPseudonymizationRuleReport(result)

  expect_equal(report$yaml_rules$matched_rows, c(1L, 0L))
  expect_equal(report$unmatched_table_rows$COLUMN_NAME, "pat_gender")
  expect_equal(report$unmatched_table_rows$RESOURCE, "Patient")
})

test_that("setFhirPseudonymizationRules uses the packaged YAML by default", {
  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA),
    COLUMN_NAME = c("pat_id", "pat_birthdate"),
    FHIR_EXPRESSION = c("id", "birthDate"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description)

  expect_equal(result$PSEUDONYMIZATION_RULE, c("cryptoHash", "generalize(YYYY-MM)"))
  expect_true(nrow(attr(result, "pseudonymization_yaml_rule_matches")) > 0)
})
