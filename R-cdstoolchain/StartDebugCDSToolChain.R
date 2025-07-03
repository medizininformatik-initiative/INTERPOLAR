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
DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS <<- 0

for (debug_day_index in seq_along(DEBUG_DATES)) {
  DEBUG_DAY <- debug_day_index
  start_day <- Sys.time()
  source("./R-cdstoolchain/StartCDSToolChain.R")
  end_day <- Sys.time()
  diff <- capture.output(print(end_day - start_day))
  day_times <- append(day_times, paste("Day", debug_day_index, "took", diff))
  print(day_times[debug_day_index])
}
end_full <- Sys.time()

cat("\nAll days took:")
for (debug_day_index in seq_along(day_times)) {
  print(day_times[debug_day_index])
}

diff <- capture.output(print(end_full - start_full))
print(paste("All days took", diff))
