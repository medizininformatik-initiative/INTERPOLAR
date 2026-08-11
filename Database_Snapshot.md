# Snapshot-Dateien und Snapshot-Datenbanken

Das Script `ip-snapshot.sh` erstellt und pseudonymisiert Snapshot-Dateien. Es
aktiviert und deaktiviert die zugehörigen Snapshot-Datenbanken und kann
Snapshot-Dateien sowie Snapshot-Datenbanken löschen. Außerdem zeigt es
vorhandene Snapshot-Dateien und aktivierte Snapshot-Datenbanken an.
Snapshot-Dateien liegen als `.sql.gz` im Verzeichnis `Snapshots`.

## Voraussetzungen

- Alle Befehle müssen im Hauptverzeichnis von INTERPOLAR ausgeführt werden.
- Der Docker-Compose-Service `cds_hub` muss laufen.
- Namen von Snapshot-Dateien und Snapshot-Datenbanken dürfen nur Buchstaben,
  Zahlen und Unterstriche enthalten.
  Pfadangaben sind nicht erlaubt.
- Zum Erstellen einer Snapshot-Datei muss die Datenbank `cds_hub_db` verfügbar
  sein.
- Für die nachträgliche Pseudonymisierung muss die normale Snapshot-Datei
  bereits unter `Snapshots/<name>_<Datum>.sql.gz` vorhanden sein.

Für die Pseudonymisierung gelten zusätzlich folgende Voraussetzungen:

- `INPUT_REPO_PATH` muss in
  `R-dataprocessor/dataprocessor_config.toml` korrekt konfiguriert und für den
  Container erreichbar sein. Das Verzeichnis muss für die automatische
  Aktualisierung von `pseudo_mapping.xlsx` schreibbar sein.
- Die Datei `pseudo_mapping.xlsx` wird bei Bedarf automatisch im konfigurierten
  `INPUT_REPO_PATH` erzeugt und mit den in der temporären Quelldatenbank
  vorkommenden Originalwerten vorausgefüllt. Die gewünschten Pseudonyme müssen
  anschließend manuell in der Spalte `PSEUDONYM` ergänzt werden.
- Die LOINC-Mapping-Datei muss unter
  `LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx`
  innerhalb des `INPUT_REPO_PATH` verfügbar sein.
- Für die normale Snapshot-Datei sowie die temporäre Quell- und Zieldatenbank
  muss ausreichend Speicherplatz vorhanden sein. Nach erfolgreicher
  Pseudonymisierung bleiben die normale und die pseudonymisierte
  Snapshot-Datenbank erhalten.

## Befehle

### Normale Snapshot-Datei erstellen

```bash
./ip-snapshot.sh create snap01
```

Der Befehl erstellt eine Snapshot-Datei aus `cds_hub_db` unter
`Snapshots/snap01_<Datum>.sql.gz`.

### Normale und pseudonymisierte Snapshot-Dateien zusammen erstellen

```bash
./ip-snapshot.sh create snap01 --with-pseudonymized
```

Zuerst wird die normale Snapshot-Datei erstellt. Anschließend wird daraus die
pseudonymisierte Snapshot-Datei `Snapshots/snap01_<Datum>_pseud.sql.gz`
erzeugt. Danach sind in PostgreSQL innerhalb des Docker-Compose-Service
`cds_hub` die schreibgeschützten Snapshot-Datenbanken `ip_snap01_<Datum>` und
`ip_snap01_<Datum>_pseud` verfügbar.

### Vorhandene Snapshot-Datei pseudonymisieren

Der Name wird ohne Dateiendung angegeben:

```bash
./ip-snapshot.sh pseudonymize snap01_20251002
```

Aus `Snapshots/snap01_20251002.sql.gz` entsteht
`Snapshots/snap01_20251002_pseud.sql.gz`. Danach sind in PostgreSQL innerhalb
des Docker-Compose-Service `cds_hub` die schreibgeschützten
Snapshot-Datenbanken `ip_snap01_20251002` und `ip_snap01_20251002_pseud`
verfügbar.

