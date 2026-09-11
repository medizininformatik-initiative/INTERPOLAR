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

## Wegweiser

Der Standardablauf ist **Rohsnapshot → Pseudonymisierung → Broad-Consent-Auswahl**.
Diese Seite beschreibt die Bedienung. Die technischen Hintergründe stehen in
zwei eigenen Dokumenten, in derselben Reihenfolge wie die Verarbeitung:

1. [Pseudonymisierung](Database_Snapshot_Pseudonymization.md): Tabellenaufbau,
   Regeln, Anreicherungen und Prüfberichte.
2. [Broad Consent](Database_Snapshot_Broad_Consent.md): Auswertung der
   Consent-Ressourcen, Berechnung der erlaubten Zeiträume und Ressourcenfilterung.

### Auf dieser Seite

- [Voraussetzungen](#voraussetzungen)
- [Befehle](#befehle)
- [Ablauf bis zur Prüfung](#ablauf-bis-zur-prüfung)
- [Prüfung vor der Weitergabe](#prüfung-vor-der-weitergabe)
- [Verhalten bei Fehlern](#verhalten-bei-fehlern)
- [Auswertungen ohne Datenbank-Cronjob](#auswertungen-ohne-datenbank-cronjob)

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

- [Rohsnapshot erstellen](#normale-snapshot-datei-erstellen)
- [Rohsnapshot und Pseudonymisierung zusammen ausführen](#normale-und-pseudonymisierte-snapshot-dateien-zusammen-erstellen)
- [Vorhandenen Snapshot pseudonymisieren](#vorhandene-snapshot-datei-pseudonymisieren)
- [Broad-Consent-Snapshot erstellen](#broad-consent-snapshot-erstellen)
- [Consent-Auswertung prüfen](#consent-auswertung-ohne-snapshot-erzeugung-prüfen)
- [Chunkgröße anpassen](#chunkgröße-anpassen)
- [Snapshots anzeigen](#snapshot-dateien-und-snapshot-datenbanken-anzeigen)
- [Snapshot aktivieren](#snapshot-datenbank-aktivieren)
- [Snapshot deaktivieren](#snapshot-datenbank-deaktivieren)
- [Snapshot-Datei löschen](#snapshot-datei-löschen)

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
Laufs gültig sein. Die Einwilligung zur Datenerhebung (`.6`) legt fest, aus
welchen Zeiträumen Daten übernommen werden dürfen. Für jede klinische Ressource
muss ihr maßgebliches Datum beziehungsweise ihr gesamter Zeitraum abgedeckt
sein. Retrospektive Freigaben können diese Datenzeiträume erweitern; Widerrufe
werden bei der Berechnung berücksichtigt. Das Bewertungsdatum wird am Start
einmalig festgehalten, damit während des gesamten Laufs derselbe Stichtag gilt.
Die [technische BC-Beschreibung](Database_Snapshot_Broad_Consent.md#berechnung-der-patientenzulassung-und-datenzeiträume)
erläutert die einzelnen Rechenschritte und enthält Beispiele.

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

## Auswertungen ohne Datenbank-Cronjob

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

Eine kompakte CLI-Hilfe liefert `./ip-snapshot.sh`.
