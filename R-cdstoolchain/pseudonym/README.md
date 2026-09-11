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
eigentliche Verarbeitung an `pseudonym`. Die Broad-Consent-Auswahl läuft entsprechend
über [`StartBroadConsentSnapshot.R`](../StartBroadConsentSnapshot.R) und übernimmt nur
die durch die Consent-Auswertung zugelassenen Patienten und Ressourcen. Referenzen auf dabei
ausgeschlossene Ressourcen werden entfernt und als maskiert dokumentiert.

FHIR-Import, reguläre fachliche Verarbeitung und Frontend-Synchronisation gehören nicht zu diesem
Paket. Die Dokumentation ist entsprechend dem Ablauf gegliedert:

- [Bedienung und Befehle](../../Database_Snapshot.md)
- [Pseudonymisierungsregeln und Anreicherungen](../../Database_Snapshot_Pseudonymization.md)
- [Broad-Consent-Regeln und Berechnung](../../Database_Snapshot_Broad_Consent.md)

Die paketbezogenen `testthat`-Tests liegen unter [`tests/testthat`](tests/testthat). Sie prüfen
insbesondere Regelübersetzung, Mapping-Abdeckung, chunkweise Verarbeitung, Anreicherungen,
Snapshot-Materialisierung und die Broad-Consent-Auswahl.
