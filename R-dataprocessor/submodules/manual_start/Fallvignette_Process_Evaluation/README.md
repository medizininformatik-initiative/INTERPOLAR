# Fallvignette Process Evaluation

Dieses manuell gestartete Dataprocessor-Submodul erzeugt die Importdatei für
das eigenständige REDCap-Projekt zur Prozessevaluation der WP8-Fallvignetten.
Es liest geeignete Fälle aus der pseudonymisierten Analysedatenbank, ergänzt
den klinischen Kontext und schreibt eine importfähige CSV-Datei sowie eine
inhaltlich identische XLSX-Datei zur Kontrolle.

Das Modul verändert weder die Quelldatenbank noch das produktive
INTERPOLAR-REDCap-Projekt.

## Voraussetzungen

Vor der Ausführung müssen folgende Voraussetzungen erfüllt sein:

- Die normale INTERPOLAR-Konfiguration wurde initialisiert.
- Die pseudonymisierte Analysedatenbank ist erreichbar und enthält die
  benötigten `*_last_version`-Views.
- Die lokalen WP7-MRP-Listen und das LOINC-Mapping sind über
  `INPUT_REPO_PATH` erreichbar.
- Standortkürzel und Stationen sind in der `dataprocessor_config.toml`
  konfiguriert.
- Die Mapping-Arbeitsmappe liegt unter
  `R-Fallvignette_Process_Evaluation/inst/extdata`.

Ein Broad Consent wird für diesen einmaligen Export nicht zusätzlich geprüft.

## Konfiguration

### Standort und Stationen

`SITE_CODE` wird im Abschnitt `[analyse]` der
`R-dataprocessor/dataprocessor_config.toml` gesetzt. Der Wert ist
verpflichtend und muss exakt in
`R-dataprocessor/dataprocessor/inst/extdata/Standortkuerzel.xlsx` vorkommen.

Für jede exportierte Station muss eine `PHASES_WARD_*`-Definition vorhanden
sein. `ward_name`, `phase_a_start`, `department` und `ward_type` sind
verpflichtend. Mehrere Fachabteilungen werden innerhalb eines einzigen
`department`-Werts mit Semikolon getrennt.

Für `department` sind ausschließlich Kombinationen aus `Code` und `Display`
aus
`R-dataprocessor/dataprocessor/inst/extdata/Fachabteilungsschluessel.xlsx`
zulässig. Code und Display werden durch genau ein Leerzeichen verbunden. Für
`ward_type` sind nur `surgical` und `internistic` erlaubt.

Die `fall_station` aus der Datenbank muss exakt einem konfigurierten
`ward_name` entsprechen. `department` wird als `wp8_mrp_fachbereich` in den
Export übernommen. `ward_type` wird validiert, aber derzeit nicht als eigenes
Feld in die Fallvignetten-Datei geschrieben.

Eine beispielhafte Konfiguration befindet sich in
`R-dataprocessor/dataprocessor_config_example.toml`.

### Datenbankverbindung

Die DB-Zugangsdaten werden aus der zentralen Dataprocessor-Konfiguration
geladen. Vor dem Lesen der Fall-, Patienten- und FHIR-Daten verwendet das Modul
`PATH_TO_DB_CONFIG_TOML` aus der zentralen `dataprocessor_config.toml` und
wechselt anhand der dort referenzierten `DB_ANALYSIS_*`-Werte in den Kontext
der pseudonymisierten Analysedatenbank.

### Mapping-Arbeitsmappe

Die neueste Datei mit dem Namen `WP8MRP_Liste_Daten_Mapping<YYYYMMDD>.xlsx`
unter `R-Fallvignette_Process_Evaluation/inst/extdata` wird automatisch
verwendet. Sie muss genau ein Tabellenblatt und diese Spalten enthalten:

- `Fallvignette`: Name und Reihenfolge des REDCap-Zielfelds
- `Quelle`: DB-Quellfeld; leer bei berechneten Feldern
- `Value`: Bestandteil der Mapping-Vorlage
- `Kommentar`: fachliche Dokumentation des Mappings

Zeilen ohne `Fallvignette` werden als Hinweise ignoriert. Die Reihenfolge der
ersten Vorkommen bestimmt die Exportspalten. Ein Zielfeld darf höchstens zwei
Quellfelder besitzen. Doppelte Zuordnungen werden für die beiden möglichen
retrospektiven Bewertungen verwendet, zum Beispiel `ret_gewissheit1` und
`ret_gewissheit2`.

