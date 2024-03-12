# KDS Pipeline

Dieses Repository enthält Module der KDS (Kerndatensatz) Pipeline zur Verarbeitung von [`MII KDS FHIR Ressourcen`](https://www.medizininformatik-initiative.de/de/basismodule-des-kerndatensatzes-der-mii) mit dem Ziel Medikationsprobleme (MRP) zu erkennen. Es handelt sich um eine Referenzimplementierung und ist modular aufgebaut.  Hierbei werden FHIR-Ressourcen vom KDS (Kerndatensatz) FHIR Store heruntergeladen, in eine Tabellenstruktur überführt und in eine Posgres-Datenbank geschrieben. In einen nächsten Schritt werden die Daten geprüft, harmonisiert und mit Hilfe von Algorithmen MRPs berechnet. Anschließend werden die Daten über ein AMTS-Cockpit (z.B. Redcap) auf einer Benutzeroberfläche sichtbar gemacht.

![KDS-Pipeline](https://github.com/medizininformatik-initiative/INTERPOLAR/assets/11329281/e12353d8-a3d2-4a8b-b4ec-ba7b2256cd57)

## Module

Hier werden alle verwendeten Module aufgelistet. Detailliertere Beschreibungen befinden sich im jeweiligen Modul-Ordner.

### R-etlutils

Dieser Ordner ist eine Sammlung von R Funktionen, die von allen R-Modulen des Gesamtprojektes gemeinsam genutzt werden.

### R-kds2db

Dieses R-Modul dient zur Ausleitung Kerndatensatz-konformer Daten in eine Postgres-Datenbank.
```console
docker-compose run --rm --no-deps r-env Rscript R-kds2db/StartRetrieval.R
```

### R-db2frontend

Dieses R-Modul dient zur Übernahme von Daten aus eine Postgres-Datenbank in das Frontent (redcap).
Damit dieses R-Script funktioniert, muss zuvor der Token für die REDCap-API in die Konfigurationsdatei R-db2frontend/db2frontend_config.toml eingetragen werden:
```toml
# REDCap API token
REDCAP_TOKEN = "Fill with your REDCap API token"
```
Den API Token finden Sie im importierten REDCap-Projekt unter: Abschnitt "Applications" im Menu am linken Rand -> API -> Reiter "My Token" -> Button "Create API token now".

Anschließen können Sie die in der AMTS_DB für das Frontend verfügbaren Werte übernehmen:
```console
docker-compose run --rm --no-deps r-env Rscript R-db2frontend/StartDB2Frontend.R
```

### Frontend (redcap)

Austauschbar, aber Referenz mit REDCap ...

#### REDCap-app

Dieses Verzeichnis enthält die REDCap Web-Anwendung inkl. Anweisungen zur Erzeugung der Leufzeitumgebung (Dockerfile). Weitere Anweisungen befinden sich in der [REDCap-app/Readme.md](./REDCap-app/Readme.md)

#### REDCap-db

Die REDCap-app benötigt eine Datenbank (mariadb), welche in diesem Verzeichnis definiert (Passwörter, Umgebundgvariablen, etc.) imd initialisiert (init/redcap.sql) wird. Weitere Anweisungen befinden sich in der [REDCap-db/Readme.md](./REDCap-db/Readme.md)

## Installation

Folgende Anweisungen müssen ausgeführt werden, um die MRP-Pipeline zu verwenden: [Install.md](Install.md)