### Chunkgröße anpassen

Standardmäßig verarbeitet die Pseudonymisierung 25.000 Tabellenzeilen pro
Chunk. Kleinere Werte reduzieren den maximalen R-Speicherbedarf, können den
Lauf aber verlängern.

```bash
./ip-snapshot.sh pseudonymize snap01_20251002 --chunk-size 10000
./ip-snapshot.sh create snap01 --with-pseudonymized --chunk-size 10000
```

### Snapshot-Dateien und Snapshot-Datenbanken anzeigen

```bash
./ip-snapshot.sh list
```

Der Befehl zeigt vorhandene Snapshot-Dateien und aktivierte
Snapshot-Datenbanken an.

### Snapshot-Datenbank aktivieren

Dieser Schritt ist nur nötig, wenn die gewünschte Snapshot-Datenbank noch nicht
vorhanden ist. Nach einer erfolgreichen Pseudonymisierung sind die normale und
die pseudonymisierte Snapshot-Datenbank bereits aktiviert.

```bash
./ip-snapshot.sh activate snap01_20251002
```

Die Snapshot-Datenbank erhält den Namen `ip_snap01_20251002` und wird nach dem
Einspielen in den Read-only-Modus versetzt. Pseudonymisierte Snapshot-Dateien
werden genauso als Snapshot-Datenbank aktiviert:

```bash
./ip-snapshot.sh activate snap01_20251002_pseud
```

### Snapshot-Datenbank deaktivieren

```bash
./ip-snapshot.sh deactivate snap01_20251002
```

Der Befehl löscht nur die aktivierte Snapshot-Datenbank. Die Snapshot-Datei
bleibt erhalten.

### Snapshot-Datei und Snapshot-Datenbank löschen

```bash
./ip-snapshot.sh delete snap01_20251002
```

Der Befehl löscht die Snapshot-Datei und eine gegebenenfalls vorhandene,
gleichnamige Snapshot-Datenbank.

## Ablauf bis zur Prüfung

1. Die normale Snapshot-Datei wird in eine temporäre Quelldatenbank eingespielt.
   Das kann bei großen Snapshot-Dateien lange dauern.
2. Das Script ergänzt und prüft `pseudo_mapping.xlsx`. Fehlende Pseudonyme
   müssen vor der Fortsetzung eingetragen werden.
3. Das Script erstellt eine temporäre Zieldatenbank und schreibt die
   pseudonymisierten Daten hinein.
4. Die Zieldatenbank wird als neue Snapshot-Datei mit dem Suffix `_pseud`
   gespeichert.
5. Die normale und die pseudonymisierte Snapshot-Datenbank werden in PostgreSQL
   innerhalb des Docker-Compose-Service `cds_hub` schreibgeschützt unter ihren
   endgültigen Namen bereitgestellt. Ein zusätzliches `activate` ist nicht
   nötig.

## Prüfung vor der Weitergabe

- Die pseudonymisierte Snapshot-Datenbank auf Daten prüfen, die den Standort
  nicht verlassen dürfen.
- Die pseudonymisierte Snapshot-Datei nicht weitergeben, wenn die
  Snapshot-Datenbank solche Daten enthält.
- Solche Funde dem INTERPOLAR-Team melden. Die Pseudonymisierungsregeln werden
  dann gemeinsam geprüft und bei Bedarf angepasst.

## Verhalten bei Fehlern

- Die Fehlermeldung prüfen.
- Ergänzt das Script `pseudo_mapping.xlsx`, die leeren `PSEUDONYM`-Zellen
  ausfüllen und denselben Befehl erneut starten.
- Die normale Snapshot-Datei bleibt bei einem Fehler erhalten.
- Die vollständig eingespielte Quelldatenbank bleibt für den erneuten Lauf
  erhalten.
