# Offene fachliche Fragen

## FAS 4, 4.1 und 4.2

FAS 4 ergänzt FAS 2.2 um mindestens ein algorithmisch berechnetes MRP und
mindestens eine retrolektive Bewertung im Status `Complete`. Beide gehören
zur ersten abgeschlossenen MedA im ersten bekannten IP-Aufenthalt. Die Bewertung
darf ein anderes MRP derselben MedA betreffen und später abgeschlossen worden sein.

Für FAS 4.1 beziehungsweise 4.2 muss ein berechnetes MRP derselben MedA selbst
eine abgeschlossene Bewertung haben. Für 4.1 zählt „MRP nicht bestätigt“ mit
„MRP sachlich richtig, aber klinisch nicht relevant“. Für 4.2 zählen beide
Bestätigungsvarianten. Ein Fall kann über unterschiedliche MRPs in beide
Untergruppen fallen.

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
