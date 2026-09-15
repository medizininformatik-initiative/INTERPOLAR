BROAD_CONSENT_CODE_SYSTEM <- "urn:oid:2.16.840.1.113883.3.1937.777.24.5.3"
BROAD_CONSENT_CODE_PREFIX <- "2.16.840.1.113883.3.1937.777.24.5.3."

emptyBroadConsentPeriods <- function() {
  data.table::data.table(start = as.Date(character()), end = as.Date(character()))
}

mergeBroadConsentPeriods <- function(periods) {
  if (nrow(periods) == 0L) return(emptyBroadConsentPeriods())
  periods <- unique(periods[, c("start", "end"), with = FALSE])
  data.table::setorder(periods, start, end)
  starts <- as.numeric(periods$start)
  ends <- as.numeric(periods$end)
  groups <- cumsum(c(TRUE, starts[-1L] > head(cummax(ends), -1L) + 1))
  # Select boundaries by indices, without materializing .SD for each interval.
  result <- data.table::data.table(
    start = as.Date(starts[!duplicated(groups)], origin = "1970-01-01"),
    end = as.Date(cummax(ends)[!duplicated(groups, fromLast = TRUE)], origin = "1970-01-01")
  )
  result
}

subtractBroadConsentPeriods <- function(permits, denies) {
  result <- mergeBroadConsentPeriods(permits)
  denies <- mergeBroadConsentPeriods(denies)
  for (i in seq_len(nrow(denies))) {
    overlap <- result$start <= denies$end[i] & result$end >= denies$start[i]
    left <- result[overlap & result$start < denies$start[i], ]
    right <- result[overlap & result$end > denies$end[i], ]
    left$end <- rep(denies$start[i] - 1, nrow(left))
    right$start <- rep(denies$end[i] + 1, nrow(right))
    result <- data.table::rbindlist(list(result[!overlap, ], left, right))
  }
  mergeBroadConsentPeriods(result)
}

