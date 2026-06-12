# CDS-HUB DB (cds_hub_db)

Die Datenbank "cds_hub_db" wird mit SQL-Skripten aus
`Postgres-cds_hub/generated/sql/` initialisiert bzw. migriert. Dieses
Installationsverzeichnis wird vor dem Start des Postgres-Containers vom
Compose-Service `cds_hub_sql_generator` aus den versionierten SQL-Dateien,
SQL-Templates und Excel-Tabellenbeschreibungen erzeugt. Die lesbaren SQL-Skripte
liegen weiterhin unter `Postgres-cds_hub/sql/` im Repository und werden in der CI
gegen den Generatoroutput geprüft. Die Daten werden in einem Volume
"cds_hub_db-data" gespeichert.

Eine detaillierte Beschreibung der Datenbankstruktur befindet sich in [DB_description.md](DB_description.md).
Hinweise zur Pflege, Formatierung und Generierung der SQL-Skripte stehen in
[SQL_development.md](SQL_development.md).

## Verbindung: Console

Um sich mit der Datenbank auf der Console zu verbinden, führen Sie folgenden Befehl aus:
```docker compose exec cds_hub psql -U cds_hub_db_admin -d cds_hub_db```

## Verbindung: PGAdmin
Mit dem docker-compose wird ein PGAdmin zur Verfügung gestellt, welches unter der folgenden URL verfügbar ist: \
[http://127.0.0.1:8089/](http://127.0.0.1:8089/)

Die Login-Informationen befinden sich in der docker-compose.yml (PGADMIN_DEFAULT_EMAIL, PGADMIN_DEFAULT_PASSWORD).

Im PGAdmin wird eine Standard-Konfiguration (pgadmin_cds_hub.json) zur Verfügung gestellt, sodass nach Anmeldung an der Web-Oberfläche des PGAdmin eine Servergruppe "INTERPOLAR" und darin ein Datenbankserver "cds_hub" angelegt ist. Beim Verbinden mit "cds_hub" wird das Passwort für den Admin-Nutzer "cds_hub_db_admin" verlangt. Dieses befindet sich in der Passwort-Datei (Docker Secrets): Postgres-cds_hub/.env_cds_hub_db_admin.password

## Neu-Initialisierung / Löschen der Datenbank

Soll dieses Volume gelöscht werden, gehen Sie folgendermaßen vor. **Achtung: _Alle_ Daten in der Datenbank werden gelöscht!** Die Datenbank wird beim Start des cds_hub Containers erneut initialisiert.

1. Vorhandene(s) Docker Volume(s) der cds_hub_db auflisten:
```docker volume ls | grep cds_hub_db-data```
2. Wenn Sie das docker compose Setup mehrfach deployed haben, werden mehrere Volumes aufgelistet. Wählen Sie das Volume aus, dass gelöscht werden soll und führen Sie folgendes aus. Z.B. für das Volume "interpolar_cds_hub_db-data":
```docker volume rm interpolar_cds_hub_db-data```
