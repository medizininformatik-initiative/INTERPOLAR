# Zentrale Analysen

Zentrale Skripte verarbeiten eingesammelte dezentrale Standortergebnisse.
Eingaben bleiben unverändert unter `inputGlobal/<standort>/<export-id>/outputGlobal/`,
Ausgaben unter `outputCentral/<analyse>/<lauf>/`. Beide Ablagen sind Git-ignoriert.

Verwendete Exporte werden explizit ausgewählt. Es gibt keinen automatischen
Nextcloud-Abruf und keine implizite Auswahl des neuesten Exports. Jeder Lauf
soll Quellen und Codeversion dokumentieren.

Vor fachlicher Aggregation sind Format, Zeitraum, Version, Mehrfachzählungen und
bereits erfolgte Unterdrückung kleiner Fallzahlen zu prüfen. Prozentwerte oder
Mediane dürfen nicht ohne ihre Berechnungsgrundlage zusammengeführt werden.
Fehlende Exporte und gültige leere Ergebnisse sind getrennt zu behandeln.

Der erste ausführbare Einstieg ist die reine Dateieingabeprüfung unter `mrp-check/`.
Reporting und Datenqualität sind zunächst dokumentierte Erweiterungspunkte.
