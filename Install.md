# Installationsanleitung bzw. Anleitung zur Einrichtung der INTERPOLAR IT Tools

  * Checkout des INTERPOLAR Repositories \
    ```git clone git@github.com:medizininformatik-initiative/INTERPOLAR.git```
  * Wechsel in das geclonte Verzeichnis \
    ```cd INTERPOLAR```
  * den Branch 'release' auschecken \
    ```git checkout release```
  * Konfigurationsdateien aus den Vorlagen (Templates) erstellen
    * Postgres-amts_db/template_env_amts_db_admin.password nach Postgres-amts_db/.env_amts_db_admin.password kopieren und ein Passwort-String einfügen. Dieses Passwort ist für den Admin-Nutzer der amts-Datenbank. \
    ```cp Postgres-amts_db/template_env_amts_db_admin.password Postgres-amts_db/.env_amts_db_admin.password```
    * REDCap-db/template_env-redcap-db kopieren nach REDCap-db/.env-redcap-db \
    ```cp REDCap-db/template_env-redcap-db REDCap-db/.env-redcap-db```
    * REDCap-db/template_env_redcap_db.password kopieren nach REDCap-db/.env_redcap_db.password und tragen Sie ein Passwort für den Nutzer der redcap Datenbank ein \
    ```cp REDCap-db/template_env_redcap_db.password REDCap-db/.env_redcap_db.password```
    * REDCap-db/template_env_redcap_db_root.password kopieren nach REDCap-db/.env_redcap_db_root.password und tragen Sie ein Passwort für den root-Nutzer der Datenbank ein \
    ```cp REDCap-db/template_env_redcap_db_root.password REDCap-db/.env_redcap_db_root.password```
  * Führen Sie die Anweisungen in [REDCap-app/Readme.md](REDCap-app/Readme.md) aus
  * Führen Sie die Anweisungen in [REDCap-app/html/Readme.md](REDCap-app/html/Readme.md) aus
  * Führen Sie docker-compose aus: \
    ```docker-compose up```
  * Die amts_db (Postges-Datenbank) erreichen Sie im Browser (PGAdmin) über die URL: [http://127.0.0.1:8089/](http://127.0.0.1:8089/)
  * Das Frontend (REDCap) erreichen Sie im Browser über die URL: [http://127.0.0.1:8082/redcap](http://127.0.0.1:8082/redcap)

