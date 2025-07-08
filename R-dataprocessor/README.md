# "dataprocessor" - Analyse und Umwandung von Daten für das Frontend oder eine Ausleitung

Generell ist das Modul "dataprocessor" dazu gedacht, Daten zu transformieren und für eine Ausgabe im Frontend oder für eine Ausleitung zur Verfügung zu stellen.

Seit Version [0.2.x](https://github.com/medizininformatik-initiative/INTERPOLAR/releases) nutzt es die im [Modul "cds2db"](R-cds2db) typisierten Daten aus der Postgres-Datenbank, um Tabellen mit relevanten Patienten und Fallinformationen zu erstellen. Diese werden auch zurück in die Postgres-Datenbank geschrieben und anschließend über das [Modul "db2frontend"](../R-db2frontend) dem Frontend zur Verfügung gestellt.

## Konfiguration

Der Data Processor kann über die Datei [dataprocessor_config.toml](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-dataprocessor/dataprocessor_config.toml) konfiguriert werden. Alle Parameter sind in der Datei durch Kommentare beschrieben.

### Anpassung der Codes für Körpergröße, -gewicht und BMI

Im Abschnitt "analyse" in der toml-Datei können die auf dem FHIR-Server verfügbaren Codes und Codesysteme für Körpergröße, -gewicht und BMI eingestellt werden. Es werden nur Observationen gefunden, die genau diese Codes enthalten.

### Debug-Option: Manueller Zeitstempel

Im Abschnitt "debug" kann manuell einen spezifischen Analyse Zeitstempel gesetzt werden.
Weitere Informationen stehen direkt in diesem Abschnitt in der toml-Datei. 

## Ausführung des Moduls

Das R-Skript [StartDataProcessor.R](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-dataprocessor/StartDataProcessor.R) startet den Data Processor.
```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R
```
