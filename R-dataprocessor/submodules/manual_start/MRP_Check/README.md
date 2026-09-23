# "MRP_Check" - Berechnung aller MRPs auf Daten aus der Vergangenheit

[DataProcessor-Submodulübersicht](../../../README.md#submodule-auf-einen-blick)
· [INTERPOLAR](../../../../README.md)

## Version 0.1 (01.12.2025)

### Funktion

Berechne alle MRP-Arten auf den Daten der Vergangenheit unabhängig von der Studienphase des Falls.
Voraussetzung ist, dass der Fall mind. eine Medikationsanalyse und [weitere Eigenschaften](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/1043) hat, die
ein MRP auslösen.

### Konfiguration

- Die [gemeinsame Datenbankkonfiguration für manuelle Projekte](../../../README.md#datenbank-für-manuelle-projekte)
  beschreibt `database.toml`, Vererbung der Verbindungswerte und Snapshot-Anforderungen.
  Im Projektordner muss `DB_NAME` ausdrücklich auf die Auswertedatenbank gesetzt sein.
- Die klinischen Daten und Medikationsanalysen müssen in dieser Datenbank vorliegen.
  Die [WP7-Regeldateien der MRP-Berechnung](../../02_MRP_Calculation/README.md#konfiguration-und-eingaben)
  werden ebenfalls benötigt.
- abgefragter Zeitraum konfigurierbar über Start- und Enddatum als Argument
- fehlt das Enddatum, wird der aktuelle Ausführungszeitpunkt genommen
- fehlt das Startdatum, wird der Tagesbeginn 60 Tage vor dem Ausführungstag genommen
- Enddatum muss gleich dem Startdatum oder größer als dieses sein

### Ausführung

Manueller Aufruf des DataProcessors aus dem Repository-Stamm:

-   `mrp-check`(=Name des Submoduls im Ordner manual_start, wobei Groß-/Kleinschreibung ignoriert wird und statt eine `_` auch ein `-` genutzt werden kann) als Argument anhängen

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check
```

-   optional Anpassung des Zeitraumes über die Argumente `start-date` und `end-date` mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check start-date=2025-09-01 end-date=2025-09-08
```

### Ergebnis

Das Submodul schreibt Excel-Auswertungen und übernimmt die berechneten MRPs nicht
in die fachlichen Ergebnistabellen der Datenbank. Einstieg ist [Start.R](Start.R),
die Implementierung liegt im [R-Subprojekt](R-MRP_Check/R).

- Tabelle `MRP_Check_Result_local.xlsx` im Ordner `outputLocal/dataprocessor/tables` mit den IDs aus der ausgewählten Quelldatenbank
- Tabelle `MRP_Check_Result_global.xlsx` im Ordner `outputGlobal/dataprocessor/tables` mit je ID-Spalte durchnummerierten IDs und patientenweise verschobenen Zeitangaben
