# DataProcessor – Datenverarbeitung, Auswertungen und Exporte

Generell ist das Modul "dataprocessor" dazu gedacht, Daten zu transformieren und für eine Ausgabe im Frontend oder für eine Ausleitung zur Verfügung zu stellen.

Das Modul nutzt die im [Modul "cds2db"](../R-cds2db) typisierten Daten aus der Postgres-Datenbank, um Tabellen mit relevanten Patienten und Fallinformationen zu erstellen. Diese werden auch zurück in die Postgres-Datenbank geschrieben und anschließend über das [Modul "db2frontend"](../R-db2frontend) dem Frontend zur Verfügung gestellt.

## Submodule auf einen Blick

Das R-Paket [dataprocessor](dataprocessor/README.md) initialisiert Konfiguration,
Datenbankverbindung und Laufprotokoll und lädt die Submodule. Die fachliche
Verarbeitung liegt in den jeweiligen Submodulen. Diese Übersicht ist der Einstieg
für den Betrieb; die Paket-README beschreibt die Implementierung und Erweiterung.

| Submodul | Zweck und Ergebnis | Ausführungsart |
| --- | --- | --- |
| [01_Study_1a](submodules/01_Study_1a/README.md) | Patienten- und Falldaten für das Frontend im CDS_HUB bereitstellen. | Regulärer Lauf |
| [02_MRP_Calculation](submodules/02_MRP_Calculation/README.md) | Retrospektive MRP-Berechnung und Speicherung für das Frontend. | Regulärer Lauf, abhängig von der Studienphase |
| [Database_Quality_Analysis](submodules/manual_start/Database_Quality_Analysis/README.md) | Datenverfügbarkeit und Werteverteilungen als Excel- und CSV-Berichte prüfen. | Manuell: `database-quality-analysis` |
| [MRP_Check](submodules/manual_start/MRP_Check/README.md) | MRPs für einen historischen Zeitraum unabhängig von der Studienphase als Excel-Dateien auswerten. | Manuell: `mrp-check` |
| [Statistical_Reports](submodules/manual_start/Statistical_Reports/README.md) | Aggregierte Kennzahlen zu Fällen, Medikationsanalysen und MRPs als HTML-Bericht erzeugen. | Manuell: `statistical-reports` |
| [WP8_export](submodules/manual_start/WP8_export/README.md) | Fallvignetten für die WP8-Prozessevaluation als CSV und XLSX exportieren. | Manuell: `wp8-export` |

[00_Submodules_Shared_Functions](submodules/00_Submodules_Shared_Functions/README.md)
enthält gemeinsame Funktionen zur Studienphasenzuordnung. Es wird mitgeladen,
hat aber keinen eigenen Startschritt und erzeugt selbst keine Auswertung.

## Voraussetzungen

Die [Installation](../Install.md) und Initialisierung der Toolchain müssen abgeschlossen
sein. Die Datenbank muss erreichbar sein und die für das jeweilige Submodul benötigten
FHIR- und Frontend-Daten enthalten. Im regulären Ablauf werden zuerst CDS2DB und die
Übernahme vorhandener Frontend-Daten ausgeführt; die vollständige Reihenfolge steht in
[INTERPOLAR – Verwendung](../README.md#verwendung).

Manuelle Projekte arbeiten auf einer ausdrücklich ausgewählten Datenbank; deren Einrichtung
ist [unten beschrieben](#datenbank-für-manuelle-projekte). Benötigte Quelldaten,
zusätzliche Regeldateien und Ausgabeorte stehen in der jeweiligen Submodul-README.

## Konfiguration

Die lokale `dataprocessor_config.toml` steuert den DataProcessor. Die kommentierte
[Beispielkonfiguration](dataprocessor_config_example.toml) erklärt insbesondere
Standort (`SITE_CODE`), Stations- und Studienphasen (`PHASES_WARD_*`),
FHIR-Identifier, Observation-Codes, WP7-Regelpfad (`INPUT_REPO_PATH`) und
Datenbankkonfiguration (`PATH_TO_DB_CONFIG_TOML`).

### Datenbank für manuelle Projekte

Jedes manuell gestartete Projekt unter `submodules/manual_start` benötigt dabei
eine eigene `database.toml` in seinem Projektordner. Für neue Projekte
gibt es eine gemeinsame [Vorlage](submodules/manual_start/database_example.toml).
Der darin absichtlich leere `DB_NAME` muss vor dem Start ausdrücklich gesetzt werden. Alle übrigen Verbindungswerte werden aus der über
`PATH_TO_DB_CONFIG_TOML` referenzierten normalen Datenbankkonfiguration
übernommen. Ein nicht leerer Wert in der Projektdatei überschreibt den
zentralen Wert; fehlende oder leere optionale Werte ändern ihn nicht.

Der Ordner der manuellen Projekte wird read-only in den R-Container
eingebunden. Änderungen an `database.toml` erfordern deshalb keinen Neubau des
R-Images.

Die Datenbank wird vor Lock- und Versionsprüfung ausgewählt. Ohne zusätzliches
Argument starten manuelle Projekte nur auf pseudonymisierten Snapshot-Datenbanken,
die in `v_db_parameter` als `database_content_type = pseudonymized_snapshot`
markiert sind. Ist ein Lauf auf einer anderen kompatiblen Datenbank ausdrücklich
beabsichtigt, muss zusätzlich `--force` übergeben werden. Beispiel:

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R mrp-check --force
```

Bei manuellen Projekten darf die in `v_db_parameter` gespeicherte
Datenbankversion älter als die verwendete INTERPOLAR-Version sein. Der Lauf wird
dann mit einer Warnung fortgesetzt, damit historische Snapshots auswertbar
bleiben. Eine neuere Datenbankversion wird weiterhin abgelehnt. Fehlen einer
Auswertung benötigte Views oder Spalten, meldet die konkrete Datenbankabfrage
die strukturelle Inkompatibilität.

### Anpassung der Codes für Körpergröße, -gewicht und BMI

Im Abschnitt "analyse" in der toml-Datei können die auf dem FHIR-Server verfügbaren Codes und Codesysteme für Körpergröße, -gewicht und BMI eingestellt werden. Es werden nur Observationen gefunden, die genau diese Codes enthalten.

## Ausführung des Moduls

Alle Aufrufe erfolgen aus dem Repository-Stamm. Ohne Submodulargument startet
[StartDataProcessor.R](StartDataProcessor.R) den regulären Ablauf: gemeinsame
Funktionen laden, `01_Study_1a` ausführen, danach `02_MRP_Calculation` ausführen,
sofern dessen Studienphasenbedingungen erfüllt sind.

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R
```

Für ein manuelles Projekt wird genau ein Submodulname angehängt, zum Beispiel:

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R statistical-reports
```

Dabei wird nur das gewählte Projekt gestartet. Funktionen der regulären Submodule
werden für dessen Verwendung mitgeladen, ihre `Start.R`-Skripte aber nicht ausgeführt.
Groß-/Kleinschreibung wird beim Projektnamen ignoriert; Bindestriche können die
Unterstriche des Verzeichnisnamens ersetzen. Weitere Argumente stehen in den
verlinkten Submodul-Anleitungen. `Start.R` wird über den DataProcessor ausgeführt,
damit Konfiguration, Datenbankauswahl und Protokollierung eingerichtet sind.

## Entwicklung

Die [Paket-README](dataprocessor/README.md) beschreibt Verzeichnis- und
Dateikonventionen sowie die Trennung zwischen generischem Loader und fachlichen
Submodulen.

Zurück zur [INTERPOLAR-Modulübersicht](../README.md#module-auf-einen-blick).
