CREATE SCHEMA IF NOT EXISTS db2dataprocessor_out;

CREATE TABLE db2dataprocessor_out.v_patient_last_version
(
    pat_id        varchar NOT NULL,
    pat_birthdate varchar NULL,
    pat_gender    varchar NULL,
    PRIMARY KEY (pat_id)
);

CREATE TABLE db2dataprocessor_out.v_encounter_last_version
(
    enc_id           	   varchar NOT NULL,
    enc_patient_ref  	   varchar NULL,
    enc_class_code   	   varchar NULL,
    enc_type_code   	   varchar NULL,
    enc_period_start 	   timestamp NULL,
    enc_period_end   	   timestamp NULL,
    enc_age_at_admission   numeric NULL,
    PRIMARY KEY (enc_id)
);

CREATE TABLE db2dataprocessor_out.v_observation_last_version
(
    obs_id                       varchar NOT NULL,
    obs_encounter_calculated_ref varchar NULL,
    obs_patient_ref              varchar NULL,
    analysis_loinc_code          varchar NOT NULL,
    obs_effectivedatetime        timestamp NULL,
    analysis_value      		 float8 NULL,
    PRIMARY KEY (obs_id, analysis_loinc_code)
);

CREATE TABLE db2dataprocessor_out.v_condition_last_version
(
    con_id                       varchar NOT NULL,
    con_encounter_calculated_ref varchar NULL,
    con_patient_ref              varchar NULL,
    con_identifier_value         varchar NULL,
    con_code_system              varchar NULL,
    con_code_code                varchar NULL,
    con_code_display             varchar NULL,
    con_code_text                varchar NULL,
    con_onsetperiod_start        timestamp NULL,
    con_onsetperiod_end          timestamp NULL,
    con_onsetdatetime            timestamp NULL,
    con_recordeddate             timestamp NULL,
    PRIMARY KEY (con_id)
);

CREATE TABLE db2dataprocessor_out.v_procedure_last_version
(
    proc_id                       varchar NOT NULL,
    proc_encounter_calculated_ref varchar NULL,
    proc_patient_ref              varchar NULL,
    proc_code_system              varchar NULL,
    proc_code_code                varchar NULL,
    proc_performeddatetime        timestamp NULL,
    proc_performedperiod_start    timestamp NULL,
    proc_performedperiod_end      timestamp NULL,
    PRIMARY KEY (proc_id)
);

CREATE TABLE db2dataprocessor_out.v_medicationadministration_last_version
(
    medadm_id                       varchar NOT NULL,
    medadm_encounter_calculated_ref varchar NULL,
    medadm_patient_ref              varchar NULL,
    medadm_effectivedatetime        timestamp NULL,
    medadm_effectiveperiod_start    timestamp NULL,
    medadm_effectiveperiod_end      timestamp NULL,
    medadm_medication_system        varchar NULL,
    medadm_medication_code          varchar NULL,
    PRIMARY KEY (medadm_id)
);

CREATE TABLE db2dataprocessor_out.v_medicationstatement_last_version
(
    medstat_id                       varchar NOT NULL,
    medstat_encounter_calculated_ref varchar NULL,
    medstat_patient_ref              varchar NULL,
    medstat_effectivedatetime        timestamp NULL,
    medstat_effectiveperiod_start    timestamp NULL,
    medstat_effectiveperiod_end      timestamp NULL,
    medstat_medication_system        varchar NULL,
    medstat_medication_code          varchar NULL,
    PRIMARY KEY (medstat_id)
);

