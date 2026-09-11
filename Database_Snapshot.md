# Snapshot-Dateien, Pseudonymisierung und Broad Consent

Das Script `ip-snapshot.sh` erstellt und pseudonymisiert Snapshot-Dateien. Es
erstellt außerdem Broad-Consent-Snapshots aus vorhandenen Snapshot-Datenbanken,
aktiviert und deaktiviert die zugehörigen Snapshot-Datenbanken und kann
Snapshot-Dateien sowie Snapshot-Datenbanken löschen. Außerdem zeigt es
vorhandene Snapshot-Dateien und aktivierte Snapshot-Datenbanken an.
Snapshot-Dateien liegen als `.sql.gz` im Verzeichnis `Snapshots`.
Bei der Pseudonymisierung werden außerdem analysefertige Zusatzspalten ergänzt,
unter anderem Alters-, BMI-, Medication-Code- und Observation-Analysewerte mit
LOINC-basierter Einheitenumrechnung.

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
- Für einen Broad-Consent-Snapshot muss die als Quelle gewählte
  Snapshot-Datenbank bereits aktiviert sein. Die Quelle kann pseudonymisiert
  oder nicht pseudonymisiert sein und wird nicht verändert.

Für die Pseudonymisierung gelten zusätzlich folgende Voraussetzungen:

- `INPUT_REPO_PATH` in `R-dataprocessor/dataprocessor_config.toml` muss auf ein
  Verzeichnis zeigen, das für den Container erreichbar ist. Der Pfad darf direkt
  auf `Input-Repo` oder auf einen beliebig benannten Unterordner darin zeigen.
  `./` am Pfadanfang ist optional.
- Benötigte Eingabedateien und -verzeichnisse werden zuerst unterhalb des
  konfigurierten Pfads gesucht. Gibt es dort keinen Treffer, wird die Suche
  schrittweise bis einschließlich `Input-Repo` nach oben fortgesetzt. Der erste
  Suchbereich mit genau einem Treffer wird verwendet. Mehrere Treffer im selben
  Suchbereich führen zu einem Abbruch mit allen Fundstellen.
- Die Datei `pseudo_mapping.xlsx` wird bei Bedarf automatisch direkt unter
  `Input-Repo/pseudo_mapping.xlsx` erzeugt und mit den in der temporären
  Quelldatenbank vorkommenden Originalwerten vorausgefüllt. Die gewünschten
  Pseudonyme müssen anschließend manuell in der Spalte `PSEUDONYM` ergänzt
  werden. Das Verzeichnis `Input-Repo` muss dafür schreibbar sein.
- Bei einer Aktualisierung muss eine bereits vorhandene
  `pseudo_mapping.xlsx` aus dem bisher konfigurierten Eingabeordner einmalig
  nach `Input-Repo/pseudo_mapping.xlsx` verschoben werden. Der Prozess erkennt
  die bisherige Datei und zeigt die beiden Pfade an, bevor weitere Verarbeitung
  beginnt.
- Die LOINC-Mapping-Datei `LOINC_Mapping_Table_processed.xlsx` muss eindeutig
  innerhalb des durchsuchten Bereichs verfügbar sein. Sie wird für die
  Observation-Anreicherung und die Einheitenumrechnung benötigt.
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

Zuerst prüft der Prozess die Voraussetzungen der Pseudonymisierung gegen die
laufende `cds_hub_db`. Danach wird die normale Snapshot-Datei erstellt und
daraus die pseudonymisierte Snapshot-Datei
`Snapshots/snap01_<Datum>_pseud.sql.gz` erzeugt. Danach sind in PostgreSQL
innerhalb des Docker-Compose-Service `cds_hub` die schreibgeschützten
Snapshot-Datenbanken `ip_snap01_<Datum>` und `ip_snap01_<Datum>_pseud`
verfügbar.

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

### Broad-Consent-Snapshot erstellen

Im Standardablauf erstellt ein Befehl die normale, die pseudonymisierte und die
daraus abgeleitete Broad-Consent-Snapshot-Datei:

