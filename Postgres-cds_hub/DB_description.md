# Datenbankbeschreibung CDS-HUB DB (cds_hub_db)
## Überblick ##
Die CDS-HUB DB dient der Aufgabe die importierten FHIR Daten sowie die erhoben Studiendaten des Zentrums für spätere Auswertungen persisistent zu speichern. Dabei enthält die DB für verschiedene Aufgaben und verschiedene Zugriffsrollen mehrere Bereiche (siehe ...). 
Die Datenbank selber enthält nur rudimentär Logik welche ausschließlich der persistenten speichern der Daten (Logging) sowie der bereitstellung der aktuellen Daten an den Schnittstellen dient. 

## Bereiche / Schnittstellen ##
Man kann die verschieden Bereiche (Schemata) unterscheiden in Schnittstellenschemata und Funktionele Schemata. Die Schnittstellschemata dienen dem sicheren Austausch von Daten mit den jeweiligen "externen" Modulen mit dem damit verbundene Rollen- und Rechtekonzept. Funkionelle Schemata dienen der inhaltlichen Gliederung der Daten inerhalb der Datenbank. Im Folgenden werden die verschiedenen Bereiche der CDS-HUB DB vorgestellt.

### cds2db_in / cds2db_out ###
Schnittstellen-Schema um FHIR Daten zu importieren (_in) sowie diese so umzuwandeln das diese Daten in typiesierten relationalen Datenbanktabellen vorliegen. Die Umsetzung erfolgt in dieser Referenzimplementierung in dem Modul CDS2DB mit hilfe von R-Skripten (siehe ...)

### cds2dataprocessor_in / cds2dataprocessor_out ###
Schnittstellen-Schema um zum einen Daten aus dem Kern dem Modul DataProcessor (siehe...) zur verfügung zu stellen (_out), bzw. berechnete Daten von diesem entgegen zu nehmen (_in) und wieder im Kern zu persistieren. Sämtliche inhaltliche Logik und Berechnungen finden im Modul Dataprocessor statt und können z.b. über R-Skripte implementiert werden.

### cds2frontend_in / cds2frontend_out ###
Schnittstellen-Schema um Daten aus dem Kern an ein Frontend zu übergeben (out) bzw. von diesem Daten entgegen zu nehmen (_in) und im Kern zu speichern.

...dem Modul DataProcessor (siehe...) zur verfügung zu stellen, bzw. berechnete Daten von diesem entgegen zu nehmen (_in) und wieder im Kern zu persistieren. Sämtliche inhaltliche Logik und Berechnungen finden im Modul Dataprocessor statt und können z.b. über R-Skripte implementiert werden.

## Rechtekonzept ##
- versch. user
- bereiche

## Datenfluss ##
- verschiedene datenquellen FHIR, Studien , Organisatorische
- prinnzipielle übertragung mit copy-funktionen
- normaler "gedachter" datenfluss
