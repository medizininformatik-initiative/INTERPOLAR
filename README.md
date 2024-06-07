# CDS tool chain

Dieses Repository enthält die Bestandteile der CDS tool chain zur Verarbeitung von [`MII KDS FHIR Ressourcen`](https://www.medizininformatik-initiative.de/de/basismodule-des-kerndatensatzes-der-mii). Es handelt sich um eine modular aufgebaute Referenzimplementierung, welche z.B. Datenintegrationszentren (DIZ) der MII eingesetzt werden kann. Hierbei werden FHIR-Ressourcen vom KDS (Kerndatensatz) FHIR Server / Endpunkt heruntergeladen, in eine Tabellenstruktur überführt  ([CDS2DB](./README.md#cds2db)) und in eine Posgres-Datenbank (CDS_HUB) geschrieben. In einen nächsten Schritt werden die Daten geprüft, harmonisiert und können mit Hilfe von Algorithmen weiter verarbeitet werden (DataProcessor). Anschließend werden die Daten über ein Frontend (z.B. Redcap) auf einer Benutzeroberfläche sichtbar gemacht (DB2Frontend, Frontend).

![CDS tool chain](https://github.com/medizininformatik-initiative/INTERPOLAR/assets/11329281/452b133c-0f43-40a3-b46d-e921f5825cbc)

## Bestandteile der CDS tool chain

Hier werden alle verwendeten Bestandteile aufgelistet. Detailliertere Beschreibungen befinden sich im jeweiligen Ordner.

### FHIR Server / Endpunkt

Hierbei handelt es sich um die vom Datenintegrationszentrum zur Verfügung gestellten FHIR Server. Zu Testzwecken ist es zudem möglich, andere FHIR Server mit KDS-konformen FHIR Ressourcen zu konfigurieren, z.B. die der MII Testinfrastruktur ([kerndatensatz-testdaten](https://github.com/medizininformatik-initiative/kerndatensatz-testdaten)).

### CDS2DB

Dieses R-Modul dient zur Ausleitung Kerndatensatz-konformer Daten in eine Postgres-Datenbank.

Der Quellcode (R) dafür befindet sich im Ordner [R-cds2db](./R-cds2db).

Eine Beschreibung zur Konfiguration und Ausführung befindet sich in [R-cds2db/README.md](./R-cds2db/README.md).

### CDS_HUB

Beim CDS_HUB handelt es sich um eine relationale Datenbank (Postgres). Im Ordner [Postgres-cds_hub](./Postgres-cds_hub) befinden sich Dateien für die Konfiguration und Initialisierung.

Eine Beschreibung der Datenbankstruktur befindet sich unter [Postgres-cds_hub/DB_description.md](./Postgres-cds_hub/DB_description.md). \
Eine Beschreibung, wie der Zugriff erfolgt befindet sich unter [Postgres-cds_hub/Readme.md](./Postgres-cds_hub/Readme.md) .

### DataProcessor

Der DataProcessor verarbeitet die Daten des CDS_HUB. Diese Verarbeitung kann z.B. eine Filterung von zuvor importierten Daten für die Anzeige im Frontend sein.

Weitere Informationen zum DataProcessor befinden sich im Ordner [R-dataprocessor](./R-dataprocessor).

### Input-Repo

Das Input-Repo wird in zukünftigen Releases für den Zugriff auf Algorithmen zur Berechnung, z.B. von Scores, verwendet.

### DB2Frontend

Dieses R-Modul befindet sich im Ordner [R-db2frontend](./R-db2frontend) und dient der Übernahme von Daten aus dem CDS_HUB (Postgres-Datenbank) in das Frontent (redcap) und vom im Frontend erfassten Daten in den CDS_HUB. 

### Frontend (REDCap)

Das Frontend dient der Anzeige von importierten KDS-FHIR Daten und zur Erfassung von Rückmeldungen.
Das Frontend ist eine Web-Anwendung und besteht aus 2 Teilen. 

Die Web-Anwendung (PHP) befindet sich im Verzeichnis [REDCap-app](./REDCap-app). 
Dieses Verzeichnis enthält u.a. Anweisungen zur Erzeugung der Laufzeitumgebung (Dockerfile).

Die REDCap-app benötigt eine Datenbank (mariadb), welche sich im Verzeichnis [REDCap-db](./REDCap-db) befindet. Dort befinden sich zudem Dateien zum Setzen von Passwörtern, Umgebundgvariablen, etc. sowie zur Initialisierung der Datenbank (init/redcap.sql).

### R-etlutils

Dieser Ordner ist eine Sammlung von R Funktionen, die von den R-Modulen (CDS2DB, DataProcessor, DB2Frontend) der CDS tool chain genutzt werden.


## Installation

Folgende Anweisungen müssen ausgeführt werden, um die CDS tool chain zu verwenden: [Install.md](Install.md)

## Hilfe und Unterstützung
- [Frequently Asked Questions (FAQ)](https://github.com/medizininformatik-initiative/INTERPOLAR/wiki/Frequently-Asked-Questions-%E2%80%90-FAQ)

