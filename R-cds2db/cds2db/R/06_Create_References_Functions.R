ENCOUNTER_TYPES <- c("einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt")

getEncounterReferenceColumnName <- function(resource_name) {
  return(etlutils::fhirdbGetColumns(resource_name, "_encounter_ref"))
}

getEncounterCalculatedReferenceColumnName <- function(resource_name) {
  return(etlutils::fhirdbGetColumns(resource_name, "_encounter_calculated_ref"))
}

createReferencesForEncounters <- function(encounters, common_encounter_fhir_identifier_system) {

  # add the both calculated columns
  encounters[, enc_partof_calculated_ref := NA_character_]
  #encounters[, enc_diagnosis_condition_calculated_ref := NA_character_] # currently not used

  # split Encounters by type code
  encounters_by_type <- list(einrichtungskontakt = encounters[enc_type_code == ENCOUNTER_TYPES[[1]]],
                             abteilungskontakt = encounters[enc_type_code == ENCOUNTER_TYPES[[2]]],
                             versorgungsstellenkontakt = encounters[enc_type_code == ENCOUNTER_TYPES[[3]]])

  # cat warning message if there are no encounters of at least one type
  for (type_index in 1:3) {
    if (!nrow(encounters_by_type[[type_index]])) {
      msg <- paste0("No '", ENCOUNTER_TYPES[[type_index]], "' Encounters found!")
      etlutils::catWarningMessage(msg)
    }
  }

  etlutils::runLevel2("Fill the enc_partof_calculated_ref column level by level", {

    etlutils::runLevel2("... from existing partOf references", {
      # For levels 2 and 3 (children), copy existing partOf into calculated, if not already filled
      for (enc_lvl in 2:3) {
        encounters_of_lvl <- encounters_by_type[[enc_lvl]]

        # Vectorized copy: where original partOf exists AND calculated is still NA
        idx <- !is.na(encounters_of_lvl$enc_partof_ref) &
          is.na(encounters_of_lvl$enc_partof_calculated_ref)

        if (any(idx)) {
          encounters_of_lvl[idx, enc_partof_calculated_ref := enc_partof_ref]
        }

        encounters_by_type[[enc_lvl]] <- encounters_of_lvl
      }
    })

    # --- Fill enc_partof_calculated_ref from common_encounter_fhir_identifier_system ---
    etlutils::runLevel2("... from common_encounter_fhir_identifier_system", {
      # Only run if a non-empty identifier system filter is provided
      if (etlutils::isSimpleNotEmptyString(common_encounter_fhir_identifier_system)) {
        for (enc_lvl in 2:3) {  # levels: 2 = abteilungskontakt, 3 = versorgungsstellenkontakt
          encounters_of_lvl        <- encounters_by_type[[enc_lvl]]
          parent_encounters_of_lvl <- encounters_by_type[[enc_lvl - 1]]

          # Perform work only if there are parents
          if (nrow(parent_encounters_of_lvl)) {

            # --- Children candidates: not yet assigned, correct system, and have patient+identifier value ---
            child_dt <- encounters_of_lvl[
              is.na(enc_partof_calculated_ref) &
                enc_identifier_system %in% common_encounter_fhir_identifier_system &
                !is.na(enc_patient_ref) & !is.na(enc_identifier_value),
              .(enc_id, enc_patient_ref, enc_identifier_system, enc_identifier_value)
            ]

            # Only continue if there are candidate children
            if (nrow(child_dt)) {

              # --- Parent candidates: correct system and have patient+identifier value ---
              parent_dt <- parent_encounters_of_lvl[
                enc_identifier_system %in% common_encounter_fhir_identifier_system &
                  !is.na(enc_patient_ref) & !is.na(enc_identifier_value),
                .(enc_id, enc_patient_ref, enc_identifier_system, enc_identifier_value)
              ]

              # Only continue if there are candidate parents
              if (nrow(parent_dt)) {

                # --- Add indexes (fast lookup on the join keys) ---
                data.table::setindexv(child_dt,  c("enc_patient_ref", "enc_identifier_system", "enc_identifier_value"))
                data.table::setindexv(parent_dt, c("enc_patient_ref", "enc_identifier_system", "enc_identifier_value"))

                # --- Compress parents to unique candidate per (patient, system, value) and mark ambiguous groups ---
                parent_unique <- parent_dt[
                  ,
                  .(
                    n_parents = data.table::uniqueN(enc_id),
                    parent_id = unique(enc_id)[1L]  # arbitrary stable pick if unique
                  ),
                  by = .(enc_patient_ref, enc_identifier_system, enc_identifier_value)
                ]

                # Keep only key-combinations that identify exactly one parent
                parent_unique <- parent_unique[n_parents == 1L]

                # Only continue if there are unique parent mappings
                if (nrow(parent_unique)) {

                  # --- Join children to unique parents on (patient, system, value) ---
                  matched <- parent_unique[
                    child_dt,
                    on = .(enc_patient_ref, enc_identifier_system, enc_identifier_value),
                    nomatch = 0L
                  ]
                  # matched has: parent columns + i.enc_id (child id)

                  # Only continue if there are matches
                  if (nrow(matched)) {
                    # --- Build mapping enc_id -> computed partOf reference (propagates to all duplicate rows) ---
                    map <- unique(matched[, .(
                      enc_id,
                      enc_partof_calculated_ref = paste0("Encounter/", parent_id)
                    )], by = "enc_id")

                    # --- Update in place by reference via join on enc_id ---
                    encounters_of_lvl[
                      map,
                      on = .(enc_id),
                      enc_partof_calculated_ref := i.enc_partof_calculated_ref
                    ]
                  }
                }
              }
            }
          }

          # Write-back the current level
          encounters_by_type[[enc_lvl]] <- encounters_of_lvl
        }
      }
    })

    # --- Fill enc_partof_calculated_ref from timestamps (per child row, O(K * log P) with indexes) ---
    etlutils::runLevel2("... from timestamps", {
      for (enc_lvl in 2:3) {  # 2 = abteilungskontakt, 3 = versorgungsstellenkontakt
        encounters_of_lvl        <- encounters_by_type[[enc_lvl]]
        parent_encounters_of_lvl <- encounters_by_type[[enc_lvl - 1]]

        # Only proceed if we have parent rows
        if (nrow(parent_encounters_of_lvl)) {
          # --- Children: only those still unresolved and with patient + start present ---
          child_dt <- encounters_of_lvl[
            is.na(enc_partof_calculated_ref) &
              !is.na(enc_patient_ref) &
              !is.na(enc_period_start),
            .(
              child_id    = enc_id,
              enc_patient_ref,
              child_start = enc_period_start,
              child_end   = enc_period_end
            )
          ]

          if (nrow(child_dt)) {
            # --- Parents: same patient domain, with start present (end optional) ---
            parent_dt <- parent_encounters_of_lvl[
              !is.na(enc_patient_ref) & !is.na(enc_period_start),
              .(
                parent_id   = enc_id,
                enc_patient_ref,
                # parent start and parent end
                p_start     = enc_period_start,
                p_end       = enc_period_end
              )
            ]

            if (nrow(parent_dt)) {
              # Index for faster joins on patient
              data.table::setindexv(child_dt,  "enc_patient_ref")
              data.table::setindexv(parent_dt, "enc_patient_ref")

              # --- Case A: both ends present → enforce p_end >= child_end ---
              children_with_end <- child_dt[!is.na(child_end)]
              parents_with_end  <- parent_dt[!is.na(p_end)]

              matches_A <- parents_with_end[
                children_with_end,
                on = .(enc_patient_ref, p_start <= child_start, p_end >= child_end),
                nomatch = 0L,
                allow.cartesian = TRUE
              ]

              # --- Case B: missing end on either side → ignore end, only p_start <= child_start ---
              children_missing_end <- child_dt[is.na(child_end)]
              parents_missing_end  <- parent_dt[is.na(p_end)]

              # B1: child end is NA (parent end arbitrary)
              matches_B1 <- parent_dt[
                children_missing_end,
                on = .(enc_patient_ref, p_start <= child_start),
                nomatch = 0L,
                allow.cartesian = TRUE
              ]

              # B2: parent end is NA (child end present)
              matches_B2 <- parents_missing_end[
                children_with_end,
                on = .(enc_patient_ref, p_start <= child_start),
                nomatch = 0L,
                allow.cartesian = TRUE
              ]

              # Combine all candidate matches
              matched <- data.table::rbindlist(list(matches_A, matches_B1, matches_B2), use.names = TRUE, fill = TRUE)

              if (nrow(matched)) {
                # Pick best parent per child by smallest |p_start - child_start|
                matched[
                  , time_diff := abs(as.numeric(difftime(p_start, child_start, units = "secs")))
                ]

                best_per_child <- matched[
                  order(time_diff)
                ][
                  , .SD[1L], by = child_id
                ]

                # Build mapping child_id -> "Encounter/<parent_id>"
                map <- best_per_child[
                  , .(enc_id = child_id, enc_partof_calculated_ref = paste0("Encounter/", parent_id))
                ]

                # Update encounters_of_lvl in place for all rows with that enc_id
                encounters_of_lvl[
                  map,
                  on = .(enc_id),
                  enc_partof_calculated_ref := i.enc_partof_calculated_ref
                ]
              }
            }
          }
        }

        # Single write-back for this level
        encounters_by_type[[enc_lvl]] <- encounters_of_lvl
      }
    })

  })

  # Recombine levels first
  encounters <- data.table::rbindlist(encounters_by_type)

  # Replace everything from here (old invalid-mark + runLevel2 main-calc)
  # with the optimized block I sent:
  etlutils::runLevel2("... finalize encounters (invalid + main encounter)", {
    # mark invalid for levels 2/3
    encounters[
      is.na(enc_partof_calculated_ref) & (enc_type_code %in% ENCOUNTER_TYPES[2:3]),
      enc_partof_calculated_ref := "invalid"
    ]

    # compute enc_main_encounter_calculated_ref (vectorized, ≤3 hops)
    parent_map <- encounters[, .(enc_id, enc_partof_calculated_ref)][
      , parent_id := data.table::fifelse(
        is.na(enc_partof_calculated_ref), NA_character_,
        data.table::fifelse(
          enc_partof_calculated_ref == "invalid", "invalid",
          sub("^.*/", "", enc_partof_calculated_ref)
        )
      )
    ][, .(enc_id, parent_id)]

    data.table::setindexv(parent_map, "enc_id")

    hop1 <- parent_map[, .(enc_id, parent1 = parent_id)]

    p1_valid <- hop1[!is.na(parent1) & parent1 != "invalid", .(enc_id, parent1)]
    data.table::setindexv(p1_valid, "parent1")
    hop2 <- parent_map[p1_valid, on = .(enc_id = parent1), nomatch = 0L][, .(enc_id, parent2 = parent_id)]

    p2_valid <- hop2[!is.na(parent2) & parent2 != "invalid", .(enc_id, parent2)]
    data.table::setindexv(p2_valid, "parent2")
    hop3 <- parent_map[p2_valid, on = .(enc_id = parent2), nomatch = 0L][, .(enc_id, parent3 = parent_id)]

    main_chain <- hop1[hop2, on = .(enc_id)]
    main_chain <- main_chain[hop3, on = .(enc_id)]

    main_chain[, main_id := data.table::fcase(
      is.na(parent1),                       enc_id,
      parent1 == "invalid",                 "invalid",
      is.na(parent2),                       parent1,
      parent2 == "invalid",                 "invalid",
      is.na(parent3),                       parent2,
      parent3 == "invalid",                 "invalid",
      default = "invalid"
    )]

    main_chain[, enc_main_encounter_calculated_ref := data.table::fifelse(
      main_id == "invalid", "invalid", paste0("Encounter/", main_id)
    )]

    data.table::setindexv(encounters, "enc_id")
    encounters[
      main_chain[, .(enc_id, enc_main_encounter_calculated_ref)],
      on = .(enc_id),
      enc_main_encounter_calculated_ref := i.enc_main_encounter_calculated_ref
    ]
  })

  return(encounters)
}

