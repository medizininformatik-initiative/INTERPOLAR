# Dezentrale Analysen am DIZ

Hier werden eigenständige Fragestellungen auf dem lokalen Snapshot oder lokalen
Dateien ausgeführt. Jede Analyse erhält einen Ordner mit `Start.R`, README und bei
Bedarf einer Konfigurationsvorlage. Der Konsolenstart initialisiert keinen DataProcessor.

Zur Weitergabe bestimmte Ergebnisse: `outputGlobal/analyses/<analyse>/<lauf>/`.
Lokale Detaildaten und Logs: `outputLocal/analyses/<analyse>/<lauf>/`.
Die erforderliche Aggregation bzw. Pseudonymisierung wird je Fragestellung festgelegt;
die Ordnerwahl allein macht Daten nicht weitergabefähig.

Bestehende Reporting- und Datenqualitätsmodule verbleiben zunächst unter
`R-dataprocessor/submodules/manual_start/`. Die Unterordner dokumentieren ihre spätere
Migration; ausführbare Ersatzimplementierungen sind hier noch nicht enthalten.
