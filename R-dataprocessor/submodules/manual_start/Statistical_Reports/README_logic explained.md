---
output: 
  html_document: 
    toc: true
    toc_depth: 4
---

# "Statistical_Reports" - kumulative Kennzahlen zur Qualitätssicherung des Studienfortschritts

## Logik hinter den Kennzahlen detailliert erklärt (work in progress)

### 1. Laden und Filtern der Daten sowie Warnungen bei unerwarteten Datenkonstellationen

#### `getPatientData` (`v_patient_last_version`) --\> patient_table

Ziel: lade die für INTERPOLAR relevanten Patienten und erhalte für jeden Patienten eine Zeile mit zugehöriger eindeutiger `pat_id` (FHIR) und `pat_identifier_value` (CIS) sowie seinem Geburtsdatum. Die ID dient dem Mapping auf Daten des Patienten aus anderen Datenbanktabellen. Der Identifier wird für das Mapping nicht verwendet, es wir djedoch geprüft, ob doppelte Zeilen vorkommen (dann sind ggf. `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_` Filter nicht korrekt umgesetzt). Das Geburtsdatum wird benötigt, um das Alter des Patienten bei Krankenhausaufnahme des für INTERPOLAR relevanten Falls zu berechnen.

-   lädt die letzte Version der FHIR-Patientendaten, die der INTERPOLAR-Datenbank bekannt ist
-   Variablen:
    -   `pat_id` (FHIR Patienten ID)
    -   `pat_identifier_system` (System des FHIR Patientenidentifikators)
    -   `pat_identifier_type_system` (System des FHIR Patientenidentifikator-Typs)
    -   `pat_identifier_type_code` (Code des FHIR Patientenidentifikator-Typs, z.B. "MR" für Medical Record Number)
    -   `pat_identifier_value` (Patientenidentifikator im Klinikinformationssystem (CIS))
    -   `pat_birthdate` (Geburtsdatum des Patienten)
-   filtert die Patientendatensätze basierend auf den in der dataprocessor_config.toml gesetzten Filtern (wenn eine oder mehrere der folgenden Bedingungen zutreffen):
    -   `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_SYSTEM` entspricht `pat_identifier_system`
    -   `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_SYSTEM` entspricht `pat_identifier_type_system`
    -   `FRONTEND_DISPLAYED_PATIENT_FHIR_IDENTIFIER_TYPE_CODE` entspricht `pat_identifier_type_code`
    -   Wenn keine dieser Filter gesetzt oder aktiv sind (`""` oder Platzhalter `"."`), findet keine Filterung statt
-   erstellt die Variable `processing_exclusion_reason`, für zukünftige Begründung, warum ein Patient von der Verarbeitung ausgeschlossen wurde (z.B. fehlende Daten oder Uneindeutigkeit für die Zählung)
-   stoppt das Skript wenn kein Patientendatensatz gefunden wurde
-   nachfolgende Funktionen geben Warnungen wenn:
    -   mehrere Zeilen für die selbe `pat_id` (FHIR) gefunden wurden (es sollte für die verwendeten Variablen nur eine eindeutige Kombination geben). Es folgt hier kein Ausschluss, da die `pat_id` für das Mapping zu den FHIR-Daten ausreicht (kein `processing_exclusion_reason`).
    -   mehrere Zeilen für den selben `pat_identifier_value` (CIS) gefunden wurden (es sollte für die verwendeten Variablen nur eine eindeutige Kombination geben) (`processing_exclusion_reason = "multiple_rows_per_pat_identifier_value"`)

mögliche Optimierungen:

-   wurden wichtige Variablen zur Identifizierung vergessen?

#### `getEncounterData` (`v_encounter_last_version`) --\> encounter_table

Ziel: lade die Falldaten der für INTERPOLAR relevanten Patienten und filtere auf die für INTERPOLAR und die MRP-Dokumentation relevante Fälle.

