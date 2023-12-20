###
# Read the configuration toml file
###
CONFIG <- RcppTOML::parseToml(paste0('../interpolar_R_ETL_config.toml'))

###
# Create globally used polar_clock
###
polar_clock <- interpolar.R.utils::createClock()

PROJECT_NAME <<- 'interpolar'
PROJECT_TIME_STAMP <<- format(Sys.time(), "-%Y-%m%d-%H%M%S")


source('01_Table_Description.R')


