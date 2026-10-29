# TOP-Vergleichslauf mit Optimierung

Nach Abschluss des Referenzlaufs im INTERPOLAR-Hauptverzeichnis:

```bash
git fetch origin
git switch top-study-analysis-optimized
git pull --ff-only
./run-top-study.sh
```

Denselben Snapshot und dieselben TOML-Dateien unverändert weiterverwenden. Beide Läufe nacheinander bei möglichst ähnlicher Systemlast ausführen und ihre lokalen Ausgabeordner behalten.

Der Aufruf baut automatisch ein lokales Image mit TOP 2.0.0, Modellpaket 1.1.1 und der Codehierarchie-Optimierung aus [TOP-PR #158](https://github.com/Onto-Med/top-phenotypic-query/pull/158). Der erste Bau lädt zusätzlich das Java-Compiler-Image und den festgelegten PR-Quelltext herunter; weitere Aufrufe nutzen den Docker-Build-Cache. Das offizielle TOP-Image bleibt erhalten.

Fortschritt: `outputLocal/top-study/<Lauf>/image-build.log` beim Bau, danach Terminal und `progress.log`. Vorbereitung und Plausibilitätsprüfung stehen in `preparation.log` und `plausibility.log`.

Nach Erfolg oder Abbruch ausschließlich `outputGlobal/top-study/<Lauf>/TOP_Report_YYYY-MM-DD_HH-MM-SS.txt` hochladen. Der Bericht enthält Algorithmuslaufzeiten, Fallauswahl, Plausibilitätsprüfung und den Optimierungsstand. Die Bauzeit steht separat in `image-build.tsv` im Bericht: Sie ist in der Gesamtlaufzeit enthalten und muss beim Vergleich abgezogen werden. Die Algorithmuslaufzeiten enthalten sie bereits nicht.

ZIPs einschließlich Metadaten, Modellkopien und Rohlogs bleiben unter `outputLocal` für den lokalen Ergebnisvergleich. Es werden dieselben 118 Auswertungen wie im Referenzlauf ausgeführt.

Der Dateiname enthält die lokale Startzeit am Standort, zum Beispiel `TOP_Report_2026-10-29_14-35-22.txt`.
