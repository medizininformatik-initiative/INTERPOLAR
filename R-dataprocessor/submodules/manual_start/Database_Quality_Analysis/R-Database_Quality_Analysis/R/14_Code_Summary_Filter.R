#' Keep global medication identities without retaining out-of-scope clinical rows
#'
#' A selected usage ID may also have reference/code rows outside the selected
#' cases. These narrow identity rows preserve direct-code matching, diagnostic
#' suppression and incoming-reference existence without sorting those full rows.
#' Each usage view has one additional projection containing only IDs and a flag.
buildCodeSummaryUsageIdentityCtes <- function(sources, links, systems, include_direct_codes = TRUE, chunk_identity = FALSE) {
  views <- unique(vapply(links, function(source) quoteTable(source$schema, source$view), character(1)))
  selects <- vapply(views, function(view) {
    view_links <- Filter(function(source) quoteTable(source$schema, source$view) == view, links)
    view_codes <- Filter(function(source) {
      source$resource %in% vapply(view_links, `[[`, character(1), "resource") &&
        quoteTable(source$schema, source$view) == view && source$coding == "medicationCodeableConcept/coding"
    }, sources)
    branches <- lapply(view_links, function(source) {
      paste0(
        "SELECT ", quoteSqlString(source$resource), " AS kind, ",
        codeSummaryFieldSql(source$fields, "resource_id"), " AS own_id, ",
        codeSummaryReferenceSql(codeSummaryFieldSql(source$fields, "medication_ref"), "Medication"),
        " AS medication_ref,false AS direct_coding"
      )
    })
    if (!include_direct_codes) view_codes <- list()
    branches <- c(branches, lapply(view_codes, function(source) {
      id <- codeSummaryFieldSql(source$fields, "resource_id")
      paste0(
        "SELECT ", quoteSqlString(source$resource), ", ", id, ",NULL::text,true WHERE ",
        id, " IS NOT NULL AND ", codeSummaryFieldSql(source$fields, "code"), " IS NOT NULL AND ",
        codeSummaryFieldSql(source$fields, "system"), " IN (",
        paste(vapply(unique(unlist(systems[source$reports])), quoteSqlString, character(1)), collapse = ","), ")"
      )
    }))
    paste0("SELECT ids.* FROM ", view, " s CROSS JOIN LATERAL (", paste(branches, collapse = " UNION ALL "), ") ids")
  }, character(1))
  identities <- paste(selects, collapse = " UNION ALL ")
  if (chunk_identity) {
    selected_id <- "EXISTS (SELECT 1 FROM selected_usage_ids u WHERE u.kind=ids.kind AND u.own_id=ids.own_id)"
    selected_ref <- "EXISTS (SELECT 1 FROM chunk_medication_ids m WHERE ids.medication_ref='Medication/' || m.id)"
    # Non-selected usage IDs matter only as incoming references. Collapse them
    # to NULL IDs before DISTINCT, retaining their Medication existence marker.
    identities <- paste0(
      "SELECT kind,CASE WHEN ", selected_id, " THEN own_id END AS own_id,medication_ref,direct_coding FROM (",
      identities, ") ids WHERE (", selected_id, ") OR (", selected_ref, ")"
    )
  }
  c(
    paste0("usage_identities AS MATERIALIZED (SELECT DISTINCT * FROM (", identities, ") ids)"),
    "reference_links AS MATERIALIZED (SELECT kind,own_id,medication_ref FROM usage_identities WHERE NOT direct_coding)",
    "direct_coding_ids AS MATERIALIZED (SELECT kind,own_id FROM usage_identities WHERE direct_coding)"
  )
}
