# cdstoolchain

`cdstoolchain` ist die Orchestrierungsschicht der INTERPOLAR-R-Module. Sie koordiniert deren
Initialisierung und Ausführungsreihenfolge, implementiert aber weder FHIR-Import noch fachliche
Datenverarbeitung, Datenbank-/Frontend-Synchronisation oder Pseudonymisierung selbst. Diese Logik
bleibt in `cds2db`, `dataprocessor`, `db2frontend`, `etlutils` und `pseudonym`.

## Öffentliche Einstiege

Das Paket exportiert derzeit keine R-Funktionen; seine [`NAMESPACE`](NAMESPACE) ist leer. Die
tatsächlichen Einstiege liegen als Skripte im übergeordneten Verzeichnis:

- [`StartCDSToolChainWithVacuum.sh`](../../StartCDSToolChainWithVacuum.sh) ist der dokumentierte
  Einstieg für den vollständigen regulären Lauf einschließlich `VACUUM (ANALYZE)`.
- [`StartCDSToolChain.R`](../StartCDSToolChain.R) führt die reguläre Modulkette aus.
- [`StartDataImport.R`](../StartDataImport.R) steuert vollständige oder ressourcenbezogene Importe.
- [`StartMRPRecalculation.R`](../StartMRPRecalculation.R) startet die additive MRP-Neuberechnung.
- Die Snapshot-Skripte verwenden das separate [`pseudonym`](../pseudonym/README.md)-Paket.

Die projektweite Verwendung erläutert die [zentrale README](../../README.md). Details zur
Einrichtung und zum Betrieb stehen in [`Install.md`](../../Install.md) und
[`Operation.md`](../../Operation.md); die MRP-Neuberechnung ist in
[`README_MRP_Recalculation.md`](../README_MRP_Recalculation.md) beschrieben.

## Tests und Modulschnittstellen

Der `testthat`-Einstieg liegt unter [`tests/testthat`](tests/testthat); der aktuelle Pakettest ist
noch ein Gerüsttest. Das Verhalten der delegierten Schritte wird in den jeweiligen Modulpaketen
getestet und dokumentiert: [`cds2db`](../../R-cds2db/cds2db/README.md),
[`dataprocessor`](../../R-dataprocessor/dataprocessor/README.md),
[`db2frontend`](../../R-db2frontend/README.md) und [`etlutils`](../../R-etlutils/etlutils/README.md).
