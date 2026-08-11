# Datenverfuegbarkeit: kein REDCap-Testdatenbedarf.
#
# Der zugehoerige RAW-Test erzeugt zwei FHIR-Faelle fuer denselben Patienten:
# einen INTERPOLAR-Fall auf Station 1 und einen Nicht-INTERPOLAR-Fall auf
# Station 3. Fuer die Database Quality Analysis werden keine zusaetzlichen
# REDCap-Daten benoetigt. Diese Datei existiert bewusst, damit der Debuglauf
# fuer DEBUG_TEST_INDEX 15 ein passendes REDCap-Change-Skript findet.

source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

if (isDebugDay(1)) {
  invisible(NULL)
}
