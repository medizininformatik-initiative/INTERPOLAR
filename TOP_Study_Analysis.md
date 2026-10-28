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

Nach Erfolg oder Abbruch diese Dateien aus dem Laufordner hochladen, soweit vorhanden:

- `run-summary.tsv`
- `algorithms.tsv`
- `preparation.json` (enthält unter `ignored_missing_encounter_contacts` die Zahl ignorierter Stationszuordnungszeilen ohne Encounter; diese stoppen den Lauf nicht)
- `versions.json`
- `model-checksums.txt`
- `revision.txt`

Bei einem Abbruch kurz die Ursache angeben. Bei Fehlern zusätzlich den relevanten Ausschnitt aus `preparation.log` oder `logs/` mitsenden, bereinigt um Zugangsdaten und Patienten-/Fallangaben. Fallbezogene CSV-Ergebnisse und Adapterdateien bleiben am DIZ.
