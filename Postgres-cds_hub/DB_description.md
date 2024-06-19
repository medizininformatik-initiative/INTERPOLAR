# Datenbankbeschreibung CDS-HUB DB (cds_hub_db)

## Überblick
Die CDS-HUB DB dient dazu, die importierten FHIR-Daten sowie die erhobenen Studiendaten des Zentrums für spätere Auswertungen persistent zu speichern. Die Datenbank enthält für verschiedene Aufgaben und Zugriffsrollen mehrere Bereiche. Sie enthält nur rudimentäre Logik, die ausschließlich der dauerhaften Speicherung der Daten (Logging) sowie der Bereitstellung der aktuellen Daten an den Schnittstellen dient.

![CDS tool chain](https://github.com/medizininformatik-initiative/INTERPOLAR/assets/11329281/452b133c-0f43-40a3-b46d-e921f5825cbc)

## Arten der Daten
In der CDS-HUB DB werden veschiedene Arten von Daten gespeichert. Diese unterscheiden sich zum einem entweder im Verwendungszweck oder dem Verarbeitungsstatus.
Als Verwendungszweck gibt es alle Daten die mit FHIR (also der Datenquelle), der Studiendokumentation (also Daten zum Anzeigen/Bearbeiten), organisatorischer Natur sind (Parameter, Konfigurationen usw.) oder eine Logging davon sind (Siehe auch Bereiche /Schnittstellen).
Beim Verarbeitungsstaus kann im besonderen bei dn FHIR Daten von den orginalen importierten Daten (Endung "_raw") und den dann daraus generierten Daten in relationaler Form unterscheiden werden. Dabei ist eine Referenzierung und Rückferfolgung mit Schlüsseln durch die Datenbank gegeben (siehe Beschreibung [Datenfluss](https//)).

## Bereiche / Schnittstellen
Man kann die verschiedenen Bereiche (Schemata) in Schnittstellenschemata und funktionale Schemata unterscheiden. Die Schnittstellenschemata dienen dem sicheren Austausch von Daten mit den jeweiligen "externen" Modulen und dem damit verbundenen Rollen- und Rechtekonzept. Deshalb sind Daten in diesen Schemata nur temporä enthalten und werden von der Datenbank von dort "weg" kopiert, bzw. neu zur Verfügung gestellt.
Funktionale Schemata dienen der inhaltlichen Gliederung der Daten innerhalb der Datenbank. Im Folgenden werden die verschiedenen Bereiche der CDS-HUB DB vorgestellt.

### cds2db_in / cds2db_out
Schnittstellen-Schema zum Importieren von FHIR-Daten (_in) sowie zur Umwandlung dieser Daten in typisierte relationale Datenbanktabellen. Die Umsetzung erfolgt in dieser Referenzimplementierung im Modul CDS2DB mithilfe von R-Skripten ([R-cds2db](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/release/R-cds2db/cds2db/R)). Die in diesem Schema angelegten Tabellen entsprechen den Strukturen der FHIR-Ressourcen.

### db2dataprocessor_in / db2dataprocessor_out
Schnittstellen-Schema, um zum einen Daten aus dem Kern dem Modul DataProcessor (_out) zur Verfügung zu stellen, und zum anderen berechnete Daten von diesem entgegenzunehmen (_in) und wieder im Kern dauerhaft zu speichern. Sämtliche inhaltliche Logik und Berechnungen finden im Modul DataProcessor statt und können z.B. über R-Skripte implementiert werden ([R-dataprocessor](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/release/R-dataprocessor/dataprocessor/R)). Die in diesem Schema angelegten Tabellen entsprechen den Strukturen der FHIR-Ressourcen (_out) sowie den Strukturen, die fürs Frontend benötigt werden. Weitere Tabellen können für zusätzliche Funktionalitäten erforderlich werden.

### db2frontend_in / db2frontend_out
Schnittstellen-Schema, um Daten aus dem Kern an ein Frontend zu übergeben (_out) bzw. von diesem entgegenzunehmen (_in) und im Kern zu speichern. Die in diesem Schema angelegten Tabellen entsprechen den Strukturen des Frontends.

### Kern
Im Kern der Datenbank werden alle Daten gespeichert sowie verschiedene Cron-Jobs zur Ausführung der Datenbankfunktionalitäten betrieben. Der Kern unterteilt sich in weitere Bereiche, um die Daten thematisch voneinander zu trennen.

#### db
Kern der Datenbank mit individuellen Studienspeziefischen Tabellen. Dies ergeben sich aus der Studienanforderung und können beiuspielsweise Zwischenergebnisse oder Aggregationen sein.

#### db_log
Schema zur Speicherung aller Daten so das diese zu jedem Zeitpunkt nachvollzogen werden können. Logging der Daten und Datenänderungen. Die genauen Tabellenstrukturen ergeben sich generisch aus den Anforderungen der FHIR-Daten, der Struktur des Frontends sowie den jeweiligen Studienvorgaben.

#### db_konfig
Schema zur Speicherung von Hilfstabellen, Hilfs-Views, Tabellen für individuelle Standort-Parameter (zB. Zeitformat, DB-Job-Intervalle etc.).

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
Die CDS-HUB DB ist ein Bestanteil des Datenflusses, deshalb ist der Beschreibung des "normal" vorgesehenen Datenfluss ein ausführliche und übergreifender Beschreibung gewittmet ([Datenfluss](https//)).

Um den Datenfluss zu gewährleisten und rückverfolgbar zu machen, werden zu allen Daten (Tabellen) immer Datenbankinterne technische Primärschlüssel angelegt und gegebenfalls bei der Verarbeitung mit weiter übergeben. Diese technischen Primärschlüssel können redundant zu den in den Daten enthaltenen Primärschlüsseln sein (zb. FHIR-IDs).

## Erzeugung der Datenbank
Zur Erzeugung der Strukturen und Funktionalität der Datenbank werden beim Initialisieren verschiedene Skripte in Reihenfolge ausgeführt. Diese Skripte initialisieren die Datenbank zum aktuellen Entwicklungsstand und können zukünftigen Änderungen unterliegen. Der genaue Inhalt ist im jeweiligen SQL-Skript nachzulesen (siehe [Postgres-cds_hub/init (SQL-Skripte)](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/release/Postgres-cds_hub/init)). Teilweise werden diese Skripte mithilfe von Templates und Konfigurationsdateien erzeugt, um die Änderungen während der Entwicklung bei den jeweiligen FHIR- bzw. Frontend-Strukturen abbilden zu können. Bei der Initaliesierung der Datenbank ist darauf zu achten das alle Skripte Fehlerfrei ausgeführt werden um die Funktionalität zu gewährleisten.

### 01_main_user_schema_sequence
Initialisierung aller Schemata, Nutzer und Sequenzen. Passwörter für die verschiedenen Datenbanknutzer der Bereiche (Module / Schnittstellen) sind hier zu setzen.

### 02_db_config_tools
Allgemeines Skript zur Anlage von Hilfsansichten oder Hilfs-Jobs, z.B. eine Übersicht der Cron-Jobs oder der Bereinigung von Cron-Job-Berichten.

### 10_cre_table_raw_cds2db_in
Erstellen der Strukturen für die FHIR-Daten (Rohdaten) im Importschema cds2db_in. Dabei werden eindeutige Primärschlüssel vergeben sowie die Berechtigungen für die zugehörigen Datenbankbenutzer gesetzt.

### 12_cre_table_raw_db_log
Erstellen der Strukturen zur dauerhaften speicherung für die FHIR-Daten (Rohdaten) im Kern (db_log) sowie Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 14_cre_table_typ_cds2db_in
Erstellen der Strukturen für die FHIR-Daten nach dem diese typiesiert und aufgeschlüsselt wurden (Verwendbare Daten) im Importschema cds2db_in. Dabei werden eindeutige Primärschlüssel vergeben, die technischen Primärschlüssel der Raw-Daten referenziert sowie die Berechtigungen für die zugehörigen Datenbankbenutzer gesetzt.

### 16_cre_table_typ_log
Erstellen der Strukturen für die FHIR-Daten nach dem diese typiesiert und aufgeschlüsselt wurden (Verwendbare Daten). Um diese dauerhaft im Kern (db_log) zu specihern. Enthält auch die Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 18_cre_view_typ_raw_type_diff_log
Erstellt Views im Schnittstellenschema cds2db_out um alle Datensätze zu listen, welche bereits als Raw-Daten im Kern dauerhaft gespeichert wurden, jedoch noch nicht typiesiert und aufgeschlüsselt sind (Erkennung über tecnische Datenbankinterne Primrschlüssel). Enthält auch die Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 19_cre_view_typ_dataproc_all
Erstellt Views im Schnittstellenschema db2dataprocessor_out um alle verwendbaren (getypt, aufgeschlüsselt) FHIR-Daten dem Modul Dataprocessor zur Verfügung zu stellen. Enthält auch die Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 30_cds_in_to_db_log
Erstellt die Überführungsfunktion (db.copy_raw_cds_in_to_db_log) für die FHIR-Daten vom Schnittstellenschema cds2db_in in den Kern (db_log) für die Raw-Daten. Nach anlegen der Funktion wird ebenfalls der Cron-Job angelegt und gestartet, der die Funktion regelmäßig ausführt.

### 31_cds_in_to_db_log
Erstellt die Überführungsfunktion (db.copy_type_cds_in_to_db_log) für die FHIR-Daten vom Schnittstellenschema cds2db_in in den Kern (db_log) für die getypten und aufgeschlüsselten Daten. Nach anlegen der Funktion wird ebenfalls der Cron-Job angelegt und gestartet, der die Funktion regelmäßig ausführt.

### 40_cre_table_typ_dataproc_in
Erstellen der Strukturen für die durch den Dataprocessor erstellten Daten für das Frontend im Schnittstellenschema db2dataprocessor_in. Dabei werden eindeutige Primärschlüssel vergeben, die technischen Primärschlüssel der FHIR-Daten referenziert sowie die Berechtigungen für die zugehörigen Datenbankbenutzer gesetzt.

### 42_cre_table_frontent_log
Erstellen der Strukturen für die durch den Dataprocessor erstellten Daten für das Frontend zum dauerhaften Speichern im Schema db_log. Enthält auch die Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 44_cre_table_frontent_in
Erstellen der Strukturen im Schnittstellenschema db2frontend_in um Daten vom Modul Frontend (wieder) entgegen zu nehmen. Enthält auch die Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 52_cre_view_fe_out
Erstellt Views im Schnittstellenschema db2frontend_out um aktuelle Daten aus dem Kern dem Frontend zur Übergabe bereit zu stellen. Enthält auch die Vergabe der benötigten Berechtigungen für die zugehörigen Datenbanknutzer.

### 60_dp_in_to_db_log
Erstellt die Überführungsfunktion (db.copy_fe_dp_in_to_db_log) für die Studiendaten (Frontend) vom Schnittstellenschema db2dataprocessor_in in den Kern (db_log) zur dauerhaften speicherung. Nach anlegen der Funktion wird ebenfalls der Cron-Job angelegt und gestartet, der die Funktion regelmäßig ausführt.

### 62_fe_in_to_db_log
Erstellt die Überführungsfunktion (db.copy_fe_fe_in_to_db_log) für die Studiendaten (Frontend) vom Schnittstellenschema db2frontend_in in den Kern (db_log) zur dauerhaften speicherung. Nach anlegen der Funktion wird ebenfalls der Cron-Job angelegt und gestartet, der die Funktion regelmäßig ausführt.



