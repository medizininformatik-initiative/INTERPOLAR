# TOP-Analyse der Studienfälle

Alle Befehle im INTERPOLAR-Hauptverzeichnis ausführen. Verwendet wird das TOP-Modellpaket 1.1.1 mit TOP-Framework 2.0.0; das Image wird beim ersten Lauf automatisch heruntergeladen.

## 1. Branch auschecken und bauen

```bash
git fetch origin
git switch top-study-analysis
git pull --ff-only
docker compose build r-env
```

## 2. Datenbank-TOML setzen

```bash
cp R-cdstoolchain/top-study/database.example.toml R-cdstoolchain/top-study/database.toml
```

In `R-cdstoolchain/top-study/database.toml` den Wert `DB_NAME` auf die pseudonymisierte Snapshot-Datenbank setzen. Die übrigen Verbindungswerte kommen aus `cds_hub_db_config.toml`.

## 3. Vollständigen Studienlauf starten

```bash
./run-top-study.sh
```

Fortschritt und Laufzeiten erscheinen im Terminal und in `outputLocal/top-study/<Lauf>/progress.log`. Während einer TOP-Berechnung erscheint alle 60 Sekunden ein Lebenszeichen. Die Vorbereitung steht in `preparation.log`, die anschließende aggregierte Prüfung in `plausibility.log`.

## 4. Rückmeldung hochladen

Nach Erfolg oder Abbruch ausschließlich `outputGlobal/top-study/<Lauf>/TOP_Report_YYYY-MM-DD_HH-MM-SS.txt` hochladen. Der Bericht enthält Trefferzahlen und Laufzeiten, Fallauswahl nach Station und Studiengrenzen, Laborabdeckung und Einheitenstatus sowie den Anämie-Kontrollvergleich. Zwischenkriterien und Fallzählung sind ausdrücklich gekennzeichnet. Die Non-AE-Algorithmen stehen mit ihren Modellnamen im Bericht; ihre Bedingungen definieren nicht automatisch die Restmenge der Studienfälle.

Die vollständigen TOP-ZIPs einschließlich `metadata.csv`, Modellkopien und Rohlogs bleiben unter `outputLocal/top-study/<Lauf>/` für die lokale Prüfung. Die Kontrollanalyse verändert weder Laborgrenzen noch TOP-Ergebnisse. Für die fachliche Bewertung müssen die lokalen Hämoglobin- und Glukose-Referenzgrenzen noch bestätigt werden.

Der Dateiname enthält die lokale Startzeit am Standort, zum Beispiel `TOP_Report_2026-10-29_14-35-22.txt`.

TOP erhält numerische Laborwerte mit `analysis_value_status = converted` oder
`already_reference_unit`. Primär-LOINC und Referenzeinheit folgen der WP7-Laborliste.
Werte mit anderen oder fehlenden Status sowie fehlende Zahlenwerte zählt der
Bericht als nicht auswertbar. Die Laborübersicht enthält je LOINC die gemeinsam
aufgeführten Modelle und je
Einheit und Status die Auswertbarkeit, Anzahl der FHIR-Observations und Fälle
sowie Minimum, Median und Maximum. Observations ohne Zahlenwert werden mitgezählt;
die Werteverteilung verwendet vorhandene Zahlenwerte. Fallzahlen verschiedener
Gruppen können sich überschneiden. Modellparameter ohne Observations werden
separat aufgeführt.