Direkte Quellfelder müssen mit `pat_`, `meda_` oder `ret_` beginnen. Zusätzlich
wird `fall_age_at_admission` aus `fall_fe` unterstützt. `record_id`,
`wp8_standort_id`, `wp8_mrp_fachbereich`, Diagnosen, Medikationen, Laborwerte
und OP-Status werden durch das Modul befüllt. `mrp_auswahl_complete` bleibt
absichtlich leer.

## Auswahl der Exportfälle

Grundlage ist die retrospektive MRP-Bewertung. Eine Zeile ist geeignet, wenn
alle folgenden Bedingungen erfüllt sind:

- `ret_id` und die referenzierte Medikationsanalyse sind vorhanden.
- Mindestens eine der beiden Bewertungen besitzt für
  `ret_gewiss_grund1_abl_01` beziehungsweise
  `ret_gewiss_grund2_abl_01` den Wert `3`, also sachlich richtig, aber klinisch
  nicht relevant.
- Für dieselbe Medikationsanalyse existiert mindestens eine
  MRP-Dokumentation mit einer `mrp_id`.
- Es handelt sich nicht um eine Test-MRP. IDs mit `-TEST-` und
  Kurzbeschreibungen mit `*TEST*` werden ausgeschlossen.

Sind beide retrospektiven Bewertungen mit `3` gekennzeichnet, entstehen zwei
Exportzeilen. Jede erhält eine eigene `record_id`. Gemeinsam gemappte Fall- und
Patientendaten werden wiederholt, doppelt hinterlegte Zielfelder werden aus der
jeweils passenden Bewertung befüllt.

## Klinischer Kontext

Alle klinischen Ressourcen werden aus der pseudonymisierten Analysedatenbank
gelesen. Die bestehenden Loader der regulären MRP-Toolchain werden für
Conditions, MedicationRequests, Observations und Procedures wiederverwendet.

### Diagnosen

- Alle ICD-10-GM-Diagnosen des aktuellen Hauptencounters werden übernommen,
  sofern sie nicht nach der Medikationsanalyse dokumentiert wurden.
- Diagnosen aus früheren Fällen werden nur übernommen, wenn ihr ICD-Code in
  den lokalen WP7-Drug-Disease- oder Drug-Niereninsuffizienz-Regeln vorkommt
  und `ICD_VALIDITY_DAYS` am Analysezeitpunkt erfüllt ist.
- `unbegrenzt` sowie ein leerer Gültigkeitswert gelten als zeitlich
  unbeschränkt.
- Doppelte Diagnosen bleiben erhalten.
- Die Ausgabe wird alphabetisch nach Diagnosetext sortiert. Ein vorhandener
  Diagnosezeitpunkt wird mit ausgegeben.

Beispiel:

```text
Essentielle Hypertonie (ICD: I10) [2026-01-15 08:30:00]
```

### Medikationen

- Berücksichtigt werden MedicationRequests des aktuellen Hauptencounters.
- Die Aktivitätsprüfung verwendet `getActiveATCs()` aus der regulären
  MRP-Berechnung und berücksichtigt Aufnahme, Entlassung und Analysezeitpunkt.
- Der Medikationsbeginn darf nicht nach der Medikationsanalyse liegen.
- Bevorzugt werden Wirkstoffbezeichnung und ATC-Code ausgegeben. Ist kein ATC
  ermittelbar, wird eine direkt oder über Medication referenzierte PZN als
  Rückfallwert verwendet.
- Die Ausgabe wird alphabetisch nach der Bezeichnung sortiert. Der erste
  geplante Medikationsbeginn wird mit ausgegeben.

Beispiel:

```text
Heparin (ATC: B01AB01) [2026-01-18 09:00:00]
```

### Laborwerte

- Berücksichtigt werden Labor-Observations mit dem Codesystem
  `http://loinc.org`.
- Der LOINC oder sein primärer LOINC muss in den relevanten lokalen WP7-Regeln
  vorkommen.
- Das Zeitfenster umfasst die sieben Tage bis einschließlich der
  Medikationsanalyse. Spätere Werte werden ausgeschlossen.
- Die Bezeichnung stammt bevorzugt aus dem lokalen LOINC-Mapping, anschließend
  aus `Observation.code.display` und zuletzt aus dem Code.
- Wert, Einheit, LOINC-Code und vorhandener Beobachtungszeitpunkt werden
  ausgegeben. Die Sortierung erfolgt alphabetisch nach der Bezeichnung.

Beispiel:

```text
Kreatinin (LOINC: 2160-0): 1.2 mg/dL [2026-01-19 07:45:00]
```

### Operation innerhalb der letzten 30 Tage

`wp8_fv_op` wird mit `1` befüllt, wenn innerhalb der 30 Tage bis zur
Medikationsanalyse mindestens eines der folgenden Merkmale vorliegt:

