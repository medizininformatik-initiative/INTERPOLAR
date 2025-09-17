# "Statistical_Reports" - kumulative Kennzahlen zur Qualitätssicherung des Studienforschritts

## Version 0.1 (16.09.2025)

### Funktion

Zählung von Patienten, Fällen, Medikationsanalysen und MRPs in FHIR und Frontend-Tabellen auf Basis der INTERPOLAR-Datenbank

### Ausgabe

gibt zwei Tabellen in OutputGlobal als html Datei aus (../outputGlobal/dataprocessor/reports)

-   statistical_reports.html beinhaltet Zählungen für die Full Analysis Set 1 (FAS1) gesplittet nach Station und Aufnahmewoche (nur erster Kontakt eines Falls auf einer INTERPOLAR-Station und davon nur die erste Medikationanalyse und dazugehörige MRPs)

    -   F1: Kumulative Anzahl der hospitalisierten Fälle auf INTERPOLAR-Stationen (\>18 Jahre, erster Kontakt mit einer INTERPOLAR-Station)

        -   Anzahl der Patienten in den FHIR Tabellen der INTERPOLAR-Datenbank

        -   Anzahl der ebenfalls im Frontend aufgeführten Patienten

        -   Anzahl der Fälle in den FHIR Tabellen der INTERPOLAR-Datenbank

        -   Anzahl der ebenfalls im Frontend aufgeführten Fälle

    -   Anzahl nicht verwertbarer Fälle aus FHIR (unplausible oder fehlende Daten)

    -   Anzahl der angelegten Medikationsanalysen

    -   Anzahl der abgeschlossenen Medikationsanalysen (status: "completed")

    -   Anzahl der dokumentierten MRP

    -   Anzahl der abgeschlossenen MRP-Dokumentationen (status: "completed")

    -   Anzahl der gelösten MRP (im Sinne von: vorgeschlagene Intervention umgesetzt)

    -   Anzahl der MRP mit nicht-informativem Lösungszustand ("Arzt / Pflege informiert", "Intervention vorgeschlagen, Umsetzung unbekannt")

    -   Anzahl der Kontraindikationen

    -   Anzahl von drug-drug Kontraindikationen

    -   Anzahl von drug-disease Kontraindikationen

    -   Anzahl von drug-Niereninsuffizienz Kontraindikationen

    -   Anzahl nicht verwertbarer Fälle aus dem Frontend (unplausible oder fehlende Daten)

-   fe_summary.html beinhaltet die Zählungen für alle im Frontend dokumentierten Fälle, gesplittet nach Station

    -   Anzahl der im Frontend aufgeführten Patienten

    -   Anzahl der im Frontend aufgeführten Fälle

    -   Anzahl der angelegten Medikationsanalysen

    -   Anzahl der abgeschlossenen Medikationsanalysen (status: "completed")

    -   Anzahl der dokumentierten MRP

    -   Anzahl der abgeschlossenen MRP-Dokumentationen (status: "completed")

    -   Anzahl der gelösten MRP (im Sinne von: vorgeschlagene Intervention umgesetzt)

    -   Anzahl der MRP mit nicht-informativem Lösungszustand ("Arzt / Pflege informiert", "Intervention vorgeschlagen, Umsetzung unbekannt")

    -   Anzahl der Kontraindikationen

    -   Anzahl von drug-drug Kontraindikationen

    -   Anzahl von drug-disease Kontraindikationen

    -   Anzahl von drug-Niereninsuffizienz Kontraindikationen

    -   Anzahl nicht verwertbarer Fälle aus dem Frontend (unplausible oder fehlende Daten)

### Details

-   die aggregierten Kennzahlen umfassen nur solche Fälle, die die Kriterien für die INTERPOLAR-Kohorte (Full Analysis Set 1 / FAS1) erfüllen (stationäre Fälle \>18 Jahre, die auf einer INTERPOLAR-Station aufgenommen wurden)
-   nur Medikationsanalysen deren Datum innerhalb eines INTERPOLAR-Stationsaufenthaltes liegt, werden gezählt (d.h. die Medikationsanalyse muss innerhalb des Zeitraumes des INTERPOLAR-Versorgungsstellenkontaktes liegen)

### Konfiguration

abgefragter Zeitraum konfigurierbar

-   alle Fälle werden gezählt, die innerhalb dieses Zeitraumes auf einer INTERPOLAR-Station (in statistical_reports.html über Versorgungsstellenkontakt) bzw. in der Einrichtung (in fe_summary.html über Einrichtungskontakt) aufgenommen wurden; dabei zählt der Start-Tag dazu, der End-Tag nicht

-   Default ist aktuell gesetzt auf [01.01.2025, aktuelles Datum)

### Ausführung

nach Auschecken der Branches '553-initiale-statistik-reports-erstellen' und Neubau des Images ausführbar über Aufruf des dataprocessors mit folgenden Argumenten:

-   `Statistical_Reports`(=Name des Submoduls im Ordner manual_start) als Argument anhängen (unbenannt)

