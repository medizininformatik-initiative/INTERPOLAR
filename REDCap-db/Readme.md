Bitte kopieren Sie die Dateien *REDCap-db/template_** nach *REDCap-db/.** und passen Sie die Passwörter in den beiden Dateien *.env_redcap_db_root.password* und *.env_redcap_db.password* an.

Wenn Sie den Datenbank-Namen (*MARIADB_DATABASE=redcap*) und / oder den REDCap-Benutzer (*MARIADB_USER=redcap*) anpassen, müssen Sie das entspr. auch im Init-Script für die REDCap-Datenbank (*REDCap-db/init/redcap.sql*) anpassen.

Der Zugriff auf die REDCap-Datenbank (MariaDB) kann mittels SQL-Client an der Kommandozeile mit folgendem Befehl durchgeführt werden:
```console
docker compose exec redcap_db mariadb --user=redcap --password=redcap
```
