# INTERPOLAR – Standorttest für Datenbank-Verbindungsabbrüche

**Aktueller Test: TCP-Keepalives nach 600 Sekunden (10 Minuten).**

Dieser Standortbranch enthält die Swarm-Anpassungen aus #1463 und zusätzlich
die Diagnose unerwarteter Verbindungsabbrüche bei der Snapshot-Pseudonymisierung.
Die Diagnose-Ergänzung dient ausschließlich dem Standorttest und ist nicht zum
Merge vorgesehen.

**Standortbranch:** `1463-enh-snapshot-script-um-swarm-befehle-ergänzen`

**Issues:** [#1463 – Swarm-Unterstützung](https://github.com/medizininformatik-initiative/INTERPOLAR/issues/1463),
[#1484 – Verbindungsdiagnose](https://github.com/medizininformatik-initiative/INTERPOLAR/issues/1484)

Für Vergleichstests an Nicht-Swarm-Standorten bleibt der Branch
`1484-add-database-connection-diagnostics` verfügbar.

## Durchführung am Standort

1. Den aktuellen Stand dieses Branches auschecken und das INTERPOLAR-R-Image
   wie am Standort üblich bauen. Nach einer Branch-Aktualisierung erneut bauen.
2. Die Diagnose mit derselben Netzwerkanbindung, Konfiguration und denselben
   Mounts wie die Snapshot-Pseudonymisierung starten. Im R-Container genügt:

   ```bash
   Rscript /src/R-cdstoolchain/DiagnoseDatabaseConnection.R
   ```

   In diesem Swarm-Branch führt die Snapshot-Pseudonymisierung R-Aufrufe im
   laufenden `r-env`-Task aus. Die Diagnose im selben Task des aktualisierten
   Images starten, damit sie denselben DB-Verbindungsweg verwendet. Die
   Datenbank muss bereits laufen.
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
Anschließend setzt die Diagnose auf **jeder Testverbindung**
`tcp_keepalives_idle = 600`. Damit sendet PostgreSQL bei Netzwerkinaktivität
bereits nach zehn Minuten einen TCP-Keepalive. Die Einstellung gilt nur für
die jeweilige Diagnosesitzung; die PostgreSQL-Konfiguration und normale
Snapshot-Läufe bleiben unverändert. Weitere Einstellungen sind am Standort
nicht erforderlich. Der Bericht kennzeichnet diese Testvariante und zeigt den
wirksamen Wert. Eine separate Prozessüberwachung begrenzt die Laufzeit
hängender Tests.

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
- **Alle Tests erfolgreich:** Gegenüber dem bereits fehlgeschlagenen Test mit
  7.200 Sekunden spricht das für einen Zusammenhang mit Netzwerkinaktivität und
  Keepalive-Einstellungen. Es beweist noch nicht die genaue Netzwerkkomponente
  und schließt einen Abbruch im vollständigen Snapshot-Lauf nicht aus.

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