CREATE TABLE db2dataprocessor_out.v_medicationrequest_last_version
(
    medreq_id                       varchar NOT NULL,
    medreq_encounter_calculated_ref varchar NULL,
    medreq_patient_ref              varchar NULL,
    medreq_authoredon               timestamp NULL,
    medreq_medication_system        varchar NULL,
    medreq_medication_code          varchar NULL,
    PRIMARY KEY (medreq_id)
);
ALTER TABLE db2dataprocessor_out.v_encounter_last_version ADD enc_main_encounter_calculated_ref varchar;
CREATE TABLE db2dataprocessor_out.v_pids_per_ward(encounter_id varchar,ward_name varchar);
INSERT INTO db2dataprocessor_out.v_patient_last_version VALUES ('P','1980-01-01','female');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('early_hospital','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/early_hospital');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_early_hospital','Encounter/early_hospital','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('early_hospital_w0','Patient/P','versorgungsstellenkontakt','2026-01-15','2026-01-15','Encounter/early_hospital'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('early_hospital_w0','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('no_ip','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/no_ip');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_no_ip','Encounter/no_ip','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('before_then_inside','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/before_then_inside');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_before_then_inside','Encounter/before_then_inside','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('before_then_inside_w0','Patient/P','versorgungsstellenkontakt','2026-01-09','2026-01-09','Encounter/before_then_inside'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('before_then_inside_w0','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('before_then_inside_w1','Patient/P','versorgungsstellenkontakt','2026-01-15','2026-01-15','Encounter/before_then_inside'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('before_then_inside_w1','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('at_start','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/at_start');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_at_start','Encounter/at_start','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('at_start_w0','Patient/P','versorgungsstellenkontakt','2026-01-10','2026-01-10','Encounter/at_start'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('at_start_w0','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('at_end','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/at_end');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_at_end','Encounter/at_end','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('at_end_w0','Patient/P','versorgungsstellenkontakt','2026-02-01','2026-02-01','Encounter/at_end'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('at_end_w0','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('multiple','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/multiple');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_multiple','Encounter/multiple','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('multiple_w0','Patient/P','versorgungsstellenkontakt','2026-01-12','2026-01-12','Encounter/multiple'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('multiple_w0','A');
INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('multiple_w0','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('multiple_w1','Patient/P','versorgungsstellenkontakt','2026-01-16','2026-01-16','Encounter/multiple'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('multiple_w1','A');
INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('multiple_w1','A');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('ward_b_before','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/ward_b_before');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_ward_b_before','Encounter/ward_b_before','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('ward_b_before_w0','Patient/P','versorgungsstellenkontakt','2026-01-15','2026-01-15','Encounter/ward_b_before'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('ward_b_before_w0','B');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('ward_b_inside','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/ward_b_inside');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_ward_b_inside','Encounter/ward_b_inside','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('ward_b_inside_w0','Patient/P','versorgungsstellenkontakt','2026-01-20','2026-01-20','Encounter/ward_b_inside'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('ward_b_inside_w0','B');
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_class_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('ended','Patient/P','einrichtungskontakt','IMP','2026-01-01','2026-03-01','Encounter/ended');
INSERT INTO db2dataprocessor_out.v_observation_last_version VALUES ('o_ended','Encounter/ended','Patient/P','2823-3','2026-01-16',2.0);
INSERT INTO db2dataprocessor_out.v_encounter_last_version(enc_id,enc_patient_ref,enc_type_code,enc_period_start,enc_period_end,enc_main_encounter_calculated_ref) VALUES ('ended_w0','Patient/P','versorgungsstellenkontakt','2026-01-11','2026-01-11','Encounter/ended'); INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('ended_w0','A');
INSERT INTO db2dataprocessor_out.v_condition_last_version
(con_id,con_encounter_calculated_ref,con_patient_ref,con_code_system,con_code_code,con_recordeddate)
SELECT 'c_'||enc_id,'Encounter/'||enc_id,'Patient/P',
'http://fhir.de/CodeSystem/bfarm/icd-10-gm','F05.1','2026-01-16'
FROM db2dataprocessor_out.v_encounter_last_version WHERE enc_type_code='einrichtungskontakt';

-- Missing station encounters are reported and ignored, including repeated rows.
INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES
('absent','A'), ('absent','A'), ('absent2','A'), ('absent3','A'),
('absent4','A'), ('absent5','A'), (NULL,'A');
