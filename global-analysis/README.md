# Standortübergreifende Auswertungen

Dieser Bereich enthält den versionierten Code für zentrale Auswertungen der
`outputGlobal`-Exporte aus den Standorten. Die Ausführung erfolgt manuell in der
Konsole mit `Rscript`, bei Bedarf über den bestehenden Docker-Service `r-env`.
Es werden keine Datenbankverbindungen oder automatischen Nextcloud-Downloads gestartet.

## Umfang des Grundgerüsts

Der Einstiegspunkt `analyses/mrp-check/run.R` prüft zunächst die explizit ausgewählten
Eingabedateien und schreibt ein Eingabemanifest. Er liest noch keine Excel-Inhalte
und berechnet keine standortübergreifenden MRP-Kennzahlen. Ein erfolgreicher Lauf
bestätigt nur, dass die ausgewählten Dateien vorhanden, lesbar und nicht null Byte groß sind.
Eine Excel-Datei mit leerer Ergebnistabelle wird dadurch nicht erkannt.

## Struktur und lokale Daten

```text
global-analysis/
├── README.md
├── R/                         # gemeinsame, datenbankunabhängige Funktionen
├── analyses/mrp-check/run.R    # Konsoleneinstiegspunkt für die Eingabeprüfung
├── config/
│   ├── sites_example.csv       # versionierte Vorlage mit fiktiven Standorten
│   └── sites.csv               # lokale Auswahl, Git-ignoriert
└── data/                       # vollständig Git- und Docker-Build-ignoriert
    ├── input/<site_id>/<export_id>/outputGlobal/…
    └── results/mrp-check/<run-id>/input-manifest.csv
```

Die Skripte legen die Datenordner bei Bedarf an. Ein Ordner für Zwischenergebnisse
ist nicht vorgesehen. Weitere Analysen, etwa Reporting, Datenqualitätsanalyse und
Kohortenbeschreibung, erhalten bei ihrer Umsetzung eigene Einstiegspunkte unter
`analyses/`. Gemeinsame Funktionen kommen nur bei konkretem Bedarf unter `R/` hinzu.

## Vorbereitung

Alle folgenden Befehle aus dem INTERPOLAR-Projektverzeichnis ausführen.

```bash
mkdir -p global-analysis/data/input
cp global-analysis/config/sites_example.csv global-analysis/config/sites.csv
```

Die Standortexporte manuell aus Nextcloud herunterladen und unverändert unter
`data/input/<site_id>/<export_id>/outputGlobal/` ablegen. Beispielsweise:

```text
global-analysis/data/input/SITE_A/2026-10-14/outputGlobal/dataprocessor/tables/MRP_Check_Result_global.xlsx
```

In `config/sites.csv` pro Standort genau einen Export auswählen. `site_id` und
`export_id` entsprechen den Ordnernamen und bestehen aus Buchstaben, Ziffern,
Bindestrichen und Unterstrichen; sie beginnen mit Buchstabe oder Ziffer.
`mrp_check_file` ist der genaue relative Dateipfad innerhalb dieses `outputGlobal`.
Bei abweichenden Dateinamen, beispielsweise mit Zeitstempel, den tatsächlichen
Namen eintragen. Es gibt keine automatische Auswahl des neuesten Exports.

Die Vorlage enthält nur Beispiele; nicht verfügbare Beispielstandorte entfernen.
Lokale Daten und die Auswahl werden weder eingecheckt noch ins Docker-Image kopiert.
Neue Analysen müssen ihre Ergebnisse ebenfalls unter `data/results/` schreiben;
weitere lokale Konfigurationen benötigen einen eigenen Git- und Docker-Ausschluss.

## Konsolenaufruf

Mit vorhandenem `r-env`-Image:

```bash
docker compose run --rm --no-deps \
  -v "${PWD}/global-analysis:/src/global-analysis" \
  r-env Rscript global-analysis/analyses/mrp-check/run.R
```

Der zusätzliche Mount stellt aktuellen Analysecode und lokale Daten bereit und
schreibt Ergebnisse auf den Host zurück. Eine Änderung an der lokalen Compose-Datei
oder ein Image-Neubau ist für diesen Bereich nicht erforderlich. `--no-deps`
verhindert den Start der Datenbank- und REDCap-Dienste. Alternativ mit lokalem R:

```bash
Rscript global-analysis/analyses/mrp-check/run.R
Rscript global-analysis/analyses/mrp-check/run.R --help
```

Ein optionales Positionsargument ersetzt den Pfad zur lokalen Auswahl:

```bash
Rscript global-analysis/analyses/mrp-check/run.R global-analysis/config/sites.csv
```

Fehlende Eingaben, doppelte Standorte und ungültige Pfade führen zu einem Fehler
mit von null verschiedenem Exitstatus. Erst nach erfolgreicher Prüfung aller
ausgewählten Dateien wird ein neuer Ergebnisordner angelegt. Vorherige Ergebnisse
werden nicht überschrieben. Das Manifest enthält Standort, Exportkennung,
Dateipfad, MD5-Dateiprüfsumme, Prüfsumme der Auswahl, Prüfzeit in UTC und den
Git-Commit, soweit verfügbar. Die Prüfsummen dienen der Wiedererkennung der
Eingabedateien. Für nachvollziehbare Auswertungen einen committed Code-Stand verwenden;
das Manifest erfasst keine uncommitteten Änderungen.

## Regeln für die spätere MRP-Aggregation

- Globale IDs werden je Export neu durchnummeriert. IDs sind deshalb mindestens
  zusammen mit Standort und Exportkennung zu betrachten. Eine stabile Identität
  über mehrere Exporte darf nicht angenommen werden.
- Metadatenzeilen am Ende des MRP-Exports sind keine MRP-Ergebnisse.
- Eine leere Ergebnistabelle, eine fehlende Datei und ein fehlgeschlagener
  Standortlauf müssen getrennt ausgewiesen werden.
- Vor der Aggregation müssen Schema, Exportversion und Auswertungszeitraum der
  tatsächlichen Standortdateien geprüft werden. Diese fachliche Prüfung wird im
  nächsten Schritt anhand von Exportbeispielen implementiert.
