# CDS-HUB DB (cds_hub_db)

Die Datenbank "cds_hub_db" wird mit SQL-Scripten im Ordner "Postgres-cds_hub/init/" beim ersten Start (docker compose up) initialisiert. Die Daten werden in einem Volume "cds_hub_db-data" gespeichert.

Eine detaillierte Beschreibung der Datenbankstruktur befindet sich in [DB_description.md](DB_description.md).

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
