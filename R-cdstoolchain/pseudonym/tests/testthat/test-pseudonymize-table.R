test_that("pseudonymizeTable applies keep redact hash and generalize rules", {
  source_table <- data.table::data.table(
    pat_id = c("p1", "p2", NA),
    pat_birthdate = as.Date(c("1980-05-17", "1975-12-01", NA)),
    pat_gender = c("female", "male", "other"),
    pat_name = c("A", "B", "C"),
    undocumented = c("x", "y", "z")
  )
  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA, NA, NA),
    COLUMN_NAME = c("pat_id", "pat_birthdate", "pat_gender", "pat_name"),
    PSEUDONYMIZATION_RULE = c(
      "cryptoHash",
      "generalize(format = \"YYYY-MM\")",
      "keep",
      "redact"
    )
  )

  result <- pseudonymizeTable(source_table, table_description, "Patient", salt = "test-salt")

  expect_false(identical(result$pat_id[1], source_table$pat_id[1]))
  expect_equal(result$pat_id[1], pseudonymizeTable(
    data.table::data.table(pat_id = source_table$pat_id[1]),
    table_description[1, ],
    "Patient",
    salt = "test-salt"
  )$pat_id)
  expect_equal(result$pat_birthdate, as.Date(c("1980-05-01", "1975-12-01", NA)))
  expect_equal(result$pat_gender, source_table$pat_gender)
  expect_true(all(is.na(result$pat_name)))
  expect_equal(result$undocumented, source_table$undocumented)
})

test_that("conditional rules use first match and redact unmatched rows", {
  source_table <- data.table::data.table(
    identifier_type_system = c("https://example.test", "https://example.test", "other"),
    identifier_type_code = c("VN", "MR", "VN"),
    identifier_value = c("visit-1", "record-2", "other-3")
  )
  table_description <- data.table::data.table(
    RESOURCE = c("Encounter", NA, NA),
    COLUMN_NAME = c("identifier_type_system", "identifier_type_code", "identifier_value"),
    FHIR_EXPRESSION = c(
      "identifier/type/coding/system",
      "identifier/type/coding/code",
      "identifier/value"
    ),
    PSEUDONYMIZATION_RULE = c(
      NA_character_,
      NA_character_,
      paste0(
        "pseudonymize(domain = \"encounter-vn\"; ",
        "type.coding.system == \"https://example.test\" & type.coding.code == \"VN\")"
      )
    )
  )

  result <- pseudonymizeTable(source_table, table_description, "Encounter", salt = "test-salt")

  expect_false(identical(result$identifier_value[1], source_table$identifier_value[1]))
  expect_true(is.na(result$identifier_value[2]))
  expect_true(is.na(result$identifier_value[3]))
})

test_that("conditional rules tolerate Excel escaped line breaks", {
  source_table <- data.table::data.table(
    identifier_type_system = c("https://example.test", "https://example.test"),
    identifier_type_code = c("VN", "MR"),
    identifier_value = c("visit-1", "record-2")
  )
  table_description <- data.table::data.table(
    TABLE_NAME = "target",
    COLUMN_NAME = c("identifier_type_system", "identifier_type_code", "identifier_value"),
    FHIR_EXPRESSION = c(
      "identifier/type/coding/system",
      "identifier/type/coding/code",
      "identifier/value"
    ),
    PSEUDONYMIZATION_RULE = c(
      NA_character_,
      NA_character_,
      paste0(
        "pseudonymize(domain = \"encounter-vn\"; ",
        "type.coding.system == \"https://example.test\" & type.coding.code == \"VN\");",
        "_x000D_keepIf(type.coding.system == \"https://example.test\" & type.coding.code == \"MR\")"
      )
    )
  )

  result <- pseudonymizeTable(source_table, table_description, "target", salt = "test-salt")

  expect_false(identical(result$identifier_value[1], source_table$identifier_value[1]))
  expect_equal(result$identifier_value[2], source_table$identifier_value[2])

  table_description$PSEUDONYMIZATION_RULE <- gsub(
    "_x000D_",
    "&#10;",
    table_description$PSEUDONYMIZATION_RULE,
    fixed = TRUE
  )
  result <- pseudonymizeTable(source_table, table_description, "target", salt = "test-salt")

  expect_false(identical(result$identifier_value[1], source_table$identifier_value[1]))
  expect_equal(result$identifier_value[2], source_table$identifier_value[2])
})