-   lädt die letzte Version der FHIR-Encounter-Daten, die der INTERPOLAR-Datenbank bekannt ist
-   Variablen:
    -   `enc_id` (FHIR Encounter ID)
    -   `enc_identifier_value` (Fallidentifikator im Klinikinformationssystem (CIS))
    -   `enc_patient_ref` (Referenz auf die FHIR Patienten ID (`pat_id`))
    -   `enc_partof_calculated_ref` (Referenz auf übergeordneten Encounter in der 3-Stufen-Encounter-Hierarchie, falls initial nicht vorhanden, dann berechnet aus Zeitstempeln)
    -   `enc_main_encounter_calculated_ref` (berechnete Referenz auf den Haupt-Encounter in der 3-Stufen-Encounter-Hierarchie)
    -   `enc_class_code` (Encounter-Klasse, z.B. "IMP" für stationär)
    -   `enc_type_code` (Encounter-Typ, kann Kontaktebene (z.B. "versorgungsstellenkontakt"") oder Kontaktart (z.B. "normalstationaer") beinhalten)
    -   `enc_type_system` (System des FHIR Encounter-Typs, definiert ob Kontaktart oder Kontaktebene)
    -   `enc_period_start`(Beginn des Falls: Klinikaufnahme (Einrichtungskontakt), Stationsaufnahme (Versogrunsgstellenkontakt))
    -   `enc_period_end` (Ende des Falls: Klinikentlassung (Einrichtungskontakt), Stationsentlassung (Versorgungsstellenkontakt))
    -   `enc_status` (Status des Falls, z.B. "finished" für abgeschlossene Fälle)
    -   `enc_identifier_system` (System des FHIR Fallidentifikators)
-   filtert Einrichtungskontakte heraus, deren `enc_identifier_system` nicht dem erwarteten Fall-FHIR-Identifikatorsystem entsprechen (sofern als `COMMON_ENCOUNTER_FHIR_IDENTIFIER_SYSTEM` definiert).
-   Filterung aller Falldaten falls Startdatum vorhanden auf `enc_period_start` innerhalb eines Jahres vor `reporting_period_start`, um das Laden von einer großen Menge Altdaten zu vermeiden
-   filtert Fälle mit `enc_class_code` "PRENC"(pre-admission), "VR"(virtual) oder "HH"(home health) heraus, um irrelevante Datensätze auszuschließen.
-   filtert Fälle mit `enc_status` "planned", "cancelled", "entered-in-error" oder "unknown" heraus, um irrelevante Datensätze auszuschließen; übrig sollten bleiben: "in-progress", "onleave" und "finished".
-   verwendet die Spalten `enc_type_code` und `enc_type_system`, um Kontaktebene (z.B. Versorgungsstellenkontakt) und Kontaktart (z.B. normalstationär, intensivstationär) um die Tabelle zu verflachen:
    -   `enc_type_code_Kontaktebene` und `enc_type_code_Kontaktart` werden als neue Spalten mit den entspechenden Codes aus `enc_type_code` angelegt, sodass beide in einer Zeile vorliegen
    -   Binding gemäß implementation Guide:
        -   system: "<http://fhir.de/CodeSystem/Kontaktebene>",
        -   codes: "einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt"
        -   system: "\<<http://fhir.de/CodeSystem/kontaktart-de>"
        -   codes: "begleitperson", "vorstationaer", "nachstationaer", "teilstationaer", "tagesklinik", "nachtklinik", "normalstationaer", "intensivstationaer", "ub", "konsil", "stationsaequivalent", "operation"
    -   erstellt Warnungen, wenn System oder Code unbekannt oder uneindeutig sind (sichtbar in `processing_exclusion_reason` = "undefined_kontaktebene_or_kontaktart")
-   filtert Fälle mit Kontaktart "begleitperson" heraus, da diese für INTERPOLAR nicht relevant sind
-   stoppt das Skript wenn kein Falldatensatz gefunden wurde oder wenn keinerlei Einrichtungskontakte oder Versorgungsstellenkontakte identifiziert wurden
-   nachfolgende Funktionen geben Warnungen für:
    -   `CheckMissingStartDate`: fehlende Startdaten (`enc_period_start` is NA) in `processing_exclusion_reason` = "missing_start_date"
    -   inpatient encounter (`enc_class_code` = "IMP") mit fehlender Kontaktebene (`processing_exclusion_reason` = "missing_kontaktebene_for_imp_encounter")
    -   inpatient encounter mit fehlender oder unerwartetem Status (`enc_status` not in "in-progress", "onleave", "finished") (`processing_exclusion_reason` = "unexpected_imp_status")
    -   abgeschlossene inpatient encounter mit fehlendem Enddatum (`enc_status` = "finished" and `enc_period_end` is NA) (`processing_exclusion_reason` = "imp_finished_without_end_date")
    -   Encounter mit unerwartetem class_code (not in "AMB", "SS", "IMP") (`processing_exclusion_reason` = "unexpected_class_code")
    -   Encounter mit unbekannter Kontaktart (`processing_exclusion_reason` = "unexpected_kontaktart_code")
    -   Encounter von Typ "Einrichtungskontakt" mit uneindeutiger `enc_identifier_value` - `enc_id` Kombination (`processing_exclusion_reason` = "multiple_einrichtungskontakt_enc_ids_for_same_enc_identifier_value" / "multiple_einrichtungskontakt_enc_identifier_values_for_same_enc_id")
    -   fehlende `enc_partof_calculated_ref` bei Abteilungs- oder Versorgungsstellenkontakten (kein processing_exclusion_reason, nur Warnung)
    -   fehlende berechnete Referenz zum Einrichtungskontakt `enc_main_encounter_calculated_ref` (`processing_exclusion_reason` = "No_enc_main_encounter_calculated_ref")

mögliche Optimierungen:

-   wurden wichtige Variablen zur Identifizierung vergessen?
-   ist die Filterung aller Einrichtungskontakte auf das erwartete FHIR-Identifikatorsystem so richtig? Werden damit die richtigen Fälle erfasst? Was passiert wenn es nicht definiert ist? Welche Fälle sind dann zu viel drin?
-   ggf. kann das Laden von Altdaten hier noch weiter minimiert/ komplett entfernt werden
-   kann hier ggf. schon auf `enc_class_code` "AMB"(ambulatory) und "SS"(short stay) gefiltert werden, oder können sich hierunter INTERPOLAR-Stationskontakte verbergen?
-   sind die definierten Codes, status & systeme so umgesetzt?
-   werden die richtigen Codes herausgefiltert? Finden sie sich auf alle Encounter-Ebenen wider oder nur auf bestimmten?
-   sind die Stopps und Warnungen so plausibel?

#### `getPidsPerWardData` (`v_pids_per_ward`) --\> pids_per_ward_table

Ziel: Erkennen, auf welcher INTERPOLAR-Station ein Fall aufgenommen wurde (Erkennen eines Falls auf einer INTERPOLAR-Station über die CDS-Toolchain konfigurierbar) und zu welchem Versorgungsstellenkontakt dieser INTERPOLAR-Fall gehört.

-   lädt die Tabelle pids_per_ward, die bei jedem Durchlauf der CDS-Toolchain erfasst, welche Patienten sich aktuell auf einer INTERPOLAR-Station befinden
-   Variablen:
    -   `ward_name` (Name der Station)
    -   `patient_id` (FHIR Patienten ID)
    -   `encounter_id` (FHIR Encounter ID: alle Ebenen?!)
-   stoppt das Skript wenn kein Datensatz gefunden wurde

mögliche Optimierungen:

-   richtige Annahme?
    -   über die pids_per_ward Tabelle (INTERPOLAR-DB) sind die Fälle auf Versorgungsstellenkontakt-Ebene einer Station zugeordnet
    -   encounter_id in pids_per_ward zeigt (unter Anderem) alle INTERPOLAR-Versorgungsstellenkontakte eines Falls

#### `getPatientFeData` (`v_patient_fe` --\> in Erarbeitung: `v_patient_fe_last_version`?) --\> patient_fe_table

Ziel: lade die für das Reporting relevanten Patienten-Daten aus der Frontend-Tabelle, um das Mapping zu weiteren Daten des Patienten zu vorzunehmen und ein Abgleich zwischen Frontend und FHIR-Daten zu ermöglichen.

-   lädt die (letzte?) Version der Frontend-Patienten-Identifikatoren, die der INTERPOLAR-Datenbank bekannt ist (verschiedene Versionen sollten hier eigentlich nicht vorkommen, trotzdem ist sicherheitshalber `_last_version` zu verwenden, sobald verfügbar)
-   Variablen:
    -   `pat_id` (FHIR Patienten ID)
    -   `record_id` (Frontend Datensatz ID)
-   legt die Variable `processing_exclusion_reason` an, für zukünftige Begründung, warum ein Patient von der Verarbeitung ausgeschlossen wurde (z.B. fehlende Daten oder Uneindeutigkeit für die Zählung)
-   stoppt das Skript wenn kein Datensatz gefunden wurde
-   nachfolgende Funktionen geben Warnungen für:
    -   mehrere Zeilen für die selbe `pat_id` (FHIR) gefunden wurden (es sollte für die verwendeten Variablen nur eine eindeutige Kombination geben) (`processing_exclusion_reason = "multiple_rows_per_pat_id_in_fe"`)

mögliche Optimierungen:

-   wurden wichtige Variablen zur Identifizierung vergessen?
-   gibt es Gründe warum trotz der Filterung noch mehrere Zeilen pro Patient existieren?

#### `getFallFeData` (`v_fall_fe` --\> in Erarbeitung: `v_fall_fe_last_version`?) --\> fall_fe_table

Ziel: lade die für das Reporting relevanten Fall-Daten aus der Frontend-Tabelle, um das Mapping zu weiteren Daten des Falls vorzunehmen und ein Abgleich zwischen Frontend und FHIR-Daten zu ermöglichen. Weiterhin sind hier die Information über Studienphase, Station und Aufnahmedatum (Einrichtungskontakt) des Falls enthalten.

-   lädt die (letzte?) Version der Frontend-Fall-Daten, die der INTERPOLAR-Datenbank bekannt ist (eine Änderung der Station sollte dabei in der Historie verfolgbar sein (kein Überschreiben), die Studienphase sollte immer die erste pro Fall abbilden)
-   Variablen:
    -   `record_id` (Frontend Datensatz ID)
    -   `fall_fhir_enc_id` (FHIR Encounter ID: hier nur Einrichtungskontaktebene)
    -   `fall_pat_id` (FHIR Patienten ID)
    -   `fall_id` (Fallidentifikator im Klinikinformationssystem (CIS))
    -   (`fall_studienphase` (Studienphase des Falls, z.B. "PhaseA", "PhaseBTest", "PhaseB" oder NA falls Fall vor Implementierung der Studienphasen erfasst wurde? (zählt dann zu PhaseA)): aktuell nicht verwendet, da nicht benötigt)
    -   `fall_station` (Name der Station, auf der der Fall aufgenommen wurde)
    -   `fall_aufn_dat` (Aufnahmedatum des Falls (Einrichtungskontakt))
-   stoppt das Skript wenn kein Datensatz gefunden wurde

mögliche Optimierungen:

-   ist hier ein \_last_version notwendig, oder sollte immer die erste Version pro Sub-Fall (siehe Stationswechsel) verwendet werden (dann richtige Studienphase): Spezialfall bzgl. view nötig?
-   wurden wichtige Variablen zur Identifizierung vergessen?
-   ist das fall_additional_value Feld zu Nutzen (z.B. für einfachere Zuordnung Versorgunsgstellenkontakt?)

#### `getMedikationsanalyseFeData` (`v_medikationsanalyse_fe` --\> in Erarbeitung: `v_medikationsanalyse_fe_last_version`) ---\> medikationsanalyse_fe_table

Ziel: lade die für das Reporting relevanten Medikationsanalyse-Daten aus der Frontend-Tabelle

-   lädt die letzte Version der Frontend-Medikationsanalyse Einträge, die der INTERPOLAR-Datenbank bekannt ist (aktuell komplette Datenbanktabelle verwendet, besser: \_last_version)
-   Variablen:
    -   `record_id` (Frontend Datensatz ID)
    -   `fall_meda_id` (Fallidentifikator im Klinikinformationssystem (CIS))
    -   `meda_id` (ID der Medikationsanalyse (= Fallidentifikator im Klinikinformationssystem (CIS) + Suffix z.B. "-1" für erste Analyse))
    -   `meda_dat` (Datum der Medikationsanalyse: wichtig für das Mapping zum Versorgungsstellenkontakt)
    -   `medikationsanalyse_complete` (Form Status der Medikationsanalyse, z.B. "Complete" für abgeschlossene Analyse, "Incomplete" für unvollständige Analyse, "Unverified" für ungültige z.B. versehentliche Anlage?)
-   stoppt das Skript wenn kein Datensatz gefunden wurde

#### `getMRPDokumentationValidierungFeData` (`v_mrpdokumentation_validierung_fe` --\> in Erarbeitung: `v_mrpdokumentation_validierung_fe_last_version`) --\> mrp_dokumentation_validierung_fe_table

Ziel: lade die für das Reporting relevanten MRP-Dokumentation Validierungs-Daten aus der Frontend-Tabelle

-   lädt die letzte Version der Frontend-MRP-Dokumentation Validierungs Einträge, die der INTERPOLAR-Datenbank bekannt ist (aktuell komplette Datenbanktabelle verwendet, besser: \_last_version)
-   Variablen:
    -   `record_id` (Frontend Datensatz ID)
    -   `mrp_meda_id` (ID der Medikationsanalyse (= Fallidentifikator im Klinikinformationssystem (CIS) + Suffix z.B. "-1" für erste Analyse))
    -   `mrp_id` (ID des MRP (= ID der Medikationsanalyse + Suffix z.B. "-m1" für erstes dokumentiertes MRP))
    -   `mrp_pigrund___21` (Indikator, ob das MRP eine Kontraindikation darstellt ("Checked" = ja / "Unchecked" = nein))
    -   `mrp_dokup_hand_emp_akz` (Ergebnis der Intervention: "Arzt / Pflege informiert", "Intervention vorgeschlagen und umgesetzt", "Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation)", "Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung)", "Intervention vorgeschlagen, Umsetzung unbekannt", "Problem nicht gelöst")
    -   `mrpdokumentation_validierung_complete` (Form Status der MRP-Dokumentation, z.B. "Complete" für abgeschlossene Dokumentation, "Incomplete" für unvollständige Dokumentation, "Unverified" für ungültige z.B. versehentliche Anlage?)
-   stoppt das Skript wenn kein Datensatz gefunden wurde

### 2. Mapping und Kuratieren der Daten unter Ableiten von Zusammenhängen

#### Mapping der FHIR-Tabellen --\> FHIR_table

#### `mergePatEnc`(patient_table, encounter_table)

Ziel: Mappen der Patienten- und Falldaten aufeinander, um für jeden Fall die zugehörigen Patientendaten zu erhalten.

-   führt einen Left-Join der patient_table (Variablen: pat_id, pat_birthdate, processing_exclusion_reason) mit der encounter_table basierend auf der Beziehung `enc_patient_ref` referenziert auf `pat_id` durch
-   setzt den processing_exclusion_reason auf der Wert aus der patient_table, falls vorhanden, falls nicht auf den Wert aus der encounter_table (NA falls beide nicht vorhanden)

#### `addCuratedEncPeriodEnd`

Ziel: Ergänzen der Falldaten um ein kuratiertes Enddatum für fehlende Enddaten aktiver Fälle

-   erstellt die Variable `enc_period_end_curated`
    -   falls das Enddatum eines Falls (`enc_period_end`) fehlt & der Status (`enc_status`) "in-progress" ist, wird das Enddatum auf das aktuelle Datum gesetzt (Annahme: Fall läuft noch)
    -   falls das Enddatum eines Falls (`enc_period_end`) fehlt & der Status (`enc_status`) "onleave" ist, wird das Enddatum auf das Startdatum des Falls (enc_period_start) gesetzt (Fall aktuell nicht auf der Station)
    -   anderenfalls wird das originale Enddatum (`enc_period_end`) verwendet
-   daraus folgt: falls das Enddatum eines Falls (`enc_period_end`) fehlt & der Status (`enc_status`) "finished" ist, bleibt das Enddatum leer (NA) (Warnung wird bereits in getEncounterData generiert)
-   falls aus diesem oder sonstigem Grund das kuratierte Enddatum fehlt wird hier (nochmals) eine Warnung generiert (processing_exclusion_reason = "NA_in_curated_enc_period_end") sowie der betroffene Datensatz ausgegeben

#### `addMainEncId`

Ziel: Ergänzen der Falldaten um die ID des Haupt-Encounters in der 3-Stufen-Encounter-Hierarchie (wichtig z.B. zur Ermittlung des Aufnahmedatums des Haupt-Falls (wichtig für Alter bei Aufnahme), sowie für weiteres Mapping zu Frontend Daten)

-   Extrahiere die main_enc_id aus enc_main_encounter_calculated_ref (löst frühere Logik (`main_enc_id_initial_try`) ab)
