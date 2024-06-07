# Data Processor

Dies ist das Data Processor Modul, in dem typisierte Daten von der Postgres-Datenbank eingelesen und gefiltert werden. Anschließend werden Tabellen mit relevanten Patienten und Fallinformationen erstellt und zurück in die Postgres-Datenbank geschrieben.  

## Konfiguration

Der Data Processor kann über die Datei [dataprocessor_config.toml](dataprocessor_config.toml) konfiguriert werden. Alle Parameter sind in der Datei durch Kommentare beschrieben.

### Anpassung der Codes für Körpergröße, -gewicht und BMI

Im Abschnitt "analyse" in der toml-Datei können die auf dem FHIR-Server verfügbaren Codes und Codesysteme für Körpergröße, -gewicht und BMI eingestellt werden. Es werden nur Observationen gefunden, die genau diese Codes enthalten.

### Debug-Option: Manueller Zeitstempel

Im Abschnitt "debug" kann manuell einen spezifischen Analyse Zeitstempel gesetzt werden.
Weitere Informationen stehen direkt in diesem Abschnitt in der toml-Datei. 

## Ausführung des Moduls

Das R-Skript [StartDataProcessor.R](StartDataProcessor.R) startet den Data Processor.
```console
docker-compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R
```
