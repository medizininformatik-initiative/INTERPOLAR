test_that("configured case identifiers extend standard rules without retaining unrelated identifiers", {
  root <- testthat::test_path("..", "..", "..", "..")
  sources <- getDefaultSnapshotPseudonymizationRuleSources(root)
  configured_system <- "https://example.test/identifiers?kind=case&site=A"
  rules <- loadPseudonymizationRules(
    sources$table_descriptions, sources$snapshot_extensions,
    encounter_identifier_system = configured_system
  )
  input <- data.table::data.table(
    enc_identifier_system = c(configured_system, "urn:other", "urn:standard", NA_character_),
    enc_identifier_value = c("case-1", "unrelated", "case-2", "unknown"),
    enc_identifier_type_system = c(NA, NA, "http://terminology.hl7.org/CodeSystem/v2-0203", NA),
    enc_identifier_type_code = c(NA, NA, "VN", NA)
  )
  result <- pseudonymizeTable(input, rules, "Encounter")
  expect_equal(result$enc_identifier_value, c(
    pseudonymizationHash("case-1", DEFAULT_CRYPTO_HASH_MAX_LENGTH), NA_character_,
    pseudonymizationHash("case-2", DEFAULT_CRYPTO_HASH_MAX_LENGTH), NA_character_
  ))
  expect_equal(result$enc_identifier_system, c(configured_system, NA, "urn:standard", NA))
  expect_true(is.na(result$enc_identifier_type_code[1]))
  frontend <- pseudonymizeTable(data.table::data.table(fall_id = "case-1"), rules, "fall")
  expect_identical(result$enc_identifier_value[1], frontend$fall_id[1])
  unchanged <- loadPseudonymizationRules(sources$table_descriptions, sources$snapshot_extensions)
  expect_identical(
    rules[which(tolower(rules$TABLE_OR_RESOURCE) != "encounter"), ],
    unchanged[which(tolower(unchanged$TABLE_OR_RESOURCE) != "encounter"), ]
  )
  expect_true(is.na(pseudonymizeTable(input, unchanged, "Encounter")$enc_identifier_value[1]))
  expect_identical(addConfiguredEncounterIdentifierRules(unchanged, c("", NA)), unchanged)
})

test_that("configured identifiers inherit VN actions, arguments and rule precedence", {
  selector <- paste0(
    'type.coding.system == "http://terminology.hl7.org/CodeSystem/v2-0203"',
    ' & type.coding.code == "VN"'
  )
  rules <- data.table::data.table(
    TABLE_OR_RESOURCE = "Encounter",
    COLUMN_NAME = c("system", "value", "type_system", "type_code"),
    FHIR_EXPRESSION = c(
      "identifier/system", "identifier/value",
      "identifier/type/coding/system", "identifier/type/coding/code"
    ),
    PSEUDONYMIZATION_RULE = paste0("keepIf(", selector, "); redact")
  )
  input <- data.table::data.table(
    system = c("urn:local", "urn:vn", "urn:other"), value = "case-1",
    type_system = c(NA, "http://terminology.hl7.org/CodeSystem/v2-0203", NA),
    type_code = c(NA, "VN", NA)
  )
  for (action in c("keepIf", "redactIf", "cryptoHash(maxLength = 8; ")) {
    value_rule <- if (action == "cryptoHash(maxLength = 8; ") {
      paste0(action, selector, "); redact")
    } else {
      paste0(action, "(", selector, "); redact")
    }
    rules$PSEUDONYMIZATION_RULE[2] <- value_rule
    effective <- addConfiguredEncounterIdentifierRules(rules, "urn:local")
    result <- pseudonymizeTable(input, effective, "Encounter")
    expect_identical(result$value[1], result$value[2])
    expect_true(is.na(result$value[3]))
    if (action == "keepIf") expect_identical(result$value[1], "case-1")
    if (action == "redactIf") expect_true(is.na(result$value[1]))
    if (startsWith(action, "cryptoHash")) expect_equal(nchar(result$value[1]), 8L)
  }
  rules$PSEUDONYMIZATION_RULE[2] <- paste0('redactIf(system == "urn:local"); ', value_rule)
  result <- pseudonymizeTable(input, addConfiguredEncounterIdentifierRules(rules, "urn:local"), "Encounter")
  expect_true(is.na(result$value[1]))
  expect_equal(nchar(result$value[2]), 8L)

  rules$PSEUDONYMIZATION_RULE[2] <- "cryptoHash"
  expect_error(addConfiguredEncounterIdentifierRules(rules, "urn:local"), "exactly one VN rule.*value")
  rules$PSEUDONYMIZATION_RULE[2] <- paste(value_rule, value_rule, sep = "; ")
  expect_error(addConfiguredEncounterIdentifierRules(rules, "urn:local"), "exactly one VN rule.*value")
})
