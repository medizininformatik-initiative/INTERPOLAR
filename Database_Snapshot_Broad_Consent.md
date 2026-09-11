# Broad-Consent-Auswahl für Snapshot-Daten

[Bedienung](Database_Snapshot.md) → [Pseudonymisierung](Database_Snapshot_Pseudonymization.md) → Broad Consent

Die BC-Auswahl verarbeitet im Standardablauf den bereits pseudonymisierten
Snapshot. Sie berechnet zunächst pro Patient, ob Daten genutzt werden dürfen
und welche Datenzeiträume erlaubt sind. Anschließend wählt sie die dazu passenden
Ressourcen aus und entfernt Referenzen auf ausgeschlossene Ressourcen.
Die Quelle bleibt unverändert; das Ergebnis wird in eine eigene Datenbank und
Snapshot-Datei geschrieben.

Die folgenden Schritte beschreiben die Implementierung in INTERPOLAR.
Grundlage ist der TORCH-Stand `b12757d09a525ae1a3309e4aded999b209b1d600`.
Die [Abgrenzung zu TORCH](#abgrenzung-zu-torch-und-codequellen) erläutert,
welche Besonderheiten bei der Übertragung auf Snapshot-Daten gelten.

## Inhalt

- [Daten aus der Consent-Ressource](#daten-aus-der-consent-ressource)
- [Bedeutung der vier Codes](#bedeutung-der-vier-codes)
- [Berechnung der Patientenzulassung und Datenzeiträume](#berechnung-der-patientenzulassung-und-datenzeiträume)
- [Rechenbeispiele](#rechenbeispiele)
- [Zeitliche Prüfung der Ressourcen](#zeitliche-prüfung-der-ressourcen)
- [Abhängige Tabellen und Encounter-Hierarchien](#abhängige-tabellen-und-encounter-hierarchien)
- [Entfernte Referenzen und Maskierungsnachweise](#entfernte-referenzen-und-maskierungsnachweise)
- [Prüfberichte](#prüfberichte)
- [Abgrenzung zu TORCH und Codequellen](#abgrenzung-zu-torch-und-codequellen)

## Daten aus der Consent-Ressource

Verwendet werden die aktuellen Fassungen aus
`db2dataprocessor_out.v_consent_last_version`. Frühere Consent-Versionen erteilen
keine zusätzlichen Rechte. Mehrere unterschiedliche aktuelle Consent-Dokumente
eines Patienten werden dagegen gemeinsam ausgewertet. Patient und Encounter
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
retrospektiver Erklärungen wird dagegen der vollständige Erklärungszeitpunkt
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
Eine passende Erlaubnis für einen der beiden Codes genügt. Sie ersetzen weder
die erforderliche `.6`-Erlaubnis noch die aktuelle Nutzungsberechtigung aus `.8`.

Die Zeiträume werden aus den Provisions übernommen. Der Prozess leitet aus dem
Erklärungsdatum keine pauschale Laufzeit von etwa fünf oder dreißig Jahren ab.

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

Es werden auch unvollständige Ablehnungen als Fehler behandelt. Sie einfach zu
ignorieren könnte eine Freigabe stehen lassen, deren Einschränkung nicht sicher
berechnet werden kann.

### 2. Beginn der `.6`-Zeiträume an Encounter anpassen

Liegt der Beginn einer `.6`-Provision innerhalb eines bereits begonnenen
Encounters desselben Patienten, wird dieser Beginn auf den früheren
Encounter-Beginn zurückgesetzt. Bei mehreren passenden Encountern zählt der
früheste Beginn. Der Encounter muss einen gültigen Anfang und ein gültiges Ende
haben; offene Encounter werden für diese Anpassung nicht verwendet.

Das Ende der Provision bleibt unverändert. Die Anpassung betrifft im aktuellen
INTERPOLAR-Code sowohl `.6`-Erlaubnisse als auch `.6`-Ablehnungen. Sie gilt für
alle passenden Encounter, nicht nur für Einrichtungskontakte. `.8`, `.45` und
`.46` werden in diesem Schritt nicht verändert.

### 3. Vollständige Dokumente als Grundlage der Erlaubnisse bestimmen

Nur ein Dokument, das sowohl ein `.6 permit` als auch ein `.8 permit` enthält,
kann Erlaubnisse beitragen. Eine `.6`-Erlaubnis in Dokument A und eine
`.8`-Erlaubnis in Dokument B erfüllen diese Voraussetzung nicht gemeinsam.
Auch retrospektive Erlaubnisse müssen aus einem solchen vollständigen Dokument
stammen.

Ablehnungen werden dagegen aus allen aktiven relevanten Dokumenten
berücksichtigt. Ein reines Widerrufsdokument braucht keine eigenen Erlaubnisse.

### 4. Aktuelle Datennutzung mit `.8` prüfen

Die `.8`-Erlaubniszeiträume der vollständigen Dokumente werden vereinigt.
Davon werden sämtliche `.8`-Ablehnungszeiträume abgezogen. Der Bewertungstag
muss in einem verbleibenden Zeitraum liegen. Andernfalls wird der Patient mit
`no_current_usage_permission` ausgeschlossen.

Hier zählt die zeitliche Abdeckung durch die Provisions, nicht ein allgemeines
„das neueste Dokument gewinnt“. Ein späteres `.8 permit` entfernt daher keine
weiterhin überlappende `.8 deny`-Provision aus der Berechnung.

Der verbleibende `.8`-Zeitraum wird **nicht** mit den `.6`-Datenzeiträumen
geschnitten. `.8` beantwortet die Frage, ob die Nutzung heute zulässig ist;
`.6` beantwortet, aus welchen Zeiträumen die Daten stammen dürfen.

### 5. Retrospektive Freigaben aus `.45` und `.46` berechnen

Zuerst wird geprüft, ob retrospektive Freigaben widerrufen wurden. Der zeitlich
neueste `deny` für `.45` oder `.46` hebt alle früher oder gleichzeitig erklärten
retrospektiven `permit`-Provisions des Patienten auf. Das gilt über
Dokumentgrenzen und über beide Codes hinweg: Ein `.46 deny` kann auch eine
frühere `.45 permit`-Provision aufheben. Bei gleichem Erklärungszeitpunkt gewinnt
die Ablehnung. Eine danach erklärte retrospektive Erlaubnis kann erneut wirken.
Die Ablehnung hebt dabei die betreffende Erweiterung insgesamt auf; ihr Zeitraum
wird nicht als einzelne Lücke aus dem erweiterten Datenzeitraum ausgeschnitten.

Eine verbliebene retrospektive Erlaubnis erweitert eine `.6`-Erlaubnis nur, wenn
beide im selben vollständigen Consent-Dokument stehen und sich ihre Zeiträume
mindestens an einem Tag überschneiden. Verglichen wird der in Schritt 2 bereits
an Encounter angepasste `.6`-Zeitraum.

Bei einer solchen Überschneidung wird der `.6`-Beginn auf **01.01.1900** gesetzt;
das `.6`-Ende bleibt unverändert. Die Überschneidung ist also die Voraussetzung
für die Erweiterung, nicht der neue erlaubte Datenzeitraum. Wurde eine
retrospektive Erlaubnis widerrufen, bleibt die zugehörige `.6`-Erlaubnis mit ihrem
ursprünglichen beziehungsweise an Encounter angepassten Beginn bestehen.

### 6. Endgültige Datenzeiträume aus `.6` bilden

Die `.6`-Erlaubnisse werden für diesen Schritt in zwei Gruppen aufgeteilt:

- Von den **nicht retrospektiv erweiterten** Zeiträumen werden sämtliche
  `.6`-Ablehnungszeiträume abgezogen, einschließlich der in Schritt 2
  angepassten Ablehnungen. Ein späteres `.6 permit` hebt eine vorhandene
  überlappende `.6 deny`-Provision dabei nicht automatisch auf.
- **Retrospektiv erweiterte** Zeiträume werden unverändert hinzugefügt.
  Sie werden entsprechend der übernommenen TORCH-Semantik nicht durch
  `.6 deny` gekürzt. Ihre Erweiterung wird über `.45`/`.46`-Widerrufe gesteuert;
  die `.8`-Prüfung bleibt trotzdem Voraussetzung.

Anschließend werden die verbleibenden Zeiträume vereinigt. Überlappende
Zeiträume und direkt aufeinanderfolgende Tage werden zusammengefasst; echte
Lücken bleiben erhalten. Ein abgelehnter Zeitraum einschließlich seiner
Grenztage wird entfernt: Aus 01.–31.03. mit Ablehnung 10.–12.03. entstehen
01.–09.03. und 13.–31.03.

Bleibt kein Zeitraum übrig, wird der Patient mit `no_permitted_data_period`
ausgeschlossen. Andernfalls lautet die Patientenentscheidung `included`.
Dies bedeutet noch nicht, dass jede Ressource des Patienten übernommen wird:
Es folgt die Prüfung ihrer eigenen Datumswerte.

## Rechenbeispiele

Die Beispiele setzen jeweils gültige, aktive und eindeutig zugeordnete
Dokumente voraus. Bewertungstag ist der 11.09.2026; eine gültige `.8`-Erlaubnis
reicht jeweils bis 2050. Außer im Encounter-Beispiel gibt es keine Encounter,
die einen Provision-Beginn verschieben.

| Fall | Ausgangslage | Ergebnis |
|---|---|---|
| Historische Daten bei heutiger Nutzungsberechtigung | `.6 permit`: 2020–2025; `.8 permit`: 2026–2050, im selben Dokument | Patient zugelassen; Datenzeitraum bleibt 2020–2025. Die fehlende zeitliche Überschneidung mit `.8` entfernt diese Daten nicht. |
| Lücke durch `.6 deny` | `.6 permit`: 2020–2025; separates `.6 deny`: Kalenderjahr 2022 | Datenzeiträume 2020–2021 und 2023–2025. |
| Retrospektive Erweiterung | Zusätzlich zum vorigen Fall: passende `.45 permit` im vollständigen Erlaubnisdokument | Datenzeitraum 01.01.1900–31.12.2025; die `.6`-Ablehnung erzeugt in der retrospektiven Erweiterung keine Lücke. |
| Dokumentübergreifender Retro-Widerruf | Erweiterung durch `.45 permit`, erklärt 2020; `.46 deny` in einem anderen Dokument, erklärt 2021 | Erweiterung entfällt. Die reguläre `.6`-Erlaubnis und ihre `.6`-Ablehnungen bestimmen wieder die Datenzeiträume. |
| Erneute Retro-Erlaubnis | Nach dem Retro-Widerruf folgt 2022 ein neues vollständiges Dokument mit `.6`, `.8` und passender `.45 permit` | Die spätere retrospektive Erlaubnis kann wieder bis 01.01.1900 erweitern. |
| Aktuelle Nutzung widerrufen | `.8 deny` deckt den 11.09.2026 ab | Patient vollständig ausgeschlossen, auch bei wirksamer retrospektiver Erweiterung. |
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

Für `Patient` und `Medication` ist ausdrücklich keine eigene zeitliche Prüfung
vorgesehen: Patientendaten werden anhand der Patientenzulassung ausgewählt.
Medikamentenressourcen werden übernommen, wenn sie von einem behaltenen
Medikationsereignis direkt oder über eine Zutatenreferenz benötigt werden.
Ein leeres Datumsfeld in einer anderen Ressource hebt deren zeitliche Prüfung
jedoch nicht auf.

Für `Location` ist in der verwendeten Regelzuordnung keine Auswahlregel
hinterlegt. Deshalb werden `Location`-Ressourcen derzeit vollständig
ausgeschlossen. Eine fehlende Regel wird nicht als Freigabe behandelt. Die
Zuordnung der Datumsfelder folgt dem TORCH-Stand
`b12757d09a525ae1a3309e4aded999b209b1d600` und ist im Code in
[`BROAD_CONSENT_RESOURCE_DATES`](R-cdstoolchain/pseudonym/R/broad_consent_resources.R)
festgehalten.

## Abhängige Tabellen und Encounter-Hierarchien

Nicht-FHIR-Tabellen, etwa Frontend-Daten und MRP-Berechnungen, werden anhand ihrer
Patientenzuordnung gefiltert. Für sie wird kein eigener Datenzeitraum geprüft.
Die Zuordnung erfolgt anhand der Quelldaten, bevor Encounter ausgeschlossen und
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

Für jeden so entfernten Referenzwert entsteht zusätzlich ein Eintrag in
`db_log.broad_consent_masked_reference` mit dem Grund `masked`. Damit kann eine
Auswertung unterscheiden, ob eine Referenz durch die BC-Auswahl entfernt wurde
oder bereits in der Quelle fehlte. Ein `NULL`-Wert allein reicht für diese
Unterscheidung nicht aus. Der Nachweis bezieht sich auf die BC-Maskierung von
Referenzen; er erfasst nicht allgemein alle durch die Pseudonymisierungsregel
`redact` entfernten Werte.

Der Eintrag benennt Tabelle, technische Zeilen-ID, Ressourcen-ID, Version,
Patienten-ID und Spalte. Der entfernte Referenzwert selbst wird nicht gespeichert.
Durch die Anreicherung mit Medikamentencodes können mehrere Datenzeilen dieselbe
technische Zeilen-ID haben. Diese Datenzeilen bleiben erhalten, sofern sie die
BC-Auswahl bestehen. Identische Entscheidungen und Maskierungsnachweise werden
jeweils einmal gespeichert, auch wenn die Zeilen in verschiedenen Blöcken
verarbeitet werden. Widersprüchliche Zuordnungen derselben technischen Zeilen-ID
führen weiterhin zum Abbruch.
Die Nachweistabelle liegt dauerhaft im Schema `db_log` und wird mit dem Snapshot
als Dump gesichert, unabhängig von `--consent-details`. Über die View
`db2dataprocessor_out.v_broad_consent_masked_reference` ist sie für Auswertungen
zugänglich.

Wird aus einem BC-Snapshot erneut ein BC-Snapshot erzeugt, wird die
Patientenzulassung erneut geprüft. Bei einer MRP-Berechnung kann die dafür
benötigte Encounter-Referenz bereits maskiert sein. In diesem Fall liefert der
Nachweis die Patienten-ID für die Prüfung. Nur weiterhin zugelassene Zeilen
und deren Nachweise werden übernommen.
`db_log.broad_consent_run` dokumentiert dazu die Quelldatenbank, das
Bewertungsdatum, den verwendeten TORCH-Stand und den Abschlusszeitpunkt.

## Prüfberichte

Der Broad-Consent-Prozess schreibt zusätzlich den lokalen Bericht
`outputLocal/broad_consent_snapshot/reports/broad_consent_snapshot_report.xlsx`.
Er enthält für jede Relation insbesondere Ein- und Ausgabezeilen,
Versionspartition, Chunk-Anzahl, Laufzeiten und Filteraktion sowie die
Anzahl der Patienten und Ressourcenzeilen je Entscheidungsgrund. Dieser lokale
Bericht ist nicht Bestandteil der Snapshot-Datei. Die dauerhafte
Maskierungsnachweistabelle wird dagegen immer mitgesichert, auch ohne
`--consent-details`. Detaillierte CSV-Berichte liegen bei Aktivierung in einem
eigenen Laufverzeichnis unter `outputLocal/broad_consent_snapshot`.
Die Datei `COMPLETE` zeigt an, dass die Consent-Berichte vollständig geschrieben
sind. Das Schreiben der Snapshot-Daten und des Dumps ist damit noch nicht
bestätigt. Für die Weitergabe des Snapshots muss deshalb der gesamte Befehl
erfolgreich beendet
sein; `COMPLETE` allein bestätigt noch keinen fertigen Snapshot.

Der [reine Consent-Prüflauf](Database_Snapshot.md#consent-auswertung-ohne-snapshot-erzeugung-prüfen)
verwendet dieselbe Patientenberechnung. Er schreibt die Details, erzeugt aber
keinen Snapshot und prüft noch keine klinischen Ressourcen. Die Detaildateien
machen die oben beschriebenen Schritte nachvollziehbar:

| Datei | Inhalt |
|---|---|
| `patients.csv` | Patientenentscheidung und Grund |
| `provisions.csv` | Eingelesene Provisions mit Dokument, Code, Typ und Zeitraum |
| `changes.csv` | Änderungen durch Encounter, retrospektive Erweiterungen und deren Widerrufe |
| `intervals.csv` | Endgültige erlaubte Datenzeiträume |
| `summary.csv` | Anzahl der Patienten je Entscheidungsgrund |

## Abgrenzung zu TORCH und Codequellen

Die [TORCH-Beschreibung im verwendeten Referenzstand](https://github.com/medizininformatik-initiative/torch/blob/b12757d09a525ae1a3309e4aded999b209b1d600/docs/implementation/consent.md)
erläutert die Trennung von aktueller Nutzungsberechtigung und Datenzeiträumen
sowie die retrospektive Erweiterung. Für INTERPOLAR sind die hier beschriebenen
Schritte und die zugehörigen Tests maßgeblich. Insbesondere:

- INTERPOLAR liest die bereits importierten Snapshot-Views. Es führt in diesem
  Schritt weder einen FHIR-Abruf noch eine CRTDL-Auswertung aus. Die vier Codes
  sind fest vorgegeben; vorhandene `.45`/`.46`-Provisions werden ohne zusätzliche
  Auswahloption berücksichtigt.
- Die globale Prüfung der Patientenzuordnung und der Ausschluss zukünftiger
  Erklärungen verhindern Freigaben bei diesen widersprüchlichen Quelldaten.
- Retrospektive Widerrufe gelten in INTERPOLAR nach ihrer Erklärungsreihenfolge
  dokument- und codeübergreifend, wie in Schritt 5 beschrieben. Die
  TORCH-Dokumentation dieses Referenzstands beschreibt dagegen eine
  dokumentinterne Verrechnung der Retro-Widerrufszeiträume. Diese Passage darf
  deshalb nicht unverändert als Beschreibung des INTERPOLAR-Verhaltens gelesen
  werden.
- Die Encounter-Anpassung des `.6`-Beginns betrifft im INTERPOLAR-Code sowohl
  `permit` als auch `deny` und ist nicht über einen Schalter abschaltbar.
- Referenzen auf ausgeschlossene Ziele werden in erhaltenen Zeilen maskiert.
  Abhängige gültige Ressourcen dürfen dadurch auch bei einer unvollständigen
  Encounter-Hierarchie erhalten bleiben.

Die Implementierung ist auf folgende Stellen verteilt:

- [Einlesen und Patientenzuordnung](R-cdstoolchain/pseudonym/R/broad_consent_source.R)
- [Berechnung der Patientenentscheidung und Zeiträume](R-cdstoolchain/pseudonym/R/broad_consent_periods.R)
- [Datumsfelder und Ressourcenprüfung](R-cdstoolchain/pseudonym/R/broad_consent_resources.R)
- [Indirekte Patientenzuordnung und Medikamentenreferenzen](R-cdstoolchain/pseudonym/R/broad_consent_selection.R)
- [Referenzmaskierung und dauerhafte Nachweise](R-cdstoolchain/pseudonym/R/broad_consent_references.R)
- [Tests der Zeitraum- und Widerrufsregeln](R-cdstoolchain/pseudonym/tests/testthat/test-broad-consent-periods.R)

Zurück zur [Bedienungsanleitung](Database_Snapshot.md).
