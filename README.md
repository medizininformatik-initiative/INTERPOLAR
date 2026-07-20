# CDS tool chain

Dieses Repository enthält die Bestandteile der CDS tool chain zur Verarbeitung von [`MII KDS FHIR Ressourcen`](https://www.medizininformatik-initiative.de/de/basismodule-des-kerndatensatzes-der-mii). Es handelt sich um eine modular aufgebaute Referenzimplementierung, welche z.B. Datenintegrationszentren (DIZ) der MII eingesetzt werden kann. Hierbei werden FHIR-Ressourcen vom KDS (Kerndatensatz) FHIR Server / Endpunkt heruntergeladen, in eine Tabellenstruktur überführt  ([CDS2DB](#cds2db)) und in eine Posgres-Datenbank (CDS_HUB) geschrieben. In einen nächsten Schritt werden die Daten geprüft, harmonisiert und können mit Hilfe von Algorithmen weiter verarbeitet werden (DataProcessor). Anschließend werden die Daten über ein Frontend (z.B. Redcap) auf einer Benutzeroberfläche sichtbar gemacht (DB2Frontend, Frontend).

![CDS tool chain](./doc/CDS_Tool_Chain_architecture.png?raw=true)
Der detaillierte Datenfluss zwischen den und innerhalb der Module ist in der Datei [Dataflow](Dataflow) beschrieben.

Der gesamte Ablauf der CDS Toolchain ist in der Datei [full_toolchain_description](full_toolchain_description) beschrieben.

Hinweise fuer Entwicklung und Beitraege stehen in [CONTRIBUTING.md](CONTRIBUTING.md).

## Bestandteile der CDS tool chain

Hier werden alle verwendeten Bestandteile bzw. CDS-Module aufgelistet. Detaillierte Beschreibungen sind in den jeweiligen Ordnern zu finden. Ein Modul ist eine eigenständige Softwarekomponente mit klar definierten Funktionalitäten. Die Module kommunizieren über Schnittstellen miteinander und sind austauschbar.

### FHIR Server / Endpunkt

Hierbei handelt es sich um die vom Datenintegrationszentrum zur Verfügung gestellten FHIR Server. Zu Testzwecken ist es zudem möglich, andere FHIR Server mit KDS-konformen FHIR Ressourcen zu konfigurieren, z.B. die der MII Testinfrastruktur ([kerndatensatz-testdaten](https://github.com/medizininformatik-initiative/kerndatensatz-testdaten)).

### CDS2DB

Dieses R-Modul dient zur Ausleitung Kerndatensatz-konformer Daten in eine Postgres-Datenbank.

Der Quellcode (R) dafür befindet sich im Ordner [R-cds2db](./R-cds2db).

Eine Beschreibung zur Konfiguration und Ausführung befindet sich in [R-cds2db](./R-cds2db/).

### CDS_HUB

Beim CDS_HUB handelt es sich um eine relationale Datenbank (Postgres). Im Ordner [Postgres-cds_hub](./Postgres-cds_hub) befinden sich Dateien für die Konfiguration und Initialisierung.

Eine Beschreibung der Datenbankstruktur befindet sich unter [Postgres-cds_hub/DB_description](./Postgres-cds_hub/DB_description). \
Eine Beschreibung, wie der Zugriff erfolgt befindet sich unter [Postgres-cds_hub](./Postgres-cds_hub) .

### DataProcessor

Der DataProcessor verarbeitet die Daten des CDS_HUB. Diese Verarbeitung kann z.B. eine Filterung von zuvor importierten Daten für die Anzeige im Frontend sein.

Weitere Informationen zum DataProcessor befinden sich im Ordner [R-dataprocessor](./R-dataprocessor).

### Input-Repo

Das Input-Repo wird in zukünftigen Releases für den Zugriff auf Algorithmen zur Berechnung, z.B. von Scores, verwendet.

### DB2Frontend

Dieses R-Modul befindet sich im Ordner [R-db2frontend](./R-db2frontend) und dient der Synchronisation von Daten zwischen CDS_HUB (Postgres-Datenbank) und Frontent (redcap). 

### Frontend (REDCap)

Das Frontend dient der Anzeige von importierten KDS-FHIR Daten und zur Erfassung von Rückmeldungen.
Das Frontend ist eine Web-Anwendung und besteht aus 2 Teilen. 

Die Web-Anwendung (PHP) befindet sich im Verzeichnis [REDCap-app](./REDCap-app). 
Dieses Verzeichnis enthält u.a. Anweisungen zur Erzeugung der Laufzeitumgebung (Dockerfile).

Die REDCap-app benötigt eine Datenbank (mariadb), welche sich im Verzeichnis [REDCap-db](./REDCap-db) befindet. Dort befinden sich zudem Dateien zum Setzen von Passwörtern, Umgebundgvariablen, etc. sowie zur Initialisierung der Datenbank (init/redcap.sql).

### R-etlutils

Dieser Ordner ist eine Sammlung von R Funktionen, die von den R-Modulen (CDS2DB, DataProcessor, DB2Frontend) der CDS tool chain genutzt werden.


## Anforderungen / Voraussetzungen

Aktuell werden Erfahrungen beim Einsatz der CDS tool chain gesammelt. Wir können die Anforderungen an CPU/RAM/Storage daher nur schätzen. Dabei gehen wir vom folgenden Anwendungsfall an einem Standort aus:

 - Laufzeit ca. 2 Jahre
 - 2-6 Stationen
 - 20-24 Betten je Station
 - 5-6 Neuaufnahmen je Tag
 - durchschn. Liegedauer 5 Tage (davon 30 % Kurzlieger)
 
Daraus kommen wir zu folgender Abschätzung der IT-Ressourcen:

 |  | |
 | --- | --- | 
 | CPU | 2-4 Kerne |
 | RAM | 8-16 Gb |
 | Storage | 500 Gb |

Es handelt sich dabei um eine Schätzung. Je nach Datenbestand kann es erforderlich sein, die IT-Ressourcen anzupassen. Nach bisherigen Rückmeldungen kann eine Erhöhung der IT-Ressourcen auf 8 CPU-Kerne und 64 Gb RAM die Verarbeitung ggf. stark beschleunigen.

## Installation

Folgende Anweisungen müssen ausgeführt werden, um die CDS tool chain zu verwenden: [Install](Install)

## Verwendung

Die Ausführung kann manuell durch DIZ Mitarbeitende oder in regelmäßigen Abständen zeitgesteuert (cron) ausgeführt werden, siehe Hinweise unter [Discussions #750](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/750). Der folgende Aufruf führt die CDS Tool Chain komplett aus:
```console
docker compose run --rm --no-deps r-env Rscript R-cdstoolchain/StartCDSToolChain.R
```
**Hinweis:** Um eine sinnvolles Intervall für die zeitgesteuerte Ausführung der CDS Tool Chain zu wählen, sollten die initialen Aufrufe (z.B. die ersten 3 Tage der Verwendung) manuell erfolgen, um die typischen Laufzeiten am Standort zu ermitteln. Der initiale Lauf dauert länger, spätere Läufe entsprechend kürzer, da nur noch Änderungen verarbeitet werden. Es wird empfohlen die CDS Tool Chain in der Projektlaufzeit mehrfach täglich auszuführen, mind. jedoch einmal am Tag. Bei der Wahl des Ausführungsintervals sollte darauf geachtet werden, dass ein typischer Durchlauf innerhalb des Intervalls erfolgen kann. Wird z.B. ermittelt, dass ein Lauf mit den typischen Änderungen bei den Patientendaten auf den INTERPOLAR-Stationen ca. 1h dauert, kann die CDS Tool Chain via cron 2-stündlich laufen.

Um die Teilschritte einzeln auszuführen, können die folgenden Aufrufe in der hier angegebenen typischen Reihenfolge verwendet werden:

 1. [CDS2DB](./R-cds2db) ausführen (Ziffern 1-3 in der Grafik oben), um die Daten vom FHIR-Server herunterzuladen und in CDS_HUB DB zu speichern
    ```console
    docker compose run --rm --no-deps r-env Rscript R-cds2db/StartRetrieval.R
    ```
 1. [DB2Frontend](./R-db2frontend) ausführen (Ziffern 8 und 9 in der Grafik oben), um bereits vorhandene Daten im Frontend in CDS_HUB zu übernehmen
    ```console
    docker compose run --rm --no-deps r-env Rscript R-db2frontend/Start1_Frontend2DB.R
    ```
 1. [DataProcessor](./R-dataprocessor) ausführen (Ziffern 4 und 5 in der Grafik oben), um in CDS_HUB vorhandene Daten zu verarbeiten
    ```console
    docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R
    ```
 1. [DB2Frontend](./R-db2frontend) ausführen (Ziffern 6 und 7 in der Grafik oben), um über CDS2DB und DataProcessor in CDS_HUB hinzugefügte Daten in das Frontend zu übernehmen
    ```console
    docker compose run --rm --no-deps r-env Rscript R-db2frontend/Start2_DB2Frontend.R
    ```

## Datenbank Snapshot

Zur Erstellung, Löschung, Aktivierung, De-Aktivierung, Pseudonymisierung und Auflistung von Snapshots wird das Bash-Script `ip-snapshot.sh` verwendet. Das Script muss direkt im Hauptverzeichnis ausgeführt werden. Snapshot-Dateinamen dürfen keine Pfadangaben enthalten und werden im Verzeichnis `Snapshots` als `.sql.gz` abgelegt.

Beim Erstellen (_create_) wird ein Dump der `cds_hub_db` Datenbank erzeugt und unter `Snapshots/<name>_<Datum>.sql.gz` gespeichert.
```cmd
./ip-snapshot.sh create snap01
```

Zusätzlich kann direkt beim Erstellen ein pseudonymisierter Auswertungs-Snapshot erzeugt werden.
```cmd
./ip-snapshot.sh create snap01 --with-pseudonymized
```

Ein pseudonymisierter Snapshot kann auch nachträglich aus einem vorhandenen Snapshot-Dump erzeugt werden. Der Name wird ohne Dateiendung angegeben. Aus `Snapshots/snap01_20251002.sql.gz` wird dadurch `Snapshots/snap01_20251002_pseud.sql.gz`.
```cmd
./ip-snapshot.sh pseudonymize snap01_20251002
```

Falls die pseudonymisierte Snapshot-Datei bereits existiert, fragt das Script vor dem Überschreiben nach. Für lokale Tests nach Codeänderungen muss vor dem Pseudonymisierungslauf das R-Image neu gebaut werden, da der Lauf das im Container installierte R-Paket verwendet.
```cmd
docker compose build r-env
./ip-snapshot.sh pseudonymize snap01_20251002
```

Der pseudonymisierte Snapshot enthält nur die für Auswertungen relevanten Schemata `db_log` und `db2dataprocessor_out`. In `db_log` liegen die pseudonymisierten Tabellen materialisiert, in `db2dataprocessor_out` liegen durchgereichte Views wie `v_<table>` und `v_<table>_last_version`. Tabellen werden nur aufgenommen, wenn sie über die Pseudonymisierungsquellen bzw. Table Descriptions für den Snapshot ausgewählt sind. Innerhalb dieser Tabellen bleiben alle Spalten der Original-Snapshot-Tabellen erhalten. Spalten ohne Pseudonymisierungsregel werden unverändert übernommen; es werden keine technischen Originalspalten wie `hash_index_col`, RAW-Referenzen oder Einfügezeitpunkte entfernt und es werden keine redundanten Zeilen per `unique()` zusammengefasst.

Die Pseudonymisierungsregeln stammen aus den Table-Description-Dateien und den Snapshot-Erweiterungen. Die Regeln `cryptoHash` und `pseudonymize(...)` werden in der DB-Ausführung beide als deterministischer SHA-256-Hash ohne Salt umgesetzt. Derselbe Originalwert ergibt dadurch immer denselben Hash. `pseudonymize(...)` dient in der Table Description als fachlich lesbare Regelnotation; ein eventueller `domain = ...`-Parameter verändert den erzeugten Hash nicht. Bei FHIR-Referenzen wie `Encounter/<id>` bleibt der Prefix erhalten und nur der ID-Anteil nach dem Slash wird gehasht.

Vor der Pseudonymisierung werden einige Snapshot-spezifische Auswertungsspalten ergänzt. Für `fall_fe` und `fall_fe_last_version` wird `fall_age_at_admission` ergänzt. Für `encounter` und `encounter_last_version` wird `enc_age_at_admission` ergänzt. Neu ergänzte Altersspalten werden an das Ende der jeweiligen Tabelle angehängt. `fall_bmi` wird in `fall_fe` und `fall_fe_last_version` befüllt, sofern Gewicht und Größe mit eindeutig unterstützten Einheiten vorliegen; da diese Spalte bereits im Original-Tabellenlayout existiert, wird sie nicht ans Tabellenende verschoben. Das Alter wird in abgeschlossenen Jahren berechnet. BMI unterstützt Gewicht in `kg`, `g`, `mg` und Größe in `m`, `cm`, `mm`.

Für `observation` und `observation_last_version` werden zusätzlich `primary_loinc_code`, `reference_unit` und `value_in_reference_unit` aus der im Input-Repo konfigurierten Datei `LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx` ergänzt. Voraussetzung ist, dass für die im auswertenden Prozess verwendeten LOINCs ein Eintrag in dieser Mapping-Tabelle existiert; nicht gemappte oder nicht-LOINC Observation-Zeilen bleiben erhalten und erhalten in den zusätzlichen Spalten leere Werte.

Für `medicationrequest`, `medicationadministration` und `medicationstatement` werden zusätzlich die Code-/System-Paare der referenzierten `Medication` materialisiert. Wenn eine referenzierte `Medication` mehrere unterschiedliche Code-/System-Paare hat, wird die referenzierende Zeile entsprechend mehrfach ausgegeben. Referenzen ohne gefundenes Code-/System-Paar bleiben erhalten und werden im Enrichment-Review ausgewiesen.

Der Pseudonymisierungslauf schreibt Kontroll-Reports unter `outputLocal/snapshot_pseudonymization*/reports`. Diese Reports sind Kontroll- und Freigabeartefakte für das DIZ. Sie werden nicht in den Snapshot-Dump aufgenommen und sind nicht Bestandteil der auswertbaren Read-only-DB.

- `pseudonymization_rule_review.xlsx`: Review der geladenen Pseudonymisierungsregeln, TODOs, impliziten Keep-Regeln, nicht unterstützten Regeln, doppelten Spalten und Mapping-Regeln.
- `snapshot_enrichment_review.xlsx`: aktuell Medication-Referenzen, für die bei der Snapshot-Anreicherung kein Code-/System-Paar in der referenzierten `Medication` gefunden wurde.
- `snapshot_postprocessing_report.xlsx`: technische Zusammenfassung nach der Pseudonymisierung, u.a. Zeilen-/Spaltenzahlen; aktuell werden keine Originalspalten und keine Zeilen entfernt.

Erstellte Snapshots können aktiviert (_activate_), d.h. in eine Snapshot-Datenbank geladen werden. Die aktivierte Datenbank erhält den Namen `ip_<snapshot_name>` und wird nach dem Einspielen in den Read-only-Modus gesetzt.
```cmd
./ip-snapshot.sh activate snap01_20251002
```

Pseudonymisierte Snapshots werden gleichartig aktiviert.
```cmd
./ip-snapshot.sh activate snap01_20251002_pseud
```

Falls eine Snapshot-Datenbank mit diesem Namen bereits existiert, muss sie vor dem erneuten Aktivieren deaktiviert werden.
```cmd
./ip-snapshot.sh deactivate snap01_20251002_pseud
./ip-snapshot.sh activate snap01_20251002_pseud
```

Beim Deaktivieren (_deactivate_) wird die aktivierte Snapshot-Datenbank gelöscht. Die Snapshot-Datei bleibt erhalten.
```cmd
./ip-snapshot.sh deactivate snap01_20251002
```

Beim Löschen (_delete_) wird die Snapshot-Datei gelöscht; falls eine gleichnamige Snapshot-Datenbank existiert, wird sie ebenfalls entfernt.
```cmd
./ip-snapshot.sh delete snap01_20251002
```

Erstellte sowie aktivierte Snapshots können mit _list_ angezeigt werden.
```cmd
./ip-snapshot.sh list
```

Eine ausführliche Beschreibung liefert der Aufruf von `./ip-snapshot.sh` ohne Parameter.

## Hilfe und Unterstützung
- [Frequently Asked Questions (FAQ)](https://github.com/medizininformatik-initiative/INTERPOLAR/wiki/Frequently-Asked-Questions-%E2%80%90-FAQ)
- Haben Sie einen Fehler gefunden, legen Sie bitte ein Ticket ([Issues->New issue](https://github.com/medizininformatik-initiative/INTERPOLAR/issues/new/choose)) an.
- Haben Sie Vorschläge zur Verbesserung oder Fragen, erstellen Sie bitte einen Beitrag unter [Discussions](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions).
- Hinweise zum Umgang mit Fehlern und Änderungswünschen sind in [diesem Beitrag](https://github.com/medizininformatik-initiative/INTERPOLAR/discussions/574) zusammengefasst.