- eine Procedure mit einem OPS-Code aus Kapitel 5 (`5-...`) oder
- ein zeitlich überlappender Encounter mit dem Codesystem
  `http://fhir.de/CodeSystem/kontaktart-de` und dem Code `operation`.

Andernfalls wird `wp8_fv_op` mit `0` befüllt.

## IDs und lokale Rückverfolgung

Für jede Exportzeile wird intern eine lokale ID aus `SITE_CODE` und einer
fortlaufenden, mindestens vierstellig aufgefüllten Nummer gebildet, zum
Beispiel `UKB0001`. In die REDCap-Datei gelangt ausschließlich der SHA-256-Hash
dieser ID als `record_id`. `wp8_standort_id` enthält den SHA-256-Hash des reinen
`SITE_CODE`.

Die lokale Rückverfolgungsdatei enthält je nach Verfügbarkeit:

- `record_id`, `local_record_id`, `site_code` und `evaluation_index`
- Quell-, Patienten-, Fall-, Medikationsanalyse- und retrospektive MRP-IDs

Diese Datei muss am exportierenden Standort verbleiben. Sie darf weder in das
WP8-REDCap-Projekt importiert noch mit den globalen Dateien übertragen werden.

Die Nummerierung beginnt bei jedem vollständigen Export erneut bei `0001`.
Das Verfahren ist für den vorgesehenen einmaligen Export ausgelegt. Bei einem
erneuten Lauf mit veränderter Fallmenge können lokale Nummern anderen Fällen
zugeordnet werden. Die Mapping-Datei muss daher eindeutig dem Lauf zugeordnet
und sicher aufbewahrt werden.

## Ausführung

Start aus dem Repository-Stamm:

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R fallvignette-process-evaluation
```

Der Ablauf ist:

1. Mapping-Arbeitsmappe und lokale WP7-/LOINC-Definitionen laden.
2. Auf die konfigurierte pseudonymisierte `DB_ANALYSIS`-Datenbank umschalten.
3. Geeignete Bewertungen und klinische Ressourcen lesen.
4. Klinischen Kontext berechnen und Zielfelder gemäß Mapping anordnen.
5. Lokale Rückverfolgungsdatei sowie globale CSV und XLSX schreiben.

## Ausgabedateien

| Datei | Ablage | Verwendung |
| --- | --- | --- |
| `WP8_Fallvignetten_Import.csv` | `outputGlobal/dataprocessor/reports` | Import in das eigenständige WP8-REDCap-Projekt |
| `WP8_Fallvignetten_Import.xlsx` | `outputGlobal/dataprocessor/reports` | Kontrolle; inhaltlich identisch zur CSV |
| `Fallvignette_Process_Evaluation_ID_Mapping.xlsx` | `outputLocal/dataprocessor/data` | Ausschließlich lokale Rückverfolgung |

Die CSV wird UTF-8-kodiert, mit BOM, Spaltenüberschriften und leeren Feldern
anstelle von `NA` geschrieben. Vorher werden Vollständigkeit und Reihenfolge
der Spalten sowie Befüllung und Eindeutigkeit der `record_id` geprüft.

## Typische Fehler

- **Ungültiger `SITE_CODE`:** Wert mit `Standortkuerzel.xlsx` abgleichen.
- **Ungültiger Fachabteilungsschlüssel:** Vollständigen Code und Display mit
  `Fachabteilungsschluessel.xlsx` abgleichen; mehrere Werte mit Semikolon
  trennen.
- **Keine Fachabteilung für `fall_station`:** `fall_station` und `ward_name`
  müssen exakt übereinstimmen.
- **Mapping-Datei nicht gefunden:** Mindestens eine Datei nach dem Muster
  `WP8MRP_Liste_Daten_Mapping<YYYYMMDD>.xlsx` muss unter `inst/extdata` liegen.
- **Unbekanntes Quellfeld:** Nur `pat_`, `meda_`, `ret_` sowie
  `fall_age_at_admission` verwenden.
- **Datenbankverbindung schlägt fehl:** `PATH_TO_DB_CONFIG_TOML` in der
  `dataprocessor_config.toml` und die `DB_ANALYSIS_*`-Werte der referenzierten
  DB-Konfiguration prüfen.
- **Leerer Export:** Prüfen, ob geeignete Bewertungen mit Wert `3`, eine
  passende MRP-Dokumentation und zugehörige Fall-/Patientendaten vorhanden
  sind.

## Tests

```console
R --slave -e "setwd('R-dataprocessor/submodules/manual_start/Fallvignette_Process_Evaluation/R-Fallvignette_Process_Evaluation'); testthat::test_local(reporter='summary')"
```
