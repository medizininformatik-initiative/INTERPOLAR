test_that("masking distinguishes excluded current and explicitly referenced historical versions", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  targets <- basename(tempfile("bc_targets_"))
  sources <- basename(tempfile("bc_references_"))
  on.exit(DBI::dbRemoveTable(connection, targets), add = TRUE)
  on.exit(DBI::dbRemoveTable(connection, sources), add = TRUE)
  DBI::dbWriteTable(connection, targets, data.frame(
    resource_type = "Encounter", resource_id = "e",
    version_id = c("1", "2"), retained = c(TRUE, FALSE), is_current = c(FALSE, TRUE)
  ), temporary = TRUE)
  values <- c(
    NA, "invalid", "Encounter/absent", "Encounter/e", "e", "[1]Encounter/e",
    "Encounter/e/_history/1", "Encounter/e/_history/2", "Encounter/e/_history/2/invalid"
  )
  DBI::dbWriteTable(connection, sources, data.frame(row = seq_along(values), obs_encounter_ref = values), temporary = TRUE)
  predicate <- buildBroadConsentReferenceMaskPredicate(
    connection, "obs_encounter_ref", "Observation",
    snapshotQualifiedName(connection, targets)
  )
  masked <- DBI::dbGetQuery(connection, paste0(
    "SELECT ", predicate, " AS masked FROM ",
    snapshotQualifiedName(connection, sources), " s ORDER BY s.row"
  ))$masked
  expect_equal(which(masked %in% TRUE), c(4L, 5L, 6L, 8L))
  expect_equal(DBI::dbReadTable(connection, sources)$obs_encounter_ref, values)
})

test_that("calculated hierarchy references use the same target types", {
  expect_equal(getBroadConsentReferenceType("enc_main_encounter_calculated_ref", "Encounter"), "Encounter")
  expect_equal(getBroadConsentReferenceType("enc_partof_calculated_ref", "Encounter"), "Encounter")
  expect_equal(getBroadConsentReferenceType("enc_diagnosis_condition_calculated_ref", "Encounter"), "Condition")
  expect_equal(getBroadConsentReferenceType("obs_encounter_calculated_ref", "Observation"), "Encounter")
})
