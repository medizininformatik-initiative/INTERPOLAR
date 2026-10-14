# Dezentrale Datenqualitätsanalyse

Die bestehende Implementierung liegt unter
`R-dataprocessor/submodules/manual_start/Database_Quality_Analysis/`.
Sie liest die ausgewählte Standortdatenbank und schreibt eine Excel-Zusammenfassung
sowie ein ZIP mit CSV-Wertezusammenfassungen unter `outputGlobal/dataprocessor/reports`.

Der bisherige Aufruf bleibt gültig:

```bash
docker compose run --rm --no-deps r-env \
  Rscript R-dataprocessor/StartDataProcessor.R database-quality-analysis
```

Dieser Ordner dokumentiert die spätere Migration. Eine eigenständige Ausführung muss
vorhandene Fachfunktionen wiederverwenden, Konfiguration explizit übergeben und
Ergebnisgleichheit sowie Kompatibilität der bisherigen Aufrufe prüfen.
