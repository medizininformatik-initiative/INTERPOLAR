# MRP-Berechnung

Grundlage für die Berechnung der MRP sind die [Excel-Listen aus dem WP7-Projekt](https://github.com/medizininformatik-initiative/INTERPOLAR-WP7).

## MRP-Arten

Für alle MRP-Arten ist die Voraussetzung, dass mind. eine Verordnung (MedicationRequest) während des aktuellen Falls mit einem ATC Code vorliegt.
Bei den indirekten Berechnungen über Proxies wird das 2. Item einer Kombination (z.B. Disease bei Drug-Disease) aus einem anderen Code (z.B. ein anderer ATC, ein LOINC oder ein OPS) abgeleitet.

- Drug-Drug
   - direkte Berechnung über MedicationRequests mit ATC Codes (seit v1.1.0)
- Drug-DrugGroup
   - direkte Berechnung über MedicationRequests mit ATC Codes (seit v1.1.0)
- Drug-Disease
   - direkte Berechnung über eine Condition mit ICD Code (seit v1.0.0)
   - indirekte Berechnung über Proxi-Medication mit ATC-Code (aus MedicationRequest, MedicationAdministration oder MedicationStatement, seit v1.0.0 )
   - indirekte Berechnung über Proxi-Prozedur mit OPS-Code (seit v1.0.0)
   - indirekte Berechnung über Proxi-Observation mit LOINC-Code (mit relativem Cutoff aus der Observation, seit v1.2.0)
   - indirekte Berechnung über Proxi-Observation mit LOINC-Code (seit Release v1.3.0)
- Drug-Niereninsuffizienz
   - seit Release v1.3.0

Drug-Drug sowie Drug-DrugGroup vergleichen immer 2 ATC Codes. 
Aus Sicht eines Mediziners kann nicht zwischen diesen MRP-Arten unterschieden werden, so dass im REDCap Drug-DrugGroup MRPs auch als Drug-Drug klassiert werden. 

## Voraussetzungen zur MRP-Berechnung

MRP werden nur für Fälle berechnet, die seit der Aufnahme auf einer Station mit der Phase B lagen, wenn der Fall mind. 14 Tage beendet ist.
Der Zeitpunkt, zu dem die MRP berechnet werden, entspricht dem Zeitpunkt der ersten Medikationsanalyse im Fallzeitraum.
Berechnete MRP werden in REDCap im Instrument `retrolektive_mrpbewertung` angezeigt und in der Datenbank unter `db_log.retrolektive_mrpbewertung_fe` gespeichert.
