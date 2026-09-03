normalizeMRPRecalculationKeyColumn <- function(value) {
  if (inherits(value, "POSIXct")) {
    value <- format(value, "%Y-%m-%d %H:%M:%S", tz = "UTC")
  } else {
    value <- as.character(value)
  }
  value[is.na(value)] <- "#NULL#"
  trimws(value)
}

addMRPRecalculationKey <- function(dt, key_cols) {
  dt[, .mrp_recalculation_key := do.call(
    paste,
    c(lapply(.SD, normalizeMRPRecalculationKeyColumn), sep = "|||")
  ), .SDcols = key_cols]
}

filterExistingMRPRows <- function(current_table, existing_table, key_cols, exact_key_cols = character()) {
  if (!nrow(current_table)) {
    return(current_table)
  }

  current_table <- data.table::copy(current_table)
  existing_table <- data.table::copy(existing_table)
  current_table[, .mrp_recalculation_order := .I]
  addMRPRecalculationKey(current_table, key_cols)
  if (!nrow(existing_table)) {
    current_table[, c(".mrp_recalculation_order", ".mrp_recalculation_key") := NULL]
    return(current_table)
  }

  addMRPRecalculationKey(existing_table, key_cols)

  # Prefer candidates that match an existing row on the complete legacy key
  # when more than one fixed WP7 rule shares the same visible MRP key. This
  # makes the legacy comparison a multiset subtraction instead of suppressing
  # every candidate with that key.
  current_table[, .mrp_recalculation_exact_match := FALSE]
  if (length(exact_key_cols)) {
    current_exact <- data.table::copy(current_table)
    existing_exact <- data.table::copy(existing_table)
    addMRPRecalculationKey(current_exact, exact_key_cols)
    addMRPRecalculationKey(existing_exact, exact_key_cols)
    current_table[, .mrp_recalculation_exact_match :=
      current_exact$.mrp_recalculation_key %in% existing_exact$.mrp_recalculation_key]
  }

  existing_identity_cols <- c(".mrp_recalculation_key", intersect("ret_id", names(existing_table)))
  existing_counts <- unique(existing_table[, ..existing_identity_cols])[
    , .(.mrp_recalculation_existing_count = .N),
    by = .mrp_recalculation_key
  ]
  current_table <- merge(
    current_table,
    existing_counts,
    by = ".mrp_recalculation_key",
    all.x = TRUE,
    sort = FALSE
  )
  current_table[is.na(.mrp_recalculation_existing_count), .mrp_recalculation_existing_count := 0L]

  data.table::setorder(
    current_table,
    .mrp_recalculation_key,
    -.mrp_recalculation_exact_match,
    .mrp_recalculation_order
  )
  current_table[, .mrp_recalculation_rank := seq_len(.N), by = .mrp_recalculation_key]
  current_table <- current_table[
    .mrp_recalculation_rank > .mrp_recalculation_existing_count
  ]
  data.table::setorder(current_table, .mrp_recalculation_order)
  current_table[, c(
    ".mrp_recalculation_order",
    ".mrp_recalculation_key",
    ".mrp_recalculation_exact_match",
    ".mrp_recalculation_existing_count",
    ".mrp_recalculation_rank"
  ) := NULL]

  current_table
}

splitMRPRecordIds <- function(record_ids, chunk_size = 1000L) {
  record_ids <- unique(na.omit(record_ids))
  split(record_ids, ceiling(seq_along(record_ids) / chunk_size))
}

