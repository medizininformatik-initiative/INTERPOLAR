# "MRP_Check" - Berechnung aller MRPs auf Daten aus der Vergangenheit

## Version 0.1 (01.12.2025)

### Funktion

Berechne alle MRP-Arten auf den Daten der Vergangenheit unabhängig von der Studienphase des Falls.
Voraussetzung ist, dass der Fall mind. eine Medikationsanalyse und [weitere Eigenschaften](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/1043) hat, die
ein MRP auslösen.

### Konfiguration

- Im Projektordner liegt eine `database.toml`. Ihr absichtlich leerer `DB_NAME`
  muss vor dem Start gesetzt werden. Weitere Verbindungswerte werden aus der
  normalen Datenbankkonfiguration geerbt. Nur nicht leere Projektwerte
  überschreiben sie. Die gemeinsame Vorlage für neue Projekte liegt unter
  `R-dataprocessor/submodules/manual_start/database_example.toml`. Ein
  Image-Neubau ist nach einer Änderung nicht erforderlich.
- abgefragter Zeitraum konfigurierbar über Start- und Enddatum als Argument
- fehlt das Enddatum, wird der aktuelle Ausführungszeitpunkt genommen
- fehlt das Startdatum, wird der aktuelle Ausführungszeitpunkt - 60 Tage genommen
- Enddatum muss gleich dem Startdatum oder größer als dieses sein

### Ausführung

Aufruf des dataprocessors mit folgenden Argumenten:

-   `mrp-check`(=Name des Submoduls im Ordner manual_start, wobei Groß-/Kleinschreibung ignoriert wird und statt eine `_` auch ein `-` genutzt werden kann) als Argument anhängen

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check
```

Ohne zusätzliches Argument startet `MRP_Check` nur auf einer pseudonymisierten
Snapshot-Datenbank. Für jede andere kompatible Datenbank ist bewusst zusätzlich
`--force` erforderlich.

-   optional Anpassung des Zeitraumes über die Argumente `start-date` und `end-date` mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check start-date=2025-09-01 end-date=2025-09-08
```

### Ergebnis

- Tabelle `MRP_Check_Result_local.xlsx` im Ordner `outputLocal/dataprocessor/tables` mit allen IDs, wie sie in FHIR und REDCap vorkommen
- Tabelle `MRP_Check_Result_global.xlsx` im Ordner `outputGlobal/dataprocessor/tables` mit anonymisierten IDs (durchnummeriert)