```bash
./ip-snapshot.sh create snap01 --with-broad-consent
```

Der Befehl erstellt:

```text
Snapshots/snap01_20251002.sql.gz
Snapshots/snap01_20251002_pseud.sql.gz
Snapshots/snap01_20251002_pseud_broad_consent.sql.gz
ip_snap01_20251002
ip_snap01_20251002_pseud
ip_snap01_20251002_pseud_broad_consent
```

Alle drei Datenbanken bleiben schreibgeschützt verfügbar. Schlägt nur der
Broad-Consent-Schritt fehl, bleiben die normale und die pseudonymisierte
Snapshot-Datei sowie deren Datenbanken erhalten. Der letzte Schritt kann dann
gesondert fortgesetzt werden:

```bash
./ip-snapshot.sh create-broad-consent snap01_20251002_pseud
```

Der technische Prozess ist unabhängig von der Pseudonymisierung. Für eine
gesonderte lokale Prüfung kann deshalb ausdrücklich auch eine nicht
pseudonymisierte Snapshot-Datenbank als Quelle verwendet werden:

```bash
./ip-snapshot.sh create-broad-consent snap01_20251002
```

Die Auswahl verwendet die aktuellen Consent-Fassungen der Quelldatenbank. Die
Einwilligung zur Datennutzung (Consent-Code mit der Endung `.8`) muss am Tag des
Laufs gültig sein. Die Einwilligung zur Datenspeicherung (`.6`) legt fest, aus
welchen Zeiträumen Daten übernommen werden dürfen. Für jede klinische Ressource
muss ihr maßgebliches Datum beziehungsweise ihr gesamter Zeitraum abgedeckt
sein. Retrospektive Freigaben können diese Datenzeiträume erweitern; Widerrufe
werden bei der Berechnung berücksichtigt. Das Bewertungsdatum wird am Start
einmalig festgehalten, damit während des gesamten Laufs derselbe Stichtag gilt.

Optional schreibt `--consent-details` die patientenbezogenen CSV-Berichte:

```bash
./ip-snapshot.sh create-broad-consent snap01_20251002_pseud --consent-details
```

Der Parameter ist auch bei `create --with-broad-consent` zulässig. Ohne ihn
werden nur die Zusammenfassung und die dauerhaften Maskierungsnachweise erzeugt.

### Consent-Auswertung ohne Snapshot-Erzeugung prüfen

```bash
./ip-snapshot.sh review-broad-consent snap01_20251002_pseud
```

Der Prüflauf verwendet die aktuelle Version der Consent- und Encounter-Ressourcen
aus einer bereits aktivierten Snapshot-Datenbank. Er legt keine Ziel-Datenbank
und keine Snapshot-Datei an. Das aktuelle Bewertungsdatum wird am Start einmalig
festgehalten. Die detaillierten CSV-Berichte liegen in einem eigenen Verzeichnis
unter `outputLocal/broad_consent_review`. Eine `README.txt` erläutert die Dateien;
erst die Datei `COMPLETE` kennzeichnet eine vollständig abgeschlossene Auswertung.

Die Berichte enthalten die Patientenzulassung, ursprüngliche Consent-Provisionen,
nachvollziehbare Änderungen durch Widerrufe und Encounter sowie die endgültigen
Datenintervalle. Patienten- und Consent-IDs entsprechen dem Quellsnapshot. Der
Prüflauf wertet keine einzelnen klinischen Ressourcen aus und bestätigt deshalb
noch keine tatsächlichen Ressourcen-Einschlusszahlen.

`--chunk-size` begrenzt bei diesem Prüflauf die Zahl der Patienten je Leseblock.
Alle Consent-Provisionen und benötigten Encounter eines Blocks werden gemeinsam
gelesen. Der Speicherbedarf hängt daher zusätzlich von der Zahl dieser Einträge
pro Patient ab.

Prüflauf und Snapshot-Erzeugung verwenden dieselbe Consent-Auswertung. Nur die
Snapshot-Erzeugung prüft darüber hinaus die klinischen Ressourcen und maskiert
Referenzen auf ausgeschlossene Ziele.

