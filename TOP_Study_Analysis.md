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

Fortschritt und Laufzeiten erscheinen im Terminal und in `progress.log` im ausgegebenen Laufordner unter `outputLocal/top-study/`. Während einer TOP-Berechnung erscheint alle 60 Sekunden ein Lebenszeichen. Die Schritte der Vorbereitung stehen mit Zeitstempel in `preparation.log`.

## 4. Rückmeldedateien hochladen

Nach Erfolg oder Abbruch den gesamten Laufordner `outputGlobal/top-study/<Lauf>/` hochladen:

- `report.txt`: Namen und Kennzeichnung als Algorithmus oder Zwischenkriterium, Trefferzahlen, Laufzeiten, Gesamtstatus und Fallauswahl-/Fehlerzahlen.
- `results/*.zip`: vollständige TOP-Ergebnisse je Algorithmus oder Zwischenkriterium mit `data_subjects.csv` (fallweise Ergebnisse), `data_phenotypes.csv` (einzelne Phänotypwerte) und `metadata.csv` (Modellbeschreibungen). Die Fall-IDs stammen aus dem pseudonymisierten Snapshot.

Zwischenkriterien sind keine eigenständigen Krankheitsnachweise. Bei einem Abbruch bleiben die ZIPs der abgeschlossenen Berechnungen verfügbar. `outputLocal/top-study/` enthält Adapterdateien, Rohlogs und gegebenenfalls unvollständige Exporte für die lokale Fehlersuche.
