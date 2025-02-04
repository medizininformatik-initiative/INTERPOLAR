-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-01-13 09:38:21
-- Rights definition file size        : 15240 Byte
--
-- Create SQL Tables in Schema "cds2db_in"
-- Create time: 2025-02-04 23:38:17
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  10_cre_table_raw_cds2db_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_in
-- TAGS:  RAW
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _raw
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "cds2db_in" --
-----------------------------------------------------

-- Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.encounter_raw (
  encounter_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  enc_id VARCHAR,   -- id (VARCHAR)
  enc_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  enc_partof_ref VARCHAR,   -- partOf/reference (VARCHAR)
  enc_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  enc_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  enc_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  enc_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  enc_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  enc_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  enc_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  enc_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  enc_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  enc_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  enc_status VARCHAR,   -- status (VARCHAR)
  enc_class_system VARCHAR,   -- class/system (VARCHAR)
  enc_class_version VARCHAR,   -- class/version (VARCHAR)
  enc_class_code VARCHAR,   -- class/code (VARCHAR)
  enc_class_display VARCHAR,   -- class/display (VARCHAR)
  enc_type_system VARCHAR,   -- type/coding/system (VARCHAR)
  enc_type_version VARCHAR,   -- type/coding/version (VARCHAR)
  enc_type_code VARCHAR,   -- type/coding/code (VARCHAR)
  enc_type_display VARCHAR,   -- type/coding/display (VARCHAR)
  enc_type_text VARCHAR,   -- type/text (VARCHAR)
  enc_servicetype_system VARCHAR,   -- serviceType/coding/system (VARCHAR)
  enc_servicetype_version VARCHAR,   -- serviceType/coding/version (VARCHAR)
  enc_servicetype_code VARCHAR,   -- serviceType/coding/code (VARCHAR)
  enc_servicetype_display VARCHAR,   -- serviceType/coding/display (VARCHAR)
  enc_servicetype_text VARCHAR,   -- serviceType/text (VARCHAR)
  enc_period_start VARCHAR,   -- period/start (VARCHAR)
  enc_period_end VARCHAR,   -- period/end (VARCHAR)
  enc_diagnosis_condition_ref VARCHAR,   -- diagnosis/condition/reference (VARCHAR)
  enc_diagnosis_use_system VARCHAR,   -- diagnosis/use/coding/system (VARCHAR)
  enc_diagnosis_use_version VARCHAR,   -- diagnosis/use/coding/version (VARCHAR)
  enc_diagnosis_use_code VARCHAR,   -- diagnosis/use/coding/code (VARCHAR)
  enc_diagnosis_use_display VARCHAR,   -- diagnosis/use/coding/display (VARCHAR)
  enc_diagnosis_use_text VARCHAR,   -- diagnosis/use/text (VARCHAR)
  enc_diagnosis_rank VARCHAR,   -- diagnosis/rank (VARCHAR)
  enc_hospitalization_admitsource_system VARCHAR,   -- hospitalization/admitSource/coding/system (VARCHAR)
  enc_hospitalization_admitsource_version VARCHAR,   -- hospitalization/admitSource/coding/version (VARCHAR)
  enc_hospitalization_admitsource_code VARCHAR,   -- hospitalization/admitSource/coding/code (VARCHAR)
  enc_hospitalization_admitsource_display VARCHAR,   -- hospitalization/admitSource/coding/display (VARCHAR)
  enc_hospitalization_admitsource_text VARCHAR,   -- hospitalization/admitSource/text (VARCHAR)
  enc_hospitalization_dischargedisposition_system VARCHAR,   -- hospitalization/dischargeDisposition/coding/system (VARCHAR)
  enc_hospitalization_dischargedisposition_version VARCHAR,   -- hospitalization/dischargeDisposition/coding/version (VARCHAR)
  enc_hospitalization_dischargedisposition_code VARCHAR,   -- hospitalization/dischargeDisposition/coding/code (VARCHAR)
  enc_hospitalization_dischargedisposition_display VARCHAR,   -- hospitalization/dischargeDisposition/coding/display (VARCHAR)
  enc_hospitalization_dischargedisposition_text VARCHAR,   -- hospitalization/dischargeDisposition/text (VARCHAR)
  enc_location_ref VARCHAR,   -- location/location/reference (VARCHAR)
  enc_location_type VARCHAR,   -- location/location/type (VARCHAR)
  enc_location_identifier_use VARCHAR,   -- location/location/identifier/use (VARCHAR)
  enc_location_identifier_type_system VARCHAR,   -- location/location/identifier/type/coding/system (VARCHAR)
  enc_location_identifier_type_version VARCHAR,   -- location/location/identifier/type/coding/version (VARCHAR)
  enc_location_identifier_type_code VARCHAR,   -- location/location/identifier/type/coding/code (VARCHAR)
  enc_location_identifier_type_display VARCHAR,   -- location/location/identifier/type/coding/display (VARCHAR)
  enc_location_identifier_type_text VARCHAR,   -- location/location/identifier/type/text (VARCHAR)
  enc_location_display VARCHAR,   -- location/location/display (VARCHAR)
  enc_location_status VARCHAR,   -- location/status (VARCHAR)
  enc_location_physicaltype_system VARCHAR,   -- location/physicalType/coding/system (VARCHAR)
  enc_location_physicaltype_version VARCHAR,   -- location/physicalType/coding/version (VARCHAR)
  enc_location_physicaltype_code VARCHAR,   -- location/physicalType/coding/code (VARCHAR)
  enc_location_physicaltype_display VARCHAR,   -- location/physicalType/coding/display (VARCHAR)
  enc_location_physicaltype_text VARCHAR,   -- location/physicalType/text (VARCHAR)
  enc_serviceprovider_ref VARCHAR,   -- serviceProvider/reference (VARCHAR)
  enc_serviceprovider_type VARCHAR,   -- serviceProvider/type (VARCHAR)
  enc_serviceprovider_identifier_use VARCHAR,   -- serviceProvider/identifier/use (VARCHAR)
  enc_serviceprovider_identifier_type_system VARCHAR,   -- serviceProvider/identifier/type/coding/system (VARCHAR)
  enc_serviceprovider_identifier_type_version VARCHAR,   -- serviceProvider/identifier/type/coding/version (VARCHAR)
  enc_serviceprovider_identifier_type_code VARCHAR,   -- serviceProvider/identifier/type/coding/code (VARCHAR)
  enc_serviceprovider_identifier_type_display VARCHAR,   -- serviceProvider/identifier/type/coding/display (VARCHAR)
  enc_serviceprovider_identifier_type_text VARCHAR,   -- serviceProvider/identifier/type/text (VARCHAR)
  enc_serviceprovider_display VARCHAR,   -- serviceProvider/display (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(enc_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(enc_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(enc_partof_ref, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(enc_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(enc_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(enc_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(enc_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(enc_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(enc_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(enc_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(enc_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(enc_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(enc_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(enc_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(enc_class_system, '#NULL#') || '|||' || -- hash from: class/system
             COALESCE(enc_class_version, '#NULL#') || '|||' || -- hash from: class/version
             COALESCE(enc_class_code, '#NULL#') || '|||' || -- hash from: class/code
             COALESCE(enc_class_display, '#NULL#') || '|||' || -- hash from: class/display
             COALESCE(enc_type_system, '#NULL#') || '|||' || -- hash from: type/coding/system
             COALESCE(enc_type_version, '#NULL#') || '|||' || -- hash from: type/coding/version
             COALESCE(enc_type_code, '#NULL#') || '|||' || -- hash from: type/coding/code
             COALESCE(enc_type_display, '#NULL#') || '|||' || -- hash from: type/coding/display
             COALESCE(enc_type_text, '#NULL#') || '|||' || -- hash from: type/text
             COALESCE(enc_servicetype_system, '#NULL#') || '|||' || -- hash from: serviceType/coding/system
             COALESCE(enc_servicetype_version, '#NULL#') || '|||' || -- hash from: serviceType/coding/version
             COALESCE(enc_servicetype_code, '#NULL#') || '|||' || -- hash from: serviceType/coding/code
             COALESCE(enc_servicetype_display, '#NULL#') || '|||' || -- hash from: serviceType/coding/display
             COALESCE(enc_servicetype_text, '#NULL#') || '|||' || -- hash from: serviceType/text
             COALESCE(enc_period_start, '#NULL#') || '|||' || -- hash from: period/start
             COALESCE(enc_period_end, '#NULL#') || '|||' || -- hash from: period/end
             COALESCE(enc_diagnosis_condition_ref, '#NULL#') || '|||' || -- hash from: diagnosis/condition/reference
             COALESCE(enc_diagnosis_use_system, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/system
             COALESCE(enc_diagnosis_use_version, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/version
             COALESCE(enc_diagnosis_use_code, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/code
             COALESCE(enc_diagnosis_use_display, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/display
             COALESCE(enc_diagnosis_use_text, '#NULL#') || '|||' || -- hash from: diagnosis/use/text
             COALESCE(enc_diagnosis_rank, '#NULL#') || '|||' || -- hash from: diagnosis/rank
             COALESCE(enc_hospitalization_admitsource_system, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/system
             COALESCE(enc_hospitalization_admitsource_version, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/version
             COALESCE(enc_hospitalization_admitsource_code, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/code
             COALESCE(enc_hospitalization_admitsource_display, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/display
             COALESCE(enc_hospitalization_admitsource_text, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/text
             COALESCE(enc_hospitalization_dischargedisposition_system, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/system
             COALESCE(enc_hospitalization_dischargedisposition_version, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/version
             COALESCE(enc_hospitalization_dischargedisposition_code, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/code
             COALESCE(enc_hospitalization_dischargedisposition_display, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/display
             COALESCE(enc_hospitalization_dischargedisposition_text, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/text
             COALESCE(enc_location_ref, '#NULL#') || '|||' || -- hash from: location/location/reference
             COALESCE(enc_location_type, '#NULL#') || '|||' || -- hash from: location/location/type
             COALESCE(enc_location_identifier_use, '#NULL#') || '|||' || -- hash from: location/location/identifier/use
             COALESCE(enc_location_identifier_type_system, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/system
             COALESCE(enc_location_identifier_type_version, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/version
             COALESCE(enc_location_identifier_type_code, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/code
             COALESCE(enc_location_identifier_type_display, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/display
             COALESCE(enc_location_identifier_type_text, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/text
             COALESCE(enc_location_display, '#NULL#') || '|||' || -- hash from: location/location/display
             COALESCE(enc_location_status, '#NULL#') || '|||' || -- hash from: location/status
             COALESCE(enc_location_physicaltype_system, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/system
             COALESCE(enc_location_physicaltype_version, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/version
             COALESCE(enc_location_physicaltype_code, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/code
             COALESCE(enc_location_physicaltype_display, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/display
             COALESCE(enc_location_physicaltype_text, '#NULL#') || '|||' || -- hash from: location/physicalType/text
             COALESCE(enc_serviceprovider_ref, '#NULL#') || '|||' || -- hash from: serviceProvider/reference
             COALESCE(enc_serviceprovider_type, '#NULL#') || '|||' || -- hash from: serviceProvider/type
             COALESCE(enc_serviceprovider_identifier_use, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/use
             COALESCE(enc_serviceprovider_identifier_type_system, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/system
             COALESCE(enc_serviceprovider_identifier_type_version, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/version
             COALESCE(enc_serviceprovider_identifier_type_code, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/code
             COALESCE(enc_serviceprovider_identifier_type_display, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/display
             COALESCE(enc_serviceprovider_identifier_type_text, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/text
             COALESCE(enc_serviceprovider_display, '#NULL#') || '|||' || -- hash from: serviceProvider/display
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.patient_raw (
  patient_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  pat_id VARCHAR,   -- id (VARCHAR)
  pat_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  pat_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  pat_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  pat_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  pat_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  pat_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  pat_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  pat_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  pat_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  pat_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  pat_name_text VARCHAR,   -- name/text (VARCHAR)
  pat_name_family VARCHAR,   -- name/family (VARCHAR)
  pat_name_given VARCHAR,   -- name/given (VARCHAR)
  pat_gender VARCHAR,   -- gender (VARCHAR)
  pat_birthdate VARCHAR,   -- birthDate (VARCHAR)
  pat_address_postalcode VARCHAR,   -- address/postalCode (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(pat_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(pat_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(pat_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(pat_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(pat_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(pat_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(pat_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(pat_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(pat_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(pat_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(pat_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(pat_name_text, '#NULL#') || '|||' || -- hash from: name/text
             COALESCE(pat_name_family, '#NULL#') || '|||' || -- hash from: name/family
             COALESCE(pat_name_given, '#NULL#') || '|||' || -- hash from: name/given
             COALESCE(pat_gender, '#NULL#') || '|||' || -- hash from: gender
             COALESCE(pat_birthdate, '#NULL#') || '|||' || -- hash from: birthDate
             COALESCE(pat_address_postalcode, '#NULL#') || '|||' || -- hash from: address/postalCode
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.condition_raw (
  condition_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  con_id VARCHAR,   -- id (VARCHAR)
  con_encounter_ref VARCHAR,   -- encounter/reference (VARCHAR)
  con_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  con_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  con_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  con_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  con_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  con_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  con_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  con_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  con_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  con_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  con_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  con_clinicalstatus_system VARCHAR,   -- clinicalStatus/coding/system (VARCHAR)
  con_clinicalstatus_version VARCHAR,   -- clinicalStatus/coding/version (VARCHAR)
  con_clinicalstatus_code VARCHAR,   -- clinicalStatus/coding/code (VARCHAR)
  con_clinicalstatus_display VARCHAR,   -- clinicalStatus/coding/display (VARCHAR)
  con_clinicalstatus_text VARCHAR,   -- clinicalStatus/text (VARCHAR)
  con_verificationstatus_system VARCHAR,   -- verificationStatus/coding/system (VARCHAR)
  con_verificationstatus_version VARCHAR,   -- verificationStatus/coding/version (VARCHAR)
  con_verificationstatus_code VARCHAR,   -- verificationStatus/coding/code (VARCHAR)
  con_verificationstatus_display VARCHAR,   -- verificationStatus/coding/display (VARCHAR)
  con_verificationstatus_text VARCHAR,   -- verificationStatus/text (VARCHAR)
  con_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  con_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  con_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  con_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  con_category_text VARCHAR,   -- category/text (VARCHAR)
  con_severity_system VARCHAR,   -- severity/coding/system (VARCHAR)
  con_severity_version VARCHAR,   -- severity/coding/version (VARCHAR)
  con_severity_code VARCHAR,   -- severity/coding/code (VARCHAR)
  con_severity_display VARCHAR,   -- severity/coding/display (VARCHAR)
  con_severity_text VARCHAR,   -- severity/text (VARCHAR)
  con_code_system VARCHAR,   -- code/coding/system (VARCHAR)
  con_code_version VARCHAR,   -- code/coding/version (VARCHAR)
  con_code_code VARCHAR,   -- code/coding/code (VARCHAR)
  con_code_display VARCHAR,   -- code/coding/display (VARCHAR)
  con_code_text VARCHAR,   -- code/text (VARCHAR)
  con_bodysite_system VARCHAR,   -- bodySite/coding/system (VARCHAR)
  con_bodysite_version VARCHAR,   -- bodySite/coding/version (VARCHAR)
  con_bodysite_code VARCHAR,   -- bodySite/coding/code (VARCHAR)
  con_bodysite_display VARCHAR,   -- bodySite/coding/display (VARCHAR)
  con_bodysite_text VARCHAR,   -- bodySite/text (VARCHAR)
  con_onsetperiod_start VARCHAR,   -- onsetPeriod/start (VARCHAR)
  con_onsetperiod_end VARCHAR,   -- onsetPeriod/end (VARCHAR)
  con_onsetdatetime VARCHAR,   -- onsetDateTime (VARCHAR)
  con_abatementdatetime VARCHAR,   -- abatementDateTime (VARCHAR)
  con_abatementage_value VARCHAR,   -- abatementAge/value (VARCHAR)
  con_abatementage_comparator VARCHAR,   -- abatementAge/comparator (VARCHAR)
  con_abatementage_unit VARCHAR,   -- abatementAge/unit (VARCHAR)
  con_abatementage_system VARCHAR,   -- abatementAge/system (VARCHAR)
  con_abatementage_code VARCHAR,   -- abatementAge/code (VARCHAR)
  con_abatementperiod_start VARCHAR,   -- abatementPeriod/start (VARCHAR)
  con_abatementperiod_end VARCHAR,   -- abatementPeriod/end (VARCHAR)
  con_abatementrange_low_value VARCHAR,   -- abatementRange/low/value (VARCHAR)
  con_abatementrange_low_unit VARCHAR,   -- abatementRange/low/unit (VARCHAR)
  con_abatementrange_low_system VARCHAR,   -- abatementRange/low/system (VARCHAR)
  con_abatementrange_low_code VARCHAR,   -- abatementRange/low/code (VARCHAR)
  con_abatementrange_high_value VARCHAR,   -- abatementRange/high/value (VARCHAR)
  con_abatementrange_high_unit VARCHAR,   -- abatementRange/high/unit (VARCHAR)
  con_abatementrange_high_system VARCHAR,   -- abatementRange/high/system (VARCHAR)
  con_abatementrange_high_code VARCHAR,   -- abatementRange/high/code (VARCHAR)
  con_abatementstring VARCHAR,   -- abatementString (VARCHAR)
  con_recordeddate VARCHAR,   -- recordedDate (VARCHAR)
  con_recorder_ref VARCHAR,   -- recorder/reference (VARCHAR)
  con_recorder_type VARCHAR,   -- recorder/type (VARCHAR)
  con_recorder_identifier_use VARCHAR,   -- recorder/identifier/use (VARCHAR)
  con_recorder_identifier_type_system VARCHAR,   -- recorder/identifier/type/coding/system (VARCHAR)
  con_recorder_identifier_type_version VARCHAR,   -- recorder/identifier/type/coding/version (VARCHAR)
  con_recorder_identifier_type_code VARCHAR,   -- recorder/identifier/type/coding/code (VARCHAR)
  con_recorder_identifier_type_display VARCHAR,   -- recorder/identifier/type/coding/display (VARCHAR)
  con_recorder_identifier_type_text VARCHAR,   -- recorder/identifier/type/text (VARCHAR)
  con_recorder_display VARCHAR,   -- recorder/display (VARCHAR)
  con_asserter_ref VARCHAR,   -- asserter/reference (VARCHAR)
  con_asserter_type VARCHAR,   -- asserter/type (VARCHAR)
  con_asserter_identifier_use VARCHAR,   -- asserter/identifier/use (VARCHAR)
  con_asserter_identifier_type_system VARCHAR,   -- asserter/identifier/type/coding/system (VARCHAR)
  con_asserter_identifier_type_version VARCHAR,   -- asserter/identifier/type/coding/version (VARCHAR)
  con_asserter_identifier_type_code VARCHAR,   -- asserter/identifier/type/coding/code (VARCHAR)
  con_asserter_identifier_type_display VARCHAR,   -- asserter/identifier/type/coding/display (VARCHAR)
  con_asserter_identifier_type_text VARCHAR,   -- asserter/identifier/type/text (VARCHAR)
  con_asserter_display VARCHAR,   -- asserter/display (VARCHAR)
  con_stage_summary_system VARCHAR,   -- stage/summary/coding/system (VARCHAR)
  con_stage_summary_version VARCHAR,   -- stage/summary/coding/version (VARCHAR)
  con_stage_summary_code VARCHAR,   -- stage/summary/coding/code (VARCHAR)
  con_stage_summary_display VARCHAR,   -- stage/summary/coding/display (VARCHAR)
  con_stage_summary_text VARCHAR,   -- stage/summary/text (VARCHAR)
  con_stage_assessment_ref VARCHAR,   -- stage/assessment/reference (VARCHAR)
  con_stage_assessment_type VARCHAR,   -- stage/assessment/type (VARCHAR)
  con_stage_assessment_identifier_use VARCHAR,   -- stage/assessment/identifier/use (VARCHAR)
  con_stage_assessment_identifier_type_system VARCHAR,   -- stage/assessment/identifier/type/coding/system (VARCHAR)
  con_stage_assessment_identifier_type_version VARCHAR,   -- stage/assessment/identifier/type/coding/version (VARCHAR)
  con_stage_assessment_identifier_type_code VARCHAR,   -- stage/assessment/identifier/type/coding/code (VARCHAR)
  con_stage_assessment_identifier_type_display VARCHAR,   -- stage/assessment/identifier/type/coding/display (VARCHAR)
  con_stage_assessment_identifier_type_text VARCHAR,   -- stage/assessment/identifier/type/text (VARCHAR)
  con_stage_assessment_display VARCHAR,   -- stage/assessment/display (VARCHAR)
  con_stage_type_system VARCHAR,   -- stage/type/coding/system (VARCHAR)
  con_stage_type_version VARCHAR,   -- stage/type/coding/version (VARCHAR)
  con_stage_type_code VARCHAR,   -- stage/type/coding/code (VARCHAR)
  con_stage_type_display VARCHAR,   -- stage/type/coding/display (VARCHAR)
  con_stage_type_text VARCHAR,   -- stage/type/text (VARCHAR)
  con_note_authorstring VARCHAR,   -- note/authorString (VARCHAR)
  con_note_authorreference_ref VARCHAR,   -- note/authorReference/reference (VARCHAR)
  con_note_authorreference_type VARCHAR,   -- note/authorReference/type (VARCHAR)
  con_note_authorreference_identifier_use VARCHAR,   -- note/authorReference/identifier/use (VARCHAR)
  con_note_authorreference_identifier_type_system VARCHAR,   -- note/authorReference/identifier/type/coding/system (VARCHAR)
  con_note_authorreference_identifier_type_version VARCHAR,   -- note/authorReference/identifier/type/coding/version (VARCHAR)
  con_note_authorreference_identifier_type_code VARCHAR,   -- note/authorReference/identifier/type/coding/code (VARCHAR)
  con_note_authorreference_identifier_type_display VARCHAR,   -- note/authorReference/identifier/type/coding/display (VARCHAR)
  con_note_authorreference_identifier_type_text VARCHAR,   -- note/authorReference/identifier/type/text (VARCHAR)
  con_note_authorreference_display VARCHAR,   -- note/authorReference/display (VARCHAR)
  con_note_time VARCHAR,   -- note/time (VARCHAR)
  con_note_text VARCHAR,   -- note/text (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(con_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(con_encounter_ref, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(con_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(con_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(con_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(con_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(con_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(con_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(con_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(con_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(con_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(con_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(con_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(con_clinicalstatus_system, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/system
             COALESCE(con_clinicalstatus_version, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/version
             COALESCE(con_clinicalstatus_code, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/code
             COALESCE(con_clinicalstatus_display, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/display
             COALESCE(con_clinicalstatus_text, '#NULL#') || '|||' || -- hash from: clinicalStatus/text
             COALESCE(con_verificationstatus_system, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/system
             COALESCE(con_verificationstatus_version, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/version
             COALESCE(con_verificationstatus_code, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/code
             COALESCE(con_verificationstatus_display, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/display
             COALESCE(con_verificationstatus_text, '#NULL#') || '|||' || -- hash from: verificationStatus/text
             COALESCE(con_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(con_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(con_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(con_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(con_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(con_severity_system, '#NULL#') || '|||' || -- hash from: severity/coding/system
             COALESCE(con_severity_version, '#NULL#') || '|||' || -- hash from: severity/coding/version
             COALESCE(con_severity_code, '#NULL#') || '|||' || -- hash from: severity/coding/code
             COALESCE(con_severity_display, '#NULL#') || '|||' || -- hash from: severity/coding/display
             COALESCE(con_severity_text, '#NULL#') || '|||' || -- hash from: severity/text
             COALESCE(con_code_system, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(con_code_version, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(con_code_code, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(con_code_display, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(con_code_text, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(con_bodysite_system, '#NULL#') || '|||' || -- hash from: bodySite/coding/system
             COALESCE(con_bodysite_version, '#NULL#') || '|||' || -- hash from: bodySite/coding/version
             COALESCE(con_bodysite_code, '#NULL#') || '|||' || -- hash from: bodySite/coding/code
             COALESCE(con_bodysite_display, '#NULL#') || '|||' || -- hash from: bodySite/coding/display
             COALESCE(con_bodysite_text, '#NULL#') || '|||' || -- hash from: bodySite/text
             COALESCE(con_onsetperiod_start, '#NULL#') || '|||' || -- hash from: onsetPeriod/start
             COALESCE(con_onsetperiod_end, '#NULL#') || '|||' || -- hash from: onsetPeriod/end
             COALESCE(con_onsetdatetime, '#NULL#') || '|||' || -- hash from: onsetDateTime
             COALESCE(con_abatementdatetime, '#NULL#') || '|||' || -- hash from: abatementDateTime
             COALESCE(con_abatementage_value, '#NULL#') || '|||' || -- hash from: abatementAge/value
             COALESCE(con_abatementage_comparator, '#NULL#') || '|||' || -- hash from: abatementAge/comparator
             COALESCE(con_abatementage_unit, '#NULL#') || '|||' || -- hash from: abatementAge/unit
             COALESCE(con_abatementage_system, '#NULL#') || '|||' || -- hash from: abatementAge/system
             COALESCE(con_abatementage_code, '#NULL#') || '|||' || -- hash from: abatementAge/code
             COALESCE(con_abatementperiod_start, '#NULL#') || '|||' || -- hash from: abatementPeriod/start
             COALESCE(con_abatementperiod_end, '#NULL#') || '|||' || -- hash from: abatementPeriod/end
             COALESCE(con_abatementrange_low_value, '#NULL#') || '|||' || -- hash from: abatementRange/low/value
             COALESCE(con_abatementrange_low_unit, '#NULL#') || '|||' || -- hash from: abatementRange/low/unit
             COALESCE(con_abatementrange_low_system, '#NULL#') || '|||' || -- hash from: abatementRange/low/system
             COALESCE(con_abatementrange_low_code, '#NULL#') || '|||' || -- hash from: abatementRange/low/code
             COALESCE(con_abatementrange_high_value, '#NULL#') || '|||' || -- hash from: abatementRange/high/value
             COALESCE(con_abatementrange_high_unit, '#NULL#') || '|||' || -- hash from: abatementRange/high/unit
             COALESCE(con_abatementrange_high_system, '#NULL#') || '|||' || -- hash from: abatementRange/high/system
             COALESCE(con_abatementrange_high_code, '#NULL#') || '|||' || -- hash from: abatementRange/high/code
             COALESCE(con_abatementstring, '#NULL#') || '|||' || -- hash from: abatementString
             COALESCE(con_recordeddate, '#NULL#') || '|||' || -- hash from: recordedDate
             COALESCE(con_recorder_ref, '#NULL#') || '|||' || -- hash from: recorder/reference
             COALESCE(con_recorder_type, '#NULL#') || '|||' || -- hash from: recorder/type
             COALESCE(con_recorder_identifier_use, '#NULL#') || '|||' || -- hash from: recorder/identifier/use
             COALESCE(con_recorder_identifier_type_system, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/system
             COALESCE(con_recorder_identifier_type_version, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/version
             COALESCE(con_recorder_identifier_type_code, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/code
             COALESCE(con_recorder_identifier_type_display, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/display
             COALESCE(con_recorder_identifier_type_text, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/text
             COALESCE(con_recorder_display, '#NULL#') || '|||' || -- hash from: recorder/display
             COALESCE(con_asserter_ref, '#NULL#') || '|||' || -- hash from: asserter/reference
             COALESCE(con_asserter_type, '#NULL#') || '|||' || -- hash from: asserter/type
             COALESCE(con_asserter_identifier_use, '#NULL#') || '|||' || -- hash from: asserter/identifier/use
             COALESCE(con_asserter_identifier_type_system, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/system
             COALESCE(con_asserter_identifier_type_version, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/version
             COALESCE(con_asserter_identifier_type_code, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/code
             COALESCE(con_asserter_identifier_type_display, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/display
             COALESCE(con_asserter_identifier_type_text, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/text
             COALESCE(con_asserter_display, '#NULL#') || '|||' || -- hash from: asserter/display
             COALESCE(con_stage_summary_system, '#NULL#') || '|||' || -- hash from: stage/summary/coding/system
             COALESCE(con_stage_summary_version, '#NULL#') || '|||' || -- hash from: stage/summary/coding/version
             COALESCE(con_stage_summary_code, '#NULL#') || '|||' || -- hash from: stage/summary/coding/code
             COALESCE(con_stage_summary_display, '#NULL#') || '|||' || -- hash from: stage/summary/coding/display
             COALESCE(con_stage_summary_text, '#NULL#') || '|||' || -- hash from: stage/summary/text
             COALESCE(con_stage_assessment_ref, '#NULL#') || '|||' || -- hash from: stage/assessment/reference
             COALESCE(con_stage_assessment_type, '#NULL#') || '|||' || -- hash from: stage/assessment/type
             COALESCE(con_stage_assessment_identifier_use, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/use
             COALESCE(con_stage_assessment_identifier_type_system, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/system
             COALESCE(con_stage_assessment_identifier_type_version, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/version
             COALESCE(con_stage_assessment_identifier_type_code, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/code
             COALESCE(con_stage_assessment_identifier_type_display, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/display
             COALESCE(con_stage_assessment_identifier_type_text, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/text
             COALESCE(con_stage_assessment_display, '#NULL#') || '|||' || -- hash from: stage/assessment/display
             COALESCE(con_stage_type_system, '#NULL#') || '|||' || -- hash from: stage/type/coding/system
             COALESCE(con_stage_type_version, '#NULL#') || '|||' || -- hash from: stage/type/coding/version
             COALESCE(con_stage_type_code, '#NULL#') || '|||' || -- hash from: stage/type/coding/code
             COALESCE(con_stage_type_display, '#NULL#') || '|||' || -- hash from: stage/type/coding/display
             COALESCE(con_stage_type_text, '#NULL#') || '|||' || -- hash from: stage/type/text
             COALESCE(con_note_authorstring, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(con_note_authorreference_ref, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(con_note_authorreference_type, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(con_note_authorreference_identifier_use, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(con_note_authorreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(con_note_authorreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(con_note_authorreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(con_note_authorreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(con_note_authorreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(con_note_authorreference_display, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(con_note_time, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(con_note_text, '#NULL#') || '|||' || -- hash from: note/text
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medication_raw (
  medication_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  med_id VARCHAR,   -- id (VARCHAR)
  med_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  med_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  med_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  med_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  med_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  med_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  med_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  med_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  med_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  med_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  med_code_system VARCHAR,   -- code/coding/system (VARCHAR)
  med_code_version VARCHAR,   -- code/coding/version (VARCHAR)
  med_code_code VARCHAR,   -- code/coding/code (VARCHAR)
  med_code_display VARCHAR,   -- code/coding/display (VARCHAR)
  med_code_text VARCHAR,   -- code/text (VARCHAR)
  med_status VARCHAR,   -- status (VARCHAR)
  med_form_system VARCHAR,   -- form/coding/system (VARCHAR)
  med_form_version VARCHAR,   -- form/coding/version (VARCHAR)
  med_form_code VARCHAR,   -- form/coding/code (VARCHAR)
  med_form_display VARCHAR,   -- form/coding/display (VARCHAR)
  med_form_text VARCHAR,   -- form/text (VARCHAR)
  med_amount_numerator_value VARCHAR,   -- amount/numerator/value (VARCHAR)
  med_amount_numerator_comparator VARCHAR,   -- amount/numerator/comparator (VARCHAR)
  med_amount_numerator_unit VARCHAR,   -- amount/numerator/unit (VARCHAR)
  med_amount_numerator_system VARCHAR,   -- amount/numerator/system (VARCHAR)
  med_amount_numerator_code VARCHAR,   -- amount/numerator/code (VARCHAR)
  med_amount_denominator_value VARCHAR,   -- amount/denominator/value (VARCHAR)
  med_amount_denominator_comparator VARCHAR,   -- amount/denominator/comparator (VARCHAR)
  med_amount_denominator_unit VARCHAR,   -- amount/denominator/unit (VARCHAR)
  med_amount_denominator_system VARCHAR,   -- amount/denominator/system (VARCHAR)
  med_amount_denominator_code VARCHAR,   -- amount/denominator/code (VARCHAR)
  med_ingredient_strength_numerator_value VARCHAR,   -- ingredient/strength/numerator/value (VARCHAR)
  med_ingredient_strength_numerator_comparator VARCHAR,   -- ingredient/strength/numerator/comparator (VARCHAR)
  med_ingredient_strength_numerator_unit VARCHAR,   -- ingredient/strength/numerator/unit (VARCHAR)
  med_ingredient_strength_numerator_system VARCHAR,   -- ingredient/strength/numerator/system (VARCHAR)
  med_ingredient_strength_numerator_code VARCHAR,   -- ingredient/strength/numerator/code (VARCHAR)
  med_ingredient_strength_denominator_value VARCHAR,   -- ingredient/strength/denominator/value (VARCHAR)
  med_ingredient_strength_denominator_comparator VARCHAR,   -- ingredient/strength/denominator/comparator (VARCHAR)
  med_ingredient_strength_denominator_unit VARCHAR,   -- ingredient/strength/denominator/unit (VARCHAR)
  med_ingredient_strength_denominator_system VARCHAR,   -- ingredient/strength/denominator/system (VARCHAR)
  med_ingredient_strength_denominator_code VARCHAR,   -- ingredient/strength/denominator/code (VARCHAR)
  med_ingredient_itemcodeableconcept_system VARCHAR,   -- ingredient/itemCodeableConcept/coding/system (VARCHAR)
  med_ingredient_itemcodeableconcept_version VARCHAR,   -- ingredient/itemCodeableConcept/coding/version (VARCHAR)
  med_ingredient_itemcodeableconcept_code VARCHAR,   -- ingredient/itemCodeableConcept/coding/code (VARCHAR)
  med_ingredient_itemcodeableconcept_display VARCHAR,   -- ingredient/itemCodeableConcept/coding/display (VARCHAR)
  med_ingredient_itemcodeableconcept_text VARCHAR,   -- ingredient/itemCodeableConcept/text (VARCHAR)
  med_ingredient_itemreference_ref VARCHAR,   -- ingredient/itemReference/reference (VARCHAR)
  med_ingredient_itemreference_type VARCHAR,   -- ingredient/itemReference/type (VARCHAR)
  med_ingredient_itemreference_identifier_use VARCHAR,   -- ingredient/itemReference/identifier/use (VARCHAR)
  med_ingredient_itemreference_identifier_type_system VARCHAR,   -- ingredient/itemReference/identifier/type/coding/system (VARCHAR)
  med_ingredient_itemreference_identifier_type_version VARCHAR,   -- ingredient/itemReference/identifier/type/coding/version (VARCHAR)
  med_ingredient_itemreference_identifier_type_code VARCHAR,   -- ingredient/itemReference/identifier/type/coding/code (VARCHAR)
  med_ingredient_itemreference_identifier_type_display VARCHAR,   -- ingredient/itemReference/identifier/type/coding/display (VARCHAR)
  med_ingredient_itemreference_identifier_type_text VARCHAR,   -- ingredient/itemReference/identifier/type/text (VARCHAR)
  med_ingredient_itemreference_display VARCHAR,   -- ingredient/itemReference/display (VARCHAR)
  med_ingredient_isactive VARCHAR,   -- ingredient/isActive (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(med_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(med_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(med_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(med_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(med_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(med_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(med_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(med_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(med_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(med_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(med_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(med_code_system, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(med_code_version, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(med_code_code, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(med_code_display, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(med_code_text, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(med_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(med_form_system, '#NULL#') || '|||' || -- hash from: form/coding/system
             COALESCE(med_form_version, '#NULL#') || '|||' || -- hash from: form/coding/version
             COALESCE(med_form_code, '#NULL#') || '|||' || -- hash from: form/coding/code
             COALESCE(med_form_display, '#NULL#') || '|||' || -- hash from: form/coding/display
             COALESCE(med_form_text, '#NULL#') || '|||' || -- hash from: form/text
             COALESCE(med_amount_numerator_value, '#NULL#') || '|||' || -- hash from: amount/numerator/value
             COALESCE(med_amount_numerator_comparator, '#NULL#') || '|||' || -- hash from: amount/numerator/comparator
             COALESCE(med_amount_numerator_unit, '#NULL#') || '|||' || -- hash from: amount/numerator/unit
             COALESCE(med_amount_numerator_system, '#NULL#') || '|||' || -- hash from: amount/numerator/system
             COALESCE(med_amount_numerator_code, '#NULL#') || '|||' || -- hash from: amount/numerator/code
             COALESCE(med_amount_denominator_value, '#NULL#') || '|||' || -- hash from: amount/denominator/value
             COALESCE(med_amount_denominator_comparator, '#NULL#') || '|||' || -- hash from: amount/denominator/comparator
             COALESCE(med_amount_denominator_unit, '#NULL#') || '|||' || -- hash from: amount/denominator/unit
             COALESCE(med_amount_denominator_system, '#NULL#') || '|||' || -- hash from: amount/denominator/system
             COALESCE(med_amount_denominator_code, '#NULL#') || '|||' || -- hash from: amount/denominator/code
             COALESCE(med_ingredient_strength_numerator_value, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/value
             COALESCE(med_ingredient_strength_numerator_comparator, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/comparator
             COALESCE(med_ingredient_strength_numerator_unit, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/unit
             COALESCE(med_ingredient_strength_numerator_system, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/system
             COALESCE(med_ingredient_strength_numerator_code, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/code
             COALESCE(med_ingredient_strength_denominator_value, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/value
             COALESCE(med_ingredient_strength_denominator_comparator, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/comparator
             COALESCE(med_ingredient_strength_denominator_unit, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/unit
             COALESCE(med_ingredient_strength_denominator_system, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/system
             COALESCE(med_ingredient_strength_denominator_code, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/code
             COALESCE(med_ingredient_itemcodeableconcept_system, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/system
             COALESCE(med_ingredient_itemcodeableconcept_version, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/version
             COALESCE(med_ingredient_itemcodeableconcept_code, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/code
             COALESCE(med_ingredient_itemcodeableconcept_display, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/display
             COALESCE(med_ingredient_itemcodeableconcept_text, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/text
             COALESCE(med_ingredient_itemreference_ref, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/reference
             COALESCE(med_ingredient_itemreference_type, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/type
             COALESCE(med_ingredient_itemreference_identifier_use, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/use
             COALESCE(med_ingredient_itemreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/system
             COALESCE(med_ingredient_itemreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/version
             COALESCE(med_ingredient_itemreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/code
             COALESCE(med_ingredient_itemreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/display
             COALESCE(med_ingredient_itemreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/text
             COALESCE(med_ingredient_itemreference_display, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/display
             COALESCE(med_ingredient_isactive, '#NULL#') || '|||' || -- hash from: ingredient/isActive
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationrequest_raw (
  medicationrequest_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medreq_id VARCHAR,   -- id (VARCHAR)
  medreq_encounter_ref VARCHAR,   -- encounter/reference (VARCHAR)
  medreq_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  medreq_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  medreq_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  medreq_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  medreq_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  medreq_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  medreq_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  medreq_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  medreq_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  medreq_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  medreq_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  medreq_medicationreference_ref VARCHAR,   -- medicationReference/reference (VARCHAR)
  medreq_status VARCHAR,   -- status (VARCHAR)
  medreq_statusreason_system VARCHAR,   -- statusReason/coding/system (VARCHAR)
  medreq_statusreason_version VARCHAR,   -- statusReason/coding/version (VARCHAR)
  medreq_statusreason_code VARCHAR,   -- statusReason/coding/code (VARCHAR)
  medreq_statusreason_display VARCHAR,   -- statusReason/coding/display (VARCHAR)
  medreq_statusreason_text VARCHAR,   -- statusReason/text (VARCHAR)
  medreq_intend VARCHAR,   -- intend (VARCHAR)
  medreq_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  medreq_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  medreq_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  medreq_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  medreq_category_text VARCHAR,   -- category/text (VARCHAR)
  medreq_priority VARCHAR,   -- priority (VARCHAR)
  medreq_reportedboolean VARCHAR,   -- reportedBoolean (VARCHAR)
  medreq_reportedreference_ref VARCHAR,   -- reportedReference/reference (VARCHAR)
  medreq_reportedreference_type VARCHAR,   -- reportedReference/type (VARCHAR)
  medreq_reportedreference_identifier_use VARCHAR,   -- reportedReference/identifier/use (VARCHAR)
  medreq_reportedreference_identifier_type_system VARCHAR,   -- reportedReference/identifier/type/coding/system (VARCHAR)
  medreq_reportedreference_identifier_type_version VARCHAR,   -- reportedReference/identifier/type/coding/version (VARCHAR)
  medreq_reportedreference_identifier_type_code VARCHAR,   -- reportedReference/identifier/type/coding/code (VARCHAR)
  medreq_reportedreference_identifier_type_display VARCHAR,   -- reportedReference/identifier/type/coding/display (VARCHAR)
  medreq_reportedreference_identifier_type_text VARCHAR,   -- reportedReference/identifier/type/text (VARCHAR)
  medreq_reportedreference_display VARCHAR,   -- reportedReference/display (VARCHAR)
  medreq_medicationcodeableconcept_system VARCHAR,   -- medicationCodeableConcept/coding/system (VARCHAR)
  medreq_medicationcodeableconcept_version VARCHAR,   -- medicationCodeableConcept/coding/version (VARCHAR)
  medreq_medicationcodeableconcept_code VARCHAR,   -- medicationCodeableConcept/coding/code (VARCHAR)
  medreq_medicationcodeableconcept_display VARCHAR,   -- medicationCodeableConcept/coding/display (VARCHAR)
  medreq_medicationcodeableconcept_text VARCHAR,   -- medicationCodeableConcept/text (VARCHAR)
  medreq_supportinginformation_ref VARCHAR,   -- supportingInformation/reference (VARCHAR)
  medreq_supportinginformation_type VARCHAR,   -- supportingInformation/type (VARCHAR)
  medreq_supportinginformation_identifier_use VARCHAR,   -- supportingInformation/identifier/use (VARCHAR)
  medreq_supportinginformation_identifier_type_system VARCHAR,   -- supportingInformation/identifier/type/coding/system (VARCHAR)
  medreq_supportinginformation_identifier_type_version VARCHAR,   -- supportingInformation/identifier/type/coding/version (VARCHAR)
  medreq_supportinginformation_identifier_type_code VARCHAR,   -- supportingInformation/identifier/type/coding/code (VARCHAR)
  medreq_supportinginformation_identifier_type_display VARCHAR,   -- supportingInformation/identifier/type/coding/display (VARCHAR)
  medreq_supportinginformation_identifier_type_text VARCHAR,   -- supportingInformation/identifier/type/text (VARCHAR)
  medreq_supportinginformation_display VARCHAR,   -- supportingInformation/display (VARCHAR)
  medreq_authoredon VARCHAR,   -- authoredOn (VARCHAR)
  medreq_requester_ref VARCHAR,   -- requester/reference (VARCHAR)
  medreq_requester_type VARCHAR,   -- requester/type (VARCHAR)
  medreq_requester_identifier_use VARCHAR,   -- requester/identifier/use (VARCHAR)
  medreq_requester_identifier_type_system VARCHAR,   -- requester/identifier/type/coding/system (VARCHAR)
  medreq_requester_identifier_type_version VARCHAR,   -- requester/identifier/type/coding/version (VARCHAR)
  medreq_requester_identifier_type_code VARCHAR,   -- requester/identifier/type/coding/code (VARCHAR)
  medreq_requester_identifier_type_display VARCHAR,   -- requester/identifier/type/coding/display (VARCHAR)
  medreq_requester_identifier_type_text VARCHAR,   -- requester/identifier/type/text (VARCHAR)
  medreq_requester_display VARCHAR,   -- requester/display (VARCHAR)
  medreq_reasoncode_system VARCHAR,   -- reasonCode/coding/system (VARCHAR)
  medreq_reasoncode_version VARCHAR,   -- reasonCode/coding/version (VARCHAR)
  medreq_reasoncode_code VARCHAR,   -- reasonCode/coding/code (VARCHAR)
  medreq_reasoncode_display VARCHAR,   -- reasonCode/coding/display (VARCHAR)
  medreq_reasoncode_text VARCHAR,   -- reasonCode/text (VARCHAR)
  medreq_reasonreference_ref VARCHAR,   -- reasonReference/reference (VARCHAR)
  medreq_reasonreference_type VARCHAR,   -- reasonReference/type (VARCHAR)
  medreq_reasonreference_identifier_use VARCHAR,   -- reasonReference/identifier/use (VARCHAR)
  medreq_reasonreference_identifier_type_system VARCHAR,   -- reasonReference/identifier/type/coding/system (VARCHAR)
  medreq_reasonreference_identifier_type_version VARCHAR,   -- reasonReference/identifier/type/coding/version (VARCHAR)
  medreq_reasonreference_identifier_type_code VARCHAR,   -- reasonReference/identifier/type/coding/code (VARCHAR)
  medreq_reasonreference_identifier_type_display VARCHAR,   -- reasonReference/identifier/type/coding/display (VARCHAR)
  medreq_reasonreference_identifier_type_text VARCHAR,   -- reasonReference/identifier/type/text (VARCHAR)
  medreq_reasonreference_display VARCHAR,   -- reasonReference/display (VARCHAR)
  medreq_basedon_ref VARCHAR,   -- basedOn/reference (VARCHAR)
  medreq_basedon_type VARCHAR,   -- basedOn/type (VARCHAR)
  medreq_basedon_identifier_use VARCHAR,   -- basedOn/identifier/use (VARCHAR)
  medreq_basedon_identifier_type_system VARCHAR,   -- basedOn/identifier/type/coding/system (VARCHAR)
  medreq_basedon_identifier_type_version VARCHAR,   -- basedOn/identifier/type/coding/version (VARCHAR)
  medreq_basedon_identifier_type_code VARCHAR,   -- basedOn/identifier/type/coding/code (VARCHAR)
  medreq_basedon_identifier_type_display VARCHAR,   -- basedOn/identifier/type/coding/display (VARCHAR)
  medreq_basedon_identifier_type_text VARCHAR,   -- basedOn/identifier/type/text (VARCHAR)
  medreq_basedon_display VARCHAR,   -- basedOn/display (VARCHAR)
  medreq_note_authorstring VARCHAR,   -- note/authorString (VARCHAR)
  medreq_note_authorreference_ref VARCHAR,   -- note/authorReference/reference (VARCHAR)
  medreq_note_authorreference_type VARCHAR,   -- note/authorReference/type (VARCHAR)
  medreq_note_authorreference_identifier_use VARCHAR,   -- note/authorReference/identifier/use (VARCHAR)
  medreq_note_authorreference_identifier_type_system VARCHAR,   -- note/authorReference/identifier/type/coding/system (VARCHAR)
  medreq_note_authorreference_identifier_type_version VARCHAR,   -- note/authorReference/identifier/type/coding/version (VARCHAR)
  medreq_note_authorreference_identifier_type_code VARCHAR,   -- note/authorReference/identifier/type/coding/code (VARCHAR)
  medreq_note_authorreference_identifier_type_display VARCHAR,   -- note/authorReference/identifier/type/coding/display (VARCHAR)
  medreq_note_authorreference_identifier_type_text VARCHAR,   -- note/authorReference/identifier/type/text (VARCHAR)
  medreq_note_authorreference_display VARCHAR,   -- note/authorReference/display (VARCHAR)
  medreq_note_time VARCHAR,   -- note/time (VARCHAR)
  medreq_note_text VARCHAR,   -- note/text (VARCHAR)
  medreq_doseinstruc_sequence VARCHAR,   -- dosageInstruction/sequence (VARCHAR)
  medreq_doseinstruc_text VARCHAR,   -- dosageInstruction/text (VARCHAR)
  medreq_doseinstruc_additionalinstruction_system VARCHAR,   -- dosageInstruction/additionalInstruction/coding/system (VARCHAR)
  medreq_doseinstruc_additionalinstruction_version VARCHAR,   -- dosageInstruction/additionalInstruction/coding/version (VARCHAR)
  medreq_doseinstruc_additionalinstruction_code VARCHAR,   -- dosageInstruction/additionalInstruction/coding/code (VARCHAR)
  medreq_doseinstruc_additionalinstruction_display VARCHAR,   -- dosageInstruction/additionalInstruction/coding/display (VARCHAR)
  medreq_doseinstruc_additionalinstruction_text VARCHAR,   -- dosageInstruction/additionalInstruction/text (VARCHAR)
  medreq_doseinstruc_patientinstruction VARCHAR,   -- dosageInstruction/patientInstruction (VARCHAR)
  medreq_doseinstruc_timing_event VARCHAR,   -- dosageInstruction/timing/event (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsduration_value VARCHAR,   -- dosageInstruction/timing/repeat/boundsDuration/value (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsduration_comparator VARCHAR,   -- dosageInstruction/timing/repeat/boundsDuration/comparator (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsduration_unit VARCHAR,   -- dosageInstruction/timing/repeat/boundsDuration/unit (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsduration_system VARCHAR,   -- dosageInstruction/timing/repeat/boundsDuration/system (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsduration_code VARCHAR,   -- dosageInstruction/timing/repeat/boundsDuration/code (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_low_value VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/low/value (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_low_unit VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/low/unit (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_low_system VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/low/system (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_low_code VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/low/code (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_high_value VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/high/value (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_high_unit VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/high/unit (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_high_system VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/high/system (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsrange_high_code VARCHAR,   -- dosageInstruction/timing/repeat/boundsRange/high/code (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsperiod_start VARCHAR,   -- dosageInstruction/timing/repeat/boundsPeriod/start (VARCHAR)
  medreq_doseinstruc_timing_repeat_boundsperiod_end VARCHAR,   -- dosageInstruction/timing/repeat/boundsPeriod/end (VARCHAR)
  medreq_doseinstruc_timing_repeat_count VARCHAR,   -- dosageInstruction/timing/repeat/count (VARCHAR)
  medreq_doseinstruc_timing_repeat_countmax VARCHAR,   -- dosageInstruction/timing/repeat/countMax (VARCHAR)
  medreq_doseinstruc_timing_repeat_duration VARCHAR,   -- dosageInstruction/timing/repeat/duration (VARCHAR)
  medreq_doseinstruc_timing_repeat_durationmax VARCHAR,   -- dosageInstruction/timing/repeat/durationMax (VARCHAR)
  medreq_doseinstruc_timing_repeat_durationunit VARCHAR,   -- dosageInstruction/timing/repeat/durationUnit (VARCHAR)
  medreq_doseinstruc_timing_repeat_frequency VARCHAR,   -- dosageInstruction/timing/repeat/frequency (VARCHAR)
  medreq_doseinstruc_timing_repeat_frequencymax VARCHAR,   -- dosageInstruction/timing/repeat/frequencyMax (VARCHAR)
  medreq_doseinstruc_timing_repeat_period VARCHAR,   -- dosageInstruction/timing/repeat/period (VARCHAR)
  medreq_doseinstruc_timing_repeat_periodmax VARCHAR,   -- dosageInstruction/timing/repeat/periodMax (VARCHAR)
  medreq_doseinstruc_timing_repeat_periodunit VARCHAR,   -- dosageInstruction/timing/repeat/periodUnit (VARCHAR)
  medreq_doseinstruc_timing_repeat_dayofweek VARCHAR,   -- dosageInstruction/timing/repeat/dayOfWeek (VARCHAR)
  medreq_doseinstruc_timing_repeat_timeofday VARCHAR,   -- dosageInstruction/timing/repeat/timeOfDay (VARCHAR)
  medreq_doseinstruc_timing_repeat_when VARCHAR,   -- dosageInstruction/timing/repeat/when (VARCHAR)
  medreq_doseinstruc_timing_repeat_offset VARCHAR,   -- dosageInstruction/timing/repeat/offset (VARCHAR)
  medreq_doseinstruc_timing_code_system VARCHAR,   -- dosageInstruction/timing/code/coding/system (VARCHAR)
  medreq_doseinstruc_timing_code_version VARCHAR,   -- dosageInstruction/timing/code/coding/version (VARCHAR)
  medreq_doseinstruc_timing_code_code VARCHAR,   -- dosageInstruction/timing/code/coding/code (VARCHAR)
  medreq_doseinstruc_timing_code_display VARCHAR,   -- dosageInstruction/timing/code/coding/display (VARCHAR)
  medreq_doseinstruc_timing_code_text VARCHAR,   -- dosageInstruction/timing/code/text (VARCHAR)
  medreq_doseinstruc_asneededboolean VARCHAR,   -- dosageInstruction/asNeededBoolean (VARCHAR)
  medreq_doseinstruc_asneededcodeableconcept_system VARCHAR,   -- dosageInstruction/asNeededCodeableConcept/coding/system (VARCHAR)
  medreq_doseinstruc_asneededcodeableconcept_version VARCHAR,   -- dosageInstruction/asNeededCodeableConcept/coding/version (VARCHAR)
  medreq_doseinstruc_asneededcodeableconcept_code VARCHAR,   -- dosageInstruction/asNeededCodeableConcept/coding/code (VARCHAR)
  medreq_doseinstruc_asneededcodeableconcept_display VARCHAR,   -- dosageInstruction/asNeededCodeableConcept/coding/display (VARCHAR)
  medreq_doseinstruc_asneededcodeableconcept_text VARCHAR,   -- dosageInstruction/asNeededCodeableConcept/text (VARCHAR)
  medreq_doseinstruc_site_system VARCHAR,   -- dosageInstruction/site/coding/system (VARCHAR)
  medreq_doseinstruc_site_version VARCHAR,   -- dosageInstruction/site/coding/version (VARCHAR)
  medreq_doseinstruc_site_code VARCHAR,   -- dosageInstruction/site/coding/code (VARCHAR)
  medreq_doseinstruc_site_display VARCHAR,   -- dosageInstruction/site/coding/display (VARCHAR)
  medreq_doseinstruc_site_text VARCHAR,   -- dosageInstruction/site/text (VARCHAR)
  medreq_doseinstruc_route_system VARCHAR,   -- dosageInstruction/route/coding/system (VARCHAR)
  medreq_doseinstruc_route_version VARCHAR,   -- dosageInstruction/route/coding/version (VARCHAR)
  medreq_doseinstruc_route_code VARCHAR,   -- dosageInstruction/route/coding/code (VARCHAR)
  medreq_doseinstruc_route_display VARCHAR,   -- dosageInstruction/route/coding/display (VARCHAR)
  medreq_doseinstruc_route_text VARCHAR,   -- dosageInstruction/route/text (VARCHAR)
  medreq_doseinstruc_method_system VARCHAR,   -- dosageInstruction/method/coding/system (VARCHAR)
  medreq_doseinstruc_method_version VARCHAR,   -- dosageInstruction/method/coding/version (VARCHAR)
  medreq_doseinstruc_method_code VARCHAR,   -- dosageInstruction/method/coding/code (VARCHAR)
  medreq_doseinstruc_method_display VARCHAR,   -- dosageInstruction/method/coding/display (VARCHAR)
  medreq_doseinstruc_method_text VARCHAR,   -- dosageInstruction/method/text (VARCHAR)
  medreq_doseinstruc_doseandrate_type_system VARCHAR,   -- dosageInstruction/doseAndRate/type/coding/system (VARCHAR)
  medreq_doseinstruc_doseandrate_type_version VARCHAR,   -- dosageInstruction/doseAndRate/type/coding/version (VARCHAR)
  medreq_doseinstruc_doseandrate_type_code VARCHAR,   -- dosageInstruction/doseAndRate/type/coding/code (VARCHAR)
  medreq_doseinstruc_doseandrate_type_display VARCHAR,   -- dosageInstruction/doseAndRate/type/coding/display (VARCHAR)
  medreq_doseinstruc_doseandrate_type_text VARCHAR,   -- dosageInstruction/doseAndRate/type/text (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_low_value VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/low/value (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_low_unit VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/low/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_low_system VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/low/system (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_low_code VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/low/code (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_high_value VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/high/value (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_high_unit VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/high/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_high_system VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/high/system (VARCHAR)
  medreq_doseinstruc_doseandrate_doserange_high_code VARCHAR,   -- dosageInstruction/doseAndRate/doseRange/high/code (VARCHAR)
  medreq_doseinstruc_doseandrate_dosequantity_value VARCHAR,   -- dosageInstruction/doseAndRate/doseQuantity/value (VARCHAR)
  medreq_doseinstruc_doseandrate_dosequantity_comparator VARCHAR,   -- dosageInstruction/doseAndRate/doseQuantity/comparator (VARCHAR)
  medreq_doseinstruc_doseandrate_dosequantity_unit VARCHAR,   -- dosageInstruction/doseAndRate/doseQuantity/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_dosequantity_system VARCHAR,   -- dosageInstruction/doseAndRate/doseQuantity/system (VARCHAR)
  medreq_doseinstruc_doseandrate_dosequantity_code VARCHAR,   -- dosageInstruction/doseAndRate/doseQuantity/code (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_numerator_value VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/numerator/value (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_numerator_comparator VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/numerator/comparator (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_numerator_unit VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/numerator/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_numerator_system VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/numerator/system (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_numerator_code VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/numerator/code (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_denominator_value VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/denominator/value (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_denominator_comparator VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/denominator/comparator (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_denominator_unit VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/denominator/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_denominator_system VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/denominator/system (VARCHAR)
  medreq_doseinstruc_doseandrate_rateratio_denominator_code VARCHAR,   -- dosageInstruction/doseAndRate/rateRatio/denominator/code (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_low_value VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/low/value (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_low_unit VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/low/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_low_system VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/low/system (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_low_code VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/low/code (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_high_value VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/high/value (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_high_unit VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/high/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_high_system VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/high/system (VARCHAR)
  medreq_doseinstruc_doseandrate_raterange_high_code VARCHAR,   -- dosageInstruction/doseAndRate/rateRange/high/code (VARCHAR)
  medreq_doseinstruc_doseandrate_ratequantity_value VARCHAR,   -- dosageInstruction/doseAndRate/rateQuantity/value (VARCHAR)
  medreq_doseinstruc_doseandrate_ratequantity_unit VARCHAR,   -- dosageInstruction/doseAndRate/rateQuantity/unit (VARCHAR)
  medreq_doseinstruc_doseandrate_ratequantity_system VARCHAR,   -- dosageInstruction/doseAndRate/rateQuantity/system (VARCHAR)
  medreq_doseinstruc_doseandrate_ratequantity_code VARCHAR,   -- dosageInstruction/doseAndRate/rateQuantity/code (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_numerator_value VARCHAR,   -- dosageInstruction/maxDosePerPeriod/numerator/value (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_numerator_comparator VARCHAR,   -- dosageInstruction/maxDosePerPeriod/numerator/comparator (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_numerator_unit VARCHAR,   -- dosageInstruction/maxDosePerPeriod/numerator/unit (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_numerator_system VARCHAR,   -- dosageInstruction/maxDosePerPeriod/numerator/system (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_numerator_code VARCHAR,   -- dosageInstruction/maxDosePerPeriod/numerator/code (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_denominator_value VARCHAR,   -- dosageInstruction/maxDosePerPeriod/denominator/value (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_denominator_comparator VARCHAR,   -- dosageInstruction/maxDosePerPeriod/denominator/comparator (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_denominator_unit VARCHAR,   -- dosageInstruction/maxDosePerPeriod/denominator/unit (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_denominator_system VARCHAR,   -- dosageInstruction/maxDosePerPeriod/denominator/system (VARCHAR)
  medreq_doseinstruc_maxdoseperperiod_denominator_code VARCHAR,   -- dosageInstruction/maxDosePerPeriod/denominator/code (VARCHAR)
  medreq_doseinstruc_maxdoseperadministration_value VARCHAR,   -- dosageInstruction/maxDosePerAdministration/value (VARCHAR)
  medreq_doseinstruc_maxdoseperadministration_unit VARCHAR,   -- dosageInstruction/maxDosePerAdministration/unit (VARCHAR)
  medreq_doseinstruc_maxdoseperadministration_system VARCHAR,   -- dosageInstruction/maxDosePerAdministration/system (VARCHAR)
  medreq_doseinstruc_maxdoseperadministration_code VARCHAR,   -- dosageInstruction/maxDosePerAdministration/code (VARCHAR)
  medreq_doseinstruc_maxdoseperlifetime_value VARCHAR,   -- dosageInstruction/maxDosePerLifetime/value (VARCHAR)
  medreq_doseinstruc_maxdoseperlifetime_unit VARCHAR,   -- dosageInstruction/maxDosePerLifetime/unit (VARCHAR)
  medreq_doseinstruc_maxdoseperlifetime_system VARCHAR,   -- dosageInstruction/maxDosePerLifetime/system (VARCHAR)
  medreq_doseinstruc_maxdoseperlifetime_code VARCHAR,   -- dosageInstruction/maxDosePerLifetime/code (VARCHAR)
  medreq_substitution_reason_system VARCHAR,   -- substitution/reason/coding/system (VARCHAR)
  medreq_substitution_reason_version VARCHAR,   -- substitution/reason/coding/version (VARCHAR)
  medreq_substitution_reason_code VARCHAR,   -- substitution/reason/coding/code (VARCHAR)
  medreq_substitution_reason_display VARCHAR,   -- substitution/reason/coding/display (VARCHAR)
  medreq_substitution_reason_text VARCHAR,   -- substitution/reason/text (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(medreq_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(medreq_encounter_ref, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(medreq_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(medreq_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(medreq_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(medreq_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(medreq_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(medreq_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(medreq_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(medreq_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(medreq_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(medreq_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(medreq_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(medreq_medicationreference_ref, '#NULL#') || '|||' || -- hash from: medicationReference/reference
             COALESCE(medreq_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(medreq_statusreason_system, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(medreq_statusreason_version, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(medreq_statusreason_code, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(medreq_statusreason_display, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(medreq_statusreason_text, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(medreq_intend, '#NULL#') || '|||' || -- hash from: intend
             COALESCE(medreq_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(medreq_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(medreq_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(medreq_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(medreq_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(medreq_priority, '#NULL#') || '|||' || -- hash from: priority
             COALESCE(medreq_reportedboolean, '#NULL#') || '|||' || -- hash from: reportedBoolean
             COALESCE(medreq_reportedreference_ref, '#NULL#') || '|||' || -- hash from: reportedReference/reference
             COALESCE(medreq_reportedreference_type, '#NULL#') || '|||' || -- hash from: reportedReference/type
             COALESCE(medreq_reportedreference_identifier_use, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/use
             COALESCE(medreq_reportedreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/system
             COALESCE(medreq_reportedreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/version
             COALESCE(medreq_reportedreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/code
             COALESCE(medreq_reportedreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/display
             COALESCE(medreq_reportedreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/text
             COALESCE(medreq_reportedreference_display, '#NULL#') || '|||' || -- hash from: reportedReference/display
             COALESCE(medreq_medicationcodeableconcept_system, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/system
             COALESCE(medreq_medicationcodeableconcept_version, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/version
             COALESCE(medreq_medicationcodeableconcept_code, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/code
             COALESCE(medreq_medicationcodeableconcept_display, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/display
             COALESCE(medreq_medicationcodeableconcept_text, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/text
             COALESCE(medreq_supportinginformation_ref, '#NULL#') || '|||' || -- hash from: supportingInformation/reference
             COALESCE(medreq_supportinginformation_type, '#NULL#') || '|||' || -- hash from: supportingInformation/type
             COALESCE(medreq_supportinginformation_identifier_use, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/use
             COALESCE(medreq_supportinginformation_identifier_type_system, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/system
             COALESCE(medreq_supportinginformation_identifier_type_version, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/version
             COALESCE(medreq_supportinginformation_identifier_type_code, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/code
             COALESCE(medreq_supportinginformation_identifier_type_display, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/display
             COALESCE(medreq_supportinginformation_identifier_type_text, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/text
             COALESCE(medreq_supportinginformation_display, '#NULL#') || '|||' || -- hash from: supportingInformation/display
             COALESCE(medreq_authoredon, '#NULL#') || '|||' || -- hash from: authoredOn
             COALESCE(medreq_requester_ref, '#NULL#') || '|||' || -- hash from: requester/reference
             COALESCE(medreq_requester_type, '#NULL#') || '|||' || -- hash from: requester/type
             COALESCE(medreq_requester_identifier_use, '#NULL#') || '|||' || -- hash from: requester/identifier/use
             COALESCE(medreq_requester_identifier_type_system, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/system
             COALESCE(medreq_requester_identifier_type_version, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/version
             COALESCE(medreq_requester_identifier_type_code, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/code
             COALESCE(medreq_requester_identifier_type_display, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/display
             COALESCE(medreq_requester_identifier_type_text, '#NULL#') || '|||' || -- hash from: requester/identifier/type/text
             COALESCE(medreq_requester_display, '#NULL#') || '|||' || -- hash from: requester/display
             COALESCE(medreq_reasoncode_system, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(medreq_reasoncode_version, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(medreq_reasoncode_code, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(medreq_reasoncode_display, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(medreq_reasoncode_text, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(medreq_reasonreference_ref, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(medreq_reasonreference_type, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(medreq_reasonreference_identifier_use, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(medreq_reasonreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(medreq_reasonreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(medreq_reasonreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(medreq_reasonreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(medreq_reasonreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(medreq_reasonreference_display, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(medreq_basedon_ref, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(medreq_basedon_type, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(medreq_basedon_identifier_use, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(medreq_basedon_identifier_type_system, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(medreq_basedon_identifier_type_version, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(medreq_basedon_identifier_type_code, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(medreq_basedon_identifier_type_display, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(medreq_basedon_identifier_type_text, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(medreq_basedon_display, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(medreq_note_authorstring, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(medreq_note_authorreference_ref, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(medreq_note_authorreference_type, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(medreq_note_authorreference_identifier_use, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(medreq_note_authorreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(medreq_note_authorreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(medreq_note_authorreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(medreq_note_authorreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(medreq_note_authorreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(medreq_note_authorreference_display, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(medreq_note_time, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(medreq_note_text, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(medreq_doseinstruc_sequence, '#NULL#') || '|||' || -- hash from: dosageInstruction/sequence
             COALESCE(medreq_doseinstruc_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/text
             COALESCE(medreq_doseinstruc_additionalinstruction_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/system
             COALESCE(medreq_doseinstruc_additionalinstruction_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/version
             COALESCE(medreq_doseinstruc_additionalinstruction_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/code
             COALESCE(medreq_doseinstruc_additionalinstruction_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/display
             COALESCE(medreq_doseinstruc_additionalinstruction_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/text
             COALESCE(medreq_doseinstruc_patientinstruction, '#NULL#') || '|||' || -- hash from: dosageInstruction/patientInstruction
             COALESCE(medreq_doseinstruc_timing_event, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/event
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/value
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_comparator, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/comparator
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/unit
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/system
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/code
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/value
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/unit
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/system
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/code
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/value
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/unit
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/system
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/code
             COALESCE(medreq_doseinstruc_timing_repeat_boundsperiod_start, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsPeriod/start
             COALESCE(medreq_doseinstruc_timing_repeat_boundsperiod_end, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsPeriod/end
             COALESCE(medreq_doseinstruc_timing_repeat_count, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/count
             COALESCE(medreq_doseinstruc_timing_repeat_countmax, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/countMax
             COALESCE(medreq_doseinstruc_timing_repeat_duration, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/duration
             COALESCE(medreq_doseinstruc_timing_repeat_durationmax, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/durationMax
             COALESCE(medreq_doseinstruc_timing_repeat_durationunit, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/durationUnit
             COALESCE(medreq_doseinstruc_timing_repeat_frequency, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/frequency
             COALESCE(medreq_doseinstruc_timing_repeat_frequencymax, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/frequencyMax
             COALESCE(medreq_doseinstruc_timing_repeat_period, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/period
             COALESCE(medreq_doseinstruc_timing_repeat_periodmax, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/periodMax
             COALESCE(medreq_doseinstruc_timing_repeat_periodunit, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/periodUnit
             COALESCE(medreq_doseinstruc_timing_repeat_dayofweek, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/dayOfWeek
             COALESCE(medreq_doseinstruc_timing_repeat_timeofday, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/timeOfDay
             COALESCE(medreq_doseinstruc_timing_repeat_when, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/when
             COALESCE(medreq_doseinstruc_timing_repeat_offset, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/offset
             COALESCE(medreq_doseinstruc_timing_code_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/system
             COALESCE(medreq_doseinstruc_timing_code_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/version
             COALESCE(medreq_doseinstruc_timing_code_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/code
             COALESCE(medreq_doseinstruc_timing_code_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/display
             COALESCE(medreq_doseinstruc_timing_code_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/text
             COALESCE(medreq_doseinstruc_asneededboolean, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededBoolean
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/system
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/version
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/code
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/display
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/text
             COALESCE(medreq_doseinstruc_site_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/system
             COALESCE(medreq_doseinstruc_site_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/version
             COALESCE(medreq_doseinstruc_site_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/code
             COALESCE(medreq_doseinstruc_site_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/display
             COALESCE(medreq_doseinstruc_site_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/text
             COALESCE(medreq_doseinstruc_route_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/system
             COALESCE(medreq_doseinstruc_route_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/version
             COALESCE(medreq_doseinstruc_route_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/code
             COALESCE(medreq_doseinstruc_route_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/display
             COALESCE(medreq_doseinstruc_route_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/text
             COALESCE(medreq_doseinstruc_method_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/system
             COALESCE(medreq_doseinstruc_method_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/version
             COALESCE(medreq_doseinstruc_method_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/code
             COALESCE(medreq_doseinstruc_method_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/display
             COALESCE(medreq_doseinstruc_method_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/text
             COALESCE(medreq_doseinstruc_doseandrate_type_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/system
             COALESCE(medreq_doseinstruc_doseandrate_type_version, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/version
             COALESCE(medreq_doseinstruc_doseandrate_type_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/code
             COALESCE(medreq_doseinstruc_doseandrate_type_display, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/display
             COALESCE(medreq_doseinstruc_doseandrate_type_text, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/text
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/value
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/unit
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/system
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/code
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/value
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/unit
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/system
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/code
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/value
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_comparator, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/comparator
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/unit
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/system
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/code
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/value
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_comparator, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/comparator
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/unit
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/system
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/code
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/value
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_comparator, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/comparator
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/unit
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/system
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/code
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/value
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/unit
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/system
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/code
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/value
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/unit
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/system
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/code
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/value
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/unit
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/system
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/code
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/value
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_comparator, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/comparator
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/unit
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/system
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/code
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/value
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_comparator, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/comparator
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/unit
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/system
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/code
             COALESCE(medreq_doseinstruc_maxdoseperadministration_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/value
             COALESCE(medreq_doseinstruc_maxdoseperadministration_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/unit
             COALESCE(medreq_doseinstruc_maxdoseperadministration_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/system
             COALESCE(medreq_doseinstruc_maxdoseperadministration_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/code
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_value, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/value
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_unit, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/unit
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_system, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/system
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_code, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/code
             COALESCE(medreq_substitution_reason_system, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/system
             COALESCE(medreq_substitution_reason_version, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/version
             COALESCE(medreq_substitution_reason_code, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/code
             COALESCE(medreq_substitution_reason_display, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/display
             COALESCE(medreq_substitution_reason_text, '#NULL#') || '|||' || -- hash from: substitution/reason/text
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationadministration_raw (
  medicationadministration_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medadm_id VARCHAR,   -- id (VARCHAR)
  medadm_encounter_ref VARCHAR,   -- context/reference (VARCHAR)
  medadm_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  medadm_partof_ref VARCHAR,   -- partOf/reference (VARCHAR)
  medadm_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  medadm_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  medadm_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  medadm_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  medadm_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  medadm_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  medadm_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  medadm_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  medadm_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  medadm_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  medadm_status VARCHAR,   -- status (VARCHAR)
  medadm_statusreason_system VARCHAR,   -- statusReason/coding/system (VARCHAR)
  medadm_statusreason_version VARCHAR,   -- statusReason/coding/version (VARCHAR)
  medadm_statusreason_code VARCHAR,   -- statusReason/coding/code (VARCHAR)
  medadm_statusreason_display VARCHAR,   -- statusReason/coding/display (VARCHAR)
  medadm_statusreason_text VARCHAR,   -- statusReason/text (VARCHAR)
  medadm_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  medadm_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  medadm_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  medadm_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  medadm_category_text VARCHAR,   -- category/text (VARCHAR)
  medadm_medicationreference_ref VARCHAR,   -- medicationReference/reference (VARCHAR)
  medadm_medicationcodeableconcept_system VARCHAR,   -- medicationCodeableConcept/coding/system (VARCHAR)
  medadm_medicationcodeableconcept_version VARCHAR,   -- medicationCodeableConcept/coding/version (VARCHAR)
  medadm_medicationcodeableconcept_code VARCHAR,   -- medicationCodeableConcept/coding/code (VARCHAR)
  medadm_medicationcodeableconcept_display VARCHAR,   -- medicationCodeableConcept/coding/display (VARCHAR)
  medadm_medicationcodeableconcept_text VARCHAR,   -- medicationCodeableConcept/text (VARCHAR)
  medadm_supportinginformation_ref VARCHAR,   -- supportingInformation/reference (VARCHAR)
  medadm_supportinginformation_type VARCHAR,   -- supportingInformation/type (VARCHAR)
  medadm_supportinginformation_identifier_use VARCHAR,   -- supportingInformation/identifier/use (VARCHAR)
  medadm_supportinginformation_identifier_type_system VARCHAR,   -- supportingInformation/identifier/type/coding/system (VARCHAR)
  medadm_supportinginformation_identifier_type_version VARCHAR,   -- supportingInformation/identifier/type/coding/version (VARCHAR)
  medadm_supportinginformation_identifier_type_code VARCHAR,   -- supportingInformation/identifier/type/coding/code (VARCHAR)
  medadm_supportinginformation_identifier_type_display VARCHAR,   -- supportingInformation/identifier/type/coding/display (VARCHAR)
  medadm_supportinginformation_identifier_type_text VARCHAR,   -- supportingInformation/identifier/type/text (VARCHAR)
  medadm_supportinginformation_display VARCHAR,   -- supportingInformation/display (VARCHAR)
  medadm_effectivedatetime VARCHAR,   -- effectiveDateTime (VARCHAR)
  medadm_effectiveperiod_start VARCHAR,   -- effectivePeriod/start (VARCHAR)
  medadm_effectiveperiod_end VARCHAR,   -- effectivePeriod/end (VARCHAR)
  medadm_performer_function_system VARCHAR,   -- performer/function/coding/system (VARCHAR)
  medadm_performer_function_version VARCHAR,   -- performer/function/coding/version (VARCHAR)
  medadm_performer_function_code VARCHAR,   -- performer/function/coding/code (VARCHAR)
  medadm_performer_function_display VARCHAR,   -- performer/function/coding/display (VARCHAR)
  medadm_performer_function_text VARCHAR,   -- performer/function/text (VARCHAR)
  medadm_reasoncode_system VARCHAR,   -- reasonCode/coding/system (VARCHAR)
  medadm_reasoncode_version VARCHAR,   -- reasonCode/coding/version (VARCHAR)
  medadm_reasoncode_code VARCHAR,   -- reasonCode/coding/code (VARCHAR)
  medadm_reasoncode_display VARCHAR,   -- reasonCode/coding/display (VARCHAR)
  medadm_reasoncode_text VARCHAR,   -- reasonCode/text (VARCHAR)
  medadm_reasonreference_ref VARCHAR,   -- reasonReference/reference (VARCHAR)
  medadm_reasonreference_type VARCHAR,   -- reasonReference/type (VARCHAR)
  medadm_reasonreference_identifier_use VARCHAR,   -- reasonReference/identifier/use (VARCHAR)
  medadm_reasonreference_identifier_type_system VARCHAR,   -- reasonReference/identifier/type/coding/system (VARCHAR)
  medadm_reasonreference_identifier_type_version VARCHAR,   -- reasonReference/identifier/type/coding/version (VARCHAR)
  medadm_reasonreference_identifier_type_code VARCHAR,   -- reasonReference/identifier/type/coding/code (VARCHAR)
  medadm_reasonreference_identifier_type_display VARCHAR,   -- reasonReference/identifier/type/coding/display (VARCHAR)
  medadm_reasonreference_identifier_type_text VARCHAR,   -- reasonReference/identifier/type/text (VARCHAR)
  medadm_reasonreference_display VARCHAR,   -- reasonReference/display (VARCHAR)
  medadm_request_ref VARCHAR,   -- request/reference (VARCHAR)
  medadm_note_authorstring VARCHAR,   -- note/authorString (VARCHAR)
  medadm_note_authorreference_ref VARCHAR,   -- note/authorReference/reference (VARCHAR)
  medadm_note_authorreference_type VARCHAR,   -- note/authorReference/type (VARCHAR)
  medadm_note_authorreference_identifier_use VARCHAR,   -- note/authorReference/identifier/use (VARCHAR)
  medadm_note_authorreference_identifier_type_system VARCHAR,   -- note/authorReference/identifier/type/coding/system (VARCHAR)
  medadm_note_authorreference_identifier_type_version VARCHAR,   -- note/authorReference/identifier/type/coding/version (VARCHAR)
  medadm_note_authorreference_identifier_type_code VARCHAR,   -- note/authorReference/identifier/type/coding/code (VARCHAR)
  medadm_note_authorreference_identifier_type_display VARCHAR,   -- note/authorReference/identifier/type/coding/display (VARCHAR)
  medadm_note_authorreference_identifier_type_text VARCHAR,   -- note/authorReference/identifier/type/text (VARCHAR)
  medadm_note_authorreference_display VARCHAR,   -- note/authorReference/display (VARCHAR)
  medadm_note_time VARCHAR,   -- note/time (VARCHAR)
  medadm_note_text VARCHAR,   -- note/text (VARCHAR)
  medadm_dosage_text VARCHAR,   -- dosage/text (VARCHAR)
  medadm_dosage_site_system VARCHAR,   -- dosage/site/coding/system (VARCHAR)
  medadm_dosage_site_version VARCHAR,   -- dosage/site/coding/version (VARCHAR)
  medadm_dosage_site_code VARCHAR,   -- dosage/site/coding/code (VARCHAR)
  medadm_dosage_site_display VARCHAR,   -- dosage/site/coding/display (VARCHAR)
  medadm_dosage_site_text VARCHAR,   -- dosage/site/text (VARCHAR)
  medadm_dosage_route_system VARCHAR,   -- dosage/route/coding/system (VARCHAR)
  medadm_dosage_route_version VARCHAR,   -- dosage/route/coding/version (VARCHAR)
  medadm_dosage_route_code VARCHAR,   -- dosage/route/coding/code (VARCHAR)
  medadm_dosage_route_display VARCHAR,   -- dosage/route/coding/display (VARCHAR)
  medadm_dosage_route_text VARCHAR,   -- dosage/route/text (VARCHAR)
  medadm_dosage_method_system VARCHAR,   -- dosage/method/coding/system (VARCHAR)
  medadm_dosage_method_version VARCHAR,   -- dosage/method/coding/version (VARCHAR)
  medadm_dosage_method_code VARCHAR,   -- dosage/method/coding/code (VARCHAR)
  medadm_dosage_method_display VARCHAR,   -- dosage/method/coding/display (VARCHAR)
  medadm_dosage_method_text VARCHAR,   -- dosage/method/text (VARCHAR)
  medadm_dosage_dose_value VARCHAR,   -- dosage/dose/value (VARCHAR)
  medadm_dosage_dose_unit VARCHAR,   -- dosage/dose/unit (VARCHAR)
  medadm_dosage_dose_system VARCHAR,   -- dosage/dose/system (VARCHAR)
  medadm_dosage_dose_code VARCHAR,   -- dosage/dose/code (VARCHAR)
  medadm_dosage_rateratio_numerator_value VARCHAR,   -- dosage/rateRatio/numerator/value (VARCHAR)
  medadm_dosage_rateratio_numerator_comparator VARCHAR,   -- dosage/rateRatio/numerator/comparator (VARCHAR)
  medadm_dosage_rateratio_numerator_unit VARCHAR,   -- dosage/rateRatio/numerator/unit (VARCHAR)
  medadm_dosage_rateratio_numerator_system VARCHAR,   -- dosage/rateRatio/numerator/system (VARCHAR)
  medadm_dosage_rateratio_numerator_code VARCHAR,   -- dosage/rateRatio/numerator/code (VARCHAR)
  medadm_dosage_rateratio_denominator_value VARCHAR,   -- dosage/rateRatio/denominator/value (VARCHAR)
  medadm_dosage_rateratio_denominator_comparator VARCHAR,   -- dosage/rateRatio/denominator/comparator (VARCHAR)
  medadm_dosage_rateratio_denominator_unit VARCHAR,   -- dosage/rateRatio/denominator/unit (VARCHAR)
  medadm_dosage_rateratio_denominator_system VARCHAR,   -- dosage/rateRatio/denominator/system (VARCHAR)
  medadm_dosage_rateratio_denominator_code VARCHAR,   -- dosage/rateRatio/denominator/code (VARCHAR)
  medadm_dosage_ratequantity_value VARCHAR,   -- dosage/rateQuantity/value (VARCHAR)
  medadm_dosage_ratequantity_unit VARCHAR,   -- dosage/rateQuantity/unit (VARCHAR)
  medadm_dosage_ratequantity_system VARCHAR,   -- dosage/rateQuantity/system (VARCHAR)
  medadm_dosage_ratequantity_code VARCHAR,   -- dosage/rateQuantity/code (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(medadm_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(medadm_encounter_ref, '#NULL#') || '|||' || -- hash from: context/reference
             COALESCE(medadm_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(medadm_partof_ref, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(medadm_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(medadm_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(medadm_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(medadm_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(medadm_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(medadm_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(medadm_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(medadm_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(medadm_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(medadm_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(medadm_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(medadm_statusreason_system, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(medadm_statusreason_version, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(medadm_statusreason_code, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(medadm_statusreason_display, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(medadm_statusreason_text, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(medadm_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(medadm_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(medadm_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(medadm_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(medadm_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(medadm_medicationreference_ref, '#NULL#') || '|||' || -- hash from: medicationReference/reference
             COALESCE(medadm_medicationcodeableconcept_system, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/system
             COALESCE(medadm_medicationcodeableconcept_version, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/version
             COALESCE(medadm_medicationcodeableconcept_code, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/code
             COALESCE(medadm_medicationcodeableconcept_display, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/display
             COALESCE(medadm_medicationcodeableconcept_text, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/text
             COALESCE(medadm_supportinginformation_ref, '#NULL#') || '|||' || -- hash from: supportingInformation/reference
             COALESCE(medadm_supportinginformation_type, '#NULL#') || '|||' || -- hash from: supportingInformation/type
             COALESCE(medadm_supportinginformation_identifier_use, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/use
             COALESCE(medadm_supportinginformation_identifier_type_system, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/system
             COALESCE(medadm_supportinginformation_identifier_type_version, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/version
             COALESCE(medadm_supportinginformation_identifier_type_code, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/code
             COALESCE(medadm_supportinginformation_identifier_type_display, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/display
             COALESCE(medadm_supportinginformation_identifier_type_text, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/text
             COALESCE(medadm_supportinginformation_display, '#NULL#') || '|||' || -- hash from: supportingInformation/display
             COALESCE(medadm_effectivedatetime, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(medadm_effectiveperiod_start, '#NULL#') || '|||' || -- hash from: effectivePeriod/start
             COALESCE(medadm_effectiveperiod_end, '#NULL#') || '|||' || -- hash from: effectivePeriod/end
             COALESCE(medadm_performer_function_system, '#NULL#') || '|||' || -- hash from: performer/function/coding/system
             COALESCE(medadm_performer_function_version, '#NULL#') || '|||' || -- hash from: performer/function/coding/version
             COALESCE(medadm_performer_function_code, '#NULL#') || '|||' || -- hash from: performer/function/coding/code
             COALESCE(medadm_performer_function_display, '#NULL#') || '|||' || -- hash from: performer/function/coding/display
             COALESCE(medadm_performer_function_text, '#NULL#') || '|||' || -- hash from: performer/function/text
             COALESCE(medadm_reasoncode_system, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(medadm_reasoncode_version, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(medadm_reasoncode_code, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(medadm_reasoncode_display, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(medadm_reasoncode_text, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(medadm_reasonreference_ref, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(medadm_reasonreference_type, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(medadm_reasonreference_identifier_use, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(medadm_reasonreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(medadm_reasonreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(medadm_reasonreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(medadm_reasonreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(medadm_reasonreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(medadm_reasonreference_display, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(medadm_request_ref, '#NULL#') || '|||' || -- hash from: request/reference
             COALESCE(medadm_note_authorstring, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(medadm_note_authorreference_ref, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(medadm_note_authorreference_type, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(medadm_note_authorreference_identifier_use, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(medadm_note_authorreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(medadm_note_authorreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(medadm_note_authorreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(medadm_note_authorreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(medadm_note_authorreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(medadm_note_authorreference_display, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(medadm_note_time, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(medadm_note_text, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(medadm_dosage_text, '#NULL#') || '|||' || -- hash from: dosage/text
             COALESCE(medadm_dosage_site_system, '#NULL#') || '|||' || -- hash from: dosage/site/coding/system
             COALESCE(medadm_dosage_site_version, '#NULL#') || '|||' || -- hash from: dosage/site/coding/version
             COALESCE(medadm_dosage_site_code, '#NULL#') || '|||' || -- hash from: dosage/site/coding/code
             COALESCE(medadm_dosage_site_display, '#NULL#') || '|||' || -- hash from: dosage/site/coding/display
             COALESCE(medadm_dosage_site_text, '#NULL#') || '|||' || -- hash from: dosage/site/text
             COALESCE(medadm_dosage_route_system, '#NULL#') || '|||' || -- hash from: dosage/route/coding/system
             COALESCE(medadm_dosage_route_version, '#NULL#') || '|||' || -- hash from: dosage/route/coding/version
             COALESCE(medadm_dosage_route_code, '#NULL#') || '|||' || -- hash from: dosage/route/coding/code
             COALESCE(medadm_dosage_route_display, '#NULL#') || '|||' || -- hash from: dosage/route/coding/display
             COALESCE(medadm_dosage_route_text, '#NULL#') || '|||' || -- hash from: dosage/route/text
             COALESCE(medadm_dosage_method_system, '#NULL#') || '|||' || -- hash from: dosage/method/coding/system
             COALESCE(medadm_dosage_method_version, '#NULL#') || '|||' || -- hash from: dosage/method/coding/version
             COALESCE(medadm_dosage_method_code, '#NULL#') || '|||' || -- hash from: dosage/method/coding/code
             COALESCE(medadm_dosage_method_display, '#NULL#') || '|||' || -- hash from: dosage/method/coding/display
             COALESCE(medadm_dosage_method_text, '#NULL#') || '|||' || -- hash from: dosage/method/text
             COALESCE(medadm_dosage_dose_value, '#NULL#') || '|||' || -- hash from: dosage/dose/value
             COALESCE(medadm_dosage_dose_unit, '#NULL#') || '|||' || -- hash from: dosage/dose/unit
             COALESCE(medadm_dosage_dose_system, '#NULL#') || '|||' || -- hash from: dosage/dose/system
             COALESCE(medadm_dosage_dose_code, '#NULL#') || '|||' || -- hash from: dosage/dose/code
             COALESCE(medadm_dosage_rateratio_numerator_value, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/value
             COALESCE(medadm_dosage_rateratio_numerator_comparator, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/comparator
             COALESCE(medadm_dosage_rateratio_numerator_unit, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/unit
             COALESCE(medadm_dosage_rateratio_numerator_system, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/system
             COALESCE(medadm_dosage_rateratio_numerator_code, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/code
             COALESCE(medadm_dosage_rateratio_denominator_value, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/value
             COALESCE(medadm_dosage_rateratio_denominator_comparator, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/comparator
             COALESCE(medadm_dosage_rateratio_denominator_unit, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/unit
             COALESCE(medadm_dosage_rateratio_denominator_system, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/system
             COALESCE(medadm_dosage_rateratio_denominator_code, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/code
             COALESCE(medadm_dosage_ratequantity_value, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/value
             COALESCE(medadm_dosage_ratequantity_unit, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/unit
             COALESCE(medadm_dosage_ratequantity_system, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/system
             COALESCE(medadm_dosage_ratequantity_code, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/code
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationstatement_raw (
  medicationstatement_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medstat_id VARCHAR,   -- id (VARCHAR)
  medstat_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  medstat_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  medstat_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  medstat_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  medstat_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  medstat_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  medstat_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  medstat_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  medstat_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  medstat_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  medstat_encounter_ref VARCHAR,   -- context/reference (VARCHAR)
  medstat_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  medstat_partof_ref VARCHAR,   -- partOf/reference (VARCHAR)
  medstat_basedon_ref VARCHAR,   -- basedOn/reference (VARCHAR)
  medstat_basedon_type VARCHAR,   -- basedOn/type (VARCHAR)
  medstat_basedon_identifier_use VARCHAR,   -- basedOn/identifier/use (VARCHAR)
  medstat_basedon_identifier_type_system VARCHAR,   -- basedOn/identifier/type/coding/system (VARCHAR)
  medstat_basedon_identifier_type_version VARCHAR,   -- basedOn/identifier/type/coding/version (VARCHAR)
  medstat_basedon_identifier_type_code VARCHAR,   -- basedOn/identifier/type/coding/code (VARCHAR)
  medstat_basedon_identifier_type_display VARCHAR,   -- basedOn/identifier/type/coding/display (VARCHAR)
  medstat_basedon_identifier_type_text VARCHAR,   -- basedOn/identifier/type/text (VARCHAR)
  medstat_basedon_display VARCHAR,   -- basedOn/display (VARCHAR)
  medstat_status VARCHAR,   -- status (VARCHAR)
  medstat_statusreason_system VARCHAR,   -- statusReason/coding/system (VARCHAR)
  medstat_statusreason_version VARCHAR,   -- statusReason/coding/version (VARCHAR)
  medstat_statusreason_code VARCHAR,   -- statusReason/coding/code (VARCHAR)
  medstat_statusreason_display VARCHAR,   -- statusReason/coding/display (VARCHAR)
  medstat_statusreason_text VARCHAR,   -- statusReason/text (VARCHAR)
  medstat_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  medstat_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  medstat_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  medstat_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  medstat_category_text VARCHAR,   -- category/text (VARCHAR)
  medstat_medicationreference_ref VARCHAR,   -- medicationReference/reference (VARCHAR)
  medstat_medicationcodeableconcept_system VARCHAR,   -- medicationCodeableConcept/coding/system (VARCHAR)
  medstat_medicationcodeableconcept_version VARCHAR,   -- medicationCodeableConcept/coding/version (VARCHAR)
  medstat_medicationcodeableconcept_code VARCHAR,   -- medicationCodeableConcept/coding/code (VARCHAR)
  medstat_medicationcodeableconcept_display VARCHAR,   -- medicationCodeableConcept/coding/display (VARCHAR)
  medstat_medicationcodeableconcept_text VARCHAR,   -- medicationCodeableConcept/text (VARCHAR)
  medstat_effectivedatetime VARCHAR,   -- effectiveDateTime (VARCHAR)
  medstat_effectiveperiod_start VARCHAR,   -- effectivePeriod/start (VARCHAR)
  medstat_effectiveperiod_end VARCHAR,   -- effectivePeriod/end (VARCHAR)
  medstat_dateasserted VARCHAR,   -- dateAsserted (VARCHAR)
  medstat_informationsource_ref VARCHAR,   -- informationSource/reference (VARCHAR)
  medstat_informationsource_type VARCHAR,   -- informationSource/type (VARCHAR)
  medstat_informationsource_identifier_use VARCHAR,   -- informationSource/identifier/use (VARCHAR)
  medstat_informationsource_identifier_type_system VARCHAR,   -- informationSource/identifier/type/coding/system (VARCHAR)
  medstat_informationsource_identifier_type_version VARCHAR,   -- informationSource/identifier/type/coding/version (VARCHAR)
  medstat_informationsource_identifier_type_code VARCHAR,   -- informationSource/identifier/type/coding/code (VARCHAR)
  medstat_informationsource_identifier_type_display VARCHAR,   -- informationSource/identifier/type/coding/display (VARCHAR)
  medstat_informationsource_identifier_type_text VARCHAR,   -- informationSource/identifier/type/text (VARCHAR)
  medstat_informationsource_display VARCHAR,   -- informationSource/display (VARCHAR)
  medstat_derivedfrom_ref VARCHAR,   -- derivedFrom/reference (VARCHAR)
  medstat_derivedfrom_type VARCHAR,   -- derivedFrom/type (VARCHAR)
  medstat_derivedfrom_identifier_use VARCHAR,   -- derivedFrom/identifier/use (VARCHAR)
  medstat_derivedfrom_identifier_type_system VARCHAR,   -- derivedFrom/identifier/type/coding/system (VARCHAR)
  medstat_derivedfrom_identifier_type_version VARCHAR,   -- derivedFrom/identifier/type/coding/version (VARCHAR)
  medstat_derivedfrom_identifier_type_code VARCHAR,   -- derivedFrom/identifier/type/coding/code (VARCHAR)
  medstat_derivedfrom_identifier_type_display VARCHAR,   -- derivedFrom/identifier/type/coding/display (VARCHAR)
  medstat_derivedfrom_identifier_type_text VARCHAR,   -- derivedFrom/identifier/type/text (VARCHAR)
  medstat_derivedfrom_display VARCHAR,   -- derivedFrom/display (VARCHAR)
  medstat_reasoncode_system VARCHAR,   -- reasonCode/coding/system (VARCHAR)
  medstat_reasoncode_version VARCHAR,   -- reasonCode/coding/version (VARCHAR)
  medstat_reasoncode_code VARCHAR,   -- reasonCode/coding/code (VARCHAR)
  medstat_reasoncode_display VARCHAR,   -- reasonCode/coding/display (VARCHAR)
  medstat_reasoncode_text VARCHAR,   -- reasonCode/text (VARCHAR)
  medstat_reasonreference_ref VARCHAR,   -- reasonReference/reference (VARCHAR)
  medstat_reasonreference_type VARCHAR,   -- reasonReference/type (VARCHAR)
  medstat_reasonreference_identifier_use VARCHAR,   -- reasonReference/identifier/use (VARCHAR)
  medstat_reasonreference_identifier_type_system VARCHAR,   -- reasonReference/identifier/type/coding/system (VARCHAR)
  medstat_reasonreference_identifier_type_version VARCHAR,   -- reasonReference/identifier/type/coding/version (VARCHAR)
  medstat_reasonreference_identifier_type_code VARCHAR,   -- reasonReference/identifier/type/coding/code (VARCHAR)
  medstat_reasonreference_identifier_type_display VARCHAR,   -- reasonReference/identifier/type/coding/display (VARCHAR)
  medstat_reasonreference_identifier_type_text VARCHAR,   -- reasonReference/identifier/type/text (VARCHAR)
  medstat_reasonreference_display VARCHAR,   -- reasonReference/display (VARCHAR)
  medstat_note_authorstring VARCHAR,   -- note/authorString (VARCHAR)
  medstat_note_authorreference_ref VARCHAR,   -- note/authorReference/reference (VARCHAR)
  medstat_note_authorreference_type VARCHAR,   -- note/authorReference/type (VARCHAR)
  medstat_note_authorreference_identifier_use VARCHAR,   -- note/authorReference/identifier/use (VARCHAR)
  medstat_note_authorreference_identifier_type_system VARCHAR,   -- note/authorReference/identifier/type/coding/system (VARCHAR)
  medstat_note_authorreference_identifier_type_version VARCHAR,   -- note/authorReference/identifier/type/coding/version (VARCHAR)
  medstat_note_authorreference_identifier_type_code VARCHAR,   -- note/authorReference/identifier/type/coding/code (VARCHAR)
  medstat_note_authorreference_identifier_type_display VARCHAR,   -- note/authorReference/identifier/type/coding/display (VARCHAR)
  medstat_note_authorreference_identifier_type_text VARCHAR,   -- note/authorReference/identifier/type/text (VARCHAR)
  medstat_note_authorreference_display VARCHAR,   -- note/authorReference/display (VARCHAR)
  medstat_note_time VARCHAR,   -- note/time (VARCHAR)
  medstat_note_text VARCHAR,   -- note/text (VARCHAR)
  medstat_dosage_sequence VARCHAR,   -- dosage/sequence (VARCHAR)
  medstat_dosage_text VARCHAR,   -- dosage/text (VARCHAR)
  medstat_dosage_additionalinstruction_system VARCHAR,   -- dosage/additionalInstruction/coding/system (VARCHAR)
  medstat_dosage_additionalinstruction_version VARCHAR,   -- dosage/additionalInstruction/coding/version (VARCHAR)
  medstat_dosage_additionalinstruction_code VARCHAR,   -- dosage/additionalInstruction/coding/code (VARCHAR)
  medstat_dosage_additionalinstruction_display VARCHAR,   -- dosage/additionalInstruction/coding/display (VARCHAR)
  medstat_dosage_additionalinstruction_text VARCHAR,   -- dosage/additionalInstruction/text (VARCHAR)
  medstat_dosage_patientinstruction VARCHAR,   -- dosage/patientInstruction (VARCHAR)
  medstat_dosage_timing_event VARCHAR,   -- dosage/timing/event (VARCHAR)
  medstat_dosage_timing_repeat_boundsduration_value VARCHAR,   -- dosage/timing/repeat/boundsDuration/value (VARCHAR)
  medstat_dosage_timing_repeat_boundsduration_comparator VARCHAR,   -- dosage/timing/repeat/boundsDuration/comparator (VARCHAR)
  medstat_dosage_timing_repeat_boundsduration_unit VARCHAR,   -- dosage/timing/repeat/boundsDuration/unit (VARCHAR)
  medstat_dosage_timing_repeat_boundsduration_system VARCHAR,   -- dosage/timing/repeat/boundsDuration/system (VARCHAR)
  medstat_dosage_timing_repeat_boundsduration_code VARCHAR,   -- dosage/timing/repeat/boundsDuration/code (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_low_value VARCHAR,   -- dosage/timing/repeat/boundsRange/low/value (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_low_unit VARCHAR,   -- dosage/timing/repeat/boundsRange/low/unit (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_low_system VARCHAR,   -- dosage/timing/repeat/boundsRange/low/system (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_low_code VARCHAR,   -- dosage/timing/repeat/boundsRange/low/code (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_high_value VARCHAR,   -- dosage/timing/repeat/boundsRange/high/value (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_high_unit VARCHAR,   -- dosage/timing/repeat/boundsRange/high/unit (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_high_system VARCHAR,   -- dosage/timing/repeat/boundsRange/high/system (VARCHAR)
  medstat_dosage_timing_repeat_boundsrange_high_code VARCHAR,   -- dosage/timing/repeat/boundsRange/high/code (VARCHAR)
  medstat_dosage_timing_repeat_boundsperiod_start VARCHAR,   -- dosage/timing/repeat/boundsPeriod/start (VARCHAR)
  medstat_dosage_timing_repeat_boundsperiod_end VARCHAR,   -- dosage/timing/repeat/boundsPeriod/end (VARCHAR)
  medstat_dosage_timing_repeat_count VARCHAR,   -- dosage/timing/repeat/count (VARCHAR)
  medstat_dosage_timing_repeat_countmax VARCHAR,   -- dosage/timing/repeat/countMax (VARCHAR)
  medstat_dosage_timing_repeat_duration VARCHAR,   -- dosage/timing/repeat/duration (VARCHAR)
  medstat_dosage_timing_repeat_durationmax VARCHAR,   -- dosage/timing/repeat/durationMax (VARCHAR)
  medstat_dosage_timing_repeat_durationunit VARCHAR,   -- dosage/timing/repeat/durationUnit (VARCHAR)
  medstat_dosage_timing_repeat_frequency VARCHAR,   -- dosage/timing/repeat/frequency (VARCHAR)
  medstat_dosage_timing_repeat_frequencymax VARCHAR,   -- dosage/timing/repeat/frequencyMax (VARCHAR)
  medstat_dosage_timing_repeat_period VARCHAR,   -- dosage/timing/repeat/period (VARCHAR)
  medstat_dosage_timing_repeat_periodmax VARCHAR,   -- dosage/timing/repeat/periodMax (VARCHAR)
  medstat_dosage_timing_repeat_periodunit VARCHAR,   -- dosage/timing/repeat/periodUnit (VARCHAR)
  medstat_dosage_timing_repeat_dayofweek VARCHAR,   -- dosage/timing/repeat/dayOfWeek (VARCHAR)
  medstat_dosage_timing_repeat_timeofday VARCHAR,   -- dosage/timing/repeat/timeOfDay (VARCHAR)
  medstat_dosage_timing_repeat_when VARCHAR,   -- dosage/timing/repeat/when (VARCHAR)
  medstat_dosage_timing_repeat_offset VARCHAR,   -- dosage/timing/repeat/offset (VARCHAR)
  medstat_dosage_timing_code_system VARCHAR,   -- dosage/timing/code/coding/system (VARCHAR)
  medstat_dosage_timing_code_version VARCHAR,   -- dosage/timing/code/coding/version (VARCHAR)
  medstat_dosage_timing_code_code VARCHAR,   -- dosage/timing/code/coding/code (VARCHAR)
  medstat_dosage_timing_code_display VARCHAR,   -- dosage/timing/code/coding/display (VARCHAR)
  medstat_dosage_timing_code_text VARCHAR,   -- dosage/timing/code/text (VARCHAR)
  medstat_dosage_asneededboolean VARCHAR,   -- dosage/asNeededBoolean (VARCHAR)
  medstat_dosage_asneededcodeableconcept_system VARCHAR,   -- dosage/asNeededCodeableConcept/coding/system (VARCHAR)
  medstat_dosage_asneededcodeableconcept_version VARCHAR,   -- dosage/asNeededCodeableConcept/coding/version (VARCHAR)
  medstat_dosage_asneededcodeableconcept_code VARCHAR,   -- dosage/asNeededCodeableConcept/coding/code (VARCHAR)
  medstat_dosage_asneededcodeableconcept_display VARCHAR,   -- dosage/asNeededCodeableConcept/coding/display (VARCHAR)
  medstat_dosage_asneededcodeableconcept_text VARCHAR,   -- dosage/asNeededCodeableConcept/text (VARCHAR)
  medstat_dosage_site_system VARCHAR,   -- dosage/site/coding/system (VARCHAR)
  medstat_dosage_site_version VARCHAR,   -- dosage/site/coding/version (VARCHAR)
  medstat_dosage_site_code VARCHAR,   -- dosage/site/coding/code (VARCHAR)
  medstat_dosage_site_display VARCHAR,   -- dosage/site/coding/display (VARCHAR)
  medstat_dosage_site_text VARCHAR,   -- dosage/site/text (VARCHAR)
  medstat_dosage_route_system VARCHAR,   -- dosage/route/coding/system (VARCHAR)
  medstat_dosage_route_version VARCHAR,   -- dosage/route/coding/version (VARCHAR)
  medstat_dosage_route_code VARCHAR,   -- dosage/route/coding/code (VARCHAR)
  medstat_dosage_route_display VARCHAR,   -- dosage/route/coding/display (VARCHAR)
  medstat_dosage_route_text VARCHAR,   -- dosage/route/text (VARCHAR)
  medstat_dosage_method_system VARCHAR,   -- dosage/method/coding/system (VARCHAR)
  medstat_dosage_method_version VARCHAR,   -- dosage/method/coding/version (VARCHAR)
  medstat_dosage_method_code VARCHAR,   -- dosage/method/coding/code (VARCHAR)
  medstat_dosage_method_display VARCHAR,   -- dosage/method/coding/display (VARCHAR)
  medstat_dosage_method_text VARCHAR,   -- dosage/method/text (VARCHAR)
  medstat_dosage_doseandrate_type_system VARCHAR,   -- dosage/doseAndRate/type/coding/system (VARCHAR)
  medstat_dosage_doseandrate_type_version VARCHAR,   -- dosage/doseAndRate/type/coding/version (VARCHAR)
  medstat_dosage_doseandrate_type_code VARCHAR,   -- dosage/doseAndRate/type/coding/code (VARCHAR)
  medstat_dosage_doseandrate_type_display VARCHAR,   -- dosage/doseAndRate/type/coding/display (VARCHAR)
  medstat_dosage_doseandrate_type_text VARCHAR,   -- dosage/doseAndRate/type/text (VARCHAR)
  medstat_dosage_doseandrate_doserange_low_value VARCHAR,   -- dosage/doseAndRate/doseRange/low/value (VARCHAR)
  medstat_dosage_doseandrate_doserange_low_unit VARCHAR,   -- dosage/doseAndRate/doseRange/low/unit (VARCHAR)
  medstat_dosage_doseandrate_doserange_low_system VARCHAR,   -- dosage/doseAndRate/doseRange/low/system (VARCHAR)
  medstat_dosage_doseandrate_doserange_low_code VARCHAR,   -- dosage/doseAndRate/doseRange/low/code (VARCHAR)
  medstat_dosage_doseandrate_doserange_high_value VARCHAR,   -- dosage/doseAndRate/doseRange/high/value (VARCHAR)
  medstat_dosage_doseandrate_doserange_high_unit VARCHAR,   -- dosage/doseAndRate/doseRange/high/unit (VARCHAR)
  medstat_dosage_doseandrate_doserange_high_system VARCHAR,   -- dosage/doseAndRate/doseRange/high/system (VARCHAR)
  medstat_dosage_doseandrate_doserange_high_code VARCHAR,   -- dosage/doseAndRate/doseRange/high/code (VARCHAR)
  medstat_dosage_doseandrate_dosequantity_value VARCHAR,   -- dosage/doseAndRate/doseQuantity/value (VARCHAR)
  medstat_dosage_doseandrate_dosequantity_comparator VARCHAR,   -- dosage/doseAndRate/doseQuantity/comparator (VARCHAR)
  medstat_dosage_doseandrate_dosequantity_unit VARCHAR,   -- dosage/doseAndRate/doseQuantity/unit (VARCHAR)
  medstat_dosage_doseandrate_dosequantity_system VARCHAR,   -- dosage/doseAndRate/doseQuantity/system (VARCHAR)
  medstat_dosage_doseandrate_dosequantity_code VARCHAR,   -- dosage/doseAndRate/doseQuantity/code (VARCHAR)
  medstat_dosage_doseandrate_rateratio_numerator_value VARCHAR,   -- dosage/doseAndRate/rateRatio/numerator/value (VARCHAR)
  medstat_dosage_doseandrate_rateratio_numerator_comparator VARCHAR,   -- dosage/doseAndRate/rateRatio/numerator/comparator (VARCHAR)
  medstat_dosage_doseandrate_rateratio_numerator_unit VARCHAR,   -- dosage/doseAndRate/rateRatio/numerator/unit (VARCHAR)
  medstat_dosage_doseandrate_rateratio_numerator_system VARCHAR,   -- dosage/doseAndRate/rateRatio/numerator/system (VARCHAR)
  medstat_dosage_doseandrate_rateratio_numerator_code VARCHAR,   -- dosage/doseAndRate/rateRatio/numerator/code (VARCHAR)
  medstat_dosage_doseandrate_rateratio_denominator_value VARCHAR,   -- dosage/doseAndRate/rateRatio/denominator/value (VARCHAR)
  medstat_dosage_doseandrate_rateratio_denominator_comparator VARCHAR,   -- dosage/doseAndRate/rateRatio/denominator/comparator (VARCHAR)
  medstat_dosage_doseandrate_rateratio_denominator_unit VARCHAR,   -- dosage/doseAndRate/rateRatio/denominator/unit (VARCHAR)
  medstat_dosage_doseandrate_rateratio_denominator_system VARCHAR,   -- dosage/doseAndRate/rateRatio/denominator/system (VARCHAR)
  medstat_dosage_doseandrate_rateratio_denominator_code VARCHAR,   -- dosage/doseAndRate/rateRatio/denominator/code (VARCHAR)
  medstat_dosage_doseandrate_raterange_low_value VARCHAR,   -- dosage/doseAndRate/rateRange/low/value (VARCHAR)
  medstat_dosage_doseandrate_raterange_low_unit VARCHAR,   -- dosage/doseAndRate/rateRange/low/unit (VARCHAR)
  medstat_dosage_doseandrate_raterange_low_system VARCHAR,   -- dosage/doseAndRate/rateRange/low/system (VARCHAR)
  medstat_dosage_doseandrate_raterange_low_code VARCHAR,   -- dosage/doseAndRate/rateRange/low/code (VARCHAR)
  medstat_dosage_doseandrate_raterange_high_value VARCHAR,   -- dosage/doseAndRate/rateRange/high/value (VARCHAR)
  medstat_dosage_doseandrate_raterange_high_unit VARCHAR,   -- dosage/doseAndRate/rateRange/high/unit (VARCHAR)
  medstat_dosage_doseandrate_raterange_high_system VARCHAR,   -- dosage/doseAndRate/rateRange/high/system (VARCHAR)
  medstat_dosage_doseandrate_raterange_high_code VARCHAR,   -- dosage/doseAndRate/rateRange/high/code (VARCHAR)
  medstat_dosage_doseandrate_ratequantity_value VARCHAR,   -- dosage/doseAndRate/rateQuantity/value (VARCHAR)
  medstat_dosage_doseandrate_ratequantity_unit VARCHAR,   -- dosage/doseAndRate/rateQuantity/unit (VARCHAR)
  medstat_dosage_doseandrate_ratequantity_system VARCHAR,   -- dosage/doseAndRate/rateQuantity/system (VARCHAR)
  medstat_dosage_doseandrate_ratequantity_code VARCHAR,   -- dosage/doseAndRate/rateQuantity/code (VARCHAR)
  medstat_dosage_maxdoseperperiod_numerator_value VARCHAR,   -- dosage/maxDosePerPeriod/numerator/value (VARCHAR)
  medstat_dosage_maxdoseperperiod_numerator_comparator VARCHAR,   -- dosage/maxDosePerPeriod/numerator/comparator (VARCHAR)
  medstat_dosage_maxdoseperperiod_numerator_unit VARCHAR,   -- dosage/maxDosePerPeriod/numerator/unit (VARCHAR)
  medstat_dosage_maxdoseperperiod_numerator_system VARCHAR,   -- dosage/maxDosePerPeriod/numerator/system (VARCHAR)
  medstat_dosage_maxdoseperperiod_numerator_code VARCHAR,   -- dosage/maxDosePerPeriod/numerator/code (VARCHAR)
  medstat_dosage_maxdoseperperiod_denominator_value VARCHAR,   -- dosage/maxDosePerPeriod/denominator/value (VARCHAR)
  medstat_dosage_maxdoseperperiod_denominator_comparator VARCHAR,   -- dosage/maxDosePerPeriod/denominator/comparator (VARCHAR)
  medstat_dosage_maxdoseperperiod_denominator_unit VARCHAR,   -- dosage/maxDosePerPeriod/denominator/unit (VARCHAR)
  medstat_dosage_maxdoseperperiod_denominator_system VARCHAR,   -- dosage/maxDosePerPeriod/denominator/system (VARCHAR)
  medstat_dosage_maxdoseperperiod_denominator_code VARCHAR,   -- dosage/maxDosePerPeriod/denominator/code (VARCHAR)
  medstat_dosage_maxdoseperadministration_value VARCHAR,   -- dosage/maxDosePerAdministration/value (VARCHAR)
  medstat_dosage_maxdoseperadministration_unit VARCHAR,   -- dosage/maxDosePerAdministration/unit (VARCHAR)
  medstat_dosage_maxdoseperadministration_system VARCHAR,   -- dosage/maxDosePerAdministration/system (VARCHAR)
  medstat_dosage_maxdoseperadministration_code VARCHAR,   -- dosage/maxDosePerAdministration/code (VARCHAR)
  medstat_dosage_maxdoseperlifetime_value VARCHAR,   -- dosage/maxDosePerLifetime/value (VARCHAR)
  medstat_dosage_maxdoseperlifetime_unit VARCHAR,   -- dosage/maxDosePerLifetime/unit (VARCHAR)
  medstat_dosage_maxdoseperlifetime_system VARCHAR,   -- dosage/maxDosePerLifetime/system (VARCHAR)
  medstat_dosage_maxdoseperlifetime_code VARCHAR,   -- dosage/maxDosePerLifetime/code (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(medstat_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(medstat_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(medstat_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(medstat_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(medstat_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(medstat_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(medstat_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(medstat_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(medstat_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(medstat_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(medstat_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(medstat_encounter_ref, '#NULL#') || '|||' || -- hash from: context/reference
             COALESCE(medstat_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(medstat_partof_ref, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(medstat_basedon_ref, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(medstat_basedon_type, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(medstat_basedon_identifier_use, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(medstat_basedon_identifier_type_system, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(medstat_basedon_identifier_type_version, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(medstat_basedon_identifier_type_code, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(medstat_basedon_identifier_type_display, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(medstat_basedon_identifier_type_text, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(medstat_basedon_display, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(medstat_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(medstat_statusreason_system, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(medstat_statusreason_version, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(medstat_statusreason_code, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(medstat_statusreason_display, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(medstat_statusreason_text, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(medstat_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(medstat_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(medstat_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(medstat_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(medstat_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(medstat_medicationreference_ref, '#NULL#') || '|||' || -- hash from: medicationReference/reference
             COALESCE(medstat_medicationcodeableconcept_system, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/system
             COALESCE(medstat_medicationcodeableconcept_version, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/version
             COALESCE(medstat_medicationcodeableconcept_code, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/code
             COALESCE(medstat_medicationcodeableconcept_display, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/display
             COALESCE(medstat_medicationcodeableconcept_text, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/text
             COALESCE(medstat_effectivedatetime, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(medstat_effectiveperiod_start, '#NULL#') || '|||' || -- hash from: effectivePeriod/start
             COALESCE(medstat_effectiveperiod_end, '#NULL#') || '|||' || -- hash from: effectivePeriod/end
             COALESCE(medstat_dateasserted, '#NULL#') || '|||' || -- hash from: dateAsserted
             COALESCE(medstat_informationsource_ref, '#NULL#') || '|||' || -- hash from: informationSource/reference
             COALESCE(medstat_informationsource_type, '#NULL#') || '|||' || -- hash from: informationSource/type
             COALESCE(medstat_informationsource_identifier_use, '#NULL#') || '|||' || -- hash from: informationSource/identifier/use
             COALESCE(medstat_informationsource_identifier_type_system, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/system
             COALESCE(medstat_informationsource_identifier_type_version, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/version
             COALESCE(medstat_informationsource_identifier_type_code, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/code
             COALESCE(medstat_informationsource_identifier_type_display, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/display
             COALESCE(medstat_informationsource_identifier_type_text, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/text
             COALESCE(medstat_informationsource_display, '#NULL#') || '|||' || -- hash from: informationSource/display
             COALESCE(medstat_derivedfrom_ref, '#NULL#') || '|||' || -- hash from: derivedFrom/reference
             COALESCE(medstat_derivedfrom_type, '#NULL#') || '|||' || -- hash from: derivedFrom/type
             COALESCE(medstat_derivedfrom_identifier_use, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/use
             COALESCE(medstat_derivedfrom_identifier_type_system, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/system
             COALESCE(medstat_derivedfrom_identifier_type_version, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/version
             COALESCE(medstat_derivedfrom_identifier_type_code, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/code
             COALESCE(medstat_derivedfrom_identifier_type_display, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/display
             COALESCE(medstat_derivedfrom_identifier_type_text, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/text
             COALESCE(medstat_derivedfrom_display, '#NULL#') || '|||' || -- hash from: derivedFrom/display
             COALESCE(medstat_reasoncode_system, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(medstat_reasoncode_version, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(medstat_reasoncode_code, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(medstat_reasoncode_display, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(medstat_reasoncode_text, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(medstat_reasonreference_ref, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(medstat_reasonreference_type, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(medstat_reasonreference_identifier_use, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(medstat_reasonreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(medstat_reasonreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(medstat_reasonreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(medstat_reasonreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(medstat_reasonreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(medstat_reasonreference_display, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(medstat_note_authorstring, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(medstat_note_authorreference_ref, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(medstat_note_authorreference_type, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(medstat_note_authorreference_identifier_use, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(medstat_note_authorreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(medstat_note_authorreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(medstat_note_authorreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(medstat_note_authorreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(medstat_note_authorreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(medstat_note_authorreference_display, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(medstat_note_time, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(medstat_note_text, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(medstat_dosage_sequence, '#NULL#') || '|||' || -- hash from: dosage/sequence
             COALESCE(medstat_dosage_text, '#NULL#') || '|||' || -- hash from: dosage/text
             COALESCE(medstat_dosage_additionalinstruction_system, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/system
             COALESCE(medstat_dosage_additionalinstruction_version, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/version
             COALESCE(medstat_dosage_additionalinstruction_code, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/code
             COALESCE(medstat_dosage_additionalinstruction_display, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/display
             COALESCE(medstat_dosage_additionalinstruction_text, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/text
             COALESCE(medstat_dosage_patientinstruction, '#NULL#') || '|||' || -- hash from: dosage/patientInstruction
             COALESCE(medstat_dosage_timing_event, '#NULL#') || '|||' || -- hash from: dosage/timing/event
             COALESCE(medstat_dosage_timing_repeat_boundsduration_value, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/value
             COALESCE(medstat_dosage_timing_repeat_boundsduration_comparator, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/comparator
             COALESCE(medstat_dosage_timing_repeat_boundsduration_unit, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/unit
             COALESCE(medstat_dosage_timing_repeat_boundsduration_system, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/system
             COALESCE(medstat_dosage_timing_repeat_boundsduration_code, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/code
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_value, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/value
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_unit, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/unit
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_system, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/system
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_code, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/code
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_value, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/value
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_unit, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/unit
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_system, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/system
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_code, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/code
             COALESCE(medstat_dosage_timing_repeat_boundsperiod_start, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsPeriod/start
             COALESCE(medstat_dosage_timing_repeat_boundsperiod_end, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsPeriod/end
             COALESCE(medstat_dosage_timing_repeat_count, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/count
             COALESCE(medstat_dosage_timing_repeat_countmax, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/countMax
             COALESCE(medstat_dosage_timing_repeat_duration, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/duration
             COALESCE(medstat_dosage_timing_repeat_durationmax, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/durationMax
             COALESCE(medstat_dosage_timing_repeat_durationunit, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/durationUnit
             COALESCE(medstat_dosage_timing_repeat_frequency, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/frequency
             COALESCE(medstat_dosage_timing_repeat_frequencymax, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/frequencyMax
             COALESCE(medstat_dosage_timing_repeat_period, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/period
             COALESCE(medstat_dosage_timing_repeat_periodmax, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/periodMax
             COALESCE(medstat_dosage_timing_repeat_periodunit, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/periodUnit
             COALESCE(medstat_dosage_timing_repeat_dayofweek, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/dayOfWeek
             COALESCE(medstat_dosage_timing_repeat_timeofday, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/timeOfDay
             COALESCE(medstat_dosage_timing_repeat_when, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/when
             COALESCE(medstat_dosage_timing_repeat_offset, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/offset
             COALESCE(medstat_dosage_timing_code_system, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/system
             COALESCE(medstat_dosage_timing_code_version, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/version
             COALESCE(medstat_dosage_timing_code_code, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/code
             COALESCE(medstat_dosage_timing_code_display, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/display
             COALESCE(medstat_dosage_timing_code_text, '#NULL#') || '|||' || -- hash from: dosage/timing/code/text
             COALESCE(medstat_dosage_asneededboolean, '#NULL#') || '|||' || -- hash from: dosage/asNeededBoolean
             COALESCE(medstat_dosage_asneededcodeableconcept_system, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/system
             COALESCE(medstat_dosage_asneededcodeableconcept_version, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/version
             COALESCE(medstat_dosage_asneededcodeableconcept_code, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/code
             COALESCE(medstat_dosage_asneededcodeableconcept_display, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/display
             COALESCE(medstat_dosage_asneededcodeableconcept_text, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/text
             COALESCE(medstat_dosage_site_system, '#NULL#') || '|||' || -- hash from: dosage/site/coding/system
             COALESCE(medstat_dosage_site_version, '#NULL#') || '|||' || -- hash from: dosage/site/coding/version
             COALESCE(medstat_dosage_site_code, '#NULL#') || '|||' || -- hash from: dosage/site/coding/code
             COALESCE(medstat_dosage_site_display, '#NULL#') || '|||' || -- hash from: dosage/site/coding/display
             COALESCE(medstat_dosage_site_text, '#NULL#') || '|||' || -- hash from: dosage/site/text
             COALESCE(medstat_dosage_route_system, '#NULL#') || '|||' || -- hash from: dosage/route/coding/system
             COALESCE(medstat_dosage_route_version, '#NULL#') || '|||' || -- hash from: dosage/route/coding/version
             COALESCE(medstat_dosage_route_code, '#NULL#') || '|||' || -- hash from: dosage/route/coding/code
             COALESCE(medstat_dosage_route_display, '#NULL#') || '|||' || -- hash from: dosage/route/coding/display
             COALESCE(medstat_dosage_route_text, '#NULL#') || '|||' || -- hash from: dosage/route/text
             COALESCE(medstat_dosage_method_system, '#NULL#') || '|||' || -- hash from: dosage/method/coding/system
             COALESCE(medstat_dosage_method_version, '#NULL#') || '|||' || -- hash from: dosage/method/coding/version
             COALESCE(medstat_dosage_method_code, '#NULL#') || '|||' || -- hash from: dosage/method/coding/code
             COALESCE(medstat_dosage_method_display, '#NULL#') || '|||' || -- hash from: dosage/method/coding/display
             COALESCE(medstat_dosage_method_text, '#NULL#') || '|||' || -- hash from: dosage/method/text
             COALESCE(medstat_dosage_doseandrate_type_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/system
             COALESCE(medstat_dosage_doseandrate_type_version, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/version
             COALESCE(medstat_dosage_doseandrate_type_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/code
             COALESCE(medstat_dosage_doseandrate_type_display, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/display
             COALESCE(medstat_dosage_doseandrate_type_text, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/text
             COALESCE(medstat_dosage_doseandrate_doserange_low_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/value
             COALESCE(medstat_dosage_doseandrate_doserange_low_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/unit
             COALESCE(medstat_dosage_doseandrate_doserange_low_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/system
             COALESCE(medstat_dosage_doseandrate_doserange_low_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/code
             COALESCE(medstat_dosage_doseandrate_doserange_high_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/value
             COALESCE(medstat_dosage_doseandrate_doserange_high_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/unit
             COALESCE(medstat_dosage_doseandrate_doserange_high_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/system
             COALESCE(medstat_dosage_doseandrate_doserange_high_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/code
             COALESCE(medstat_dosage_doseandrate_dosequantity_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/value
             COALESCE(medstat_dosage_doseandrate_dosequantity_comparator, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/comparator
             COALESCE(medstat_dosage_doseandrate_dosequantity_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/unit
             COALESCE(medstat_dosage_doseandrate_dosequantity_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/system
             COALESCE(medstat_dosage_doseandrate_dosequantity_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/code
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/value
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_comparator, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/comparator
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/unit
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/system
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/code
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/value
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_comparator, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/comparator
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/unit
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/system
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/code
             COALESCE(medstat_dosage_doseandrate_raterange_low_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/value
             COALESCE(medstat_dosage_doseandrate_raterange_low_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/unit
             COALESCE(medstat_dosage_doseandrate_raterange_low_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/system
             COALESCE(medstat_dosage_doseandrate_raterange_low_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/code
             COALESCE(medstat_dosage_doseandrate_raterange_high_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/value
             COALESCE(medstat_dosage_doseandrate_raterange_high_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/unit
             COALESCE(medstat_dosage_doseandrate_raterange_high_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/system
             COALESCE(medstat_dosage_doseandrate_raterange_high_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/code
             COALESCE(medstat_dosage_doseandrate_ratequantity_value, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/value
             COALESCE(medstat_dosage_doseandrate_ratequantity_unit, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/unit
             COALESCE(medstat_dosage_doseandrate_ratequantity_system, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/system
             COALESCE(medstat_dosage_doseandrate_ratequantity_code, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/code
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_value, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/value
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_comparator, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/comparator
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_unit, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/unit
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_system, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/system
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_code, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/code
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_value, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/value
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_comparator, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/comparator
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_unit, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/unit
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_system, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/system
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_code, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/code
             COALESCE(medstat_dosage_maxdoseperadministration_value, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/value
             COALESCE(medstat_dosage_maxdoseperadministration_unit, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/unit
             COALESCE(medstat_dosage_maxdoseperadministration_system, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/system
             COALESCE(medstat_dosage_maxdoseperadministration_code, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/code
             COALESCE(medstat_dosage_maxdoseperlifetime_value, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/value
             COALESCE(medstat_dosage_maxdoseperlifetime_unit, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/unit
             COALESCE(medstat_dosage_maxdoseperlifetime_system, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/system
             COALESCE(medstat_dosage_maxdoseperlifetime_code, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/code
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.observation_raw (
  observation_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  obs_id VARCHAR,   -- id (VARCHAR)
  obs_encounter_ref VARCHAR,   -- encounter/reference (VARCHAR)
  obs_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  obs_partof_ref VARCHAR,   -- partOf/reference (VARCHAR)
  obs_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  obs_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  obs_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  obs_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  obs_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  obs_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  obs_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  obs_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  obs_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  obs_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  obs_basedon_ref VARCHAR,   -- basedOn/reference (VARCHAR)
  obs_basedon_type VARCHAR,   -- basedOn/type (VARCHAR)
  obs_basedon_identifier_use VARCHAR,   -- basedOn/identifier/use (VARCHAR)
  obs_basedon_identifier_type_system VARCHAR,   -- basedOn/identifier/type/coding/system (VARCHAR)
  obs_basedon_identifier_type_version VARCHAR,   -- basedOn/identifier/type/coding/version (VARCHAR)
  obs_basedon_identifier_type_code VARCHAR,   -- basedOn/identifier/type/coding/code (VARCHAR)
  obs_basedon_identifier_type_display VARCHAR,   -- basedOn/identifier/type/coding/display (VARCHAR)
  obs_basedon_identifier_type_text VARCHAR,   -- basedOn/identifier/type/text (VARCHAR)
  obs_basedon_display VARCHAR,   -- basedOn/display (VARCHAR)
  obs_status VARCHAR,   -- status (VARCHAR)
  obs_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  obs_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  obs_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  obs_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  obs_category_text VARCHAR,   -- category/text (VARCHAR)
  obs_code_system VARCHAR,   -- code/coding/system (VARCHAR)
  obs_code_version VARCHAR,   -- code/coding/version (VARCHAR)
  obs_code_code VARCHAR,   -- code/coding/code (VARCHAR)
  obs_code_display VARCHAR,   -- code/coding/display (VARCHAR)
  obs_code_text VARCHAR,   -- code/text (VARCHAR)
  obs_effectivedatetime VARCHAR,   -- effectiveDateTime (VARCHAR)
  obs_issued VARCHAR,   -- issued (VARCHAR)
  obs_valuerange_low_value VARCHAR,   -- valueRange/low/value (VARCHAR)
  obs_valuerange_low_unit VARCHAR,   -- valueRange/low/unit (VARCHAR)
  obs_valuerange_low_system VARCHAR,   -- valueRange/low/system (VARCHAR)
  obs_valuerange_low_code VARCHAR,   -- valueRange/low/code (VARCHAR)
  obs_valuerange_high_value VARCHAR,   -- valueRange/high/value (VARCHAR)
  obs_valuerange_high_unit VARCHAR,   -- valueRange/high/unit (VARCHAR)
  obs_valuerange_high_system VARCHAR,   -- valueRange/high/system (VARCHAR)
  obs_valuerange_high_code VARCHAR,   -- valueRange/high/code (VARCHAR)
  obs_valueratio_numerator_value VARCHAR,   -- valueRatio/numerator/value (VARCHAR)
  obs_valueratio_numerator_comparator VARCHAR,   -- valueRatio/numerator/comparator (VARCHAR)
  obs_valueratio_numerator_unit VARCHAR,   -- valueRatio/numerator/unit (VARCHAR)
  obs_valueratio_numerator_system VARCHAR,   -- valueRatio/numerator/system (VARCHAR)
  obs_valueratio_numerator_code VARCHAR,   -- valueRatio/numerator/code (VARCHAR)
  obs_valueratio_denominator_value VARCHAR,   -- valueRatio/denominator/value (VARCHAR)
  obs_valueratio_denominator_comparator VARCHAR,   -- valueRatio/denominator/comparator (VARCHAR)
  obs_valueratio_denominator_unit VARCHAR,   -- valueRatio/denominator/unit (VARCHAR)
  obs_valueratio_denominator_system VARCHAR,   -- valueRatio/denominator/system (VARCHAR)
  obs_valueratio_denominator_code VARCHAR,   -- valueRatio/denominator/code (VARCHAR)
  obs_valuequantity_value VARCHAR,   -- valueQuantity/value (VARCHAR)
  obs_valuequantity_comparator VARCHAR,   -- valueQuantity/comparator (VARCHAR)
  obs_valuequantity_unit VARCHAR,   -- valueQuantity/unit (VARCHAR)
  obs_valuequantity_system VARCHAR,   -- valueQuantity/system (VARCHAR)
  obs_valuequantity_code VARCHAR,   -- valueQuantity/code (VARCHAR)
  obs_valuecodableconcept_system VARCHAR,   -- valueCodableConcept/coding/system (VARCHAR)
  obs_valuecodableconcept_version VARCHAR,   -- valueCodableConcept/coding/version (VARCHAR)
  obs_valuecodableconcept_code VARCHAR,   -- valueCodableConcept/coding/code (VARCHAR)
  obs_valuecodableconcept_display VARCHAR,   -- valueCodableConcept/coding/display (VARCHAR)
  obs_valuecodableconcept_text VARCHAR,   -- valueCodableConcept/text (VARCHAR)
  obs_dataabsentreason_system VARCHAR,   -- dataAbsentReason/coding/system (VARCHAR)
  obs_dataabsentreason_version VARCHAR,   -- dataAbsentReason/coding/version (VARCHAR)
  obs_dataabsentreason_code VARCHAR,   -- dataAbsentReason/coding/code (VARCHAR)
  obs_dataabsentreason_display VARCHAR,   -- dataAbsentReason/coding/display (VARCHAR)
  obs_dataabsentreason_text VARCHAR,   -- dataAbsentReason/text (VARCHAR)
  obs_note_authorstring VARCHAR,   -- note/authorString (VARCHAR)
  obs_note_authorreference_ref VARCHAR,   -- note/authorReference/reference (VARCHAR)
  obs_note_authorreference_type VARCHAR,   -- note/authorReference/type (VARCHAR)
  obs_note_authorreference_identifier_use VARCHAR,   -- note/authorReference/identifier/use (VARCHAR)
  obs_note_authorreference_identifier_type_system VARCHAR,   -- note/authorReference/identifier/type/coding/system (VARCHAR)
  obs_note_authorreference_identifier_type_version VARCHAR,   -- note/authorReference/identifier/type/coding/version (VARCHAR)
  obs_note_authorreference_identifier_type_code VARCHAR,   -- note/authorReference/identifier/type/coding/code (VARCHAR)
  obs_note_authorreference_identifier_type_display VARCHAR,   -- note/authorReference/identifier/type/coding/display (VARCHAR)
  obs_note_authorreference_identifier_type_text VARCHAR,   -- note/authorReference/identifier/type/text (VARCHAR)
  obs_note_authorreference_display VARCHAR,   -- note/authorReference/display (VARCHAR)
  obs_note_time VARCHAR,   -- note/time (VARCHAR)
  obs_note_text VARCHAR,   -- note/text (VARCHAR)
  obs_method_system VARCHAR,   -- method/coding/system (VARCHAR)
  obs_method_version VARCHAR,   -- method/coding/version (VARCHAR)
  obs_method_code VARCHAR,   -- method/coding/code (VARCHAR)
  obs_method_display VARCHAR,   -- method/coding/display (VARCHAR)
  obs_method_text VARCHAR,   -- method/text (VARCHAR)
  obs_performer_ref VARCHAR,   -- performer/reference (VARCHAR)
  obs_performer_type VARCHAR,   -- performer/type (VARCHAR)
  obs_performer_identifier_use VARCHAR,   -- performer/identifier/use (VARCHAR)
  obs_performer_identifier_type_system VARCHAR,   -- performer/identifier/type/coding/system (VARCHAR)
  obs_performer_identifier_type_version VARCHAR,   -- performer/identifier/type/coding/version (VARCHAR)
  obs_performer_identifier_type_code VARCHAR,   -- performer/identifier/type/coding/code (VARCHAR)
  obs_performer_identifier_type_display VARCHAR,   -- performer/identifier/type/coding/display (VARCHAR)
  obs_performer_identifier_type_text VARCHAR,   -- performer/identifier/type/text (VARCHAR)
  obs_performer_display VARCHAR,   -- performer/display (VARCHAR)
  obs_referencerange_low_value VARCHAR,   -- referenceRange/low/value (VARCHAR)
  obs_referencerange_low_unit VARCHAR,   -- referenceRange/low/unit (VARCHAR)
  obs_referencerange_low_system VARCHAR,   -- referenceRange/low/system (VARCHAR)
  obs_referencerange_low_code VARCHAR,   -- referenceRange/low/code (VARCHAR)
  obs_referencerange_high_value VARCHAR,   -- referenceRange/high/value (VARCHAR)
  obs_referencerange_high_unit VARCHAR,   -- referenceRange/high/unit (VARCHAR)
  obs_referencerange_high_system VARCHAR,   -- referenceRange/high/system (VARCHAR)
  obs_referencerange_high_code VARCHAR,   -- referenceRange/high/code (VARCHAR)
  obs_referencerange_type_system VARCHAR,   -- referenceRange/type/coding/system (VARCHAR)
  obs_referencerange_type_version VARCHAR,   -- referenceRange/type/coding/version (VARCHAR)
  obs_referencerange_type_code VARCHAR,   -- referenceRange/type/coding/code (VARCHAR)
  obs_referencerange_type_display VARCHAR,   -- referenceRange/type/coding/display (VARCHAR)
  obs_referencerange_type_text VARCHAR,   -- referenceRange/type/text (VARCHAR)
  obs_referencerange_appliesto_system VARCHAR,   -- referenceRange/appliesTo/coding/system (VARCHAR)
  obs_referencerange_appliesto_version VARCHAR,   -- referenceRange/appliesTo/coding/version (VARCHAR)
  obs_referencerange_appliesto_code VARCHAR,   -- referenceRange/appliesTo/coding/code (VARCHAR)
  obs_referencerange_appliesto_display VARCHAR,   -- referenceRange/appliesTo/coding/display (VARCHAR)
  obs_referencerange_appliesto_text VARCHAR,   -- referenceRange/appliesTo/text (VARCHAR)
  obs_referencerange_age_low_value VARCHAR,   -- referenceRange/age/low/value (VARCHAR)
  obs_referencerange_age_low_unit VARCHAR,   -- referenceRange/age/low/unit (VARCHAR)
  obs_referencerange_age_low_system VARCHAR,   -- referenceRange/age/low/system (VARCHAR)
  obs_referencerange_age_low_code VARCHAR,   -- referenceRange/age/low/code (VARCHAR)
  obs_referencerange_age_high_value VARCHAR,   -- referenceRange/age/high/value (VARCHAR)
  obs_referencerange_age_high_unit VARCHAR,   -- referenceRange/age/high/unit (VARCHAR)
  obs_referencerange_age_high_system VARCHAR,   -- referenceRange/age/high/system (VARCHAR)
  obs_referencerange_age_high_code VARCHAR,   -- referenceRange/age/high/code (VARCHAR)
  obs_referencerange_text VARCHAR,   -- referenceRange/text (VARCHAR)
  obs_hasmember_ref VARCHAR,   -- hasMember/reference (VARCHAR)
  obs_hasmember_type VARCHAR,   -- hasMember/type (VARCHAR)
  obs_hasmember_identifier_use VARCHAR,   -- hasMember/identifier/use (VARCHAR)
  obs_hasmember_identifier_type_system VARCHAR,   -- hasMember/identifier/type/coding/system (VARCHAR)
  obs_hasmember_identifier_type_version VARCHAR,   -- hasMember/identifier/type/coding/version (VARCHAR)
  obs_hasmember_identifier_type_code VARCHAR,   -- hasMember/identifier/type/coding/code (VARCHAR)
  obs_hasmember_identifier_type_display VARCHAR,   -- hasMember/identifier/type/coding/display (VARCHAR)
  obs_hasmember_identifier_type_text VARCHAR,   -- hasMember/identifier/type/text (VARCHAR)
  obs_hasmember_display VARCHAR,   -- hasMember/display (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(obs_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(obs_encounter_ref, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(obs_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(obs_partof_ref, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(obs_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(obs_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(obs_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(obs_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(obs_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(obs_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(obs_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(obs_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(obs_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(obs_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(obs_basedon_ref, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(obs_basedon_type, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(obs_basedon_identifier_use, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(obs_basedon_identifier_type_system, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(obs_basedon_identifier_type_version, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(obs_basedon_identifier_type_code, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(obs_basedon_identifier_type_display, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(obs_basedon_identifier_type_text, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(obs_basedon_display, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(obs_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(obs_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(obs_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(obs_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(obs_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(obs_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(obs_code_system, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(obs_code_version, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(obs_code_code, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(obs_code_display, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(obs_code_text, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(obs_effectivedatetime, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(obs_issued, '#NULL#') || '|||' || -- hash from: issued
             COALESCE(obs_valuerange_low_value, '#NULL#') || '|||' || -- hash from: valueRange/low/value
             COALESCE(obs_valuerange_low_unit, '#NULL#') || '|||' || -- hash from: valueRange/low/unit
             COALESCE(obs_valuerange_low_system, '#NULL#') || '|||' || -- hash from: valueRange/low/system
             COALESCE(obs_valuerange_low_code, '#NULL#') || '|||' || -- hash from: valueRange/low/code
             COALESCE(obs_valuerange_high_value, '#NULL#') || '|||' || -- hash from: valueRange/high/value
             COALESCE(obs_valuerange_high_unit, '#NULL#') || '|||' || -- hash from: valueRange/high/unit
             COALESCE(obs_valuerange_high_system, '#NULL#') || '|||' || -- hash from: valueRange/high/system
             COALESCE(obs_valuerange_high_code, '#NULL#') || '|||' || -- hash from: valueRange/high/code
             COALESCE(obs_valueratio_numerator_value, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/value
             COALESCE(obs_valueratio_numerator_comparator, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/comparator
             COALESCE(obs_valueratio_numerator_unit, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/unit
             COALESCE(obs_valueratio_numerator_system, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/system
             COALESCE(obs_valueratio_numerator_code, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/code
             COALESCE(obs_valueratio_denominator_value, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/value
             COALESCE(obs_valueratio_denominator_comparator, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/comparator
             COALESCE(obs_valueratio_denominator_unit, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/unit
             COALESCE(obs_valueratio_denominator_system, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/system
             COALESCE(obs_valueratio_denominator_code, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/code
             COALESCE(obs_valuequantity_value, '#NULL#') || '|||' || -- hash from: valueQuantity/value
             COALESCE(obs_valuequantity_comparator, '#NULL#') || '|||' || -- hash from: valueQuantity/comparator
             COALESCE(obs_valuequantity_unit, '#NULL#') || '|||' || -- hash from: valueQuantity/unit
             COALESCE(obs_valuequantity_system, '#NULL#') || '|||' || -- hash from: valueQuantity/system
             COALESCE(obs_valuequantity_code, '#NULL#') || '|||' || -- hash from: valueQuantity/code
             COALESCE(obs_valuecodableconcept_system, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/system
             COALESCE(obs_valuecodableconcept_version, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/version
             COALESCE(obs_valuecodableconcept_code, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/code
             COALESCE(obs_valuecodableconcept_display, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/display
             COALESCE(obs_valuecodableconcept_text, '#NULL#') || '|||' || -- hash from: valueCodableConcept/text
             COALESCE(obs_dataabsentreason_system, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/system
             COALESCE(obs_dataabsentreason_version, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/version
             COALESCE(obs_dataabsentreason_code, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/code
             COALESCE(obs_dataabsentreason_display, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/display
             COALESCE(obs_dataabsentreason_text, '#NULL#') || '|||' || -- hash from: dataAbsentReason/text
             COALESCE(obs_note_authorstring, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(obs_note_authorreference_ref, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(obs_note_authorreference_type, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(obs_note_authorreference_identifier_use, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(obs_note_authorreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(obs_note_authorreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(obs_note_authorreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(obs_note_authorreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(obs_note_authorreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(obs_note_authorreference_display, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(obs_note_time, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(obs_note_text, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(obs_method_system, '#NULL#') || '|||' || -- hash from: method/coding/system
             COALESCE(obs_method_version, '#NULL#') || '|||' || -- hash from: method/coding/version
             COALESCE(obs_method_code, '#NULL#') || '|||' || -- hash from: method/coding/code
             COALESCE(obs_method_display, '#NULL#') || '|||' || -- hash from: method/coding/display
             COALESCE(obs_method_text, '#NULL#') || '|||' || -- hash from: method/text
             COALESCE(obs_performer_ref, '#NULL#') || '|||' || -- hash from: performer/reference
             COALESCE(obs_performer_type, '#NULL#') || '|||' || -- hash from: performer/type
             COALESCE(obs_performer_identifier_use, '#NULL#') || '|||' || -- hash from: performer/identifier/use
             COALESCE(obs_performer_identifier_type_system, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/system
             COALESCE(obs_performer_identifier_type_version, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/version
             COALESCE(obs_performer_identifier_type_code, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/code
             COALESCE(obs_performer_identifier_type_display, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/display
             COALESCE(obs_performer_identifier_type_text, '#NULL#') || '|||' || -- hash from: performer/identifier/type/text
             COALESCE(obs_performer_display, '#NULL#') || '|||' || -- hash from: performer/display
             COALESCE(obs_referencerange_low_value, '#NULL#') || '|||' || -- hash from: referenceRange/low/value
             COALESCE(obs_referencerange_low_unit, '#NULL#') || '|||' || -- hash from: referenceRange/low/unit
             COALESCE(obs_referencerange_low_system, '#NULL#') || '|||' || -- hash from: referenceRange/low/system
             COALESCE(obs_referencerange_low_code, '#NULL#') || '|||' || -- hash from: referenceRange/low/code
             COALESCE(obs_referencerange_high_value, '#NULL#') || '|||' || -- hash from: referenceRange/high/value
             COALESCE(obs_referencerange_high_unit, '#NULL#') || '|||' || -- hash from: referenceRange/high/unit
             COALESCE(obs_referencerange_high_system, '#NULL#') || '|||' || -- hash from: referenceRange/high/system
             COALESCE(obs_referencerange_high_code, '#NULL#') || '|||' || -- hash from: referenceRange/high/code
             COALESCE(obs_referencerange_type_system, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/system
             COALESCE(obs_referencerange_type_version, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/version
             COALESCE(obs_referencerange_type_code, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/code
             COALESCE(obs_referencerange_type_display, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/display
             COALESCE(obs_referencerange_type_text, '#NULL#') || '|||' || -- hash from: referenceRange/type/text
             COALESCE(obs_referencerange_appliesto_system, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/system
             COALESCE(obs_referencerange_appliesto_version, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/version
             COALESCE(obs_referencerange_appliesto_code, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/code
             COALESCE(obs_referencerange_appliesto_display, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/display
             COALESCE(obs_referencerange_appliesto_text, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/text
             COALESCE(obs_referencerange_age_low_value, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/value
             COALESCE(obs_referencerange_age_low_unit, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/unit
             COALESCE(obs_referencerange_age_low_system, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/system
             COALESCE(obs_referencerange_age_low_code, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/code
             COALESCE(obs_referencerange_age_high_value, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/value
             COALESCE(obs_referencerange_age_high_unit, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/unit
             COALESCE(obs_referencerange_age_high_system, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/system
             COALESCE(obs_referencerange_age_high_code, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/code
             COALESCE(obs_referencerange_text, '#NULL#') || '|||' || -- hash from: referenceRange/text
             COALESCE(obs_hasmember_ref, '#NULL#') || '|||' || -- hash from: hasMember/reference
             COALESCE(obs_hasmember_type, '#NULL#') || '|||' || -- hash from: hasMember/type
             COALESCE(obs_hasmember_identifier_use, '#NULL#') || '|||' || -- hash from: hasMember/identifier/use
             COALESCE(obs_hasmember_identifier_type_system, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/system
             COALESCE(obs_hasmember_identifier_type_version, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/version
             COALESCE(obs_hasmember_identifier_type_code, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/code
             COALESCE(obs_hasmember_identifier_type_display, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/display
             COALESCE(obs_hasmember_identifier_type_text, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/text
             COALESCE(obs_hasmember_display, '#NULL#') || '|||' || -- hash from: hasMember/display
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.diagnosticreport_raw (
  diagnosticreport_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  diagrep_id VARCHAR,   -- id (VARCHAR)
  diagrep_encounter_ref VARCHAR,   -- encounter/reference (VARCHAR)
  diagrep_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  diagrep_partof_ref VARCHAR,   -- partOf/reference (VARCHAR)
  diagrep_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  diagrep_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  diagrep_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  diagrep_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  diagrep_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  diagrep_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  diagrep_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  diagrep_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  diagrep_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  diagrep_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  diagrep_result_ref VARCHAR,   -- result/reference (VARCHAR)
  diagrep_basedon_ref VARCHAR,   -- basedOn/reference (VARCHAR)
  diagrep_status VARCHAR,   -- status (VARCHAR)
  diagrep_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  diagrep_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  diagrep_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  diagrep_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  diagrep_category_text VARCHAR,   -- category/text (VARCHAR)
  diagrep_code_system VARCHAR,   -- code/coding/system (VARCHAR)
  diagrep_code_version VARCHAR,   -- code/coding/version (VARCHAR)
  diagrep_code_code VARCHAR,   -- code/coding/code (VARCHAR)
  diagrep_code_display VARCHAR,   -- code/coding/display (VARCHAR)
  diagrep_code_text VARCHAR,   -- code/text (VARCHAR)
  diagrep_effectivedatetime VARCHAR,   -- effectiveDateTime (VARCHAR)
  diagrep_issued VARCHAR,   -- issued (VARCHAR)
  diagrep_performer_ref VARCHAR,   -- performer/reference (VARCHAR)
  diagrep_performer_type VARCHAR,   -- performer/type (VARCHAR)
  diagrep_performer_identifier_use VARCHAR,   -- performer/identifier/use (VARCHAR)
  diagrep_performer_identifier_type_system VARCHAR,   -- performer/identifier/type/coding/system (VARCHAR)
  diagrep_performer_identifier_type_version VARCHAR,   -- performer/identifier/type/coding/version (VARCHAR)
  diagrep_performer_identifier_type_code VARCHAR,   -- performer/identifier/type/coding/code (VARCHAR)
  diagrep_performer_identifier_type_display VARCHAR,   -- performer/identifier/type/coding/display (VARCHAR)
  diagrep_performer_identifier_type_text VARCHAR,   -- performer/identifier/type/text (VARCHAR)
  diagrep_performer_display VARCHAR,   -- performer/display (VARCHAR)
  diagrep_conclusion VARCHAR,   -- conclusion (VARCHAR)
  diagrep_conclusioncode_system VARCHAR,   -- conclusionCode/coding/system (VARCHAR)
  diagrep_conclusioncode_version VARCHAR,   -- conclusionCode/coding/version (VARCHAR)
  diagrep_conclusioncode_code VARCHAR,   -- conclusionCode/coding/code (VARCHAR)
  diagrep_conclusioncode_display VARCHAR,   -- conclusionCode/coding/display (VARCHAR)
  diagrep_conclusioncode_text VARCHAR,   -- conclusionCode/text (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(diagrep_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(diagrep_encounter_ref, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(diagrep_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(diagrep_partof_ref, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(diagrep_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(diagrep_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(diagrep_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(diagrep_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(diagrep_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(diagrep_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(diagrep_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(diagrep_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(diagrep_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(diagrep_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(diagrep_result_ref, '#NULL#') || '|||' || -- hash from: result/reference
             COALESCE(diagrep_basedon_ref, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(diagrep_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(diagrep_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(diagrep_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(diagrep_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(diagrep_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(diagrep_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(diagrep_code_system, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(diagrep_code_version, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(diagrep_code_code, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(diagrep_code_display, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(diagrep_code_text, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(diagrep_effectivedatetime, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(diagrep_issued, '#NULL#') || '|||' || -- hash from: issued
             COALESCE(diagrep_performer_ref, '#NULL#') || '|||' || -- hash from: performer/reference
             COALESCE(diagrep_performer_type, '#NULL#') || '|||' || -- hash from: performer/type
             COALESCE(diagrep_performer_identifier_use, '#NULL#') || '|||' || -- hash from: performer/identifier/use
             COALESCE(diagrep_performer_identifier_type_system, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/system
             COALESCE(diagrep_performer_identifier_type_version, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/version
             COALESCE(diagrep_performer_identifier_type_code, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/code
             COALESCE(diagrep_performer_identifier_type_display, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/display
             COALESCE(diagrep_performer_identifier_type_text, '#NULL#') || '|||' || -- hash from: performer/identifier/type/text
             COALESCE(diagrep_performer_display, '#NULL#') || '|||' || -- hash from: performer/display
             COALESCE(diagrep_conclusion, '#NULL#') || '|||' || -- hash from: conclusion
             COALESCE(diagrep_conclusioncode_system, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/system
             COALESCE(diagrep_conclusioncode_version, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/version
             COALESCE(diagrep_conclusioncode_code, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/code
             COALESCE(diagrep_conclusioncode_display, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/display
             COALESCE(diagrep_conclusioncode_text, '#NULL#') || '|||' || -- hash from: conclusionCode/text
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.servicerequest_raw (
  servicerequest_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  servreq_id VARCHAR,   -- id (VARCHAR)
  servreq_encounter_ref VARCHAR,   -- encounter/reference (VARCHAR)
  servreq_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  servreq_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  servreq_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  servreq_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  servreq_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  servreq_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  servreq_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  servreq_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  servreq_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  servreq_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  servreq_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  servreq_basedon_ref VARCHAR,   -- basedOn/reference (VARCHAR)
  servreq_basedon_type VARCHAR,   -- basedOn/type (VARCHAR)
  servreq_basedon_identifier_use VARCHAR,   -- basedOn/identifier/use (VARCHAR)
  servreq_basedon_identifier_type_system VARCHAR,   -- basedOn/identifier/type/coding/system (VARCHAR)
  servreq_basedon_identifier_type_version VARCHAR,   -- basedOn/identifier/type/coding/version (VARCHAR)
  servreq_basedon_identifier_type_code VARCHAR,   -- basedOn/identifier/type/coding/code (VARCHAR)
  servreq_basedon_identifier_type_display VARCHAR,   -- basedOn/identifier/type/coding/display (VARCHAR)
  servreq_basedon_identifier_type_text VARCHAR,   -- basedOn/identifier/type/text (VARCHAR)
  servreq_basedon_display VARCHAR,   -- basedOn/display (VARCHAR)
  servreq_status VARCHAR,   -- status (VARCHAR)
  servreq_intent VARCHAR,   -- intent (VARCHAR)
  servreq_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  servreq_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  servreq_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  servreq_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  servreq_category_text VARCHAR,   -- category/text (VARCHAR)
  servreq_code_system VARCHAR,   -- code/coding/system (VARCHAR)
  servreq_code_version VARCHAR,   -- code/coding/version (VARCHAR)
  servreq_code_code VARCHAR,   -- code/coding/code (VARCHAR)
  servreq_code_display VARCHAR,   -- code/coding/display (VARCHAR)
  servreq_code_text VARCHAR,   -- code/text (VARCHAR)
  servreq_authoredon VARCHAR,   -- authoredOn (VARCHAR)
  servreq_requester_ref VARCHAR,   -- requester/reference (VARCHAR)
  servreq_requester_type VARCHAR,   -- requester/type (VARCHAR)
  servreq_requester_identifier_use VARCHAR,   -- requester/identifier/use (VARCHAR)
  servreq_requester_identifier_type_system VARCHAR,   -- requester/identifier/type/coding/system (VARCHAR)
  servreq_requester_identifier_type_version VARCHAR,   -- requester/identifier/type/coding/version (VARCHAR)
  servreq_requester_identifier_type_code VARCHAR,   -- requester/identifier/type/coding/code (VARCHAR)
  servreq_requester_identifier_type_display VARCHAR,   -- requester/identifier/type/coding/display (VARCHAR)
  servreq_requester_identifier_type_text VARCHAR,   -- requester/identifier/type/text (VARCHAR)
  servreq_requester_display VARCHAR,   -- requester/display (VARCHAR)
  servreq_performer_ref VARCHAR,   -- performer/reference (VARCHAR)
  servreq_performer_type VARCHAR,   -- performer/type (VARCHAR)
  servreq_performer_identifier_use VARCHAR,   -- performer/identifier/use (VARCHAR)
  servreq_performer_identifier_type_system VARCHAR,   -- performer/identifier/type/coding/system (VARCHAR)
  servreq_performer_identifier_type_version VARCHAR,   -- performer/identifier/type/coding/version (VARCHAR)
  servreq_performer_identifier_type_code VARCHAR,   -- performer/identifier/type/coding/code (VARCHAR)
  servreq_performer_identifier_type_display VARCHAR,   -- performer/identifier/type/coding/display (VARCHAR)
  servreq_performer_identifier_type_text VARCHAR,   -- performer/identifier/type/text (VARCHAR)
  servreq_performer_display VARCHAR,   -- performer/display (VARCHAR)
  servreq_locationcode_system VARCHAR,   -- locationCode/coding/system (VARCHAR)
  servreq_locationcode_version VARCHAR,   -- locationCode/coding/version (VARCHAR)
  servreq_locationcode_code VARCHAR,   -- locationCode/coding/code (VARCHAR)
  servreq_locationcode_display VARCHAR,   -- locationCode/coding/display (VARCHAR)
  servreq_locationcode_text VARCHAR,   -- locationCode/text (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(servreq_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(servreq_encounter_ref, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(servreq_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(servreq_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(servreq_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(servreq_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(servreq_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(servreq_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(servreq_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(servreq_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(servreq_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(servreq_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(servreq_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(servreq_basedon_ref, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(servreq_basedon_type, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(servreq_basedon_identifier_use, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(servreq_basedon_identifier_type_system, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(servreq_basedon_identifier_type_version, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(servreq_basedon_identifier_type_code, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(servreq_basedon_identifier_type_display, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(servreq_basedon_identifier_type_text, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(servreq_basedon_display, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(servreq_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(servreq_intent, '#NULL#') || '|||' || -- hash from: intent
             COALESCE(servreq_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(servreq_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(servreq_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(servreq_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(servreq_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(servreq_code_system, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(servreq_code_version, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(servreq_code_code, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(servreq_code_display, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(servreq_code_text, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(servreq_authoredon, '#NULL#') || '|||' || -- hash from: authoredOn
             COALESCE(servreq_requester_ref, '#NULL#') || '|||' || -- hash from: requester/reference
             COALESCE(servreq_requester_type, '#NULL#') || '|||' || -- hash from: requester/type
             COALESCE(servreq_requester_identifier_use, '#NULL#') || '|||' || -- hash from: requester/identifier/use
             COALESCE(servreq_requester_identifier_type_system, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/system
             COALESCE(servreq_requester_identifier_type_version, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/version
             COALESCE(servreq_requester_identifier_type_code, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/code
             COALESCE(servreq_requester_identifier_type_display, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/display
             COALESCE(servreq_requester_identifier_type_text, '#NULL#') || '|||' || -- hash from: requester/identifier/type/text
             COALESCE(servreq_requester_display, '#NULL#') || '|||' || -- hash from: requester/display
             COALESCE(servreq_performer_ref, '#NULL#') || '|||' || -- hash from: performer/reference
             COALESCE(servreq_performer_type, '#NULL#') || '|||' || -- hash from: performer/type
             COALESCE(servreq_performer_identifier_use, '#NULL#') || '|||' || -- hash from: performer/identifier/use
             COALESCE(servreq_performer_identifier_type_system, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/system
             COALESCE(servreq_performer_identifier_type_version, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/version
             COALESCE(servreq_performer_identifier_type_code, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/code
             COALESCE(servreq_performer_identifier_type_display, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/display
             COALESCE(servreq_performer_identifier_type_text, '#NULL#') || '|||' || -- hash from: performer/identifier/type/text
             COALESCE(servreq_performer_display, '#NULL#') || '|||' || -- hash from: performer/display
             COALESCE(servreq_locationcode_system, '#NULL#') || '|||' || -- hash from: locationCode/coding/system
             COALESCE(servreq_locationcode_version, '#NULL#') || '|||' || -- hash from: locationCode/coding/version
             COALESCE(servreq_locationcode_code, '#NULL#') || '|||' || -- hash from: locationCode/coding/code
             COALESCE(servreq_locationcode_display, '#NULL#') || '|||' || -- hash from: locationCode/coding/display
             COALESCE(servreq_locationcode_text, '#NULL#') || '|||' || -- hash from: locationCode/text
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.procedure_raw (
  procedure_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  proc_id VARCHAR,   -- id (VARCHAR)
  proc_encounter_ref VARCHAR,   -- encounter/reference (VARCHAR)
  proc_patient_ref VARCHAR,   -- subject/reference (VARCHAR)
  proc_partof_ref VARCHAR,   -- partOf/reference (VARCHAR)
  proc_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  proc_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  proc_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  proc_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  proc_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  proc_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  proc_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  proc_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  proc_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  proc_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  proc_basedon_ref VARCHAR,   -- basedOn/reference (VARCHAR)
  proc_basedon_type VARCHAR,   -- basedOn/type (VARCHAR)
  proc_basedon_identifier_use VARCHAR,   -- basedOn/identifier/use (VARCHAR)
  proc_basedon_identifier_type_system VARCHAR,   -- basedOn/identifier/type/coding/system (VARCHAR)
  proc_basedon_identifier_type_version VARCHAR,   -- basedOn/identifier/type/coding/version (VARCHAR)
  proc_basedon_identifier_type_code VARCHAR,   -- basedOn/identifier/type/coding/code (VARCHAR)
  proc_basedon_identifier_type_display VARCHAR,   -- basedOn/identifier/type/coding/display (VARCHAR)
  proc_basedon_identifier_type_text VARCHAR,   -- basedOn/identifier/type/text (VARCHAR)
  proc_basedon_display VARCHAR,   -- basedOn/display (VARCHAR)
  proc_status VARCHAR,   -- status (VARCHAR)
  proc_statusreason_system VARCHAR,   -- statusReason/coding/system (VARCHAR)
  proc_statusreason_version VARCHAR,   -- statusReason/coding/version (VARCHAR)
  proc_statusreason_code VARCHAR,   -- statusReason/coding/code (VARCHAR)
  proc_statusreason_display VARCHAR,   -- statusReason/coding/display (VARCHAR)
  proc_statusreason_text VARCHAR,   -- statusReason/text (VARCHAR)
  proc_category_system VARCHAR,   -- category/coding/system (VARCHAR)
  proc_category_version VARCHAR,   -- category/coding/version (VARCHAR)
  proc_category_code VARCHAR,   -- category/coding/code (VARCHAR)
  proc_category_display VARCHAR,   -- category/coding/display (VARCHAR)
  proc_category_text VARCHAR,   -- category/text (VARCHAR)
  proc_code_system VARCHAR,   -- code/coding/system (VARCHAR)
  proc_code_version VARCHAR,   -- code/coding/version (VARCHAR)
  proc_code_code VARCHAR,   -- code/coding/code (VARCHAR)
  proc_code_display VARCHAR,   -- code/coding/display (VARCHAR)
  proc_code_text VARCHAR,   -- code/text (VARCHAR)
  proc_performeddatetime VARCHAR,   -- performedDateTime (VARCHAR)
  proc_performedperiod_start VARCHAR,   -- performedPeriod/start (VARCHAR)
  proc_performedperiod_end VARCHAR,   -- performedPeriod/end (VARCHAR)
  proc_reasoncode_system VARCHAR,   -- reasonCode/coding/system (VARCHAR)
  proc_reasoncode_version VARCHAR,   -- reasonCode/coding/version (VARCHAR)
  proc_reasoncode_code VARCHAR,   -- reasonCode/coding/code (VARCHAR)
  proc_reasoncode_display VARCHAR,   -- reasonCode/coding/display (VARCHAR)
  proc_reasoncode_text VARCHAR,   -- reasonCode/text (VARCHAR)
  proc_reasonreference_ref VARCHAR,   -- reasonReference/reference (VARCHAR)
  proc_reasonreference_type VARCHAR,   -- reasonReference/type (VARCHAR)
  proc_reasonreference_identifier_use VARCHAR,   -- reasonReference/identifier/use (VARCHAR)
  proc_reasonreference_identifier_type_system VARCHAR,   -- reasonReference/identifier/type/coding/system (VARCHAR)
  proc_reasonreference_identifier_type_version VARCHAR,   -- reasonReference/identifier/type/coding/version (VARCHAR)
  proc_reasonreference_identifier_type_code VARCHAR,   -- reasonReference/identifier/type/coding/code (VARCHAR)
  proc_reasonreference_identifier_type_display VARCHAR,   -- reasonReference/identifier/type/coding/display (VARCHAR)
  proc_reasonreference_identifier_type_text VARCHAR,   -- reasonReference/identifier/type/text (VARCHAR)
  proc_reasonreference_display VARCHAR,   -- reasonReference/display (VARCHAR)
  proc_note_authorstring VARCHAR,   -- note/authorString (VARCHAR)
  proc_note_authorreference_ref VARCHAR,   -- note/authorReference/reference (VARCHAR)
  proc_note_authorreference_type VARCHAR,   -- note/authorReference/type (VARCHAR)
  proc_note_authorreference_identifier_use VARCHAR,   -- note/authorReference/identifier/use (VARCHAR)
  proc_note_authorreference_identifier_type_system VARCHAR,   -- note/authorReference/identifier/type/coding/system (VARCHAR)
  proc_note_authorreference_identifier_type_version VARCHAR,   -- note/authorReference/identifier/type/coding/version (VARCHAR)
  proc_note_authorreference_identifier_type_code VARCHAR,   -- note/authorReference/identifier/type/coding/code (VARCHAR)
  proc_note_authorreference_identifier_type_display VARCHAR,   -- note/authorReference/identifier/type/coding/display (VARCHAR)
  proc_note_authorreference_identifier_type_text VARCHAR,   -- note/authorReference/identifier/type/text (VARCHAR)
  proc_note_authorreference_display VARCHAR,   -- note/authorReference/display (VARCHAR)
  proc_note_time VARCHAR,   -- note/time (VARCHAR)
  proc_note_text VARCHAR,   -- note/text (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(proc_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(proc_encounter_ref, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(proc_patient_ref, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(proc_partof_ref, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(proc_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(proc_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(proc_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(proc_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(proc_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(proc_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(proc_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(proc_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(proc_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(proc_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(proc_basedon_ref, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(proc_basedon_type, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(proc_basedon_identifier_use, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(proc_basedon_identifier_type_system, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(proc_basedon_identifier_type_version, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(proc_basedon_identifier_type_code, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(proc_basedon_identifier_type_display, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(proc_basedon_identifier_type_text, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(proc_basedon_display, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(proc_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(proc_statusreason_system, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(proc_statusreason_version, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(proc_statusreason_code, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(proc_statusreason_display, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(proc_statusreason_text, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(proc_category_system, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(proc_category_version, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(proc_category_code, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(proc_category_display, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(proc_category_text, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(proc_code_system, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(proc_code_version, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(proc_code_code, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(proc_code_display, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(proc_code_text, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(proc_performeddatetime, '#NULL#') || '|||' || -- hash from: performedDateTime
             COALESCE(proc_performedperiod_start, '#NULL#') || '|||' || -- hash from: performedPeriod/start
             COALESCE(proc_performedperiod_end, '#NULL#') || '|||' || -- hash from: performedPeriod/end
             COALESCE(proc_reasoncode_system, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(proc_reasoncode_version, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(proc_reasoncode_code, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(proc_reasoncode_display, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(proc_reasoncode_text, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(proc_reasonreference_ref, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(proc_reasonreference_type, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(proc_reasonreference_identifier_use, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(proc_reasonreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(proc_reasonreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(proc_reasonreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(proc_reasonreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(proc_reasonreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(proc_reasonreference_display, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(proc_note_authorstring, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(proc_note_authorreference_ref, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(proc_note_authorreference_type, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(proc_note_authorreference_identifier_use, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(proc_note_authorreference_identifier_type_system, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(proc_note_authorreference_identifier_type_version, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(proc_note_authorreference_identifier_type_code, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(proc_note_authorreference_identifier_type_display, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(proc_note_authorreference_identifier_type_text, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(proc_note_authorreference_display, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(proc_note_time, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(proc_note_text, '#NULL#') || '|||' || -- hash from: note/text
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.consent_raw (
  consent_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  cons_id VARCHAR,   -- id (VARCHAR)
  cons_patient_ref VARCHAR,   -- patient/reference (VARCHAR)
  cons_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  cons_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  cons_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  cons_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  cons_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  cons_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  cons_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  cons_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  cons_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  cons_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  cons_status VARCHAR,   -- status (VARCHAR)
  cons_scope_system VARCHAR,   -- scope/coding/system (VARCHAR)
  cons_scope_version VARCHAR,   -- scope/coding/version (VARCHAR)
  cons_scope_code VARCHAR,   -- scope/coding/code (VARCHAR)
  cons_scope_display VARCHAR,   -- scope/coding/display (VARCHAR)
  cons_scope_text VARCHAR,   -- scope/text (VARCHAR)
  cons_datetime VARCHAR,   -- dateTime (VARCHAR)
  cons_provision_type VARCHAR,   -- provision/type (VARCHAR)
  cons_provision_period_start VARCHAR,   -- provision/period/start (VARCHAR)
  cons_provision_period_end VARCHAR,   -- provision/period/end (VARCHAR)
  cons_provision_actor_role_system VARCHAR,   -- provision/actor/role/coding/system (VARCHAR)
  cons_provision_actor_role_version VARCHAR,   -- provision/actor/role/coding/version (VARCHAR)
  cons_provision_actor_role_code VARCHAR,   -- provision/actor/role/coding/code (VARCHAR)
  cons_provision_actor_role_display VARCHAR,   -- provision/actor/role/coding/display (VARCHAR)
  cons_provision_actor_role_text VARCHAR,   -- provision/actor/role/text (VARCHAR)
  cons_provision_code_system VARCHAR,   -- provision/code/coding/system (VARCHAR)
  cons_provision_code_version VARCHAR,   -- provision/code/coding/version (VARCHAR)
  cons_provision_code_code VARCHAR,   -- provision/code/coding/code (VARCHAR)
  cons_provision_code_display VARCHAR,   -- provision/code/coding/display (VARCHAR)
  cons_provision_code_text VARCHAR,   -- provision/code/text (VARCHAR)
  cons_provision_dataperiod_start VARCHAR,   -- provision/dataPeriod/start (VARCHAR)
  cons_provision_dataperiod_end VARCHAR,   -- provision/dataPeriod/end (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(cons_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(cons_patient_ref, '#NULL#') || '|||' || -- hash from: patient/reference
             COALESCE(cons_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(cons_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(cons_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(cons_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(cons_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(cons_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(cons_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(cons_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(cons_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(cons_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(cons_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(cons_scope_system, '#NULL#') || '|||' || -- hash from: scope/coding/system
             COALESCE(cons_scope_version, '#NULL#') || '|||' || -- hash from: scope/coding/version
             COALESCE(cons_scope_code, '#NULL#') || '|||' || -- hash from: scope/coding/code
             COALESCE(cons_scope_display, '#NULL#') || '|||' || -- hash from: scope/coding/display
             COALESCE(cons_scope_text, '#NULL#') || '|||' || -- hash from: scope/text
             COALESCE(cons_datetime, '#NULL#') || '|||' || -- hash from: dateTime
             COALESCE(cons_provision_type, '#NULL#') || '|||' || -- hash from: provision/type
             COALESCE(cons_provision_period_start, '#NULL#') || '|||' || -- hash from: provision/period/start
             COALESCE(cons_provision_period_end, '#NULL#') || '|||' || -- hash from: provision/period/end
             COALESCE(cons_provision_actor_role_system, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/system
             COALESCE(cons_provision_actor_role_version, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/version
             COALESCE(cons_provision_actor_role_code, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/code
             COALESCE(cons_provision_actor_role_display, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/display
             COALESCE(cons_provision_actor_role_text, '#NULL#') || '|||' || -- hash from: provision/actor/role/text
             COALESCE(cons_provision_code_system, '#NULL#') || '|||' || -- hash from: provision/code/coding/system
             COALESCE(cons_provision_code_version, '#NULL#') || '|||' || -- hash from: provision/code/coding/version
             COALESCE(cons_provision_code_code, '#NULL#') || '|||' || -- hash from: provision/code/coding/code
             COALESCE(cons_provision_code_display, '#NULL#') || '|||' || -- hash from: provision/code/coding/display
             COALESCE(cons_provision_code_text, '#NULL#') || '|||' || -- hash from: provision/code/text
             COALESCE(cons_provision_dataperiod_start, '#NULL#') || '|||' || -- hash from: provision/dataPeriod/start
             COALESCE(cons_provision_dataperiod_end, '#NULL#') || '|||' || -- hash from: provision/dataPeriod/end
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.location_raw (
  location_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  loc_id VARCHAR,   -- id (VARCHAR)
  loc_identifier_use VARCHAR,   -- identifier/use (VARCHAR)
  loc_identifier_type_system VARCHAR,   -- identifier/type/coding/system (VARCHAR)
  loc_identifier_type_version VARCHAR,   -- identifier/type/coding/version (VARCHAR)
  loc_identifier_type_code VARCHAR,   -- identifier/type/coding/code (VARCHAR)
  loc_identifier_type_display VARCHAR,   -- identifier/type/coding/display (VARCHAR)
  loc_identifier_type_text VARCHAR,   -- identifier/type/text (VARCHAR)
  loc_identifier_system VARCHAR,   -- identifier/system (VARCHAR)
  loc_identifier_value VARCHAR,   -- identifier/value (VARCHAR)
  loc_identifier_start VARCHAR,   -- identifier/start (VARCHAR)
  loc_identifier_end VARCHAR,   -- identifier/end (VARCHAR)
  loc_status VARCHAR,   -- status (VARCHAR)
  loc_name VARCHAR,   -- name (VARCHAR)
  loc_description VARCHAR,   -- description (VARCHAR)
  loc_alias VARCHAR,   -- alias (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(loc_id, '#NULL#') || '|||' || -- hash from: id
             COALESCE(loc_identifier_use, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(loc_identifier_type_system, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(loc_identifier_type_version, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(loc_identifier_type_code, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(loc_identifier_type_display, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(loc_identifier_type_text, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(loc_identifier_system, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(loc_identifier_value, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(loc_identifier_start, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(loc_identifier_end, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(loc_status, '#NULL#') || '|||' || -- hash from: status
             COALESCE(loc_name, '#NULL#') || '|||' || -- hash from: name
             COALESCE(loc_description, '#NULL#') || '|||' || -- hash from: description
             COALESCE(loc_alias, '#NULL#') || '|||' || -- hash from: alias
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.pids_per_ward_raw (
  pids_per_ward_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  ward_name VARCHAR,   -- ward_name (VARCHAR)
  patient_id VARCHAR,   -- patient_id (VARCHAR)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             COALESCE(ward_name, '#NULL#') || '|||' || -- hash from: ward_name
             COALESCE(patient_id, '#NULL#') || '|||' || -- hash from: patient_id
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);


------------------------------------------------------
-- SQL Role / Trigger in Schema "cds2db_in" --
------------------------------------------------------


-- Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.encounter_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter_raw TO db_user; -- Additional authorizations for testing

-- Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.patient_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient_raw TO db_user; -- Additional authorizations for testing

-- Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.condition_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition_raw TO db_user; -- Additional authorizations for testing

-- Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medication_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication_raw TO db_user; -- Additional authorizations for testing

-- Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medicationrequest_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest_raw TO db_user; -- Additional authorizations for testing

-- Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medicationadministration_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration_raw TO db_user; -- Additional authorizations for testing

-- Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medicationstatement_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement_raw TO db_user; -- Additional authorizations for testing

-- Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.observation_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation_raw TO db_user; -- Additional authorizations for testing

-- Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.diagnosticreport_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport_raw TO db_user; -- Additional authorizations for testing

-- Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.servicerequest_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest_raw TO db_user; -- Additional authorizations for testing

-- Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.procedure_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure_raw TO db_user; -- Additional authorizations for testing

-- Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.consent_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent_raw TO db_user; -- Additional authorizations for testing

-- Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.location_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location_raw TO db_user; -- Additional authorizations for testing

-- Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.pids_per_ward_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward_raw TO db_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "cds2db_in" --
------------------------------------------------------
-- Output off
\o /dev/null

COMMENT ON COLUMN cds2db_in.encounter_raw.encounter_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_class_system IS 'class/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_class_version IS 'class/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_class_code IS 'class/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_class_display IS 'class/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_type_system IS 'type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_type_version IS 'type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_type_code IS 'type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_type_display IS 'type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_type_text IS 'type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_servicetype_system IS 'serviceType/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_servicetype_version IS 'serviceType/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_servicetype_code IS 'serviceType/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_servicetype_display IS 'serviceType/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_servicetype_text IS 'serviceType/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_period_start IS 'period/start (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_period_end IS 'period/end (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_condition_ref IS 'diagnosis/condition/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_use_system IS 'diagnosis/use/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_use_version IS 'diagnosis/use/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_use_code IS 'diagnosis/use/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_use_display IS 'diagnosis/use/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_use_text IS 'diagnosis/use/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_diagnosis_rank IS 'diagnosis/rank (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_admitsource_system IS 'hospitalization/admitSource/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_admitsource_version IS 'hospitalization/admitSource/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_admitsource_code IS 'hospitalization/admitSource/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_admitsource_display IS 'hospitalization/admitSource/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_admitsource_text IS 'hospitalization/admitSource/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_system IS 'hospitalization/dischargeDisposition/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_version IS 'hospitalization/dischargeDisposition/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_code IS 'hospitalization/dischargeDisposition/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_display IS 'hospitalization/dischargeDisposition/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_text IS 'hospitalization/dischargeDisposition/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_ref IS 'location/location/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_type IS 'location/location/type (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_identifier_use IS 'location/location/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_identifier_type_system IS 'location/location/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_identifier_type_version IS 'location/location/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_identifier_type_code IS 'location/location/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_identifier_type_display IS 'location/location/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_identifier_type_text IS 'location/location/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_display IS 'location/location/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_status IS 'location/status (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_physicaltype_system IS 'location/physicalType/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_physicaltype_version IS 'location/physicalType/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_physicaltype_code IS 'location/physicalType/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_physicaltype_display IS 'location/physicalType/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_location_physicaltype_text IS 'location/physicalType/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_ref IS 'serviceProvider/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_type IS 'serviceProvider/type (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_identifier_use IS 'serviceProvider/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_system IS 'serviceProvider/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_version IS 'serviceProvider/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_code IS 'serviceProvider/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_display IS 'serviceProvider/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_text IS 'serviceProvider/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.enc_serviceprovider_display IS 'serviceProvider/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.encounter_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.encounter_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.encounter_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.encounter_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.patient_raw.patient_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_text IS 'name/text (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_family IS 'name/family (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_given IS 'name/given (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_gender IS 'gender (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_birthdate IS 'birthDate (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_address_postalcode IS 'address/postalCode (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.patient_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.patient_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.patient_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.patient_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.condition_raw.condition_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.condition_raw.con_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_clinicalstatus_system IS 'clinicalStatus/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_clinicalstatus_version IS 'clinicalStatus/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_clinicalstatus_code IS 'clinicalStatus/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_clinicalstatus_display IS 'clinicalStatus/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_clinicalstatus_text IS 'clinicalStatus/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_verificationstatus_system IS 'verificationStatus/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_verificationstatus_version IS 'verificationStatus/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_verificationstatus_code IS 'verificationStatus/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_verificationstatus_display IS 'verificationStatus/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_verificationstatus_text IS 'verificationStatus/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_severity_system IS 'severity/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_severity_version IS 'severity/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_severity_code IS 'severity/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_severity_display IS 'severity/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_severity_text IS 'severity/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_bodysite_system IS 'bodySite/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_bodysite_version IS 'bodySite/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_bodysite_code IS 'bodySite/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_bodysite_display IS 'bodySite/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_bodysite_text IS 'bodySite/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_onsetperiod_start IS 'onsetPeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_onsetperiod_end IS 'onsetPeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_onsetdatetime IS 'onsetDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementdatetime IS 'abatementDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementage_value IS 'abatementAge/value (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementage_comparator IS 'abatementAge/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementage_unit IS 'abatementAge/unit (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementage_system IS 'abatementAge/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementage_code IS 'abatementAge/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementperiod_start IS 'abatementPeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementperiod_end IS 'abatementPeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_low_value IS 'abatementRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_low_unit IS 'abatementRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_low_system IS 'abatementRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_low_code IS 'abatementRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_high_value IS 'abatementRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_high_unit IS 'abatementRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_high_system IS 'abatementRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementrange_high_code IS 'abatementRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_abatementstring IS 'abatementString (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recordeddate IS 'recordedDate (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_ref IS 'recorder/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_type IS 'recorder/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_identifier_use IS 'recorder/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_identifier_type_system IS 'recorder/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_identifier_type_version IS 'recorder/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_identifier_type_code IS 'recorder/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_identifier_type_display IS 'recorder/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_identifier_type_text IS 'recorder/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_recorder_display IS 'recorder/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_ref IS 'asserter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_type IS 'asserter/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_identifier_use IS 'asserter/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_identifier_type_system IS 'asserter/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_identifier_type_version IS 'asserter/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_identifier_type_code IS 'asserter/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_identifier_type_display IS 'asserter/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_identifier_type_text IS 'asserter/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_asserter_display IS 'asserter/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_summary_system IS 'stage/summary/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_summary_version IS 'stage/summary/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_summary_code IS 'stage/summary/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_summary_display IS 'stage/summary/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_summary_text IS 'stage/summary/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_ref IS 'stage/assessment/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_type IS 'stage/assessment/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_identifier_use IS 'stage/assessment/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_identifier_type_system IS 'stage/assessment/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_identifier_type_version IS 'stage/assessment/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_identifier_type_code IS 'stage/assessment/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_identifier_type_display IS 'stage/assessment/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_identifier_type_text IS 'stage/assessment/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_assessment_display IS 'stage/assessment/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_type_system IS 'stage/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_type_version IS 'stage/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_type_code IS 'stage/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_type_display IS 'stage/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_stage_type_text IS 'stage/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_time IS 'note/time (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.con_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.condition_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.condition_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.condition_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.condition_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medication_raw.medication_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medication_raw.med_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_form_system IS 'form/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_form_version IS 'form/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_form_code IS 'form/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_form_display IS 'form/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_form_text IS 'form/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_numerator_value IS 'amount/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_numerator_comparator IS 'amount/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_numerator_unit IS 'amount/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_numerator_system IS 'amount/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_numerator_code IS 'amount/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_denominator_value IS 'amount/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_denominator_comparator IS 'amount/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_denominator_unit IS 'amount/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_denominator_system IS 'amount/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_amount_denominator_code IS 'amount/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_numerator_value IS 'ingredient/strength/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_numerator_comparator IS 'ingredient/strength/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_numerator_unit IS 'ingredient/strength/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_numerator_system IS 'ingredient/strength/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_numerator_code IS 'ingredient/strength/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_denominator_value IS 'ingredient/strength/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_denominator_comparator IS 'ingredient/strength/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_denominator_unit IS 'ingredient/strength/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_denominator_system IS 'ingredient/strength/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_strength_denominator_code IS 'ingredient/strength/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_system IS 'ingredient/itemCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_version IS 'ingredient/itemCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_code IS 'ingredient/itemCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_display IS 'ingredient/itemCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_text IS 'ingredient/itemCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_ref IS 'ingredient/itemReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_type IS 'ingredient/itemReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_identifier_use IS 'ingredient/itemReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_system IS 'ingredient/itemReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_version IS 'ingredient/itemReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_code IS 'ingredient/itemReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_display IS 'ingredient/itemReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_text IS 'ingredient/itemReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_itemreference_display IS 'ingredient/itemReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.med_ingredient_isactive IS 'ingredient/isActive (varchar)';
COMMENT ON COLUMN cds2db_in.medication_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medication_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medication_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medication_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medication_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medicationrequest_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_medicationreference_ref IS 'medicationReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_intend IS 'intend (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_priority IS 'priority (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedboolean IS 'reportedBoolean (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_ref IS 'reportedReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_type IS 'reportedReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_use IS 'reportedReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_system IS 'reportedReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_version IS 'reportedReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_code IS 'reportedReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_display IS 'reportedReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_text IS 'reportedReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reportedreference_display IS 'reportedReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_ref IS 'supportingInformation/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_type IS 'supportingInformation/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_use IS 'supportingInformation/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_system IS 'supportingInformation/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_version IS 'supportingInformation/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_code IS 'supportingInformation/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_display IS 'supportingInformation/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_text IS 'supportingInformation/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_supportinginformation_display IS 'supportingInformation/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_authoredon IS 'authoredOn (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_ref IS 'requester/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_type IS 'requester/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_identifier_use IS 'requester/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_system IS 'requester/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_version IS 'requester/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_code IS 'requester/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_display IS 'requester/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_text IS 'requester/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_requester_display IS 'requester/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_time IS 'note/time (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_sequence IS 'dosageInstruction/sequence (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_text IS 'dosageInstruction/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_system IS 'dosageInstruction/additionalInstruction/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_version IS 'dosageInstruction/additionalInstruction/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_code IS 'dosageInstruction/additionalInstruction/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_display IS 'dosageInstruction/additionalInstruction/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_text IS 'dosageInstruction/additionalInstruction/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_patientinstruction IS 'dosageInstruction/patientInstruction (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_event IS 'dosageInstruction/timing/event (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_value IS 'dosageInstruction/timing/repeat/boundsDuration/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_comparator IS 'dosageInstruction/timing/repeat/boundsDuration/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_unit IS 'dosageInstruction/timing/repeat/boundsDuration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_system IS 'dosageInstruction/timing/repeat/boundsDuration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_code IS 'dosageInstruction/timing/repeat/boundsDuration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_value IS 'dosageInstruction/timing/repeat/boundsRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_unit IS 'dosageInstruction/timing/repeat/boundsRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_system IS 'dosageInstruction/timing/repeat/boundsRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_code IS 'dosageInstruction/timing/repeat/boundsRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_value IS 'dosageInstruction/timing/repeat/boundsRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_unit IS 'dosageInstruction/timing/repeat/boundsRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_system IS 'dosageInstruction/timing/repeat/boundsRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_code IS 'dosageInstruction/timing/repeat/boundsRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsperiod_start IS 'dosageInstruction/timing/repeat/boundsPeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsperiod_end IS 'dosageInstruction/timing/repeat/boundsPeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_count IS 'dosageInstruction/timing/repeat/count (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_countmax IS 'dosageInstruction/timing/repeat/countMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_duration IS 'dosageInstruction/timing/repeat/duration (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_durationmax IS 'dosageInstruction/timing/repeat/durationMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_durationunit IS 'dosageInstruction/timing/repeat/durationUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_frequency IS 'dosageInstruction/timing/repeat/frequency (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_frequencymax IS 'dosageInstruction/timing/repeat/frequencyMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_period IS 'dosageInstruction/timing/repeat/period (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_periodmax IS 'dosageInstruction/timing/repeat/periodMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_periodunit IS 'dosageInstruction/timing/repeat/periodUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_dayofweek IS 'dosageInstruction/timing/repeat/dayOfWeek (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_timeofday IS 'dosageInstruction/timing/repeat/timeOfDay (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_when IS 'dosageInstruction/timing/repeat/when (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_offset IS 'dosageInstruction/timing/repeat/offset (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_system IS 'dosageInstruction/timing/code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_version IS 'dosageInstruction/timing/code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_code IS 'dosageInstruction/timing/code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_display IS 'dosageInstruction/timing/code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_text IS 'dosageInstruction/timing/code/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededboolean IS 'dosageInstruction/asNeededBoolean (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_system IS 'dosageInstruction/asNeededCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_version IS 'dosageInstruction/asNeededCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_code IS 'dosageInstruction/asNeededCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_display IS 'dosageInstruction/asNeededCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_text IS 'dosageInstruction/asNeededCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_system IS 'dosageInstruction/site/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_version IS 'dosageInstruction/site/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_code IS 'dosageInstruction/site/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_display IS 'dosageInstruction/site/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_text IS 'dosageInstruction/site/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_system IS 'dosageInstruction/route/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_version IS 'dosageInstruction/route/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_code IS 'dosageInstruction/route/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_display IS 'dosageInstruction/route/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_text IS 'dosageInstruction/route/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_system IS 'dosageInstruction/method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_version IS 'dosageInstruction/method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_code IS 'dosageInstruction/method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_display IS 'dosageInstruction/method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_text IS 'dosageInstruction/method/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_system IS 'dosageInstruction/doseAndRate/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_version IS 'dosageInstruction/doseAndRate/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_code IS 'dosageInstruction/doseAndRate/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_display IS 'dosageInstruction/doseAndRate/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_text IS 'dosageInstruction/doseAndRate/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_value IS 'dosageInstruction/doseAndRate/doseRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_unit IS 'dosageInstruction/doseAndRate/doseRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_system IS 'dosageInstruction/doseAndRate/doseRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_code IS 'dosageInstruction/doseAndRate/doseRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_value IS 'dosageInstruction/doseAndRate/doseRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_unit IS 'dosageInstruction/doseAndRate/doseRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_system IS 'dosageInstruction/doseAndRate/doseRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_code IS 'dosageInstruction/doseAndRate/doseRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_value IS 'dosageInstruction/doseAndRate/doseQuantity/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_comparator IS 'dosageInstruction/doseAndRate/doseQuantity/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_unit IS 'dosageInstruction/doseAndRate/doseQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_system IS 'dosageInstruction/doseAndRate/doseQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_code IS 'dosageInstruction/doseAndRate/doseQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_value IS 'dosageInstruction/doseAndRate/rateRatio/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator IS 'dosageInstruction/doseAndRate/rateRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_unit IS 'dosageInstruction/doseAndRate/rateRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_system IS 'dosageInstruction/doseAndRate/rateRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_code IS 'dosageInstruction/doseAndRate/rateRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_value IS 'dosageInstruction/doseAndRate/rateRatio/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator IS 'dosageInstruction/doseAndRate/rateRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_unit IS 'dosageInstruction/doseAndRate/rateRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_system IS 'dosageInstruction/doseAndRate/rateRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_code IS 'dosageInstruction/doseAndRate/rateRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_value IS 'dosageInstruction/doseAndRate/rateRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_unit IS 'dosageInstruction/doseAndRate/rateRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_system IS 'dosageInstruction/doseAndRate/rateRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_code IS 'dosageInstruction/doseAndRate/rateRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_value IS 'dosageInstruction/doseAndRate/rateRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_unit IS 'dosageInstruction/doseAndRate/rateRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_system IS 'dosageInstruction/doseAndRate/rateRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_code IS 'dosageInstruction/doseAndRate/rateRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_value IS 'dosageInstruction/doseAndRate/rateQuantity/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_unit IS 'dosageInstruction/doseAndRate/rateQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_system IS 'dosageInstruction/doseAndRate/rateQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_code IS 'dosageInstruction/doseAndRate/rateQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_value IS 'dosageInstruction/maxDosePerPeriod/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_comparator IS 'dosageInstruction/maxDosePerPeriod/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_unit IS 'dosageInstruction/maxDosePerPeriod/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_system IS 'dosageInstruction/maxDosePerPeriod/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_code IS 'dosageInstruction/maxDosePerPeriod/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_value IS 'dosageInstruction/maxDosePerPeriod/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_comparator IS 'dosageInstruction/maxDosePerPeriod/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_unit IS 'dosageInstruction/maxDosePerPeriod/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_system IS 'dosageInstruction/maxDosePerPeriod/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_code IS 'dosageInstruction/maxDosePerPeriod/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_value IS 'dosageInstruction/maxDosePerAdministration/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_unit IS 'dosageInstruction/maxDosePerAdministration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_system IS 'dosageInstruction/maxDosePerAdministration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_code IS 'dosageInstruction/maxDosePerAdministration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_value IS 'dosageInstruction/maxDosePerLifetime/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_unit IS 'dosageInstruction/maxDosePerLifetime/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_system IS 'dosageInstruction/maxDosePerLifetime/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_code IS 'dosageInstruction/maxDosePerLifetime/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_substitution_reason_system IS 'substitution/reason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_substitution_reason_version IS 'substitution/reason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_substitution_reason_code IS 'substitution/reason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_substitution_reason_display IS 'substitution/reason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.medreq_substitution_reason_text IS 'substitution/reason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medicationrequest_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medicationadministration_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_encounter_ref IS 'context/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_medicationreference_ref IS 'medicationReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_ref IS 'supportingInformation/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_type IS 'supportingInformation/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_use IS 'supportingInformation/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_system IS 'supportingInformation/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_version IS 'supportingInformation/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_code IS 'supportingInformation/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_display IS 'supportingInformation/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_text IS 'supportingInformation/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_supportinginformation_display IS 'supportingInformation/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_effectivedatetime IS 'effectiveDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_effectiveperiod_start IS 'effectivePeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_effectiveperiod_end IS 'effectivePeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_performer_function_system IS 'performer/function/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_performer_function_version IS 'performer/function/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_performer_function_code IS 'performer/function/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_performer_function_display IS 'performer/function/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_performer_function_text IS 'performer/function/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_request_ref IS 'request/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_time IS 'note/time (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_text IS 'dosage/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_site_system IS 'dosage/site/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_site_version IS 'dosage/site/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_site_code IS 'dosage/site/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_site_display IS 'dosage/site/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_site_text IS 'dosage/site/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_route_system IS 'dosage/route/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_route_version IS 'dosage/route/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_route_code IS 'dosage/route/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_route_display IS 'dosage/route/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_route_text IS 'dosage/route/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_method_system IS 'dosage/method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_method_version IS 'dosage/method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_method_code IS 'dosage/method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_method_display IS 'dosage/method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_method_text IS 'dosage/method/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_dose_value IS 'dosage/dose/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_dose_unit IS 'dosage/dose/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_dose_system IS 'dosage/dose/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_dose_code IS 'dosage/dose/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_value IS 'dosage/rateRatio/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_comparator IS 'dosage/rateRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_unit IS 'dosage/rateRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_system IS 'dosage/rateRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_code IS 'dosage/rateRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_value IS 'dosage/rateRatio/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_comparator IS 'dosage/rateRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_unit IS 'dosage/rateRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_system IS 'dosage/rateRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_code IS 'dosage/rateRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_value IS 'dosage/rateQuantity/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_unit IS 'dosage/rateQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_system IS 'dosage/rateQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_code IS 'dosage/rateQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medicationadministration_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medicationstatement_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_encounter_ref IS 'context/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_medicationreference_ref IS 'medicationReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_effectivedatetime IS 'effectiveDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_effectiveperiod_start IS 'effectivePeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_effectiveperiod_end IS 'effectivePeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dateasserted IS 'dateAsserted (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_ref IS 'informationSource/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_type IS 'informationSource/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_use IS 'informationSource/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_system IS 'informationSource/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_version IS 'informationSource/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_code IS 'informationSource/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_display IS 'informationSource/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_text IS 'informationSource/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_informationsource_display IS 'informationSource/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_ref IS 'derivedFrom/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_type IS 'derivedFrom/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_use IS 'derivedFrom/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_system IS 'derivedFrom/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_version IS 'derivedFrom/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_code IS 'derivedFrom/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_display IS 'derivedFrom/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_text IS 'derivedFrom/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_derivedfrom_display IS 'derivedFrom/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_time IS 'note/time (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_sequence IS 'dosage/sequence (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_text IS 'dosage/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_system IS 'dosage/additionalInstruction/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_version IS 'dosage/additionalInstruction/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_code IS 'dosage/additionalInstruction/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_display IS 'dosage/additionalInstruction/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_text IS 'dosage/additionalInstruction/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_patientinstruction IS 'dosage/patientInstruction (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_event IS 'dosage/timing/event (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_value IS 'dosage/timing/repeat/boundsDuration/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_comparator IS 'dosage/timing/repeat/boundsDuration/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_unit IS 'dosage/timing/repeat/boundsDuration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_system IS 'dosage/timing/repeat/boundsDuration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_code IS 'dosage/timing/repeat/boundsDuration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_value IS 'dosage/timing/repeat/boundsRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_unit IS 'dosage/timing/repeat/boundsRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_system IS 'dosage/timing/repeat/boundsRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_code IS 'dosage/timing/repeat/boundsRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_value IS 'dosage/timing/repeat/boundsRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_unit IS 'dosage/timing/repeat/boundsRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_system IS 'dosage/timing/repeat/boundsRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_code IS 'dosage/timing/repeat/boundsRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsperiod_start IS 'dosage/timing/repeat/boundsPeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsperiod_end IS 'dosage/timing/repeat/boundsPeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_count IS 'dosage/timing/repeat/count (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_countmax IS 'dosage/timing/repeat/countMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_duration IS 'dosage/timing/repeat/duration (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_durationmax IS 'dosage/timing/repeat/durationMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_durationunit IS 'dosage/timing/repeat/durationUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_frequency IS 'dosage/timing/repeat/frequency (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_frequencymax IS 'dosage/timing/repeat/frequencyMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_period IS 'dosage/timing/repeat/period (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_periodmax IS 'dosage/timing/repeat/periodMax (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_periodunit IS 'dosage/timing/repeat/periodUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_dayofweek IS 'dosage/timing/repeat/dayOfWeek (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_timeofday IS 'dosage/timing/repeat/timeOfDay (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_when IS 'dosage/timing/repeat/when (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_offset IS 'dosage/timing/repeat/offset (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_system IS 'dosage/timing/code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_version IS 'dosage/timing/code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_code IS 'dosage/timing/code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_display IS 'dosage/timing/code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_text IS 'dosage/timing/code/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_asneededboolean IS 'dosage/asNeededBoolean (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_system IS 'dosage/asNeededCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_version IS 'dosage/asNeededCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_code IS 'dosage/asNeededCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_display IS 'dosage/asNeededCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_text IS 'dosage/asNeededCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_site_system IS 'dosage/site/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_site_version IS 'dosage/site/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_site_code IS 'dosage/site/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_site_display IS 'dosage/site/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_site_text IS 'dosage/site/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_route_system IS 'dosage/route/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_route_version IS 'dosage/route/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_route_code IS 'dosage/route/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_route_display IS 'dosage/route/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_route_text IS 'dosage/route/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_method_system IS 'dosage/method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_method_version IS 'dosage/method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_method_code IS 'dosage/method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_method_display IS 'dosage/method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_method_text IS 'dosage/method/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_system IS 'dosage/doseAndRate/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_version IS 'dosage/doseAndRate/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_code IS 'dosage/doseAndRate/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_display IS 'dosage/doseAndRate/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_text IS 'dosage/doseAndRate/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_value IS 'dosage/doseAndRate/doseRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_unit IS 'dosage/doseAndRate/doseRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_system IS 'dosage/doseAndRate/doseRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_code IS 'dosage/doseAndRate/doseRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_value IS 'dosage/doseAndRate/doseRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_unit IS 'dosage/doseAndRate/doseRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_system IS 'dosage/doseAndRate/doseRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_code IS 'dosage/doseAndRate/doseRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_value IS 'dosage/doseAndRate/doseQuantity/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_comparator IS 'dosage/doseAndRate/doseQuantity/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_unit IS 'dosage/doseAndRate/doseQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_system IS 'dosage/doseAndRate/doseQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_code IS 'dosage/doseAndRate/doseQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_value IS 'dosage/doseAndRate/rateRatio/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_comparator IS 'dosage/doseAndRate/rateRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_unit IS 'dosage/doseAndRate/rateRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_system IS 'dosage/doseAndRate/rateRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_code IS 'dosage/doseAndRate/rateRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_value IS 'dosage/doseAndRate/rateRatio/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_comparator IS 'dosage/doseAndRate/rateRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_unit IS 'dosage/doseAndRate/rateRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_system IS 'dosage/doseAndRate/rateRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_code IS 'dosage/doseAndRate/rateRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_value IS 'dosage/doseAndRate/rateRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_unit IS 'dosage/doseAndRate/rateRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_system IS 'dosage/doseAndRate/rateRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_code IS 'dosage/doseAndRate/rateRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_value IS 'dosage/doseAndRate/rateRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_unit IS 'dosage/doseAndRate/rateRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_system IS 'dosage/doseAndRate/rateRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_code IS 'dosage/doseAndRate/rateRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_value IS 'dosage/doseAndRate/rateQuantity/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_unit IS 'dosage/doseAndRate/rateQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_system IS 'dosage/doseAndRate/rateQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_code IS 'dosage/doseAndRate/rateQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_value IS 'dosage/maxDosePerPeriod/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_comparator IS 'dosage/maxDosePerPeriod/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_unit IS 'dosage/maxDosePerPeriod/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_system IS 'dosage/maxDosePerPeriod/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_code IS 'dosage/maxDosePerPeriod/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_value IS 'dosage/maxDosePerPeriod/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_comparator IS 'dosage/maxDosePerPeriod/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_unit IS 'dosage/maxDosePerPeriod/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_system IS 'dosage/maxDosePerPeriod/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_code IS 'dosage/maxDosePerPeriod/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_value IS 'dosage/maxDosePerAdministration/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_unit IS 'dosage/maxDosePerAdministration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_system IS 'dosage/maxDosePerAdministration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_code IS 'dosage/maxDosePerAdministration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_value IS 'dosage/maxDosePerLifetime/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_unit IS 'dosage/maxDosePerLifetime/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_system IS 'dosage/maxDosePerLifetime/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_code IS 'dosage/maxDosePerLifetime/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medicationstatement_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.observation_raw.observation_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_effectivedatetime IS 'effectiveDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_issued IS 'issued (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_low_value IS 'valueRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_low_unit IS 'valueRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_low_system IS 'valueRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_low_code IS 'valueRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_high_value IS 'valueRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_high_unit IS 'valueRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_high_system IS 'valueRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuerange_high_code IS 'valueRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_numerator_value IS 'valueRatio/numerator/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_numerator_comparator IS 'valueRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_numerator_unit IS 'valueRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_numerator_system IS 'valueRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_numerator_code IS 'valueRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_denominator_value IS 'valueRatio/denominator/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_denominator_comparator IS 'valueRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_denominator_unit IS 'valueRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_denominator_system IS 'valueRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valueratio_denominator_code IS 'valueRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuequantity_value IS 'valueQuantity/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuequantity_comparator IS 'valueQuantity/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuequantity_unit IS 'valueQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuequantity_system IS 'valueQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuequantity_code IS 'valueQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuecodableconcept_system IS 'valueCodableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuecodableconcept_version IS 'valueCodableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuecodableconcept_code IS 'valueCodableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuecodableconcept_display IS 'valueCodableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_valuecodableconcept_text IS 'valueCodableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_dataabsentreason_system IS 'dataAbsentReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_dataabsentreason_version IS 'dataAbsentReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_dataabsentreason_code IS 'dataAbsentReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_dataabsentreason_display IS 'dataAbsentReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_dataabsentreason_text IS 'dataAbsentReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_time IS 'note/time (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_method_system IS 'method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_method_version IS 'method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_method_code IS 'method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_method_display IS 'method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_method_text IS 'method/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_ref IS 'performer/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_type IS 'performer/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_identifier_use IS 'performer/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_performer_display IS 'performer/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_low_value IS 'referenceRange/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_low_unit IS 'referenceRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_low_system IS 'referenceRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_low_code IS 'referenceRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_high_value IS 'referenceRange/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_high_unit IS 'referenceRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_high_system IS 'referenceRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_high_code IS 'referenceRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_type_system IS 'referenceRange/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_type_version IS 'referenceRange/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_type_code IS 'referenceRange/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_type_display IS 'referenceRange/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_type_text IS 'referenceRange/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_appliesto_system IS 'referenceRange/appliesTo/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_appliesto_version IS 'referenceRange/appliesTo/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_appliesto_code IS 'referenceRange/appliesTo/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_appliesto_display IS 'referenceRange/appliesTo/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_appliesto_text IS 'referenceRange/appliesTo/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_low_value IS 'referenceRange/age/low/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_low_unit IS 'referenceRange/age/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_low_system IS 'referenceRange/age/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_low_code IS 'referenceRange/age/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_high_value IS 'referenceRange/age/high/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_high_unit IS 'referenceRange/age/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_high_system IS 'referenceRange/age/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_age_high_code IS 'referenceRange/age/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_referencerange_text IS 'referenceRange/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_ref IS 'hasMember/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_type IS 'hasMember/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_identifier_use IS 'hasMember/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_identifier_type_system IS 'hasMember/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_identifier_type_version IS 'hasMember/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_identifier_type_code IS 'hasMember/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_identifier_type_display IS 'hasMember/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_identifier_type_text IS 'hasMember/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.obs_hasmember_display IS 'hasMember/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.observation_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.observation_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.observation_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.observation_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagnosticreport_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_result_ref IS 'result/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_effectivedatetime IS 'effectiveDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_issued IS 'issued (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_ref IS 'performer/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_type IS 'performer/type (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_use IS 'performer/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_performer_display IS 'performer/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_conclusion IS 'conclusion (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_system IS 'conclusionCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_version IS 'conclusionCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_code IS 'conclusionCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_display IS 'conclusionCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_text IS 'conclusionCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.diagnosticreport_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.servicerequest_raw.servicerequest_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_intent IS 'intent (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_authoredon IS 'authoredOn (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_ref IS 'requester/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_type IS 'requester/type (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_identifier_use IS 'requester/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_identifier_type_system IS 'requester/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_identifier_type_version IS 'requester/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_identifier_type_code IS 'requester/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_identifier_type_display IS 'requester/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_identifier_type_text IS 'requester/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_requester_display IS 'requester/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_ref IS 'performer/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_type IS 'performer/type (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_identifier_use IS 'performer/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_performer_display IS 'performer/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_locationcode_system IS 'locationCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_locationcode_version IS 'locationCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_locationcode_code IS 'locationCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_locationcode_display IS 'locationCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.servreq_locationcode_text IS 'locationCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.servicerequest_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.procedure_raw.procedure_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_performeddatetime IS 'performedDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_performedperiod_start IS 'performedPeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_performedperiod_end IS 'performedPeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_time IS 'note/time (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.proc_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.procedure_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.procedure_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.procedure_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.procedure_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.consent_raw.consent_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_patient_ref IS 'patient/reference (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_scope_system IS 'scope/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_scope_version IS 'scope/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_scope_code IS 'scope/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_scope_display IS 'scope/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_scope_text IS 'scope/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_datetime IS 'dateTime (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_type IS 'provision/type (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_period_start IS 'provision/period/start (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_period_end IS 'provision/period/end (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_actor_role_system IS 'provision/actor/role/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_actor_role_version IS 'provision/actor/role/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_actor_role_code IS 'provision/actor/role/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_actor_role_display IS 'provision/actor/role/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_actor_role_text IS 'provision/actor/role/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_code_system IS 'provision/code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_code_version IS 'provision/code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_code_code IS 'provision/code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_code_display IS 'provision/code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_code_text IS 'provision/code/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_dataperiod_start IS 'provision/dataPeriod/start (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.cons_provision_dataperiod_end IS 'provision/dataPeriod/end (varchar)';
COMMENT ON COLUMN cds2db_in.consent_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.consent_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.consent_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.consent_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.consent_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.location_raw.location_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.location_raw.loc_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_name IS 'name (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_description IS 'description (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.loc_alias IS 'alias (varchar)';
COMMENT ON COLUMN cds2db_in.location_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.location_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.location_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.location_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.location_raw.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.pids_per_ward_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.ward_name IS 'ward_name (varchar)';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.patient_id IS 'patient_id (varchar)';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.pids_per_ward_raw.last_processing_nr IS 'Last processing number of the data record';


-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "cds2db_in" --
------------------------------------------------------

------------------------- Index for cds2db_in - encounter_raw ---------------------------------

-- Index idx_cds2db_in_encounter_raw_input_dt for Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_raw_input_dt
ON cds2db_in.encounter_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_encounter_raw_input_pnr for Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_raw_input_pnr
ON cds2db_in.encounter_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_encounter_raw_last_dt for Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_raw_last_dt
ON cds2db_in.encounter_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_encounter_raw_last_dt for Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_raw_last_pnr
ON cds2db_in.encounter_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_encounter_raw_hash for Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_raw_hash
ON cds2db_in.encounter_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - patient_raw ---------------------------------

-- Index idx_cds2db_in_patient_raw_input_dt for Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_raw_input_dt
ON cds2db_in.patient_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_patient_raw_input_pnr for Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_raw_input_pnr
ON cds2db_in.patient_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_patient_raw_last_dt for Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_raw_last_dt
ON cds2db_in.patient_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_patient_raw_last_dt for Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_raw_last_pnr
ON cds2db_in.patient_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_patient_raw_hash for Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_raw_hash
ON cds2db_in.patient_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - condition_raw ---------------------------------

-- Index idx_cds2db_in_condition_raw_input_dt for Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_raw_input_dt
ON cds2db_in.condition_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_condition_raw_input_pnr for Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_raw_input_pnr
ON cds2db_in.condition_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_condition_raw_last_dt for Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_raw_last_dt
ON cds2db_in.condition_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_condition_raw_last_dt for Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_raw_last_pnr
ON cds2db_in.condition_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_condition_raw_hash for Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_raw_hash
ON cds2db_in.condition_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medication_raw ---------------------------------

-- Index idx_cds2db_in_medication_raw_input_dt for Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_raw_input_dt
ON cds2db_in.medication_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medication_raw_input_pnr for Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_raw_input_pnr
ON cds2db_in.medication_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medication_raw_last_dt for Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_raw_last_dt
ON cds2db_in.medication_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medication_raw_last_dt for Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_raw_last_pnr
ON cds2db_in.medication_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medication_raw_hash for Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_raw_hash
ON cds2db_in.medication_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medicationrequest_raw ---------------------------------

-- Index idx_cds2db_in_medicationrequest_raw_input_dt for Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_raw_input_dt
ON cds2db_in.medicationrequest_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medicationrequest_raw_input_pnr for Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_raw_input_pnr
ON cds2db_in.medicationrequest_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medicationrequest_raw_last_dt for Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_raw_last_dt
ON cds2db_in.medicationrequest_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medicationrequest_raw_last_dt for Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_raw_last_pnr
ON cds2db_in.medicationrequest_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medicationrequest_raw_hash for Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_raw_hash
ON cds2db_in.medicationrequest_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medicationadministration_raw ---------------------------------

-- Index idx_cds2db_in_medicationadministration_raw_input_dt for Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_raw_input_dt
ON cds2db_in.medicationadministration_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medicationadministration_raw_input_pnr for Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_raw_input_pnr
ON cds2db_in.medicationadministration_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medicationadministration_raw_last_dt for Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_raw_last_dt
ON cds2db_in.medicationadministration_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medicationadministration_raw_last_dt for Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_raw_last_pnr
ON cds2db_in.medicationadministration_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medicationadministration_raw_hash for Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_raw_hash
ON cds2db_in.medicationadministration_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medicationstatement_raw ---------------------------------

-- Index idx_cds2db_in_medicationstatement_raw_input_dt for Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_raw_input_dt
ON cds2db_in.medicationstatement_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medicationstatement_raw_input_pnr for Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_raw_input_pnr
ON cds2db_in.medicationstatement_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medicationstatement_raw_last_dt for Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_raw_last_dt
ON cds2db_in.medicationstatement_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medicationstatement_raw_last_dt for Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_raw_last_pnr
ON cds2db_in.medicationstatement_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medicationstatement_raw_hash for Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_raw_hash
ON cds2db_in.medicationstatement_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - observation_raw ---------------------------------

-- Index idx_cds2db_in_observation_raw_input_dt for Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_raw_input_dt
ON cds2db_in.observation_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_observation_raw_input_pnr for Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_raw_input_pnr
ON cds2db_in.observation_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_observation_raw_last_dt for Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_raw_last_dt
ON cds2db_in.observation_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_observation_raw_last_dt for Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_raw_last_pnr
ON cds2db_in.observation_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_observation_raw_hash for Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_raw_hash
ON cds2db_in.observation_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - diagnosticreport_raw ---------------------------------

-- Index idx_cds2db_in_diagnosticreport_raw_input_dt for Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_raw_input_dt
ON cds2db_in.diagnosticreport_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_diagnosticreport_raw_input_pnr for Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_raw_input_pnr
ON cds2db_in.diagnosticreport_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_diagnosticreport_raw_last_dt for Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_raw_last_dt
ON cds2db_in.diagnosticreport_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_diagnosticreport_raw_last_dt for Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_raw_last_pnr
ON cds2db_in.diagnosticreport_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_diagnosticreport_raw_hash for Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_raw_hash
ON cds2db_in.diagnosticreport_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - servicerequest_raw ---------------------------------

-- Index idx_cds2db_in_servicerequest_raw_input_dt for Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_raw_input_dt
ON cds2db_in.servicerequest_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_servicerequest_raw_input_pnr for Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_raw_input_pnr
ON cds2db_in.servicerequest_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_servicerequest_raw_last_dt for Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_raw_last_dt
ON cds2db_in.servicerequest_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_servicerequest_raw_last_dt for Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_raw_last_pnr
ON cds2db_in.servicerequest_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_servicerequest_raw_hash for Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_raw_hash
ON cds2db_in.servicerequest_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - procedure_raw ---------------------------------

-- Index idx_cds2db_in_procedure_raw_input_dt for Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_raw_input_dt
ON cds2db_in.procedure_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_procedure_raw_input_pnr for Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_raw_input_pnr
ON cds2db_in.procedure_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_procedure_raw_last_dt for Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_raw_last_dt
ON cds2db_in.procedure_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_procedure_raw_last_dt for Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_raw_last_pnr
ON cds2db_in.procedure_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_procedure_raw_hash for Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_raw_hash
ON cds2db_in.procedure_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - consent_raw ---------------------------------

-- Index idx_cds2db_in_consent_raw_input_dt for Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_raw_input_dt
ON cds2db_in.consent_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_consent_raw_input_pnr for Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_raw_input_pnr
ON cds2db_in.consent_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_consent_raw_last_dt for Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_raw_last_dt
ON cds2db_in.consent_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_consent_raw_last_dt for Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_raw_last_pnr
ON cds2db_in.consent_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_consent_raw_hash for Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_raw_hash
ON cds2db_in.consent_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - location_raw ---------------------------------

-- Index idx_cds2db_in_location_raw_input_dt for Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_raw_input_dt
ON cds2db_in.location_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_location_raw_input_pnr for Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_raw_input_pnr
ON cds2db_in.location_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_location_raw_last_dt for Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_raw_last_dt
ON cds2db_in.location_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_location_raw_last_dt for Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_raw_last_pnr
ON cds2db_in.location_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_location_raw_hash for Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_raw_hash
ON cds2db_in.location_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - pids_per_ward_raw ---------------------------------

-- Index idx_cds2db_in_pids_per_ward_raw_input_dt for Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_raw_input_dt
ON cds2db_in.pids_per_ward_raw (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_pids_per_ward_raw_input_pnr for Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_raw_input_pnr
ON cds2db_in.pids_per_ward_raw (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_pids_per_ward_raw_last_dt for Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_raw_last_dt
ON cds2db_in.pids_per_ward_raw (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_pids_per_ward_raw_last_dt for Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_raw_last_pnr
ON cds2db_in.pids_per_ward_raw (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_pids_per_ward_raw_hash for Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_raw_hash
ON cds2db_in.pids_per_ward_raw (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);


