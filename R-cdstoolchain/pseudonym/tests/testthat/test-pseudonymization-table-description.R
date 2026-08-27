test_that("setFhirPseudonymizationRules maps explicit and default keep semantics", {
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
    "generalize(format = \"YYYY-MM\")",
    "redact",
    "keep",
    "keep"
  ))
})

test_that("setFhirPseudonymizationRules leaves structural rows empty", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirPathRules:",
    "  - path: Resource.id",
    "    method: cryptoHash"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA_character_, NA_character_),
    COLUMN_NAME = c("pat_id", "pat_gender", NA_character_),
    FHIR_EXPRESSION = c("id", "gender", NA_character_),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(result$PSEUDONYMIZATION_RULE, c("cryptoHash", "keep", NA_character_))
})

test_that("setFhirPseudonymizationRules accepts top-level YAML rule lists", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "- path: Resource.id",
    "  method: cryptoHash"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = "Patient",
    COLUMN_NAME = "pat_id",
    FHIR_EXPRESSION = "id",
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(result$PSEUDONYMIZATION_RULE, "cryptoHash")
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

  expect_equal(result$PSEUDONYMIZATION_RULE, "generalize(format = \"postalCode2\")")
  expect_equal(nrow(attr(result, "pseudonymization_conflicts")), 1)
})

test_that("earlier YAML rules win over later more specific rules", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Address')",
    "    method: redact",
    "  - path: Patient.address.postalCode",
    "    method: generalize",
    "    cases:",
    "      \"$this\": \"$this.toString().substring(0,2)\""
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

  expect_equal(result$PSEUDONYMIZATION_RULE, "redact")
  expect_equal(report$overridden_rules$pseudonymization_rule, "generalize(format = \"postalCode2\")")
})

test_that("nodesByType Reference reference matches calculated references", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Reference').reference",
    "    method: cryptoHash"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Encounter", NA, NA),
    COLUMN_NAME = c(
      "enc_partof_ref",
      "enc_partof_calculated_ref",
      "enc_main_encounter_calculated_ref"
    ),
    FHIR_EXPRESSION = c(
      "partOf/reference",
      "partOf/calculated_ref",
      "main/encounter/calculated/ref"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)
  report <- getFhirPseudonymizationRuleReport(result)

  expect_equal(result$PSEUDONYMIZATION_RULE, rep("cryptoHash", 3))
  expect_equal(
    report$selected_rules$match_type,
    c("direct", "calculatedReferenceAlias", "calculatedReferenceAlias")
  )
})

test_that("nodesByType Reference identifier matches expanded identifier children", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Reference').identifier",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Condition", NA, NA),
    COLUMN_NAME = c(
      "con_recorder_ref",
      "con_recorder_identifier_system",
      "con_recorder_identifier_value"
    ),
    FHIR_EXPRESSION = c(
      "recorder/reference",
      "recorder/identifier/system",
      "recorder/identifier/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  candidates <- attr(result, "pseudonymization_candidates")
  selected <- attr(result, "pseudonymization_selected")
  expect_equal(candidates$row_index, c(2L, 3L))
  expect_equal(selected$row_index, c(2L, 3L))
})

test_that("nodesByType Reference identifier requires a reference sibling prefix", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Reference').identifier",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Consent", NA),
    COLUMN_NAME = c(
      "cons_identifier_value",
      "cons_provision_actor_identifier_value"
    ),
    FHIR_EXPRESSION = c(
      "identifier/value",
      "provision/actor/identifier/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  table_description[["RESOURCE_FILLED"]] <- table_description[["RESOURCE"]]
  etlutils::fillNAWithLastRowValue(table_description, "RESOURCE_FILLED")
  yaml_rule <- yaml::read_yaml(yaml_file)$fhirPathRules[[1]]
  matched_rows <- pseudonym:::matchYamlRuleToTableDescription(yaml_rule, table_description)

  expect_equal(matched_rows$row_index, integer())
})

