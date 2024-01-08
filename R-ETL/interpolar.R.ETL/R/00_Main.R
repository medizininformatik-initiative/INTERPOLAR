###
# Read the configuration toml file
###

interpolar.R.utils::initConstants('../interpolar_R_ETL_config.toml')

###
# Create globally used polar_clock
###
POLAR_CLOCK <- interpolar.R.utils::createClock()

###
# Set the project name to 'interpolar'
PROJECT_NAME <<- 'interpolar'
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
