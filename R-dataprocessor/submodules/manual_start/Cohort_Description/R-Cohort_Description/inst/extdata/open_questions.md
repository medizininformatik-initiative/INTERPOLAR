# Offene fachliche Fragen

## Vorläufige FAS-4-Regeln

Die FAS-4-Ergebnisse beruhen auf folgenden Arbeitsannahmen und benötigen noch
fachliche Bestätigung (Ticket #1478):

- FAS 4 ergänzt FAS 2.2 um mindestens ein algorithmisch detektiertes MRP mit
  eigener retrolektiver Bewertung im Status `Complete`.
- Es zählen alle abgeschlossenen MedAs des ersten bekannten IP-Aufenthalts.
- Bewertungen zählen bis zum Datenstand des Snapshots, auch nach Entlassung oder Studienende.
- FAS 4.1 verlangt beim selben abgeschlossenen Bewertungsinstrument
  „MRP nicht bestätigt“ und „MRP sachlich richtig, aber klinisch nicht relevant“.
- FAS 4.2 umfasst „MRP bestätigt“ sowie
  „MRP bestätigt und von Stationsapotheker vorher identifiziert“.
- FAS 4.1 und 4.2 dürfen sich überschneiden; andere Ablehnungsgründe zählen nur zu FAS 4.

Zu bestätigen sind MedA-Bezug, Verknüpfung von MRP und Bewertung, zeitlicher
Bewertungsschluss, Abschlussstatus, Relevanzkategorien, abgeschlossene Bewertung
in den Untergruppen und deren Überschneidung.

## Vorläufiges TRS-Zeitfenster

TRS verwendet einen Gesamtzeitraum vom 01.01.2023 einschließlich bis zum
01.01.2027 ausschließlich in der Projektzeitzone. Krankenhausaufnahme und erster
IP-Eintritt liegen darin; eine zusätzliche Entlassungsfrist gilt nicht.
Gesamtzeitraum statt Phasenteilung, Grenzen und Entlassungsregel sind noch zu bestätigen.

## Auswertungsumfang

Alle sieben FAS werden für BS, CRS A, CRS B, TRS und RES berechnet, einschließlich
leerer Kombinationen. BS/CRS A/CRS B stammen aus der regulären Datenbank,
TRS/RES ausschließlich aus der ausgewählten Broad-Consent-Datenbank.
RES übernimmt die Zeit- und Fallgrenzen von CRS B.

# Verbindliche Berechnungsregeln

- **ICD-Diagnosegrundlage:** Nur die Full-length-Zeilen 65/67 prüfen die
  Endständigkeit im Jahreskatalog. Dreizeichen-Zählung und Charlson verwenden
  alle interpretierbaren ICD-Diagnosen. Missing Information muss deshalb
  zwischen Full-length-Zeilen und Charlson nicht übereinstimmen.

- **Ernährung, OPS `8-015.y`:** Gültiger Code mit wörtlichem `y`; die vereinbarte
  Präfixsuche einschließlich Untercodes bleibt bestehen.
- **Alterszeilen je Geschlecht, lokal 27/32/37:** N umfasst die Fälle des jeweiligen
  Geschlechts mit verwertbarem Alter innerhalb der Auswertungsgruppe. Der
  geschlechtsübergreifende Nenner steht separat in der Gesamtauswertung.