-   optional Anpassung des Zeitraumes über die Argumente `REPORT_PERIOD_START`und `REPORT_PERIOD_END`mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD oder YYYY/MM/DD

-   Beispiel:

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R Statistical_Reports REPORT_PERIOD_START=2025-07-01 REPORT_PERIOD_END=2025-07-31
```

### Annahmen

(nach bestem Wissen und Gewissen gemäß MII KDS Implementation-Guide (mit Bitte um Korrektur falls nicht korrekt umgesetzt) sowie ggf. für die Analyse nötige Erweiterungen)

-   Encounter-Ressourcen sind über das dreistufige-Encounter Modell abgebildet (für das Reporting sind Einrichtungskontakt und vor allem Versorgungstellenkontakt von Bedeutung)
-   Encounter.status, Encounter.class & Encounter.type:Kontaktebene sind gemäß den entsprechenden Bindings implementiert ( <http://fhir.de/ValueSet/EncounterStatusDe> , <http://fhir.de/ValueSet/EncounterClassDE> , <http://fhir.de/CodeSystem/Kontaktebene> )
-   falls neben normalstationären Kontakten weitere Kontakte in FHIR abgebildet werden, sind diese über Encounter.type:Kontaktart mit entsprechendem Binding implementiert ( <http://fhir.de/CodeSystem/kontaktart-de> )
-   der eindeutige organisationsinterner Patienten-Identifier (PID) kann über die in der dataprocessor_config.toml bereits implementierten Filter festgelegt werden (FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM/\_TYPE_SYSTEM/\_TYPE_CODE). Dabei muss mindestens eine der drei Bedingungen zutreffen.
-   die Kontaktebenen eines Falls sind über partOf-Beziehungen verknüpft; falls nicht müssen alle Encounter-Ressourcen eines Falles den selben enc_identifier_value tragen.
-   falls es für einen Fall verschiedene enc_identifier_values im Einrichtungskontakt geben kann, muss über COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM in der dataprocessor_config.toml festgelegt werden, aus welchem System die eigentliche Aufnahmenummer/Fallnummer stammt
-   wenn COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM spezifiziert ist, werden Datenbankreihen von Einrichtungskontakten mit anderem (oder NA) enc_identifier_system nicht in der Auswertung beachtet
-   über die pids_per_ward Tabelle (INTERPOLAR-DB) sind die Fälle auf Versorgungsstellenkontakt-Ebene einer Station zugeordnet (INTERPOLAR-Stationsaufenthalt): encounter_id in pids_per_ward zeigt (unter Anderem) alle INTERPOLAR-Versorgungsstellenkontakte eines Falls.
-   INTERPOLAR-Versorgungsstellenkontakte besitzen ein Start-Datum, welches das Aufnahmedatum auf der INTERPOLAR Station darstellt (enc_period_start)
-   verschiedene INTERPOLAR-Versorgungstellenkontakte eines Falls dürfen nicht das selbe Start-Datum haben (keine gleichzeitige Aufnahme auf verschiedenen Stationen)
-   Versorgungsstellenkontakte die kein Enddatum haben und 'in-progress' sind, befinden sich aktuell noch auf der Station (für Berechnungen wird End-Datum auf aktuelles Datum gesetzt)
-   Encounter-Ressourcen aller Hierarchie-Ebenen besitzen ein End-Datum, wenn der Status auf 'finished' gesetzt ist (gemäß Invarianten des Implementation Guide)
-   Encounter-Ressources mit status 'planned', 'cancelled', 'entered-in-error' & 'unknown' werden nicht für die Zählungen berücksichtigt
-   für Encounter-Ressourcen mit status 'onleave' und fehlendem End-Datum, wird für Berechnungen das End-Datum auf deren Start-Datum gesetzt
-   Encounter-Ressourcen mit class_code 'PRENC', 'VR', 'HH' werden nicht für die Zählungen berücksichtigt; 'AMB' und 'SS' könnten ggf. für komplexere Analysen benötigt werden (z.B. Ermittlung eines OP Aufenthalts), werden aber aktuell nicht in die Berechnungen einbezogen
-   stationäre INTERPOLAR-Kontakte tragen enc_class_code == "IMP" mindestens im Einrichtungskontakt
-   Kontakte mit Kontaktart "begleitperson" werden in den Zählungen nicht berücksichtigt. Die Kontaktarten "vorstationaer", "nachstationaer", "ub", "konsil" und "operation" könnten als Sekundärkontakte für komplexere Analysen benötigt werden, werden aber aktuell nicht in die Berechnungen einbezogen. Die Kontaktarten "teilstationaer", "tagesklinik", "nachtklinik", "normalstationaer", "intensivstationaer" im Versorgungsstellenkontakt werden für INTERPOLAR Stationskontakte in den Zählungen berücksichtigt.
-   Wenn fall_studienphase in fall_fe leer ist, wird diese durch 'PhaseA' ersetzt (für Daten vor Einführung der Befüllung der Spalte Studienphase)
