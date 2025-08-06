# chance the working directory to the main directory
if (grepl('/cdstoolchain', getwd())) setwd("../..")
if (grepl('/R-cdstoolchain', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)
library(dataprocessor)
library(db2frontend)

# Reset error status
options(error = NULL)

start_full <- Sys.time()
datetime_minus_2_day <- start_full - as.difftime(2, units = "days")
datetime_minus_1_day <- start_full - as.difftime(1, units = "days")

DEBUG_DATES <- c(#datetime_minus_2_day,
                 datetime_minus_1_day,
                 start_full
                 #"2025-03-03 13:55:45 CET",
                 #"2025-03-04 13:55:45 CET",
                 #"2025-03-05 13:55:45 CET",
                 #"2025-03-06 13:55:45 CET",
                 #"2025-03-07 13:55:45 CET",
                 #"2025-03-08 13:55:45 CET"
)

day_times <- c()

for (debug_day_index in seq_along(DEBUG_DATES)) {
  DEBUG_DAY <- debug_day_index
  start_day <- Sys.time()
  source("./R-cdstoolchain/StartCDSToolChain.R")
  end_day <- Sys.time()
  diff <- capture.output(print(end_day - start_day))
  day_times <- append(day_times, paste("Day", debug_day_index, "took", diff))
  print(day_times[debug_day_index])
#  browser()
}
end_full <- Sys.time()

cat("\nAll days took:")
for (debug_day_index in seq_along(day_times)) {
  print(day_times[debug_day_index])
}

diff <- capture.output(print(end_full - start_full))
print(paste("All days took", diff))
