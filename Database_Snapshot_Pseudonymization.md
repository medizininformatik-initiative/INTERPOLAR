# Pseudonymisierung von Snapshot-Daten

[Bedienung](Database_Snapshot.md) → [Pseudonymisierung](Database_Snapshot_Pseudonymization.md) → [Broad Consent](Database_Snapshot_Broad_Consent.md)

Die Pseudonymisierung verarbeitet einen vorhandenen Rohsnapshot und erzeugt
seine pseudonymisierte Fassung. Sie ergänzt zunächst die für Auswertungen
benötigten Werte und wendet dann die Regeln für die einzelnen Spalten an.
Im Standardablauf folgt darauf die Broad-Consent-Auswahl.
Befehle und Voraussetzungen stehen in der [Bedienungsanleitung](Database_Snapshot.md).

## Inhalt

- [Tabellen und Versionen](#inhalt-der-pseudonymisierten-snapshot-datei-und-snapshot-datenbank)
- [Verarbeitung großer Tabellen](#verarbeitung-großer-tabellen)
- [Pseudonymisierungsregeln](#pseudonymisierungsregeln)
- [Vorprüfung und Wiederaufnahme](#vorprüfung-und-wiederaufnahme)
- [Fachliche Anreicherungen](#fachliche-anreicherungen)
- [Prüfberichte](#prüfberichte)

## Inhalt der pseudonymisierten Snapshot-Datei und Snapshot-Datenbank

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
die normale als auch die Last-Version-View bereitstellen muss. Damit übernimmt
der Snapshot dieselbe Zuordnung zu aktuellen und historischen Zeilen wie die Quelle. Er berechnet nicht selbst, welche Version
die neueste ist.

Aufgenommen werden Tabellen, die über die maßgeblichen Table Descriptions für
die pseudonymisierte Snapshot-Datenbank ausgewählt sind. Innerhalb dieser
Tabellen bleiben alle Spalten der Originaltabellen erhalten. Für beschriebene
Spalten muss eine Regel angegeben sein; `keep` übernimmt eine Spalte
ausdrücklich unverändert. Technische Originalspalten wie `hash_index_col`,
RAW-Referenzen und Einfügezeitpunkte werden nicht entfernt. Zeilen werden nicht
mit `unique()` zusammengefasst.

## Verarbeitung großer Tabellen

Die Tabellen werden nacheinander verarbeitet. Innerhalb einer Tabelle wird
jeder Chunk angereichert, pseudonymisiert und unmittelbar in die Zieldatenbank
geschrieben. Erst danach wird der nächste Chunk gelesen. So muss R die Tabelle
nicht vollständig im Speicher halten. Die Chunkgröße begrenzt die gleichzeitig verarbeiteten Quellzeilen; zusätzliche
Auswertungsspalten und durch Anreicherungen vervielfachte Zeilen benötigen
weiteren Speicher.

Kontrollsummen und Prüfergebnisse werden über alle Chunks hinweg
zusammengeführt.

## Pseudonymisierungsregeln

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

Bei `Observation.code` bleiben LOINC- und SNOMED-Codes samt `display` und
`text` erhalten. Bei `Observation.valueCodeableConcept` gilt dies für ATC, PZN,
SNOMED und ASK. Codes anderer oder fehlender Systeme werden gehasht; ihr
`display` und `text` werden entfernt. Das jeweilige `system` bleibt erhalten.

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
Sheet aus `Input-Repo/pseudo_mapping.xlsx`. Jedes verwendete Sheet enthält die
Spalten `KEY` und `PSEUDONYM`. Beide Werte dürfen Leerzeichen enthalten, aber
nicht leer sein. Doppelte Keys sind nicht erlaubt.

## Vorprüfung und Wiederaufnahme

Vor der Pseudonymisierung prüft das Script die Regeln, Spaltendefinitionen und
Mapping-Voraussetzungen. Bei einem Problem bricht es mit einer Fehlermeldung
ab.

Bei `create --with-pseudonymized` und `create --with-broad-consent` ergänzt das
Script fehlende Werte in `Input-Repo/pseudo_mapping.xlsx` bereits vor dem
normalen Snapshot und bricht ab. Nach dem manuellen Ausfüllen kann derselbe
Befehl erneut gestartet werden. Direkt im R-Start der eigentlichen
Pseudonymisierung wird dieselbe Prüfung gegen die konkrete
Snapshot-Quelldatenbank wiederholt. Wenn dabei zusätzliche Werte gefunden
werden, wird `pseudo_mapping.xlsx` erneut ergänzt und der Lauf bricht vor dem
Schreiben der pseudonymisierten Daten ab.

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

## Fachliche Anreicherungen

Vor der Pseudonymisierung ergänzt der Prozess zusätzliche Auswertungsspalten in
der pseudonymisierten Snapshot-Datenbank:

- `fall_fe_old_versions` und `fall_fe_last_version` erhalten
  `fall_age_at_admission`.
- `encounter_old_versions` und `encounter_last_version` erhalten
  `enc_age_at_admission`.
- `fall_bmi` wird befüllt, wenn Gewicht und Größe in unterstützten Einheiten
  vorliegen. Unterstützt werden `kg`, `g`, `mg`, `m`, `cm` und `mm`.
- `medikationsanalyse_fe` erhält analog `meda_bmi` aus
  `meda_gewicht_aktuell` und `meda_groesse`, wenn beide Werte in unterstützten
  Einheiten vorliegen.
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

## Prüfberichte

Der Pseudonymisierungslauf schreibt lokale Prüfberichte in diese Verzeichnisse:

```text
outputLocal/snapshot_pseudonymization_preflight/reports
outputLocal/snapshot_pseudonymization/reports
```

Die Prüfberichte werden nicht in die pseudonymisierte Snapshot-Datei aufgenommen
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

Nach erfolgreicher Pseudonymisierung endet die Ausgabe mit einem deutlich
hervorgehobenen Hinweis auf `snapshot_pseudonymization_issues.xlsx`. Wenn der
Prozess Probleme gefunden hat, nennt die direkte R-Ausgabe außerdem deren
Gesamtzahl.

Weiter mit der [Broad-Consent-Auswahl](Database_Snapshot_Broad_Consent.md).
