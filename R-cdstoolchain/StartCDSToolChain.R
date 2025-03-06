# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

DEBUG_DATES <- c("2025-03-05 13:55:45 CET",
                 "2025-03-06 13:55:45 CET")

for (i in seq_along(DEBUG_DATES)) {
  DEBUG_DAY <- i

  cat("START DEBUG_DAY", DEBUG_DAY, "\n")
  tryCatch({
    # Fehlerstatus zurücksetzen
    options(error = NULL)
    # browser()
    cds2db::retrieve()
    # browser()
    dataprocessor::processData()
    # browser()
    db2frontend::startDB2Frontend()
  }, error = function(e) {
    # Zerlege die Fehlermeldung in einzelne Zeilen
    error_lines <- unlist(strsplit(e$message, "\n"))

    # Definiere das Muster für die SQL-Spaltenfehler
    allowed_pattern <- "column .* of relation .* does not exist"

    # Prüfe, ob eine der Zeilen das Muster enthält
    if (any(grepl(allowed_pattern, error_lines))) {
      message("Ignoring expected error: ", e$message)

      # `next` nur ausführen, wenn nicht im letzten Schleifendurchlauf
      if (i < length(DEBUG_DATES)) {
        next
      }
    } else {
      stop(e)  # Andere Fehler abbrechen
    }
  })
  cat("END DEBUG_DAY", DEBUG_DAY, "\n")
}
