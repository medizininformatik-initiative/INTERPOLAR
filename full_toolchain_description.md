**Work in progress, Stand: 20.12.2024**

# CDS Tool Chain - Ablauf:

## 0. Projektkonventionen

## 1. Vorbereitung:

Eine Übersicht aller Module ist in der [Projekt README Datei](README.md) zu finden.

### 1.1 Konfigurationsdateien:

Um Änderungen an bestimmten Parameters innerhalb der CDS-Toolchain vornehmen zu können, gibt es zu jedem Modul eine Konfigurationsdatei (*config.toml). Hierbei gibt es eine Datei die die [Datenbankeinstellungen](cds_hub_db_config.toml) für alle User und Schemata beinhaltet, diese muss im Regelfall nicht verändert werden.
Weiterhin gibt es für jedes R-Modul einzeln eine Konfigurationsdatei. Diese befindet sich im jeweiligen Modul-Unterordner und muss selbst nach den lokalen Gegebenheiten angepasst werden. Die zur Anpassung möglichen Parameter sind in der Konfigurationsdatei mit Beispiel beschrieben.

## 2. Start des Moduls 'cds2db':

Nach dem Start dieses Moduls werden alle gesetzten Konfigurationsparameter in R eingelesen.

### 2.1 Semaphore freigeben

In einem ersten Schritt wird Status der Semaphore in der DB zurückgesetzt, falls zuvor ein fehlerhafter Durchlauf zum Abbruch der Pipeline geführt hat. Generell wird vor jedem Lese- und Schreibmodul geprüft, ob die Datenbank bereit ist Daten zu empfangen oder zu senden. Die Datenbank wird über einen Cron-Jobs gesteuert und über eine eingebaute Semaphore wird der aktuelle Status der Datenbank bekannt gegeben.
Die Datenbank kann für den Lese- und Schreibzugriff in R gesperrt und wieder freigegeben werden. Weitere Informationen zur Datenbank sind in der [DB_description.md](Postgres-cds_hub/DB_description.md) und dem [Dataflow.md](Dataflow.md) nachzulesen.

### 2.2  Laden der relevanten Patienten-IDs (PIDs)

