# "MRP_Check" - Berechnung aller MRPs auf Daten aus der Vergangenheit

## Version 0.1 (01.12.2025)

### Funktion

Berechne alle MRP-Arten auf den Daten der Vergangenheit. Das Ergebnis wird als 
Excel-Dateien in den Ordnern outputLocal und outputGLobal zur Verfügung gestellt.

### Konfiguration

TODO: abgefragter Zeitraum konfigurierbar - erste Version nimmt die letzten 2 Monate

### Ausführung

Aufruf des dataprocessors mit folgenden Argumenten:

-   `MRP_Check`(=Name des Submoduls im Ordner manual_start) als Argument anhängen

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R MRP_Check
```

#### TODO:

-   optional Anpassung des Zeitraumes über die Argumente `REPORT_PERIOD_START`und `REPORT_PERIOD_END`mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD oder YYYY/MM/DD

-   optional Ausgabe der zu Grunde liegenden Datentabellen in outputLocal über das Argument `WRITE_TABLE_LOCAL=TRUE`

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R Statistical_Reports REPORT_PERIOD_START=2025-09-01 REPORT_PERIOD_END=2025-09-08 WRITE_TABLE_LOCAL=TRUE
```
