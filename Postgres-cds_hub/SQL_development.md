# SQL-Entwicklung im CDS-HUB

Diese Hinweise beschreiben, wie SQL-Skripte im CDS-HUB gepflegt werden und welche
Prüfungen in GitHub Actions laufen.

## Grundprinzip

Die SQL-Dateien unter `Postgres-cds_hub/sql/` bleiben im Repository sichtbar und
können in GitHub je Version gelesen und verglichen werden.

Ein Teil dieser Dateien wird jedoch aus Templates erzeugt. Diese Dateien enthalten
im Kopf den Hinweis:

```sql
-- This file is generated. Changes should only be made by regenerating the file.
```

Solche Dateien sollen nicht direkt geändert werden. Die fachliche Änderung erfolgt
an den Quellen, also an Templates, Excel-Definitionen oder Generator-Code. Danach
werden die SQL-Dateien neu erzeugt und mitcommitted.

## Kurzablauf für SQL-Änderungen

- Manuelle SQL-Datei geändert: SQL-Datei committen und pushen. Wenn der
  Format-Check fehlschlägt, den GitHub-Workflow **Format SQL** auf dem eigenen
  Branch starten.
- Template, Excel-Definition oder Generator geändert: Generator ausführen,
  `Postgres-cds_hub/generated/sql/` nach `Postgres-cds_hub/sql/` übernehmen und
  Quellen plus erzeugte SQL-Dateien gemeinsam committen.
- Migration und Docker verwenden immer den committed Stand unter
  `Postgres-cds_hub/sql/`, nicht das lokale `generated/sql/`-Verzeichnis.

## Welche Dateien werden manuell geändert?

Manuell gepflegte SQL-Dateien sind insbesondere:

- `Postgres-cds_hub/sql/init/*.sql`
- `Postgres-cds_hub/sql/recalculations/*.sql`
- `Postgres-cds_hub/sql/base/000_stop_semapore_during_run.sql`
- `Postgres-cds_hub/sql/base/020_db_config_tools.sql`
- `Postgres-cds_hub/sql/base/030_db_parameter.sql`
- `Postgres-cds_hub/sql/base/035_db_log_table_structure.sql`
- `Postgres-cds_hub/sql/base/950_cro_job.sql`
- `Postgres-cds_hub/sql/base/980_dev_and_test.sql`
- `Postgres-cds_hub/sql/base/999_start_semapore_after_run.sql`

Wenn nur eine dieser Dateien geändert wird, muss der SQL-Generator nicht lokal
ausgeführt werden.

## Welche Dateien werden generiert?

Generierte Ergebnisdateien liegen vor allem unter:

- `Postgres-cds_hub/sql/start.sql`
- `Postgres-cds_hub/sql/base/*.sql` mit generiertem Header

Die Quellen für diese Dateien sind:

- `Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx`
- `Postgres-cds_hub/sql/template/*.sql`
- `R-cds2db/cds2db/inst/extdata/Table_Description.xlsx`
- `R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx`
- `Postgres-cds_hub/R-initcdstoolchain/initcdstoolchain/R/Init_02_Create_Database_Scripts.R`

## Manuelles SQL ändern

1. SQL-Datei unter `Postgres-cds_hub/sql/` ändern.
2. Änderung committen und pushen.
3. GitHub Actions prüft die Formatierung.

Wenn die Formatierung nicht passt, kann der Workflow **Format SQL** in GitHub
manuell gestartet werden. Dieser Workflow formatiert die manuell gepflegten
SQL-Dateien und committet die Änderungen zurück in den Branch.

Für Entwicklung ohne lokale Formatter-Installation, z.B. unter Windows mit einem
einfachen Texteditor, ist das der empfohlene Weg:

1. SQL-Datei bearbeiten.
2. Änderungen committen und pushen.
3. In GitHub den Branch bzw. Pull Request öffnen.
4. Wenn der Check **SQL checks / sql-format** fehlschlägt, in GitHub
   **Actions** öffnen.
5. Links den Workflow **Format SQL** auswählen.
6. **Run workflow** anklicken.
7. Unter **Use workflow from** den eigenen Branch auswählen.
8. **Run workflow** bestätigen.
9. Warten, bis der Workflow fertig ist. Er pushed einen Formatierungs-Commit auf
   denselben Branch.
10. Danach den Pull Request erneut prüfen; die SQL-Checks laufen durch den neuen
    Commit automatisch noch einmal.

Der Workflow muss nur gestartet werden, wenn SQL-Formatierung fehlt oder lokal
kein `pg_format` verfügbar ist. Bei reinen Template-/Excel-Änderungen ersetzt er
keinen Generatorlauf.

Lokal kann die Formatierung der manuell gepflegten SQL-Dateien ebenfalls
ausgeführt werden, wenn `pg_format` installiert ist:

```sh
tools/format-sql.sh
```

Der lokale Format-Check ist:

```sh
tools/check-sql-format.sh
```

Dieser Check prüft standardmäßig nur manuell gepflegte SQL-Dateien und ist deshalb
schnell.

## Generierte SQL-Dateien ändern

Wenn Templates, Excel-Definitionen oder Generator-Code geändert werden, müssen die
generierten SQL-Dateien aktualisiert und mitcommitted werden.

Mit lokal installierter R-Umgebung und `pg_format`:

```sh
bash Postgres-cds_hub/generate-sql.sh
cp -R Postgres-cds_hub/generated/sql/. Postgres-cds_hub/sql/
```

Danach sollten die Änderungen an Templates, Excel-Dateien und den erzeugten
SQL-Dateien gemeinsam committed werden.

Der Drift-Check prüft, ob die versionierten generierten SQL-Dateien zum aktuellen
Generatoroutput passen:

```sh
tools/check-generated-sql.sh
```

Dieser Check dauert mehrere Minuten, weil der komplette SQL-Output neu erzeugt,
formatiert und verglichen wird.

## GitHub Actions

Der Workflow `SQL checks` erkennt geänderte Dateien und startet nur die nötigen
Jobs:

- Änderungen an manuell gepflegten SQL-Dateien starten `sql-format`.
- Änderungen an Templates, Excel-Definitionen, Generator-Code oder generierten
  SQL-Dateien starten `generated-sql-drift`.
- Änderungen ohne SQL-Bezug starten keinen SQL-Prüfjob außer der kurzen
  Änderungserkennung.

Der Workflow `Format SQL` kann manuell gestartet werden, wenn SQL-Dateien auf
GitHub formatiert werden sollen. Er formatiert die manuell gepflegten
SQL-Dateien. Das ist besonders hilfreich, wenn lokal kein Formatter installiert
ist.

## Docker-Setup

Beim Start über Docker Compose verwendet die CDS_HUB-Datenbank die versionierten
SQL-Dateien unter `Postgres-cds_hub/sql/`. Es wird beim Start kein zusätzlicher
Generatorlauf ausgeführt.

Die versionierten SQL-Dateien bleiben damit die einzige direkt verwendete
Installationsfassung für Review, Historie und Docker-Betrieb. Die CI stellt
sicher, dass die generierten Dateien nicht vom Generatoroutput abweichen.
