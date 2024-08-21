# Installationsanleitung bzw. Anleitung zur Einrichtung der CDS tool chain

  1. Checkout des INTERPOLAR Repositories \
    ```git clone git@github.com:medizininformatik-initiative/INTERPOLAR.git```
  1. Wechsel in das geclonte Verzeichnis \
    ```cd INTERPOLAR```
  1. Optionaler Schritt: Wenn Sie die aktuellste Entwickler-Version ausprobieren möchten, checken Sie den Branch 'release' aus. Ansonsten überspringen Sie diesen Schritt. \
    ```git checkout release```
  1. Konfigurationsdateien aus den Vorlagen (Templates) erstellen \
     * _Postgres-cds_hub/template_env_cds_hub_db_admin.password_ nach _Postgres-cds_hub/.env_cds_hub_db_admin.password_ kopieren und ein Passwort-String einfügen. Dieses Passwort ist für den Admin-Nutzer der CDS_HUB-Datenbank. \
    ```cp Postgres-cds_hub/template_env_cds_hub_db_admin.password Postgres-cds_hub/.env_cds_hub_db_admin.password```
     * _REDCap-db/template_env_redcap_db.password_ kopieren nach _REDCap-db/.env_redcap_db_ \
    ```cp REDCap-db/template_env_redcap_db.password REDCap-db/.env_redcap_db```
     * _REDCap-db/template_env_redcap_db.password_ kopieren nach _REDCap-db/.env_redcap_db.password_ und tragen Sie ein Passwort für den Nutzer der redcap Datenbank ein \
    ```cp REDCap-db/template_env_redcap_db.password REDCap-db/.env_redcap_db.password```
     * _REDCap-db/template_env_redcap_db_root.password_ kopieren nach _REDCap-db/.env_redcap_db_root.password_ und tragen Sie ein Passwort für den root-Nutzer der Datenbank ein \
    ```cp REDCap-db/template_env_redcap_db_root.password REDCap-db/.env_redcap_db_root.password```
  1. Führen Sie die Anweisungen in [REDCap-app/Readme.md](REDCap-app/Readme.md) aus
  1. Führen Sie die Anweisungen in [REDCap-app/html/Readme.md](REDCap-app/html/Readme.md) aus
  1. Führen Sie docker-compose aus, falls Sie es noch nicht ausgeführt: \
    ```docker-compose up```
  1. Die cds_hub_db (Postges-Datenbank) erreichen Sie im Browser (PGAdmin) über die URL: [http://127.0.0.1:8089/](http://127.0.0.1:8089/)
     * Die Zugangsdaten für pgadmin entnehmen Sie bitte der [docker-compose.yml](/docker-compose.yml#L94) (services -> pgadmin) bzw. können Sie diese dort anpassen.
     * ggf. muss im pgadmin die Verbindung zur cds_hub_db mit den Zugangsdaten aus der [docker-compose.yml](/docker-compose.yml#L63) (services -> cds_hub: POSTGRES_USER, POSTGRES_DB) bzw. der Passwort-Datei (secrets -> cds_hub_db_admin.password, Postgres-cds_ub/.env_cds_hub_db_admin.password) angelegt werden. Weitere Informationen siehe [Postgres-cds_hub/Readme.md](Postgres-cds_hub/Readme.md)
  1. Das Frontend (REDCap) erreichen Sie im Browser über die URL: [http://127.0.0.1:8082/redcap](http://127.0.0.1:8082/redcap)

[Zurück zur Übersicht](./)
