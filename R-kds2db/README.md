# kds2db - ETL Prozess zur Ausleitung Kerndatensatz-konformer Daten (KDS) in eine Datenbank

Diese Implementierung beinhaltet ETL-Prozesses zur Überführung KDS-konformer Daten von einem FHIR-Server in eine Postgres-Datenbank.

Die Ausleitung der FHIR-Daten in die Datenbank sollte 1 mal täglich passieren. Dabei werden die Daten aller Patienten, die sich auf einer der relevanten Stationen befinden bzw. die sich am Tag zuvor auf einer der relevanten Stationen befanden vom FHIR-Server geladen und in die Datenbank überspielt.

## Konfiguration

Der ETL-Prozess kann über die Datei [kds2db_config.toml](kds2db_config.toml) konfiguriert werden. Alle Parameter sind in der Datei durch Kommentare beschrieben. Hier werden unter anderem die Parameter zum Aufruf der Datenbank, als auch des FHIR-Servers angegeben.

### Extraktion relevanter Patienten

Die Übermittlung der Patienten relevanter Stationen erfolgt über einen der beiden folgenden Varianten.

#### Die relevanten Patienten werden über Informationen aus den FHIR-Daten ermittelt

Bei dieser Variante ist es notwendig, dass die relevanten Stationen aus dem FHIR-Profil [Encounter](https://www.medizininformatik-initiative.de/Kerndatensatz/Modul_Fall/EncounterKontaktGesundheitseinrichtung.html) ausgelesen werden können. Dabei werden in der Config-Datei Name der Station und Stationsidentifier angegeben (siehe Parameter, 'ENCOUNTER_FILTER_PATTERN').

#### Die relevanten Patienten werden über Informationen aus einer Textdatei mit Patientenliste ermittelt

Bei dieser Variante gibt es eine Textdatei, in der die relevanten Stationen mit jeweiligen Patienten hinterlegt sind. Hierfür muss der Parameter 'PATH_TO_PID_LIST_FILE' aktiviert werden.

## Ausführung des Moduls

Das R-Skript [StartRetrieval.R](StartRetrieval.R) startet das Retrieval für den ETL-Prozess.

## Details der Implementierung

Weitere Details siehe [README](./README.md) des R Packages kds2db.
