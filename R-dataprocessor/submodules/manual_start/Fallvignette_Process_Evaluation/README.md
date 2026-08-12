# Fallvignette Process Evaluation

Dieses Dataprocessor-Submodul bereitet die Daten für die Fallvignetten der
Prozessevaluation aus Arbeitspaket 8 auf.

Die fachliche Verarbeitung wird im Rahmen von Issue #1328 ergänzt.

Die zu verwendende Mapping-Datei wird über
`FALLVIGNETTE_MAPPING_FILE_NAME` in
`fallvignette_process_evaluation_config.toml` konfiguriert. Die Arbeitsmappe
muss genau ein Tabellenblatt enthalten.

Das standortspezifische Kürzel wird zentral über `SITE_CODE` in der
`dataprocessor_config.toml` konfiguriert. Es muss in
`dataprocessor/inst/extdata/Standortkuerzel.xlsx` enthalten sein und wird vor
dem Schreiben jeder Importzeile mit SHA-256 pseudonymisiert.

Die DB-Basisabfrage berücksichtigt retrospektive MRPs mit mindestens einer
Bewertung als sachlich richtig, aber klinisch nicht relevant. Test-MRPs werden
ausgeschlossen. Zusätzlich muss für dieselbe Medikationsanalyse mindestens
eine MRP-Dokumentation vorhanden sein.

Die Basisdaten für den Import enthalten eine neu generierte UUID als
`record_id` und den SHA-256-Hash des Standortkürzels als `wp8_standort_id`. Der
Fachbereich wird anhand von `fall_station` aus dem
`department` der passenden `PHASES_WARD`-Definition übernommen. Alter,
Geschlecht, Gewicht und Schwangerschaftsstatus werden direkt aus den in der
Mapping-Datei angegebenen DB-Quellfeldern übertragen. Dasselbe gilt für alle
gemappten `ret_`-Felder. Enthält eine retrospektive MRP-Bewertung zwei als
sachlich richtig, aber klinisch nicht relevant markierte Bewertungen, werden
zwei Importzeilen mit jeweils eigener `record_id` erzeugt.

Diagnosen des aktuellen Falls werden unabhängig von den WP7-Listen
übernommen. Diagnosen aus früheren Fällen werden nur aufgenommen, wenn ihr
ICD-Code in der verarbeiteten WP7-Drug-Disease-Liste enthalten und zum
Zeitpunkt der Medikationsanalyse noch gültig ist. Die Ausgabe bleibt
duplikaterhaltend, wird alphabetisch nach Diagnosetext sortiert und enthält
den Diagnosezeitpunkt, sofern dieser verfügbar ist.
