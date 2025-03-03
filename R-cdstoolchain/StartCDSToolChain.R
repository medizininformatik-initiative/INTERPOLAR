# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

debug_days <- c(1:2)  # Liste der Durchläufe

for (i in seq_along(debug_days)) {
  DEBUG_DAY <- debug_days[i]

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
      if (i < length(debug_days)) {
        next
      }
    } else {
      stop(e)  # Andere Fehler abbrechen
    }
  })
  cat("END DEBUG_DAY", DEBUG_DAY, "\n")
}
