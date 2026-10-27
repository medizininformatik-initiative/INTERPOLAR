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

## TOP-Studienanalyse auf einem Snapshot

Mit `./run-top-study.sh` werden die Studienfälle auf einer vorhandenen pseudonymisierten Snapshot-Datenbank analysiert. Einrichtung, Fortschrittsprotokolle und die Rückmeldung des DIZ sind in [TOP-Studienanalyse](TOP_Study_Analysis.md) beschrieben.
