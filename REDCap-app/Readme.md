# Frontend Setup (REDCap)

In diesem Ordner wird für das Frontend ein minimales Redcap aufgesetzt.

Dies erfolgt in 3 Schritten:
1. Docker-Image für die Ausführung von Redcap erzeugen (Ordner [build](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/REDCap-app/build))
   * [build/Dockerfile](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/REDCap-app/build/Dockerfile) beschreibt eine PHP-8 Umgebung inkl. Extensions, wie sie für REDCap benötigt werden
   * Im Verzeichnis [build/config](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/REDCap-app/build/config) liegen Konfigurationsdateien, die zur Build-Zeit verwendet werden. Diese können auch auch zur Laufzeit in der [../docker-compose.yml](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/docker-compose.yml) mittels Volumes überschrieben werden.
   * Optional: Für den Mailversand aus dem REDCap-Container heraus ist z.B. die Konfigurationsdatei [build/config/msmtprc](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/REDCap-app/build/config/msmtprc) entspr. anzupassen (Mailadressen, Mailhost, etc.).
1. REDCap-(Installations)-Dateien zur Verfügung stellen (Ordner [html](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/REDCap-app/html))
   * Siehe Anweisungen in [html/Readme.md](html/Readme.md)
1. REDCap Konfiguration (Rechte und Rollen, etc.) \
   Die REDCap Konfiguration ist abhängig von den Gegebenheiten am Standort, z.B. Anzahl und Namen der an INTERPOLAR teilnehmenden Stationen sowie der dort beteiligten Personen.
   REDCap enthält eine Benutzerverwaltung mit Rechten und Rollen. Die Einrichtung / Konfiguration ist in der REDCap Dokumentation beschrieben:
   * <a href="https://redcap.vumc.org/community/post.php?id=691" target="_blank" rel="noopener noreferrer">How to change and set up authentication in REDCap?</a>
   * <a href="https://confluence.research.cchmc.org/pages/viewpage.action?pageId=90966866" target="_blank" rel="noopener noreferrer">How do I create a customized report in REDCap?</a>
1. Cronjob für REDCap einrichten: \
   Es gibt mehrere Möglichkeiten, den Cronjob für die regelmäßigen Aufgaben, welche vom REDCap durchgeführt werden müssen, einzurichten. Dies kann z.B. ein Script sein, dass per Cron des Host-System aufgerufen wird oder die Hinzunahme eines weiteren "Cron"-Eintrages/Services in der docker-compose.yml. \
   Eine einfache Möglichkeit besteht darin, den folgenden Eintrag in die crontab des docker-Nutzers auf dem Host-System bzw. wenn dies root ist in der _/etc/crontab_ hinzuzufügen. Wenn die CDS Tool Chain auf dem Host-System im Verzeichnis _/opt/docker/INTERPOLAR_ ausgecheckt wurde, sieht der Eintrag beispielsweise so aus:
   ```cron
   * *     * * *   root    cd /opt/docker/INTERPOLAR && docker compose exec -T redcap php /var/www/html/redcap/cron.php > /dev/null
   ```
   Beim Durchlauf des Configuration-Check über die REDCap Weboberfläche sollte dann der Test für den Cronjob "grün" sein.
   ![image](https://github.com/user-attachments/assets/16e7f884-a559-4341-9e01-782d2b38678f)


[Zurück zur Installationsanleitung](../Install.md) (weiter mit Schritt 7)
