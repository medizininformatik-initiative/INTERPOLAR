debugAddPatientIdentifier <- function(resource_tables) {

  # Function to add a new value separated by " ~ "
  addValue <- function(value, replace_for_old_value = NA, new_value = NA, old_value_suffix = "", new_value_suffix = "") {
    # Extrahiere den Text innerhalb der Klammern und den Rest
    match <- regmatches(value, regexec("\\[(.*)\\](.*)", value))
    if (length(match[[1]]) == 3) {
      numbers <- match[[1]][2]
      text <- match[[1]][3]

      # Splitten der Nummern und Umwandeln in Integer
      number_parts <- unlist(strsplit(numbers, "\\."))
      number_parts <- as.integer(number_parts)

      # Erhöhen der ersten Nummer um eins
      number_parts[1] <- number_parts[1] + 1

      # Erstelle die neue Nummernfolge
      new_numbers <- paste(number_parts, collapse = ".")

      # Erstelle den neuen Wert
      old_value <- if (etlutils::isSimpleNA(replace_for_old_value)) text else replace_for_old_value
      new_value <- if (etlutils::isSimpleNA(new_value)) text else new_value
      result <- paste0("[", numbers, "]", text, old_value_suffix, " ~ [", new_numbers, "]", text, new_value_suffix)
      return(result)
    } else {
      # Falls das Format nicht stimmt, gib den ursprünglichen Wert zurück
      return(value)
    }
  }

  old_value_suffix <- "_aaa"
  new_value_suffix <- "_bbb"

  # Add a second value to all values pat_identifier_system
  resource_tables$Patient[, pat_identifier_system := sapply(pat_identifier_system, function(x) addValue(x, old_value_suffix, new_value_suffix))]
  # Add a second value to all values pat_identifier_system
  resource_tables$Patient[, pat_identifier_value := sapply(pat_identifier_value, function(x) addValue(x, old_value_suffix, new_value_suffix))]

  return(resource_tables)

}

debugAddPatient <- function(Patient, patient_IDs_per_ward) {
  addRow <- function(dt, old_string, new_string) {
    dt <- etlutils::addEmptyRows(dt, 1, "end")
    dt[.N, names(dt) := dt[.N - 1]]
    dt[.N, names(dt) := lapply(.SD, function(x) gsub(old_string, new_string, x))]
    return(dt)
  }

  Patient <- addRow(Patient, "0003", "0004")
  Patient[.N, pat_identifier_type_code := paste0(Patient[.N - 1, pat_identifier_type_code], "P")]

  pid <- sub("^\\[[^]]*\\]", "", Patient[.N, pat_id])
  pid <- paste0("Patient/", pid)

  patient_IDs_per_ward[[length(patient_IDs_per_ward)]] <- append(patient_IDs_per_ward[[length(patient_IDs_per_ward)]], pid)

  return(etlutils::namedListByParam(Patient, patient_IDs_per_ward))
}
