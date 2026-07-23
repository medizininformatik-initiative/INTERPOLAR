# Datenbank-Snapshots

Das Script `ip-snapshot.sh` erstellt, pseudonymisiert, aktiviert, deaktiviert,
löscht und listet Datenbank-Snapshots. Snapshot-Dateien liegen als `.sql.gz`
im Verzeichnis `Snapshots`.

## Voraussetzungen

- Alle Befehle müssen im Hauptverzeichnis von INTERPOLAR ausgeführt werden.
- Der Docker-Compose-Service `cds_hub` muss laufen.
- Snapshot-Namen dürfen nur Buchstaben, Zahlen und Unterstriche enthalten.
  Pfadangaben sind nicht erlaubt.
- Für die Snapshot-Erstellung muss die Datenbank `cds_hub_db` verfügbar sein.
- Für die nachträgliche Pseudonymisierung muss der normale Snapshot bereits
  unter `Snapshots/<name>_<Datum>.sql.gz` vorhanden sein.
- Das R-Image muss den aktuellen Code enthalten. Nach Änderungen am R-Code muss
  es neu gebaut werden:

```bash
docker compose build r-env
```

Für die Pseudonymisierung gelten zusätzlich folgende Voraussetzungen:

- `INPUT_REPO_PATH` muss in
  `R-dataprocessor/dataprocessor_config.toml` korrekt konfiguriert und für den
  Container erreichbar sein.
- Das Template `pseudo_mapping.xlsx` aus dem Projekt-Hauptverzeichnis muss als
  befüllte Datei `pseudo_mapping.xlsx` im konfigurierten `INPUT_REPO_PATH`
  liegen. Für den aktuellen Regelsatz muss insbesondere das Sheet
  `frontend_users` die Spalten `KEY` und `PSEUDONYM` enthalten. `KEY` enthält
  die ursprünglichen Frontend-Benutzernamen, `PSEUDONYM` die gewünschten
  Ersatzwerte.
- Die LOINC-Mapping-Datei muss unter
  `LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx`
  innerhalb des `INPUT_REPO_PATH` verfügbar sein.
- Für den normalen Dump sowie die temporäre Source- und Ziel-Datenbank muss
  ausreichend Speicherplatz vorhanden sein.

Vor dem Einspielen eines Dumps prüft das Script automatisch die
Pseudonymisierungsregeln und die statisch prüfbaren Mapping-Voraussetzungen.

## Befehle

### Normalen Snapshot erstellen

```bash
./ip-snapshot.sh create snap01
```

Der Befehl erstellt einen Dump von `cds_hub_db` unter
`Snapshots/snap01_<Datum>.sql.gz`.

### Normalen und pseudonymisierten Snapshot zusammen erstellen

```bash
./ip-snapshot.sh create snap01 --with-pseudonymized
```

Zuerst wird der normale Snapshot erstellt. Anschließend wird daraus der
pseudonymisierte Snapshot `Snapshots/snap01_<Datum>_pseud.sql.gz` erzeugt.

### Vorhandenen Snapshot pseudonymisieren

Der Name wird ohne Dateiendung angegeben:

```bash
./ip-snapshot.sh pseudonymize snap01_20251002
```

Aus `Snapshots/snap01_20251002.sql.gz` entsteht
`Snapshots/snap01_20251002_pseud.sql.gz`.

### Chunkgröße anpassen

Standardmäßig verarbeitet die Pseudonymisierung 25.000 Tabellenzeilen pro
Chunk. Kleinere Werte reduzieren den maximalen R-Speicherbedarf, können den
Lauf aber verlängern.

```bash
./ip-snapshot.sh pseudonymize snap01_20251002 --chunk-size 10000
./ip-snapshot.sh create snap01 --with-pseudonymized --chunk-size 10000
```

### Snapshots anzeigen

```bash
./ip-snapshot.sh list
```

Der Befehl zeigt vorhandene Snapshot-Dateien und aktivierte
Snapshot-Datenbanken an.

### Snapshot aktivieren

