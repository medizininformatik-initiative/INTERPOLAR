testthat::test_that("snapshot Consent conversion preserves inactive documents and provision pairs", {
  testthat::local_mocked_bindings(
    runLevel3 = function(message, process, ...) force(process),
    writeDebugExcelFile = function(...) stop("Snapshot refresh must not write unpseudonymized debug workbooks"),
    .package = "etlutils"
  )
  bundle <- fhircrackr::fhir_bundle_list(list(xml2::read_xml(paste0(
    '<Bundle xmlns="http://hl7.org/fhir"><type value="searchset"/><entry><resource><Consent>',
    '<id value="c1"/><meta><versionId value="2"/><lastUpdated value="2026-09-15T10:00:00Z"/></meta>',
    '<status value="inactive"/><patient><reference value="Patient/p1"/></patient>',
    '<provision><type value="deny"/><provision><type value="permit"/>',
    '<code><coding><system value="urn:a"/><code value="6"/></coding></code></provision>',
    '<provision><type value="deny"/><code><coding><system value="urn:b"/><code value="8"/>',
    "</coding></code></provision></provision></Consent></resource></entry></Bundle>"
  ))))
  rows <- convertSnapshotConsentBundles(bundle)
  testthat::expect_true(all(rows$cons_status == "inactive"))
  testthat::expect_true(all(rows$cons_patient_ref == "Patient/p1"))
  testthat::expect_s3_class(rows$cons_meta_lastupdated, "POSIXct")
  testthat::expect_setequal(paste(
    rows$cons_provision_provision_code_system,
    rows$cons_provision_provision_code_code, rows$cons_provision_provision_type
  ), c("urn:a 6 permit", "urn:b 8 deny"))
  empty <- fhircrackr::fhir_bundle_list(list(xml2::read_xml('<Bundle xmlns="http://hl7.org/fhir"><type value="searchset"/><total value="0"/></Bundle>')))
  testthat::expect_equal(nrow(suppressWarnings(convertSnapshotConsentBundles(empty))), 0L)
})