test_that("nodesByType Reference identifier uses reference sibling prefixes", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Reference').identifier",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Consent", NA),
    COLUMN_NAME = c(
      "cons_provision_actor_ref",
      "cons_provision_actor_identifier_value"
    ),
    FHIR_EXPRESSION = c(
      "provision/actor/reference",
      "provision/actor/identifier/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  table_description[["RESOURCE_FILLED"]] <- table_description[["RESOURCE"]]
  etlutils::fillNAWithLastRowValue(table_description, "RESOURCE_FILLED")
  yaml_rule <- yaml::read_yaml(yaml_file)$fhirPathRules[[1]]
  matched_rows <- pseudonym:::matchYamlRuleToTableDescription(yaml_rule, table_description)

  expect_equal(matched_rows$row_index, 2L)
})

test_that("nodesByType uses expansion provenance instead of matching element names", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Age')",
    "    method: redact",
    "  - path: nodesByType('HumanName')",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Condition", "Observation", "Patient", "Organization"),
    COLUMN_NAME = c(
      "con_abatementage_value",
      "obs_referencerange_age_low_value",
      "pat_name_family",
      "org_name"
    ),
    FHIR_EXPRESSION = c(
      "abatementAge/value",
      "referenceRange/age/low/value",
      "name/family",
      "name"
    ),
    FHIR_NODE_TYPE_PATHS = c(
      "Age=abatementAge",
      "Range=referenceRange/age|SimpleQuantity=referenceRange/age/low",
      "HumanName=name",
      NA_character_
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = c("decimal", "decimal", NA_character_, NA_character_)
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(
    result$PSEUDONYMIZATION_RULE,
    c("redact", "keep", "redact", "keep")
  )
})

test_that("nodesByType provenance supports root-level expanded node types", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Identifier').system",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Patient", "Organization"),
    COLUMN_NAME = c("pat_identifier_system", "org_system"),
    FHIR_EXPRESSION = c("identifier/system", "system"),
    FHIR_NODE_TYPE_PATHS = c("Identifier=identifier", NA_character_),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(result$PSEUDONYMIZATION_RULE, c("redact", "keep"))
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
    "overridden_rules",
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

  expect_equal(
    result$PSEUDONYMIZATION_RULE,
    c("cryptoHash", "generalize(format = \"YYYY-MM\")")
  )
  expect_true(nrow(attr(result, "pseudonymization_yaml_rule_matches")) > 0)
})

test_that("currently absent non-Bundle default YAML paths match when present", {
  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA, NA, NA, "Provenance", "Observation"),
    COLUMN_NAME = c(
      "pat_address_country",
      "pat_address_state",
      "pat_deceased_boolean",
      "pat_deceaseddatetime",
      "pro_target_ref",
      "obs_telecom_value"
    ),
    FHIR_EXPRESSION = c(
      "address/country",
      "address/state",
      "deceasedBoolean",
      "deceasedDateTime",
      "target/reference",
      "telecom/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description)

  expect_equal(result$PSEUDONYMIZATION_RULE, c(
    "keep",
    "keep",
    "keep",
    "generalize(format = \"YYYY-MM\")",
    "cryptoHash",
    "redact"
  ))
})

