getEncounterReferenceColumnName <- function(resource_name) {
  resource_prefix <- etlutils::fhirdbGetResourceAbbreviation(resource_name)
  return(paste0(resource_prefix, "_encounter_ref"))
}

getEncounterCalculatedReferenceColumnName <- function(resource_name) {
  resource_prefix <- etlutils::fhirdbGetResourceAbbreviation(resource_name)
  return(paste0(resource_prefix, "_encounter_calculated_ref"))
}

createReferencesForEncounters <- function(encounters) {
  # add the both calculated columns
  encounters[, enc_partof_calculated_ref := NA_character_]
  encounters[, enc_diagnosis_condition_calculated_ref := NA_character_]

  # split Encounters by type code
  encounters_by_type <- list(einrichtungskontakt = encounters[enc_type_code == encounter_type[[1]]],
                             abteilungskontakt = encounters[enc_type_code == encounter_type[[2]]],
                             versorgungsstellenkontakt = encounters[enc_type_code == encounter_type[[3]]],
                             invalid = encounters[!(enc_type_code %in% encounter_type)])

  # cat a warning for every invalid Encounter
  if (nrow(encounters_by_type$invalid)) {
    msg <- "The Encounters with the following FHIR ID have no or an invalid type/code attribute and will be ignored:\n"
    msg <- paste0(msg, paste0("  ", encounters_by_type$invalid$enc_id, collapse = "\n"))
    etlutils::catWarningMessage(msg)
  }

  # cat warning message if there are no encounters of at least one type
  for (type_index in 1:3) {
    if (!nrow(encounters_by_type[[type_index]])) {
      msg <- paste0("No '", encounter_type[[type_index]], "' Encounters found!")
      etlutils::catWarningMessage(msg)
    }
  }

  # fill the enc_partof_calculated_ref column level by level
  # from existing part_of references
  for (i in 2:3) { # for each level except the first (einrichtungskontakt)
    encounters_of_lvl <- encounters_by_type[[i]]
    parent_encounters_of_lvl <- encounters_by_type[[i - 1]]
    if (nrow(parent_encounters_of_lvl)) {
      for (enc_index in seq_len(nrow(encounters_of_lvl))) {
        partof_ref <- encounters_of_lvl$enc_partof_ref[enc_index]
        if (!is.na(partof_ref)) { # direct copy
          encounters_of_lvl[enc_index, enc_partof_calculated_ref := partof_ref]
        }
      }
    }
    encounters_by_type[[i]] <- encounters_of_lvl
  }

  # fill the enc_partof_calculated_ref column level by level
  # from common_encounter_fhir_identifier_system
  if (etlutils::isSimpleNotEmptyString(common_encounter_fhir_identifier_system)) {
    for (enc_lvl in 2:3) { # for each level except the first (einrichtungskontakt)
      encounters_of_lvl <- encounters_by_type[[enc_lvl]]
      data.table::setorder(encounters_of_lvl, enc_id)
      parent_encounters_of_lvl <- encounters_by_type[[enc_lvl - 1]]
      if (nrow(parent_encounters_of_lvl)) {
        for (enc_index in seq_len(nrow(encounters_of_lvl))) {
          if (is.na(encounters_of_lvl$enc_partof_calculated_ref[enc_index])) {
            identifier_system <- encounters_of_lvl$enc_identifier_system[enc_index]
            if (identifier_system %in% common_encounter_fhir_identifier_system) {
              patient_ref <- encounters_of_lvl$enc_patient_ref[enc_index]
              identifier_value <- encounters_of_lvl$enc_identifier_value[enc_index]
              parent_candidate_ids <- parent_encounters_of_lvl[enc_patient_ref %in% patient_ref & enc_identifier_value %in% identifier_value, enc_id]
              parent_candidate_id <- unique(parent_candidate_ids)
              if (length(parent_candidate_id) == 1) {
                parent_encounter_ref <- etlutils::fhirdataGetEncounterReference(parent_candidate_id)
                encounters_of_lvl[enc_index, enc_partof_calculated_ref := parent_encounter_ref]
                if (enc_index > 1) {
                  for (pre_enc_index in (enc_index - 1):1) {
                    if (encounters_of_lvl[pre_enc_index, enc_id] == encounters_of_lvl[enc_index, enc_id]) {
                      encounters_of_lvl[pre_enc_index, enc_partof_calculated_ref := parent_encounter_ref]
                    }
                  }
                }
                if (enc_index < nrow(encounters_of_lvl)) {
                  for (post_enc_index in (enc_index + 1):nrow(encounters_of_lvl)) {
                    if (encounters_of_lvl[post_enc_index, enc_id] == encounters_of_lvl[enc_index, enc_id]) {
                      encounters_of_lvl[post_enc_index, enc_partof_calculated_ref := parent_encounter_ref]
                    }
                  }
                }
              }
            }
          }
        }
      }
      encounters_by_type[[enc_lvl]] <- encounters_of_lvl
    }
  }

  # fill the enc_partof_calculated_ref column level by level
  # from timestamps
  for (i in 2:3) { # for each level except the first (einrichtungskontakt)
    encounters_of_lvl <- encounters_by_type[[i]]
    parent_encounters_of_lvl <- encounters_by_type[[i - 1]]
    if (nrow(parent_encounters_of_lvl)) {
      for (enc_index in seq_len(nrow(encounters_of_lvl))) {
        if (is.na(encounters_of_lvl$enc_partof_calculated_ref[enc_index])) {
          patient_ref <- encounters_of_lvl$enc_patient_ref[enc_index]
          candidate_parent_encounters <- parent_encounters_of_lvl[enc_patient_ref == patient_ref]
          if (nrow(candidate_parent_encounters)) {
            # find the best fitting parent encounter by timestamp
            child_start <- encounters_of_lvl$enc_period_start[enc_index]
            child_end <- encounters_of_lvl$enc_period_end[enc_index]
            # filter candidates that enclose the child encounter
            # Keep candidates that start no later than the child start.
            # Compare end times only if BOTH ends are present; otherwise ignore end.
            candidate_parent_encounters <- candidate_parent_encounters[
              enc_period_start <= child_start &
                (is.na(child_end) | is.na(enc_period_end) | enc_period_end >= child_end)
            ]
            if (nrow(candidate_parent_encounters)) {
              time_diff <- abs(as.numeric(difftime(
                candidate_parent_encounters$enc_period_start,
                child_start,
                units = "secs"
              )))
              idx <- which.min(time_diff)
              best_fit_parent <- candidate_parent_encounters[idx]
              encounters_of_lvl[enc_index, enc_partof_calculated_ref := paste0("Encounter/", best_fit_parent$enc_id)]
            }
          }
        }
      }
    }
    encounters_by_type[[i]] <- encounters_of_lvl
  }
  # update the encounters table in the list
  encounters <- data.table::rbindlist(encounters_by_type)
  # fill all abteilungskontakt and versorgungstellenkontakt Encounters NA partof refs with "invalid"
  encounters[is.na(enc_partof_calculated_ref) & (enc_type_code %in% encounter_type[2:3]),
             enc_partof_calculated_ref := "invalid"]

  # Start: create enc_main_encounter_calculated_ref

  # Compute main-encounter reference per enc_id (handles duplicated enc_id rows)
  encounters[, enc_main_encounter_calculated_ref := NA_character_]
  # Unique enc_ids (FHIR-cracked table can have duplicates per enc_id)
  ids <- unique(encounters$enc_id)
  # Memoization to avoid repeated walks
  resolve_cache <- new.env(parent = emptyenv())
  # Resolve top-most encounter (max depth = 3), return "Encounter/<id>" or "invalid"
  resolveMainRef <- function(id) {
    # Return cached if present
    if (exists(id, envir = resolve_cache, inherits = FALSE)) {
      return(get(id, envir = resolve_cache, inherits = FALSE))
    }
    walk_id <- id
    main_id <- NA_character_

    for (hop in 1:3) {
      current_row <- encounters[enc_id == walk_id]
      if (nrow(current_row) == 0L) {  # unknown id
        main_id <- NA_character_
        break
      }
      current_row <- current_row[1]  # take any row for this enc_id
      partof_ref <- current_row$enc_partof_calculated_ref
      # Reached top-level (no parent)
      if (is.na(partof_ref)) {
        main_id <- walk_id
        break
      }
      # Go to parent; abort on "invalid" or empty
      parent_id <- etlutils::fhirdataExtractIDs(partof_ref)
      if (identical(parent_id, "invalid") || length(parent_id) == 0L || is.na(parent_id)) {
        main_id <- NA_character_
        break
      }
      walk_id <- parent_id
    }
    main_ref <- if (is.na(main_id)) "invalid" else etlutils::fhirdataGetEncounterReference(main_id)
    assign(id, main_ref, envir = resolve_cache)
    main_ref
  }
  # Build mapping enc_id -> main_ref and join back
  main_map <- data.table::data.table(
    enc_id = ids,
    enc_main_encounter_calculated_ref = vapply(ids, resolveMainRef, FUN.VALUE = character(1))
  )
  encounters[
    main_map,
    on = .(enc_id),
    enc_main_encounter_calculated_ref := i.enc_main_encounter_calculated_ref
  ]
  # End: create enc_main_encounter_calculated_ref

  return(encouters)
}

