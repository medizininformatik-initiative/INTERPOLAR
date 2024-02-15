Bitte laden Sie Redcap (Install, zip) herunter:
https://redcap.vanderbilt.edu/community/custom/download.php

Entpacken Sie die Zip-Datei, z.B. redcap14.1.5.zip in den Ordner 'html'.

Bitte passen Sie die Verbindungsparameter zur Datenbank (mariadb in diesem Docker Compose Setup) in der Datei database.php an, in dem Sie die von Ihnen gewählten Redcap Datenbank-Namen, Benutzernamen und Passwort eintragen.
Beispiel für die Einträge in REDCap-app/html/redcap/database.php:
'''
$hostname   = 'redcap_db';	//your_mysql_host_name
$db         = 'redcap'; 	//your_mysql_db_name
$username   = 'redcap'; 	//your_mysql_db_username
$password   = 'password_for_redcap_user'; 	//your_mysql_db_password
'''

Rufen Sie im Browser die Seite auf: http://127.0.0.1:8082/redcap/

(Sollten Sie eine Fehlermeldung erhalten, rufen Sie im Browser die Install-Seite auf: http://127.0.0.1:8082/redcap/install.php)

(Redcap ggf. via Reverse-Proxy auf dem Client-PC verfügbar machen.)

Klicken Sie auf "New Project" (Menu-Leiste oben).
  * Geben Sie dem Projekt einen Titel, z.B. INTERPOLAR-dev
  * wählen Sie bei "Project creation option" -> "Upload a REDCap project XML file" und importieren Sie diese aus dem Ordner REDCap-frontend/INTERPOLARDev*.xml
