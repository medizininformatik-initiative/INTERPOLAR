Bitte laden Sie Redcap (Install, zip) herunter:
https://redcap.vanderbilt.edu/community/custom/download.php

  1. Entpacken Sie die Zip-Datei, z.B. redcap14.1.5.zip in den Ordner 'html'.
  ```cd REDCap-app/html/
  unzip redcap14.1.5.zip```
  1. Legen Sie das folgende Verzeichnis an: REDCap-app/html/redcapdocs
  ```mkdir redcapdocs```
  1. Passen Sie die Zugriffrechte für die folgenden Verzeichnisse an:
    * REDCap-app/html/redcap/temp
    * REDCap-app/html/redcap/modules
    * REDCap-app/html/redcapdocs
  ```chmod ugo+rwx redcap/temp redcap/modules redcapdocs```
  1. Bitte passen Sie die Verbindungsparameter zur Datenbank (mariadb in diesem Docker Compose Setup) in der Datei redcap/database.php an. Verwenden Sie dafür den von Ihnen gewählten Redcap Datenbank-Namen, den Benutzernamen und das Passwort entspr. der Einträge in den .env-Dateien unter REDCap-db/.env_redcap_db* .
  Beispiel für die Einträge in REDCap-app/html/redcap/database.php:
  
  ```
  $hostname   = 'redcap_db';   //your_mysql_host_name
  $db         = 'redcap';      //your_mysql_db_name
  $username   = 'redcap';      //your_mysql_db_username
  $password   = 'password_for_redcap_user';    //your_mysql_db_password
  ```
  Ändern Sie außerdem die SALT Variable, z.B.:
  
  ```
  $salt = '32534739';
  ```

  1. wechseln Sie in das Hauptverzeichnis und führen Sie 'docker-compose up' aus:
  ```cd ../..
  docker-compose up```
  1. Rufen Sie im Browser die Seite auf: http://127.0.0.1:8082/redcap/ (REDCap-URL)
    * Optional: Sollten Sie eine Fehlermeldung erhalten, rufen Sie im Browser die Install-Seite auf: http://127.0.0.1:8082/redcap/install.php
    * Optional: Sie können die REDCap-URL ggf. über einen Reverse-Proxy oder einen SSH-Tunnel auf dem Client-PC verfügbar machen.
  1. Das INTERPOLAR-Projekt in REDCap importieren:
    * Klicken Sie auf "New Project" (Menu-Leiste oben).
    * Geben Sie dem Projekt einen Titel, z.B. INTERPOLAR-dev
    * Wählen Sie bei "Project's purpose" aus: "Practice / Just for fun"
    * wählen Sie bei "Project creation option" -> "Upload a REDCap project XML file" und importieren Sie diese aus dem Ordner REDCap-app/INTERPOLARDev*.xml. Rufen Sie den Browser nicht auf dem Computer auf, auf dem docker-compose ausgeführt ist, könenn Sie sich die Datei [INTERPOLARDev*.xml](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/REDCap-app/INTERPOLARDev_2024-02-15_1502.REDCap.xml) aus dem GitHub-Repo herunterladen.
    * Klicken Sie auf "Create Project"
    * Unter "My Projects" einscheint nun das angelegte Projekt.

{% comment %} 
  * Zurück zur Install-Anleitung einfügen
  * Doku für die Verwendung des REDCap INTERPOLAR-Projektes hier Verweis darauf einfügen
{% endcomment %}
