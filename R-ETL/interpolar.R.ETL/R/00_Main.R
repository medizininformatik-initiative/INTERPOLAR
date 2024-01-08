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

###
# STOP is set by a Script to TRUE, if this script 'wants' to stop the Scripts Loop
###
STOP <- FALSE

###
# log all console outputs and save them at the end
###
interpolar.R.utils::start_logging('retrieval-total')

###
# Source all R files with a number prefix > 00 in R/ directory (this file here starts
# with 00 and will not be sourced again.
###
for (file in sort(dir(path = 'R/', pattern = '^[0-9][1-9]_.+\\.R$', full.names = TRUE))) {
  source(file)
}

# ###
# # Save all console logs
# ###
interpolar.R.utils::end_logging()
