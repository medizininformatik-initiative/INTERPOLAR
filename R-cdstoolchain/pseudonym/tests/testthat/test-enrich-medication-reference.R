test_that("enrichSnapshotMedicationReferenceTables adds medication codes and repeats rows", {
  medication <- data.table::data.table(
    med_id = c("med-1", "med-1", "med-1", "med-2"),
    med_code_system = c("http://atc", "http://rxnorm", "http://atc", "http://atc"),
    med_code_code = c("A01", "123", "A01", "B02")
  )
  medicationrequest <- data.table::data.table(
    medreq_id = c("req-1", "req-2", "req-3"),
    medreq_medicationreference_ref = c("Medication/med-1", "Medication/med-2", "Medication/missing")
  )
  medicationrequest_last_version <- data.table::data.table(
    medreq_id = "req-lv-1",
    medreq_medicationreference_ref = "Medication/med-1"
  )
  tables <- list(
    medication = medication,
    medication_last_version = medication,
    medicationrequest = medicationrequest,
    medicationrequest_last_version = medicationrequest_last_version,
    patient = data.table::data.table(pat_id = "pat-1")
  )

  result <- enrichSnapshotMedicationReferenceTables(tables)

  expect_equal(nrow(result$medicationrequest), 4)
  expect_equal(
    result$medicationrequest[result$medicationrequest$medreq_id == "req-1", "medreq_medication_code"][[1]],
    c("A01", "123")
  )
  expect_equal(
    result$medicationrequest[result$medicationrequest$medreq_id == "req-1", "medreq_medication_system"][[1]],
    c("http://atc", "http://rxnorm")
  )
  expect_equal(
    result$medicationrequest[result$medicationrequest$medreq_id == "req-2", "medreq_medication_code"][[1]],
    "B02"
  )
  expect_true(is.na(
    result$medicationrequest[result$medicationrequest$medreq_id == "req-3", "medreq_medication_code"][[1]]
  ))
  expect_equal(nrow(result$medicationrequest_last_version), 2)
  expect_false("medreq_medication_code" %in% names(result$patient))
})

test_that("enrichSnapshotMedicationReferenceTables supports configured medication reference tables", {
  medication <- data.table::data.table(
    med_id = "med-1",
    med_code_system = "http://atc",
    med_code_code = "A01"
  )
  tables <- list(
    medication = medication,
    medicationadministration = data.table::data.table(
      medadm_id = "adm-1",
      medadm_medicationreference_ref = "Medication/med-1"
    ),
    medicationstatement = data.table::data.table(
      medstat_id = "stat-1",
      medstat_medicationreference_ref = "Medication/med-1"
    )
  )

  result <- enrichSnapshotMedicationReferenceTables(tables)

  expect_equal(result$medicationadministration$medadm_medication_system, "http://atc")
  expect_equal(result$medicationadministration$medadm_medication_code, "A01")
  expect_equal(result$medicationstatement$medstat_medication_system, "http://atc")
  expect_equal(result$medicationstatement$medstat_medication_code, "A01")
})

test_that("enrichSnapshotMedicationReferenceTables leaves tables without reference columns unchanged", {
  tables <- list(
    medication = data.table::data.table(
      med_id = "med-1",
      med_code_system = "http://atc",
      med_code_code = "A01"
    ),
    medicationrequest = data.table::data.table(medreq_id = "req-1")
  )

  result <- enrichSnapshotMedicationReferenceTables(tables)

  expect_equal(result$medicationrequest, tables$medicationrequest)
})

test_that("enrichSnapshotMedicationReferenceTables keeps empty reference tables", {
  tables <- list(
    medication = data.table::data.table(
      med_id = "med-1",
      med_code_system = "http://atc",
      med_code_code = "A01"
    ),
    medicationrequest = data.table::data.table(
      medreq_id = character(),
      medreq_medicationreference_ref = character()
    )
  )

  result <- enrichSnapshotMedicationReferenceTables(tables)

  expect_equal(nrow(result$medicationrequest), 0)
  expect_true("medreq_medication_system" %in% names(result$medicationrequest))
  expect_true("medreq_medication_code" %in% names(result$medicationrequest))
})
