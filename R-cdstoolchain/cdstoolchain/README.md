# cdstoolchain

Der Bereich `R-cdstoolchain` verbindet die INTERPOLAR-R-Module zu ausführbaren Abläufen. Die
eigentliche Fachlogik bleibt in `cds2db`, `dataprocessor`, `db2frontend`, `etlutils` und
`pseudonym`; hier werden Initialisierung, Reihenfolge, gemeinsame Fehlerbehandlung und besondere
Laufvarianten koordiniert.

Der reguläre Aufruf über
[`StartCDSToolChainWithVacuum.sh`](../../StartCDSToolChainWithVacuum.sh) startet
[`StartCDSToolChain.R`](../StartCDSToolChain.R). Das R-Skript prüft die zusammengehörigen
Konfigurationen und führt FHIR-Import, Übernahme vorhandener Frontend-Daten, Datenverarbeitung und
Rückübertragung ins Frontend in ihrer vorgesehenen Reihenfolge aus. Unvollständige frühere Läufe
können dabei wiederaufgenommen werden. [`StartDataImport.R`](../StartDataImport.R) steuert die
Importvarianten; [`StartMRPRecalculation.R`](../StartMRPRecalculation.R) koordiniert die additive
MRP-Neuberechnung. Die Snapshot-Skripte binden das separate
[`pseudonym`](../pseudonym/README.md)-Paket ein.

Das Paketverzeichnis `R-cdstoolchain/cdstoolchain` enthält derzeit nur das R-Paketgerüst; die
operative Orchestrierung liegt in den genannten Skripten im übergeordneten Verzeichnis. Der
vorhandene `testthat`-Test unter [`tests/testthat`](tests/testthat) ist ebenfalls noch ein Gerüsttest.

Die projektweite Ausführung ist in der [zentralen README](../../README.md) beschrieben. Weitere
Details stehen in [`Install.md`](../../Install.md), [`Operation.md`](../../Operation.md) und für die
MRP-Neuberechnung in [`README_MRP_Recalculation.md`](../README_MRP_Recalculation.md).
