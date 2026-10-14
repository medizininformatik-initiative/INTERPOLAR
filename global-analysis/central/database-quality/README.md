# Zentrale Auswertung der Datenqualität

Vorgesehen sind dateibasierte Fragestellungen auf den Standortergebnissen der
`Database_Quality_Analysis`, ohne erneuten Datenbankzugriff. Das bestehende Modul
liefert eine Excel-Zählzusammenfassung und ein ZIP mit CSV-Wertezusammenfassungen
unter `FHIR/` und `Frontend/`.

Die konkrete Fragestellung legt fest, ob CSVs entpackt bereitgestellt oder aus dem
ZIP gelesen werden. Benötigte Spalten, Exportversionen und die gewünschte Berechnung
sind vor der Implementierung festzulegen; Mediane und Quartile der Standorte sind
nicht einfach zu mitteln.

Eingang: `inputGlobal/<standort>/<export-id>/outputGlobal/…`.
Ergebnisse und Laufnachweis: `outputCentral/database-quality/<lauf>/`.
Ein ausführbares Auswertungsskript ist hier noch nicht enthalten.
