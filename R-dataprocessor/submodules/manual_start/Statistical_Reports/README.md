# "Statistical_Reports" - kumulative Kennzahlen zur Qualitätssicherung des Studienfortschritts

## Version 0.5 (14.04.2026)

### Funktion

Zählung von Patienten, Fällen, Medikationsanalysen und MRPs mittels Frontend- und FHIR-Tabellen auf Basis der INTERPOLAR-Datenbank.

### Ausgabe

Es wird eine html Datei in OutputGlobal ((../outputGlobal/dataprocessor/reports/INTERPOLAR-Reporting\_*Ausführungsdatum*.html) ausgegeben:

-   Darin sind zwei Tabellen enthalten: Die obere Tabelle stellt die Kennzahlen pro Standort (letzte Zeile: "all") sowie Stations-bezogen dar. Die untere Tabelle enthält eine zusätzliche Gruppierung nach Aufnahmewoche des jeweiligen Falls.

-   Es ist eine Suche ("Search" im oberen rechten Rand) sowie eine Sortierung (Klicken auf die Spaltennamen) und Filterung der Tabelleneinträge möglich. Über den Download-Button im oberen linken Rand kann wahlweise eine csv-Datei oder Excel-Datei der Tabelleneinträge erzeugt werden.

-   Die Tabellen beinhalten die Zählungen für alle im Frontend dokumentierten Fälle. War ein Fall auf mehreren INTERPOLAR-Stationen, wird er auf jeder seiner Stationen gezählt, wodurch die Summe über alle Stationen einzeln höher als die angezeigte Gesamtanzahl der Fälle sein kann.

-   Die Zählung gemäß primärer Endpunktanalyse (nur erster Kontakt eines Falls auf einer INTERPOLAR-Station und davon nur die erste Medikationanalyse und dazugehörige MRPs) ist in Erarbeitung.

-   die Tabellen enthalten folgende Kennzahlen:

    -   Spalte zur Auflistung der Station (ward)

    -   Anzahl der im Frontend aufgeführten Patienten (patients)

    -   Anzahl der aufgrund geringer Anzahl (n\<5 pro Zeile) zensierten Patienten (censored patients)

    -   Anzahl der Patienten mit aktivem, zugestimmten und aktuellem Eintrag der MII-Consent-Policy Provision: MDAT wissenschaftlich nutzen (2.16.840.1.113883.3.1937.777.24.5.3.8) (consent given)

    -   Anzahl der im Frontend aufgeführten Fälle (encounters)

    -   Anzahl nicht verwertbarer Fälle aus dem Frontend (processing excluded encounters (linkage issues))

    -   Anzahl der Fälle die die Einschlusskriterien für die INTERPOLAR-Kohorte nicht erfüllen z.B. minderjährige Patienten (not meeting inclusion criteria (patient underage))

    -   Anzahl der Fälle mit abgeschlossener Medikationsanalyse im Frontend = Status: "completed" (encounters with completed medication analysis)

    -   Anzahl der angelegten Medikationsanalysen (medication analyses)

    -   Anzahl der abgeschlossenen Medikationsanalysen = status: "completed" (completed medication analyses)

    -   Anzahl der Fälle mit abgeschlossender MRP-Dokumentation im Frontend = Status: "completed" (encounters with completed MRP documentation)

    -   Anzahl der dokumentierten MRP (MRP documented)

    -   Anzahl der abgeschlossenen MRP-Dokumentationen = status: "completed" (completed MRP documentation)

    -   Anzahl der gelösten MRP = im Sinne von: vorgeschlagene Intervention umgesetzt (resolved MRP)

    -   Anzahl der MRP mit nicht-informativem Lösungszustand = nicht ausgewählt, "Arzt / Pflege informiert", "Intervention vorgeschlagen, Umsetzung unbekannt" (MRP resolution not informative)

    -   Anzahl der Kontraindikationen (contraindications)

    -   Anzahl von drug-drug Kontraindikationen (class: drug-drug)

    -   Anzahl von drug-disease Kontraindikationen (class: drug-disease)

    -   Anzahl von drug-Niereninsuffizienz Kontraindikationen (class: drug-renal insufficiency)

    -   Anzahl der Kontraindikationen mit nicht ausgewählter Klasse (class not assigned)

    -   Anzahl der gelösten Kontraindikationen (resolved contraindications)

    -   Anzahl der Fälle, die für eine algorithmische MRP-Berechnung in Frage komme: Aufnahme auf Station in Studienphase B, erhaltene Medikationsanalyse, seit mind. 14 Tagen entlassen (encounters eligible for algorithmic MRP)

    -   Anzahl der Fälle, für die mindestens ein MRP algorithmisch ermittelt wurde (encounters with algorithmic MRP)

    -   Anzahl der Fälle, für die mindestens ein MRP algorithmisch ermittelt wurde sowie ein consent vorliegt (encounters with algorithmic MRP and consent)

    -   Anzahl der algorithmisch detektierten MRP (nur Kontraindikationen!) (algorithmic MRP found)

    -   Anzahl der algorithmisch detektierten MRP mit MRP-Klasse drug-drug (algorithmic class: drug-drug)

    -   Anzahl der algorithmisch detektierten MRP mit MRP-Klasse drug-disease (algorithmic class: drug-disease)

    -   Anzahl der algorithmisch detektierten MRP mit MRP-Klasse drug-renal insufficiency (algorithmic class: drug-renal insufficiency)

    -   Anzahl der algorithmisch detektierten MRP, für die eine retrolektive MRP-Bewertung erfolgt ist (completed algorithmic MRP evaluation)

    -   Anzahl der als klinisch relevant bewerteten algorithmischen MRP, welche nicht zuvor manuell dokumentiert wurden (evaluation: new and clinically relevant)

    -   Anzahl der bereits manuell dokumentierten, klinisch relevanten algorithmischen MRP (evaluation: already manually documented)

    -   Anzahl der algorithmisch detektierten MRP, die per Definition nicht als Kontrainidkation beurteilt werden (evaluation: no contraindication)

    -   Anzahl der algorithmisch detektierten MRP, deren Berechnung auf falsche Datengrundlage beruhen (evaluation: based on incorrect data items)

    -   Anzahl der algorithmisch detektierten MRP, für die das MRP-Konzept zu unspezifisch war (evaluation: MRP concept unspecific)

    -   Anzahl der algorithmisch detektierten MRP, die für den speziellen Fall als klinisch nicht relevant eingestuft werden (evaluation: clinically irrelevant)

    -   Anzahl der algorithmisch detektierten MRP, die für diese Station immer als klinisch nicht relevant eingestuft werden (evaluation: always clinically irrelevant)

Auf Anforderung können ergänzend weitere Tabellen als html-Dateien ausgegeben werden, welche die der Zählung zugrunde liegenden Datenelemente auf Patienten bzw. Fallbasis enthalten. Diese sind keine aggregierten Daten und werden daher im outputLocal gespeichert.

### Details

-   die aggregierten Kennzahlen umfassen nur solche Fälle, die die Kriterien für die INTERPOLAR-Kohorte (Full Analysis Set 1 / FAS1) erfüllen (stationäre Fälle \>18 Jahre, die auf einer INTERPOLAR-Station aufgenommen wurden)
-   für Fälle mit mehreren Stationen: nur Medikationsanalysen deren Datum innerhalb eines INTERPOLAR-Stationsaufenthaltes liegt, werden gezählt (d.h. die Medikationsanalyse muss innerhalb des Zeitraumes des INTERPOLAR-Versorgungsstellenkontaktes liegen)

### Konfiguration

abgefragter Zeitraum konfigurierbar

-   alle Fälle werden gezählt, die innerhalb dieses Zeitraumes in der Klinik (Beginn des Einrichtungskontaktes) aufgenommen wurden; dabei zählt der Start-Tag dazu, der End-Tag nicht

-   Default ist aktuell gesetzt auf [01.01.2024, aktuelles Datum)

bei Bedarf Ausgabe der zu Grunde liegenden Datentabellen (outputLocal)

-   zur besseren Nachvollziehbarkeit können bei Bedarf die den Berechnungen zu Grunde liegenden Datentabellen in outputLocal ausgegeben werden

-   dies wird nur empfohlen für nach Zeitraum gefilterte Anfragen, da die Generierung der Tabellen sonst zu memory-Problemen führen kann

### Ausführung

Aufruf des dataprocessors mit folgenden Argumenten:

-   `Statistical_Reports`(=Name des Submoduls im Ordner manual_start) als Argument anhängen

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R Statistical_Reports
```

-   optional Anpassung des Zeitraumes über die Argumente `REPORT_PERIOD_START`und `REPORT_PERIOD_END`mit Name=Wert (ohne Leerzeichen zwischen Name und Wert) und Wert im Format YYYY-MM-DD oder YYYY/MM/DD

-   optional Ausgabe der zu Grunde liegenden Datentabellen in outputLocal über das Argument `WRITE_TABLE_LOCAL=TRUE`

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R Statistical_Reports REPORT_PERIOD_START=2025-09-01 REPORT_PERIOD_END=2025-09-08 WRITE_TABLE_LOCAL=TRUE
```

### Annahmen/Erläuterungen

(nach bestem Wissen und Gewissen gemäß MII KDS Implementation-Guide (mit Bitte um Korrektur falls nicht korrekt umgesetzt) sowie ggf. für die Analyse nötige Erweiterungen)

-   Encounter-Ressourcen sind über das dreistufige-Encounter Modell abgebildet (für das Reporting sind Einrichtungskontakt und vor allem Versorgungstellenkontakt von Bedeutung)
-   Encounter.status, Encounter.class & Encounter.type:Kontaktebene sind gemäß den entsprechenden Bindings implementiert ( <http://fhir.de/ValueSet/EncounterStatusDe> , <http://fhir.de/ValueSet/EncounterClassDE> , <http://fhir.de/CodeSystem/Kontaktebene> )
-   falls neben normalstationären Kontakten weitere Kontakte in FHIR abgebildet werden, sind diese über Encounter.type:Kontaktart mit entsprechendem Binding implementiert ( <http://fhir.de/CodeSystem/kontaktart-de> )
-   der eindeutige organisationsinterner Patienten-Identifier (PID) kann über die in der dataprocessor_config.toml bereits implementierten Filter festgelegt werden (FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM/\_TYPE_SYSTEM/\_TYPE_CODE). Die Bedingungen sind für eine Filterung mit UND-Verknüpfung vorgesehen. Falls dies nicht zur Eindeutigkeit führt (Warnung) sollten die Filter überprüft werden, um die korrekte Anzeige im Frontend sicher zu stellen. Für das Reporting hat dies keinen Einfluss auf die Zählung.
-   die Kontaktebenen eines Falls sind über partOf-Beziehungen verknüpft; falls nicht müssen alle Encounter-Ressourcen eines Falles den selben enc_identifier_value tragen.
-   falls es für einen Fall verschiedene enc_identifier_values geben kann, muss über COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM in der dataprocessor_config.toml festgelegt werden, aus welchem System die eigentliche Aufnahmenummer/Fallnummer stammt, dieses muss dann für alle drei Encounter-Ebenen eingetragen sein
-   wenn COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM spezifiziert ist, werden Datenbankreihen mit anderem (oder NA) enc_identifier_system nicht in der Auswertung beachtet
-   über die pids_per_ward Tabelle (INTERPOLAR-DB) sind die Fälle auf Versorgungsstellenkontakt-Ebene einer Station zugeordnet (INTERPOLAR-Stationsaufenthalt): encounter_id in pids_per_ward zeigt (unter Anderem) alle INTERPOLAR-Versorgungsstellenkontakte eines Falls.
-   INTERPOLAR-Versorgungsstellenkontakte besitzen ein Start-Datum, welches das Aufnahmedatum auf der INTERPOLAR Station darstellt (enc_period_start)
-   verschiedene INTERPOLAR-Versorgungstellenkontakte eines Falls dürfen nicht das selbe Start-Datum haben (keine gleichzeitige Aufnahme auf verschiedenen Stationen)
-   Versorgungsstellenkontakte die kein Enddatum haben und 'in-progress' sind, befinden sich aktuell noch auf der Station (für Berechnungen wird End-Datum auf aktuelles Datum gesetzt)
-   Encounter-Ressourcen aller Hierarchie-Ebenen besitzen ein End-Datum, wenn der Status auf 'finished' gesetzt ist (gemäß Invarianten des Implementation Guides)
-   Encounter-Ressources mit status 'planned', 'cancelled', 'entered-in-error' & 'unknown' werden nicht für die Zählungen berücksichtigt
-   für Encounter-Ressourcen mit status 'onleave' und fehlendem End-Datum, wird für Berechnungen das End-Datum auf deren Start-Datum gesetzt
-   Encounter-Ressourcen mit class_code 'PRENC', 'VR', 'HH' werden nicht für die Zählungen berücksichtigt; 'AMB' und 'SS' könnten ggf. für komplexere Analysen benötigt werden (z.B. Ermittlung eines OP Aufenthalts), werden aber aktuell nicht in die Berechnungen einbezogen
-   stationäre INTERPOLAR-Kontakte tragen enc_class_code entsprechend der Definition in FRONTEND_DISPLAYED_ENCOUNTER_CLASS (e.g. "IMP"", ggf. "SS")
-   Kontakte mit Kontaktart "begleitperson" werden in den Zählungen nicht berücksichtigt. Die Kontaktarten "vorstationaer", "nachstationaer", "ub", "konsil" und "operation" könnten als Sekundärkontakte für komplexere Analysen benötigt werden, werden aber aktuell nicht in die Berechnungen einbezogen. Die Kontaktarten "teilstationaer", "tagesklinik", "nachtklinik", "normalstationaer", "intensivstationaer" im Versorgungsstellenkontakt werden für INTERPOLAR Stationskontakte in den Zählungen berücksichtigt.
-   Wenn fall_studienphase in fall_fe leer ist, wird diese durch 'PhaseA' ersetzt (für Daten vor Einführung der Befüllung der Spalte Studienphase)
-   Encounter-Altdaten (die ggf. in den lokalen Tabellen erscheinen) werden ressourcensparend aktuell gefiltert auf ein Startdatum(enc_period_start) von 1 Jahr vor REPORT_PERIOD_START
-   Dateneinträge mit processing_exclusion_reason waren betroffen von einem der Datenqualitätschecks und werden nicht weiter verarbeitet (siehe warnings)
-   dokumentierte Medikationsanalysen müssen mit einem Fall verknüpft sein (im Frontend Fall-ID setzen); falls dies fehlt und es meherer Fälle für einen Patienten gibt, fehlen die zugehörigen Analysen u.U. im Reporting, da sie keinem Fall zugeordnet werden können falls das Matching über den Zeitraum des Falls fehlschlägt
-   Einträge mit RedCap-Status "unverified" werden in der Zählung nicht beachtet
