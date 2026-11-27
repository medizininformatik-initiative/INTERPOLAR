test_that("the resource loader queries Patient by bare ID and linked resources by reference", {
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) query,
    .package = "etlutils"
  )
  patient_query <- getResourcesFromDB("Patient", c("pat_id", "pat_gender"), c("p1", "Patient/p2"))
  expect_match(patient_query, "WHERE pat_id IN ('p1', 'p2')", fixed = TRUE)
  prefixes <- c(
    Encounter = "enc", Condition = "con", Observation = "obs", Procedure = "proc",
    MedicationRequest = "medreq", MedicationAdministration = "medadm", MedicationStatement = "medstat"
  )
  for (resource in names(prefixes)) {
    prefix <- prefixes[[resource]]
    query <- getResourcesFromDB(resource, paste0(prefix, "_id"), c("p1", "Patient/p2"))
    expect_match(query, paste0("WHERE ", prefix, "_patient_ref IN ('Patient/p1', 'Patient/p2')"), fixed = TRUE)
  }
})
