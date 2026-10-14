# Zentrale MRP-Eingabeprüfung

Dieser Einstiegspunkt prüft ausgewählte Standortdateien und schreibt ein Manifest.
Er liest noch keine Excel-Inhalte und berechnet keine MRP-Kennzahlen. Eine vorhandene
Excel-Datei mit leerer Ergebnistabelle wird nicht als solche erkannt.

## Einrichtung und Aufruf

Aus dem INTERPOLAR-Projektverzeichnis:

```bash
mkdir -p inputGlobal outputCentral
cp global-analysis/central/mrp-check/config/sites_example.csv \
  global-analysis/central/mrp-check/config/sites.csv
```

Exporte unverändert ablegen, beispielsweise:

```text
inputGlobal/SITE_A/2026-10-14/outputGlobal/dataprocessor/tables/MRP_Check_Result_global.xlsx
```

In `config/sites.csv` genau einen Export pro Standort auswählen. `site_id` und
`export_id` entsprechen den Ordnernamen und bestehen aus Buchstaben, Ziffern,
Bindestrichen oder Unterstrichen; sie beginnen mit Buchstabe oder Ziffer.
`mrp_check_file` ist der genaue relative Pfad innerhalb des jeweiligen `outputGlobal`,
gegebenenfalls mit Zeitstempel im Dateinamen. Die lokale Auswahl ist Git- und
Docker-Build-ignoriert. Die Vorlage enthält nur fiktive Beispiele.

```bash
Rscript global-analysis/central/mrp-check/Start.R
Rscript global-analysis/central/mrp-check/Start.R --help
```

Ein optionales Positionsargument ersetzt den Auswahlpfad. Der
[Docker-Aufruf](../../README.md#konsolenstart-und-docker) bindet Eingaben
schreibgeschützt und `outputCentral` beschreibbar ein.

## Ergebnis und Grenzen

Fehlende Dateien, doppelte Standorte, ungültige Pfade und Null-Byte-Dateien führen
zu einem Fehler-Exitstatus. Erst nach erfolgreicher Prüfung aller Dateien entsteht
`outputCentral/mrp-check/<lauf>/input-manifest.csv`. Vorherige Läufe werden nicht
überschrieben. Das Manifest enthält Standort, Exportkennung, Dateipfad,
MD5-Dateiprüfsumme, Prüfsumme der Auswahl, UTC-Prüfzeit und Git-Commit, soweit verfügbar.
Uncommittete Codeänderungen werden nicht erfasst.

Für eine spätere Aggregation sind Schema, Zeitraum und Version zu prüfen.
Metadatenzeilen sind keine Ergebnisse. Globale IDs sind exportlokal und dürfen
nicht ohne Standort und Exportkennung verknüpft werden. Leere Ergebnistabellen,
fehlende Dateien und fehlgeschlagene Standortläufe müssen unterschieden werden.
