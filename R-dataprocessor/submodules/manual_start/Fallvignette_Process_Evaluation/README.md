# Fallvignette Process Evaluation

Dieses Dataprocessor-Submodul bereitet die Daten für die Fallvignetten der
Prozessevaluation aus Arbeitspaket 8 auf.

Die fachliche Verarbeitung wird im Rahmen von Issue #1328 ergänzt.

Die zu verwendende Mapping-Datei wird über
`FALLVIGNETTE_MAPPING_FILE_NAME` in
`fallvignette_process_evaluation_config.toml` konfiguriert. Die Arbeitsmappe
muss genau ein Tabellenblatt enthalten.

Die DB-Basisabfrage berücksichtigt retrospektive MRPs mit gültigem Broad
Consent und mindestens einer Bewertung als sachlich richtig, aber klinisch
nicht relevant. Test-MRPs werden ausgeschlossen. Zusätzlich muss für dieselbe
Medikationsanalyse mindestens eine MRP-Dokumentation vorhanden sein.
