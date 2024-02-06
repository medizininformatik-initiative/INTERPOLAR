# MRP Pipeline

Dieses Repository enthält Module der MRP (Medication related problem) Pipeline zur Verarbeitung von [`MII KDS FHIR Ressourcen`](https://www.medizininformatik-initiative.de/de/basismodule-des-kerndatensatzes-der-mii) mit dem Ziel Medikationsprobleme (MRP) zu erkennen. Es handelt sich um eine Referenzimplementierung und ist modular aufgebaut.  Hierbei werden FHIR-Ressourcen vom KDS (Kerndatensatz) FHIR Store heruntergeladen, in eine Tabellenstruktur überführt und in eine Posgres-Datenbank geschrieben. In einen nächsten Schritt werden die Daten geprüft, harmonisiert und mit Hilfe von Algorithmen MRPs berechnet. Anschließend werden die Daten über ein AMTS-Cockpit (hier Redcap) auf einer Oberfläche sichtbar gemacht.

## Module

Hier werden alle verwendeten Module aufgelistet. Detailliertere Beschreibungen befinden sich im jeweiligen Modul-Ordner.

### R-mrputils

Dieser Ordner ist eine Sammlung von R Funktionen, die von allen R-Modulen des Gesamtprojektes gemeinsam genutzt werden.

### R-kds2db

Dieses R-Modul dient zur Ausleitung Kerndatensatz-konformer Daten in eine Postgres-Datenbank.

...
