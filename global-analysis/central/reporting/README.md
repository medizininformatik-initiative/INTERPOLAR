# Zentrale Auswertung des Reportings

Vorgesehen ist die Auswertung der dezentral erzeugten Berichtstabellen.
Das bestehende Standortmodul erzeugt HTML mit CSV-/Excel-Download je Tabelle;
ein direkter zentraler HTML-Import ist hier noch nicht implementiert.

Vor der Umsetzung sind Exportformat für die sechs Tabellen, Standortkennung,
Berichtsversion und Zeitraum festzulegen. Gesamtzeilen und Stationszeilen dürfen
nicht gemeinsam aufsummiert werden. Bereits unterdrückte kleine Fallzahlen müssen
berücksichtigt werden.

Eingang: `inputGlobal/<standort>/<export-id>/outputGlobal/…`.
Ergebnisse und Laufnachweis: `outputCentral/reporting/<lauf>/`.