```bash
./ip-snapshot.sh activate snap01_20251002
```

Die Datenbank erhält den Namen `ip_snap01_20251002` und wird nach dem Einspielen
in den Read-only-Modus versetzt. Pseudonymisierte Snapshots werden genauso
aktiviert:

```bash
./ip-snapshot.sh activate snap01_20251002_pseud
```

### Snapshot deaktivieren

```bash
./ip-snapshot.sh deactivate snap01_20251002
```

Der Befehl löscht nur die aktivierte Datenbank. Die Snapshot-Datei bleibt
erhalten. Vor dem erneuten Aktivieren muss eine bereits vorhandene
Snapshot-Datenbank deaktiviert werden:

```bash
./ip-snapshot.sh deactivate snap01_20251002_pseud
./ip-snapshot.sh activate snap01_20251002_pseud
```

### Snapshot löschen

```bash
./ip-snapshot.sh delete snap01_20251002
```

Der Befehl löscht die Snapshot-Datei und eine gegebenenfalls vorhandene,
gleichnamige Snapshot-Datenbank.

## Vorprüfung und Verhalten bei Fehlern

Vor jeder Pseudonymisierung prüft das Script:

- TODO-Regeln,
- nicht unterstützte Regeln,
- doppelte Spaltendefinitionen,
- die konfigurierte `INPUT_REPO_PATH`,
- die Datei `pseudo_mapping.xlsx`,
- benötigte Sheets und Pflichtspalten,
- leere Mappingwerte und
- doppelte `KEY`-Werte.

Beim separaten Pseudonymisieren erfolgt diese Prüfung vor dem Einspielen des
Snapshot-Dumps. Bei `create --with-pseudonymized` wird zuerst der normale
Snapshot erstellt; die Vorprüfung erfolgt anschließend vor dem Einspielen für
die Pseudonymisierung.

Schlägt die Vorprüfung fehl, werden keine Build-Datenbanken angelegt. Die
Fehlermeldung beschreibt die notwendige Korrektur. Alle Details stehen unter:

```text
outputLocal/snapshot_pseudonymization_preflight*/reports/pseudonymization_rule_review.xlsx
```

Fehlende Mapping-Keys aus den tatsächlichen Snapshot-Daten können erst während
der Tabellenverarbeitung erkannt werden.

Schlägt die Verarbeitung nach dem Einspielen fehl, bleiben die temporäre
Source-Datenbank und die teilweise erzeugte Ziel-Datenbank zur Diagnose
erhalten. Die ursprüngliche Snapshot-Datei wird nicht gelöscht. Vor einem neuen
Lauf müssen die Build-Datenbanken geprüft und manuell entfernt werden. Nach
einem erfolgreichen Lauf löscht das Script beide Build-Datenbanken automatisch.

Ein abgebrochener Lauf wird vollständig neu gestartet. Ein Wiederaufsetzen ab
dem letzten Chunk ist derzeit nicht vorgesehen. Existiert die pseudonymisierte
Snapshot-Datei bereits, fragt das Script vor dem Überschreiben nach.

## Technische Details

### Inhalt des pseudonymisierten Snapshots

Der pseudonymisierte Snapshot enthält die für Auswertungen relevanten Schemata
`db_log` und `db2dataprocessor_out`. In `db_log` liegen die pseudonymisierten
Tabellen materialisiert. `db2dataprocessor_out` enthält durchgereichte Views wie
`v_<table>` und `v_<table>_last_version`.

Aufgenommen werden Tabellen, die über die Pseudonymisierungsquellen oder Table
Descriptions für den Snapshot ausgewählt sind. Innerhalb dieser Tabellen
bleiben alle Spalten der Originaltabellen erhalten. Spalten ohne Regel werden
unverändert übernommen. Technische Originalspalten wie `hash_index_col`,
RAW-Referenzen und Einfügezeitpunkte werden nicht entfernt. Zeilen werden nicht
mit `unique()` zusammengefasst.

### Verarbeitung großer Tabellen

