-----------------------------------------------------
-- Create SQL Tables in Schema "db_log" --
-----------------------------------------------------

-- Table "encounter" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.encounter (
  encounter_id serial PRIMARY KEY not null, -- Primary key of the entity
  enc_id varchar (70),   -- id (70 varchar)
  enc_patient_id varchar (70),   -- subject/reference (70 varchar)
  enc_partof_id varchar (70),   -- partOf/reference (70 varchar)
  enc_identifier_use varchar (50),   -- identifier/use (50 varchar)
  enc_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  enc_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  enc_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  enc_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  enc_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  enc_identifier_system varchar (70),   -- identifier/system (70 varchar)
  enc_identifier_value varchar (70),   -- identifier/value (70 varchar)
  enc_identifier_start timestamp,   -- identifier/start (30 timestamp)
  enc_identifier_end timestamp,   -- identifier/end (30 timestamp)
  enc_status varchar (30),   -- status (30 varchar)
  enc_class_system varchar (70),   -- class/coding/system (70 varchar)
  enc_class_version varchar (50),   -- class/coding/version (50 varchar)
  enc_class_code varchar (30),   -- class/coding/code (30 varchar)
  enc_class_display varchar (100),   -- class/coding/display (100 varchar)
  enc_type_system varchar (70),   -- type/coding/system (70 varchar)
  enc_type_version varchar (50),   -- type/coding/version (50 varchar)
  enc_type_code varchar (30),   -- type/coding/code (30 varchar)
  enc_type_display varchar (100),   -- type/coding/display (100 varchar)
  enc_type_text varchar (500),   -- type/text (500 varchar)
  enc_servicetype_system varchar (70),   -- serviceType/coding/system (70 varchar)
  enc_servicetype_version varchar (50),   -- serviceType/coding/version (50 varchar)
  enc_servicetype_code varchar (30),   -- serviceType/coding/code (30 varchar)
  enc_servicetype_display varchar (100),   -- serviceType/coding/display (100 varchar)
  enc_servicetype_text varchar (500),   -- serviceType/text (500 varchar)
  enc_period_start timestamp,   -- period/start (30 timestamp)
  enc_period_end timestamp,   -- period/end (30 timestamp)
  enc_diagnosis_condition_id varchar (70),   -- diagnosis/condition/reference (70 varchar)
  enc_diagnosis_use_system varchar (70),   -- diagnosis/use/coding/system (70 varchar)
  enc_diagnosis_use_version varchar (50),   -- diagnosis/use/coding/version (50 varchar)
  enc_diagnosis_use_code varchar (30),   -- diagnosis/use/coding/code (30 varchar)
  enc_diagnosis_use_display varchar (100),   -- diagnosis/use/coding/display (100 varchar)
  enc_diagnosis_use_text varchar (500),   -- diagnosis/use/text (500 varchar)
  enc_diagnosis_rank int,   -- diagnosis/rank (2 int)
  enc_hospitalization_admitsource_system varchar (70),   -- hospitalization/admitSource/coding/system (70 varchar)
  enc_hospitalization_admitsource_version varchar (50),   -- hospitalization/admitSource/coding/version (50 varchar)
  enc_hospitalization_admitsource_code varchar (30),   -- hospitalization/admitSource/coding/code (30 varchar)
  enc_hospitalization_admitsource_display varchar (100),   -- hospitalization/admitSource/coding/display (100 varchar)
  enc_hospitalization_admitsource_text varchar (500),   -- hospitalization/admitSource/text (500 varchar)
  enc_hospitalization_dischargedisposition_system varchar (70),   -- hospitalization/dischargeDisposition/coding/system (70 varchar)
  enc_hospitalization_dischargedisposition_version varchar (50),   -- hospitalization/dischargeDisposition/coding/version (50 varchar)
  enc_hospitalization_dischargedisposition_code varchar (30),   -- hospitalization/dischargeDisposition/coding/code (30 varchar)
  enc_hospitalization_dischargedisposition_display varchar (100),   -- hospitalization/dischargeDisposition/coding/display (100 varchar)
  enc_hospitalization_dischargedisposition_text varchar (500),   -- hospitalization/dischargeDisposition/text (500 varchar)
  enc_location_id varchar (70),   -- location/location/reference (70 varchar)
  enc_location_type varchar (30),   -- location/location/type (30 varchar)
  enc_location_identifier_use varchar (30),   -- location/location/identifier/use (30 varchar)
  enc_location_identifier_type_system varchar (70),   -- location/location/identifier/type/coding/system (70 varchar)
  enc_location_identifier_type_version varchar (50),   -- location/location/identifier/type/coding/version (50 varchar)
  enc_location_identifier_type_code varchar (30),   -- location/location/identifier/type/coding/code (30 varchar)
  enc_location_identifier_type_display varchar (100),   -- location/location/identifier/type/coding/display (100 varchar)
  enc_location_identifier_type_text varchar (500),   -- location/location/identifier/type/text (500 varchar)
  enc_location_display varchar (100),   -- location/location/display (100 varchar)
  enc_location_status varchar (10),   -- location/location/status (10 varchar)
  enc_location_physicaltype_system varchar (70),   -- location/location/physicalType/coding/system (70 varchar)
  enc_location_physicaltype_version varchar (50),   -- location/location/physicalType/coding/version (50 varchar)
  enc_location_physicaltype_code varchar (30),   -- location/location/physicalType/coding/code (30 varchar)
  enc_location_physicaltype_display varchar (100),   -- location/location/physicalType/coding/display (100 varchar)
  enc_location_physicaltype_text varchar (500),   -- location/location/physicalType/text (500 varchar)
  enc_serviceprovider_id varchar (70),   -- serviceProvider/reference (70 varchar)
  enc_serviceprovider_type varchar (30),   -- serviceProvider/type (30 varchar)
  enc_serviceprovider_identifier_use varchar (30),   -- serviceProvider/identifier/use (30 varchar)
  enc_serviceprovider_identifier_type_system varchar (70),   -- serviceProvider/identifier/type/coding/system (70 varchar)
  enc_serviceprovider_identifier_type_version varchar (50),   -- serviceProvider/identifier/type/coding/version (50 varchar)
  enc_serviceprovider_identifier_type_code varchar (30),   -- serviceProvider/identifier/type/coding/code (30 varchar)
  enc_serviceprovider_identifier_type_display varchar (100),   -- serviceProvider/identifier/type/coding/display (100 varchar)
  enc_serviceprovider_identifier_type_text varchar (500),   -- serviceProvider/identifier/type/text (500 varchar)
  enc_serviceprovider_display varchar (100),   -- serviceProvider/display (100 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "patient" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.patient (
  patient_id serial PRIMARY KEY not null, -- Primary key of the entity
  pat_id varchar (70),   -- id (70 varchar)
  pat_identifier_use varchar (50),   -- identifier/use (50 varchar)
  pat_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  pat_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  pat_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  pat_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  pat_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  pat_identifier_system varchar (70),   -- identifier/system (70 varchar)
  pat_identifier_value varchar (70),   -- identifier/value (70 varchar)
  pat_identifier_start timestamp,   -- identifier/start (30 timestamp)
  pat_identifier_end timestamp,   -- identifier/end (30 timestamp)
  pat_name_text varchar (250),   -- name/text (250 varchar)
  pat_name_family varchar (50),   -- name/family (50 varchar)
  pat_name_given varchar (30),   -- name/given (30 varchar)
  pat_gender varchar (10),   -- gender (10 varchar)
  pat_birthdate date,   -- birthDate (30 date)
  pat_address_postalcode varchar (10),   -- address/postalCode (10 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "condition" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.condition (
  condition_id serial PRIMARY KEY not null, -- Primary key of the entity
  con_id varchar (70),   -- id (70 varchar)
  con_encounter_id varchar (70),   -- encounter/reference (70 varchar)
  con_patient_id varchar (70),   -- subject/reference (70 varchar)
  con_identifier_use varchar (50),   -- identifier/use (50 varchar)
  con_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  con_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  con_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  con_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  con_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  con_identifier_system varchar (70),   -- identifier/system (70 varchar)
  con_identifier_value varchar (70),   -- identifier/value (70 varchar)
  con_identifier_start timestamp,   -- identifier/start (30 timestamp)
  con_identifier_end timestamp,   -- identifier/end (30 timestamp)
  con_clinicalstatus_system varchar (70),   -- clinicalStatus/coding/system (70 varchar)
  con_clinicalstatus_version varchar (50),   -- clinicalStatus/coding/version (50 varchar)
  con_clinicalstatus_code varchar (30),   -- clinicalStatus/coding/code (30 varchar)
  con_clinicalstatus_display varchar (100),   -- clinicalStatus/coding/display (100 varchar)
  con_clinicalstatus_text varchar (500),   -- clinicalStatus/text (500 varchar)
  con_verificationstatus_system varchar (70),   -- verificationStatus/coding/system (70 varchar)
  con_verificationstatus_version varchar (50),   -- verificationStatus/coding/version (50 varchar)
  con_verificationstatus_code varchar (30),   -- verificationStatus/coding/code (30 varchar)
  con_verificationstatus_display varchar (100),   -- verificationStatus/coding/display (100 varchar)
  con_verificationstatus_text varchar (500),   -- verificationStatus/text (500 varchar)
  con_category_system varchar (70),   -- category/coding/system (70 varchar)
  con_category_version varchar (50),   -- category/coding/version (50 varchar)
  con_category_code varchar (30),   -- category/coding/code (30 varchar)
  con_category_display varchar (100),   -- category/coding/display (100 varchar)
  con_category_text varchar (500),   -- category/text (500 varchar)
  con_severity_system varchar (70),   -- severity/coding/system (70 varchar)
  con_severity_version varchar (50),   -- severity/coding/version (50 varchar)
  con_severity_code varchar (30),   -- severity/coding/code (30 varchar)
  con_severity_display varchar (100),   -- severity/coding/display (100 varchar)
  con_severity_text varchar (500),   -- severity/text (500 varchar)
  con_code_system varchar (70),   -- code/coding/system (70 varchar)
  con_code_version varchar (50),   -- code/coding/version (50 varchar)
  con_code_code varchar (30),   -- code/coding/code (30 varchar)
  con_code_display varchar (100),   -- code/coding/display (100 varchar)
  con_code_text varchar (500),   -- code/text (500 varchar)
  con_bodysite_system varchar (70),   -- bodySite/coding/system (70 varchar)
  con_bodysite_version varchar (50),   -- bodySite/coding/version (50 varchar)
  con_bodysite_code varchar (30),   -- bodySite/coding/code (30 varchar)
  con_bodysite_display varchar (100),   -- bodySite/coding/display (100 varchar)
  con_bodysite_text varchar (500),   -- bodySite/text (500 varchar)
  con_onsetperiod_start timestamp,   -- onsetPeriod/start (30 timestamp)
  con_onsetperiod_end timestamp,   -- onsetPeriod/end (30 timestamp)
  con_onsetdatetime timestamp,   -- onsetDateTime (30 timestamp)
  con_abatementdatetime timestamp,   -- abatementDateTime (30 timestamp)
  con_abatementage_value numeric (10, 10),   -- abatementAge/value (10 numeric)
  con_abatementage_comparator varchar (3),   -- abatementAge/comparator (3 varchar)
  con_abatementage_unit varchar (30),   -- abatementAge/unit (30 varchar)
  con_abatementage_system varchar (70),   -- abatementAge/system (70 varchar)
  con_abatementage_code varchar (30),   -- abatementAge/code (30 varchar)
  con_abatementperiod_start timestamp,   -- abatementPeriod/start (30 timestamp)
  con_abatementperiod_end timestamp,   -- abatementPeriod/end (30 timestamp)
  con_abatementrange_low_value numeric (10, 10),   -- abatementRange/low/value (10 numeric)
  con_abatementrange_low_unit varchar (30),   -- abatementRange/low/unit (30 varchar)
  con_abatementrange_low_system varchar (70),   -- abatementRange/low/system (70 varchar)
  con_abatementrange_low_code varchar (30),   -- abatementRange/low/code (30 varchar)
  con_abatementrange_high_value numeric (10, 10),   -- abatementRange/high/value (10 numeric)
  con_abatementrange_high_unit varchar (30),   -- abatementRange/high/unit (30 varchar)
  con_abatementrange_high_system varchar (70),   -- abatementRange/high/system (70 varchar)
  con_abatementrange_high_code varchar (30),   -- abatementRange/high/code (30 varchar)
  con_abatementstring varchar (300),   -- abatementString (300 varchar)
  con_recordeddate timestamp,   -- recordedDate (30 timestamp)
  con_recorder_id varchar (70),   -- recorder/reference (70 varchar)
  con_recorder_type varchar (30),   -- recorder/type (30 varchar)
  con_recorder_identifier_use varchar (30),   -- recorder/identifier/use (30 varchar)
  con_recorder_identifier_type_system varchar (70),   -- recorder/identifier/type/coding/system (70 varchar)
  con_recorder_identifier_type_version varchar (50),   -- recorder/identifier/type/coding/version (50 varchar)
  con_recorder_identifier_type_code varchar (30),   -- recorder/identifier/type/coding/code (30 varchar)
  con_recorder_identifier_type_display varchar (100),   -- recorder/identifier/type/coding/display (100 varchar)
  con_recorder_identifier_type_text varchar (500),   -- recorder/identifier/type/text (500 varchar)
  con_recorder_display varchar (100),   -- recorder/display (100 varchar)
  con_asserter_id varchar (70),   -- asserter/reference (70 varchar)
  con_asserter_type varchar (30),   -- asserter/type (30 varchar)
  con_asserter_identifier_use varchar (30),   -- asserter/identifier/use (30 varchar)
  con_asserter_identifier_type_system varchar (70),   -- asserter/identifier/type/coding/system (70 varchar)
  con_asserter_identifier_type_version varchar (50),   -- asserter/identifier/type/coding/version (50 varchar)
  con_asserter_identifier_type_code varchar (30),   -- asserter/identifier/type/coding/code (30 varchar)
  con_asserter_identifier_type_display varchar (100),   -- asserter/identifier/type/coding/display (100 varchar)
  con_asserter_identifier_type_text varchar (500),   -- asserter/identifier/type/text (500 varchar)
  con_asserter_display varchar (100),   -- asserter/display (100 varchar)
  con_stage_summary_system varchar (70),   -- stage/summary/coding/system (70 varchar)
  con_stage_summary_version varchar (50),   -- stage/summary/coding/version (50 varchar)
  con_stage_summary_code varchar (30),   -- stage/summary/coding/code (30 varchar)
  con_stage_summary_display varchar (100),   -- stage/summary/coding/display (100 varchar)
  con_stage_summary_text varchar (500),   -- stage/summary/text (500 varchar)
  con_stage_assessment_id varchar (70),   -- stage/assessment/reference (70 varchar)
  con_stage_assessment_type varchar (30),   -- stage/assessment/type (30 varchar)
  con_stage_assessment_identifier_use varchar (30),   -- stage/assessment/identifier/use (30 varchar)
  con_stage_assessment_identifier_type_system varchar (70),   -- stage/assessment/identifier/type/coding/system (70 varchar)
  con_stage_assessment_identifier_type_version varchar (50),   -- stage/assessment/identifier/type/coding/version (50 varchar)
  con_stage_assessment_identifier_type_code varchar (30),   -- stage/assessment/identifier/type/coding/code (30 varchar)
  con_stage_assessment_identifier_type_display varchar (100),   -- stage/assessment/identifier/type/coding/display (100 varchar)
  con_stage_assessment_identifier_type_text varchar (500),   -- stage/assessment/identifier/type/text (500 varchar)
  con_stage_assessment_display varchar (100),   -- stage/assessment/display (100 varchar)
  con_stage_type_system varchar (70),   -- stage/type/coding/system (70 varchar)
  con_stage_type_version varchar (50),   -- stage/type/coding/version (50 varchar)
  con_stage_type_code varchar (30),   -- stage/type/coding/code (30 varchar)
  con_stage_type_display varchar (100),   -- stage/type/coding/display (100 varchar)
  con_stage_type_text varchar (500),   -- stage/type/text (500 varchar)
  con_note_authorstring varchar (50),   -- note/authorString (50 varchar)
  con_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 varchar)
  con_note_authorreference_type varchar (30),   -- note/authorReference/type (30 varchar)
  con_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 varchar)
  con_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 varchar)
  con_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 varchar)
  con_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 varchar)
  con_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 varchar)
  con_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 varchar)
  con_note_authorreference_display varchar (100),   -- note/authorReference/display (100 varchar)
  con_note_time timestamp,   -- note/time (30 timestamp)
  con_note_text varchar (5000),   -- note/text (5000 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medication" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medication (
  medication_id serial PRIMARY KEY not null, -- Primary key of the entity
  med_id varchar (70),   -- id (70 varchar)
  med_identifier_use varchar (50),   -- identifier/use (50 varchar)
  med_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  med_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  med_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  med_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  med_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  med_identifier_system varchar (70),   -- identifier/system (70 varchar)
  med_identifier_value varchar (70),   -- identifier/value (70 varchar)
  med_identifier_start timestamp,   -- identifier/start (30 timestamp)
  med_identifier_end timestamp,   -- identifier/end (30 timestamp)
  med_code_system varchar (70),   -- code/coding/system (70 varchar)
  med_code_version varchar (50),   -- code/coding/version (50 varchar)
  med_code_code varchar (30),   -- code/coding/code (30 varchar)
  med_code_display varchar (100),   -- code/coding/display (100 varchar)
  med_code_text varchar (500),   -- code/text (500 varchar)
  med_status varchar (20),   -- status (20 varchar)
  med_form_system varchar (70),   -- form/coding/system (70 varchar)
  med_form_version varchar (50),   -- form/coding/version (50 varchar)
  med_form_code varchar (30),   -- form/coding/code (30 varchar)
  med_form_display varchar (100),   -- form/coding/display (100 varchar)
  med_form_text varchar (500),   -- form/text (500 varchar)
  med_amount_numerator_value numeric (10, 10),   -- amount/numerator/value (10 numeric)
  med_amount_numerator_comparator varchar (10),   -- amount/numerator/comparator (10 varchar)
  med_amount_numerator_unit varchar (30),   -- amount/numerator/unit (30 varchar)
  med_amount_numerator_system varchar (70),   -- amount/numerator/system (70 varchar)
  med_amount_numerator_code varchar (30),   -- amount/numerator/code (30 varchar)
  med_amount_denominator_value numeric (10, 10),   -- amount/denominator/value (10 numeric)
  med_amount_denominator_comparator varchar (10),   -- amount/denominator/comparator (10 varchar)
  med_amount_denominator_unit varchar (30),   -- amount/denominator/unit (30 varchar)
  med_amount_denominator_system varchar (70),   -- amount/denominator/system (70 varchar)
  med_amount_denominator_code varchar (30),   -- amount/denominator/code (30 varchar)
  med_ingredient_strength_numerator_value numeric (10, 10),   -- ingredient/strength/numerator/value (10 numeric)
  med_ingredient_strength_numerator_comparator varchar (10),   -- ingredient/strength/numerator/comparator (10 varchar)
  med_ingredient_strength_numerator_unit varchar (30),   -- ingredient/strength/numerator/unit (30 varchar)
  med_ingredient_strength_numerator_system varchar (70),   -- ingredient/strength/numerator/system (70 varchar)
  med_ingredient_strength_numerator_code varchar (30),   -- ingredient/strength/numerator/code (30 varchar)
  med_ingredient_strength_denominator_value numeric (10, 10),   -- ingredient/strength/denominator/value (10 numeric)
  med_ingredient_strength_denominator_comparator varchar (10),   -- ingredient/strength/denominator/comparator (10 varchar)
  med_ingredient_strength_denominator_unit varchar (30),   -- ingredient/strength/denominator/unit (30 varchar)
  med_ingredient_strength_denominator_system varchar (70),   -- ingredient/strength/denominator/system (70 varchar)
  med_ingredient_strength_denominator_code varchar (30),   -- ingredient/strength/denominator/code (30 varchar)
  med_ingredient_itemcodeableconcept_system varchar (70),   -- ingredient/itemCodeableConcept/coding/system (70 varchar)
  med_ingredient_itemcodeableconcept_version varchar (50),   -- ingredient/itemCodeableConcept/coding/version (50 varchar)
  med_ingredient_itemcodeableconcept_code varchar (30),   -- ingredient/itemCodeableConcept/coding/code (30 varchar)
  med_ingredient_itemcodeableconcept_display varchar (100),   -- ingredient/itemCodeableConcept/coding/display (100 varchar)
  med_ingredient_itemcodeableconcept_text varchar (500),   -- ingredient/itemCodeableConcept/text (500 varchar)
  med_ingredient_itemreference_id varchar (70),   -- ingredient/itemReference/reference (70 varchar)
  med_ingredient_itemreference_type varchar (30),   -- ingredient/itemReference/type (30 varchar)
  med_ingredient_itemreference_identifier_use varchar (30),   -- ingredient/itemReference/identifier/use (30 varchar)
  med_ingredient_itemreference_identifier_type_system varchar (70),   -- ingredient/itemReference/identifier/type/coding/system (70 varchar)
  med_ingredient_itemreference_identifier_type_version varchar (50),   -- ingredient/itemReference/identifier/type/coding/version (50 varchar)
  med_ingredient_itemreference_identifier_type_code varchar (30),   -- ingredient/itemReference/identifier/type/coding/code (30 varchar)
  med_ingredient_itemreference_identifier_type_display varchar (100),   -- ingredient/itemReference/identifier/type/coding/display (100 varchar)
  med_ingredient_itemreference_identifier_type_text varchar (500),   -- ingredient/itemReference/identifier/type/text (500 varchar)
  med_ingredient_itemreference_display varchar (100),   -- ingredient/itemReference/display (100 varchar)
  med_ingredient_isactive boolean,   -- ingredient/isActive (10 boolean)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medicationrequest" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medicationrequest (
  medicationrequest_id serial PRIMARY KEY not null, -- Primary key of the entity
  medreq_id varchar (70),   -- id (70 varchar)
  medreq_encounter_id varchar (70),   -- encounter/reference (70 varchar)
  medreq_patient_id varchar (70),   -- subject/reference (70 varchar)
  medreq_identifier_use varchar (50),   -- identifier/use (50 varchar)
  medreq_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  medreq_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  medreq_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  medreq_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  medreq_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  medreq_identifier_system varchar (70),   -- identifier/system (70 varchar)
  medreq_identifier_value varchar (70),   -- identifier/value (70 varchar)
  medreq_identifier_start timestamp,   -- identifier/start (30 timestamp)
  medreq_identifier_end timestamp,   -- identifier/end (30 timestamp)
  medreq_medicationreference_id varchar (70),   -- medicationReference/reference (70 varchar)
  medreq_status varchar (20),   -- status (20 varchar)
  medreq_statusreason_system varchar (70),   -- statusReason/coding/system (70 varchar)
  medreq_statusreason_version varchar (50),   -- statusReason/coding/version (50 varchar)
  medreq_statusreason_code varchar (30),   -- statusReason/coding/code (30 varchar)
  medreq_statusreason_display varchar (100),   -- statusReason/coding/display (100 varchar)
  medreq_statusreason_text varchar (500),   -- statusReason/text (500 varchar)
  medreq_intend varchar (20),   -- intend (20 varchar)
  medreq_category_system varchar (70),   -- category/coding/system (70 varchar)
  medreq_category_version varchar (50),   -- category/coding/version (50 varchar)
  medreq_category_code varchar (30),   -- category/coding/code (30 varchar)
  medreq_category_display varchar (100),   -- category/coding/display (100 varchar)
  medreq_category_text varchar (500),   -- category/text (500 varchar)
  medreq_priority varchar (10),   -- priority (10 varchar)
  medreq_reportedboolean boolean,   -- reportedBoolean (10 boolean)
  medreq_reportedreference_id varchar (70),   -- reportedReference/reference (70 varchar)
  medreq_reportedreference_type varchar (30),   -- reportedReference/type (30 varchar)
  medreq_reportedreference_identifier_use varchar (30),   -- reportedReference/identifier/use (30 varchar)
  medreq_reportedreference_identifier_type_system varchar (70),   -- reportedReference/identifier/type/coding/system (70 varchar)
  medreq_reportedreference_identifier_type_version varchar (50),   -- reportedReference/identifier/type/coding/version (50 varchar)
  medreq_reportedreference_identifier_type_code varchar (30),   -- reportedReference/identifier/type/coding/code (30 varchar)
  medreq_reportedreference_identifier_type_display varchar (100),   -- reportedReference/identifier/type/coding/display (100 varchar)
  medreq_reportedreference_identifier_type_text varchar (500),   -- reportedReference/identifier/type/text (500 varchar)
  medreq_reportedreference_display varchar (100),   -- reportedReference/display (100 varchar)
  medreq_medicationcodeableconcept_system varchar (70),   -- medicationCodeableConcept/coding/system (70 varchar)
  medreq_medicationcodeableconcept_version varchar (50),   -- medicationCodeableConcept/coding/version (50 varchar)
  medreq_medicationcodeableconcept_code varchar (30),   -- medicationCodeableConcept/coding/code (30 varchar)
  medreq_medicationcodeableconcept_display varchar (100),   -- medicationCodeableConcept/coding/display (100 varchar)
  medreq_medicationcodeableconcept_text varchar (500),   -- medicationCodeableConcept/text (500 varchar)
  medreq_supportinginformation_id varchar (70),   -- supportingInformation/reference (70 varchar)
  medreq_supportinginformation_type varchar (30),   -- supportingInformation/type (30 varchar)
  medreq_supportinginformation_identifier_use varchar (30),   -- supportingInformation/identifier/use (30 varchar)
  medreq_supportinginformation_identifier_type_system varchar (70),   -- supportingInformation/identifier/type/coding/system (70 varchar)
  medreq_supportinginformation_identifier_type_version varchar (50),   -- supportingInformation/identifier/type/coding/version (50 varchar)
  medreq_supportinginformation_identifier_type_code varchar (30),   -- supportingInformation/identifier/type/coding/code (30 varchar)
  medreq_supportinginformation_identifier_type_display varchar (100),   -- supportingInformation/identifier/type/coding/display (100 varchar)
  medreq_supportinginformation_identifier_type_text varchar (500),   -- supportingInformation/identifier/type/text (500 varchar)
  medreq_supportinginformation_display varchar (100),   -- supportingInformation/display (100 varchar)
  medreq_authoredon timestamp,   -- authoredOn (30 timestamp)
  medreq_requester_id varchar (70),   -- requester/reference (70 varchar)
  medreq_requester_type varchar (30),   -- requester/type (30 varchar)
  medreq_requester_identifier_use varchar (30),   -- requester/identifier/use (30 varchar)
  medreq_requester_identifier_type_system varchar (70),   -- requester/identifier/type/coding/system (70 varchar)
  medreq_requester_identifier_type_version varchar (50),   -- requester/identifier/type/coding/version (50 varchar)
  medreq_requester_identifier_type_code varchar (30),   -- requester/identifier/type/coding/code (30 varchar)
  medreq_requester_identifier_type_display varchar (100),   -- requester/identifier/type/coding/display (100 varchar)
  medreq_requester_identifier_type_text varchar (500),   -- requester/identifier/type/text (500 varchar)
  medreq_requester_display varchar (100),   -- requester/display (100 varchar)
  medreq_reasoncode_system varchar (70),   -- reasonCode/coding/system (70 varchar)
  medreq_reasoncode_version varchar (50),   -- reasonCode/coding/version (50 varchar)
  medreq_reasoncode_code varchar (30),   -- reasonCode/coding/code (30 varchar)
  medreq_reasoncode_display varchar (100),   -- reasonCode/coding/display (100 varchar)
  medreq_reasoncode_text varchar (500),   -- reasonCode/text (500 varchar)
  medreq_reasonreference_id varchar (70),   -- reasonReference/reference (70 varchar)
  medreq_reasonreference_type varchar (30),   -- reasonReference/type (30 varchar)
  medreq_reasonreference_identifier_use varchar (30),   -- reasonReference/identifier/use (30 varchar)
  medreq_reasonreference_identifier_type_system varchar (70),   -- reasonReference/identifier/type/coding/system (70 varchar)
  medreq_reasonreference_identifier_type_version varchar (50),   -- reasonReference/identifier/type/coding/version (50 varchar)
  medreq_reasonreference_identifier_type_code varchar (30),   -- reasonReference/identifier/type/coding/code (30 varchar)
  medreq_reasonreference_identifier_type_display varchar (100),   -- reasonReference/identifier/type/coding/display (100 varchar)
  medreq_reasonreference_identifier_type_text varchar (500),   -- reasonReference/identifier/type/text (500 varchar)
  medreq_reasonreference_display varchar (100),   -- reasonReference/display (100 varchar)
  medreq_basedon_id varchar (70),   -- basedOn/reference (70 varchar)
  medreq_basedon_type varchar (30),   -- basedOn/type (30 varchar)
  medreq_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 varchar)
  medreq_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 varchar)
  medreq_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 varchar)
  medreq_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 varchar)
  medreq_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 varchar)
  medreq_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 varchar)
  medreq_basedon_display varchar (100),   -- basedOn/display (100 varchar)
  medreq_note_authorstring varchar (50),   -- note/authorString (50 varchar)
  medreq_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 varchar)
  medreq_note_authorreference_type varchar (30),   -- note/authorReference/type (30 varchar)
  medreq_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 varchar)
  medreq_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 varchar)
  medreq_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 varchar)
  medreq_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 varchar)
  medreq_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 varchar)
  medreq_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 varchar)
  medreq_note_authorreference_display varchar (100),   -- note/authorReference/display (100 varchar)
  medreq_note_time timestamp,   -- note/time (30 timestamp)
  medreq_note_text varchar (5000),   -- note/text (5000 varchar)
  medreq_doseinstruc_sequence int,   -- dosageInstruction/sequence (10 int)
  medreq_doseinstruc_text varchar (500),   -- dosageInstruction/text (500 varchar)
  medreq_doseinstruc_additionalinstruction_system varchar (70),   -- dosageInstruction/additionalInstruction/coding/system (70 varchar)
  medreq_doseinstruc_additionalinstruction_version varchar (50),   -- dosageInstruction/additionalInstruction/coding/version (50 varchar)
  medreq_doseinstruc_additionalinstruction_code varchar (30),   -- dosageInstruction/additionalInstruction/coding/code (30 varchar)
  medreq_doseinstruc_additionalinstruction_display varchar (100),   -- dosageInstruction/additionalInstruction/coding/display (100 varchar)
  medreq_doseinstruc_additionalinstruction_text varchar (500),   -- dosageInstruction/additionalInstruction/text (500 varchar)
  medreq_doseinstruc_patientinstruction varchar (100),   -- dosageInstruction/patientInstruction (100 varchar)
  medreq_doseinstruc_timing_event timestamp,   -- dosageInstruction/timing/event (30 timestamp)
  medreq_doseinstruc_timing_repeat_boundsduration_value numeric (30, 30),   -- dosageInstruction/timing/repeat/boundsDuration/value (30 numeric)
  medreq_doseinstruc_timing_repeat_boundsduration_comparator varchar (10),   -- dosageInstruction/timing/repeat/boundsDuration/comparator (10 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_unit varchar (30),   -- dosageInstruction/timing/repeat/boundsDuration/unit (30 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_system varchar (70),   -- dosageInstruction/timing/repeat/boundsDuration/system (70 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_code varchar (30),   -- dosageInstruction/timing/repeat/boundsDuration/code (30 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_value numeric (10, 10),   -- dosageInstruction/timing/repeat/boundsRange/low/value (10 numeric)
  medreq_doseinstruc_timing_repeat_boundsrange_low_unit varchar (30),   -- dosageInstruction/timing/repeat/boundsRange/low/unit (30 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_system varchar (70),   -- dosageInstruction/timing/repeat/boundsRange/low/system (70 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_code varchar (30),   -- dosageInstruction/timing/repeat/boundsRange/low/code (30 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_value numeric (10, 10),   -- dosageInstruction/timing/repeat/boundsRange/high/value (10 numeric)
  medreq_doseinstruc_timing_repeat_boundsrange_high_unit varchar (30),   -- dosageInstruction/timing/repeat/boundsRange/high/unit (30 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_system varchar (70),   -- dosageInstruction/timing/repeat/boundsRange/high/system (70 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_code varchar (30),   -- dosageInstruction/timing/repeat/boundsRange/high/code (30 varchar)
  medreq_doseinstruc_timing_repeat_boundsperiod_start timestamp,   -- dosageInstruction/timing/repeat/boundsPeriod/start (30 timestamp)
  medreq_doseinstruc_timing_repeat_boundsperiod_end timestamp,   -- dosageInstruction/timing/repeat/boundsPeriod/end (30 timestamp)
  medreq_doseinstruc_timing_repeat_count int,   -- dosageInstruction/timing/repeat/count (10 int)
  medreq_doseinstruc_timing_repeat_countmax int,   -- dosageInstruction/timing/repeat/countMax (10 int)
  medreq_doseinstruc_timing_repeat_duration numeric (10, 10),   -- dosageInstruction/timing/repeat/duration (10 numeric)
  medreq_doseinstruc_timing_repeat_durationmax numeric (10, 10),   -- dosageInstruction/timing/repeat/durationMax (10 numeric)
  medreq_doseinstruc_timing_repeat_durationunit varchar (20),   -- dosageInstruction/timing/repeat/durationUnit (20 varchar)
  medreq_doseinstruc_timing_repeat_frequency int,   -- dosageInstruction/timing/repeat/frequency (10 int)
  medreq_doseinstruc_timing_repeat_frequencymax int,   -- dosageInstruction/timing/repeat/frequencyMax (10 int)
  medreq_doseinstruc_timing_repeat_period numeric (10, 10),   -- dosageInstruction/timing/repeat/period (10 numeric)
  medreq_doseinstruc_timing_repeat_periodmax numeric (10, 10),   -- dosageInstruction/timing/repeat/periodMax (10 numeric)
  medreq_doseinstruc_timing_repeat_periodunit varchar (20),   -- dosageInstruction/timing/repeat/periodUnit (20 varchar)
  medreq_doseinstruc_timing_repeat_dayofweek varchar (10),   -- dosageInstruction/timing/repeat/dayOfWeek (10 varchar)
  medreq_doseinstruc_timing_repeat_timeofday time,   -- dosageInstruction/timing/repeat/timeOfDay (20 time)
  medreq_doseinstruc_timing_repeat_when varchar (20),   -- dosageInstruction/timing/repeat/when (20 varchar)
  medreq_doseinstruc_timing_repeat_offset int,   -- dosageInstruction/timing/repeat/offset (10 int)
  medreq_doseinstruc_timing_code_system varchar (70),   -- dosageInstruction/timing/code/coding/system (70 varchar)
  medreq_doseinstruc_timing_code_version varchar (50),   -- dosageInstruction/timing/code/coding/version (50 varchar)
  medreq_doseinstruc_timing_code_code varchar (30),   -- dosageInstruction/timing/code/coding/code (30 varchar)
  medreq_doseinstruc_timing_code_display varchar (100),   -- dosageInstruction/timing/code/coding/display (100 varchar)
  medreq_doseinstruc_timing_code_text varchar (500),   -- dosageInstruction/timing/code/text (500 varchar)
  medreq_doseinstruc_asneededboolean boolean,   -- dosageInstruction/asNeededBoolean (10 boolean)
  medreq_doseinstruc_asneededcodeableconcept_system varchar (70),   -- dosageInstruction/asNeededCodeableConcept/coding/system (70 varchar)
  medreq_doseinstruc_asneededcodeableconcept_version varchar (50),   -- dosageInstruction/asNeededCodeableConcept/coding/version (50 varchar)
  medreq_doseinstruc_asneededcodeableconcept_code varchar (30),   -- dosageInstruction/asNeededCodeableConcept/coding/code (30 varchar)
  medreq_doseinstruc_asneededcodeableconcept_display varchar (100),   -- dosageInstruction/asNeededCodeableConcept/coding/display (100 varchar)
  medreq_doseinstruc_asneededcodeableconcept_text varchar (500),   -- dosageInstruction/asNeededCodeableConcept/text (500 varchar)
  medreq_doseinstruc_site_system varchar (70),   -- dosageInstruction/site/coding/system (70 varchar)
  medreq_doseinstruc_site_version varchar (50),   -- dosageInstruction/site/coding/version (50 varchar)
  medreq_doseinstruc_site_code varchar (30),   -- dosageInstruction/site/coding/code (30 varchar)
  medreq_doseinstruc_site_display varchar (100),   -- dosageInstruction/site/coding/display (100 varchar)
  medreq_doseinstruc_site_text varchar (500),   -- dosageInstruction/site/text (500 varchar)
  medreq_doseinstruc_route_system varchar (70),   -- dosageInstruction/route/coding/system (70 varchar)
  medreq_doseinstruc_route_version varchar (50),   -- dosageInstruction/route/coding/version (50 varchar)
  medreq_doseinstruc_route_code varchar (30),   -- dosageInstruction/route/coding/code (30 varchar)
  medreq_doseinstruc_route_display varchar (100),   -- dosageInstruction/route/coding/display (100 varchar)
  medreq_doseinstruc_route_text varchar (500),   -- dosageInstruction/route/text (500 varchar)
  medreq_doseinstruc_method_system varchar (70),   -- dosageInstruction/method/coding/system (70 varchar)
  medreq_doseinstruc_method_version varchar (50),   -- dosageInstruction/method/coding/version (50 varchar)
  medreq_doseinstruc_method_code varchar (30),   -- dosageInstruction/method/coding/code (30 varchar)
  medreq_doseinstruc_method_display varchar (100),   -- dosageInstruction/method/coding/display (100 varchar)
  medreq_doseinstruc_method_text varchar (500),   -- dosageInstruction/method/text (500 varchar)
  medreq_doseinstruc_doseandrate_type_system varchar (70),   -- dosageInstruction/doseAndRate/type/coding/system (70 varchar)
  medreq_doseinstruc_doseandrate_type_version varchar (50),   -- dosageInstruction/doseAndRate/type/coding/version (50 varchar)
  medreq_doseinstruc_doseandrate_type_code varchar (30),   -- dosageInstruction/doseAndRate/type/coding/code (30 varchar)
  medreq_doseinstruc_doseandrate_type_display varchar (100),   -- dosageInstruction/doseAndRate/type/coding/display (100 varchar)
  medreq_doseinstruc_doseandrate_type_text varchar (500),   -- dosageInstruction/doseAndRate/type/text (500 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_value numeric (10, 10),   -- dosageInstruction/doseAndRate/doseRange/low/value (10 numeric)
  medreq_doseinstruc_doseandrate_doserange_low_unit varchar (30),   -- dosageInstruction/doseAndRate/doseRange/low/unit (30 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_system varchar (70),   -- dosageInstruction/doseAndRate/doseRange/low/system (70 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_code varchar (30),   -- dosageInstruction/doseAndRate/doseRange/low/code (30 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_value numeric (10, 10),   -- dosageInstruction/doseAndRate/doseRange/high/value (10 numeric)
  medreq_doseinstruc_doseandrate_doserange_high_unit varchar (30),   -- dosageInstruction/doseAndRate/doseRange/high/unit (30 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_system varchar (70),   -- dosageInstruction/doseAndRate/doseRange/high/system (70 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_code varchar (30),   -- dosageInstruction/doseAndRate/doseRange/high/code (30 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_value numeric (10, 10),   -- dosageInstruction/doseAndRate/doseQuantity/value (10 numeric)
  medreq_doseinstruc_doseandrate_dosequantity_comparator varchar (10),   -- dosageInstruction/doseAndRate/doseQuantity/comparator (10 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_unit varchar (30),   -- dosageInstruction/doseAndRate/doseQuantity/unit (30 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_system varchar (70),   -- dosageInstruction/doseAndRate/doseQuantity/system (70 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_code varchar (30),   -- dosageInstruction/doseAndRate/doseQuantity/code (30 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_value numeric (10, 10),   -- dosageInstruction/doseAndRate/rateRatio/numerator/value (10 numeric)
  medreq_doseinstruc_doseandrate_rateratio_numerator_comparator varchar (10),   -- dosageInstruction/doseAndRate/rateRatio/numerator/comparator (10 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_unit varchar (30),   -- dosageInstruction/doseAndRate/rateRatio/numerator/unit (30 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_system varchar (70),   -- dosageInstruction/doseAndRate/rateRatio/numerator/system (70 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_code varchar (30),   -- dosageInstruction/doseAndRate/rateRatio/numerator/code (30 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_value numeric (10, 10),   -- dosageInstruction/doseAndRate/rateRatio/denominator/value (10 numeric)
  medreq_doseinstruc_doseandrate_rateratio_denominator_comparator varchar (10),   -- dosageInstruction/doseAndRate/rateRatio/denominator/comparator (10 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_unit varchar (30),   -- dosageInstruction/doseAndRate/rateRatio/denominator/unit (30 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_system varchar (70),   -- dosageInstruction/doseAndRate/rateRatio/denominator/system (70 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_code varchar (30),   -- dosageInstruction/doseAndRate/rateRatio/denominator/code (30 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_value numeric (10, 10),   -- dosageInstruction/doseAndRate/rateRange/low/value (10 numeric)
  medreq_doseinstruc_doseandrate_raterange_low_unit varchar (30),   -- dosageInstruction/doseAndRate/rateRange/low/unit (30 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_system varchar (70),   -- dosageInstruction/doseAndRate/rateRange/low/system (70 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_code varchar (30),   -- dosageInstruction/doseAndRate/rateRange/low/code (30 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_value numeric (10, 10),   -- dosageInstruction/doseAndRate/rateRange/high/value (10 numeric)
  medreq_doseinstruc_doseandrate_raterange_high_unit varchar (30),   -- dosageInstruction/doseAndRate/rateRange/high/unit (30 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_system varchar (70),   -- dosageInstruction/doseAndRate/rateRange/high/system (70 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_code varchar (30),   -- dosageInstruction/doseAndRate/rateRange/high/code (30 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_value numeric (10, 10),   -- dosageInstruction/doseAndRate/rateQuantity/value (10 numeric)
  medreq_doseinstruc_doseandrate_ratequantity_unit varchar (30),   -- dosageInstruction/doseAndRate/rateQuantity/unit (30 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_system varchar (70),   -- dosageInstruction/doseAndRate/rateQuantity/system (70 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_code varchar (30),   -- dosageInstruction/doseAndRate/rateQuantity/code (30 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_value numeric (10, 10),   -- dosageInstruction/maxDosePerPeriod/numerator/value (10 numeric)
  medreq_doseinstruc_maxdoseperperiod_numerator_comparator varchar (10),   -- dosageInstruction/maxDosePerPeriod/numerator/comparator (10 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_unit varchar (30),   -- dosageInstruction/maxDosePerPeriod/numerator/unit (30 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_system varchar (70),   -- dosageInstruction/maxDosePerPeriod/numerator/system (70 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_code varchar (30),   -- dosageInstruction/maxDosePerPeriod/numerator/code (30 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_value numeric (10, 10),   -- dosageInstruction/maxDosePerPeriod/denominator/value (10 numeric)
  medreq_doseinstruc_maxdoseperperiod_denominator_comparator varchar (10),   -- dosageInstruction/maxDosePerPeriod/denominator/comparator (10 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_unit varchar (30),   -- dosageInstruction/maxDosePerPeriod/denominator/unit (30 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_system varchar (70),   -- dosageInstruction/maxDosePerPeriod/denominator/system (70 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_code varchar (30),   -- dosageInstruction/maxDosePerPeriod/denominator/code (30 varchar)
  medreq_doseinstruc_maxdoseperadministration_value numeric (10, 10),   -- dosageInstruction/maxDosePerAdministration/value (10 numeric)
  medreq_doseinstruc_maxdoseperadministration_unit varchar (30),   -- dosageInstruction/maxDosePerAdministration/unit (30 varchar)
  medreq_doseinstruc_maxdoseperadministration_system varchar (70),   -- dosageInstruction/maxDosePerAdministration/system (70 varchar)
  medreq_doseinstruc_maxdoseperadministration_code varchar (30),   -- dosageInstruction/maxDosePerAdministration/code (30 varchar)
  medreq_doseinstruc_maxdoseperlifetime_value numeric (10, 10),   -- dosageInstruction/maxDosePerLifetime/value (10 numeric)
  medreq_doseinstruc_maxdoseperlifetime_unit varchar (30),   -- dosageInstruction/maxDosePerLifetime/unit (30 varchar)
  medreq_doseinstruc_maxdoseperlifetime_system varchar (70),   -- dosageInstruction/maxDosePerLifetime/system (70 varchar)
  medreq_doseinstruc_maxdoseperlifetime_code varchar (30),   -- dosageInstruction/maxDosePerLifetime/code (30 varchar)
  medreq_substitution_reason_system varchar (70),   -- substitution/reason/coding/system (70 varchar)
  medreq_substitution_reason_version varchar (50),   -- substitution/reason/coding/version (50 varchar)
  medreq_substitution_reason_code varchar (30),   -- substitution/reason/coding/code (30 varchar)
  medreq_substitution_reason_display varchar (100),   -- substitution/reason/coding/display (100 varchar)
  medreq_substitution_reason_text varchar (500),   -- substitution/reason/text (500 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medicationadministration" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medicationadministration (
  medicationadministration_id serial PRIMARY KEY not null, -- Primary key of the entity
  medadm_id varchar (70),   -- id (70 varchar)
  medadm_encounter_id varchar (70),   -- context/reference (70 varchar)
  medadm_patient_id varchar (70),   -- subject/reference (70 varchar)
  medadm_partof_id varchar (70),   -- partOf/reference (70 varchar)
  medadm_identifier_use varchar (50),   -- identifier/use (50 varchar)
  medadm_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  medadm_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  medadm_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  medadm_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  medadm_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  medadm_identifier_system varchar (70),   -- identifier/system (70 varchar)
  medadm_identifier_value varchar (70),   -- identifier/value (70 varchar)
  medadm_identifier_start timestamp,   -- identifier/start (30 timestamp)
  medadm_identifier_end timestamp,   -- identifier/end (30 timestamp)
  medadm_status varchar (30),   -- status (30 varchar)
  medadm_statusreason_system varchar (70),   -- statusReason/coding/system (70 varchar)
  medadm_statusreason_version varchar (50),   -- statusReason/coding/version (50 varchar)
  medadm_statusreason_code varchar (30),   -- statusReason/coding/code (30 varchar)
  medadm_statusreason_display varchar (100),   -- statusReason/coding/display (100 varchar)
  medadm_statusreason_text varchar (500),   -- statusReason/text (500 varchar)
  medadm_category_system varchar (70),   -- category/coding/system (70 varchar)
  medadm_category_version varchar (50),   -- category/coding/version (50 varchar)
  medadm_category_code varchar (30),   -- category/coding/code (30 varchar)
  medadm_category_display varchar (100),   -- category/coding/display (100 varchar)
  medadm_category_text varchar (500),   -- category/text (500 varchar)
  medadm_medicationreference_id varchar (70),   -- medicationReference/reference (70 varchar)
  medadm_medicationcodeableconcept_system varchar (70),   -- medicationCodeableConcept/coding/system (70 varchar)
  medadm_medicationcodeableconcept_version varchar (50),   -- medicationCodeableConcept/coding/version (50 varchar)
  medadm_medicationcodeableconcept_code varchar (30),   -- medicationCodeableConcept/coding/code (30 varchar)
  medadm_medicationcodeableconcept_display varchar (100),   -- medicationCodeableConcept/coding/display (100 varchar)
  medadm_medicationcodeableconcept_text varchar (500),   -- medicationCodeableConcept/text (500 varchar)
  medadm_supportinginformation_id varchar (70),   -- supportingInformation/reference (70 varchar)
  medadm_supportinginformation_type varchar (30),   -- supportingInformation/type (30 varchar)
  medadm_supportinginformation_identifier_use varchar (30),   -- supportingInformation/identifier/use (30 varchar)
  medadm_supportinginformation_identifier_type_system varchar (70),   -- supportingInformation/identifier/type/coding/system (70 varchar)
  medadm_supportinginformation_identifier_type_version varchar (50),   -- supportingInformation/identifier/type/coding/version (50 varchar)
  medadm_supportinginformation_identifier_type_code varchar (30),   -- supportingInformation/identifier/type/coding/code (30 varchar)
  medadm_supportinginformation_identifier_type_display varchar (100),   -- supportingInformation/identifier/type/coding/display (100 varchar)
  medadm_supportinginformation_identifier_type_text varchar (500),   -- supportingInformation/identifier/type/text (500 varchar)
  medadm_supportinginformation_display varchar (100),   -- supportingInformation/display (100 varchar)
  medadm_effectivedatetime timestamp,   -- effectiveDateTime (30 timestamp)
  medadm_effectiveperiod_start timestamp,   -- effectivePeriod/start (30 timestamp)
  medadm_effectiveperiod_end timestamp,   -- effectivePeriod/end (30 timestamp)
  medadm_performer_function_system varchar (70),   -- performer/function/coding/system (70 varchar)
  medadm_performer_function_version varchar (50),   -- performer/function/coding/version (50 varchar)
  medadm_performer_function_code varchar (30),   -- performer/function/coding/code (30 varchar)
  medadm_performer_function_display varchar (100),   -- performer/function/coding/display (100 varchar)
  medadm_performer_function_text varchar (500),   -- performer/function/text (500 varchar)
  medadm_reasoncode_system varchar (70),   -- reasonCode/coding/system (70 varchar)
  medadm_reasoncode_version varchar (50),   -- reasonCode/coding/version (50 varchar)
  medadm_reasoncode_code varchar (30),   -- reasonCode/coding/code (30 varchar)
  medadm_reasoncode_display varchar (100),   -- reasonCode/coding/display (100 varchar)
  medadm_reasoncode_text varchar (500),   -- reasonCode/text (500 varchar)
  medadm_reasonreference_id varchar (70),   -- reasonReference/reference (70 varchar)
  medadm_reasonreference_type varchar (30),   -- reasonReference/type (30 varchar)
  medadm_reasonreference_identifier_use varchar (30),   -- reasonReference/identifier/use (30 varchar)
  medadm_reasonreference_identifier_type_system varchar (70),   -- reasonReference/identifier/type/coding/system (70 varchar)
  medadm_reasonreference_identifier_type_version varchar (50),   -- reasonReference/identifier/type/coding/version (50 varchar)
  medadm_reasonreference_identifier_type_code varchar (30),   -- reasonReference/identifier/type/coding/code (30 varchar)
  medadm_reasonreference_identifier_type_display varchar (100),   -- reasonReference/identifier/type/coding/display (100 varchar)
  medadm_reasonreference_identifier_type_text varchar (500),   -- reasonReference/identifier/type/text (500 varchar)
  medadm_reasonreference_display varchar (100),   -- reasonReference/display (100 varchar)
  medadm_request_id varchar (70),   -- request/reference (70 varchar)
  medadm_note_authorstring varchar (50),   -- note/authorString (50 varchar)
  medadm_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 varchar)
  medadm_note_authorreference_type varchar (30),   -- note/authorReference/type (30 varchar)
  medadm_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 varchar)
  medadm_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 varchar)
  medadm_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 varchar)
  medadm_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 varchar)
  medadm_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 varchar)
  medadm_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 varchar)
  medadm_note_authorreference_display varchar (100),   -- note/authorReference/display (100 varchar)
  medadm_note_time timestamp,   -- note/time (30 timestamp)
  medadm_note_text varchar (5000),   -- note/text (5000 varchar)
  medadm_dosage_text varchar (100),   -- dosage/text (100 varchar)
  medadm_dosage_site_system varchar (70),   -- dosage/site/coding/system (70 varchar)
  medadm_dosage_site_version varchar (50),   -- dosage/site/coding/version (50 varchar)
  medadm_dosage_site_code varchar (30),   -- dosage/site/coding/code (30 varchar)
  medadm_dosage_site_display varchar (100),   -- dosage/site/coding/display (100 varchar)
  medadm_dosage_site_text varchar (500),   -- dosage/site/text (500 varchar)
  medadm_dosage_route_system varchar (70),   -- dosage/route/coding/system (70 varchar)
  medadm_dosage_route_version varchar (50),   -- dosage/route/coding/version (50 varchar)
  medadm_dosage_route_code varchar (30),   -- dosage/route/coding/code (30 varchar)
  medadm_dosage_route_display varchar (100),   -- dosage/route/coding/display (100 varchar)
  medadm_dosage_route_text varchar (500),   -- dosage/route/text (500 varchar)
  medadm_dosage_method_system varchar (70),   -- dosage/method/coding/system (70 varchar)
  medadm_dosage_method_version varchar (50),   -- dosage/method/coding/version (50 varchar)
  medadm_dosage_method_code varchar (30),   -- dosage/method/coding/code (30 varchar)
  medadm_dosage_method_display varchar (100),   -- dosage/method/coding/display (100 varchar)
  medadm_dosage_method_text varchar (500),   -- dosage/method/text (500 varchar)
  medadm_dosage_dose_value numeric (10, 10),   -- dosage/dose/value (10 numeric)
  medadm_dosage_dose_unit varchar (30),   -- dosage/dose/unit (30 varchar)
  medadm_dosage_dose_system varchar (70),   -- dosage/dose/system (70 varchar)
  medadm_dosage_dose_code varchar (30),   -- dosage/dose/code (30 varchar)
  medadm_dosage_rateratio_numerator_value numeric (10, 10),   -- dosage/rateRatio/numerator/value (10 numeric)
  medadm_dosage_rateratio_numerator_comparator varchar (10),   -- dosage/rateRatio/numerator/comparator (10 varchar)
  medadm_dosage_rateratio_numerator_unit varchar (30),   -- dosage/rateRatio/numerator/unit (30 varchar)
  medadm_dosage_rateratio_numerator_system varchar (70),   -- dosage/rateRatio/numerator/system (70 varchar)
  medadm_dosage_rateratio_numerator_code varchar (30),   -- dosage/rateRatio/numerator/code (30 varchar)
  medadm_dosage_rateratio_denominator_value numeric (10, 10),   -- dosage/rateRatio/denominator/value (10 numeric)
  medadm_dosage_rateratio_denominator_comparator varchar (10),   -- dosage/rateRatio/denominator/comparator (10 varchar)
  medadm_dosage_rateratio_denominator_unit varchar (30),   -- dosage/rateRatio/denominator/unit (30 varchar)
  medadm_dosage_rateratio_denominator_system varchar (70),   -- dosage/rateRatio/denominator/system (70 varchar)
  medadm_dosage_rateratio_denominator_code varchar (30),   -- dosage/rateRatio/denominator/code (30 varchar)
  medadm_dosage_ratequantity_value numeric (10, 10),   -- dosage/rateQuantity/value (10 numeric)
  medadm_dosage_ratequantity_unit varchar (30),   -- dosage/rateQuantity/unit (30 varchar)
  medadm_dosage_ratequantity_system varchar (70),   -- dosage/rateQuantity/system (70 varchar)
  medadm_dosage_ratequantity_code varchar (30),   -- dosage/rateQuantity/code (30 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medicationstatement" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medicationstatement (
  medicationstatement_id serial PRIMARY KEY not null, -- Primary key of the entity
  medstat_id varchar (70),   -- id (70 varchar)
  medstat_identifier_use varchar (50),   -- identifier/use (50 varchar)
  medstat_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  medstat_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  medstat_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  medstat_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  medstat_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  medstat_identifier_system varchar (70),   -- identifier/system (70 varchar)
  medstat_identifier_value varchar (70),   -- identifier/value (70 varchar)
  medstat_identifier_start timestamp,   -- identifier/start (30 timestamp)
  medstat_identifier_end timestamp,   -- identifier/end (30 timestamp)
  medstat_encounter_id varchar (70),   -- context/reference (70 varchar)
  medstat_patient_id varchar (70),   -- subject/reference (70 varchar)
  medstat_partof_id varchar (70),   -- partOf/reference (70 varchar)
  medstat_basedon_id varchar (70),   -- basedOn/reference (70 varchar)
  medstat_basedon_type varchar (30),   -- basedOn/type (30 varchar)
  medstat_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 varchar)
  medstat_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 varchar)
  medstat_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 varchar)
  medstat_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 varchar)
  medstat_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 varchar)
  medstat_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 varchar)
  medstat_basedon_display varchar (100),   -- basedOn/display (100 varchar)
  medstat_status varchar (30),   -- status (30 varchar)
  medstat_statusreason_system varchar (70),   -- statusReason/coding/system (70 varchar)
  medstat_statusreason_version varchar (50),   -- statusReason/coding/version (50 varchar)
  medstat_statusreason_code varchar (30),   -- statusReason/coding/code (30 varchar)
  medstat_statusreason_display varchar (100),   -- statusReason/coding/display (100 varchar)
  medstat_statusreason_text varchar (500),   -- statusReason/text (500 varchar)
  medstat_category_system varchar (70),   -- category/coding/system (70 varchar)
  medstat_category_version varchar (50),   -- category/coding/version (50 varchar)
  medstat_category_code varchar (30),   -- category/coding/code (30 varchar)
  medstat_category_display varchar (100),   -- category/coding/display (100 varchar)
  medstat_category_text varchar (500),   -- category/text (500 varchar)
  medstat_medicationreference_id varchar (70),   -- medicationReference/reference (70 varchar)
  medstat_medicationcodeableconcept_system varchar (70),   -- medicationCodeableConcept/coding/system (70 varchar)
  medstat_medicationcodeableconcept_version varchar (50),   -- medicationCodeableConcept/coding/version (50 varchar)
  medstat_medicationcodeableconcept_code varchar (30),   -- medicationCodeableConcept/coding/code (30 varchar)
  medstat_medicationcodeableconcept_display varchar (100),   -- medicationCodeableConcept/coding/display (100 varchar)
  medstat_medicationcodeableconcept_text varchar (500),   -- medicationCodeableConcept/text (500 varchar)
  medstat_effectivedatetime timestamp,   -- effectiveDateTime (30 timestamp)
  medstat_effectiveperiod_start timestamp,   -- effectivePeriod/start (30 timestamp)
  medstat_effectiveperiod_end timestamp,   -- effectivePeriod/end (30 timestamp)
  medstat_dateasserted timestamp,   -- dateAsserted (30 timestamp)
  medstat_informationsource_id varchar (70),   -- informationSource/reference (70 varchar)
  medstat_informationsource_type varchar (30),   -- informationSource/type (30 varchar)
  medstat_informationsource_identifier_use varchar (30),   -- informationSource/identifier/use (30 varchar)
  medstat_informationsource_identifier_type_system varchar (70),   -- informationSource/identifier/type/coding/system (70 varchar)
  medstat_informationsource_identifier_type_version varchar (50),   -- informationSource/identifier/type/coding/version (50 varchar)
  medstat_informationsource_identifier_type_code varchar (30),   -- informationSource/identifier/type/coding/code (30 varchar)
  medstat_informationsource_identifier_type_display varchar (100),   -- informationSource/identifier/type/coding/display (100 varchar)
  medstat_informationsource_identifier_type_text varchar (500),   -- informationSource/identifier/type/text (500 varchar)
  medstat_informationsource_display varchar (100),   -- informationSource/display (100 varchar)
  medstat_derivedfrom_id varchar (70),   -- derivedFrom/reference (70 varchar)
  medstat_derivedfrom_type varchar (30),   -- derivedFrom/type (30 varchar)
  medstat_derivedfrom_identifier_use varchar (30),   -- derivedFrom/identifier/use (30 varchar)
  medstat_derivedfrom_identifier_type_system varchar (70),   -- derivedFrom/identifier/type/coding/system (70 varchar)
  medstat_derivedfrom_identifier_type_version varchar (50),   -- derivedFrom/identifier/type/coding/version (50 varchar)
  medstat_derivedfrom_identifier_type_code varchar (30),   -- derivedFrom/identifier/type/coding/code (30 varchar)
  medstat_derivedfrom_identifier_type_display varchar (100),   -- derivedFrom/identifier/type/coding/display (100 varchar)
  medstat_derivedfrom_identifier_type_text varchar (500),   -- derivedFrom/identifier/type/text (500 varchar)
  medstat_derivedfrom_display varchar (100),   -- derivedFrom/display (100 varchar)
  medstat_reasoncode_system varchar (70),   -- reasonCode/coding/system (70 varchar)
  medstat_reasoncode_version varchar (50),   -- reasonCode/coding/version (50 varchar)
  medstat_reasoncode_code varchar (30),   -- reasonCode/coding/code (30 varchar)
  medstat_reasoncode_display varchar (100),   -- reasonCode/coding/display (100 varchar)
  medstat_reasoncode_text varchar (500),   -- reasonCode/text (500 varchar)
  medstat_reasonreference_id varchar (70),   -- reasonReference/reference (70 varchar)
  medstat_reasonreference_type varchar (30),   -- reasonReference/type (30 varchar)
  medstat_reasonreference_identifier_use varchar (30),   -- reasonReference/identifier/use (30 varchar)
  medstat_reasonreference_identifier_type_system varchar (70),   -- reasonReference/identifier/type/coding/system (70 varchar)
  medstat_reasonreference_identifier_type_version varchar (50),   -- reasonReference/identifier/type/coding/version (50 varchar)
  medstat_reasonreference_identifier_type_code varchar (30),   -- reasonReference/identifier/type/coding/code (30 varchar)
  medstat_reasonreference_identifier_type_display varchar (100),   -- reasonReference/identifier/type/coding/display (100 varchar)
  medstat_reasonreference_identifier_type_text varchar (500),   -- reasonReference/identifier/type/text (500 varchar)
  medstat_reasonreference_display varchar (100),   -- reasonReference/display (100 varchar)
  medstat_note_authorstring varchar (50),   -- note/authorString (50 varchar)
  medstat_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 varchar)
  medstat_note_authorreference_type varchar (30),   -- note/authorReference/type (30 varchar)
  medstat_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 varchar)
  medstat_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 varchar)
  medstat_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 varchar)
  medstat_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 varchar)
  medstat_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 varchar)
  medstat_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 varchar)
  medstat_note_authorreference_display varchar (100),   -- note/authorReference/display (100 varchar)
  medstat_note_time timestamp,   -- note/time (30 timestamp)
  medstat_note_text varchar (5000),   -- note/text (5000 varchar)
  medstat_dosage_sequence int,   -- dosage/sequence (10 int)
  medstat_dosage_text varchar (500),   -- dosage/text (500 varchar)
  medstat_dosage_additionalinstruction_system varchar (70),   -- dosage/additionalInstruction/coding/system (70 varchar)
  medstat_dosage_additionalinstruction_version varchar (50),   -- dosage/additionalInstruction/coding/version (50 varchar)
  medstat_dosage_additionalinstruction_code varchar (30),   -- dosage/additionalInstruction/coding/code (30 varchar)
  medstat_dosage_additionalinstruction_display varchar (100),   -- dosage/additionalInstruction/coding/display (100 varchar)
  medstat_dosage_additionalinstruction_text varchar (500),   -- dosage/additionalInstruction/text (500 varchar)
  medstat_dosage_patientinstruction varchar (100),   -- dosage/patientInstruction (100 varchar)
  medstat_dosage_timing_event timestamp,   -- dosage/timing/event (30 timestamp)
  medstat_dosage_timing_repeat_boundsduration_value numeric (30, 30),   -- dosage/timing/repeat/boundsDuration/value (30 numeric)
  medstat_dosage_timing_repeat_boundsduration_comparator varchar (10),   -- dosage/timing/repeat/boundsDuration/comparator (10 varchar)
  medstat_dosage_timing_repeat_boundsduration_unit varchar (30),   -- dosage/timing/repeat/boundsDuration/unit (30 varchar)
  medstat_dosage_timing_repeat_boundsduration_system varchar (70),   -- dosage/timing/repeat/boundsDuration/system (70 varchar)
  medstat_dosage_timing_repeat_boundsduration_code varchar (30),   -- dosage/timing/repeat/boundsDuration/code (30 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_value numeric (10, 10),   -- dosage/timing/repeat/boundsRange/low/value (10 numeric)
  medstat_dosage_timing_repeat_boundsrange_low_unit varchar (30),   -- dosage/timing/repeat/boundsRange/low/unit (30 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_system varchar (70),   -- dosage/timing/repeat/boundsRange/low/system (70 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_code varchar (30),   -- dosage/timing/repeat/boundsRange/low/code (30 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_value numeric (10, 10),   -- dosage/timing/repeat/boundsRange/high/value (10 numeric)
  medstat_dosage_timing_repeat_boundsrange_high_unit varchar (30),   -- dosage/timing/repeat/boundsRange/high/unit (30 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_system varchar (70),   -- dosage/timing/repeat/boundsRange/high/system (70 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_code varchar (30),   -- dosage/timing/repeat/boundsRange/high/code (30 varchar)
  medstat_dosage_timing_repeat_boundsperiod_start timestamp,   -- dosage/timing/repeat/boundsPeriod/start (30 timestamp)
  medstat_dosage_timing_repeat_boundsperiod_end timestamp,   -- dosage/timing/repeat/boundsPeriod/end (30 timestamp)
  medstat_dosage_timing_repeat_count int,   -- dosage/timing/repeat/count (10 int)
  medstat_dosage_timing_repeat_countmax int,   -- dosage/timing/repeat/countMax (10 int)
  medstat_dosage_timing_repeat_duration numeric (10, 10),   -- dosage/timing/repeat/duration (10 numeric)
  medstat_dosage_timing_repeat_durationmax numeric (10, 10),   -- dosage/timing/repeat/durationMax (10 numeric)
  medstat_dosage_timing_repeat_durationunit varchar (20),   -- dosage/timing/repeat/durationUnit (20 varchar)
  medstat_dosage_timing_repeat_frequency int,   -- dosage/timing/repeat/frequency (10 int)
  medstat_dosage_timing_repeat_frequencymax int,   -- dosage/timing/repeat/frequencyMax (10 int)
  medstat_dosage_timing_repeat_period numeric (10, 10),   -- dosage/timing/repeat/period (10 numeric)
  medstat_dosage_timing_repeat_periodmax numeric (10, 10),   -- dosage/timing/repeat/periodMax (10 numeric)
  medstat_dosage_timing_repeat_periodunit varchar (20),   -- dosage/timing/repeat/periodUnit (20 varchar)
  medstat_dosage_timing_repeat_dayofweek varchar (10),   -- dosage/timing/repeat/dayOfWeek (10 varchar)
  medstat_dosage_timing_repeat_timeofday time,   -- dosage/timing/repeat/timeOfDay (20 time)
  medstat_dosage_timing_repeat_when varchar (20),   -- dosage/timing/repeat/when (20 varchar)
  medstat_dosage_timing_repeat_offset int,   -- dosage/timing/repeat/offset (10 int)
  medstat_dosage_timing_code_system varchar (70),   -- dosage/timing/code/coding/system (70 varchar)
  medstat_dosage_timing_code_version varchar (50),   -- dosage/timing/code/coding/version (50 varchar)
  medstat_dosage_timing_code_code varchar (30),   -- dosage/timing/code/coding/code (30 varchar)
  medstat_dosage_timing_code_display varchar (100),   -- dosage/timing/code/coding/display (100 varchar)
  medstat_dosage_timing_code_text varchar (500),   -- dosage/timing/code/text (500 varchar)
  medstat_dosage_asneededboolean boolean,   -- dosage/asNeededBoolean (10 boolean)
  medstat_dosage_asneededcodeableconcept_system varchar (70),   -- dosage/asNeededCodeableConcept/coding/system (70 varchar)
  medstat_dosage_asneededcodeableconcept_version varchar (50),   -- dosage/asNeededCodeableConcept/coding/version (50 varchar)
  medstat_dosage_asneededcodeableconcept_code varchar (30),   -- dosage/asNeededCodeableConcept/coding/code (30 varchar)
  medstat_dosage_asneededcodeableconcept_display varchar (100),   -- dosage/asNeededCodeableConcept/coding/display (100 varchar)
  medstat_dosage_asneededcodeableconcept_text varchar (500),   -- dosage/asNeededCodeableConcept/text (500 varchar)
  medstat_dosage_site_system varchar (70),   -- dosage/site/coding/system (70 varchar)
  medstat_dosage_site_version varchar (50),   -- dosage/site/coding/version (50 varchar)
  medstat_dosage_site_code varchar (30),   -- dosage/site/coding/code (30 varchar)
  medstat_dosage_site_display varchar (100),   -- dosage/site/coding/display (100 varchar)
  medstat_dosage_site_text varchar (500),   -- dosage/site/text (500 varchar)
  medstat_dosage_route_system varchar (70),   -- dosage/route/coding/system (70 varchar)
  medstat_dosage_route_version varchar (50),   -- dosage/route/coding/version (50 varchar)
  medstat_dosage_route_code varchar (30),   -- dosage/route/coding/code (30 varchar)
  medstat_dosage_route_display varchar (100),   -- dosage/route/coding/display (100 varchar)
  medstat_dosage_route_text varchar (500),   -- dosage/route/text (500 varchar)
  medstat_dosage_method_system varchar (70),   -- dosage/method/coding/system (70 varchar)
  medstat_dosage_method_version varchar (50),   -- dosage/method/coding/version (50 varchar)
  medstat_dosage_method_code varchar (30),   -- dosage/method/coding/code (30 varchar)
  medstat_dosage_method_display varchar (100),   -- dosage/method/coding/display (100 varchar)
  medstat_dosage_method_text varchar (500),   -- dosage/method/text (500 varchar)
  medstat_dosage_doseandrate_type_system varchar (70),   -- dosage/doseAndRate/type/coding/system (70 varchar)
  medstat_dosage_doseandrate_type_version varchar (50),   -- dosage/doseAndRate/type/coding/version (50 varchar)
  medstat_dosage_doseandrate_type_code varchar (30),   -- dosage/doseAndRate/type/coding/code (30 varchar)
  medstat_dosage_doseandrate_type_display varchar (100),   -- dosage/doseAndRate/type/coding/display (100 varchar)
  medstat_dosage_doseandrate_type_text varchar (500),   -- dosage/doseAndRate/type/text (500 varchar)
  medstat_dosage_doseandrate_doserange_low_value numeric (10, 10),   -- dosage/doseAndRate/doseRange/low/value (10 numeric)
  medstat_dosage_doseandrate_doserange_low_unit varchar (30),   -- dosage/doseAndRate/doseRange/low/unit (30 varchar)
  medstat_dosage_doseandrate_doserange_low_system varchar (70),   -- dosage/doseAndRate/doseRange/low/system (70 varchar)
  medstat_dosage_doseandrate_doserange_low_code varchar (30),   -- dosage/doseAndRate/doseRange/low/code (30 varchar)
  medstat_dosage_doseandrate_doserange_high_value numeric (10, 10),   -- dosage/doseAndRate/doseRange/high/value (10 numeric)
  medstat_dosage_doseandrate_doserange_high_unit varchar (30),   -- dosage/doseAndRate/doseRange/high/unit (30 varchar)
  medstat_dosage_doseandrate_doserange_high_system varchar (70),   -- dosage/doseAndRate/doseRange/high/system (70 varchar)
  medstat_dosage_doseandrate_doserange_high_code varchar (30),   -- dosage/doseAndRate/doseRange/high/code (30 varchar)
  medstat_dosage_doseandrate_dosequantity_value numeric (10, 10),   -- dosage/doseAndRate/doseQuantity/value (10 numeric)
  medstat_dosage_doseandrate_dosequantity_comparator varchar (10),   -- dosage/doseAndRate/doseQuantity/comparator (10 varchar)
  medstat_dosage_doseandrate_dosequantity_unit varchar (30),   -- dosage/doseAndRate/doseQuantity/unit (30 varchar)
  medstat_dosage_doseandrate_dosequantity_system varchar (70),   -- dosage/doseAndRate/doseQuantity/system (70 varchar)
  medstat_dosage_doseandrate_dosequantity_code varchar (30),   -- dosage/doseAndRate/doseQuantity/code (30 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_value numeric (10, 10),   -- dosage/doseAndRate/rateRatio/numerator/value (10 numeric)
  medstat_dosage_doseandrate_rateratio_numerator_comparator varchar (10),   -- dosage/doseAndRate/rateRatio/numerator/comparator (10 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_unit varchar (30),   -- dosage/doseAndRate/rateRatio/numerator/unit (30 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_system varchar (70),   -- dosage/doseAndRate/rateRatio/numerator/system (70 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_code varchar (30),   -- dosage/doseAndRate/rateRatio/numerator/code (30 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_value numeric (10, 10),   -- dosage/doseAndRate/rateRatio/denominator/value (10 numeric)
  medstat_dosage_doseandrate_rateratio_denominator_comparator varchar (10),   -- dosage/doseAndRate/rateRatio/denominator/comparator (10 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_unit varchar (30),   -- dosage/doseAndRate/rateRatio/denominator/unit (30 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_system varchar (70),   -- dosage/doseAndRate/rateRatio/denominator/system (70 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_code varchar (30),   -- dosage/doseAndRate/rateRatio/denominator/code (30 varchar)
  medstat_dosage_doseandrate_raterange_low_value numeric (10, 10),   -- dosage/doseAndRate/rateRange/low/value (10 numeric)
  medstat_dosage_doseandrate_raterange_low_unit varchar (30),   -- dosage/doseAndRate/rateRange/low/unit (30 varchar)
  medstat_dosage_doseandrate_raterange_low_system varchar (70),   -- dosage/doseAndRate/rateRange/low/system (70 varchar)
  medstat_dosage_doseandrate_raterange_low_code varchar (30),   -- dosage/doseAndRate/rateRange/low/code (30 varchar)
  medstat_dosage_doseandrate_raterange_high_value numeric (10, 10),   -- dosage/doseAndRate/rateRange/high/value (10 numeric)
  medstat_dosage_doseandrate_raterange_high_unit varchar (30),   -- dosage/doseAndRate/rateRange/high/unit (30 varchar)
  medstat_dosage_doseandrate_raterange_high_system varchar (70),   -- dosage/doseAndRate/rateRange/high/system (70 varchar)
  medstat_dosage_doseandrate_raterange_high_code varchar (30),   -- dosage/doseAndRate/rateRange/high/code (30 varchar)
  medstat_dosage_doseandrate_ratequantity_value numeric (10, 10),   -- dosage/doseAndRate/rateQuantity/value (10 numeric)
  medstat_dosage_doseandrate_ratequantity_unit varchar (30),   -- dosage/doseAndRate/rateQuantity/unit (30 varchar)
  medstat_dosage_doseandrate_ratequantity_system varchar (70),   -- dosage/doseAndRate/rateQuantity/system (70 varchar)
  medstat_dosage_doseandrate_ratequantity_code varchar (30),   -- dosage/doseAndRate/rateQuantity/code (30 varchar)
  medstat_dosage_maxdoseperperiod_numerator_value numeric (10, 10),   -- dosage/maxDosePerPeriod/numerator/value (10 numeric)
  medstat_dosage_maxdoseperperiod_numerator_comparator varchar (10),   -- dosage/maxDosePerPeriod/numerator/comparator (10 varchar)
  medstat_dosage_maxdoseperperiod_numerator_unit varchar (30),   -- dosage/maxDosePerPeriod/numerator/unit (30 varchar)
  medstat_dosage_maxdoseperperiod_numerator_system varchar (70),   -- dosage/maxDosePerPeriod/numerator/system (70 varchar)
  medstat_dosage_maxdoseperperiod_numerator_code varchar (30),   -- dosage/maxDosePerPeriod/numerator/code (30 varchar)
  medstat_dosage_maxdoseperperiod_denominator_value numeric (10, 10),   -- dosage/maxDosePerPeriod/denominator/value (10 numeric)
  medstat_dosage_maxdoseperperiod_denominator_comparator varchar (10),   -- dosage/maxDosePerPeriod/denominator/comparator (10 varchar)
  medstat_dosage_maxdoseperperiod_denominator_unit varchar (30),   -- dosage/maxDosePerPeriod/denominator/unit (30 varchar)
  medstat_dosage_maxdoseperperiod_denominator_system varchar (70),   -- dosage/maxDosePerPeriod/denominator/system (70 varchar)
  medstat_dosage_maxdoseperperiod_denominator_code varchar (30),   -- dosage/maxDosePerPeriod/denominator/code (30 varchar)
  medstat_dosage_maxdoseperadministration_value numeric (10, 10),   -- dosage/maxDosePerAdministration/value (10 numeric)
  medstat_dosage_maxdoseperadministration_unit varchar (30),   -- dosage/maxDosePerAdministration/unit (30 varchar)
  medstat_dosage_maxdoseperadministration_system varchar (70),   -- dosage/maxDosePerAdministration/system (70 varchar)
  medstat_dosage_maxdoseperadministration_code varchar (30),   -- dosage/maxDosePerAdministration/code (30 varchar)
  medstat_dosage_maxdoseperlifetime_value numeric (10, 10),   -- dosage/maxDosePerLifetime/value (10 numeric)
  medstat_dosage_maxdoseperlifetime_unit varchar (30),   -- dosage/maxDosePerLifetime/unit (30 varchar)
  medstat_dosage_maxdoseperlifetime_system varchar (70),   -- dosage/maxDosePerLifetime/system (70 varchar)
  medstat_dosage_maxdoseperlifetime_code varchar (30),   -- dosage/maxDosePerLifetime/code (30 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "observation" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.observation (
  observation_id serial PRIMARY KEY not null, -- Primary key of the entity
  obs_id varchar (70),   -- id (70 varchar)
  obs_encounter_id varchar (70),   -- encounter/reference (70 varchar)
  obs_patient_id varchar (70),   -- subject/reference (70 varchar)
  obs_partof_id varchar (70),   -- partOf/reference (70 varchar)
  obs_identifier_use varchar (50),   -- identifier/use (50 varchar)
  obs_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  obs_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  obs_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  obs_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  obs_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  obs_identifier_system varchar (70),   -- identifier/system (70 varchar)
  obs_identifier_value varchar (70),   -- identifier/value (70 varchar)
  obs_identifier_start timestamp,   -- identifier/start (30 timestamp)
  obs_identifier_end timestamp,   -- identifier/end (30 timestamp)
  obs_basedon_id varchar (70),   -- basedOn/reference (70 varchar)
  obs_basedon_type varchar (30),   -- basedOn/type (30 varchar)
  obs_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 varchar)
  obs_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 varchar)
  obs_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 varchar)
  obs_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 varchar)
  obs_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 varchar)
  obs_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 varchar)
  obs_basedon_display varchar (100),   -- basedOn/display (100 varchar)
  obs_status varchar (30),   -- status (30 varchar)
  obs_category_system varchar (70),   -- category/coding/system (70 varchar)
  obs_category_version varchar (50),   -- category/coding/version (50 varchar)
  obs_category_code varchar (30),   -- category/coding/code (30 varchar)
  obs_category_display varchar (100),   -- category/coding/display (100 varchar)
  obs_category_text varchar (500),   -- category/text (500 varchar)
  obs_code_system varchar (70),   -- code/coding/system (70 varchar)
  obs_code_version varchar (50),   -- code/coding/version (50 varchar)
  obs_code_code varchar (30),   -- code/coding/code (30 varchar)
  obs_code_display varchar (100),   -- code/coding/display (100 varchar)
  obs_code_text varchar (500),   -- code/text (500 varchar)
  obs_effectivedatetime timestamp,   -- effectiveDateTime (30 timestamp)
  obs_issued timestamp,   -- issued (30 timestamp)
  obs_valuerange_low_value numeric (10, 10),   -- valueRange/low/value (10 numeric)
  obs_valuerange_low_unit varchar (30),   -- valueRange/low/unit (30 varchar)
  obs_valuerange_low_system varchar (70),   -- valueRange/low/system (70 varchar)
  obs_valuerange_low_code varchar (30),   -- valueRange/low/code (30 varchar)
  obs_valuerange_high_value numeric (10, 10),   -- valueRange/high/value (10 numeric)
  obs_valuerange_high_unit varchar (30),   -- valueRange/high/unit (30 varchar)
  obs_valuerange_high_system varchar (70),   -- valueRange/high/system (70 varchar)
  obs_valuerange_high_code varchar (30),   -- valueRange/high/code (30 varchar)
  obs_valueratio_numerator_value numeric (10, 10),   -- valueRatio/numerator/value (10 numeric)
  obs_valueratio_numerator_comparator varchar (10),   -- valueRatio/numerator/comparator (10 varchar)
  obs_valueratio_numerator_unit varchar (30),   -- valueRatio/numerator/unit (30 varchar)
  obs_valueratio_numerator_system varchar (70),   -- valueRatio/numerator/system (70 varchar)
  obs_valueratio_numerator_code varchar (30),   -- valueRatio/numerator/code (30 varchar)
  obs_valueratio_denominator_value numeric (10, 10),   -- valueRatio/denominator/value (10 numeric)
  obs_valueratio_denominator_comparator varchar (10),   -- valueRatio/denominator/comparator (10 varchar)
  obs_valueratio_denominator_unit varchar (30),   -- valueRatio/denominator/unit (30 varchar)
  obs_valueratio_denominator_system varchar (70),   -- valueRatio/denominator/system (70 varchar)
  obs_valueratio_denominator_code varchar (30),   -- valueRatio/denominator/code (30 varchar)
  obs_valuequantity_value numeric (10, 10),   -- valueQuantity/value (10 numeric)
  obs_valuequantity_comparator varchar (10),   -- valueQuantity/comparator (10 varchar)
  obs_valuequantity_unit varchar (30),   -- valueQuantity/unit (30 varchar)
  obs_valuequantity_system varchar (70),   -- valueQuantity/system (70 varchar)
  obs_valuequantity_code varchar (30),   -- valueQuantity/code (30 varchar)
  obs_valuecodableconcept_system varchar (70),   -- valueCodableConcept/coding/system (70 varchar)
  obs_valuecodableconcept_version varchar (50),   -- valueCodableConcept/coding/version (50 varchar)
  obs_valuecodableconcept_code varchar (30),   -- valueCodableConcept/coding/code (30 varchar)
  obs_valuecodableconcept_display varchar (100),   -- valueCodableConcept/coding/display (100 varchar)
  obs_valuecodableconcept_text varchar (500),   -- valueCodableConcept/text (500 varchar)
  obs_dataabsentreason_system varchar (70),   -- dataAbsentReason/coding/system (70 varchar)
  obs_dataabsentreason_version varchar (50),   -- dataAbsentReason/coding/version (50 varchar)
  obs_dataabsentreason_code varchar (30),   -- dataAbsentReason/coding/code (30 varchar)
  obs_dataabsentreason_display varchar (100),   -- dataAbsentReason/coding/display (100 varchar)
  obs_dataabsentreason_text varchar (500),   -- dataAbsentReason/text (500 varchar)
  obs_note_authorstring varchar (50),   -- note/authorString (50 varchar)
  obs_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 varchar)
  obs_note_authorreference_type varchar (30),   -- note/authorReference/type (30 varchar)
  obs_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 varchar)
  obs_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 varchar)
  obs_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 varchar)
  obs_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 varchar)
  obs_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 varchar)
  obs_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 varchar)
  obs_note_authorreference_display varchar (100),   -- note/authorReference/display (100 varchar)
  obs_note_time timestamp,   -- note/time (30 timestamp)
  obs_note_text varchar (5000),   -- note/text (5000 varchar)
  obs_method_system varchar (70),   -- method/coding/system (70 varchar)
  obs_method_version varchar (50),   -- method/coding/version (50 varchar)
  obs_method_code varchar (30),   -- method/coding/code (30 varchar)
  obs_method_display varchar (100),   -- method/coding/display (100 varchar)
  obs_method_text varchar (500),   -- method/text (500 varchar)
  obs_performer_id varchar (70),   -- performer/reference (70 varchar)
  obs_performer_type varchar (30),   -- performer/type (30 varchar)
  obs_performer_identifier_use varchar (30),   -- performer/identifier/use (30 varchar)
  obs_performer_identifier_type_system varchar (70),   -- performer/identifier/type/coding/system (70 varchar)
  obs_performer_identifier_type_version varchar (50),   -- performer/identifier/type/coding/version (50 varchar)
  obs_performer_identifier_type_code varchar (30),   -- performer/identifier/type/coding/code (30 varchar)
  obs_performer_identifier_type_display varchar (100),   -- performer/identifier/type/coding/display (100 varchar)
  obs_performer_identifier_type_text varchar (500),   -- performer/identifier/type/text (500 varchar)
  obs_performer_display varchar (100),   -- performer/display (100 varchar)
  obs_referencerange_low_value numeric (10, 10),   -- referenceRange/low/value (10 numeric)
  obs_referencerange_low_unit varchar (30),   -- referenceRange/low/unit (30 varchar)
  obs_referencerange_low_system varchar (70),   -- referenceRange/low/system (70 varchar)
  obs_referencerange_low_code varchar (30),   -- referenceRange/low/code (30 varchar)
  obs_referencerange_high_value numeric (10, 10),   -- referenceRange/high/value (10 numeric)
  obs_referencerange_high_unit varchar (30),   -- referenceRange/high/unit (30 varchar)
  obs_referencerange_high_system varchar (70),   -- referenceRange/high/system (70 varchar)
  obs_referencerange_high_code varchar (30),   -- referenceRange/high/code (30 varchar)
  obs_referencerange_type_system varchar (70),   -- referenceRange/type/coding/system (70 varchar)
  obs_referencerange_type_version varchar (50),   -- referenceRange/type/coding/version (50 varchar)
  obs_referencerange_type_code varchar (30),   -- referenceRange/type/coding/code (30 varchar)
  obs_referencerange_type_display varchar (100),   -- referenceRange/type/coding/display (100 varchar)
  obs_referencerange_type_text varchar (500),   -- referenceRange/type/text (500 varchar)
  obs_referencerange_appliesto_system varchar (70),   -- referenceRange/appliesTo/coding/system (70 varchar)
  obs_referencerange_appliesto_version varchar (50),   -- referenceRange/appliesTo/coding/version (50 varchar)
  obs_referencerange_appliesto_code varchar (30),   -- referenceRange/appliesTo/coding/code (30 varchar)
  obs_referencerange_appliesto_display varchar (100),   -- referenceRange/appliesTo/coding/display (100 varchar)
  obs_referencerange_appliesto_text varchar (500),   -- referenceRange/appliesTo/text (500 varchar)
  obs_referencerange_age_low_value numeric (10, 10),   -- referenceRange/age/low/value (10 numeric)
  obs_referencerange_age_low_unit varchar (30),   -- referenceRange/age/low/unit (30 varchar)
  obs_referencerange_age_low_system varchar (70),   -- referenceRange/age/low/system (70 varchar)
  obs_referencerange_age_low_code varchar (30),   -- referenceRange/age/low/code (30 varchar)
  obs_referencerange_age_high_value numeric (10, 10),   -- referenceRange/age/high/value (10 numeric)
  obs_referencerange_age_high_unit varchar (30),   -- referenceRange/age/high/unit (30 varchar)
  obs_referencerange_age_high_system varchar (70),   -- referenceRange/age/high/system (70 varchar)
  obs_referencerange_age_high_code varchar (30),   -- referenceRange/age/high/code (30 varchar)
  obs_referencerange_text varchar (500),   -- referenceRange/text (500 varchar)
  obs_hasmember_id varchar (70),   -- hasMember/reference (70 varchar)
  obs_hasmember_type varchar (30),   -- hasMember/type (30 varchar)
  obs_hasmember_identifier_use varchar (30),   -- hasMember/identifier/use (30 varchar)
  obs_hasmember_identifier_type_system varchar (70),   -- hasMember/identifier/type/coding/system (70 varchar)
  obs_hasmember_identifier_type_version varchar (50),   -- hasMember/identifier/type/coding/version (50 varchar)
  obs_hasmember_identifier_type_code varchar (30),   -- hasMember/identifier/type/coding/code (30 varchar)
  obs_hasmember_identifier_type_display varchar (100),   -- hasMember/identifier/type/coding/display (100 varchar)
  obs_hasmember_identifier_type_text varchar (500),   -- hasMember/identifier/type/text (500 varchar)
  obs_hasmember_display varchar (100),   -- hasMember/display (100 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "diagnosticreport" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.diagnosticreport (
  diagnosticreport_id serial PRIMARY KEY not null, -- Primary key of the entity
  diagrep_id varchar (70),   -- id (70 varchar)
  diagrep_encounter_id varchar (70),   -- encounter/reference (70 varchar)
  diagrep_patient_id varchar (70),   -- subject/reference (70 varchar)
  diagrep_partof_id varchar (70),   -- partOf/reference (70 varchar)
  diagrep_identifier_use varchar (50),   -- identifier/use (50 varchar)
  diagrep_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  diagrep_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  diagrep_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  diagrep_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  diagrep_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  diagrep_identifier_system varchar (70),   -- identifier/system (70 varchar)
  diagrep_identifier_value varchar (70),   -- identifier/value (70 varchar)
  diagrep_identifier_start timestamp,   -- identifier/start (30 timestamp)
  diagrep_identifier_end timestamp,   -- identifier/end (30 timestamp)
  diagrep_result_id varchar (70),   -- result/reference (70 varchar)
  diagrep_basedon_id varchar (70),   -- basedOn/reference (70 varchar)
  diagrep_status varchar (30),   -- status (30 varchar)
  diagrep_category_system varchar (70),   -- category/coding/system (70 varchar)
  diagrep_category_version varchar (50),   -- category/coding/version (50 varchar)
  diagrep_category_code varchar (30),   -- category/coding/code (30 varchar)
  diagrep_category_display varchar (100),   -- category/coding/display (100 varchar)
  diagrep_category_text varchar (500),   -- category/text (500 varchar)
  diagrep_code_system varchar (70),   -- code/coding/system (70 varchar)
  diagrep_code_version varchar (50),   -- code/coding/version (50 varchar)
  diagrep_code_code varchar (30),   -- code/coding/code (30 varchar)
  diagrep_code_display varchar (100),   -- code/coding/display (100 varchar)
  diagrep_code_text varchar (500),   -- code/text (500 varchar)
  diagrep_effectivedatetime timestamp,   -- effectiveDateTime (30 timestamp)
  diagrep_issued timestamp,   -- issued (30 timestamp)
  diagrep_performer_id varchar (70),   -- performer/reference (70 varchar)
  diagrep_performer_type varchar (30),   -- performer/type (30 varchar)
  diagrep_performer_identifier_use varchar (30),   -- performer/identifier/use (30 varchar)
  diagrep_performer_identifier_type_system varchar (70),   -- performer/identifier/type/coding/system (70 varchar)
  diagrep_performer_identifier_type_version varchar (50),   -- performer/identifier/type/coding/version (50 varchar)
  diagrep_performer_identifier_type_code varchar (30),   -- performer/identifier/type/coding/code (30 varchar)
  diagrep_performer_identifier_type_display varchar (100),   -- performer/identifier/type/coding/display (100 varchar)
  diagrep_performer_identifier_type_text varchar (500),   -- performer/identifier/type/text (500 varchar)
  diagrep_performer_display varchar (100),   -- performer/display (100 varchar)
  diagrep_conclusion varchar (500),   -- conclusion (500 varchar)
  diagrep_conclusioncode_system varchar (70),   -- conclusionCode/coding/system (70 varchar)
  diagrep_conclusioncode_version varchar (50),   -- conclusionCode/coding/version (50 varchar)
  diagrep_conclusioncode_code varchar (30),   -- conclusionCode/coding/code (30 varchar)
  diagrep_conclusioncode_display varchar (100),   -- conclusionCode/coding/display (100 varchar)
  diagrep_conclusioncode_text varchar (500),   -- conclusionCode/text (500 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "servicerequest" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.servicerequest (
  servicerequest_id serial PRIMARY KEY not null, -- Primary key of the entity
  servreq_id varchar (70),   -- id (70 varchar)
  servreq_encounter_id varchar (70),   -- encounter/reference (70 varchar)
  servreq_patient_id varchar (70),   -- subject/reference (70 varchar)
  servreq_identifier_use varchar (50),   -- identifier/use (50 varchar)
  servreq_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  servreq_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  servreq_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  servreq_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  servreq_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  servreq_identifier_system varchar (70),   -- identifier/system (70 varchar)
  servreq_identifier_value varchar (70),   -- identifier/value (70 varchar)
  servreq_identifier_start timestamp,   -- identifier/start (30 timestamp)
  servreq_identifier_end timestamp,   -- identifier/end (30 timestamp)
  servreq_basedon_id varchar (70),   -- basedOn/reference (70 varchar)
  servreq_basedon_type varchar (30),   -- basedOn/type (30 varchar)
  servreq_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 varchar)
  servreq_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 varchar)
  servreq_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 varchar)
  servreq_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 varchar)
  servreq_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 varchar)
  servreq_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 varchar)
  servreq_basedon_display varchar (100),   -- basedOn/display (100 varchar)
  servreq_status varchar (30),   -- status (30 varchar)
  servreq_intent varchar (30),   -- intent (30 varchar)
  servreq_category_system varchar (70),   -- category/coding/system (70 varchar)
  servreq_category_version varchar (50),   -- category/coding/version (50 varchar)
  servreq_category_code varchar (30),   -- category/coding/code (30 varchar)
  servreq_category_display varchar (100),   -- category/coding/display (100 varchar)
  servreq_category_text varchar (500),   -- category/text (500 varchar)
  servreq_code_system varchar (70),   -- code/coding/system (70 varchar)
  servreq_code_version varchar (50),   -- code/coding/version (50 varchar)
  servreq_code_code varchar (30),   -- code/coding/code (30 varchar)
  servreq_code_display varchar (100),   -- code/coding/display (100 varchar)
  servreq_code_text varchar (500),   -- code/text (500 varchar)
  servreq_authoredon timestamp,   -- authoredOn (30 timestamp)
  servreq_requester_id varchar (70),   -- requester/reference (70 varchar)
  servreq_requester_type varchar (30),   -- requester/type (30 varchar)
  servreq_requester_identifier_use varchar (30),   -- requester/identifier/use (30 varchar)
  servreq_requester_identifier_type_system varchar (70),   -- requester/identifier/type/coding/system (70 varchar)
  servreq_requester_identifier_type_version varchar (50),   -- requester/identifier/type/coding/version (50 varchar)
  servreq_requester_identifier_type_code varchar (30),   -- requester/identifier/type/coding/code (30 varchar)
  servreq_requester_identifier_type_display varchar (100),   -- requester/identifier/type/coding/display (100 varchar)
  servreq_requester_identifier_type_text varchar (500),   -- requester/identifier/type/text (500 varchar)
  servreq_requester_display varchar (100),   -- requester/display (100 varchar)
  servreq_performer_id varchar (70),   -- performer/reference (70 varchar)
  servreq_performer_type varchar (30),   -- performer/type (30 varchar)
  servreq_performer_identifier_use varchar (30),   -- performer/identifier/use (30 varchar)
  servreq_performer_identifier_type_system varchar (70),   -- performer/identifier/type/coding/system (70 varchar)
  servreq_performer_identifier_type_version varchar (50),   -- performer/identifier/type/coding/version (50 varchar)
  servreq_performer_identifier_type_code varchar (30),   -- performer/identifier/type/coding/code (30 varchar)
  servreq_performer_identifier_type_display varchar (100),   -- performer/identifier/type/coding/display (100 varchar)
  servreq_performer_identifier_type_text varchar (500),   -- performer/identifier/type/text (500 varchar)
  servreq_performer_display varchar (100),   -- performer/display (100 varchar)
  servreq_locationcode_system varchar (70),   -- locationCode/coding/system (70 varchar)
  servreq_locationcode_version varchar (50),   -- locationCode/coding/version (50 varchar)
  servreq_locationcode_code varchar (30),   -- locationCode/coding/code (30 varchar)
  servreq_locationcode_display varchar (100),   -- locationCode/coding/display (100 varchar)
  servreq_locationcode_text varchar (500),   -- locationCode/text (500 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "procedure" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.procedure (
  procedure_id serial PRIMARY KEY not null, -- Primary key of the entity
  proc_id varchar (70),   -- id (70 varchar)
  proc_encounter_id varchar (70),   -- encounter/reference (70 varchar)
  proc_patient_id varchar (70),   -- subject/reference (70 varchar)
  proc_partof_id varchar (70),   -- partOf/reference (70 varchar)
  proc_identifier_use varchar (50),   -- identifier/use (50 varchar)
  proc_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  proc_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  proc_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  proc_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  proc_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  proc_identifier_system varchar (70),   -- identifier/system (70 varchar)
  proc_identifier_value varchar (70),   -- identifier/value (70 varchar)
  proc_identifier_start timestamp,   -- identifier/start (30 timestamp)
  proc_identifier_end timestamp,   -- identifier/end (30 timestamp)
  proc_basedon_id varchar (70),   -- basedOn/reference (70 varchar)
  proc_basedon_type varchar (30),   -- basedOn/type (30 varchar)
  proc_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 varchar)
  proc_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 varchar)
  proc_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 varchar)
  proc_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 varchar)
  proc_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 varchar)
  proc_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 varchar)
  proc_basedon_display varchar (100),   -- basedOn/display (100 varchar)
  proc_status varchar (30),   -- status (30 varchar)
  proc_statusreason_system varchar (70),   -- statusReason/coding/system (70 varchar)
  proc_statusreason_version varchar (50),   -- statusReason/coding/version (50 varchar)
  proc_statusreason_code varchar (30),   -- statusReason/coding/code (30 varchar)
  proc_statusreason_display varchar (100),   -- statusReason/coding/display (100 varchar)
  proc_statusreason_text varchar (500),   -- statusReason/text (500 varchar)
  proc_category_system varchar (70),   -- category/coding/system (70 varchar)
  proc_category_version varchar (50),   -- category/coding/version (50 varchar)
  proc_category_code varchar (30),   -- category/coding/code (30 varchar)
  proc_category_display varchar (100),   -- category/coding/display (100 varchar)
  proc_category_text varchar (500),   -- category/text (500 varchar)
  proc_code_system varchar (70),   -- code/coding/system (70 varchar)
  proc_code_version varchar (50),   -- code/coding/version (50 varchar)
  proc_code_code varchar (30),   -- code/coding/code (30 varchar)
  proc_code_display varchar (100),   -- code/coding/display (100 varchar)
  proc_code_text varchar (500),   -- code/text (500 varchar)
  proc_performeddatetime timestamp,   -- performedDateTime (30 timestamp)
  proc_performedperiod_start timestamp,   -- performedPeriod/start (30 timestamp)
  proc_performedperiod_end timestamp,   -- performedPeriod/end (30 timestamp)
  proc_reasoncode_system varchar (70),   -- reasonCode/coding/system (70 varchar)
  proc_reasoncode_version varchar (50),   -- reasonCode/coding/version (50 varchar)
  proc_reasoncode_code varchar (30),   -- reasonCode/coding/code (30 varchar)
  proc_reasoncode_display varchar (100),   -- reasonCode/coding/display (100 varchar)
  proc_reasoncode_text varchar (500),   -- reasonCode/text (500 varchar)
  proc_reasonreference_id varchar (70),   -- reasonReference/reference (70 varchar)
  proc_reasonreference_type varchar (30),   -- reasonReference/type (30 varchar)
  proc_reasonreference_identifier_use varchar (30),   -- reasonReference/identifier/use (30 varchar)
  proc_reasonreference_identifier_type_system varchar (70),   -- reasonReference/identifier/type/coding/system (70 varchar)
  proc_reasonreference_identifier_type_version varchar (50),   -- reasonReference/identifier/type/coding/version (50 varchar)
  proc_reasonreference_identifier_type_code varchar (30),   -- reasonReference/identifier/type/coding/code (30 varchar)
  proc_reasonreference_identifier_type_display varchar (100),   -- reasonReference/identifier/type/coding/display (100 varchar)
  proc_reasonreference_identifier_type_text varchar (500),   -- reasonReference/identifier/type/text (500 varchar)
  proc_reasonreference_display varchar (100),   -- reasonReference/display (100 varchar)
  proc_note_authorstring varchar (50),   -- note/authorString (50 varchar)
  proc_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 varchar)
  proc_note_authorreference_type varchar (30),   -- note/authorReference/type (30 varchar)
  proc_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 varchar)
  proc_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 varchar)
  proc_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 varchar)
  proc_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 varchar)
  proc_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 varchar)
  proc_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 varchar)
  proc_note_authorreference_display varchar (100),   -- note/authorReference/display (100 varchar)
  proc_note_time timestamp,   -- note/time (30 timestamp)
  proc_note_text varchar (5000),   -- note/text (5000 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "consent" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.consent (
  consent_id serial PRIMARY KEY not null, -- Primary key of the entity
  cons_id varchar (70),   -- id (70 varchar)
  cons_patient_id varchar (70),   -- patient/reference (70 varchar)
  cons_identifier_use varchar (50),   -- identifier/use (50 varchar)
  cons_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  cons_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  cons_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  cons_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  cons_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  cons_identifier_system varchar (70),   -- identifier/system (70 varchar)
  cons_identifier_value varchar (70),   -- identifier/value (70 varchar)
  cons_identifier_start timestamp,   -- identifier/start (30 timestamp)
  cons_identifier_end timestamp,   -- identifier/end (30 timestamp)
  cons_status varchar (30),   -- status (30 varchar)
  cons_scope_system varchar (70),   -- scope/coding/system (70 varchar)
  cons_scope_version varchar (50),   -- scope/coding/version (50 varchar)
  cons_scope_code varchar (30),   -- scope/coding/code (30 varchar)
  cons_scope_display varchar (100),   -- scope/coding/display (100 varchar)
  cons_scope_text varchar (500),   -- scope/text (500 varchar)
  cons_datetime timestamp,   -- dateTime (30 timestamp)
  cons_provision_type varchar (10),   -- provision/type (10 varchar)
  cons_provision_period_start timestamp,   -- provision/period/start (30 timestamp)
  cons_provision_period_end timestamp,   -- provision/period/end (30 timestamp)
  cons_provision_actor_role_system varchar (70),   -- provision/actor/role/coding/system (70 varchar)
  cons_provision_actor_role_version varchar (50),   -- provision/actor/role/coding/version (50 varchar)
  cons_provision_actor_role_code varchar (30),   -- provision/actor/role/coding/code (30 varchar)
  cons_provision_actor_role_display varchar (100),   -- provision/actor/role/coding/display (100 varchar)
  cons_provision_actor_role_text varchar (500),   -- provision/actor/role/text (500 varchar)
  cons_provision_code_system varchar (70),   -- provision/code/coding/system (70 varchar)
  cons_provision_code_version varchar (50),   -- provision/code/coding/version (50 varchar)
  cons_provision_code_code varchar (30),   -- provision/code/coding/code (30 varchar)
  cons_provision_code_display varchar (100),   -- provision/code/coding/display (100 varchar)
  cons_provision_code_text varchar (500),   -- provision/code/text (500 varchar)
  cons_provision_dataperiod_start timestamp,   -- provision/dataPeriod/start (30 timestamp)
  cons_provision_dataperiod_end timestamp,   -- provision/dataPeriod/end (30 timestamp)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "location" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.location (
  location_id serial PRIMARY KEY not null, -- Primary key of the entity
  loc_id varchar (70),   -- id (70 varchar)
  loc_identifier_use varchar (50),   -- identifier/use (50 varchar)
  loc_identifier_type_system varchar (70),   -- identifier/type/coding/system (70 varchar)
  loc_identifier_type_version varchar (50),   -- identifier/type/coding/version (50 varchar)
  loc_identifier_type_code varchar (30),   -- identifier/type/coding/code (30 varchar)
  loc_identifier_type_display varchar (100),   -- identifier/type/coding/display (100 varchar)
  loc_identifier_type_text varchar (500),   -- identifier/type/text (500 varchar)
  loc_identifier_system varchar (70),   -- identifier/system (70 varchar)
  loc_identifier_value varchar (70),   -- identifier/value (70 varchar)
  loc_identifier_start timestamp,   -- identifier/start (30 timestamp)
  loc_identifier_end timestamp,   -- identifier/end (30 timestamp)
  loc_status varchar (30),   -- status (30 varchar)
  loc_name varchar (50),   -- name (50 varchar)
  loc_description varchar (50),   -- description (50 varchar)
  loc_alias varchar (30),   -- alias (30 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

-- Table "pids_per_ward" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.pids_per_ward (
  pids_per_ward_id serial PRIMARY KEY not null, -- Primary key of the entity
  date_time timestamp,   -- date_time (30 timestamp)
  ward_name varchar (30),   -- ward_name (30 varchar)
  patient_id varchar (70),   -- patient_id (70 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);


------------------------------------------------------
-- SQL Role / Trigger in Schema "db_log" --
------------------------------------------------------


-- Table "encounter" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.encounter TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.encounter TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.encounter TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.encounter TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.encounter_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER encounter_tr_ins_tr
  BEFORE INSERT
  ON db_log.encounter
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.encounter_tr_ins_fkt();


-- Table "patient" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.patient TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.patient TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.patient_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_tr_ins_tr
  BEFORE INSERT
  ON db_log.patient
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.patient_tr_ins_fkt();


-- Table "condition" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.condition TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.condition TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.condition TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.condition TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.condition_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER condition_tr_ins_tr
  BEFORE INSERT
  ON db_log.condition
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.condition_tr_ins_fkt();


-- Table "medication" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.medication TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medication TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medication TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.medication TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.medication_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medication_tr_ins_tr
  BEFORE INSERT
  ON db_log.medication
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.medication_tr_ins_fkt();


-- Table "medicationrequest" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.medicationrequest TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medicationrequest TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medicationrequest TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.medicationrequest TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.medicationrequest_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationrequest_tr_ins_tr
  BEFORE INSERT
  ON db_log.medicationrequest
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.medicationrequest_tr_ins_fkt();


-- Table "medicationadministration" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.medicationadministration TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medicationadministration TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medicationadministration TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.medicationadministration TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.medicationadministration_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationadministration_tr_ins_tr
  BEFORE INSERT
  ON db_log.medicationadministration
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.medicationadministration_tr_ins_fkt();


-- Table "medicationstatement" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.medicationstatement TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medicationstatement TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medicationstatement TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.medicationstatement TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.medicationstatement_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationstatement_tr_ins_tr
  BEFORE INSERT
  ON db_log.medicationstatement
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.medicationstatement_tr_ins_fkt();


-- Table "observation" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.observation TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.observation TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.observation TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.observation TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.observation_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER observation_tr_ins_tr
  BEFORE INSERT
  ON db_log.observation
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.observation_tr_ins_fkt();


-- Table "diagnosticreport" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.diagnosticreport TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.diagnosticreport TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.diagnosticreport TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.diagnosticreport TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.diagnosticreport_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER diagnosticreport_tr_ins_tr
  BEFORE INSERT
  ON db_log.diagnosticreport
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.diagnosticreport_tr_ins_fkt();


-- Table "servicerequest" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.servicerequest TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.servicerequest TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.servicerequest TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.servicerequest TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.servicerequest_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER servicerequest_tr_ins_tr
  BEFORE INSERT
  ON db_log.servicerequest
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.servicerequest_tr_ins_fkt();


-- Table "procedure" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.procedure TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.procedure TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.procedure TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.procedure TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.procedure_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER procedure_tr_ins_tr
  BEFORE INSERT
  ON db_log.procedure
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.procedure_tr_ins_fkt();


-- Table "consent" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.consent TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.consent TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.consent TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.consent TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.consent_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER consent_tr_ins_tr
  BEFORE INSERT
  ON db_log.consent
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.consent_tr_ins_fkt();


-- Table "location" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.location TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.location TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.location TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.location TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.location_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER location_tr_ins_tr
  BEFORE INSERT
  ON db_log.location
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.location_tr_ins_fkt();


-- Table "pids_per_ward" in schema "db_log"
----------------------------------------------------


GRANT TRIGGER ON db_log.pids_per_ward TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.pids_per_ward TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.pids_per_ward TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db_log.pids_per_ward TO cds2db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db_log.pids_per_ward_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER pids_per_ward_tr_ins_tr
  BEFORE INSERT
  ON db_log.pids_per_ward
  FOR EACH ROW
  EXECUTE PROCEDURE db_log.pids_per_ward_tr_ins_fkt();


------------------------------------------------------
-- Comments on Tables in Schema "db_log" --
------------------------------------------------------

comment on column db_log.encounter.enc_id is 'id id (70 varchar)';
comment on column db_log.encounter.enc_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.encounter.enc_partof_id is 'partOf/reference partOf/reference (70 varchar)';
comment on column db_log.encounter.enc_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.encounter.enc_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.encounter.enc_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.encounter.enc_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.encounter.enc_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.encounter.enc_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.encounter.enc_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.encounter.enc_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.encounter.enc_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.encounter.enc_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.encounter.enc_status is 'status status (30 varchar)';
comment on column db_log.encounter.enc_class_system is 'class/coding/system class/coding/system (70 varchar)';
comment on column db_log.encounter.enc_class_version is 'class/coding/version class/coding/version (50 varchar)';
comment on column db_log.encounter.enc_class_code is 'class/coding/code class/coding/code (30 varchar)';
comment on column db_log.encounter.enc_class_display is 'class/coding/display class/coding/display (100 varchar)';
comment on column db_log.encounter.enc_type_system is 'type/coding/system type/coding/system (70 varchar)';
comment on column db_log.encounter.enc_type_version is 'type/coding/version type/coding/version (50 varchar)';
comment on column db_log.encounter.enc_type_code is 'type/coding/code type/coding/code (30 varchar)';
comment on column db_log.encounter.enc_type_display is 'type/coding/display type/coding/display (100 varchar)';
comment on column db_log.encounter.enc_type_text is 'type/text type/text (500 varchar)';
comment on column db_log.encounter.enc_servicetype_system is 'serviceType/coding/system serviceType/coding/system (70 varchar)';
comment on column db_log.encounter.enc_servicetype_version is 'serviceType/coding/version serviceType/coding/version (50 varchar)';
comment on column db_log.encounter.enc_servicetype_code is 'serviceType/coding/code serviceType/coding/code (30 varchar)';
comment on column db_log.encounter.enc_servicetype_display is 'serviceType/coding/display serviceType/coding/display (100 varchar)';
comment on column db_log.encounter.enc_servicetype_text is 'serviceType/text serviceType/text (500 varchar)';
comment on column db_log.encounter.enc_period_start is 'period/start period/start (30 timestamp)';
comment on column db_log.encounter.enc_period_end is 'period/end period/end (30 timestamp)';
comment on column db_log.encounter.enc_diagnosis_condition_id is 'diagnosis/condition/reference diagnosis/condition/reference (70 varchar)';
comment on column db_log.encounter.enc_diagnosis_use_system is 'diagnosis/use/coding/system diagnosis/use/coding/system (70 varchar)';
comment on column db_log.encounter.enc_diagnosis_use_version is 'diagnosis/use/coding/version diagnosis/use/coding/version (50 varchar)';
comment on column db_log.encounter.enc_diagnosis_use_code is 'diagnosis/use/coding/code diagnosis/use/coding/code (30 varchar)';
comment on column db_log.encounter.enc_diagnosis_use_display is 'diagnosis/use/coding/display diagnosis/use/coding/display (100 varchar)';
comment on column db_log.encounter.enc_diagnosis_use_text is 'diagnosis/use/text diagnosis/use/text (500 varchar)';
comment on column db_log.encounter.enc_diagnosis_rank is 'diagnosis/rank diagnosis/rank (2 int)';
comment on column db_log.encounter.enc_hospitalization_admitsource_system is 'hospitalization/admitSource/coding/system hospitalization/admitSource/coding/system (70 varchar)';
comment on column db_log.encounter.enc_hospitalization_admitsource_version is 'hospitalization/admitSource/coding/version hospitalization/admitSource/coding/version (50 varchar)';
comment on column db_log.encounter.enc_hospitalization_admitsource_code is 'hospitalization/admitSource/coding/code hospitalization/admitSource/coding/code (30 varchar)';
comment on column db_log.encounter.enc_hospitalization_admitsource_display is 'hospitalization/admitSource/coding/display hospitalization/admitSource/coding/display (100 varchar)';
comment on column db_log.encounter.enc_hospitalization_admitsource_text is 'hospitalization/admitSource/text hospitalization/admitSource/text (500 varchar)';
comment on column db_log.encounter.enc_hospitalization_dischargedisposition_system is 'hospitalization/dischargeDisposition/coding/system hospitalization/dischargeDisposition/coding/system (70 varchar)';
comment on column db_log.encounter.enc_hospitalization_dischargedisposition_version is 'hospitalization/dischargeDisposition/coding/version hospitalization/dischargeDisposition/coding/version (50 varchar)';
comment on column db_log.encounter.enc_hospitalization_dischargedisposition_code is 'hospitalization/dischargeDisposition/coding/code hospitalization/dischargeDisposition/coding/code (30 varchar)';
comment on column db_log.encounter.enc_hospitalization_dischargedisposition_display is 'hospitalization/dischargeDisposition/coding/display hospitalization/dischargeDisposition/coding/display (100 varchar)';
comment on column db_log.encounter.enc_hospitalization_dischargedisposition_text is 'hospitalization/dischargeDisposition/text hospitalization/dischargeDisposition/text (500 varchar)';
comment on column db_log.encounter.enc_location_id is 'location/location/reference location/location/reference (70 varchar)';
comment on column db_log.encounter.enc_location_type is 'location/location/type location/location/type (30 varchar)';
comment on column db_log.encounter.enc_location_identifier_use is 'location/location/identifier/use location/location/identifier/use (30 varchar)';
comment on column db_log.encounter.enc_location_identifier_type_system is 'location/location/identifier/type/coding/system location/location/identifier/type/coding/system (70 varchar)';
comment on column db_log.encounter.enc_location_identifier_type_version is 'location/location/identifier/type/coding/version location/location/identifier/type/coding/version (50 varchar)';
comment on column db_log.encounter.enc_location_identifier_type_code is 'location/location/identifier/type/coding/code location/location/identifier/type/coding/code (30 varchar)';
comment on column db_log.encounter.enc_location_identifier_type_display is 'location/location/identifier/type/coding/display location/location/identifier/type/coding/display (100 varchar)';
comment on column db_log.encounter.enc_location_identifier_type_text is 'location/location/identifier/type/text location/location/identifier/type/text (500 varchar)';
comment on column db_log.encounter.enc_location_display is 'location/location/display location/location/display (100 varchar)';
comment on column db_log.encounter.enc_location_status is 'location/location/status location/location/status (10 varchar)';
comment on column db_log.encounter.enc_location_physicaltype_system is 'location/location/physicalType/coding/system location/location/physicalType/coding/system (70 varchar)';
comment on column db_log.encounter.enc_location_physicaltype_version is 'location/location/physicalType/coding/version location/location/physicalType/coding/version (50 varchar)';
comment on column db_log.encounter.enc_location_physicaltype_code is 'location/location/physicalType/coding/code location/location/physicalType/coding/code (30 varchar)';
comment on column db_log.encounter.enc_location_physicaltype_display is 'location/location/physicalType/coding/display location/location/physicalType/coding/display (100 varchar)';
comment on column db_log.encounter.enc_location_physicaltype_text is 'location/location/physicalType/text location/location/physicalType/text (500 varchar)';
comment on column db_log.encounter.enc_serviceprovider_id is 'serviceProvider/reference serviceProvider/reference (70 varchar)';
comment on column db_log.encounter.enc_serviceprovider_type is 'serviceProvider/type serviceProvider/type (30 varchar)';
comment on column db_log.encounter.enc_serviceprovider_identifier_use is 'serviceProvider/identifier/use serviceProvider/identifier/use (30 varchar)';
comment on column db_log.encounter.enc_serviceprovider_identifier_type_system is 'serviceProvider/identifier/type/coding/system serviceProvider/identifier/type/coding/system (70 varchar)';
comment on column db_log.encounter.enc_serviceprovider_identifier_type_version is 'serviceProvider/identifier/type/coding/version serviceProvider/identifier/type/coding/version (50 varchar)';
comment on column db_log.encounter.enc_serviceprovider_identifier_type_code is 'serviceProvider/identifier/type/coding/code serviceProvider/identifier/type/coding/code (30 varchar)';
comment on column db_log.encounter.enc_serviceprovider_identifier_type_display is 'serviceProvider/identifier/type/coding/display serviceProvider/identifier/type/coding/display (100 varchar)';
comment on column db_log.encounter.enc_serviceprovider_identifier_type_text is 'serviceProvider/identifier/type/text serviceProvider/identifier/type/text (500 varchar)';
comment on column db_log.encounter.enc_serviceprovider_display is 'serviceProvider/display serviceProvider/display (100 varchar)';

comment on column db_log.patient.pat_id is 'id id (70 varchar)';
comment on column db_log.patient.pat_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.patient.pat_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.patient.pat_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.patient.pat_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.patient.pat_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.patient.pat_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.patient.pat_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.patient.pat_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.patient.pat_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.patient.pat_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.patient.pat_name_text is 'name/text name/text (250 varchar)';
comment on column db_log.patient.pat_name_family is 'name/family name/family (50 varchar)';
comment on column db_log.patient.pat_name_given is 'name/given name/given (30 varchar)';
comment on column db_log.patient.pat_gender is 'gender gender (10 varchar)';
comment on column db_log.patient.pat_birthdate is 'birthDate birthDate (30 date)';
comment on column db_log.patient.pat_address_postalcode is 'address/postalCode address/postalCode (10 varchar)';

comment on column db_log.condition.con_id is 'id id (70 varchar)';
comment on column db_log.condition.con_encounter_id is 'encounter/reference encounter/reference (70 varchar)';
comment on column db_log.condition.con_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.condition.con_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.condition.con_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.condition.con_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.condition.con_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.condition.con_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.condition.con_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.condition.con_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.condition.con_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.condition.con_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.condition.con_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.condition.con_clinicalstatus_system is 'clinicalStatus/coding/system clinicalStatus/coding/system (70 varchar)';
comment on column db_log.condition.con_clinicalstatus_version is 'clinicalStatus/coding/version clinicalStatus/coding/version (50 varchar)';
comment on column db_log.condition.con_clinicalstatus_code is 'clinicalStatus/coding/code clinicalStatus/coding/code (30 varchar)';
comment on column db_log.condition.con_clinicalstatus_display is 'clinicalStatus/coding/display clinicalStatus/coding/display (100 varchar)';
comment on column db_log.condition.con_clinicalstatus_text is 'clinicalStatus/text clinicalStatus/text (500 varchar)';
comment on column db_log.condition.con_verificationstatus_system is 'verificationStatus/coding/system verificationStatus/coding/system (70 varchar)';
comment on column db_log.condition.con_verificationstatus_version is 'verificationStatus/coding/version verificationStatus/coding/version (50 varchar)';
comment on column db_log.condition.con_verificationstatus_code is 'verificationStatus/coding/code verificationStatus/coding/code (30 varchar)';
comment on column db_log.condition.con_verificationstatus_display is 'verificationStatus/coding/display verificationStatus/coding/display (100 varchar)';
comment on column db_log.condition.con_verificationstatus_text is 'verificationStatus/text verificationStatus/text (500 varchar)';
comment on column db_log.condition.con_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.condition.con_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.condition.con_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.condition.con_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.condition.con_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.condition.con_severity_system is 'severity/coding/system severity/coding/system (70 varchar)';
comment on column db_log.condition.con_severity_version is 'severity/coding/version severity/coding/version (50 varchar)';
comment on column db_log.condition.con_severity_code is 'severity/coding/code severity/coding/code (30 varchar)';
comment on column db_log.condition.con_severity_display is 'severity/coding/display severity/coding/display (100 varchar)';
comment on column db_log.condition.con_severity_text is 'severity/text severity/text (500 varchar)';
comment on column db_log.condition.con_code_system is 'code/coding/system code/coding/system (70 varchar)';
comment on column db_log.condition.con_code_version is 'code/coding/version code/coding/version (50 varchar)';
comment on column db_log.condition.con_code_code is 'code/coding/code code/coding/code (30 varchar)';
comment on column db_log.condition.con_code_display is 'code/coding/display code/coding/display (100 varchar)';
comment on column db_log.condition.con_code_text is 'code/text code/text (500 varchar)';
comment on column db_log.condition.con_bodysite_system is 'bodySite/coding/system bodySite/coding/system (70 varchar)';
comment on column db_log.condition.con_bodysite_version is 'bodySite/coding/version bodySite/coding/version (50 varchar)';
comment on column db_log.condition.con_bodysite_code is 'bodySite/coding/code bodySite/coding/code (30 varchar)';
comment on column db_log.condition.con_bodysite_display is 'bodySite/coding/display bodySite/coding/display (100 varchar)';
comment on column db_log.condition.con_bodysite_text is 'bodySite/text bodySite/text (500 varchar)';
comment on column db_log.condition.con_onsetperiod_start is 'onsetPeriod/start onsetPeriod/start (30 timestamp)';
comment on column db_log.condition.con_onsetperiod_end is 'onsetPeriod/end onsetPeriod/end (30 timestamp)';
comment on column db_log.condition.con_onsetdatetime is 'onsetDateTime onsetDateTime (30 timestamp)';
comment on column db_log.condition.con_abatementdatetime is 'abatementDateTime abatementDateTime (30 timestamp)';
comment on column db_log.condition.con_abatementage_value is 'abatementAge/value abatementAge/value (10 numeric)';
comment on column db_log.condition.con_abatementage_comparator is 'abatementAge/comparator abatementAge/comparator (3 varchar)';
comment on column db_log.condition.con_abatementage_unit is 'abatementAge/unit abatementAge/unit (30 varchar)';
comment on column db_log.condition.con_abatementage_system is 'abatementAge/system abatementAge/system (70 varchar)';
comment on column db_log.condition.con_abatementage_code is 'abatementAge/code abatementAge/code (30 varchar)';
comment on column db_log.condition.con_abatementperiod_start is 'abatementPeriod/start abatementPeriod/start (30 timestamp)';
comment on column db_log.condition.con_abatementperiod_end is 'abatementPeriod/end abatementPeriod/end (30 timestamp)';
comment on column db_log.condition.con_abatementrange_low_value is 'abatementRange/low/value abatementRange/low/value (10 numeric)';
comment on column db_log.condition.con_abatementrange_low_unit is 'abatementRange/low/unit abatementRange/low/unit (30 varchar)';
comment on column db_log.condition.con_abatementrange_low_system is 'abatementRange/low/system abatementRange/low/system (70 varchar)';
comment on column db_log.condition.con_abatementrange_low_code is 'abatementRange/low/code abatementRange/low/code (30 varchar)';
comment on column db_log.condition.con_abatementrange_high_value is 'abatementRange/high/value abatementRange/high/value (10 numeric)';
comment on column db_log.condition.con_abatementrange_high_unit is 'abatementRange/high/unit abatementRange/high/unit (30 varchar)';
comment on column db_log.condition.con_abatementrange_high_system is 'abatementRange/high/system abatementRange/high/system (70 varchar)';
comment on column db_log.condition.con_abatementrange_high_code is 'abatementRange/high/code abatementRange/high/code (30 varchar)';
comment on column db_log.condition.con_abatementstring is 'abatementString abatementString (300 varchar)';
comment on column db_log.condition.con_recordeddate is 'recordedDate recordedDate (30 timestamp)';
comment on column db_log.condition.con_recorder_id is 'recorder/reference recorder/reference (70 varchar)';
comment on column db_log.condition.con_recorder_type is 'recorder/type recorder/type (30 varchar)';
comment on column db_log.condition.con_recorder_identifier_use is 'recorder/identifier/use recorder/identifier/use (30 varchar)';
comment on column db_log.condition.con_recorder_identifier_type_system is 'recorder/identifier/type/coding/system recorder/identifier/type/coding/system (70 varchar)';
comment on column db_log.condition.con_recorder_identifier_type_version is 'recorder/identifier/type/coding/version recorder/identifier/type/coding/version (50 varchar)';
comment on column db_log.condition.con_recorder_identifier_type_code is 'recorder/identifier/type/coding/code recorder/identifier/type/coding/code (30 varchar)';
comment on column db_log.condition.con_recorder_identifier_type_display is 'recorder/identifier/type/coding/display recorder/identifier/type/coding/display (100 varchar)';
comment on column db_log.condition.con_recorder_identifier_type_text is 'recorder/identifier/type/text recorder/identifier/type/text (500 varchar)';
comment on column db_log.condition.con_recorder_display is 'recorder/display recorder/display (100 varchar)';
comment on column db_log.condition.con_asserter_id is 'asserter/reference asserter/reference (70 varchar)';
comment on column db_log.condition.con_asserter_type is 'asserter/type asserter/type (30 varchar)';
comment on column db_log.condition.con_asserter_identifier_use is 'asserter/identifier/use asserter/identifier/use (30 varchar)';
comment on column db_log.condition.con_asserter_identifier_type_system is 'asserter/identifier/type/coding/system asserter/identifier/type/coding/system (70 varchar)';
comment on column db_log.condition.con_asserter_identifier_type_version is 'asserter/identifier/type/coding/version asserter/identifier/type/coding/version (50 varchar)';
comment on column db_log.condition.con_asserter_identifier_type_code is 'asserter/identifier/type/coding/code asserter/identifier/type/coding/code (30 varchar)';
comment on column db_log.condition.con_asserter_identifier_type_display is 'asserter/identifier/type/coding/display asserter/identifier/type/coding/display (100 varchar)';
comment on column db_log.condition.con_asserter_identifier_type_text is 'asserter/identifier/type/text asserter/identifier/type/text (500 varchar)';
comment on column db_log.condition.con_asserter_display is 'asserter/display asserter/display (100 varchar)';
comment on column db_log.condition.con_stage_summary_system is 'stage/summary/coding/system stage/summary/coding/system (70 varchar)';
comment on column db_log.condition.con_stage_summary_version is 'stage/summary/coding/version stage/summary/coding/version (50 varchar)';
comment on column db_log.condition.con_stage_summary_code is 'stage/summary/coding/code stage/summary/coding/code (30 varchar)';
comment on column db_log.condition.con_stage_summary_display is 'stage/summary/coding/display stage/summary/coding/display (100 varchar)';
comment on column db_log.condition.con_stage_summary_text is 'stage/summary/text stage/summary/text (500 varchar)';
comment on column db_log.condition.con_stage_assessment_id is 'stage/assessment/reference stage/assessment/reference (70 varchar)';
comment on column db_log.condition.con_stage_assessment_type is 'stage/assessment/type stage/assessment/type (30 varchar)';
comment on column db_log.condition.con_stage_assessment_identifier_use is 'stage/assessment/identifier/use stage/assessment/identifier/use (30 varchar)';
comment on column db_log.condition.con_stage_assessment_identifier_type_system is 'stage/assessment/identifier/type/coding/system stage/assessment/identifier/type/coding/system (70 varchar)';
comment on column db_log.condition.con_stage_assessment_identifier_type_version is 'stage/assessment/identifier/type/coding/version stage/assessment/identifier/type/coding/version (50 varchar)';
comment on column db_log.condition.con_stage_assessment_identifier_type_code is 'stage/assessment/identifier/type/coding/code stage/assessment/identifier/type/coding/code (30 varchar)';
comment on column db_log.condition.con_stage_assessment_identifier_type_display is 'stage/assessment/identifier/type/coding/display stage/assessment/identifier/type/coding/display (100 varchar)';
comment on column db_log.condition.con_stage_assessment_identifier_type_text is 'stage/assessment/identifier/type/text stage/assessment/identifier/type/text (500 varchar)';
comment on column db_log.condition.con_stage_assessment_display is 'stage/assessment/display stage/assessment/display (100 varchar)';
comment on column db_log.condition.con_stage_type_system is 'stage/type/coding/system stage/type/coding/system (70 varchar)';
comment on column db_log.condition.con_stage_type_version is 'stage/type/coding/version stage/type/coding/version (50 varchar)';
comment on column db_log.condition.con_stage_type_code is 'stage/type/coding/code stage/type/coding/code (30 varchar)';
comment on column db_log.condition.con_stage_type_display is 'stage/type/coding/display stage/type/coding/display (100 varchar)';
comment on column db_log.condition.con_stage_type_text is 'stage/type/text stage/type/text (500 varchar)';
comment on column db_log.condition.con_note_authorstring is 'note/authorString note/authorString (50 varchar)';
comment on column db_log.condition.con_note_authorreference_id is 'note/authorReference/reference note/authorReference/reference (70 varchar)';
comment on column db_log.condition.con_note_authorreference_type is 'note/authorReference/type note/authorReference/type (30 varchar)';
comment on column db_log.condition.con_note_authorreference_identifier_use is 'note/authorReference/identifier/use note/authorReference/identifier/use (30 varchar)';
comment on column db_log.condition.con_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system note/authorReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.condition.con_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version note/authorReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.condition.con_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code note/authorReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.condition.con_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display note/authorReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.condition.con_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text note/authorReference/identifier/type/text (500 varchar)';
comment on column db_log.condition.con_note_authorreference_display is 'note/authorReference/display note/authorReference/display (100 varchar)';
comment on column db_log.condition.con_note_time is 'note/time note/time (30 timestamp)';
comment on column db_log.condition.con_note_text is 'note/text note/text (5000 varchar)';

comment on column db_log.medication.med_id is 'id id (70 varchar)';
comment on column db_log.medication.med_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.medication.med_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.medication.med_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.medication.med_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.medication.med_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.medication.med_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.medication.med_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.medication.med_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.medication.med_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.medication.med_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.medication.med_code_system is 'code/coding/system code/coding/system (70 varchar)';
comment on column db_log.medication.med_code_version is 'code/coding/version code/coding/version (50 varchar)';
comment on column db_log.medication.med_code_code is 'code/coding/code code/coding/code (30 varchar)';
comment on column db_log.medication.med_code_display is 'code/coding/display code/coding/display (100 varchar)';
comment on column db_log.medication.med_code_text is 'code/text code/text (500 varchar)';
comment on column db_log.medication.med_status is 'status status (20 varchar)';
comment on column db_log.medication.med_form_system is 'form/coding/system form/coding/system (70 varchar)';
comment on column db_log.medication.med_form_version is 'form/coding/version form/coding/version (50 varchar)';
comment on column db_log.medication.med_form_code is 'form/coding/code form/coding/code (30 varchar)';
comment on column db_log.medication.med_form_display is 'form/coding/display form/coding/display (100 varchar)';
comment on column db_log.medication.med_form_text is 'form/text form/text (500 varchar)';
comment on column db_log.medication.med_amount_numerator_value is 'amount/numerator/value amount/numerator/value (10 numeric)';
comment on column db_log.medication.med_amount_numerator_comparator is 'amount/numerator/comparator amount/numerator/comparator (10 varchar)';
comment on column db_log.medication.med_amount_numerator_unit is 'amount/numerator/unit amount/numerator/unit (30 varchar)';
comment on column db_log.medication.med_amount_numerator_system is 'amount/numerator/system amount/numerator/system (70 varchar)';
comment on column db_log.medication.med_amount_numerator_code is 'amount/numerator/code amount/numerator/code (30 varchar)';
comment on column db_log.medication.med_amount_denominator_value is 'amount/denominator/value amount/denominator/value (10 numeric)';
comment on column db_log.medication.med_amount_denominator_comparator is 'amount/denominator/comparator amount/denominator/comparator (10 varchar)';
comment on column db_log.medication.med_amount_denominator_unit is 'amount/denominator/unit amount/denominator/unit (30 varchar)';
comment on column db_log.medication.med_amount_denominator_system is 'amount/denominator/system amount/denominator/system (70 varchar)';
comment on column db_log.medication.med_amount_denominator_code is 'amount/denominator/code amount/denominator/code (30 varchar)';
comment on column db_log.medication.med_ingredient_strength_numerator_value is 'ingredient/strength/numerator/value ingredient/strength/numerator/value (10 numeric)';
comment on column db_log.medication.med_ingredient_strength_numerator_comparator is 'ingredient/strength/numerator/comparator ingredient/strength/numerator/comparator (10 varchar)';
comment on column db_log.medication.med_ingredient_strength_numerator_unit is 'ingredient/strength/numerator/unit ingredient/strength/numerator/unit (30 varchar)';
comment on column db_log.medication.med_ingredient_strength_numerator_system is 'ingredient/strength/numerator/system ingredient/strength/numerator/system (70 varchar)';
comment on column db_log.medication.med_ingredient_strength_numerator_code is 'ingredient/strength/numerator/code ingredient/strength/numerator/code (30 varchar)';
comment on column db_log.medication.med_ingredient_strength_denominator_value is 'ingredient/strength/denominator/value ingredient/strength/denominator/value (10 numeric)';
comment on column db_log.medication.med_ingredient_strength_denominator_comparator is 'ingredient/strength/denominator/comparator ingredient/strength/denominator/comparator (10 varchar)';
comment on column db_log.medication.med_ingredient_strength_denominator_unit is 'ingredient/strength/denominator/unit ingredient/strength/denominator/unit (30 varchar)';
comment on column db_log.medication.med_ingredient_strength_denominator_system is 'ingredient/strength/denominator/system ingredient/strength/denominator/system (70 varchar)';
comment on column db_log.medication.med_ingredient_strength_denominator_code is 'ingredient/strength/denominator/code ingredient/strength/denominator/code (30 varchar)';
comment on column db_log.medication.med_ingredient_itemcodeableconcept_system is 'ingredient/itemCodeableConcept/coding/system ingredient/itemCodeableConcept/coding/system (70 varchar)';
comment on column db_log.medication.med_ingredient_itemcodeableconcept_version is 'ingredient/itemCodeableConcept/coding/version ingredient/itemCodeableConcept/coding/version (50 varchar)';
comment on column db_log.medication.med_ingredient_itemcodeableconcept_code is 'ingredient/itemCodeableConcept/coding/code ingredient/itemCodeableConcept/coding/code (30 varchar)';
comment on column db_log.medication.med_ingredient_itemcodeableconcept_display is 'ingredient/itemCodeableConcept/coding/display ingredient/itemCodeableConcept/coding/display (100 varchar)';
comment on column db_log.medication.med_ingredient_itemcodeableconcept_text is 'ingredient/itemCodeableConcept/text ingredient/itemCodeableConcept/text (500 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_id is 'ingredient/itemReference/reference ingredient/itemReference/reference (70 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_type is 'ingredient/itemReference/type ingredient/itemReference/type (30 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_identifier_use is 'ingredient/itemReference/identifier/use ingredient/itemReference/identifier/use (30 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_identifier_type_system is 'ingredient/itemReference/identifier/type/coding/system ingredient/itemReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_identifier_type_version is 'ingredient/itemReference/identifier/type/coding/version ingredient/itemReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_identifier_type_code is 'ingredient/itemReference/identifier/type/coding/code ingredient/itemReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_identifier_type_display is 'ingredient/itemReference/identifier/type/coding/display ingredient/itemReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_identifier_type_text is 'ingredient/itemReference/identifier/type/text ingredient/itemReference/identifier/type/text (500 varchar)';
comment on column db_log.medication.med_ingredient_itemreference_display is 'ingredient/itemReference/display ingredient/itemReference/display (100 varchar)';
comment on column db_log.medication.med_ingredient_isactive is 'ingredient/isActive ingredient/isActive (10 boolean)';

comment on column db_log.medicationrequest.medreq_id is 'id id (70 varchar)';
comment on column db_log.medicationrequest.medreq_encounter_id is 'encounter/reference encounter/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.medicationrequest.medreq_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.medicationrequest.medreq_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.medicationrequest.medreq_medicationreference_id is 'medicationReference/reference medicationReference/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_status is 'status status (20 varchar)';
comment on column db_log.medicationrequest.medreq_statusreason_system is 'statusReason/coding/system statusReason/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_statusreason_version is 'statusReason/coding/version statusReason/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_statusreason_code is 'statusReason/coding/code statusReason/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_statusreason_display is 'statusReason/coding/display statusReason/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_statusreason_text is 'statusReason/text statusReason/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_intend is 'intend intend (20 varchar)';
comment on column db_log.medicationrequest.medreq_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_priority is 'priority priority (10 varchar)';
comment on column db_log.medicationrequest.medreq_reportedboolean is 'reportedBoolean reportedBoolean (10 boolean)';
comment on column db_log.medicationrequest.medreq_reportedreference_id is 'reportedReference/reference reportedReference/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_type is 'reportedReference/type reportedReference/type (30 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_identifier_use is 'reportedReference/identifier/use reportedReference/identifier/use (30 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_identifier_type_system is 'reportedReference/identifier/type/coding/system reportedReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_identifier_type_version is 'reportedReference/identifier/type/coding/version reportedReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_identifier_type_code is 'reportedReference/identifier/type/coding/code reportedReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_identifier_type_display is 'reportedReference/identifier/type/coding/display reportedReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_identifier_type_text is 'reportedReference/identifier/type/text reportedReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_reportedreference_display is 'reportedReference/display reportedReference/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system medicationCodeableConcept/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version medicationCodeableConcept/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code medicationCodeableConcept/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display medicationCodeableConcept/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_medicationcodeableconcept_text is 'medicationCodeableConcept/text medicationCodeableConcept/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_id is 'supportingInformation/reference supportingInformation/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_type is 'supportingInformation/type supportingInformation/type (30 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_identifier_use is 'supportingInformation/identifier/use supportingInformation/identifier/use (30 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_identifier_type_system is 'supportingInformation/identifier/type/coding/system supportingInformation/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_identifier_type_version is 'supportingInformation/identifier/type/coding/version supportingInformation/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_identifier_type_code is 'supportingInformation/identifier/type/coding/code supportingInformation/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_identifier_type_display is 'supportingInformation/identifier/type/coding/display supportingInformation/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_identifier_type_text is 'supportingInformation/identifier/type/text supportingInformation/identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_supportinginformation_display is 'supportingInformation/display supportingInformation/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_authoredon is 'authoredOn authoredOn (30 timestamp)';
comment on column db_log.medicationrequest.medreq_requester_id is 'requester/reference requester/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_requester_type is 'requester/type requester/type (30 varchar)';
comment on column db_log.medicationrequest.medreq_requester_identifier_use is 'requester/identifier/use requester/identifier/use (30 varchar)';
comment on column db_log.medicationrequest.medreq_requester_identifier_type_system is 'requester/identifier/type/coding/system requester/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_requester_identifier_type_version is 'requester/identifier/type/coding/version requester/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_requester_identifier_type_code is 'requester/identifier/type/coding/code requester/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_requester_identifier_type_display is 'requester/identifier/type/coding/display requester/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_requester_identifier_type_text is 'requester/identifier/type/text requester/identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_requester_display is 'requester/display requester/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_reasoncode_system is 'reasonCode/coding/system reasonCode/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_reasoncode_version is 'reasonCode/coding/version reasonCode/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_reasoncode_code is 'reasonCode/coding/code reasonCode/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_reasoncode_display is 'reasonCode/coding/display reasonCode/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_reasoncode_text is 'reasonCode/text reasonCode/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_id is 'reasonReference/reference reasonReference/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_type is 'reasonReference/type reasonReference/type (30 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_identifier_use is 'reasonReference/identifier/use reasonReference/identifier/use (30 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system reasonReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version reasonReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code reasonReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display reasonReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text reasonReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_reasonreference_display is 'reasonReference/display reasonReference/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_id is 'basedOn/reference basedOn/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_type is 'basedOn/type basedOn/type (30 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_identifier_use is 'basedOn/identifier/use basedOn/identifier/use (30 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system basedOn/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version basedOn/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code basedOn/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display basedOn/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_identifier_type_text is 'basedOn/identifier/type/text basedOn/identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_basedon_display is 'basedOn/display basedOn/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorstring is 'note/authorString note/authorString (50 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_id is 'note/authorReference/reference note/authorReference/reference (70 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_type is 'note/authorReference/type note/authorReference/type (30 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_identifier_use is 'note/authorReference/identifier/use note/authorReference/identifier/use (30 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system note/authorReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version note/authorReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code note/authorReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display note/authorReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text note/authorReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_note_authorreference_display is 'note/authorReference/display note/authorReference/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_note_time is 'note/time note/time (30 timestamp)';
comment on column db_log.medicationrequest.medreq_note_text is 'note/text note/text (5000 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_sequence is 'dosageInstruction/sequence dosageInstruction/sequence (10 int)';
comment on column db_log.medicationrequest.medreq_doseinstruc_text is 'dosageInstruction/text dosageInstruction/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_additionalinstruction_system is 'dosageInstruction/additionalInstruction/coding/system dosageInstruction/additionalInstruction/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_additionalinstruction_version is 'dosageInstruction/additionalInstruction/coding/version dosageInstruction/additionalInstruction/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_additionalinstruction_code is 'dosageInstruction/additionalInstruction/coding/code dosageInstruction/additionalInstruction/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_additionalinstruction_display is 'dosageInstruction/additionalInstruction/coding/display dosageInstruction/additionalInstruction/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_additionalinstruction_text is 'dosageInstruction/additionalInstruction/text dosageInstruction/additionalInstruction/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_patientinstruction is 'dosageInstruction/patientInstruction dosageInstruction/patientInstruction (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_event is 'dosageInstruction/timing/event dosageInstruction/timing/event (30 timestamp)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_value is 'dosageInstruction/timing/repeat/boundsDuration/value dosageInstruction/timing/repeat/boundsDuration/value (30 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_comparator is 'dosageInstruction/timing/repeat/boundsDuration/comparator dosageInstruction/timing/repeat/boundsDuration/comparator (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_unit is 'dosageInstruction/timing/repeat/boundsDuration/unit dosageInstruction/timing/repeat/boundsDuration/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_system is 'dosageInstruction/timing/repeat/boundsDuration/system dosageInstruction/timing/repeat/boundsDuration/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsduration_code is 'dosageInstruction/timing/repeat/boundsDuration/code dosageInstruction/timing/repeat/boundsDuration/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_value is 'dosageInstruction/timing/repeat/boundsRange/low/value dosageInstruction/timing/repeat/boundsRange/low/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_unit is 'dosageInstruction/timing/repeat/boundsRange/low/unit dosageInstruction/timing/repeat/boundsRange/low/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_system is 'dosageInstruction/timing/repeat/boundsRange/low/system dosageInstruction/timing/repeat/boundsRange/low/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_low_code is 'dosageInstruction/timing/repeat/boundsRange/low/code dosageInstruction/timing/repeat/boundsRange/low/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_value is 'dosageInstruction/timing/repeat/boundsRange/high/value dosageInstruction/timing/repeat/boundsRange/high/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_unit is 'dosageInstruction/timing/repeat/boundsRange/high/unit dosageInstruction/timing/repeat/boundsRange/high/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_system is 'dosageInstruction/timing/repeat/boundsRange/high/system dosageInstruction/timing/repeat/boundsRange/high/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsrange_high_code is 'dosageInstruction/timing/repeat/boundsRange/high/code dosageInstruction/timing/repeat/boundsRange/high/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsperiod_start is 'dosageInstruction/timing/repeat/boundsPeriod/start dosageInstruction/timing/repeat/boundsPeriod/start (30 timestamp)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_boundsperiod_end is 'dosageInstruction/timing/repeat/boundsPeriod/end dosageInstruction/timing/repeat/boundsPeriod/end (30 timestamp)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_count is 'dosageInstruction/timing/repeat/count dosageInstruction/timing/repeat/count (10 int)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_countmax is 'dosageInstruction/timing/repeat/countMax dosageInstruction/timing/repeat/countMax (10 int)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_duration is 'dosageInstruction/timing/repeat/duration dosageInstruction/timing/repeat/duration (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_durationmax is 'dosageInstruction/timing/repeat/durationMax dosageInstruction/timing/repeat/durationMax (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_durationunit is 'dosageInstruction/timing/repeat/durationUnit dosageInstruction/timing/repeat/durationUnit (20 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_frequency is 'dosageInstruction/timing/repeat/frequency dosageInstruction/timing/repeat/frequency (10 int)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_frequencymax is 'dosageInstruction/timing/repeat/frequencyMax dosageInstruction/timing/repeat/frequencyMax (10 int)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_period is 'dosageInstruction/timing/repeat/period dosageInstruction/timing/repeat/period (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_periodmax is 'dosageInstruction/timing/repeat/periodMax dosageInstruction/timing/repeat/periodMax (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_periodunit is 'dosageInstruction/timing/repeat/periodUnit dosageInstruction/timing/repeat/periodUnit (20 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_dayofweek is 'dosageInstruction/timing/repeat/dayOfWeek dosageInstruction/timing/repeat/dayOfWeek (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_timeofday is 'dosageInstruction/timing/repeat/timeOfDay dosageInstruction/timing/repeat/timeOfDay (20 time)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_when is 'dosageInstruction/timing/repeat/when dosageInstruction/timing/repeat/when (20 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_repeat_offset is 'dosageInstruction/timing/repeat/offset dosageInstruction/timing/repeat/offset (10 int)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_code_system is 'dosageInstruction/timing/code/coding/system dosageInstruction/timing/code/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_code_version is 'dosageInstruction/timing/code/coding/version dosageInstruction/timing/code/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_code_code is 'dosageInstruction/timing/code/coding/code dosageInstruction/timing/code/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_code_display is 'dosageInstruction/timing/code/coding/display dosageInstruction/timing/code/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_timing_code_text is 'dosageInstruction/timing/code/text dosageInstruction/timing/code/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_asneededboolean is 'dosageInstruction/asNeededBoolean dosageInstruction/asNeededBoolean (10 boolean)';
comment on column db_log.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_system is 'dosageInstruction/asNeededCodeableConcept/coding/system dosageInstruction/asNeededCodeableConcept/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_version is 'dosageInstruction/asNeededCodeableConcept/coding/version dosageInstruction/asNeededCodeableConcept/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_code is 'dosageInstruction/asNeededCodeableConcept/coding/code dosageInstruction/asNeededCodeableConcept/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_display is 'dosageInstruction/asNeededCodeableConcept/coding/display dosageInstruction/asNeededCodeableConcept/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_asneededcodeableconcept_text is 'dosageInstruction/asNeededCodeableConcept/text dosageInstruction/asNeededCodeableConcept/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_site_system is 'dosageInstruction/site/coding/system dosageInstruction/site/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_site_version is 'dosageInstruction/site/coding/version dosageInstruction/site/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_site_code is 'dosageInstruction/site/coding/code dosageInstruction/site/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_site_display is 'dosageInstruction/site/coding/display dosageInstruction/site/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_site_text is 'dosageInstruction/site/text dosageInstruction/site/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_route_system is 'dosageInstruction/route/coding/system dosageInstruction/route/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_route_version is 'dosageInstruction/route/coding/version dosageInstruction/route/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_route_code is 'dosageInstruction/route/coding/code dosageInstruction/route/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_route_display is 'dosageInstruction/route/coding/display dosageInstruction/route/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_route_text is 'dosageInstruction/route/text dosageInstruction/route/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_method_system is 'dosageInstruction/method/coding/system dosageInstruction/method/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_method_version is 'dosageInstruction/method/coding/version dosageInstruction/method/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_method_code is 'dosageInstruction/method/coding/code dosageInstruction/method/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_method_display is 'dosageInstruction/method/coding/display dosageInstruction/method/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_method_text is 'dosageInstruction/method/text dosageInstruction/method/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_type_system is 'dosageInstruction/doseAndRate/type/coding/system dosageInstruction/doseAndRate/type/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_type_version is 'dosageInstruction/doseAndRate/type/coding/version dosageInstruction/doseAndRate/type/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_type_code is 'dosageInstruction/doseAndRate/type/coding/code dosageInstruction/doseAndRate/type/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_type_display is 'dosageInstruction/doseAndRate/type/coding/display dosageInstruction/doseAndRate/type/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_type_text is 'dosageInstruction/doseAndRate/type/text dosageInstruction/doseAndRate/type/text (500 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_value is 'dosageInstruction/doseAndRate/doseRange/low/value dosageInstruction/doseAndRate/doseRange/low/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_unit is 'dosageInstruction/doseAndRate/doseRange/low/unit dosageInstruction/doseAndRate/doseRange/low/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_system is 'dosageInstruction/doseAndRate/doseRange/low/system dosageInstruction/doseAndRate/doseRange/low/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_low_code is 'dosageInstruction/doseAndRate/doseRange/low/code dosageInstruction/doseAndRate/doseRange/low/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_value is 'dosageInstruction/doseAndRate/doseRange/high/value dosageInstruction/doseAndRate/doseRange/high/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_unit is 'dosageInstruction/doseAndRate/doseRange/high/unit dosageInstruction/doseAndRate/doseRange/high/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_system is 'dosageInstruction/doseAndRate/doseRange/high/system dosageInstruction/doseAndRate/doseRange/high/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_doserange_high_code is 'dosageInstruction/doseAndRate/doseRange/high/code dosageInstruction/doseAndRate/doseRange/high/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_value is 'dosageInstruction/doseAndRate/doseQuantity/value dosageInstruction/doseAndRate/doseQuantity/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_comparator is 'dosageInstruction/doseAndRate/doseQuantity/comparator dosageInstruction/doseAndRate/doseQuantity/comparator (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_unit is 'dosageInstruction/doseAndRate/doseQuantity/unit dosageInstruction/doseAndRate/doseQuantity/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_system is 'dosageInstruction/doseAndRate/doseQuantity/system dosageInstruction/doseAndRate/doseQuantity/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_dosequantity_code is 'dosageInstruction/doseAndRate/doseQuantity/code dosageInstruction/doseAndRate/doseQuantity/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_value is 'dosageInstruction/doseAndRate/rateRatio/numerator/value dosageInstruction/doseAndRate/rateRatio/numerator/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator is 'dosageInstruction/doseAndRate/rateRatio/numerator/comparator dosageInstruction/doseAndRate/rateRatio/numerator/comparator (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_unit is 'dosageInstruction/doseAndRate/rateRatio/numerator/unit dosageInstruction/doseAndRate/rateRatio/numerator/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_system is 'dosageInstruction/doseAndRate/rateRatio/numerator/system dosageInstruction/doseAndRate/rateRatio/numerator/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_numerator_code is 'dosageInstruction/doseAndRate/rateRatio/numerator/code dosageInstruction/doseAndRate/rateRatio/numerator/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_value is 'dosageInstruction/doseAndRate/rateRatio/denominator/value dosageInstruction/doseAndRate/rateRatio/denominator/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator is 'dosageInstruction/doseAndRate/rateRatio/denominator/comparator dosageInstruction/doseAndRate/rateRatio/denominator/comparator (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_unit is 'dosageInstruction/doseAndRate/rateRatio/denominator/unit dosageInstruction/doseAndRate/rateRatio/denominator/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_system is 'dosageInstruction/doseAndRate/rateRatio/denominator/system dosageInstruction/doseAndRate/rateRatio/denominator/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_rateratio_denominator_code is 'dosageInstruction/doseAndRate/rateRatio/denominator/code dosageInstruction/doseAndRate/rateRatio/denominator/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_value is 'dosageInstruction/doseAndRate/rateRange/low/value dosageInstruction/doseAndRate/rateRange/low/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_unit is 'dosageInstruction/doseAndRate/rateRange/low/unit dosageInstruction/doseAndRate/rateRange/low/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_system is 'dosageInstruction/doseAndRate/rateRange/low/system dosageInstruction/doseAndRate/rateRange/low/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_low_code is 'dosageInstruction/doseAndRate/rateRange/low/code dosageInstruction/doseAndRate/rateRange/low/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_value is 'dosageInstruction/doseAndRate/rateRange/high/value dosageInstruction/doseAndRate/rateRange/high/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_unit is 'dosageInstruction/doseAndRate/rateRange/high/unit dosageInstruction/doseAndRate/rateRange/high/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_system is 'dosageInstruction/doseAndRate/rateRange/high/system dosageInstruction/doseAndRate/rateRange/high/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_raterange_high_code is 'dosageInstruction/doseAndRate/rateRange/high/code dosageInstruction/doseAndRate/rateRange/high/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_value is 'dosageInstruction/doseAndRate/rateQuantity/value dosageInstruction/doseAndRate/rateQuantity/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_unit is 'dosageInstruction/doseAndRate/rateQuantity/unit dosageInstruction/doseAndRate/rateQuantity/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_system is 'dosageInstruction/doseAndRate/rateQuantity/system dosageInstruction/doseAndRate/rateQuantity/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_doseandrate_ratequantity_code is 'dosageInstruction/doseAndRate/rateQuantity/code dosageInstruction/doseAndRate/rateQuantity/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_value is 'dosageInstruction/maxDosePerPeriod/numerator/value dosageInstruction/maxDosePerPeriod/numerator/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_comparator is 'dosageInstruction/maxDosePerPeriod/numerator/comparator dosageInstruction/maxDosePerPeriod/numerator/comparator (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_unit is 'dosageInstruction/maxDosePerPeriod/numerator/unit dosageInstruction/maxDosePerPeriod/numerator/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_system is 'dosageInstruction/maxDosePerPeriod/numerator/system dosageInstruction/maxDosePerPeriod/numerator/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_numerator_code is 'dosageInstruction/maxDosePerPeriod/numerator/code dosageInstruction/maxDosePerPeriod/numerator/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_value is 'dosageInstruction/maxDosePerPeriod/denominator/value dosageInstruction/maxDosePerPeriod/denominator/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_comparator is 'dosageInstruction/maxDosePerPeriod/denominator/comparator dosageInstruction/maxDosePerPeriod/denominator/comparator (10 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_unit is 'dosageInstruction/maxDosePerPeriod/denominator/unit dosageInstruction/maxDosePerPeriod/denominator/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_system is 'dosageInstruction/maxDosePerPeriod/denominator/system dosageInstruction/maxDosePerPeriod/denominator/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperperiod_denominator_code is 'dosageInstruction/maxDosePerPeriod/denominator/code dosageInstruction/maxDosePerPeriod/denominator/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperadministration_value is 'dosageInstruction/maxDosePerAdministration/value dosageInstruction/maxDosePerAdministration/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperadministration_unit is 'dosageInstruction/maxDosePerAdministration/unit dosageInstruction/maxDosePerAdministration/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperadministration_system is 'dosageInstruction/maxDosePerAdministration/system dosageInstruction/maxDosePerAdministration/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperadministration_code is 'dosageInstruction/maxDosePerAdministration/code dosageInstruction/maxDosePerAdministration/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_value is 'dosageInstruction/maxDosePerLifetime/value dosageInstruction/maxDosePerLifetime/value (10 numeric)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_unit is 'dosageInstruction/maxDosePerLifetime/unit dosageInstruction/maxDosePerLifetime/unit (30 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_system is 'dosageInstruction/maxDosePerLifetime/system dosageInstruction/maxDosePerLifetime/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_doseinstruc_maxdoseperlifetime_code is 'dosageInstruction/maxDosePerLifetime/code dosageInstruction/maxDosePerLifetime/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_substitution_reason_system is 'substitution/reason/coding/system substitution/reason/coding/system (70 varchar)';
comment on column db_log.medicationrequest.medreq_substitution_reason_version is 'substitution/reason/coding/version substitution/reason/coding/version (50 varchar)';
comment on column db_log.medicationrequest.medreq_substitution_reason_code is 'substitution/reason/coding/code substitution/reason/coding/code (30 varchar)';
comment on column db_log.medicationrequest.medreq_substitution_reason_display is 'substitution/reason/coding/display substitution/reason/coding/display (100 varchar)';
comment on column db_log.medicationrequest.medreq_substitution_reason_text is 'substitution/reason/text substitution/reason/text (500 varchar)';

comment on column db_log.medicationadministration.medadm_id is 'id id (70 varchar)';
comment on column db_log.medicationadministration.medadm_encounter_id is 'context/reference context/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_partof_id is 'partOf/reference partOf/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.medicationadministration.medadm_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.medicationadministration.medadm_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.medicationadministration.medadm_status is 'status status (30 varchar)';
comment on column db_log.medicationadministration.medadm_statusreason_system is 'statusReason/coding/system statusReason/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_statusreason_version is 'statusReason/coding/version statusReason/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_statusreason_code is 'statusReason/coding/code statusReason/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_statusreason_display is 'statusReason/coding/display statusReason/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_statusreason_text is 'statusReason/text statusReason/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_medicationreference_id is 'medicationReference/reference medicationReference/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system medicationCodeableConcept/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version medicationCodeableConcept/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code medicationCodeableConcept/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display medicationCodeableConcept/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_medicationcodeableconcept_text is 'medicationCodeableConcept/text medicationCodeableConcept/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_id is 'supportingInformation/reference supportingInformation/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_type is 'supportingInformation/type supportingInformation/type (30 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_identifier_use is 'supportingInformation/identifier/use supportingInformation/identifier/use (30 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_identifier_type_system is 'supportingInformation/identifier/type/coding/system supportingInformation/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_identifier_type_version is 'supportingInformation/identifier/type/coding/version supportingInformation/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_identifier_type_code is 'supportingInformation/identifier/type/coding/code supportingInformation/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_identifier_type_display is 'supportingInformation/identifier/type/coding/display supportingInformation/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_identifier_type_text is 'supportingInformation/identifier/type/text supportingInformation/identifier/type/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_supportinginformation_display is 'supportingInformation/display supportingInformation/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_effectivedatetime is 'effectiveDateTime effectiveDateTime (30 timestamp)';
comment on column db_log.medicationadministration.medadm_effectiveperiod_start is 'effectivePeriod/start effectivePeriod/start (30 timestamp)';
comment on column db_log.medicationadministration.medadm_effectiveperiod_end is 'effectivePeriod/end effectivePeriod/end (30 timestamp)';
comment on column db_log.medicationadministration.medadm_performer_function_system is 'performer/function/coding/system performer/function/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_performer_function_version is 'performer/function/coding/version performer/function/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_performer_function_code is 'performer/function/coding/code performer/function/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_performer_function_display is 'performer/function/coding/display performer/function/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_performer_function_text is 'performer/function/text performer/function/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_reasoncode_system is 'reasonCode/coding/system reasonCode/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_reasoncode_version is 'reasonCode/coding/version reasonCode/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_reasoncode_code is 'reasonCode/coding/code reasonCode/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_reasoncode_display is 'reasonCode/coding/display reasonCode/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_reasoncode_text is 'reasonCode/text reasonCode/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_id is 'reasonReference/reference reasonReference/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_type is 'reasonReference/type reasonReference/type (30 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_identifier_use is 'reasonReference/identifier/use reasonReference/identifier/use (30 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system reasonReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version reasonReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code reasonReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display reasonReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text reasonReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_reasonreference_display is 'reasonReference/display reasonReference/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_request_id is 'request/reference request/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorstring is 'note/authorString note/authorString (50 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_id is 'note/authorReference/reference note/authorReference/reference (70 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_type is 'note/authorReference/type note/authorReference/type (30 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_identifier_use is 'note/authorReference/identifier/use note/authorReference/identifier/use (30 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system note/authorReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version note/authorReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code note/authorReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display note/authorReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text note/authorReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_note_authorreference_display is 'note/authorReference/display note/authorReference/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_note_time is 'note/time note/time (30 timestamp)';
comment on column db_log.medicationadministration.medadm_note_text is 'note/text note/text (5000 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_text is 'dosage/text dosage/text (100 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_site_system is 'dosage/site/coding/system dosage/site/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_site_version is 'dosage/site/coding/version dosage/site/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_site_code is 'dosage/site/coding/code dosage/site/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_site_display is 'dosage/site/coding/display dosage/site/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_site_text is 'dosage/site/text dosage/site/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_route_system is 'dosage/route/coding/system dosage/route/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_route_version is 'dosage/route/coding/version dosage/route/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_route_code is 'dosage/route/coding/code dosage/route/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_route_display is 'dosage/route/coding/display dosage/route/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_route_text is 'dosage/route/text dosage/route/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_method_system is 'dosage/method/coding/system dosage/method/coding/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_method_version is 'dosage/method/coding/version dosage/method/coding/version (50 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_method_code is 'dosage/method/coding/code dosage/method/coding/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_method_display is 'dosage/method/coding/display dosage/method/coding/display (100 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_method_text is 'dosage/method/text dosage/method/text (500 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_dose_value is 'dosage/dose/value dosage/dose/value (10 numeric)';
comment on column db_log.medicationadministration.medadm_dosage_dose_unit is 'dosage/dose/unit dosage/dose/unit (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_dose_system is 'dosage/dose/system dosage/dose/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_dose_code is 'dosage/dose/code dosage/dose/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_numerator_value is 'dosage/rateRatio/numerator/value dosage/rateRatio/numerator/value (10 numeric)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_numerator_comparator is 'dosage/rateRatio/numerator/comparator dosage/rateRatio/numerator/comparator (10 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_numerator_unit is 'dosage/rateRatio/numerator/unit dosage/rateRatio/numerator/unit (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_numerator_system is 'dosage/rateRatio/numerator/system dosage/rateRatio/numerator/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_numerator_code is 'dosage/rateRatio/numerator/code dosage/rateRatio/numerator/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_denominator_value is 'dosage/rateRatio/denominator/value dosage/rateRatio/denominator/value (10 numeric)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_denominator_comparator is 'dosage/rateRatio/denominator/comparator dosage/rateRatio/denominator/comparator (10 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_denominator_unit is 'dosage/rateRatio/denominator/unit dosage/rateRatio/denominator/unit (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_denominator_system is 'dosage/rateRatio/denominator/system dosage/rateRatio/denominator/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_rateratio_denominator_code is 'dosage/rateRatio/denominator/code dosage/rateRatio/denominator/code (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_ratequantity_value is 'dosage/rateQuantity/value dosage/rateQuantity/value (10 numeric)';
comment on column db_log.medicationadministration.medadm_dosage_ratequantity_unit is 'dosage/rateQuantity/unit dosage/rateQuantity/unit (30 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_ratequantity_system is 'dosage/rateQuantity/system dosage/rateQuantity/system (70 varchar)';
comment on column db_log.medicationadministration.medadm_dosage_ratequantity_code is 'dosage/rateQuantity/code dosage/rateQuantity/code (30 varchar)';

comment on column db_log.medicationstatement.medstat_id is 'id id (70 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.medicationstatement.medstat_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.medicationstatement.medstat_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.medicationstatement.medstat_encounter_id is 'context/reference context/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_partof_id is 'partOf/reference partOf/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_id is 'basedOn/reference basedOn/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_type is 'basedOn/type basedOn/type (30 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_identifier_use is 'basedOn/identifier/use basedOn/identifier/use (30 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system basedOn/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version basedOn/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code basedOn/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display basedOn/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_identifier_type_text is 'basedOn/identifier/type/text basedOn/identifier/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_basedon_display is 'basedOn/display basedOn/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_status is 'status status (30 varchar)';
comment on column db_log.medicationstatement.medstat_statusreason_system is 'statusReason/coding/system statusReason/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_statusreason_version is 'statusReason/coding/version statusReason/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_statusreason_code is 'statusReason/coding/code statusReason/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_statusreason_display is 'statusReason/coding/display statusReason/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_statusreason_text is 'statusReason/text statusReason/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_medicationreference_id is 'medicationReference/reference medicationReference/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system medicationCodeableConcept/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version medicationCodeableConcept/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code medicationCodeableConcept/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display medicationCodeableConcept/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_medicationcodeableconcept_text is 'medicationCodeableConcept/text medicationCodeableConcept/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_effectivedatetime is 'effectiveDateTime effectiveDateTime (30 timestamp)';
comment on column db_log.medicationstatement.medstat_effectiveperiod_start is 'effectivePeriod/start effectivePeriod/start (30 timestamp)';
comment on column db_log.medicationstatement.medstat_effectiveperiod_end is 'effectivePeriod/end effectivePeriod/end (30 timestamp)';
comment on column db_log.medicationstatement.medstat_dateasserted is 'dateAsserted dateAsserted (30 timestamp)';
comment on column db_log.medicationstatement.medstat_informationsource_id is 'informationSource/reference informationSource/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_type is 'informationSource/type informationSource/type (30 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_identifier_use is 'informationSource/identifier/use informationSource/identifier/use (30 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_identifier_type_system is 'informationSource/identifier/type/coding/system informationSource/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_identifier_type_version is 'informationSource/identifier/type/coding/version informationSource/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_identifier_type_code is 'informationSource/identifier/type/coding/code informationSource/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_identifier_type_display is 'informationSource/identifier/type/coding/display informationSource/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_identifier_type_text is 'informationSource/identifier/type/text informationSource/identifier/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_informationsource_display is 'informationSource/display informationSource/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_id is 'derivedFrom/reference derivedFrom/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_type is 'derivedFrom/type derivedFrom/type (30 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_identifier_use is 'derivedFrom/identifier/use derivedFrom/identifier/use (30 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_identifier_type_system is 'derivedFrom/identifier/type/coding/system derivedFrom/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_identifier_type_version is 'derivedFrom/identifier/type/coding/version derivedFrom/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_identifier_type_code is 'derivedFrom/identifier/type/coding/code derivedFrom/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_identifier_type_display is 'derivedFrom/identifier/type/coding/display derivedFrom/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_identifier_type_text is 'derivedFrom/identifier/type/text derivedFrom/identifier/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_derivedfrom_display is 'derivedFrom/display derivedFrom/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_reasoncode_system is 'reasonCode/coding/system reasonCode/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_reasoncode_version is 'reasonCode/coding/version reasonCode/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_reasoncode_code is 'reasonCode/coding/code reasonCode/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_reasoncode_display is 'reasonCode/coding/display reasonCode/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_reasoncode_text is 'reasonCode/text reasonCode/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_id is 'reasonReference/reference reasonReference/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_type is 'reasonReference/type reasonReference/type (30 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_identifier_use is 'reasonReference/identifier/use reasonReference/identifier/use (30 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system reasonReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version reasonReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code reasonReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display reasonReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text reasonReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_reasonreference_display is 'reasonReference/display reasonReference/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorstring is 'note/authorString note/authorString (50 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_id is 'note/authorReference/reference note/authorReference/reference (70 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_type is 'note/authorReference/type note/authorReference/type (30 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_identifier_use is 'note/authorReference/identifier/use note/authorReference/identifier/use (30 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system note/authorReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version note/authorReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code note/authorReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display note/authorReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text note/authorReference/identifier/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_note_authorreference_display is 'note/authorReference/display note/authorReference/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_note_time is 'note/time note/time (30 timestamp)';
comment on column db_log.medicationstatement.medstat_note_text is 'note/text note/text (5000 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_sequence is 'dosage/sequence dosage/sequence (10 int)';
comment on column db_log.medicationstatement.medstat_dosage_text is 'dosage/text dosage/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_additionalinstruction_system is 'dosage/additionalInstruction/coding/system dosage/additionalInstruction/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_additionalinstruction_version is 'dosage/additionalInstruction/coding/version dosage/additionalInstruction/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_additionalinstruction_code is 'dosage/additionalInstruction/coding/code dosage/additionalInstruction/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_additionalinstruction_display is 'dosage/additionalInstruction/coding/display dosage/additionalInstruction/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_additionalinstruction_text is 'dosage/additionalInstruction/text dosage/additionalInstruction/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_patientinstruction is 'dosage/patientInstruction dosage/patientInstruction (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_event is 'dosage/timing/event dosage/timing/event (30 timestamp)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsduration_value is 'dosage/timing/repeat/boundsDuration/value dosage/timing/repeat/boundsDuration/value (30 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsduration_comparator is 'dosage/timing/repeat/boundsDuration/comparator dosage/timing/repeat/boundsDuration/comparator (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsduration_unit is 'dosage/timing/repeat/boundsDuration/unit dosage/timing/repeat/boundsDuration/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsduration_system is 'dosage/timing/repeat/boundsDuration/system dosage/timing/repeat/boundsDuration/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsduration_code is 'dosage/timing/repeat/boundsDuration/code dosage/timing/repeat/boundsDuration/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_value is 'dosage/timing/repeat/boundsRange/low/value dosage/timing/repeat/boundsRange/low/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_unit is 'dosage/timing/repeat/boundsRange/low/unit dosage/timing/repeat/boundsRange/low/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_system is 'dosage/timing/repeat/boundsRange/low/system dosage/timing/repeat/boundsRange/low/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_low_code is 'dosage/timing/repeat/boundsRange/low/code dosage/timing/repeat/boundsRange/low/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_value is 'dosage/timing/repeat/boundsRange/high/value dosage/timing/repeat/boundsRange/high/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_unit is 'dosage/timing/repeat/boundsRange/high/unit dosage/timing/repeat/boundsRange/high/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_system is 'dosage/timing/repeat/boundsRange/high/system dosage/timing/repeat/boundsRange/high/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsrange_high_code is 'dosage/timing/repeat/boundsRange/high/code dosage/timing/repeat/boundsRange/high/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsperiod_start is 'dosage/timing/repeat/boundsPeriod/start dosage/timing/repeat/boundsPeriod/start (30 timestamp)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_boundsperiod_end is 'dosage/timing/repeat/boundsPeriod/end dosage/timing/repeat/boundsPeriod/end (30 timestamp)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_count is 'dosage/timing/repeat/count dosage/timing/repeat/count (10 int)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_countmax is 'dosage/timing/repeat/countMax dosage/timing/repeat/countMax (10 int)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_duration is 'dosage/timing/repeat/duration dosage/timing/repeat/duration (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_durationmax is 'dosage/timing/repeat/durationMax dosage/timing/repeat/durationMax (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_durationunit is 'dosage/timing/repeat/durationUnit dosage/timing/repeat/durationUnit (20 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_frequency is 'dosage/timing/repeat/frequency dosage/timing/repeat/frequency (10 int)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_frequencymax is 'dosage/timing/repeat/frequencyMax dosage/timing/repeat/frequencyMax (10 int)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_period is 'dosage/timing/repeat/period dosage/timing/repeat/period (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_periodmax is 'dosage/timing/repeat/periodMax dosage/timing/repeat/periodMax (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_periodunit is 'dosage/timing/repeat/periodUnit dosage/timing/repeat/periodUnit (20 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_dayofweek is 'dosage/timing/repeat/dayOfWeek dosage/timing/repeat/dayOfWeek (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_timeofday is 'dosage/timing/repeat/timeOfDay dosage/timing/repeat/timeOfDay (20 time)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_when is 'dosage/timing/repeat/when dosage/timing/repeat/when (20 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_repeat_offset is 'dosage/timing/repeat/offset dosage/timing/repeat/offset (10 int)';
comment on column db_log.medicationstatement.medstat_dosage_timing_code_system is 'dosage/timing/code/coding/system dosage/timing/code/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_code_version is 'dosage/timing/code/coding/version dosage/timing/code/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_code_code is 'dosage/timing/code/coding/code dosage/timing/code/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_code_display is 'dosage/timing/code/coding/display dosage/timing/code/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_timing_code_text is 'dosage/timing/code/text dosage/timing/code/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_asneededboolean is 'dosage/asNeededBoolean dosage/asNeededBoolean (10 boolean)';
comment on column db_log.medicationstatement.medstat_dosage_asneededcodeableconcept_system is 'dosage/asNeededCodeableConcept/coding/system dosage/asNeededCodeableConcept/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_asneededcodeableconcept_version is 'dosage/asNeededCodeableConcept/coding/version dosage/asNeededCodeableConcept/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_asneededcodeableconcept_code is 'dosage/asNeededCodeableConcept/coding/code dosage/asNeededCodeableConcept/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_asneededcodeableconcept_display is 'dosage/asNeededCodeableConcept/coding/display dosage/asNeededCodeableConcept/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_asneededcodeableconcept_text is 'dosage/asNeededCodeableConcept/text dosage/asNeededCodeableConcept/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_site_system is 'dosage/site/coding/system dosage/site/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_site_version is 'dosage/site/coding/version dosage/site/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_site_code is 'dosage/site/coding/code dosage/site/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_site_display is 'dosage/site/coding/display dosage/site/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_site_text is 'dosage/site/text dosage/site/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_route_system is 'dosage/route/coding/system dosage/route/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_route_version is 'dosage/route/coding/version dosage/route/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_route_code is 'dosage/route/coding/code dosage/route/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_route_display is 'dosage/route/coding/display dosage/route/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_route_text is 'dosage/route/text dosage/route/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_method_system is 'dosage/method/coding/system dosage/method/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_method_version is 'dosage/method/coding/version dosage/method/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_method_code is 'dosage/method/coding/code dosage/method/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_method_display is 'dosage/method/coding/display dosage/method/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_method_text is 'dosage/method/text dosage/method/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_type_system is 'dosage/doseAndRate/type/coding/system dosage/doseAndRate/type/coding/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_type_version is 'dosage/doseAndRate/type/coding/version dosage/doseAndRate/type/coding/version (50 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_type_code is 'dosage/doseAndRate/type/coding/code dosage/doseAndRate/type/coding/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_type_display is 'dosage/doseAndRate/type/coding/display dosage/doseAndRate/type/coding/display (100 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_type_text is 'dosage/doseAndRate/type/text dosage/doseAndRate/type/text (500 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_low_value is 'dosage/doseAndRate/doseRange/low/value dosage/doseAndRate/doseRange/low/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_low_unit is 'dosage/doseAndRate/doseRange/low/unit dosage/doseAndRate/doseRange/low/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_low_system is 'dosage/doseAndRate/doseRange/low/system dosage/doseAndRate/doseRange/low/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_low_code is 'dosage/doseAndRate/doseRange/low/code dosage/doseAndRate/doseRange/low/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_high_value is 'dosage/doseAndRate/doseRange/high/value dosage/doseAndRate/doseRange/high/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_high_unit is 'dosage/doseAndRate/doseRange/high/unit dosage/doseAndRate/doseRange/high/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_high_system is 'dosage/doseAndRate/doseRange/high/system dosage/doseAndRate/doseRange/high/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_doserange_high_code is 'dosage/doseAndRate/doseRange/high/code dosage/doseAndRate/doseRange/high/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_dosequantity_value is 'dosage/doseAndRate/doseQuantity/value dosage/doseAndRate/doseQuantity/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_dosequantity_comparator is 'dosage/doseAndRate/doseQuantity/comparator dosage/doseAndRate/doseQuantity/comparator (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_dosequantity_unit is 'dosage/doseAndRate/doseQuantity/unit dosage/doseAndRate/doseQuantity/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_dosequantity_system is 'dosage/doseAndRate/doseQuantity/system dosage/doseAndRate/doseQuantity/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_dosequantity_code is 'dosage/doseAndRate/doseQuantity/code dosage/doseAndRate/doseQuantity/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_value is 'dosage/doseAndRate/rateRatio/numerator/value dosage/doseAndRate/rateRatio/numerator/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_comparator is 'dosage/doseAndRate/rateRatio/numerator/comparator dosage/doseAndRate/rateRatio/numerator/comparator (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_unit is 'dosage/doseAndRate/rateRatio/numerator/unit dosage/doseAndRate/rateRatio/numerator/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_system is 'dosage/doseAndRate/rateRatio/numerator/system dosage/doseAndRate/rateRatio/numerator/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_numerator_code is 'dosage/doseAndRate/rateRatio/numerator/code dosage/doseAndRate/rateRatio/numerator/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_value is 'dosage/doseAndRate/rateRatio/denominator/value dosage/doseAndRate/rateRatio/denominator/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_comparator is 'dosage/doseAndRate/rateRatio/denominator/comparator dosage/doseAndRate/rateRatio/denominator/comparator (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_unit is 'dosage/doseAndRate/rateRatio/denominator/unit dosage/doseAndRate/rateRatio/denominator/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_system is 'dosage/doseAndRate/rateRatio/denominator/system dosage/doseAndRate/rateRatio/denominator/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_rateratio_denominator_code is 'dosage/doseAndRate/rateRatio/denominator/code dosage/doseAndRate/rateRatio/denominator/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_low_value is 'dosage/doseAndRate/rateRange/low/value dosage/doseAndRate/rateRange/low/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_low_unit is 'dosage/doseAndRate/rateRange/low/unit dosage/doseAndRate/rateRange/low/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_low_system is 'dosage/doseAndRate/rateRange/low/system dosage/doseAndRate/rateRange/low/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_low_code is 'dosage/doseAndRate/rateRange/low/code dosage/doseAndRate/rateRange/low/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_high_value is 'dosage/doseAndRate/rateRange/high/value dosage/doseAndRate/rateRange/high/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_high_unit is 'dosage/doseAndRate/rateRange/high/unit dosage/doseAndRate/rateRange/high/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_high_system is 'dosage/doseAndRate/rateRange/high/system dosage/doseAndRate/rateRange/high/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_raterange_high_code is 'dosage/doseAndRate/rateRange/high/code dosage/doseAndRate/rateRange/high/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_ratequantity_value is 'dosage/doseAndRate/rateQuantity/value dosage/doseAndRate/rateQuantity/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_ratequantity_unit is 'dosage/doseAndRate/rateQuantity/unit dosage/doseAndRate/rateQuantity/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_ratequantity_system is 'dosage/doseAndRate/rateQuantity/system dosage/doseAndRate/rateQuantity/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_doseandrate_ratequantity_code is 'dosage/doseAndRate/rateQuantity/code dosage/doseAndRate/rateQuantity/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_value is 'dosage/maxDosePerPeriod/numerator/value dosage/maxDosePerPeriod/numerator/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_comparator is 'dosage/maxDosePerPeriod/numerator/comparator dosage/maxDosePerPeriod/numerator/comparator (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_unit is 'dosage/maxDosePerPeriod/numerator/unit dosage/maxDosePerPeriod/numerator/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_system is 'dosage/maxDosePerPeriod/numerator/system dosage/maxDosePerPeriod/numerator/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_numerator_code is 'dosage/maxDosePerPeriod/numerator/code dosage/maxDosePerPeriod/numerator/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_value is 'dosage/maxDosePerPeriod/denominator/value dosage/maxDosePerPeriod/denominator/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_comparator is 'dosage/maxDosePerPeriod/denominator/comparator dosage/maxDosePerPeriod/denominator/comparator (10 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_unit is 'dosage/maxDosePerPeriod/denominator/unit dosage/maxDosePerPeriod/denominator/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_system is 'dosage/maxDosePerPeriod/denominator/system dosage/maxDosePerPeriod/denominator/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperperiod_denominator_code is 'dosage/maxDosePerPeriod/denominator/code dosage/maxDosePerPeriod/denominator/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperadministration_value is 'dosage/maxDosePerAdministration/value dosage/maxDosePerAdministration/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperadministration_unit is 'dosage/maxDosePerAdministration/unit dosage/maxDosePerAdministration/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperadministration_system is 'dosage/maxDosePerAdministration/system dosage/maxDosePerAdministration/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperadministration_code is 'dosage/maxDosePerAdministration/code dosage/maxDosePerAdministration/code (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperlifetime_value is 'dosage/maxDosePerLifetime/value dosage/maxDosePerLifetime/value (10 numeric)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperlifetime_unit is 'dosage/maxDosePerLifetime/unit dosage/maxDosePerLifetime/unit (30 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperlifetime_system is 'dosage/maxDosePerLifetime/system dosage/maxDosePerLifetime/system (70 varchar)';
comment on column db_log.medicationstatement.medstat_dosage_maxdoseperlifetime_code is 'dosage/maxDosePerLifetime/code dosage/maxDosePerLifetime/code (30 varchar)';

comment on column db_log.observation.obs_id is 'id id (70 varchar)';
comment on column db_log.observation.obs_encounter_id is 'encounter/reference encounter/reference (70 varchar)';
comment on column db_log.observation.obs_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.observation.obs_partof_id is 'partOf/reference partOf/reference (70 varchar)';
comment on column db_log.observation.obs_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.observation.obs_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.observation.obs_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.observation.obs_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.observation.obs_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.observation.obs_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.observation.obs_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.observation.obs_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.observation.obs_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.observation.obs_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.observation.obs_basedon_id is 'basedOn/reference basedOn/reference (70 varchar)';
comment on column db_log.observation.obs_basedon_type is 'basedOn/type basedOn/type (30 varchar)';
comment on column db_log.observation.obs_basedon_identifier_use is 'basedOn/identifier/use basedOn/identifier/use (30 varchar)';
comment on column db_log.observation.obs_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system basedOn/identifier/type/coding/system (70 varchar)';
comment on column db_log.observation.obs_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version basedOn/identifier/type/coding/version (50 varchar)';
comment on column db_log.observation.obs_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code basedOn/identifier/type/coding/code (30 varchar)';
comment on column db_log.observation.obs_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display basedOn/identifier/type/coding/display (100 varchar)';
comment on column db_log.observation.obs_basedon_identifier_type_text is 'basedOn/identifier/type/text basedOn/identifier/type/text (500 varchar)';
comment on column db_log.observation.obs_basedon_display is 'basedOn/display basedOn/display (100 varchar)';
comment on column db_log.observation.obs_status is 'status status (30 varchar)';
comment on column db_log.observation.obs_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.observation.obs_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.observation.obs_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.observation.obs_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.observation.obs_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.observation.obs_code_system is 'code/coding/system code/coding/system (70 varchar)';
comment on column db_log.observation.obs_code_version is 'code/coding/version code/coding/version (50 varchar)';
comment on column db_log.observation.obs_code_code is 'code/coding/code code/coding/code (30 varchar)';
comment on column db_log.observation.obs_code_display is 'code/coding/display code/coding/display (100 varchar)';
comment on column db_log.observation.obs_code_text is 'code/text code/text (500 varchar)';
comment on column db_log.observation.obs_effectivedatetime is 'effectiveDateTime effectiveDateTime (30 timestamp)';
comment on column db_log.observation.obs_issued is 'issued issued (30 timestamp)';
comment on column db_log.observation.obs_valuerange_low_value is 'valueRange/low/value valueRange/low/value (10 numeric)';
comment on column db_log.observation.obs_valuerange_low_unit is 'valueRange/low/unit valueRange/low/unit (30 varchar)';
comment on column db_log.observation.obs_valuerange_low_system is 'valueRange/low/system valueRange/low/system (70 varchar)';
comment on column db_log.observation.obs_valuerange_low_code is 'valueRange/low/code valueRange/low/code (30 varchar)';
comment on column db_log.observation.obs_valuerange_high_value is 'valueRange/high/value valueRange/high/value (10 numeric)';
comment on column db_log.observation.obs_valuerange_high_unit is 'valueRange/high/unit valueRange/high/unit (30 varchar)';
comment on column db_log.observation.obs_valuerange_high_system is 'valueRange/high/system valueRange/high/system (70 varchar)';
comment on column db_log.observation.obs_valuerange_high_code is 'valueRange/high/code valueRange/high/code (30 varchar)';
comment on column db_log.observation.obs_valueratio_numerator_value is 'valueRatio/numerator/value valueRatio/numerator/value (10 numeric)';
comment on column db_log.observation.obs_valueratio_numerator_comparator is 'valueRatio/numerator/comparator valueRatio/numerator/comparator (10 varchar)';
comment on column db_log.observation.obs_valueratio_numerator_unit is 'valueRatio/numerator/unit valueRatio/numerator/unit (30 varchar)';
comment on column db_log.observation.obs_valueratio_numerator_system is 'valueRatio/numerator/system valueRatio/numerator/system (70 varchar)';
comment on column db_log.observation.obs_valueratio_numerator_code is 'valueRatio/numerator/code valueRatio/numerator/code (30 varchar)';
comment on column db_log.observation.obs_valueratio_denominator_value is 'valueRatio/denominator/value valueRatio/denominator/value (10 numeric)';
comment on column db_log.observation.obs_valueratio_denominator_comparator is 'valueRatio/denominator/comparator valueRatio/denominator/comparator (10 varchar)';
comment on column db_log.observation.obs_valueratio_denominator_unit is 'valueRatio/denominator/unit valueRatio/denominator/unit (30 varchar)';
comment on column db_log.observation.obs_valueratio_denominator_system is 'valueRatio/denominator/system valueRatio/denominator/system (70 varchar)';
comment on column db_log.observation.obs_valueratio_denominator_code is 'valueRatio/denominator/code valueRatio/denominator/code (30 varchar)';
comment on column db_log.observation.obs_valuequantity_value is 'valueQuantity/value valueQuantity/value (10 numeric)';
comment on column db_log.observation.obs_valuequantity_comparator is 'valueQuantity/comparator valueQuantity/comparator (10 varchar)';
comment on column db_log.observation.obs_valuequantity_unit is 'valueQuantity/unit valueQuantity/unit (30 varchar)';
comment on column db_log.observation.obs_valuequantity_system is 'valueQuantity/system valueQuantity/system (70 varchar)';
comment on column db_log.observation.obs_valuequantity_code is 'valueQuantity/code valueQuantity/code (30 varchar)';
comment on column db_log.observation.obs_valuecodableconcept_system is 'valueCodableConcept/coding/system valueCodableConcept/coding/system (70 varchar)';
comment on column db_log.observation.obs_valuecodableconcept_version is 'valueCodableConcept/coding/version valueCodableConcept/coding/version (50 varchar)';
comment on column db_log.observation.obs_valuecodableconcept_code is 'valueCodableConcept/coding/code valueCodableConcept/coding/code (30 varchar)';
comment on column db_log.observation.obs_valuecodableconcept_display is 'valueCodableConcept/coding/display valueCodableConcept/coding/display (100 varchar)';
comment on column db_log.observation.obs_valuecodableconcept_text is 'valueCodableConcept/text valueCodableConcept/text (500 varchar)';
comment on column db_log.observation.obs_dataabsentreason_system is 'dataAbsentReason/coding/system dataAbsentReason/coding/system (70 varchar)';
comment on column db_log.observation.obs_dataabsentreason_version is 'dataAbsentReason/coding/version dataAbsentReason/coding/version (50 varchar)';
comment on column db_log.observation.obs_dataabsentreason_code is 'dataAbsentReason/coding/code dataAbsentReason/coding/code (30 varchar)';
comment on column db_log.observation.obs_dataabsentreason_display is 'dataAbsentReason/coding/display dataAbsentReason/coding/display (100 varchar)';
comment on column db_log.observation.obs_dataabsentreason_text is 'dataAbsentReason/text dataAbsentReason/text (500 varchar)';
comment on column db_log.observation.obs_note_authorstring is 'note/authorString note/authorString (50 varchar)';
comment on column db_log.observation.obs_note_authorreference_id is 'note/authorReference/reference note/authorReference/reference (70 varchar)';
comment on column db_log.observation.obs_note_authorreference_type is 'note/authorReference/type note/authorReference/type (30 varchar)';
comment on column db_log.observation.obs_note_authorreference_identifier_use is 'note/authorReference/identifier/use note/authorReference/identifier/use (30 varchar)';
comment on column db_log.observation.obs_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system note/authorReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.observation.obs_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version note/authorReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.observation.obs_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code note/authorReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.observation.obs_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display note/authorReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.observation.obs_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text note/authorReference/identifier/type/text (500 varchar)';
comment on column db_log.observation.obs_note_authorreference_display is 'note/authorReference/display note/authorReference/display (100 varchar)';
comment on column db_log.observation.obs_note_time is 'note/time note/time (30 timestamp)';
comment on column db_log.observation.obs_note_text is 'note/text note/text (5000 varchar)';
comment on column db_log.observation.obs_method_system is 'method/coding/system method/coding/system (70 varchar)';
comment on column db_log.observation.obs_method_version is 'method/coding/version method/coding/version (50 varchar)';
comment on column db_log.observation.obs_method_code is 'method/coding/code method/coding/code (30 varchar)';
comment on column db_log.observation.obs_method_display is 'method/coding/display method/coding/display (100 varchar)';
comment on column db_log.observation.obs_method_text is 'method/text method/text (500 varchar)';
comment on column db_log.observation.obs_performer_id is 'performer/reference performer/reference (70 varchar)';
comment on column db_log.observation.obs_performer_type is 'performer/type performer/type (30 varchar)';
comment on column db_log.observation.obs_performer_identifier_use is 'performer/identifier/use performer/identifier/use (30 varchar)';
comment on column db_log.observation.obs_performer_identifier_type_system is 'performer/identifier/type/coding/system performer/identifier/type/coding/system (70 varchar)';
comment on column db_log.observation.obs_performer_identifier_type_version is 'performer/identifier/type/coding/version performer/identifier/type/coding/version (50 varchar)';
comment on column db_log.observation.obs_performer_identifier_type_code is 'performer/identifier/type/coding/code performer/identifier/type/coding/code (30 varchar)';
comment on column db_log.observation.obs_performer_identifier_type_display is 'performer/identifier/type/coding/display performer/identifier/type/coding/display (100 varchar)';
comment on column db_log.observation.obs_performer_identifier_type_text is 'performer/identifier/type/text performer/identifier/type/text (500 varchar)';
comment on column db_log.observation.obs_performer_display is 'performer/display performer/display (100 varchar)';
comment on column db_log.observation.obs_referencerange_low_value is 'referenceRange/low/value referenceRange/low/value (10 numeric)';
comment on column db_log.observation.obs_referencerange_low_unit is 'referenceRange/low/unit referenceRange/low/unit (30 varchar)';
comment on column db_log.observation.obs_referencerange_low_system is 'referenceRange/low/system referenceRange/low/system (70 varchar)';
comment on column db_log.observation.obs_referencerange_low_code is 'referenceRange/low/code referenceRange/low/code (30 varchar)';
comment on column db_log.observation.obs_referencerange_high_value is 'referenceRange/high/value referenceRange/high/value (10 numeric)';
comment on column db_log.observation.obs_referencerange_high_unit is 'referenceRange/high/unit referenceRange/high/unit (30 varchar)';
comment on column db_log.observation.obs_referencerange_high_system is 'referenceRange/high/system referenceRange/high/system (70 varchar)';
comment on column db_log.observation.obs_referencerange_high_code is 'referenceRange/high/code referenceRange/high/code (30 varchar)';
comment on column db_log.observation.obs_referencerange_type_system is 'referenceRange/type/coding/system referenceRange/type/coding/system (70 varchar)';
comment on column db_log.observation.obs_referencerange_type_version is 'referenceRange/type/coding/version referenceRange/type/coding/version (50 varchar)';
comment on column db_log.observation.obs_referencerange_type_code is 'referenceRange/type/coding/code referenceRange/type/coding/code (30 varchar)';
comment on column db_log.observation.obs_referencerange_type_display is 'referenceRange/type/coding/display referenceRange/type/coding/display (100 varchar)';
comment on column db_log.observation.obs_referencerange_type_text is 'referenceRange/type/text referenceRange/type/text (500 varchar)';
comment on column db_log.observation.obs_referencerange_appliesto_system is 'referenceRange/appliesTo/coding/system referenceRange/appliesTo/coding/system (70 varchar)';
comment on column db_log.observation.obs_referencerange_appliesto_version is 'referenceRange/appliesTo/coding/version referenceRange/appliesTo/coding/version (50 varchar)';
comment on column db_log.observation.obs_referencerange_appliesto_code is 'referenceRange/appliesTo/coding/code referenceRange/appliesTo/coding/code (30 varchar)';
comment on column db_log.observation.obs_referencerange_appliesto_display is 'referenceRange/appliesTo/coding/display referenceRange/appliesTo/coding/display (100 varchar)';
comment on column db_log.observation.obs_referencerange_appliesto_text is 'referenceRange/appliesTo/text referenceRange/appliesTo/text (500 varchar)';
comment on column db_log.observation.obs_referencerange_age_low_value is 'referenceRange/age/low/value referenceRange/age/low/value (10 numeric)';
comment on column db_log.observation.obs_referencerange_age_low_unit is 'referenceRange/age/low/unit referenceRange/age/low/unit (30 varchar)';
comment on column db_log.observation.obs_referencerange_age_low_system is 'referenceRange/age/low/system referenceRange/age/low/system (70 varchar)';
comment on column db_log.observation.obs_referencerange_age_low_code is 'referenceRange/age/low/code referenceRange/age/low/code (30 varchar)';
comment on column db_log.observation.obs_referencerange_age_high_value is 'referenceRange/age/high/value referenceRange/age/high/value (10 numeric)';
comment on column db_log.observation.obs_referencerange_age_high_unit is 'referenceRange/age/high/unit referenceRange/age/high/unit (30 varchar)';
comment on column db_log.observation.obs_referencerange_age_high_system is 'referenceRange/age/high/system referenceRange/age/high/system (70 varchar)';
comment on column db_log.observation.obs_referencerange_age_high_code is 'referenceRange/age/high/code referenceRange/age/high/code (30 varchar)';
comment on column db_log.observation.obs_referencerange_text is 'referenceRange/text referenceRange/text (500 varchar)';
comment on column db_log.observation.obs_hasmember_id is 'hasMember/reference hasMember/reference (70 varchar)';
comment on column db_log.observation.obs_hasmember_type is 'hasMember/type hasMember/type (30 varchar)';
comment on column db_log.observation.obs_hasmember_identifier_use is 'hasMember/identifier/use hasMember/identifier/use (30 varchar)';
comment on column db_log.observation.obs_hasmember_identifier_type_system is 'hasMember/identifier/type/coding/system hasMember/identifier/type/coding/system (70 varchar)';
comment on column db_log.observation.obs_hasmember_identifier_type_version is 'hasMember/identifier/type/coding/version hasMember/identifier/type/coding/version (50 varchar)';
comment on column db_log.observation.obs_hasmember_identifier_type_code is 'hasMember/identifier/type/coding/code hasMember/identifier/type/coding/code (30 varchar)';
comment on column db_log.observation.obs_hasmember_identifier_type_display is 'hasMember/identifier/type/coding/display hasMember/identifier/type/coding/display (100 varchar)';
comment on column db_log.observation.obs_hasmember_identifier_type_text is 'hasMember/identifier/type/text hasMember/identifier/type/text (500 varchar)';
comment on column db_log.observation.obs_hasmember_display is 'hasMember/display hasMember/display (100 varchar)';

comment on column db_log.diagnosticreport.diagrep_id is 'id id (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_encounter_id is 'encounter/reference encounter/reference (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_partof_id is 'partOf/reference partOf/reference (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.diagnosticreport.diagrep_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.diagnosticreport.diagrep_result_id is 'result/reference result/reference (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_basedon_id is 'basedOn/reference basedOn/reference (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_status is 'status status (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.diagnosticreport.diagrep_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.diagnosticreport.diagrep_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.diagnosticreport.diagrep_code_system is 'code/coding/system code/coding/system (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_code_version is 'code/coding/version code/coding/version (50 varchar)';
comment on column db_log.diagnosticreport.diagrep_code_code is 'code/coding/code code/coding/code (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_code_display is 'code/coding/display code/coding/display (100 varchar)';
comment on column db_log.diagnosticreport.diagrep_code_text is 'code/text code/text (500 varchar)';
comment on column db_log.diagnosticreport.diagrep_effectivedatetime is 'effectiveDateTime effectiveDateTime (30 timestamp)';
comment on column db_log.diagnosticreport.diagrep_issued is 'issued issued (30 timestamp)';
comment on column db_log.diagnosticreport.diagrep_performer_id is 'performer/reference performer/reference (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_type is 'performer/type performer/type (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_identifier_use is 'performer/identifier/use performer/identifier/use (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_identifier_type_system is 'performer/identifier/type/coding/system performer/identifier/type/coding/system (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_identifier_type_version is 'performer/identifier/type/coding/version performer/identifier/type/coding/version (50 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_identifier_type_code is 'performer/identifier/type/coding/code performer/identifier/type/coding/code (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_identifier_type_display is 'performer/identifier/type/coding/display performer/identifier/type/coding/display (100 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_identifier_type_text is 'performer/identifier/type/text performer/identifier/type/text (500 varchar)';
comment on column db_log.diagnosticreport.diagrep_performer_display is 'performer/display performer/display (100 varchar)';
comment on column db_log.diagnosticreport.diagrep_conclusion is 'conclusion conclusion (500 varchar)';
comment on column db_log.diagnosticreport.diagrep_conclusioncode_system is 'conclusionCode/coding/system conclusionCode/coding/system (70 varchar)';
comment on column db_log.diagnosticreport.diagrep_conclusioncode_version is 'conclusionCode/coding/version conclusionCode/coding/version (50 varchar)';
comment on column db_log.diagnosticreport.diagrep_conclusioncode_code is 'conclusionCode/coding/code conclusionCode/coding/code (30 varchar)';
comment on column db_log.diagnosticreport.diagrep_conclusioncode_display is 'conclusionCode/coding/display conclusionCode/coding/display (100 varchar)';
comment on column db_log.diagnosticreport.diagrep_conclusioncode_text is 'conclusionCode/text conclusionCode/text (500 varchar)';

comment on column db_log.servicerequest.servreq_id is 'id id (70 varchar)';
comment on column db_log.servicerequest.servreq_encounter_id is 'encounter/reference encounter/reference (70 varchar)';
comment on column db_log.servicerequest.servreq_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.servicerequest.servreq_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.servicerequest.servreq_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.servicerequest.servreq_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.servicerequest.servreq_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.servicerequest.servreq_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.servicerequest.servreq_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.servicerequest.servreq_basedon_id is 'basedOn/reference basedOn/reference (70 varchar)';
comment on column db_log.servicerequest.servreq_basedon_type is 'basedOn/type basedOn/type (30 varchar)';
comment on column db_log.servicerequest.servreq_basedon_identifier_use is 'basedOn/identifier/use basedOn/identifier/use (30 varchar)';
comment on column db_log.servicerequest.servreq_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system basedOn/identifier/type/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version basedOn/identifier/type/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code basedOn/identifier/type/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display basedOn/identifier/type/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_basedon_identifier_type_text is 'basedOn/identifier/type/text basedOn/identifier/type/text (500 varchar)';
comment on column db_log.servicerequest.servreq_basedon_display is 'basedOn/display basedOn/display (100 varchar)';
comment on column db_log.servicerequest.servreq_status is 'status status (30 varchar)';
comment on column db_log.servicerequest.servreq_intent is 'intent intent (30 varchar)';
comment on column db_log.servicerequest.servreq_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.servicerequest.servreq_code_system is 'code/coding/system code/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_code_version is 'code/coding/version code/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_code_code is 'code/coding/code code/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_code_display is 'code/coding/display code/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_code_text is 'code/text code/text (500 varchar)';
comment on column db_log.servicerequest.servreq_authoredon is 'authoredOn authoredOn (30 timestamp)';
comment on column db_log.servicerequest.servreq_requester_id is 'requester/reference requester/reference (70 varchar)';
comment on column db_log.servicerequest.servreq_requester_type is 'requester/type requester/type (30 varchar)';
comment on column db_log.servicerequest.servreq_requester_identifier_use is 'requester/identifier/use requester/identifier/use (30 varchar)';
comment on column db_log.servicerequest.servreq_requester_identifier_type_system is 'requester/identifier/type/coding/system requester/identifier/type/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_requester_identifier_type_version is 'requester/identifier/type/coding/version requester/identifier/type/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_requester_identifier_type_code is 'requester/identifier/type/coding/code requester/identifier/type/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_requester_identifier_type_display is 'requester/identifier/type/coding/display requester/identifier/type/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_requester_identifier_type_text is 'requester/identifier/type/text requester/identifier/type/text (500 varchar)';
comment on column db_log.servicerequest.servreq_requester_display is 'requester/display requester/display (100 varchar)';
comment on column db_log.servicerequest.servreq_performer_id is 'performer/reference performer/reference (70 varchar)';
comment on column db_log.servicerequest.servreq_performer_type is 'performer/type performer/type (30 varchar)';
comment on column db_log.servicerequest.servreq_performer_identifier_use is 'performer/identifier/use performer/identifier/use (30 varchar)';
comment on column db_log.servicerequest.servreq_performer_identifier_type_system is 'performer/identifier/type/coding/system performer/identifier/type/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_performer_identifier_type_version is 'performer/identifier/type/coding/version performer/identifier/type/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_performer_identifier_type_code is 'performer/identifier/type/coding/code performer/identifier/type/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_performer_identifier_type_display is 'performer/identifier/type/coding/display performer/identifier/type/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_performer_identifier_type_text is 'performer/identifier/type/text performer/identifier/type/text (500 varchar)';
comment on column db_log.servicerequest.servreq_performer_display is 'performer/display performer/display (100 varchar)';
comment on column db_log.servicerequest.servreq_locationcode_system is 'locationCode/coding/system locationCode/coding/system (70 varchar)';
comment on column db_log.servicerequest.servreq_locationcode_version is 'locationCode/coding/version locationCode/coding/version (50 varchar)';
comment on column db_log.servicerequest.servreq_locationcode_code is 'locationCode/coding/code locationCode/coding/code (30 varchar)';
comment on column db_log.servicerequest.servreq_locationcode_display is 'locationCode/coding/display locationCode/coding/display (100 varchar)';
comment on column db_log.servicerequest.servreq_locationcode_text is 'locationCode/text locationCode/text (500 varchar)';

comment on column db_log.procedure.proc_id is 'id id (70 varchar)';
comment on column db_log.procedure.proc_encounter_id is 'encounter/reference encounter/reference (70 varchar)';
comment on column db_log.procedure.proc_patient_id is 'subject/reference subject/reference (70 varchar)';
comment on column db_log.procedure.proc_partof_id is 'partOf/reference partOf/reference (70 varchar)';
comment on column db_log.procedure.proc_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.procedure.proc_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.procedure.proc_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.procedure.proc_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.procedure.proc_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.procedure.proc_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.procedure.proc_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.procedure.proc_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.procedure.proc_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.procedure.proc_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.procedure.proc_basedon_id is 'basedOn/reference basedOn/reference (70 varchar)';
comment on column db_log.procedure.proc_basedon_type is 'basedOn/type basedOn/type (30 varchar)';
comment on column db_log.procedure.proc_basedon_identifier_use is 'basedOn/identifier/use basedOn/identifier/use (30 varchar)';
comment on column db_log.procedure.proc_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system basedOn/identifier/type/coding/system (70 varchar)';
comment on column db_log.procedure.proc_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version basedOn/identifier/type/coding/version (50 varchar)';
comment on column db_log.procedure.proc_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code basedOn/identifier/type/coding/code (30 varchar)';
comment on column db_log.procedure.proc_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display basedOn/identifier/type/coding/display (100 varchar)';
comment on column db_log.procedure.proc_basedon_identifier_type_text is 'basedOn/identifier/type/text basedOn/identifier/type/text (500 varchar)';
comment on column db_log.procedure.proc_basedon_display is 'basedOn/display basedOn/display (100 varchar)';
comment on column db_log.procedure.proc_status is 'status status (30 varchar)';
comment on column db_log.procedure.proc_statusreason_system is 'statusReason/coding/system statusReason/coding/system (70 varchar)';
comment on column db_log.procedure.proc_statusreason_version is 'statusReason/coding/version statusReason/coding/version (50 varchar)';
comment on column db_log.procedure.proc_statusreason_code is 'statusReason/coding/code statusReason/coding/code (30 varchar)';
comment on column db_log.procedure.proc_statusreason_display is 'statusReason/coding/display statusReason/coding/display (100 varchar)';
comment on column db_log.procedure.proc_statusreason_text is 'statusReason/text statusReason/text (500 varchar)';
comment on column db_log.procedure.proc_category_system is 'category/coding/system category/coding/system (70 varchar)';
comment on column db_log.procedure.proc_category_version is 'category/coding/version category/coding/version (50 varchar)';
comment on column db_log.procedure.proc_category_code is 'category/coding/code category/coding/code (30 varchar)';
comment on column db_log.procedure.proc_category_display is 'category/coding/display category/coding/display (100 varchar)';
comment on column db_log.procedure.proc_category_text is 'category/text category/text (500 varchar)';
comment on column db_log.procedure.proc_code_system is 'code/coding/system code/coding/system (70 varchar)';
comment on column db_log.procedure.proc_code_version is 'code/coding/version code/coding/version (50 varchar)';
comment on column db_log.procedure.proc_code_code is 'code/coding/code code/coding/code (30 varchar)';
comment on column db_log.procedure.proc_code_display is 'code/coding/display code/coding/display (100 varchar)';
comment on column db_log.procedure.proc_code_text is 'code/text code/text (500 varchar)';
comment on column db_log.procedure.proc_performeddatetime is 'performedDateTime performedDateTime (30 timestamp)';
comment on column db_log.procedure.proc_performedperiod_start is 'performedPeriod/start performedPeriod/start (30 timestamp)';
comment on column db_log.procedure.proc_performedperiod_end is 'performedPeriod/end performedPeriod/end (30 timestamp)';
comment on column db_log.procedure.proc_reasoncode_system is 'reasonCode/coding/system reasonCode/coding/system (70 varchar)';
comment on column db_log.procedure.proc_reasoncode_version is 'reasonCode/coding/version reasonCode/coding/version (50 varchar)';
comment on column db_log.procedure.proc_reasoncode_code is 'reasonCode/coding/code reasonCode/coding/code (30 varchar)';
comment on column db_log.procedure.proc_reasoncode_display is 'reasonCode/coding/display reasonCode/coding/display (100 varchar)';
comment on column db_log.procedure.proc_reasoncode_text is 'reasonCode/text reasonCode/text (500 varchar)';
comment on column db_log.procedure.proc_reasonreference_id is 'reasonReference/reference reasonReference/reference (70 varchar)';
comment on column db_log.procedure.proc_reasonreference_type is 'reasonReference/type reasonReference/type (30 varchar)';
comment on column db_log.procedure.proc_reasonreference_identifier_use is 'reasonReference/identifier/use reasonReference/identifier/use (30 varchar)';
comment on column db_log.procedure.proc_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system reasonReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.procedure.proc_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version reasonReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.procedure.proc_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code reasonReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.procedure.proc_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display reasonReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.procedure.proc_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text reasonReference/identifier/type/text (500 varchar)';
comment on column db_log.procedure.proc_reasonreference_display is 'reasonReference/display reasonReference/display (100 varchar)';
comment on column db_log.procedure.proc_note_authorstring is 'note/authorString note/authorString (50 varchar)';
comment on column db_log.procedure.proc_note_authorreference_id is 'note/authorReference/reference note/authorReference/reference (70 varchar)';
comment on column db_log.procedure.proc_note_authorreference_type is 'note/authorReference/type note/authorReference/type (30 varchar)';
comment on column db_log.procedure.proc_note_authorreference_identifier_use is 'note/authorReference/identifier/use note/authorReference/identifier/use (30 varchar)';
comment on column db_log.procedure.proc_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system note/authorReference/identifier/type/coding/system (70 varchar)';
comment on column db_log.procedure.proc_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version note/authorReference/identifier/type/coding/version (50 varchar)';
comment on column db_log.procedure.proc_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code note/authorReference/identifier/type/coding/code (30 varchar)';
comment on column db_log.procedure.proc_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display note/authorReference/identifier/type/coding/display (100 varchar)';
comment on column db_log.procedure.proc_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text note/authorReference/identifier/type/text (500 varchar)';
comment on column db_log.procedure.proc_note_authorreference_display is 'note/authorReference/display note/authorReference/display (100 varchar)';
comment on column db_log.procedure.proc_note_time is 'note/time note/time (30 timestamp)';
comment on column db_log.procedure.proc_note_text is 'note/text note/text (5000 varchar)';

comment on column db_log.consent.cons_id is 'id id (70 varchar)';
comment on column db_log.consent.cons_patient_id is 'patient/reference patient/reference (70 varchar)';
comment on column db_log.consent.cons_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.consent.cons_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.consent.cons_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.consent.cons_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.consent.cons_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.consent.cons_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.consent.cons_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.consent.cons_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.consent.cons_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.consent.cons_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.consent.cons_status is 'status status (30 varchar)';
comment on column db_log.consent.cons_scope_system is 'scope/coding/system scope/coding/system (70 varchar)';
comment on column db_log.consent.cons_scope_version is 'scope/coding/version scope/coding/version (50 varchar)';
comment on column db_log.consent.cons_scope_code is 'scope/coding/code scope/coding/code (30 varchar)';
comment on column db_log.consent.cons_scope_display is 'scope/coding/display scope/coding/display (100 varchar)';
comment on column db_log.consent.cons_scope_text is 'scope/text scope/text (500 varchar)';
comment on column db_log.consent.cons_datetime is 'dateTime dateTime (30 timestamp)';
comment on column db_log.consent.cons_provision_type is 'provision/type provision/type (10 varchar)';
comment on column db_log.consent.cons_provision_period_start is 'provision/period/start provision/period/start (30 timestamp)';
comment on column db_log.consent.cons_provision_period_end is 'provision/period/end provision/period/end (30 timestamp)';
comment on column db_log.consent.cons_provision_actor_role_system is 'provision/actor/role/coding/system provision/actor/role/coding/system (70 varchar)';
comment on column db_log.consent.cons_provision_actor_role_version is 'provision/actor/role/coding/version provision/actor/role/coding/version (50 varchar)';
comment on column db_log.consent.cons_provision_actor_role_code is 'provision/actor/role/coding/code provision/actor/role/coding/code (30 varchar)';
comment on column db_log.consent.cons_provision_actor_role_display is 'provision/actor/role/coding/display provision/actor/role/coding/display (100 varchar)';
comment on column db_log.consent.cons_provision_actor_role_text is 'provision/actor/role/text provision/actor/role/text (500 varchar)';
comment on column db_log.consent.cons_provision_code_system is 'provision/code/coding/system provision/code/coding/system (70 varchar)';
comment on column db_log.consent.cons_provision_code_version is 'provision/code/coding/version provision/code/coding/version (50 varchar)';
comment on column db_log.consent.cons_provision_code_code is 'provision/code/coding/code provision/code/coding/code (30 varchar)';
comment on column db_log.consent.cons_provision_code_display is 'provision/code/coding/display provision/code/coding/display (100 varchar)';
comment on column db_log.consent.cons_provision_code_text is 'provision/code/text provision/code/text (500 varchar)';
comment on column db_log.consent.cons_provision_dataperiod_start is 'provision/dataPeriod/start provision/dataPeriod/start (30 timestamp)';
comment on column db_log.consent.cons_provision_dataperiod_end is 'provision/dataPeriod/end provision/dataPeriod/end (30 timestamp)';

comment on column db_log.location.loc_id is 'id id (70 varchar)';
comment on column db_log.location.loc_identifier_use is 'identifier/use identifier/use (50 varchar)';
comment on column db_log.location.loc_identifier_type_system is 'identifier/type/coding/system identifier/type/coding/system (70 varchar)';
comment on column db_log.location.loc_identifier_type_version is 'identifier/type/coding/version identifier/type/coding/version (50 varchar)';
comment on column db_log.location.loc_identifier_type_code is 'identifier/type/coding/code identifier/type/coding/code (30 varchar)';
comment on column db_log.location.loc_identifier_type_display is 'identifier/type/coding/display identifier/type/coding/display (100 varchar)';
comment on column db_log.location.loc_identifier_type_text is 'identifier/type/text identifier/type/text (500 varchar)';
comment on column db_log.location.loc_identifier_system is 'identifier/system identifier/system (70 varchar)';
comment on column db_log.location.loc_identifier_value is 'identifier/value identifier/value (70 varchar)';
comment on column db_log.location.loc_identifier_start is 'identifier/start identifier/start (30 timestamp)';
comment on column db_log.location.loc_identifier_end is 'identifier/end identifier/end (30 timestamp)';
comment on column db_log.location.loc_status is 'status status (30 varchar)';
comment on column db_log.location.loc_name is 'name name (50 varchar)';
comment on column db_log.location.loc_description is 'description description (50 varchar)';
comment on column db_log.location.loc_alias is 'alias alias (30 varchar)';

comment on column db_log.pids_per_ward.date_time is 'date_time date_time (30 timestamp)';
comment on column db_log.pids_per_ward.ward_name is 'ward_name ward_name (30 varchar)';
comment on column db_log.pids_per_ward.patient_id is 'patient_id patient_id (70 varchar)';