#' Recalculate retrospective MRPs additively for a selected time range
#'
#' Re-runs the retrospective MRP calculation for encounters in the given time
#' range, removes already existing MRP evaluations on a domain-specific key,
#' renumbers the remaining REDCap repeat instances, and writes only the new rows
#' to the database.
#'
#' @param start_date Start date or timestamp of the encounter selection window.
#' @param end_date Optional end date or timestamp of the encounter selection
#'   window. If omitted, the current date is used.
#' @param ignore_newer_db_version Logical. Passed to the standard version check.
#' @param validate_config Logical. If `TRUE`, validates the dataprocessor
#'   configuration before execution.
#'
#' @return Invisible finalize status from the dataprocessor module run.
#' @export
recalculateMRPs <- function(start_date,
                            end_date = NULL,
                            ignore_newer_db_version = FALSE,
                            validate_config = TRUE) {
  start_date <- etlutils::as.POSIXctWithTimezone(start_date)
  end_date <- if (is.null(end_date)) {
    etlutils::as.POSIXctWithTimezone(Sys.Date())
  } else {
    etlutils::as.POSIXctWithTimezone(end_date)
  }

  if (start_date > end_date) {
    stop("Parameter end_date (", end_date, ") must be greater than start_date (", start_date, ").")
  }

  # Load only the columns needed for duplicate detection and renumbering. The
  # query is chunked by record_id to keep memory and SQL statement sizes bounded
  # without introducing per-record database round trips.
  loadExistingMRPRows <- function(record_ids, key_cols, chunk_size = 1000L) {
    chunks <- splitMRPRecordIds(record_ids, chunk_size)
    if (!length(chunks)) {
      return(data.table::data.table())
    }

    existing_chunks <- lapply(seq_along(chunks), function(chunk_index) {
      query <- paste0(
        "SELECT ", paste(unique(c(key_cols, "ret_id", "redcap_repeat_instance")), collapse = ", "), "\n",
        "FROM v_retrolektive_mrpbewertung_fe\n",
        "WHERE record_id IN ", etlutils::fhirdbGetQueryList(chunks[[chunk_index]]), "\n"
      )
      etlutils::dbGetReadOnlyQuery(
        query,
        lock_id = paste0("MRP_Recalculation_existing_mrps_", chunk_index)
      )
    })

    data.table::rbindlist(existing_chunks, use.names = TRUE, fill = TRUE)
  }

  # ret_id values continue per medication analysis, while REDCap repeat
  # instances continue per patient record. After deduplication, both sequences
  # must be rebuilt from the current last-version state so the surviving new
  # rows remain gap-free and consistent.
  renumberNewMRPs <- function(mrp_tables, existing_ret_rows) {
    ret_table <- mrp_tables$retrolektive_mrpbewertung_fe
    dp_table <- mrp_tables$dp_mrp_calculations
    if (!nrow(ret_table)) {
      return(mrp_tables)
    }

    # Determine the next ret_id suffix for the given medication analysis
    getNextRetIndex <- function(existing_group, ret_meda_id_value, ret_id_prefix) {
      existing_ret_suffixes <- suppressWarnings(
        as.integer(sub(
          ret_id_prefix,
          "",
          existing_group[ret_meda_id == ret_meda_id_value, ret_id],
          fixed = TRUE
        ))
      )
      max_existing_ret_index <- suppressWarnings(max(existing_ret_suffixes, na.rm = TRUE))
      if (length(existing_ret_suffixes) && is.finite(max_existing_ret_index)) {
        return(max_existing_ret_index + 1L)
      }
      1L
    }

    # Determine the next redcap_repeat_instance for the given patient record.
    getNextRepeatInstance <- function(existing_group) {
      max_existing_repeat_instance <- suppressWarnings(
        max(as.integer(existing_group$redcap_repeat_instance), na.rm = TRUE)
      )
      if (nrow(existing_group) && is.finite(max_existing_repeat_instance)) {
        return(max_existing_repeat_instance + 1L)
      }
      1L
    }

    # Build a mapping from old to new ret_id and redcap_repeat_instance values for the given group of rows
    buildRenumberMap <- function(current_rows, existing_group, ret_meda_id_value) {
      current_rows <- data.table::copy(current_rows)[order(redcap_repeat_instance, ret_id)]
      ret_id_prefix <- sub("[0-9]+$", "", current_rows$temp_old_ret_id[1])
      next_ret_index <- getNextRetIndex(existing_group, ret_meda_id_value, ret_id_prefix)
      next_repeat_instance <- getNextRepeatInstance(existing_group)

      current_rows[, new_ret_id := paste0(
        ret_id_prefix,
        seq.int(from = next_ret_index, length.out = .N)
      )]
      current_rows[, new_redcap_repeat_instance := seq.int(
        from = next_repeat_instance,
        length.out = .N
      )]

      current_rows[, .(
        temp_old_ret_id,
        temp_old_redcap_repeat_instance,
        new_ret_id,
        new_redcap_repeat_instance
      )]
    }

    applyRenumberMap <- function(ret_table, dp_table, renumber_map) {
      ret_table[
        renumber_map,
        on = .(
          record_id, ret_meda_id, temp_old_ret_id, temp_old_redcap_repeat_instance
        ),
        ret_id := i.new_ret_id
      ]

      ret_table[
        renumber_map,
        on = .(
          record_id, ret_meda_id, temp_old_ret_id, temp_old_redcap_repeat_instance
        ),
        redcap_repeat_instance := i.new_redcap_repeat_instance
      ]

      dp_table[
        renumber_map,
        on = .(
          temp_old_ret_id = temp_old_ret_id, temp_old_ret_redcap_repeat_instance = temp_old_redcap_repeat_instance
        ),
        ret_id := i.new_ret_id
      ]

      dp_table[
        renumber_map,
        on = .(
          temp_old_ret_id = temp_old_ret_id, temp_old_ret_redcap_repeat_instance = temp_old_redcap_repeat_instance
        ),
        ret_redcap_repeat_instance := i.new_redcap_repeat_instance
      ]

      list(ret_table = ret_table, dp_table = dp_table)
    }

    ret_table[, temp_old_ret_id := ret_id]
    ret_table[, temp_old_redcap_repeat_instance := redcap_repeat_instance]
    dp_table[, temp_old_ret_id := ret_id]
    dp_table[, temp_old_ret_redcap_repeat_instance := ret_redcap_repeat_instance]

    renumber_map <- ret_table[
      ,
      buildRenumberMap(.SD, existing_ret_rows[record_id == .BY$record_id], .BY$ret_meda_id),
      by = .(record_id, ret_meda_id)
    ]
    updated_tables <- applyRenumberMap(ret_table, dp_table, renumber_map)
    ret_table <- updated_tables$ret_table
    dp_table <- updated_tables$dp_table

    ret_table[, c("temp_old_ret_id", "temp_old_redcap_repeat_instance") := NULL]
    dp_table[, c("temp_old_ret_id", "temp_old_ret_redcap_repeat_instance") := NULL]

    list(
      retrolektive_mrpbewertung_fe = ret_table,
      dp_mrp_calculations = dp_table
    )
  }

  # Add additional values to the new MRP rows in retrolektive_mrpbewertung_fe to mark them as results of this recalculation run.
  markRecalculatedMRPs <- function(mrp_tables) {
    ret_table <- mrp_tables$retrolektive_mrpbewertung_fe

    if (nrow(ret_table)) {
      recalculation_process_name <- etlutils::getProcess()
      recalculation_timestamp <- etlutils::as.POSIXctWithTimezone(Sys.time(), format = "%Y-%m-%d %H:%M:%S")
      ret_table[
        ,
        ret_additional_values := paste(recalculation_process_name, recalculation_timestamp)
      ]
    }

    mrp_tables$retrolektive_mrpbewertung_fe <- ret_table
    mrp_tables
  }

  startDataprocessorModule(validate_config)
  etlutils::setSubmoduleName("MRPRecalculation")

  try(etlutils::runLevel1("Run additive MRP recalculation", {
    sourceDataprocessorSubmodules(
      ignore_newer_db_version = ignore_newer_db_version,
      source_submodule_functions = TRUE
    )

    etlutils::runLevel2("Recalculate MRPs for time range", {
      # calculateMRPs() still returns both existing and newly rediscovered MRPs
      # for the selected encounters. The additive behavior is applied afterwards.
      mrp_tables <- calculateMRPs(start_date, end_date)

      # Keep only genuinely new retrospective MRPs and the matching
      # dp_mrp_calculations rows of those surviving MRPs.
      ret_table <- mrp_tables$retrolektive_mrpbewertung_fe[!is.na(ret_id)]
      dp_table <- mrp_tables$dp_mrp_calculations[!is.na(ret_id)]
      existing_ret_rows <- data.table::data.table()
      if (!nrow(ret_table)) {
        mrp_tables$retrolektive_mrpbewertung_fe <- ret_table
        mrp_tables$dp_mrp_calculations <- dp_table[0]
      } else {
        # The display text and reference timestamp are intentionally excluded.
        # Both can change when additional evidence is loaded although the
        # underlying clinical MRP is unchanged.
        ret_key_cols <- c(
          "record_id",
          "ret_meda_id",
          "ret_atc1",
          "ret_ip_klasse_01",
          "ret_ip_klasse_disease",
          "ret_atc2"
        )
        exact_ret_key_cols <- c(
          ret_key_cols,
          "ret_meda_dat_referenz",
          "ret_kurzbeschr"
        )
        existing_ret_rows <- loadExistingMRPRows(
          ret_table$record_id,
          unique(c(ret_key_cols, exact_ret_key_cols))
        )
        ret_table <- filterExistingMRPRows(
          current_table = ret_table,
          existing_table = existing_ret_rows,
          key_cols = ret_key_cols,
          exact_key_cols = exact_ret_key_cols
        )
        mrp_tables$retrolektive_mrpbewertung_fe <- ret_table
        mrp_tables$dp_mrp_calculations <- dp_table[ret_id %in% unique(ret_table$ret_id)]
      }

      mrp_tables <- renumberNewMRPs(mrp_tables, existing_ret_rows)
      mrp_tables <- markRecalculatedMRPs(mrp_tables)

      # Only rows belonging to surviving new MRPs remain at this point. Remove
      # exact within-run duplicates without another database query. Including
      # ret_id preserves audit rows when one source item contributes to more
      # than one genuinely distinct MRP.
      mrp_tables$dp_mrp_calculations <- unique(mrp_tables$dp_mrp_calculations)
    })

    etlutils::runLevel2("Write new MRP results to database", {
      new_mrp_count <- nrow(mrp_tables$retrolektive_mrpbewertung_fe)
      if (new_mrp_count) {
        etlutils::dbWriteTables(
          tables = mrp_tables,
          lock_id = "Write additive MRP recalculation to database",
          stop_if_table_not_empty = FALSE
        )
        cat("Added ", new_mrp_count, " new MRP evaluation(s).\n", sep = "")
      } else {
        # A clean no-op is expected when all recalculated MRPs are already present.
        cat("No new MRP evaluations found for the selected time range.\n")
      }
    })
  }))

  etlutils::removeSubmoduleName()
  etlutils::dbCloseAllConnections()

  finish_message <- etlutils::generateFinishMessage()
  invisible(etlutils::finalize(finish_message))
}
