-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-01-13 09:38:21
-- Rights definition file size        : 15240 Byte
--
-- Create SQL Tables in Schema "cds2db_in"
-- Create time: 2025-02-05 01:33:34
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  14_cre_table_typ_cds2db_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_in
-- TAGS:  TYPED
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  15_get_last_processing_nr_typed.sql
-- COPY_FUNC_TEMPLATE:  template_get_last_pnr_typed.sql
-- COPY_FUNC_NAME:  get_last_processing_nr_typed
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "cds2db_in" --
-----------------------------------------------------

-- Table "encounter" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.encounter (
  encounter_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  encounter_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  enc_id varchar,   -- id (varchar)
  enc_patient_ref varchar,   -- subject/reference (varchar)
  enc_partof_ref varchar,   -- partOf/reference (varchar)
  enc_identifier_use varchar,   -- identifier/use (varchar)
  enc_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  enc_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  enc_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  enc_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  enc_identifier_type_text varchar,   -- identifier/type/text (varchar)
  enc_identifier_system varchar,   -- identifier/system (varchar)
  enc_identifier_value varchar,   -- identifier/value (varchar)
  enc_identifier_start timestamp,   -- identifier/start (timestamp)
  enc_identifier_end timestamp,   -- identifier/end (timestamp)
  enc_status varchar,   -- status (varchar)
  enc_class_system varchar,   -- class/system (varchar)
  enc_class_version varchar,   -- class/version (varchar)
  enc_class_code varchar,   -- class/code (varchar)
  enc_class_display varchar,   -- class/display (varchar)
  enc_type_system varchar,   -- type/coding/system (varchar)
  enc_type_version varchar,   -- type/coding/version (varchar)
  enc_type_code varchar,   -- type/coding/code (varchar)
  enc_type_display varchar,   -- type/coding/display (varchar)
  enc_type_text varchar,   -- type/text (varchar)
  enc_servicetype_system varchar,   -- serviceType/coding/system (varchar)
  enc_servicetype_version varchar,   -- serviceType/coding/version (varchar)
  enc_servicetype_code varchar,   -- serviceType/coding/code (varchar)
  enc_servicetype_display varchar,   -- serviceType/coding/display (varchar)
  enc_servicetype_text varchar,   -- serviceType/text (varchar)
  enc_period_start timestamp,   -- period/start (timestamp)
  enc_period_end timestamp,   -- period/end (timestamp)
  enc_diagnosis_condition_ref varchar,   -- diagnosis/condition/reference (varchar)
  enc_diagnosis_use_system varchar,   -- diagnosis/use/coding/system (varchar)
  enc_diagnosis_use_version varchar,   -- diagnosis/use/coding/version (varchar)
  enc_diagnosis_use_code varchar,   -- diagnosis/use/coding/code (varchar)
  enc_diagnosis_use_display varchar,   -- diagnosis/use/coding/display (varchar)
  enc_diagnosis_use_text varchar,   -- diagnosis/use/text (varchar)
  enc_diagnosis_rank int,   -- diagnosis/rank (int)
  enc_hospitalization_admitsource_system varchar,   -- hospitalization/admitSource/coding/system (varchar)
  enc_hospitalization_admitsource_version varchar,   -- hospitalization/admitSource/coding/version (varchar)
  enc_hospitalization_admitsource_code varchar,   -- hospitalization/admitSource/coding/code (varchar)
  enc_hospitalization_admitsource_display varchar,   -- hospitalization/admitSource/coding/display (varchar)
  enc_hospitalization_admitsource_text varchar,   -- hospitalization/admitSource/text (varchar)
  enc_hospitalization_dischargedisposition_system varchar,   -- hospitalization/dischargeDisposition/coding/system (varchar)
  enc_hospitalization_dischargedisposition_version varchar,   -- hospitalization/dischargeDisposition/coding/version (varchar)
  enc_hospitalization_dischargedisposition_code varchar,   -- hospitalization/dischargeDisposition/coding/code (varchar)
  enc_hospitalization_dischargedisposition_display varchar,   -- hospitalization/dischargeDisposition/coding/display (varchar)
  enc_hospitalization_dischargedisposition_text varchar,   -- hospitalization/dischargeDisposition/text (varchar)
  enc_location_ref varchar,   -- location/location/reference (varchar)
  enc_location_type varchar,   -- location/location/type (varchar)
  enc_location_identifier_use varchar,   -- location/location/identifier/use (varchar)
  enc_location_identifier_type_system varchar,   -- location/location/identifier/type/coding/system (varchar)
  enc_location_identifier_type_version varchar,   -- location/location/identifier/type/coding/version (varchar)
  enc_location_identifier_type_code varchar,   -- location/location/identifier/type/coding/code (varchar)
  enc_location_identifier_type_display varchar,   -- location/location/identifier/type/coding/display (varchar)
  enc_location_identifier_type_text varchar,   -- location/location/identifier/type/text (varchar)
  enc_location_display varchar,   -- location/location/display (varchar)
  enc_location_status varchar,   -- location/status (varchar)
  enc_location_physicaltype_system varchar,   -- location/physicalType/coding/system (varchar)
  enc_location_physicaltype_version varchar,   -- location/physicalType/coding/version (varchar)
  enc_location_physicaltype_code varchar,   -- location/physicalType/coding/code (varchar)
  enc_location_physicaltype_display varchar,   -- location/physicalType/coding/display (varchar)
  enc_location_physicaltype_text varchar,   -- location/physicalType/text (varchar)
  enc_serviceprovider_ref varchar,   -- serviceProvider/reference (varchar)
  enc_serviceprovider_type varchar,   -- serviceProvider/type (varchar)
  enc_serviceprovider_identifier_use varchar,   -- serviceProvider/identifier/use (varchar)
  enc_serviceprovider_identifier_type_system varchar,   -- serviceProvider/identifier/type/coding/system (varchar)
  enc_serviceprovider_identifier_type_version varchar,   -- serviceProvider/identifier/type/coding/version (varchar)
  enc_serviceprovider_identifier_type_code varchar,   -- serviceProvider/identifier/type/coding/code (varchar)
  enc_serviceprovider_identifier_type_display varchar,   -- serviceProvider/identifier/type/coding/display (varchar)
  enc_serviceprovider_identifier_type_text varchar,   -- serviceProvider/identifier/type/text (varchar)
  enc_serviceprovider_display varchar,   -- serviceProvider/display (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(enc_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(enc_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(enc_partof_ref::TEXT, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(enc_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(enc_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(enc_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(enc_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(enc_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(enc_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(enc_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(enc_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(enc_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(enc_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(enc_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(enc_class_system::TEXT, '#NULL#') || '|||' || -- hash from: class/system
             COALESCE(enc_class_version::TEXT, '#NULL#') || '|||' || -- hash from: class/version
             COALESCE(enc_class_code::TEXT, '#NULL#') || '|||' || -- hash from: class/code
             COALESCE(enc_class_display::TEXT, '#NULL#') || '|||' || -- hash from: class/display
             COALESCE(enc_type_system::TEXT, '#NULL#') || '|||' || -- hash from: type/coding/system
             COALESCE(enc_type_version::TEXT, '#NULL#') || '|||' || -- hash from: type/coding/version
             COALESCE(enc_type_code::TEXT, '#NULL#') || '|||' || -- hash from: type/coding/code
             COALESCE(enc_type_display::TEXT, '#NULL#') || '|||' || -- hash from: type/coding/display
             COALESCE(enc_type_text::TEXT, '#NULL#') || '|||' || -- hash from: type/text
             COALESCE(enc_servicetype_system::TEXT, '#NULL#') || '|||' || -- hash from: serviceType/coding/system
             COALESCE(enc_servicetype_version::TEXT, '#NULL#') || '|||' || -- hash from: serviceType/coding/version
             COALESCE(enc_servicetype_code::TEXT, '#NULL#') || '|||' || -- hash from: serviceType/coding/code
             COALESCE(enc_servicetype_display::TEXT, '#NULL#') || '|||' || -- hash from: serviceType/coding/display
             COALESCE(enc_servicetype_text::TEXT, '#NULL#') || '|||' || -- hash from: serviceType/text
             COALESCE(enc_period_start::TEXT, '#NULL#') || '|||' || -- hash from: period/start
             COALESCE(enc_period_end::TEXT, '#NULL#') || '|||' || -- hash from: period/end
             COALESCE(enc_diagnosis_condition_ref::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/condition/reference
             COALESCE(enc_diagnosis_use_system::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/system
             COALESCE(enc_diagnosis_use_version::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/version
             COALESCE(enc_diagnosis_use_code::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/code
             COALESCE(enc_diagnosis_use_display::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/use/coding/display
             COALESCE(enc_diagnosis_use_text::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/use/text
             COALESCE(enc_diagnosis_rank::TEXT, '#NULL#') || '|||' || -- hash from: diagnosis/rank
             COALESCE(enc_hospitalization_admitsource_system::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/system
             COALESCE(enc_hospitalization_admitsource_version::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/version
             COALESCE(enc_hospitalization_admitsource_code::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/code
             COALESCE(enc_hospitalization_admitsource_display::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/coding/display
             COALESCE(enc_hospitalization_admitsource_text::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/admitSource/text
             COALESCE(enc_hospitalization_dischargedisposition_system::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/system
             COALESCE(enc_hospitalization_dischargedisposition_version::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/version
             COALESCE(enc_hospitalization_dischargedisposition_code::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/code
             COALESCE(enc_hospitalization_dischargedisposition_display::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/coding/display
             COALESCE(enc_hospitalization_dischargedisposition_text::TEXT, '#NULL#') || '|||' || -- hash from: hospitalization/dischargeDisposition/text
             COALESCE(enc_location_ref::TEXT, '#NULL#') || '|||' || -- hash from: location/location/reference
             COALESCE(enc_location_type::TEXT, '#NULL#') || '|||' || -- hash from: location/location/type
             COALESCE(enc_location_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: location/location/identifier/use
             COALESCE(enc_location_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/system
             COALESCE(enc_location_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/version
             COALESCE(enc_location_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/code
             COALESCE(enc_location_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/coding/display
             COALESCE(enc_location_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: location/location/identifier/type/text
             COALESCE(enc_location_display::TEXT, '#NULL#') || '|||' || -- hash from: location/location/display
             COALESCE(enc_location_status::TEXT, '#NULL#') || '|||' || -- hash from: location/status
             COALESCE(enc_location_physicaltype_system::TEXT, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/system
             COALESCE(enc_location_physicaltype_version::TEXT, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/version
             COALESCE(enc_location_physicaltype_code::TEXT, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/code
             COALESCE(enc_location_physicaltype_display::TEXT, '#NULL#') || '|||' || -- hash from: location/physicalType/coding/display
             COALESCE(enc_location_physicaltype_text::TEXT, '#NULL#') || '|||' || -- hash from: location/physicalType/text
             COALESCE(enc_serviceprovider_ref::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/reference
             COALESCE(enc_serviceprovider_type::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/type
             COALESCE(enc_serviceprovider_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/use
             COALESCE(enc_serviceprovider_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/system
             COALESCE(enc_serviceprovider_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/version
             COALESCE(enc_serviceprovider_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/code
             COALESCE(enc_serviceprovider_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/coding/display
             COALESCE(enc_serviceprovider_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/identifier/type/text
             COALESCE(enc_serviceprovider_display::TEXT, '#NULL#') || '|||' || -- hash from: serviceProvider/display
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "patient" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.patient (
  patient_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  patient_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  pat_id varchar,   -- id (varchar)
  pat_identifier_use varchar,   -- identifier/use (varchar)
  pat_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  pat_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  pat_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  pat_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  pat_identifier_type_text varchar,   -- identifier/type/text (varchar)
  pat_identifier_system varchar,   -- identifier/system (varchar)
  pat_identifier_value varchar,   -- identifier/value (varchar)
  pat_identifier_start timestamp,   -- identifier/start (timestamp)
  pat_identifier_end timestamp,   -- identifier/end (timestamp)
  pat_name_text varchar,   -- name/text (varchar)
  pat_name_family varchar,   -- name/family (varchar)
  pat_name_given varchar,   -- name/given (varchar)
  pat_gender varchar,   -- gender (varchar)
  pat_birthdate date,   -- birthDate (date)
  pat_address_postalcode varchar,   -- address/postalCode (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(pat_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(pat_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(pat_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(pat_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(pat_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(pat_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(pat_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(pat_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(pat_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(pat_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(pat_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(pat_name_text::TEXT, '#NULL#') || '|||' || -- hash from: name/text
             COALESCE(pat_name_family::TEXT, '#NULL#') || '|||' || -- hash from: name/family
             COALESCE(pat_name_given::TEXT, '#NULL#') || '|||' || -- hash from: name/given
             COALESCE(pat_gender::TEXT, '#NULL#') || '|||' || -- hash from: gender
             COALESCE(pat_birthdate::TEXT, '#NULL#') || '|||' || -- hash from: birthDate
             COALESCE(pat_address_postalcode::TEXT, '#NULL#') || '|||' || -- hash from: address/postalCode
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "condition" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.condition (
  condition_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  condition_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  con_id varchar,   -- id (varchar)
  con_encounter_ref varchar,   -- encounter/reference (varchar)
  con_patient_ref varchar,   -- subject/reference (varchar)
  con_identifier_use varchar,   -- identifier/use (varchar)
  con_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  con_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  con_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  con_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  con_identifier_type_text varchar,   -- identifier/type/text (varchar)
  con_identifier_system varchar,   -- identifier/system (varchar)
  con_identifier_value varchar,   -- identifier/value (varchar)
  con_identifier_start timestamp,   -- identifier/start (timestamp)
  con_identifier_end timestamp,   -- identifier/end (timestamp)
  con_clinicalstatus_system varchar,   -- clinicalStatus/coding/system (varchar)
  con_clinicalstatus_version varchar,   -- clinicalStatus/coding/version (varchar)
  con_clinicalstatus_code varchar,   -- clinicalStatus/coding/code (varchar)
  con_clinicalstatus_display varchar,   -- clinicalStatus/coding/display (varchar)
  con_clinicalstatus_text varchar,   -- clinicalStatus/text (varchar)
  con_verificationstatus_system varchar,   -- verificationStatus/coding/system (varchar)
  con_verificationstatus_version varchar,   -- verificationStatus/coding/version (varchar)
  con_verificationstatus_code varchar,   -- verificationStatus/coding/code (varchar)
  con_verificationstatus_display varchar,   -- verificationStatus/coding/display (varchar)
  con_verificationstatus_text varchar,   -- verificationStatus/text (varchar)
  con_category_system varchar,   -- category/coding/system (varchar)
  con_category_version varchar,   -- category/coding/version (varchar)
  con_category_code varchar,   -- category/coding/code (varchar)
  con_category_display varchar,   -- category/coding/display (varchar)
  con_category_text varchar,   -- category/text (varchar)
  con_severity_system varchar,   -- severity/coding/system (varchar)
  con_severity_version varchar,   -- severity/coding/version (varchar)
  con_severity_code varchar,   -- severity/coding/code (varchar)
  con_severity_display varchar,   -- severity/coding/display (varchar)
  con_severity_text varchar,   -- severity/text (varchar)
  con_code_system varchar,   -- code/coding/system (varchar)
  con_code_version varchar,   -- code/coding/version (varchar)
  con_code_code varchar,   -- code/coding/code (varchar)
  con_code_display varchar,   -- code/coding/display (varchar)
  con_code_text varchar,   -- code/text (varchar)
  con_bodysite_system varchar,   -- bodySite/coding/system (varchar)
  con_bodysite_version varchar,   -- bodySite/coding/version (varchar)
  con_bodysite_code varchar,   -- bodySite/coding/code (varchar)
  con_bodysite_display varchar,   -- bodySite/coding/display (varchar)
  con_bodysite_text varchar,   -- bodySite/text (varchar)
  con_onsetperiod_start timestamp,   -- onsetPeriod/start (timestamp)
  con_onsetperiod_end timestamp,   -- onsetPeriod/end (timestamp)
  con_onsetdatetime timestamp,   -- onsetDateTime (timestamp)
  con_abatementdatetime timestamp,   -- abatementDateTime (timestamp)
  con_abatementage_value double precision,   -- abatementAge/value (double precision)
  con_abatementage_comparator varchar,   -- abatementAge/comparator (varchar)
  con_abatementage_unit varchar,   -- abatementAge/unit (varchar)
  con_abatementage_system varchar,   -- abatementAge/system (varchar)
  con_abatementage_code varchar,   -- abatementAge/code (varchar)
  con_abatementperiod_start timestamp,   -- abatementPeriod/start (timestamp)
  con_abatementperiod_end timestamp,   -- abatementPeriod/end (timestamp)
  con_abatementrange_low_value double precision,   -- abatementRange/low/value (double precision)
  con_abatementrange_low_unit varchar,   -- abatementRange/low/unit (varchar)
  con_abatementrange_low_system varchar,   -- abatementRange/low/system (varchar)
  con_abatementrange_low_code varchar,   -- abatementRange/low/code (varchar)
  con_abatementrange_high_value double precision,   -- abatementRange/high/value (double precision)
  con_abatementrange_high_unit varchar,   -- abatementRange/high/unit (varchar)
  con_abatementrange_high_system varchar,   -- abatementRange/high/system (varchar)
  con_abatementrange_high_code varchar,   -- abatementRange/high/code (varchar)
  con_abatementstring varchar,   -- abatementString (varchar)
  con_recordeddate timestamp,   -- recordedDate (timestamp)
  con_recorder_ref varchar,   -- recorder/reference (varchar)
  con_recorder_type varchar,   -- recorder/type (varchar)
  con_recorder_identifier_use varchar,   -- recorder/identifier/use (varchar)
  con_recorder_identifier_type_system varchar,   -- recorder/identifier/type/coding/system (varchar)
  con_recorder_identifier_type_version varchar,   -- recorder/identifier/type/coding/version (varchar)
  con_recorder_identifier_type_code varchar,   -- recorder/identifier/type/coding/code (varchar)
  con_recorder_identifier_type_display varchar,   -- recorder/identifier/type/coding/display (varchar)
  con_recorder_identifier_type_text varchar,   -- recorder/identifier/type/text (varchar)
  con_recorder_display varchar,   -- recorder/display (varchar)
  con_asserter_ref varchar,   -- asserter/reference (varchar)
  con_asserter_type varchar,   -- asserter/type (varchar)
  con_asserter_identifier_use varchar,   -- asserter/identifier/use (varchar)
  con_asserter_identifier_type_system varchar,   -- asserter/identifier/type/coding/system (varchar)
  con_asserter_identifier_type_version varchar,   -- asserter/identifier/type/coding/version (varchar)
  con_asserter_identifier_type_code varchar,   -- asserter/identifier/type/coding/code (varchar)
  con_asserter_identifier_type_display varchar,   -- asserter/identifier/type/coding/display (varchar)
  con_asserter_identifier_type_text varchar,   -- asserter/identifier/type/text (varchar)
  con_asserter_display varchar,   -- asserter/display (varchar)
  con_stage_summary_system varchar,   -- stage/summary/coding/system (varchar)
  con_stage_summary_version varchar,   -- stage/summary/coding/version (varchar)
  con_stage_summary_code varchar,   -- stage/summary/coding/code (varchar)
  con_stage_summary_display varchar,   -- stage/summary/coding/display (varchar)
  con_stage_summary_text varchar,   -- stage/summary/text (varchar)
  con_stage_assessment_ref varchar,   -- stage/assessment/reference (varchar)
  con_stage_assessment_type varchar,   -- stage/assessment/type (varchar)
  con_stage_assessment_identifier_use varchar,   -- stage/assessment/identifier/use (varchar)
  con_stage_assessment_identifier_type_system varchar,   -- stage/assessment/identifier/type/coding/system (varchar)
  con_stage_assessment_identifier_type_version varchar,   -- stage/assessment/identifier/type/coding/version (varchar)
  con_stage_assessment_identifier_type_code varchar,   -- stage/assessment/identifier/type/coding/code (varchar)
  con_stage_assessment_identifier_type_display varchar,   -- stage/assessment/identifier/type/coding/display (varchar)
  con_stage_assessment_identifier_type_text varchar,   -- stage/assessment/identifier/type/text (varchar)
  con_stage_assessment_display varchar,   -- stage/assessment/display (varchar)
  con_stage_type_system varchar,   -- stage/type/coding/system (varchar)
  con_stage_type_version varchar,   -- stage/type/coding/version (varchar)
  con_stage_type_code varchar,   -- stage/type/coding/code (varchar)
  con_stage_type_display varchar,   -- stage/type/coding/display (varchar)
  con_stage_type_text varchar,   -- stage/type/text (varchar)
  con_note_authorstring varchar,   -- note/authorString (varchar)
  con_note_authorreference_ref varchar,   -- note/authorReference/reference (varchar)
  con_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  con_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  con_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  con_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  con_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  con_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  con_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  con_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  con_note_time timestamp,   -- note/time (timestamp)
  con_note_text varchar,   -- note/text (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(con_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(con_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(con_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(con_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(con_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(con_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(con_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(con_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(con_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(con_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(con_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(con_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(con_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(con_clinicalstatus_system::TEXT, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/system
             COALESCE(con_clinicalstatus_version::TEXT, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/version
             COALESCE(con_clinicalstatus_code::TEXT, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/code
             COALESCE(con_clinicalstatus_display::TEXT, '#NULL#') || '|||' || -- hash from: clinicalStatus/coding/display
             COALESCE(con_clinicalstatus_text::TEXT, '#NULL#') || '|||' || -- hash from: clinicalStatus/text
             COALESCE(con_verificationstatus_system::TEXT, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/system
             COALESCE(con_verificationstatus_version::TEXT, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/version
             COALESCE(con_verificationstatus_code::TEXT, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/code
             COALESCE(con_verificationstatus_display::TEXT, '#NULL#') || '|||' || -- hash from: verificationStatus/coding/display
             COALESCE(con_verificationstatus_text::TEXT, '#NULL#') || '|||' || -- hash from: verificationStatus/text
             COALESCE(con_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(con_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(con_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(con_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(con_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(con_severity_system::TEXT, '#NULL#') || '|||' || -- hash from: severity/coding/system
             COALESCE(con_severity_version::TEXT, '#NULL#') || '|||' || -- hash from: severity/coding/version
             COALESCE(con_severity_code::TEXT, '#NULL#') || '|||' || -- hash from: severity/coding/code
             COALESCE(con_severity_display::TEXT, '#NULL#') || '|||' || -- hash from: severity/coding/display
             COALESCE(con_severity_text::TEXT, '#NULL#') || '|||' || -- hash from: severity/text
             COALESCE(con_code_system::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(con_code_version::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(con_code_code::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(con_code_display::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(con_code_text::TEXT, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(con_bodysite_system::TEXT, '#NULL#') || '|||' || -- hash from: bodySite/coding/system
             COALESCE(con_bodysite_version::TEXT, '#NULL#') || '|||' || -- hash from: bodySite/coding/version
             COALESCE(con_bodysite_code::TEXT, '#NULL#') || '|||' || -- hash from: bodySite/coding/code
             COALESCE(con_bodysite_display::TEXT, '#NULL#') || '|||' || -- hash from: bodySite/coding/display
             COALESCE(con_bodysite_text::TEXT, '#NULL#') || '|||' || -- hash from: bodySite/text
             COALESCE(con_onsetperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: onsetPeriod/start
             COALESCE(con_onsetperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: onsetPeriod/end
             COALESCE(con_onsetdatetime::TEXT, '#NULL#') || '|||' || -- hash from: onsetDateTime
             COALESCE(con_abatementdatetime::TEXT, '#NULL#') || '|||' || -- hash from: abatementDateTime
             COALESCE(con_abatementage_value::TEXT, '#NULL#') || '|||' || -- hash from: abatementAge/value
             COALESCE(con_abatementage_comparator::TEXT, '#NULL#') || '|||' || -- hash from: abatementAge/comparator
             COALESCE(con_abatementage_unit::TEXT, '#NULL#') || '|||' || -- hash from: abatementAge/unit
             COALESCE(con_abatementage_system::TEXT, '#NULL#') || '|||' || -- hash from: abatementAge/system
             COALESCE(con_abatementage_code::TEXT, '#NULL#') || '|||' || -- hash from: abatementAge/code
             COALESCE(con_abatementperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: abatementPeriod/start
             COALESCE(con_abatementperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: abatementPeriod/end
             COALESCE(con_abatementrange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/low/value
             COALESCE(con_abatementrange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/low/unit
             COALESCE(con_abatementrange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/low/system
             COALESCE(con_abatementrange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/low/code
             COALESCE(con_abatementrange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/high/value
             COALESCE(con_abatementrange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/high/unit
             COALESCE(con_abatementrange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/high/system
             COALESCE(con_abatementrange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: abatementRange/high/code
             COALESCE(con_abatementstring::TEXT, '#NULL#') || '|||' || -- hash from: abatementString
             COALESCE(con_recordeddate::TEXT, '#NULL#') || '|||' || -- hash from: recordedDate
             COALESCE(con_recorder_ref::TEXT, '#NULL#') || '|||' || -- hash from: recorder/reference
             COALESCE(con_recorder_type::TEXT, '#NULL#') || '|||' || -- hash from: recorder/type
             COALESCE(con_recorder_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: recorder/identifier/use
             COALESCE(con_recorder_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/system
             COALESCE(con_recorder_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/version
             COALESCE(con_recorder_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/code
             COALESCE(con_recorder_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/coding/display
             COALESCE(con_recorder_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: recorder/identifier/type/text
             COALESCE(con_recorder_display::TEXT, '#NULL#') || '|||' || -- hash from: recorder/display
             COALESCE(con_asserter_ref::TEXT, '#NULL#') || '|||' || -- hash from: asserter/reference
             COALESCE(con_asserter_type::TEXT, '#NULL#') || '|||' || -- hash from: asserter/type
             COALESCE(con_asserter_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: asserter/identifier/use
             COALESCE(con_asserter_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/system
             COALESCE(con_asserter_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/version
             COALESCE(con_asserter_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/code
             COALESCE(con_asserter_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/coding/display
             COALESCE(con_asserter_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: asserter/identifier/type/text
             COALESCE(con_asserter_display::TEXT, '#NULL#') || '|||' || -- hash from: asserter/display
             COALESCE(con_stage_summary_system::TEXT, '#NULL#') || '|||' || -- hash from: stage/summary/coding/system
             COALESCE(con_stage_summary_version::TEXT, '#NULL#') || '|||' || -- hash from: stage/summary/coding/version
             COALESCE(con_stage_summary_code::TEXT, '#NULL#') || '|||' || -- hash from: stage/summary/coding/code
             COALESCE(con_stage_summary_display::TEXT, '#NULL#') || '|||' || -- hash from: stage/summary/coding/display
             COALESCE(con_stage_summary_text::TEXT, '#NULL#') || '|||' || -- hash from: stage/summary/text
             COALESCE(con_stage_assessment_ref::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/reference
             COALESCE(con_stage_assessment_type::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/type
             COALESCE(con_stage_assessment_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/use
             COALESCE(con_stage_assessment_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/system
             COALESCE(con_stage_assessment_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/version
             COALESCE(con_stage_assessment_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/code
             COALESCE(con_stage_assessment_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/coding/display
             COALESCE(con_stage_assessment_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/identifier/type/text
             COALESCE(con_stage_assessment_display::TEXT, '#NULL#') || '|||' || -- hash from: stage/assessment/display
             COALESCE(con_stage_type_system::TEXT, '#NULL#') || '|||' || -- hash from: stage/type/coding/system
             COALESCE(con_stage_type_version::TEXT, '#NULL#') || '|||' || -- hash from: stage/type/coding/version
             COALESCE(con_stage_type_code::TEXT, '#NULL#') || '|||' || -- hash from: stage/type/coding/code
             COALESCE(con_stage_type_display::TEXT, '#NULL#') || '|||' || -- hash from: stage/type/coding/display
             COALESCE(con_stage_type_text::TEXT, '#NULL#') || '|||' || -- hash from: stage/type/text
             COALESCE(con_note_authorstring::TEXT, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(con_note_authorreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(con_note_authorreference_type::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(con_note_authorreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(con_note_authorreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(con_note_authorreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(con_note_authorreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(con_note_authorreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(con_note_authorreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(con_note_authorreference_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(con_note_time::TEXT, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(con_note_text::TEXT, '#NULL#') || '|||' || -- hash from: note/text
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medication" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medication (
  medication_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medication_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  med_id varchar,   -- id (varchar)
  med_identifier_use varchar,   -- identifier/use (varchar)
  med_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  med_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  med_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  med_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  med_identifier_type_text varchar,   -- identifier/type/text (varchar)
  med_identifier_system varchar,   -- identifier/system (varchar)
  med_identifier_value varchar,   -- identifier/value (varchar)
  med_identifier_start timestamp,   -- identifier/start (timestamp)
  med_identifier_end timestamp,   -- identifier/end (timestamp)
  med_code_system varchar,   -- code/coding/system (varchar)
  med_code_version varchar,   -- code/coding/version (varchar)
  med_code_code varchar,   -- code/coding/code (varchar)
  med_code_display varchar,   -- code/coding/display (varchar)
  med_code_text varchar,   -- code/text (varchar)
  med_status varchar,   -- status (varchar)
  med_form_system varchar,   -- form/coding/system (varchar)
  med_form_version varchar,   -- form/coding/version (varchar)
  med_form_code varchar,   -- form/coding/code (varchar)
  med_form_display varchar,   -- form/coding/display (varchar)
  med_form_text varchar,   -- form/text (varchar)
  med_amount_numerator_value double precision,   -- amount/numerator/value (double precision)
  med_amount_numerator_comparator varchar,   -- amount/numerator/comparator (varchar)
  med_amount_numerator_unit varchar,   -- amount/numerator/unit (varchar)
  med_amount_numerator_system varchar,   -- amount/numerator/system (varchar)
  med_amount_numerator_code varchar,   -- amount/numerator/code (varchar)
  med_amount_denominator_value double precision,   -- amount/denominator/value (double precision)
  med_amount_denominator_comparator varchar,   -- amount/denominator/comparator (varchar)
  med_amount_denominator_unit varchar,   -- amount/denominator/unit (varchar)
  med_amount_denominator_system varchar,   -- amount/denominator/system (varchar)
  med_amount_denominator_code varchar,   -- amount/denominator/code (varchar)
  med_ingredient_strength_numerator_value double precision,   -- ingredient/strength/numerator/value (double precision)
  med_ingredient_strength_numerator_comparator varchar,   -- ingredient/strength/numerator/comparator (varchar)
  med_ingredient_strength_numerator_unit varchar,   -- ingredient/strength/numerator/unit (varchar)
  med_ingredient_strength_numerator_system varchar,   -- ingredient/strength/numerator/system (varchar)
  med_ingredient_strength_numerator_code varchar,   -- ingredient/strength/numerator/code (varchar)
  med_ingredient_strength_denominator_value double precision,   -- ingredient/strength/denominator/value (double precision)
  med_ingredient_strength_denominator_comparator varchar,   -- ingredient/strength/denominator/comparator (varchar)
  med_ingredient_strength_denominator_unit varchar,   -- ingredient/strength/denominator/unit (varchar)
  med_ingredient_strength_denominator_system varchar,   -- ingredient/strength/denominator/system (varchar)
  med_ingredient_strength_denominator_code varchar,   -- ingredient/strength/denominator/code (varchar)
  med_ingredient_itemcodeableconcept_system varchar,   -- ingredient/itemCodeableConcept/coding/system (varchar)
  med_ingredient_itemcodeableconcept_version varchar,   -- ingredient/itemCodeableConcept/coding/version (varchar)
  med_ingredient_itemcodeableconcept_code varchar,   -- ingredient/itemCodeableConcept/coding/code (varchar)
  med_ingredient_itemcodeableconcept_display varchar,   -- ingredient/itemCodeableConcept/coding/display (varchar)
  med_ingredient_itemcodeableconcept_text varchar,   -- ingredient/itemCodeableConcept/text (varchar)
  med_ingredient_itemreference_ref varchar,   -- ingredient/itemReference/reference (varchar)
  med_ingredient_itemreference_type varchar,   -- ingredient/itemReference/type (varchar)
  med_ingredient_itemreference_identifier_use varchar,   -- ingredient/itemReference/identifier/use (varchar)
  med_ingredient_itemreference_identifier_type_system varchar,   -- ingredient/itemReference/identifier/type/coding/system (varchar)
  med_ingredient_itemreference_identifier_type_version varchar,   -- ingredient/itemReference/identifier/type/coding/version (varchar)
  med_ingredient_itemreference_identifier_type_code varchar,   -- ingredient/itemReference/identifier/type/coding/code (varchar)
  med_ingredient_itemreference_identifier_type_display varchar,   -- ingredient/itemReference/identifier/type/coding/display (varchar)
  med_ingredient_itemreference_identifier_type_text varchar,   -- ingredient/itemReference/identifier/type/text (varchar)
  med_ingredient_itemreference_display varchar,   -- ingredient/itemReference/display (varchar)
  med_ingredient_isactive boolean,   -- ingredient/isActive (boolean)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(med_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(med_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(med_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(med_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(med_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(med_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(med_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(med_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(med_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(med_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(med_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(med_code_system::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(med_code_version::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(med_code_code::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(med_code_display::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(med_code_text::TEXT, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(med_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(med_form_system::TEXT, '#NULL#') || '|||' || -- hash from: form/coding/system
             COALESCE(med_form_version::TEXT, '#NULL#') || '|||' || -- hash from: form/coding/version
             COALESCE(med_form_code::TEXT, '#NULL#') || '|||' || -- hash from: form/coding/code
             COALESCE(med_form_display::TEXT, '#NULL#') || '|||' || -- hash from: form/coding/display
             COALESCE(med_form_text::TEXT, '#NULL#') || '|||' || -- hash from: form/text
             COALESCE(med_amount_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: amount/numerator/value
             COALESCE(med_amount_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: amount/numerator/comparator
             COALESCE(med_amount_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: amount/numerator/unit
             COALESCE(med_amount_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: amount/numerator/system
             COALESCE(med_amount_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: amount/numerator/code
             COALESCE(med_amount_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: amount/denominator/value
             COALESCE(med_amount_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: amount/denominator/comparator
             COALESCE(med_amount_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: amount/denominator/unit
             COALESCE(med_amount_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: amount/denominator/system
             COALESCE(med_amount_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: amount/denominator/code
             COALESCE(med_ingredient_strength_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/value
             COALESCE(med_ingredient_strength_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/comparator
             COALESCE(med_ingredient_strength_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/unit
             COALESCE(med_ingredient_strength_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/system
             COALESCE(med_ingredient_strength_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/numerator/code
             COALESCE(med_ingredient_strength_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/value
             COALESCE(med_ingredient_strength_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/comparator
             COALESCE(med_ingredient_strength_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/unit
             COALESCE(med_ingredient_strength_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/system
             COALESCE(med_ingredient_strength_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/strength/denominator/code
             COALESCE(med_ingredient_itemcodeableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/system
             COALESCE(med_ingredient_itemcodeableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/version
             COALESCE(med_ingredient_itemcodeableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/code
             COALESCE(med_ingredient_itemcodeableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/coding/display
             COALESCE(med_ingredient_itemcodeableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemCodeableConcept/text
             COALESCE(med_ingredient_itemreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/reference
             COALESCE(med_ingredient_itemreference_type::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/type
             COALESCE(med_ingredient_itemreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/use
             COALESCE(med_ingredient_itemreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/system
             COALESCE(med_ingredient_itemreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/version
             COALESCE(med_ingredient_itemreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/code
             COALESCE(med_ingredient_itemreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/coding/display
             COALESCE(med_ingredient_itemreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/identifier/type/text
             COALESCE(med_ingredient_itemreference_display::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/itemReference/display
             COALESCE(med_ingredient_isactive::TEXT, '#NULL#') || '|||' || -- hash from: ingredient/isActive
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationrequest (
  medicationrequest_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medicationrequest_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  medreq_id varchar,   -- id (varchar)
  medreq_encounter_ref varchar,   -- encounter/reference (varchar)
  medreq_patient_ref varchar,   -- subject/reference (varchar)
  medreq_identifier_use varchar,   -- identifier/use (varchar)
  medreq_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  medreq_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  medreq_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  medreq_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  medreq_identifier_type_text varchar,   -- identifier/type/text (varchar)
  medreq_identifier_system varchar,   -- identifier/system (varchar)
  medreq_identifier_value varchar,   -- identifier/value (varchar)
  medreq_identifier_start timestamp,   -- identifier/start (timestamp)
  medreq_identifier_end timestamp,   -- identifier/end (timestamp)
  medreq_medicationreference_ref varchar,   -- medicationReference/reference (varchar)
  medreq_status varchar,   -- status (varchar)
  medreq_statusreason_system varchar,   -- statusReason/coding/system (varchar)
  medreq_statusreason_version varchar,   -- statusReason/coding/version (varchar)
  medreq_statusreason_code varchar,   -- statusReason/coding/code (varchar)
  medreq_statusreason_display varchar,   -- statusReason/coding/display (varchar)
  medreq_statusreason_text varchar,   -- statusReason/text (varchar)
  medreq_intend varchar,   -- intend (varchar)
  medreq_category_system varchar,   -- category/coding/system (varchar)
  medreq_category_version varchar,   -- category/coding/version (varchar)
  medreq_category_code varchar,   -- category/coding/code (varchar)
  medreq_category_display varchar,   -- category/coding/display (varchar)
  medreq_category_text varchar,   -- category/text (varchar)
  medreq_priority varchar,   -- priority (varchar)
  medreq_reportedboolean boolean,   -- reportedBoolean (boolean)
  medreq_reportedreference_ref varchar,   -- reportedReference/reference (varchar)
  medreq_reportedreference_type varchar,   -- reportedReference/type (varchar)
  medreq_reportedreference_identifier_use varchar,   -- reportedReference/identifier/use (varchar)
  medreq_reportedreference_identifier_type_system varchar,   -- reportedReference/identifier/type/coding/system (varchar)
  medreq_reportedreference_identifier_type_version varchar,   -- reportedReference/identifier/type/coding/version (varchar)
  medreq_reportedreference_identifier_type_code varchar,   -- reportedReference/identifier/type/coding/code (varchar)
  medreq_reportedreference_identifier_type_display varchar,   -- reportedReference/identifier/type/coding/display (varchar)
  medreq_reportedreference_identifier_type_text varchar,   -- reportedReference/identifier/type/text (varchar)
  medreq_reportedreference_display varchar,   -- reportedReference/display (varchar)
  medreq_medicationcodeableconcept_system varchar,   -- medicationCodeableConcept/coding/system (varchar)
  medreq_medicationcodeableconcept_version varchar,   -- medicationCodeableConcept/coding/version (varchar)
  medreq_medicationcodeableconcept_code varchar,   -- medicationCodeableConcept/coding/code (varchar)
  medreq_medicationcodeableconcept_display varchar,   -- medicationCodeableConcept/coding/display (varchar)
  medreq_medicationcodeableconcept_text varchar,   -- medicationCodeableConcept/text (varchar)
  medreq_supportinginformation_ref varchar,   -- supportingInformation/reference (varchar)
  medreq_supportinginformation_type varchar,   -- supportingInformation/type (varchar)
  medreq_supportinginformation_identifier_use varchar,   -- supportingInformation/identifier/use (varchar)
  medreq_supportinginformation_identifier_type_system varchar,   -- supportingInformation/identifier/type/coding/system (varchar)
  medreq_supportinginformation_identifier_type_version varchar,   -- supportingInformation/identifier/type/coding/version (varchar)
  medreq_supportinginformation_identifier_type_code varchar,   -- supportingInformation/identifier/type/coding/code (varchar)
  medreq_supportinginformation_identifier_type_display varchar,   -- supportingInformation/identifier/type/coding/display (varchar)
  medreq_supportinginformation_identifier_type_text varchar,   -- supportingInformation/identifier/type/text (varchar)
  medreq_supportinginformation_display varchar,   -- supportingInformation/display (varchar)
  medreq_authoredon timestamp,   -- authoredOn (timestamp)
  medreq_requester_ref varchar,   -- requester/reference (varchar)
  medreq_requester_type varchar,   -- requester/type (varchar)
  medreq_requester_identifier_use varchar,   -- requester/identifier/use (varchar)
  medreq_requester_identifier_type_system varchar,   -- requester/identifier/type/coding/system (varchar)
  medreq_requester_identifier_type_version varchar,   -- requester/identifier/type/coding/version (varchar)
  medreq_requester_identifier_type_code varchar,   -- requester/identifier/type/coding/code (varchar)
  medreq_requester_identifier_type_display varchar,   -- requester/identifier/type/coding/display (varchar)
  medreq_requester_identifier_type_text varchar,   -- requester/identifier/type/text (varchar)
  medreq_requester_display varchar,   -- requester/display (varchar)
  medreq_reasoncode_system varchar,   -- reasonCode/coding/system (varchar)
  medreq_reasoncode_version varchar,   -- reasonCode/coding/version (varchar)
  medreq_reasoncode_code varchar,   -- reasonCode/coding/code (varchar)
  medreq_reasoncode_display varchar,   -- reasonCode/coding/display (varchar)
  medreq_reasoncode_text varchar,   -- reasonCode/text (varchar)
  medreq_reasonreference_ref varchar,   -- reasonReference/reference (varchar)
  medreq_reasonreference_type varchar,   -- reasonReference/type (varchar)
  medreq_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  medreq_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  medreq_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  medreq_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  medreq_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  medreq_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  medreq_reasonreference_display varchar,   -- reasonReference/display (varchar)
  medreq_basedon_ref varchar,   -- basedOn/reference (varchar)
  medreq_basedon_type varchar,   -- basedOn/type (varchar)
  medreq_basedon_identifier_use varchar,   -- basedOn/identifier/use (varchar)
  medreq_basedon_identifier_type_system varchar,   -- basedOn/identifier/type/coding/system (varchar)
  medreq_basedon_identifier_type_version varchar,   -- basedOn/identifier/type/coding/version (varchar)
  medreq_basedon_identifier_type_code varchar,   -- basedOn/identifier/type/coding/code (varchar)
  medreq_basedon_identifier_type_display varchar,   -- basedOn/identifier/type/coding/display (varchar)
  medreq_basedon_identifier_type_text varchar,   -- basedOn/identifier/type/text (varchar)
  medreq_basedon_display varchar,   -- basedOn/display (varchar)
  medreq_note_authorstring varchar,   -- note/authorString (varchar)
  medreq_note_authorreference_ref varchar,   -- note/authorReference/reference (varchar)
  medreq_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  medreq_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  medreq_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  medreq_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  medreq_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  medreq_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  medreq_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  medreq_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  medreq_note_time timestamp,   -- note/time (timestamp)
  medreq_note_text varchar,   -- note/text (varchar)
  medreq_doseinstruc_sequence int,   -- dosageInstruction/sequence (int)
  medreq_doseinstruc_text varchar,   -- dosageInstruction/text (varchar)
  medreq_doseinstruc_additionalinstruction_system varchar,   -- dosageInstruction/additionalInstruction/coding/system (varchar)
  medreq_doseinstruc_additionalinstruction_version varchar,   -- dosageInstruction/additionalInstruction/coding/version (varchar)
  medreq_doseinstruc_additionalinstruction_code varchar,   -- dosageInstruction/additionalInstruction/coding/code (varchar)
  medreq_doseinstruc_additionalinstruction_display varchar,   -- dosageInstruction/additionalInstruction/coding/display (varchar)
  medreq_doseinstruc_additionalinstruction_text varchar,   -- dosageInstruction/additionalInstruction/text (varchar)
  medreq_doseinstruc_patientinstruction varchar,   -- dosageInstruction/patientInstruction (varchar)
  medreq_doseinstruc_timing_event timestamp,   -- dosageInstruction/timing/event (timestamp)
  medreq_doseinstruc_timing_repeat_boundsduration_value double precision,   -- dosageInstruction/timing/repeat/boundsDuration/value (double precision)
  medreq_doseinstruc_timing_repeat_boundsduration_comparator varchar,   -- dosageInstruction/timing/repeat/boundsDuration/comparator (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_unit varchar,   -- dosageInstruction/timing/repeat/boundsDuration/unit (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_system varchar,   -- dosageInstruction/timing/repeat/boundsDuration/system (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_code varchar,   -- dosageInstruction/timing/repeat/boundsDuration/code (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_value double precision,   -- dosageInstruction/timing/repeat/boundsRange/low/value (double precision)
  medreq_doseinstruc_timing_repeat_boundsrange_low_unit varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/unit (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_system varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/system (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_code varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/code (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_value double precision,   -- dosageInstruction/timing/repeat/boundsRange/high/value (double precision)
  medreq_doseinstruc_timing_repeat_boundsrange_high_unit varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/unit (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_system varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/system (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_code varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/code (varchar)
  medreq_doseinstruc_timing_repeat_boundsperiod_start timestamp,   -- dosageInstruction/timing/repeat/boundsPeriod/start (timestamp)
  medreq_doseinstruc_timing_repeat_boundsperiod_end timestamp,   -- dosageInstruction/timing/repeat/boundsPeriod/end (timestamp)
  medreq_doseinstruc_timing_repeat_count int,   -- dosageInstruction/timing/repeat/count (int)
  medreq_doseinstruc_timing_repeat_countmax int,   -- dosageInstruction/timing/repeat/countMax (int)
  medreq_doseinstruc_timing_repeat_duration double precision,   -- dosageInstruction/timing/repeat/duration (double precision)
  medreq_doseinstruc_timing_repeat_durationmax double precision,   -- dosageInstruction/timing/repeat/durationMax (double precision)
  medreq_doseinstruc_timing_repeat_durationunit varchar,   -- dosageInstruction/timing/repeat/durationUnit (varchar)
  medreq_doseinstruc_timing_repeat_frequency int,   -- dosageInstruction/timing/repeat/frequency (int)
  medreq_doseinstruc_timing_repeat_frequencymax int,   -- dosageInstruction/timing/repeat/frequencyMax (int)
  medreq_doseinstruc_timing_repeat_period double precision,   -- dosageInstruction/timing/repeat/period (double precision)
  medreq_doseinstruc_timing_repeat_periodmax double precision,   -- dosageInstruction/timing/repeat/periodMax (double precision)
  medreq_doseinstruc_timing_repeat_periodunit varchar,   -- dosageInstruction/timing/repeat/periodUnit (varchar)
  medreq_doseinstruc_timing_repeat_dayofweek varchar,   -- dosageInstruction/timing/repeat/dayOfWeek (varchar)
  medreq_doseinstruc_timing_repeat_timeofday time,   -- dosageInstruction/timing/repeat/timeOfDay (time)
  medreq_doseinstruc_timing_repeat_when varchar,   -- dosageInstruction/timing/repeat/when (varchar)
  medreq_doseinstruc_timing_repeat_offset int,   -- dosageInstruction/timing/repeat/offset (int)
  medreq_doseinstruc_timing_code_system varchar,   -- dosageInstruction/timing/code/coding/system (varchar)
  medreq_doseinstruc_timing_code_version varchar,   -- dosageInstruction/timing/code/coding/version (varchar)
  medreq_doseinstruc_timing_code_code varchar,   -- dosageInstruction/timing/code/coding/code (varchar)
  medreq_doseinstruc_timing_code_display varchar,   -- dosageInstruction/timing/code/coding/display (varchar)
  medreq_doseinstruc_timing_code_text varchar,   -- dosageInstruction/timing/code/text (varchar)
  medreq_doseinstruc_asneededboolean boolean,   -- dosageInstruction/asNeededBoolean (boolean)
  medreq_doseinstruc_asneededcodeableconcept_system varchar,   -- dosageInstruction/asNeededCodeableConcept/coding/system (varchar)
  medreq_doseinstruc_asneededcodeableconcept_version varchar,   -- dosageInstruction/asNeededCodeableConcept/coding/version (varchar)
  medreq_doseinstruc_asneededcodeableconcept_code varchar,   -- dosageInstruction/asNeededCodeableConcept/coding/code (varchar)
  medreq_doseinstruc_asneededcodeableconcept_display varchar,   -- dosageInstruction/asNeededCodeableConcept/coding/display (varchar)
  medreq_doseinstruc_asneededcodeableconcept_text varchar,   -- dosageInstruction/asNeededCodeableConcept/text (varchar)
  medreq_doseinstruc_site_system varchar,   -- dosageInstruction/site/coding/system (varchar)
  medreq_doseinstruc_site_version varchar,   -- dosageInstruction/site/coding/version (varchar)
  medreq_doseinstruc_site_code varchar,   -- dosageInstruction/site/coding/code (varchar)
  medreq_doseinstruc_site_display varchar,   -- dosageInstruction/site/coding/display (varchar)
  medreq_doseinstruc_site_text varchar,   -- dosageInstruction/site/text (varchar)
  medreq_doseinstruc_route_system varchar,   -- dosageInstruction/route/coding/system (varchar)
  medreq_doseinstruc_route_version varchar,   -- dosageInstruction/route/coding/version (varchar)
  medreq_doseinstruc_route_code varchar,   -- dosageInstruction/route/coding/code (varchar)
  medreq_doseinstruc_route_display varchar,   -- dosageInstruction/route/coding/display (varchar)
  medreq_doseinstruc_route_text varchar,   -- dosageInstruction/route/text (varchar)
  medreq_doseinstruc_method_system varchar,   -- dosageInstruction/method/coding/system (varchar)
  medreq_doseinstruc_method_version varchar,   -- dosageInstruction/method/coding/version (varchar)
  medreq_doseinstruc_method_code varchar,   -- dosageInstruction/method/coding/code (varchar)
  medreq_doseinstruc_method_display varchar,   -- dosageInstruction/method/coding/display (varchar)
  medreq_doseinstruc_method_text varchar,   -- dosageInstruction/method/text (varchar)
  medreq_doseinstruc_doseandrate_type_system varchar,   -- dosageInstruction/doseAndRate/type/coding/system (varchar)
  medreq_doseinstruc_doseandrate_type_version varchar,   -- dosageInstruction/doseAndRate/type/coding/version (varchar)
  medreq_doseinstruc_doseandrate_type_code varchar,   -- dosageInstruction/doseAndRate/type/coding/code (varchar)
  medreq_doseinstruc_doseandrate_type_display varchar,   -- dosageInstruction/doseAndRate/type/coding/display (varchar)
  medreq_doseinstruc_doseandrate_type_text varchar,   -- dosageInstruction/doseAndRate/type/text (varchar)
  medreq_doseinstruc_doseandrate_doserange_low_value double precision,   -- dosageInstruction/doseAndRate/doseRange/low/value (double precision)
  medreq_doseinstruc_doseandrate_doserange_low_unit varchar,   -- dosageInstruction/doseAndRate/doseRange/low/unit (varchar)
  medreq_doseinstruc_doseandrate_doserange_low_system varchar,   -- dosageInstruction/doseAndRate/doseRange/low/system (varchar)
  medreq_doseinstruc_doseandrate_doserange_low_code varchar,   -- dosageInstruction/doseAndRate/doseRange/low/code (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_value double precision,   -- dosageInstruction/doseAndRate/doseRange/high/value (double precision)
  medreq_doseinstruc_doseandrate_doserange_high_unit varchar,   -- dosageInstruction/doseAndRate/doseRange/high/unit (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_system varchar,   -- dosageInstruction/doseAndRate/doseRange/high/system (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_code varchar,   -- dosageInstruction/doseAndRate/doseRange/high/code (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_value double precision,   -- dosageInstruction/doseAndRate/doseQuantity/value (double precision)
  medreq_doseinstruc_doseandrate_dosequantity_comparator varchar,   -- dosageInstruction/doseAndRate/doseQuantity/comparator (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_unit varchar,   -- dosageInstruction/doseAndRate/doseQuantity/unit (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_system varchar,   -- dosageInstruction/doseAndRate/doseQuantity/system (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_code varchar,   -- dosageInstruction/doseAndRate/doseQuantity/code (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_value double precision,   -- dosageInstruction/doseAndRate/rateRatio/numerator/value (double precision)
  medreq_doseinstruc_doseandrate_rateratio_numerator_comparator varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/comparator (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_unit varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/unit (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_system varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/system (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_code varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/code (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_value double precision,   -- dosageInstruction/doseAndRate/rateRatio/denominator/value (double precision)
  medreq_doseinstruc_doseandrate_rateratio_denominator_comparator varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/comparator (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_unit varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/unit (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_system varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/system (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_code varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/code (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_value double precision,   -- dosageInstruction/doseAndRate/rateRange/low/value (double precision)
  medreq_doseinstruc_doseandrate_raterange_low_unit varchar,   -- dosageInstruction/doseAndRate/rateRange/low/unit (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_system varchar,   -- dosageInstruction/doseAndRate/rateRange/low/system (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_code varchar,   -- dosageInstruction/doseAndRate/rateRange/low/code (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_value double precision,   -- dosageInstruction/doseAndRate/rateRange/high/value (double precision)
  medreq_doseinstruc_doseandrate_raterange_high_unit varchar,   -- dosageInstruction/doseAndRate/rateRange/high/unit (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_system varchar,   -- dosageInstruction/doseAndRate/rateRange/high/system (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_code varchar,   -- dosageInstruction/doseAndRate/rateRange/high/code (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_value double precision,   -- dosageInstruction/doseAndRate/rateQuantity/value (double precision)
  medreq_doseinstruc_doseandrate_ratequantity_unit varchar,   -- dosageInstruction/doseAndRate/rateQuantity/unit (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_system varchar,   -- dosageInstruction/doseAndRate/rateQuantity/system (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_code varchar,   -- dosageInstruction/doseAndRate/rateQuantity/code (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_value double precision,   -- dosageInstruction/maxDosePerPeriod/numerator/value (double precision)
  medreq_doseinstruc_maxdoseperperiod_numerator_comparator varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/comparator (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_unit varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/unit (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_system varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/system (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_code varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/code (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_value double precision,   -- dosageInstruction/maxDosePerPeriod/denominator/value (double precision)
  medreq_doseinstruc_maxdoseperperiod_denominator_comparator varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/comparator (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_unit varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/unit (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_system varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/system (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_code varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/code (varchar)
  medreq_doseinstruc_maxdoseperadministration_value double precision,   -- dosageInstruction/maxDosePerAdministration/value (double precision)
  medreq_doseinstruc_maxdoseperadministration_unit varchar,   -- dosageInstruction/maxDosePerAdministration/unit (varchar)
  medreq_doseinstruc_maxdoseperadministration_system varchar,   -- dosageInstruction/maxDosePerAdministration/system (varchar)
  medreq_doseinstruc_maxdoseperadministration_code varchar,   -- dosageInstruction/maxDosePerAdministration/code (varchar)
  medreq_doseinstruc_maxdoseperlifetime_value double precision,   -- dosageInstruction/maxDosePerLifetime/value (double precision)
  medreq_doseinstruc_maxdoseperlifetime_unit varchar,   -- dosageInstruction/maxDosePerLifetime/unit (varchar)
  medreq_doseinstruc_maxdoseperlifetime_system varchar,   -- dosageInstruction/maxDosePerLifetime/system (varchar)
  medreq_doseinstruc_maxdoseperlifetime_code varchar,   -- dosageInstruction/maxDosePerLifetime/code (varchar)
  medreq_substitution_reason_system varchar,   -- substitution/reason/coding/system (varchar)
  medreq_substitution_reason_version varchar,   -- substitution/reason/coding/version (varchar)
  medreq_substitution_reason_code varchar,   -- substitution/reason/coding/code (varchar)
  medreq_substitution_reason_display varchar,   -- substitution/reason/coding/display (varchar)
  medreq_substitution_reason_text varchar,   -- substitution/reason/text (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(medreq_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(medreq_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(medreq_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(medreq_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(medreq_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(medreq_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(medreq_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(medreq_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(medreq_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(medreq_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(medreq_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(medreq_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(medreq_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(medreq_medicationreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: medicationReference/reference
             COALESCE(medreq_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(medreq_statusreason_system::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(medreq_statusreason_version::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(medreq_statusreason_code::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(medreq_statusreason_display::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(medreq_statusreason_text::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(medreq_intend::TEXT, '#NULL#') || '|||' || -- hash from: intend
             COALESCE(medreq_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(medreq_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(medreq_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(medreq_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(medreq_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(medreq_priority::TEXT, '#NULL#') || '|||' || -- hash from: priority
             COALESCE(medreq_reportedboolean::TEXT, '#NULL#') || '|||' || -- hash from: reportedBoolean
             COALESCE(medreq_reportedreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/reference
             COALESCE(medreq_reportedreference_type::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/type
             COALESCE(medreq_reportedreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/use
             COALESCE(medreq_reportedreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/system
             COALESCE(medreq_reportedreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/version
             COALESCE(medreq_reportedreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/code
             COALESCE(medreq_reportedreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/coding/display
             COALESCE(medreq_reportedreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/identifier/type/text
             COALESCE(medreq_reportedreference_display::TEXT, '#NULL#') || '|||' || -- hash from: reportedReference/display
             COALESCE(medreq_medicationcodeableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/system
             COALESCE(medreq_medicationcodeableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/version
             COALESCE(medreq_medicationcodeableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/code
             COALESCE(medreq_medicationcodeableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/display
             COALESCE(medreq_medicationcodeableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/text
             COALESCE(medreq_supportinginformation_ref::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/reference
             COALESCE(medreq_supportinginformation_type::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/type
             COALESCE(medreq_supportinginformation_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/use
             COALESCE(medreq_supportinginformation_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/system
             COALESCE(medreq_supportinginformation_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/version
             COALESCE(medreq_supportinginformation_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/code
             COALESCE(medreq_supportinginformation_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/display
             COALESCE(medreq_supportinginformation_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/text
             COALESCE(medreq_supportinginformation_display::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/display
             COALESCE(medreq_authoredon::TEXT, '#NULL#') || '|||' || -- hash from: authoredOn
             COALESCE(medreq_requester_ref::TEXT, '#NULL#') || '|||' || -- hash from: requester/reference
             COALESCE(medreq_requester_type::TEXT, '#NULL#') || '|||' || -- hash from: requester/type
             COALESCE(medreq_requester_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/use
             COALESCE(medreq_requester_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/system
             COALESCE(medreq_requester_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/version
             COALESCE(medreq_requester_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/code
             COALESCE(medreq_requester_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/display
             COALESCE(medreq_requester_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/text
             COALESCE(medreq_requester_display::TEXT, '#NULL#') || '|||' || -- hash from: requester/display
             COALESCE(medreq_reasoncode_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(medreq_reasoncode_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(medreq_reasoncode_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(medreq_reasoncode_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(medreq_reasoncode_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(medreq_reasonreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(medreq_reasonreference_type::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(medreq_reasonreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(medreq_reasonreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(medreq_reasonreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(medreq_reasonreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(medreq_reasonreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(medreq_reasonreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(medreq_reasonreference_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(medreq_basedon_ref::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(medreq_basedon_type::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(medreq_basedon_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(medreq_basedon_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(medreq_basedon_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(medreq_basedon_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(medreq_basedon_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(medreq_basedon_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(medreq_basedon_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(medreq_note_authorstring::TEXT, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(medreq_note_authorreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(medreq_note_authorreference_type::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(medreq_note_authorreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(medreq_note_authorreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(medreq_note_authorreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(medreq_note_authorreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(medreq_note_authorreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(medreq_note_authorreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(medreq_note_authorreference_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(medreq_note_time::TEXT, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(medreq_note_text::TEXT, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(medreq_doseinstruc_sequence::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/sequence
             COALESCE(medreq_doseinstruc_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/text
             COALESCE(medreq_doseinstruc_additionalinstruction_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/system
             COALESCE(medreq_doseinstruc_additionalinstruction_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/version
             COALESCE(medreq_doseinstruc_additionalinstruction_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/code
             COALESCE(medreq_doseinstruc_additionalinstruction_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/coding/display
             COALESCE(medreq_doseinstruc_additionalinstruction_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/additionalInstruction/text
             COALESCE(medreq_doseinstruc_patientinstruction::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/patientInstruction
             COALESCE(medreq_doseinstruc_timing_event::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/event
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/value
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/comparator
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/unit
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/system
             COALESCE(medreq_doseinstruc_timing_repeat_boundsduration_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsDuration/code
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/value
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/unit
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/system
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/low/code
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/value
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/unit
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/system
             COALESCE(medreq_doseinstruc_timing_repeat_boundsrange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsRange/high/code
             COALESCE(medreq_doseinstruc_timing_repeat_boundsperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsPeriod/start
             COALESCE(medreq_doseinstruc_timing_repeat_boundsperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/boundsPeriod/end
             COALESCE(medreq_doseinstruc_timing_repeat_count::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/count
             COALESCE(medreq_doseinstruc_timing_repeat_countmax::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/countMax
             COALESCE(medreq_doseinstruc_timing_repeat_duration::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/duration
             COALESCE(medreq_doseinstruc_timing_repeat_durationmax::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/durationMax
             COALESCE(medreq_doseinstruc_timing_repeat_durationunit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/durationUnit
             COALESCE(medreq_doseinstruc_timing_repeat_frequency::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/frequency
             COALESCE(medreq_doseinstruc_timing_repeat_frequencymax::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/frequencyMax
             COALESCE(medreq_doseinstruc_timing_repeat_period::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/period
             COALESCE(medreq_doseinstruc_timing_repeat_periodmax::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/periodMax
             COALESCE(medreq_doseinstruc_timing_repeat_periodunit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/periodUnit
             COALESCE(medreq_doseinstruc_timing_repeat_dayofweek::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/dayOfWeek
             COALESCE(medreq_doseinstruc_timing_repeat_timeofday::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/timeOfDay
             COALESCE(medreq_doseinstruc_timing_repeat_when::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/when
             COALESCE(medreq_doseinstruc_timing_repeat_offset::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/repeat/offset
             COALESCE(medreq_doseinstruc_timing_code_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/system
             COALESCE(medreq_doseinstruc_timing_code_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/version
             COALESCE(medreq_doseinstruc_timing_code_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/code
             COALESCE(medreq_doseinstruc_timing_code_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/coding/display
             COALESCE(medreq_doseinstruc_timing_code_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/timing/code/text
             COALESCE(medreq_doseinstruc_asneededboolean::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededBoolean
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/system
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/version
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/code
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/coding/display
             COALESCE(medreq_doseinstruc_asneededcodeableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/asNeededCodeableConcept/text
             COALESCE(medreq_doseinstruc_site_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/system
             COALESCE(medreq_doseinstruc_site_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/version
             COALESCE(medreq_doseinstruc_site_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/code
             COALESCE(medreq_doseinstruc_site_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/coding/display
             COALESCE(medreq_doseinstruc_site_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/site/text
             COALESCE(medreq_doseinstruc_route_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/system
             COALESCE(medreq_doseinstruc_route_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/version
             COALESCE(medreq_doseinstruc_route_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/code
             COALESCE(medreq_doseinstruc_route_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/coding/display
             COALESCE(medreq_doseinstruc_route_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/route/text
             COALESCE(medreq_doseinstruc_method_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/system
             COALESCE(medreq_doseinstruc_method_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/version
             COALESCE(medreq_doseinstruc_method_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/code
             COALESCE(medreq_doseinstruc_method_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/coding/display
             COALESCE(medreq_doseinstruc_method_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/method/text
             COALESCE(medreq_doseinstruc_doseandrate_type_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/system
             COALESCE(medreq_doseinstruc_doseandrate_type_version::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/version
             COALESCE(medreq_doseinstruc_doseandrate_type_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/code
             COALESCE(medreq_doseinstruc_doseandrate_type_display::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/coding/display
             COALESCE(medreq_doseinstruc_doseandrate_type_text::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/type/text
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/value
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/unit
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/system
             COALESCE(medreq_doseinstruc_doseandrate_doserange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/low/code
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/value
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/unit
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/system
             COALESCE(medreq_doseinstruc_doseandrate_doserange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseRange/high/code
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/value
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/comparator
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/unit
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/system
             COALESCE(medreq_doseinstruc_doseandrate_dosequantity_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/doseQuantity/code
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/value
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/comparator
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/unit
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/system
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/numerator/code
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/value
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/comparator
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/unit
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/system
             COALESCE(medreq_doseinstruc_doseandrate_rateratio_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRatio/denominator/code
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/value
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/unit
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/system
             COALESCE(medreq_doseinstruc_doseandrate_raterange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/low/code
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/value
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/unit
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/system
             COALESCE(medreq_doseinstruc_doseandrate_raterange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateRange/high/code
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/value
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/unit
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/system
             COALESCE(medreq_doseinstruc_doseandrate_ratequantity_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/doseAndRate/rateQuantity/code
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/value
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/comparator
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/unit
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/system
             COALESCE(medreq_doseinstruc_maxdoseperperiod_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/numerator/code
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/value
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/comparator
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/unit
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/system
             COALESCE(medreq_doseinstruc_maxdoseperperiod_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerPeriod/denominator/code
             COALESCE(medreq_doseinstruc_maxdoseperadministration_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/value
             COALESCE(medreq_doseinstruc_maxdoseperadministration_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/unit
             COALESCE(medreq_doseinstruc_maxdoseperadministration_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/system
             COALESCE(medreq_doseinstruc_maxdoseperadministration_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerAdministration/code
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_value::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/value
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/unit
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_system::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/system
             COALESCE(medreq_doseinstruc_maxdoseperlifetime_code::TEXT, '#NULL#') || '|||' || -- hash from: dosageInstruction/maxDosePerLifetime/code
             COALESCE(medreq_substitution_reason_system::TEXT, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/system
             COALESCE(medreq_substitution_reason_version::TEXT, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/version
             COALESCE(medreq_substitution_reason_code::TEXT, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/code
             COALESCE(medreq_substitution_reason_display::TEXT, '#NULL#') || '|||' || -- hash from: substitution/reason/coding/display
             COALESCE(medreq_substitution_reason_text::TEXT, '#NULL#') || '|||' || -- hash from: substitution/reason/text
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationadministration (
  medicationadministration_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medicationadministration_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  medadm_id varchar,   -- id (varchar)
  medadm_encounter_ref varchar,   -- context/reference (varchar)
  medadm_patient_ref varchar,   -- subject/reference (varchar)
  medadm_partof_ref varchar,   -- partOf/reference (varchar)
  medadm_identifier_use varchar,   -- identifier/use (varchar)
  medadm_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  medadm_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  medadm_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  medadm_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  medadm_identifier_type_text varchar,   -- identifier/type/text (varchar)
  medadm_identifier_system varchar,   -- identifier/system (varchar)
  medadm_identifier_value varchar,   -- identifier/value (varchar)
  medadm_identifier_start timestamp,   -- identifier/start (timestamp)
  medadm_identifier_end timestamp,   -- identifier/end (timestamp)
  medadm_status varchar,   -- status (varchar)
  medadm_statusreason_system varchar,   -- statusReason/coding/system (varchar)
  medadm_statusreason_version varchar,   -- statusReason/coding/version (varchar)
  medadm_statusreason_code varchar,   -- statusReason/coding/code (varchar)
  medadm_statusreason_display varchar,   -- statusReason/coding/display (varchar)
  medadm_statusreason_text varchar,   -- statusReason/text (varchar)
  medadm_category_system varchar,   -- category/coding/system (varchar)
  medadm_category_version varchar,   -- category/coding/version (varchar)
  medadm_category_code varchar,   -- category/coding/code (varchar)
  medadm_category_display varchar,   -- category/coding/display (varchar)
  medadm_category_text varchar,   -- category/text (varchar)
  medadm_medicationreference_ref varchar,   -- medicationReference/reference (varchar)
  medadm_medicationcodeableconcept_system varchar,   -- medicationCodeableConcept/coding/system (varchar)
  medadm_medicationcodeableconcept_version varchar,   -- medicationCodeableConcept/coding/version (varchar)
  medadm_medicationcodeableconcept_code varchar,   -- medicationCodeableConcept/coding/code (varchar)
  medadm_medicationcodeableconcept_display varchar,   -- medicationCodeableConcept/coding/display (varchar)
  medadm_medicationcodeableconcept_text varchar,   -- medicationCodeableConcept/text (varchar)
  medadm_supportinginformation_ref varchar,   -- supportingInformation/reference (varchar)
  medadm_supportinginformation_type varchar,   -- supportingInformation/type (varchar)
  medadm_supportinginformation_identifier_use varchar,   -- supportingInformation/identifier/use (varchar)
  medadm_supportinginformation_identifier_type_system varchar,   -- supportingInformation/identifier/type/coding/system (varchar)
  medadm_supportinginformation_identifier_type_version varchar,   -- supportingInformation/identifier/type/coding/version (varchar)
  medadm_supportinginformation_identifier_type_code varchar,   -- supportingInformation/identifier/type/coding/code (varchar)
  medadm_supportinginformation_identifier_type_display varchar,   -- supportingInformation/identifier/type/coding/display (varchar)
  medadm_supportinginformation_identifier_type_text varchar,   -- supportingInformation/identifier/type/text (varchar)
  medadm_supportinginformation_display varchar,   -- supportingInformation/display (varchar)
  medadm_effectivedatetime timestamp,   -- effectiveDateTime (timestamp)
  medadm_effectiveperiod_start timestamp,   -- effectivePeriod/start (timestamp)
  medadm_effectiveperiod_end timestamp,   -- effectivePeriod/end (timestamp)
  medadm_performer_function_system varchar,   -- performer/function/coding/system (varchar)
  medadm_performer_function_version varchar,   -- performer/function/coding/version (varchar)
  medadm_performer_function_code varchar,   -- performer/function/coding/code (varchar)
  medadm_performer_function_display varchar,   -- performer/function/coding/display (varchar)
  medadm_performer_function_text varchar,   -- performer/function/text (varchar)
  medadm_reasoncode_system varchar,   -- reasonCode/coding/system (varchar)
  medadm_reasoncode_version varchar,   -- reasonCode/coding/version (varchar)
  medadm_reasoncode_code varchar,   -- reasonCode/coding/code (varchar)
  medadm_reasoncode_display varchar,   -- reasonCode/coding/display (varchar)
  medadm_reasoncode_text varchar,   -- reasonCode/text (varchar)
  medadm_reasonreference_ref varchar,   -- reasonReference/reference (varchar)
  medadm_reasonreference_type varchar,   -- reasonReference/type (varchar)
  medadm_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  medadm_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  medadm_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  medadm_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  medadm_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  medadm_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  medadm_reasonreference_display varchar,   -- reasonReference/display (varchar)
  medadm_request_ref varchar,   -- request/reference (varchar)
  medadm_note_authorstring varchar,   -- note/authorString (varchar)
  medadm_note_authorreference_ref varchar,   -- note/authorReference/reference (varchar)
  medadm_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  medadm_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  medadm_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  medadm_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  medadm_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  medadm_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  medadm_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  medadm_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  medadm_note_time timestamp,   -- note/time (timestamp)
  medadm_note_text varchar,   -- note/text (varchar)
  medadm_dosage_text varchar,   -- dosage/text (varchar)
  medadm_dosage_site_system varchar,   -- dosage/site/coding/system (varchar)
  medadm_dosage_site_version varchar,   -- dosage/site/coding/version (varchar)
  medadm_dosage_site_code varchar,   -- dosage/site/coding/code (varchar)
  medadm_dosage_site_display varchar,   -- dosage/site/coding/display (varchar)
  medadm_dosage_site_text varchar,   -- dosage/site/text (varchar)
  medadm_dosage_route_system varchar,   -- dosage/route/coding/system (varchar)
  medadm_dosage_route_version varchar,   -- dosage/route/coding/version (varchar)
  medadm_dosage_route_code varchar,   -- dosage/route/coding/code (varchar)
  medadm_dosage_route_display varchar,   -- dosage/route/coding/display (varchar)
  medadm_dosage_route_text varchar,   -- dosage/route/text (varchar)
  medadm_dosage_method_system varchar,   -- dosage/method/coding/system (varchar)
  medadm_dosage_method_version varchar,   -- dosage/method/coding/version (varchar)
  medadm_dosage_method_code varchar,   -- dosage/method/coding/code (varchar)
  medadm_dosage_method_display varchar,   -- dosage/method/coding/display (varchar)
  medadm_dosage_method_text varchar,   -- dosage/method/text (varchar)
  medadm_dosage_dose_value double precision,   -- dosage/dose/value (double precision)
  medadm_dosage_dose_unit varchar,   -- dosage/dose/unit (varchar)
  medadm_dosage_dose_system varchar,   -- dosage/dose/system (varchar)
  medadm_dosage_dose_code varchar,   -- dosage/dose/code (varchar)
  medadm_dosage_rateratio_numerator_value double precision,   -- dosage/rateRatio/numerator/value (double precision)
  medadm_dosage_rateratio_numerator_comparator varchar,   -- dosage/rateRatio/numerator/comparator (varchar)
  medadm_dosage_rateratio_numerator_unit varchar,   -- dosage/rateRatio/numerator/unit (varchar)
  medadm_dosage_rateratio_numerator_system varchar,   -- dosage/rateRatio/numerator/system (varchar)
  medadm_dosage_rateratio_numerator_code varchar,   -- dosage/rateRatio/numerator/code (varchar)
  medadm_dosage_rateratio_denominator_value double precision,   -- dosage/rateRatio/denominator/value (double precision)
  medadm_dosage_rateratio_denominator_comparator varchar,   -- dosage/rateRatio/denominator/comparator (varchar)
  medadm_dosage_rateratio_denominator_unit varchar,   -- dosage/rateRatio/denominator/unit (varchar)
  medadm_dosage_rateratio_denominator_system varchar,   -- dosage/rateRatio/denominator/system (varchar)
  medadm_dosage_rateratio_denominator_code varchar,   -- dosage/rateRatio/denominator/code (varchar)
  medadm_dosage_ratequantity_value double precision,   -- dosage/rateQuantity/value (double precision)
  medadm_dosage_ratequantity_unit varchar,   -- dosage/rateQuantity/unit (varchar)
  medadm_dosage_ratequantity_system varchar,   -- dosage/rateQuantity/system (varchar)
  medadm_dosage_ratequantity_code varchar,   -- dosage/rateQuantity/code (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(medadm_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(medadm_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: context/reference
             COALESCE(medadm_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(medadm_partof_ref::TEXT, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(medadm_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(medadm_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(medadm_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(medadm_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(medadm_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(medadm_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(medadm_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(medadm_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(medadm_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(medadm_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(medadm_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(medadm_statusreason_system::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(medadm_statusreason_version::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(medadm_statusreason_code::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(medadm_statusreason_display::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(medadm_statusreason_text::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(medadm_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(medadm_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(medadm_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(medadm_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(medadm_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(medadm_medicationreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: medicationReference/reference
             COALESCE(medadm_medicationcodeableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/system
             COALESCE(medadm_medicationcodeableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/version
             COALESCE(medadm_medicationcodeableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/code
             COALESCE(medadm_medicationcodeableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/display
             COALESCE(medadm_medicationcodeableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/text
             COALESCE(medadm_supportinginformation_ref::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/reference
             COALESCE(medadm_supportinginformation_type::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/type
             COALESCE(medadm_supportinginformation_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/use
             COALESCE(medadm_supportinginformation_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/system
             COALESCE(medadm_supportinginformation_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/version
             COALESCE(medadm_supportinginformation_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/code
             COALESCE(medadm_supportinginformation_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/coding/display
             COALESCE(medadm_supportinginformation_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/identifier/type/text
             COALESCE(medadm_supportinginformation_display::TEXT, '#NULL#') || '|||' || -- hash from: supportingInformation/display
             COALESCE(medadm_effectivedatetime::TEXT, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(medadm_effectiveperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: effectivePeriod/start
             COALESCE(medadm_effectiveperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: effectivePeriod/end
             COALESCE(medadm_performer_function_system::TEXT, '#NULL#') || '|||' || -- hash from: performer/function/coding/system
             COALESCE(medadm_performer_function_version::TEXT, '#NULL#') || '|||' || -- hash from: performer/function/coding/version
             COALESCE(medadm_performer_function_code::TEXT, '#NULL#') || '|||' || -- hash from: performer/function/coding/code
             COALESCE(medadm_performer_function_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/function/coding/display
             COALESCE(medadm_performer_function_text::TEXT, '#NULL#') || '|||' || -- hash from: performer/function/text
             COALESCE(medadm_reasoncode_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(medadm_reasoncode_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(medadm_reasoncode_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(medadm_reasoncode_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(medadm_reasoncode_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(medadm_reasonreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(medadm_reasonreference_type::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(medadm_reasonreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(medadm_reasonreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(medadm_reasonreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(medadm_reasonreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(medadm_reasonreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(medadm_reasonreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(medadm_reasonreference_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(medadm_request_ref::TEXT, '#NULL#') || '|||' || -- hash from: request/reference
             COALESCE(medadm_note_authorstring::TEXT, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(medadm_note_authorreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(medadm_note_authorreference_type::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(medadm_note_authorreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(medadm_note_authorreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(medadm_note_authorreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(medadm_note_authorreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(medadm_note_authorreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(medadm_note_authorreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(medadm_note_authorreference_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(medadm_note_time::TEXT, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(medadm_note_text::TEXT, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(medadm_dosage_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/text
             COALESCE(medadm_dosage_site_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/system
             COALESCE(medadm_dosage_site_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/version
             COALESCE(medadm_dosage_site_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/code
             COALESCE(medadm_dosage_site_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/display
             COALESCE(medadm_dosage_site_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/text
             COALESCE(medadm_dosage_route_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/system
             COALESCE(medadm_dosage_route_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/version
             COALESCE(medadm_dosage_route_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/code
             COALESCE(medadm_dosage_route_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/display
             COALESCE(medadm_dosage_route_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/text
             COALESCE(medadm_dosage_method_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/system
             COALESCE(medadm_dosage_method_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/version
             COALESCE(medadm_dosage_method_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/code
             COALESCE(medadm_dosage_method_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/display
             COALESCE(medadm_dosage_method_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/text
             COALESCE(medadm_dosage_dose_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/dose/value
             COALESCE(medadm_dosage_dose_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/dose/unit
             COALESCE(medadm_dosage_dose_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/dose/system
             COALESCE(medadm_dosage_dose_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/dose/code
             COALESCE(medadm_dosage_rateratio_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/value
             COALESCE(medadm_dosage_rateratio_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/comparator
             COALESCE(medadm_dosage_rateratio_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/unit
             COALESCE(medadm_dosage_rateratio_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/system
             COALESCE(medadm_dosage_rateratio_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/numerator/code
             COALESCE(medadm_dosage_rateratio_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/value
             COALESCE(medadm_dosage_rateratio_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/comparator
             COALESCE(medadm_dosage_rateratio_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/unit
             COALESCE(medadm_dosage_rateratio_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/system
             COALESCE(medadm_dosage_rateratio_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateRatio/denominator/code
             COALESCE(medadm_dosage_ratequantity_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/value
             COALESCE(medadm_dosage_ratequantity_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/unit
             COALESCE(medadm_dosage_ratequantity_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/system
             COALESCE(medadm_dosage_ratequantity_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/rateQuantity/code
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationstatement (
  medicationstatement_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  medicationstatement_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  medstat_id varchar,   -- id (varchar)
  medstat_identifier_use varchar,   -- identifier/use (varchar)
  medstat_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  medstat_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  medstat_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  medstat_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  medstat_identifier_type_text varchar,   -- identifier/type/text (varchar)
  medstat_identifier_system varchar,   -- identifier/system (varchar)
  medstat_identifier_value varchar,   -- identifier/value (varchar)
  medstat_identifier_start timestamp,   -- identifier/start (timestamp)
  medstat_identifier_end timestamp,   -- identifier/end (timestamp)
  medstat_encounter_ref varchar,   -- context/reference (varchar)
  medstat_patient_ref varchar,   -- subject/reference (varchar)
  medstat_partof_ref varchar,   -- partOf/reference (varchar)
  medstat_basedon_ref varchar,   -- basedOn/reference (varchar)
  medstat_basedon_type varchar,   -- basedOn/type (varchar)
  medstat_basedon_identifier_use varchar,   -- basedOn/identifier/use (varchar)
  medstat_basedon_identifier_type_system varchar,   -- basedOn/identifier/type/coding/system (varchar)
  medstat_basedon_identifier_type_version varchar,   -- basedOn/identifier/type/coding/version (varchar)
  medstat_basedon_identifier_type_code varchar,   -- basedOn/identifier/type/coding/code (varchar)
  medstat_basedon_identifier_type_display varchar,   -- basedOn/identifier/type/coding/display (varchar)
  medstat_basedon_identifier_type_text varchar,   -- basedOn/identifier/type/text (varchar)
  medstat_basedon_display varchar,   -- basedOn/display (varchar)
  medstat_status varchar,   -- status (varchar)
  medstat_statusreason_system varchar,   -- statusReason/coding/system (varchar)
  medstat_statusreason_version varchar,   -- statusReason/coding/version (varchar)
  medstat_statusreason_code varchar,   -- statusReason/coding/code (varchar)
  medstat_statusreason_display varchar,   -- statusReason/coding/display (varchar)
  medstat_statusreason_text varchar,   -- statusReason/text (varchar)
  medstat_category_system varchar,   -- category/coding/system (varchar)
  medstat_category_version varchar,   -- category/coding/version (varchar)
  medstat_category_code varchar,   -- category/coding/code (varchar)
  medstat_category_display varchar,   -- category/coding/display (varchar)
  medstat_category_text varchar,   -- category/text (varchar)
  medstat_medicationreference_ref varchar,   -- medicationReference/reference (varchar)
  medstat_medicationcodeableconcept_system varchar,   -- medicationCodeableConcept/coding/system (varchar)
  medstat_medicationcodeableconcept_version varchar,   -- medicationCodeableConcept/coding/version (varchar)
  medstat_medicationcodeableconcept_code varchar,   -- medicationCodeableConcept/coding/code (varchar)
  medstat_medicationcodeableconcept_display varchar,   -- medicationCodeableConcept/coding/display (varchar)
  medstat_medicationcodeableconcept_text varchar,   -- medicationCodeableConcept/text (varchar)
  medstat_effectivedatetime timestamp,   -- effectiveDateTime (timestamp)
  medstat_effectiveperiod_start timestamp,   -- effectivePeriod/start (timestamp)
  medstat_effectiveperiod_end timestamp,   -- effectivePeriod/end (timestamp)
  medstat_dateasserted timestamp,   -- dateAsserted (timestamp)
  medstat_informationsource_ref varchar,   -- informationSource/reference (varchar)
  medstat_informationsource_type varchar,   -- informationSource/type (varchar)
  medstat_informationsource_identifier_use varchar,   -- informationSource/identifier/use (varchar)
  medstat_informationsource_identifier_type_system varchar,   -- informationSource/identifier/type/coding/system (varchar)
  medstat_informationsource_identifier_type_version varchar,   -- informationSource/identifier/type/coding/version (varchar)
  medstat_informationsource_identifier_type_code varchar,   -- informationSource/identifier/type/coding/code (varchar)
  medstat_informationsource_identifier_type_display varchar,   -- informationSource/identifier/type/coding/display (varchar)
  medstat_informationsource_identifier_type_text varchar,   -- informationSource/identifier/type/text (varchar)
  medstat_informationsource_display varchar,   -- informationSource/display (varchar)
  medstat_derivedfrom_ref varchar,   -- derivedFrom/reference (varchar)
  medstat_derivedfrom_type varchar,   -- derivedFrom/type (varchar)
  medstat_derivedfrom_identifier_use varchar,   -- derivedFrom/identifier/use (varchar)
  medstat_derivedfrom_identifier_type_system varchar,   -- derivedFrom/identifier/type/coding/system (varchar)
  medstat_derivedfrom_identifier_type_version varchar,   -- derivedFrom/identifier/type/coding/version (varchar)
  medstat_derivedfrom_identifier_type_code varchar,   -- derivedFrom/identifier/type/coding/code (varchar)
  medstat_derivedfrom_identifier_type_display varchar,   -- derivedFrom/identifier/type/coding/display (varchar)
  medstat_derivedfrom_identifier_type_text varchar,   -- derivedFrom/identifier/type/text (varchar)
  medstat_derivedfrom_display varchar,   -- derivedFrom/display (varchar)
  medstat_reasoncode_system varchar,   -- reasonCode/coding/system (varchar)
  medstat_reasoncode_version varchar,   -- reasonCode/coding/version (varchar)
  medstat_reasoncode_code varchar,   -- reasonCode/coding/code (varchar)
  medstat_reasoncode_display varchar,   -- reasonCode/coding/display (varchar)
  medstat_reasoncode_text varchar,   -- reasonCode/text (varchar)
  medstat_reasonreference_ref varchar,   -- reasonReference/reference (varchar)
  medstat_reasonreference_type varchar,   -- reasonReference/type (varchar)
  medstat_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  medstat_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  medstat_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  medstat_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  medstat_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  medstat_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  medstat_reasonreference_display varchar,   -- reasonReference/display (varchar)
  medstat_note_authorstring varchar,   -- note/authorString (varchar)
  medstat_note_authorreference_ref varchar,   -- note/authorReference/reference (varchar)
  medstat_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  medstat_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  medstat_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  medstat_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  medstat_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  medstat_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  medstat_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  medstat_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  medstat_note_time timestamp,   -- note/time (timestamp)
  medstat_note_text varchar,   -- note/text (varchar)
  medstat_dosage_sequence int,   -- dosage/sequence (int)
  medstat_dosage_text varchar,   -- dosage/text (varchar)
  medstat_dosage_additionalinstruction_system varchar,   -- dosage/additionalInstruction/coding/system (varchar)
  medstat_dosage_additionalinstruction_version varchar,   -- dosage/additionalInstruction/coding/version (varchar)
  medstat_dosage_additionalinstruction_code varchar,   -- dosage/additionalInstruction/coding/code (varchar)
  medstat_dosage_additionalinstruction_display varchar,   -- dosage/additionalInstruction/coding/display (varchar)
  medstat_dosage_additionalinstruction_text varchar,   -- dosage/additionalInstruction/text (varchar)
  medstat_dosage_patientinstruction varchar,   -- dosage/patientInstruction (varchar)
  medstat_dosage_timing_event timestamp,   -- dosage/timing/event (timestamp)
  medstat_dosage_timing_repeat_boundsduration_value double precision,   -- dosage/timing/repeat/boundsDuration/value (double precision)
  medstat_dosage_timing_repeat_boundsduration_comparator varchar,   -- dosage/timing/repeat/boundsDuration/comparator (varchar)
  medstat_dosage_timing_repeat_boundsduration_unit varchar,   -- dosage/timing/repeat/boundsDuration/unit (varchar)
  medstat_dosage_timing_repeat_boundsduration_system varchar,   -- dosage/timing/repeat/boundsDuration/system (varchar)
  medstat_dosage_timing_repeat_boundsduration_code varchar,   -- dosage/timing/repeat/boundsDuration/code (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_value double precision,   -- dosage/timing/repeat/boundsRange/low/value (double precision)
  medstat_dosage_timing_repeat_boundsrange_low_unit varchar,   -- dosage/timing/repeat/boundsRange/low/unit (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_system varchar,   -- dosage/timing/repeat/boundsRange/low/system (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_code varchar,   -- dosage/timing/repeat/boundsRange/low/code (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_value double precision,   -- dosage/timing/repeat/boundsRange/high/value (double precision)
  medstat_dosage_timing_repeat_boundsrange_high_unit varchar,   -- dosage/timing/repeat/boundsRange/high/unit (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_system varchar,   -- dosage/timing/repeat/boundsRange/high/system (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_code varchar,   -- dosage/timing/repeat/boundsRange/high/code (varchar)
  medstat_dosage_timing_repeat_boundsperiod_start timestamp,   -- dosage/timing/repeat/boundsPeriod/start (timestamp)
  medstat_dosage_timing_repeat_boundsperiod_end timestamp,   -- dosage/timing/repeat/boundsPeriod/end (timestamp)
  medstat_dosage_timing_repeat_count int,   -- dosage/timing/repeat/count (int)
  medstat_dosage_timing_repeat_countmax int,   -- dosage/timing/repeat/countMax (int)
  medstat_dosage_timing_repeat_duration double precision,   -- dosage/timing/repeat/duration (double precision)
  medstat_dosage_timing_repeat_durationmax double precision,   -- dosage/timing/repeat/durationMax (double precision)
  medstat_dosage_timing_repeat_durationunit varchar,   -- dosage/timing/repeat/durationUnit (varchar)
  medstat_dosage_timing_repeat_frequency int,   -- dosage/timing/repeat/frequency (int)
  medstat_dosage_timing_repeat_frequencymax int,   -- dosage/timing/repeat/frequencyMax (int)
  medstat_dosage_timing_repeat_period double precision,   -- dosage/timing/repeat/period (double precision)
  medstat_dosage_timing_repeat_periodmax double precision,   -- dosage/timing/repeat/periodMax (double precision)
  medstat_dosage_timing_repeat_periodunit varchar,   -- dosage/timing/repeat/periodUnit (varchar)
  medstat_dosage_timing_repeat_dayofweek varchar,   -- dosage/timing/repeat/dayOfWeek (varchar)
  medstat_dosage_timing_repeat_timeofday time,   -- dosage/timing/repeat/timeOfDay (time)
  medstat_dosage_timing_repeat_when varchar,   -- dosage/timing/repeat/when (varchar)
  medstat_dosage_timing_repeat_offset int,   -- dosage/timing/repeat/offset (int)
  medstat_dosage_timing_code_system varchar,   -- dosage/timing/code/coding/system (varchar)
  medstat_dosage_timing_code_version varchar,   -- dosage/timing/code/coding/version (varchar)
  medstat_dosage_timing_code_code varchar,   -- dosage/timing/code/coding/code (varchar)
  medstat_dosage_timing_code_display varchar,   -- dosage/timing/code/coding/display (varchar)
  medstat_dosage_timing_code_text varchar,   -- dosage/timing/code/text (varchar)
  medstat_dosage_asneededboolean boolean,   -- dosage/asNeededBoolean (boolean)
  medstat_dosage_asneededcodeableconcept_system varchar,   -- dosage/asNeededCodeableConcept/coding/system (varchar)
  medstat_dosage_asneededcodeableconcept_version varchar,   -- dosage/asNeededCodeableConcept/coding/version (varchar)
  medstat_dosage_asneededcodeableconcept_code varchar,   -- dosage/asNeededCodeableConcept/coding/code (varchar)
  medstat_dosage_asneededcodeableconcept_display varchar,   -- dosage/asNeededCodeableConcept/coding/display (varchar)
  medstat_dosage_asneededcodeableconcept_text varchar,   -- dosage/asNeededCodeableConcept/text (varchar)
  medstat_dosage_site_system varchar,   -- dosage/site/coding/system (varchar)
  medstat_dosage_site_version varchar,   -- dosage/site/coding/version (varchar)
  medstat_dosage_site_code varchar,   -- dosage/site/coding/code (varchar)
  medstat_dosage_site_display varchar,   -- dosage/site/coding/display (varchar)
  medstat_dosage_site_text varchar,   -- dosage/site/text (varchar)
  medstat_dosage_route_system varchar,   -- dosage/route/coding/system (varchar)
  medstat_dosage_route_version varchar,   -- dosage/route/coding/version (varchar)
  medstat_dosage_route_code varchar,   -- dosage/route/coding/code (varchar)
  medstat_dosage_route_display varchar,   -- dosage/route/coding/display (varchar)
  medstat_dosage_route_text varchar,   -- dosage/route/text (varchar)
  medstat_dosage_method_system varchar,   -- dosage/method/coding/system (varchar)
  medstat_dosage_method_version varchar,   -- dosage/method/coding/version (varchar)
  medstat_dosage_method_code varchar,   -- dosage/method/coding/code (varchar)
  medstat_dosage_method_display varchar,   -- dosage/method/coding/display (varchar)
  medstat_dosage_method_text varchar,   -- dosage/method/text (varchar)
  medstat_dosage_doseandrate_type_system varchar,   -- dosage/doseAndRate/type/coding/system (varchar)
  medstat_dosage_doseandrate_type_version varchar,   -- dosage/doseAndRate/type/coding/version (varchar)
  medstat_dosage_doseandrate_type_code varchar,   -- dosage/doseAndRate/type/coding/code (varchar)
  medstat_dosage_doseandrate_type_display varchar,   -- dosage/doseAndRate/type/coding/display (varchar)
  medstat_dosage_doseandrate_type_text varchar,   -- dosage/doseAndRate/type/text (varchar)
  medstat_dosage_doseandrate_doserange_low_value double precision,   -- dosage/doseAndRate/doseRange/low/value (double precision)
  medstat_dosage_doseandrate_doserange_low_unit varchar,   -- dosage/doseAndRate/doseRange/low/unit (varchar)
  medstat_dosage_doseandrate_doserange_low_system varchar,   -- dosage/doseAndRate/doseRange/low/system (varchar)
  medstat_dosage_doseandrate_doserange_low_code varchar,   -- dosage/doseAndRate/doseRange/low/code (varchar)
  medstat_dosage_doseandrate_doserange_high_value double precision,   -- dosage/doseAndRate/doseRange/high/value (double precision)
  medstat_dosage_doseandrate_doserange_high_unit varchar,   -- dosage/doseAndRate/doseRange/high/unit (varchar)
  medstat_dosage_doseandrate_doserange_high_system varchar,   -- dosage/doseAndRate/doseRange/high/system (varchar)
  medstat_dosage_doseandrate_doserange_high_code varchar,   -- dosage/doseAndRate/doseRange/high/code (varchar)
  medstat_dosage_doseandrate_dosequantity_value double precision,   -- dosage/doseAndRate/doseQuantity/value (double precision)
  medstat_dosage_doseandrate_dosequantity_comparator varchar,   -- dosage/doseAndRate/doseQuantity/comparator (varchar)
  medstat_dosage_doseandrate_dosequantity_unit varchar,   -- dosage/doseAndRate/doseQuantity/unit (varchar)
  medstat_dosage_doseandrate_dosequantity_system varchar,   -- dosage/doseAndRate/doseQuantity/system (varchar)
  medstat_dosage_doseandrate_dosequantity_code varchar,   -- dosage/doseAndRate/doseQuantity/code (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_value double precision,   -- dosage/doseAndRate/rateRatio/numerator/value (double precision)
  medstat_dosage_doseandrate_rateratio_numerator_comparator varchar,   -- dosage/doseAndRate/rateRatio/numerator/comparator (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_unit varchar,   -- dosage/doseAndRate/rateRatio/numerator/unit (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_system varchar,   -- dosage/doseAndRate/rateRatio/numerator/system (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_code varchar,   -- dosage/doseAndRate/rateRatio/numerator/code (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_value double precision,   -- dosage/doseAndRate/rateRatio/denominator/value (double precision)
  medstat_dosage_doseandrate_rateratio_denominator_comparator varchar,   -- dosage/doseAndRate/rateRatio/denominator/comparator (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_unit varchar,   -- dosage/doseAndRate/rateRatio/denominator/unit (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_system varchar,   -- dosage/doseAndRate/rateRatio/denominator/system (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_code varchar,   -- dosage/doseAndRate/rateRatio/denominator/code (varchar)
  medstat_dosage_doseandrate_raterange_low_value double precision,   -- dosage/doseAndRate/rateRange/low/value (double precision)
  medstat_dosage_doseandrate_raterange_low_unit varchar,   -- dosage/doseAndRate/rateRange/low/unit (varchar)
  medstat_dosage_doseandrate_raterange_low_system varchar,   -- dosage/doseAndRate/rateRange/low/system (varchar)
  medstat_dosage_doseandrate_raterange_low_code varchar,   -- dosage/doseAndRate/rateRange/low/code (varchar)
  medstat_dosage_doseandrate_raterange_high_value double precision,   -- dosage/doseAndRate/rateRange/high/value (double precision)
  medstat_dosage_doseandrate_raterange_high_unit varchar,   -- dosage/doseAndRate/rateRange/high/unit (varchar)
  medstat_dosage_doseandrate_raterange_high_system varchar,   -- dosage/doseAndRate/rateRange/high/system (varchar)
  medstat_dosage_doseandrate_raterange_high_code varchar,   -- dosage/doseAndRate/rateRange/high/code (varchar)
  medstat_dosage_doseandrate_ratequantity_value double precision,   -- dosage/doseAndRate/rateQuantity/value (double precision)
  medstat_dosage_doseandrate_ratequantity_unit varchar,   -- dosage/doseAndRate/rateQuantity/unit (varchar)
  medstat_dosage_doseandrate_ratequantity_system varchar,   -- dosage/doseAndRate/rateQuantity/system (varchar)
  medstat_dosage_doseandrate_ratequantity_code varchar,   -- dosage/doseAndRate/rateQuantity/code (varchar)
  medstat_dosage_maxdoseperperiod_numerator_value double precision,   -- dosage/maxDosePerPeriod/numerator/value (double precision)
  medstat_dosage_maxdoseperperiod_numerator_comparator varchar,   -- dosage/maxDosePerPeriod/numerator/comparator (varchar)
  medstat_dosage_maxdoseperperiod_numerator_unit varchar,   -- dosage/maxDosePerPeriod/numerator/unit (varchar)
  medstat_dosage_maxdoseperperiod_numerator_system varchar,   -- dosage/maxDosePerPeriod/numerator/system (varchar)
  medstat_dosage_maxdoseperperiod_numerator_code varchar,   -- dosage/maxDosePerPeriod/numerator/code (varchar)
  medstat_dosage_maxdoseperperiod_denominator_value double precision,   -- dosage/maxDosePerPeriod/denominator/value (double precision)
  medstat_dosage_maxdoseperperiod_denominator_comparator varchar,   -- dosage/maxDosePerPeriod/denominator/comparator (varchar)
  medstat_dosage_maxdoseperperiod_denominator_unit varchar,   -- dosage/maxDosePerPeriod/denominator/unit (varchar)
  medstat_dosage_maxdoseperperiod_denominator_system varchar,   -- dosage/maxDosePerPeriod/denominator/system (varchar)
  medstat_dosage_maxdoseperperiod_denominator_code varchar,   -- dosage/maxDosePerPeriod/denominator/code (varchar)
  medstat_dosage_maxdoseperadministration_value double precision,   -- dosage/maxDosePerAdministration/value (double precision)
  medstat_dosage_maxdoseperadministration_unit varchar,   -- dosage/maxDosePerAdministration/unit (varchar)
  medstat_dosage_maxdoseperadministration_system varchar,   -- dosage/maxDosePerAdministration/system (varchar)
  medstat_dosage_maxdoseperadministration_code varchar,   -- dosage/maxDosePerAdministration/code (varchar)
  medstat_dosage_maxdoseperlifetime_value double precision,   -- dosage/maxDosePerLifetime/value (double precision)
  medstat_dosage_maxdoseperlifetime_unit varchar,   -- dosage/maxDosePerLifetime/unit (varchar)
  medstat_dosage_maxdoseperlifetime_system varchar,   -- dosage/maxDosePerLifetime/system (varchar)
  medstat_dosage_maxdoseperlifetime_code varchar,   -- dosage/maxDosePerLifetime/code (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(medstat_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(medstat_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(medstat_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(medstat_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(medstat_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(medstat_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(medstat_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(medstat_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(medstat_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(medstat_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(medstat_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(medstat_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: context/reference
             COALESCE(medstat_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(medstat_partof_ref::TEXT, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(medstat_basedon_ref::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(medstat_basedon_type::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(medstat_basedon_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(medstat_basedon_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(medstat_basedon_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(medstat_basedon_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(medstat_basedon_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(medstat_basedon_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(medstat_basedon_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(medstat_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(medstat_statusreason_system::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(medstat_statusreason_version::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(medstat_statusreason_code::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(medstat_statusreason_display::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(medstat_statusreason_text::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(medstat_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(medstat_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(medstat_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(medstat_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(medstat_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(medstat_medicationreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: medicationReference/reference
             COALESCE(medstat_medicationcodeableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/system
             COALESCE(medstat_medicationcodeableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/version
             COALESCE(medstat_medicationcodeableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/code
             COALESCE(medstat_medicationcodeableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/coding/display
             COALESCE(medstat_medicationcodeableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: medicationCodeableConcept/text
             COALESCE(medstat_effectivedatetime::TEXT, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(medstat_effectiveperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: effectivePeriod/start
             COALESCE(medstat_effectiveperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: effectivePeriod/end
             COALESCE(medstat_dateasserted::TEXT, '#NULL#') || '|||' || -- hash from: dateAsserted
             COALESCE(medstat_informationsource_ref::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/reference
             COALESCE(medstat_informationsource_type::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/type
             COALESCE(medstat_informationsource_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/identifier/use
             COALESCE(medstat_informationsource_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/system
             COALESCE(medstat_informationsource_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/version
             COALESCE(medstat_informationsource_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/code
             COALESCE(medstat_informationsource_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/coding/display
             COALESCE(medstat_informationsource_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/identifier/type/text
             COALESCE(medstat_informationsource_display::TEXT, '#NULL#') || '|||' || -- hash from: informationSource/display
             COALESCE(medstat_derivedfrom_ref::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/reference
             COALESCE(medstat_derivedfrom_type::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/type
             COALESCE(medstat_derivedfrom_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/use
             COALESCE(medstat_derivedfrom_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/system
             COALESCE(medstat_derivedfrom_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/version
             COALESCE(medstat_derivedfrom_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/code
             COALESCE(medstat_derivedfrom_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/coding/display
             COALESCE(medstat_derivedfrom_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/identifier/type/text
             COALESCE(medstat_derivedfrom_display::TEXT, '#NULL#') || '|||' || -- hash from: derivedFrom/display
             COALESCE(medstat_reasoncode_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(medstat_reasoncode_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(medstat_reasoncode_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(medstat_reasoncode_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(medstat_reasoncode_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(medstat_reasonreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(medstat_reasonreference_type::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(medstat_reasonreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(medstat_reasonreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(medstat_reasonreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(medstat_reasonreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(medstat_reasonreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(medstat_reasonreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(medstat_reasonreference_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(medstat_note_authorstring::TEXT, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(medstat_note_authorreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(medstat_note_authorreference_type::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(medstat_note_authorreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(medstat_note_authorreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(medstat_note_authorreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(medstat_note_authorreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(medstat_note_authorreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(medstat_note_authorreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(medstat_note_authorreference_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(medstat_note_time::TEXT, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(medstat_note_text::TEXT, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(medstat_dosage_sequence::TEXT, '#NULL#') || '|||' || -- hash from: dosage/sequence
             COALESCE(medstat_dosage_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/text
             COALESCE(medstat_dosage_additionalinstruction_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/system
             COALESCE(medstat_dosage_additionalinstruction_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/version
             COALESCE(medstat_dosage_additionalinstruction_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/code
             COALESCE(medstat_dosage_additionalinstruction_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/coding/display
             COALESCE(medstat_dosage_additionalinstruction_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/additionalInstruction/text
             COALESCE(medstat_dosage_patientinstruction::TEXT, '#NULL#') || '|||' || -- hash from: dosage/patientInstruction
             COALESCE(medstat_dosage_timing_event::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/event
             COALESCE(medstat_dosage_timing_repeat_boundsduration_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/value
             COALESCE(medstat_dosage_timing_repeat_boundsduration_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/comparator
             COALESCE(medstat_dosage_timing_repeat_boundsduration_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/unit
             COALESCE(medstat_dosage_timing_repeat_boundsduration_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/system
             COALESCE(medstat_dosage_timing_repeat_boundsduration_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsDuration/code
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/value
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/unit
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/system
             COALESCE(medstat_dosage_timing_repeat_boundsrange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/low/code
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/value
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/unit
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/system
             COALESCE(medstat_dosage_timing_repeat_boundsrange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsRange/high/code
             COALESCE(medstat_dosage_timing_repeat_boundsperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsPeriod/start
             COALESCE(medstat_dosage_timing_repeat_boundsperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/boundsPeriod/end
             COALESCE(medstat_dosage_timing_repeat_count::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/count
             COALESCE(medstat_dosage_timing_repeat_countmax::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/countMax
             COALESCE(medstat_dosage_timing_repeat_duration::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/duration
             COALESCE(medstat_dosage_timing_repeat_durationmax::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/durationMax
             COALESCE(medstat_dosage_timing_repeat_durationunit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/durationUnit
             COALESCE(medstat_dosage_timing_repeat_frequency::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/frequency
             COALESCE(medstat_dosage_timing_repeat_frequencymax::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/frequencyMax
             COALESCE(medstat_dosage_timing_repeat_period::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/period
             COALESCE(medstat_dosage_timing_repeat_periodmax::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/periodMax
             COALESCE(medstat_dosage_timing_repeat_periodunit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/periodUnit
             COALESCE(medstat_dosage_timing_repeat_dayofweek::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/dayOfWeek
             COALESCE(medstat_dosage_timing_repeat_timeofday::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/timeOfDay
             COALESCE(medstat_dosage_timing_repeat_when::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/when
             COALESCE(medstat_dosage_timing_repeat_offset::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/repeat/offset
             COALESCE(medstat_dosage_timing_code_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/system
             COALESCE(medstat_dosage_timing_code_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/version
             COALESCE(medstat_dosage_timing_code_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/code
             COALESCE(medstat_dosage_timing_code_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/code/coding/display
             COALESCE(medstat_dosage_timing_code_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/timing/code/text
             COALESCE(medstat_dosage_asneededboolean::TEXT, '#NULL#') || '|||' || -- hash from: dosage/asNeededBoolean
             COALESCE(medstat_dosage_asneededcodeableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/system
             COALESCE(medstat_dosage_asneededcodeableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/version
             COALESCE(medstat_dosage_asneededcodeableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/code
             COALESCE(medstat_dosage_asneededcodeableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/coding/display
             COALESCE(medstat_dosage_asneededcodeableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/asNeededCodeableConcept/text
             COALESCE(medstat_dosage_site_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/system
             COALESCE(medstat_dosage_site_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/version
             COALESCE(medstat_dosage_site_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/code
             COALESCE(medstat_dosage_site_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/coding/display
             COALESCE(medstat_dosage_site_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/site/text
             COALESCE(medstat_dosage_route_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/system
             COALESCE(medstat_dosage_route_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/version
             COALESCE(medstat_dosage_route_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/code
             COALESCE(medstat_dosage_route_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/coding/display
             COALESCE(medstat_dosage_route_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/route/text
             COALESCE(medstat_dosage_method_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/system
             COALESCE(medstat_dosage_method_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/version
             COALESCE(medstat_dosage_method_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/code
             COALESCE(medstat_dosage_method_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/coding/display
             COALESCE(medstat_dosage_method_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/method/text
             COALESCE(medstat_dosage_doseandrate_type_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/system
             COALESCE(medstat_dosage_doseandrate_type_version::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/version
             COALESCE(medstat_dosage_doseandrate_type_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/code
             COALESCE(medstat_dosage_doseandrate_type_display::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/coding/display
             COALESCE(medstat_dosage_doseandrate_type_text::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/type/text
             COALESCE(medstat_dosage_doseandrate_doserange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/value
             COALESCE(medstat_dosage_doseandrate_doserange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/unit
             COALESCE(medstat_dosage_doseandrate_doserange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/system
             COALESCE(medstat_dosage_doseandrate_doserange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/low/code
             COALESCE(medstat_dosage_doseandrate_doserange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/value
             COALESCE(medstat_dosage_doseandrate_doserange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/unit
             COALESCE(medstat_dosage_doseandrate_doserange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/system
             COALESCE(medstat_dosage_doseandrate_doserange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseRange/high/code
             COALESCE(medstat_dosage_doseandrate_dosequantity_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/value
             COALESCE(medstat_dosage_doseandrate_dosequantity_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/comparator
             COALESCE(medstat_dosage_doseandrate_dosequantity_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/unit
             COALESCE(medstat_dosage_doseandrate_dosequantity_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/system
             COALESCE(medstat_dosage_doseandrate_dosequantity_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/doseQuantity/code
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/value
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/comparator
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/unit
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/system
             COALESCE(medstat_dosage_doseandrate_rateratio_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/numerator/code
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/value
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/comparator
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/unit
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/system
             COALESCE(medstat_dosage_doseandrate_rateratio_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRatio/denominator/code
             COALESCE(medstat_dosage_doseandrate_raterange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/value
             COALESCE(medstat_dosage_doseandrate_raterange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/unit
             COALESCE(medstat_dosage_doseandrate_raterange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/system
             COALESCE(medstat_dosage_doseandrate_raterange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/low/code
             COALESCE(medstat_dosage_doseandrate_raterange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/value
             COALESCE(medstat_dosage_doseandrate_raterange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/unit
             COALESCE(medstat_dosage_doseandrate_raterange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/system
             COALESCE(medstat_dosage_doseandrate_raterange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateRange/high/code
             COALESCE(medstat_dosage_doseandrate_ratequantity_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/value
             COALESCE(medstat_dosage_doseandrate_ratequantity_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/unit
             COALESCE(medstat_dosage_doseandrate_ratequantity_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/system
             COALESCE(medstat_dosage_doseandrate_ratequantity_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/doseAndRate/rateQuantity/code
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/value
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/comparator
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/unit
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/system
             COALESCE(medstat_dosage_maxdoseperperiod_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/numerator/code
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/value
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/comparator
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/unit
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/system
             COALESCE(medstat_dosage_maxdoseperperiod_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerPeriod/denominator/code
             COALESCE(medstat_dosage_maxdoseperadministration_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/value
             COALESCE(medstat_dosage_maxdoseperadministration_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/unit
             COALESCE(medstat_dosage_maxdoseperadministration_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/system
             COALESCE(medstat_dosage_maxdoseperadministration_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerAdministration/code
             COALESCE(medstat_dosage_maxdoseperlifetime_value::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/value
             COALESCE(medstat_dosage_maxdoseperlifetime_unit::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/unit
             COALESCE(medstat_dosage_maxdoseperlifetime_system::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/system
             COALESCE(medstat_dosage_maxdoseperlifetime_code::TEXT, '#NULL#') || '|||' || -- hash from: dosage/maxDosePerLifetime/code
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "observation" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.observation (
  observation_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  observation_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  obs_id varchar,   -- id (varchar)
  obs_encounter_ref varchar,   -- encounter/reference (varchar)
  obs_patient_ref varchar,   -- subject/reference (varchar)
  obs_partof_ref varchar,   -- partOf/reference (varchar)
  obs_identifier_use varchar,   -- identifier/use (varchar)
  obs_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  obs_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  obs_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  obs_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  obs_identifier_type_text varchar,   -- identifier/type/text (varchar)
  obs_identifier_system varchar,   -- identifier/system (varchar)
  obs_identifier_value varchar,   -- identifier/value (varchar)
  obs_identifier_start timestamp,   -- identifier/start (timestamp)
  obs_identifier_end timestamp,   -- identifier/end (timestamp)
  obs_basedon_ref varchar,   -- basedOn/reference (varchar)
  obs_basedon_type varchar,   -- basedOn/type (varchar)
  obs_basedon_identifier_use varchar,   -- basedOn/identifier/use (varchar)
  obs_basedon_identifier_type_system varchar,   -- basedOn/identifier/type/coding/system (varchar)
  obs_basedon_identifier_type_version varchar,   -- basedOn/identifier/type/coding/version (varchar)
  obs_basedon_identifier_type_code varchar,   -- basedOn/identifier/type/coding/code (varchar)
  obs_basedon_identifier_type_display varchar,   -- basedOn/identifier/type/coding/display (varchar)
  obs_basedon_identifier_type_text varchar,   -- basedOn/identifier/type/text (varchar)
  obs_basedon_display varchar,   -- basedOn/display (varchar)
  obs_status varchar,   -- status (varchar)
  obs_category_system varchar,   -- category/coding/system (varchar)
  obs_category_version varchar,   -- category/coding/version (varchar)
  obs_category_code varchar,   -- category/coding/code (varchar)
  obs_category_display varchar,   -- category/coding/display (varchar)
  obs_category_text varchar,   -- category/text (varchar)
  obs_code_system varchar,   -- code/coding/system (varchar)
  obs_code_version varchar,   -- code/coding/version (varchar)
  obs_code_code varchar,   -- code/coding/code (varchar)
  obs_code_display varchar,   -- code/coding/display (varchar)
  obs_code_text varchar,   -- code/text (varchar)
  obs_effectivedatetime timestamp,   -- effectiveDateTime (timestamp)
  obs_issued timestamp,   -- issued (timestamp)
  obs_valuerange_low_value double precision,   -- valueRange/low/value (double precision)
  obs_valuerange_low_unit varchar,   -- valueRange/low/unit (varchar)
  obs_valuerange_low_system varchar,   -- valueRange/low/system (varchar)
  obs_valuerange_low_code varchar,   -- valueRange/low/code (varchar)
  obs_valuerange_high_value double precision,   -- valueRange/high/value (double precision)
  obs_valuerange_high_unit varchar,   -- valueRange/high/unit (varchar)
  obs_valuerange_high_system varchar,   -- valueRange/high/system (varchar)
  obs_valuerange_high_code varchar,   -- valueRange/high/code (varchar)
  obs_valueratio_numerator_value double precision,   -- valueRatio/numerator/value (double precision)
  obs_valueratio_numerator_comparator varchar,   -- valueRatio/numerator/comparator (varchar)
  obs_valueratio_numerator_unit varchar,   -- valueRatio/numerator/unit (varchar)
  obs_valueratio_numerator_system varchar,   -- valueRatio/numerator/system (varchar)
  obs_valueratio_numerator_code varchar,   -- valueRatio/numerator/code (varchar)
  obs_valueratio_denominator_value double precision,   -- valueRatio/denominator/value (double precision)
  obs_valueratio_denominator_comparator varchar,   -- valueRatio/denominator/comparator (varchar)
  obs_valueratio_denominator_unit varchar,   -- valueRatio/denominator/unit (varchar)
  obs_valueratio_denominator_system varchar,   -- valueRatio/denominator/system (varchar)
  obs_valueratio_denominator_code varchar,   -- valueRatio/denominator/code (varchar)
  obs_valuequantity_value double precision,   -- valueQuantity/value (double precision)
  obs_valuequantity_comparator varchar,   -- valueQuantity/comparator (varchar)
  obs_valuequantity_unit varchar,   -- valueQuantity/unit (varchar)
  obs_valuequantity_system varchar,   -- valueQuantity/system (varchar)
  obs_valuequantity_code varchar,   -- valueQuantity/code (varchar)
  obs_valuecodableconcept_system varchar,   -- valueCodableConcept/coding/system (varchar)
  obs_valuecodableconcept_version varchar,   -- valueCodableConcept/coding/version (varchar)
  obs_valuecodableconcept_code varchar,   -- valueCodableConcept/coding/code (varchar)
  obs_valuecodableconcept_display varchar,   -- valueCodableConcept/coding/display (varchar)
  obs_valuecodableconcept_text varchar,   -- valueCodableConcept/text (varchar)
  obs_dataabsentreason_system varchar,   -- dataAbsentReason/coding/system (varchar)
  obs_dataabsentreason_version varchar,   -- dataAbsentReason/coding/version (varchar)
  obs_dataabsentreason_code varchar,   -- dataAbsentReason/coding/code (varchar)
  obs_dataabsentreason_display varchar,   -- dataAbsentReason/coding/display (varchar)
  obs_dataabsentreason_text varchar,   -- dataAbsentReason/text (varchar)
  obs_note_authorstring varchar,   -- note/authorString (varchar)
  obs_note_authorreference_ref varchar,   -- note/authorReference/reference (varchar)
  obs_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  obs_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  obs_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  obs_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  obs_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  obs_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  obs_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  obs_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  obs_note_time timestamp,   -- note/time (timestamp)
  obs_note_text varchar,   -- note/text (varchar)
  obs_method_system varchar,   -- method/coding/system (varchar)
  obs_method_version varchar,   -- method/coding/version (varchar)
  obs_method_code varchar,   -- method/coding/code (varchar)
  obs_method_display varchar,   -- method/coding/display (varchar)
  obs_method_text varchar,   -- method/text (varchar)
  obs_performer_ref varchar,   -- performer/reference (varchar)
  obs_performer_type varchar,   -- performer/type (varchar)
  obs_performer_identifier_use varchar,   -- performer/identifier/use (varchar)
  obs_performer_identifier_type_system varchar,   -- performer/identifier/type/coding/system (varchar)
  obs_performer_identifier_type_version varchar,   -- performer/identifier/type/coding/version (varchar)
  obs_performer_identifier_type_code varchar,   -- performer/identifier/type/coding/code (varchar)
  obs_performer_identifier_type_display varchar,   -- performer/identifier/type/coding/display (varchar)
  obs_performer_identifier_type_text varchar,   -- performer/identifier/type/text (varchar)
  obs_performer_display varchar,   -- performer/display (varchar)
  obs_referencerange_low_value double precision,   -- referenceRange/low/value (double precision)
  obs_referencerange_low_unit varchar,   -- referenceRange/low/unit (varchar)
  obs_referencerange_low_system varchar,   -- referenceRange/low/system (varchar)
  obs_referencerange_low_code varchar,   -- referenceRange/low/code (varchar)
  obs_referencerange_high_value double precision,   -- referenceRange/high/value (double precision)
  obs_referencerange_high_unit varchar,   -- referenceRange/high/unit (varchar)
  obs_referencerange_high_system varchar,   -- referenceRange/high/system (varchar)
  obs_referencerange_high_code varchar,   -- referenceRange/high/code (varchar)
  obs_referencerange_type_system varchar,   -- referenceRange/type/coding/system (varchar)
  obs_referencerange_type_version varchar,   -- referenceRange/type/coding/version (varchar)
  obs_referencerange_type_code varchar,   -- referenceRange/type/coding/code (varchar)
  obs_referencerange_type_display varchar,   -- referenceRange/type/coding/display (varchar)
  obs_referencerange_type_text varchar,   -- referenceRange/type/text (varchar)
  obs_referencerange_appliesto_system varchar,   -- referenceRange/appliesTo/coding/system (varchar)
  obs_referencerange_appliesto_version varchar,   -- referenceRange/appliesTo/coding/version (varchar)
  obs_referencerange_appliesto_code varchar,   -- referenceRange/appliesTo/coding/code (varchar)
  obs_referencerange_appliesto_display varchar,   -- referenceRange/appliesTo/coding/display (varchar)
  obs_referencerange_appliesto_text varchar,   -- referenceRange/appliesTo/text (varchar)
  obs_referencerange_age_low_value double precision,   -- referenceRange/age/low/value (double precision)
  obs_referencerange_age_low_unit varchar,   -- referenceRange/age/low/unit (varchar)
  obs_referencerange_age_low_system varchar,   -- referenceRange/age/low/system (varchar)
  obs_referencerange_age_low_code varchar,   -- referenceRange/age/low/code (varchar)
  obs_referencerange_age_high_value double precision,   -- referenceRange/age/high/value (double precision)
  obs_referencerange_age_high_unit varchar,   -- referenceRange/age/high/unit (varchar)
  obs_referencerange_age_high_system varchar,   -- referenceRange/age/high/system (varchar)
  obs_referencerange_age_high_code varchar,   -- referenceRange/age/high/code (varchar)
  obs_referencerange_text varchar,   -- referenceRange/text (varchar)
  obs_hasmember_ref varchar,   -- hasMember/reference (varchar)
  obs_hasmember_type varchar,   -- hasMember/type (varchar)
  obs_hasmember_identifier_use varchar,   -- hasMember/identifier/use (varchar)
  obs_hasmember_identifier_type_system varchar,   -- hasMember/identifier/type/coding/system (varchar)
  obs_hasmember_identifier_type_version varchar,   -- hasMember/identifier/type/coding/version (varchar)
  obs_hasmember_identifier_type_code varchar,   -- hasMember/identifier/type/coding/code (varchar)
  obs_hasmember_identifier_type_display varchar,   -- hasMember/identifier/type/coding/display (varchar)
  obs_hasmember_identifier_type_text varchar,   -- hasMember/identifier/type/text (varchar)
  obs_hasmember_display varchar,   -- hasMember/display (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(obs_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(obs_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(obs_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(obs_partof_ref::TEXT, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(obs_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(obs_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(obs_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(obs_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(obs_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(obs_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(obs_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(obs_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(obs_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(obs_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(obs_basedon_ref::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(obs_basedon_type::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(obs_basedon_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(obs_basedon_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(obs_basedon_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(obs_basedon_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(obs_basedon_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(obs_basedon_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(obs_basedon_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(obs_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(obs_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(obs_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(obs_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(obs_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(obs_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(obs_code_system::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(obs_code_version::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(obs_code_code::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(obs_code_display::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(obs_code_text::TEXT, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(obs_effectivedatetime::TEXT, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(obs_issued::TEXT, '#NULL#') || '|||' || -- hash from: issued
             COALESCE(obs_valuerange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/low/value
             COALESCE(obs_valuerange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/low/unit
             COALESCE(obs_valuerange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/low/system
             COALESCE(obs_valuerange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/low/code
             COALESCE(obs_valuerange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/high/value
             COALESCE(obs_valuerange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/high/unit
             COALESCE(obs_valuerange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/high/system
             COALESCE(obs_valuerange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: valueRange/high/code
             COALESCE(obs_valueratio_numerator_value::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/value
             COALESCE(obs_valueratio_numerator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/comparator
             COALESCE(obs_valueratio_numerator_unit::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/unit
             COALESCE(obs_valueratio_numerator_system::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/system
             COALESCE(obs_valueratio_numerator_code::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/numerator/code
             COALESCE(obs_valueratio_denominator_value::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/value
             COALESCE(obs_valueratio_denominator_comparator::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/comparator
             COALESCE(obs_valueratio_denominator_unit::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/unit
             COALESCE(obs_valueratio_denominator_system::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/system
             COALESCE(obs_valueratio_denominator_code::TEXT, '#NULL#') || '|||' || -- hash from: valueRatio/denominator/code
             COALESCE(obs_valuequantity_value::TEXT, '#NULL#') || '|||' || -- hash from: valueQuantity/value
             COALESCE(obs_valuequantity_comparator::TEXT, '#NULL#') || '|||' || -- hash from: valueQuantity/comparator
             COALESCE(obs_valuequantity_unit::TEXT, '#NULL#') || '|||' || -- hash from: valueQuantity/unit
             COALESCE(obs_valuequantity_system::TEXT, '#NULL#') || '|||' || -- hash from: valueQuantity/system
             COALESCE(obs_valuequantity_code::TEXT, '#NULL#') || '|||' || -- hash from: valueQuantity/code
             COALESCE(obs_valuecodableconcept_system::TEXT, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/system
             COALESCE(obs_valuecodableconcept_version::TEXT, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/version
             COALESCE(obs_valuecodableconcept_code::TEXT, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/code
             COALESCE(obs_valuecodableconcept_display::TEXT, '#NULL#') || '|||' || -- hash from: valueCodableConcept/coding/display
             COALESCE(obs_valuecodableconcept_text::TEXT, '#NULL#') || '|||' || -- hash from: valueCodableConcept/text
             COALESCE(obs_dataabsentreason_system::TEXT, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/system
             COALESCE(obs_dataabsentreason_version::TEXT, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/version
             COALESCE(obs_dataabsentreason_code::TEXT, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/code
             COALESCE(obs_dataabsentreason_display::TEXT, '#NULL#') || '|||' || -- hash from: dataAbsentReason/coding/display
             COALESCE(obs_dataabsentreason_text::TEXT, '#NULL#') || '|||' || -- hash from: dataAbsentReason/text
             COALESCE(obs_note_authorstring::TEXT, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(obs_note_authorreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(obs_note_authorreference_type::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(obs_note_authorreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(obs_note_authorreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(obs_note_authorreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(obs_note_authorreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(obs_note_authorreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(obs_note_authorreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(obs_note_authorreference_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(obs_note_time::TEXT, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(obs_note_text::TEXT, '#NULL#') || '|||' || -- hash from: note/text
             COALESCE(obs_method_system::TEXT, '#NULL#') || '|||' || -- hash from: method/coding/system
             COALESCE(obs_method_version::TEXT, '#NULL#') || '|||' || -- hash from: method/coding/version
             COALESCE(obs_method_code::TEXT, '#NULL#') || '|||' || -- hash from: method/coding/code
             COALESCE(obs_method_display::TEXT, '#NULL#') || '|||' || -- hash from: method/coding/display
             COALESCE(obs_method_text::TEXT, '#NULL#') || '|||' || -- hash from: method/text
             COALESCE(obs_performer_ref::TEXT, '#NULL#') || '|||' || -- hash from: performer/reference
             COALESCE(obs_performer_type::TEXT, '#NULL#') || '|||' || -- hash from: performer/type
             COALESCE(obs_performer_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/use
             COALESCE(obs_performer_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/system
             COALESCE(obs_performer_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/version
             COALESCE(obs_performer_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/code
             COALESCE(obs_performer_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/display
             COALESCE(obs_performer_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/text
             COALESCE(obs_performer_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/display
             COALESCE(obs_referencerange_low_value::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/low/value
             COALESCE(obs_referencerange_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/low/unit
             COALESCE(obs_referencerange_low_system::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/low/system
             COALESCE(obs_referencerange_low_code::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/low/code
             COALESCE(obs_referencerange_high_value::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/high/value
             COALESCE(obs_referencerange_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/high/unit
             COALESCE(obs_referencerange_high_system::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/high/system
             COALESCE(obs_referencerange_high_code::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/high/code
             COALESCE(obs_referencerange_type_system::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/system
             COALESCE(obs_referencerange_type_version::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/version
             COALESCE(obs_referencerange_type_code::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/code
             COALESCE(obs_referencerange_type_display::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/type/coding/display
             COALESCE(obs_referencerange_type_text::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/type/text
             COALESCE(obs_referencerange_appliesto_system::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/system
             COALESCE(obs_referencerange_appliesto_version::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/version
             COALESCE(obs_referencerange_appliesto_code::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/code
             COALESCE(obs_referencerange_appliesto_display::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/coding/display
             COALESCE(obs_referencerange_appliesto_text::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/appliesTo/text
             COALESCE(obs_referencerange_age_low_value::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/value
             COALESCE(obs_referencerange_age_low_unit::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/unit
             COALESCE(obs_referencerange_age_low_system::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/system
             COALESCE(obs_referencerange_age_low_code::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/low/code
             COALESCE(obs_referencerange_age_high_value::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/value
             COALESCE(obs_referencerange_age_high_unit::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/unit
             COALESCE(obs_referencerange_age_high_system::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/system
             COALESCE(obs_referencerange_age_high_code::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/age/high/code
             COALESCE(obs_referencerange_text::TEXT, '#NULL#') || '|||' || -- hash from: referenceRange/text
             COALESCE(obs_hasmember_ref::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/reference
             COALESCE(obs_hasmember_type::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/type
             COALESCE(obs_hasmember_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/identifier/use
             COALESCE(obs_hasmember_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/system
             COALESCE(obs_hasmember_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/version
             COALESCE(obs_hasmember_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/code
             COALESCE(obs_hasmember_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/coding/display
             COALESCE(obs_hasmember_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/identifier/type/text
             COALESCE(obs_hasmember_display::TEXT, '#NULL#') || '|||' || -- hash from: hasMember/display
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.diagnosticreport (
  diagnosticreport_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  diagnosticreport_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  diagrep_id varchar,   -- id (varchar)
  diagrep_encounter_ref varchar,   -- encounter/reference (varchar)
  diagrep_patient_ref varchar,   -- subject/reference (varchar)
  diagrep_partof_ref varchar,   -- partOf/reference (varchar)
  diagrep_identifier_use varchar,   -- identifier/use (varchar)
  diagrep_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  diagrep_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  diagrep_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  diagrep_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  diagrep_identifier_type_text varchar,   -- identifier/type/text (varchar)
  diagrep_identifier_system varchar,   -- identifier/system (varchar)
  diagrep_identifier_value varchar,   -- identifier/value (varchar)
  diagrep_identifier_start timestamp,   -- identifier/start (timestamp)
  diagrep_identifier_end timestamp,   -- identifier/end (timestamp)
  diagrep_result_ref varchar,   -- result/reference (varchar)
  diagrep_basedon_ref varchar,   -- basedOn/reference (varchar)
  diagrep_status varchar,   -- status (varchar)
  diagrep_category_system varchar,   -- category/coding/system (varchar)
  diagrep_category_version varchar,   -- category/coding/version (varchar)
  diagrep_category_code varchar,   -- category/coding/code (varchar)
  diagrep_category_display varchar,   -- category/coding/display (varchar)
  diagrep_category_text varchar,   -- category/text (varchar)
  diagrep_code_system varchar,   -- code/coding/system (varchar)
  diagrep_code_version varchar,   -- code/coding/version (varchar)
  diagrep_code_code varchar,   -- code/coding/code (varchar)
  diagrep_code_display varchar,   -- code/coding/display (varchar)
  diagrep_code_text varchar,   -- code/text (varchar)
  diagrep_effectivedatetime timestamp,   -- effectiveDateTime (timestamp)
  diagrep_issued timestamp,   -- issued (timestamp)
  diagrep_performer_ref varchar,   -- performer/reference (varchar)
  diagrep_performer_type varchar,   -- performer/type (varchar)
  diagrep_performer_identifier_use varchar,   -- performer/identifier/use (varchar)
  diagrep_performer_identifier_type_system varchar,   -- performer/identifier/type/coding/system (varchar)
  diagrep_performer_identifier_type_version varchar,   -- performer/identifier/type/coding/version (varchar)
  diagrep_performer_identifier_type_code varchar,   -- performer/identifier/type/coding/code (varchar)
  diagrep_performer_identifier_type_display varchar,   -- performer/identifier/type/coding/display (varchar)
  diagrep_performer_identifier_type_text varchar,   -- performer/identifier/type/text (varchar)
  diagrep_performer_display varchar,   -- performer/display (varchar)
  diagrep_conclusion varchar,   -- conclusion (varchar)
  diagrep_conclusioncode_system varchar,   -- conclusionCode/coding/system (varchar)
  diagrep_conclusioncode_version varchar,   -- conclusionCode/coding/version (varchar)
  diagrep_conclusioncode_code varchar,   -- conclusionCode/coding/code (varchar)
  diagrep_conclusioncode_display varchar,   -- conclusionCode/coding/display (varchar)
  diagrep_conclusioncode_text varchar,   -- conclusionCode/text (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(diagrep_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(diagrep_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(diagrep_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(diagrep_partof_ref::TEXT, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(diagrep_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(diagrep_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(diagrep_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(diagrep_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(diagrep_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(diagrep_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(diagrep_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(diagrep_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(diagrep_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(diagrep_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(diagrep_result_ref::TEXT, '#NULL#') || '|||' || -- hash from: result/reference
             COALESCE(diagrep_basedon_ref::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(diagrep_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(diagrep_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(diagrep_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(diagrep_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(diagrep_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(diagrep_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(diagrep_code_system::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(diagrep_code_version::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(diagrep_code_code::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(diagrep_code_display::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(diagrep_code_text::TEXT, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(diagrep_effectivedatetime::TEXT, '#NULL#') || '|||' || -- hash from: effectiveDateTime
             COALESCE(diagrep_issued::TEXT, '#NULL#') || '|||' || -- hash from: issued
             COALESCE(diagrep_performer_ref::TEXT, '#NULL#') || '|||' || -- hash from: performer/reference
             COALESCE(diagrep_performer_type::TEXT, '#NULL#') || '|||' || -- hash from: performer/type
             COALESCE(diagrep_performer_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/use
             COALESCE(diagrep_performer_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/system
             COALESCE(diagrep_performer_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/version
             COALESCE(diagrep_performer_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/code
             COALESCE(diagrep_performer_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/display
             COALESCE(diagrep_performer_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/text
             COALESCE(diagrep_performer_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/display
             COALESCE(diagrep_conclusion::TEXT, '#NULL#') || '|||' || -- hash from: conclusion
             COALESCE(diagrep_conclusioncode_system::TEXT, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/system
             COALESCE(diagrep_conclusioncode_version::TEXT, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/version
             COALESCE(diagrep_conclusioncode_code::TEXT, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/code
             COALESCE(diagrep_conclusioncode_display::TEXT, '#NULL#') || '|||' || -- hash from: conclusionCode/coding/display
             COALESCE(diagrep_conclusioncode_text::TEXT, '#NULL#') || '|||' || -- hash from: conclusionCode/text
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.servicerequest (
  servicerequest_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  servicerequest_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  servreq_id varchar,   -- id (varchar)
  servreq_encounter_ref varchar,   -- encounter/reference (varchar)
  servreq_patient_ref varchar,   -- subject/reference (varchar)
  servreq_identifier_use varchar,   -- identifier/use (varchar)
  servreq_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  servreq_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  servreq_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  servreq_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  servreq_identifier_type_text varchar,   -- identifier/type/text (varchar)
  servreq_identifier_system varchar,   -- identifier/system (varchar)
  servreq_identifier_value varchar,   -- identifier/value (varchar)
  servreq_identifier_start timestamp,   -- identifier/start (timestamp)
  servreq_identifier_end timestamp,   -- identifier/end (timestamp)
  servreq_basedon_ref varchar,   -- basedOn/reference (varchar)
  servreq_basedon_type varchar,   -- basedOn/type (varchar)
  servreq_basedon_identifier_use varchar,   -- basedOn/identifier/use (varchar)
  servreq_basedon_identifier_type_system varchar,   -- basedOn/identifier/type/coding/system (varchar)
  servreq_basedon_identifier_type_version varchar,   -- basedOn/identifier/type/coding/version (varchar)
  servreq_basedon_identifier_type_code varchar,   -- basedOn/identifier/type/coding/code (varchar)
  servreq_basedon_identifier_type_display varchar,   -- basedOn/identifier/type/coding/display (varchar)
  servreq_basedon_identifier_type_text varchar,   -- basedOn/identifier/type/text (varchar)
  servreq_basedon_display varchar,   -- basedOn/display (varchar)
  servreq_status varchar,   -- status (varchar)
  servreq_intent varchar,   -- intent (varchar)
  servreq_category_system varchar,   -- category/coding/system (varchar)
  servreq_category_version varchar,   -- category/coding/version (varchar)
  servreq_category_code varchar,   -- category/coding/code (varchar)
  servreq_category_display varchar,   -- category/coding/display (varchar)
  servreq_category_text varchar,   -- category/text (varchar)
  servreq_code_system varchar,   -- code/coding/system (varchar)
  servreq_code_version varchar,   -- code/coding/version (varchar)
  servreq_code_code varchar,   -- code/coding/code (varchar)
  servreq_code_display varchar,   -- code/coding/display (varchar)
  servreq_code_text varchar,   -- code/text (varchar)
  servreq_authoredon timestamp,   -- authoredOn (timestamp)
  servreq_requester_ref varchar,   -- requester/reference (varchar)
  servreq_requester_type varchar,   -- requester/type (varchar)
  servreq_requester_identifier_use varchar,   -- requester/identifier/use (varchar)
  servreq_requester_identifier_type_system varchar,   -- requester/identifier/type/coding/system (varchar)
  servreq_requester_identifier_type_version varchar,   -- requester/identifier/type/coding/version (varchar)
  servreq_requester_identifier_type_code varchar,   -- requester/identifier/type/coding/code (varchar)
  servreq_requester_identifier_type_display varchar,   -- requester/identifier/type/coding/display (varchar)
  servreq_requester_identifier_type_text varchar,   -- requester/identifier/type/text (varchar)
  servreq_requester_display varchar,   -- requester/display (varchar)
  servreq_performer_ref varchar,   -- performer/reference (varchar)
  servreq_performer_type varchar,   -- performer/type (varchar)
  servreq_performer_identifier_use varchar,   -- performer/identifier/use (varchar)
  servreq_performer_identifier_type_system varchar,   -- performer/identifier/type/coding/system (varchar)
  servreq_performer_identifier_type_version varchar,   -- performer/identifier/type/coding/version (varchar)
  servreq_performer_identifier_type_code varchar,   -- performer/identifier/type/coding/code (varchar)
  servreq_performer_identifier_type_display varchar,   -- performer/identifier/type/coding/display (varchar)
  servreq_performer_identifier_type_text varchar,   -- performer/identifier/type/text (varchar)
  servreq_performer_display varchar,   -- performer/display (varchar)
  servreq_locationcode_system varchar,   -- locationCode/coding/system (varchar)
  servreq_locationcode_version varchar,   -- locationCode/coding/version (varchar)
  servreq_locationcode_code varchar,   -- locationCode/coding/code (varchar)
  servreq_locationcode_display varchar,   -- locationCode/coding/display (varchar)
  servreq_locationcode_text varchar,   -- locationCode/text (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(servreq_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(servreq_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(servreq_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(servreq_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(servreq_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(servreq_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(servreq_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(servreq_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(servreq_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(servreq_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(servreq_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(servreq_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(servreq_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(servreq_basedon_ref::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(servreq_basedon_type::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(servreq_basedon_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(servreq_basedon_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(servreq_basedon_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(servreq_basedon_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(servreq_basedon_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(servreq_basedon_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(servreq_basedon_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(servreq_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(servreq_intent::TEXT, '#NULL#') || '|||' || -- hash from: intent
             COALESCE(servreq_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(servreq_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(servreq_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(servreq_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(servreq_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(servreq_code_system::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(servreq_code_version::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(servreq_code_code::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(servreq_code_display::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(servreq_code_text::TEXT, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(servreq_authoredon::TEXT, '#NULL#') || '|||' || -- hash from: authoredOn
             COALESCE(servreq_requester_ref::TEXT, '#NULL#') || '|||' || -- hash from: requester/reference
             COALESCE(servreq_requester_type::TEXT, '#NULL#') || '|||' || -- hash from: requester/type
             COALESCE(servreq_requester_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/use
             COALESCE(servreq_requester_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/system
             COALESCE(servreq_requester_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/version
             COALESCE(servreq_requester_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/code
             COALESCE(servreq_requester_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/coding/display
             COALESCE(servreq_requester_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: requester/identifier/type/text
             COALESCE(servreq_requester_display::TEXT, '#NULL#') || '|||' || -- hash from: requester/display
             COALESCE(servreq_performer_ref::TEXT, '#NULL#') || '|||' || -- hash from: performer/reference
             COALESCE(servreq_performer_type::TEXT, '#NULL#') || '|||' || -- hash from: performer/type
             COALESCE(servreq_performer_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/use
             COALESCE(servreq_performer_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/system
             COALESCE(servreq_performer_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/version
             COALESCE(servreq_performer_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/code
             COALESCE(servreq_performer_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/coding/display
             COALESCE(servreq_performer_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: performer/identifier/type/text
             COALESCE(servreq_performer_display::TEXT, '#NULL#') || '|||' || -- hash from: performer/display
             COALESCE(servreq_locationcode_system::TEXT, '#NULL#') || '|||' || -- hash from: locationCode/coding/system
             COALESCE(servreq_locationcode_version::TEXT, '#NULL#') || '|||' || -- hash from: locationCode/coding/version
             COALESCE(servreq_locationcode_code::TEXT, '#NULL#') || '|||' || -- hash from: locationCode/coding/code
             COALESCE(servreq_locationcode_display::TEXT, '#NULL#') || '|||' || -- hash from: locationCode/coding/display
             COALESCE(servreq_locationcode_text::TEXT, '#NULL#') || '|||' || -- hash from: locationCode/text
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "procedure" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.procedure (
  procedure_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  procedure_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  proc_id varchar,   -- id (varchar)
  proc_encounter_ref varchar,   -- encounter/reference (varchar)
  proc_patient_ref varchar,   -- subject/reference (varchar)
  proc_partof_ref varchar,   -- partOf/reference (varchar)
  proc_identifier_use varchar,   -- identifier/use (varchar)
  proc_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  proc_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  proc_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  proc_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  proc_identifier_type_text varchar,   -- identifier/type/text (varchar)
  proc_identifier_system varchar,   -- identifier/system (varchar)
  proc_identifier_value varchar,   -- identifier/value (varchar)
  proc_identifier_start timestamp,   -- identifier/start (timestamp)
  proc_identifier_end timestamp,   -- identifier/end (timestamp)
  proc_basedon_ref varchar,   -- basedOn/reference (varchar)
  proc_basedon_type varchar,   -- basedOn/type (varchar)
  proc_basedon_identifier_use varchar,   -- basedOn/identifier/use (varchar)
  proc_basedon_identifier_type_system varchar,   -- basedOn/identifier/type/coding/system (varchar)
  proc_basedon_identifier_type_version varchar,   -- basedOn/identifier/type/coding/version (varchar)
  proc_basedon_identifier_type_code varchar,   -- basedOn/identifier/type/coding/code (varchar)
  proc_basedon_identifier_type_display varchar,   -- basedOn/identifier/type/coding/display (varchar)
  proc_basedon_identifier_type_text varchar,   -- basedOn/identifier/type/text (varchar)
  proc_basedon_display varchar,   -- basedOn/display (varchar)
  proc_status varchar,   -- status (varchar)
  proc_statusreason_system varchar,   -- statusReason/coding/system (varchar)
  proc_statusreason_version varchar,   -- statusReason/coding/version (varchar)
  proc_statusreason_code varchar,   -- statusReason/coding/code (varchar)
  proc_statusreason_display varchar,   -- statusReason/coding/display (varchar)
  proc_statusreason_text varchar,   -- statusReason/text (varchar)
  proc_category_system varchar,   -- category/coding/system (varchar)
  proc_category_version varchar,   -- category/coding/version (varchar)
  proc_category_code varchar,   -- category/coding/code (varchar)
  proc_category_display varchar,   -- category/coding/display (varchar)
  proc_category_text varchar,   -- category/text (varchar)
  proc_code_system varchar,   -- code/coding/system (varchar)
  proc_code_version varchar,   -- code/coding/version (varchar)
  proc_code_code varchar,   -- code/coding/code (varchar)
  proc_code_display varchar,   -- code/coding/display (varchar)
  proc_code_text varchar,   -- code/text (varchar)
  proc_performeddatetime timestamp,   -- performedDateTime (timestamp)
  proc_performedperiod_start timestamp,   -- performedPeriod/start (timestamp)
  proc_performedperiod_end timestamp,   -- performedPeriod/end (timestamp)
  proc_reasoncode_system varchar,   -- reasonCode/coding/system (varchar)
  proc_reasoncode_version varchar,   -- reasonCode/coding/version (varchar)
  proc_reasoncode_code varchar,   -- reasonCode/coding/code (varchar)
  proc_reasoncode_display varchar,   -- reasonCode/coding/display (varchar)
  proc_reasoncode_text varchar,   -- reasonCode/text (varchar)
  proc_reasonreference_ref varchar,   -- reasonReference/reference (varchar)
  proc_reasonreference_type varchar,   -- reasonReference/type (varchar)
  proc_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  proc_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  proc_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  proc_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  proc_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  proc_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  proc_reasonreference_display varchar,   -- reasonReference/display (varchar)
  proc_note_authorstring varchar,   -- note/authorString (varchar)
  proc_note_authorreference_ref varchar,   -- note/authorReference/reference (varchar)
  proc_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  proc_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  proc_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  proc_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  proc_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  proc_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  proc_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  proc_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  proc_note_time timestamp,   -- note/time (timestamp)
  proc_note_text varchar,   -- note/text (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(proc_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(proc_encounter_ref::TEXT, '#NULL#') || '|||' || -- hash from: encounter/reference
             COALESCE(proc_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: subject/reference
             COALESCE(proc_partof_ref::TEXT, '#NULL#') || '|||' || -- hash from: partOf/reference
             COALESCE(proc_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(proc_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(proc_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(proc_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(proc_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(proc_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(proc_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(proc_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(proc_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(proc_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(proc_basedon_ref::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/reference
             COALESCE(proc_basedon_type::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/type
             COALESCE(proc_basedon_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/use
             COALESCE(proc_basedon_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/system
             COALESCE(proc_basedon_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/version
             COALESCE(proc_basedon_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/code
             COALESCE(proc_basedon_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/coding/display
             COALESCE(proc_basedon_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/identifier/type/text
             COALESCE(proc_basedon_display::TEXT, '#NULL#') || '|||' || -- hash from: basedOn/display
             COALESCE(proc_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(proc_statusreason_system::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/system
             COALESCE(proc_statusreason_version::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/version
             COALESCE(proc_statusreason_code::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/code
             COALESCE(proc_statusreason_display::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/coding/display
             COALESCE(proc_statusreason_text::TEXT, '#NULL#') || '|||' || -- hash from: statusReason/text
             COALESCE(proc_category_system::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/system
             COALESCE(proc_category_version::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/version
             COALESCE(proc_category_code::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/code
             COALESCE(proc_category_display::TEXT, '#NULL#') || '|||' || -- hash from: category/coding/display
             COALESCE(proc_category_text::TEXT, '#NULL#') || '|||' || -- hash from: category/text
             COALESCE(proc_code_system::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/system
             COALESCE(proc_code_version::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/version
             COALESCE(proc_code_code::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/code
             COALESCE(proc_code_display::TEXT, '#NULL#') || '|||' || -- hash from: code/coding/display
             COALESCE(proc_code_text::TEXT, '#NULL#') || '|||' || -- hash from: code/text
             COALESCE(proc_performeddatetime::TEXT, '#NULL#') || '|||' || -- hash from: performedDateTime
             COALESCE(proc_performedperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: performedPeriod/start
             COALESCE(proc_performedperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: performedPeriod/end
             COALESCE(proc_reasoncode_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/system
             COALESCE(proc_reasoncode_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/version
             COALESCE(proc_reasoncode_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/code
             COALESCE(proc_reasoncode_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/coding/display
             COALESCE(proc_reasoncode_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonCode/text
             COALESCE(proc_reasonreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/reference
             COALESCE(proc_reasonreference_type::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/type
             COALESCE(proc_reasonreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/use
             COALESCE(proc_reasonreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/system
             COALESCE(proc_reasonreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/version
             COALESCE(proc_reasonreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/code
             COALESCE(proc_reasonreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/coding/display
             COALESCE(proc_reasonreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/identifier/type/text
             COALESCE(proc_reasonreference_display::TEXT, '#NULL#') || '|||' || -- hash from: reasonReference/display
             COALESCE(proc_note_authorstring::TEXT, '#NULL#') || '|||' || -- hash from: note/authorString
             COALESCE(proc_note_authorreference_ref::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/reference
             COALESCE(proc_note_authorreference_type::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/type
             COALESCE(proc_note_authorreference_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/use
             COALESCE(proc_note_authorreference_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/system
             COALESCE(proc_note_authorreference_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/version
             COALESCE(proc_note_authorreference_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/code
             COALESCE(proc_note_authorreference_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/coding/display
             COALESCE(proc_note_authorreference_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/identifier/type/text
             COALESCE(proc_note_authorreference_display::TEXT, '#NULL#') || '|||' || -- hash from: note/authorReference/display
             COALESCE(proc_note_time::TEXT, '#NULL#') || '|||' || -- hash from: note/time
             COALESCE(proc_note_text::TEXT, '#NULL#') || '|||' || -- hash from: note/text
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "consent" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.consent (
  consent_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  consent_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  cons_id varchar,   -- id (varchar)
  cons_patient_ref varchar,   -- patient/reference (varchar)
  cons_identifier_use varchar,   -- identifier/use (varchar)
  cons_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  cons_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  cons_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  cons_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  cons_identifier_type_text varchar,   -- identifier/type/text (varchar)
  cons_identifier_system varchar,   -- identifier/system (varchar)
  cons_identifier_value varchar,   -- identifier/value (varchar)
  cons_identifier_start timestamp,   -- identifier/start (timestamp)
  cons_identifier_end timestamp,   -- identifier/end (timestamp)
  cons_status varchar,   -- status (varchar)
  cons_scope_system varchar,   -- scope/coding/system (varchar)
  cons_scope_version varchar,   -- scope/coding/version (varchar)
  cons_scope_code varchar,   -- scope/coding/code (varchar)
  cons_scope_display varchar,   -- scope/coding/display (varchar)
  cons_scope_text varchar,   -- scope/text (varchar)
  cons_datetime timestamp,   -- dateTime (timestamp)
  cons_provision_type varchar,   -- provision/type (varchar)
  cons_provision_period_start timestamp,   -- provision/period/start (timestamp)
  cons_provision_period_end timestamp,   -- provision/period/end (timestamp)
  cons_provision_actor_role_system varchar,   -- provision/actor/role/coding/system (varchar)
  cons_provision_actor_role_version varchar,   -- provision/actor/role/coding/version (varchar)
  cons_provision_actor_role_code varchar,   -- provision/actor/role/coding/code (varchar)
  cons_provision_actor_role_display varchar,   -- provision/actor/role/coding/display (varchar)
  cons_provision_actor_role_text varchar,   -- provision/actor/role/text (varchar)
  cons_provision_code_system varchar,   -- provision/code/coding/system (varchar)
  cons_provision_code_version varchar,   -- provision/code/coding/version (varchar)
  cons_provision_code_code varchar,   -- provision/code/coding/code (varchar)
  cons_provision_code_display varchar,   -- provision/code/coding/display (varchar)
  cons_provision_code_text varchar,   -- provision/code/text (varchar)
  cons_provision_dataperiod_start timestamp,   -- provision/dataPeriod/start (timestamp)
  cons_provision_dataperiod_end timestamp,   -- provision/dataPeriod/end (timestamp)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(cons_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(cons_patient_ref::TEXT, '#NULL#') || '|||' || -- hash from: patient/reference
             COALESCE(cons_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(cons_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(cons_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(cons_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(cons_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(cons_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(cons_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(cons_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(cons_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(cons_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(cons_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(cons_scope_system::TEXT, '#NULL#') || '|||' || -- hash from: scope/coding/system
             COALESCE(cons_scope_version::TEXT, '#NULL#') || '|||' || -- hash from: scope/coding/version
             COALESCE(cons_scope_code::TEXT, '#NULL#') || '|||' || -- hash from: scope/coding/code
             COALESCE(cons_scope_display::TEXT, '#NULL#') || '|||' || -- hash from: scope/coding/display
             COALESCE(cons_scope_text::TEXT, '#NULL#') || '|||' || -- hash from: scope/text
             COALESCE(cons_datetime::TEXT, '#NULL#') || '|||' || -- hash from: dateTime
             COALESCE(cons_provision_type::TEXT, '#NULL#') || '|||' || -- hash from: provision/type
             COALESCE(cons_provision_period_start::TEXT, '#NULL#') || '|||' || -- hash from: provision/period/start
             COALESCE(cons_provision_period_end::TEXT, '#NULL#') || '|||' || -- hash from: provision/period/end
             COALESCE(cons_provision_actor_role_system::TEXT, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/system
             COALESCE(cons_provision_actor_role_version::TEXT, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/version
             COALESCE(cons_provision_actor_role_code::TEXT, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/code
             COALESCE(cons_provision_actor_role_display::TEXT, '#NULL#') || '|||' || -- hash from: provision/actor/role/coding/display
             COALESCE(cons_provision_actor_role_text::TEXT, '#NULL#') || '|||' || -- hash from: provision/actor/role/text
             COALESCE(cons_provision_code_system::TEXT, '#NULL#') || '|||' || -- hash from: provision/code/coding/system
             COALESCE(cons_provision_code_version::TEXT, '#NULL#') || '|||' || -- hash from: provision/code/coding/version
             COALESCE(cons_provision_code_code::TEXT, '#NULL#') || '|||' || -- hash from: provision/code/coding/code
             COALESCE(cons_provision_code_display::TEXT, '#NULL#') || '|||' || -- hash from: provision/code/coding/display
             COALESCE(cons_provision_code_text::TEXT, '#NULL#') || '|||' || -- hash from: provision/code/text
             COALESCE(cons_provision_dataperiod_start::TEXT, '#NULL#') || '|||' || -- hash from: provision/dataPeriod/start
             COALESCE(cons_provision_dataperiod_end::TEXT, '#NULL#') || '|||' || -- hash from: provision/dataPeriod/end
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "location" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.location (
  location_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  location_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  loc_id varchar,   -- id (varchar)
  loc_identifier_use varchar,   -- identifier/use (varchar)
  loc_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  loc_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  loc_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  loc_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  loc_identifier_type_text varchar,   -- identifier/type/text (varchar)
  loc_identifier_system varchar,   -- identifier/system (varchar)
  loc_identifier_value varchar,   -- identifier/value (varchar)
  loc_identifier_start timestamp,   -- identifier/start (timestamp)
  loc_identifier_end timestamp,   -- identifier/end (timestamp)
  loc_status varchar,   -- status (varchar)
  loc_name varchar,   -- name (varchar)
  loc_description varchar,   -- description (varchar)
  loc_alias varchar,   -- alias (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(loc_id::TEXT, '#NULL#') || '|||' || -- hash from: id
             COALESCE(loc_identifier_use::TEXT, '#NULL#') || '|||' || -- hash from: identifier/use
             COALESCE(loc_identifier_type_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/system
             COALESCE(loc_identifier_type_version::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/version
             COALESCE(loc_identifier_type_code::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/code
             COALESCE(loc_identifier_type_display::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/coding/display
             COALESCE(loc_identifier_type_text::TEXT, '#NULL#') || '|||' || -- hash from: identifier/type/text
             COALESCE(loc_identifier_system::TEXT, '#NULL#') || '|||' || -- hash from: identifier/system
             COALESCE(loc_identifier_value::TEXT, '#NULL#') || '|||' || -- hash from: identifier/value
             COALESCE(loc_identifier_start::TEXT, '#NULL#') || '|||' || -- hash from: identifier/start
             COALESCE(loc_identifier_end::TEXT, '#NULL#') || '|||' || -- hash from: identifier/end
             COALESCE(loc_status::TEXT, '#NULL#') || '|||' || -- hash from: status
             COALESCE(loc_name::TEXT, '#NULL#') || '|||' || -- hash from: name
             COALESCE(loc_description::TEXT, '#NULL#') || '|||' || -- hash from: description
             COALESCE(loc_alias::TEXT, '#NULL#') || '|||' || -- hash from: alias
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.pids_per_ward (
  pids_per_ward_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
  pids_per_ward_raw_id int NOT NULL, -- Primary key of the corresponding raw table
  ward_name varchar,   -- ward_name (varchar)
  patient_id varchar,   -- patient_id (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
--      db.mutable_md5(
--         convert_to(
             COALESCE(ward_name::TEXT, '#NULL#') || '|||' || -- hash from: ward_name
             COALESCE(patient_id::TEXT, '#NULL#') || '|||' || -- hash from: patient_id
             '#'
--             ,'UTF8' )
--      )
  ) STORED, 							-- Column collection data for index automatic 
  hash_index_col TEXT DEFAULT 'ToDo automatisches füllen',      -- Column for hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);


------------------------------------------------------
-- SQL Role / Trigger in Schema "cds2db_in" --
------------------------------------------------------


-- Table "encounter" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.encounter TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter TO db_user; -- Additional authorizations for testing

-- Table "patient" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.patient TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient TO db_user; -- Additional authorizations for testing

-- Table "condition" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.condition TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition TO db_user; -- Additional authorizations for testing

-- Table "medication" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medication TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication TO db_user; -- Additional authorizations for testing

-- Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medicationrequest TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest TO db_user; -- Additional authorizations for testing

-- Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medicationadministration TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration TO db_user; -- Additional authorizations for testing

-- Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.medicationstatement TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement TO db_user; -- Additional authorizations for testing

-- Table "observation" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.observation TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation TO db_user; -- Additional authorizations for testing

-- Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.diagnosticreport TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport TO db_user; -- Additional authorizations for testing

-- Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.servicerequest TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest TO db_user; -- Additional authorizations for testing

-- Table "procedure" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.procedure TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure TO db_user; -- Additional authorizations for testing

-- Table "consent" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.consent TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent TO db_user; -- Additional authorizations for testing

-- Table "location" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.location TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location TO db_user; -- Additional authorizations for testing

-- Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
GRANT TRIGGER ON cds2db_in.pids_per_ward TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON db.db_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward TO db_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "cds2db_in" --
------------------------------------------------------
-- Output off
\o /dev/null

COMMENT ON COLUMN cds2db_in.encounter.encounter_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.encounter.encounter_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.encounter.enc_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.encounter.enc_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.encounter.enc_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_class_system IS 'class/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_class_version IS 'class/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_class_code IS 'class/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_class_display IS 'class/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_type_system IS 'type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_type_version IS 'type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_type_code IS 'type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_type_display IS 'type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_type_text IS 'type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_servicetype_system IS 'serviceType/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_servicetype_version IS 'serviceType/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_servicetype_code IS 'serviceType/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_servicetype_display IS 'serviceType/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_servicetype_text IS 'serviceType/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_period_start IS 'period/start (timestamp)';
COMMENT ON COLUMN cds2db_in.encounter.enc_period_end IS 'period/end (timestamp)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_condition_ref IS 'diagnosis/condition/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_use_system IS 'diagnosis/use/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_use_version IS 'diagnosis/use/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_use_code IS 'diagnosis/use/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_use_display IS 'diagnosis/use/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_use_text IS 'diagnosis/use/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_diagnosis_rank IS 'diagnosis/rank (int)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_admitsource_system IS 'hospitalization/admitSource/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_admitsource_version IS 'hospitalization/admitSource/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_admitsource_code IS 'hospitalization/admitSource/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_admitsource_display IS 'hospitalization/admitSource/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_admitsource_text IS 'hospitalization/admitSource/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_dischargedisposition_system IS 'hospitalization/dischargeDisposition/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_dischargedisposition_version IS 'hospitalization/dischargeDisposition/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_dischargedisposition_code IS 'hospitalization/dischargeDisposition/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_dischargedisposition_display IS 'hospitalization/dischargeDisposition/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_hospitalization_dischargedisposition_text IS 'hospitalization/dischargeDisposition/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_ref IS 'location/location/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_type IS 'location/location/type (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_identifier_use IS 'location/location/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_identifier_type_system IS 'location/location/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_identifier_type_version IS 'location/location/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_identifier_type_code IS 'location/location/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_identifier_type_display IS 'location/location/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_identifier_type_text IS 'location/location/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_display IS 'location/location/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_status IS 'location/status (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_physicaltype_system IS 'location/physicalType/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_physicaltype_version IS 'location/physicalType/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_physicaltype_code IS 'location/physicalType/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_physicaltype_display IS 'location/physicalType/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_location_physicaltype_text IS 'location/physicalType/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_ref IS 'serviceProvider/reference (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_type IS 'serviceProvider/type (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_identifier_use IS 'serviceProvider/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_identifier_type_system IS 'serviceProvider/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_identifier_type_version IS 'serviceProvider/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_identifier_type_code IS 'serviceProvider/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_identifier_type_display IS 'serviceProvider/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_identifier_type_text IS 'serviceProvider/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.enc_serviceprovider_display IS 'serviceProvider/display (varchar)';
COMMENT ON COLUMN cds2db_in.encounter.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.encounter.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.encounter.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.encounter.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.encounter.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.patient.patient_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.patient.patient_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.patient.pat_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.patient.pat_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.patient.pat_name_text IS 'name/text (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_name_family IS 'name/family (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_name_given IS 'name/given (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_gender IS 'gender (varchar)';
COMMENT ON COLUMN cds2db_in.patient.pat_birthdate IS 'birthDate (date)';
COMMENT ON COLUMN cds2db_in.patient.pat_address_postalcode IS 'address/postalCode (varchar)';
COMMENT ON COLUMN cds2db_in.patient.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.patient.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.patient.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.patient.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.patient.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.condition.condition_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.condition.condition_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.condition.con_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_clinicalstatus_system IS 'clinicalStatus/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_clinicalstatus_version IS 'clinicalStatus/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_clinicalstatus_code IS 'clinicalStatus/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_clinicalstatus_display IS 'clinicalStatus/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_clinicalstatus_text IS 'clinicalStatus/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_verificationstatus_system IS 'verificationStatus/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_verificationstatus_version IS 'verificationStatus/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_verificationstatus_code IS 'verificationStatus/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_verificationstatus_display IS 'verificationStatus/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_verificationstatus_text IS 'verificationStatus/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_severity_system IS 'severity/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_severity_version IS 'severity/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_severity_code IS 'severity/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_severity_display IS 'severity/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_severity_text IS 'severity/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_bodysite_system IS 'bodySite/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_bodysite_version IS 'bodySite/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_bodysite_code IS 'bodySite/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_bodysite_display IS 'bodySite/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_bodysite_text IS 'bodySite/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_onsetperiod_start IS 'onsetPeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_onsetperiod_end IS 'onsetPeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_onsetdatetime IS 'onsetDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementdatetime IS 'abatementDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementage_value IS 'abatementAge/value (double precision)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementage_comparator IS 'abatementAge/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementage_unit IS 'abatementAge/unit (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementage_system IS 'abatementAge/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementage_code IS 'abatementAge/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementperiod_start IS 'abatementPeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementperiod_end IS 'abatementPeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_low_value IS 'abatementRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_low_unit IS 'abatementRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_low_system IS 'abatementRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_low_code IS 'abatementRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_high_value IS 'abatementRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_high_unit IS 'abatementRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_high_system IS 'abatementRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementrange_high_code IS 'abatementRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_abatementstring IS 'abatementString (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recordeddate IS 'recordedDate (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_ref IS 'recorder/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_type IS 'recorder/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_identifier_use IS 'recorder/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_identifier_type_system IS 'recorder/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_identifier_type_version IS 'recorder/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_identifier_type_code IS 'recorder/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_identifier_type_display IS 'recorder/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_identifier_type_text IS 'recorder/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_recorder_display IS 'recorder/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_ref IS 'asserter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_type IS 'asserter/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_identifier_use IS 'asserter/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_identifier_type_system IS 'asserter/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_identifier_type_version IS 'asserter/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_identifier_type_code IS 'asserter/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_identifier_type_display IS 'asserter/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_identifier_type_text IS 'asserter/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_asserter_display IS 'asserter/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_summary_system IS 'stage/summary/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_summary_version IS 'stage/summary/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_summary_code IS 'stage/summary/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_summary_display IS 'stage/summary/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_summary_text IS 'stage/summary/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_ref IS 'stage/assessment/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_type IS 'stage/assessment/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_identifier_use IS 'stage/assessment/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_identifier_type_system IS 'stage/assessment/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_identifier_type_version IS 'stage/assessment/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_identifier_type_code IS 'stage/assessment/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_identifier_type_display IS 'stage/assessment/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_identifier_type_text IS 'stage/assessment/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_assessment_display IS 'stage/assessment/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_type_system IS 'stage/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_type_version IS 'stage/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_type_code IS 'stage/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_type_display IS 'stage/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_stage_type_text IS 'stage/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.condition.con_note_time IS 'note/time (timestamp)';
COMMENT ON COLUMN cds2db_in.condition.con_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.condition.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.condition.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.condition.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.condition.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.condition.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medication.medication_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medication.medication_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.medication.med_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medication.med_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medication.med_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_form_system IS 'form/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_form_version IS 'form/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_form_code IS 'form/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_form_display IS 'form/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_form_text IS 'form/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_numerator_value IS 'amount/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_numerator_comparator IS 'amount/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_numerator_unit IS 'amount/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_numerator_system IS 'amount/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_numerator_code IS 'amount/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_denominator_value IS 'amount/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_denominator_comparator IS 'amount/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_denominator_unit IS 'amount/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_denominator_system IS 'amount/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_amount_denominator_code IS 'amount/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_numerator_value IS 'ingredient/strength/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_numerator_comparator IS 'ingredient/strength/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_numerator_unit IS 'ingredient/strength/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_numerator_system IS 'ingredient/strength/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_numerator_code IS 'ingredient/strength/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_denominator_value IS 'ingredient/strength/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_denominator_comparator IS 'ingredient/strength/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_denominator_unit IS 'ingredient/strength/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_denominator_system IS 'ingredient/strength/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_strength_denominator_code IS 'ingredient/strength/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemcodeableconcept_system IS 'ingredient/itemCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemcodeableconcept_version IS 'ingredient/itemCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemcodeableconcept_code IS 'ingredient/itemCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemcodeableconcept_display IS 'ingredient/itemCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemcodeableconcept_text IS 'ingredient/itemCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_ref IS 'ingredient/itemReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_type IS 'ingredient/itemReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_identifier_use IS 'ingredient/itemReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_identifier_type_system IS 'ingredient/itemReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_identifier_type_version IS 'ingredient/itemReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_identifier_type_code IS 'ingredient/itemReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_identifier_type_display IS 'ingredient/itemReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_identifier_type_text IS 'ingredient/itemReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_itemreference_display IS 'ingredient/itemReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medication.med_ingredient_isactive IS 'ingredient/isActive (boolean)';
COMMENT ON COLUMN cds2db_in.medication.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medication.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medication.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medication.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medication.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medicationrequest.medicationrequest_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medicationrequest.medicationrequest_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_medicationreference_ref IS 'medicationReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_intend IS 'intend (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_priority IS 'priority (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedboolean IS 'reportedBoolean (boolean)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_ref IS 'reportedReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_type IS 'reportedReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_identifier_use IS 'reportedReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_identifier_type_system IS 'reportedReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_identifier_type_version IS 'reportedReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_identifier_type_code IS 'reportedReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_identifier_type_display IS 'reportedReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_identifier_type_text IS 'reportedReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reportedreference_display IS 'reportedReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_ref IS 'supportingInformation/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_type IS 'supportingInformation/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_identifier_use IS 'supportingInformation/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_identifier_type_system IS 'supportingInformation/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_identifier_type_version IS 'supportingInformation/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_identifier_type_code IS 'supportingInformation/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_identifier_type_display IS 'supportingInformation/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_identifier_type_text IS 'supportingInformation/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_supportinginformation_display IS 'supportingInformation/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_authoredon IS 'authoredOn (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_ref IS 'requester/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_type IS 'requester/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_identifier_use IS 'requester/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_identifier_type_system IS 'requester/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_identifier_type_version IS 'requester/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_identifier_type_code IS 'requester/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_identifier_type_display IS 'requester/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_identifier_type_text IS 'requester/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_requester_display IS 'requester/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_time IS 'note/time (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_sequence IS 'dosageInstruction/sequence (int)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_text IS 'dosageInstruction/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_additionalinstruction_system IS 'dosageInstruction/additionalInstruction/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_additionalinstruction_version IS 'dosageInstruction/additionalInstruction/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_additionalinstruction_code IS 'dosageInstruction/additionalInstruction/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_additionalinstruction_display IS 'dosageInstruction/additionalInstruction/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_additionalinstruction_text IS 'dosageInstruction/additionalInstruction/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_patientinstruction IS 'dosageInstruction/patientInstruction (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_event IS 'dosageInstruction/timing/event (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_value IS 'dosageInstruction/timing/repeat/boundsDuration/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_comparator IS 'dosageInstruction/timing/repeat/boundsDuration/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_unit IS 'dosageInstruction/timing/repeat/boundsDuration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_system IS 'dosageInstruction/timing/repeat/boundsDuration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_code IS 'dosageInstruction/timing/repeat/boundsDuration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_value IS 'dosageInstruction/timing/repeat/boundsRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_unit IS 'dosageInstruction/timing/repeat/boundsRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_system IS 'dosageInstruction/timing/repeat/boundsRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_code IS 'dosageInstruction/timing/repeat/boundsRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_value IS 'dosageInstruction/timing/repeat/boundsRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_unit IS 'dosageInstruction/timing/repeat/boundsRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_system IS 'dosageInstruction/timing/repeat/boundsRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_code IS 'dosageInstruction/timing/repeat/boundsRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsperiod_start IS 'dosageInstruction/timing/repeat/boundsPeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_boundsperiod_end IS 'dosageInstruction/timing/repeat/boundsPeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_count IS 'dosageInstruction/timing/repeat/count (int)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_countmax IS 'dosageInstruction/timing/repeat/countMax (int)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_duration IS 'dosageInstruction/timing/repeat/duration (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_durationmax IS 'dosageInstruction/timing/repeat/durationMax (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_durationunit IS 'dosageInstruction/timing/repeat/durationUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_frequency IS 'dosageInstruction/timing/repeat/frequency (int)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_frequencymax IS 'dosageInstruction/timing/repeat/frequencyMax (int)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_period IS 'dosageInstruction/timing/repeat/period (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_periodmax IS 'dosageInstruction/timing/repeat/periodMax (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_periodunit IS 'dosageInstruction/timing/repeat/periodUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_dayofweek IS 'dosageInstruction/timing/repeat/dayOfWeek (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_timeofday IS 'dosageInstruction/timing/repeat/timeOfDay (time)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_when IS 'dosageInstruction/timing/repeat/when (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_repeat_offset IS 'dosageInstruction/timing/repeat/offset (int)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_code_system IS 'dosageInstruction/timing/code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_code_version IS 'dosageInstruction/timing/code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_code_code IS 'dosageInstruction/timing/code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_code_display IS 'dosageInstruction/timing/code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_timing_code_text IS 'dosageInstruction/timing/code/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_asneededboolean IS 'dosageInstruction/asNeededBoolean (boolean)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_system IS 'dosageInstruction/asNeededCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_version IS 'dosageInstruction/asNeededCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_code IS 'dosageInstruction/asNeededCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_display IS 'dosageInstruction/asNeededCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_text IS 'dosageInstruction/asNeededCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_site_system IS 'dosageInstruction/site/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_site_version IS 'dosageInstruction/site/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_site_code IS 'dosageInstruction/site/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_site_display IS 'dosageInstruction/site/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_site_text IS 'dosageInstruction/site/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_route_system IS 'dosageInstruction/route/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_route_version IS 'dosageInstruction/route/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_route_code IS 'dosageInstruction/route/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_route_display IS 'dosageInstruction/route/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_route_text IS 'dosageInstruction/route/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_method_system IS 'dosageInstruction/method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_method_version IS 'dosageInstruction/method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_method_code IS 'dosageInstruction/method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_method_display IS 'dosageInstruction/method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_method_text IS 'dosageInstruction/method/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_type_system IS 'dosageInstruction/doseAndRate/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_type_version IS 'dosageInstruction/doseAndRate/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_type_code IS 'dosageInstruction/doseAndRate/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_type_display IS 'dosageInstruction/doseAndRate/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_type_text IS 'dosageInstruction/doseAndRate/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_value IS 'dosageInstruction/doseAndRate/doseRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_unit IS 'dosageInstruction/doseAndRate/doseRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_system IS 'dosageInstruction/doseAndRate/doseRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_code IS 'dosageInstruction/doseAndRate/doseRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_value IS 'dosageInstruction/doseAndRate/doseRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_unit IS 'dosageInstruction/doseAndRate/doseRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_system IS 'dosageInstruction/doseAndRate/doseRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_code IS 'dosageInstruction/doseAndRate/doseRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_value IS 'dosageInstruction/doseAndRate/doseQuantity/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_comparator IS 'dosageInstruction/doseAndRate/doseQuantity/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_unit IS 'dosageInstruction/doseAndRate/doseQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_system IS 'dosageInstruction/doseAndRate/doseQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_code IS 'dosageInstruction/doseAndRate/doseQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_value IS 'dosageInstruction/doseAndRate/rateRatio/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator IS 'dosageInstruction/doseAndRate/rateRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_unit IS 'dosageInstruction/doseAndRate/rateRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_system IS 'dosageInstruction/doseAndRate/rateRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_code IS 'dosageInstruction/doseAndRate/rateRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_value IS 'dosageInstruction/doseAndRate/rateRatio/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator IS 'dosageInstruction/doseAndRate/rateRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_unit IS 'dosageInstruction/doseAndRate/rateRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_system IS 'dosageInstruction/doseAndRate/rateRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_code IS 'dosageInstruction/doseAndRate/rateRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_value IS 'dosageInstruction/doseAndRate/rateRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_unit IS 'dosageInstruction/doseAndRate/rateRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_system IS 'dosageInstruction/doseAndRate/rateRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_code IS 'dosageInstruction/doseAndRate/rateRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_value IS 'dosageInstruction/doseAndRate/rateRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_unit IS 'dosageInstruction/doseAndRate/rateRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_system IS 'dosageInstruction/doseAndRate/rateRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_code IS 'dosageInstruction/doseAndRate/rateRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_value IS 'dosageInstruction/doseAndRate/rateQuantity/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_unit IS 'dosageInstruction/doseAndRate/rateQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_system IS 'dosageInstruction/doseAndRate/rateQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_code IS 'dosageInstruction/doseAndRate/rateQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_value IS 'dosageInstruction/maxDosePerPeriod/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_comparator IS 'dosageInstruction/maxDosePerPeriod/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_unit IS 'dosageInstruction/maxDosePerPeriod/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_system IS 'dosageInstruction/maxDosePerPeriod/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_code IS 'dosageInstruction/maxDosePerPeriod/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_value IS 'dosageInstruction/maxDosePerPeriod/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_comparator IS 'dosageInstruction/maxDosePerPeriod/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_unit IS 'dosageInstruction/maxDosePerPeriod/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_system IS 'dosageInstruction/maxDosePerPeriod/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_code IS 'dosageInstruction/maxDosePerPeriod/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperadministration_value IS 'dosageInstruction/maxDosePerAdministration/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperadministration_unit IS 'dosageInstruction/maxDosePerAdministration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperadministration_system IS 'dosageInstruction/maxDosePerAdministration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperadministration_code IS 'dosageInstruction/maxDosePerAdministration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_value IS 'dosageInstruction/maxDosePerLifetime/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_unit IS 'dosageInstruction/maxDosePerLifetime/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_system IS 'dosageInstruction/maxDosePerLifetime/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_code IS 'dosageInstruction/maxDosePerLifetime/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_substitution_reason_system IS 'substitution/reason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_substitution_reason_version IS 'substitution/reason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_substitution_reason_code IS 'substitution/reason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_substitution_reason_display IS 'substitution/reason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.medreq_substitution_reason_text IS 'substitution/reason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationrequest.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medicationrequest.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medicationrequest.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medicationrequest.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medicationrequest.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medicationadministration.medicationadministration_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medicationadministration.medicationadministration_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_encounter_ref IS 'context/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_medicationreference_ref IS 'medicationReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_ref IS 'supportingInformation/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_type IS 'supportingInformation/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_identifier_use IS 'supportingInformation/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_identifier_type_system IS 'supportingInformation/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_identifier_type_version IS 'supportingInformation/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_identifier_type_code IS 'supportingInformation/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_identifier_type_display IS 'supportingInformation/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_identifier_type_text IS 'supportingInformation/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_supportinginformation_display IS 'supportingInformation/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_effectivedatetime IS 'effectiveDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_effectiveperiod_start IS 'effectivePeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_effectiveperiod_end IS 'effectivePeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_performer_function_system IS 'performer/function/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_performer_function_version IS 'performer/function/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_performer_function_code IS 'performer/function/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_performer_function_display IS 'performer/function/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_performer_function_text IS 'performer/function/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_request_ref IS 'request/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_time IS 'note/time (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_text IS 'dosage/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_site_system IS 'dosage/site/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_site_version IS 'dosage/site/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_site_code IS 'dosage/site/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_site_display IS 'dosage/site/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_site_text IS 'dosage/site/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_route_system IS 'dosage/route/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_route_version IS 'dosage/route/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_route_code IS 'dosage/route/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_route_display IS 'dosage/route/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_route_text IS 'dosage/route/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_method_system IS 'dosage/method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_method_version IS 'dosage/method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_method_code IS 'dosage/method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_method_display IS 'dosage/method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_method_text IS 'dosage/method/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_dose_value IS 'dosage/dose/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_dose_unit IS 'dosage/dose/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_dose_system IS 'dosage/dose/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_dose_code IS 'dosage/dose/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_numerator_value IS 'dosage/rateRatio/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_numerator_comparator IS 'dosage/rateRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_numerator_unit IS 'dosage/rateRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_numerator_system IS 'dosage/rateRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_numerator_code IS 'dosage/rateRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_denominator_value IS 'dosage/rateRatio/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_denominator_comparator IS 'dosage/rateRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_denominator_unit IS 'dosage/rateRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_denominator_system IS 'dosage/rateRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_rateratio_denominator_code IS 'dosage/rateRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_ratequantity_value IS 'dosage/rateQuantity/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_ratequantity_unit IS 'dosage/rateQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_ratequantity_system IS 'dosage/rateQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.medadm_dosage_ratequantity_code IS 'dosage/rateQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationadministration.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medicationadministration.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medicationadministration.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medicationadministration.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medicationadministration.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.medicationstatement.medicationstatement_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.medicationstatement.medicationstatement_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_encounter_ref IS 'context/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_medicationreference_ref IS 'medicationReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_effectivedatetime IS 'effectiveDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_effectiveperiod_start IS 'effectivePeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_effectiveperiod_end IS 'effectivePeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dateasserted IS 'dateAsserted (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_ref IS 'informationSource/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_type IS 'informationSource/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_identifier_use IS 'informationSource/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_identifier_type_system IS 'informationSource/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_identifier_type_version IS 'informationSource/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_identifier_type_code IS 'informationSource/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_identifier_type_display IS 'informationSource/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_identifier_type_text IS 'informationSource/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_informationsource_display IS 'informationSource/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_ref IS 'derivedFrom/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_type IS 'derivedFrom/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_identifier_use IS 'derivedFrom/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_identifier_type_system IS 'derivedFrom/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_identifier_type_version IS 'derivedFrom/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_identifier_type_code IS 'derivedFrom/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_identifier_type_display IS 'derivedFrom/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_identifier_type_text IS 'derivedFrom/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_derivedfrom_display IS 'derivedFrom/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_time IS 'note/time (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_sequence IS 'dosage/sequence (int)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_text IS 'dosage/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_additionalinstruction_system IS 'dosage/additionalInstruction/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_additionalinstruction_version IS 'dosage/additionalInstruction/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_additionalinstruction_code IS 'dosage/additionalInstruction/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_additionalinstruction_display IS 'dosage/additionalInstruction/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_additionalinstruction_text IS 'dosage/additionalInstruction/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_patientinstruction IS 'dosage/patientInstruction (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_event IS 'dosage/timing/event (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsduration_value IS 'dosage/timing/repeat/boundsDuration/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsduration_comparator IS 'dosage/timing/repeat/boundsDuration/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsduration_unit IS 'dosage/timing/repeat/boundsDuration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsduration_system IS 'dosage/timing/repeat/boundsDuration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsduration_code IS 'dosage/timing/repeat/boundsDuration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_value IS 'dosage/timing/repeat/boundsRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_unit IS 'dosage/timing/repeat/boundsRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_system IS 'dosage/timing/repeat/boundsRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_code IS 'dosage/timing/repeat/boundsRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_value IS 'dosage/timing/repeat/boundsRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_unit IS 'dosage/timing/repeat/boundsRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_system IS 'dosage/timing/repeat/boundsRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_code IS 'dosage/timing/repeat/boundsRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsperiod_start IS 'dosage/timing/repeat/boundsPeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_boundsperiod_end IS 'dosage/timing/repeat/boundsPeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_count IS 'dosage/timing/repeat/count (int)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_countmax IS 'dosage/timing/repeat/countMax (int)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_duration IS 'dosage/timing/repeat/duration (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_durationmax IS 'dosage/timing/repeat/durationMax (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_durationunit IS 'dosage/timing/repeat/durationUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_frequency IS 'dosage/timing/repeat/frequency (int)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_frequencymax IS 'dosage/timing/repeat/frequencyMax (int)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_period IS 'dosage/timing/repeat/period (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_periodmax IS 'dosage/timing/repeat/periodMax (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_periodunit IS 'dosage/timing/repeat/periodUnit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_dayofweek IS 'dosage/timing/repeat/dayOfWeek (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_timeofday IS 'dosage/timing/repeat/timeOfDay (time)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_when IS 'dosage/timing/repeat/when (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_repeat_offset IS 'dosage/timing/repeat/offset (int)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_code_system IS 'dosage/timing/code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_code_version IS 'dosage/timing/code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_code_code IS 'dosage/timing/code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_code_display IS 'dosage/timing/code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_timing_code_text IS 'dosage/timing/code/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_asneededboolean IS 'dosage/asNeededBoolean (boolean)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_asneededcodeableconcept_system IS 'dosage/asNeededCodeableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_asneededcodeableconcept_version IS 'dosage/asNeededCodeableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_asneededcodeableconcept_code IS 'dosage/asNeededCodeableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_asneededcodeableconcept_display IS 'dosage/asNeededCodeableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_asneededcodeableconcept_text IS 'dosage/asNeededCodeableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_site_system IS 'dosage/site/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_site_version IS 'dosage/site/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_site_code IS 'dosage/site/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_site_display IS 'dosage/site/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_site_text IS 'dosage/site/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_route_system IS 'dosage/route/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_route_version IS 'dosage/route/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_route_code IS 'dosage/route/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_route_display IS 'dosage/route/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_route_text IS 'dosage/route/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_method_system IS 'dosage/method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_method_version IS 'dosage/method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_method_code IS 'dosage/method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_method_display IS 'dosage/method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_method_text IS 'dosage/method/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_type_system IS 'dosage/doseAndRate/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_type_version IS 'dosage/doseAndRate/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_type_code IS 'dosage/doseAndRate/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_type_display IS 'dosage/doseAndRate/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_type_text IS 'dosage/doseAndRate/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_low_value IS 'dosage/doseAndRate/doseRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_low_unit IS 'dosage/doseAndRate/doseRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_low_system IS 'dosage/doseAndRate/doseRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_low_code IS 'dosage/doseAndRate/doseRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_high_value IS 'dosage/doseAndRate/doseRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_high_unit IS 'dosage/doseAndRate/doseRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_high_system IS 'dosage/doseAndRate/doseRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_doserange_high_code IS 'dosage/doseAndRate/doseRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_dosequantity_value IS 'dosage/doseAndRate/doseQuantity/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_dosequantity_comparator IS 'dosage/doseAndRate/doseQuantity/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_dosequantity_unit IS 'dosage/doseAndRate/doseQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_dosequantity_system IS 'dosage/doseAndRate/doseQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_dosequantity_code IS 'dosage/doseAndRate/doseQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_value IS 'dosage/doseAndRate/rateRatio/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_comparator IS 'dosage/doseAndRate/rateRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_unit IS 'dosage/doseAndRate/rateRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_system IS 'dosage/doseAndRate/rateRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_code IS 'dosage/doseAndRate/rateRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_value IS 'dosage/doseAndRate/rateRatio/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_comparator IS 'dosage/doseAndRate/rateRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_unit IS 'dosage/doseAndRate/rateRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_system IS 'dosage/doseAndRate/rateRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_code IS 'dosage/doseAndRate/rateRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_low_value IS 'dosage/doseAndRate/rateRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_low_unit IS 'dosage/doseAndRate/rateRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_low_system IS 'dosage/doseAndRate/rateRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_low_code IS 'dosage/doseAndRate/rateRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_high_value IS 'dosage/doseAndRate/rateRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_high_unit IS 'dosage/doseAndRate/rateRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_high_system IS 'dosage/doseAndRate/rateRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_raterange_high_code IS 'dosage/doseAndRate/rateRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_ratequantity_value IS 'dosage/doseAndRate/rateQuantity/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_ratequantity_unit IS 'dosage/doseAndRate/rateQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_ratequantity_system IS 'dosage/doseAndRate/rateQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_doseandrate_ratequantity_code IS 'dosage/doseAndRate/rateQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_value IS 'dosage/maxDosePerPeriod/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_comparator IS 'dosage/maxDosePerPeriod/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_unit IS 'dosage/maxDosePerPeriod/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_system IS 'dosage/maxDosePerPeriod/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_code IS 'dosage/maxDosePerPeriod/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_value IS 'dosage/maxDosePerPeriod/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_comparator IS 'dosage/maxDosePerPeriod/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_unit IS 'dosage/maxDosePerPeriod/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_system IS 'dosage/maxDosePerPeriod/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_code IS 'dosage/maxDosePerPeriod/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperadministration_value IS 'dosage/maxDosePerAdministration/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperadministration_unit IS 'dosage/maxDosePerAdministration/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperadministration_system IS 'dosage/maxDosePerAdministration/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperadministration_code IS 'dosage/maxDosePerAdministration/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperlifetime_value IS 'dosage/maxDosePerLifetime/value (double precision)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperlifetime_unit IS 'dosage/maxDosePerLifetime/unit (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperlifetime_system IS 'dosage/maxDosePerLifetime/system (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.medstat_dosage_maxdoseperlifetime_code IS 'dosage/maxDosePerLifetime/code (varchar)';
COMMENT ON COLUMN cds2db_in.medicationstatement.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.medicationstatement.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.medicationstatement.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.medicationstatement.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.medicationstatement.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.observation.observation_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.observation.observation_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.observation.obs_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.observation.obs_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_effectivedatetime IS 'effectiveDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.observation.obs_issued IS 'issued (timestamp)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_low_value IS 'valueRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_low_unit IS 'valueRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_low_system IS 'valueRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_low_code IS 'valueRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_high_value IS 'valueRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_high_unit IS 'valueRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_high_system IS 'valueRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuerange_high_code IS 'valueRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_numerator_value IS 'valueRatio/numerator/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_numerator_comparator IS 'valueRatio/numerator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_numerator_unit IS 'valueRatio/numerator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_numerator_system IS 'valueRatio/numerator/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_numerator_code IS 'valueRatio/numerator/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_denominator_value IS 'valueRatio/denominator/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_denominator_comparator IS 'valueRatio/denominator/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_denominator_unit IS 'valueRatio/denominator/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_denominator_system IS 'valueRatio/denominator/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valueratio_denominator_code IS 'valueRatio/denominator/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuequantity_value IS 'valueQuantity/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuequantity_comparator IS 'valueQuantity/comparator (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuequantity_unit IS 'valueQuantity/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuequantity_system IS 'valueQuantity/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuequantity_code IS 'valueQuantity/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuecodableconcept_system IS 'valueCodableConcept/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuecodableconcept_version IS 'valueCodableConcept/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuecodableconcept_code IS 'valueCodableConcept/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuecodableconcept_display IS 'valueCodableConcept/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_valuecodableconcept_text IS 'valueCodableConcept/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_dataabsentreason_system IS 'dataAbsentReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_dataabsentreason_version IS 'dataAbsentReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_dataabsentreason_code IS 'dataAbsentReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_dataabsentreason_display IS 'dataAbsentReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_dataabsentreason_text IS 'dataAbsentReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_time IS 'note/time (timestamp)';
COMMENT ON COLUMN cds2db_in.observation.obs_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_method_system IS 'method/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_method_version IS 'method/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_method_code IS 'method/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_method_display IS 'method/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_method_text IS 'method/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_ref IS 'performer/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_type IS 'performer/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_identifier_use IS 'performer/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_performer_display IS 'performer/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_low_value IS 'referenceRange/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_low_unit IS 'referenceRange/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_low_system IS 'referenceRange/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_low_code IS 'referenceRange/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_high_value IS 'referenceRange/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_high_unit IS 'referenceRange/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_high_system IS 'referenceRange/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_high_code IS 'referenceRange/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_type_system IS 'referenceRange/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_type_version IS 'referenceRange/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_type_code IS 'referenceRange/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_type_display IS 'referenceRange/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_type_text IS 'referenceRange/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_appliesto_system IS 'referenceRange/appliesTo/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_appliesto_version IS 'referenceRange/appliesTo/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_appliesto_code IS 'referenceRange/appliesTo/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_appliesto_display IS 'referenceRange/appliesTo/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_appliesto_text IS 'referenceRange/appliesTo/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_low_value IS 'referenceRange/age/low/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_low_unit IS 'referenceRange/age/low/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_low_system IS 'referenceRange/age/low/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_low_code IS 'referenceRange/age/low/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_high_value IS 'referenceRange/age/high/value (double precision)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_high_unit IS 'referenceRange/age/high/unit (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_high_system IS 'referenceRange/age/high/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_age_high_code IS 'referenceRange/age/high/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_referencerange_text IS 'referenceRange/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_ref IS 'hasMember/reference (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_type IS 'hasMember/type (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_identifier_use IS 'hasMember/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_identifier_type_system IS 'hasMember/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_identifier_type_version IS 'hasMember/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_identifier_type_code IS 'hasMember/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_identifier_type_display IS 'hasMember/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_identifier_type_text IS 'hasMember/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.observation.obs_hasmember_display IS 'hasMember/display (varchar)';
COMMENT ON COLUMN cds2db_in.observation.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.observation.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.observation.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.observation.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.observation.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.diagnosticreport.diagnosticreport_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagnosticreport_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_result_ref IS 'result/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_effectivedatetime IS 'effectiveDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_issued IS 'issued (timestamp)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_ref IS 'performer/reference (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_type IS 'performer/type (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_identifier_use IS 'performer/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_performer_display IS 'performer/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_conclusion IS 'conclusion (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_conclusioncode_system IS 'conclusionCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_conclusioncode_version IS 'conclusionCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_conclusioncode_code IS 'conclusionCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_conclusioncode_display IS 'conclusionCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.diagrep_conclusioncode_text IS 'conclusionCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.diagnosticreport.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.diagnosticreport.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.diagnosticreport.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.diagnosticreport.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.diagnosticreport.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.servicerequest.servicerequest_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.servicerequest.servicerequest_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_intent IS 'intent (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_authoredon IS 'authoredOn (timestamp)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_ref IS 'requester/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_type IS 'requester/type (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_identifier_use IS 'requester/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_identifier_type_system IS 'requester/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_identifier_type_version IS 'requester/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_identifier_type_code IS 'requester/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_identifier_type_display IS 'requester/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_identifier_type_text IS 'requester/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_requester_display IS 'requester/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_ref IS 'performer/reference (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_type IS 'performer/type (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_identifier_use IS 'performer/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_performer_display IS 'performer/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_locationcode_system IS 'locationCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_locationcode_version IS 'locationCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_locationcode_code IS 'locationCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_locationcode_display IS 'locationCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.servreq_locationcode_text IS 'locationCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.servicerequest.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.servicerequest.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.servicerequest.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.servicerequest.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.servicerequest.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.procedure.procedure_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.procedure.procedure_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.procedure.proc_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_encounter_ref IS 'encounter/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_patient_ref IS 'subject/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_partof_ref IS 'partOf/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.procedure.proc_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_ref IS 'basedOn/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_type IS 'basedOn/type (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_basedon_display IS 'basedOn/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_statusreason_system IS 'statusReason/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_statusreason_version IS 'statusReason/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_statusreason_code IS 'statusReason/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_statusreason_display IS 'statusReason/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_statusreason_text IS 'statusReason/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_category_system IS 'category/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_category_version IS 'category/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_category_code IS 'category/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_category_display IS 'category/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_category_text IS 'category/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_code_system IS 'code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_code_version IS 'code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_code_code IS 'code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_code_display IS 'code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_code_text IS 'code/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_performeddatetime IS 'performedDateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.procedure.proc_performedperiod_start IS 'performedPeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.procedure.proc_performedperiod_end IS 'performedPeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasoncode_system IS 'reasonCode/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasoncode_version IS 'reasonCode/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasoncode_code IS 'reasonCode/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasoncode_display IS 'reasonCode/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasoncode_text IS 'reasonCode/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_ref IS 'reasonReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_type IS 'reasonReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_reasonreference_display IS 'reasonReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorstring IS 'note/authorString (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_type IS 'note/authorReference/type (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_authorreference_display IS 'note/authorReference/display (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_time IS 'note/time (timestamp)';
COMMENT ON COLUMN cds2db_in.procedure.proc_note_text IS 'note/text (varchar)';
COMMENT ON COLUMN cds2db_in.procedure.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.procedure.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.procedure.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.procedure.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.procedure.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.consent.consent_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.consent.consent_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.consent.cons_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_patient_ref IS 'patient/reference (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.cons_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.cons_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_scope_system IS 'scope/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_scope_version IS 'scope/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_scope_code IS 'scope/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_scope_display IS 'scope/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_scope_text IS 'scope/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_datetime IS 'dateTime (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_type IS 'provision/type (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_period_start IS 'provision/period/start (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_period_end IS 'provision/period/end (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_actor_role_system IS 'provision/actor/role/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_actor_role_version IS 'provision/actor/role/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_actor_role_code IS 'provision/actor/role/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_actor_role_display IS 'provision/actor/role/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_actor_role_text IS 'provision/actor/role/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_code_system IS 'provision/code/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_code_version IS 'provision/code/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_code_code IS 'provision/code/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_code_display IS 'provision/code/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_code_text IS 'provision/code/text (varchar)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_dataperiod_start IS 'provision/dataPeriod/start (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.cons_provision_dataperiod_end IS 'provision/dataPeriod/end (timestamp)';
COMMENT ON COLUMN cds2db_in.consent.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.consent.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.consent.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.consent.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.consent.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.location.location_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.location.location_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.location.loc_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_start IS 'identifier/start (timestamp)';
COMMENT ON COLUMN cds2db_in.location.loc_identifier_end IS 'identifier/end (timestamp)';
COMMENT ON COLUMN cds2db_in.location.loc_status IS 'status (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_name IS 'name (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_description IS 'description (varchar)';
COMMENT ON COLUMN cds2db_in.location.loc_alias IS 'alias (varchar)';
COMMENT ON COLUMN cds2db_in.location.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.location.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.location.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.location.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.location.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN cds2db_in.pids_per_ward.pids_per_ward_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.pids_per_ward.pids_per_ward_raw_id IS 'Primary key of the corresponding raw table';
COMMENT ON COLUMN cds2db_in.pids_per_ward.ward_name IS 'ward_name (varchar)';
COMMENT ON COLUMN cds2db_in.pids_per_ward.patient_id IS 'patient_id (varchar)';
COMMENT ON COLUMN cds2db_in.pids_per_ward.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.pids_per_ward.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.pids_per_ward.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.pids_per_ward.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.pids_per_ward.last_processing_nr IS 'Last processing number of the data record';


-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "cds2db_in" --
------------------------------------------------------

------------------------- Index for cds2db_in - encounter ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_encounter_raw_id ON cds2db_in.encounter ( encounter_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_encounter_input_dt for Table "encounter" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_input_dt
ON cds2db_in.encounter (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_encounter_input_pnr for Table "encounter" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_input_pnr
ON cds2db_in.encounter (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_encounter_last_dt for Table "encounter" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_last_dt
ON cds2db_in.encounter (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_encounter_last_dt for Table "encounter" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_last_pnr
ON cds2db_in.encounter (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_encounter_hash for Table "encounter" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_encounter_hash
ON cds2db_in.encounter (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - patient ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_patient_raw_id ON cds2db_in.patient ( patient_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_patient_input_dt for Table "patient" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_input_dt
ON cds2db_in.patient (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_patient_input_pnr for Table "patient" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_input_pnr
ON cds2db_in.patient (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_patient_last_dt for Table "patient" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_last_dt
ON cds2db_in.patient (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_patient_last_dt for Table "patient" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_last_pnr
ON cds2db_in.patient (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_patient_hash for Table "patient" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_patient_hash
ON cds2db_in.patient (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - condition ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_condition_raw_id ON cds2db_in.condition ( condition_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_condition_input_dt for Table "condition" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_input_dt
ON cds2db_in.condition (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_condition_input_pnr for Table "condition" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_input_pnr
ON cds2db_in.condition (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_condition_last_dt for Table "condition" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_last_dt
ON cds2db_in.condition (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_condition_last_dt for Table "condition" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_last_pnr
ON cds2db_in.condition (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_condition_hash for Table "condition" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_condition_hash
ON cds2db_in.condition (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medication ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_medication_raw_id ON cds2db_in.medication ( medication_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_medication_input_dt for Table "medication" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_input_dt
ON cds2db_in.medication (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medication_input_pnr for Table "medication" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_input_pnr
ON cds2db_in.medication (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medication_last_dt for Table "medication" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_last_dt
ON cds2db_in.medication (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medication_last_dt for Table "medication" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_last_pnr
ON cds2db_in.medication (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medication_hash for Table "medication" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medication_hash
ON cds2db_in.medication (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medicationrequest ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_medicationrequest_raw_id ON cds2db_in.medicationrequest ( medicationrequest_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_medicationrequest_input_dt for Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_input_dt
ON cds2db_in.medicationrequest (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medicationrequest_input_pnr for Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_input_pnr
ON cds2db_in.medicationrequest (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medicationrequest_last_dt for Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_last_dt
ON cds2db_in.medicationrequest (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medicationrequest_last_dt for Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_last_pnr
ON cds2db_in.medicationrequest (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medicationrequest_hash for Table "medicationrequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationrequest_hash
ON cds2db_in.medicationrequest (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medicationadministration ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_medicationadministration_raw_id ON cds2db_in.medicationadministration ( medicationadministration_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_medicationadministration_input_dt for Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_input_dt
ON cds2db_in.medicationadministration (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medicationadministration_input_pnr for Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_input_pnr
ON cds2db_in.medicationadministration (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medicationadministration_last_dt for Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_last_dt
ON cds2db_in.medicationadministration (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medicationadministration_last_dt for Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_last_pnr
ON cds2db_in.medicationadministration (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medicationadministration_hash for Table "medicationadministration" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationadministration_hash
ON cds2db_in.medicationadministration (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - medicationstatement ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_medicationstatement_raw_id ON cds2db_in.medicationstatement ( medicationstatement_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_medicationstatement_input_dt for Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_input_dt
ON cds2db_in.medicationstatement (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_medicationstatement_input_pnr for Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_input_pnr
ON cds2db_in.medicationstatement (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_medicationstatement_last_dt for Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_last_dt
ON cds2db_in.medicationstatement (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_medicationstatement_last_dt for Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_last_pnr
ON cds2db_in.medicationstatement (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_medicationstatement_hash for Table "medicationstatement" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_medicationstatement_hash
ON cds2db_in.medicationstatement (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - observation ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_observation_raw_id ON cds2db_in.observation ( observation_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_observation_input_dt for Table "observation" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_input_dt
ON cds2db_in.observation (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_observation_input_pnr for Table "observation" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_input_pnr
ON cds2db_in.observation (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_observation_last_dt for Table "observation" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_last_dt
ON cds2db_in.observation (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_observation_last_dt for Table "observation" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_last_pnr
ON cds2db_in.observation (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_observation_hash for Table "observation" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_observation_hash
ON cds2db_in.observation (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - diagnosticreport ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_diagnosticreport_raw_id ON cds2db_in.diagnosticreport ( diagnosticreport_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_diagnosticreport_input_dt for Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_input_dt
ON cds2db_in.diagnosticreport (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_diagnosticreport_input_pnr for Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_input_pnr
ON cds2db_in.diagnosticreport (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_diagnosticreport_last_dt for Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_last_dt
ON cds2db_in.diagnosticreport (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_diagnosticreport_last_dt for Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_last_pnr
ON cds2db_in.diagnosticreport (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_diagnosticreport_hash for Table "diagnosticreport" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_diagnosticreport_hash
ON cds2db_in.diagnosticreport (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - servicerequest ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_servicerequest_raw_id ON cds2db_in.servicerequest ( servicerequest_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_servicerequest_input_dt for Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_input_dt
ON cds2db_in.servicerequest (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_servicerequest_input_pnr for Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_input_pnr
ON cds2db_in.servicerequest (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_servicerequest_last_dt for Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_last_dt
ON cds2db_in.servicerequest (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_servicerequest_last_dt for Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_last_pnr
ON cds2db_in.servicerequest (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_servicerequest_hash for Table "servicerequest" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_servicerequest_hash
ON cds2db_in.servicerequest (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - procedure ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_procedure_raw_id ON cds2db_in.procedure ( procedure_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_procedure_input_dt for Table "procedure" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_input_dt
ON cds2db_in.procedure (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_procedure_input_pnr for Table "procedure" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_input_pnr
ON cds2db_in.procedure (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_procedure_last_dt for Table "procedure" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_last_dt
ON cds2db_in.procedure (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_procedure_last_dt for Table "procedure" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_last_pnr
ON cds2db_in.procedure (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_procedure_hash for Table "procedure" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_procedure_hash
ON cds2db_in.procedure (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - consent ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_consent_raw_id ON cds2db_in.consent ( consent_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_consent_input_dt for Table "consent" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_input_dt
ON cds2db_in.consent (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_consent_input_pnr for Table "consent" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_input_pnr
ON cds2db_in.consent (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_consent_last_dt for Table "consent" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_last_dt
ON cds2db_in.consent (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_consent_last_dt for Table "consent" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_last_pnr
ON cds2db_in.consent (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_consent_hash for Table "consent" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_consent_hash
ON cds2db_in.consent (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - location ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_location_raw_id ON cds2db_in.location ( location_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_location_input_dt for Table "location" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_input_dt
ON cds2db_in.location (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_location_input_pnr for Table "location" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_input_pnr
ON cds2db_in.location (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_location_last_dt for Table "location" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_last_dt
ON cds2db_in.location (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_location_last_dt for Table "location" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_last_pnr
ON cds2db_in.location (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_location_hash for Table "location" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_location_hash
ON cds2db_in.location (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for cds2db_in - pids_per_ward ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_pids_per_ward_raw_id ON cds2db_in.pids_per_ward ( pids_per_ward_raw_id); -- Primary key of the corresponding raw table

-- Index idx_cds2db_in_pids_per_ward_input_dt for Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_input_dt
ON cds2db_in.pids_per_ward (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_cds2db_in_pids_per_ward_input_pnr for Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_input_pnr
ON cds2db_in.pids_per_ward (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_cds2db_in_pids_per_ward_last_dt for Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_last_dt
ON cds2db_in.pids_per_ward (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_cds2db_in_pids_per_ward_last_dt for Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_last_pnr
ON cds2db_in.pids_per_ward (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_cds2db_in_pids_per_ward_hash for Table "pids_per_ward" in schema "cds2db_in"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cds2db_in_pids_per_ward_hash
ON cds2db_in.pids_per_ward (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);