### Chunkgröße anpassen

Standardmäßig verarbeiten die Pseudonymisierung und die Erstellung eines
Broad-Consent-Snapshots 5.000 Tabellenzeilen pro Chunk. In Tests hat sich diese
Chunkgröße als günstig erwiesen und ist deshalb der Standardwert.

Für die Pseudonymisierung einer vorhandenen Snapshot-Datei:

```bash
./ip-snapshot.sh pseudonymize snap01_20251002 --chunk-size 10000
```

Für die gemeinsame Erstellung einer normalen und einer pseudonymisierten
Snapshot-Datei:

```bash
./ip-snapshot.sh create snap01 --with-pseudonymized --chunk-size 10000
```

Für den vollständigen Standardablauf einschließlich Broad-Consent-Snapshot:

```bash
./ip-snapshot.sh create snap01 --with-broad-consent --chunk-size 10000
```

Für die Erstellung eines Broad-Consent-Snapshots:

```bash
./ip-snapshot.sh create-broad-consent snap01_20251002_pseud --chunk-size 10000
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

### Snapshot-Datei löschen

```bash
./ip-snapshot.sh delete snap01_20251002
```

Der Befehl löscht ausschließlich die Snapshot-Datei. Eine gegebenenfalls
aktivierte Snapshot-Datenbank bleibt erhalten und muss separat mit `deactivate`
entfernt werden.

`delete` erwartet den in der Dateiliste ausgegebenen Namen ohne die Erweiterung
`.sql.gz`. Das Präfix `ip_` gehört nur zum Datenbanknamen und darf hier nicht
angegeben werden.

## Ablauf bis zur Prüfung

1. Wenn der Befehl `create --with-pseudonymized` oder
   `create --with-broad-consent` verwendet wird, prüft das Script
   `pseudo_mapping.xlsx` zuerst gegen die aktuell laufende
   `cds_hub_db`. Dafür wird `StartSnapshotPseudonymization.R` ohne `target-db`
   gestartet; in diesem Modus läuft nur die Vorprüfung. Fehlende Pseudonyme
   müssen eingetragen werden, bevor der normale Snapshot erstellt wird.
2. Die normale Snapshot-Datei wird in eine temporäre Quelldatenbank eingespielt.
   Das kann bei großen Snapshot-Dateien lange dauern.
3. `StartSnapshotPseudonymization.R` prüft `pseudo_mapping.xlsx` erneut gegen
   die eingespielte Quelldatenbank. Weil der Aufruf hier zusätzlich eine
   `target-db` enthält, startet nach erfolgreicher Prüfung die eigentliche
   Pseudonymisierung. So werden auch Originalwerte erkannt, die seit der ersten
   Prüfung hinzugekommen sind und noch kein Pseudonym haben.
4. Das Script erstellt eine temporäre Zieldatenbank und schreibt die
   pseudonymisierten Daten hinein.
5. Die Zieldatenbank wird als neue Snapshot-Datei mit dem Suffix `_pseud`
   gespeichert.
6. Die normale und die pseudonymisierte Snapshot-Datenbank werden in PostgreSQL
   innerhalb des Docker-Compose-Service `cds_hub` schreibgeschützt unter ihren
   endgültigen Namen bereitgestellt. Ein zusätzliches `activate` ist nicht
   nötig.
7. Mit `create --with-broad-consent` wird anschließend automatisch die
   pseudonymisierte Snapshot-Datenbank verarbeitet. Alternativ kann dieser
   Schritt mit `create-broad-consent` einzeln ausgeführt werden. Er wählt die
   consentierten Patienten und Ressourcen aus und erzeugt die gefilterte
   Snapshot-Datenbank samt Dump.

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
- Beim Erstellen eines Broad-Consent-Snapshots bleibt die Quelldatenbank
  unverändert. Eine unvollständige Zieldatenbank wird vor dem nächsten Lauf
  entfernt und vollständig neu aufgebaut.

## Technische Details

### Inhalt des Broad-Consent-Snapshots

Ein Broad-Consent-Snapshot enthält die für Auswertungen vorgesehenen Tabellen
und Spalten der Quelldatenbank. Er übernimmt daraus nur die durch die
Consent-Auswertung zugelassenen Daten. Aktuelle
und historische Ressourcenfassungen werden einzeln geprüft. Besteht eine
Ressourcenfassung aus mehreren Tabellenzeilen, gilt die Entscheidung für alle
diese Zeilen gemeinsam. So können zusammengehörige Angaben nicht unterschiedlich
behandelt werden.

#### Patientenzulassung

Die Auswertung prüft zunächst, für welche Patienten Daten übernommen werden
dürfen. Ein aktuelles Consent-Dokument muss eindeutig einem Patienten zugeordnet
sein. Ist ein potenziell wirksames Dokument mehreren Patienten zugeordnet,
werden alle betroffenen Patienten ausgeschlossen. Weitere gültige Dokumente
heben diesen Ausschluss nicht auf, weil unklar ist, für wen die widersprüchliche
Erklärung gilt. Der Bericht nennt den Grund `ambiguous_consent_patient`.

Ein aktives relevantes Consent-Dokument mit einem Erklärungsdatum in der Zukunft
führt ebenfalls zum Ausschluss des Patienten (`future_consent_declaration`).
Eine erst später erklärte Einwilligung oder ein später erklärter Widerruf kann
keine verlässliche Grundlage für die heutige Entscheidung sein. Maßgeblich sind
UTC-Kalendertage; Erklärungen am Bewertungstag bleiben zulässig.

#### Zeitliche Prüfung der Ressourcen

Für jeden unterstützten FHIR-Ressourcentyp ist festgelegt, welches Datumsfeld mit
den erlaubten Datenzeiträumen verglichen wird. Bei `Observation` ist dies
beispielsweise `effective`, bei `Encounter` der Zeitraum `period`. Ein
Einzelzeitpunkt muss innerhalb eines erlaubten Zeitraums liegen. Bei einem
Zeitraum müssen Anfang, Ende und alle dazwischenliegenden Tage abgedeckt sein;
eine bloße Überschneidung reicht nicht aus. Fehlen dafür benötigte Datumswerte
oder sind die Angaben widersprüchlich, wird die Ressourcenfassung ausgeschlossen.

Für `Patient` und `Medication` ist ausdrücklich keine eigene zeitliche Prüfung
vorgesehen: Patientendaten werden anhand der Patientenzulassung ausgewählt.
Medikamentenressourcen werden übernommen, wenn sie von einem behaltenen
Medikationsereignis direkt oder über eine Zutatenreferenz benötigt werden.
Ein leeres Datumsfeld in einer anderen Ressource hebt deren zeitliche Prüfung
jedoch nicht auf.

Für `Location` ist in der verwendeten Regelzuordnung keine Auswahlregel
hinterlegt. Deshalb werden `Location`-Ressourcen derzeit vollständig
ausgeschlossen. Eine fehlende Regel wird nicht als Freigabe behandelt. Die
Zuordnung der Datumsfelder folgt dem TORCH-Stand
`b12757d09a525ae1a3309e4aded999b209b1d600` und ist im Code in
[`BROAD_CONSENT_RESOURCE_DATES`](R-cdstoolchain/pseudonym/R/broad_consent_resources.R)
festgehalten.

#### Abhängige Tabellen und Encounter-Hierarchien

Nicht-FHIR-Tabellen, etwa Frontend-Daten und MRP-Berechnungen, werden anhand ihrer
Patientenzuordnung gefiltert. Für sie wird kein eigener Datenzeitraum geprüft.
Die Zuordnung erfolgt anhand der Quelldaten, bevor Encounter ausgeschlossen und
Referenzen entfernt werden. Dadurch bleibt zum Beispiel eine MRP-Berechnung
einem zugelassenen Patienten zugeordnet, auch wenn der zugehörige
Einrichtungskontakt nicht übernommen werden darf.

Auch klinische Ressourcen werden jeweils nach ihren eigenen Datumswerten
beurteilt: Ein Stationskontakt oder Laborwert kann vollständig im erlaubten
Zeitraum liegen, während der längere Einrichtungskontakt darüber hinausreicht.
Dann bleibt der Stationskontakt oder Laborwert erhalten und der
Einrichtungskontakt entfällt. Die Referenzen auf diesen ausgeschlossenen Kontakt
werden wie nachfolgend beschrieben entfernt.

#### Entfernte Referenzen und Maskierungsnachweise

Verweist eine erhaltene Zeile auf eine durch die BC-Auswahl ausgeschlossene
Ressource, wird die betreffende Referenz im BC-Snapshot auf SQL `NULL` gesetzt.
Das wird hier als Maskierung bezeichnet. Es gilt auch für berechnete
Referenzspalten und bekannte FHIR-Zuordnungsspalten in Nicht-FHIR-Tabellen.
Eine Referenz ohne Versionsangabe wird anhand der aktuellen Fassung des Ziels
geprüft; bei einer Referenz mit `/_history/` ist die angegebene Version maßgeblich.

Für jeden so entfernten Referenzwert entsteht zusätzlich ein Eintrag in
`db_log.broad_consent_masked_reference` mit dem Grund `masked`. Damit kann eine
Auswertung unterscheiden, ob eine Referenz durch die BC-Auswahl entfernt wurde
oder bereits in der Quelle fehlte. Ein `NULL`-Wert allein reicht für diese
Unterscheidung nicht aus. Der Nachweis bezieht sich auf die BC-Maskierung von
Referenzen; er erfasst nicht allgemein alle durch die Pseudonymisierungsregel
`redact` entfernten Werte.

Der Eintrag benennt Tabelle, technische Zeilen-ID, Ressourcen-ID, Version,
Patienten-ID und Spalte. Der entfernte Referenzwert selbst wird nicht gespeichert.
Die Nachweistabelle liegt dauerhaft im Schema `db_log` und wird mit dem Snapshot
als Dump gesichert, unabhängig von `--consent-details`. Über die View
`db2dataprocessor_out.v_broad_consent_masked_reference` ist sie für Auswertungen
zugänglich.

Wird aus einem BC-Snapshot erneut ein BC-Snapshot erzeugt, wird die
Patientenzulassung erneut geprüft. Bei einer MRP-Berechnung kann die dafür
benötigte Encounter-Referenz bereits maskiert sein. In diesem Fall liefert der
Nachweis die Patienten-ID für die Prüfung. Nur weiterhin zugelassene Zeilen
und deren Nachweise werden übernommen.
`db_log.broad_consent_run` dokumentiert dazu die Quelldatenbank, das
Bewertungsdatum, den verwendeten TORCH-Stand und den Abschlusszeitpunkt.

### Auswertungen ohne Datenbank-Cronjob

Pseudonymisierte und Broad-Consent-Snapshot-Datenbanken enthalten die für die
Versionsprüfung benötigte View `db2dataprocessor_out.v_db_parameter`. Sie stellt
die `release_version` der jeweiligen Quelldatenbank bereit, ohne die übrige
Datenbankkonfiguration in den Snapshot zu kopieren.

Bei der Erzeugung eines Broad-Consent-Snapshots wird außerdem ein vorhandener
`database_content_type` unverändert aus der Quelldatenbank übernommen. Fehlt
dieser Marker in der Quelle, wird auch das BC-Ergebnis nicht als pseudonymisiert
markiert: Die BC-Auswahl allein führt keine Pseudonymisierung durch. Ein aus
einem markierten pseudonymisierten Snapshot erzeugter Broad-Consent-Snapshot
kann deshalb ohne `--force` für
manuelle Data-Processor-Projekte verwendet werden.

Die gemeinsame Datenbankbibliothek prüft beim ersten Zugriff, ob die ausgewählte
Datenbank schreibgeschützt ist und ob mindestens eine der für die
INTERPOLAR-Transfersteuerung typischen Datenbankfunktionen vorhanden ist. Nur
eine beschreibbare Datenbank mit einem solchen Funktionsmarker verwendet das
zugehörige Locking. In schreibgeschützten Snapshot-Datenbanken und in anderen
Datenbanken ohne diese Funktionen werden dieselben Abfragen ohne Locking
ausgeführt. Die Auswertungen benötigen deshalb weder Adminzugang noch
Cron-Metadaten oder einen bereits ausgeführten Cronjob.

Manuell gestartete Data-Processor-Projekte wählen ihre Datenbank über eine
lokale `database.toml` im jeweiligen Projektordner unter
`R-dataprocessor/submodules/manual_start`. Eine gemeinsame Vorlage liegt als
`database_example.toml` direkt in diesem Ordner. In jeder Projektdatei muss
mindestens `DB_NAME` gesetzt sein. Die übrigen Werte werden aus der normalen
DB-Konfiguration geerbt und nur durch nicht leere Projektwerte überschrieben.
Die Auswahl erfolgt vor Lock- und Versionsprüfung. Ohne zusätzliches Argument
starten manuelle Projekte nur auf pseudonymisierten Snapshot-Datenbanken, die in
`v_db_parameter` als `database_content_type = pseudonymized_snapshot` markiert
sind. Eine andere kompatible Datenbank, zum Beispiel ein normaler Snapshot oder
die Originaldatenbank, kann nur bewusst mit `--force` verwendet werden.

Die Versionsprüfung blockiert manuelle Auswertungen nicht, wenn der ausgewählte
Snapshot älter als die verwendete INTERPOLAR-Version ist. Stattdessen wird der
Versionsunterschied als Warnung protokolliert. Neuere Datenbankversionen bleiben
gesperrt. Ob eine konkrete Auswertung mit dem älteren Schema kompatibel ist,
ergibt sich aus den von ihr tatsächlich benötigten Views und Spalten.

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

### Verarbeitung großer Tabellen

Die Tabellen werden nacheinander verarbeitet. Innerhalb einer Tabelle wird
jeder Chunk angereichert, pseudonymisiert und unmittelbar in die Zieldatenbank
geschrieben. Erst danach wird der nächste Chunk gelesen. So muss R die Tabelle
nicht vollständig im Speicher halten. Die Chunkgröße begrenzt die gleichzeitig verarbeiteten Quellzeilen; zusätzliche
Auswertungsspalten und durch Anreicherungen vervielfachte Zeilen benötigen
weiteren Speicher.

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

### Vorprüfung und Wiederaufnahme

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

### Fachliche Anreicherungen

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

### Prüfberichte

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

Der Broad-Consent-Prozess schreibt zusätzlich den lokalen Bericht
`outputLocal/broad_consent_snapshot/reports/broad_consent_snapshot_report.xlsx`.
Er enthält für jede Relation insbesondere Ein- und Ausgabezeilen,
Versionspartition, Chunk-Anzahl, Laufzeiten und Filteraktion sowie die
Anzahl der Patienten und Ressourcenzeilen je Entscheidungsgrund. Dieser lokale
Bericht ist nicht Bestandteil der Snapshot-Datei. Die dauerhafte
Maskierungsnachweistabelle wird dagegen immer mitgesichert, auch ohne
`--consent-details`. Detaillierte CSV-Berichte liegen bei Aktivierung in einem
eigenen Laufverzeichnis unter `outputLocal/broad_consent_snapshot`.
Die Datei `COMPLETE` zeigt an, dass die Consent-Berichte vollständig geschrieben
sind. Das Schreiben der Snapshot-Daten und des Dumps ist damit noch nicht
bestätigt. Für die
Weitergabe des Snapshots muss deshalb der gesamte Befehl erfolgreich beendet
sein; `COMPLETE` allein bestätigt noch keinen fertigen Snapshot.

Eine kompakte CLI-Hilfe liefert:

```bash
./ip-snapshot.sh
```

Nach erfolgreicher Pseudonymisierung endet die Ausgabe mit einem deutlich
hervorgehobenen Hinweis auf `snapshot_pseudonymization_issues.xlsx`. Wenn der
Prozess Probleme gefunden hat, nennt die direkte R-Ausgabe außerdem deren
Gesamtzahl.
