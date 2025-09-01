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
docker compose exec -T cds_hub psql -U cds_hub_db_admin -d cds_hub_db < `find Postgres-cds_hub/init -maxdepth 1 -name '*.sql' | sort`
```

## Backup & Restore
Siehe [discussions/750](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/750).

