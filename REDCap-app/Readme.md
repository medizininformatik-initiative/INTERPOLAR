In diesem Ordner wird für das Frontend ein minimales Redcap aufgesetzt.
Dieser Vorgang läuft in 2 Stufen ab:
1. Docker-Image für die Ausführung von Redcap erzeugen (Ordner REDCap-app/build)
2. Redcap-(Installations)-Dateien zur Verfügung stellen (Ordner REDCap-app/html)

zu 1.
  * REDCap-app/build/Dockerfile beschreibt eine PHP-8 Umgebung inkl. Extensions, wie sie für REDCap benötigt werden
  * Im Verzeichnis REDCap-app/build/config liegen Konfigurationsdateien, die zur Build-Zeit verwendet werden. Diese können auch auch zur Laufzeit in der docker-compose.yml mittels Volumes überschrieben werden. Für den Mailversand aus dem REDCap-Container heraus ist die Konfigurationsdatei msmtprc aus der Vorlage (REDCap-app/build/config/template_msmtprc) entspr. anzupassen (Mailadressen, Mailhost, etc.).

zu 2. siehe Anweisungen in REDCap-app/html/Readme.md