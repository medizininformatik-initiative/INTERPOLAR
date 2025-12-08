# "MRP_Check" - Berechnung aller MRPs auf Daten aus der Vergangenheit

## Version 0.1 (01.12.2025)

### Funktion

Berechne alle MRP-Arten auf den Daten der Vergangenheit unabhängig von der Studienphase des Falls.
Voraussetzung ist, dass der Fall mind. eine Medikationsanalyse und [weitere Eigenschaften](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/1043) hat, die
ein MRP-Auslösen.

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

### Ergebnis

- Tabelle `MRP_Check_Result_local.xlsx` im Ordner `outputLocal/dataprocessor/tables` mit allen IDs, wie sie in FHIR und REDCap vorkommen
- Tabelle `MRP_Check_Result_global.xlsx` im Ordner `outputGlobal/dataprocessor/tables` mit anonymisierten IDs (durchnummeriert)