# Pure patient-level calculation. The database adapter must provide only the
# current version of each Consent document, preserving distinct document IDs.
# Dates are typed here deliberately: parsing flattened database values belongs
# in the adapter, where conversion failures must remain visible.
calculateBroadConsentPatient <- function(provisions, encounters, evaluation_date) {
  required <- c("consent_id", "declared_at", "status", "system", "code", "type", "start", "end")
  if (!all(required %in% names(provisions))) {
    stop("Consent provisions lack required columns.")
  }
  if (!inherits(evaluation_date, "Date") || length(evaluation_date) != 1L || is.na(evaluation_date)) {
    stop("A single explicit evaluation date is required.")
  }
  if (
    !inherits(provisions$declared_at, "POSIXct") ||
    !inherits(provisions$start, "Date") || !inherits(provisions$end, "Date")
  ) {
    stop("Consent declaration timestamps and period dates must be typed.")
  }
  provisions <- unique(data.table::as.data.table(data.table::copy(provisions))[, required, with = FALSE])
  audit <- data.table::data.table(
    consent_id = character(), code = character(), action = character(),
    related_id = character(), start = as.Date(character()), end = as.Date(character())
  )
  record <- function(row, action, related_id = NA_character_) {
    audit <<- data.table::rbindlist(list(audit, data.table::data.table(
      consent_id = row$consent_id, code = row$code, action = action,
      related_id = related_id, start = row$start, end = row$end
    )))
  }
  finish <- function(reason, periods = emptyBroadConsentPeriods()) {
    list(included = identical(reason, "included"), reason = reason, periods = periods, changes = audit)
  }
  # An unclassified status could hide an effective restriction.
  if (any(!provisions$status %in% c("draft", "proposed", "active", "rejected", "inactive", "entered-in-error"))) {
    return(finish("invalid_consent_status"))
  }
  provisions <- provisions[provisions$status == "active", ]
  if (!nrow(provisions)) return(finish("no_active_consent"))
  if (
    anyNA(provisions$system) || anyNA(provisions$code) ||
    any(!nzchar(provisions$system)) || any(!nzchar(provisions$code))
  ) {
    return(finish("unclassified_consent_policy"))
  }
  codes <- paste0(BROAD_CONSENT_CODE_PREFIX, c("6", "8", "45", "46"))
  provisions <- provisions[provisions$system == BROAD_CONSENT_CODE_SYSTEM & provisions$code %in% codes, ]
  if (!nrow(provisions)) return(finish("no_relevant_consent"))
  invalid <- is.na(provisions$consent_id) | !nzchar(provisions$consent_id) |
    is.na(provisions$declared_at) | is.na(provisions$start) | is.na(provisions$end) |
    !provisions$type %in% c("permit", "deny") | provisions$start > provisions$end
  if (any(invalid)) return(finish("invalid_relevant_provision"))
  # The evaluation is day-based; same-day declarations are valid regardless
  # of time of day. A future declaration cannot grant or restore rights today.
  if (any(as.Date(provisions$declared_at, tz = "UTC") > evaluation_date)) {
    return(finish("future_consent_declaration"))
  }
  declaration_counts <- unique(provisions[, c("consent_id", "declared_at"), with = FALSE])
  if (anyDuplicated(declaration_counts$consent_id)) return(finish("inconsistent_declaration_time"))
  data.table::setorder(provisions, declared_at, consent_id, code, type, start, end)
  code_6 <- codes[1L]
  code_8 <- codes[2L]
  retro_codes <- codes[3:4]

  if (!is.null(encounters) && nrow(encounters)) {
    if (
      !all(c("encounter_id", "start", "end") %in% names(encounters)) ||
      !inherits(encounters$start, "Date") || !inherits(encounters$end, "Date")
    ) {
      stop("Encounter IDs and typed period dates are required.")
    }
    encounters <- data.table::as.data.table(data.table::copy(encounters))
    encounters <- encounters[!is.na(encounters$start) & !is.na(encounters$end) & encounters$start <= encounters$end, ]
    for (i in which(provisions$code == code_6 & provisions$type == "permit")) {
      matches <- which(encounters$start < provisions$start[i] & encounters$end >= provisions$start[i])
      if (length(matches)) {
        match <- matches[which.min(encounters$start[matches])]
        provisions$start[i] <- encounters$start[match]
        record(provisions[i, ], "encounter_start_applied", encounters$encounter_id[match])
      }
    }
  }

  permits <- provisions[provisions$type == "permit", ]
  full_documents <- intersect(permits$consent_id[permits$code == code_6], permits$consent_id[permits$code == code_8])
  if (!length(full_documents)) return(finish("missing_complete_consent_document"))
  gate <- emptyBroadConsentPeriods()
  periods <- emptyBroadConsentPeriods()
  # Fold declarations by timestamp, not document ID. Simultaneous restrictions
  # win: apply all .6/.8 denies after grants; a retro reset keeps contributions
  # only from the resetting documents, just as a later reset would do.
  for (declaration_time in unique(provisions$declared_at)) {
    current <- provisions[provisions$declared_at == declaration_time, ]
    denies <- current[current$type == "deny", ]
    current_permits <- current[current$type == "permit" & current$consent_id %in% full_documents, ]
    retro_denies <- denies[denies$code %in% retro_codes, ]
    if (nrow(retro_denies)) {
      periods <- emptyBroadConsentPeriods()
      for (i in seq_len(nrow(retro_denies))) record(retro_denies[i, ], "retrospective_history_reset")
    }
    data_permits <- current_permits[current_permits$code == code_6, ]
    if (nrow(retro_denies)) {
      data_permits <- data_permits[data_permits$consent_id %in% retro_denies$consent_id, ]
    }
    contributions <- list(periods, data_permits[, c("start", "end"), with = FALSE])
    for (i in seq_len(nrow(data_permits))) {
      own <- current[current$consent_id == data_permits$consent_id[i], ]
      retro_permits <- own[own$type == "permit" & own$code %in% retro_codes, ]
      overlaps <- retro_permits$start <= data_permits$end[i] & retro_permits$end >= data_permits$start[i]
      # A simultaneous retro deny in another document wins over this extension.
      other_deny <- any(retro_denies$consent_id != data_permits$consent_id[i])
      if (any(overlaps) && !other_deny) {
        extension <- data.table::copy(data_permits[i, ])
        extension$start <- as.Date("1900-01-01")
        contributions[[length(contributions) + 1L]] <- subtractBroadConsentPeriods(
          extension, own[own$type == "deny" & own$code %in% retro_codes, ]
        )
        record(extension, "retrospective_start_applied", retro_permits$consent_id[which(overlaps)[1L]])
      }
    }
    periods <- subtractBroadConsentPeriods(
      data.table::rbindlist(contributions), denies[denies$code == code_6, ]
    )
    gate <- subtractBroadConsentPeriods(data.table::rbindlist(list(
      gate, current_permits[current_permits$code == code_8, c("start", "end"), with = FALSE]
    )), denies[denies$code == code_8, ])
  }
  if (!any(gate$start <= evaluation_date & gate$end >= evaluation_date)) {
    return(finish("no_current_usage_permission"))
  }
  if (!nrow(periods)) return(finish("no_permitted_data_period"))
  finish("included", periods)
}
