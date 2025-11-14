---
output: html_document
---

# "Statistical_Reports" - kumulative Kennzahlen zur Qualitätssicherung des Studienforschritts

## Logik hinter den Kennzahlen detailliert erklärt

## Version 0.1 (05.11.2025)

### 1. Laden und Filtern der Daten sowie Warnungen bei unerwarteten Datenkonstellationen

#### `getPatientData` (`v_patient_last_version`)

Ziel: lade die für INTERPOLAR relevanten Patienten und erhalte für jeden Patienten eine Zeile mit zugehöriger eindeutiger `pat_id` (FHIR) und `pat_identifier_value` (CIS) sowie seinem Geburtsdatum. ID und Identifier dienen dem Mapping auf Daten des Patienten aus anderen Datenbanktabellen. Das Geburtsdatum wird benötigt, um das Alter des Patienten bei Krankenhausaufnahme des für INTERPOLAR relevanten Falls zu berechnen.

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
-   erstellt Warnungen, wenn:
    -   mehrere Zeilen für die selbe `pat_id` (FHIR) gefunden wurden (`processing_exclusion_reason = "multiple_rows_per_pat_id"`)
    -   mehrere Zeilen für den selben `pat_identifier_value` (CIS) gefunden wurden (`processing_exclusion_reason = "multiple_rows_per_pat_identifier_value"`)

mögliche Optimierungen:

-   `pat_identifier_value` könnte ggf. komplett weggelassen werden (redundant zu `pat_id`?)
-   wurden wichtige Variablen zur Identifizierung vergessen?
-   gibt es Gründe warum trotz der Filterung noch mehrere Zeilen pro Patient existieren?

#### `getEncounterData` (`v_encounter_last_version`)

Ziel: lade die Falldaten der für INTERPOLAR relevanten Patienten und filtere auf die für INTERPOLAR und die MRP-Dokumentation relevante Fälle.

-   lädt die letzte Version der FHIR-Encounter-Daten, die der INTERPOLAR-Datenbank bekannt ist
-   Variablen:
    -   `enc_id` (FHIR Encounter ID)
    -   `enc_identifier_value` (Fallidentifikator im Klinikinformationssystem (CIS))
    -   `enc_patient_ref` (Referenz auf die FHIR Patienten ID (`pat_id`))
    -   `enc_partof_ref` (Referenz auf übergeordneten Encounter in der 3-Stufen-Encounter-Hierarchie, falls vorhanden)
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
-   gibt Warnungen für:
    -   fehlende Startdaten (`enc_period_start` is NA) in `processing_exclusion_reason` = "missing_start_date"
    -   inpatient encounter (`enc_class_code` = "IMP") mit fehlender Kontaktebene (`processing_exclusion_reason` = "missing_kontaktebene_for_imp_encounter")
    -   inpatient encounter mit fehlender oder unerwartetem Status (`enc_status` not in "in-progress", "onleave", "finished") (`processing_exclusion_reason` = "unexpected_imp_status")
    -   abgeschlossene inpatient encounter mit fehlendem Enddatum (`enc_status` = "finished" and `enc_period_end` is NA) (`processing_exclusion_reason` = "imp_finished_without_end_date")
    -   Encounter mit unerwartetem class_code (not in "AMB", "SS", "IMP") (`processing_exclusion_reason` = "unexpected_class_code")
    -   Encounter mit unbekannter Kontaktart (`processing_exclusion_reason` = "unexpected_kontaktart_code")

mögliche Optimierungen:

-   wurden wichtige Variablen zur Identifizierung vergessen?
-   ist die Filterung aller Einrichtungskontakte auf das erwartete FHIR-Identifikatorsystem so richtig? Werden damit die richtigen Fälle erfasst? Was passiert wenn es nicht definiert ist? Welche Fälle sind dann zu viel drin?
-   ggf. kann das Laden von Altdaten hier noch weiter minimiert/ komplett entfernt werden
-   kann hier ggf. schon auf `enc_class_code` "AMB"(ambulatory) und "SS"(short stay) gefiltert werden, oder können sich hierunter INTERPOLAR-Stationskontakte verbergen?
-   sind die definierten Codes, status & systeme so umgesetzt?
-   werden die richtigen Codes herausgefiltert? Finden sie sich auf alle Encounter-Ebenen wider oder nur auf bestimmten?
-   sind die Stopps und Warnungen so plausibel?

#### `getPidsPerWardData` (`v_pids_per_ward`)

Ziel: Erkennen, auf welcher INTERPOLAR-Station ein Fall aufgenommen wurde (Erkennen eines Falls auf einer INTERPOLAR-Station über die CDS-Toolchain konfigurierbar)

-   lädt die Tabelle pids_per_ward, die bei jedem Durchlauf der CDS-Toolchain erfasst, welche Patienten sich aktuell auf einer INTERPOLAR-Station befinden
-   Variablen:
    -   `ward_name` (Name der Station)
    -   `patient_id` (FHIR Patienten ID)
    -   `encounter_id` (FHIR Encounter ID)
-   stoppt das Skript wenn kein Datensatz gefunden wurde

mögliche Optimierungen:

-   richtige Annahme?
    -   über die pids_per_ward Tabelle (INTERPOLAR-DB) sind die Fälle auf Versorgungsstellenkontakt-Ebene einer Station zugeordnet
    -   encounter_id in pids_per_ward zeigt (unter Anderem) alle INTERPOLAR-Versorgungsstellenkontakte eines Falls