Die Tabellen werden nacheinander verarbeitet. Innerhalb einer Tabelle wird
jeder Chunk angereichert, pseudonymisiert und unmittelbar in die Zieldatenbank
geschrieben. Erst danach wird der nächste Chunk gelesen. Der R-Speicherbedarf
hängt dadurch von der Chunkgröße und nicht von der Gesamtgröße einer Tabelle
oder des Snapshots ab.

Kontrollsummen und Enrichment-Reports werden über alle Chunks hinweg
zusammengeführt.

### Pseudonymisierungsregeln

Die Regeln stammen aus den Table-Description-Dateien und den
Snapshot-Erweiterungen. `cryptoHash` und `pseudonymize(...)` werden bei der
DB-Pseudonymisierung als deterministischer SHA-256-Hash ohne Salt umgesetzt.
Der gleiche Originalwert ergibt immer den gleichen Hash.

`pseudonymize(...)` dient in der Table Description als fachlich lesbare
Regelnotation. Ein `domain = ...`-Parameter verändert den erzeugten Hash nicht.
Bei FHIR-Referenzen wie `Encounter/<id>` bleibt der Prefix erhalten; nur der
ID-Anteil hinter dem Schrägstrich wird gehasht.

Mapping-Regeln der Form `pseudonym(sheet = "Sheetname")` lesen das angegebene
Sheet aus `pseudo_mapping.xlsx`. Jedes verwendete Sheet benötigt die Spalten
`KEY` und `PSEUDONYM`. Beide Werte dürfen Leerzeichen enthalten, aber nicht leer
sein. Doppelte Keys sind nicht erlaubt.

### Fachliche Anreicherungen

Vor der Pseudonymisierung ergänzt der Prozess Snapshot-spezifische
Auswertungsspalten:

- `fall_fe` und `fall_fe_last_version` erhalten `fall_age_at_admission`.
- `encounter` und `encounter_last_version` erhalten
  `enc_age_at_admission`.
- `fall_bmi` wird befüllt, wenn Gewicht und Größe in unterstützten Einheiten
  vorliegen. Unterstützt werden `kg`, `g`, `mg`, `m`, `cm` und `mm`.
- `observation` und `observation_last_version` erhalten
  `primary_loinc_code`, `reference_unit` und `value_in_reference_unit` aus der
  LOINC-Mapping-Datei. Nicht gemappte oder Nicht-LOINC-Zeilen bleiben erhalten
  und erhalten in den Zusatzspalten leere Werte.
- `medicationrequest`, `medicationadministration` und `medicationstatement`
  erhalten die Code-/System-Paare der direkt referenzierten `Medication`.
  Mehrere unterschiedliche Paare erzeugen entsprechend mehrere Ausgabezeilen.
  Referenzen ohne gefundenes Paar bleiben erhalten und erscheinen im
  Enrichment-Review.

Das Alter wird in abgeschlossenen Jahren berechnet. Neu ergänzte Altersspalten
stehen am Ende der Tabelle. Die bereits vorhandene Spalte `fall_bmi` wird nicht
verschoben.

### Reports

Der Pseudonymisierungslauf schreibt Kontroll- und Freigabereports unter:

```text
outputLocal/snapshot_pseudonymization*/reports
```

Die Reports werden nicht in den Snapshot-Dump aufgenommen und sind kein
Bestandteil der auswertbaren Read-only-Datenbank:

- `pseudonymization_rule_review.xlsx` enthält die geladenen Regeln, TODOs,
  implizite Keep-Regeln, nicht unterstützte Regeln, doppelte Spalten und
  Mapping-Regeln.
- `snapshot_enrichment_review.xlsx` fasst Medication-Referenzen ohne gefundenes
  Code-/System-Paar zusammen. Der Report enthält exakte Summen und höchstens
  1.000 Beispiele.
- `snapshot_postprocessing_report.xlsx` enthält die technische Zusammenfassung,
  insbesondere Zeilen- und Spaltenzahlen.

Eine kompakte CLI-Hilfe liefert:

```bash
./ip-snapshot.sh
```
