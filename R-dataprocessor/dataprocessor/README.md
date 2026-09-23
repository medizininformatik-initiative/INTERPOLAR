# dataprocessor – R-Paket

Das Paket stellt den gemeinsamen Laufzeitrahmen für die DataProcessor-Submodule
bereit: Konfiguration und Datenbank initialisieren, manuelle Projekte auswählen,
Version und Locks prüfen, Submodule laden und den Lauf abschließen.
Fachliche Verarbeitung wie Frontend-Aufbereitung, MRP-Berechnung und Reporting
liegt in den Submodulen.

Für **Konfiguration, Startbefehle und die vollständige Submodulübersicht** siehe
[DataProcessor](../README.md). Der reguläre Einstieg ist
[StartDataProcessor.R](../StartDataProcessor.R), das `dataprocessor::processData()` aufruft.

## Implementierung und Erweiterung

- [00_Main.R](R/00_Main.R): Initialisierung, Ausführung und Abschluss des Modullaufs.
- [00_Manual_Project_Database.R](R/00_Manual_Project_Database.R): Auswahl und Prüfung der Datenbank manueller Projekte.
- [03_Submodule_Functions.R](R/03_Submodule_Functions.R): Laden der R-Dateien anhand der Verzeichnisstruktur.

Reguläre Submodule liegen direkt unter `R-dataprocessor/submodules`, manuelle
Projekte unter `submodules/manual_start`. Der Loader lädt R-Dateien aus dem
Submodulordner und aus `R/`-Verzeichnissen seiner R-Subprojekte. Eine vorhandene
`Start.R` im Submodulordner wird anschließend als Einstieg ausgeführt.
Submodul-Konfigurationen werden über `etlutils::initSubmoduleConstants()` geladen.
Gemeinsame Funktionen ohne eigenen Ablauf können ohne `Start.R` bereitgestellt werden.

Das Hauptpaket soll konkrete Submodule nicht fachlich kennen. Ein Submodul-Ordner
muss löschbar bleiben, ohne dass die Tests oder der Start des Hauptpakets dadurch
fehlschlagen. Fachliche Abhängigkeiten einzelner Submodule gehören in deren
Dokumentation.

Submodul-spezifische Implementierung und Tests gehören deshalb in das jeweilige
Submodul, üblicherweise in ein eigenes R-Subprojekt. Tests im Hauptpaket prüfen
nur generische Loader- oder Konventionslogik und dürfen keine konkreten
Submodule namentlich voraussetzen. Vor neuen Hilfsfunktionen sind bestehende
APIs in `dataprocessor` und `etlutils` zu prüfen.

Zurück zu [DataProcessor](../README.md) · [INTERPOLAR](../../README.md).
