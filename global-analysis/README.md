# Dezentrale und zentrale Analysen

Dieser Bereich enthält versionierten Analysecode für zwei Stufen:

1. **Dezentral:** Ein DIZ führt eine Fragestellung auf seinem lokalen Snapshot oder
   auf lokalen Dateien aus. Zur Weitergabe bestimmte Ergebnisse landen unter
   `outputGlobal/analyses/<analyse>/<lauf>/`; lokale Details und Logs unter
   `outputLocal/analyses/<analyse>/<lauf>/`.
2. **Zentral:** Eine Auswertung liest eingesammelte Standortergebnisse unter
   `inputGlobal/` und schreibt Ergebnisse sowie Laufnachweise unter `outputCentral/`.

`outputGlobal` bezeichnet zur Weitergabe bestimmte Standortergebnisse, nicht bereits
zentral aggregierte Ergebnisse. Die Übertragung, beispielsweise über Nextcloud,
erfolgt manuell. Alle Pfade beziehen sich auf das INTERPOLAR-Projektverzeichnis.

## Struktur

```text
global-analysis/                          # versionierter Analysecode
├── README.md
├── R/                                   # gemeinsam benötigte Funktionen
├── decentralized/
│   ├── reporting/                       # dokumentierter Migrationspunkt
│   └── database-quality/                # dokumentierter Migrationspunkt
└── central/
    ├── reporting/                       # vorgesehene zentrale Auswertung
    ├── database-quality/                # vorgesehene zentrale Auswertung
    └── mrp-check/
        ├── Start.R                      # zunächst nur Eingabeprüfung
        └── config/sites_example.csv

inputGlobal/<standort>/<export-id>/outputGlobal/…    # eingegangene Exporte
outputGlobal/analyses/<analyse>/<lauf>/…             # dezentrale Exporte
outputLocal/analyses/<analyse>/<lauf>/…              # dezentrale Details und Logs
outputCentral/<analyse>/<lauf>/…                    # zentrale Ergebnisse
```

Datenordner und lokale Standortauswahl sind Git-ignoriert und vom Docker-Build
ausgeschlossen. Sie werden bei der Einrichtung bzw. beim jeweiligen Lauf angelegt.
Es gibt keinen `intermediate/`-Ordner und keine RStudio-Projektdatei.

`inputGlobal/` ist die Eingabeablage für zentrale Analysen. Das vorhandene
`Input-Repo` enthält dagegen Regelwerke und Mappingdefinitionen, etwa aus WP7.
Standortexporte gehören nicht in dieses Regel-Repository.

## Abgrenzung zum DataProcessor

Der DataProcessor enthält bereits manuelle Auswertungen. Die Trennung ist deshalb
eine Zuständigkeit mit eigenem Startweg:

- Neue eigenständige Fragestellungen erhalten einen Ordner unter `decentralized/`
  oder `central/`, mit `Start.R`, README und bei Bedarf einer Konfigurationsvorlage.
- Sie starten direkt per `Rscript`, ohne `StartDataProcessor.R` oder dessen
  Modulinitialisierung. Quelldatenbanken und Eingabedateien werden nur gelesen.
- Snapshot-Zugriffe nutzen vorhandene Verbindungshilfen mit expliziter Konfiguration.
  Dateianalysen setzen keine Datenbankverbindung voraus.
- Gemeinsame Helfer, insbesondere aus `etlutils`, werden bei Bedarf wiederverwendet.
  Fachlogik bestehender Reports wird nicht dupliziert.
- Bestehende Module unter `R-dataprocessor/submodules/manual_start/` behalten vorerst
  ihre Aufrufe und Ausgabepfade. Ihre Überführung nach `decentralized/` ist eine eigene
  Migration mit Prüfung der Ergebnisgleichheit und Kompatibilität bisheriger Aufrufe.

Jede Analyse beschreibt Datenquelle, Parameter, benötigte Pakete und Ausgaben in
ihrer README. Lokale Konfigurationen benötigen explizite Git- und Docker-Ausschlüsse;
Vorlagen werden versioniert. Der Exportumfang wird je Fragestellung festgelegt.

## Bisheriges Reporting

`Statistical_Reports` liest die ausgewählte Standortdatenbank und erzeugt einen
HTML-Bericht unter `outputGlobal/dataprocessor/reports`. Die Tabellen können darin
als CSV oder Excel heruntergeladen werden. Das ist der dezentrale Teil; eine zentrale
Zusammenführung ist darin nicht implementiert. Dieses Grundgerüst verschiebt noch
keine bestehenden Module und implementiert noch keine fachliche Aggregation.

## Konsolenstart und Docker

Alle Aufrufe erfolgen aus dem INTERPOLAR-Projektverzeichnis. Mit lokalem R:

```bash
Rscript global-analysis/central/mrp-check/Start.R --help
```

Mit vorhandenem `r-env`-Image:

```bash
mkdir -p inputGlobal outputCentral
docker compose run --rm --no-deps \
  -v "${PWD}/global-analysis:/src/global-analysis:ro" \
  -v "${PWD}/inputGlobal:/src/inputGlobal:ro" \
  -v "${PWD}/outputCentral:/src/outputCentral" \
  r-env Rscript global-analysis/central/mrp-check/Start.R --help
```

Für die Eingabeprüfung `--help` weglassen; vorher die
[Exportauswahl einrichten](central/mrp-check/README.md). Code und zentrale Eingaben
sind schreibgeschützt eingebunden, Ergebnisse werden auf dem Host gespeichert.
`--no-deps` startet keine abhängigen Datenbank- oder REDCap-Dienste.
Die lokale Compose-Datei und das Image müssen dafür nicht geändert werden.

Dezentrale Analysen nutzen die vorhandenen Mounts für `outputGlobal` und `outputLocal`.
Zusätzliche Eingabedateien werden je Analyse explizit und schreibgeschützt eingebunden.
Bei Snapshot-Analysen muss die konfigurierte Datenbank erreichbar sein.
