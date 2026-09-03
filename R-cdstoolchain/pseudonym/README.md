# pseudonym

Das Paket `pseudonym` enthält die Logik zum Erzeugen pseudonymisierter
INTERPOLAR-Snapshot-Datenbanken. Es liest die Pseudonymisierungsregeln aus den Table Descriptions,
prüft Regeln und benötigte Mapping-Werte und verarbeitet die ausgewählten Datenbanktabellen
chunkweise. Dabei entstehen auch die zusätzlichen Auswertungsspalten und Prüfberichte des
pseudonymisierten Snapshots.

[`ip-snapshot.sh`](../../ip-snapshot.sh) steuert außerhalb des Pakets den Datei- und
Datenbanklebenszyklus. Für seine Vorprüfung und Pseudonymisierung ruft es
[`StartSnapshotPseudonymizationPreflight.R`](../StartSnapshotPseudonymizationPreflight.R) und
[`StartSnapshotPseudonymization.R`](../StartSnapshotPseudonymization.R) auf; diese übergeben die
eigentliche Verarbeitung an `pseudonym`. Der technische Broad-Consent-Schritt läuft entsprechend
über [`StartBroadConsentSnapshot.R`](../StartBroadConsentSnapshot.R) und filtert derzeit noch keine
Daten.

FHIR-Import, reguläre fachliche Verarbeitung und Frontend-Synchronisation gehören nicht zu diesem
Paket. Den vollständigen Snapshot-Ablauf, die Regeln und die erzeugten Berichte beschreibt
[`Database_Snapshot.md`](../../Database_Snapshot.md).

Die paketbezogenen `testthat`-Tests liegen unter [`tests/testthat`](tests/testthat). Sie prüfen
insbesondere Regelübersetzung, Mapping-Abdeckung, chunkweise Verarbeitung, Anreicherungen,
Snapshot-Materialisierung und den technischen Broad-Consent-Ablauf.
