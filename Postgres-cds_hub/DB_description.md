# Datenbankbeschreibung CDS-HUB DB (cds_hub_db)
## Überblick ##
Die CDS-HUB DB dient der Aufgabe die importierten FHIR Daten sowie die erhoben Studiendaten des Zentrums für spätere Auswertungen persisistent zu speichern. Dabei enthält die DB für verschiedene Aufgaben und verschiedene Zugriffsrollen mehrere Bereiche (siehe ...). 
Die Datenbank selber enthält nur rudimentär Logik welche ausschließlich der persistenten speichern der Daten (Logging) sowie der bereitstellung der aktuellen Daten an den Schnittstellen dient. 

## Bereiche / Schnittstellen ##
Man kann die verschieden Bereiche (Schemata) unterscheiden in Schnittstellenschemata und Funktionele Schemata. Die Schnittstellschemata dienen dem sicheren Austausch von Daten mit den jeweiligen "externen" Modulen mit dem damit verbundene Rollen- und Rechtekonzept. Funkionelle Schemata dienen der inhaltlichen Gliederung der Daten inerhalb der Datenbank. Im Folgenden werden die verschiedenen Bereiche der CDS-HUB DB vorgestellt.

### cds2db_in / cds2db_out ###
Schnittstellen-Schema um FHIR Daten zu importieren (_in) sowie diese so umzuwandeln das diese Daten in typiesierten relationalen Datenbanktabellen vorliegen. Die Umsetzung erfolgt in dieser Referenzimplementierung in dem Modul CDS2DB mit hilfe von R-Skripten (siehe ...)
Die in diesem Schmema angelegten Tabellen entsprechen den Struckturen der FHIR Resourcen.

### cds2dataprocessor_in / cds2dataprocessor_out ###
Schnittstellen-Schema um zum einen Daten aus dem Kern dem Modul DataProcessor (siehe...) zur verfügung zu stellen (_out), bzw. berechnete Daten von diesem entgegen zu nehmen (_in) und wieder im Kern zu persistieren. Sämtliche inhaltliche Logik und Berechnungen finden im Modul Dataprocessor statt und können z.b. über R-Skripte implementiert werden.
Die in diesen Schema angelegten Tabellen entsprechen zum einen den Struckturen der FHIR Resourcen (_out), als auch den Strukturen die fürs Frontend benötigt werden. Für weitere Funktionalitäten sind weitere Tabellen wahrscheinlich.

### cds2frontend_in / cds2frontend_out ###
Schnittstellen-Schema um Daten aus dem Kern an ein Frontend zu übergeben (_out) bzw. von diesem Daten entgegen zu nehmen (_in) und im Kern zu speichern. Die in diesem Schmema angelegten Tabellen entsprechen den Struckturen des Frontends.

### Kern ###
Im Kern der Datenbank werden alle Daten gespeichert sowie verschiedene cron-jobs zum ausführen der Datenbankfuktionalitäten. Im Kern gibt es weitere Bereiche um die Daten thematisch voneinander zu trennen.

#### db ####
Kern der Datenbank mit individuellen Tabellen.

#### db_log ####
Schema um alle Daten zu speichern. 

##### db_konfig #####
Schema um Hilfstabellen, Hielfs-Views, Tabellen für individuelle Parameter usw. zu speichern.

## Rechtekonzept ##
- versch. user
- bereiche
- kein direkter Zugriff Kern / Log

## Datenfluss ##
- verschiedene datenquellen FHIR, Studien , Organisatorische
- prinnzipielle übertragung mit copy-funktionen
- normaler "gedachter" datenfluss

## Erzeugung der Datenbank ##
Zum erzeugen der Strukturen und Funktionalität der Datenbank werden beim initialiesieren verschiedene Skripte in Reihenfolge ausgeführt. Diese Skripte initialiesieren die Datenbank zum aktuellen Entwicklungsstand und können zukünftigen Änderungen unterliegen.

### 01_main_user_schema_sequence ###
Initialiesierung aller Schmeatas, Nutzer und Sequenzen. Passwörter für die verschiedenen Datenbanknutzer der Bereiche (Module / Schnittstellen) sind hier zu setzen.

### 02_db_config_tools ###
Allegemeines Skript um Hilfs-Ansichten oder Hilfs-Jobs anzulegen. Z.B. eine Übersicht der Cron-Jobs oder der Bereinigung von Cron-Job Berichten.

### 10_cre_table_raw_cds2db_in ###
Erstellen der Strukturen für die FHIR Daten (Rohdaten) im Importschema cds2db_in. Dabei wirden eindeutiger Primärschlüssel vergeben sowie die Berechtigungen für die zugehörigen Datenbankbenutzer.

### 12_cre_table_raw_db_log ###
Erstellen der Strukturen für die FHIR Daten (Rohdaten) im Kern (db_log). Sowie vergabe der benötigten Berechtigungen für zugehörige Datenbanknutzer.