- Eine unvollständige pseudonymisierte Zieldatenbank wird entfernt.

## Technische Details

### Inhalt der pseudonymisierten Snapshot-Datei und Snapshot-Datenbank

Die pseudonymisierte Snapshot-Datei und die pseudonymisierte Snapshot-Datenbank
enthalten die für Auswertungen relevanten Schemata `db_log` und
`db2dataprocessor_out`. Wenn für eine Quelltabelle eine Last-Version-View
existiert, liegen in `db_log` zwei disjunkte pseudonymisierte Tabellen:
`<table>_old_versions` enthält nur frühere Versionen und
`<table>_last_version` nur die letzten Versionen. Die letzten Versionen werden
dadurch nicht zusätzlich in einer materialisierten Gesamttabelle gespeichert.

`db2dataprocessor_out.v_<table>_old_versions` und
`db2dataprocessor_out.v_<table>_last_version` reichen die jeweilige Tabelle
direkt durch. Die für Auswertungen unverändert benannte View
`db2dataprocessor_out.v_<table>` vereinigt beide Views mit `UNION ALL` und zeigt
damit weiterhin alle Versionen. Tabellen ohne Last-Version-View bleiben als
einzelne Tabelle mit einer durchgereichten `v_<table>`-View erhalten.

Die Zuordnung erfolgt über die technische Zeilen-ID `<table>_id`, die sowohl
die normale als auch die Last-Version-View bereitstellen muss. Dadurch bestimmt
die vorhandene Last-Version-View allein die fachliche Auswahl; der
Snapshot-Prozess führt keine zusätzliche tabellenspezifische Schlüsselliste.

Aufgenommen werden Tabellen, die über die maßgeblichen Table Descriptions für
die pseudonymisierte Snapshot-Datenbank ausgewählt sind. Innerhalb dieser
Tabellen bleiben alle Spalten der Originaltabellen erhalten. Für beschriebene
Spalten muss eine Regel angegeben sein; `keep` übernimmt eine Spalte
ausdrücklich unverändert. Technische Originalspalten wie `hash_index_col`,
RAW-Referenzen und Einfügezeitpunkte werden nicht entfernt. Zeilen werden nicht
mit `unique()` zusammengefasst.

### Verarbeitung großer Tabellen

Die Tabellen werden nacheinander verarbeitet. Innerhalb einer Tabelle wird
jeder Chunk angereichert, pseudonymisiert und unmittelbar in die Zieldatenbank
geschrieben. Erst danach wird der nächste Chunk gelesen. Der R-Speicherbedarf
hängt dadurch von der Chunkgröße und nicht von der Gesamtgröße einer Tabelle
oder der Snapshot-Datenbank ab.

Kontrollsummen und Prüfergebnisse werden über alle Chunks hinweg
zusammengeführt.

### Pseudonymisierungsregeln

Für jede beschriebene Spalte legt `PSEUDONYMIZATION_RULE` fest, wie sie
behandelt wird. Maßgeblich sind folgende Tabellenblätter:

- `table_description` und `snapshot_extension` in
  `R-cds2db/cds2db/inst/extdata/Table_Description.xlsx`
- `table_description` in
  `R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx`
- `frontend_table_description` in
  `R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx`

Die FHIR-Regeln in `Table_Description.xlsx` werden aus der mitgelieferten
DIMP-DUP-Basis-YAML erzeugt. Nicht von der YAML erfasste Spalten erhalten dabei
ausdrücklich die Regel `keep`. Leere Regeln sind ungültig. Die Dateien werden
vom INTERPOLAR-Team gepflegt.

`cryptoHash` und `pseudonymize(...)` werden bei der DB-Pseudonymisierung als
deterministischer SHA-256-Hash ohne Salt umgesetzt. Der gleiche Originalwert
ergibt immer den gleichen Hash.

