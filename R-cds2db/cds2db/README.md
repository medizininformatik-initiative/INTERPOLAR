# cds2db - R Implementierung zur Ausleitung Kerndatensatz-konformer Daten (KDS) in eine Datenbank

Dieses Implementierung setzt die Ausleitung KDS-konformer Daten von einem FHIR-Server in eine Postgres Datenbank um.

## Ablauf

Beschreibung des Ablaufes der ETL-Strecke von FHIR zur Datenbank

### Extrahieren der relevanten Patientenliste

Wenn der Parameter 'PATH_TO_PID_LIST_FILE' nicht gesetzt ist, werden die relevanten Patienten-IDs aus den vom FHIR-Server heruntergeladenen Encountern extrahiert. Wenn der Parameter aber gesetzt ist, werden die Patienten-IDs aus der angegebenen Datei geladen (eine PID pro Zeile).

### Laden der Table-Description

Es gibt eines Excel Datei  Namens [Table-Description](inst/extdata/Table_Description.xlsx), welche alle relevanten Ressourcen-Items enthält. Hier sind alle Ressourcen (z.B. Encounter, Patient, Observation, Condition, Medication) mit den dazugehörigen FHIR-Items hinterlegt. Diese Datei wird benötigt, um die vom FHIR-Server heruntergeladenen Ressourcen in flache Tabellen mit den relevanten Informationen zu überführen.

### Herunterladen und verflachen der FHIR-Ressourcen

Auf Grundlage der relevanten Patienten werden die FHIR-Ressourcen, unter Verwendung der definierten Table-Description, heruntergeladen. Aus den JSON-Struktur der heruntergeladenen Ressourcen entstehen in einen nächsten Schritt flache Tabellen auf Basis der Table-Description. Für diese Schritte wird das [fhircrackr-Package]('https://cran.r-project.org/web/packages/fhircrackr/index.html') verwendet.

### Schreiben der Ressourcen-Tabellen in die Datenbank

Die flachen Tabellen werden in eine Postgres-Datenbank überführt, dazu wird eine Datenbankverbindung mit den angegebenen Anmeldeinformationen aus der Conifg-Datei erstellt.
