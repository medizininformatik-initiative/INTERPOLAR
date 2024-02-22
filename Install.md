# Installationsanleitung bzw. Anleitung zur Einrichtung der INTERPOLAR IT Tools

  * Checkout des INTERPOLAR Repositories
    ```git clone git@github.com:medizininformatik-initiative/INTERPOLAR.git```
  * Wechsel in das geclonte Verzeichnis
    ```cd INTERPOLAR```
  * den Branch 'release' auschecken
    ```git checkout release```
  * Konfigurationsdateien aus den Vorlagen (Templates) erstellen
    * Postgres-amts_db/template_env_amts_db_admin.password nach Postgres-amts_db/.env_amts_db_admin.password kopieren und ein Passwort-String einfügen. Dieses Passwort ist für den Admin-Nutzer der amts-Datenbank.
    * REDCap-db/template_env-redcap-db kopieren nach REDCap-db/.env-redcap-db
    * REDCap-db/template_env_redcap_db.password kopieren nach REDCap-db/.env_redcap_db.password und tragen Sie ein Passwort für den Nutzer der redcap Datenbank ein
    * REDCap-db/template_env_redcap_db_root.password kopieren nach REDCap-db/.env_redcap_db_root.password und tragen Sie ein Passwort für den root-Nutzer der Datenbank ein
  * Führen Sie die Anweisungen in REDCap-app/Readme.md aus
  * Führen Sie die Anweisungen in REDCap-app/html/Readme.md aus
  * Führen Sie docker-compose aus
    ```docker-compose up```

