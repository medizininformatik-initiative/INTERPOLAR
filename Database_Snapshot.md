# Snapshots erstellen und verwenden

Der Standardablauf ist **Rohsnapshot → Pseudonymisierung → Broad-Consent-Auswahl**.
Dateien liegen unter `Snapshots/`; die zugehörigen Datenbanken heißen `ip_<Snapshotname>`
und sind schreibgeschützt.

- [Quickstart](#quickstart)
- [Vorhandene Snapshots verwenden](#vorhandene-snapshots-verwenden)
- [Consent-Auswertung ohne Snapshot-Erzeugung prüfen](#consent-auswertung-ohne-snapshot-erzeugung-prüfen)
- [Probleme beheben](#probleme-beheben)
- Hintergründe: [Pseudonymisierung](Database_Snapshot_Pseudonymization.md) ·
  [Broad-Consent-Regeln](Database_Snapshot_Broad_Consent.md)

## Quickstart

Im INTERPOLAR-Hauptverzeichnis ausführen. `snap01` ist ein frei wählbarer Name;
Datum und Dateiendung werden ergänzt.

```bash
# Nur Rohsnapshot
./ip-snapshot.sh create snap01

# Rohsnapshot und pseudonymisierten Snapshot erzeugen
./ip-snapshot.sh create snap01 --with-pseudonymized

# Zusätzlich daraus den Broad-Consent-Snapshot erzeugen
./ip-snapshot.sh create snap01 --with-broad-consent
```

Der letzte Befehl erzeugt beispielsweise:

```text
Snapshots/snap01_20260915.sql.gz
Snapshots/snap01_20260915_pseud.sql.gz
Snapshots/snap01_20260915_pseud_broad_consent.sql.gz
```

Bei der ersten Pseudonymisierung oder neuen Standortwerten kann der Prozess zum
Ergänzen von `Input-Repo/pseudo_mapping.xlsx` anhalten. Die leeren Zellen in
`PSEUDONYM` ausfüllen und denselben Befehl erneut starten. Vorhandene Zuordnungen
für spätere Läufe beibehalten.

Optional vor der Pseudonymisierung Consents aktualisieren:
`R-cdstoolchain/consent_config_example.toml` nach `consent_config.toml` im selben
Verzeichnis kopieren und FHIR-Zugangsdaten eintragen. Ohne Serveradresse bleibt
der Snapshot-Consent erhalten. Details: [Consent-Aktualisierung](Database_Snapshot_Pseudonymization.md#consent-aktualisierung).

Vor einer Weitergabe das erzeugte Ergebnis auf die vorgesehenen
Pseudonymisierungs- und Consent-Regeln prüfen. Ein Rohsnapshot enthält Originaldaten.

## Vorhandene Snapshots verwenden

Snapshotnamen immer ohne `.sql.gz` angeben. Mit `list` die vorhandenen Namen prüfen:

```bash
./ip-snapshot.sh list
./ip-snapshot.sh pseudonymize snap01_20260915
./ip-snapshot.sh create-broad-consent snap01_20260915_pseud
```

`create-broad-consent` benötigt eine aktivierte Quelldatenbank. Pseudonymisierung
und BC-Erzeugung lassen ihre Datenbanken bereits aktiviert zurück. Eine andere
Snapshot-Datei lässt sich bei Bedarf aktivieren:

```bash
./ip-snapshot.sh activate snap01_20260915
./ip-snapshot.sh deactivate snap01_20260915
./ip-snapshot.sh delete snap01_20260915
```

`deactivate` entfernt die aktivierte Datenbank, die Datei bleibt erhalten.
`delete` löscht die Snapshot-Datei; die genauen Optionen zeigt `./ip-snapshot.sh`.

Die BC-Auswahl verwendet die Consent-Daten eines normalen oder pseudonymisierten
Snapshots. Bei einer normalen Quelle enthält das Ergebnis weiterhin Originaldaten.

## Consent-Auswertung ohne Snapshot-Erzeugung prüfen

```bash
./ip-snapshot.sh review-broad-consent snap01_20260915_pseud
```

Der Prüflauf zeigt Patientenzulassung, Consent-Provisionen und erlaubte
Datenzeiträume unter `outputLocal/broad_consent_review`.

Die BC-Erzeugung schreibt Zusammenfassung und Maskierungsnachweise unter
`outputLocal/broad_consent_snapshot`. `--consent-details` ergänzt die
patientenbezogenen Detailberichte. Inhalt und Dateinamen stehen unter
[BC-Prüfberichte](Database_Snapshot_Broad_Consent.md#prüfberichte).

## Probleme beheben

| Meldung oder Situation | Vorgehen |
|---|---|
| Pseudonymzuordnungen fehlen | Angegebene `pseudo_mapping.xlsx` ergänzen, Befehl wiederholen. |
| Mappingdatei wird im alten Verzeichnis gefunden | Die vorhandene Datei nach `Input-Repo/pseudo_mapping.xlsx` verschieben; vorhandene Zuordnungen erhalten. |
| Eingabedatei fehlt oder wird mehrfach gefunden | `INPUT_REPO_PATH` in `R-dataprocessor/dataprocessor_config.toml` und die gemeldeten Fundstellen prüfen. |
| Quelle für BC nicht aktiviert | Mit `list` prüfen und den gewünschten Snapshot mit `activate` laden. |
| Hinweise zur Datenanreicherung | Im genannten Bericht nachsehen. Nicht umgerechnete Laborwerte behalten Originalwert und Quelleinheit. |
| BC meldet widersprüchliche technische IDs | Die aggregierte Konfliktdiagnose im angegebenen Log prüfen; insbesondere prüfen, ob der Quelldump in eine leere Datenbank eingespielt wurde. |
| Zu hoher Speicherbedarf | `--chunk-size` verkleinern; Standard sind 5.000 Zeilen. |
| Ein späterer Schritt bricht ab | Bereits fertige Snapshots bleiben erhalten. Pseudonymisierung oder `create-broad-consent` separat erneut starten. |

Den Logpfad nennt der Prozess am Ende. Für die Weitergabe muss der gesamte
Befehl einschließlich Export erfolgreich sein; eine `COMPLETE`-Datei bestätigt
nur die Fertigstellung der Consent-Detailberichte.

## Auswertungen auf Snapshots

Manuelle Data-Processor-Projekte wählen die Datenbank über ihre lokale
`database.toml`; Vorlage: `R-dataprocessor/submodules/manual_start/database_example.toml`.
Mindestens `DB_NAME` setzen. Standardmäßig werden pseudonymisierte Snapshots
akzeptiert; andere kompatible Datenbanken erfordern `--force`.

Ein älterer Snapshot führt zu einer Versionswarnung, ein neuerer wird abgelehnt.
Ob eine Auswertung ein älteres Schema unterstützt, hängt von ihren benötigten
Views und Spalten ab.
