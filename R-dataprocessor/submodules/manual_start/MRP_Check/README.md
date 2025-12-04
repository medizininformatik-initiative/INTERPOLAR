# "MRP_Check" - Berechnung aller MRPs auf Daten aus der Vergangenheit

## Version 0.1 (01.12.2025)

### Funktion

Berechne alle MRP-Arten auf den Daten der Vergangenheit. Das Ergebnis wird als 
Excel-Dateien in den Ordnern outputLocal und outputGLobal zur Verfügung gestellt.

### Konfiguration

- abgefragter Zeitraum konfigurierbar über Start- und Endedatum als Argument
- fehlt das Enddatum, wird der aktuelle Ausführungszeitpunkt genommen
- fehlt das Startdatum, wird der aktuelle Ausführungszeitpunkt - 60 Tage genommen
- Enddatum muss gleich dem Startdatum oder größer als dieses sein

### Ausführung

Aufruf des dataprocessors mit folgenden Argumenten:

-   `mrp-check`(=Name des Submoduls im Ordner manual_start, wobei Groß-/Kleinschreibung ignoriert wird und statt eine `_` auch ein `-` genutzt werden kann) als Argument anhängen

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check
```

-   optional Anpassung des Zeitraumes über die Argumente `start-date` und `end-date` mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check start-date=2025-09-01 end-date=2025-09-08
```
