# Fallvignette Process Evaluation

Dieses Dataprocessor-Submodul bereitet die Daten für die Fallvignetten der
Prozessevaluation aus Arbeitspaket 8 auf.

Die fachliche Verarbeitung wird im Rahmen von Issue #1328 ergänzt.

Die zu verwendende Mapping-Datei wird über
`FALLVIGNETTE_MAPPING_FILE_NAME` in
`fallvignette_process_evaluation_config.toml` konfiguriert. Die Arbeitsmappe
muss genau ein Tabellenblatt enthalten.

Die WP7-MRP-Listen und das LOINC-Mapping werden lokal aus dem über
`INPUT_REPO_PATH` konfigurierten Repository geladen. Anschließend wird der
Datenbankkontext anhand von `PATH_TO_DB_CONFIG_TOML` und den dort hinterlegten
`DB_ANALYSIS_*`-Werten auf die pseudonymisierte Datenbank umgeschaltet. Alle
Fall-, Patienten- und FHIR-Daten werden ausschließlich aus dieser Datenbank
gelesen. CSV und XLSX werden unter `outputGlobal/dataprocessor/reports`
geschrieben.

Das standortspezifische Kürzel wird zentral über `SITE_CODE` in der
`dataprocessor_config.toml` konfiguriert. Es muss in
`dataprocessor/inst/extdata/Standortkuerzel.xlsx` enthalten sein und wird vor
dem Schreiben jeder Importzeile mit SHA-256 pseudonymisiert.

Die DB-Basisabfrage berücksichtigt retrospektive MRPs mit mindestens einer
Bewertung als sachlich richtig, aber klinisch nicht relevant. Test-MRPs werden
ausgeschlossen. Zusätzlich muss für dieselbe Medikationsanalyse mindestens
eine MRP-Dokumentation vorhanden sein.

Für jede Importzeile wird eine lokale ID aus `SITE_CODE` und einer
fortlaufenden, vierstellig aufgefüllten Nummer gebildet, beispielsweise
`UKB0001`. Als `record_id` wird ausschließlich deren SHA-256-Hash exportiert.
`wp8_standort_id` enthält weiterhin den SHA-256-Hash des Standortkürzels. Der
Fachbereich wird anhand von `fall_station` aus dem
`department` der passenden `PHASES_WARD`-Definition übernommen. Alter,
Geschlecht, Gewicht und Schwangerschaftsstatus werden direkt aus den in der
Mapping-Datei angegebenen DB-Quellfeldern übertragen. Dasselbe gilt für alle
gemappten `ret_`-Felder. Enthält eine retrospektive MRP-Bewertung zwei als
sachlich richtig, aber klinisch nicht relevant markierte Bewertungen, werden
zwei Importzeilen mit jeweils eigener `record_id` erzeugt.

Zur lokalen Rückverfolgung wird zusätzlich unter
`outputLocal/dataprocessor/data` eine über
`FALLVIGNETTE_ID_MAPPING_FILE_NAME` benannte
`Fallvignette_Process_Evaluation_ID_Mapping.xlsx` geschrieben. Sie
enthält die gehashte `record_id`, die lokale ID und verfügbare Fall-,
Medikationsanalyse- und MRP-Kennungen. Diese Datei muss am exportierenden
Standort verbleiben und darf nicht zusammen mit dem REDCap-Import übertragen
werden.

Diagnosen des aktuellen Falls werden unabhängig von den WP7-Listen
übernommen. Diagnosen aus früheren Fällen werden nur aufgenommen, wenn ihr
ICD-Code in der verarbeiteten WP7-Drug-Disease-Liste enthalten und zum
Zeitpunkt der Medikationsanalyse noch gültig ist. Die Ausgabe bleibt
duplikaterhaltend, wird alphabetisch nach Diagnosetext sortiert und enthält
den Diagnosezeitpunkt, sofern dieser verfügbar ist.

Medikationen werden zunächst über `medreq_encounter_calculated_ref` dem
Hauptencounter zugeordnet. Die Aktivitätsprüfung verwendet dieselbe
`getActiveATCs()`-Logik wie die reguläre MRP-Berechnung. Zusätzlich muss der
Medikationsbeginn am oder vor dem Zeitpunkt der Medikationsanalyse liegen.
Ausgegeben werden bevorzugt Wirkstoff und ATC-Code, ersatzweise der PZN-Code.
