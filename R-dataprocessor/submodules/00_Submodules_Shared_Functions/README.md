# Gemeinsame Funktionen der DataProcessor-Submodule

[Study_Phases.R](Study_Phases.R) stellt Hilfsfunktionen zur Zuordnung von
Studienphasen und zum Lesen der konfigurierten Stationszeiträume bereit. Diese
werden unter anderem von der Frontend-Aufbereitung, der MRP-Berechnung und den
statistischen Berichten verwendet.

Die Eingaben stammen aus der [DataProcessor-Konfiguration](../../README.md#konfiguration),
insbesondere den `PHASES_WARD_*`-Definitionen. Der DataProcessor lädt diese
Funktionen vor den regulären Verarbeitungsschritten und auch für manuelle Projekte.

Der Ordner enthält keine `Start.R` und hat keinen eigenen Startbefehl. Die Funktionen
liefern Studienphasen und Zeitangaben an die aufrufenden Submodule; sie erzeugen
selbst keine Berichte und schreiben keine fachlichen Ergebnisse in die Datenbank.

Zurück zur [DataProcessor-Submodulübersicht](../../README.md#submodule-auf-einen-blick)
· [INTERPOLAR](../../../README.md).
