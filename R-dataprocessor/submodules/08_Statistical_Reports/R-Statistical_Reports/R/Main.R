#' Generate a Statistical Report
#'
#' This function generates a statistical report by querying a database view
#' (`v_condition`) and fetching the results. The query is executed with a
#' read-only lock to ensure data consistency.
#'
#' @return This function does not return a value explicitly. It prints the
#'         fetched data from the database query (`v_condition`) to the console.
#'
#' @export
createStatisticalReport <- function() {
  query <- paste0("SELECT * FROM v_condition\n")
  conditions <- etlutils::dbGetReadOnlyQuery(query, lock_id = "statistical reports[1]")
  print(conditions)
}
