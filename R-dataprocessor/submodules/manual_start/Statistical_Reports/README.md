# "Statistical_Reports" - kumulative Kennzahlen zur Qualitätssicherung des Studienforschritts

## Initiale Version (06.08.2025)

### Funktion

Zählung von Patienten, Fällen, Medikationsanalysen und MRPs in FHIR und Frontend-Tabellen auf Basis der INTERPOLAR-Datenbank

### Ausgabe

gibt zwei Tabellen in OutputGlobal als html Datei aus (../outputGlobal/dataprocessor/reports)

-   statistical_reports.html beinhaltet Zählungen für die FAS1 gesplittet nach Station und Aufnahmewoche (nur erster Kontakt eines Falls auf einer INTERPOLAR-Station und davon nur die erste Medikationanalyse und dazugehörige MRPs)

-   fe_summary.html beinhaltet die Zählungen für alle im Frontend dokumentierten Fälle, gesplittet nach Station

### Konfiguration

abgefragter Zeitraum kofigurierbar

-   alle Fälle werden gezählt, die innerhalb dieses Zeitraumes auf einer INTERPOLAR-Station (in statistical_reports.html über Versorgungsstellenkontakt) bzw. in der Einrichtung (in fe_summary.html über Einrichtungskontakt) aufgenommen wurden; dabei zählt der Start-Tag dazu, der End-Tag nicht

-   Default ist aktuell gesetzt auf [01.01.2025, aktuelles Datum)

### Ausführung

ausführbar über Aufruf des dataprocessors mit folgenden Argumenten:

-   `Statistical_Reports`(=Name des Submoduls im Ordner manual_start) als Argument anhängen (unbenannt)

-   optional Anpassung des Zeitraumes über die Argumente `REPORT_PERIOD_START`und `REPORT_PERIOD_END`mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD oder YYYY/MM/DD

-   Beispiel:

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R Statistical_Reports REPORT_PERIOD_START=2025-07-01 REPORT_PERIOD_END=2025-07-31
```
