# "dataprocessor" - Analyse und Umwandung von Daten für das Frontend oder eine Ausleitung

Generell ist das Modul "dataprocessor" dazu gedacht, Daten zu transformieren und für eine Ausgabe im Frontend oder für eine Ausleitung zur Verfügung zu stellen.

Seit Version [0.2.x](https://github.com/medizininformatik-initiative/INTERPOLAR/releases) nutzt es die im [Modul "cds2db"](../R-cds2db) typisierten Daten aus der Postgres-Datenbank, um Tabellen mit relevanten Patienten und Fallinformationen zu erstellen. Diese werden auch zurück in die Postgres-Datenbank geschrieben und anschließend über das [Modul "db2frontend"](../R-db2frontend) dem Frontend zur Verfügung gestellt.

## Konfiguration

Der Data Processor kann über die Datei [dataprocessor_config.toml](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-dataprocessor/dataprocessor_config.toml) konfiguriert werden. Alle Parameter sind in der Datei durch Kommentare beschrieben.

### Datenbank für manuelle Projekte

Jedes manuell gestartete Projekt unter `submodules/manual_start` benötigt dabei
eine eigene `database.toml` in seinem Projektordner. Für neue Projekte
liegt unter `submodules/manual_start/database_example.toml` eine gemeinsame
Vorlage. Der darin absichtlich leere `DB_NAME` muss vor dem Start ausdrücklich gesetzt
werden. Alle übrigen Verbindungswerte werden aus der über
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

### Debug-Option: Manueller Zeitstempel

Im Abschnitt "debug" kann manuell einen spezifischen Analyse Zeitstempel gesetzt werden.
Weitere Informationen stehen direkt in diesem Abschnitt in der toml-Datei. 

## Ausführung des Moduls

Das R-Skript [StartDataProcessor.R](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-dataprocessor/StartDataProcessor.R) startet den Data Processor.

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R
```

## Submodule

Submodule werden vom Data Processor anhand von Verzeichnis- und Dateikonventionen
geladen. Das Hauptpaket `dataprocessor` soll konkrete Submodule nicht fachlich
kennen. Ein Submodul-Ordner muss löschbar bleiben, ohne dass die Tests oder der
Start des Hauptpakets dadurch fehlschlagen.

Submodul-spezifische Implementierung und Tests gehören deshalb in das jeweilige
Submodul, üblicherweise in ein eigenes R-Subprojekt unterhalb des
Submodul-Ordners. Tests im Hauptpaket dürfen nur generische Loader- oder
Konventionslogik prüfen und sollen keine konkreten Submodule wie
`Database_Quality_Analysis`, `MRP_Check` oder andere namentlich voraussetzen.
