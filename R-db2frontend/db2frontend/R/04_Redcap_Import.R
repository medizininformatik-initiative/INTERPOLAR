# Batched redcapAPI imports return one CSV string per request.
normalizeRedcapImportResult <- function(import_result, csv_delimiter) {
  if (is.data.frame(import_result)) {
    return(data.table::as.data.table(import_result))
  }
  responses <- as.character(import_result)
  responses <- responses[!is.na(responses) & nzchar(responses)]
  if (any(grepl("^\\s*(<|Fatal error|Allowed memory size|\\{\\s*\"error\"\\s*:)", responses, ignore.case = TRUE))) {
    stop(paste(responses, collapse = "\n"), call. = FALSE)
  }
  if (any(grepl("[\r\n]", responses))) {
    return(data.table::rbindlist(lapply(responses, function(response) {
      data.table::as.data.table(utils::read.table(
        text = response, header = TRUE, sep = csv_delimiter, quote = "\"",
        colClasses = "character", na.strings = character(), comment.char = "",
        check.names = FALSE, stringsAsFactors = FALSE
      ))
    }), use.names = TRUE, fill = TRUE))
  }
  data.table::data.table(import_result = responses)
}

importRecordsToRedcap <- function(rcon, table_name, import_data, overwriteBehavior = "normal") {
  prepared_data <- data.table::as.data.table(import_data)
  if ("record_id" %in% names(prepared_data)) {
    prepared_data <- prepared_data[, c("record_id", setdiff(names(prepared_data), "record_id")), with = FALSE]
  }
  redcap_import_batch_size <- 1000L

  import_result <- redcapAPI::importRecords(
    rcon = rcon,
    data = prepared_data,
    overwriteBehavior = overwriteBehavior,
    returnContent = "ids",
    batch.size = if (nrow(prepared_data) > redcap_import_batch_size) redcap_import_batch_size else -1L
  )
  import_result <- normalizeRedcapImportResult(import_result, rcon$csv_delimiter())

  import_count <- nrow(import_result)
  message("REDCap import for table '", table_name, "' returned ", import_count, " record id(s).")

  etlutils::writeDebugExcelFile(import_result, paste0("db2frontend_", table_name, "_redcap_import_result"))
  return(import_result)
}