createReferencesForResource <- function(encounters, resource_name, resource_table, start_column_names) {
  etlutils::runLevel2(paste0("Create encounter reference for resource: ", resource_name), {
    # --- Fast exit for empty input ---
    if (is.null(resource_table) || !nrow(resource_table)) return(resource_table)

    # --- Column names ---
    ref_col_name <- getEncounterReferenceColumnName(resource_name)
    calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
    patient_ref_col_name <- etlutils::fhirdbGetColumns(resource_name, "_patient_ref")

    # --- Ensure target column exists (filled with NA) ---
    resource_table[, (calculated_ref_col_name) := NA_character_]

    # =========================================================================
    # 1) Resolve direct references via main-encounter map (vectorized)
    # =========================================================================
    # Prepare mapping: enc_id -> enc_main_encounter_calculated_ref
    main_map <- data.table::unique(
      encounters[, .(enc_id, enc_main_encounter_calculated_ref)]
    )
    data.table::setindexv(main_map, "enc_id")

    # Extract enc_id from reference. Keep NA for NA refs.
    # NOTE: fhirdataExtractIDs() returns character vector without keeping length
    # for NA input, so we handle NA positions and fill back safely.
    # Vector with original encounter references
    direct_ref_vec <- resource_table[[ref_col_name]]

    # Boolean mask: which rows have a direct encounter reference?
    has_direct <- !is.na(direct_ref_vec)

    # Only if any direct references exist, extract IDs and join once
    if (any(has_direct)) {
      # Extract enc_id from "Encounter/<id>" (keep length; NA stays NA)
      enc_id_from_ref <- rep(NA_character_, length(direct_ref_vec))
      enc_id_from_ref[has_direct] <- etlutils::fhirdataExtractIDs(direct_ref_vec[has_direct], unique = FALSE)

      # Prepare small DT to join back main encounter refs
      tmp_dt <- data.table::data.table(
        row_id = which(has_direct),
        enc_id = enc_id_from_ref[has_direct]
      )

      # Map: enc_id -> enc_main_encounter_calculated_ref
      main_map <- data.table::unique(encounters[, .(enc_id, enc_main_encounter_calculated_ref)])
      data.table::setindexv(main_map, "enc_id")

      # Join and assign back (only rows that matched)
      tmp_dt <- main_map[tmp_dt, on = .(enc_id), nomatch = 0L]
      if (nrow(tmp_dt)) {
        resource_table[tmp_dt$row_id, (calculated_ref_col_name) := tmp_dt$enc_main_encounter_calculated_ref]
      }
    }

    # =========================================================================
    # 2) Timestamp-based resolution for remaining rows (vectorized, non-equi)
    # =========================================================================
    # Work only on rows still NA after step 1
    need_ts <- which(is.na(resource_table[[calculated_ref_col_name]]))
    if (length(need_ts)) {
      # Candidate Encounters: only Level-1 (einrichtungskontakt)
      lvl1 <- encounters[enc_type_code == ENCOUNTER_TYPES[[1]],
                         .(enc_id, enc_patient_ref, enc_period_start, enc_period_end)]
      # Build an "infinite" end for open intervals (NA end means ongoing)
      # Try to preserve timezone from enc_period_start (fallback: no tz)
      enc_tz <- tryCatch(attr(lvl1$enc_period_start, "tzone"), error = function(e) NULL)
      far_future <- if (!is.null(enc_tz) && nzchar(enc_tz)) {
        as.POSIXct("9999-12-31 23:59:59", tz = enc_tz)
      } else {
        as.POSIXct("9999-12-31 23:59:59")
      }
      lvl1[, enc_period_end_inf := data.table::fifelse(is.na(enc_period_end), far_future, enc_period_end)]
      # Indices for faster range joins
      data.table::setindexv(lvl1, c("enc_patient_ref", "enc_period_start", "enc_period_end_inf"))

      # We’ll try each available start column until we assign a match.
      # Strategy:
      # - Take the subset of rows still NA and with non-NA time for this column.
      # - Non-equi join on (patient, enc_period_start <= time <= enc_period_end_inf).
      # - If multiple matches: pick closest enc_period_start per row.
      # - Assign Encounter/<enc_id> by reference.
      # - Remove the assigned rows from the "need_ts" set and continue with next time column.

      # Give each row a stable id for grouping
      if (!".__rid" %in% names(resource_table)) {
        resource_table[, .__rid := seq_len(.N)]
      }

      for (start_col in start_column_names) {
        if (!length(need_ts)) break

        # rows that still need assignment and have a timestamp in this column
        has_time <- need_ts[!is.na(resource_table[[start_col]][need_ts])]
        if (!length(has_time)) next

        # Build working copy with needed columns
        need_dt <- resource_table[has_time,
                                  .(.__rid,
                                    i_patient = get(patient_ref_col_name),
                                    i_time    = get(start_col))]

        # Remove rows without patient or time (just in case)
        need_dt <- need_dt[!is.na(i_patient) & !is.na(i_time)]
        if (!nrow(need_dt)) next

        # Non-equi join: lvl1[ need_dt, on=.(enc_patient_ref=i_patient, enc_period_start<=i_time, enc_period_end_inf>=i_time) ]
        # This produces one row per match; we then pick the closest start per .__rid.
        matched <- lvl1[
          need_dt,
          on = .(enc_patient_ref = i_patient,
                 enc_period_start <= i_time,
                 enc_period_end_inf >= i_time),
          nomatch = 0L,
          allow.cartesian = TRUE
        ]

        if (nrow(matched)) {
          # Compute distance to start and pick closest per row
          matched[, time_diff := abs(as.numeric(difftime(enc_period_start, i_time, units = "secs")))]
          # order by rid, then distance
          data.table::setorder(matched, .__rid, time_diff)
          best <- matched[, .SD[1L], by = .__rid]

          # Assign Encounter/<enc_id> for those rows
          assign_idx <- match(best$.__rid, resource_table$.__rid)
          resource_table[assign_idx, (calculated_ref_col_name) := paste0("Encounter/", best$enc_id)]

          # Update remaining set
          need_ts <- setdiff(need_ts, assign_idx)
        }
      }

      # Drop helper rid
      resource_table[, .__rid := NULL]
    }

    # =========================================================================
    # 3) Mark still-unresolved rows as "invalid"
    # =========================================================================
    still_na <- which(is.na(resource_table[[calculated_ref_col_name]]))
    if (length(still_na)) {
      resource_table[still_na, (calculated_ref_col_name) := "invalid"]
    }
  })

  return(resource_table)
}
