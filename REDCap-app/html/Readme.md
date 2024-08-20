  1. Bitte laden Sie Redcap (Install, zip) herunter: [https://redcap.vanderbilt.edu/community/custom/download.php](https://redcap.vanderbilt.edu/community/custom/download.php)
  1. Entpacken Sie die Zip-Datei, z.B. _redcap14.6.2.zip_ in den Ordner 'html'. \
    ``` cd REDCap-app/html/ ``` \
    ``` unzip redcap14.6.2.zip ```
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
  1. wechseln Sie in das Hauptverzeichnis und führen Sie 'docker compose up' aus:
     ```console
     cd ../..
     docker compose up
     ```
  1. Rufen Sie im Browser die REDCap Install-Seite auf: [http://127.0.0.1:8082/redcap/install.php](http://127.0.0.1:8082/redcap/install.php) (REDCap-URL)
     * Hinweis: _Sie können die REDCap-URL ggf. über einen Reverse-Proxy oder einen SSH-Tunnel auf dem Client-PC verfügbar machen._
     * Sie sollten Install-Seite mit mehreren Schritten sehen:![image](https://github.com/medizininformatik-initiative/INTERPOLAR/assets/11329281/1b442942-cac8-4378-acc6-446d61956f8d)

        * STEP 1) Kann übersprungen werden. Diese SQL-Anweisungen wurde bereits beim Initialisieren ausgeführt
        * STEP 2) Diese Anpassungen haben Sie schon vorgenommen und es sollte in gründer Schrift folgendes zu lesen sein: "Connection to the MySQL database 'redcap' was successful!"
        * STEP 3) Nehmen Sie ggf. _optional_ Änderungen vor. Klicken Sie anschließend auf "Generate SQL Install Script"
        * STEP 4) Kopieren Sie den Inhalt des SQL-Scripts und fügen Sie ihn in die Datei [REDCap-db/init/10_redcap_install-tables.sql](REDCap-db/init/10_redcap_install-tables.sql) ein. Gehen Sie anschließend zurück zur Console. Ersetzen Sie in der nachfolgenden Befehlszeile "_\<insert redcap db root pw here\>_" durch das REDCap Datenbank **_root_** Passwort und starten sie den Befehl. Das REDCap Datenbank root Passwort finden Sie unter REDCap-db/.env_redcap_db_root.password.
          ```console
          docker compose exec -T redcap_db mariadb -u root -p"<insert redcap db root pw here>" redcap < REDCap-db/init/10_redcap_install-tables.sql
          ```
        * STEP 5) Klicken Sie auf "REDCap Configuration Check". Es werden einige Rot gefärbte Meldungen erscheinen, die für eine produktive Umgebung noch behoben werden sollten. Dies kann zu einem späteren Zeitpunkt erfolgen. Ist im unteren Bereich "CONGRATULATIONS!" zu lesen, können Sie die REDCap mit Klick auf [http://127.0.0.1:8082/redcap/](http://127.0.0.1:8082/redcap/) starten.
     * Hinweis: Diese Schritte müssen nur wiederholt werden, wenn eine neue REDCap Version zum Einsazt kommen soll. Das Update kann auch über die REDCap Weboberfläche im "Control Center" eingespielt werden.
  1. Das INTERPOLAR-Projekt in REDCap importieren:
     * Die INTERPOLAR REDCap Projekt Datei ist in INTERPOLAR erarbeitet worden und steht im MII SharePoint Ordner [Release v0.2.x](https://tmfev.sharepoint.com/:f:/r/sites/tmf/mi-i/Modul3Projekte/INTERPOLAR/5_Referenzarchitektur/eDataCapture/Release%20v0.2.x?csf=1&web=1&e=7bycOQ) verfügbar. Bitte laden Sie sich die Datei "INTERPOLARDev_*.**REDCap.xml**" herunter.
     * Wechseln Sie im Browser zur REDCap Weboberfläche und klicken Sie auf "New Project" (Menu-Leiste oben).
     * Geben Sie dem Projekt einen Titel, z.B. INTERPOLAR-1a
     * Wählen Sie bei "Project's purpose" aus: "Quality Improvement"
     * wählen Sie bei "Project creation option" &rarr; "Upload a REDCap project XML file" und importieren Sie die zuvor vom MII SharePoint heruntergeladene REDCap Projektdatei "INTERPOLARDev_*.REDCap.xml".
     * Klicken Sie auf "Create Project"
     * Unter "My Projects" einscheint nun das angelegte Projekt.
     ![REDCap-Projekt importieren](https://github.com/medizininformatik-initiative/INTERPOLAR/assets/11329281/0bfc855c-8586-4c82-8d58-84615ccb1a8f)
1. Führen Sie die [Konfiguration von DB2Frontend](../../R-db2frontend) durch (REDCap API-Token).
1. Fahren Sie mit Schritt 3) [REDCap-app/Readme.md](../Readme.md) fort.

[//]: # (Zurück zur Install-Anleitung einfügen)
[//]: # (Doku für die Verwendung des REDCap INTERPOLAR-Projektes hier Verweis darauf einfügen)
