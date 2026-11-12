# OPS-Jahreskataloge 2023–2026

Diese unveränderten FHIR-Pakete stammen vom zentralen Terminologieserver des
Bundesinstituts für Arzneimittel und Medizinprodukte (BfArM). `sources.json`
enthält Downloadquelle, Paketversion, SHA-256-Prüfsumme und Anzahl endständiger
Codes je Jahr. Die Pakete enthalten die vollständigen Jahreskataloge und die
expandierten ValueSets `OPS_Terminale_Kodes`.

## Quellenangabe und Nutzungsbedingungen

Herausgegeben vom Bundesinstitut für Arzneimittel und Medizinprodukte (BfArM)
im Auftrag des Bundesministeriums für Gesundheit (BMG).

Die Erstellung erfolgt unter Verwendung der maschinenlesbaren Fassung des
Bundesinstituts für Arzneimittel und Medizinprodukte (BfArM).

Die OPS-Daten unterliegen den BfArM-Bedingungen, nicht der Apache-2.0-Lizenz des
Programmcodes. Die beim Abruf geltenden Bedingungen sind unverändert in
`BfArM-OPS-conditions.xhtml` beigefügt. § 1 erlaubt die Vervielfältigung,
Verbreitung und Zugänglichmachung unter Beachtung des Änderungsverbots und der
Quellenangabe. Diese Hinweise und die Bedingungen sind mit den Daten weiterzugeben.
Die Copyright-Angaben der jeweiligen Jahresfassung stehen außerdem in den
unveränderten FHIR-Ressourcen innerhalb der Pakete.

- [OPS-Downloadbedingungen](https://terminologien.bfarm.de/bfarm.terminologien.ops-conditions.html)
- [Vorgeschriebene Quellenangaben](https://www.bfarm.de/SharedDocs/Downloads/DE/Kodiersysteme/klassifikationen/ops/_config/Downloadbedingungen_Anhang.html?nn=841246)

## Verwendung

`etlutils::loadOPSCatalogues()` lädt die terminalen Codes der gebündelten Jahre.
`etlutils::isTerminalOPS(codes, years, catalogue)` prüft Code und Katalogjahr
gemeinsam. Die aufrufende Analyse bestimmt das Katalogjahr; der Loader leitet es
nicht aus Behandlungs- oder Aufnahmedaten ab. Der Betrieb benötigt keinen
Netzwerkzugriff und kein WP7-Input-Repo.
