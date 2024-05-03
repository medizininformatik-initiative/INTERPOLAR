-- Create SQL Table in Schema cds2db_in
CREATE TABLE IF NOT EXISTS cds2db_in.encounter_raw (
  encounter_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  enc_id varchar (70),   -- id (70 x 1 varchar)
  enc_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  enc_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
  enc_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  enc_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  enc_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  enc_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  enc_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  enc_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  enc_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  enc_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  enc_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  enc_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  enc_status varchar (30),   -- status (30 x 1 varchar)
  enc_class_system varchar (70),   -- class/coding/system (70 x 1 varchar)
  enc_class_version varchar (50),   -- class/coding/version (50 x 1 varchar)
  enc_class_code varchar (30),   -- class/coding/code (30 x 1 varchar)
  enc_class_display varchar (100),   -- class/coding/display (100 x 1 varchar)
  enc_type_system varchar (630),   -- type/coding/system (70 x 9 varchar)
  enc_type_version varchar (450),   -- type/coding/version (50 x 9 varchar)
  enc_type_code varchar (270),   -- type/coding/code (30 x 9 varchar)
  enc_type_display varchar (900),   -- type/coding/display (100 x 9 varchar)
  enc_type_text varchar (1500),   -- type/text (500 x 3 varchar)
  enc_servicetype_system varchar (70),   -- serviceType/coding/system (70 x 1 varchar)
  enc_servicetype_version varchar (50),   -- serviceType/coding/version (50 x 1 varchar)
  enc_servicetype_code varchar (30),   -- serviceType/coding/code (30 x 1 varchar)
  enc_servicetype_display varchar (100),   -- serviceType/coding/display (100 x 1 varchar)
  enc_servicetype_text varchar (500),   -- serviceType/text (500 x 1 varchar)
  enc_period_start varchar (30),   -- period/start (30 x 1 varchar)
  enc_period_end varchar (30),   -- period/end (30 x 1 varchar)
  enc_diagnosis_condition_id varchar (490),   -- diagnosis/condition/reference (70 x 7 varchar)
  enc_diagnosis_use_system varchar (1470),   -- diagnosis/use/coding/system (70 x 21 varchar)
  enc_diagnosis_use_version varchar (1050),   -- diagnosis/use/coding/version (50 x 21 varchar)
  enc_diagnosis_use_code varchar (630),   -- diagnosis/use/coding/code (30 x 21 varchar)
  enc_diagnosis_use_display varchar (2100),   -- diagnosis/use/coding/display (100 x 21 varchar)
  enc_diagnosis_use_text varchar (3500),   -- diagnosis/use/text (500 x 7 varchar)
  enc_diagnosis_rank varchar (14),   -- diagnosis/rank (2 x 7 varchar)
  enc_hospitalization_admitsource_system varchar (70),   -- hospitalization/admitSource/coding/system (70 x 1 varchar)
  enc_hospitalization_admitsource_version varchar (50),   -- hospitalization/admitSource/coding/version (50 x 1 varchar)
  enc_hospitalization_admitsource_code varchar (30),   -- hospitalization/admitSource/coding/code (30 x 1 varchar)
  enc_hospitalization_admitsource_display varchar (100),   -- hospitalization/admitSource/coding/display (100 x 1 varchar)
  enc_hospitalization_admitsource_text varchar (500),   -- hospitalization/admitSource/text (500 x 1 varchar)
  enc_hospitalization_dischargedisposition_system varchar (70),   -- hospitalization/dischargeDisposition/coding/system (70 x 1 varchar)
  enc_hospitalization_dischargedisposition_version varchar (50),   -- hospitalization/dischargeDisposition/coding/version (50 x 1 varchar)
  enc_hospitalization_dischargedisposition_code varchar (30),   -- hospitalization/dischargeDisposition/coding/code (30 x 1 varchar)
  enc_hospitalization_dischargedisposition_display varchar (100),   -- hospitalization/dischargeDisposition/coding/display (100 x 1 varchar)
  enc_hospitalization_dischargedisposition_text varchar (500),   -- hospitalization/dischargeDisposition/text (500 x 1 varchar)
  enc_location_id varchar (140),   -- location/location/reference (70 x 2 varchar)
  enc_location_type varchar (60),   -- location/location/type (30 x 2 varchar)
  enc_location_identifier_use varchar (60),   -- location/location/identifier/use (30 x 2 varchar)
  enc_location_identifier_type_system varchar (420),   -- location/location/identifier/type/coding/system (70 x 6 varchar)
  enc_location_identifier_type_version varchar (300),   -- location/location/identifier/type/coding/version (50 x 6 varchar)
  enc_location_identifier_type_code varchar (180),   -- location/location/identifier/type/coding/code (30 x 6 varchar)
  enc_location_identifier_type_display varchar (600),   -- location/location/identifier/type/coding/display (100 x 6 varchar)
  enc_location_identifier_type_text varchar (1000),   -- location/location/identifier/type/text (500 x 2 varchar)
  enc_location_display varchar (200),   -- location/location/display (100 x 2 varchar)
  enc_location_status varchar (20),   -- location/location/status (10 x 2 varchar)
  enc_location_physicaltype_system varchar (420),   -- location/location/physicalType/coding/system (70 x 6 varchar)
  enc_location_physicaltype_version varchar (300),   -- location/location/physicalType/coding/version (50 x 6 varchar)
  enc_location_physicaltype_code varchar (180),   -- location/location/physicalType/coding/code (30 x 6 varchar)
  enc_location_physicaltype_display varchar (600),   -- location/location/physicalType/coding/display (100 x 6 varchar)
  enc_location_physicaltype_text varchar (1000),   -- location/location/physicalType/text (500 x 2 varchar)
  enc_serviceprovider_id varchar (70),   -- serviceProvider/reference (70 x 1 varchar)
  enc_serviceprovider_type varchar (30),   -- serviceProvider/type (30 x 1 varchar)
  enc_serviceprovider_identifier_use varchar (30),   -- serviceProvider/identifier/use (30 x 1 varchar)
  enc_serviceprovider_identifier_type_system varchar (70),   -- serviceProvider/identifier/type/coding/system (70 x 1 varchar)
  enc_serviceprovider_identifier_type_version varchar (50),   -- serviceProvider/identifier/type/coding/version (50 x 1 varchar)
  enc_serviceprovider_identifier_type_code varchar (30),   -- serviceProvider/identifier/type/coding/code (30 x 1 varchar)
  enc_serviceprovider_identifier_type_display varchar (100),   -- serviceProvider/identifier/type/coding/display (100 x 1 varchar)
  enc_serviceprovider_identifier_type_text varchar (500),   -- serviceProvider/identifier/type/text (500 x 1 varchar)
  enc_serviceprovider_display varchar (100),   -- serviceProvider/display (100 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.patient_raw (
  patient_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  pat_id varchar (70),   -- id (70 x 1 varchar)
  pat_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  pat_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  pat_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  pat_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  pat_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  pat_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  pat_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  pat_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  pat_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  pat_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  pat_name_given varchar (100),   -- name/given (50 x 2 varchar)
  pat_name_family varchar (100),   -- name/family (50 x 2 varchar)
  pat_gender varchar (10),   -- gender (10 x 1 varchar)
  pat_birthdate varchar (30),   -- birthDate (30 x 1 varchar)
  pat_address_postalcode varchar (30),   -- address/postalCode (10 x 3 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.condition_raw (
  condition_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  con_id varchar (70),   -- id (70 x 1 varchar)
  con_encounter_id varchar (70),   -- encounter/reference (70 x 1 varchar)
  con_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  con_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  con_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  con_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  con_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  con_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  con_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  con_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  con_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  con_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  con_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  con_clinicalstatus_system varchar (70),   -- clinicalStatus/coding/system (70 x 1 varchar)
  con_clinicalstatus_version varchar (50),   -- clinicalStatus/coding/version (50 x 1 varchar)
  con_clinicalstatus_code varchar (30),   -- clinicalStatus/coding/code (30 x 1 varchar)
  con_clinicalstatus_display varchar (100),   -- clinicalStatus/coding/display (100 x 1 varchar)
  con_clinicalstatus_text varchar (500),   -- clinicalStatus/text (500 x 1 varchar)
  con_verificationstatus_system varchar (70),   -- verificationStatus/coding/system (70 x 1 varchar)
  con_verificationstatus_version varchar (50),   -- verificationStatus/coding/version (50 x 1 varchar)
  con_verificationstatus_code varchar (30),   -- verificationStatus/coding/code (30 x 1 varchar)
  con_verificationstatus_display varchar (100),   -- verificationStatus/coding/display (100 x 1 varchar)
  con_verificationstatus_text varchar (500),   -- verificationStatus/text (500 x 1 varchar)
  con_category_system varchar (420),   -- category/coding/system (70 x 6 varchar)
  con_category_version varchar (300),   -- category/coding/version (50 x 6 varchar)
  con_category_code varchar (180),   -- category/coding/code (30 x 6 varchar)
  con_category_display varchar (600),   -- category/coding/display (100 x 6 varchar)
  con_category_text varchar (1000),   -- category/text (500 x 2 varchar)
  con_severity_system varchar (70),   -- severity/coding/system (70 x 1 varchar)
  con_severity_version varchar (50),   -- severity/coding/version (50 x 1 varchar)
  con_severity_code varchar (30),   -- severity/coding/code (30 x 1 varchar)
  con_severity_display varchar (100),   -- severity/coding/display (100 x 1 varchar)
  con_severity_text varchar (500),   -- severity/text (500 x 1 varchar)
  con_code_system varchar (70),   -- code/coding/system (70 x 1 varchar)
  con_code_version varchar (50),   -- code/coding/version (50 x 1 varchar)
  con_code_code varchar (30),   -- code/coding/code (30 x 1 varchar)
  con_code_display varchar (100),   -- code/coding/display (100 x 1 varchar)
  con_code_text varchar (500),   -- code/text (500 x 1 varchar)
  con_bodysite_system varchar (630),   -- bodySite/coding/system (70 x 9 varchar)
  con_bodysite_version varchar (450),   -- bodySite/coding/version (50 x 9 varchar)
  con_bodysite_code varchar (270),   -- bodySite/coding/code (30 x 9 varchar)
  con_bodysite_display varchar (900),   -- bodySite/coding/display (100 x 9 varchar)
  con_bodysite_text varchar (1500),   -- bodySite/text (500 x 3 varchar)
  con_onsetperiod_start varchar (30),   -- onsetPeriod/start (30 x 1 varchar)
  con_onsetperiod_end varchar (30),   -- onsetPeriod/end (30 x 1 varchar)
  con_onsetdatetime varchar (30),   -- onsetDateTime (30 x 1 varchar)
  con_abatementdatetime varchar (30),   -- abatementDateTime (30 x 1 varchar)
  con_abatementage_value varchar (10),   -- abatementAge/value (10 x 1 varchar)
  con_abatementage_comparator varchar (3),   -- abatementAge/comparator (3 x 1 varchar)
  con_abatementage_unit varchar (30),   -- abatementAge/unit (30 x 1 varchar)
  con_abatementage_system varchar (70),   -- abatementAge/system (70 x 1 varchar)
  con_abatementage_code varchar (30),   -- abatementAge/code (30 x 1 varchar)
  con_abatementperiod_start varchar (30),   -- abatementPeriod/start (30 x 1 varchar)
  con_abatementperiod_end varchar (30),   -- abatementPeriod/end (30 x 1 varchar)
  con_abatementrange_low_value varchar (10),   -- abatementRange/low/value (10 x 1 varchar)
  con_abatementrange_low_unit varchar (30),   -- abatementRange/low/unit (30 x 1 varchar)
  con_abatementrange_low_system varchar (70),   -- abatementRange/low/system (70 x 1 varchar)
  con_abatementrange_low_code varchar (30),   -- abatementRange/low/code (30 x 1 varchar)
  con_abatementrange_high_value varchar (10),   -- abatementRange/high/value (10 x 1 varchar)
  con_abatementrange_high_unit varchar (30),   -- abatementRange/high/unit (30 x 1 varchar)
  con_abatementrange_high_system varchar (70),   -- abatementRange/high/system (70 x 1 varchar)
  con_abatementrange_high_code varchar (30),   -- abatementRange/high/code (30 x 1 varchar)
  con_abatementstring varchar (300),   -- abatementString (300 x 1 varchar)
  con_recordeddate varchar (30),   -- recordedDate (30 x 1 varchar)
  con_recorder_id varchar (70),   -- recorder/reference (70 x 1 varchar)
  con_recorder_type varchar (30),   -- recorder/type (30 x 1 varchar)
  con_recorder_identifier_use varchar (30),   -- recorder/identifier/use (30 x 1 varchar)
  con_recorder_identifier_type_system varchar (70),   -- recorder/identifier/type/coding/system (70 x 1 varchar)
  con_recorder_identifier_type_version varchar (50),   -- recorder/identifier/type/coding/version (50 x 1 varchar)
  con_recorder_identifier_type_code varchar (30),   -- recorder/identifier/type/coding/code (30 x 1 varchar)
  con_recorder_identifier_type_display varchar (100),   -- recorder/identifier/type/coding/display (100 x 1 varchar)
  con_recorder_identifier_type_text varchar (500),   -- recorder/identifier/type/text (500 x 1 varchar)
  con_recorder_display varchar (100),   -- recorder/display (100 x 1 varchar)
  con_asserter_id varchar (70),   -- asserter/reference (70 x 1 varchar)
  con_asserter_type varchar (30),   -- asserter/type (30 x 1 varchar)
  con_asserter_identifier_use varchar (30),   -- asserter/identifier/use (30 x 1 varchar)
  con_asserter_identifier_type_system varchar (70),   -- asserter/identifier/type/coding/system (70 x 1 varchar)
  con_asserter_identifier_type_version varchar (50),   -- asserter/identifier/type/coding/version (50 x 1 varchar)
  con_asserter_identifier_type_code varchar (30),   -- asserter/identifier/type/coding/code (30 x 1 varchar)
  con_asserter_identifier_type_display varchar (100),   -- asserter/identifier/type/coding/display (100 x 1 varchar)
  con_asserter_identifier_type_text varchar (500),   -- asserter/identifier/type/text (500 x 1 varchar)
  con_asserter_display varchar (100),   -- asserter/display (100 x 1 varchar)
  con_stage_summary_system varchar (420),   -- stage/summary/coding/system (70 x 6 varchar)
  con_stage_summary_version varchar (300),   -- stage/summary/coding/version (50 x 6 varchar)
  con_stage_summary_code varchar (180),   -- stage/summary/coding/code (30 x 6 varchar)
  con_stage_summary_display varchar (600),   -- stage/summary/coding/display (100 x 6 varchar)
  con_stage_summary_text varchar (1000),   -- stage/summary/text (500 x 2 varchar)
  con_stage_assessment_id varchar (280),   -- stage/assessment/reference (70 x 4 varchar)
  con_stage_assessment_type varchar (120),   -- stage/assessment/type (30 x 4 varchar)
  con_stage_assessment_identifier_use varchar (120),   -- stage/assessment/identifier/use (30 x 4 varchar)
  con_stage_assessment_identifier_type_system varchar (840),   -- stage/assessment/identifier/type/coding/system (70 x 12 varchar)
  con_stage_assessment_identifier_type_version varchar (600),   -- stage/assessment/identifier/type/coding/version (50 x 12 varchar)
  con_stage_assessment_identifier_type_code varchar (360),   -- stage/assessment/identifier/type/coding/code (30 x 12 varchar)
  con_stage_assessment_identifier_type_display varchar (1200),   -- stage/assessment/identifier/type/coding/display (100 x 12 varchar)
  con_stage_assessment_identifier_type_text varchar (2000),   -- stage/assessment/identifier/type/text (500 x 4 varchar)
  con_stage_assessment_display varchar (400),   -- stage/assessment/display (100 x 4 varchar)
  con_stage_type_system varchar (420),   -- stage/type/coding/system (70 x 6 varchar)
  con_stage_type_version varchar (300),   -- stage/type/coding/version (50 x 6 varchar)
  con_stage_type_code varchar (180),   -- stage/type/coding/code (30 x 6 varchar)
  con_stage_type_display varchar (600),   -- stage/type/coding/display (100 x 6 varchar)
  con_stage_type_text varchar (1000),   -- stage/type/text (500 x 2 varchar)
  con_note_authorstring varchar (300),   -- note/authorString (50 x 6 varchar)
  con_note_authorreference_id varchar (420),   -- note/authorReference/reference (70 x 6 varchar)
  con_note_authorreference_type varchar (180),   -- note/authorReference/type (30 x 6 varchar)
  con_note_authorreference_identifier_use varchar (180),   -- note/authorReference/identifier/use (30 x 6 varchar)
  con_note_authorreference_identifier_type_system varchar (1260),   -- note/authorReference/identifier/type/coding/system (70 x 18 varchar)
  con_note_authorreference_identifier_type_version varchar (900),   -- note/authorReference/identifier/type/coding/version (50 x 18 varchar)
  con_note_authorreference_identifier_type_code varchar (540),   -- note/authorReference/identifier/type/coding/code (30 x 18 varchar)
  con_note_authorreference_identifier_type_display varchar (1800),   -- note/authorReference/identifier/type/coding/display (100 x 18 varchar)
  con_note_authorreference_identifier_type_text varchar (3000),   -- note/authorReference/identifier/type/text (500 x 6 varchar)
  con_note_authorreference_display varchar (600),   -- note/authorReference/display (100 x 6 varchar)
  con_note_time varchar (60),   -- note/time (30 x 2 varchar)
  con_note_text varchar (10000),   -- note/text (5000 x 2 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.medication_raw (
  medication_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  med_id varchar (70),   -- id (70 x 1 varchar)
  med_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  med_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  med_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  med_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  med_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  med_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  med_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  med_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  med_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  med_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  med_code_system varchar (630),   -- code/coding/system (70 x 9 varchar)
  med_code_version varchar (450),   -- code/coding/version (50 x 9 varchar)
  med_code_code varchar (270),   -- code/coding/code (30 x 9 varchar)
  med_code_display varchar (900),   -- code/coding/display (100 x 9 varchar)
  med_code_text varchar (1500),   -- code/text (500 x 3 varchar)
  med_status varchar (20),   -- status (20 x 1 varchar)
  med_form_system varchar (70),   -- form/coding/system (70 x 1 varchar)
  med_form_version varchar (50),   -- form/coding/version (50 x 1 varchar)
  med_form_code varchar (30),   -- form/coding/code (30 x 1 varchar)
  med_form_display varchar (100),   -- form/coding/display (100 x 1 varchar)
  med_form_text varchar (500),   -- form/text (500 x 1 varchar)
  med_amount_numerator_value varchar (10),   -- amount/numerator/value (10 x 1 varchar)
  med_amount_numerator_comparator varchar (10),   -- amount/numerator/comparator (10 x 1 varchar)
  med_amount_numerator_unit varchar (30),   -- amount/numerator/unit (30 x 1 varchar)
  med_amount_numerator_system varchar (70),   -- amount/numerator/system (70 x 1 varchar)
  med_amount_numerator_code varchar (30),   -- amount/numerator/code (30 x 1 varchar)
  med_amount_denominator_value varchar (10),   -- amount/denominator/value (10 x 1 varchar)
  med_amount_denominator_comparator varchar (10),   -- amount/denominator/comparator (10 x 1 varchar)
  med_amount_denominator_unit varchar (30),   -- amount/denominator/unit (30 x 1 varchar)
  med_amount_denominator_system varchar (70),   -- amount/denominator/system (70 x 1 varchar)
  med_amount_denominator_code varchar (30),   -- amount/denominator/code (30 x 1 varchar)
  med_ingredient_strength_numerator_value varchar (150),   -- ingredient/strength/numerator/value (10 x 15 varchar)
  med_ingredient_strength_numerator_comparator varchar (150),   -- ingredient/strength/numerator/comparator (10 x 15 varchar)
  med_ingredient_strength_numerator_unit varchar (450),   -- ingredient/strength/numerator/unit (30 x 15 varchar)
  med_ingredient_strength_numerator_system varchar (1050),   -- ingredient/strength/numerator/system (70 x 15 varchar)
  med_ingredient_strength_numerator_code varchar (450),   -- ingredient/strength/numerator/code (30 x 15 varchar)
  med_ingredient_strength_denominator_value varchar (150),   -- ingredient/strength/denominator/value (10 x 15 varchar)
  med_ingredient_strength_denominator_comparator varchar (150),   -- ingredient/strength/denominator/comparator (10 x 15 varchar)
  med_ingredient_strength_denominator_unit varchar (450),   -- ingredient/strength/denominator/unit (30 x 15 varchar)
  med_ingredient_strength_denominator_system varchar (1050),   -- ingredient/strength/denominator/system (70 x 15 varchar)
  med_ingredient_strength_denominator_code varchar (450),   -- ingredient/strength/denominator/code (30 x 15 varchar)
  med_ingredient_itemcodeableconcept_system varchar (3150),   -- ingredient/itemCodeableConcept/coding/system (70 x 45 varchar)
  med_ingredient_itemcodeableconcept_version varchar (2250),   -- ingredient/itemCodeableConcept/coding/version (50 x 45 varchar)
  med_ingredient_itemcodeableconcept_code varchar (1350),   -- ingredient/itemCodeableConcept/coding/code (30 x 45 varchar)
  med_ingredient_itemcodeableconcept_display varchar (4500),   -- ingredient/itemCodeableConcept/coding/display (100 x 45 varchar)
  med_ingredient_itemcodeableconcept_text varchar (7500),   -- ingredient/itemCodeableConcept/text (500 x 15 varchar)
  med_ingredient_itemreference_id varchar (1050),   -- ingredient/itemReference/reference (70 x 15 varchar)
  med_ingredient_itemreference_type varchar (450),   -- ingredient/itemReference/type (30 x 15 varchar)
  med_ingredient_itemreference_identifier_use varchar (450),   -- ingredient/itemReference/identifier/use (30 x 15 varchar)
  med_ingredient_itemreference_identifier_type_system varchar (3150),   -- ingredient/itemReference/identifier/type/coding/system (70 x 45 varchar)
  med_ingredient_itemreference_identifier_type_version varchar (2250),   -- ingredient/itemReference/identifier/type/coding/version (50 x 45 varchar)
  med_ingredient_itemreference_identifier_type_code varchar (1350),   -- ingredient/itemReference/identifier/type/coding/code (30 x 45 varchar)
  med_ingredient_itemreference_identifier_type_display varchar (4500),   -- ingredient/itemReference/identifier/type/coding/display (100 x 45 varchar)
  med_ingredient_itemreference_identifier_type_text varchar (7500),   -- ingredient/itemReference/identifier/type/text (500 x 15 varchar)
  med_ingredient_itemreference_display varchar (1500),   -- ingredient/itemReference/display (100 x 15 varchar)
  med_ingredient_isactive varchar (150),   -- ingredient/isActive (10 x 15 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.medicationrequest_raw (
  medicationrequest_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  medreq_id varchar (70),   -- id (70 x 1 varchar)
  medreq_encounter_id varchar (70),   -- encounter/reference (70 x 1 varchar)
  medreq_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  medreq_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  medreq_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  medreq_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  medreq_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  medreq_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  medreq_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  medreq_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  medreq_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  medreq_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  medreq_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  medreq_medicationreference_id varchar (70),   -- medicationReference/reference (70 x 1 varchar)
  medreq_status varchar (20),   -- status (20 x 1 varchar)
  medreq_statusreason_system varchar (70),   -- statusReason/coding/system (70 x 1 varchar)
  medreq_statusreason_version varchar (50),   -- statusReason/coding/version (50 x 1 varchar)
  medreq_statusreason_code varchar (30),   -- statusReason/coding/code (30 x 1 varchar)
  medreq_statusreason_display varchar (100),   -- statusReason/coding/display (100 x 1 varchar)
  medreq_statusreason_text varchar (500),   -- statusReason/text (500 x 1 varchar)
  medreq_intend varchar (20),   -- intend (20 x 1 varchar)
  medreq_category_system varchar (420),   -- category/coding/system (70 x 6 varchar)
  medreq_category_version varchar (300),   -- category/coding/version (50 x 6 varchar)
  medreq_category_code varchar (180),   -- category/coding/code (30 x 6 varchar)
  medreq_category_display varchar (600),   -- category/coding/display (100 x 6 varchar)
  medreq_category_text varchar (1000),   -- category/text (500 x 2 varchar)
  medreq_priority varchar (10),   -- priority (10 x 1 varchar)
  medreq_reportedboolean varchar (10),   -- reportedBoolean (10 x 1 varchar)
  medreq_reportedreference_id varchar (70),   -- reportedReference/reference (70 x 1 varchar)
  medreq_reportedreference_type varchar (30),   -- reportedReference/type (30 x 1 varchar)
  medreq_reportedreference_identifier_use varchar (30),   -- reportedReference/identifier/use (30 x 1 varchar)
  medreq_reportedreference_identifier_type_system varchar (70),   -- reportedReference/identifier/type/coding/system (70 x 1 varchar)
  medreq_reportedreference_identifier_type_version varchar (50),   -- reportedReference/identifier/type/coding/version (50 x 1 varchar)
  medreq_reportedreference_identifier_type_code varchar (30),   -- reportedReference/identifier/type/coding/code (30 x 1 varchar)
  medreq_reportedreference_identifier_type_display varchar (100),   -- reportedReference/identifier/type/coding/display (100 x 1 varchar)
  medreq_reportedreference_identifier_type_text varchar (500),   -- reportedReference/identifier/type/text (500 x 1 varchar)
  medreq_reportedreference_display varchar (100),   -- reportedReference/display (100 x 1 varchar)
  medreq_medicationcodeableconcept_system varchar (70),   -- medicationCodeableConcept/coding/system (70 x 1 varchar)
  medreq_medicationcodeableconcept_version varchar (50),   -- medicationCodeableConcept/coding/version (50 x 1 varchar)
  medreq_medicationcodeableconcept_code varchar (30),   -- medicationCodeableConcept/coding/code (30 x 1 varchar)
  medreq_medicationcodeableconcept_display varchar (100),   -- medicationCodeableConcept/coding/display (100 x 1 varchar)
  medreq_medicationcodeableconcept_text varchar (500),   -- medicationCodeableConcept/text (500 x 1 varchar)
  medreq_supportinginformation_id varchar (140),   -- supportingInformation/reference (70 x 2 varchar)
  medreq_supportinginformation_type varchar (60),   -- supportingInformation/type (30 x 2 varchar)
  medreq_supportinginformation_identifier_use varchar (60),   -- supportingInformation/identifier/use (30 x 2 varchar)
  medreq_supportinginformation_identifier_type_system varchar (420),   -- supportingInformation/identifier/type/coding/system (70 x 6 varchar)
  medreq_supportinginformation_identifier_type_version varchar (300),   -- supportingInformation/identifier/type/coding/version (50 x 6 varchar)
  medreq_supportinginformation_identifier_type_code varchar (180),   -- supportingInformation/identifier/type/coding/code (30 x 6 varchar)
  medreq_supportinginformation_identifier_type_display varchar (600),   -- supportingInformation/identifier/type/coding/display (100 x 6 varchar)
  medreq_supportinginformation_identifier_type_text varchar (1000),   -- supportingInformation/identifier/type/text (500 x 2 varchar)
  medreq_supportinginformation_display varchar (200),   -- supportingInformation/display (100 x 2 varchar)
  medreq_authoredon varchar (30),   -- authoredOn (30 x 1 varchar)
  medreq_requester_id varchar (70),   -- requester/reference (70 x 1 varchar)
  medreq_requester_type varchar (30),   -- requester/type (30 x 1 varchar)
  medreq_requester_identifier_use varchar (30),   -- requester/identifier/use (30 x 1 varchar)
  medreq_requester_identifier_type_system varchar (70),   -- requester/identifier/type/coding/system (70 x 1 varchar)
  medreq_requester_identifier_type_version varchar (50),   -- requester/identifier/type/coding/version (50 x 1 varchar)
  medreq_requester_identifier_type_code varchar (30),   -- requester/identifier/type/coding/code (30 x 1 varchar)
  medreq_requester_identifier_type_display varchar (100),   -- requester/identifier/type/coding/display (100 x 1 varchar)
  medreq_requester_identifier_type_text varchar (500),   -- requester/identifier/type/text (500 x 1 varchar)
  medreq_requester_display varchar (100),   -- requester/display (100 x 1 varchar)
  medreq_reasoncode_system varchar (420),   -- reasonCode/coding/system (70 x 6 varchar)
  medreq_reasoncode_version varchar (300),   -- reasonCode/coding/version (50 x 6 varchar)
  medreq_reasoncode_code varchar (180),   -- reasonCode/coding/code (30 x 6 varchar)
  medreq_reasoncode_display varchar (600),   -- reasonCode/coding/display (100 x 6 varchar)
  medreq_reasoncode_text varchar (1000),   -- reasonCode/text (500 x 2 varchar)
  medreq_reasonreference_id varchar (140),   -- reasonReference/reference (70 x 2 varchar)
  medreq_reasonreference_type varchar (60),   -- reasonReference/type (30 x 2 varchar)
  medreq_reasonreference_identifier_use varchar (60),   -- reasonReference/identifier/use (30 x 2 varchar)
  medreq_reasonreference_identifier_type_system varchar (420),   -- reasonReference/identifier/type/coding/system (70 x 6 varchar)
  medreq_reasonreference_identifier_type_version varchar (300),   -- reasonReference/identifier/type/coding/version (50 x 6 varchar)
  medreq_reasonreference_identifier_type_code varchar (180),   -- reasonReference/identifier/type/coding/code (30 x 6 varchar)
  medreq_reasonreference_identifier_type_display varchar (600),   -- reasonReference/identifier/type/coding/display (100 x 6 varchar)
  medreq_reasonreference_identifier_type_text varchar (1000),   -- reasonReference/identifier/type/text (500 x 2 varchar)
  medreq_reasonreference_display varchar (200),   -- reasonReference/display (100 x 2 varchar)
  medreq_basedon_id varchar (140),   -- basedOn/reference (70 x 2 varchar)
  medreq_basedon_type varchar (60),   -- basedOn/type (30 x 2 varchar)
  medreq_basedon_identifier_use varchar (60),   -- basedOn/identifier/use (30 x 2 varchar)
  medreq_basedon_identifier_type_system varchar (420),   -- basedOn/identifier/type/coding/system (70 x 6 varchar)
  medreq_basedon_identifier_type_version varchar (300),   -- basedOn/identifier/type/coding/version (50 x 6 varchar)
  medreq_basedon_identifier_type_code varchar (180),   -- basedOn/identifier/type/coding/code (30 x 6 varchar)
  medreq_basedon_identifier_type_display varchar (600),   -- basedOn/identifier/type/coding/display (100 x 6 varchar)
  medreq_basedon_identifier_type_text varchar (1000),   -- basedOn/identifier/type/text (500 x 2 varchar)
  medreq_basedon_display varchar (200),   -- basedOn/display (100 x 2 varchar)
  medreq_note_authorstring varchar (300),   -- note/authorString (50 x 6 varchar)
  medreq_note_authorreference_id varchar (420),   -- note/authorReference/reference (70 x 6 varchar)
  medreq_note_authorreference_type varchar (180),   -- note/authorReference/type (30 x 6 varchar)
  medreq_note_authorreference_identifier_use varchar (180),   -- note/authorReference/identifier/use (30 x 6 varchar)
  medreq_note_authorreference_identifier_type_system varchar (1260),   -- note/authorReference/identifier/type/coding/system (70 x 18 varchar)
  medreq_note_authorreference_identifier_type_version varchar (900),   -- note/authorReference/identifier/type/coding/version (50 x 18 varchar)
  medreq_note_authorreference_identifier_type_code varchar (540),   -- note/authorReference/identifier/type/coding/code (30 x 18 varchar)
  medreq_note_authorreference_identifier_type_display varchar (1800),   -- note/authorReference/identifier/type/coding/display (100 x 18 varchar)
  medreq_note_authorreference_identifier_type_text varchar (3000),   -- note/authorReference/identifier/type/text (500 x 6 varchar)
  medreq_note_authorreference_display varchar (600),   -- note/authorReference/display (100 x 6 varchar)
  medreq_note_time varchar (60),   -- note/time (30 x 2 varchar)
  medreq_note_text varchar (10000),   -- note/text (5000 x 2 varchar)
  medreq_doseinstruc_sequence varchar (20),   -- dosageInstruction/sequence (10 x 2 varchar)
  medreq_doseinstruc_text varchar (1000),   -- dosageInstruction/text (500 x 2 varchar)
  medreq_doseinstruc_additionalinstruction_system varchar (840),   -- dosageInstruction/additionalInstruction/coding/system (70 x 12 varchar)
  medreq_doseinstruc_additionalinstruction_version varchar (600),   -- dosageInstruction/additionalInstruction/coding/version (50 x 12 varchar)
  medreq_doseinstruc_additionalinstruction_code varchar (360),   -- dosageInstruction/additionalInstruction/coding/code (30 x 12 varchar)
  medreq_doseinstruc_additionalinstruction_display varchar (1200),   -- dosageInstruction/additionalInstruction/coding/display (100 x 12 varchar)
  medreq_doseinstruc_additionalinstruction_text varchar (2000),   -- dosageInstruction/additionalInstruction/text (500 x 4 varchar)
  medreq_doseinstruc_patientinstruction varchar (200),   -- dosageInstruction/patientInstruction (100 x 2 varchar)
  medreq_doseinstruc_timing_event varchar (240),   -- dosageInstruction/timing/event (30 x 8 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_value varchar (60),   -- dosageInstruction/timing/repeat/boundsDuration/value (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_comparator varchar (20),   -- dosageInstruction/timing/repeat/boundsDuration/comparator (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_unit varchar (60),   -- dosageInstruction/timing/repeat/boundsDuration/unit (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_system varchar (140),   -- dosageInstruction/timing/repeat/boundsDuration/system (70 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_code varchar (60),   -- dosageInstruction/timing/repeat/boundsDuration/code (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_value varchar (20),   -- dosageInstruction/timing/repeat/boundsRange/low/value (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_unit varchar (60),   -- dosageInstruction/timing/repeat/boundsRange/low/unit (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_system varchar (140),   -- dosageInstruction/timing/repeat/boundsRange/low/system (70 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_code varchar (60),   -- dosageInstruction/timing/repeat/boundsRange/low/code (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_value varchar (20),   -- dosageInstruction/timing/repeat/boundsRange/high/value (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_unit varchar (60),   -- dosageInstruction/timing/repeat/boundsRange/high/unit (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_system varchar (140),   -- dosageInstruction/timing/repeat/boundsRange/high/system (70 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_code varchar (60),   -- dosageInstruction/timing/repeat/boundsRange/high/code (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsperiod_start varchar (60),   -- dosageInstruction/timing/repeat/boundsPeriod/start (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_boundsperiod_end varchar (60),   -- dosageInstruction/timing/repeat/boundsPeriod/end (30 x 2 varchar)
  medreq_doseinstruc_timing_repeat_count varchar (20),   -- dosageInstruction/timing/repeat/count (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_countmax varchar (20),   -- dosageInstruction/timing/repeat/countMax (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_duration varchar (20),   -- dosageInstruction/timing/repeat/duration (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_durationmax varchar (20),   -- dosageInstruction/timing/repeat/durationMax (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_durationunit varchar (40),   -- dosageInstruction/timing/repeat/durationUnit (20 x 2 varchar)
  medreq_doseinstruc_timing_repeat_frequency varchar (20),   -- dosageInstruction/timing/repeat/frequency (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_frequencymax varchar (20),   -- dosageInstruction/timing/repeat/frequencyMax (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_period varchar (20),   -- dosageInstruction/timing/repeat/period (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_periodmax varchar (20),   -- dosageInstruction/timing/repeat/periodMax (10 x 2 varchar)
  medreq_doseinstruc_timing_repeat_periodunit varchar (40),   -- dosageInstruction/timing/repeat/periodUnit (20 x 2 varchar)
  medreq_doseinstruc_timing_repeat_dayofweek varchar (140),   -- dosageInstruction/timing/repeat/dayOfWeek (10 x 14 varchar)
  medreq_doseinstruc_timing_repeat_timeofday varchar (160),   -- dosageInstruction/timing/repeat/timeOfDay (20 x 8 varchar)
  medreq_doseinstruc_timing_repeat_when varchar (160),   -- dosageInstruction/timing/repeat/when (20 x 8 varchar)
  medreq_doseinstruc_timing_repeat_offset varchar (20),   -- dosageInstruction/timing/repeat/offset (10 x 2 varchar)
  medreq_doseinstruc_timing_code_system varchar (420),   -- dosageInstruction/timing/code/coding/system (70 x 6 varchar)
  medreq_doseinstruc_timing_code_version varchar (300),   -- dosageInstruction/timing/code/coding/version (50 x 6 varchar)
  medreq_doseinstruc_timing_code_code varchar (180),   -- dosageInstruction/timing/code/coding/code (30 x 6 varchar)
  medreq_doseinstruc_timing_code_display varchar (600),   -- dosageInstruction/timing/code/coding/display (100 x 6 varchar)
  medreq_doseinstruc_timing_code_text varchar (1000),   -- dosageInstruction/timing/code/text (500 x 2 varchar)
  medreq_doseinstruc_asneededboolean varchar (20),   -- dosageInstruction/asNeededBoolean (10 x 2 varchar)
  medreq_doseinstruc_asneededcodeableconcept_system varchar (420),   -- dosageInstruction/asNeededCodeableConcept/coding/system (70 x 6 varchar)
  medreq_doseinstruc_asneededcodeableconcept_version varchar (300),   -- dosageInstruction/asNeededCodeableConcept/coding/version (50 x 6 varchar)
  medreq_doseinstruc_asneededcodeableconcept_code varchar (180),   -- dosageInstruction/asNeededCodeableConcept/coding/code (30 x 6 varchar)
  medreq_doseinstruc_asneededcodeableconcept_display varchar (600),   -- dosageInstruction/asNeededCodeableConcept/coding/display (100 x 6 varchar)
  medreq_doseinstruc_asneededcodeableconcept_text varchar (1000),   -- dosageInstruction/asNeededCodeableConcept/text (500 x 2 varchar)
  medreq_doseinstruc_site_system varchar (420),   -- dosageInstruction/site/coding/system (70 x 6 varchar)
  medreq_doseinstruc_site_version varchar (300),   -- dosageInstruction/site/coding/version (50 x 6 varchar)
  medreq_doseinstruc_site_code varchar (180),   -- dosageInstruction/site/coding/code (30 x 6 varchar)
  medreq_doseinstruc_site_display varchar (600),   -- dosageInstruction/site/coding/display (100 x 6 varchar)
  medreq_doseinstruc_site_text varchar (1000),   -- dosageInstruction/site/text (500 x 2 varchar)
  medreq_doseinstruc_route_system varchar (420),   -- dosageInstruction/route/coding/system (70 x 6 varchar)
  medreq_doseinstruc_route_version varchar (300),   -- dosageInstruction/route/coding/version (50 x 6 varchar)
  medreq_doseinstruc_route_code varchar (180),   -- dosageInstruction/route/coding/code (30 x 6 varchar)
  medreq_doseinstruc_route_display varchar (600),   -- dosageInstruction/route/coding/display (100 x 6 varchar)
  medreq_doseinstruc_route_text varchar (1000),   -- dosageInstruction/route/text (500 x 2 varchar)
  medreq_doseinstruc_method_system varchar (420),   -- dosageInstruction/method/coding/system (70 x 6 varchar)
  medreq_doseinstruc_method_version varchar (300),   -- dosageInstruction/method/coding/version (50 x 6 varchar)
  medreq_doseinstruc_method_code varchar (180),   -- dosageInstruction/method/coding/code (30 x 6 varchar)
  medreq_doseinstruc_method_display varchar (600),   -- dosageInstruction/method/coding/display (100 x 6 varchar)
  medreq_doseinstruc_method_text varchar (1000),   -- dosageInstruction/method/text (500 x 2 varchar)
  medreq_doseinstruc_doseandrate_type_system varchar (420),   -- dosageInstruction/doseAndRate/type/coding/system (70 x 6 varchar)
  medreq_doseinstruc_doseandrate_type_version varchar (300),   -- dosageInstruction/doseAndRate/type/coding/version (50 x 6 varchar)
  medreq_doseinstruc_doseandrate_type_code varchar (180),   -- dosageInstruction/doseAndRate/type/coding/code (30 x 6 varchar)
  medreq_doseinstruc_doseandrate_type_display varchar (600),   -- dosageInstruction/doseAndRate/type/coding/display (100 x 6 varchar)
  medreq_doseinstruc_doseandrate_type_text varchar (1000),   -- dosageInstruction/doseAndRate/type/text (500 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_value varchar (20),   -- dosageInstruction/doseAndRate/doseRange/low/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_unit varchar (60),   -- dosageInstruction/doseAndRate/doseRange/low/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_system varchar (140),   -- dosageInstruction/doseAndRate/doseRange/low/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_low_code varchar (60),   -- dosageInstruction/doseAndRate/doseRange/low/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_value varchar (20),   -- dosageInstruction/doseAndRate/doseRange/high/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_unit varchar (60),   -- dosageInstruction/doseAndRate/doseRange/high/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_system varchar (140),   -- dosageInstruction/doseAndRate/doseRange/high/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_doserange_high_code varchar (60),   -- dosageInstruction/doseAndRate/doseRange/high/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_value varchar (20),   -- dosageInstruction/doseAndRate/doseQuantity/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_comparator varchar (20),   -- dosageInstruction/doseAndRate/doseQuantity/comparator (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_unit varchar (60),   -- dosageInstruction/doseAndRate/doseQuantity/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_system varchar (140),   -- dosageInstruction/doseAndRate/doseQuantity/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_dosequantity_code varchar (60),   -- dosageInstruction/doseAndRate/doseQuantity/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_value varchar (20),   -- dosageInstruction/doseAndRate/rateRatio/numerator/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_comparator varchar (20),   -- dosageInstruction/doseAndRate/rateRatio/numerator/comparator (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_unit varchar (60),   -- dosageInstruction/doseAndRate/rateRatio/numerator/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_system varchar (140),   -- dosageInstruction/doseAndRate/rateRatio/numerator/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_code varchar (60),   -- dosageInstruction/doseAndRate/rateRatio/numerator/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_value varchar (20),   -- dosageInstruction/doseAndRate/rateRatio/denominator/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_comparator varchar (20),   -- dosageInstruction/doseAndRate/rateRatio/denominator/comparator (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_unit varchar (60),   -- dosageInstruction/doseAndRate/rateRatio/denominator/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_system varchar (140),   -- dosageInstruction/doseAndRate/rateRatio/denominator/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_code varchar (60),   -- dosageInstruction/doseAndRate/rateRatio/denominator/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_value varchar (20),   -- dosageInstruction/doseAndRate/rateRange/low/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_unit varchar (60),   -- dosageInstruction/doseAndRate/rateRange/low/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_system varchar (140),   -- dosageInstruction/doseAndRate/rateRange/low/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_low_code varchar (60),   -- dosageInstruction/doseAndRate/rateRange/low/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_value varchar (20),   -- dosageInstruction/doseAndRate/rateRange/high/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_unit varchar (60),   -- dosageInstruction/doseAndRate/rateRange/high/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_system varchar (140),   -- dosageInstruction/doseAndRate/rateRange/high/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_raterange_high_code varchar (60),   -- dosageInstruction/doseAndRate/rateRange/high/code (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_value varchar (20),   -- dosageInstruction/doseAndRate/rateQuantity/value (10 x 2 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_unit varchar (60),   -- dosageInstruction/doseAndRate/rateQuantity/unit (30 x 2 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_system varchar (140),   -- dosageInstruction/doseAndRate/rateQuantity/system (70 x 2 varchar)
  medreq_doseinstruc_doseandrate_ratequantity_code varchar (60),   -- dosageInstruction/doseAndRate/rateQuantity/code (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_value varchar (20),   -- dosageInstruction/maxDosePerPeriod/numerator/value (10 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_comparator varchar (20),   -- dosageInstruction/maxDosePerPeriod/numerator/comparator (10 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_unit varchar (60),   -- dosageInstruction/maxDosePerPeriod/numerator/unit (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_system varchar (140),   -- dosageInstruction/maxDosePerPeriod/numerator/system (70 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_code varchar (60),   -- dosageInstruction/maxDosePerPeriod/numerator/code (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_value varchar (20),   -- dosageInstruction/maxDosePerPeriod/denominator/value (10 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_comparator varchar (20),   -- dosageInstruction/maxDosePerPeriod/denominator/comparator (10 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_unit varchar (60),   -- dosageInstruction/maxDosePerPeriod/denominator/unit (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_system varchar (140),   -- dosageInstruction/maxDosePerPeriod/denominator/system (70 x 2 varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_code varchar (60),   -- dosageInstruction/maxDosePerPeriod/denominator/code (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperadministration_value varchar (20),   -- dosageInstruction/maxDosePerAdministration/value (10 x 2 varchar)
  medreq_doseinstruc_maxdoseperadministration_unit varchar (60),   -- dosageInstruction/maxDosePerAdministration/unit (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperadministration_system varchar (140),   -- dosageInstruction/maxDosePerAdministration/system (70 x 2 varchar)
  medreq_doseinstruc_maxdoseperadministration_code varchar (60),   -- dosageInstruction/maxDosePerAdministration/code (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperlifetime_value varchar (20),   -- dosageInstruction/maxDosePerLifetime/value (10 x 2 varchar)
  medreq_doseinstruc_maxdoseperlifetime_unit varchar (60),   -- dosageInstruction/maxDosePerLifetime/unit (30 x 2 varchar)
  medreq_doseinstruc_maxdoseperlifetime_system varchar (140),   -- dosageInstruction/maxDosePerLifetime/system (70 x 2 varchar)
  medreq_doseinstruc_maxdoseperlifetime_code varchar (60),   -- dosageInstruction/maxDosePerLifetime/code (30 x 2 varchar)
  medreq_substitution_reason_system varchar (70),   -- substitution/reason/coding/system (70 x 1 varchar)
  medreq_substitution_reason_version varchar (50),   -- substitution/reason/coding/version (50 x 1 varchar)
  medreq_substitution_reason_code varchar (30),   -- substitution/reason/coding/code (30 x 1 varchar)
  medreq_substitution_reason_display varchar (100),   -- substitution/reason/coding/display (100 x 1 varchar)
  medreq_substitution_reason_text varchar (500),   -- substitution/reason/text (500 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.medicationadministration_raw (
  medicationadministration_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  medadm_id varchar (70),   -- id (70 x 1 varchar)
  medadm_encounter_id varchar (70),   -- context/reference (70 x 1 varchar)
  medadm_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  medadm_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
  medadm_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  medadm_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  medadm_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  medadm_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  medadm_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  medadm_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  medadm_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  medadm_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  medadm_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  medadm_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  medadm_status varchar (30),   -- status (30 x 1 varchar)
  medadm_statusreason_system varchar (70),   -- statusReason/coding/system (70 x 1 varchar)
  medadm_statusreason_version varchar (50),   -- statusReason/coding/version (50 x 1 varchar)
  medadm_statusreason_code varchar (30),   -- statusReason/coding/code (30 x 1 varchar)
  medadm_statusreason_display varchar (100),   -- statusReason/coding/display (100 x 1 varchar)
  medadm_statusreason_text varchar (500),   -- statusReason/text (500 x 1 varchar)
  medadm_category_system varchar (70),   -- category/coding/system (70 x 1 varchar)
  medadm_category_version varchar (50),   -- category/coding/version (50 x 1 varchar)
  medadm_category_code varchar (30),   -- category/coding/code (30 x 1 varchar)
  medadm_category_display varchar (100),   -- category/coding/display (100 x 1 varchar)
  medadm_category_text varchar (500),   -- category/text (500 x 1 varchar)
  medadm_medicationreference_id varchar (70),   -- medicationReference/reference (70 x 1 varchar)
  medadm_medicationcodeableconcept_system varchar (70),   -- medicationCodeableConcept/coding/system (70 x 1 varchar)
  medadm_medicationcodeableconcept_version varchar (50),   -- medicationCodeableConcept/coding/version (50 x 1 varchar)
  medadm_medicationcodeableconcept_code varchar (30),   -- medicationCodeableConcept/coding/code (30 x 1 varchar)
  medadm_medicationcodeableconcept_display varchar (100),   -- medicationCodeableConcept/coding/display (100 x 1 varchar)
  medadm_medicationcodeableconcept_text varchar (500),   -- medicationCodeableConcept/text (500 x 1 varchar)
  medadm_supportinginformation_id varchar (140),   -- supportingInformation/reference (70 x 2 varchar)
  medadm_supportinginformation_type varchar (60),   -- supportingInformation/type (30 x 2 varchar)
  medadm_supportinginformation_identifier_use varchar (60),   -- supportingInformation/identifier/use (30 x 2 varchar)
  medadm_supportinginformation_identifier_type_system varchar (420),   -- supportingInformation/identifier/type/coding/system (70 x 6 varchar)
  medadm_supportinginformation_identifier_type_version varchar (300),   -- supportingInformation/identifier/type/coding/version (50 x 6 varchar)
  medadm_supportinginformation_identifier_type_code varchar (180),   -- supportingInformation/identifier/type/coding/code (30 x 6 varchar)
  medadm_supportinginformation_identifier_type_display varchar (600),   -- supportingInformation/identifier/type/coding/display (100 x 6 varchar)
  medadm_supportinginformation_identifier_type_text varchar (1000),   -- supportingInformation/identifier/type/text (500 x 2 varchar)
  medadm_supportinginformation_display varchar (200),   -- supportingInformation/display (100 x 2 varchar)
  medadm_effectivedatetime varchar (30),   -- effectiveDateTime (30 x 1 varchar)
  medadm_effectiveperiod_start varchar (30),   -- effectivePeriod/start (30 x 1 varchar)
  medadm_effectiveperiod_end varchar (30),   -- effectivePeriod/end (30 x 1 varchar)
  medadm_performer_function_system varchar (70),   -- performer/function/coding/system (70 x 1 varchar)
  medadm_performer_function_version varchar (50),   -- performer/function/coding/version (50 x 1 varchar)
  medadm_performer_function_code varchar (30),   -- performer/function/coding/code (30 x 1 varchar)
  medadm_performer_function_display varchar (100),   -- performer/function/coding/display (100 x 1 varchar)
  medadm_performer_function_text varchar (500),   -- performer/function/text (500 x 1 varchar)
  medadm_reasoncode_system varchar (420),   -- reasonCode/coding/system (70 x 6 varchar)
  medadm_reasoncode_version varchar (300),   -- reasonCode/coding/version (50 x 6 varchar)
  medadm_reasoncode_code varchar (180),   -- reasonCode/coding/code (30 x 6 varchar)
  medadm_reasoncode_display varchar (600),   -- reasonCode/coding/display (100 x 6 varchar)
  medadm_reasoncode_text varchar (1000),   -- reasonCode/text (500 x 2 varchar)
  medadm_reasonreference_id varchar (140),   -- reasonReference/reference (70 x 2 varchar)
  medadm_reasonreference_type varchar (60),   -- reasonReference/type (30 x 2 varchar)
  medadm_reasonreference_identifier_use varchar (60),   -- reasonReference/identifier/use (30 x 2 varchar)
  medadm_reasonreference_identifier_type_system varchar (420),   -- reasonReference/identifier/type/coding/system (70 x 6 varchar)
  medadm_reasonreference_identifier_type_version varchar (300),   -- reasonReference/identifier/type/coding/version (50 x 6 varchar)
  medadm_reasonreference_identifier_type_code varchar (180),   -- reasonReference/identifier/type/coding/code (30 x 6 varchar)
  medadm_reasonreference_identifier_type_display varchar (600),   -- reasonReference/identifier/type/coding/display (100 x 6 varchar)
  medadm_reasonreference_identifier_type_text varchar (1000),   -- reasonReference/identifier/type/text (500 x 2 varchar)
  medadm_reasonreference_display varchar (200),   -- reasonReference/display (100 x 2 varchar)
  medadm_request_id varchar (70),   -- request/reference (70 x 1 varchar)
  medadm_note_authorstring varchar (300),   -- note/authorString (50 x 6 varchar)
  medadm_note_authorreference_id varchar (420),   -- note/authorReference/reference (70 x 6 varchar)
  medadm_note_authorreference_type varchar (180),   -- note/authorReference/type (30 x 6 varchar)
  medadm_note_authorreference_identifier_use varchar (180),   -- note/authorReference/identifier/use (30 x 6 varchar)
  medadm_note_authorreference_identifier_type_system varchar (1260),   -- note/authorReference/identifier/type/coding/system (70 x 18 varchar)
  medadm_note_authorreference_identifier_type_version varchar (900),   -- note/authorReference/identifier/type/coding/version (50 x 18 varchar)
  medadm_note_authorreference_identifier_type_code varchar (540),   -- note/authorReference/identifier/type/coding/code (30 x 18 varchar)
  medadm_note_authorreference_identifier_type_display varchar (1800),   -- note/authorReference/identifier/type/coding/display (100 x 18 varchar)
  medadm_note_authorreference_identifier_type_text varchar (3000),   -- note/authorReference/identifier/type/text (500 x 6 varchar)
  medadm_note_authorreference_display varchar (600),   -- note/authorReference/display (100 x 6 varchar)
  medadm_note_time varchar (60),   -- note/time (30 x 2 varchar)
  medadm_note_text varchar (10000),   -- note/text (5000 x 2 varchar)
  medadm_dosage_text varchar (100),   -- dosage/text (100 x 1 varchar)
  medadm_dosage_site_system varchar (70),   -- dosage/site/coding/system (70 x 1 varchar)
  medadm_dosage_site_version varchar (50),   -- dosage/site/coding/version (50 x 1 varchar)
  medadm_dosage_site_code varchar (30),   -- dosage/site/coding/code (30 x 1 varchar)
  medadm_dosage_site_display varchar (100),   -- dosage/site/coding/display (100 x 1 varchar)
  medadm_dosage_site_text varchar (500),   -- dosage/site/text (500 x 1 varchar)
  medadm_dosage_route_system varchar (70),   -- dosage/route/coding/system (70 x 1 varchar)
  medadm_dosage_route_version varchar (50),   -- dosage/route/coding/version (50 x 1 varchar)
  medadm_dosage_route_code varchar (30),   -- dosage/route/coding/code (30 x 1 varchar)
  medadm_dosage_route_display varchar (100),   -- dosage/route/coding/display (100 x 1 varchar)
  medadm_dosage_route_text varchar (500),   -- dosage/route/text (500 x 1 varchar)
  medadm_dosage_method_system varchar (70),   -- dosage/method/coding/system (70 x 1 varchar)
  medadm_dosage_method_version varchar (50),   -- dosage/method/coding/version (50 x 1 varchar)
  medadm_dosage_method_code varchar (30),   -- dosage/method/coding/code (30 x 1 varchar)
  medadm_dosage_method_display varchar (100),   -- dosage/method/coding/display (100 x 1 varchar)
  medadm_dosage_method_text varchar (500),   -- dosage/method/text (500 x 1 varchar)
  medadm_dosage_dose_value varchar (10),   -- dosage/dose/value (10 x 1 varchar)
  medadm_dosage_dose_unit varchar (30),   -- dosage/dose/unit (30 x 1 varchar)
  medadm_dosage_dose_system varchar (70),   -- dosage/dose/system (70 x 1 varchar)
  medadm_dosage_dose_code varchar (30),   -- dosage/dose/code (30 x 1 varchar)
  medadm_dosage_rateratio_numerator_value varchar (10),   -- dosage/rateRatio/numerator/value (10 x 1 varchar)
  medadm_dosage_rateratio_numerator_comparator varchar (10),   -- dosage/rateRatio/numerator/comparator (10 x 1 varchar)
  medadm_dosage_rateratio_numerator_unit varchar (30),   -- dosage/rateRatio/numerator/unit (30 x 1 varchar)
  medadm_dosage_rateratio_numerator_system varchar (70),   -- dosage/rateRatio/numerator/system (70 x 1 varchar)
  medadm_dosage_rateratio_numerator_code varchar (30),   -- dosage/rateRatio/numerator/code (30 x 1 varchar)
  medadm_dosage_rateratio_denominator_value varchar (10),   -- dosage/rateRatio/denominator/value (10 x 1 varchar)
  medadm_dosage_rateratio_denominator_comparator varchar (10),   -- dosage/rateRatio/denominator/comparator (10 x 1 varchar)
  medadm_dosage_rateratio_denominator_unit varchar (30),   -- dosage/rateRatio/denominator/unit (30 x 1 varchar)
  medadm_dosage_rateratio_denominator_system varchar (70),   -- dosage/rateRatio/denominator/system (70 x 1 varchar)
  medadm_dosage_rateratio_denominator_code varchar (30),   -- dosage/rateRatio/denominator/code (30 x 1 varchar)
  medadm_dosage_ratequantity_value varchar (10),   -- dosage/rateQuantity/value (10 x 1 varchar)
  medadm_dosage_ratequantity_unit varchar (30),   -- dosage/rateQuantity/unit (30 x 1 varchar)
  medadm_dosage_ratequantity_system varchar (70),   -- dosage/rateQuantity/system (70 x 1 varchar)
  medadm_dosage_ratequantity_code varchar (30),   -- dosage/rateQuantity/code (30 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.medicationstatement_raw (
  medicationstatement_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  medstat_id varchar (70),   -- id (70 x 1 varchar)
  medstat_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  medstat_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  medstat_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  medstat_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  medstat_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  medstat_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  medstat_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  medstat_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  medstat_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  medstat_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  medstat_encounter_id varchar (70),   -- context/reference (70 x 1 varchar)
  medstat_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  medstat_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
  medstat_basedon_id varchar (140),   -- basedOn/reference (70 x 2 varchar)
  medstat_basedon_type varchar (60),   -- basedOn/type (30 x 2 varchar)
  medstat_basedon_identifier_use varchar (60),   -- basedOn/identifier/use (30 x 2 varchar)
  medstat_basedon_identifier_type_system varchar (420),   -- basedOn/identifier/type/coding/system (70 x 6 varchar)
  medstat_basedon_identifier_type_version varchar (300),   -- basedOn/identifier/type/coding/version (50 x 6 varchar)
  medstat_basedon_identifier_type_code varchar (180),   -- basedOn/identifier/type/coding/code (30 x 6 varchar)
  medstat_basedon_identifier_type_display varchar (600),   -- basedOn/identifier/type/coding/display (100 x 6 varchar)
  medstat_basedon_identifier_type_text varchar (1000),   -- basedOn/identifier/type/text (500 x 2 varchar)
  medstat_basedon_display varchar (200),   -- basedOn/display (100 x 2 varchar)
  medstat_status varchar (30),   -- status (30 x 1 varchar)
  medstat_statusreason_system varchar (70),   -- statusReason/coding/system (70 x 1 varchar)
  medstat_statusreason_version varchar (50),   -- statusReason/coding/version (50 x 1 varchar)
  medstat_statusreason_code varchar (30),   -- statusReason/coding/code (30 x 1 varchar)
  medstat_statusreason_display varchar (100),   -- statusReason/coding/display (100 x 1 varchar)
  medstat_statusreason_text varchar (500),   -- statusReason/text (500 x 1 varchar)
  medstat_category_system varchar (70),   -- category/coding/system (70 x 1 varchar)
  medstat_category_version varchar (50),   -- category/coding/version (50 x 1 varchar)
  medstat_category_code varchar (30),   -- category/coding/code (30 x 1 varchar)
  medstat_category_display varchar (100),   -- category/coding/display (100 x 1 varchar)
  medstat_category_text varchar (500),   -- category/text (500 x 1 varchar)
  medstat_medicationreference_id varchar (70),   -- medicationReference/reference (70 x 1 varchar)
  medstat_medicationcodeableconcept_system varchar (70),   -- medicationCodeableConcept/coding/system (70 x 1 varchar)
  medstat_medicationcodeableconcept_version varchar (50),   -- medicationCodeableConcept/coding/version (50 x 1 varchar)
  medstat_medicationcodeableconcept_code varchar (30),   -- medicationCodeableConcept/coding/code (30 x 1 varchar)
  medstat_medicationcodeableconcept_display varchar (100),   -- medicationCodeableConcept/coding/display (100 x 1 varchar)
  medstat_medicationcodeableconcept_text varchar (500),   -- medicationCodeableConcept/text (500 x 1 varchar)
  medstat_effectivedatetime varchar (30),   -- effectiveDateTime (30 x 1 varchar)
  medstat_effectiveperiod_start varchar (30),   -- effectivePeriod/start (30 x 1 varchar)
  medstat_effectiveperiod_end varchar (30),   -- effectivePeriod/end (30 x 1 varchar)
  medstat_dateasserted varchar (30),   -- dateAsserted (30 x 1 varchar)
  medstat_informationsource_id varchar (70),   -- informationSource/reference (70 x 1 varchar)
  medstat_informationsource_type varchar (30),   -- informationSource/type (30 x 1 varchar)
  medstat_informationsource_identifier_use varchar (30),   -- informationSource/identifier/use (30 x 1 varchar)
  medstat_informationsource_identifier_type_system varchar (70),   -- informationSource/identifier/type/coding/system (70 x 1 varchar)
  medstat_informationsource_identifier_type_version varchar (50),   -- informationSource/identifier/type/coding/version (50 x 1 varchar)
  medstat_informationsource_identifier_type_code varchar (30),   -- informationSource/identifier/type/coding/code (30 x 1 varchar)
  medstat_informationsource_identifier_type_display varchar (100),   -- informationSource/identifier/type/coding/display (100 x 1 varchar)
  medstat_informationsource_identifier_type_text varchar (500),   -- informationSource/identifier/type/text (500 x 1 varchar)
  medstat_informationsource_display varchar (100),   -- informationSource/display (100 x 1 varchar)
  medstat_derivedfrom_id varchar (70),   -- derivedFrom/reference (70 x 1 varchar)
  medstat_derivedfrom_type varchar (30),   -- derivedFrom/type (30 x 1 varchar)
  medstat_derivedfrom_identifier_use varchar (30),   -- derivedFrom/identifier/use (30 x 1 varchar)
  medstat_derivedfrom_identifier_type_system varchar (70),   -- derivedFrom/identifier/type/coding/system (70 x 1 varchar)
  medstat_derivedfrom_identifier_type_version varchar (50),   -- derivedFrom/identifier/type/coding/version (50 x 1 varchar)
  medstat_derivedfrom_identifier_type_code varchar (30),   -- derivedFrom/identifier/type/coding/code (30 x 1 varchar)
  medstat_derivedfrom_identifier_type_display varchar (100),   -- derivedFrom/identifier/type/coding/display (100 x 1 varchar)
  medstat_derivedfrom_identifier_type_text varchar (500),   -- derivedFrom/identifier/type/text (500 x 1 varchar)
  medstat_derivedfrom_display varchar (100),   -- derivedFrom/display (100 x 1 varchar)
  medstat_reasoncode_system varchar (70),   -- reasonCode/coding/system (70 x 1 varchar)
  medstat_reasoncode_version varchar (50),   -- reasonCode/coding/version (50 x 1 varchar)
  medstat_reasoncode_code varchar (30),   -- reasonCode/coding/code (30 x 1 varchar)
  medstat_reasoncode_display varchar (100),   -- reasonCode/coding/display (100 x 1 varchar)
  medstat_reasoncode_text varchar (500),   -- reasonCode/text (500 x 1 varchar)
  medstat_reasonreference_id varchar (210),   -- reasonReference/reference (70 x 3 varchar)
  medstat_reasonreference_type varchar (90),   -- reasonReference/type (30 x 3 varchar)
  medstat_reasonreference_identifier_use varchar (90),   -- reasonReference/identifier/use (30 x 3 varchar)
  medstat_reasonreference_identifier_type_system varchar (630),   -- reasonReference/identifier/type/coding/system (70 x 9 varchar)
  medstat_reasonreference_identifier_type_version varchar (450),   -- reasonReference/identifier/type/coding/version (50 x 9 varchar)
  medstat_reasonreference_identifier_type_code varchar (270),   -- reasonReference/identifier/type/coding/code (30 x 9 varchar)
  medstat_reasonreference_identifier_type_display varchar (900),   -- reasonReference/identifier/type/coding/display (100 x 9 varchar)
  medstat_reasonreference_identifier_type_text varchar (1500),   -- reasonReference/identifier/type/text (500 x 3 varchar)
  medstat_reasonreference_display varchar (300),   -- reasonReference/display (100 x 3 varchar)
  medstat_note_authorstring varchar (300),   -- note/authorString (50 x 6 varchar)
  medstat_note_authorreference_id varchar (420),   -- note/authorReference/reference (70 x 6 varchar)
  medstat_note_authorreference_type varchar (180),   -- note/authorReference/type (30 x 6 varchar)
  medstat_note_authorreference_identifier_use varchar (180),   -- note/authorReference/identifier/use (30 x 6 varchar)
  medstat_note_authorreference_identifier_type_system varchar (1260),   -- note/authorReference/identifier/type/coding/system (70 x 18 varchar)
  medstat_note_authorreference_identifier_type_version varchar (900),   -- note/authorReference/identifier/type/coding/version (50 x 18 varchar)
  medstat_note_authorreference_identifier_type_code varchar (540),   -- note/authorReference/identifier/type/coding/code (30 x 18 varchar)
  medstat_note_authorreference_identifier_type_display varchar (1800),   -- note/authorReference/identifier/type/coding/display (100 x 18 varchar)
  medstat_note_authorreference_identifier_type_text varchar (3000),   -- note/authorReference/identifier/type/text (500 x 6 varchar)
  medstat_note_authorreference_display varchar (600),   -- note/authorReference/display (100 x 6 varchar)
  medstat_note_time varchar (60),   -- note/time (30 x 2 varchar)
  medstat_note_text varchar (10000),   -- note/text (5000 x 2 varchar)
  medstat_dosage_sequence varchar (20),   -- dosage/sequence (10 x 2 varchar)
  medstat_dosage_text varchar (1000),   -- dosage/text (500 x 2 varchar)
  medstat_dosage_additionalinstruction_system varchar (840),   -- dosage/additionalInstruction/coding/system (70 x 12 varchar)
  medstat_dosage_additionalinstruction_version varchar (600),   -- dosage/additionalInstruction/coding/version (50 x 12 varchar)
  medstat_dosage_additionalinstruction_code varchar (360),   -- dosage/additionalInstruction/coding/code (30 x 12 varchar)
  medstat_dosage_additionalinstruction_display varchar (1200),   -- dosage/additionalInstruction/coding/display (100 x 12 varchar)
  medstat_dosage_additionalinstruction_text varchar (2000),   -- dosage/additionalInstruction/text (500 x 4 varchar)
  medstat_dosage_patientinstruction varchar (200),   -- dosage/patientInstruction (100 x 2 varchar)
  medstat_dosage_timing_event varchar (240),   -- dosage/timing/event (30 x 8 varchar)
  medstat_dosage_timing_repeat_boundsduration_value varchar (60),   -- dosage/timing/repeat/boundsDuration/value (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsduration_comparator varchar (20),   -- dosage/timing/repeat/boundsDuration/comparator (10 x 2 varchar)
  medstat_dosage_timing_repeat_boundsduration_unit varchar (60),   -- dosage/timing/repeat/boundsDuration/unit (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsduration_system varchar (140),   -- dosage/timing/repeat/boundsDuration/system (70 x 2 varchar)
  medstat_dosage_timing_repeat_boundsduration_code varchar (60),   -- dosage/timing/repeat/boundsDuration/code (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_value varchar (20),   -- dosage/timing/repeat/boundsRange/low/value (10 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_unit varchar (60),   -- dosage/timing/repeat/boundsRange/low/unit (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_system varchar (140),   -- dosage/timing/repeat/boundsRange/low/system (70 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_low_code varchar (60),   -- dosage/timing/repeat/boundsRange/low/code (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_value varchar (20),   -- dosage/timing/repeat/boundsRange/high/value (10 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_unit varchar (60),   -- dosage/timing/repeat/boundsRange/high/unit (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_system varchar (140),   -- dosage/timing/repeat/boundsRange/high/system (70 x 2 varchar)
  medstat_dosage_timing_repeat_boundsrange_high_code varchar (60),   -- dosage/timing/repeat/boundsRange/high/code (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsperiod_start varchar (60),   -- dosage/timing/repeat/boundsPeriod/start (30 x 2 varchar)
  medstat_dosage_timing_repeat_boundsperiod_end varchar (60),   -- dosage/timing/repeat/boundsPeriod/end (30 x 2 varchar)
  medstat_dosage_timing_repeat_count varchar (20),   -- dosage/timing/repeat/count (10 x 2 varchar)
  medstat_dosage_timing_repeat_countmax varchar (20),   -- dosage/timing/repeat/countMax (10 x 2 varchar)
  medstat_dosage_timing_repeat_duration varchar (20),   -- dosage/timing/repeat/duration (10 x 2 varchar)
  medstat_dosage_timing_repeat_durationmax varchar (20),   -- dosage/timing/repeat/durationMax (10 x 2 varchar)
  medstat_dosage_timing_repeat_durationunit varchar (40),   -- dosage/timing/repeat/durationUnit (20 x 2 varchar)
  medstat_dosage_timing_repeat_frequency varchar (20),   -- dosage/timing/repeat/frequency (10 x 2 varchar)
  medstat_dosage_timing_repeat_frequencymax varchar (20),   -- dosage/timing/repeat/frequencyMax (10 x 2 varchar)
  medstat_dosage_timing_repeat_period varchar (20),   -- dosage/timing/repeat/period (10 x 2 varchar)
  medstat_dosage_timing_repeat_periodmax varchar (20),   -- dosage/timing/repeat/periodMax (10 x 2 varchar)
  medstat_dosage_timing_repeat_periodunit varchar (40),   -- dosage/timing/repeat/periodUnit (20 x 2 varchar)
  medstat_dosage_timing_repeat_dayofweek varchar (140),   -- dosage/timing/repeat/dayOfWeek (10 x 14 varchar)
  medstat_dosage_timing_repeat_timeofday varchar (160),   -- dosage/timing/repeat/timeOfDay (20 x 8 varchar)
  medstat_dosage_timing_repeat_when varchar (160),   -- dosage/timing/repeat/when (20 x 8 varchar)
  medstat_dosage_timing_repeat_offset varchar (20),   -- dosage/timing/repeat/offset (10 x 2 varchar)
  medstat_dosage_timing_code_system varchar (420),   -- dosage/timing/code/coding/system (70 x 6 varchar)
  medstat_dosage_timing_code_version varchar (300),   -- dosage/timing/code/coding/version (50 x 6 varchar)
  medstat_dosage_timing_code_code varchar (180),   -- dosage/timing/code/coding/code (30 x 6 varchar)
  medstat_dosage_timing_code_display varchar (600),   -- dosage/timing/code/coding/display (100 x 6 varchar)
  medstat_dosage_timing_code_text varchar (1000),   -- dosage/timing/code/text (500 x 2 varchar)
  medstat_dosage_asneededboolean varchar (20),   -- dosage/asNeededBoolean (10 x 2 varchar)
  medstat_dosage_asneededcodeableconcept_system varchar (420),   -- dosage/asNeededCodeableConcept/coding/system (70 x 6 varchar)
  medstat_dosage_asneededcodeableconcept_version varchar (300),   -- dosage/asNeededCodeableConcept/coding/version (50 x 6 varchar)
  medstat_dosage_asneededcodeableconcept_code varchar (180),   -- dosage/asNeededCodeableConcept/coding/code (30 x 6 varchar)
  medstat_dosage_asneededcodeableconcept_display varchar (600),   -- dosage/asNeededCodeableConcept/coding/display (100 x 6 varchar)
  medstat_dosage_asneededcodeableconcept_text varchar (1000),   -- dosage/asNeededCodeableConcept/text (500 x 2 varchar)
  medstat_dosage_site_system varchar (420),   -- dosage/site/coding/system (70 x 6 varchar)
  medstat_dosage_site_version varchar (300),   -- dosage/site/coding/version (50 x 6 varchar)
  medstat_dosage_site_code varchar (180),   -- dosage/site/coding/code (30 x 6 varchar)
  medstat_dosage_site_display varchar (600),   -- dosage/site/coding/display (100 x 6 varchar)
  medstat_dosage_site_text varchar (1000),   -- dosage/site/text (500 x 2 varchar)
  medstat_dosage_route_system varchar (420),   -- dosage/route/coding/system (70 x 6 varchar)
  medstat_dosage_route_version varchar (300),   -- dosage/route/coding/version (50 x 6 varchar)
  medstat_dosage_route_code varchar (180),   -- dosage/route/coding/code (30 x 6 varchar)
  medstat_dosage_route_display varchar (600),   -- dosage/route/coding/display (100 x 6 varchar)
  medstat_dosage_route_text varchar (1000),   -- dosage/route/text (500 x 2 varchar)
  medstat_dosage_method_system varchar (420),   -- dosage/method/coding/system (70 x 6 varchar)
  medstat_dosage_method_version varchar (300),   -- dosage/method/coding/version (50 x 6 varchar)
  medstat_dosage_method_code varchar (180),   -- dosage/method/coding/code (30 x 6 varchar)
  medstat_dosage_method_display varchar (600),   -- dosage/method/coding/display (100 x 6 varchar)
  medstat_dosage_method_text varchar (1000),   -- dosage/method/text (500 x 2 varchar)
  medstat_dosage_doseandrate_type_system varchar (420),   -- dosage/doseAndRate/type/coding/system (70 x 6 varchar)
  medstat_dosage_doseandrate_type_version varchar (300),   -- dosage/doseAndRate/type/coding/version (50 x 6 varchar)
  medstat_dosage_doseandrate_type_code varchar (180),   -- dosage/doseAndRate/type/coding/code (30 x 6 varchar)
  medstat_dosage_doseandrate_type_display varchar (600),   -- dosage/doseAndRate/type/coding/display (100 x 6 varchar)
  medstat_dosage_doseandrate_type_text varchar (1000),   -- dosage/doseAndRate/type/text (500 x 2 varchar)
  medstat_dosage_doseandrate_doserange_low_value varchar (20),   -- dosage/doseAndRate/doseRange/low/value (10 x 2 varchar)
  medstat_dosage_doseandrate_doserange_low_unit varchar (60),   -- dosage/doseAndRate/doseRange/low/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_doserange_low_system varchar (140),   -- dosage/doseAndRate/doseRange/low/system (70 x 2 varchar)
  medstat_dosage_doseandrate_doserange_low_code varchar (60),   -- dosage/doseAndRate/doseRange/low/code (30 x 2 varchar)
  medstat_dosage_doseandrate_doserange_high_value varchar (20),   -- dosage/doseAndRate/doseRange/high/value (10 x 2 varchar)
  medstat_dosage_doseandrate_doserange_high_unit varchar (60),   -- dosage/doseAndRate/doseRange/high/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_doserange_high_system varchar (140),   -- dosage/doseAndRate/doseRange/high/system (70 x 2 varchar)
  medstat_dosage_doseandrate_doserange_high_code varchar (60),   -- dosage/doseAndRate/doseRange/high/code (30 x 2 varchar)
  medstat_dosage_doseandrate_dosequantity_value varchar (20),   -- dosage/doseAndRate/doseQuantity/value (10 x 2 varchar)
  medstat_dosage_doseandrate_dosequantity_comparator varchar (20),   -- dosage/doseAndRate/doseQuantity/comparator (10 x 2 varchar)
  medstat_dosage_doseandrate_dosequantity_unit varchar (60),   -- dosage/doseAndRate/doseQuantity/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_dosequantity_system varchar (140),   -- dosage/doseAndRate/doseQuantity/system (70 x 2 varchar)
  medstat_dosage_doseandrate_dosequantity_code varchar (60),   -- dosage/doseAndRate/doseQuantity/code (30 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_value varchar (20),   -- dosage/doseAndRate/rateRatio/numerator/value (10 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_comparator varchar (20),   -- dosage/doseAndRate/rateRatio/numerator/comparator (10 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_unit varchar (60),   -- dosage/doseAndRate/rateRatio/numerator/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_system varchar (140),   -- dosage/doseAndRate/rateRatio/numerator/system (70 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_numerator_code varchar (60),   -- dosage/doseAndRate/rateRatio/numerator/code (30 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_value varchar (20),   -- dosage/doseAndRate/rateRatio/denominator/value (10 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_comparator varchar (20),   -- dosage/doseAndRate/rateRatio/denominator/comparator (10 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_unit varchar (60),   -- dosage/doseAndRate/rateRatio/denominator/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_system varchar (140),   -- dosage/doseAndRate/rateRatio/denominator/system (70 x 2 varchar)
  medstat_dosage_doseandrate_rateratio_denominator_code varchar (60),   -- dosage/doseAndRate/rateRatio/denominator/code (30 x 2 varchar)
  medstat_dosage_doseandrate_raterange_low_value varchar (20),   -- dosage/doseAndRate/rateRange/low/value (10 x 2 varchar)
  medstat_dosage_doseandrate_raterange_low_unit varchar (60),   -- dosage/doseAndRate/rateRange/low/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_raterange_low_system varchar (140),   -- dosage/doseAndRate/rateRange/low/system (70 x 2 varchar)
  medstat_dosage_doseandrate_raterange_low_code varchar (60),   -- dosage/doseAndRate/rateRange/low/code (30 x 2 varchar)
  medstat_dosage_doseandrate_raterange_high_value varchar (20),   -- dosage/doseAndRate/rateRange/high/value (10 x 2 varchar)
  medstat_dosage_doseandrate_raterange_high_unit varchar (60),   -- dosage/doseAndRate/rateRange/high/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_raterange_high_system varchar (140),   -- dosage/doseAndRate/rateRange/high/system (70 x 2 varchar)
  medstat_dosage_doseandrate_raterange_high_code varchar (60),   -- dosage/doseAndRate/rateRange/high/code (30 x 2 varchar)
  medstat_dosage_doseandrate_ratequantity_value varchar (20),   -- dosage/doseAndRate/rateQuantity/value (10 x 2 varchar)
  medstat_dosage_doseandrate_ratequantity_unit varchar (60),   -- dosage/doseAndRate/rateQuantity/unit (30 x 2 varchar)
  medstat_dosage_doseandrate_ratequantity_system varchar (140),   -- dosage/doseAndRate/rateQuantity/system (70 x 2 varchar)
  medstat_dosage_doseandrate_ratequantity_code varchar (60),   -- dosage/doseAndRate/rateQuantity/code (30 x 2 varchar)
  medstat_dosage_maxdoseperperiod_numerator_value varchar (20),   -- dosage/maxDosePerPeriod/numerator/value (10 x 2 varchar)
  medstat_dosage_maxdoseperperiod_numerator_comparator varchar (20),   -- dosage/maxDosePerPeriod/numerator/comparator (10 x 2 varchar)
  medstat_dosage_maxdoseperperiod_numerator_unit varchar (60),   -- dosage/maxDosePerPeriod/numerator/unit (30 x 2 varchar)
  medstat_dosage_maxdoseperperiod_numerator_system varchar (140),   -- dosage/maxDosePerPeriod/numerator/system (70 x 2 varchar)
  medstat_dosage_maxdoseperperiod_numerator_code varchar (60),   -- dosage/maxDosePerPeriod/numerator/code (30 x 2 varchar)
  medstat_dosage_maxdoseperperiod_denominator_value varchar (20),   -- dosage/maxDosePerPeriod/denominator/value (10 x 2 varchar)
  medstat_dosage_maxdoseperperiod_denominator_comparator varchar (20),   -- dosage/maxDosePerPeriod/denominator/comparator (10 x 2 varchar)
  medstat_dosage_maxdoseperperiod_denominator_unit varchar (60),   -- dosage/maxDosePerPeriod/denominator/unit (30 x 2 varchar)
  medstat_dosage_maxdoseperperiod_denominator_system varchar (140),   -- dosage/maxDosePerPeriod/denominator/system (70 x 2 varchar)
  medstat_dosage_maxdoseperperiod_denominator_code varchar (60),   -- dosage/maxDosePerPeriod/denominator/code (30 x 2 varchar)
  medstat_dosage_maxdoseperadministration_value varchar (20),   -- dosage/maxDosePerAdministration/value (10 x 2 varchar)
  medstat_dosage_maxdoseperadministration_unit varchar (60),   -- dosage/maxDosePerAdministration/unit (30 x 2 varchar)
  medstat_dosage_maxdoseperadministration_system varchar (140),   -- dosage/maxDosePerAdministration/system (70 x 2 varchar)
  medstat_dosage_maxdoseperadministration_code varchar (60),   -- dosage/maxDosePerAdministration/code (30 x 2 varchar)
  medstat_dosage_maxdoseperlifetime_value varchar (20),   -- dosage/maxDosePerLifetime/value (10 x 2 varchar)
  medstat_dosage_maxdoseperlifetime_unit varchar (60),   -- dosage/maxDosePerLifetime/unit (30 x 2 varchar)
  medstat_dosage_maxdoseperlifetime_system varchar (140),   -- dosage/maxDosePerLifetime/system (70 x 2 varchar)
  medstat_dosage_maxdoseperlifetime_code varchar (60),   -- dosage/maxDosePerLifetime/code (30 x 2 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.observation_raw (
  observation_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  obs_id varchar (70),   -- id (70 x 1 varchar)
  obs_encounter_id varchar (70),   -- encounter/reference (70 x 1 varchar)
  obs_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  obs_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
  obs_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  obs_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  obs_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  obs_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  obs_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  obs_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  obs_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  obs_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  obs_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  obs_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  obs_basedon_id varchar (70),   -- basedOn/reference (70 x 1 varchar)
  obs_basedon_type varchar (30),   -- basedOn/type (30 x 1 varchar)
  obs_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 x 1 varchar)
  obs_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 x 1 varchar)
  obs_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 x 1 varchar)
  obs_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 x 1 varchar)
  obs_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 x 1 varchar)
  obs_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 x 1 varchar)
  obs_basedon_display varchar (100),   -- basedOn/display (100 x 1 varchar)
  obs_status varchar (30),   -- status (30 x 1 varchar)
  obs_category_system varchar (70),   -- category/coding/system (70 x 1 varchar)
  obs_category_version varchar (50),   -- category/coding/version (50 x 1 varchar)
  obs_category_code varchar (30),   -- category/coding/code (30 x 1 varchar)
  obs_category_display varchar (100),   -- category/coding/display (100 x 1 varchar)
  obs_category_text varchar (500),   -- category/text (500 x 1 varchar)
  obs_code_system varchar (70),   -- code/coding/system (70 x 1 varchar)
  obs_code_version varchar (50),   -- code/coding/version (50 x 1 varchar)
  obs_code_code varchar (30),   -- code/coding/code (30 x 1 varchar)
  obs_code_display varchar (100),   -- code/coding/display (100 x 1 varchar)
  obs_code_text varchar (500),   -- code/text (500 x 1 varchar)
  obs_effectivedatetime varchar (30),   -- effectiveDateTime (30 x 1 varchar)
  obs_issued varchar (30),   -- issued (30 x 1 varchar)
  obs_valuerange_low_value varchar (20),   -- valueRange/low/value (10 x 2 varchar)
  obs_valuerange_low_unit varchar (60),   -- valueRange/low/unit (30 x 2 varchar)
  obs_valuerange_low_system varchar (140),   -- valueRange/low/system (70 x 2 varchar)
  obs_valuerange_low_code varchar (60),   -- valueRange/low/code (30 x 2 varchar)
  obs_valuerange_high_value varchar (20),   -- valueRange/high/value (10 x 2 varchar)
  obs_valuerange_high_unit varchar (60),   -- valueRange/high/unit (30 x 2 varchar)
  obs_valuerange_high_system varchar (140),   -- valueRange/high/system (70 x 2 varchar)
  obs_valuerange_high_code varchar (60),   -- valueRange/high/code (30 x 2 varchar)
  obs_valueratio_numerator_value varchar (20),   -- valueRatio/numerator/value (10 x 2 varchar)
  obs_valueratio_numerator_comparator varchar (20),   -- valueRatio/numerator/comparator (10 x 2 varchar)
  obs_valueratio_numerator_unit varchar (60),   -- valueRatio/numerator/unit (30 x 2 varchar)
  obs_valueratio_numerator_system varchar (140),   -- valueRatio/numerator/system (70 x 2 varchar)
  obs_valueratio_numerator_code varchar (60),   -- valueRatio/numerator/code (30 x 2 varchar)
  obs_valueratio_denominator_value varchar (20),   -- valueRatio/denominator/value (10 x 2 varchar)
  obs_valueratio_denominator_comparator varchar (20),   -- valueRatio/denominator/comparator (10 x 2 varchar)
  obs_valueratio_denominator_unit varchar (60),   -- valueRatio/denominator/unit (30 x 2 varchar)
  obs_valueratio_denominator_system varchar (140),   -- valueRatio/denominator/system (70 x 2 varchar)
  obs_valueratio_denominator_code varchar (60),   -- valueRatio/denominator/code (30 x 2 varchar)
  obs_valuequantity_value varchar (20),   -- valueQuantity/value (10 x 2 varchar)
  obs_valuequantity_comparator varchar (20),   -- valueQuantity/comparator (10 x 2 varchar)
  obs_valuequantity_unit varchar (60),   -- valueQuantity/unit (30 x 2 varchar)
  obs_valuequantity_system varchar (140),   -- valueQuantity/system (70 x 2 varchar)
  obs_valuequantity_code varchar (60),   -- valueQuantity/code (30 x 2 varchar)
  obs_valuecodableconcept_system varchar (420),   -- valueCodableConcept/coding/system (70 x 6 varchar)
  obs_valuecodableconcept_version varchar (300),   -- valueCodableConcept/coding/version (50 x 6 varchar)
  obs_valuecodableconcept_code varchar (180),   -- valueCodableConcept/coding/code (30 x 6 varchar)
  obs_valuecodableconcept_display varchar (600),   -- valueCodableConcept/coding/display (100 x 6 varchar)
  obs_valuecodableconcept_text varchar (1000),   -- valueCodableConcept/text (500 x 2 varchar)
  obs_dataabsentreason_system varchar (70),   -- dataAbsentReason/coding/system (70 x 1 varchar)
  obs_dataabsentreason_version varchar (50),   -- dataAbsentReason/coding/version (50 x 1 varchar)
  obs_dataabsentreason_code varchar (30),   -- dataAbsentReason/coding/code (30 x 1 varchar)
  obs_dataabsentreason_display varchar (100),   -- dataAbsentReason/coding/display (100 x 1 varchar)
  obs_dataabsentreason_text varchar (500),   -- dataAbsentReason/text (500 x 1 varchar)
  obs_note_authorstring varchar (50),   -- note/authorString (50 x 1 varchar)
  obs_note_authorreference_id varchar (70),   -- note/authorReference/reference (70 x 1 varchar)
  obs_note_authorreference_type varchar (30),   -- note/authorReference/type (30 x 1 varchar)
  obs_note_authorreference_identifier_use varchar (30),   -- note/authorReference/identifier/use (30 x 1 varchar)
  obs_note_authorreference_identifier_type_system varchar (70),   -- note/authorReference/identifier/type/coding/system (70 x 1 varchar)
  obs_note_authorreference_identifier_type_version varchar (50),   -- note/authorReference/identifier/type/coding/version (50 x 1 varchar)
  obs_note_authorreference_identifier_type_code varchar (30),   -- note/authorReference/identifier/type/coding/code (30 x 1 varchar)
  obs_note_authorreference_identifier_type_display varchar (100),   -- note/authorReference/identifier/type/coding/display (100 x 1 varchar)
  obs_note_authorreference_identifier_type_text varchar (500),   -- note/authorReference/identifier/type/text (500 x 1 varchar)
  obs_note_authorreference_display varchar (100),   -- note/authorReference/display (100 x 1 varchar)
  obs_note_time varchar (30),   -- note/time (30 x 1 varchar)
  obs_note_text varchar (5000),   -- note/text (5000 x 1 varchar)
  obs_method_system varchar (70),   -- method/coding/system (70 x 1 varchar)
  obs_method_version varchar (50),   -- method/coding/version (50 x 1 varchar)
  obs_method_code varchar (30),   -- method/coding/code (30 x 1 varchar)
  obs_method_display varchar (100),   -- method/coding/display (100 x 1 varchar)
  obs_method_text varchar (500),   -- method/text (500 x 1 varchar)
  obs_performer_id varchar (70),   -- performer/reference (70 x 1 varchar)
  obs_performer_type varchar (30),   -- performer/type (30 x 1 varchar)
  obs_performer_identifier_use varchar (30),   -- performer/identifier/use (30 x 1 varchar)
  obs_performer_identifier_type_system varchar (70),   -- performer/identifier/type/coding/system (70 x 1 varchar)
  obs_performer_identifier_type_version varchar (50),   -- performer/identifier/type/coding/version (50 x 1 varchar)
  obs_performer_identifier_type_code varchar (30),   -- performer/identifier/type/coding/code (30 x 1 varchar)
  obs_performer_identifier_type_display varchar (100),   -- performer/identifier/type/coding/display (100 x 1 varchar)
  obs_performer_identifier_type_text varchar (500),   -- performer/identifier/type/text (500 x 1 varchar)
  obs_performer_display varchar (100),   -- performer/display (100 x 1 varchar)
  obs_referencerange_low_value varchar (30),   -- referenceRange/low/value (10 x 3 varchar)
  obs_referencerange_low_unit varchar (90),   -- referenceRange/low/unit (30 x 3 varchar)
  obs_referencerange_low_system varchar (210),   -- referenceRange/low/system (70 x 3 varchar)
  obs_referencerange_low_code varchar (90),   -- referenceRange/low/code (30 x 3 varchar)
  obs_referencerange_high_value varchar (30),   -- referenceRange/high/value (10 x 3 varchar)
  obs_referencerange_high_unit varchar (90),   -- referenceRange/high/unit (30 x 3 varchar)
  obs_referencerange_high_system varchar (210),   -- referenceRange/high/system (70 x 3 varchar)
  obs_referencerange_high_code varchar (90),   -- referenceRange/high/code (30 x 3 varchar)
  obs_referencerange_type_system varchar (630),   -- referenceRange/type/coding/system (70 x 9 varchar)
  obs_referencerange_type_version varchar (450),   -- referenceRange/type/coding/version (50 x 9 varchar)
  obs_referencerange_type_code varchar (270),   -- referenceRange/type/coding/code (30 x 9 varchar)
  obs_referencerange_type_display varchar (900),   -- referenceRange/type/coding/display (100 x 9 varchar)
  obs_referencerange_type_text varchar (1500),   -- referenceRange/type/text (500 x 3 varchar)
  obs_referencerange_appliesto_system varchar (630),   -- referenceRange/appliesTo/coding/system (70 x 9 varchar)
  obs_referencerange_appliesto_version varchar (450),   -- referenceRange/appliesTo/coding/version (50 x 9 varchar)
  obs_referencerange_appliesto_code varchar (270),   -- referenceRange/appliesTo/coding/code (30 x 9 varchar)
  obs_referencerange_appliesto_display varchar (900),   -- referenceRange/appliesTo/coding/display (100 x 9 varchar)
  obs_referencerange_appliesto_text varchar (1500),   -- referenceRange/appliesTo/text (500 x 3 varchar)
  obs_referencerange_age_low_value varchar (30),   -- referenceRange/age/low/value (10 x 3 varchar)
  obs_referencerange_age_low_unit varchar (90),   -- referenceRange/age/low/unit (30 x 3 varchar)
  obs_referencerange_age_low_system varchar (210),   -- referenceRange/age/low/system (70 x 3 varchar)
  obs_referencerange_age_low_code varchar (90),   -- referenceRange/age/low/code (30 x 3 varchar)
  obs_referencerange_age_high_value varchar (30),   -- referenceRange/age/high/value (10 x 3 varchar)
  obs_referencerange_age_high_unit varchar (90),   -- referenceRange/age/high/unit (30 x 3 varchar)
  obs_referencerange_age_high_system varchar (210),   -- referenceRange/age/high/system (70 x 3 varchar)
  obs_referencerange_age_high_code varchar (90),   -- referenceRange/age/high/code (30 x 3 varchar)
  obs_referencerange_text varchar (500),   -- referenceRange/text (500 x 1 varchar)
  obs_hasmember_id varchar (70),   -- hasMember/reference (70 x 1 varchar)
  obs_hasmember_type varchar (30),   -- hasMember/type (30 x 1 varchar)
  obs_hasmember_identifier_use varchar (30),   -- hasMember/identifier/use (30 x 1 varchar)
  obs_hasmember_identifier_type_system varchar (70),   -- hasMember/identifier/type/coding/system (70 x 1 varchar)
  obs_hasmember_identifier_type_version varchar (50),   -- hasMember/identifier/type/coding/version (50 x 1 varchar)
  obs_hasmember_identifier_type_code varchar (30),   -- hasMember/identifier/type/coding/code (30 x 1 varchar)
  obs_hasmember_identifier_type_display varchar (100),   -- hasMember/identifier/type/coding/display (100 x 1 varchar)
  obs_hasmember_identifier_type_text varchar (500),   -- hasMember/identifier/type/text (500 x 1 varchar)
  obs_hasmember_display varchar (100),   -- hasMember/display (100 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.diagnosticreport_raw (
  diagnosticreport_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  diagrep_id varchar (70),   -- id (70 x 1 varchar)
  diagrep_encounter_id varchar (70),   -- encounter/reference (70 x 1 varchar)
  diagrep_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  diagrep_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
  diagrep_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  diagrep_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  diagrep_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  diagrep_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  diagrep_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  diagrep_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  diagrep_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  diagrep_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  diagrep_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  diagrep_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  diagrep_result_id varchar (70),   -- result/reference (70 x 1 varchar)
  diagrep_basedon_id varchar (70),   -- basedOn/reference (70 x 1 varchar)
  diagrep_status varchar (30),   -- status (30 x 1 varchar)
  diagrep_category_system varchar (70),   -- category/coding/system (70 x 1 varchar)
  diagrep_category_version varchar (50),   -- category/coding/version (50 x 1 varchar)
  diagrep_category_code varchar (30),   -- category/coding/code (30 x 1 varchar)
  diagrep_category_display varchar (100),   -- category/coding/display (100 x 1 varchar)
  diagrep_category_text varchar (500),   -- category/text (500 x 1 varchar)
  diagrep_code_system varchar (70),   -- code/coding/system (70 x 1 varchar)
  diagrep_code_version varchar (50),   -- code/coding/version (50 x 1 varchar)
  diagrep_code_code varchar (30),   -- code/coding/code (30 x 1 varchar)
  diagrep_code_display varchar (100),   -- code/coding/display (100 x 1 varchar)
  diagrep_code_text varchar (500),   -- code/text (500 x 1 varchar)
  diagrep_effectivedatetime varchar (30),   -- effectiveDateTime (30 x 1 varchar)
  diagrep_issued varchar (30),   -- issued (30 x 1 varchar)
  diagrep_performer_id varchar (70),   -- performer/reference (70 x 1 varchar)
  diagrep_performer_type varchar (30),   -- performer/type (30 x 1 varchar)
  diagrep_performer_identifier_use varchar (30),   -- performer/identifier/use (30 x 1 varchar)
  diagrep_performer_identifier_type_system varchar (70),   -- performer/identifier/type/coding/system (70 x 1 varchar)
  diagrep_performer_identifier_type_version varchar (50),   -- performer/identifier/type/coding/version (50 x 1 varchar)
  diagrep_performer_identifier_type_code varchar (30),   -- performer/identifier/type/coding/code (30 x 1 varchar)
  diagrep_performer_identifier_type_display varchar (100),   -- performer/identifier/type/coding/display (100 x 1 varchar)
  diagrep_performer_identifier_type_text varchar (500),   -- performer/identifier/type/text (500 x 1 varchar)
  diagrep_performer_display varchar (100),   -- performer/display (100 x 1 varchar)
  diagrep_conclusion varchar (500),   -- conclusion (500 x 1 varchar)
  diagrep_conclusioncode_system varchar (70),   -- conclusionCode/coding/system (70 x 1 varchar)
  diagrep_conclusioncode_version varchar (50),   -- conclusionCode/coding/version (50 x 1 varchar)
  diagrep_conclusioncode_code varchar (30),   -- conclusionCode/coding/code (30 x 1 varchar)
  diagrep_conclusioncode_display varchar (100),   -- conclusionCode/coding/display (100 x 1 varchar)
  diagrep_conclusioncode_text varchar (500),   -- conclusionCode/text (500 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.servicerequest_raw (
  servicerequest_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  servreq_id varchar (70),   -- id (70 x 1 varchar)
  servreq_encounter_id varchar (70),   -- encounter/reference (70 x 1 varchar)
  servreq_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  servreq_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  servreq_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  servreq_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  servreq_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  servreq_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  servreq_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  servreq_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  servreq_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  servreq_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  servreq_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  servreq_basedon_id varchar (70),   -- basedOn/reference (70 x 1 varchar)
  servreq_basedon_type varchar (30),   -- basedOn/type (30 x 1 varchar)
  servreq_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 x 1 varchar)
  servreq_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 x 1 varchar)
  servreq_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 x 1 varchar)
  servreq_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 x 1 varchar)
  servreq_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 x 1 varchar)
  servreq_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 x 1 varchar)
  servreq_basedon_display varchar (100),   -- basedOn/display (100 x 1 varchar)
  servreq_status varchar (30),   -- status (30 x 1 varchar)
  servreq_intent varchar (30),   -- intent (30 x 1 varchar)
  servreq_category_system varchar (70),   -- category/coding/system (70 x 1 varchar)
  servreq_category_version varchar (50),   -- category/coding/version (50 x 1 varchar)
  servreq_category_code varchar (30),   -- category/coding/code (30 x 1 varchar)
  servreq_category_display varchar (100),   -- category/coding/display (100 x 1 varchar)
  servreq_category_text varchar (500),   -- category/text (500 x 1 varchar)
  servreq_code_system varchar (70),   -- code/coding/system (70 x 1 varchar)
  servreq_code_version varchar (50),   -- code/coding/version (50 x 1 varchar)
  servreq_code_code varchar (30),   -- code/coding/code (30 x 1 varchar)
  servreq_code_display varchar (100),   -- code/coding/display (100 x 1 varchar)
  servreq_code_text varchar (500),   -- code/text (500 x 1 varchar)
  servreq_authoredon varchar (30),   -- authoredOn (30 x 1 varchar)
  servreq_requester_id varchar (70),   -- requester/reference (70 x 1 varchar)
  servreq_requester_type varchar (30),   -- requester/type (30 x 1 varchar)
  servreq_requester_identifier_use varchar (30),   -- requester/identifier/use (30 x 1 varchar)
  servreq_requester_identifier_type_system varchar (70),   -- requester/identifier/type/coding/system (70 x 1 varchar)
  servreq_requester_identifier_type_version varchar (50),   -- requester/identifier/type/coding/version (50 x 1 varchar)
  servreq_requester_identifier_type_code varchar (30),   -- requester/identifier/type/coding/code (30 x 1 varchar)
  servreq_requester_identifier_type_display varchar (100),   -- requester/identifier/type/coding/display (100 x 1 varchar)
  servreq_requester_identifier_type_text varchar (500),   -- requester/identifier/type/text (500 x 1 varchar)
  servreq_requester_display varchar (100),   -- requester/display (100 x 1 varchar)
  servreq_performer_id varchar (70),   -- performer/reference (70 x 1 varchar)
  servreq_performer_type varchar (30),   -- performer/type (30 x 1 varchar)
  servreq_performer_identifier_use varchar (30),   -- performer/identifier/use (30 x 1 varchar)
  servreq_performer_identifier_type_system varchar (70),   -- performer/identifier/type/coding/system (70 x 1 varchar)
  servreq_performer_identifier_type_version varchar (50),   -- performer/identifier/type/coding/version (50 x 1 varchar)
  servreq_performer_identifier_type_code varchar (30),   -- performer/identifier/type/coding/code (30 x 1 varchar)
  servreq_performer_identifier_type_display varchar (100),   -- performer/identifier/type/coding/display (100 x 1 varchar)
  servreq_performer_identifier_type_text varchar (500),   -- performer/identifier/type/text (500 x 1 varchar)
  servreq_performer_display varchar (100),   -- performer/display (100 x 1 varchar)
  servreq_locationcode_system varchar (70),   -- locationCode/coding/system (70 x 1 varchar)
  servreq_locationcode_version varchar (50),   -- locationCode/coding/version (50 x 1 varchar)
  servreq_locationcode_code varchar (30),   -- locationCode/coding/code (30 x 1 varchar)
  servreq_locationcode_display varchar (100),   -- locationCode/coding/display (100 x 1 varchar)
  servreq_locationcode_text varchar (500),   -- locationCode/text (500 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.procedure_raw (
  procedure_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  proc_id varchar (70),   -- id (70 x 1 varchar)
  proc_encounter_id varchar (70),   -- encounter/reference (70 x 1 varchar)
  proc_patient_id varchar (70),   -- subject/reference (70 x 1 varchar)
  proc_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
  proc_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  proc_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  proc_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  proc_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  proc_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  proc_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  proc_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  proc_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  proc_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  proc_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  proc_basedon_id varchar (70),   -- basedOn/reference (70 x 1 varchar)
  proc_basedon_type varchar (30),   -- basedOn/type (30 x 1 varchar)
  proc_basedon_identifier_use varchar (30),   -- basedOn/identifier/use (30 x 1 varchar)
  proc_basedon_identifier_type_system varchar (70),   -- basedOn/identifier/type/coding/system (70 x 1 varchar)
  proc_basedon_identifier_type_version varchar (50),   -- basedOn/identifier/type/coding/version (50 x 1 varchar)
  proc_basedon_identifier_type_code varchar (30),   -- basedOn/identifier/type/coding/code (30 x 1 varchar)
  proc_basedon_identifier_type_display varchar (100),   -- basedOn/identifier/type/coding/display (100 x 1 varchar)
  proc_basedon_identifier_type_text varchar (500),   -- basedOn/identifier/type/text (500 x 1 varchar)
  proc_basedon_display varchar (100),   -- basedOn/display (100 x 1 varchar)
  proc_status varchar (30),   -- status (30 x 1 varchar)
  proc_statusreason_system varchar (70),   -- statusReason/coding/system (70 x 1 varchar)
  proc_statusreason_version varchar (50),   -- statusReason/coding/version (50 x 1 varchar)
  proc_statusreason_code varchar (30),   -- statusReason/coding/code (30 x 1 varchar)
  proc_statusreason_display varchar (100),   -- statusReason/coding/display (100 x 1 varchar)
  proc_statusreason_text varchar (500),   -- statusReason/text (500 x 1 varchar)
  proc_category_system varchar (70),   -- category/coding/system (70 x 1 varchar)
  proc_category_version varchar (50),   -- category/coding/version (50 x 1 varchar)
  proc_category_code varchar (30),   -- category/coding/code (30 x 1 varchar)
  proc_category_display varchar (100),   -- category/coding/display (100 x 1 varchar)
  proc_category_text varchar (500),   -- category/text (500 x 1 varchar)
  proc_code_system varchar (70),   -- code/coding/system (70 x 1 varchar)
  proc_code_version varchar (50),   -- code/coding/version (50 x 1 varchar)
  proc_code_code varchar (30),   -- code/coding/code (30 x 1 varchar)
  proc_code_display varchar (100),   -- code/coding/display (100 x 1 varchar)
  proc_code_text varchar (500),   -- code/text (500 x 1 varchar)
  proc_performeddatetime varchar (30),   -- performedDateTime (30 x 1 varchar)
  proc_performedperiod_start varchar (30),   -- performedPeriod/start (30 x 1 varchar)
  proc_performedperiod_end varchar (30),   -- performedPeriod/end (30 x 1 varchar)
  proc_reasoncode_system varchar (70),   -- reasonCode/coding/system (70 x 1 varchar)
  proc_reasoncode_version varchar (50),   -- reasonCode/coding/version (50 x 1 varchar)
  proc_reasoncode_code varchar (30),   -- reasonCode/coding/code (30 x 1 varchar)
  proc_reasoncode_display varchar (100),   -- reasonCode/coding/display (100 x 1 varchar)
  proc_reasoncode_text varchar (500),   -- reasonCode/text (500 x 1 varchar)
  proc_reasonreference_id varchar (70),   -- reasonReference/reference (70 x 1 varchar)
  proc_reasonreference_type varchar (30),   -- reasonReference/type (30 x 1 varchar)
  proc_reasonreference_identifier_use varchar (30),   -- reasonReference/identifier/use (30 x 1 varchar)
  proc_reasonreference_identifier_type_system varchar (70),   -- reasonReference/identifier/type/coding/system (70 x 1 varchar)
  proc_reasonreference_identifier_type_version varchar (50),   -- reasonReference/identifier/type/coding/version (50 x 1 varchar)
  proc_reasonreference_identifier_type_code varchar (30),   -- reasonReference/identifier/type/coding/code (30 x 1 varchar)
  proc_reasonreference_identifier_type_display varchar (100),   -- reasonReference/identifier/type/coding/display (100 x 1 varchar)
  proc_reasonreference_identifier_type_text varchar (500),   -- reasonReference/identifier/type/text (500 x 1 varchar)
  proc_reasonreference_display varchar (100),   -- reasonReference/display (100 x 1 varchar)
  proc_note_authorstring varchar (300),   -- note/authorString (50 x 6 varchar)
  proc_note_authorreference_id varchar (420),   -- note/authorReference/reference (70 x 6 varchar)
  proc_note_authorreference_type varchar (180),   -- note/authorReference/type (30 x 6 varchar)
  proc_note_authorreference_identifier_use varchar (180),   -- note/authorReference/identifier/use (30 x 6 varchar)
  proc_note_authorreference_identifier_type_system varchar (1260),   -- note/authorReference/identifier/type/coding/system (70 x 18 varchar)
  proc_note_authorreference_identifier_type_version varchar (900),   -- note/authorReference/identifier/type/coding/version (50 x 18 varchar)
  proc_note_authorreference_identifier_type_code varchar (540),   -- note/authorReference/identifier/type/coding/code (30 x 18 varchar)
  proc_note_authorreference_identifier_type_display varchar (1800),   -- note/authorReference/identifier/type/coding/display (100 x 18 varchar)
  proc_note_authorreference_identifier_type_text varchar (3000),   -- note/authorReference/identifier/type/text (500 x 6 varchar)
  proc_note_authorreference_display varchar (600),   -- note/authorReference/display (100 x 6 varchar)
  proc_note_time varchar (60),   -- note/time (30 x 2 varchar)
  proc_note_text varchar (10000),   -- note/text (5000 x 2 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.consent_raw (
  consent_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  cons_id varchar (70),   -- id (70 x 1 varchar)
  cons_patient_id varchar (70),   -- patient/reference (70 x 1 varchar)
  cons_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  cons_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  cons_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  cons_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  cons_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  cons_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  cons_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  cons_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  cons_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  cons_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  cons_status varchar (30),   -- status (30 x 1 varchar)
  cons_scope_system varchar (70),   -- scope/coding/system (70 x 1 varchar)
  cons_scope_version varchar (50),   -- scope/coding/version (50 x 1 varchar)
  cons_scope_code varchar (30),   -- scope/coding/code (30 x 1 varchar)
  cons_scope_display varchar (100),   -- scope/coding/display (100 x 1 varchar)
  cons_scope_text varchar (500),   -- scope/text (500 x 1 varchar)
  cons_datetime varchar (30),   -- dateTime (30 x 1 varchar)
  cons_provision_type varchar (10),   -- provision/type (10 x 1 varchar)
  cons_provision_period_start varchar (30),   -- provision/period/start (30 x 1 varchar)
  cons_provision_period_end varchar (30),   -- provision/period/end (30 x 1 varchar)
  cons_provision_actor_role_system varchar (70),   -- provision/actor/role/coding/system (70 x 1 varchar)
  cons_provision_actor_role_version varchar (50),   -- provision/actor/role/coding/version (50 x 1 varchar)
  cons_provision_actor_role_code varchar (30),   -- provision/actor/role/coding/code (30 x 1 varchar)
  cons_provision_actor_role_display varchar (100),   -- provision/actor/role/coding/display (100 x 1 varchar)
  cons_provision_actor_role_text varchar (500),   -- provision/actor/role/text (500 x 1 varchar)
  cons_provision_code_system varchar (70),   -- provision/code/coding/system (70 x 1 varchar)
  cons_provision_code_version varchar (50),   -- provision/code/coding/version (50 x 1 varchar)
  cons_provision_code_code varchar (30),   -- provision/code/coding/code (30 x 1 varchar)
  cons_provision_code_display varchar (100),   -- provision/code/coding/display (100 x 1 varchar)
  cons_provision_code_text varchar (500),   -- provision/code/text (500 x 1 varchar)
  cons_provision_dataperiod_start varchar (30),   -- provision/dataPeriod/start (30 x 1 varchar)
  cons_provision_dataperiod_end varchar (30),   -- provision/dataPeriod/end (30 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.location_raw (
  location_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  loc_id varchar (70),   -- id (70 x 1 varchar)
  loc_identifier_use varchar (100),   -- identifier/use (50 x 2 varchar)
  loc_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 varchar)
  loc_identifier_type_version varchar (300),   -- identifier/type/coding/version (50 x 6 varchar)
  loc_identifier_type_code varchar (180),   -- identifier/type/coding/code (30 x 6 varchar)
  loc_identifier_type_display varchar (600),   -- identifier/type/coding/display (100 x 6 varchar)
  loc_identifier_type_text varchar (1000),   -- identifier/type/text (500 x 2 varchar)
  loc_identifier_system varchar (140),   -- identifier/system (70 x 2 varchar)
  loc_identifier_value varchar (140),   -- identifier/value (70 x 2 varchar)
  loc_identifier_start varchar (60),   -- identifier/start (30 x 2 varchar)
  loc_identifier_end varchar (60),   -- identifier/end (30 x 2 varchar)
  loc_status varchar (30),   -- status (30 x 1 varchar)
  loc_name varchar (50),   -- name (50 x 1 varchar)
  loc_description varchar (50),   -- description (50 x 1 varchar)
  loc_alias varchar (90),   -- alias (30 x 3 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);

CREATE TABLE IF NOT EXISTS cds2db_in.pids_per_ward_raw (
  pids_per_ward_raw_id serial PRIMARY KEY not null, -- Primary key of the entity
  date_time varchar (30),   -- date_time (30 x 1 varchar)
  ward_name varchar (30),   -- ward_name (30 x 1 varchar)
  patient_id varchar (70),   -- patient_id (70 x 1 varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);


--SQL Role / Trigger in Schema cds2db_in

--GRANT INSERT, SELECT ON TABLE cds2db_in.encounter_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.encounter_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.encounter_raw TO cds2db_user;
ALTER TABLE cds2db_in.encounter_raw ALTER COLUMN encounter_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.encounter_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER encounter_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.encounter_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.encounter_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.patient_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.patient_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.patient_raw TO cds2db_user;
ALTER TABLE cds2db_in.patient_raw ALTER COLUMN patient_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.patient_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.patient_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.patient_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.condition_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.condition_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.condition_raw TO cds2db_user;
ALTER TABLE cds2db_in.condition_raw ALTER COLUMN condition_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.condition_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER condition_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.condition_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.condition_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.medication_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.medication_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.medication_raw TO cds2db_user;
ALTER TABLE cds2db_in.medication_raw ALTER COLUMN medication_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.medication_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medication_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.medication_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.medication_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.medicationrequest_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.medicationrequest_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.medicationrequest_raw TO cds2db_user;
ALTER TABLE cds2db_in.medicationrequest_raw ALTER COLUMN medicationrequest_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.medicationrequest_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationrequest_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.medicationrequest_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.medicationrequest_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.medicationadministration_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.medicationadministration_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.medicationadministration_raw TO cds2db_user;
ALTER TABLE cds2db_in.medicationadministration_raw ALTER COLUMN medicationadministration_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.medicationadministration_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationadministration_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.medicationadministration_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.medicationadministration_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.medicationstatement_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.medicationstatement_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.medicationstatement_raw TO cds2db_user;
ALTER TABLE cds2db_in.medicationstatement_raw ALTER COLUMN medicationstatement_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.medicationstatement_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationstatement_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.medicationstatement_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.medicationstatement_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.observation_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.observation_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.observation_raw TO cds2db_user;
ALTER TABLE cds2db_in.observation_raw ALTER COLUMN observation_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.observation_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER observation_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.observation_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.observation_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.diagnosticreport_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.diagnosticreport_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.diagnosticreport_raw TO cds2db_user;
ALTER TABLE cds2db_in.diagnosticreport_raw ALTER COLUMN diagnosticreport_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.diagnosticreport_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER diagnosticreport_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.diagnosticreport_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.diagnosticreport_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.servicerequest_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.servicerequest_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.servicerequest_raw TO cds2db_user;
ALTER TABLE cds2db_in.servicerequest_raw ALTER COLUMN servicerequest_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.servicerequest_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER servicerequest_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.servicerequest_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.servicerequest_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.procedure_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.procedure_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.procedure_raw TO cds2db_user;
ALTER TABLE cds2db_in.procedure_raw ALTER COLUMN procedure_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.procedure_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER procedure_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.procedure_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.procedure_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.consent_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.consent_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.consent_raw TO cds2db_user;
ALTER TABLE cds2db_in.consent_raw ALTER COLUMN consent_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.consent_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER consent_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.consent_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.consent_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.location_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.location_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.location_raw TO cds2db_user;
ALTER TABLE cds2db_in.location_raw ALTER COLUMN location_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.location_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER location_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.location_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.location_raw_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE cds2db_in.pids_per_ward_raw TO cds2db_user; -- nach Entwicklungsphase
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward_raw TO cds2db_user; -- zum Testen weitere Berechtigungen
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE cds2db_in.pids_per_ward_raw TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON cds2db_in.pids_per_ward_raw TO cds2db_user;
ALTER TABLE cds2db_in.pids_per_ward_raw ALTER COLUMN pids_per_ward_raw_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

CREATE OR REPLACE FUNCTION cds2db_in.pids_per_ward_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER pids_per_ward_raw_tr_ins_tr
  BEFORE INSERT
  ON  cds2db_in.pids_per_ward_raw
  FOR EACH ROW
  EXECUTE PROCEDURE  cds2db_in.pids_per_ward_raw_tr_ins_fkt();

-- Comment on Table in Schema cds2db_in
comment on column cds2db_in.encounter_raw.enc_id is 'id (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_partof_id is 'partOf/reference (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.encounter_raw.enc_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.encounter_raw.enc_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.encounter_raw.enc_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.encounter_raw.enc_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.encounter_raw.enc_status is 'status (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_class_system is 'class/coding/system (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_class_version is 'class/coding/version (50 x 1 50)';
comment on column cds2db_in.encounter_raw.enc_class_code is 'class/coding/code (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_class_display is 'class/coding/display (100 x 1 100)';
comment on column cds2db_in.encounter_raw.enc_type_system is 'type/coding/system (70 x 9 630)';
comment on column cds2db_in.encounter_raw.enc_type_version is 'type/coding/version (50 x 9 450)';
comment on column cds2db_in.encounter_raw.enc_type_code is 'type/coding/code (30 x 9 270)';
comment on column cds2db_in.encounter_raw.enc_type_display is 'type/coding/display (100 x 9 900)';
comment on column cds2db_in.encounter_raw.enc_type_text is 'type/text (500 x 3 1500)';
comment on column cds2db_in.encounter_raw.enc_servicetype_system is 'serviceType/coding/system (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_servicetype_version is 'serviceType/coding/version (50 x 1 50)';
comment on column cds2db_in.encounter_raw.enc_servicetype_code is 'serviceType/coding/code (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_servicetype_display is 'serviceType/coding/display (100 x 1 100)';
comment on column cds2db_in.encounter_raw.enc_servicetype_text is 'serviceType/text (500 x 1 500)';
comment on column cds2db_in.encounter_raw.enc_period_start is 'period/start (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_period_end is 'period/end (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_condition_id is 'diagnosis/condition/reference (70 x 7 490)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_system is 'diagnosis/use/coding/system (70 x 21 1470)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_version is 'diagnosis/use/coding/version (50 x 21 1050)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_code is 'diagnosis/use/coding/code (30 x 21 630)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_display is 'diagnosis/use/coding/display (100 x 21 2100)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_text is 'diagnosis/use/text (500 x 7 3500)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_rank is 'diagnosis/rank (2 x 7 14)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_system is 'hospitalization/admitSource/coding/system (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_version is 'hospitalization/admitSource/coding/version (50 x 1 50)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_code is 'hospitalization/admitSource/coding/code (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_display is 'hospitalization/admitSource/coding/display (100 x 1 100)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_text is 'hospitalization/admitSource/text (500 x 1 500)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_system is 'hospitalization/dischargeDisposition/coding/system (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_version is 'hospitalization/dischargeDisposition/coding/version (50 x 1 50)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_code is 'hospitalization/dischargeDisposition/coding/code (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_display is 'hospitalization/dischargeDisposition/coding/display (100 x 1 100)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_text is 'hospitalization/dischargeDisposition/text (500 x 1 500)';
comment on column cds2db_in.encounter_raw.enc_location_id is 'location/location/reference (70 x 2 140)';
comment on column cds2db_in.encounter_raw.enc_location_type is 'location/location/type (30 x 2 60)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_use is 'location/location/identifier/use (30 x 2 60)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_system is 'location/location/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_version is 'location/location/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_code is 'location/location/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_display is 'location/location/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_text is 'location/location/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.encounter_raw.enc_location_display is 'location/location/display (100 x 2 200)';
comment on column cds2db_in.encounter_raw.enc_location_status is 'location/location/status (10 x 2 20)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_system is 'location/location/physicalType/coding/system (70 x 6 420)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_version is 'location/location/physicalType/coding/version (50 x 6 300)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_code is 'location/location/physicalType/coding/code (30 x 6 180)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_display is 'location/location/physicalType/coding/display (100 x 6 600)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_text is 'location/location/physicalType/text (500 x 2 1000)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_id is 'serviceProvider/reference (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_type is 'serviceProvider/type (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_use is 'serviceProvider/identifier/use (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_system is 'serviceProvider/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_version is 'serviceProvider/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_code is 'serviceProvider/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_display is 'serviceProvider/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_text is 'serviceProvider/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_display is 'serviceProvider/display (100 x 1 100)';

comment on column cds2db_in.patient_raw.pat_id is 'id (70 x 1 70)';
comment on column cds2db_in.patient_raw.pat_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.patient_raw.pat_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.patient_raw.pat_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.patient_raw.pat_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.patient_raw.pat_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.patient_raw.pat_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.patient_raw.pat_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.patient_raw.pat_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.patient_raw.pat_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.patient_raw.pat_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.patient_raw.pat_name_given is 'name/given (50 x 2 100)';
comment on column cds2db_in.patient_raw.pat_name_family is 'name/family (50 x 2 100)';
comment on column cds2db_in.patient_raw.pat_gender is 'gender (10 x 1 10)';
comment on column cds2db_in.patient_raw.pat_birthdate is 'birthDate (30 x 1 30)';
comment on column cds2db_in.patient_raw.pat_address_postalcode is 'address/postalCode (10 x 3 30)';

comment on column cds2db_in.condition_raw.con_id is 'id (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_encounter_id is 'encounter/reference (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.condition_raw.con_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.condition_raw.con_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.condition_raw.con_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.condition_raw.con_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.condition_raw.con_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.condition_raw.con_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.condition_raw.con_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.condition_raw.con_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.condition_raw.con_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_system is 'clinicalStatus/coding/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_version is 'clinicalStatus/coding/version (50 x 1 50)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_code is 'clinicalStatus/coding/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_display is 'clinicalStatus/coding/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_text is 'clinicalStatus/text (500 x 1 500)';
comment on column cds2db_in.condition_raw.con_verificationstatus_system is 'verificationStatus/coding/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_verificationstatus_version is 'verificationStatus/coding/version (50 x 1 50)';
comment on column cds2db_in.condition_raw.con_verificationstatus_code is 'verificationStatus/coding/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_verificationstatus_display is 'verificationStatus/coding/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_verificationstatus_text is 'verificationStatus/text (500 x 1 500)';
comment on column cds2db_in.condition_raw.con_category_system is 'category/coding/system (70 x 6 420)';
comment on column cds2db_in.condition_raw.con_category_version is 'category/coding/version (50 x 6 300)';
comment on column cds2db_in.condition_raw.con_category_code is 'category/coding/code (30 x 6 180)';
comment on column cds2db_in.condition_raw.con_category_display is 'category/coding/display (100 x 6 600)';
comment on column cds2db_in.condition_raw.con_category_text is 'category/text (500 x 2 1000)';
comment on column cds2db_in.condition_raw.con_severity_system is 'severity/coding/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_severity_version is 'severity/coding/version (50 x 1 50)';
comment on column cds2db_in.condition_raw.con_severity_code is 'severity/coding/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_severity_display is 'severity/coding/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_severity_text is 'severity/text (500 x 1 500)';
comment on column cds2db_in.condition_raw.con_code_system is 'code/coding/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_code_version is 'code/coding/version (50 x 1 50)';
comment on column cds2db_in.condition_raw.con_code_code is 'code/coding/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_code_display is 'code/coding/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_code_text is 'code/text (500 x 1 500)';
comment on column cds2db_in.condition_raw.con_bodysite_system is 'bodySite/coding/system (70 x 9 630)';
comment on column cds2db_in.condition_raw.con_bodysite_version is 'bodySite/coding/version (50 x 9 450)';
comment on column cds2db_in.condition_raw.con_bodysite_code is 'bodySite/coding/code (30 x 9 270)';
comment on column cds2db_in.condition_raw.con_bodysite_display is 'bodySite/coding/display (100 x 9 900)';
comment on column cds2db_in.condition_raw.con_bodysite_text is 'bodySite/text (500 x 3 1500)';
comment on column cds2db_in.condition_raw.con_onsetperiod_start is 'onsetPeriod/start (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_onsetperiod_end is 'onsetPeriod/end (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_onsetdatetime is 'onsetDateTime (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementdatetime is 'abatementDateTime (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementage_value is 'abatementAge/value (10 x 1 10)';
comment on column cds2db_in.condition_raw.con_abatementage_comparator is 'abatementAge/comparator (3 x 1 3)';
comment on column cds2db_in.condition_raw.con_abatementage_unit is 'abatementAge/unit (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementage_system is 'abatementAge/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_abatementage_code is 'abatementAge/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementperiod_start is 'abatementPeriod/start (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementperiod_end is 'abatementPeriod/end (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_value is 'abatementRange/low/value (10 x 1 10)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_unit is 'abatementRange/low/unit (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_system is 'abatementRange/low/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_code is 'abatementRange/low/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_value is 'abatementRange/high/value (10 x 1 10)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_unit is 'abatementRange/high/unit (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_system is 'abatementRange/high/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_code is 'abatementRange/high/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_abatementstring is 'abatementString (300 x 1 300)';
comment on column cds2db_in.condition_raw.con_recordeddate is 'recordedDate (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_recorder_id is 'recorder/reference (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_recorder_type is 'recorder/type (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_use is 'recorder/identifier/use (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_system is 'recorder/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_version is 'recorder/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_code is 'recorder/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_display is 'recorder/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_text is 'recorder/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.condition_raw.con_recorder_display is 'recorder/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_asserter_id is 'asserter/reference (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_asserter_type is 'asserter/type (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_use is 'asserter/identifier/use (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_system is 'asserter/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_version is 'asserter/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_code is 'asserter/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_display is 'asserter/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_text is 'asserter/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.condition_raw.con_asserter_display is 'asserter/display (100 x 1 100)';
comment on column cds2db_in.condition_raw.con_stage_summary_system is 'stage/summary/coding/system (70 x 6 420)';
comment on column cds2db_in.condition_raw.con_stage_summary_version is 'stage/summary/coding/version (50 x 6 300)';
comment on column cds2db_in.condition_raw.con_stage_summary_code is 'stage/summary/coding/code (30 x 6 180)';
comment on column cds2db_in.condition_raw.con_stage_summary_display is 'stage/summary/coding/display (100 x 6 600)';
comment on column cds2db_in.condition_raw.con_stage_summary_text is 'stage/summary/text (500 x 2 1000)';
comment on column cds2db_in.condition_raw.con_stage_assessment_id is 'stage/assessment/reference (70 x 4 280)';
comment on column cds2db_in.condition_raw.con_stage_assessment_type is 'stage/assessment/type (30 x 4 120)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_use is 'stage/assessment/identifier/use (30 x 4 120)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_system is 'stage/assessment/identifier/type/coding/system (70 x 12 840)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_version is 'stage/assessment/identifier/type/coding/version (50 x 12 600)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_code is 'stage/assessment/identifier/type/coding/code (30 x 12 360)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_display is 'stage/assessment/identifier/type/coding/display (100 x 12 1200)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_text is 'stage/assessment/identifier/type/text (500 x 4 2000)';
comment on column cds2db_in.condition_raw.con_stage_assessment_display is 'stage/assessment/display (100 x 4 400)';
comment on column cds2db_in.condition_raw.con_stage_type_system is 'stage/type/coding/system (70 x 6 420)';
comment on column cds2db_in.condition_raw.con_stage_type_version is 'stage/type/coding/version (50 x 6 300)';
comment on column cds2db_in.condition_raw.con_stage_type_code is 'stage/type/coding/code (30 x 6 180)';
comment on column cds2db_in.condition_raw.con_stage_type_display is 'stage/type/coding/display (100 x 6 600)';
comment on column cds2db_in.condition_raw.con_stage_type_text is 'stage/type/text (500 x 2 1000)';
comment on column cds2db_in.condition_raw.con_note_authorstring is 'note/authorString (50 x 6 300)';
comment on column cds2db_in.condition_raw.con_note_authorreference_id is 'note/authorReference/reference (70 x 6 420)';
comment on column cds2db_in.condition_raw.con_note_authorreference_type is 'note/authorReference/type (30 x 6 180)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_use is 'note/authorReference/identifier/use (30 x 6 180)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (50 x 18 900)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (30 x 18 540)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (100 x 18 1800)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (500 x 6 3000)';
comment on column cds2db_in.condition_raw.con_note_authorreference_display is 'note/authorReference/display (100 x 6 600)';
comment on column cds2db_in.condition_raw.con_note_time is 'note/time (30 x 2 60)';
comment on column cds2db_in.condition_raw.con_note_text is 'note/text (5000 x 2 10000)';

comment on column cds2db_in.medication_raw.med_id is 'id (70 x 1 70)';
comment on column cds2db_in.medication_raw.med_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.medication_raw.med_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medication_raw.med_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medication_raw.med_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medication_raw.med_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medication_raw.med_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medication_raw.med_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.medication_raw.med_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.medication_raw.med_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.medication_raw.med_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.medication_raw.med_code_system is 'code/coding/system (70 x 9 630)';
comment on column cds2db_in.medication_raw.med_code_version is 'code/coding/version (50 x 9 450)';
comment on column cds2db_in.medication_raw.med_code_code is 'code/coding/code (30 x 9 270)';
comment on column cds2db_in.medication_raw.med_code_display is 'code/coding/display (100 x 9 900)';
comment on column cds2db_in.medication_raw.med_code_text is 'code/text (500 x 3 1500)';
comment on column cds2db_in.medication_raw.med_status is 'status (20 x 1 20)';
comment on column cds2db_in.medication_raw.med_form_system is 'form/coding/system (70 x 1 70)';
comment on column cds2db_in.medication_raw.med_form_version is 'form/coding/version (50 x 1 50)';
comment on column cds2db_in.medication_raw.med_form_code is 'form/coding/code (30 x 1 30)';
comment on column cds2db_in.medication_raw.med_form_display is 'form/coding/display (100 x 1 100)';
comment on column cds2db_in.medication_raw.med_form_text is 'form/text (500 x 1 500)';
comment on column cds2db_in.medication_raw.med_amount_numerator_value is 'amount/numerator/value (10 x 1 10)';
comment on column cds2db_in.medication_raw.med_amount_numerator_comparator is 'amount/numerator/comparator (10 x 1 10)';
comment on column cds2db_in.medication_raw.med_amount_numerator_unit is 'amount/numerator/unit (30 x 1 30)';
comment on column cds2db_in.medication_raw.med_amount_numerator_system is 'amount/numerator/system (70 x 1 70)';
comment on column cds2db_in.medication_raw.med_amount_numerator_code is 'amount/numerator/code (30 x 1 30)';
comment on column cds2db_in.medication_raw.med_amount_denominator_value is 'amount/denominator/value (10 x 1 10)';
comment on column cds2db_in.medication_raw.med_amount_denominator_comparator is 'amount/denominator/comparator (10 x 1 10)';
comment on column cds2db_in.medication_raw.med_amount_denominator_unit is 'amount/denominator/unit (30 x 1 30)';
comment on column cds2db_in.medication_raw.med_amount_denominator_system is 'amount/denominator/system (70 x 1 70)';
comment on column cds2db_in.medication_raw.med_amount_denominator_code is 'amount/denominator/code (30 x 1 30)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_value is 'ingredient/strength/numerator/value (10 x 15 150)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_comparator is 'ingredient/strength/numerator/comparator (10 x 15 150)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_unit is 'ingredient/strength/numerator/unit (30 x 15 450)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_system is 'ingredient/strength/numerator/system (70 x 15 1050)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_code is 'ingredient/strength/numerator/code (30 x 15 450)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_value is 'ingredient/strength/denominator/value (10 x 15 150)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_comparator is 'ingredient/strength/denominator/comparator (10 x 15 150)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_unit is 'ingredient/strength/denominator/unit (30 x 15 450)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_system is 'ingredient/strength/denominator/system (70 x 15 1050)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_code is 'ingredient/strength/denominator/code (30 x 15 450)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_system is 'ingredient/itemCodeableConcept/coding/system (70 x 45 3150)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_version is 'ingredient/itemCodeableConcept/coding/version (50 x 45 2250)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_code is 'ingredient/itemCodeableConcept/coding/code (30 x 45 1350)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_display is 'ingredient/itemCodeableConcept/coding/display (100 x 45 4500)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_text is 'ingredient/itemCodeableConcept/text (500 x 15 7500)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_id is 'ingredient/itemReference/reference (70 x 15 1050)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_type is 'ingredient/itemReference/type (30 x 15 450)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_use is 'ingredient/itemReference/identifier/use (30 x 15 450)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_system is 'ingredient/itemReference/identifier/type/coding/system (70 x 45 3150)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_version is 'ingredient/itemReference/identifier/type/coding/version (50 x 45 2250)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_code is 'ingredient/itemReference/identifier/type/coding/code (30 x 45 1350)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_display is 'ingredient/itemReference/identifier/type/coding/display (100 x 45 4500)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_text is 'ingredient/itemReference/identifier/type/text (500 x 15 7500)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_display is 'ingredient/itemReference/display (100 x 15 1500)';
comment on column cds2db_in.medication_raw.med_ingredient_isactive is 'ingredient/isActive (10 x 15 150)';

comment on column cds2db_in.medicationrequest_raw.medreq_id is 'id (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_encounter_id is 'encounter/reference (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationreference_id is 'medicationReference/reference (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_status is 'status (20 x 1 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_system is 'statusReason/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_version is 'statusReason/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_code is 'statusReason/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_display is 'statusReason/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_text is 'statusReason/text (500 x 1 500)';
comment on column cds2db_in.medicationrequest_raw.medreq_intend is 'intend (20 x 1 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_system is 'category/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_version is 'category/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_code is 'category/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_display is 'category/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_text is 'category/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_priority is 'priority (10 x 1 10)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedboolean is 'reportedBoolean (10 x 1 10)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_id is 'reportedReference/reference (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_type is 'reportedReference/type (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_use is 'reportedReference/identifier/use (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_system is 'reportedReference/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_version is 'reportedReference/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_code is 'reportedReference/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_display is 'reportedReference/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_text is 'reportedReference/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_display is 'reportedReference/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_text is 'medicationCodeableConcept/text (500 x 1 500)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_id is 'supportingInformation/reference (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_type is 'supportingInformation/type (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_use is 'supportingInformation/identifier/use (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_system is 'supportingInformation/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_version is 'supportingInformation/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_code is 'supportingInformation/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_display is 'supportingInformation/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_text is 'supportingInformation/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_display is 'supportingInformation/display (100 x 2 200)';
comment on column cds2db_in.medicationrequest_raw.medreq_authoredon is 'authoredOn (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_id is 'requester/reference (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_type is 'requester/type (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_use is 'requester/identifier/use (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_system is 'requester/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_version is 'requester/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_code is 'requester/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_display is 'requester/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_text is 'requester/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_display is 'requester/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_system is 'reasonCode/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_version is 'reasonCode/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_code is 'reasonCode/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_display is 'reasonCode/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_text is 'reasonCode/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_id is 'reasonReference/reference (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_type is 'reasonReference/type (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_use is 'reasonReference/identifier/use (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_display is 'reasonReference/display (100 x 2 200)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_id is 'basedOn/reference (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_type is 'basedOn/type (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_use is 'basedOn/identifier/use (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_text is 'basedOn/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_display is 'basedOn/display (100 x 2 200)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorstring is 'note/authorString (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_id is 'note/authorReference/reference (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_type is 'note/authorReference/type (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_use is 'note/authorReference/identifier/use (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (50 x 18 900)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (30 x 18 540)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (100 x 18 1800)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (500 x 6 3000)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_display is 'note/authorReference/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_time is 'note/time (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_text is 'note/text (5000 x 2 10000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_sequence is 'dosageInstruction/sequence (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_text is 'dosageInstruction/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_system is 'dosageInstruction/additionalInstruction/coding/system (70 x 12 840)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_version is 'dosageInstruction/additionalInstruction/coding/version (50 x 12 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_code is 'dosageInstruction/additionalInstruction/coding/code (30 x 12 360)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_display is 'dosageInstruction/additionalInstruction/coding/display (100 x 12 1200)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_text is 'dosageInstruction/additionalInstruction/text (500 x 4 2000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_patientinstruction is 'dosageInstruction/patientInstruction (100 x 2 200)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_event is 'dosageInstruction/timing/event (30 x 8 240)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_value is 'dosageInstruction/timing/repeat/boundsDuration/value (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_comparator is 'dosageInstruction/timing/repeat/boundsDuration/comparator (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_unit is 'dosageInstruction/timing/repeat/boundsDuration/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_system is 'dosageInstruction/timing/repeat/boundsDuration/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_code is 'dosageInstruction/timing/repeat/boundsDuration/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_value is 'dosageInstruction/timing/repeat/boundsRange/low/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_unit is 'dosageInstruction/timing/repeat/boundsRange/low/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_system is 'dosageInstruction/timing/repeat/boundsRange/low/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_code is 'dosageInstruction/timing/repeat/boundsRange/low/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_value is 'dosageInstruction/timing/repeat/boundsRange/high/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_unit is 'dosageInstruction/timing/repeat/boundsRange/high/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_system is 'dosageInstruction/timing/repeat/boundsRange/high/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_code is 'dosageInstruction/timing/repeat/boundsRange/high/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsperiod_start is 'dosageInstruction/timing/repeat/boundsPeriod/start (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsperiod_end is 'dosageInstruction/timing/repeat/boundsPeriod/end (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_count is 'dosageInstruction/timing/repeat/count (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_countmax is 'dosageInstruction/timing/repeat/countMax (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_duration is 'dosageInstruction/timing/repeat/duration (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_durationmax is 'dosageInstruction/timing/repeat/durationMax (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_durationunit is 'dosageInstruction/timing/repeat/durationUnit (20 x 2 40)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_frequency is 'dosageInstruction/timing/repeat/frequency (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_frequencymax is 'dosageInstruction/timing/repeat/frequencyMax (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_period is 'dosageInstruction/timing/repeat/period (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_periodmax is 'dosageInstruction/timing/repeat/periodMax (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_periodunit is 'dosageInstruction/timing/repeat/periodUnit (20 x 2 40)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_dayofweek is 'dosageInstruction/timing/repeat/dayOfWeek (10 x 14 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_timeofday is 'dosageInstruction/timing/repeat/timeOfDay (20 x 8 160)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_when is 'dosageInstruction/timing/repeat/when (20 x 8 160)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_offset is 'dosageInstruction/timing/repeat/offset (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_system is 'dosageInstruction/timing/code/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_version is 'dosageInstruction/timing/code/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_code is 'dosageInstruction/timing/code/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_display is 'dosageInstruction/timing/code/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_text is 'dosageInstruction/timing/code/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededboolean is 'dosageInstruction/asNeededBoolean (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_system is 'dosageInstruction/asNeededCodeableConcept/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_version is 'dosageInstruction/asNeededCodeableConcept/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_code is 'dosageInstruction/asNeededCodeableConcept/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_display is 'dosageInstruction/asNeededCodeableConcept/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_text is 'dosageInstruction/asNeededCodeableConcept/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_system is 'dosageInstruction/site/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_version is 'dosageInstruction/site/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_code is 'dosageInstruction/site/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_display is 'dosageInstruction/site/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_text is 'dosageInstruction/site/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_system is 'dosageInstruction/route/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_version is 'dosageInstruction/route/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_code is 'dosageInstruction/route/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_display is 'dosageInstruction/route/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_text is 'dosageInstruction/route/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_system is 'dosageInstruction/method/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_version is 'dosageInstruction/method/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_code is 'dosageInstruction/method/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_display is 'dosageInstruction/method/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_text is 'dosageInstruction/method/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_system is 'dosageInstruction/doseAndRate/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_version is 'dosageInstruction/doseAndRate/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_code is 'dosageInstruction/doseAndRate/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_display is 'dosageInstruction/doseAndRate/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_text is 'dosageInstruction/doseAndRate/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_value is 'dosageInstruction/doseAndRate/doseRange/low/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_unit is 'dosageInstruction/doseAndRate/doseRange/low/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_system is 'dosageInstruction/doseAndRate/doseRange/low/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_code is 'dosageInstruction/doseAndRate/doseRange/low/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_value is 'dosageInstruction/doseAndRate/doseRange/high/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_unit is 'dosageInstruction/doseAndRate/doseRange/high/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_system is 'dosageInstruction/doseAndRate/doseRange/high/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_code is 'dosageInstruction/doseAndRate/doseRange/high/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_value is 'dosageInstruction/doseAndRate/doseQuantity/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_comparator is 'dosageInstruction/doseAndRate/doseQuantity/comparator (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_unit is 'dosageInstruction/doseAndRate/doseQuantity/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_system is 'dosageInstruction/doseAndRate/doseQuantity/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_code is 'dosageInstruction/doseAndRate/doseQuantity/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_value is 'dosageInstruction/doseAndRate/rateRatio/numerator/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator is 'dosageInstruction/doseAndRate/rateRatio/numerator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_unit is 'dosageInstruction/doseAndRate/rateRatio/numerator/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_system is 'dosageInstruction/doseAndRate/rateRatio/numerator/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_code is 'dosageInstruction/doseAndRate/rateRatio/numerator/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_value is 'dosageInstruction/doseAndRate/rateRatio/denominator/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator is 'dosageInstruction/doseAndRate/rateRatio/denominator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_unit is 'dosageInstruction/doseAndRate/rateRatio/denominator/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_system is 'dosageInstruction/doseAndRate/rateRatio/denominator/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_code is 'dosageInstruction/doseAndRate/rateRatio/denominator/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_value is 'dosageInstruction/doseAndRate/rateRange/low/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_unit is 'dosageInstruction/doseAndRate/rateRange/low/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_system is 'dosageInstruction/doseAndRate/rateRange/low/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_code is 'dosageInstruction/doseAndRate/rateRange/low/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_value is 'dosageInstruction/doseAndRate/rateRange/high/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_unit is 'dosageInstruction/doseAndRate/rateRange/high/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_system is 'dosageInstruction/doseAndRate/rateRange/high/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_code is 'dosageInstruction/doseAndRate/rateRange/high/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_value is 'dosageInstruction/doseAndRate/rateQuantity/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_unit is 'dosageInstruction/doseAndRate/rateQuantity/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_system is 'dosageInstruction/doseAndRate/rateQuantity/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_code is 'dosageInstruction/doseAndRate/rateQuantity/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_value is 'dosageInstruction/maxDosePerPeriod/numerator/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_comparator is 'dosageInstruction/maxDosePerPeriod/numerator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_unit is 'dosageInstruction/maxDosePerPeriod/numerator/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_system is 'dosageInstruction/maxDosePerPeriod/numerator/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_code is 'dosageInstruction/maxDosePerPeriod/numerator/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_value is 'dosageInstruction/maxDosePerPeriod/denominator/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_comparator is 'dosageInstruction/maxDosePerPeriod/denominator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_unit is 'dosageInstruction/maxDosePerPeriod/denominator/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_system is 'dosageInstruction/maxDosePerPeriod/denominator/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_code is 'dosageInstruction/maxDosePerPeriod/denominator/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_value is 'dosageInstruction/maxDosePerAdministration/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_unit is 'dosageInstruction/maxDosePerAdministration/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_system is 'dosageInstruction/maxDosePerAdministration/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_code is 'dosageInstruction/maxDosePerAdministration/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_value is 'dosageInstruction/maxDosePerLifetime/value (10 x 2 20)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_unit is 'dosageInstruction/maxDosePerLifetime/unit (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_system is 'dosageInstruction/maxDosePerLifetime/system (70 x 2 140)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_code is 'dosageInstruction/maxDosePerLifetime/code (30 x 2 60)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_system is 'substitution/reason/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_version is 'substitution/reason/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_code is 'substitution/reason/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_display is 'substitution/reason/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_text is 'substitution/reason/text (500 x 1 500)';

comment on column cds2db_in.medicationadministration_raw.medadm_id is 'id (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_encounter_id is 'context/reference (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_partof_id is 'partOf/reference (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_status is 'status (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_system is 'statusReason/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_version is 'statusReason/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_code is 'statusReason/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_display is 'statusReason/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_text is 'statusReason/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_system is 'category/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_version is 'category/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_code is 'category/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_display is 'category/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_text is 'category/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationreference_id is 'medicationReference/reference (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_text is 'medicationCodeableConcept/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_id is 'supportingInformation/reference (70 x 2 140)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_type is 'supportingInformation/type (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_use is 'supportingInformation/identifier/use (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_system is 'supportingInformation/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_version is 'supportingInformation/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_code is 'supportingInformation/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_display is 'supportingInformation/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_text is 'supportingInformation/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_display is 'supportingInformation/display (100 x 2 200)';
comment on column cds2db_in.medicationadministration_raw.medadm_effectivedatetime is 'effectiveDateTime (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_effectiveperiod_start is 'effectivePeriod/start (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_effectiveperiod_end is 'effectivePeriod/end (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_system is 'performer/function/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_version is 'performer/function/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_code is 'performer/function/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_display is 'performer/function/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_text is 'performer/function/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_system is 'reasonCode/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_version is 'reasonCode/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_code is 'reasonCode/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_display is 'reasonCode/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_text is 'reasonCode/text (500 x 2 1000)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_id is 'reasonReference/reference (70 x 2 140)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_type is 'reasonReference/type (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_use is 'reasonReference/identifier/use (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_display is 'reasonReference/display (100 x 2 200)';
comment on column cds2db_in.medicationadministration_raw.medadm_request_id is 'request/reference (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorstring is 'note/authorString (50 x 6 300)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_id is 'note/authorReference/reference (70 x 6 420)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_type is 'note/authorReference/type (30 x 6 180)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_use is 'note/authorReference/identifier/use (30 x 6 180)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (50 x 18 900)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (30 x 18 540)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (100 x 18 1800)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (500 x 6 3000)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_display is 'note/authorReference/display (100 x 6 600)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_time is 'note/time (30 x 2 60)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_text is 'note/text (5000 x 2 10000)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_text is 'dosage/text (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_system is 'dosage/site/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_version is 'dosage/site/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_code is 'dosage/site/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_display is 'dosage/site/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_text is 'dosage/site/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_system is 'dosage/route/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_version is 'dosage/route/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_code is 'dosage/route/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_display is 'dosage/route/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_text is 'dosage/route/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_system is 'dosage/method/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_version is 'dosage/method/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_code is 'dosage/method/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_display is 'dosage/method/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_text is 'dosage/method/text (500 x 1 500)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_value is 'dosage/dose/value (10 x 1 10)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_unit is 'dosage/dose/unit (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_system is 'dosage/dose/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_code is 'dosage/dose/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_value is 'dosage/rateRatio/numerator/value (10 x 1 10)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_comparator is 'dosage/rateRatio/numerator/comparator (10 x 1 10)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_unit is 'dosage/rateRatio/numerator/unit (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_system is 'dosage/rateRatio/numerator/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_code is 'dosage/rateRatio/numerator/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_value is 'dosage/rateRatio/denominator/value (10 x 1 10)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_comparator is 'dosage/rateRatio/denominator/comparator (10 x 1 10)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_unit is 'dosage/rateRatio/denominator/unit (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_system is 'dosage/rateRatio/denominator/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_code is 'dosage/rateRatio/denominator/code (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_value is 'dosage/rateQuantity/value (10 x 1 10)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_unit is 'dosage/rateQuantity/unit (30 x 1 30)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_system is 'dosage/rateQuantity/system (70 x 1 70)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_code is 'dosage/rateQuantity/code (30 x 1 30)';

comment on column cds2db_in.medicationstatement_raw.medstat_id is 'id (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_encounter_id is 'context/reference (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_partof_id is 'partOf/reference (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_id is 'basedOn/reference (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_type is 'basedOn/type (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_use is 'basedOn/identifier/use (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_text is 'basedOn/identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_display is 'basedOn/display (100 x 2 200)';
comment on column cds2db_in.medicationstatement_raw.medstat_status is 'status (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_system is 'statusReason/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_version is 'statusReason/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_code is 'statusReason/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_display is 'statusReason/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_text is 'statusReason/text (500 x 1 500)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_system is 'category/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_version is 'category/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_code is 'category/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_display is 'category/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_text is 'category/text (500 x 1 500)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationreference_id is 'medicationReference/reference (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_text is 'medicationCodeableConcept/text (500 x 1 500)';
comment on column cds2db_in.medicationstatement_raw.medstat_effectivedatetime is 'effectiveDateTime (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_effectiveperiod_start is 'effectivePeriod/start (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_effectiveperiod_end is 'effectivePeriod/end (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_dateasserted is 'dateAsserted (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_id is 'informationSource/reference (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_type is 'informationSource/type (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_use is 'informationSource/identifier/use (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_system is 'informationSource/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_version is 'informationSource/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_code is 'informationSource/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_display is 'informationSource/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_text is 'informationSource/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_display is 'informationSource/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_id is 'derivedFrom/reference (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_type is 'derivedFrom/type (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_use is 'derivedFrom/identifier/use (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_system is 'derivedFrom/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_version is 'derivedFrom/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_code is 'derivedFrom/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_display is 'derivedFrom/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_text is 'derivedFrom/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_display is 'derivedFrom/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_system is 'reasonCode/coding/system (70 x 1 70)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_version is 'reasonCode/coding/version (50 x 1 50)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_code is 'reasonCode/coding/code (30 x 1 30)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_display is 'reasonCode/coding/display (100 x 1 100)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_text is 'reasonCode/text (500 x 1 500)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_id is 'reasonReference/reference (70 x 3 210)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_type is 'reasonReference/type (30 x 3 90)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_use is 'reasonReference/identifier/use (30 x 3 90)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (70 x 9 630)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (50 x 9 450)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (30 x 9 270)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (100 x 9 900)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (500 x 3 1500)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_display is 'reasonReference/display (100 x 3 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorstring is 'note/authorString (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_id is 'note/authorReference/reference (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_type is 'note/authorReference/type (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_use is 'note/authorReference/identifier/use (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (50 x 18 900)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (30 x 18 540)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (100 x 18 1800)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (500 x 6 3000)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_display is 'note/authorReference/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_time is 'note/time (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_text is 'note/text (5000 x 2 10000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_sequence is 'dosage/sequence (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_text is 'dosage/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_system is 'dosage/additionalInstruction/coding/system (70 x 12 840)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_version is 'dosage/additionalInstruction/coding/version (50 x 12 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_code is 'dosage/additionalInstruction/coding/code (30 x 12 360)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_display is 'dosage/additionalInstruction/coding/display (100 x 12 1200)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_text is 'dosage/additionalInstruction/text (500 x 4 2000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_patientinstruction is 'dosage/patientInstruction (100 x 2 200)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_event is 'dosage/timing/event (30 x 8 240)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_value is 'dosage/timing/repeat/boundsDuration/value (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_comparator is 'dosage/timing/repeat/boundsDuration/comparator (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_unit is 'dosage/timing/repeat/boundsDuration/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_system is 'dosage/timing/repeat/boundsDuration/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_code is 'dosage/timing/repeat/boundsDuration/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_value is 'dosage/timing/repeat/boundsRange/low/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_unit is 'dosage/timing/repeat/boundsRange/low/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_system is 'dosage/timing/repeat/boundsRange/low/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_code is 'dosage/timing/repeat/boundsRange/low/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_value is 'dosage/timing/repeat/boundsRange/high/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_unit is 'dosage/timing/repeat/boundsRange/high/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_system is 'dosage/timing/repeat/boundsRange/high/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_code is 'dosage/timing/repeat/boundsRange/high/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsperiod_start is 'dosage/timing/repeat/boundsPeriod/start (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsperiod_end is 'dosage/timing/repeat/boundsPeriod/end (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_count is 'dosage/timing/repeat/count (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_countmax is 'dosage/timing/repeat/countMax (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_duration is 'dosage/timing/repeat/duration (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_durationmax is 'dosage/timing/repeat/durationMax (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_durationunit is 'dosage/timing/repeat/durationUnit (20 x 2 40)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_frequency is 'dosage/timing/repeat/frequency (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_frequencymax is 'dosage/timing/repeat/frequencyMax (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_period is 'dosage/timing/repeat/period (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_periodmax is 'dosage/timing/repeat/periodMax (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_periodunit is 'dosage/timing/repeat/periodUnit (20 x 2 40)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_dayofweek is 'dosage/timing/repeat/dayOfWeek (10 x 14 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_timeofday is 'dosage/timing/repeat/timeOfDay (20 x 8 160)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_when is 'dosage/timing/repeat/when (20 x 8 160)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_offset is 'dosage/timing/repeat/offset (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_system is 'dosage/timing/code/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_version is 'dosage/timing/code/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_code is 'dosage/timing/code/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_display is 'dosage/timing/code/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_text is 'dosage/timing/code/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededboolean is 'dosage/asNeededBoolean (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_system is 'dosage/asNeededCodeableConcept/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_version is 'dosage/asNeededCodeableConcept/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_code is 'dosage/asNeededCodeableConcept/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_display is 'dosage/asNeededCodeableConcept/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_text is 'dosage/asNeededCodeableConcept/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_system is 'dosage/site/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_version is 'dosage/site/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_code is 'dosage/site/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_display is 'dosage/site/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_text is 'dosage/site/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_system is 'dosage/route/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_version is 'dosage/route/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_code is 'dosage/route/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_display is 'dosage/route/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_text is 'dosage/route/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_system is 'dosage/method/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_version is 'dosage/method/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_code is 'dosage/method/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_display is 'dosage/method/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_text is 'dosage/method/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_system is 'dosage/doseAndRate/type/coding/system (70 x 6 420)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_version is 'dosage/doseAndRate/type/coding/version (50 x 6 300)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_code is 'dosage/doseAndRate/type/coding/code (30 x 6 180)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_display is 'dosage/doseAndRate/type/coding/display (100 x 6 600)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_text is 'dosage/doseAndRate/type/text (500 x 2 1000)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_value is 'dosage/doseAndRate/doseRange/low/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_unit is 'dosage/doseAndRate/doseRange/low/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_system is 'dosage/doseAndRate/doseRange/low/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_code is 'dosage/doseAndRate/doseRange/low/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_value is 'dosage/doseAndRate/doseRange/high/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_unit is 'dosage/doseAndRate/doseRange/high/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_system is 'dosage/doseAndRate/doseRange/high/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_code is 'dosage/doseAndRate/doseRange/high/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_value is 'dosage/doseAndRate/doseQuantity/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_comparator is 'dosage/doseAndRate/doseQuantity/comparator (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_unit is 'dosage/doseAndRate/doseQuantity/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_system is 'dosage/doseAndRate/doseQuantity/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_code is 'dosage/doseAndRate/doseQuantity/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_value is 'dosage/doseAndRate/rateRatio/numerator/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_comparator is 'dosage/doseAndRate/rateRatio/numerator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_unit is 'dosage/doseAndRate/rateRatio/numerator/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_system is 'dosage/doseAndRate/rateRatio/numerator/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_code is 'dosage/doseAndRate/rateRatio/numerator/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_value is 'dosage/doseAndRate/rateRatio/denominator/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_comparator is 'dosage/doseAndRate/rateRatio/denominator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_unit is 'dosage/doseAndRate/rateRatio/denominator/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_system is 'dosage/doseAndRate/rateRatio/denominator/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_code is 'dosage/doseAndRate/rateRatio/denominator/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_value is 'dosage/doseAndRate/rateRange/low/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_unit is 'dosage/doseAndRate/rateRange/low/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_system is 'dosage/doseAndRate/rateRange/low/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_code is 'dosage/doseAndRate/rateRange/low/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_value is 'dosage/doseAndRate/rateRange/high/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_unit is 'dosage/doseAndRate/rateRange/high/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_system is 'dosage/doseAndRate/rateRange/high/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_code is 'dosage/doseAndRate/rateRange/high/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_value is 'dosage/doseAndRate/rateQuantity/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_unit is 'dosage/doseAndRate/rateQuantity/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_system is 'dosage/doseAndRate/rateQuantity/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_code is 'dosage/doseAndRate/rateQuantity/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_value is 'dosage/maxDosePerPeriod/numerator/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_comparator is 'dosage/maxDosePerPeriod/numerator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_unit is 'dosage/maxDosePerPeriod/numerator/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_system is 'dosage/maxDosePerPeriod/numerator/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_code is 'dosage/maxDosePerPeriod/numerator/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_value is 'dosage/maxDosePerPeriod/denominator/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_comparator is 'dosage/maxDosePerPeriod/denominator/comparator (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_unit is 'dosage/maxDosePerPeriod/denominator/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_system is 'dosage/maxDosePerPeriod/denominator/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_code is 'dosage/maxDosePerPeriod/denominator/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_value is 'dosage/maxDosePerAdministration/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_unit is 'dosage/maxDosePerAdministration/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_system is 'dosage/maxDosePerAdministration/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_code is 'dosage/maxDosePerAdministration/code (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_value is 'dosage/maxDosePerLifetime/value (10 x 2 20)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_unit is 'dosage/maxDosePerLifetime/unit (30 x 2 60)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_system is 'dosage/maxDosePerLifetime/system (70 x 2 140)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_code is 'dosage/maxDosePerLifetime/code (30 x 2 60)';

comment on column cds2db_in.observation_raw.obs_id is 'id (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_encounter_id is 'encounter/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_partof_id is 'partOf/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.observation_raw.obs_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.observation_raw.obs_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.observation_raw.obs_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.observation_raw.obs_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.observation_raw.obs_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.observation_raw.obs_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_basedon_id is 'basedOn/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_basedon_type is 'basedOn/type (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_use is 'basedOn/identifier/use (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_text is 'basedOn/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_basedon_display is 'basedOn/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_status is 'status (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_category_system is 'category/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_category_version is 'category/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_category_code is 'category/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_category_display is 'category/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_category_text is 'category/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_code_system is 'code/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_code_version is 'code/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_code_code is 'code/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_code_display is 'code/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_code_text is 'code/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_effectivedatetime is 'effectiveDateTime (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_issued is 'issued (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_value is 'valueRange/low/value (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_unit is 'valueRange/low/unit (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_system is 'valueRange/low/system (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_code is 'valueRange/low/code (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_value is 'valueRange/high/value (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_unit is 'valueRange/high/unit (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_system is 'valueRange/high/system (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_code is 'valueRange/high/code (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_value is 'valueRatio/numerator/value (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_comparator is 'valueRatio/numerator/comparator (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_unit is 'valueRatio/numerator/unit (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_system is 'valueRatio/numerator/system (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_code is 'valueRatio/numerator/code (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_value is 'valueRatio/denominator/value (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_comparator is 'valueRatio/denominator/comparator (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_unit is 'valueRatio/denominator/unit (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_system is 'valueRatio/denominator/system (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_code is 'valueRatio/denominator/code (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valuequantity_value is 'valueQuantity/value (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valuequantity_comparator is 'valueQuantity/comparator (10 x 2 20)';
comment on column cds2db_in.observation_raw.obs_valuequantity_unit is 'valueQuantity/unit (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valuequantity_system is 'valueQuantity/system (70 x 2 140)';
comment on column cds2db_in.observation_raw.obs_valuequantity_code is 'valueQuantity/code (30 x 2 60)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_system is 'valueCodableConcept/coding/system (70 x 6 420)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_version is 'valueCodableConcept/coding/version (50 x 6 300)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_code is 'valueCodableConcept/coding/code (30 x 6 180)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_display is 'valueCodableConcept/coding/display (100 x 6 600)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_text is 'valueCodableConcept/text (500 x 2 1000)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_system is 'dataAbsentReason/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_version is 'dataAbsentReason/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_code is 'dataAbsentReason/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_display is 'dataAbsentReason/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_text is 'dataAbsentReason/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_note_authorstring is 'note/authorString (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_id is 'note/authorReference/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_type is 'note/authorReference/type (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_use is 'note/authorReference/identifier/use (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_display is 'note/authorReference/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_note_time is 'note/time (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_note_text is 'note/text (5000 x 1 5000)';
comment on column cds2db_in.observation_raw.obs_method_system is 'method/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_method_version is 'method/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_method_code is 'method/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_method_display is 'method/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_method_text is 'method/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_performer_id is 'performer/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_performer_type is 'performer/type (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_use is 'performer/identifier/use (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_system is 'performer/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_version is 'performer/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_code is 'performer/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_display is 'performer/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_text is 'performer/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_performer_display is 'performer/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_value is 'referenceRange/low/value (10 x 3 30)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_unit is 'referenceRange/low/unit (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_system is 'referenceRange/low/system (70 x 3 210)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_code is 'referenceRange/low/code (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_value is 'referenceRange/high/value (10 x 3 30)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_unit is 'referenceRange/high/unit (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_system is 'referenceRange/high/system (70 x 3 210)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_code is 'referenceRange/high/code (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_system is 'referenceRange/type/coding/system (70 x 9 630)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_version is 'referenceRange/type/coding/version (50 x 9 450)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_code is 'referenceRange/type/coding/code (30 x 9 270)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_display is 'referenceRange/type/coding/display (100 x 9 900)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_text is 'referenceRange/type/text (500 x 3 1500)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_system is 'referenceRange/appliesTo/coding/system (70 x 9 630)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_version is 'referenceRange/appliesTo/coding/version (50 x 9 450)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_code is 'referenceRange/appliesTo/coding/code (30 x 9 270)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_display is 'referenceRange/appliesTo/coding/display (100 x 9 900)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_text is 'referenceRange/appliesTo/text (500 x 3 1500)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_value is 'referenceRange/age/low/value (10 x 3 30)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_unit is 'referenceRange/age/low/unit (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_system is 'referenceRange/age/low/system (70 x 3 210)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_code is 'referenceRange/age/low/code (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_value is 'referenceRange/age/high/value (10 x 3 30)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_unit is 'referenceRange/age/high/unit (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_system is 'referenceRange/age/high/system (70 x 3 210)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_code is 'referenceRange/age/high/code (30 x 3 90)';
comment on column cds2db_in.observation_raw.obs_referencerange_text is 'referenceRange/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_hasmember_id is 'hasMember/reference (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_hasmember_type is 'hasMember/type (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_use is 'hasMember/identifier/use (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_system is 'hasMember/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_version is 'hasMember/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_code is 'hasMember/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_display is 'hasMember/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_text is 'hasMember/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.observation_raw.obs_hasmember_display is 'hasMember/display (100 x 1 100)';

comment on column cds2db_in.diagnosticreport_raw.diagrep_id is 'id (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_encounter_id is 'encounter/reference (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_partof_id is 'partOf/reference (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_result_id is 'result/reference (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_basedon_id is 'basedOn/reference (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_status is 'status (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_system is 'category/coding/system (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_version is 'category/coding/version (50 x 1 50)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_code is 'category/coding/code (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_display is 'category/coding/display (100 x 1 100)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_text is 'category/text (500 x 1 500)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_system is 'code/coding/system (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_version is 'code/coding/version (50 x 1 50)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_code is 'code/coding/code (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_display is 'code/coding/display (100 x 1 100)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_text is 'code/text (500 x 1 500)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_effectivedatetime is 'effectiveDateTime (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_issued is 'issued (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_id is 'performer/reference (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_type is 'performer/type (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_use is 'performer/identifier/use (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_system is 'performer/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_version is 'performer/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_code is 'performer/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_display is 'performer/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_text is 'performer/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_display is 'performer/display (100 x 1 100)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusion is 'conclusion (500 x 1 500)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_system is 'conclusionCode/coding/system (70 x 1 70)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_version is 'conclusionCode/coding/version (50 x 1 50)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_code is 'conclusionCode/coding/code (30 x 1 30)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_display is 'conclusionCode/coding/display (100 x 1 100)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_text is 'conclusionCode/text (500 x 1 500)';

comment on column cds2db_in.servicerequest_raw.servreq_id is 'id (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_encounter_id is 'encounter/reference (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_id is 'basedOn/reference (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_type is 'basedOn/type (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_use is 'basedOn/identifier/use (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_text is 'basedOn/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_display is 'basedOn/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_status is 'status (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_intent is 'intent (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_category_system is 'category/coding/system (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_category_version is 'category/coding/version (50 x 1 50)';
comment on column cds2db_in.servicerequest_raw.servreq_category_code is 'category/coding/code (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_category_display is 'category/coding/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_category_text is 'category/text (500 x 1 500)';
comment on column cds2db_in.servicerequest_raw.servreq_code_system is 'code/coding/system (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_code_version is 'code/coding/version (50 x 1 50)';
comment on column cds2db_in.servicerequest_raw.servreq_code_code is 'code/coding/code (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_code_display is 'code/coding/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_code_text is 'code/text (500 x 1 500)';
comment on column cds2db_in.servicerequest_raw.servreq_authoredon is 'authoredOn (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_id is 'requester/reference (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_type is 'requester/type (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_use is 'requester/identifier/use (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_system is 'requester/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_version is 'requester/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_code is 'requester/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_display is 'requester/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_text is 'requester/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_display is 'requester/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_id is 'performer/reference (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_type is 'performer/type (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_use is 'performer/identifier/use (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_system is 'performer/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_version is 'performer/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_code is 'performer/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_display is 'performer/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_text is 'performer/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_display is 'performer/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_system is 'locationCode/coding/system (70 x 1 70)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_version is 'locationCode/coding/version (50 x 1 50)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_code is 'locationCode/coding/code (30 x 1 30)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_display is 'locationCode/coding/display (100 x 1 100)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_text is 'locationCode/text (500 x 1 500)';

comment on column cds2db_in.procedure_raw.proc_id is 'id (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_encounter_id is 'encounter/reference (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_patient_id is 'subject/reference (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_partof_id is 'partOf/reference (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.procedure_raw.proc_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.procedure_raw.proc_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.procedure_raw.proc_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.procedure_raw.proc_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.procedure_raw.proc_basedon_id is 'basedOn/reference (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_basedon_type is 'basedOn/type (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_use is 'basedOn/identifier/use (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_text is 'basedOn/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.procedure_raw.proc_basedon_display is 'basedOn/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_status is 'status (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_statusreason_system is 'statusReason/coding/system (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_statusreason_version is 'statusReason/coding/version (50 x 1 50)';
comment on column cds2db_in.procedure_raw.proc_statusreason_code is 'statusReason/coding/code (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_statusreason_display is 'statusReason/coding/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_statusreason_text is 'statusReason/text (500 x 1 500)';
comment on column cds2db_in.procedure_raw.proc_category_system is 'category/coding/system (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_category_version is 'category/coding/version (50 x 1 50)';
comment on column cds2db_in.procedure_raw.proc_category_code is 'category/coding/code (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_category_display is 'category/coding/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_category_text is 'category/text (500 x 1 500)';
comment on column cds2db_in.procedure_raw.proc_code_system is 'code/coding/system (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_code_version is 'code/coding/version (50 x 1 50)';
comment on column cds2db_in.procedure_raw.proc_code_code is 'code/coding/code (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_code_display is 'code/coding/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_code_text is 'code/text (500 x 1 500)';
comment on column cds2db_in.procedure_raw.proc_performeddatetime is 'performedDateTime (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_performedperiod_start is 'performedPeriod/start (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_performedperiod_end is 'performedPeriod/end (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_system is 'reasonCode/coding/system (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_version is 'reasonCode/coding/version (50 x 1 50)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_code is 'reasonCode/coding/code (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_display is 'reasonCode/coding/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_text is 'reasonCode/text (500 x 1 500)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_id is 'reasonReference/reference (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_type is 'reasonReference/type (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_use is 'reasonReference/identifier/use (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (70 x 1 70)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (50 x 1 50)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (30 x 1 30)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (500 x 1 500)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_display is 'reasonReference/display (100 x 1 100)';
comment on column cds2db_in.procedure_raw.proc_note_authorstring is 'note/authorString (50 x 6 300)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_id is 'note/authorReference/reference (70 x 6 420)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_type is 'note/authorReference/type (30 x 6 180)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_use is 'note/authorReference/identifier/use (30 x 6 180)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (50 x 18 900)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (30 x 18 540)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (100 x 18 1800)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (500 x 6 3000)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_display is 'note/authorReference/display (100 x 6 600)';
comment on column cds2db_in.procedure_raw.proc_note_time is 'note/time (30 x 2 60)';
comment on column cds2db_in.procedure_raw.proc_note_text is 'note/text (5000 x 2 10000)';

comment on column cds2db_in.consent_raw.cons_id is 'id (70 x 1 70)';
comment on column cds2db_in.consent_raw.cons_patient_id is 'patient/reference (70 x 1 70)';
comment on column cds2db_in.consent_raw.cons_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.consent_raw.cons_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.consent_raw.cons_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.consent_raw.cons_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.consent_raw.cons_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.consent_raw.cons_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.consent_raw.cons_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.consent_raw.cons_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.consent_raw.cons_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.consent_raw.cons_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.consent_raw.cons_status is 'status (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_scope_system is 'scope/coding/system (70 x 1 70)';
comment on column cds2db_in.consent_raw.cons_scope_version is 'scope/coding/version (50 x 1 50)';
comment on column cds2db_in.consent_raw.cons_scope_code is 'scope/coding/code (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_scope_display is 'scope/coding/display (100 x 1 100)';
comment on column cds2db_in.consent_raw.cons_scope_text is 'scope/text (500 x 1 500)';
comment on column cds2db_in.consent_raw.cons_datetime is 'dateTime (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_provision_type is 'provision/type (10 x 1 10)';
comment on column cds2db_in.consent_raw.cons_provision_period_start is 'provision/period/start (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_provision_period_end is 'provision/period/end (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_system is 'provision/actor/role/coding/system (70 x 1 70)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_version is 'provision/actor/role/coding/version (50 x 1 50)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_code is 'provision/actor/role/coding/code (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_display is 'provision/actor/role/coding/display (100 x 1 100)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_text is 'provision/actor/role/text (500 x 1 500)';
comment on column cds2db_in.consent_raw.cons_provision_code_system is 'provision/code/coding/system (70 x 1 70)';
comment on column cds2db_in.consent_raw.cons_provision_code_version is 'provision/code/coding/version (50 x 1 50)';
comment on column cds2db_in.consent_raw.cons_provision_code_code is 'provision/code/coding/code (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_provision_code_display is 'provision/code/coding/display (100 x 1 100)';
comment on column cds2db_in.consent_raw.cons_provision_code_text is 'provision/code/text (500 x 1 500)';
comment on column cds2db_in.consent_raw.cons_provision_dataperiod_start is 'provision/dataPeriod/start (30 x 1 30)';
comment on column cds2db_in.consent_raw.cons_provision_dataperiod_end is 'provision/dataPeriod/end (30 x 1 30)';

comment on column cds2db_in.location_raw.loc_id is 'id (70 x 1 70)';
comment on column cds2db_in.location_raw.loc_identifier_use is 'identifier/use (50 x 2 100)';
comment on column cds2db_in.location_raw.loc_identifier_type_system is 'identifier/type/coding/system (70 x 6 420)';
comment on column cds2db_in.location_raw.loc_identifier_type_version is 'identifier/type/coding/version (50 x 6 300)';
comment on column cds2db_in.location_raw.loc_identifier_type_code is 'identifier/type/coding/code (30 x 6 180)';
comment on column cds2db_in.location_raw.loc_identifier_type_display is 'identifier/type/coding/display (100 x 6 600)';
comment on column cds2db_in.location_raw.loc_identifier_type_text is 'identifier/type/text (500 x 2 1000)';
comment on column cds2db_in.location_raw.loc_identifier_system is 'identifier/system (70 x 2 140)';
comment on column cds2db_in.location_raw.loc_identifier_value is 'identifier/value (70 x 2 140)';
comment on column cds2db_in.location_raw.loc_identifier_start is 'identifier/start (30 x 2 60)';
comment on column cds2db_in.location_raw.loc_identifier_end is 'identifier/end (30 x 2 60)';
comment on column cds2db_in.location_raw.loc_status is 'status (30 x 1 30)';
comment on column cds2db_in.location_raw.loc_name is 'name (50 x 1 50)';
comment on column cds2db_in.location_raw.loc_description is 'description (50 x 1 50)';
comment on column cds2db_in.location_raw.loc_alias is 'alias (30 x 3 90)';

comment on column cds2db_in.pids_per_ward_raw.date_time is 'date_time (30 x 1 30)';
comment on column cds2db_in.pids_per_ward_raw.ward_name is 'ward_name (30 x 1 30)';
comment on column cds2db_in.pids_per_ward_raw.patient_id is 'patient_id (30 x 1 30)';
