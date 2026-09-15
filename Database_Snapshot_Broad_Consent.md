# Broad-Consent-Auswahl für Snapshot-Daten

[Bedienung](Database_Snapshot.md) → [Pseudonymisierung](Database_Snapshot_Pseudonymization.md) → Broad Consent

Die BC-Auswahl verarbeitet einen normalen oder pseudonymisierten Snapshot.
Im Standardablauf folgt sie auf die Pseudonymisierung. Sie berechnet zunächst
pro Patient, ob Daten genutzt werden dürfen
und welche Datenzeiträume erlaubt sind. Anschließend wählt sie die dazu passenden
Ressourcen aus und entfernt Referenzen auf ausgeschlossene Ressourcen.
Die Quelle bleibt unverändert; das Ergebnis wird in eine eigene Datenbank und
Snapshot-Datei geschrieben.

Die folgenden Schritte beschreiben die Consent-Regeln in INTERPOLAR.
[Fachliche Referenzen und Codequellen](#fachliche-referenzen-und-codequellen)
stehen am Ende dieser Beschreibung.

## Inhalt

- [Daten aus der Consent-Ressource](#daten-aus-der-consent-ressource)
- [Bedeutung der vier Codes](#bedeutung-der-vier-codes)
- [Berechnung der Patientenzulassung und Datenzeiträume](#berechnung-der-patientenzulassung-und-datenzeiträume)
- [Rechenbeispiele](#rechenbeispiele)
- [Zeitliche Prüfung der Ressourcen](#zeitliche-prüfung-der-ressourcen)
- [Abhängige Tabellen und Encounter-Hierarchien](#abhängige-tabellen-und-encounter-hierarchien)
- [Entfernte Referenzen und Maskierungsnachweise](#entfernte-referenzen-und-maskierungsnachweise)
- [Prüfberichte](#prüfberichte)
- [Fachliche Referenzen und Codequellen](#fachliche-referenzen-und-codequellen)

## Daten aus der Consent-Ressource

Jeder reguläre CDS2DB-Lauf lädt Consents für alle bekannten Patienten erneut,
auch wenn deren übrige Ressourcen gerade nicht aktualisiert werden. Ein bereits
erzeugter Snapshot behält dagegen seinen damaligen Datenstand.

Verwendet werden die aktuellen Fassungen aus
`db2dataprocessor_out.v_consent_last_version`. Mehrere unterschiedliche aktuelle
Consent-Dokumente eines Patienten werden gemeinsam ausgewertet. Patient und Encounter
werden ebenfalls aus ihren aktuellen Views gelesen.

Eine Consent-Ressource kann mehrere einzelne Festlegungen enthalten, die FHIR
als *Provisions* bezeichnet. Jede betrachtete Provision benennt einen Code,
eine Erlaubnis (`permit`) oder Ablehnung (`deny`) und deren Zeitraum. Für die
Berechnung werden die bereits importierten Datenbankspalten verwendet:

| Angabe | FHIR-Feld | Datenbankspalte |
|---|---|---|
| Dokument-ID | `Consent.id` | `cons_id` |
| Patient | `Consent.patient.reference` | `cons_patient_ref` |
| Status | `Consent.status` | `cons_status` |
| Zeitpunkt der Erklärung | `Consent.dateTime` | `cons_datetime` |
| Codesystem und Code | `Consent.provision.provision.code.coding.system` / `.code` | `cons_provision_provision_code_system` / `cons_provision_provision_code_code` |
| Erlaubnis oder Ablehnung | `Consent.provision.provision.type` | `cons_provision_provision_type` |
| Beginn und Ende | `Consent.provision.provision.period.start` / `.end` | `cons_provision_provision_period_start` / `cons_provision_provision_period_end` |

Die Auswertung liest die untergeordneten Provisions. Ein übergeordnetes
`Consent.provision.type = deny` wird nicht als pauschaler Widerruf aller darin
enthaltenen Erlaubnisse ausgelegt. Dokument-ID und Erklärungszeitpunkt bleiben
erhalten, damit zusammengehörige Erlaubnisse und spätere Widerrufe zugeordnet
werden können. Identische, durch die Tabellenaufbereitung mehrfach vorhandene
Provision-Zeilen werden für die Berechnung zusammengefasst.

Das Bewertungsdatum ist der einmalig am Start festgehaltene UTC-Kalendertag.
Provision-Zeiträume werden ebenfalls als UTC-Kalendertage verglichen;
Anfangs- und Endtag gehören jeweils zum Zeitraum. Für die Reihenfolge
aller relevanten Erklärungen wird dagegen der vollständige Erklärungszeitpunkt
verwendet.

## Bedeutung der vier Codes

Das Codesystem lautet `urn:oid:2.16.840.1.113883.3.1937.777.24.5.3`.
Die vollständigen Codes beginnen mit `2.16.840.1.113883.3.1937.777.24.5.3.`;
im Folgenden stehen nur ihre Endungen.

| Code | Bezeichnung | Wirkung in der Berechnung |
|---|---|---|
| `.8` | MDAT wissenschaftlich nutzen EU DSGVO NIVEAU | Prüft, ob die Datennutzung am Bewertungstag erlaubt ist. |
| `.6` | MDAT erheben | Liefert die Zeiträume, aus denen Daten übernommen werden dürfen. |
| `.45` | MDAT retrospektiv speichern, verarbeiten | Kann einen `.6`-Zeitraum rückwirkend erweitern. |
| `.46` | MDAT retrospektiv wissenschaftlich nutzen EU DSGVO NIVEAU | Kann ebenfalls einen `.6`-Zeitraum rückwirkend erweitern. |

`.45` und `.46` werden als alternative retrospektive Erweiterungen behandelt:
Eine passende Erlaubnis für einen der beiden Codes genügt; Voraussetzung sind
die `.6`-Erlaubnis und die aktuelle Nutzungsberechtigung aus `.8`.

Beginn und Ende der Zeiträume werden aus den Provisions übernommen.

## Berechnung der Patientenzulassung und Datenzeiträume

- [1. Zuordnung und Angaben prüfen](#1-zuordnung-und-angaben-prüfen)
- [2. Encounter-Anpassung](#2-beginn-der-6-zeiträume-an-encounter-anpassen)
- [3. Vollständige Dokumente](#3-vollständige-dokumente-als-grundlage-der-erlaubnisse-bestimmen)
- [4. Aktuelle Nutzung mit `.8`](#4-aktuelle-datennutzung-mit-8-prüfen)
- [5. Retrospektive Freigaben und Widerrufe](#5-retrospektive-freigaben-aus-45-und-46-berechnen)
- [6. Endgültige `.6`-Zeiträume](#6-endgültige-datenzeiträume-aus-6-bilden)

### 1. Zuordnung und Angaben prüfen

Vor der Aufteilung in Patientenblöcke wird die Zuordnung der aktuellen
Consent-Dokumente über die gesamte Quelle geprüft. Ist ein potenziell wirksames
Dokument mehreren Patienten zugeordnet, werden alle betroffenen Patienten mit
`ambiguous_consent_patient` ausgeschlossen. Weitere gültige Dokumente heben die
Unklarheit nicht auf. Kann eine potenziell wirksame Consent-Referenz überhaupt
keinem Patienten sicher zugeordnet werden, bricht der Lauf ab: Ein möglicher
Widerruf dürfte sonst unbemerkt für den falschen Patienten entfallen.

Für die Patientenzuordnung bezeichnet auch eine relative versionierte Referenz
wie `Patient/p1/_history/2` den Patienten `p1`. Bei der späteren Referenzmaskierung
wird die angegebene Zielversion geprüft.

Pro Patient werden danach die Angaben geprüft:

- Nur `active`-Dokumente tragen zur Berechnung bei. Bekannte andere Statuswerte
  wie `inactive` werden ignoriert; ein fehlender oder unbekannter Status führt
  zum Patientenausschluss, weil die Wirksamkeit der Erklärung unklar ist.
- Fehlende Codes oder Codesysteme in aktiven Provisions führen zum Ausschluss.
  Vollständig bezeichnete andere Codes oder Codesysteme werden ignoriert.
- Für die vier relevanten Codes müssen Dokument-ID, Erklärungszeitpunkt,
  `permit`/`deny` und beide Zeitraumgrenzen vorhanden sein. Der Beginn darf
  nicht nach dem Ende liegen. Ungültige Angaben führen zum Ausschluss.
- Alle relevanten Provisions eines Dokuments müssen denselben
  Erklärungszeitpunkt haben.
- Liegt eine aktive relevante Erklärung nach dem Bewertungstag, wird der
  Patient mit `future_consent_declaration` ausgeschlossen. Erklärungen am
  selben UTC-Kalendertag sind zulässig.

### 2. Beginn der `.6`-Zeiträume an Encounter anpassen

Liegt der Beginn einer `.6`-Erlaubnis innerhalb eines bereits begonnenen
Encounters desselben Patienten, wird dieser Beginn auf den früheren
Encounter-Beginn zurückgesetzt. Bei mehreren passenden Encountern zählt der
früheste Beginn. Der Encounter muss einen gültigen Anfang und ein gültiges Ende
haben.

Das Ende der Provision bleibt unverändert. Die Anpassung betrifft nur
`.6`-Erlaubnisse; `.6`-Ablehnungen behalten ihren angegebenen Beginn. Sie gilt für
alle passenden Encounter.

### 3. Vollständige Dokumente als Grundlage der Erlaubnisse bestimmen

Nur ein Dokument, das sowohl ein `.6 permit` als auch ein `.8 permit` enthält,
kann Erlaubnisse beitragen. Eine `.6`-Erlaubnis in Dokument A und eine
`.8`-Erlaubnis in Dokument B erfüllen diese Voraussetzung nicht gemeinsam.
Auch retrospektive Erlaubnisse müssen aus einem solchen vollständigen Dokument
stammen.

Ablehnungen werden dagegen aus allen aktiven relevanten Dokumenten
berücksichtigt. Ein reines Widerrufsdokument braucht keine eigenen Erlaubnisse.

### 4. Aktuelle Datennutzung mit `.8` prüfen

Die Dokumente werden nach ihrem vollständigen `Consent.dateTime` aufsteigend
verarbeitet. Eine neue `.8`-Erlaubnis fügt ihren Zeitraum hinzu; eine neue
`.8`-Ablehnung zieht ihren Zeitraum ab. Eine spätere ausdrückliche Erlaubnis
kann damit eine frühere Ablehnung für ihren Zeitraum überstimmen. Bei exakt
gleichen Erklärungszeitpunkten gewinnt die Ablehnung, unabhängig von Dokument-ID
und Zeilenreihenfolge.

Nach Verarbeitung aller Erklärungen muss der Bewertungstag in einem verbleibenden
`.8`-Zeitraum liegen. Andernfalls wird der Patient mit
`no_current_usage_permission` ausgeschlossen. Der verbleibende `.8`-Zeitraum
wird **nicht** mit den `.6`-Datenzeiträumen geschnitten: `.8` prüft die heutige
Nutzung, `.6` bestimmt die erlaubten Datenzeiträume.

### 5. Retrospektive Freigaben aus `.45` und `.46` berechnen

Eine retrospektive Erlaubnis erweitert eine `.6`-Erlaubnis nur, wenn beide im
selben vollständigen Consent-Dokument stehen und sich ihre Zeiträume mindestens
an einem Tag überschneiden. Verglichen wird der in Schritt 2 bereits an Encounter
angepasste `.6`-Zeitraum. Die Erweiterung beginnt am **01.01.1900** und endet am
unveränderten `.6`-Ende.

Ein späteres `.45 deny` oder `.46 deny` setzt dagegen die **gesamten bisher
angesammelten `.6`-Freigaben** zurück, einschließlich regulärer Freigaben und
unabhängig von einer Überschneidung mit dem angegebenen Widerrufszeitraum.
Das gilt dokument- und codeübergreifend. Eigene `.6`-Erlaubnisse im neuen
vollständigen Dokument bleiben erhalten. Ein reines Retro-Widerrufsdokument
hinterlässt daher zunächst keinen erlaubten Datenzeitraum. Spätere vollständige
Erlaubnisdokumente können erneut Freigaben erteilen.

Enthält das zurücksetzende Dokument selbst eine passende Retro-Erlaubnis, werden
seine Retro-Ablehnungszeiträume aus deren Erweiterung ausgeschnitten; die eigenen
regulären `.6`-Erlaubnisse bleiben erhalten. Bei gleichzeitig erklärten Dokumenten
hat die Einschränkung Vorrang: Ein Reset verwirft auch Beiträge anderer
Dokumente dieses Zeitpunkts ohne eigenen Reset. Eine Retro-Ablehnung in einem
anderen gleichzeitigen Dokument verhindert die Retro-Erweiterung. Reguläre
Erlaubnisse aus den zurücksetzenden Dokumenten werden zusammengeführt.

### 6. Endgültige Datenzeiträume aus `.6` bilden

Auch `.6` wird chronologisch verarbeitet. Nach dem gegebenenfalls erforderlichen
Reset werden die eigenen regulären und retrospektiv erweiterten Erlaubnisse
hinzugefügt und anschließend die `.6`-Ablehnungszeiträume abgezogen. Eine spätere
Erlaubnis kann einen zuvor gesperrten Zeitraum wieder freigeben, jedoch nur im
Umfang ihrer eigenen regulären beziehungsweise retrospektiven Freigabe.
Bei gleichem Erklärungszeitpunkt werden alle `.6`-Ablehnungen zuletzt angewendet.

Anschließend werden die verbleibenden Zeiträume vereinigt. Überlappende
Zeiträume und direkt aufeinanderfolgende Tage werden zusammengefasst; echte
Lücken bleiben erhalten. Ein abgelehnter Zeitraum einschließlich seiner
Grenztage wird entfernt: Aus 01.–31.03. mit Ablehnung 10.–12.03. entstehen
01.–09.03. und 13.–31.03.

Bleibt kein Zeitraum übrig, wird der Patient mit `no_permitted_data_period`
ausgeschlossen. Andernfalls lautet die Patientenentscheidung `included`.
Für zugelassene Patienten folgt die Prüfung der einzelnen Ressourcen anhand
ihrer Datumswerte.

## Rechenbeispiele

Die Beispiele setzen jeweils gültige, aktive und eindeutig zugeordnete
Dokumente voraus. Bewertungstag ist der 11.09.2026; eine gültige `.8`-Erlaubnis
reicht jeweils bis 2050. Außer im Encounter-Beispiel gibt es keine Encounter,
die einen Provision-Beginn verschieben.

| Fall | Ausgangslage | Ergebnis |
|---|---|---|
| Historische Daten bei heutiger Nutzungsberechtigung | `.6 permit`: 2020–2025; `.8 permit`: 2026–2050, im selben Dokument | Patient zugelassen; Datenzeitraum bleibt 2020–2025. Die aktuelle `.8`-Erlaubnis deckt die Nutzung dieser historischen Daten ab. |
| Lücke durch `.6 deny` | `.6 permit`: 2020–2025; später erklärtes separates `.6 deny`: Kalenderjahr 2022 | Datenzeiträume 2020–2021 und 2023–2025. |
| Retrospektive Erweiterung | Zusätzlich zum vorigen Fall: passende `.45 permit` im vollständigen Erlaubnisdokument | Datenzeiträume 01.01.1900–31.12.2021 und 01.01.2023–31.12.2025; die später erklärte `.6`-Ablehnung bleibt wirksam. |
| Dokumentübergreifender Retro-Widerruf | Erweiterung durch `.45 permit`, erklärt 2020; `.46 deny` in einem anderen Dokument, erklärt 2021 | Alle bisherigen `.6`-Freigaben entfallen; ohne neue eigene Erlaubnisse wird der Patient ausgeschlossen. |
| Erneute Retro-Erlaubnis | Nach dem Retro-Widerruf folgt 2022 ein neues vollständiges Dokument mit `.6`, `.8` und passender `.45 permit` | Die spätere retrospektive Erlaubnis kann wieder bis 01.01.1900 erweitern. |
| Wiederfreigabe | `.6 deny` für 2024, danach vollständiges Dokument mit `.6 permit` für 2024 | 2024 wird erneut freigegeben. |
| Reset mit neuer regulärer Freigabe | Alte Freigabe 2020–2023; neues vollständiges Dokument mit `.6 permit` für 2025–2028 und `.45 deny` | Nur 2025–2028 bleibt erlaubt. |
| Aktuelle Nutzung widerrufen | Letzte wirksame Erklärung für den 11.09.2026 ist `.8 deny` | Patient vollständig ausgeschlossen, auch bei wirksamer retrospektiver Erweiterung. |
| Encounter-Anpassung | `.6 permit`: 05.–15.03.2026; Encounter: 01.–20.03.2026 | `.6` wird auf 01.–15.03. erweitert. Der Encounter selbst wird nicht übernommen, weil sein Ende außerhalb liegt; ein Laborwert vom 08.03. kann bleiben. |

## Zeitliche Prüfung der Ressourcen

Aktuelle und historische Ressourcenfassungen werden einzeln geprüft. Besteht
eine Ressourcenfassung aus mehreren Tabellenzeilen, gilt die Entscheidung für
alle diese Zeilen gemeinsam. Neben den Datumswerten müssen auch die
Ressourcenidentität und die Patientenzuordnung eindeutig sein. Fehlende oder
widersprüchliche benötigte Angaben führen zum Ausschluss der Ressourcenfassung.

Für jeden unterstützten FHIR-Ressourcentyp ist festgelegt, welches Datumsfeld mit
den erlaubten Datenzeiträumen verglichen wird. Bei `Observation` ist dies
beispielsweise `effective`, bei `Encounter` der Zeitraum `period`. Ein
Einzelzeitpunkt muss innerhalb eines erlaubten Zeitraums liegen. Bei einem
Zeitraum müssen Anfang, Ende und alle dazwischenliegenden Tage abgedeckt sein;
eine bloße Überschneidung reicht nicht aus. Fehlen dafür benötigte Datumswerte
oder sind die Angaben widersprüchlich, wird die Ressourcenfassung ausgeschlossen.

Patientendaten werden anhand der Patientenzulassung ausgewählt.
Medikamentenressourcen werden übernommen, wenn sie von einem behaltenen
Medikationsereignis direkt oder über eine Zutatenreferenz benötigt werden.

`Location`-Ressourcen werden vollständig ausgeschlossen. Die Zuordnung der
Datumsfelder ist im Code in
[`BROAD_CONSENT_RESOURCE_DATES`](R-cdstoolchain/pseudonym/R/broad_consent_resources.R)
festgehalten.

## Abhängige Tabellen und Encounter-Hierarchien

Nicht-FHIR-Tabellen, etwa Frontend-Daten und MRP-Berechnungen, werden anhand ihrer
Patientenzuordnung und der Patientenzulassung gefiltert. Die Zuordnung erfolgt
anhand der Quelldaten, bevor Encounter ausgeschlossen und
Referenzen entfernt werden. Dadurch bleibt zum Beispiel eine MRP-Berechnung
einem zugelassenen Patienten zugeordnet, auch wenn der zugehörige
Einrichtungskontakt nicht übernommen werden darf.

Auch klinische Ressourcen werden jeweils nach ihren eigenen Datumswerten
beurteilt: Ein Stationskontakt oder Laborwert kann vollständig im erlaubten
Zeitraum liegen, während der längere Einrichtungskontakt darüber hinausreicht.
Dann bleibt der Stationskontakt oder Laborwert erhalten und der
Einrichtungskontakt entfällt. Die Referenzen auf diesen ausgeschlossenen Kontakt
werden wie nachfolgend beschrieben entfernt.

## Entfernte Referenzen und Maskierungsnachweise

Verweist eine erhaltene Zeile auf eine durch die BC-Auswahl ausgeschlossene
Ressource, wird die betreffende Referenz im BC-Snapshot auf SQL `NULL` gesetzt.
Das wird hier als Maskierung bezeichnet. Es gilt auch für berechnete
Referenzspalten und bekannte FHIR-Zuordnungsspalten in Nicht-FHIR-Tabellen.
Eine Referenz ohne Versionsangabe wird anhand der aktuellen Fassung des Ziels
geprüft; bei einer Referenz mit `/_history/` ist die angegebene Version maßgeblich.

Die Maskierungsnachweise stehen in `masked_references.csv` im Laufverzeichnis.
Ein Eintrag benennt Tabelle, technische
Zeilen-ID, Ressourcen-ID, Version, Patienten-ID, Spalte und den Grund `masked`.
Bei angereicherten Mehrfachzeilen können identische Nachweise mehrfach im
Bericht vorkommen.
Widersprüchliche Zuordnungen derselben technischen Zeilen-ID führen bereits bei
der Auswahl zum Abbruch.

## Prüfberichte

Der Broad-Consent-Prozess schreibt zusätzlich den lokalen Bericht
`outputLocal/broad_consent_snapshot/reports/broad_consent_snapshot_report.xlsx`.
Er enthält für jede Relation insbesondere Ein- und Ausgabezeilen,
Versionspartition, Chunk-Anzahl, Laufzeiten und Filteraktion sowie die
Anzahl der Patienten und Ressourcenzeilen je Entscheidungsgrund. In einem
Laufverzeichnis unter `outputLocal/broad_consent_snapshot` entstehen immer `masked_references.csv`
und `run.csv` mit Quelldatenbank, Bewertungsdatum und Abschlusszeit der
Datenbankerzeugung. Mit `--consent-details` kommen die detaillierten
patientenbezogenen CSV-Berichte hinzu.

`COMPLETE` kennzeichnet den Abschluss der Patientenprüfung. Für die Weitergabe
des Snapshots muss der gesamte Befehl einschließlich Datenbankerzeugung und
Export erfolgreich beendet sein.

Der [reine Consent-Prüflauf](Database_Snapshot.md#consent-auswertung-ohne-snapshot-erzeugung-prüfen)
verwendet dieselbe Patientenberechnung und schreibt folgende Detaildateien:

| Datei | Inhalt |
|---|---|
| `patients.csv` | Patientenentscheidung und Grund |
| `provisions.csv` | Eingelesene Provisions mit Dokument, Code, Typ und Zeitraum |
| `changes.csv` | Änderungen durch Encounter, retrospektive Erweiterungen und deren Widerrufe |
| `intervals.csv` | Endgültige erlaubte Datenzeiträume |
| `summary.csv` | Anzahl der Patienten je Entscheidungsgrund |

## Fachliche Referenzen und Codequellen

Die Consent-Berechnung orientiert sich an
[TORCHs ConsentCalculator, Stand `8a7bee63`](https://github.com/medizininformatik-initiative/torch/blob/8a7bee63c79403040fc9723cf3d20123256593d4/src/main/java/de/medizininformatikinitiative/torch/consent/ConsentCalculator.java).
Die Datumszuordnung folgt
[`type_to_consent.json`, Stand `b12757d0`](https://github.com/medizininformatik-initiative/torch/blob/b12757d09a525ae1a3309e4aded999b209b1d600/mappings/type_to_consent.json).
Für INTERPOLAR sind die oben beschriebenen Regeln und die zugehörigen Tests maßgeblich.

Die Implementierung ist auf folgende Stellen verteilt:

- [Einlesen und Patientenzuordnung](R-cdstoolchain/pseudonym/R/broad_consent_source.R)
- [Berechnung der Patientenentscheidung und Zeiträume](R-cdstoolchain/pseudonym/R/broad_consent_periods.R)
- [Datumsfelder und Ressourcenprüfung](R-cdstoolchain/pseudonym/R/broad_consent_resources.R)
- [Indirekte Patientenzuordnung und Medikamentenreferenzen](R-cdstoolchain/pseudonym/R/broad_consent_selection.R)
- [Referenzmaskierung und Berichtsdaten](R-cdstoolchain/pseudonym/R/broad_consent_references.R)
- [Tests der Zeitraum- und Widerrufsregeln](R-cdstoolchain/pseudonym/tests/testthat/test-broad-consent-periods.R)

Zurück zur [Bedienungsanleitung](Database_Snapshot.md).
