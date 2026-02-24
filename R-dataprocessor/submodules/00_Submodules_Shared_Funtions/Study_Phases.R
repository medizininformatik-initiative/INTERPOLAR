#
# Get the study phase for a unique ward_name from defined toml parameters.
#
getStudyPhase <- function(ward_name) {
  if (etlutils::isDefinedAndNotEmpty("WARDS_PHASE_A") && ward_name %in% WARDS_PHASE_A) {
    return("PhaseA")
  }
  if (etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B_TEST") && ward_name %in% WARDS_PHASE_B_TEST) {
    return("PhaseBTest")
  }
  if (etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B") && ward_name %in% WARDS_PHASE_B) {
    return("PhaseB")
  }
  return(NULL)
}

#
# Check if the study has no or not only Phase A wards defined in the configuration.
#
hasPhaseBOrBTestWards <- function() {
  return(etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B") || etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B_TEST"))
}

#
# Check if the study has Phase B wards defined in the configuration.
#
isPhaseBActive <- function() {
  return(etlutils::isDefinedAndNotEmpty("WARDS_PHASE_B"))
}
