#' Reuse exact count aggregation in detail and narrow cross-code passes
buildCodeSummaryCountsCte <- function() {
  paste0(
    "counts AS (SELECT ARRAY[g.report_scope,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high] AS summary_id,g.report_scope,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high, ",
    "COUNT(DISTINCT g.count_key) AS count, ",
    "COUNT(DISTINCT g.pid) AS patient_count, COUNT(DISTINCT g.case_id) AS case_count, ",
    "CASE WHEN g.row_type = 'unresolved medication reference' THEN ",
    "COUNT(DISTINCT g.event_key) - COUNT(DISTINCT g.event_key) FILTER (WHERE g.case_id IS NOT NULL) ELSE ",
    "COUNT(DISTINCT g.count_key) - COUNT(DISTINCT g.count_key) FILTER (WHERE g.case_id IS NOT NULL) END AS no_case_count, ",
    "COUNT(DISTINCT g.count_key) FILTER (WHERE g.count_key LIKE 'Medication/%') AS medication_count, ",
    "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationRequest') AS medication_request_count, ",
    "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationAdministration') AS medication_administration_count, ",
    "COUNT(DISTINCT g.event_key) FILTER (WHERE g.kind = 'MedicationStatement') AS medication_statement_count, ",

    "COUNT(DISTINCT g.count_key) FILTER (WHERE g.unreferenced_medication) AS unreferenced_medication_count ",
    "FROM grouped g ",
    "GROUP BY g.report_scope,g.export_target,g.report,g.system,g.coding_path,g.row_type,g.version,g.code,g.unit,g.unit_system,g.low,g.high)"
  )
}

#' Reuse count output expansion and the existing null-safe statistics merge
buildCodeSummaryResultQuery <- function(ctes, collect_statistics = FALSE) {
  export_targets <- "(VALUES ('global'), ('local')) AS t(export_target)"
  ctes <- c(ctes, paste0(
    "counts_outputs AS (SELECT c.*,t.export_target AS output_target FROM counts c CROSS JOIN ",
    export_targets, " WHERE c.export_target IN ('both',t.export_target))"
  ))
  # Statistics contain a subset of the count groups, keyed identically. FULL
  # therefore has the same rows as LEFT here, while requiring a hash/merge join
  # even when PostgreSQL underestimates the number of measurement groups.
  # Expand targets before that join: a post-join count-side filter would let
  # PostgreSQL reduce FULL back to LEFT and choose quadratic nested loops again.
  statistic_columns <- c("median", "q1", "q3", "mean", "sd", "minimum", "maximum")
  statistics_select <- if (collect_statistics) {
    paste0("s.", statistic_columns, collapse = ",")
  } else {
    paste0("NULL::double precision AS ", statistic_columns, collapse = ",")
  }
  statistics_join <- if (collect_statistics) " FULL JOIN statistics s USING (summary_id) " else " "
  paste0(
    "/* INTERPOLAR DQA code summary */\nWITH ", paste(ctes, collapse = ",\n"),
    "\nSELECT c.summary_id,c.report_scope,c.output_target AS export_target,c.report,c.system,c.coding_path,c.row_type,c.version,c.code,",
    "c.unit,c.unit_system,c.low,c.high,c.count,c.patient_count,c.case_count,c.no_case_count,c.medication_count,",
    "c.medication_request_count,c.medication_administration_count,c.medication_statement_count,c.unreferenced_medication_count,",
    statistics_select, " FROM counts_outputs c", statistics_join,
    "ORDER BY c.report_scope,c.output_target,c.report,c.system,c.coding_path,c.row_type,c.version,c.code,c.unit,c.unit_system,c.low,c.high"
  )
}

#' Build small, quoted metadata relations; no individual resource IDs enter R
buildCodeSummaryValuesCte <- function(rows, columns, name) {
  values <- vapply(seq_len(nrow(rows)), function(index) {
    fields <- vapply(columns, function(column) {
      value <- rows[[column]][[index]]
      if (is.na(value)) "NULL::text" else quoteSqlString(as.character(value))
    }, character(1))
    paste0("(", paste(fields, collapse = ","), ")")
  }, character(1))
  paste0(name, " (", paste(columns, collapse = ","), ") AS (VALUES ", paste(values, collapse = ","), ")")
}

#' Keep complete system/code groups together before source materialization
buildCodeSummaryKeyCte <- function(code_keys) {
  buildCodeSummaryValuesCte(code_keys, c("system", "code"), "code_keys")
}

#' Find Medication IDs whose own or ingredient codes belong to the current chunk
buildCodeSummaryChunkMedicationCte <- function(sources) {
  views <- unique(vapply(sources, function(source) quoteTable(source$schema, source$view), character(1)))
  selects <- vapply(views, function(view) {
    branches <- lapply(Filter(function(source) quoteTable(source$schema, source$view) == view, sources), function(source) {
      paste0(
        "SELECT ", codeSummaryFieldSql(source$fields, "resource_id"), " AS id WHERE EXISTS (SELECT 1 FROM code_keys k WHERE k.system=",
        codeSummaryFieldSql(source$fields, "system"), " AND k.code=", codeSummaryFieldSql(source$fields, "code"), ")"
      )
    })
    paste0("SELECT ids.* FROM ", view, " s CROSS JOIN LATERAL (", paste(branches, collapse = " UNION ALL "), ") ids")
  }, character(1))
  paste0("chunk_medication_ids AS MATERIALIZED (SELECT DISTINCT id FROM (", paste(selects, collapse = " UNION ALL "), ") ids WHERE id IS NOT NULL)")
}

