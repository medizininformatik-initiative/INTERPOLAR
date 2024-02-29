# kds2db - ETL Prozess zur Ausleitung Kerndatensatz-konformer Daten (KDS) in eine Datenbank

Diese Implementierung beinhaltet ETL-Prozesses zur Überführung KDS-konformer Daten von einem FHIR-Server in eine Postgres-Datenbank.

Die Ausleitung der FHIR-Daten in die Datenbank sollte 1 mal täglich passieren. Dabei werden die Daten aller Patienten, die sich auf einer der relevanten Stationen befinden bzw. die sich am Tag zuvor auf einer der relevanten Stationen befanden vom FHIR-Server geladen und in die Datenbank überspielt.

## Konfiguration

Der ETL-Prozess kann über die Datei [kds2db_config.toml](kds2db_config.toml) konfiguriert werden. Alle Parameter sind in der Datei durch Kommentare beschrieben. Hier werden u.a. sowohl die logging-Parameter, als auch die Parameter zum Zugriff auf den FHIR-Server angegeben.

### Extraktion relevanter Patienten

Die Ermittlung der Patienten relevanter Stationen erfolgt über eine der beiden folgenden Varianten.

#### Variante 1: Die relevanten Patienten werden über Informationen aus den FHIR-Daten ermittelt

Bei dieser Variante ist es notwendig, dass die relevanten Stationen aus dem FHIR-Profil [Encounter](https://www.medizininformatik-initiative.de/Kerndatensatz/Modul_Fall/EncounterKontaktGesundheitseinrichtung.html) ausgelesen werden können.\
Ziel ist es Patienten-IDs von Encountern zu finden, die bestimmte Eigenschaften in den FHIR-Daten aufweisen. Idealerweise sollte es so etwas sein wie, der Encounter ist noch nicht abgeschlossen und als ServiceProvider ist der gesuchte Stationsname angegeben oder der Encounter referenziert eine Location mit einem bestimmten Namen.\
Die Encounter können also über beliebige Einträge identifiziert werden. Es ist frei konfigurierbar und auf die lokalen Gegebenheiten am DIZ einstellbar. Die Beschreibung der Einstellungsmöglichkeiten befinden sich direkt in der toml-Datei als Kommentar zu den ENCOUNTER_FILTER_PATTERN.

#### Variante 2: Die relevanten Patienten werden über Informationen aus einer Textdatei mit Patientenliste ermittelt

Diese Variante sollte genommen werden, wenn es keine Möglichkeit gibt die aktuellen Fälle der Stationen über die Encounter zu ermitteln.
Bei dieser Variante muss das DIZ eine Textdatei erzeugen, die folgende Form hat: [source_PIDs](source_PIDs.txt). Diese Datei muss ständig aktualisiert werden. Wie ein DIZ diese Datei erzeugt, ist ihm selbst überlassen. Um diese Variante 2 zu aktivieren und damit die Variante 1 auszuschalten, muss der Parameter 'PATH_TO_PID_LIST_FILE' aktiviert werden und der Pfad auf die entsprechende Datei zeigen.

## Ausführung des Moduls

Das R-Skript [StartRetrieval.R](StartRetrieval.R) startet das Retrieval für den ETL-Prozess.

## Details der Implementierung

Weitere Details siehe [README](./README.md) des R Packages kds2db.