test_that("packaged YAML redacts identifiers unless their type is approved", {
  table_description <- data.table::data.table(
    RESOURCE = c("Observation", NA, NA, NA),
    COLUMN_NAME = c(
      "obs_identifier_type_system",
      "obs_identifier_type_code",
      "obs_identifier_system",
      "obs_identifier_value"
    ),
    FHIR_EXPRESSION = c(
      "identifier/type/coding/system",
      "identifier/type/coding/code",
      "identifier/system",
      "identifier/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description)

  metadata_rule <- result$PSEUDONYMIZATION_RULE[3]
  value_rule <- result$PSEUDONYMIZATION_RULE[4]
  expect_match(metadata_rule, "keepIf(", fixed = TRUE)
  expect_match(value_rule, "pseudonymize(", fixed = TRUE)
  for (code in c("VN", "MR", "PSEUDED", "ANONYED")) {
    condition_end <- paste0('code == "', code, '")')
    expect_match(metadata_rule, condition_end, fixed = TRUE)
    expect_match(value_rule, condition_end, fixed = TRUE)
  }
  expect_true(endsWith(metadata_rule, "; redact"))
  expect_true(endsWith(value_rule, "; redact"))
})

test_that("conditional reference identifier rules are translated into readable rule calls", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Reference').identifier.where(type.coding.where(system='https://example.test' and code='VN').exists()).value",
    "    method: pseudonymize",
    "    domain: encounter-vn",
    "  - path: nodesByType('Reference').identifier",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Encounter", NA, NA, NA, NA),
    COLUMN_NAME = c(
      "enc_subject_ref",
      "enc_subject_identifier_system",
      "enc_subject_identifier_type_coding_system",
      "enc_subject_identifier_type_coding_code",
      "enc_subject_identifier_value"
    ),
    FHIR_EXPRESSION = c(
      "subject/reference",
      "subject/identifier/system",
      "subject/identifier/type/coding/system",
      "subject/identifier/type/coding/code",
      "subject/identifier/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(
    result$PSEUDONYMIZATION_RULE[5],
    paste0(
      "pseudonymize(domain = \"encounter-vn\"; ",
      "type.coding.system == \"https://example.test\" & type.coding.code == \"VN\"); redact"
    )
  )
})

test_that("conditional redact rules are hidden when fallback redact already applies", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Identifier').where(type.coding.where(system='https://example.test' and code='MR').exists()).system",
    "    method: keep",
    "  - path: nodesByType('Identifier').where(type.coding.where(system='https://example.test' and code='GKV').exists()).system",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = "Patient",
    COLUMN_NAME = "pat_identifier_system",
    FHIR_EXPRESSION = "identifier/system",
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(
    result$PSEUDONYMIZATION_RULE,
    paste0(
      "keepIf(type.coding.system == \"https://example.test\" & ",
      "type.coding.code == \"MR\"); redact"
    )
  )
})

test_that("conditional rule chains keep only the first rule for each condition", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Identifier').where(type.coding.where(system='https://example.test' and code='VN').exists()).value",
    "    method: pseudonymize",
    "    domain: vn",
    "  - path: nodesByType('Reference').identifier.where(type.coding.where(system='https://example.test' and code='VN').exists())",
    "    method: keep",
    "  - path: nodesByType('Reference').identifier.where(system='https://example.test/extraction_id')",
    "    method: keep"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = c("Encounter", NA, NA),
    COLUMN_NAME = c(
      "enc_subject_ref",
      "enc_subject_identifier_system",
      "enc_subject_identifier_value"
    ),
    FHIR_EXPRESSION = c(
      "subject/reference",
      "subject/identifier/system",
      "subject/identifier/value"
    ),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(
    result$PSEUDONYMIZATION_RULE[3],
    paste0(
      "pseudonymize(domain = \"vn\"; ",
      "type.coding.system == \"https://example.test\" & type.coding.code == \"VN\"); ",
      "keepIf(system == \"https://example.test/extraction_id\"); redact"
    )
  )
})

test_that("only conditional redact rules receive an explicit keep fallback", {
  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(c(
    "---",
    "fhirVersion: R4",
    "fhirPathRules:",
    "  - path: nodesByType('Identifier').where(type.coding.where(system='https://example.test' and code='GKV').exists()).system",
    "    method: redact"
  ), yaml_file)

  table_description <- data.table::data.table(
    RESOURCE = "Patient",
    COLUMN_NAME = "pat_identifier_system",
    FHIR_EXPRESSION = "identifier/system",
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- setFhirPseudonymizationRules(table_description, yaml_file)

  expect_equal(
    result$PSEUDONYMIZATION_RULE,
    paste0(
      "redactIf(type.coding.system == \"https://example.test\" & ",
      "type.coding.code == \"GKV\"); keep"
    )
  )
})
