# chance the working directory to the main directory
if (grepl('/cdstoolchain$', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

# Reset error status
options(error = NULL)

DEBUG_DATES <- c("2025-03-03 13:55:45 CET",
                 "2025-03-04 13:55:45 CET",
                 "2025-03-05 13:55:45 CET",
                 "2025-03-06 13:55:45 CET")

start_full <- Sys.time()
day_times <- c()

for (i in seq_along(DEBUG_DATES)) {
  DEBUG_DAY <- i
  start_day <- Sys.time()
  source("./R-cdstoolchain/StartCDSToolChain.R")
  end_day <- Sys.time()
  diff <- capture.output(print(end_day - start_day))
  day_times <- append(day_times, paste("Day", i, "took", diff))
  print(day_times[i])
}
end_full <- Sys.time()


print("\nAll days took:")
for (i in seq_along(day_times)) {
  print(day_times[i])
}

diff <- capture.output(print(end_full - start_full))
print(paste("All days took", diff))

#'
#' Loads all tables from subdirectory 'tables' of the last directory
#' in the given tale_path.
#'
loadTables <- function(table_path, name_pattern = NA) {
  table_names <- list.files(path = table_path, pattern = ".\\.RData$")
  if (!is.na(name_pattern)) {
    table_names <- table_names[grep(name_pattern, table_names, ignore.case = TRUE)]
  }
  tables <- list()
  for (table_name in table_names) {
    full_table_path <- paste0(table_path, table_name)
    table <- try(readRDS(full_table_path), silent = TRUE)
    if (data.table::is.data.table(table)) {
      tables <- append(tables, list(table))
      names(tables)[length(tables)] <- gsub("\\.RData$", "", table_name)
    }
  }
  return(tables)
}

#tables <- loadTables("./outputLocal/db2frontend/tables/")
