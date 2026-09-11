consentProvisionFixture <- function(
  code, type = "permit", start = "2020-01-01", end = "2025-12-31",
  consent_id = "a", declared_at = "2020-01-01 12:00:00", status = "active"
) {
  data.table::data.table(
    consent_id = consent_id, declared_at = as.POSIXct(declared_at, tz = "UTC"),
    status = status, system = BROAD_CONSENT_CODE_SYSTEM,
    code = paste0(BROAD_CONSENT_CODE_PREFIX, code), type = type,
    start = as.Date(start), end = as.Date(end)
  )
}

consentDocumentFixture <- function(consent_id = "a", declared_at = "2020-01-01 12:00:00") {
  data.table::rbindlist(list(
    consentProvisionFixture("6", consent_id = consent_id, declared_at = declared_at),
    consentProvisionFixture("8", end = "2050-01-01", consent_id = consent_id, declared_at = declared_at)
  ))
}
