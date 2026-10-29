# TOP-Analyse der Studienfälle

Alle Befehle im INTERPOLAR-Hauptverzeichnis ausführen.

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

Nach Erfolg oder Abbruch ausschließlich `outputGlobal/top-study/<Lauf>/report.txt` hochladen. Der Bericht enthält Trefferzahlen und Laufzeiten, Fallauswahl nach Station und Studiengrenzen, Laborabdeckung und Einheitenstatus sowie den Anämie-Kontrollvergleich. Zwischenkriterien sind ausdrücklich gekennzeichnet.

Die vollständigen TOP-ZIPs einschließlich `metadata.csv`, Modellkopien und Rohlogs bleiben unter `outputLocal/top-study/<Lauf>/` für die lokale Prüfung. Die Kontrollanalyse verändert weder Laborgrenzen noch TOP-Ergebnisse. Für die fachliche Bewertung müssen die lokalen Hämoglobin- und Glukose-Referenzgrenzen noch bestätigt werden.
