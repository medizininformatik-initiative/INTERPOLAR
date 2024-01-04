###
# Read the configuration toml file
###
CONFIG <- RcppTOML::parseToml(paste0('../interpolar_R_ETL_config.toml'))

###
# Create globally used polar_clock
###
POLAR_CLOCK <- interpolar.R.utils::createClock()

###
# Set the project name to 'interpolar'
PROJECT_NAME <<- 'interpolar'
###

###
# Set the project timestamp to the current date and time in the format '-%Y-%m%d-%H%M%S'
PROJECT_TIME_STAMP <<- format(Sys.time(), "-%Y-%m%d-%H%M%S")
###

###
# Take nested list CONFIG and flattens it into a single-level list
# Remove parent names from variable names
# And assign list values to the global environment
flatten_CONFIG <- interpolar.R.utils::flatten_list(CONFIG)
# Extract variable names from flatten_CONFIG
variable_names <- names(flatten_CONFIG)
# Assign values to variables from flatten_CONFIG
for (variable_name in variable_names) {
  assign(variable_name, flatten_CONFIG[[variable_name]])
}
rm(variable_name, variable_names, flatten_CONFIG)
###

interpolar.R.utils::create_dirs(PROJECT_NAME)

source('R/01_Table_Description.R')

##
# print disclaimer if Verbose Level allows it
###
# if (1 <= VERBOSE) {
#   browser()
#   cat(interpolar.R.utils::polar_disclaimer())
# }

###
# STOP is set by a Script to TRUE, if this script 'wants' to stop the Scripts Loop
###
STOP <- FALSE

###
# log all console outputs and save them at the end
###
interpolar.R.utils::start_logging('retrieval-total')

interpolar.R.utils::run_in(toupper('get_encounters'), {
PERIOD_START <- "2019-01-02"
PERIOD_END <- "2019-06-02"
browser()
interpolar.R.utils::get_encounters()
})

#build FHIR-Server-Requests
request <- fhircrackr::fhir_url(url = FHIR_SERVER_ENDPOINT, resource = "Encounter")
#download and crack bundles
bundles <- fhircrackr::fhir_search(request, max_bundles = 5)
table_enc <- fhircrackr::fhir_crack(bundles = bundles, design = TABLE_DESCRIPTION$Encounter, verbose = 10)

###
# Save all console logs
###
interpolar.R.utils::end_logging()
