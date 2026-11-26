---
layout: default
title: Betrieb
---
_Work in progress_

# Betrieb der CDS Tool Chain
[//]: # (ToDo:Beschreibung)

## Aktualisierung der Upstream Docker Images

``docker compose pull``

## Befehl im Container aufrufen
### Extern
### Extern interaktiv
### Intern

## Manuelle Initialisierung der cds_hub_db Postgres Datenbank
Siehe [Install](https://medizininformatik-initiative.github.io/INTERPOLAR/Install).
```sh
docker compose exec -w /cds_hub-initdb.d cds_hub psql -U cds_hub_db_admin -d cds_hub_db -f ./start.sql
```

## Backup & Restore
Siehe [discussions/750](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/750).

### TOP-Framework

Der Compose-Dienst `top-framework` verwendet die Datenbankverbindung aus
`.env_top-framework`. Nach einem erfolgreichen Containerlauf liegen die ZIPs
unter `outputLocal/top-results/archives/outputGlobal` (Zusammenfassung) und
`outputLocal/top-results/archives/outputLocal` (Abfrageergebnisse und
Aufrufprotokoll). Beide heißen
`top-framework_<UTC-Start>_toolchain-<Version>_<Datenherkunft>.zip`.
Die Datenherkunft folgt dem Datenbankmarker und dem Snapshot-Namen.
Die Dateien liegen direkt im ZIP. Sobald das ZIP geprüft ist, werden die
verpackten Einzeldateien entfernt. Die ZIPs bleiben je Lauf erhalten.

Nach Änderungen am TOP-Image den Dienst mit `--build` starten:

```sh
docker compose --profile '*' run --build --rm top-framework
```
