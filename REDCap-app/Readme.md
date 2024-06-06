# Frontend Setup (REDCap)

In diesem Ordner wird für das Frontend ein minimales Redcap aufgesetzt.

Dies erfolgt in 2 Schritten:
1. Docker-Image für die Ausführung von Redcap erzeugen (Ordner [build](build))
2. REDCap-(Installations)-Dateien zur Verfügung stellen (Ordner [html](html))
3. REDCap Konfiguration (Rechte und Rollen, etc.)

## zu 1.
  * [build/Dockerfile](build/Dockerfile) beschreibt eine PHP-8 Umgebung inkl. Extensions, wie sie für REDCap benötigt werden
  * Im Verzeichnis [build/config](build/config) liegen Konfigurationsdateien, die zur Build-Zeit verwendet werden. Diese können auch auch zur Laufzeit in der [../docker-compose.yml](../docker-compose.yml) mittels Volumes überschrieben werden.
  * Optional: Für den Mailversand aus dem REDCap-Container heraus ist z.B. die Konfigurationsdatei [build/config/msmtprc](build/config/msmtprc) entspr. anzupassen (Mailadressen, Mailhost, etc.).

## zu 2.
Siehe Anweisungen in [html/Readme.md](html/Readme.md)

## zu 3.
Die REDCap Konfiguration ist abhängig von den Gegebenheiten am Standort, z.B. Anzahl und Namen der an INTERPOLAR teilnehmenden Stationen sowie der dort beteiligten Personen.
REDCap enthält eine Benutzerverwaltung mit Rechten und Rollen. Die Einrichtung / Konfiguration ist in der REDCap Dokumentation beschrieben:
 * [How to change and set up authentication in REDCap](https://redcap.vumc.org/community/post.php?id=691)
 * [How do I create a customized report in REDCap?](https://confluence.research.cchmc.org/pages/viewpage.action?pageId=90966866)
