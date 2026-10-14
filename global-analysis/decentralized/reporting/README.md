# Dezentrales Reporting

Die bestehende Implementierung liegt unter
`R-dataprocessor/submodules/manual_start/Statistical_Reports/`.
Sie liest die in ihrer `database.toml` ausgewählte Standortdatenbank und erzeugt
einen HTML-Bericht unter `outputGlobal/dataprocessor/reports`.

Der bisherige Aufruf bleibt gültig:

```bash
docker compose run --rm --no-deps r-env \
  Rscript R-dataprocessor/StartDataProcessor.R statistical-reports
```

Dieser Ordner ist der vorgesehene Migrationspunkt. Dabei sind die Modulinitialisierung
durch explizite Analysekonfiguration zu ersetzen, Ergebnisgleichheit zu prüfen und
bisherige Aufrufe kompatibel zu halten. Fachlogik wird wiederverwendet, nicht kopiert.
Für die zentrale Weiterverarbeitung ist ein verbindliches maschinenlesbares Format
für die sechs Berichtstabellen einschließlich Zeitraum und Version festzulegen.
