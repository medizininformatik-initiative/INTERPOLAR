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

Nach Erfolg oder Abbruch den Gesamtbericht aus `outputGlobal/top-study/<Lauf>/report.txt` hochladen. Er enthält Algorithmus-Ergebnisse mit Trefferzahlen und Laufzeiten, Gesamtstatus, Studienfallzahl, Gesamtzahl der Krankenhausfälle, ignorierte Stationszuordnungen und weitere Zuordnungsprobleme sowie die verwendeten Versionen.

`outputLocal/top-study/` enthält fallbezogene Ergebnisse, Adapterdateien und Rohlogs für die lokale Fehlersuche am Standort.
