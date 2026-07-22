# Datenbank Snapshot

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

Die Tabellen werden nacheinander und innerhalb einer Tabelle in Blöcken von standardmäßig 25.000 Zeilen verarbeitet. Ein Block wird angereichert, pseudonymisiert und unmittelbar in die Zieldatenbank geschrieben, bevor der nächste Block gelesen wird. Dadurch hängt der R-Speicherbedarf nicht mehr von der Größe des gesamten Snapshots oder einer einzelnen großen Tabelle ab. Die Kontrollsummen und Enrichment-Reports werden über alle Blöcke hinweg zusammengeführt. Ein abgebrochener Lauf wird weiterhin vollständig neu gestartet; ein blockweises Wiederaufsetzen ist derzeit nicht vorgesehen.

Die Pseudonymisierungsregeln stammen aus den Table-Description-Dateien und den Snapshot-Erweiterungen. Die Regeln `cryptoHash` und `pseudonymize(...)` werden in der DB-Ausführung beide als deterministischer SHA-256-Hash ohne Salt umgesetzt. Derselbe Originalwert ergibt dadurch immer denselben Hash. `pseudonymize(...)` dient in der Table Description als fachlich lesbare Regelnotation; ein eventueller `domain = ...`-Parameter verändert den erzeugten Hash nicht. Bei FHIR-Referenzen wie `Encounter/<id>` bleibt der Prefix erhalten und nur der ID-Anteil nach dem Slash wird gehasht.

Mapping-basierte Pseudonymisierungsregeln der Form `pseudonym(sheet = "Sheetname")` verwenden die Datei `pseudo_mapping.xlsx`. Sie wird nur benötigt, wenn solche Regeln in den Table Descriptions vorkommen. Das Template liegt im Projekt-Hauptverzeichnis. Für den Lauf muss die befüllte Datei in das in der TOML konfigurierte `INPUT_REPO_PATH` kopiert werden. Pro verwendetem Sheet müssen die Spalten `KEY` und `PSEUDONYM` vorhanden sein. `KEY` enthält den Originalwert, `PSEUDONYM` den auszugebenden Ersatzwert; beide Werte dürfen Leerzeichen enthalten. Wenn die Datei, das Sheet, die Pflichtspalten oder konkrete Keys aus den Quelldaten fehlen, bricht die Snapshot-Pseudonymisierung mit einer Fehlermeldung ab. Fehlende konkrete Keys werden gesammelt und gemeinsam ausgegeben.

Vor der Pseudonymisierung werden einige Snapshot-spezifische Auswertungsspalten ergänzt. Für `fall_fe` und `fall_fe_last_version` wird `fall_age_at_admission` ergänzt. Für `encounter` und `encounter_last_version` wird `enc_age_at_admission` ergänzt. Neu ergänzte Altersspalten werden an das Ende der jeweiligen Tabelle angehängt. `fall_bmi` wird in `fall_fe` und `fall_fe_last_version` befüllt, sofern Gewicht und Größe mit eindeutig unterstützten Einheiten vorliegen; da diese Spalte bereits im Original-Tabellenlayout existiert, wird sie nicht ans Tabellenende verschoben. Das Alter wird in abgeschlossenen Jahren berechnet. BMI unterstützt Gewicht in `kg`, `g`, `mg` und Größe in `m`, `cm`, `mm`.

Für `observation` und `observation_last_version` werden zusätzlich `primary_loinc_code`, `reference_unit` und `value_in_reference_unit` aus der im Input-Repo konfigurierten Datei `LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx` ergänzt. Voraussetzung ist, dass für die im auswertenden Prozess verwendeten LOINCs ein Eintrag in dieser Mapping-Tabelle existiert; nicht gemappte oder nicht-LOINC Observation-Zeilen bleiben erhalten und erhalten in den zusätzlichen Spalten leere Werte.

Für `medicationrequest`, `medicationadministration` und `medicationstatement` werden zusätzlich die Code-/System-Paare der referenzierten `Medication` materialisiert. Wenn eine referenzierte `Medication` mehrere unterschiedliche Code-/System-Paare hat, wird die referenzierende Zeile entsprechend mehrfach ausgegeben. Referenzen ohne gefundenes Code-/System-Paar bleiben erhalten und werden im Enrichment-Review ausgewiesen.

Der Pseudonymisierungslauf schreibt Kontroll-Reports unter `outputLocal/snapshot_pseudonymization*/reports`. Diese Reports sind Kontroll- und Freigabeartefakte für das DIZ. Sie werden nicht in den Snapshot-Dump aufgenommen und sind nicht Bestandteil der auswertbaren Read-only-DB.

- `pseudonymization_rule_review.xlsx`: Review der geladenen Pseudonymisierungsregeln, TODOs, impliziten Keep-Regeln, nicht unterstützten Regeln, doppelten Spalten und Mapping-Regeln.
- `snapshot_enrichment_review.xlsx`: begrenzte Zusammenfassung der Medication-Referenzen, für die bei der Snapshot-Anreicherung kein Code-/System-Paar in der referenzierten `Medication` gefunden wurde. Der Report enthält exakte Summen pro Tabelle und höchstens 1.000 Beispiele; seine Größe wächst daher nicht mit der Gesamtzahl unterschiedlicher Fehlerreferenzen.
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

Beim Deaktivieren (_deactivate_) wird nur die aus einer Snapshot-Datei geladene Datenbank gelöscht. Die Snapshot-Datei selbst bleibt erhalten.
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
