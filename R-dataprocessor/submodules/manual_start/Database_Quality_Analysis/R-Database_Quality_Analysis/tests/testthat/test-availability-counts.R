test_that("availability counts preserve distinct IDs, row conditions and empty inputs", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    "CREATE TEMP TABLE availability_fixture (id text, patient text, value text, quantity numeric, checked boolean, selected boolean);",
    "INSERT INTO availability_fixture VALUES ('a','p1',NULL,NULL,NULL,true), ('a','p1','filled',0,false,true), ('a','p1','filled',0,false,true), ('b','p1','',NULL,true,true), ('c','p2','filled',3,true,false), (NULL,'p3','filled',4,true,true), ('','p4','filled',5,true,true), ('d',NULL,'filled',6,true,true), ('e','','filled',7,true,true);"
  )
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "pg_temp", VIEW_NAME = "availability_fixture",
    TABLE_NAME = "availability_fixture",
    COLUMN_NAME = c("id", "patient", "value", "quantity", "checked", "selected"),
    DATA_TYPE = c("text", "text", "text", "numeric", "boolean", "boolean")
  )
  groups <- data.table::data.table(
    grouping_column = c("id", "patient", "id"),
    count_column = c("resources", "patients", "selected resources"),
    extra_condition = c(NA_character_, NA_character_, '"selected"')
  )
  query <- buildAvailabilityCountQuery(metadata, c("value", "quantity", "checked"), groups)
  actual <- runCodeSummaryFixtureQuery(fixture, query$query)
  expect_equal(as.numeric(actual[1]), c(4, 4, 3, 4, 4, 3, 5, 4, 4))
  expect_equal(query$alias_map$COLUMN_NAME, rep(c("value", "quantity", "checked"), each = 3))

  # Use the previous expression as an independent oracle for mixed NULL/empty rows.
  reference_parts <- vapply(seq_len(nrow(query$alias_map)), function(index) {
    column <- query$alias_map$COLUMN_NAME[[index]]
    group <- groups[(index - 1L) %% nrow(groups) + 1L]
    types <- getMetadataDataTypes(metadata)
    conditions <- c(
      getValueAvailableCondition(column, metadata, types),
      getValueAvailableCondition(group$grouping_column, metadata, types),
      group$extra_condition
    )
    conditions <- conditions[!is.na(conditions)]
    paste0(
      "COUNT(DISTINCT CASE WHEN ", paste(conditions, collapse = " AND "),
      " THEN ", quoteIdentifier(group$grouping_column), " END) AS ", query$alias_map$alias[[index]]
    )
  }, character(1))
  reference <- buildSelectQuery(reference_parts, "pg_temp.availability_fixture")
  expect_equal(actual, runCodeSummaryFixtureQuery(fixture, reference))

  filtered <- buildAvailabilityCountQuery(metadata, c("value", "quantity", "checked"), groups, '"selected"')
  expect_equal(
    runCodeSummaryFixtureQuery(fixture, filtered$query),
    runCodeSummaryFixtureQuery(fixture, paste0(reference, ' WHERE "selected"'))
  )
  empty <- buildAvailabilityCountQuery(metadata, c("value", "quantity", "checked"), groups, "false")
  expect_equal(as.numeric(runCodeSummaryFixtureQuery(fixture, empty$query)[1]), rep(0, 9))
})