createReferencesForResource <- function(encounters, resource_name, resource_table, start_column_names) {
  if (!is.null(resource_table) && nrow(resource_table) > 0) {
    ref_col_name <- getEncounterReferenceColumnName(resource_name)
    calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
    # add the calculated reference column
    resource_table[, (calculated_ref_col_name) := NA_character_]
    for (row_index in seq_len(nrow(resource_table))) {
      resource_encounter_ref <- resource_table[[ref_col_name]][row_index]
      if (!is.na(resource_encounter_ref)) {
        resource_encounter_id <- etlutils::fhirdataExtractIDs(resource_encounter_ref)
        # the encounter of the calculated reference must be an einrichtungskontakt -> trace back via partOf
        encounter_resource <- encounters[enc_id == resource_encounter_id]
        parent_encounter_id <- NA_character_
        while (nrow(encounter_resource)) {
          # we just take the very first because all should have the same values in the columns we are interested in
          encounter_resource <- encounter_resource[1]
          partof_ref <- encounter_resource$enc_partof_calculated_ref
          if (is.na(partof_ref)) {
            parent_encounter_id <- encounter_resource$enc_id
            break
          }
          parent_encounter_id <- etlutils::fhirdataExtractIDs(partof_ref)
          if (identical(parent_encounter_id, "invalid")) {
            parent_encounter_id <- NA_character_
            break
          }
          encounter_resource <- encounters[enc_id == parent_encounter_id]
        }
        if (!is.na(parent_encounter_id)) {
          encounter_ref <- etlutils::fhirdataGetEncounterReference(parent_encounter_id)
          resource_table[row_index, (calculated_ref_col_name) := encounter_ref]
        }
      }
      # get the reference from the timestamps
      if (is.na(resource_table[[calculated_ref_col_name]][row_index])) {
        patient_ref_col_name <- paste0(getResourcePrefix(start_column_names[1]), "_patient_ref")
        patient_ref <- resource_table[[patient_ref_col_name]][row_index]
        candidate_encounters <- encounters[enc_patient_ref == patient_ref & enc_type_code == encounter_type[[1]]]
        if (nrow(candidate_encounters)) {
          # find the best fitting encounter by timestamp
          for (start_column_name in start_column_names) {
            resource_start_time <- resource_table[[start_column_name]][row_index]
            if (!is.na(resource_start_time)) {
              # filter candidates that enclose the resource timestamp
              candidate_encounters_filtered <- candidate_encounters[
                enc_period_start <= resource_start_time & (is.na(enc_period_end) | enc_period_end >= resource_start_time)
              ]
              if (nrow(candidate_encounters_filtered)) {
                # If multiple candidates remain, take the one with the closest start time (no side-effect column)
                time_diff <- abs(as.numeric(difftime(
                  candidate_encounters_filtered$enc_period_start,
                  resource_start_time,
                  units = "secs"
                )))
                idx <- which.min(time_diff)
                best_fit_encounter <- candidate_encounters_filtered[idx]
                resource_table[row_index, (calculated_ref_col_name) := paste0("Encounter/", best_fit_encounter$enc_id)]
                break  # Exit the for loop over start_column_names
              }
            }
          }
        }
      }
      # if the reference is still NA -> mark it as invalid
      if (is.na(resource_table[[calculated_ref_col_name]][row_index])) {
        resource_table[row_index, (calculated_ref_col_name) := "invalid"]
      }
    }
  }
  return(resource_table)
}