Um die relevanten PIDs verfügbar zu machen gibt es zwei Wege.
1. Zum einen können die PIDs über eine Textdatei [source_PIDs.txt](R-cds2db/source_PIDs.txt) eingelesen werden. Hier müssen die täglich auf den Stationen befindlichen PIDs hinterlegt werden.
2. Der andere Weg ist es die PIDs über einen Encounter-Filter zu bekommen. Hierbei können zum Beispiel Encounter mit bestimmter Location gefiltert werden. In beiden Fällen muss entsprechend die [Konfigurationsdatei](R-cds2db/cds2db_config.toml#L123-L158) angepasst werden.

Es werden per FHIR-Search alle Encounter vom FHIR-Server heruntergeladen, die zum aktuellen Datum noch nicht beendet sind. Es wird nicht unterschieden zwischen den Encounter-Typen (Einrichtungskontakt, Abteilungskontakt, Versorgungsstellenkontakt). 'Noch nicht beendet' bedeutet, dass das Startdatum der Encounter (date=ltJJJJ-MM-TT) in der Vergangenheit liegt und der Status der Encounter auf "in-progress" steht.
Es sind weitere Filter möglich, wie z.B. lade nur Encounter, mit einer bestimmten Referenz auf eine Location oder einer bestimmten Class (z.B. "IMP"). ([Konfigurationsdatei](R-cds2db/cds2db_config.toml#L82-L122))

Zusätzlich gibt es eine Reihe von DEBUG-Parametern. Es kann das aktuelle Datum zur FHIR-Search-Anfrage in die Vergangenheit gesetzt werden. Zusätzlich dazu kann auch ein Ende-Datum gesetzt werden, so dass die FHIR-Search-Anfrage der Encounter nicht mit lower than = 'lt' sondern mit starts after = 'sa' für das DEBUG-Startdatum und ends before = 'eb' für das DEBUG-Enddatum gestellt wird. ([DEBUG_ENCOUNTER_DATETIME](R-cds2db/cds2db_config.toml#L174-L175))
Ebenso können auch nur Encounter mit einer bestimmten PID heruntergeladen werden ([DEBUG_ENCOUNTER_ACCEPTED_PIDS](R-cds2db/cds2db_config.toml#L179)). Ein weiterer DEBUG_Parameter ermöglicht es nach dem Herunterladen der Encounter die ebenfalls generierte Tabelle mit dem PIDs pro Station (pids_per_ward) auf PIDs mit einen bestimmten Pattern in der ID zu filtern. ([DEBUG_FILTER_PIDS_PATTERN](R-cds2db/cds2db_config.toml#L257))
Diese beschriebenen Parameter sind jedoch nur für Test-Zwecke gedacht!

### 2.3 Einlesen der TableDescription

In diesen Schritt wird die [Table_Description.xlsx](R-cds2db/cds2db/inst/extdata/Table_Description.xlsx), welche alle abgefragten FHIR-Ressourcen (COI) sowie alle absoluten XML-Pfade dieser Ressourcen beinhaltet, eingelesen. Weitere Informationen zur Generierung und Funktionalität dieser Datei ist in dem Dokument [Dataflow.md](Dataflow.md#voraussetzungen--vorbereitung) nachzulesen.

### 2.4 Herunterladen der FHIR Ressourcen

Der Download der FHIR Ressourcen vom Server erfolgt in zwei Schritten. Zunächst werden die  PID-abhängigen FHIR-Ressourcen heruntergeladen. Hierzu werden über eine Datenbankabfrage die PIDs der beim letzten Durchlauf in die Datenbank geschriebenen Encounter von der Datenbank geladen.
Über einer zweiten SQL Abfrage werden für alle PIDs das Datum ermittelt, wann diese Patienten das letzte mal in die Datenbank geschrieben wurden. Dadurch ist es möglich von allen Patienten nur die aktuellen Daten vom FHIR Server herunterzuladen. Wurden noch nie Daten vom FHIR-Server für eine PID heruntergeladen, dann wird alles, was auf dem FHIR-Server verfügbar ist, zu der jeweiligen PID heruntergeladen.
Für alle PIDs der in Punkt 2.2 gefundenen Encounter werden alle im Projekt festgelegten, noch nicht auf der Datenbank befindlichen, PID-abhängigen FHIR-Ressourcen heruntergeladen.
Gemeint sind hier alle Resourcen, die eine direkte Referenz (in FHIR 'subject' oder 'patient') zu einer in Punkt 2.2 gefundenen PID besitzen sowie die zugehörige Patient-Ressourcen mit genau diesen PIDs.
Dabei handelt es sich konkret um:
 - Patient
 - Encounter
 - Condition
 - MedicationRequest
 - MedicationAdministration
 - MedicationStatement
 - Observation
 - DiagnosticReport
 - ServiceRequest
 - Procedure
 - Consent

In einen zweiten Schritt werden alle PID-unabhängigen Ressourcen vom FHIR Server über die eigene ID heruntergeladen. Dazu werden alle von den bereits heruntergeladenen Ressourcen die Referenz-IDs der referenzierten Ressourcen ermittelt und anhand dieser heruntergeladen.
Zu den FHIR Ressourcen ohne Referenzierung zum Patienten gehören:
- Medication
- Location

Intern erfolgt direkt nach dem Download der einzelnen FHIR-Ressourcen der erste Aufbereitungsschritt bei dem die FHIR-Daten in flache Tabellen umgewandelt werden mittels dem R-Paket "fhircrackr" über die Funktion *fhir_crack()*. Die dann entstandenen, indexierten "RAW"-Tabellen werden dann in die Datenbank überführt. Die Tabellenspalten sind an dieser Stelle alle vom Typ "character".

Für diesen Schritt gibt es weitere DEBUG-Parameter ([DEBUG_ADD_FHIR_SEARCH_*](R-cds2db/cds2db_config.toml#L190)) mit denen es möglich ist den Download der Ressourcen einzuschränken. Hier können zusätzliche Parameter für die FHIR-Search-Anfrage spezifisch für jede Ressource angegeben werden.

### 2.5 Typisierung der Ressourcen Tabellen

Im nächsten Schritt werden "RAW"-Daten von der Datenbank geladen, die noch nicht typisiert wurden. Die Typisierung beinhaltet den einzelnen Items in den Ressourcen Tabellen den korrekten Datentypen zuzuordnen. Die Information des korrekten Datentyps der einzelnen Items in den Ressourcen Tabellen ist in der TableDescription hinterlegt.
Nach dem Laden der "RAW"-Daten wird ein weiterer Aufarbeitungsschritt, das *fhir_melt()* durchgeführt. Dieser Schritt ist notwendig, weil durch *fhir_crack()* in den Tabellen mehrfache Einträge aufgrund von Listen von Unterelementen produziert werden können. Durch Klammerung und Indexierung werden die Ebenen dann dargestellt und die einzelnen Elemente mit einen Separator (hier "~") getrennt. Durch das *fhir_melt()* werden die Unterelemente dann aufgeschlüsselt und alle separat in einer Zeile dargestellt.
Anschließend werden die expandierten Ressourcen-Tabellen typisiert und wieder in die Datenbank geschrieben.

Da der *fhir_melt()* Prozess eine gewissen Zeit in Anspruch nehmen kann, ist es per DEBUG-Parameter möglich die von der Datenbank geladenen Ressourcen Tabellen vor dem *fhir_melt()* auf bestimmte Zeilen zu kürzen, siehe ([DEBUG_FILTER_*](R-cds2db/cds2db_config.toml#L220)).

### 2.6 Schließen aller Datenbankverbindungen

Am Ende werden alle offenen Datenbankverbindungen geschlossen. Wenn es zu einen Fehler innerhalb der cds2db Moduls kommt, wird das Skript gestoppt und es wird eine Fehlermeldung angezeigt. Wenn es Warnungen gibt, läuft das Modul durch und gibt am Ende die Warnmeldungen aus. In jedem Fall werden am Ende alle Schritte, die geloggt wurden aufgelistet und die benötigte Zeit angegeben. Diese Performance-Informationen sind neben der eigentlichen Log-Datei im Ordner "outputLocal" zu finden


## 3. Start des Moduls 'dataprocessor':

Nach dem Start dieses Moduls werden alle gesetzten Konfigurationsparameter in R eingelesen.

### 3.1 Semaphore freigeben

siehe Abschnitt *2.1*.

### 3.2 Tabellen für das Frontend erstellen

Das Modul "dataprocessor" stellt die für das Frontend benötigten Tabellen bereit. Momentan sind zwei Tabellen relevant, die Patienten- und die Fall-Informationen. Es werden immer die zuletzt auf der Datenbank eingefügten Daten angefragt.

Zunächst werden die Tabellenstrukturen gemäß den Vorgaben des Frontend angelegt. Über die pids_per_ward Tabelle werden die zuletzt in die Datenbank geschriebenen Patienten geladen. Ebenso werden alle Encounter für die aktuellen PIDs geladen. Für das Frontend sind aber auch weitere Informationen, wie Patienten-Gewicht oder die Aufnahmediagnose. Daher werden auch Informationen aus den Conditions und den Observationen benötigt. Durch Filterung werden alle benötigten Datenitems zusammengetragen und dann in die initialisierten Tabellen für das Frontend geschrieben.

*Voraussetzung*: Das aktuelle Datum muss zu den Start- und Enddaten der Encounter passen. Es werden nur Fälle gefunden, deren Startdatum vor dem aktuellen Datum liegt und deren Enddatum nach dem aktuellen Datum liegt oder nicht gesetzt ist.

Will man hier für Daten aus der Vergangenheit irgendwas sehen, dann muss in der Konfigurationsdatei für den Dataprocessor ([dataprocessor_cofig.toml](R-dataprocessor)) unter der Variable  ["DEBUG_ENCOUNTER_DATETIME"](R-dataprocessor/dataprocessor_config.toml#L43) ein entsprechend zu den Daten passendes Datum eingestellt werden. Alle Variablen, die im Echtbetrieb deaktiviert sein sollten, haben den Präfix "DEBUG_".

Weitere Informationen folgen.
