# INTERPOLAR – Standorttest für Datenbank-Verbindungsabbrüche

Dieser Branch dient ausschließlich der Diagnose unerwarteter Verbindungsabbrüche
bei der Snapshot-Pseudonymisierung. Er ist nicht zum Merge vorgesehen.

**Branch:** `1484-add-database-connection-diagnostics`

**Basis:** `main`

**Issue:** [#1484](https://github.com/medizininformatik-initiative/INTERPOLAR/issues/1484)

## Durchführung am Standort

1. Den aktuellen Stand dieses Branches auschecken und das INTERPOLAR-R-Image
   wie am Standort üblich bauen. Nach einer Branch-Aktualisierung erneut bauen.
2. Die Diagnose mit derselben Netzwerkanbindung, Konfiguration und denselben
   Mounts wie die Snapshot-Pseudonymisierung starten. Im R-Container genügt:

   ```bash
   Rscript /src/R-cdstoolchain/DiagnoseDatabaseConnection.R
   ```

   Bei Verwendung der mitgelieferten Docker-Compose-Konfiguration lautet der
   Startbefehl auf dem Host:

   ```bash
   docker compose run --rm --no-deps r-env Rscript /src/R-cdstoolchain/DiagnoseDatabaseConnection.R
   ```

   Bei Docker Swarm den Rscript-Aufruf über den üblichen Standort-Startweg
   ausführen. Entscheidend ist derselbe DB-Verbindungsweg wie beim betroffenen
   Snapshot-Lauf. Die Datenbank muss bereits laufen.
3. Etwa **17–20 Minuten** warten. Anschließend die vom Skript genannte
   **TXT-Ergebnisdatei zurückschicken**. Auch ein Fehlerbericht ist hilfreich.

Die Ergebnisdatei liegt unter:

```text
outputLocal/database_connection_diagnostics/connection-diagnostic-*.txt
```

`outputLocal` muss wie beim normalen Betrieb nach außen eingebunden sein, damit
die Datei nach Ende des Containers verfügbar bleibt. Bei der mitgelieferten
Compose-Konfiguration ist dieser Mount vorhanden.

## Was wird geprüft?

Die Diagnose verwendet die vorhandene DB-Konfiguration. Der Pfad wird aus
`R-dataprocessor/dataprocessor_config.toml` (`PATH_TO_DB_CONFIG_TOML`) gelesen;
ohne diese Vorgabe gilt `cds_hub_db_config.toml` im Projektverzeichnis.

Der Verbindungsaufbau läuft über denselben Helfer wie beim Snapshot:
`connectSnapshotPseudonymizationDatabase()` → `etlutils::dbCreateConnection()`.
Damit gelten auch dieselben Session-Einstellungen. Die Diagnose setzt keine
zusätzlichen Verbindungs-, Abfrage- oder Keepalive-Parameter. Eine separate
Prozessüberwachung begrenzt die Laufzeit hängender Tests.

Drei Tests laufen parallel:

- **Ruhephase:** Eine Verbindung bleibt 17 Minuten unbenutzt und wird danach
  erneut abgefragt.
- **Lange Abfrage:** `pg_sleep(1020)` simuliert eine lange Abfrage ohne laufende
  Ergebnisübertragung. Wie beim Snapshot werden `dbSendQuery()`, `dbFetch()`
  und `dbHasCompleted()` verwendet.
- **Chunk-Streaming:** Zwei getrennte Quell- und Zielverbindungen verarbeiten
  10.001 synthetische Zeilen in Chunks der Snapshot-Standardgröße von 5.000.
  Gelesen wird über `dbSendQuery()`/`dbFetch()`, geschrieben über
  `dbWriteTable()`/`dbAppendTable()`. Nach dem ersten Chunk folgt eine
  17-minütige Pause, während die Verbindungen und das Resultset offen bleiben.
  Die synthetischen Daten werden in eine temporäre Zieltabelle geschrieben,
  die beim Schließen der Verbindung entfernt wird.

Anschließend wird eine **neue Verbindung** aufgebaut und geprüft. Fehlgeschlagene
Operationen werden nicht automatisch wiederholt, damit ihr Fehler sichtbar bleibt.

Der Bericht enthält außerdem DNS-Auflösung, DB-Endpunkte, Backend-PIDs,
Zeitpunkte, Laufzeiten, wirksame PostgreSQL-Timeout-/Keepalive-Einstellungen,
Client-Kernelvorgaben sowie abweichende Rollen- und Datenbankvorgaben. Zugangsdaten
werden nicht ausgegeben; konfigurierte Passwörter werden in Fehlertexten maskiert.
Der Bericht enthält interne Adressen, Rollen und Datenbanknamen.

## Ergebnis einordnen

- **Langzeittest fehlgeschlagen, neue Verbindung erfolgreich:** Hinweis auf ein
  Problem bestehender Verbindungen oder ein Abfragezeitlimit. Der konkrete
  Fehlertext und die verstrichene Zeit helfen bei der Unterscheidung.
- **`statement timeout`:** Ein PostgreSQL-Abfragezeitlimit hat gegriffen.
- **Auch die neue Verbindung fehlgeschlagen:** Erreichbarkeit und DB-/Servicezustand
  zum Testzeitpunkt sind zu prüfen.
- **Alle Tests erfolgreich:** Der Fehler wurde unter diesen Bedingungen nicht
  reproduziert. Das schließt einen Abbruch im vollständigen Snapshot-Lauf nicht aus.

Die Tests verwenden `DB_NAME` aus der Konfiguration für beide Verbindungen und
standardmäßig den Dataprocessor-Zugang. Vorhandene `SOURCE_DB_USER`/
`SOURCE_DB_PASSWORD` beziehungsweise `TARGET_DB_USER`/`TARGET_DB_PASSWORD` werden
wie im Snapshot-Verbindungshelfer berücksichtigt. Spezielle CLI-Parameter eines
anderen Snapshot-Aufrufs werden nicht übernommen. Die aufgeführten
Timeout-Vorgaben anderer Datenbanken werden nicht in jeder Datenbank getestet.

Die Diagnose verarbeitet synthetische Daten und bildet die Verbindungs- und
Streamingtechnik nach; sie führt keine Pseudonymisierung von Standortdaten aus.
DNS- und Backend-Adressen allein beweisen keinen Swarm-VIP-Pfad. Die vollständige
Swarm-Servicekonfiguration ist im R-Container ohne Verwaltungszugriff nicht
verfügbar. Diese Grenzen stehen auch im Ergebnisbericht.