`pseudonymize(...)` dient in der Table Description als fachlich lesbare
Regelnotation. Ein `domain = ...`-Parameter verändert den erzeugten Hash nicht.
Bei FHIR-Referenzen wie `Encounter/<id>` bleibt der Prefix erhalten; nur der
ID-Anteil hinter dem Schrägstrich wird gehasht.

Die Regel `generalize(format = "YYYY-MM")` erhält Jahr und Monat eines Datums.
In der pseudonymisierten Snapshot-Datenbank wird das Ergebnis als Text im Format
`YYYY-MM` gespeichert. Es wird kein Tag ergänzt, damit der Wert nicht mit einem
tatsächlichen Geburtsdatum verwechselt werden kann. Alters- und
Volljährigkeitsprüfungen müssen die vor der Pseudonymisierung aus dem
vollständigen Originaldatum berechneten Altersspalten verwenden.

Die Regel `redact` entfernt den ursprünglichen Wert vollständig. Das Ergebnis
ist `NA` in R und wird als `NULL` in PostgreSQL gespeichert. Es wird kein
Platzhaltertext wie `redacted` eingetragen.

Mapping-Regeln der Form `pseudonym(sheet = "Sheetname")` lesen das angegebene
Sheet aus `INPUT_REPO_PATH/pseudo_mapping.xlsx`. Jedes verwendete Sheet enthält
die Spalten `KEY` und `PSEUDONYM`. Beide Werte dürfen Leerzeichen enthalten,
aber nicht leer sein. Doppelte Keys sind nicht erlaubt.

### Vorprüfung und Wiederaufnahme

Vor der Pseudonymisierung prüft das Script die Regeln, Spaltendefinitionen und
Mapping-Voraussetzungen. Bei einem Problem bricht es mit einer Fehlermeldung
ab.

Nach dem Einspielen der Quelldatenbank ergänzt das Script fehlende Werte in
`INPUT_REPO_PATH/pseudo_mapping.xlsx` und bricht ab. Nach dem manuellen
Ausfüllen kann derselbe Befehl erneut gestartet werden; die bereits eingespielte
Quelldatenbank wird wiederverwendet.

Bei späteren Fehlern bleibt die Quelldatenbank erhalten. Beim nächsten Lauf wird
sie nur wiederverwendet, wenn ihr vermerkter SHA-256-Wert zur normalen
Snapshot-Datei passt. Eine unvollständige Zieldatenbank wird entfernt und bei
der Fortsetzung neu erstellt.

Nach einem erfolgreichen Lauf werden die normale und die pseudonymisierte
Snapshot-Datenbank in PostgreSQL innerhalb des Docker-Compose-Service `cds_hub`
schreibgeschützt unter ihren endgültigen Namen bereitgestellt:

```text
ip_<name>_<Datum>
ip_<name>_<Datum>_pseud
```

Mit `deactivate` werden nicht mehr benötigte Snapshot-Datenbanken entfernt. Die
Snapshot-Dateien bleiben erhalten.

### Fachliche Anreicherungen

Vor der Pseudonymisierung ergänzt der Prozess zusätzliche Auswertungsspalten in
der pseudonymisierten Snapshot-Datenbank:

- `fall_fe_old_versions` und `fall_fe_last_version` erhalten
  `fall_age_at_admission`.
- `encounter_old_versions` und `encounter_last_version` erhalten
  `enc_age_at_admission`.
- `fall_bmi` wird befüllt, wenn Gewicht und Größe in unterstützten Einheiten
  vorliegen. Unterstützt werden `kg`, `g`, `mg`, `m`, `cm` und `mm`.
