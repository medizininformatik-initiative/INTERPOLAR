debugAddMultiplePatientLines <- function(patients_from_database) {
  # Add new rows with a changed postal code to test the following code line which should
  # identify one valid Identifier.value from one patient_id (= source record ID).
  new_row_count <- 2 # number of rows to add
  patients_from_database <- etlutils::addEmptyRows(patients_from_database, new_row_count, "end")
  for (i in 1:new_row_count) {
    # first duplicate the last 'new_row_count' lines
    i_source <- nrow(patients_from_database) - (2 * new_row_count) + i
    i_target <- i_source + new_row_count
    patients_from_database[i_target] <- patients_from_database[i_source]
  }
  # now change the postal code and increase the patient_id = db internal record id number
  new_column_indices <- (nrow(patients_from_database) - new_row_count + 1):nrow(patients_from_database)
  patients_from_database[new_column_indices, pat_address_postalcode := etlutils::reverseString(pat_address_postalcode)]
  patients_from_database[new_column_indices, pat_address_postalcode := etlutils::reverseString("ABC")]
  patients_from_database[new_column_indices, patient_id := patient_id + 1]
  return(patients_from_database)
}
