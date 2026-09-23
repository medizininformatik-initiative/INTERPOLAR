# 01_Study_1a – Patienten- und Falldaten für das Frontend

Dieses reguläre DataProcessor-Submodul bereitet importierte Patienten- und
Encounter-Daten für die Anzeige im Frontend auf. Es verbindet die Stationszuordnung
mit Patientenstammdaten und Fallinformationen, beispielsweise Aufnahme, Entlassung,
Diagnosen, Körpermaßen und Studienphase.

## Voraussetzungen und Konfiguration

Es gelten die [gemeinsamen Voraussetzungen](../../README.md#voraussetzungen) und die
[DataProcessor-Konfiguration](../../README.md#konfiguration). Benötigt werden die
importierten FHIR-Daten und Stationszuordnungen aus CDS2DB sowie vorhandene
Frontend-Daten im CDS_HUB. Relevant sind insbesondere `PHASES_WARD_*`,
`FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_*`,
`MEDICAL_CASE_ID_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM`,
`FRONTEND_DISPLAYED_ENCOUNTER_CLASS` und die Codes für Größe, Gewicht und BMI.

## Ausführung

`01_Study_1a` läuft automatisch vor der regulären MRP-Berechnung. Der folgende
Aufruf aus dem Repository-Stamm startet den gesamten regulären DataProcessor:

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R
```

[Start.R](Start.R) ruft `createFrontendTables()` aus dem
[R-Subprojekt study1a](R-Study_1a/README.md) auf.

## Ergebnis

Die aufbereiteten Patienten- und Falldaten werden als `patient_fe` und `fall_fe`
in die Datenbank geschrieben. [DB2Frontend](../../../R-db2frontend/README.md)
überträgt sie im nachfolgenden Toolchain-Schritt nach REDCap. Dieses Submodul
aktualisiert damit Datenbankinhalte; es ist kein eigenständiger Dateiexport.

Zurück zur [DataProcessor-Submodulübersicht](../../README.md#submodule-auf-einen-blick)
· [INTERPOLAR](../../../README.md).
