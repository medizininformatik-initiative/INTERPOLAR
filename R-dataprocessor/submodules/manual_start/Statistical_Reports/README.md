# "Statistical_Reports" - kumulative Kennzahlen zur Qualitätssicherung des Studienforschritts

## Initiale Version (06.08.2025)

### Funktion

Zählung von Patienten, Fällen, Medikationsanalysen und MRPs in FHIR und Frontend-Tabellen auf Basis der INTERPOLAR-Datenbank

### Ausgabe

gibt zwei Tabellen in OutputGlobal als html Datei aus (../outputGlobal/dataprocessor/reports)

-   statistical_reports.html beinhaltet Zählungen für die Full Analysis Set 1 (FAS1) gesplittet nach Station und Aufnahmewoche (nur erster Kontakt eines Falls auf einer INTERPOLAR-Station und davon nur die erste Medikationanalyse und dazugehörige MRPs)

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

### Annahmen

-   die Kontaktebenen eines Falls sind über partOf-Beziehungen verknüpft; falls nicht müssen alle Encounter-Ressourcen eines Falles den selben enc_identifier_value haben
-   über Patient.indentifier.type.coding.code(FHIR) bzw. pat_identifier_type_code(INTERPOLAR-DB) == "MR" kann für jeden Patienten ein eindeutiger organisationsinterner Patienten-Identifier (PID) identifiziert werden (gemäß <https://ig.fhir.de/basisprofile-de/1.5.0/ig-markdown-OrganisationsinternerPatienten-Identifier.html> )
-   über die pids_per_ward Tabelle (INTERPOLAR-DB) sind die Fälle auf Versorgungsstellenkontakt-Ebene einer Station zugeordnet (INTERPOLAR-Stationsaufenthalt): encounter_id in pids_per_ward zeigt (unter Anderem) alle INTERPOLAR-Versorgungsstellenkontakte eines Falls
-   INTERPOLAR-Versorgungsstellenkontakte besitzen ein Start-Datum, welches das Aufnahmedatum auf der INTERPOLAR Station darstellt (enc_period_start)
-   verschiedene INTERPOLAR-Versorgungstellenkontakte eines Falls dürfen nicht das selbe Start-Datum haben (keine gleichzeitige Aufnahme auf verschiedenen Stationen)
-   Versorgungsstellenkontakte die kein Enddatum haben und 'in-progress' sind, befinden sich aktuell noch auf der Station (für Berechnungen wird End-Datum auf aktuelles Datum gesetzt)
-   Encounter-Ressourcen aller Hierarchie-Ebenen besitzen ein End-Datum, wenn der Status auf 'finished' gesetzt ist (gemäß Invarianten des Implementation Guide)
-   Encounter-Ressources mit status 'planned', 'cancelled', 'entered-in-error' & 'unknown' werden nicht für die Zählungen berücksichtigt
-   für Encounter-Ressourcen mit status 'onleave' und fehlendem End-Datum, wird für Berechnungen das End-Datum auf deren Start-Datum gesetzt

### Details

-   die aggregierten Kennzahlen umfassen nur solche Fälle, die die Kriterien für die INTERPOLAR-Kohorte (Full Analysis Set 1 / FAS1) erfüllen (stationäre Fälle \>18 Jahre, die auf einer INTERPOLAR-Station aufgenommen wurden)
-   nur Medikationsanalysen deren Datum innerhalb eines INTERPOLAR-Stationsaufenthaltes liegen, werden gezählt (d.h. die Medikationsanalyse muss innerhalb des Zeitraumes des INTERPOLAR-Versorgungsstellenkontaktes liegen)
