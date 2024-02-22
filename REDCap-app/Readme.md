# Frontend Setup (Redcap)

In diesem Ordner wird für das Frontend ein minimales Redcap aufgesetzt.

Dies erfolgt in 2 Schritten:
1. Docker-Image für die Ausführung von Redcap erzeugen (Ordner [build](build))
2. Redcap-(Installations)-Dateien zur Verfügung stellen (Ordner [html](html))

## zu 1.
  * [build/Dockerfile](build/Dockerfile) beschreibt eine PHP-8 Umgebung inkl. Extensions, wie sie für REDCap benötigt werden
  * Im Verzeichnis [build/config](build/config) liegen Konfigurationsdateien, die zur Build-Zeit verwendet werden. Diese können auch auch zur Laufzeit in der [../docker-compose.yml](../docker-compose.yml) mittels Volumes überschrieben werden.
  * Für den Mailversand aus dem REDCap-Container heraus ist z.B. die Konfigurationsdatei [build/config/msmtprc](build/config/msmtprc) entspr. anzupassen (Mailadressen, Mailhost, etc.).

## zu 2.
Siehe Anweisungen in [html/Readme.md](html/Readme.md)
