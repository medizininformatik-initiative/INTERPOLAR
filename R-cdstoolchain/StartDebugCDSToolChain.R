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

cat("\nAll days took:")
for (i in seq_along(day_times)) {
  print(day_times[i])
}

diff <- capture.output(print(end_full - start_full))
print(paste("All days took", diff))
