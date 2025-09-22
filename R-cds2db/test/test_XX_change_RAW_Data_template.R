# Define the days count for this test (integer value)
DEBUG_DAYS_COUNT <- 3

# Test description:
# Patient/Hospital case
# Day 1: what happens on Day 1
# Tag 2: what happens on Day 2
# Tag 3: what happens on Day 3

# This condition must be defined in every test script to prevent the script
# execution if this test will be sourced in the StartDebugCDSToolChain.R file
# to get the value of DEBUG_DAYS_COUNT only.
if (exists("DEBUG_DAY")) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

  # ... common data preparation for all days

  if (DEBUG_DAY == 1) {
    # clear database on Day 1 - activate if needed
    # etlutils::dbReset()
  } else if (DEBUG_DAY == 2) {
    # ...
  } else if (DEBUG_DAY == 3) {
    # ...
  }

}