#' Reuse the exact deduplicated resource/value stream and quartile calculation
buildCodeSummaryStatisticsCtes <- function() {
  dimensions <- "report_scope,report,system,coding_path,version,code,unit,unit_system,low,high"
  c(
    paste0(
      "measurements AS (SELECT DISTINCT ", dimensions, ",count_key,value FROM scoped_events WHERE NOT unresolved AND value IS NOT NULL ",
      "AND value NOT IN ('NaN'::double precision,'Infinity'::double precision,'-Infinity'::double precision))"
    ),
    paste0(
      "measurement_statistics AS (SELECT ", dimensions, ",percentile_cont(ARRAY[0.25,0.5,0.75]) WITHIN GROUP (ORDER BY value) AS quartiles, ",
      "AVG(value) AS mean,STDDEV_SAMP(value) AS sd,MIN(value) AS minimum,MAX(value) AS maximum FROM measurements GROUP BY ", dimensions, ")"
    )
  )
}

#' Compute exact quantiles independently, retaining the separate-pass query API
buildCodeSummaryStatisticsQuery <- function(ctes) {
  dimensions <- "report_scope,report,system,coding_path,version,code,unit,unit_system,low,high"
  ctes <- c(ctes, buildCodeSummaryStatisticsCtes())
  paste0(
    "/* INTERPOLAR DQA code statistics */\nWITH ", paste(ctes, collapse = ",\n"),
    " SELECT ", dimensions, ",'detail'::text AS row_type,quartiles[2] AS median,quartiles[1] AS q1,quartiles[3] AS q3,mean,sd,minimum,maximum FROM measurement_statistics"
  )
}

#' Aggregate cross-code totals/diagnostics or rare pools independently and exactly
#'
#' Distinct counts are never summed across detail chunks. The rare catalog carries
#' aggregate group metadata only; full range selection still precedes matching it.
buildCodeSummaryCompactQuery <- function(ctes, mode, rare_groups = NULL) {
  from <- " FROM scoped_events e"
  if (mode == "rare") {
    dimensions <- c("report_scope", "report", "system", "coding_path", "version", "code", "unit", "unit_system", "low", "high")
    ctes <- c(ctes, buildCodeSummaryValuesCte(rare_groups, dimensions, "rare_groups"))
    e_keys <- paste0("e.", dimensions, collapse = ",")
    r_keys <- paste0("r.", dimensions, collapse = ",")
    # Empty arrays remove unmatched rows without reducing FULL to a nested-loop
    # LEFT join when estimates for a rare catalog are very small.
    from <- paste0(
      from, " FULL JOIN rare_groups r ON ARRAY[", e_keys, "]=ARRAY[", r_keys, "] ",
      "CROSS JOIN LATERAL unnest(CASE WHEN e.count_key IS NOT NULL AND r.report_scope IS NOT NULL ",
      "THEN ARRAY[1] ELSE ARRAY[]::integer[] END) matched(flag)"
    )
  }
  ctes <- c(ctes, paste0(
    "grouped AS (SELECT e.report_scope,", if (mode == "rare") "'global'" else "'both'", "::text AS export_target,",
    "e.report,e.system,", if (mode == "rare") "e.coding_path" else "NULL::text", " AS coding_path,",
    if (mode == "rare") "'other (count < 5)'::text" else "CASE WHEN e.unresolved THEN 'unresolved medication reference' ELSE 'total' END", " AS row_type,",
    "NULL::text AS version,NULL::text AS code,NULL::text AS unit,NULL::text AS unit_system,NULL::text AS low,NULL::text AS high,",
    "e.count_key,e.event_key,e.kind,e.pid,e.case_id,e.unreferenced_medication", from, ")"
  ), buildCodeSummaryCountsCte())
  buildCodeSummaryResultQuery(ctes)
}

#' Count every complete detail group once for both output targets
#'
#' Both outputs retain every code. Small counts are masked only during global
#' CSV export, so no frequency/event/label caches or rare-pool passes are needed.
#' Measurement chunks reuse their resolved events for exact statistics in SQL.
buildCodeSummaryDetailQuery <- function(ctes, collect_statistics = FALSE) {
  ctes <- c(ctes, paste0(
    "grouped AS (SELECT e.report_scope,'both'::text AS export_target,e.report,e.system,e.coding_path,",
    "'detail'::text AS row_type,e.version,e.code,e.unit,e.unit_system,e.low,e.high,",
    "e.count_key,e.event_key,e.kind,e.pid,e.case_id,e.unreferenced_medication FROM scoped_events e)"
  ), buildCodeSummaryCountsCte())
  if (collect_statistics) {
    ctes <- c(ctes, buildCodeSummaryStatisticsCtes(), paste0(
      "statistics AS (SELECT ARRAY[report_scope,'both',report,system,coding_path,'detail',version,code,unit,unit_system,low,high] AS summary_id,",
      "quartiles[2] AS median,quartiles[1] AS q1,quartiles[3] AS q3,mean,sd,minimum,maximum FROM measurement_statistics)"
    ))
  }
  buildCodeSummaryResultQuery(ctes, collect_statistics)
}
