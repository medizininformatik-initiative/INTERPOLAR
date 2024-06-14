# Datenbankbeschreibung CDS-HUB DB (cds_hub_db)

## Überblick
Die CDS-HUB DB dient dazu, die importierten FHIR-Daten sowie die erhobenen Studiendaten des Zentrums für spätere Auswertungen persistent zu speichern. Die Datenbank enthält für verschiedene Aufgaben und Zugriffsrollen mehrere Bereiche (siehe ...). Sie enthält nur rudimentäre Logik, die ausschließlich der persistenten Speicherung der Daten (Logging) sowie der Bereitstellung der aktuellen Daten an den Schnittstellen dient.

## Bereiche / Schnittstellen
Man kann die verschiedenen Bereiche (Schemata) in Schnittstellenschemata und funktionale Schemata unterscheiden. Die Schnittstellenschemata dienen dem sicheren Austausch von Daten mit den jeweiligen "externen" Modulen und dem damit verbundenen Rollen- und Rechtekonzept. Funktionale Schemata dienen der inhaltlichen Gliederung der Daten innerhalb der Datenbank. Im Folgenden werden die verschiedenen Bereiche der CDS-HUB DB vorgestellt.

### cds2db_in / cds2db_out
Schnittstellen-Schema zum Importieren von FHIR-Daten (_in) sowie zur Umwandlung dieser Daten in typisierte relationale Datenbanktabellen. Die Umsetzung erfolgt in dieser Referenzimplementierung im Modul CDS2DB mithilfe von R-Skripten (siehe ...). Die in diesem Schema angelegten Tabellen entsprechen den Strukturen der FHIR-Ressourcen.

### db2dataprocessor_in / db2dataprocessor_out
Schnittstellen-Schema, um zum einen Daten aus dem Kern dem Modul DataProcessor (_out) zur Verfügung zu stellen, und zum anderen berechnete Daten von diesem entgegenzunehmen (_in) und wieder im Kern zu persistieren. Sämtliche inhaltliche Logik und Berechnungen finden im Modul DataProcessor statt und können z.B. über R-Skripte implementiert werden. Die in diesem Schema angelegten Tabellen entsprechen den Strukturen der FHIR-Ressourcen (_out) sowie den Strukturen, die fürs Frontend benötigt werden. Weitere Tabellen können für zusätzliche Funktionalitäten erforderlich sein.

### db2frontend_in / db2frontend_out
Schnittstellen-Schema, um Daten aus dem Kern an ein Frontend zu übergeben (_out) bzw. von diesem entgegenzunehmen (_in) und im Kern zu speichern. Die in diesem Schema angelegten Tabellen entsprechen den Strukturen des Frontends.

### Kern
Im Kern der Datenbank werden alle Daten gespeichert sowie verschiedene Cron-Jobs zur Ausführung der Datenbankfunktionalitäten betrieben. Der Kern unterteilt sich in weitere Bereiche, um die Daten thematisch voneinander zu trennen.

#### db
Kern der Datenbank mit individuellen Tabellen.

#### db_log
Schema zur Speicherung aller Daten.

#### db_konfig
Schema zur Speicherung von Hilfstabellen, Hilfs-Views, Tabellen für individuelle Parameter usw.

## Rechtekonzept
Die Zugriffskontrolle auf die verschiedenen Bereiche und damit auf Daten und Funktionalitäten erfolgt über verschiedene Datenbanknutzer. Jede Schnittstelle hat jeweils einen Datenbanknutzer, der exakt nur die Berechtigungen hat, die für die jeweilige Schnittstelle benötigt werden. Die Berechtigungen sind so gesetzt, dass die Schnittstellennutzer nur Daten innerhalb des Schnittstellenbereichs ändern können. Diese Datenbanknutzer sind für den Austausch mit anderen Modulen gedacht.

Im Kern der Datenbank haben weitere Datenbanknutzer Berechtigungen, die Daten aus den Schnittstellen zu lesen, zu archivieren und den Schnittstellen bereitzustellen. Diese Datenbanknutzer sowie vor allem der Administrator-Nutzer sollten nur den für die Datenbank verantwortlichen Personen zugänglich sein.

| DB-Nutzer                 | Bereich                  | Lesen (Select) | Schreiben (Insert) | Ändern (Update) | Löschen (Delete) |
|---------------------------|--------------------------|----------------|--------------------|-----------------|------------------|
| cds2db_user               | cds2db_in                |                | x                  |                 |                  |
| cds2db_user               | cds2db_out               | x              |                    |                 |                  |
| db2dataprocessor_user     | db2dataprocessor_in      |                | x                  |                 |                  |
| db2dataprocessor_user     | db2dataprocessor_out     | x              |                    |                 |                  |
| db2frontend_user          | db2frontend_in           |                | x                  |                 |                  |
| db2frontend_user          | db2frontend_out          | x              |                    |                 |                  |
| db_log_user               | cds2db_in                | x              |                    |                 |                  |
| db_log_user               | db2dataprocessor_in      | x              |                    |                 |                  |
| db_log_user               | db2frontend_in           | x              |                    |                 |                  |
| db (Kern)                 | db_log                   | x              | x                  | x               |                  |
| db (Kern)                 | cds2db_in                | x              |                    | x               | x                |
| db (Kern)                 | db2dataprocessor_in      | x              |                    | x               | x                |
| db (Kern)                 | db2frontend_in           | x              |                    | x               | x                |
| Admin                     | * alle                   | x              | x                  | x               | x                |

## Datenfluss
- Verschiedene Datenquellen: FHIR, Studien, Organisatorische
- Neben dem importierten "inhaltlichen" Primärschlüssel wird in der Datenbank immer ein technischer, datenbankinterner Primärschlüssel vergeben und beim ETL innerhalb der Datenbank miteinander referenziert (z.B. FHIR -> relationale Tabellen 1:n-Beziehungen).
- Prinzipielle Übertragung mit Copy-Funktionen
- Normaler "gedachter" Datenfluss

## Erzeugung der Datenbank
Zur Erzeugung der Strukturen und Funktionalität der Datenbank werden beim Initialisieren verschiedene Skripte in Reihenfolge ausgeführt. Diese Skripte initialisieren die Datenbank zum aktuellen Entwicklungsstand und können zukünftigen Änderungen unterliegen. Der genaue Inhalt ist im jeweiligen SQL-Skript nachzulesen. Teilweise werden diese Skripte mithilfe von Templates und Konfigurationsdateien erzeugt, um die Änderungen während der Entwicklung bei den jeweiligen FHIR- bzw. Frontend-Strukturen abbilden zu können.

### 01_main_user_schema_sequence
Initialisierung aller Schemata, Nutzer und Sequenzen. Passwörter für die verschiedenen Datenbanknutzer der Bereiche (Module / Schnittstellen) sind hier zu setzen.

### 02_db_config_tools
Allgemeines Skript zur Anlage von Hilfsansichten oder Hilfs-Jobs, z.B. eine Übersicht der Cron-Jobs oder der Bereinigung von Cron-Job-Berichten.

### 10_cre_table_raw_cds2db_in
Erstellen der Strukturen für die FHIR-Daten (Rohdaten) im Importschema cds2db_in. Dabei werden eindeutige Primärschlüssel vergeben sowie die Berechtigungen für die zugehörigen Datenbankbenutzer gesetzt.

### 12_cre_table_raw_db_log
Erstellen der Strukturen für die FHIR-Daten (Rohdaten) im Kern (db_log) sowie Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.
