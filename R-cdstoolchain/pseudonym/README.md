# pseudonym

`pseudonym` stellt die Pseudonymisierungslogik für INTERPOLAR-Snapshot-Datenbanken
bereit. Das Paket übersetzt FHIR-Regeln in Table Descriptions, prüft Regeln und
Mapping-Abdeckung und materialisiert pseudonymisierte beziehungsweise technische
Broad-Consent-Snapshot-Datenbanken. Den Datei- und Datenbanklebenszyklus steuert hingegen
[`ip-snapshot.sh`](../../ip-snapshot.sh); FHIR-Import, fachliche Verarbeitung und
Frontend-Synchronisation bleiben Aufgaben der übrigen Module.

## Öffentliche Einstiege

Die [`NAMESPACE`](NAMESPACE) exportiert:

- `setFhirPseudonymizationRules()` zum Ergänzen einer expandierten FHIR Table Description,
- `preflightSnapshotPseudonymization()` zur Regel- und Mapping-Prüfung,
- `pseudonymizeSnapshotDatabase()` zur materialisierten Pseudonymisierung einer Snapshot-Datenbank,
- `createBroadConsentSnapshotDatabase()` für den technischen Broad-Consent-Snapshot.

Die R-seitigen Einstiegsskripte sind
[`StartSnapshotPseudonymization.R`](../StartSnapshotPseudonymization.R),
[`StartSnapshotPseudonymizationPreflight.R`](../StartSnapshotPseudonymizationPreflight.R) und
[`StartBroadConsentSnapshot.R`](../StartBroadConsentSnapshot.R). Bedienung, Voraussetzungen,
Prüfhinweise und technische Details des regulären Ablaufs beschreibt
[`Database_Snapshot.md`](../../Database_Snapshot.md).

## Tests und weitere Orientierung

Die paketbezogenen `testthat`-Tests liegen unter [`tests/testthat`](tests/testthat) und decken
Regelübersetzung, Mapping-Prüfung, tabellen- und chunkweise Pseudonymisierung,
Snapshot-Materialisierung, Anreicherungen und den Broad-Consent-Ablauf ab. Der Gesamtaufbau der
CDS Tool Chain ist in der [zentralen README](../../README.md) beschrieben; Installation und Betrieb
sind in [`Install.md`](../../Install.md) und [`Operation.md`](../../Operation.md) dokumentiert.
