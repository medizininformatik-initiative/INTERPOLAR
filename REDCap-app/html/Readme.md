  1. Bitte laden Sie Redcap (Install, zip) herunter: [https://redcap.vanderbilt.edu/community/custom/download.php](https://redcap.vanderbilt.edu/community/custom/download.php)
  1. Entpacken Sie die Zip-Datei, z.B. _redcap14.1.5.zip_ in den Ordner 'html'. \
    ``` cd REDCap-app/html/ ``` \
    ``` unzip redcap14.1.5.zip ```
  1. Legen Sie das folgende Verzeichnis an: _REDCap-app/html/redcapdocs_ \
    ``` mkdir redcapdocs ```
  1. Passen Sie die Zugriffrechte für die folgenden Verzeichnisse an:
     * _REDCap-app/html/redcap/temp_
     * _REDCap-app/html/redcap/modules_
     * _REDCap-app/html/redcapdocs_ \
  ``` chmod ugo+rwx redcap/temp redcap/modules redcapdocs ```
  1. Bitte passen Sie die Verbindungsparameter zur Datenbank (mariadb in diesem Docker Compose Setup) in der Datei _redcap/database.php_ an. Verwenden Sie dafür den von Ihnen gewählten Redcap Datenbank-Namen, den Benutzernamen und das Passwort entspr. der Einträge in den _.env-Dateien_ unter _REDCap-db/.env_redcap_db*_. Ändern Sie außerdem die SALT Variable. \
  Beispiel für die Einträge in _REDCap-app/html/redcap/database.php_:
  ```php
  $hostname   = 'redcap_db';   //your_mysql_host_name
  $db         = 'redcap';      //your_mysql_db_name
  $username   = 'redcap';      //your_mysql_db_username
  $password   = 'password_for_redcap_user';    //your_mysql_db_password
  ```
  ```php
  $salt = '32534739';
  ```
  6. wechseln Sie in das Hauptverzeichnis und führen Sie 'docker-compose up' aus:
  ```console
  cd ../..
  docker-compose up
  ```
  7. Rufen Sie im Browser die REDCap Install-Seite auf: [http://127.0.0.1:8082/redcap/install.php](http://127.0.0.1:8082/redcap/install.php) (REDCap-URL)
     * Hinweis: _Sie können die REDCap-URL ggf. über einen Reverse-Proxy oder einen SSH-Tunnel auf dem Client-PC verfügbar machen._
     * Sie sollten Install-Seite mit mehreren Schritten sehen:
        * STEP 1) Kann übersprungen werden. Diese SQL-Anweisungen wurde bereits beim Initialisieren ausgeführt
        * STEP 2) Diese Anpassungen haben Sie schon vorgenommen und es sollte in gründer Schrift folgendes zu lesen sein: "Connection to the MySQL database 'redcap' was successful!"
        * STEP 3) Nehmen Sie ggf. _optional_ Änderungen vor. Klicken Sie anschließend auf "Generate SQL Install Script"
        * STEP 4) Kopieren Sie den Inhalt des SQL-Scripts und fügen Sie ihn in die Datei [REDCap-db/init/10_redcap_install-tables.sql](REDCap-db/init/10_redcap_install-tables.sql) ein. Gehen Sie anschließend zurück zur Console und führen Sie folgendes aus. Das REDCap Datenbank root Passwort finden Sie unter REDCap-db/.env_redcap_db_root.password. Ersetzen Sie "<insert redcap db root pw here>" durch das root Passwort und starten sie den Befehl:
         ```
         docker-compose exec -T redcap_db mariadb -u root -p"<insert redcap db root pw here>" redcap 
         < REDCap-db/init/10_redcap_install-tables.sql
         ```
        * STEP 5) Klicken Sie auf "REDCap Configuration Check". Es werden einige Rot gefärbte Meldungen erscheinen, die für eine produktive Umgebung noch behoben werden sollten.
  1. Das INTERPOLAR-Projekt in REDCap importieren:
     * Klicken Sie auf "New Project" (Menu-Leiste oben).
     * Geben Sie dem Projekt einen Titel, z.B. INTERPOLAR-dev
     * Wählen Sie bei "Project's purpose" aus: "Practice / Just for fun"
     * wählen Sie bei "Project creation option" &rarr; "Upload a REDCap project XML file" und importieren Sie diese aus dem Ordner _REDCap-app/INTERPOLARDev*.xml_. Rufen Sie den Browser nicht auf dem Computer auf, auf dem docker-compose ausgeführt ist, könenn Sie sich die Datei _[INTERPOLARDev*.xml](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/REDCap-app/INTERPOLARDev_2024-02-15_1502.REDCap.xml)_ aus dem GitHub-Repo herunterladen.
     * Klicken Sie auf "Create Project"
     * Unter "My Projects" einscheint nun das angelegte Projekt.
     ![REDCap-Projekt importieren](https://github.com/medizininformatik-initiative/INTERPOLAR/assets/11329281/0bfc855c-8586-4c82-8d58-84615ccb1a8f)


[//]: # (Zurück zur Install-Anleitung einfügen)
[//]: # (Doku für die Verwendung des REDCap INTERPOLAR-Projektes hier Verweis darauf einfügen)