- `observation_old_versions` und `observation_last_version` erhalten
  `analysis_loinc_code`, `analysis_unit`, `analysis_value` und
  `analysis_value_status`. Wenn die
  LOINC-Mapping-Datei eine Referenzeinheit enthält und die Umrechnung gelingt,
  stehen dort der Primary-LOINC, die Referenzeinheit und der umgerechnete Wert.
  Andernfalls werden für LOINC-Observations der gemappte Primary-LOINC, soweit
  vorhanden, sowie die ursprüngliche Einheit und der ursprüngliche Wert
  übernommen. `analysis_value_status` enthält `converted`,
  `already_reference_unit`, `source_conversion_failed`, `source_missing_unit`,
  `source_mapping_missing_unit`, `source_no_mapping`,
  `source_no_mapping_missing_unit` oder `missing_value`. Damit ist für jeden
  Analysewert erkennbar, ob Referenz- oder Quelldaten verwendet wurden. Die
  ursprünglichen Observation-Spalten bleiben unverändert erhalten.
- `medicationrequest`, `medicationadministration` und `medicationstatement`
  erhalten die Code-/System-Paare aller `Medication`-Einträge, die über die
  direkte Referenz und rekursiv über
  `med_ingredient_itemreference_ref` erreichbar sind. Mehrere unterschiedliche
  Paare erzeugen entsprechend mehrere Ausgabezeilen; Duplikate werden entfernt.
  Auch zyklische Referenzen werden sicher beendet. Fehlende referenzierte
  Medications und Referenzketten ohne erreichbaren Code bleiben erhalten und
  werden als Prüfproblem erfasst.

Das Alter wird in abgeschlossenen Jahren berechnet. Die Berechnung erfolgt nur,
wenn das Geburtsdatum am oder nach dem 01.01.1910 liegt und das jeweilige
Aufnahme- beziehungsweise Encounter-Datum nicht vor dem Geburtsdatum liegt.
Andernfalls bleibt das Altersfeld leer und der Grund wird als Prüfproblem
protokolliert. Neu ergänzte Altersspalten stehen am Ende der Tabelle. Die
bereits vorhandene Spalte `fall_bmi` wird nicht verschoben.

### Reports

Der Pseudonymisierungslauf schreibt lokale Prüfberichte in diese Verzeichnisse:

```text
outputLocal/snapshot_pseudonymization_preflight/reports
outputLocal/snapshot_pseudonymization/reports
```

Die Reports werden nicht in die pseudonymisierte Snapshot-Datei aufgenommen
und sind kein Bestandteil der auswertbaren, pseudonymisierten
Snapshot-Datenbank:

- `pseudonymization_rule_review.xlsx` enthält die technische Prüfung der
  geladenen Regeln. Das Tabellenblatt `README` erklärt die weiteren
  Tabellenblätter. Regelprobleme werden vom INTERPOLAR-Team behoben.
- `snapshot_pseudonymization_issues.xlsx` ist der Fehlerbericht für fehlende
  direkt oder transitiv referenzierte `Medication`-Ressourcen, Referenzketten
  ohne erreichbares Code-/System-Paar, nicht berechenbare Alterswerte und nicht
  umrechenbare Laboreinheiten. Er kann nicht pseudonymisierte Identifikatoren
  für die lokale Fehlersuche enthalten und darf deshalb nicht weitergegeben
  werden.
- `snapshot_postprocessing_report.xlsx` enthält die technische Zusammenfassung,
  insbesondere Zeilen- und Spaltenzahlen, Chunk-Zahlen sowie Laufzeiten für das
  Öffnen der Quelle, Lesen, Anreichern, Prüfen, Pseudonymisieren und Schreiben
  jeder Tabelle.

Eine kompakte CLI-Hilfe liefert:

```bash
./ip-snapshot.sh
```

Nach erfolgreicher Pseudonymisierung endet die Ausgabe mit einem deutlich
hervorgehobenen Hinweis auf `snapshot_pseudonymization_issues.xlsx`. Wenn der
Prozess Probleme gefunden hat, nennt die direkte R-Ausgabe außerdem deren
Gesamtzahl.
