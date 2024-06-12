-----------------------------------------------------
-- Create SQL Tables in Schema "cds2db_in" --
-----------------------------------------------------

-- Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.encounter_raw (
  encounter_id serial PRIMARY KEY not null, -- Primary key of the entity
  enc_id varchar,   -- id (varchar)
  enc_patient_id varchar,   -- subject/reference (varchar)
  enc_partof_id varchar,   -- partOf/reference (varchar)
  enc_identifier_use varchar,   -- identifier/use (varchar)
  enc_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  enc_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  enc_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  enc_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  enc_identifier_type_text varchar,   -- identifier/type/text (varchar)
  enc_identifier_system varchar,   -- identifier/system (varchar)
  enc_identifier_value varchar,   -- identifier/value (varchar)
  enc_identifier_start varchar,   -- identifier/start (varchar)
  enc_identifier_end varchar,   -- identifier/end (varchar)
  enc_status varchar,   -- status (varchar)
  enc_class_system varchar,   -- class/coding/system (varchar)
  enc_class_version varchar,   -- class/coding/version (varchar)
  enc_class_code varchar,   -- class/coding/code (varchar)
  enc_class_display varchar,   -- class/coding/display (varchar)
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
  enc_period_start varchar,   -- period/start (varchar)
  enc_period_end varchar,   -- period/end (varchar)
  enc_diagnosis_condition_id varchar,   -- diagnosis/condition/reference (varchar)
  enc_diagnosis_use_system varchar,   -- diagnosis/use/coding/system (varchar)
  enc_diagnosis_use_version varchar,   -- diagnosis/use/coding/version (varchar)
  enc_diagnosis_use_code varchar,   -- diagnosis/use/coding/code (varchar)
  enc_diagnosis_use_display varchar,   -- diagnosis/use/coding/display (varchar)
  enc_diagnosis_use_text varchar,   -- diagnosis/use/text (varchar)
  enc_diagnosis_rank varchar,   -- diagnosis/rank (varchar)
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
  enc_location_id varchar,   -- location/location/reference (varchar)
  enc_location_type varchar,   -- location/location/type (varchar)
  enc_location_identifier_use varchar,   -- location/location/identifier/use (varchar)
  enc_location_identifier_type_system varchar,   -- location/location/identifier/type/coding/system (varchar)
  enc_location_identifier_type_version varchar,   -- location/location/identifier/type/coding/version (varchar)
  enc_location_identifier_type_code varchar,   -- location/location/identifier/type/coding/code (varchar)
  enc_location_identifier_type_display varchar,   -- location/location/identifier/type/coding/display (varchar)
  enc_location_identifier_type_text varchar,   -- location/location/identifier/type/text (varchar)
  enc_location_display varchar,   -- location/location/display (varchar)
  enc_location_status varchar,   -- location/location/status (varchar)
  enc_location_physicaltype_system varchar,   -- location/location/physicalType/coding/system (varchar)
  enc_location_physicaltype_version varchar,   -- location/location/physicalType/coding/version (varchar)
  enc_location_physicaltype_code varchar,   -- location/location/physicalType/coding/code (varchar)
  enc_location_physicaltype_display varchar,   -- location/location/physicalType/coding/display (varchar)
  enc_location_physicaltype_text varchar,   -- location/location/physicalType/text (varchar)
  enc_serviceprovider_id varchar,   -- serviceProvider/reference (varchar)
  enc_serviceprovider_type varchar,   -- serviceProvider/type (varchar)
  enc_serviceprovider_identifier_use varchar,   -- serviceProvider/identifier/use (varchar)
  enc_serviceprovider_identifier_type_system varchar,   -- serviceProvider/identifier/type/coding/system (varchar)
  enc_serviceprovider_identifier_type_version varchar,   -- serviceProvider/identifier/type/coding/version (varchar)
  enc_serviceprovider_identifier_type_code varchar,   -- serviceProvider/identifier/type/coding/code (varchar)
  enc_serviceprovider_identifier_type_display varchar,   -- serviceProvider/identifier/type/coding/display (varchar)
  enc_serviceprovider_identifier_type_text varchar,   -- serviceProvider/identifier/type/text (varchar)
  enc_serviceprovider_display varchar,   -- serviceProvider/display (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.patient_raw (
  patient_id serial PRIMARY KEY not null, -- Primary key of the entity
  pat_id varchar,   -- id (varchar)
  pat_identifier_use varchar,   -- identifier/use (varchar)
  pat_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  pat_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  pat_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  pat_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  pat_identifier_type_text varchar,   -- identifier/type/text (varchar)
  pat_identifier_system varchar,   -- identifier/system (varchar)
  pat_identifier_value varchar,   -- identifier/value (varchar)
  pat_identifier_start varchar,   -- identifier/start (varchar)
  pat_identifier_end varchar,   -- identifier/end (varchar)
  pat_name_text varchar,   -- name/text (varchar)
  pat_name_family varchar,   -- name/family (varchar)
  pat_name_given varchar,   -- name/given (varchar)
  pat_gender varchar,   -- gender (varchar)
  pat_birthdate varchar,   -- birthDate (varchar)
  pat_address_postalcode varchar,   -- address/postalCode (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.condition_raw (
  condition_id serial PRIMARY KEY not null, -- Primary key of the entity
  con_id varchar,   -- id (varchar)
  con_encounter_id varchar,   -- encounter/reference (varchar)
  con_patient_id varchar,   -- subject/reference (varchar)
  con_identifier_use varchar,   -- identifier/use (varchar)
  con_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  con_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  con_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  con_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  con_identifier_type_text varchar,   -- identifier/type/text (varchar)
  con_identifier_system varchar,   -- identifier/system (varchar)
  con_identifier_value varchar,   -- identifier/value (varchar)
  con_identifier_start varchar,   -- identifier/start (varchar)
  con_identifier_end varchar,   -- identifier/end (varchar)
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
  con_onsetperiod_start varchar,   -- onsetPeriod/start (varchar)
  con_onsetperiod_end varchar,   -- onsetPeriod/end (varchar)
  con_onsetdatetime varchar,   -- onsetDateTime (varchar)
  con_abatementdatetime varchar,   -- abatementDateTime (varchar)
  con_abatementage_value varchar,   -- abatementAge/value (varchar)
  con_abatementage_comparator varchar,   -- abatementAge/comparator (varchar)
  con_abatementage_unit varchar,   -- abatementAge/unit (varchar)
  con_abatementage_system varchar,   -- abatementAge/system (varchar)
  con_abatementage_code varchar,   -- abatementAge/code (varchar)
  con_abatementperiod_start varchar,   -- abatementPeriod/start (varchar)
  con_abatementperiod_end varchar,   -- abatementPeriod/end (varchar)
  con_abatementrange_low_value varchar,   -- abatementRange/low/value (varchar)
  con_abatementrange_low_unit varchar,   -- abatementRange/low/unit (varchar)
  con_abatementrange_low_system varchar,   -- abatementRange/low/system (varchar)
  con_abatementrange_low_code varchar,   -- abatementRange/low/code (varchar)
  con_abatementrange_high_value varchar,   -- abatementRange/high/value (varchar)
  con_abatementrange_high_unit varchar,   -- abatementRange/high/unit (varchar)
  con_abatementrange_high_system varchar,   -- abatementRange/high/system (varchar)
  con_abatementrange_high_code varchar,   -- abatementRange/high/code (varchar)
  con_abatementstring varchar,   -- abatementString (varchar)
  con_recordeddate varchar,   -- recordedDate (varchar)
  con_recorder_id varchar,   -- recorder/reference (varchar)
  con_recorder_type varchar,   -- recorder/type (varchar)
  con_recorder_identifier_use varchar,   -- recorder/identifier/use (varchar)
  con_recorder_identifier_type_system varchar,   -- recorder/identifier/type/coding/system (varchar)
  con_recorder_identifier_type_version varchar,   -- recorder/identifier/type/coding/version (varchar)
  con_recorder_identifier_type_code varchar,   -- recorder/identifier/type/coding/code (varchar)
  con_recorder_identifier_type_display varchar,   -- recorder/identifier/type/coding/display (varchar)
  con_recorder_identifier_type_text varchar,   -- recorder/identifier/type/text (varchar)
  con_recorder_display varchar,   -- recorder/display (varchar)
  con_asserter_id varchar,   -- asserter/reference (varchar)
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
  con_stage_assessment_id varchar,   -- stage/assessment/reference (varchar)
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
  con_note_authorreference_id varchar,   -- note/authorReference/reference (varchar)
  con_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  con_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  con_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  con_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  con_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  con_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  con_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  con_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  con_note_time varchar,   -- note/time (varchar)
  con_note_text varchar,   -- note/text (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medication_raw (
  medication_id serial PRIMARY KEY not null, -- Primary key of the entity
  med_id varchar,   -- id (varchar)
  med_identifier_use varchar,   -- identifier/use (varchar)
  med_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  med_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  med_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  med_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  med_identifier_type_text varchar,   -- identifier/type/text (varchar)
  med_identifier_system varchar,   -- identifier/system (varchar)
  med_identifier_value varchar,   -- identifier/value (varchar)
  med_identifier_start varchar,   -- identifier/start (varchar)
  med_identifier_end varchar,   -- identifier/end (varchar)
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
  med_amount_numerator_value varchar,   -- amount/numerator/value (varchar)
  med_amount_numerator_comparator varchar,   -- amount/numerator/comparator (varchar)
  med_amount_numerator_unit varchar,   -- amount/numerator/unit (varchar)
  med_amount_numerator_system varchar,   -- amount/numerator/system (varchar)
  med_amount_numerator_code varchar,   -- amount/numerator/code (varchar)
  med_amount_denominator_value varchar,   -- amount/denominator/value (varchar)
  med_amount_denominator_comparator varchar,   -- amount/denominator/comparator (varchar)
  med_amount_denominator_unit varchar,   -- amount/denominator/unit (varchar)
  med_amount_denominator_system varchar,   -- amount/denominator/system (varchar)
  med_amount_denominator_code varchar,   -- amount/denominator/code (varchar)
  med_ingredient_strength_numerator_value varchar,   -- ingredient/strength/numerator/value (varchar)
  med_ingredient_strength_numerator_comparator varchar,   -- ingredient/strength/numerator/comparator (varchar)
  med_ingredient_strength_numerator_unit varchar,   -- ingredient/strength/numerator/unit (varchar)
  med_ingredient_strength_numerator_system varchar,   -- ingredient/strength/numerator/system (varchar)
  med_ingredient_strength_numerator_code varchar,   -- ingredient/strength/numerator/code (varchar)
  med_ingredient_strength_denominator_value varchar,   -- ingredient/strength/denominator/value (varchar)
  med_ingredient_strength_denominator_comparator varchar,   -- ingredient/strength/denominator/comparator (varchar)
  med_ingredient_strength_denominator_unit varchar,   -- ingredient/strength/denominator/unit (varchar)
  med_ingredient_strength_denominator_system varchar,   -- ingredient/strength/denominator/system (varchar)
  med_ingredient_strength_denominator_code varchar,   -- ingredient/strength/denominator/code (varchar)
  med_ingredient_itemcodeableconcept_system varchar,   -- ingredient/itemCodeableConcept/coding/system (varchar)
  med_ingredient_itemcodeableconcept_version varchar,   -- ingredient/itemCodeableConcept/coding/version (varchar)
  med_ingredient_itemcodeableconcept_code varchar,   -- ingredient/itemCodeableConcept/coding/code (varchar)
  med_ingredient_itemcodeableconcept_display varchar,   -- ingredient/itemCodeableConcept/coding/display (varchar)
  med_ingredient_itemcodeableconcept_text varchar,   -- ingredient/itemCodeableConcept/text (varchar)
  med_ingredient_itemreference_id varchar,   -- ingredient/itemReference/reference (varchar)
  med_ingredient_itemreference_type varchar,   -- ingredient/itemReference/type (varchar)
  med_ingredient_itemreference_identifier_use varchar,   -- ingredient/itemReference/identifier/use (varchar)
  med_ingredient_itemreference_identifier_type_system varchar,   -- ingredient/itemReference/identifier/type/coding/system (varchar)
  med_ingredient_itemreference_identifier_type_version varchar,   -- ingredient/itemReference/identifier/type/coding/version (varchar)
  med_ingredient_itemreference_identifier_type_code varchar,   -- ingredient/itemReference/identifier/type/coding/code (varchar)
  med_ingredient_itemreference_identifier_type_display varchar,   -- ingredient/itemReference/identifier/type/coding/display (varchar)
  med_ingredient_itemreference_identifier_type_text varchar,   -- ingredient/itemReference/identifier/type/text (varchar)
  med_ingredient_itemreference_display varchar,   -- ingredient/itemReference/display (varchar)
  med_ingredient_isactive varchar,   -- ingredient/isActive (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationrequest_raw (
  medicationrequest_id serial PRIMARY KEY not null, -- Primary key of the entity
  medreq_id varchar,   -- id (varchar)
  medreq_encounter_id varchar,   -- encounter/reference (varchar)
  medreq_patient_id varchar,   -- subject/reference (varchar)
  medreq_identifier_use varchar,   -- identifier/use (varchar)
  medreq_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  medreq_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  medreq_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  medreq_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  medreq_identifier_type_text varchar,   -- identifier/type/text (varchar)
  medreq_identifier_system varchar,   -- identifier/system (varchar)
  medreq_identifier_value varchar,   -- identifier/value (varchar)
  medreq_identifier_start varchar,   -- identifier/start (varchar)
  medreq_identifier_end varchar,   -- identifier/end (varchar)
  medreq_medicationreference_id varchar,   -- medicationReference/reference (varchar)
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
  medreq_reportedboolean varchar,   -- reportedBoolean (varchar)
  medreq_reportedreference_id varchar,   -- reportedReference/reference (varchar)
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
  medreq_supportinginformation_id varchar,   -- supportingInformation/reference (varchar)
  medreq_supportinginformation_type varchar,   -- supportingInformation/type (varchar)
  medreq_supportinginformation_identifier_use varchar,   -- supportingInformation/identifier/use (varchar)
  medreq_supportinginformation_identifier_type_system varchar,   -- supportingInformation/identifier/type/coding/system (varchar)
  medreq_supportinginformation_identifier_type_version varchar,   -- supportingInformation/identifier/type/coding/version (varchar)
  medreq_supportinginformation_identifier_type_code varchar,   -- supportingInformation/identifier/type/coding/code (varchar)
  medreq_supportinginformation_identifier_type_display varchar,   -- supportingInformation/identifier/type/coding/display (varchar)
  medreq_supportinginformation_identifier_type_text varchar,   -- supportingInformation/identifier/type/text (varchar)
  medreq_supportinginformation_display varchar,   -- supportingInformation/display (varchar)
  medreq_authoredon varchar,   -- authoredOn (varchar)
  medreq_requester_id varchar,   -- requester/reference (varchar)
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
  medreq_reasonreference_id varchar,   -- reasonReference/reference (varchar)
  medreq_reasonreference_type varchar,   -- reasonReference/type (varchar)
  medreq_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  medreq_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  medreq_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  medreq_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  medreq_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  medreq_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  medreq_reasonreference_display varchar,   -- reasonReference/display (varchar)
  medreq_basedon_id varchar,   -- basedOn/reference (varchar)
  medreq_basedon_type varchar,   -- basedOn/type (varchar)
  medreq_basedon_identifier_use varchar,   -- basedOn/identifier/use (varchar)
  medreq_basedon_identifier_type_system varchar,   -- basedOn/identifier/type/coding/system (varchar)
  medreq_basedon_identifier_type_version varchar,   -- basedOn/identifier/type/coding/version (varchar)
  medreq_basedon_identifier_type_code varchar,   -- basedOn/identifier/type/coding/code (varchar)
  medreq_basedon_identifier_type_display varchar,   -- basedOn/identifier/type/coding/display (varchar)
  medreq_basedon_identifier_type_text varchar,   -- basedOn/identifier/type/text (varchar)
  medreq_basedon_display varchar,   -- basedOn/display (varchar)
  medreq_note_authorstring varchar,   -- note/authorString (varchar)
  medreq_note_authorreference_id varchar,   -- note/authorReference/reference (varchar)
  medreq_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  medreq_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  medreq_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  medreq_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  medreq_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  medreq_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  medreq_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  medreq_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  medreq_note_time varchar,   -- note/time (varchar)
  medreq_note_text varchar,   -- note/text (varchar)
  medreq_doseinstruc_sequence varchar,   -- dosageInstruction/sequence (varchar)
  medreq_doseinstruc_text varchar,   -- dosageInstruction/text (varchar)
  medreq_doseinstruc_additionalinstruction_system varchar,   -- dosageInstruction/additionalInstruction/coding/system (varchar)
  medreq_doseinstruc_additionalinstruction_version varchar,   -- dosageInstruction/additionalInstruction/coding/version (varchar)
  medreq_doseinstruc_additionalinstruction_code varchar,   -- dosageInstruction/additionalInstruction/coding/code (varchar)
  medreq_doseinstruc_additionalinstruction_display varchar,   -- dosageInstruction/additionalInstruction/coding/display (varchar)
  medreq_doseinstruc_additionalinstruction_text varchar,   -- dosageInstruction/additionalInstruction/text (varchar)
  medreq_doseinstruc_patientinstruction varchar,   -- dosageInstruction/patientInstruction (varchar)
  medreq_doseinstruc_timing_event varchar,   -- dosageInstruction/timing/event (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_value varchar,   -- dosageInstruction/timing/repeat/boundsDuration/value (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_comparator varchar,   -- dosageInstruction/timing/repeat/boundsDuration/comparator (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_unit varchar,   -- dosageInstruction/timing/repeat/boundsDuration/unit (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_system varchar,   -- dosageInstruction/timing/repeat/boundsDuration/system (varchar)
  medreq_doseinstruc_timing_repeat_boundsduration_code varchar,   -- dosageInstruction/timing/repeat/boundsDuration/code (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_value varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/value (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_unit varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/unit (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_system varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/system (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_low_code varchar,   -- dosageInstruction/timing/repeat/boundsRange/low/code (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_value varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/value (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_unit varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/unit (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_system varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/system (varchar)
  medreq_doseinstruc_timing_repeat_boundsrange_high_code varchar,   -- dosageInstruction/timing/repeat/boundsRange/high/code (varchar)
  medreq_doseinstruc_timing_repeat_boundsperiod_start varchar,   -- dosageInstruction/timing/repeat/boundsPeriod/start (varchar)
  medreq_doseinstruc_timing_repeat_boundsperiod_end varchar,   -- dosageInstruction/timing/repeat/boundsPeriod/end (varchar)
  medreq_doseinstruc_timing_repeat_count varchar,   -- dosageInstruction/timing/repeat/count (varchar)
  medreq_doseinstruc_timing_repeat_countmax varchar,   -- dosageInstruction/timing/repeat/countMax (varchar)
  medreq_doseinstruc_timing_repeat_duration varchar,   -- dosageInstruction/timing/repeat/duration (varchar)
  medreq_doseinstruc_timing_repeat_durationmax varchar,   -- dosageInstruction/timing/repeat/durationMax (varchar)
  medreq_doseinstruc_timing_repeat_durationunit varchar,   -- dosageInstruction/timing/repeat/durationUnit (varchar)
  medreq_doseinstruc_timing_repeat_frequency varchar,   -- dosageInstruction/timing/repeat/frequency (varchar)
  medreq_doseinstruc_timing_repeat_frequencymax varchar,   -- dosageInstruction/timing/repeat/frequencyMax (varchar)
  medreq_doseinstruc_timing_repeat_period varchar,   -- dosageInstruction/timing/repeat/period (varchar)
  medreq_doseinstruc_timing_repeat_periodmax varchar,   -- dosageInstruction/timing/repeat/periodMax (varchar)
  medreq_doseinstruc_timing_repeat_periodunit varchar,   -- dosageInstruction/timing/repeat/periodUnit (varchar)
  medreq_doseinstruc_timing_repeat_dayofweek varchar,   -- dosageInstruction/timing/repeat/dayOfWeek (varchar)
  medreq_doseinstruc_timing_repeat_timeofday varchar,   -- dosageInstruction/timing/repeat/timeOfDay (varchar)
  medreq_doseinstruc_timing_repeat_when varchar,   -- dosageInstruction/timing/repeat/when (varchar)
  medreq_doseinstruc_timing_repeat_offset varchar,   -- dosageInstruction/timing/repeat/offset (varchar)
  medreq_doseinstruc_timing_code_system varchar,   -- dosageInstruction/timing/code/coding/system (varchar)
  medreq_doseinstruc_timing_code_version varchar,   -- dosageInstruction/timing/code/coding/version (varchar)
  medreq_doseinstruc_timing_code_code varchar,   -- dosageInstruction/timing/code/coding/code (varchar)
  medreq_doseinstruc_timing_code_display varchar,   -- dosageInstruction/timing/code/coding/display (varchar)
  medreq_doseinstruc_timing_code_text varchar,   -- dosageInstruction/timing/code/text (varchar)
  medreq_doseinstruc_asneededboolean varchar,   -- dosageInstruction/asNeededBoolean (varchar)
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
  medreq_doseinstruc_doseandrate_doserange_low_value varchar,   -- dosageInstruction/doseAndRate/doseRange/low/value (varchar)
  medreq_doseinstruc_doseandrate_doserange_low_unit varchar,   -- dosageInstruction/doseAndRate/doseRange/low/unit (varchar)
  medreq_doseinstruc_doseandrate_doserange_low_system varchar,   -- dosageInstruction/doseAndRate/doseRange/low/system (varchar)
  medreq_doseinstruc_doseandrate_doserange_low_code varchar,   -- dosageInstruction/doseAndRate/doseRange/low/code (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_value varchar,   -- dosageInstruction/doseAndRate/doseRange/high/value (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_unit varchar,   -- dosageInstruction/doseAndRate/doseRange/high/unit (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_system varchar,   -- dosageInstruction/doseAndRate/doseRange/high/system (varchar)
  medreq_doseinstruc_doseandrate_doserange_high_code varchar,   -- dosageInstruction/doseAndRate/doseRange/high/code (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_value varchar,   -- dosageInstruction/doseAndRate/doseQuantity/value (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_comparator varchar,   -- dosageInstruction/doseAndRate/doseQuantity/comparator (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_unit varchar,   -- dosageInstruction/doseAndRate/doseQuantity/unit (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_system varchar,   -- dosageInstruction/doseAndRate/doseQuantity/system (varchar)
  medreq_doseinstruc_doseandrate_dosequantity_code varchar,   -- dosageInstruction/doseAndRate/doseQuantity/code (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_value varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/value (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_comparator varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/comparator (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_unit varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/unit (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_system varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/system (varchar)
  medreq_doseinstruc_doseandrate_rateratio_numerator_code varchar,   -- dosageInstruction/doseAndRate/rateRatio/numerator/code (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_value varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/value (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_comparator varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/comparator (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_unit varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/unit (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_system varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/system (varchar)
  medreq_doseinstruc_doseandrate_rateratio_denominator_code varchar,   -- dosageInstruction/doseAndRate/rateRatio/denominator/code (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_value varchar,   -- dosageInstruction/doseAndRate/rateRange/low/value (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_unit varchar,   -- dosageInstruction/doseAndRate/rateRange/low/unit (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_system varchar,   -- dosageInstruction/doseAndRate/rateRange/low/system (varchar)
  medreq_doseinstruc_doseandrate_raterange_low_code varchar,   -- dosageInstruction/doseAndRate/rateRange/low/code (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_value varchar,   -- dosageInstruction/doseAndRate/rateRange/high/value (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_unit varchar,   -- dosageInstruction/doseAndRate/rateRange/high/unit (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_system varchar,   -- dosageInstruction/doseAndRate/rateRange/high/system (varchar)
  medreq_doseinstruc_doseandrate_raterange_high_code varchar,   -- dosageInstruction/doseAndRate/rateRange/high/code (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_value varchar,   -- dosageInstruction/doseAndRate/rateQuantity/value (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_unit varchar,   -- dosageInstruction/doseAndRate/rateQuantity/unit (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_system varchar,   -- dosageInstruction/doseAndRate/rateQuantity/system (varchar)
  medreq_doseinstruc_doseandrate_ratequantity_code varchar,   -- dosageInstruction/doseAndRate/rateQuantity/code (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_value varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/value (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_comparator varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/comparator (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_unit varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/unit (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_system varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/system (varchar)
  medreq_doseinstruc_maxdoseperperiod_numerator_code varchar,   -- dosageInstruction/maxDosePerPeriod/numerator/code (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_value varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/value (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_comparator varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/comparator (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_unit varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/unit (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_system varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/system (varchar)
  medreq_doseinstruc_maxdoseperperiod_denominator_code varchar,   -- dosageInstruction/maxDosePerPeriod/denominator/code (varchar)
  medreq_doseinstruc_maxdoseperadministration_value varchar,   -- dosageInstruction/maxDosePerAdministration/value (varchar)
  medreq_doseinstruc_maxdoseperadministration_unit varchar,   -- dosageInstruction/maxDosePerAdministration/unit (varchar)
  medreq_doseinstruc_maxdoseperadministration_system varchar,   -- dosageInstruction/maxDosePerAdministration/system (varchar)
  medreq_doseinstruc_maxdoseperadministration_code varchar,   -- dosageInstruction/maxDosePerAdministration/code (varchar)
  medreq_doseinstruc_maxdoseperlifetime_value varchar,   -- dosageInstruction/maxDosePerLifetime/value (varchar)
  medreq_doseinstruc_maxdoseperlifetime_unit varchar,   -- dosageInstruction/maxDosePerLifetime/unit (varchar)
  medreq_doseinstruc_maxdoseperlifetime_system varchar,   -- dosageInstruction/maxDosePerLifetime/system (varchar)
  medreq_doseinstruc_maxdoseperlifetime_code varchar,   -- dosageInstruction/maxDosePerLifetime/code (varchar)
  medreq_substitution_reason_system varchar,   -- substitution/reason/coding/system (varchar)
  medreq_substitution_reason_version varchar,   -- substitution/reason/coding/version (varchar)
  medreq_substitution_reason_code varchar,   -- substitution/reason/coding/code (varchar)
  medreq_substitution_reason_display varchar,   -- substitution/reason/coding/display (varchar)
  medreq_substitution_reason_text varchar,   -- substitution/reason/text (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationadministration_raw (
  medicationadministration_id serial PRIMARY KEY not null, -- Primary key of the entity
  medadm_id varchar,   -- id (varchar)
  medadm_encounter_id varchar,   -- context/reference (varchar)
  medadm_patient_id varchar,   -- subject/reference (varchar)
  medadm_partof_id varchar,   -- partOf/reference (varchar)
  medadm_identifier_use varchar,   -- identifier/use (varchar)
  medadm_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  medadm_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  medadm_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  medadm_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  medadm_identifier_type_text varchar,   -- identifier/type/text (varchar)
  medadm_identifier_system varchar,   -- identifier/system (varchar)
  medadm_identifier_value varchar,   -- identifier/value (varchar)
  medadm_identifier_start varchar,   -- identifier/start (varchar)
  medadm_identifier_end varchar,   -- identifier/end (varchar)
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
  medadm_medicationreference_id varchar,   -- medicationReference/reference (varchar)
  medadm_medicationcodeableconcept_system varchar,   -- medicationCodeableConcept/coding/system (varchar)
  medadm_medicationcodeableconcept_version varchar,   -- medicationCodeableConcept/coding/version (varchar)
  medadm_medicationcodeableconcept_code varchar,   -- medicationCodeableConcept/coding/code (varchar)
  medadm_medicationcodeableconcept_display varchar,   -- medicationCodeableConcept/coding/display (varchar)
  medadm_medicationcodeableconcept_text varchar,   -- medicationCodeableConcept/text (varchar)
  medadm_supportinginformation_id varchar,   -- supportingInformation/reference (varchar)
  medadm_supportinginformation_type varchar,   -- supportingInformation/type (varchar)
  medadm_supportinginformation_identifier_use varchar,   -- supportingInformation/identifier/use (varchar)
  medadm_supportinginformation_identifier_type_system varchar,   -- supportingInformation/identifier/type/coding/system (varchar)
  medadm_supportinginformation_identifier_type_version varchar,   -- supportingInformation/identifier/type/coding/version (varchar)
  medadm_supportinginformation_identifier_type_code varchar,   -- supportingInformation/identifier/type/coding/code (varchar)
  medadm_supportinginformation_identifier_type_display varchar,   -- supportingInformation/identifier/type/coding/display (varchar)
  medadm_supportinginformation_identifier_type_text varchar,   -- supportingInformation/identifier/type/text (varchar)
  medadm_supportinginformation_display varchar,   -- supportingInformation/display (varchar)
  medadm_effectivedatetime varchar,   -- effectiveDateTime (varchar)
  medadm_effectiveperiod_start varchar,   -- effectivePeriod/start (varchar)
  medadm_effectiveperiod_end varchar,   -- effectivePeriod/end (varchar)
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
  medadm_reasonreference_id varchar,   -- reasonReference/reference (varchar)
  medadm_reasonreference_type varchar,   -- reasonReference/type (varchar)
  medadm_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  medadm_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  medadm_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  medadm_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  medadm_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  medadm_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  medadm_reasonreference_display varchar,   -- reasonReference/display (varchar)
  medadm_request_id varchar,   -- request/reference (varchar)
  medadm_note_authorstring varchar,   -- note/authorString (varchar)
  medadm_note_authorreference_id varchar,   -- note/authorReference/reference (varchar)
  medadm_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  medadm_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  medadm_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  medadm_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  medadm_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  medadm_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  medadm_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  medadm_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  medadm_note_time varchar,   -- note/time (varchar)
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
  medadm_dosage_dose_value varchar,   -- dosage/dose/value (varchar)
  medadm_dosage_dose_unit varchar,   -- dosage/dose/unit (varchar)
  medadm_dosage_dose_system varchar,   -- dosage/dose/system (varchar)
  medadm_dosage_dose_code varchar,   -- dosage/dose/code (varchar)
  medadm_dosage_rateratio_numerator_value varchar,   -- dosage/rateRatio/numerator/value (varchar)
  medadm_dosage_rateratio_numerator_comparator varchar,   -- dosage/rateRatio/numerator/comparator (varchar)
  medadm_dosage_rateratio_numerator_unit varchar,   -- dosage/rateRatio/numerator/unit (varchar)
  medadm_dosage_rateratio_numerator_system varchar,   -- dosage/rateRatio/numerator/system (varchar)
  medadm_dosage_rateratio_numerator_code varchar,   -- dosage/rateRatio/numerator/code (varchar)
  medadm_dosage_rateratio_denominator_value varchar,   -- dosage/rateRatio/denominator/value (varchar)
  medadm_dosage_rateratio_denominator_comparator varchar,   -- dosage/rateRatio/denominator/comparator (varchar)
  medadm_dosage_rateratio_denominator_unit varchar,   -- dosage/rateRatio/denominator/unit (varchar)
  medadm_dosage_rateratio_denominator_system varchar,   -- dosage/rateRatio/denominator/system (varchar)
  medadm_dosage_rateratio_denominator_code varchar,   -- dosage/rateRatio/denominator/code (varchar)
  medadm_dosage_ratequantity_value varchar,   -- dosage/rateQuantity/value (varchar)
  medadm_dosage_ratequantity_unit varchar,   -- dosage/rateQuantity/unit (varchar)
  medadm_dosage_ratequantity_system varchar,   -- dosage/rateQuantity/system (varchar)
  medadm_dosage_ratequantity_code varchar,   -- dosage/rateQuantity/code (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.medicationstatement_raw (
  medicationstatement_id serial PRIMARY KEY not null, -- Primary key of the entity
  medstat_id varchar,   -- id (varchar)
  medstat_identifier_use varchar,   -- identifier/use (varchar)
  medstat_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  medstat_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  medstat_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  medstat_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  medstat_identifier_type_text varchar,   -- identifier/type/text (varchar)
  medstat_identifier_system varchar,   -- identifier/system (varchar)
  medstat_identifier_value varchar,   -- identifier/value (varchar)
  medstat_identifier_start varchar,   -- identifier/start (varchar)
  medstat_identifier_end varchar,   -- identifier/end (varchar)
  medstat_encounter_id varchar,   -- context/reference (varchar)
  medstat_patient_id varchar,   -- subject/reference (varchar)
  medstat_partof_id varchar,   -- partOf/reference (varchar)
  medstat_basedon_id varchar,   -- basedOn/reference (varchar)
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
  medstat_medicationreference_id varchar,   -- medicationReference/reference (varchar)
  medstat_medicationcodeableconcept_system varchar,   -- medicationCodeableConcept/coding/system (varchar)
  medstat_medicationcodeableconcept_version varchar,   -- medicationCodeableConcept/coding/version (varchar)
  medstat_medicationcodeableconcept_code varchar,   -- medicationCodeableConcept/coding/code (varchar)
  medstat_medicationcodeableconcept_display varchar,   -- medicationCodeableConcept/coding/display (varchar)
  medstat_medicationcodeableconcept_text varchar,   -- medicationCodeableConcept/text (varchar)
  medstat_effectivedatetime varchar,   -- effectiveDateTime (varchar)
  medstat_effectiveperiod_start varchar,   -- effectivePeriod/start (varchar)
  medstat_effectiveperiod_end varchar,   -- effectivePeriod/end (varchar)
  medstat_dateasserted varchar,   -- dateAsserted (varchar)
  medstat_informationsource_id varchar,   -- informationSource/reference (varchar)
  medstat_informationsource_type varchar,   -- informationSource/type (varchar)
  medstat_informationsource_identifier_use varchar,   -- informationSource/identifier/use (varchar)
  medstat_informationsource_identifier_type_system varchar,   -- informationSource/identifier/type/coding/system (varchar)
  medstat_informationsource_identifier_type_version varchar,   -- informationSource/identifier/type/coding/version (varchar)
  medstat_informationsource_identifier_type_code varchar,   -- informationSource/identifier/type/coding/code (varchar)
  medstat_informationsource_identifier_type_display varchar,   -- informationSource/identifier/type/coding/display (varchar)
  medstat_informationsource_identifier_type_text varchar,   -- informationSource/identifier/type/text (varchar)
  medstat_informationsource_display varchar,   -- informationSource/display (varchar)
  medstat_derivedfrom_id varchar,   -- derivedFrom/reference (varchar)
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
  medstat_reasonreference_id varchar,   -- reasonReference/reference (varchar)
  medstat_reasonreference_type varchar,   -- reasonReference/type (varchar)
  medstat_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  medstat_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  medstat_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  medstat_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  medstat_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  medstat_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  medstat_reasonreference_display varchar,   -- reasonReference/display (varchar)
  medstat_note_authorstring varchar,   -- note/authorString (varchar)
  medstat_note_authorreference_id varchar,   -- note/authorReference/reference (varchar)
  medstat_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  medstat_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  medstat_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  medstat_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  medstat_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  medstat_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  medstat_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  medstat_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  medstat_note_time varchar,   -- note/time (varchar)
  medstat_note_text varchar,   -- note/text (varchar)
  medstat_dosage_sequence varchar,   -- dosage/sequence (varchar)
  medstat_dosage_text varchar,   -- dosage/text (varchar)
  medstat_dosage_additionalinstruction_system varchar,   -- dosage/additionalInstruction/coding/system (varchar)
  medstat_dosage_additionalinstruction_version varchar,   -- dosage/additionalInstruction/coding/version (varchar)
  medstat_dosage_additionalinstruction_code varchar,   -- dosage/additionalInstruction/coding/code (varchar)
  medstat_dosage_additionalinstruction_display varchar,   -- dosage/additionalInstruction/coding/display (varchar)
  medstat_dosage_additionalinstruction_text varchar,   -- dosage/additionalInstruction/text (varchar)
  medstat_dosage_patientinstruction varchar,   -- dosage/patientInstruction (varchar)
  medstat_dosage_timing_event varchar,   -- dosage/timing/event (varchar)
  medstat_dosage_timing_repeat_boundsduration_value varchar,   -- dosage/timing/repeat/boundsDuration/value (varchar)
  medstat_dosage_timing_repeat_boundsduration_comparator varchar,   -- dosage/timing/repeat/boundsDuration/comparator (varchar)
  medstat_dosage_timing_repeat_boundsduration_unit varchar,   -- dosage/timing/repeat/boundsDuration/unit (varchar)
  medstat_dosage_timing_repeat_boundsduration_system varchar,   -- dosage/timing/repeat/boundsDuration/system (varchar)
  medstat_dosage_timing_repeat_boundsduration_code varchar,   -- dosage/timing/repeat/boundsDuration/code (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_value varchar,   -- dosage/timing/repeat/boundsRange/low/value (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_unit varchar,   -- dosage/timing/repeat/boundsRange/low/unit (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_system varchar,   -- dosage/timing/repeat/boundsRange/low/system (varchar)
  medstat_dosage_timing_repeat_boundsrange_low_code varchar,   -- dosage/timing/repeat/boundsRange/low/code (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_value varchar,   -- dosage/timing/repeat/boundsRange/high/value (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_unit varchar,   -- dosage/timing/repeat/boundsRange/high/unit (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_system varchar,   -- dosage/timing/repeat/boundsRange/high/system (varchar)
  medstat_dosage_timing_repeat_boundsrange_high_code varchar,   -- dosage/timing/repeat/boundsRange/high/code (varchar)
  medstat_dosage_timing_repeat_boundsperiod_start varchar,   -- dosage/timing/repeat/boundsPeriod/start (varchar)
  medstat_dosage_timing_repeat_boundsperiod_end varchar,   -- dosage/timing/repeat/boundsPeriod/end (varchar)
  medstat_dosage_timing_repeat_count varchar,   -- dosage/timing/repeat/count (varchar)
  medstat_dosage_timing_repeat_countmax varchar,   -- dosage/timing/repeat/countMax (varchar)
  medstat_dosage_timing_repeat_duration varchar,   -- dosage/timing/repeat/duration (varchar)
  medstat_dosage_timing_repeat_durationmax varchar,   -- dosage/timing/repeat/durationMax (varchar)
  medstat_dosage_timing_repeat_durationunit varchar,   -- dosage/timing/repeat/durationUnit (varchar)
  medstat_dosage_timing_repeat_frequency varchar,   -- dosage/timing/repeat/frequency (varchar)
  medstat_dosage_timing_repeat_frequencymax varchar,   -- dosage/timing/repeat/frequencyMax (varchar)
  medstat_dosage_timing_repeat_period varchar,   -- dosage/timing/repeat/period (varchar)
  medstat_dosage_timing_repeat_periodmax varchar,   -- dosage/timing/repeat/periodMax (varchar)
  medstat_dosage_timing_repeat_periodunit varchar,   -- dosage/timing/repeat/periodUnit (varchar)
  medstat_dosage_timing_repeat_dayofweek varchar,   -- dosage/timing/repeat/dayOfWeek (varchar)
  medstat_dosage_timing_repeat_timeofday varchar,   -- dosage/timing/repeat/timeOfDay (varchar)
  medstat_dosage_timing_repeat_when varchar,   -- dosage/timing/repeat/when (varchar)
  medstat_dosage_timing_repeat_offset varchar,   -- dosage/timing/repeat/offset (varchar)
  medstat_dosage_timing_code_system varchar,   -- dosage/timing/code/coding/system (varchar)
  medstat_dosage_timing_code_version varchar,   -- dosage/timing/code/coding/version (varchar)
  medstat_dosage_timing_code_code varchar,   -- dosage/timing/code/coding/code (varchar)
  medstat_dosage_timing_code_display varchar,   -- dosage/timing/code/coding/display (varchar)
  medstat_dosage_timing_code_text varchar,   -- dosage/timing/code/text (varchar)
  medstat_dosage_asneededboolean varchar,   -- dosage/asNeededBoolean (varchar)
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
  medstat_dosage_doseandrate_doserange_low_value varchar,   -- dosage/doseAndRate/doseRange/low/value (varchar)
  medstat_dosage_doseandrate_doserange_low_unit varchar,   -- dosage/doseAndRate/doseRange/low/unit (varchar)
  medstat_dosage_doseandrate_doserange_low_system varchar,   -- dosage/doseAndRate/doseRange/low/system (varchar)
  medstat_dosage_doseandrate_doserange_low_code varchar,   -- dosage/doseAndRate/doseRange/low/code (varchar)
  medstat_dosage_doseandrate_doserange_high_value varchar,   -- dosage/doseAndRate/doseRange/high/value (varchar)
  medstat_dosage_doseandrate_doserange_high_unit varchar,   -- dosage/doseAndRate/doseRange/high/unit (varchar)
  medstat_dosage_doseandrate_doserange_high_system varchar,   -- dosage/doseAndRate/doseRange/high/system (varchar)
  medstat_dosage_doseandrate_doserange_high_code varchar,   -- dosage/doseAndRate/doseRange/high/code (varchar)
  medstat_dosage_doseandrate_dosequantity_value varchar,   -- dosage/doseAndRate/doseQuantity/value (varchar)
  medstat_dosage_doseandrate_dosequantity_comparator varchar,   -- dosage/doseAndRate/doseQuantity/comparator (varchar)
  medstat_dosage_doseandrate_dosequantity_unit varchar,   -- dosage/doseAndRate/doseQuantity/unit (varchar)
  medstat_dosage_doseandrate_dosequantity_system varchar,   -- dosage/doseAndRate/doseQuantity/system (varchar)
  medstat_dosage_doseandrate_dosequantity_code varchar,   -- dosage/doseAndRate/doseQuantity/code (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_value varchar,   -- dosage/doseAndRate/rateRatio/numerator/value (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_comparator varchar,   -- dosage/doseAndRate/rateRatio/numerator/comparator (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_unit varchar,   -- dosage/doseAndRate/rateRatio/numerator/unit (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_system varchar,   -- dosage/doseAndRate/rateRatio/numerator/system (varchar)
  medstat_dosage_doseandrate_rateratio_numerator_code varchar,   -- dosage/doseAndRate/rateRatio/numerator/code (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_value varchar,   -- dosage/doseAndRate/rateRatio/denominator/value (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_comparator varchar,   -- dosage/doseAndRate/rateRatio/denominator/comparator (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_unit varchar,   -- dosage/doseAndRate/rateRatio/denominator/unit (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_system varchar,   -- dosage/doseAndRate/rateRatio/denominator/system (varchar)
  medstat_dosage_doseandrate_rateratio_denominator_code varchar,   -- dosage/doseAndRate/rateRatio/denominator/code (varchar)
  medstat_dosage_doseandrate_raterange_low_value varchar,   -- dosage/doseAndRate/rateRange/low/value (varchar)
  medstat_dosage_doseandrate_raterange_low_unit varchar,   -- dosage/doseAndRate/rateRange/low/unit (varchar)
  medstat_dosage_doseandrate_raterange_low_system varchar,   -- dosage/doseAndRate/rateRange/low/system (varchar)
  medstat_dosage_doseandrate_raterange_low_code varchar,   -- dosage/doseAndRate/rateRange/low/code (varchar)
  medstat_dosage_doseandrate_raterange_high_value varchar,   -- dosage/doseAndRate/rateRange/high/value (varchar)
  medstat_dosage_doseandrate_raterange_high_unit varchar,   -- dosage/doseAndRate/rateRange/high/unit (varchar)
  medstat_dosage_doseandrate_raterange_high_system varchar,   -- dosage/doseAndRate/rateRange/high/system (varchar)
  medstat_dosage_doseandrate_raterange_high_code varchar,   -- dosage/doseAndRate/rateRange/high/code (varchar)
  medstat_dosage_doseandrate_ratequantity_value varchar,   -- dosage/doseAndRate/rateQuantity/value (varchar)
  medstat_dosage_doseandrate_ratequantity_unit varchar,   -- dosage/doseAndRate/rateQuantity/unit (varchar)
  medstat_dosage_doseandrate_ratequantity_system varchar,   -- dosage/doseAndRate/rateQuantity/system (varchar)
  medstat_dosage_doseandrate_ratequantity_code varchar,   -- dosage/doseAndRate/rateQuantity/code (varchar)
  medstat_dosage_maxdoseperperiod_numerator_value varchar,   -- dosage/maxDosePerPeriod/numerator/value (varchar)
  medstat_dosage_maxdoseperperiod_numerator_comparator varchar,   -- dosage/maxDosePerPeriod/numerator/comparator (varchar)
  medstat_dosage_maxdoseperperiod_numerator_unit varchar,   -- dosage/maxDosePerPeriod/numerator/unit (varchar)
  medstat_dosage_maxdoseperperiod_numerator_system varchar,   -- dosage/maxDosePerPeriod/numerator/system (varchar)
  medstat_dosage_maxdoseperperiod_numerator_code varchar,   -- dosage/maxDosePerPeriod/numerator/code (varchar)
  medstat_dosage_maxdoseperperiod_denominator_value varchar,   -- dosage/maxDosePerPeriod/denominator/value (varchar)
  medstat_dosage_maxdoseperperiod_denominator_comparator varchar,   -- dosage/maxDosePerPeriod/denominator/comparator (varchar)
  medstat_dosage_maxdoseperperiod_denominator_unit varchar,   -- dosage/maxDosePerPeriod/denominator/unit (varchar)
  medstat_dosage_maxdoseperperiod_denominator_system varchar,   -- dosage/maxDosePerPeriod/denominator/system (varchar)
  medstat_dosage_maxdoseperperiod_denominator_code varchar,   -- dosage/maxDosePerPeriod/denominator/code (varchar)
  medstat_dosage_maxdoseperadministration_value varchar,   -- dosage/maxDosePerAdministration/value (varchar)
  medstat_dosage_maxdoseperadministration_unit varchar,   -- dosage/maxDosePerAdministration/unit (varchar)
  medstat_dosage_maxdoseperadministration_system varchar,   -- dosage/maxDosePerAdministration/system (varchar)
  medstat_dosage_maxdoseperadministration_code varchar,   -- dosage/maxDosePerAdministration/code (varchar)
  medstat_dosage_maxdoseperlifetime_value varchar,   -- dosage/maxDosePerLifetime/value (varchar)
  medstat_dosage_maxdoseperlifetime_unit varchar,   -- dosage/maxDosePerLifetime/unit (varchar)
  medstat_dosage_maxdoseperlifetime_system varchar,   -- dosage/maxDosePerLifetime/system (varchar)
  medstat_dosage_maxdoseperlifetime_code varchar,   -- dosage/maxDosePerLifetime/code (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.observation_raw (
  observation_id serial PRIMARY KEY not null, -- Primary key of the entity
  obs_id varchar,   -- id (varchar)
  obs_encounter_id varchar,   -- encounter/reference (varchar)
  obs_patient_id varchar,   -- subject/reference (varchar)
  obs_partof_id varchar,   -- partOf/reference (varchar)
  obs_identifier_use varchar,   -- identifier/use (varchar)
  obs_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  obs_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  obs_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  obs_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  obs_identifier_type_text varchar,   -- identifier/type/text (varchar)
  obs_identifier_system varchar,   -- identifier/system (varchar)
  obs_identifier_value varchar,   -- identifier/value (varchar)
  obs_identifier_start varchar,   -- identifier/start (varchar)
  obs_identifier_end varchar,   -- identifier/end (varchar)
  obs_basedon_id varchar,   -- basedOn/reference (varchar)
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
  obs_effectivedatetime varchar,   -- effectiveDateTime (varchar)
  obs_issued varchar,   -- issued (varchar)
  obs_valuerange_low_value varchar,   -- valueRange/low/value (varchar)
  obs_valuerange_low_unit varchar,   -- valueRange/low/unit (varchar)
  obs_valuerange_low_system varchar,   -- valueRange/low/system (varchar)
  obs_valuerange_low_code varchar,   -- valueRange/low/code (varchar)
  obs_valuerange_high_value varchar,   -- valueRange/high/value (varchar)
  obs_valuerange_high_unit varchar,   -- valueRange/high/unit (varchar)
  obs_valuerange_high_system varchar,   -- valueRange/high/system (varchar)
  obs_valuerange_high_code varchar,   -- valueRange/high/code (varchar)
  obs_valueratio_numerator_value varchar,   -- valueRatio/numerator/value (varchar)
  obs_valueratio_numerator_comparator varchar,   -- valueRatio/numerator/comparator (varchar)
  obs_valueratio_numerator_unit varchar,   -- valueRatio/numerator/unit (varchar)
  obs_valueratio_numerator_system varchar,   -- valueRatio/numerator/system (varchar)
  obs_valueratio_numerator_code varchar,   -- valueRatio/numerator/code (varchar)
  obs_valueratio_denominator_value varchar,   -- valueRatio/denominator/value (varchar)
  obs_valueratio_denominator_comparator varchar,   -- valueRatio/denominator/comparator (varchar)
  obs_valueratio_denominator_unit varchar,   -- valueRatio/denominator/unit (varchar)
  obs_valueratio_denominator_system varchar,   -- valueRatio/denominator/system (varchar)
  obs_valueratio_denominator_code varchar,   -- valueRatio/denominator/code (varchar)
  obs_valuequantity_value varchar,   -- valueQuantity/value (varchar)
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
  obs_note_authorreference_id varchar,   -- note/authorReference/reference (varchar)
  obs_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  obs_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  obs_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  obs_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  obs_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  obs_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  obs_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  obs_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  obs_note_time varchar,   -- note/time (varchar)
  obs_note_text varchar,   -- note/text (varchar)
  obs_method_system varchar,   -- method/coding/system (varchar)
  obs_method_version varchar,   -- method/coding/version (varchar)
  obs_method_code varchar,   -- method/coding/code (varchar)
  obs_method_display varchar,   -- method/coding/display (varchar)
  obs_method_text varchar,   -- method/text (varchar)
  obs_performer_id varchar,   -- performer/reference (varchar)
  obs_performer_type varchar,   -- performer/type (varchar)
  obs_performer_identifier_use varchar,   -- performer/identifier/use (varchar)
  obs_performer_identifier_type_system varchar,   -- performer/identifier/type/coding/system (varchar)
  obs_performer_identifier_type_version varchar,   -- performer/identifier/type/coding/version (varchar)
  obs_performer_identifier_type_code varchar,   -- performer/identifier/type/coding/code (varchar)
  obs_performer_identifier_type_display varchar,   -- performer/identifier/type/coding/display (varchar)
  obs_performer_identifier_type_text varchar,   -- performer/identifier/type/text (varchar)
  obs_performer_display varchar,   -- performer/display (varchar)
  obs_referencerange_low_value varchar,   -- referenceRange/low/value (varchar)
  obs_referencerange_low_unit varchar,   -- referenceRange/low/unit (varchar)
  obs_referencerange_low_system varchar,   -- referenceRange/low/system (varchar)
  obs_referencerange_low_code varchar,   -- referenceRange/low/code (varchar)
  obs_referencerange_high_value varchar,   -- referenceRange/high/value (varchar)
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
  obs_referencerange_age_low_value varchar,   -- referenceRange/age/low/value (varchar)
  obs_referencerange_age_low_unit varchar,   -- referenceRange/age/low/unit (varchar)
  obs_referencerange_age_low_system varchar,   -- referenceRange/age/low/system (varchar)
  obs_referencerange_age_low_code varchar,   -- referenceRange/age/low/code (varchar)
  obs_referencerange_age_high_value varchar,   -- referenceRange/age/high/value (varchar)
  obs_referencerange_age_high_unit varchar,   -- referenceRange/age/high/unit (varchar)
  obs_referencerange_age_high_system varchar,   -- referenceRange/age/high/system (varchar)
  obs_referencerange_age_high_code varchar,   -- referenceRange/age/high/code (varchar)
  obs_referencerange_text varchar,   -- referenceRange/text (varchar)
  obs_hasmember_id varchar,   -- hasMember/reference (varchar)
  obs_hasmember_type varchar,   -- hasMember/type (varchar)
  obs_hasmember_identifier_use varchar,   -- hasMember/identifier/use (varchar)
  obs_hasmember_identifier_type_system varchar,   -- hasMember/identifier/type/coding/system (varchar)
  obs_hasmember_identifier_type_version varchar,   -- hasMember/identifier/type/coding/version (varchar)
  obs_hasmember_identifier_type_code varchar,   -- hasMember/identifier/type/coding/code (varchar)
  obs_hasmember_identifier_type_display varchar,   -- hasMember/identifier/type/coding/display (varchar)
  obs_hasmember_identifier_type_text varchar,   -- hasMember/identifier/type/text (varchar)
  obs_hasmember_display varchar,   -- hasMember/display (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.diagnosticreport_raw (
  diagnosticreport_id serial PRIMARY KEY not null, -- Primary key of the entity
  diagrep_id varchar,   -- id (varchar)
  diagrep_encounter_id varchar,   -- encounter/reference (varchar)
  diagrep_patient_id varchar,   -- subject/reference (varchar)
  diagrep_partof_id varchar,   -- partOf/reference (varchar)
  diagrep_identifier_use varchar,   -- identifier/use (varchar)
  diagrep_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  diagrep_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  diagrep_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  diagrep_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  diagrep_identifier_type_text varchar,   -- identifier/type/text (varchar)
  diagrep_identifier_system varchar,   -- identifier/system (varchar)
  diagrep_identifier_value varchar,   -- identifier/value (varchar)
  diagrep_identifier_start varchar,   -- identifier/start (varchar)
  diagrep_identifier_end varchar,   -- identifier/end (varchar)
  diagrep_result_id varchar,   -- result/reference (varchar)
  diagrep_basedon_id varchar,   -- basedOn/reference (varchar)
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
  diagrep_effectivedatetime varchar,   -- effectiveDateTime (varchar)
  diagrep_issued varchar,   -- issued (varchar)
  diagrep_performer_id varchar,   -- performer/reference (varchar)
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
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.servicerequest_raw (
  servicerequest_id serial PRIMARY KEY not null, -- Primary key of the entity
  servreq_id varchar,   -- id (varchar)
  servreq_encounter_id varchar,   -- encounter/reference (varchar)
  servreq_patient_id varchar,   -- subject/reference (varchar)
  servreq_identifier_use varchar,   -- identifier/use (varchar)
  servreq_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  servreq_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  servreq_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  servreq_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  servreq_identifier_type_text varchar,   -- identifier/type/text (varchar)
  servreq_identifier_system varchar,   -- identifier/system (varchar)
  servreq_identifier_value varchar,   -- identifier/value (varchar)
  servreq_identifier_start varchar,   -- identifier/start (varchar)
  servreq_identifier_end varchar,   -- identifier/end (varchar)
  servreq_basedon_id varchar,   -- basedOn/reference (varchar)
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
  servreq_authoredon varchar,   -- authoredOn (varchar)
  servreq_requester_id varchar,   -- requester/reference (varchar)
  servreq_requester_type varchar,   -- requester/type (varchar)
  servreq_requester_identifier_use varchar,   -- requester/identifier/use (varchar)
  servreq_requester_identifier_type_system varchar,   -- requester/identifier/type/coding/system (varchar)
  servreq_requester_identifier_type_version varchar,   -- requester/identifier/type/coding/version (varchar)
  servreq_requester_identifier_type_code varchar,   -- requester/identifier/type/coding/code (varchar)
  servreq_requester_identifier_type_display varchar,   -- requester/identifier/type/coding/display (varchar)
  servreq_requester_identifier_type_text varchar,   -- requester/identifier/type/text (varchar)
  servreq_requester_display varchar,   -- requester/display (varchar)
  servreq_performer_id varchar,   -- performer/reference (varchar)
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
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.procedure_raw (
  procedure_id serial PRIMARY KEY not null, -- Primary key of the entity
  proc_id varchar,   -- id (varchar)
  proc_encounter_id varchar,   -- encounter/reference (varchar)
  proc_patient_id varchar,   -- subject/reference (varchar)
  proc_partof_id varchar,   -- partOf/reference (varchar)
  proc_identifier_use varchar,   -- identifier/use (varchar)
  proc_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  proc_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  proc_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  proc_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  proc_identifier_type_text varchar,   -- identifier/type/text (varchar)
  proc_identifier_system varchar,   -- identifier/system (varchar)
  proc_identifier_value varchar,   -- identifier/value (varchar)
  proc_identifier_start varchar,   -- identifier/start (varchar)
  proc_identifier_end varchar,   -- identifier/end (varchar)
  proc_basedon_id varchar,   -- basedOn/reference (varchar)
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
  proc_performeddatetime varchar,   -- performedDateTime (varchar)
  proc_performedperiod_start varchar,   -- performedPeriod/start (varchar)
  proc_performedperiod_end varchar,   -- performedPeriod/end (varchar)
  proc_reasoncode_system varchar,   -- reasonCode/coding/system (varchar)
  proc_reasoncode_version varchar,   -- reasonCode/coding/version (varchar)
  proc_reasoncode_code varchar,   -- reasonCode/coding/code (varchar)
  proc_reasoncode_display varchar,   -- reasonCode/coding/display (varchar)
  proc_reasoncode_text varchar,   -- reasonCode/text (varchar)
  proc_reasonreference_id varchar,   -- reasonReference/reference (varchar)
  proc_reasonreference_type varchar,   -- reasonReference/type (varchar)
  proc_reasonreference_identifier_use varchar,   -- reasonReference/identifier/use (varchar)
  proc_reasonreference_identifier_type_system varchar,   -- reasonReference/identifier/type/coding/system (varchar)
  proc_reasonreference_identifier_type_version varchar,   -- reasonReference/identifier/type/coding/version (varchar)
  proc_reasonreference_identifier_type_code varchar,   -- reasonReference/identifier/type/coding/code (varchar)
  proc_reasonreference_identifier_type_display varchar,   -- reasonReference/identifier/type/coding/display (varchar)
  proc_reasonreference_identifier_type_text varchar,   -- reasonReference/identifier/type/text (varchar)
  proc_reasonreference_display varchar,   -- reasonReference/display (varchar)
  proc_note_authorstring varchar,   -- note/authorString (varchar)
  proc_note_authorreference_id varchar,   -- note/authorReference/reference (varchar)
  proc_note_authorreference_type varchar,   -- note/authorReference/type (varchar)
  proc_note_authorreference_identifier_use varchar,   -- note/authorReference/identifier/use (varchar)
  proc_note_authorreference_identifier_type_system varchar,   -- note/authorReference/identifier/type/coding/system (varchar)
  proc_note_authorreference_identifier_type_version varchar,   -- note/authorReference/identifier/type/coding/version (varchar)
  proc_note_authorreference_identifier_type_code varchar,   -- note/authorReference/identifier/type/coding/code (varchar)
  proc_note_authorreference_identifier_type_display varchar,   -- note/authorReference/identifier/type/coding/display (varchar)
  proc_note_authorreference_identifier_type_text varchar,   -- note/authorReference/identifier/type/text (varchar)
  proc_note_authorreference_display varchar,   -- note/authorReference/display (varchar)
  proc_note_time varchar,   -- note/time (varchar)
  proc_note_text varchar,   -- note/text (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.consent_raw (
  consent_id serial PRIMARY KEY not null, -- Primary key of the entity
  cons_id varchar,   -- id (varchar)
  cons_patient_id varchar,   -- patient/reference (varchar)
  cons_identifier_use varchar,   -- identifier/use (varchar)
  cons_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  cons_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  cons_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  cons_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  cons_identifier_type_text varchar,   -- identifier/type/text (varchar)
  cons_identifier_system varchar,   -- identifier/system (varchar)
  cons_identifier_value varchar,   -- identifier/value (varchar)
  cons_identifier_start varchar,   -- identifier/start (varchar)
  cons_identifier_end varchar,   -- identifier/end (varchar)
  cons_status varchar,   -- status (varchar)
  cons_scope_system varchar,   -- scope/coding/system (varchar)
  cons_scope_version varchar,   -- scope/coding/version (varchar)
  cons_scope_code varchar,   -- scope/coding/code (varchar)
  cons_scope_display varchar,   -- scope/coding/display (varchar)
  cons_scope_text varchar,   -- scope/text (varchar)
  cons_datetime varchar,   -- dateTime (varchar)
  cons_provision_type varchar,   -- provision/type (varchar)
  cons_provision_period_start varchar,   -- provision/period/start (varchar)
  cons_provision_period_end varchar,   -- provision/period/end (varchar)
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
  cons_provision_dataperiod_start varchar,   -- provision/dataPeriod/start (varchar)
  cons_provision_dataperiod_end varchar,   -- provision/dataPeriod/end (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.location_raw (
  location_id serial PRIMARY KEY not null, -- Primary key of the entity
  loc_id varchar,   -- id (varchar)
  loc_identifier_use varchar,   -- identifier/use (varchar)
  loc_identifier_type_system varchar,   -- identifier/type/coding/system (varchar)
  loc_identifier_type_version varchar,   -- identifier/type/coding/version (varchar)
  loc_identifier_type_code varchar,   -- identifier/type/coding/code (varchar)
  loc_identifier_type_display varchar,   -- identifier/type/coding/display (varchar)
  loc_identifier_type_text varchar,   -- identifier/type/text (varchar)
  loc_identifier_system varchar,   -- identifier/system (varchar)
  loc_identifier_value varchar,   -- identifier/value (varchar)
  loc_identifier_start varchar,   -- identifier/start (varchar)
  loc_identifier_end varchar,   -- identifier/end (varchar)
  loc_status varchar,   -- status (varchar)
  loc_name varchar,   -- name (varchar)
  loc_description varchar,   -- description (varchar)
  loc_alias varchar,   -- alias (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

-- Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.pids_per_ward_raw (
  pids_per_ward_id serial PRIMARY KEY not null, -- Primary key of the entity
  ward_name varchar,   -- ward_name (varchar)
  patient_id varchar,   -- patient_id (varchar)
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);


------------------------------------------------------
-- SQL Role / Trigger in Schema "cds2db_in" --
------------------------------------------------------


-- Table "encounter_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.encounter_raw ALTER COLUMN encounter_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.encounter_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.encounter_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.encounter_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER encounter_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.encounter_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.encounter_raw_tr_ins_fkt();


-- Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.patient_raw ALTER COLUMN patient_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.patient_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.patient_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.patient_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.patient_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.patient_raw_tr_ins_fkt();


-- Table "condition_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.condition_raw ALTER COLUMN condition_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.condition_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.condition_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.condition_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER condition_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.condition_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.condition_raw_tr_ins_fkt();


-- Table "medication_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.medication_raw ALTER COLUMN medication_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.medication_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medication_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.medication_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medication_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.medication_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.medication_raw_tr_ins_fkt();


-- Table "medicationrequest_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.medicationrequest_raw ALTER COLUMN medicationrequest_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.medicationrequest_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationrequest_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.medicationrequest_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationrequest_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.medicationrequest_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.medicationrequest_raw_tr_ins_fkt();


-- Table "medicationadministration_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.medicationadministration_raw ALTER COLUMN medicationadministration_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.medicationadministration_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationadministration_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.medicationadministration_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationadministration_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.medicationadministration_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.medicationadministration_raw_tr_ins_fkt();


-- Table "medicationstatement_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.medicationstatement_raw ALTER COLUMN medicationstatement_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.medicationstatement_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.medicationstatement_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.medicationstatement_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medicationstatement_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.medicationstatement_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.medicationstatement_raw_tr_ins_fkt();


-- Table "observation_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.observation_raw ALTER COLUMN observation_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.observation_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.observation_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.observation_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER observation_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.observation_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.observation_raw_tr_ins_fkt();


-- Table "diagnosticreport_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.diagnosticreport_raw ALTER COLUMN diagnosticreport_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.diagnosticreport_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.diagnosticreport_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.diagnosticreport_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER diagnosticreport_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.diagnosticreport_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.diagnosticreport_raw_tr_ins_fkt();


-- Table "servicerequest_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.servicerequest_raw ALTER COLUMN servicerequest_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.servicerequest_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.servicerequest_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.servicerequest_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER servicerequest_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.servicerequest_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.servicerequest_raw_tr_ins_fkt();


-- Table "procedure_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.procedure_raw ALTER COLUMN procedure_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.procedure_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.procedure_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.procedure_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER procedure_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.procedure_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.procedure_raw_tr_ins_fkt();


-- Table "consent_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.consent_raw ALTER COLUMN consent_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.consent_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.consent_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.consent_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER consent_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.consent_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.consent_raw_tr_ins_fkt();


-- Table "location_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.location_raw ALTER COLUMN location_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.location_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.location_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.location_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER location_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.location_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.location_raw_tr_ins_fkt();


-- Table "pids_per_ward_raw" in schema "cds2db_in"
----------------------------------------------------
ALTER TABLE cds2db_in.pids_per_ward_raw ALTER COLUMN pids_per_ward_id SET DEFAULT (nextval('cds2db_in.cds2db_in_seq'));

GRANT TRIGGER ON cds2db_in.pids_per_ward_raw TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_in TO cds2db_user;
GRANT USAGE ON cds2db_in.cds2db_in_seq TO cds2db_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward_raw TO cds2db_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.pids_per_ward_raw TO db_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION cds2db_in.pids_per_ward_raw_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER pids_per_ward_raw_tr_ins_tr
  BEFORE INSERT
  ON cds2db_in.pids_per_ward_raw
  FOR EACH ROW
  EXECUTE PROCEDURE cds2db_in.pids_per_ward_raw_tr_ins_fkt();


------------------------------------------------------
-- Comments on Tables in Schema "cds2db_in" --
------------------------------------------------------
-- Output off
\o /dev/null

comment on column cds2db_in.encounter_raw.encounter_id is 'Primary key of the entity';
comment on column cds2db_in.encounter_raw.enc_id is 'id (varchar)';
comment on column cds2db_in.encounter_raw.enc_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.encounter_raw.enc_partof_id is 'partOf/reference (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.encounter_raw.enc_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.encounter_raw.enc_status is 'status (varchar)';
comment on column cds2db_in.encounter_raw.enc_class_system is 'class/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_class_version is 'class/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_class_code is 'class/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_class_display is 'class/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_type_system is 'type/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_type_version is 'type/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_type_code is 'type/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_type_display is 'type/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_type_text is 'type/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_servicetype_system is 'serviceType/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_servicetype_version is 'serviceType/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_servicetype_code is 'serviceType/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_servicetype_display is 'serviceType/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_servicetype_text is 'serviceType/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_period_start is 'period/start (varchar)';
comment on column cds2db_in.encounter_raw.enc_period_end is 'period/end (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_condition_id is 'diagnosis/condition/reference (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_system is 'diagnosis/use/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_version is 'diagnosis/use/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_code is 'diagnosis/use/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_display is 'diagnosis/use/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_use_text is 'diagnosis/use/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_diagnosis_rank is 'diagnosis/rank (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_system is 'hospitalization/admitSource/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_version is 'hospitalization/admitSource/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_code is 'hospitalization/admitSource/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_display is 'hospitalization/admitSource/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_admitsource_text is 'hospitalization/admitSource/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_system is 'hospitalization/dischargeDisposition/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_version is 'hospitalization/dischargeDisposition/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_code is 'hospitalization/dischargeDisposition/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_display is 'hospitalization/dischargeDisposition/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_hospitalization_dischargedisposition_text is 'hospitalization/dischargeDisposition/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_id is 'location/location/reference (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_type is 'location/location/type (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_use is 'location/location/identifier/use (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_system is 'location/location/identifier/type/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_version is 'location/location/identifier/type/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_code is 'location/location/identifier/type/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_display is 'location/location/identifier/type/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_identifier_type_text is 'location/location/identifier/type/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_display is 'location/location/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_status is 'location/location/status (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_system is 'location/location/physicalType/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_version is 'location/location/physicalType/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_code is 'location/location/physicalType/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_display is 'location/location/physicalType/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_location_physicaltype_text is 'location/location/physicalType/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_id is 'serviceProvider/reference (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_type is 'serviceProvider/type (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_use is 'serviceProvider/identifier/use (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_system is 'serviceProvider/identifier/type/coding/system (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_version is 'serviceProvider/identifier/type/coding/version (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_code is 'serviceProvider/identifier/type/coding/code (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_display is 'serviceProvider/identifier/type/coding/display (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_identifier_type_text is 'serviceProvider/identifier/type/text (varchar)';
comment on column cds2db_in.encounter_raw.enc_serviceprovider_display is 'serviceProvider/display (varchar)';
comment on column cds2db_in.encounter_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.encounter_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.encounter_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.patient_raw.patient_id is 'Primary key of the entity';
comment on column cds2db_in.patient_raw.pat_id is 'id (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.patient_raw.pat_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.patient_raw.pat_name_text is 'name/text (varchar)';
comment on column cds2db_in.patient_raw.pat_name_family is 'name/family (varchar)';
comment on column cds2db_in.patient_raw.pat_name_given is 'name/given (varchar)';
comment on column cds2db_in.patient_raw.pat_gender is 'gender (varchar)';
comment on column cds2db_in.patient_raw.pat_birthdate is 'birthDate (varchar)';
comment on column cds2db_in.patient_raw.pat_address_postalcode is 'address/postalCode (varchar)';
comment on column cds2db_in.patient_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.patient_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.patient_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.condition_raw.condition_id is 'Primary key of the entity';
comment on column cds2db_in.condition_raw.con_id is 'id (varchar)';
comment on column cds2db_in.condition_raw.con_encounter_id is 'encounter/reference (varchar)';
comment on column cds2db_in.condition_raw.con_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.condition_raw.con_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_system is 'clinicalStatus/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_version is 'clinicalStatus/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_code is 'clinicalStatus/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_display is 'clinicalStatus/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_clinicalstatus_text is 'clinicalStatus/text (varchar)';
comment on column cds2db_in.condition_raw.con_verificationstatus_system is 'verificationStatus/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_verificationstatus_version is 'verificationStatus/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_verificationstatus_code is 'verificationStatus/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_verificationstatus_display is 'verificationStatus/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_verificationstatus_text is 'verificationStatus/text (varchar)';
comment on column cds2db_in.condition_raw.con_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_category_text is 'category/text (varchar)';
comment on column cds2db_in.condition_raw.con_severity_system is 'severity/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_severity_version is 'severity/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_severity_code is 'severity/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_severity_display is 'severity/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_severity_text is 'severity/text (varchar)';
comment on column cds2db_in.condition_raw.con_code_system is 'code/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_code_version is 'code/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_code_code is 'code/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_code_display is 'code/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_code_text is 'code/text (varchar)';
comment on column cds2db_in.condition_raw.con_bodysite_system is 'bodySite/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_bodysite_version is 'bodySite/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_bodysite_code is 'bodySite/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_bodysite_display is 'bodySite/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_bodysite_text is 'bodySite/text (varchar)';
comment on column cds2db_in.condition_raw.con_onsetperiod_start is 'onsetPeriod/start (varchar)';
comment on column cds2db_in.condition_raw.con_onsetperiod_end is 'onsetPeriod/end (varchar)';
comment on column cds2db_in.condition_raw.con_onsetdatetime is 'onsetDateTime (varchar)';
comment on column cds2db_in.condition_raw.con_abatementdatetime is 'abatementDateTime (varchar)';
comment on column cds2db_in.condition_raw.con_abatementage_value is 'abatementAge/value (varchar)';
comment on column cds2db_in.condition_raw.con_abatementage_comparator is 'abatementAge/comparator (varchar)';
comment on column cds2db_in.condition_raw.con_abatementage_unit is 'abatementAge/unit (varchar)';
comment on column cds2db_in.condition_raw.con_abatementage_system is 'abatementAge/system (varchar)';
comment on column cds2db_in.condition_raw.con_abatementage_code is 'abatementAge/code (varchar)';
comment on column cds2db_in.condition_raw.con_abatementperiod_start is 'abatementPeriod/start (varchar)';
comment on column cds2db_in.condition_raw.con_abatementperiod_end is 'abatementPeriod/end (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_value is 'abatementRange/low/value (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_unit is 'abatementRange/low/unit (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_system is 'abatementRange/low/system (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_low_code is 'abatementRange/low/code (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_value is 'abatementRange/high/value (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_unit is 'abatementRange/high/unit (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_system is 'abatementRange/high/system (varchar)';
comment on column cds2db_in.condition_raw.con_abatementrange_high_code is 'abatementRange/high/code (varchar)';
comment on column cds2db_in.condition_raw.con_abatementstring is 'abatementString (varchar)';
comment on column cds2db_in.condition_raw.con_recordeddate is 'recordedDate (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_id is 'recorder/reference (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_type is 'recorder/type (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_use is 'recorder/identifier/use (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_system is 'recorder/identifier/type/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_version is 'recorder/identifier/type/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_code is 'recorder/identifier/type/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_display is 'recorder/identifier/type/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_identifier_type_text is 'recorder/identifier/type/text (varchar)';
comment on column cds2db_in.condition_raw.con_recorder_display is 'recorder/display (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_id is 'asserter/reference (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_type is 'asserter/type (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_use is 'asserter/identifier/use (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_system is 'asserter/identifier/type/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_version is 'asserter/identifier/type/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_code is 'asserter/identifier/type/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_display is 'asserter/identifier/type/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_identifier_type_text is 'asserter/identifier/type/text (varchar)';
comment on column cds2db_in.condition_raw.con_asserter_display is 'asserter/display (varchar)';
comment on column cds2db_in.condition_raw.con_stage_summary_system is 'stage/summary/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_stage_summary_version is 'stage/summary/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_stage_summary_code is 'stage/summary/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_stage_summary_display is 'stage/summary/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_stage_summary_text is 'stage/summary/text (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_id is 'stage/assessment/reference (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_type is 'stage/assessment/type (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_use is 'stage/assessment/identifier/use (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_system is 'stage/assessment/identifier/type/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_version is 'stage/assessment/identifier/type/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_code is 'stage/assessment/identifier/type/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_display is 'stage/assessment/identifier/type/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_identifier_type_text is 'stage/assessment/identifier/type/text (varchar)';
comment on column cds2db_in.condition_raw.con_stage_assessment_display is 'stage/assessment/display (varchar)';
comment on column cds2db_in.condition_raw.con_stage_type_system is 'stage/type/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_stage_type_version is 'stage/type/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_stage_type_code is 'stage/type/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_stage_type_display is 'stage/type/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_stage_type_text is 'stage/type/text (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorstring is 'note/authorString (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_id is 'note/authorReference/reference (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_type is 'note/authorReference/type (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_use is 'note/authorReference/identifier/use (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (varchar)';
comment on column cds2db_in.condition_raw.con_note_authorreference_display is 'note/authorReference/display (varchar)';
comment on column cds2db_in.condition_raw.con_note_time is 'note/time (varchar)';
comment on column cds2db_in.condition_raw.con_note_text is 'note/text (varchar)';
comment on column cds2db_in.condition_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.condition_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.condition_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.medication_raw.medication_id is 'Primary key of the entity';
comment on column cds2db_in.medication_raw.med_id is 'id (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.medication_raw.med_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.medication_raw.med_code_system is 'code/coding/system (varchar)';
comment on column cds2db_in.medication_raw.med_code_version is 'code/coding/version (varchar)';
comment on column cds2db_in.medication_raw.med_code_code is 'code/coding/code (varchar)';
comment on column cds2db_in.medication_raw.med_code_display is 'code/coding/display (varchar)';
comment on column cds2db_in.medication_raw.med_code_text is 'code/text (varchar)';
comment on column cds2db_in.medication_raw.med_status is 'status (varchar)';
comment on column cds2db_in.medication_raw.med_form_system is 'form/coding/system (varchar)';
comment on column cds2db_in.medication_raw.med_form_version is 'form/coding/version (varchar)';
comment on column cds2db_in.medication_raw.med_form_code is 'form/coding/code (varchar)';
comment on column cds2db_in.medication_raw.med_form_display is 'form/coding/display (varchar)';
comment on column cds2db_in.medication_raw.med_form_text is 'form/text (varchar)';
comment on column cds2db_in.medication_raw.med_amount_numerator_value is 'amount/numerator/value (varchar)';
comment on column cds2db_in.medication_raw.med_amount_numerator_comparator is 'amount/numerator/comparator (varchar)';
comment on column cds2db_in.medication_raw.med_amount_numerator_unit is 'amount/numerator/unit (varchar)';
comment on column cds2db_in.medication_raw.med_amount_numerator_system is 'amount/numerator/system (varchar)';
comment on column cds2db_in.medication_raw.med_amount_numerator_code is 'amount/numerator/code (varchar)';
comment on column cds2db_in.medication_raw.med_amount_denominator_value is 'amount/denominator/value (varchar)';
comment on column cds2db_in.medication_raw.med_amount_denominator_comparator is 'amount/denominator/comparator (varchar)';
comment on column cds2db_in.medication_raw.med_amount_denominator_unit is 'amount/denominator/unit (varchar)';
comment on column cds2db_in.medication_raw.med_amount_denominator_system is 'amount/denominator/system (varchar)';
comment on column cds2db_in.medication_raw.med_amount_denominator_code is 'amount/denominator/code (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_value is 'ingredient/strength/numerator/value (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_comparator is 'ingredient/strength/numerator/comparator (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_unit is 'ingredient/strength/numerator/unit (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_system is 'ingredient/strength/numerator/system (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_numerator_code is 'ingredient/strength/numerator/code (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_value is 'ingredient/strength/denominator/value (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_comparator is 'ingredient/strength/denominator/comparator (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_unit is 'ingredient/strength/denominator/unit (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_system is 'ingredient/strength/denominator/system (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_strength_denominator_code is 'ingredient/strength/denominator/code (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_system is 'ingredient/itemCodeableConcept/coding/system (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_version is 'ingredient/itemCodeableConcept/coding/version (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_code is 'ingredient/itemCodeableConcept/coding/code (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_display is 'ingredient/itemCodeableConcept/coding/display (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemcodeableconcept_text is 'ingredient/itemCodeableConcept/text (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_id is 'ingredient/itemReference/reference (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_type is 'ingredient/itemReference/type (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_use is 'ingredient/itemReference/identifier/use (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_system is 'ingredient/itemReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_version is 'ingredient/itemReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_code is 'ingredient/itemReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_display is 'ingredient/itemReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_identifier_type_text is 'ingredient/itemReference/identifier/type/text (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_itemreference_display is 'ingredient/itemReference/display (varchar)';
comment on column cds2db_in.medication_raw.med_ingredient_isactive is 'ingredient/isActive (varchar)';
comment on column cds2db_in.medication_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.medication_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.medication_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.medicationrequest_raw.medicationrequest_id is 'Primary key of the entity';
comment on column cds2db_in.medicationrequest_raw.medreq_id is 'id (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_encounter_id is 'encounter/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationreference_id is 'medicationReference/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_status is 'status (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_system is 'statusReason/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_version is 'statusReason/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_code is 'statusReason/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_display is 'statusReason/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_statusreason_text is 'statusReason/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_intend is 'intend (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_category_text is 'category/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_priority is 'priority (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedboolean is 'reportedBoolean (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_id is 'reportedReference/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_type is 'reportedReference/type (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_use is 'reportedReference/identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_system is 'reportedReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_version is 'reportedReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_code is 'reportedReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_display is 'reportedReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_identifier_type_text is 'reportedReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reportedreference_display is 'reportedReference/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_medicationcodeableconcept_text is 'medicationCodeableConcept/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_id is 'supportingInformation/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_type is 'supportingInformation/type (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_use is 'supportingInformation/identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_system is 'supportingInformation/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_version is 'supportingInformation/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_code is 'supportingInformation/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_display is 'supportingInformation/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_identifier_type_text is 'supportingInformation/identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_supportinginformation_display is 'supportingInformation/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_authoredon is 'authoredOn (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_id is 'requester/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_type is 'requester/type (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_use is 'requester/identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_system is 'requester/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_version is 'requester/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_code is 'requester/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_display is 'requester/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_identifier_type_text is 'requester/identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_requester_display is 'requester/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_system is 'reasonCode/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_version is 'reasonCode/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_code is 'reasonCode/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_display is 'reasonCode/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasoncode_text is 'reasonCode/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_id is 'reasonReference/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_type is 'reasonReference/type (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_use is 'reasonReference/identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_reasonreference_display is 'reasonReference/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_id is 'basedOn/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_type is 'basedOn/type (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_use is 'basedOn/identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_identifier_type_text is 'basedOn/identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_basedon_display is 'basedOn/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorstring is 'note/authorString (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_id is 'note/authorReference/reference (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_type is 'note/authorReference/type (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_use is 'note/authorReference/identifier/use (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_authorreference_display is 'note/authorReference/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_time is 'note/time (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_note_text is 'note/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_sequence is 'dosageInstruction/sequence (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_text is 'dosageInstruction/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_system is 'dosageInstruction/additionalInstruction/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_version is 'dosageInstruction/additionalInstruction/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_code is 'dosageInstruction/additionalInstruction/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_display is 'dosageInstruction/additionalInstruction/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_additionalinstruction_text is 'dosageInstruction/additionalInstruction/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_patientinstruction is 'dosageInstruction/patientInstruction (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_event is 'dosageInstruction/timing/event (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_value is 'dosageInstruction/timing/repeat/boundsDuration/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_comparator is 'dosageInstruction/timing/repeat/boundsDuration/comparator (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_unit is 'dosageInstruction/timing/repeat/boundsDuration/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_system is 'dosageInstruction/timing/repeat/boundsDuration/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsduration_code is 'dosageInstruction/timing/repeat/boundsDuration/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_value is 'dosageInstruction/timing/repeat/boundsRange/low/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_unit is 'dosageInstruction/timing/repeat/boundsRange/low/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_system is 'dosageInstruction/timing/repeat/boundsRange/low/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_low_code is 'dosageInstruction/timing/repeat/boundsRange/low/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_value is 'dosageInstruction/timing/repeat/boundsRange/high/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_unit is 'dosageInstruction/timing/repeat/boundsRange/high/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_system is 'dosageInstruction/timing/repeat/boundsRange/high/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsrange_high_code is 'dosageInstruction/timing/repeat/boundsRange/high/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsperiod_start is 'dosageInstruction/timing/repeat/boundsPeriod/start (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_boundsperiod_end is 'dosageInstruction/timing/repeat/boundsPeriod/end (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_count is 'dosageInstruction/timing/repeat/count (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_countmax is 'dosageInstruction/timing/repeat/countMax (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_duration is 'dosageInstruction/timing/repeat/duration (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_durationmax is 'dosageInstruction/timing/repeat/durationMax (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_durationunit is 'dosageInstruction/timing/repeat/durationUnit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_frequency is 'dosageInstruction/timing/repeat/frequency (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_frequencymax is 'dosageInstruction/timing/repeat/frequencyMax (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_period is 'dosageInstruction/timing/repeat/period (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_periodmax is 'dosageInstruction/timing/repeat/periodMax (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_periodunit is 'dosageInstruction/timing/repeat/periodUnit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_dayofweek is 'dosageInstruction/timing/repeat/dayOfWeek (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_timeofday is 'dosageInstruction/timing/repeat/timeOfDay (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_when is 'dosageInstruction/timing/repeat/when (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_repeat_offset is 'dosageInstruction/timing/repeat/offset (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_system is 'dosageInstruction/timing/code/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_version is 'dosageInstruction/timing/code/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_code is 'dosageInstruction/timing/code/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_display is 'dosageInstruction/timing/code/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_timing_code_text is 'dosageInstruction/timing/code/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededboolean is 'dosageInstruction/asNeededBoolean (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_system is 'dosageInstruction/asNeededCodeableConcept/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_version is 'dosageInstruction/asNeededCodeableConcept/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_code is 'dosageInstruction/asNeededCodeableConcept/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_display is 'dosageInstruction/asNeededCodeableConcept/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_asneededcodeableconcept_text is 'dosageInstruction/asNeededCodeableConcept/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_system is 'dosageInstruction/site/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_version is 'dosageInstruction/site/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_code is 'dosageInstruction/site/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_display is 'dosageInstruction/site/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_site_text is 'dosageInstruction/site/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_system is 'dosageInstruction/route/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_version is 'dosageInstruction/route/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_code is 'dosageInstruction/route/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_display is 'dosageInstruction/route/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_route_text is 'dosageInstruction/route/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_system is 'dosageInstruction/method/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_version is 'dosageInstruction/method/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_code is 'dosageInstruction/method/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_display is 'dosageInstruction/method/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_method_text is 'dosageInstruction/method/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_system is 'dosageInstruction/doseAndRate/type/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_version is 'dosageInstruction/doseAndRate/type/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_code is 'dosageInstruction/doseAndRate/type/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_display is 'dosageInstruction/doseAndRate/type/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_type_text is 'dosageInstruction/doseAndRate/type/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_value is 'dosageInstruction/doseAndRate/doseRange/low/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_unit is 'dosageInstruction/doseAndRate/doseRange/low/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_system is 'dosageInstruction/doseAndRate/doseRange/low/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_low_code is 'dosageInstruction/doseAndRate/doseRange/low/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_value is 'dosageInstruction/doseAndRate/doseRange/high/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_unit is 'dosageInstruction/doseAndRate/doseRange/high/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_system is 'dosageInstruction/doseAndRate/doseRange/high/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_doserange_high_code is 'dosageInstruction/doseAndRate/doseRange/high/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_value is 'dosageInstruction/doseAndRate/doseQuantity/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_comparator is 'dosageInstruction/doseAndRate/doseQuantity/comparator (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_unit is 'dosageInstruction/doseAndRate/doseQuantity/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_system is 'dosageInstruction/doseAndRate/doseQuantity/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_dosequantity_code is 'dosageInstruction/doseAndRate/doseQuantity/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_value is 'dosageInstruction/doseAndRate/rateRatio/numerator/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator is 'dosageInstruction/doseAndRate/rateRatio/numerator/comparator (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_unit is 'dosageInstruction/doseAndRate/rateRatio/numerator/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_system is 'dosageInstruction/doseAndRate/rateRatio/numerator/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_numerator_code is 'dosageInstruction/doseAndRate/rateRatio/numerator/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_value is 'dosageInstruction/doseAndRate/rateRatio/denominator/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator is 'dosageInstruction/doseAndRate/rateRatio/denominator/comparator (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_unit is 'dosageInstruction/doseAndRate/rateRatio/denominator/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_system is 'dosageInstruction/doseAndRate/rateRatio/denominator/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_rateratio_denominator_code is 'dosageInstruction/doseAndRate/rateRatio/denominator/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_value is 'dosageInstruction/doseAndRate/rateRange/low/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_unit is 'dosageInstruction/doseAndRate/rateRange/low/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_system is 'dosageInstruction/doseAndRate/rateRange/low/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_low_code is 'dosageInstruction/doseAndRate/rateRange/low/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_value is 'dosageInstruction/doseAndRate/rateRange/high/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_unit is 'dosageInstruction/doseAndRate/rateRange/high/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_system is 'dosageInstruction/doseAndRate/rateRange/high/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_raterange_high_code is 'dosageInstruction/doseAndRate/rateRange/high/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_value is 'dosageInstruction/doseAndRate/rateQuantity/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_unit is 'dosageInstruction/doseAndRate/rateQuantity/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_system is 'dosageInstruction/doseAndRate/rateQuantity/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_doseandrate_ratequantity_code is 'dosageInstruction/doseAndRate/rateQuantity/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_value is 'dosageInstruction/maxDosePerPeriod/numerator/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_comparator is 'dosageInstruction/maxDosePerPeriod/numerator/comparator (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_unit is 'dosageInstruction/maxDosePerPeriod/numerator/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_system is 'dosageInstruction/maxDosePerPeriod/numerator/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_numerator_code is 'dosageInstruction/maxDosePerPeriod/numerator/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_value is 'dosageInstruction/maxDosePerPeriod/denominator/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_comparator is 'dosageInstruction/maxDosePerPeriod/denominator/comparator (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_unit is 'dosageInstruction/maxDosePerPeriod/denominator/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_system is 'dosageInstruction/maxDosePerPeriod/denominator/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperperiod_denominator_code is 'dosageInstruction/maxDosePerPeriod/denominator/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_value is 'dosageInstruction/maxDosePerAdministration/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_unit is 'dosageInstruction/maxDosePerAdministration/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_system is 'dosageInstruction/maxDosePerAdministration/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperadministration_code is 'dosageInstruction/maxDosePerAdministration/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_value is 'dosageInstruction/maxDosePerLifetime/value (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_unit is 'dosageInstruction/maxDosePerLifetime/unit (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_system is 'dosageInstruction/maxDosePerLifetime/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_doseinstruc_maxdoseperlifetime_code is 'dosageInstruction/maxDosePerLifetime/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_system is 'substitution/reason/coding/system (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_version is 'substitution/reason/coding/version (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_code is 'substitution/reason/coding/code (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_display is 'substitution/reason/coding/display (varchar)';
comment on column cds2db_in.medicationrequest_raw.medreq_substitution_reason_text is 'substitution/reason/text (varchar)';
comment on column cds2db_in.medicationrequest_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.medicationrequest_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.medicationrequest_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.medicationadministration_raw.medicationadministration_id is 'Primary key of the entity';
comment on column cds2db_in.medicationadministration_raw.medadm_id is 'id (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_encounter_id is 'context/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_partof_id is 'partOf/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_status is 'status (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_system is 'statusReason/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_version is 'statusReason/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_code is 'statusReason/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_display is 'statusReason/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_statusreason_text is 'statusReason/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_category_text is 'category/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationreference_id is 'medicationReference/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_medicationcodeableconcept_text is 'medicationCodeableConcept/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_id is 'supportingInformation/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_type is 'supportingInformation/type (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_use is 'supportingInformation/identifier/use (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_system is 'supportingInformation/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_version is 'supportingInformation/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_code is 'supportingInformation/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_display is 'supportingInformation/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_identifier_type_text is 'supportingInformation/identifier/type/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_supportinginformation_display is 'supportingInformation/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_effectivedatetime is 'effectiveDateTime (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_effectiveperiod_start is 'effectivePeriod/start (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_effectiveperiod_end is 'effectivePeriod/end (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_system is 'performer/function/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_version is 'performer/function/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_code is 'performer/function/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_display is 'performer/function/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_performer_function_text is 'performer/function/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_system is 'reasonCode/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_version is 'reasonCode/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_code is 'reasonCode/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_display is 'reasonCode/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasoncode_text is 'reasonCode/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_id is 'reasonReference/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_type is 'reasonReference/type (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_use is 'reasonReference/identifier/use (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_reasonreference_display is 'reasonReference/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_request_id is 'request/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorstring is 'note/authorString (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_id is 'note/authorReference/reference (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_type is 'note/authorReference/type (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_use is 'note/authorReference/identifier/use (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_authorreference_display is 'note/authorReference/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_time is 'note/time (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_note_text is 'note/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_text is 'dosage/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_system is 'dosage/site/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_version is 'dosage/site/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_code is 'dosage/site/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_display is 'dosage/site/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_site_text is 'dosage/site/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_system is 'dosage/route/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_version is 'dosage/route/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_code is 'dosage/route/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_display is 'dosage/route/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_route_text is 'dosage/route/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_system is 'dosage/method/coding/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_version is 'dosage/method/coding/version (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_code is 'dosage/method/coding/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_display is 'dosage/method/coding/display (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_method_text is 'dosage/method/text (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_value is 'dosage/dose/value (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_unit is 'dosage/dose/unit (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_system is 'dosage/dose/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_dose_code is 'dosage/dose/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_value is 'dosage/rateRatio/numerator/value (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_comparator is 'dosage/rateRatio/numerator/comparator (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_unit is 'dosage/rateRatio/numerator/unit (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_system is 'dosage/rateRatio/numerator/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_numerator_code is 'dosage/rateRatio/numerator/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_value is 'dosage/rateRatio/denominator/value (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_comparator is 'dosage/rateRatio/denominator/comparator (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_unit is 'dosage/rateRatio/denominator/unit (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_system is 'dosage/rateRatio/denominator/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_rateratio_denominator_code is 'dosage/rateRatio/denominator/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_value is 'dosage/rateQuantity/value (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_unit is 'dosage/rateQuantity/unit (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_system is 'dosage/rateQuantity/system (varchar)';
comment on column cds2db_in.medicationadministration_raw.medadm_dosage_ratequantity_code is 'dosage/rateQuantity/code (varchar)';
comment on column cds2db_in.medicationadministration_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.medicationadministration_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.medicationadministration_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.medicationstatement_raw.medicationstatement_id is 'Primary key of the entity';
comment on column cds2db_in.medicationstatement_raw.medstat_id is 'id (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_encounter_id is 'context/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_partof_id is 'partOf/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_id is 'basedOn/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_type is 'basedOn/type (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_use is 'basedOn/identifier/use (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_identifier_type_text is 'basedOn/identifier/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_basedon_display is 'basedOn/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_status is 'status (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_system is 'statusReason/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_version is 'statusReason/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_code is 'statusReason/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_display is 'statusReason/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_statusreason_text is 'statusReason/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_category_text is 'category/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationreference_id is 'medicationReference/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_system is 'medicationCodeableConcept/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_version is 'medicationCodeableConcept/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_code is 'medicationCodeableConcept/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_display is 'medicationCodeableConcept/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_medicationcodeableconcept_text is 'medicationCodeableConcept/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_effectivedatetime is 'effectiveDateTime (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_effectiveperiod_start is 'effectivePeriod/start (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_effectiveperiod_end is 'effectivePeriod/end (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dateasserted is 'dateAsserted (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_id is 'informationSource/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_type is 'informationSource/type (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_use is 'informationSource/identifier/use (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_system is 'informationSource/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_version is 'informationSource/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_code is 'informationSource/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_display is 'informationSource/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_identifier_type_text is 'informationSource/identifier/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_informationsource_display is 'informationSource/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_id is 'derivedFrom/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_type is 'derivedFrom/type (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_use is 'derivedFrom/identifier/use (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_system is 'derivedFrom/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_version is 'derivedFrom/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_code is 'derivedFrom/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_display is 'derivedFrom/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_identifier_type_text is 'derivedFrom/identifier/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_derivedfrom_display is 'derivedFrom/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_system is 'reasonCode/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_version is 'reasonCode/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_code is 'reasonCode/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_display is 'reasonCode/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasoncode_text is 'reasonCode/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_id is 'reasonReference/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_type is 'reasonReference/type (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_use is 'reasonReference/identifier/use (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_reasonreference_display is 'reasonReference/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorstring is 'note/authorString (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_id is 'note/authorReference/reference (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_type is 'note/authorReference/type (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_use is 'note/authorReference/identifier/use (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_authorreference_display is 'note/authorReference/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_time is 'note/time (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_note_text is 'note/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_sequence is 'dosage/sequence (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_text is 'dosage/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_system is 'dosage/additionalInstruction/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_version is 'dosage/additionalInstruction/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_code is 'dosage/additionalInstruction/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_display is 'dosage/additionalInstruction/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_additionalinstruction_text is 'dosage/additionalInstruction/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_patientinstruction is 'dosage/patientInstruction (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_event is 'dosage/timing/event (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_value is 'dosage/timing/repeat/boundsDuration/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_comparator is 'dosage/timing/repeat/boundsDuration/comparator (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_unit is 'dosage/timing/repeat/boundsDuration/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_system is 'dosage/timing/repeat/boundsDuration/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsduration_code is 'dosage/timing/repeat/boundsDuration/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_value is 'dosage/timing/repeat/boundsRange/low/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_unit is 'dosage/timing/repeat/boundsRange/low/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_system is 'dosage/timing/repeat/boundsRange/low/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_low_code is 'dosage/timing/repeat/boundsRange/low/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_value is 'dosage/timing/repeat/boundsRange/high/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_unit is 'dosage/timing/repeat/boundsRange/high/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_system is 'dosage/timing/repeat/boundsRange/high/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsrange_high_code is 'dosage/timing/repeat/boundsRange/high/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsperiod_start is 'dosage/timing/repeat/boundsPeriod/start (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_boundsperiod_end is 'dosage/timing/repeat/boundsPeriod/end (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_count is 'dosage/timing/repeat/count (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_countmax is 'dosage/timing/repeat/countMax (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_duration is 'dosage/timing/repeat/duration (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_durationmax is 'dosage/timing/repeat/durationMax (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_durationunit is 'dosage/timing/repeat/durationUnit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_frequency is 'dosage/timing/repeat/frequency (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_frequencymax is 'dosage/timing/repeat/frequencyMax (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_period is 'dosage/timing/repeat/period (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_periodmax is 'dosage/timing/repeat/periodMax (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_periodunit is 'dosage/timing/repeat/periodUnit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_dayofweek is 'dosage/timing/repeat/dayOfWeek (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_timeofday is 'dosage/timing/repeat/timeOfDay (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_when is 'dosage/timing/repeat/when (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_repeat_offset is 'dosage/timing/repeat/offset (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_system is 'dosage/timing/code/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_version is 'dosage/timing/code/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_code is 'dosage/timing/code/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_display is 'dosage/timing/code/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_timing_code_text is 'dosage/timing/code/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededboolean is 'dosage/asNeededBoolean (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_system is 'dosage/asNeededCodeableConcept/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_version is 'dosage/asNeededCodeableConcept/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_code is 'dosage/asNeededCodeableConcept/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_display is 'dosage/asNeededCodeableConcept/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_asneededcodeableconcept_text is 'dosage/asNeededCodeableConcept/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_system is 'dosage/site/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_version is 'dosage/site/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_code is 'dosage/site/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_display is 'dosage/site/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_site_text is 'dosage/site/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_system is 'dosage/route/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_version is 'dosage/route/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_code is 'dosage/route/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_display is 'dosage/route/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_route_text is 'dosage/route/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_system is 'dosage/method/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_version is 'dosage/method/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_code is 'dosage/method/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_display is 'dosage/method/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_method_text is 'dosage/method/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_system is 'dosage/doseAndRate/type/coding/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_version is 'dosage/doseAndRate/type/coding/version (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_code is 'dosage/doseAndRate/type/coding/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_display is 'dosage/doseAndRate/type/coding/display (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_type_text is 'dosage/doseAndRate/type/text (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_value is 'dosage/doseAndRate/doseRange/low/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_unit is 'dosage/doseAndRate/doseRange/low/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_system is 'dosage/doseAndRate/doseRange/low/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_low_code is 'dosage/doseAndRate/doseRange/low/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_value is 'dosage/doseAndRate/doseRange/high/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_unit is 'dosage/doseAndRate/doseRange/high/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_system is 'dosage/doseAndRate/doseRange/high/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_doserange_high_code is 'dosage/doseAndRate/doseRange/high/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_value is 'dosage/doseAndRate/doseQuantity/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_comparator is 'dosage/doseAndRate/doseQuantity/comparator (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_unit is 'dosage/doseAndRate/doseQuantity/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_system is 'dosage/doseAndRate/doseQuantity/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_dosequantity_code is 'dosage/doseAndRate/doseQuantity/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_value is 'dosage/doseAndRate/rateRatio/numerator/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_comparator is 'dosage/doseAndRate/rateRatio/numerator/comparator (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_unit is 'dosage/doseAndRate/rateRatio/numerator/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_system is 'dosage/doseAndRate/rateRatio/numerator/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_numerator_code is 'dosage/doseAndRate/rateRatio/numerator/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_value is 'dosage/doseAndRate/rateRatio/denominator/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_comparator is 'dosage/doseAndRate/rateRatio/denominator/comparator (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_unit is 'dosage/doseAndRate/rateRatio/denominator/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_system is 'dosage/doseAndRate/rateRatio/denominator/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_rateratio_denominator_code is 'dosage/doseAndRate/rateRatio/denominator/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_value is 'dosage/doseAndRate/rateRange/low/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_unit is 'dosage/doseAndRate/rateRange/low/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_system is 'dosage/doseAndRate/rateRange/low/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_low_code is 'dosage/doseAndRate/rateRange/low/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_value is 'dosage/doseAndRate/rateRange/high/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_unit is 'dosage/doseAndRate/rateRange/high/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_system is 'dosage/doseAndRate/rateRange/high/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_raterange_high_code is 'dosage/doseAndRate/rateRange/high/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_value is 'dosage/doseAndRate/rateQuantity/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_unit is 'dosage/doseAndRate/rateQuantity/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_system is 'dosage/doseAndRate/rateQuantity/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_doseandrate_ratequantity_code is 'dosage/doseAndRate/rateQuantity/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_value is 'dosage/maxDosePerPeriod/numerator/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_comparator is 'dosage/maxDosePerPeriod/numerator/comparator (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_unit is 'dosage/maxDosePerPeriod/numerator/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_system is 'dosage/maxDosePerPeriod/numerator/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_numerator_code is 'dosage/maxDosePerPeriod/numerator/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_value is 'dosage/maxDosePerPeriod/denominator/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_comparator is 'dosage/maxDosePerPeriod/denominator/comparator (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_unit is 'dosage/maxDosePerPeriod/denominator/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_system is 'dosage/maxDosePerPeriod/denominator/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperperiod_denominator_code is 'dosage/maxDosePerPeriod/denominator/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_value is 'dosage/maxDosePerAdministration/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_unit is 'dosage/maxDosePerAdministration/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_system is 'dosage/maxDosePerAdministration/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperadministration_code is 'dosage/maxDosePerAdministration/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_value is 'dosage/maxDosePerLifetime/value (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_unit is 'dosage/maxDosePerLifetime/unit (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_system is 'dosage/maxDosePerLifetime/system (varchar)';
comment on column cds2db_in.medicationstatement_raw.medstat_dosage_maxdoseperlifetime_code is 'dosage/maxDosePerLifetime/code (varchar)';
comment on column cds2db_in.medicationstatement_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.medicationstatement_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.medicationstatement_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.observation_raw.observation_id is 'Primary key of the entity';
comment on column cds2db_in.observation_raw.obs_id is 'id (varchar)';
comment on column cds2db_in.observation_raw.obs_encounter_id is 'encounter/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_partof_id is 'partOf/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.observation_raw.obs_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_id is 'basedOn/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_type is 'basedOn/type (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_use is 'basedOn/identifier/use (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_identifier_type_text is 'basedOn/identifier/type/text (varchar)';
comment on column cds2db_in.observation_raw.obs_basedon_display is 'basedOn/display (varchar)';
comment on column cds2db_in.observation_raw.obs_status is 'status (varchar)';
comment on column cds2db_in.observation_raw.obs_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_category_text is 'category/text (varchar)';
comment on column cds2db_in.observation_raw.obs_code_system is 'code/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_code_version is 'code/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_code_code is 'code/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_code_display is 'code/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_code_text is 'code/text (varchar)';
comment on column cds2db_in.observation_raw.obs_effectivedatetime is 'effectiveDateTime (varchar)';
comment on column cds2db_in.observation_raw.obs_issued is 'issued (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_value is 'valueRange/low/value (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_unit is 'valueRange/low/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_system is 'valueRange/low/system (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_low_code is 'valueRange/low/code (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_value is 'valueRange/high/value (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_unit is 'valueRange/high/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_system is 'valueRange/high/system (varchar)';
comment on column cds2db_in.observation_raw.obs_valuerange_high_code is 'valueRange/high/code (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_value is 'valueRatio/numerator/value (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_comparator is 'valueRatio/numerator/comparator (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_unit is 'valueRatio/numerator/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_system is 'valueRatio/numerator/system (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_numerator_code is 'valueRatio/numerator/code (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_value is 'valueRatio/denominator/value (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_comparator is 'valueRatio/denominator/comparator (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_unit is 'valueRatio/denominator/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_system is 'valueRatio/denominator/system (varchar)';
comment on column cds2db_in.observation_raw.obs_valueratio_denominator_code is 'valueRatio/denominator/code (varchar)';
comment on column cds2db_in.observation_raw.obs_valuequantity_value is 'valueQuantity/value (varchar)';
comment on column cds2db_in.observation_raw.obs_valuequantity_comparator is 'valueQuantity/comparator (varchar)';
comment on column cds2db_in.observation_raw.obs_valuequantity_unit is 'valueQuantity/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_valuequantity_system is 'valueQuantity/system (varchar)';
comment on column cds2db_in.observation_raw.obs_valuequantity_code is 'valueQuantity/code (varchar)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_system is 'valueCodableConcept/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_version is 'valueCodableConcept/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_code is 'valueCodableConcept/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_display is 'valueCodableConcept/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_valuecodableconcept_text is 'valueCodableConcept/text (varchar)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_system is 'dataAbsentReason/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_version is 'dataAbsentReason/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_code is 'dataAbsentReason/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_display is 'dataAbsentReason/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_dataabsentreason_text is 'dataAbsentReason/text (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorstring is 'note/authorString (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_id is 'note/authorReference/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_type is 'note/authorReference/type (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_use is 'note/authorReference/identifier/use (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (varchar)';
comment on column cds2db_in.observation_raw.obs_note_authorreference_display is 'note/authorReference/display (varchar)';
comment on column cds2db_in.observation_raw.obs_note_time is 'note/time (varchar)';
comment on column cds2db_in.observation_raw.obs_note_text is 'note/text (varchar)';
comment on column cds2db_in.observation_raw.obs_method_system is 'method/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_method_version is 'method/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_method_code is 'method/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_method_display is 'method/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_method_text is 'method/text (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_id is 'performer/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_type is 'performer/type (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_use is 'performer/identifier/use (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_system is 'performer/identifier/type/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_version is 'performer/identifier/type/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_code is 'performer/identifier/type/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_display is 'performer/identifier/type/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_identifier_type_text is 'performer/identifier/type/text (varchar)';
comment on column cds2db_in.observation_raw.obs_performer_display is 'performer/display (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_value is 'referenceRange/low/value (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_unit is 'referenceRange/low/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_system is 'referenceRange/low/system (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_low_code is 'referenceRange/low/code (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_value is 'referenceRange/high/value (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_unit is 'referenceRange/high/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_system is 'referenceRange/high/system (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_high_code is 'referenceRange/high/code (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_system is 'referenceRange/type/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_version is 'referenceRange/type/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_code is 'referenceRange/type/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_display is 'referenceRange/type/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_type_text is 'referenceRange/type/text (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_system is 'referenceRange/appliesTo/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_version is 'referenceRange/appliesTo/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_code is 'referenceRange/appliesTo/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_display is 'referenceRange/appliesTo/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_appliesto_text is 'referenceRange/appliesTo/text (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_value is 'referenceRange/age/low/value (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_unit is 'referenceRange/age/low/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_system is 'referenceRange/age/low/system (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_low_code is 'referenceRange/age/low/code (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_value is 'referenceRange/age/high/value (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_unit is 'referenceRange/age/high/unit (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_system is 'referenceRange/age/high/system (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_age_high_code is 'referenceRange/age/high/code (varchar)';
comment on column cds2db_in.observation_raw.obs_referencerange_text is 'referenceRange/text (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_id is 'hasMember/reference (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_type is 'hasMember/type (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_use is 'hasMember/identifier/use (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_system is 'hasMember/identifier/type/coding/system (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_version is 'hasMember/identifier/type/coding/version (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_code is 'hasMember/identifier/type/coding/code (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_display is 'hasMember/identifier/type/coding/display (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_identifier_type_text is 'hasMember/identifier/type/text (varchar)';
comment on column cds2db_in.observation_raw.obs_hasmember_display is 'hasMember/display (varchar)';
comment on column cds2db_in.observation_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.observation_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.observation_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.diagnosticreport_raw.diagnosticreport_id is 'Primary key of the entity';
comment on column cds2db_in.diagnosticreport_raw.diagrep_id is 'id (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_encounter_id is 'encounter/reference (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_partof_id is 'partOf/reference (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_result_id is 'result/reference (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_basedon_id is 'basedOn/reference (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_status is 'status (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_category_text is 'category/text (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_system is 'code/coding/system (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_version is 'code/coding/version (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_code is 'code/coding/code (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_display is 'code/coding/display (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_code_text is 'code/text (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_effectivedatetime is 'effectiveDateTime (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_issued is 'issued (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_id is 'performer/reference (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_type is 'performer/type (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_use is 'performer/identifier/use (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_system is 'performer/identifier/type/coding/system (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_version is 'performer/identifier/type/coding/version (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_code is 'performer/identifier/type/coding/code (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_display is 'performer/identifier/type/coding/display (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_identifier_type_text is 'performer/identifier/type/text (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_performer_display is 'performer/display (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusion is 'conclusion (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_system is 'conclusionCode/coding/system (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_version is 'conclusionCode/coding/version (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_code is 'conclusionCode/coding/code (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_display is 'conclusionCode/coding/display (varchar)';
comment on column cds2db_in.diagnosticreport_raw.diagrep_conclusioncode_text is 'conclusionCode/text (varchar)';
comment on column cds2db_in.diagnosticreport_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.diagnosticreport_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.diagnosticreport_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.servicerequest_raw.servicerequest_id is 'Primary key of the entity';
comment on column cds2db_in.servicerequest_raw.servreq_id is 'id (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_encounter_id is 'encounter/reference (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_id is 'basedOn/reference (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_type is 'basedOn/type (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_use is 'basedOn/identifier/use (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_identifier_type_text is 'basedOn/identifier/type/text (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_basedon_display is 'basedOn/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_status is 'status (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_intent is 'intent (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_category_text is 'category/text (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_code_system is 'code/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_code_version is 'code/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_code_code is 'code/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_code_display is 'code/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_code_text is 'code/text (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_authoredon is 'authoredOn (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_id is 'requester/reference (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_type is 'requester/type (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_use is 'requester/identifier/use (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_system is 'requester/identifier/type/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_version is 'requester/identifier/type/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_code is 'requester/identifier/type/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_display is 'requester/identifier/type/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_identifier_type_text is 'requester/identifier/type/text (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_requester_display is 'requester/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_id is 'performer/reference (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_type is 'performer/type (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_use is 'performer/identifier/use (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_system is 'performer/identifier/type/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_version is 'performer/identifier/type/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_code is 'performer/identifier/type/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_display is 'performer/identifier/type/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_identifier_type_text is 'performer/identifier/type/text (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_performer_display is 'performer/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_system is 'locationCode/coding/system (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_version is 'locationCode/coding/version (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_code is 'locationCode/coding/code (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_display is 'locationCode/coding/display (varchar)';
comment on column cds2db_in.servicerequest_raw.servreq_locationcode_text is 'locationCode/text (varchar)';
comment on column cds2db_in.servicerequest_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.servicerequest_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.servicerequest_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.procedure_raw.procedure_id is 'Primary key of the entity';
comment on column cds2db_in.procedure_raw.proc_id is 'id (varchar)';
comment on column cds2db_in.procedure_raw.proc_encounter_id is 'encounter/reference (varchar)';
comment on column cds2db_in.procedure_raw.proc_patient_id is 'subject/reference (varchar)';
comment on column cds2db_in.procedure_raw.proc_partof_id is 'partOf/reference (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.procedure_raw.proc_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_id is 'basedOn/reference (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_type is 'basedOn/type (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_use is 'basedOn/identifier/use (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_system is 'basedOn/identifier/type/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_version is 'basedOn/identifier/type/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_code is 'basedOn/identifier/type/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_display is 'basedOn/identifier/type/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_identifier_type_text is 'basedOn/identifier/type/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_basedon_display is 'basedOn/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_status is 'status (varchar)';
comment on column cds2db_in.procedure_raw.proc_statusreason_system is 'statusReason/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_statusreason_version is 'statusReason/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_statusreason_code is 'statusReason/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_statusreason_display is 'statusReason/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_statusreason_text is 'statusReason/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_category_system is 'category/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_category_version is 'category/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_category_code is 'category/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_category_display is 'category/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_category_text is 'category/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_code_system is 'code/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_code_version is 'code/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_code_code is 'code/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_code_display is 'code/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_code_text is 'code/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_performeddatetime is 'performedDateTime (varchar)';
comment on column cds2db_in.procedure_raw.proc_performedperiod_start is 'performedPeriod/start (varchar)';
comment on column cds2db_in.procedure_raw.proc_performedperiod_end is 'performedPeriod/end (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_system is 'reasonCode/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_version is 'reasonCode/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_code is 'reasonCode/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_display is 'reasonCode/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasoncode_text is 'reasonCode/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_id is 'reasonReference/reference (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_type is 'reasonReference/type (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_use is 'reasonReference/identifier/use (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_system is 'reasonReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_version is 'reasonReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_code is 'reasonReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_display is 'reasonReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_identifier_type_text is 'reasonReference/identifier/type/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_reasonreference_display is 'reasonReference/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorstring is 'note/authorString (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_id is 'note/authorReference/reference (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_type is 'note/authorReference/type (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_use is 'note/authorReference/identifier/use (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_version is 'note/authorReference/identifier/type/coding/version (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_code is 'note/authorReference/identifier/type/coding/code (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_display is 'note/authorReference/identifier/type/coding/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_identifier_type_text is 'note/authorReference/identifier/type/text (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_authorreference_display is 'note/authorReference/display (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_time is 'note/time (varchar)';
comment on column cds2db_in.procedure_raw.proc_note_text is 'note/text (varchar)';
comment on column cds2db_in.procedure_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.procedure_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.procedure_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.consent_raw.consent_id is 'Primary key of the entity';
comment on column cds2db_in.consent_raw.cons_id is 'id (varchar)';
comment on column cds2db_in.consent_raw.cons_patient_id is 'patient/reference (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.consent_raw.cons_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.consent_raw.cons_status is 'status (varchar)';
comment on column cds2db_in.consent_raw.cons_scope_system is 'scope/coding/system (varchar)';
comment on column cds2db_in.consent_raw.cons_scope_version is 'scope/coding/version (varchar)';
comment on column cds2db_in.consent_raw.cons_scope_code is 'scope/coding/code (varchar)';
comment on column cds2db_in.consent_raw.cons_scope_display is 'scope/coding/display (varchar)';
comment on column cds2db_in.consent_raw.cons_scope_text is 'scope/text (varchar)';
comment on column cds2db_in.consent_raw.cons_datetime is 'dateTime (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_type is 'provision/type (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_period_start is 'provision/period/start (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_period_end is 'provision/period/end (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_system is 'provision/actor/role/coding/system (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_version is 'provision/actor/role/coding/version (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_code is 'provision/actor/role/coding/code (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_display is 'provision/actor/role/coding/display (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_actor_role_text is 'provision/actor/role/text (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_code_system is 'provision/code/coding/system (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_code_version is 'provision/code/coding/version (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_code_code is 'provision/code/coding/code (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_code_display is 'provision/code/coding/display (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_code_text is 'provision/code/text (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_dataperiod_start is 'provision/dataPeriod/start (varchar)';
comment on column cds2db_in.consent_raw.cons_provision_dataperiod_end is 'provision/dataPeriod/end (varchar)';
comment on column cds2db_in.consent_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.consent_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.consent_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.location_raw.location_id is 'Primary key of the entity';
comment on column cds2db_in.location_raw.loc_id is 'id (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_use is 'identifier/use (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_type_system is 'identifier/type/coding/system (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_type_version is 'identifier/type/coding/version (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_type_code is 'identifier/type/coding/code (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_type_display is 'identifier/type/coding/display (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_type_text is 'identifier/type/text (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_system is 'identifier/system (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_value is 'identifier/value (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_start is 'identifier/start (varchar)';
comment on column cds2db_in.location_raw.loc_identifier_end is 'identifier/end (varchar)';
comment on column cds2db_in.location_raw.loc_status is 'status (varchar)';
comment on column cds2db_in.location_raw.loc_name is 'name (varchar)';
comment on column cds2db_in.location_raw.loc_description is 'description (varchar)';
comment on column cds2db_in.location_raw.loc_alias is 'alias (varchar)';
comment on column cds2db_in.location_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.location_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.location_raw.current_dataset_status is 'Processing status of the data record';

comment on column cds2db_in.pids_per_ward_raw.pids_per_ward_id is 'Primary key of the entity';
comment on column cds2db_in.pids_per_ward_raw.ward_name is 'ward_name (varchar)';
comment on column cds2db_in.pids_per_ward_raw.patient_id is 'patient_id (varchar)';
comment on column cds2db_in.pids_per_ward_raw.input_datetime is 'Time at which the data record is inserted';
comment on column cds2db_in.pids_per_ward_raw.last_check_datetime is 'Time at which data record was last checked';
comment on column cds2db_in.pids_per_ward_raw.current_dataset_status is 'Processing status of the data record';



-- Output on
\o