test_that("conditional rules honor explicit keep and redact fallbacks", {
  source_table <- data.table::data.table(
    identifier_type_system = c("https://example.test", "other"),
    identifier_type_code = c("GKV", "MR"),
    identifier_value = c("insurance-1", "record-2")
  )
  table_description <- data.table::data.table(
    RESOURCE = c("Patient", NA, NA),
    COLUMN_NAME = c("identifier_type_system", "identifier_type_code", "identifier_value"),
    FHIR_EXPRESSION = c(
      "identifier/type/coding/system",
      "identifier/type/coding/code",
      "identifier/value"
    ),
    PSEUDONYMIZATION_RULE = c(
      NA_character_,
      NA_character_,
      paste0(
        "redactIf(type.coding.system == \"https://example.test\" & ",
        "type.coding.code == \"GKV\"); keep"
      )
    )
  )

  result <- pseudonymizeTable(source_table, table_description, "Patient", salt = "test-salt")

  expect_true(is.na(result$identifier_value[1]))
  expect_equal(result$identifier_value[2], source_table$identifier_value[2])

  table_description$PSEUDONYMIZATION_RULE[3] <- paste0(
    "keepIf(type.coding.system == \"https://example.test\" & ",
    "type.coding.code == \"GKV\"); redact"
  )
  result <- pseudonymizeTable(source_table, table_description, "Patient", salt = "test-salt")

  expect_equal(result$identifier_value[1], source_table$identifier_value[1])
  expect_true(is.na(result$identifier_value[2]))
})

test_that("cryptoHash maxLength truncates generated hashes", {
  source_table <- data.table::data.table(id = "abc")
  table_description <- data.table::data.table(
    TABLE_NAME = "target",
    COLUMN_NAME = "id",
    PSEUDONYMIZATION_RULE = "cryptoHash(maxLength = 8)"
  )

  result <- pseudonymizeTable(source_table, table_description, "target", salt = "test-salt")

  expect_equal(nchar(result$id), 8L)

  table_description$PSEUDONYMIZATION_RULE <- "cryptoHash(8)"
  result <- pseudonymizeTable(source_table, table_description, "target", salt = "test-salt")

  expect_equal(nchar(result$id), 8L)
})

test_that("cryptoHash defaults to maxLength 32", {
  source_table <- data.table::data.table(id = "abc")
  table_description <- data.table::data.table(
    TABLE_NAME = "target",
    COLUMN_NAME = "id",
    PSEUDONYMIZATION_RULE = "cryptoHash"
  )

  result <- pseudonymizeTable(source_table, table_description, "target", salt = "test-salt")

  expect_equal(nchar(result$id), 32L)
})

test_that("empty rules default to keep and explicit table filtering is respected", {
  source_table <- data.table::data.table(id = "abc", value = "visible")
  table_description <- data.table::data.table(
    TABLE_NAME = c("other", "target", NA),
    COLUMN_NAME = c("id", "id", "value"),
    PSEUDONYMIZATION_RULE = c("keep", NA_character_, "keep")
  )

  result <- pseudonymizeTable(source_table, table_description, "target")

  expect_equal(result$id, "abc")
  expect_equal(result$value, "visible")
})

test_that("hashing rules require an explicit salt", {
  source_table <- data.table::data.table(id = "abc")
  table_description <- data.table::data.table(
    TABLE_NAME = "target",
    COLUMN_NAME = "id",
    PSEUDONYMIZATION_RULE = "cryptoHash"
  )

  expect_error(
    pseudonymizeTable(source_table, table_description, "target"),
    "salt must be provided"
  )
})

test_that("unsupported rules fail loudly", {
  source_table <- data.table::data.table(id = "abc")
  table_description <- data.table::data.table(
    TABLE_NAME = "target",
    COLUMN_NAME = "id",
    PSEUDONYMIZATION_RULE = "blur"
  )

  expect_error(
    pseudonymizeTable(source_table, table_description, "target"),
    "Unsupported PSEUDONYMIZATION_RULE"
  )
})
