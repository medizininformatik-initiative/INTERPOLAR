# Enable data.table dispatch in the package without attaching it.
.datatable.aware <- TRUE

#' Link known station assignments to Encounter data
#'
#' @param pids_per_ward Station, patient and Encounter assignments.
#' @param encounters Latest Encounter data for the related cases.
#'
#' @return A data.table retaining all assignments, with Encounter details and an
#'   `encounter_found` flag. Multiple codings and station assignments are retained.
#'
linkCohortStationContacts <- function(pids_per_ward, encounters) {
  assignments <- data.table::copy(data.table::as.data.table(pids_per_ward))
  details <- data.table::copy(data.table::as.data.table(encounters))
  if (!nrow(details)) {
    assignments[, encounter_found := FALSE]
    for (column_name in c("enc_id", "enc_patient_ref", "enc_main_encounter_calculated_ref", "enc_type_system", "enc_type_code")) {
      data.table::set(assignments, j = column_name, value = NA_character_)
    }
    for (column_name in c("enc_period_start", "enc_period_end")) {
      data.table::set(assignments, j = column_name, value = as.POSIXct(NA_character_, tz = "UTC"))
    }
  } else {
    # Keep reference extraction row-aligned; the utility otherwise removes duplicates.
    details[, patient_id := etlutils::fhirdataExtractIDs(enc_patient_ref, unique = FALSE)]
    details[, encounter_id := enc_id]
    details[, encounter_found := TRUE]
    # Missing join keys must not match each other.
    details <- details[!is.na(patient_id) & nzchar(patient_id) &
      !is.na(encounter_id) & nzchar(encounter_id)]
    assignments <- merge(
      assignments, unique(details),
      by = c("patient_id", "encounter_id"),
      all.x = TRUE, sort = FALSE, allow.cartesian = TRUE
    )
    assignments[is.na(encounter_found), encounter_found := FALSE]
  }
  unmatched <- unique(assignments[encounter_found == FALSE, c("patient_id", "encounter_id"), with = FALSE])
  if (nrow(unmatched)) {
    warning(nrow(unmatched), " known station contact(s) could not be linked by patient and Encounter ID.", call. = FALSE)
  }
  if ("enc_period_start" %in% names(assignments) && any(assignments$encounter_found & is.na(assignments$enc_period_start))) {
    warning("Linked station contacts contain missing start timestamps; chronology requires clarification.", call. = FALSE)
  }
  assignments
}

#' Select the first known INTERPOLAR contact of each hospital case
#'
#' @param contacts Linked assignments including original registration metadata.
#' @return One contact per patient/case. Invalid chronology raises an error rather
#'   than silently selecting a later contact. Selection precedes phase/ward filters.
selectFirstCohortContacts <- function(contacts) {
  contacts <- data.table::copy(data.table::as.data.table(contacts))
  required <- c(
    "patient_id", "encounter_id", "ward_name", "encounter_found",
    "enc_main_encounter_calculated_ref", "enc_period_start", "enc_period_end",
    "input_datetime", "pids_per_ward_id"
  )
  if (!all(required %in% names(contacts))) {
    stop(
      "First-contact selection lacks required columns: ",
      paste(setdiff(required, names(contacts)), collapse = ", ")
    )
  }
  contacts[, case_id := etlutils::fhirdataExtractIDs(
    enc_main_encounter_calculated_ref,
    unique = FALSE
  )]
  invalid <- !contacts$encounter_found | is.na(contacts$case_id) |
    !nzchar(contacts$case_id) | is.na(contacts$enc_period_start) |
    is.na(contacts$input_datetime) | is.na(contacts$pids_per_ward_id)
  if (any(invalid)) {
    affected <- contacts[which(invalid)]
    missing_case <- is.na(affected$case_id) | !nzchar(affected$case_id)
    # Counts describe linked rows, so causes can overlap and codings can repeat contacts.
    counts <- c(
      encounter_not_found = sum(!affected$encounter_found),
      missing_case_id = sum(missing_case),
      missing_contact_start = sum(is.na(affected$enc_period_start)),
      missing_input_datetime = sum(is.na(affected$input_datetime)),
      missing_pids_per_ward_id = sum(is.na(affected$pids_per_ward_id))
    )
    known_contacts <- affected[!is.na(patient_id) & nzchar(patient_id) &
      !is.na(encounter_id) & nzchar(encounter_id)]
    known_cases <- affected[!missing_case & !is.na(patient_id) & nzchar(patient_id)]
    stop(
      sum(invalid), " known IP assignment row(s) lack data required for first-contact selection.\n",
      "Affected distinct contacts (patient/Encounter): ",
      data.table::uniqueN(known_contacts, by = c("patient_id", "encounter_id")),
      "; rows without complete contact key: ", nrow(affected) - nrow(known_contacts), "\n",
      "Affected identifiable cases (patient/case): ",
      data.table::uniqueN(known_cases, by = c("patient_id", "case_id")),
      "; rows without complete case key: ", nrow(affected) - nrow(known_cases), "\n",
      "Causes (linked row counts; may overlap): ",
      paste(names(counts), counts, sep = "=", collapse = ", "),
      call. = FALSE
    )
  }
  # Codings do not identify distinct contacts. Conflicting contact intervals do.
  columns <- c(
    "patient_id", "case_id", "encounter_id", "ward_name",
    "enc_period_start", "enc_period_end", "input_datetime", "pids_per_ward_id"
  )
  contacts <- unique(contacts[, ..columns])
  interval_columns <- c(
    "patient_id", "case_id", "encounter_id", "ward_name",
    "enc_period_start", "enc_period_end"
  )
  intervals <- unique(contacts[, ..interval_columns])
  if (anyDuplicated(intervals, by = c("patient_id", "case_id", "encounter_id", "ward_name"))) {
    stop("Known IP contacts have conflicting intervals or case assignments.")
  }
  data.table::setorderv(
    contacts,
    c("patient_id", "case_id", "enc_period_start", "input_datetime", "pids_per_ward_id")
  )
  contacts[!duplicated(contacts, by = c("patient_id", "case_id"))]
}


#' Save unlinked assignments locally and retain linked contacts for analysis
#'
#' Identifiers belong in this local diagnostic file, outside aggregate reports.
#' An unmatched assignment does not prove that the source resource was deleted.
#' @param contacts Linked station assignments.
#' @param directory Local diagnostic output directory.
#' @return Contacts with a successful patient/Encounter link, in original order.
retainLinkedCohortContacts <- function(contacts, directory) {
  unmatched <- contacts[encounter_found == FALSE]
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(directory, "unlinked_station_contacts.csv")
  # Rewrite even for zero rows so an earlier run cannot leave stale identifiers.
  data.table::fwrite(unmatched, path, na = "NA")
  message(
    "Cohort Description: excluded ", nrow(unmatched),
    " unlinked station assignment row(s); local diagnostic file: ", path
  )
  contacts[encounter_found == TRUE]
}
