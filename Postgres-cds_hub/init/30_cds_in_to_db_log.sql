------------------------------
CREATE OR REPLACE FUNCTION db.copy_raw_cds_in_to_db_log()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
BEGIN
    -- Copy Functionname: copy_raw_cds_in_to_db_log - From: cds2db_in -> To: db_log
    -- Start encounter
    FOR current_record IN (SELECT * FROM cds2db_in.encounter_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.encounter_raw target_record
                WHERE COALESCE(target_record.enc_id::text,'#NULL#') = COALESCE(current_record.enc_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_patient_id::text,'#NULL#') = COALESCE(current_record.enc_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_partof_id::text,'#NULL#') = COALESCE(current_record.enc_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_use::text,'#NULL#') = COALESCE(current_record.enc_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_system::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_version::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_code::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_display::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_text::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_system::text,'#NULL#') = COALESCE(current_record.enc_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_value::text,'#NULL#') = COALESCE(current_record.enc_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_start::text,'#NULL#') = COALESCE(current_record.enc_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_end::text,'#NULL#') = COALESCE(current_record.enc_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.enc_status::text,'#NULL#') = COALESCE(current_record.enc_status::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_system::text,'#NULL#') = COALESCE(current_record.enc_class_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_version::text,'#NULL#') = COALESCE(current_record.enc_class_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_code::text,'#NULL#') = COALESCE(current_record.enc_class_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_display::text,'#NULL#') = COALESCE(current_record.enc_class_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_system::text,'#NULL#') = COALESCE(current_record.enc_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_version::text,'#NULL#') = COALESCE(current_record.enc_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_code::text,'#NULL#') = COALESCE(current_record.enc_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_display::text,'#NULL#') = COALESCE(current_record.enc_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_text::text,'#NULL#') = COALESCE(current_record.enc_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_system::text,'#NULL#') = COALESCE(current_record.enc_servicetype_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_version::text,'#NULL#') = COALESCE(current_record.enc_servicetype_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_code::text,'#NULL#') = COALESCE(current_record.enc_servicetype_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_display::text,'#NULL#') = COALESCE(current_record.enc_servicetype_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_text::text,'#NULL#') = COALESCE(current_record.enc_servicetype_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_period_start::text,'#NULL#') = COALESCE(current_record.enc_period_start::text,'#NULL#') AND
                      COALESCE(target_record.enc_period_end::text,'#NULL#') = COALESCE(current_record.enc_period_end::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_condition_id::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_condition_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_system::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_version::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_code::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_display::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_text::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_rank::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_rank::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_system::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_version::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_code::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_display::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_text::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_system::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_version::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_code::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_display::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_text::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_id::text,'#NULL#') = COALESCE(current_record.enc_location_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_type::text,'#NULL#') = COALESCE(current_record.enc_location_type::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_use::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_system::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_version::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_code::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_display::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_text::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_display::text,'#NULL#') = COALESCE(current_record.enc_location_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_status::text,'#NULL#') = COALESCE(current_record.enc_location_status::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_system::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_version::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_code::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_display::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_text::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_id::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_type::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_type::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_use::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_system::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_version::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_code::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_display::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_text::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_display::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_display::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.encounter_raw (
                        enc_id,
                        enc_patient_id,
                        enc_partof_id,
                        enc_identifier_use,
                        enc_identifier_type_system,
                        enc_identifier_type_version,
                        enc_identifier_type_code,
                        enc_identifier_type_display,
                        enc_identifier_type_text,
                        enc_identifier_system,
                        enc_identifier_value,
                        enc_identifier_start,
                        enc_identifier_end,
                        enc_status,
                        enc_class_system,
                        enc_class_version,
                        enc_class_code,
                        enc_class_display,
                        enc_type_system,
                        enc_type_version,
                        enc_type_code,
                        enc_type_display,
                        enc_type_text,
                        enc_servicetype_system,
                        enc_servicetype_version,
                        enc_servicetype_code,
                        enc_servicetype_display,
                        enc_servicetype_text,
                        enc_period_start,
                        enc_period_end,
                        enc_diagnosis_condition_id,
                        enc_diagnosis_use_system,
                        enc_diagnosis_use_version,
                        enc_diagnosis_use_code,
                        enc_diagnosis_use_display,
                        enc_diagnosis_use_text,
                        enc_diagnosis_rank,
                        enc_hospitalization_admitsource_system,
                        enc_hospitalization_admitsource_version,
                        enc_hospitalization_admitsource_code,
                        enc_hospitalization_admitsource_display,
                        enc_hospitalization_admitsource_text,
                        enc_hospitalization_dischargedisposition_system,
                        enc_hospitalization_dischargedisposition_version,
                        enc_hospitalization_dischargedisposition_code,
                        enc_hospitalization_dischargedisposition_display,
                        enc_hospitalization_dischargedisposition_text,
                        enc_location_id,
                        enc_location_type,
                        enc_location_identifier_use,
                        enc_location_identifier_type_system,
                        enc_location_identifier_type_version,
                        enc_location_identifier_type_code,
                        enc_location_identifier_type_display,
                        enc_location_identifier_type_text,
                        enc_location_display,
                        enc_location_status,
                        enc_location_physicaltype_system,
                        enc_location_physicaltype_version,
                        enc_location_physicaltype_code,
                        enc_location_physicaltype_display,
                        enc_location_physicaltype_text,
                        enc_serviceprovider_id,
                        enc_serviceprovider_type,
                        enc_serviceprovider_identifier_use,
                        enc_serviceprovider_identifier_type_system,
                        enc_serviceprovider_identifier_type_version,
                        enc_serviceprovider_identifier_type_code,
                        enc_serviceprovider_identifier_type_display,
                        enc_serviceprovider_identifier_type_text,
                        enc_serviceprovider_display,
                        input_datetime
                    )
                    VALUES (
                        current_record.enc_id,
                        current_record.enc_patient_id,
                        current_record.enc_partof_id,
                        current_record.enc_identifier_use,
                        current_record.enc_identifier_type_system,
                        current_record.enc_identifier_type_version,
                        current_record.enc_identifier_type_code,
                        current_record.enc_identifier_type_display,
                        current_record.enc_identifier_type_text,
                        current_record.enc_identifier_system,
                        current_record.enc_identifier_value,
                        current_record.enc_identifier_start,
                        current_record.enc_identifier_end,
                        current_record.enc_status,
                        current_record.enc_class_system,
                        current_record.enc_class_version,
                        current_record.enc_class_code,
                        current_record.enc_class_display,
                        current_record.enc_type_system,
                        current_record.enc_type_version,
                        current_record.enc_type_code,
                        current_record.enc_type_display,
                        current_record.enc_type_text,
                        current_record.enc_servicetype_system,
                        current_record.enc_servicetype_version,
                        current_record.enc_servicetype_code,
                        current_record.enc_servicetype_display,
                        current_record.enc_servicetype_text,
                        current_record.enc_period_start,
                        current_record.enc_period_end,
                        current_record.enc_diagnosis_condition_id,
                        current_record.enc_diagnosis_use_system,
                        current_record.enc_diagnosis_use_version,
                        current_record.enc_diagnosis_use_code,
                        current_record.enc_diagnosis_use_display,
                        current_record.enc_diagnosis_use_text,
                        current_record.enc_diagnosis_rank,
                        current_record.enc_hospitalization_admitsource_system,
                        current_record.enc_hospitalization_admitsource_version,
                        current_record.enc_hospitalization_admitsource_code,
                        current_record.enc_hospitalization_admitsource_display,
                        current_record.enc_hospitalization_admitsource_text,
                        current_record.enc_hospitalization_dischargedisposition_system,
                        current_record.enc_hospitalization_dischargedisposition_version,
                        current_record.enc_hospitalization_dischargedisposition_code,
                        current_record.enc_hospitalization_dischargedisposition_display,
                        current_record.enc_hospitalization_dischargedisposition_text,
                        current_record.enc_location_id,
                        current_record.enc_location_type,
                        current_record.enc_location_identifier_use,
                        current_record.enc_location_identifier_type_system,
                        current_record.enc_location_identifier_type_version,
                        current_record.enc_location_identifier_type_code,
                        current_record.enc_location_identifier_type_display,
                        current_record.enc_location_identifier_type_text,
                        current_record.enc_location_display,
                        current_record.enc_location_status,
                        current_record.enc_location_physicaltype_system,
                        current_record.enc_location_physicaltype_version,
                        current_record.enc_location_physicaltype_code,
                        current_record.enc_location_physicaltype_display,
                        current_record.enc_location_physicaltype_text,
                        current_record.enc_serviceprovider_id,
                        current_record.enc_serviceprovider_type,
                        current_record.enc_serviceprovider_identifier_use,
                        current_record.enc_serviceprovider_identifier_type_system,
                        current_record.enc_serviceprovider_identifier_type_version,
                        current_record.enc_serviceprovider_identifier_type_code,
                        current_record.enc_serviceprovider_identifier_type_display,
                        current_record.enc_serviceprovider_identifier_type_text,
                        current_record.enc_serviceprovider_display,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.encounter_raw WHERE encounter_id = current_record.encounter_id;
                ELSE
                UPDATE db_log.encounter_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.enc_id::text,'#NULL#') = COALESCE(current_record.enc_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_patient_id::text,'#NULL#') = COALESCE(current_record.enc_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_partof_id::text,'#NULL#') = COALESCE(current_record.enc_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_use::text,'#NULL#') = COALESCE(current_record.enc_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_system::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_version::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_code::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_display::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_type_text::text,'#NULL#') = COALESCE(current_record.enc_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_system::text,'#NULL#') = COALESCE(current_record.enc_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_value::text,'#NULL#') = COALESCE(current_record.enc_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_start::text,'#NULL#') = COALESCE(current_record.enc_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.enc_identifier_end::text,'#NULL#') = COALESCE(current_record.enc_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.enc_status::text,'#NULL#') = COALESCE(current_record.enc_status::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_system::text,'#NULL#') = COALESCE(current_record.enc_class_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_version::text,'#NULL#') = COALESCE(current_record.enc_class_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_code::text,'#NULL#') = COALESCE(current_record.enc_class_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_class_display::text,'#NULL#') = COALESCE(current_record.enc_class_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_system::text,'#NULL#') = COALESCE(current_record.enc_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_version::text,'#NULL#') = COALESCE(current_record.enc_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_code::text,'#NULL#') = COALESCE(current_record.enc_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_display::text,'#NULL#') = COALESCE(current_record.enc_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_type_text::text,'#NULL#') = COALESCE(current_record.enc_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_system::text,'#NULL#') = COALESCE(current_record.enc_servicetype_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_version::text,'#NULL#') = COALESCE(current_record.enc_servicetype_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_code::text,'#NULL#') = COALESCE(current_record.enc_servicetype_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_display::text,'#NULL#') = COALESCE(current_record.enc_servicetype_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_servicetype_text::text,'#NULL#') = COALESCE(current_record.enc_servicetype_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_period_start::text,'#NULL#') = COALESCE(current_record.enc_period_start::text,'#NULL#') AND
                      COALESCE(target_record.enc_period_end::text,'#NULL#') = COALESCE(current_record.enc_period_end::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_condition_id::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_condition_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_system::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_version::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_code::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_display::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_use_text::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_use_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_diagnosis_rank::text,'#NULL#') = COALESCE(current_record.enc_diagnosis_rank::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_system::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_version::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_code::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_display::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_admitsource_text::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_admitsource_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_system::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_version::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_code::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_display::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_hospitalization_dischargedisposition_text::text,'#NULL#') = COALESCE(current_record.enc_hospitalization_dischargedisposition_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_id::text,'#NULL#') = COALESCE(current_record.enc_location_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_type::text,'#NULL#') = COALESCE(current_record.enc_location_type::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_use::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_system::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_version::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_code::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_display::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_identifier_type_text::text,'#NULL#') = COALESCE(current_record.enc_location_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_display::text,'#NULL#') = COALESCE(current_record.enc_location_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_status::text,'#NULL#') = COALESCE(current_record.enc_location_status::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_system::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_version::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_code::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_display::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_location_physicaltype_text::text,'#NULL#') = COALESCE(current_record.enc_location_physicaltype_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_id::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_id::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_type::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_type::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_use::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_system::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_version::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_code::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_display::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_identifier_type_text::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.enc_serviceprovider_display::text,'#NULL#') = COALESCE(current_record.enc_serviceprovider_display::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.encounter_raw WHERE encounter_id = current_record.encounter_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.encounter_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE encounter_id = current_record.encounter_id;
            END;
    END LOOP;
    -- END encounter
    -- Start patient
    FOR current_record IN (SELECT * FROM cds2db_in.patient_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.patient_raw target_record
                WHERE COALESCE(target_record.pat_id::text,'#NULL#') = COALESCE(current_record.pat_id::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_use::text,'#NULL#') = COALESCE(current_record.pat_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_system::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_version::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_code::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_display::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_text::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_system::text,'#NULL#') = COALESCE(current_record.pat_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_value::text,'#NULL#') = COALESCE(current_record.pat_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_start::text,'#NULL#') = COALESCE(current_record.pat_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_end::text,'#NULL#') = COALESCE(current_record.pat_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.pat_name_text::text,'#NULL#') = COALESCE(current_record.pat_name_text::text,'#NULL#') AND
                      COALESCE(target_record.pat_name_family::text,'#NULL#') = COALESCE(current_record.pat_name_family::text,'#NULL#') AND
                      COALESCE(target_record.pat_name_given::text,'#NULL#') = COALESCE(current_record.pat_name_given::text,'#NULL#') AND
                      COALESCE(target_record.pat_gender::text,'#NULL#') = COALESCE(current_record.pat_gender::text,'#NULL#') AND
                      COALESCE(target_record.pat_birthdate::text,'#NULL#') = COALESCE(current_record.pat_birthdate::text,'#NULL#') AND
                      COALESCE(target_record.pat_address_postalcode::text,'#NULL#') = COALESCE(current_record.pat_address_postalcode::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.patient_raw (
                        pat_id,
                        pat_identifier_use,
                        pat_identifier_type_system,
                        pat_identifier_type_version,
                        pat_identifier_type_code,
                        pat_identifier_type_display,
                        pat_identifier_type_text,
                        pat_identifier_system,
                        pat_identifier_value,
                        pat_identifier_start,
                        pat_identifier_end,
                        pat_name_text,
                        pat_name_family,
                        pat_name_given,
                        pat_gender,
                        pat_birthdate,
                        pat_address_postalcode,
                        input_datetime
                    )
                    VALUES (
                        current_record.pat_id,
                        current_record.pat_identifier_use,
                        current_record.pat_identifier_type_system,
                        current_record.pat_identifier_type_version,
                        current_record.pat_identifier_type_code,
                        current_record.pat_identifier_type_display,
                        current_record.pat_identifier_type_text,
                        current_record.pat_identifier_system,
                        current_record.pat_identifier_value,
                        current_record.pat_identifier_start,
                        current_record.pat_identifier_end,
                        current_record.pat_name_text,
                        current_record.pat_name_family,
                        current_record.pat_name_given,
                        current_record.pat_gender,
                        current_record.pat_birthdate,
                        current_record.pat_address_postalcode,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.patient_raw WHERE patient_id = current_record.patient_id;
                ELSE
                UPDATE db_log.patient_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.pat_id::text,'#NULL#') = COALESCE(current_record.pat_id::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_use::text,'#NULL#') = COALESCE(current_record.pat_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_system::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_version::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_code::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_display::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_type_text::text,'#NULL#') = COALESCE(current_record.pat_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_system::text,'#NULL#') = COALESCE(current_record.pat_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_value::text,'#NULL#') = COALESCE(current_record.pat_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_start::text,'#NULL#') = COALESCE(current_record.pat_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.pat_identifier_end::text,'#NULL#') = COALESCE(current_record.pat_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.pat_name_text::text,'#NULL#') = COALESCE(current_record.pat_name_text::text,'#NULL#') AND
                      COALESCE(target_record.pat_name_family::text,'#NULL#') = COALESCE(current_record.pat_name_family::text,'#NULL#') AND
                      COALESCE(target_record.pat_name_given::text,'#NULL#') = COALESCE(current_record.pat_name_given::text,'#NULL#') AND
                      COALESCE(target_record.pat_gender::text,'#NULL#') = COALESCE(current_record.pat_gender::text,'#NULL#') AND
                      COALESCE(target_record.pat_birthdate::text,'#NULL#') = COALESCE(current_record.pat_birthdate::text,'#NULL#') AND
                      COALESCE(target_record.pat_address_postalcode::text,'#NULL#') = COALESCE(current_record.pat_address_postalcode::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.patient_raw WHERE patient_id = current_record.patient_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.patient_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE patient_id = current_record.patient_id;
            END;
    END LOOP;
    -- END patient
    -- Start condition
    FOR current_record IN (SELECT * FROM cds2db_in.condition_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.condition_raw target_record
                WHERE COALESCE(target_record.con_id::text,'#NULL#') = COALESCE(current_record.con_id::text,'#NULL#') AND
                      COALESCE(target_record.con_encounter_id::text,'#NULL#') = COALESCE(current_record.con_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.con_patient_id::text,'#NULL#') = COALESCE(current_record.con_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_use::text,'#NULL#') = COALESCE(current_record.con_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_system::text,'#NULL#') = COALESCE(current_record.con_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_value::text,'#NULL#') = COALESCE(current_record.con_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_start::text,'#NULL#') = COALESCE(current_record.con_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_end::text,'#NULL#') = COALESCE(current_record.con_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_system::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_system::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_version::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_version::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_code::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_code::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_display::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_display::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_text::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_text::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_system::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_system::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_version::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_version::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_code::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_code::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_display::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_display::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_text::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_text::text,'#NULL#') AND
                      COALESCE(target_record.con_category_system::text,'#NULL#') = COALESCE(current_record.con_category_system::text,'#NULL#') AND
                      COALESCE(target_record.con_category_version::text,'#NULL#') = COALESCE(current_record.con_category_version::text,'#NULL#') AND
                      COALESCE(target_record.con_category_code::text,'#NULL#') = COALESCE(current_record.con_category_code::text,'#NULL#') AND
                      COALESCE(target_record.con_category_display::text,'#NULL#') = COALESCE(current_record.con_category_display::text,'#NULL#') AND
                      COALESCE(target_record.con_category_text::text,'#NULL#') = COALESCE(current_record.con_category_text::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_system::text,'#NULL#') = COALESCE(current_record.con_severity_system::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_version::text,'#NULL#') = COALESCE(current_record.con_severity_version::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_code::text,'#NULL#') = COALESCE(current_record.con_severity_code::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_display::text,'#NULL#') = COALESCE(current_record.con_severity_display::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_text::text,'#NULL#') = COALESCE(current_record.con_severity_text::text,'#NULL#') AND
                      COALESCE(target_record.con_code_system::text,'#NULL#') = COALESCE(current_record.con_code_system::text,'#NULL#') AND
                      COALESCE(target_record.con_code_version::text,'#NULL#') = COALESCE(current_record.con_code_version::text,'#NULL#') AND
                      COALESCE(target_record.con_code_code::text,'#NULL#') = COALESCE(current_record.con_code_code::text,'#NULL#') AND
                      COALESCE(target_record.con_code_display::text,'#NULL#') = COALESCE(current_record.con_code_display::text,'#NULL#') AND
                      COALESCE(target_record.con_code_text::text,'#NULL#') = COALESCE(current_record.con_code_text::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_system::text,'#NULL#') = COALESCE(current_record.con_bodysite_system::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_version::text,'#NULL#') = COALESCE(current_record.con_bodysite_version::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_code::text,'#NULL#') = COALESCE(current_record.con_bodysite_code::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_display::text,'#NULL#') = COALESCE(current_record.con_bodysite_display::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_text::text,'#NULL#') = COALESCE(current_record.con_bodysite_text::text,'#NULL#') AND
                      COALESCE(target_record.con_onsetperiod_start::text,'#NULL#') = COALESCE(current_record.con_onsetperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.con_onsetperiod_end::text,'#NULL#') = COALESCE(current_record.con_onsetperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.con_onsetdatetime::text,'#NULL#') = COALESCE(current_record.con_onsetdatetime::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementdatetime::text,'#NULL#') = COALESCE(current_record.con_abatementdatetime::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_value::text,'#NULL#') = COALESCE(current_record.con_abatementage_value::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_comparator::text,'#NULL#') = COALESCE(current_record.con_abatementage_comparator::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_unit::text,'#NULL#') = COALESCE(current_record.con_abatementage_unit::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_system::text,'#NULL#') = COALESCE(current_record.con_abatementage_system::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_code::text,'#NULL#') = COALESCE(current_record.con_abatementage_code::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementperiod_start::text,'#NULL#') = COALESCE(current_record.con_abatementperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementperiod_end::text,'#NULL#') = COALESCE(current_record.con_abatementperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_value::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_unit::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_system::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_code::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_value::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_unit::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_system::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_code::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementstring::text,'#NULL#') = COALESCE(current_record.con_abatementstring::text,'#NULL#') AND
                      COALESCE(target_record.con_recordeddate::text,'#NULL#') = COALESCE(current_record.con_recordeddate::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_id::text,'#NULL#') = COALESCE(current_record.con_recorder_id::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_type::text,'#NULL#') = COALESCE(current_record.con_recorder_type::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_use::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_display::text,'#NULL#') = COALESCE(current_record.con_recorder_display::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_id::text,'#NULL#') = COALESCE(current_record.con_asserter_id::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_type::text,'#NULL#') = COALESCE(current_record.con_asserter_type::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_use::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_display::text,'#NULL#') = COALESCE(current_record.con_asserter_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_system::text,'#NULL#') = COALESCE(current_record.con_stage_summary_system::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_version::text,'#NULL#') = COALESCE(current_record.con_stage_summary_version::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_code::text,'#NULL#') = COALESCE(current_record.con_stage_summary_code::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_display::text,'#NULL#') = COALESCE(current_record.con_stage_summary_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_text::text,'#NULL#') = COALESCE(current_record.con_stage_summary_text::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_id::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_id::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_type::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_type::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_use::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_display::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_system::text,'#NULL#') = COALESCE(current_record.con_stage_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_version::text,'#NULL#') = COALESCE(current_record.con_stage_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_code::text,'#NULL#') = COALESCE(current_record.con_stage_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_display::text,'#NULL#') = COALESCE(current_record.con_stage_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_text::text,'#NULL#') = COALESCE(current_record.con_stage_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorstring::text,'#NULL#') = COALESCE(current_record.con_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.con_note_time::text,'#NULL#') = COALESCE(current_record.con_note_time::text,'#NULL#') AND
                      COALESCE(target_record.con_note_text::text,'#NULL#') = COALESCE(current_record.con_note_text::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.condition_raw (
                        con_id,
                        con_encounter_id,
                        con_patient_id,
                        con_identifier_use,
                        con_identifier_type_system,
                        con_identifier_type_version,
                        con_identifier_type_code,
                        con_identifier_type_display,
                        con_identifier_type_text,
                        con_identifier_system,
                        con_identifier_value,
                        con_identifier_start,
                        con_identifier_end,
                        con_clinicalstatus_system,
                        con_clinicalstatus_version,
                        con_clinicalstatus_code,
                        con_clinicalstatus_display,
                        con_clinicalstatus_text,
                        con_verificationstatus_system,
                        con_verificationstatus_version,
                        con_verificationstatus_code,
                        con_verificationstatus_display,
                        con_verificationstatus_text,
                        con_category_system,
                        con_category_version,
                        con_category_code,
                        con_category_display,
                        con_category_text,
                        con_severity_system,
                        con_severity_version,
                        con_severity_code,
                        con_severity_display,
                        con_severity_text,
                        con_code_system,
                        con_code_version,
                        con_code_code,
                        con_code_display,
                        con_code_text,
                        con_bodysite_system,
                        con_bodysite_version,
                        con_bodysite_code,
                        con_bodysite_display,
                        con_bodysite_text,
                        con_onsetperiod_start,
                        con_onsetperiod_end,
                        con_onsetdatetime,
                        con_abatementdatetime,
                        con_abatementage_value,
                        con_abatementage_comparator,
                        con_abatementage_unit,
                        con_abatementage_system,
                        con_abatementage_code,
                        con_abatementperiod_start,
                        con_abatementperiod_end,
                        con_abatementrange_low_value,
                        con_abatementrange_low_unit,
                        con_abatementrange_low_system,
                        con_abatementrange_low_code,
                        con_abatementrange_high_value,
                        con_abatementrange_high_unit,
                        con_abatementrange_high_system,
                        con_abatementrange_high_code,
                        con_abatementstring,
                        con_recordeddate,
                        con_recorder_id,
                        con_recorder_type,
                        con_recorder_identifier_use,
                        con_recorder_identifier_type_system,
                        con_recorder_identifier_type_version,
                        con_recorder_identifier_type_code,
                        con_recorder_identifier_type_display,
                        con_recorder_identifier_type_text,
                        con_recorder_display,
                        con_asserter_id,
                        con_asserter_type,
                        con_asserter_identifier_use,
                        con_asserter_identifier_type_system,
                        con_asserter_identifier_type_version,
                        con_asserter_identifier_type_code,
                        con_asserter_identifier_type_display,
                        con_asserter_identifier_type_text,
                        con_asserter_display,
                        con_stage_summary_system,
                        con_stage_summary_version,
                        con_stage_summary_code,
                        con_stage_summary_display,
                        con_stage_summary_text,
                        con_stage_assessment_id,
                        con_stage_assessment_type,
                        con_stage_assessment_identifier_use,
                        con_stage_assessment_identifier_type_system,
                        con_stage_assessment_identifier_type_version,
                        con_stage_assessment_identifier_type_code,
                        con_stage_assessment_identifier_type_display,
                        con_stage_assessment_identifier_type_text,
                        con_stage_assessment_display,
                        con_stage_type_system,
                        con_stage_type_version,
                        con_stage_type_code,
                        con_stage_type_display,
                        con_stage_type_text,
                        con_note_authorstring,
                        con_note_authorreference_id,
                        con_note_authorreference_type,
                        con_note_authorreference_identifier_use,
                        con_note_authorreference_identifier_type_system,
                        con_note_authorreference_identifier_type_version,
                        con_note_authorreference_identifier_type_code,
                        con_note_authorreference_identifier_type_display,
                        con_note_authorreference_identifier_type_text,
                        con_note_authorreference_display,
                        con_note_time,
                        con_note_text,
                        input_datetime
                    )
                    VALUES (
                        current_record.con_id,
                        current_record.con_encounter_id,
                        current_record.con_patient_id,
                        current_record.con_identifier_use,
                        current_record.con_identifier_type_system,
                        current_record.con_identifier_type_version,
                        current_record.con_identifier_type_code,
                        current_record.con_identifier_type_display,
                        current_record.con_identifier_type_text,
                        current_record.con_identifier_system,
                        current_record.con_identifier_value,
                        current_record.con_identifier_start,
                        current_record.con_identifier_end,
                        current_record.con_clinicalstatus_system,
                        current_record.con_clinicalstatus_version,
                        current_record.con_clinicalstatus_code,
                        current_record.con_clinicalstatus_display,
                        current_record.con_clinicalstatus_text,
                        current_record.con_verificationstatus_system,
                        current_record.con_verificationstatus_version,
                        current_record.con_verificationstatus_code,
                        current_record.con_verificationstatus_display,
                        current_record.con_verificationstatus_text,
                        current_record.con_category_system,
                        current_record.con_category_version,
                        current_record.con_category_code,
                        current_record.con_category_display,
                        current_record.con_category_text,
                        current_record.con_severity_system,
                        current_record.con_severity_version,
                        current_record.con_severity_code,
                        current_record.con_severity_display,
                        current_record.con_severity_text,
                        current_record.con_code_system,
                        current_record.con_code_version,
                        current_record.con_code_code,
                        current_record.con_code_display,
                        current_record.con_code_text,
                        current_record.con_bodysite_system,
                        current_record.con_bodysite_version,
                        current_record.con_bodysite_code,
                        current_record.con_bodysite_display,
                        current_record.con_bodysite_text,
                        current_record.con_onsetperiod_start,
                        current_record.con_onsetperiod_end,
                        current_record.con_onsetdatetime,
                        current_record.con_abatementdatetime,
                        current_record.con_abatementage_value,
                        current_record.con_abatementage_comparator,
                        current_record.con_abatementage_unit,
                        current_record.con_abatementage_system,
                        current_record.con_abatementage_code,
                        current_record.con_abatementperiod_start,
                        current_record.con_abatementperiod_end,
                        current_record.con_abatementrange_low_value,
                        current_record.con_abatementrange_low_unit,
                        current_record.con_abatementrange_low_system,
                        current_record.con_abatementrange_low_code,
                        current_record.con_abatementrange_high_value,
                        current_record.con_abatementrange_high_unit,
                        current_record.con_abatementrange_high_system,
                        current_record.con_abatementrange_high_code,
                        current_record.con_abatementstring,
                        current_record.con_recordeddate,
                        current_record.con_recorder_id,
                        current_record.con_recorder_type,
                        current_record.con_recorder_identifier_use,
                        current_record.con_recorder_identifier_type_system,
                        current_record.con_recorder_identifier_type_version,
                        current_record.con_recorder_identifier_type_code,
                        current_record.con_recorder_identifier_type_display,
                        current_record.con_recorder_identifier_type_text,
                        current_record.con_recorder_display,
                        current_record.con_asserter_id,
                        current_record.con_asserter_type,
                        current_record.con_asserter_identifier_use,
                        current_record.con_asserter_identifier_type_system,
                        current_record.con_asserter_identifier_type_version,
                        current_record.con_asserter_identifier_type_code,
                        current_record.con_asserter_identifier_type_display,
                        current_record.con_asserter_identifier_type_text,
                        current_record.con_asserter_display,
                        current_record.con_stage_summary_system,
                        current_record.con_stage_summary_version,
                        current_record.con_stage_summary_code,
                        current_record.con_stage_summary_display,
                        current_record.con_stage_summary_text,
                        current_record.con_stage_assessment_id,
                        current_record.con_stage_assessment_type,
                        current_record.con_stage_assessment_identifier_use,
                        current_record.con_stage_assessment_identifier_type_system,
                        current_record.con_stage_assessment_identifier_type_version,
                        current_record.con_stage_assessment_identifier_type_code,
                        current_record.con_stage_assessment_identifier_type_display,
                        current_record.con_stage_assessment_identifier_type_text,
                        current_record.con_stage_assessment_display,
                        current_record.con_stage_type_system,
                        current_record.con_stage_type_version,
                        current_record.con_stage_type_code,
                        current_record.con_stage_type_display,
                        current_record.con_stage_type_text,
                        current_record.con_note_authorstring,
                        current_record.con_note_authorreference_id,
                        current_record.con_note_authorreference_type,
                        current_record.con_note_authorreference_identifier_use,
                        current_record.con_note_authorreference_identifier_type_system,
                        current_record.con_note_authorreference_identifier_type_version,
                        current_record.con_note_authorreference_identifier_type_code,
                        current_record.con_note_authorreference_identifier_type_display,
                        current_record.con_note_authorreference_identifier_type_text,
                        current_record.con_note_authorreference_display,
                        current_record.con_note_time,
                        current_record.con_note_text,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.condition_raw WHERE condition_id = current_record.condition_id;
                ELSE
                UPDATE db_log.condition_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.con_id::text,'#NULL#') = COALESCE(current_record.con_id::text,'#NULL#') AND
                      COALESCE(target_record.con_encounter_id::text,'#NULL#') = COALESCE(current_record.con_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.con_patient_id::text,'#NULL#') = COALESCE(current_record.con_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_use::text,'#NULL#') = COALESCE(current_record.con_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_system::text,'#NULL#') = COALESCE(current_record.con_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_value::text,'#NULL#') = COALESCE(current_record.con_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_start::text,'#NULL#') = COALESCE(current_record.con_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.con_identifier_end::text,'#NULL#') = COALESCE(current_record.con_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_system::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_system::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_version::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_version::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_code::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_code::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_display::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_display::text,'#NULL#') AND
                      COALESCE(target_record.con_clinicalstatus_text::text,'#NULL#') = COALESCE(current_record.con_clinicalstatus_text::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_system::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_system::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_version::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_version::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_code::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_code::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_display::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_display::text,'#NULL#') AND
                      COALESCE(target_record.con_verificationstatus_text::text,'#NULL#') = COALESCE(current_record.con_verificationstatus_text::text,'#NULL#') AND
                      COALESCE(target_record.con_category_system::text,'#NULL#') = COALESCE(current_record.con_category_system::text,'#NULL#') AND
                      COALESCE(target_record.con_category_version::text,'#NULL#') = COALESCE(current_record.con_category_version::text,'#NULL#') AND
                      COALESCE(target_record.con_category_code::text,'#NULL#') = COALESCE(current_record.con_category_code::text,'#NULL#') AND
                      COALESCE(target_record.con_category_display::text,'#NULL#') = COALESCE(current_record.con_category_display::text,'#NULL#') AND
                      COALESCE(target_record.con_category_text::text,'#NULL#') = COALESCE(current_record.con_category_text::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_system::text,'#NULL#') = COALESCE(current_record.con_severity_system::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_version::text,'#NULL#') = COALESCE(current_record.con_severity_version::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_code::text,'#NULL#') = COALESCE(current_record.con_severity_code::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_display::text,'#NULL#') = COALESCE(current_record.con_severity_display::text,'#NULL#') AND
                      COALESCE(target_record.con_severity_text::text,'#NULL#') = COALESCE(current_record.con_severity_text::text,'#NULL#') AND
                      COALESCE(target_record.con_code_system::text,'#NULL#') = COALESCE(current_record.con_code_system::text,'#NULL#') AND
                      COALESCE(target_record.con_code_version::text,'#NULL#') = COALESCE(current_record.con_code_version::text,'#NULL#') AND
                      COALESCE(target_record.con_code_code::text,'#NULL#') = COALESCE(current_record.con_code_code::text,'#NULL#') AND
                      COALESCE(target_record.con_code_display::text,'#NULL#') = COALESCE(current_record.con_code_display::text,'#NULL#') AND
                      COALESCE(target_record.con_code_text::text,'#NULL#') = COALESCE(current_record.con_code_text::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_system::text,'#NULL#') = COALESCE(current_record.con_bodysite_system::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_version::text,'#NULL#') = COALESCE(current_record.con_bodysite_version::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_code::text,'#NULL#') = COALESCE(current_record.con_bodysite_code::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_display::text,'#NULL#') = COALESCE(current_record.con_bodysite_display::text,'#NULL#') AND
                      COALESCE(target_record.con_bodysite_text::text,'#NULL#') = COALESCE(current_record.con_bodysite_text::text,'#NULL#') AND
                      COALESCE(target_record.con_onsetperiod_start::text,'#NULL#') = COALESCE(current_record.con_onsetperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.con_onsetperiod_end::text,'#NULL#') = COALESCE(current_record.con_onsetperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.con_onsetdatetime::text,'#NULL#') = COALESCE(current_record.con_onsetdatetime::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementdatetime::text,'#NULL#') = COALESCE(current_record.con_abatementdatetime::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_value::text,'#NULL#') = COALESCE(current_record.con_abatementage_value::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_comparator::text,'#NULL#') = COALESCE(current_record.con_abatementage_comparator::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_unit::text,'#NULL#') = COALESCE(current_record.con_abatementage_unit::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_system::text,'#NULL#') = COALESCE(current_record.con_abatementage_system::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementage_code::text,'#NULL#') = COALESCE(current_record.con_abatementage_code::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementperiod_start::text,'#NULL#') = COALESCE(current_record.con_abatementperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementperiod_end::text,'#NULL#') = COALESCE(current_record.con_abatementperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_value::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_unit::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_system::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_low_code::text,'#NULL#') = COALESCE(current_record.con_abatementrange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_value::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_unit::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_system::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementrange_high_code::text,'#NULL#') = COALESCE(current_record.con_abatementrange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.con_abatementstring::text,'#NULL#') = COALESCE(current_record.con_abatementstring::text,'#NULL#') AND
                      COALESCE(target_record.con_recordeddate::text,'#NULL#') = COALESCE(current_record.con_recordeddate::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_id::text,'#NULL#') = COALESCE(current_record.con_recorder_id::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_type::text,'#NULL#') = COALESCE(current_record.con_recorder_type::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_use::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_recorder_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_recorder_display::text,'#NULL#') = COALESCE(current_record.con_recorder_display::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_id::text,'#NULL#') = COALESCE(current_record.con_asserter_id::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_type::text,'#NULL#') = COALESCE(current_record.con_asserter_type::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_use::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_asserter_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_asserter_display::text,'#NULL#') = COALESCE(current_record.con_asserter_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_system::text,'#NULL#') = COALESCE(current_record.con_stage_summary_system::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_version::text,'#NULL#') = COALESCE(current_record.con_stage_summary_version::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_code::text,'#NULL#') = COALESCE(current_record.con_stage_summary_code::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_display::text,'#NULL#') = COALESCE(current_record.con_stage_summary_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_summary_text::text,'#NULL#') = COALESCE(current_record.con_stage_summary_text::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_id::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_id::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_type::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_type::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_use::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_assessment_display::text,'#NULL#') = COALESCE(current_record.con_stage_assessment_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_system::text,'#NULL#') = COALESCE(current_record.con_stage_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_version::text,'#NULL#') = COALESCE(current_record.con_stage_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_code::text,'#NULL#') = COALESCE(current_record.con_stage_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_display::text,'#NULL#') = COALESCE(current_record.con_stage_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_stage_type_text::text,'#NULL#') = COALESCE(current_record.con_stage_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorstring::text,'#NULL#') = COALESCE(current_record.con_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.con_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.con_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.con_note_time::text,'#NULL#') = COALESCE(current_record.con_note_time::text,'#NULL#') AND
                      COALESCE(target_record.con_note_text::text,'#NULL#') = COALESCE(current_record.con_note_text::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.condition_raw WHERE condition_id = current_record.condition_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.condition_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE condition_id = current_record.condition_id;
            END;
    END LOOP;
    -- END condition
    -- Start medication
    FOR current_record IN (SELECT * FROM cds2db_in.medication_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.medication_raw target_record
                WHERE COALESCE(target_record.med_id::text,'#NULL#') = COALESCE(current_record.med_id::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_use::text,'#NULL#') = COALESCE(current_record.med_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_system::text,'#NULL#') = COALESCE(current_record.med_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_version::text,'#NULL#') = COALESCE(current_record.med_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_code::text,'#NULL#') = COALESCE(current_record.med_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_display::text,'#NULL#') = COALESCE(current_record.med_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_text::text,'#NULL#') = COALESCE(current_record.med_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_system::text,'#NULL#') = COALESCE(current_record.med_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_value::text,'#NULL#') = COALESCE(current_record.med_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_start::text,'#NULL#') = COALESCE(current_record.med_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_end::text,'#NULL#') = COALESCE(current_record.med_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.med_code_system::text,'#NULL#') = COALESCE(current_record.med_code_system::text,'#NULL#') AND
                      COALESCE(target_record.med_code_version::text,'#NULL#') = COALESCE(current_record.med_code_version::text,'#NULL#') AND
                      COALESCE(target_record.med_code_code::text,'#NULL#') = COALESCE(current_record.med_code_code::text,'#NULL#') AND
                      COALESCE(target_record.med_code_display::text,'#NULL#') = COALESCE(current_record.med_code_display::text,'#NULL#') AND
                      COALESCE(target_record.med_code_text::text,'#NULL#') = COALESCE(current_record.med_code_text::text,'#NULL#') AND
                      COALESCE(target_record.med_status::text,'#NULL#') = COALESCE(current_record.med_status::text,'#NULL#') AND
                      COALESCE(target_record.med_form_system::text,'#NULL#') = COALESCE(current_record.med_form_system::text,'#NULL#') AND
                      COALESCE(target_record.med_form_version::text,'#NULL#') = COALESCE(current_record.med_form_version::text,'#NULL#') AND
                      COALESCE(target_record.med_form_code::text,'#NULL#') = COALESCE(current_record.med_form_code::text,'#NULL#') AND
                      COALESCE(target_record.med_form_display::text,'#NULL#') = COALESCE(current_record.med_form_display::text,'#NULL#') AND
                      COALESCE(target_record.med_form_text::text,'#NULL#') = COALESCE(current_record.med_form_text::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_value::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_comparator::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_unit::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_system::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_code::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_value::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_comparator::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_unit::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_system::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_code::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_value::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_comparator::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_unit::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_value::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_comparator::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_unit::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_id::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_id::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_type::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_type::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_use::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_display::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_display::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_isactive::text,'#NULL#') = COALESCE(current_record.med_ingredient_isactive::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.medication_raw (
                        med_id,
                        med_identifier_use,
                        med_identifier_type_system,
                        med_identifier_type_version,
                        med_identifier_type_code,
                        med_identifier_type_display,
                        med_identifier_type_text,
                        med_identifier_system,
                        med_identifier_value,
                        med_identifier_start,
                        med_identifier_end,
                        med_code_system,
                        med_code_version,
                        med_code_code,
                        med_code_display,
                        med_code_text,
                        med_status,
                        med_form_system,
                        med_form_version,
                        med_form_code,
                        med_form_display,
                        med_form_text,
                        med_amount_numerator_value,
                        med_amount_numerator_comparator,
                        med_amount_numerator_unit,
                        med_amount_numerator_system,
                        med_amount_numerator_code,
                        med_amount_denominator_value,
                        med_amount_denominator_comparator,
                        med_amount_denominator_unit,
                        med_amount_denominator_system,
                        med_amount_denominator_code,
                        med_ingredient_strength_numerator_value,
                        med_ingredient_strength_numerator_comparator,
                        med_ingredient_strength_numerator_unit,
                        med_ingredient_strength_numerator_system,
                        med_ingredient_strength_numerator_code,
                        med_ingredient_strength_denominator_value,
                        med_ingredient_strength_denominator_comparator,
                        med_ingredient_strength_denominator_unit,
                        med_ingredient_strength_denominator_system,
                        med_ingredient_strength_denominator_code,
                        med_ingredient_itemcodeableconcept_system,
                        med_ingredient_itemcodeableconcept_version,
                        med_ingredient_itemcodeableconcept_code,
                        med_ingredient_itemcodeableconcept_display,
                        med_ingredient_itemcodeableconcept_text,
                        med_ingredient_itemreference_id,
                        med_ingredient_itemreference_type,
                        med_ingredient_itemreference_identifier_use,
                        med_ingredient_itemreference_identifier_type_system,
                        med_ingredient_itemreference_identifier_type_version,
                        med_ingredient_itemreference_identifier_type_code,
                        med_ingredient_itemreference_identifier_type_display,
                        med_ingredient_itemreference_identifier_type_text,
                        med_ingredient_itemreference_display,
                        med_ingredient_isactive,
                        input_datetime
                    )
                    VALUES (
                        current_record.med_id,
                        current_record.med_identifier_use,
                        current_record.med_identifier_type_system,
                        current_record.med_identifier_type_version,
                        current_record.med_identifier_type_code,
                        current_record.med_identifier_type_display,
                        current_record.med_identifier_type_text,
                        current_record.med_identifier_system,
                        current_record.med_identifier_value,
                        current_record.med_identifier_start,
                        current_record.med_identifier_end,
                        current_record.med_code_system,
                        current_record.med_code_version,
                        current_record.med_code_code,
                        current_record.med_code_display,
                        current_record.med_code_text,
                        current_record.med_status,
                        current_record.med_form_system,
                        current_record.med_form_version,
                        current_record.med_form_code,
                        current_record.med_form_display,
                        current_record.med_form_text,
                        current_record.med_amount_numerator_value,
                        current_record.med_amount_numerator_comparator,
                        current_record.med_amount_numerator_unit,
                        current_record.med_amount_numerator_system,
                        current_record.med_amount_numerator_code,
                        current_record.med_amount_denominator_value,
                        current_record.med_amount_denominator_comparator,
                        current_record.med_amount_denominator_unit,
                        current_record.med_amount_denominator_system,
                        current_record.med_amount_denominator_code,
                        current_record.med_ingredient_strength_numerator_value,
                        current_record.med_ingredient_strength_numerator_comparator,
                        current_record.med_ingredient_strength_numerator_unit,
                        current_record.med_ingredient_strength_numerator_system,
                        current_record.med_ingredient_strength_numerator_code,
                        current_record.med_ingredient_strength_denominator_value,
                        current_record.med_ingredient_strength_denominator_comparator,
                        current_record.med_ingredient_strength_denominator_unit,
                        current_record.med_ingredient_strength_denominator_system,
                        current_record.med_ingredient_strength_denominator_code,
                        current_record.med_ingredient_itemcodeableconcept_system,
                        current_record.med_ingredient_itemcodeableconcept_version,
                        current_record.med_ingredient_itemcodeableconcept_code,
                        current_record.med_ingredient_itemcodeableconcept_display,
                        current_record.med_ingredient_itemcodeableconcept_text,
                        current_record.med_ingredient_itemreference_id,
                        current_record.med_ingredient_itemreference_type,
                        current_record.med_ingredient_itemreference_identifier_use,
                        current_record.med_ingredient_itemreference_identifier_type_system,
                        current_record.med_ingredient_itemreference_identifier_type_version,
                        current_record.med_ingredient_itemreference_identifier_type_code,
                        current_record.med_ingredient_itemreference_identifier_type_display,
                        current_record.med_ingredient_itemreference_identifier_type_text,
                        current_record.med_ingredient_itemreference_display,
                        current_record.med_ingredient_isactive,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.medication_raw WHERE medication_id = current_record.medication_id;
                ELSE
                UPDATE db_log.medication_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.med_id::text,'#NULL#') = COALESCE(current_record.med_id::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_use::text,'#NULL#') = COALESCE(current_record.med_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_system::text,'#NULL#') = COALESCE(current_record.med_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_version::text,'#NULL#') = COALESCE(current_record.med_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_code::text,'#NULL#') = COALESCE(current_record.med_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_display::text,'#NULL#') = COALESCE(current_record.med_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_type_text::text,'#NULL#') = COALESCE(current_record.med_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_system::text,'#NULL#') = COALESCE(current_record.med_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_value::text,'#NULL#') = COALESCE(current_record.med_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_start::text,'#NULL#') = COALESCE(current_record.med_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.med_identifier_end::text,'#NULL#') = COALESCE(current_record.med_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.med_code_system::text,'#NULL#') = COALESCE(current_record.med_code_system::text,'#NULL#') AND
                      COALESCE(target_record.med_code_version::text,'#NULL#') = COALESCE(current_record.med_code_version::text,'#NULL#') AND
                      COALESCE(target_record.med_code_code::text,'#NULL#') = COALESCE(current_record.med_code_code::text,'#NULL#') AND
                      COALESCE(target_record.med_code_display::text,'#NULL#') = COALESCE(current_record.med_code_display::text,'#NULL#') AND
                      COALESCE(target_record.med_code_text::text,'#NULL#') = COALESCE(current_record.med_code_text::text,'#NULL#') AND
                      COALESCE(target_record.med_status::text,'#NULL#') = COALESCE(current_record.med_status::text,'#NULL#') AND
                      COALESCE(target_record.med_form_system::text,'#NULL#') = COALESCE(current_record.med_form_system::text,'#NULL#') AND
                      COALESCE(target_record.med_form_version::text,'#NULL#') = COALESCE(current_record.med_form_version::text,'#NULL#') AND
                      COALESCE(target_record.med_form_code::text,'#NULL#') = COALESCE(current_record.med_form_code::text,'#NULL#') AND
                      COALESCE(target_record.med_form_display::text,'#NULL#') = COALESCE(current_record.med_form_display::text,'#NULL#') AND
                      COALESCE(target_record.med_form_text::text,'#NULL#') = COALESCE(current_record.med_form_text::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_value::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_comparator::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_unit::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_system::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_numerator_code::text,'#NULL#') = COALESCE(current_record.med_amount_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_value::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_comparator::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_unit::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_system::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_amount_denominator_code::text,'#NULL#') = COALESCE(current_record.med_amount_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_value::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_comparator::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_unit::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_numerator_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_value::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_comparator::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_unit::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_strength_denominator_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_strength_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_id::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_id::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_type::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_type::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_use::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_itemreference_display::text,'#NULL#') = COALESCE(current_record.med_ingredient_itemreference_display::text,'#NULL#') AND
                      COALESCE(target_record.med_ingredient_isactive::text,'#NULL#') = COALESCE(current_record.med_ingredient_isactive::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.medication_raw WHERE medication_id = current_record.medication_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.medication_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE medication_id = current_record.medication_id;
            END;
    END LOOP;
    -- END medication
    -- Start medicationrequest
    FOR current_record IN (SELECT * FROM cds2db_in.medicationrequest_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.medicationrequest_raw target_record
                WHERE COALESCE(target_record.medreq_id::text,'#NULL#') = COALESCE(current_record.medreq_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_encounter_id::text,'#NULL#') = COALESCE(current_record.medreq_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_patient_id::text,'#NULL#') = COALESCE(current_record.medreq_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_system::text,'#NULL#') = COALESCE(current_record.medreq_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_value::text,'#NULL#') = COALESCE(current_record.medreq_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_start::text,'#NULL#') = COALESCE(current_record.medreq_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_end::text,'#NULL#') = COALESCE(current_record.medreq_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationreference_id::text,'#NULL#') = COALESCE(current_record.medreq_medicationreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_status::text,'#NULL#') = COALESCE(current_record.medreq_status::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_system::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_version::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_code::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_display::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_text::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_intend::text,'#NULL#') = COALESCE(current_record.medreq_intend::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_system::text,'#NULL#') = COALESCE(current_record.medreq_category_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_version::text,'#NULL#') = COALESCE(current_record.medreq_category_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_code::text,'#NULL#') = COALESCE(current_record.medreq_category_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_display::text,'#NULL#') = COALESCE(current_record.medreq_category_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_text::text,'#NULL#') = COALESCE(current_record.medreq_category_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_priority::text,'#NULL#') = COALESCE(current_record.medreq_priority::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedboolean::text,'#NULL#') = COALESCE(current_record.medreq_reportedboolean::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_id::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_type::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_display::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_id::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_type::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_display::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_authoredon::text,'#NULL#') = COALESCE(current_record.medreq_authoredon::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_id::text,'#NULL#') = COALESCE(current_record.medreq_requester_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_type::text,'#NULL#') = COALESCE(current_record.medreq_requester_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_display::text,'#NULL#') = COALESCE(current_record.medreq_requester_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_system::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_version::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_code::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_display::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_text::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_id::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_type::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_display::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_id::text,'#NULL#') = COALESCE(current_record.medreq_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_type::text,'#NULL#') = COALESCE(current_record.medreq_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_display::text,'#NULL#') = COALESCE(current_record.medreq_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorstring::text,'#NULL#') = COALESCE(current_record.medreq_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_time::text,'#NULL#') = COALESCE(current_record.medreq_note_time::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_text::text,'#NULL#') = COALESCE(current_record.medreq_note_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_sequence::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_sequence::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_patientinstruction::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_patientinstruction::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_event::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_event::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsperiod_start::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsperiod_end::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_count::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_count::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_countmax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_countmax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_duration::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_duration::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_durationmax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_durationmax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_durationunit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_durationunit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_frequency::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_frequency::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_frequencymax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_frequencymax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_period::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_period::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_periodmax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_periodmax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_periodunit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_periodunit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_dayofweek::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_dayofweek::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_timeofday::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_timeofday::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_when::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_when::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_offset::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_offset::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededboolean::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededboolean::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_system::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_version::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_code::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_display::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_text::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_text::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.medicationrequest_raw (
                        medreq_id,
                        medreq_encounter_id,
                        medreq_patient_id,
                        medreq_identifier_use,
                        medreq_identifier_type_system,
                        medreq_identifier_type_version,
                        medreq_identifier_type_code,
                        medreq_identifier_type_display,
                        medreq_identifier_type_text,
                        medreq_identifier_system,
                        medreq_identifier_value,
                        medreq_identifier_start,
                        medreq_identifier_end,
                        medreq_medicationreference_id,
                        medreq_status,
                        medreq_statusreason_system,
                        medreq_statusreason_version,
                        medreq_statusreason_code,
                        medreq_statusreason_display,
                        medreq_statusreason_text,
                        medreq_intend,
                        medreq_category_system,
                        medreq_category_version,
                        medreq_category_code,
                        medreq_category_display,
                        medreq_category_text,
                        medreq_priority,
                        medreq_reportedboolean,
                        medreq_reportedreference_id,
                        medreq_reportedreference_type,
                        medreq_reportedreference_identifier_use,
                        medreq_reportedreference_identifier_type_system,
                        medreq_reportedreference_identifier_type_version,
                        medreq_reportedreference_identifier_type_code,
                        medreq_reportedreference_identifier_type_display,
                        medreq_reportedreference_identifier_type_text,
                        medreq_reportedreference_display,
                        medreq_medicationcodeableconcept_system,
                        medreq_medicationcodeableconcept_version,
                        medreq_medicationcodeableconcept_code,
                        medreq_medicationcodeableconcept_display,
                        medreq_medicationcodeableconcept_text,
                        medreq_supportinginformation_id,
                        medreq_supportinginformation_type,
                        medreq_supportinginformation_identifier_use,
                        medreq_supportinginformation_identifier_type_system,
                        medreq_supportinginformation_identifier_type_version,
                        medreq_supportinginformation_identifier_type_code,
                        medreq_supportinginformation_identifier_type_display,
                        medreq_supportinginformation_identifier_type_text,
                        medreq_supportinginformation_display,
                        medreq_authoredon,
                        medreq_requester_id,
                        medreq_requester_type,
                        medreq_requester_identifier_use,
                        medreq_requester_identifier_type_system,
                        medreq_requester_identifier_type_version,
                        medreq_requester_identifier_type_code,
                        medreq_requester_identifier_type_display,
                        medreq_requester_identifier_type_text,
                        medreq_requester_display,
                        medreq_reasoncode_system,
                        medreq_reasoncode_version,
                        medreq_reasoncode_code,
                        medreq_reasoncode_display,
                        medreq_reasoncode_text,
                        medreq_reasonreference_id,
                        medreq_reasonreference_type,
                        medreq_reasonreference_identifier_use,
                        medreq_reasonreference_identifier_type_system,
                        medreq_reasonreference_identifier_type_version,
                        medreq_reasonreference_identifier_type_code,
                        medreq_reasonreference_identifier_type_display,
                        medreq_reasonreference_identifier_type_text,
                        medreq_reasonreference_display,
                        medreq_basedon_id,
                        medreq_basedon_type,
                        medreq_basedon_identifier_use,
                        medreq_basedon_identifier_type_system,
                        medreq_basedon_identifier_type_version,
                        medreq_basedon_identifier_type_code,
                        medreq_basedon_identifier_type_display,
                        medreq_basedon_identifier_type_text,
                        medreq_basedon_display,
                        medreq_note_authorstring,
                        medreq_note_authorreference_id,
                        medreq_note_authorreference_type,
                        medreq_note_authorreference_identifier_use,
                        medreq_note_authorreference_identifier_type_system,
                        medreq_note_authorreference_identifier_type_version,
                        medreq_note_authorreference_identifier_type_code,
                        medreq_note_authorreference_identifier_type_display,
                        medreq_note_authorreference_identifier_type_text,
                        medreq_note_authorreference_display,
                        medreq_note_time,
                        medreq_note_text,
                        medreq_doseinstruc_sequence,
                        medreq_doseinstruc_text,
                        medreq_doseinstruc_additionalinstruction_system,
                        medreq_doseinstruc_additionalinstruction_version,
                        medreq_doseinstruc_additionalinstruction_code,
                        medreq_doseinstruc_additionalinstruction_display,
                        medreq_doseinstruc_additionalinstruction_text,
                        medreq_doseinstruc_patientinstruction,
                        medreq_doseinstruc_timing_event,
                        medreq_doseinstruc_timing_repeat_boundsduration_value,
                        medreq_doseinstruc_timing_repeat_boundsduration_comparator,
                        medreq_doseinstruc_timing_repeat_boundsduration_unit,
                        medreq_doseinstruc_timing_repeat_boundsduration_system,
                        medreq_doseinstruc_timing_repeat_boundsduration_code,
                        medreq_doseinstruc_timing_repeat_boundsrange_low_value,
                        medreq_doseinstruc_timing_repeat_boundsrange_low_unit,
                        medreq_doseinstruc_timing_repeat_boundsrange_low_system,
                        medreq_doseinstruc_timing_repeat_boundsrange_low_code,
                        medreq_doseinstruc_timing_repeat_boundsrange_high_value,
                        medreq_doseinstruc_timing_repeat_boundsrange_high_unit,
                        medreq_doseinstruc_timing_repeat_boundsrange_high_system,
                        medreq_doseinstruc_timing_repeat_boundsrange_high_code,
                        medreq_doseinstruc_timing_repeat_boundsperiod_start,
                        medreq_doseinstruc_timing_repeat_boundsperiod_end,
                        medreq_doseinstruc_timing_repeat_count,
                        medreq_doseinstruc_timing_repeat_countmax,
                        medreq_doseinstruc_timing_repeat_duration,
                        medreq_doseinstruc_timing_repeat_durationmax,
                        medreq_doseinstruc_timing_repeat_durationunit,
                        medreq_doseinstruc_timing_repeat_frequency,
                        medreq_doseinstruc_timing_repeat_frequencymax,
                        medreq_doseinstruc_timing_repeat_period,
                        medreq_doseinstruc_timing_repeat_periodmax,
                        medreq_doseinstruc_timing_repeat_periodunit,
                        medreq_doseinstruc_timing_repeat_dayofweek,
                        medreq_doseinstruc_timing_repeat_timeofday,
                        medreq_doseinstruc_timing_repeat_when,
                        medreq_doseinstruc_timing_repeat_offset,
                        medreq_doseinstruc_timing_code_system,
                        medreq_doseinstruc_timing_code_version,
                        medreq_doseinstruc_timing_code_code,
                        medreq_doseinstruc_timing_code_display,
                        medreq_doseinstruc_timing_code_text,
                        medreq_doseinstruc_asneededboolean,
                        medreq_doseinstruc_asneededcodeableconcept_system,
                        medreq_doseinstruc_asneededcodeableconcept_version,
                        medreq_doseinstruc_asneededcodeableconcept_code,
                        medreq_doseinstruc_asneededcodeableconcept_display,
                        medreq_doseinstruc_asneededcodeableconcept_text,
                        medreq_doseinstruc_site_system,
                        medreq_doseinstruc_site_version,
                        medreq_doseinstruc_site_code,
                        medreq_doseinstruc_site_display,
                        medreq_doseinstruc_site_text,
                        medreq_doseinstruc_route_system,
                        medreq_doseinstruc_route_version,
                        medreq_doseinstruc_route_code,
                        medreq_doseinstruc_route_display,
                        medreq_doseinstruc_route_text,
                        medreq_doseinstruc_method_system,
                        medreq_doseinstruc_method_version,
                        medreq_doseinstruc_method_code,
                        medreq_doseinstruc_method_display,
                        medreq_doseinstruc_method_text,
                        medreq_doseinstruc_doseandrate_type_system,
                        medreq_doseinstruc_doseandrate_type_version,
                        medreq_doseinstruc_doseandrate_type_code,
                        medreq_doseinstruc_doseandrate_type_display,
                        medreq_doseinstruc_doseandrate_type_text,
                        medreq_doseinstruc_doseandrate_doserange_low_value,
                        medreq_doseinstruc_doseandrate_doserange_low_unit,
                        medreq_doseinstruc_doseandrate_doserange_low_system,
                        medreq_doseinstruc_doseandrate_doserange_low_code,
                        medreq_doseinstruc_doseandrate_doserange_high_value,
                        medreq_doseinstruc_doseandrate_doserange_high_unit,
                        medreq_doseinstruc_doseandrate_doserange_high_system,
                        medreq_doseinstruc_doseandrate_doserange_high_code,
                        medreq_doseinstruc_doseandrate_dosequantity_value,
                        medreq_doseinstruc_doseandrate_dosequantity_comparator,
                        medreq_doseinstruc_doseandrate_dosequantity_unit,
                        medreq_doseinstruc_doseandrate_dosequantity_system,
                        medreq_doseinstruc_doseandrate_dosequantity_code,
                        medreq_doseinstruc_doseandrate_rateratio_numerator_value,
                        medreq_doseinstruc_doseandrate_rateratio_numerator_comparator,
                        medreq_doseinstruc_doseandrate_rateratio_numerator_unit,
                        medreq_doseinstruc_doseandrate_rateratio_numerator_system,
                        medreq_doseinstruc_doseandrate_rateratio_numerator_code,
                        medreq_doseinstruc_doseandrate_rateratio_denominator_value,
                        medreq_doseinstruc_doseandrate_rateratio_denominator_comparator,
                        medreq_doseinstruc_doseandrate_rateratio_denominator_unit,
                        medreq_doseinstruc_doseandrate_rateratio_denominator_system,
                        medreq_doseinstruc_doseandrate_rateratio_denominator_code,
                        medreq_doseinstruc_doseandrate_raterange_low_value,
                        medreq_doseinstruc_doseandrate_raterange_low_unit,
                        medreq_doseinstruc_doseandrate_raterange_low_system,
                        medreq_doseinstruc_doseandrate_raterange_low_code,
                        medreq_doseinstruc_doseandrate_raterange_high_value,
                        medreq_doseinstruc_doseandrate_raterange_high_unit,
                        medreq_doseinstruc_doseandrate_raterange_high_system,
                        medreq_doseinstruc_doseandrate_raterange_high_code,
                        medreq_doseinstruc_doseandrate_ratequantity_value,
                        medreq_doseinstruc_doseandrate_ratequantity_unit,
                        medreq_doseinstruc_doseandrate_ratequantity_system,
                        medreq_doseinstruc_doseandrate_ratequantity_code,
                        medreq_doseinstruc_maxdoseperperiod_numerator_value,
                        medreq_doseinstruc_maxdoseperperiod_numerator_comparator,
                        medreq_doseinstruc_maxdoseperperiod_numerator_unit,
                        medreq_doseinstruc_maxdoseperperiod_numerator_system,
                        medreq_doseinstruc_maxdoseperperiod_numerator_code,
                        medreq_doseinstruc_maxdoseperperiod_denominator_value,
                        medreq_doseinstruc_maxdoseperperiod_denominator_comparator,
                        medreq_doseinstruc_maxdoseperperiod_denominator_unit,
                        medreq_doseinstruc_maxdoseperperiod_denominator_system,
                        medreq_doseinstruc_maxdoseperperiod_denominator_code,
                        medreq_doseinstruc_maxdoseperadministration_value,
                        medreq_doseinstruc_maxdoseperadministration_unit,
                        medreq_doseinstruc_maxdoseperadministration_system,
                        medreq_doseinstruc_maxdoseperadministration_code,
                        medreq_doseinstruc_maxdoseperlifetime_value,
                        medreq_doseinstruc_maxdoseperlifetime_unit,
                        medreq_doseinstruc_maxdoseperlifetime_system,
                        medreq_doseinstruc_maxdoseperlifetime_code,
                        medreq_substitution_reason_system,
                        medreq_substitution_reason_version,
                        medreq_substitution_reason_code,
                        medreq_substitution_reason_display,
                        medreq_substitution_reason_text,
                        input_datetime
                    )
                    VALUES (
                        current_record.medreq_id,
                        current_record.medreq_encounter_id,
                        current_record.medreq_patient_id,
                        current_record.medreq_identifier_use,
                        current_record.medreq_identifier_type_system,
                        current_record.medreq_identifier_type_version,
                        current_record.medreq_identifier_type_code,
                        current_record.medreq_identifier_type_display,
                        current_record.medreq_identifier_type_text,
                        current_record.medreq_identifier_system,
                        current_record.medreq_identifier_value,
                        current_record.medreq_identifier_start,
                        current_record.medreq_identifier_end,
                        current_record.medreq_medicationreference_id,
                        current_record.medreq_status,
                        current_record.medreq_statusreason_system,
                        current_record.medreq_statusreason_version,
                        current_record.medreq_statusreason_code,
                        current_record.medreq_statusreason_display,
                        current_record.medreq_statusreason_text,
                        current_record.medreq_intend,
                        current_record.medreq_category_system,
                        current_record.medreq_category_version,
                        current_record.medreq_category_code,
                        current_record.medreq_category_display,
                        current_record.medreq_category_text,
                        current_record.medreq_priority,
                        current_record.medreq_reportedboolean,
                        current_record.medreq_reportedreference_id,
                        current_record.medreq_reportedreference_type,
                        current_record.medreq_reportedreference_identifier_use,
                        current_record.medreq_reportedreference_identifier_type_system,
                        current_record.medreq_reportedreference_identifier_type_version,
                        current_record.medreq_reportedreference_identifier_type_code,
                        current_record.medreq_reportedreference_identifier_type_display,
                        current_record.medreq_reportedreference_identifier_type_text,
                        current_record.medreq_reportedreference_display,
                        current_record.medreq_medicationcodeableconcept_system,
                        current_record.medreq_medicationcodeableconcept_version,
                        current_record.medreq_medicationcodeableconcept_code,
                        current_record.medreq_medicationcodeableconcept_display,
                        current_record.medreq_medicationcodeableconcept_text,
                        current_record.medreq_supportinginformation_id,
                        current_record.medreq_supportinginformation_type,
                        current_record.medreq_supportinginformation_identifier_use,
                        current_record.medreq_supportinginformation_identifier_type_system,
                        current_record.medreq_supportinginformation_identifier_type_version,
                        current_record.medreq_supportinginformation_identifier_type_code,
                        current_record.medreq_supportinginformation_identifier_type_display,
                        current_record.medreq_supportinginformation_identifier_type_text,
                        current_record.medreq_supportinginformation_display,
                        current_record.medreq_authoredon,
                        current_record.medreq_requester_id,
                        current_record.medreq_requester_type,
                        current_record.medreq_requester_identifier_use,
                        current_record.medreq_requester_identifier_type_system,
                        current_record.medreq_requester_identifier_type_version,
                        current_record.medreq_requester_identifier_type_code,
                        current_record.medreq_requester_identifier_type_display,
                        current_record.medreq_requester_identifier_type_text,
                        current_record.medreq_requester_display,
                        current_record.medreq_reasoncode_system,
                        current_record.medreq_reasoncode_version,
                        current_record.medreq_reasoncode_code,
                        current_record.medreq_reasoncode_display,
                        current_record.medreq_reasoncode_text,
                        current_record.medreq_reasonreference_id,
                        current_record.medreq_reasonreference_type,
                        current_record.medreq_reasonreference_identifier_use,
                        current_record.medreq_reasonreference_identifier_type_system,
                        current_record.medreq_reasonreference_identifier_type_version,
                        current_record.medreq_reasonreference_identifier_type_code,
                        current_record.medreq_reasonreference_identifier_type_display,
                        current_record.medreq_reasonreference_identifier_type_text,
                        current_record.medreq_reasonreference_display,
                        current_record.medreq_basedon_id,
                        current_record.medreq_basedon_type,
                        current_record.medreq_basedon_identifier_use,
                        current_record.medreq_basedon_identifier_type_system,
                        current_record.medreq_basedon_identifier_type_version,
                        current_record.medreq_basedon_identifier_type_code,
                        current_record.medreq_basedon_identifier_type_display,
                        current_record.medreq_basedon_identifier_type_text,
                        current_record.medreq_basedon_display,
                        current_record.medreq_note_authorstring,
                        current_record.medreq_note_authorreference_id,
                        current_record.medreq_note_authorreference_type,
                        current_record.medreq_note_authorreference_identifier_use,
                        current_record.medreq_note_authorreference_identifier_type_system,
                        current_record.medreq_note_authorreference_identifier_type_version,
                        current_record.medreq_note_authorreference_identifier_type_code,
                        current_record.medreq_note_authorreference_identifier_type_display,
                        current_record.medreq_note_authorreference_identifier_type_text,
                        current_record.medreq_note_authorreference_display,
                        current_record.medreq_note_time,
                        current_record.medreq_note_text,
                        current_record.medreq_doseinstruc_sequence,
                        current_record.medreq_doseinstruc_text,
                        current_record.medreq_doseinstruc_additionalinstruction_system,
                        current_record.medreq_doseinstruc_additionalinstruction_version,
                        current_record.medreq_doseinstruc_additionalinstruction_code,
                        current_record.medreq_doseinstruc_additionalinstruction_display,
                        current_record.medreq_doseinstruc_additionalinstruction_text,
                        current_record.medreq_doseinstruc_patientinstruction,
                        current_record.medreq_doseinstruc_timing_event,
                        current_record.medreq_doseinstruc_timing_repeat_boundsduration_value,
                        current_record.medreq_doseinstruc_timing_repeat_boundsduration_comparator,
                        current_record.medreq_doseinstruc_timing_repeat_boundsduration_unit,
                        current_record.medreq_doseinstruc_timing_repeat_boundsduration_system,
                        current_record.medreq_doseinstruc_timing_repeat_boundsduration_code,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_value,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_unit,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_system,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_code,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_value,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_unit,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_system,
                        current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_code,
                        current_record.medreq_doseinstruc_timing_repeat_boundsperiod_start,
                        current_record.medreq_doseinstruc_timing_repeat_boundsperiod_end,
                        current_record.medreq_doseinstruc_timing_repeat_count,
                        current_record.medreq_doseinstruc_timing_repeat_countmax,
                        current_record.medreq_doseinstruc_timing_repeat_duration,
                        current_record.medreq_doseinstruc_timing_repeat_durationmax,
                        current_record.medreq_doseinstruc_timing_repeat_durationunit,
                        current_record.medreq_doseinstruc_timing_repeat_frequency,
                        current_record.medreq_doseinstruc_timing_repeat_frequencymax,
                        current_record.medreq_doseinstruc_timing_repeat_period,
                        current_record.medreq_doseinstruc_timing_repeat_periodmax,
                        current_record.medreq_doseinstruc_timing_repeat_periodunit,
                        current_record.medreq_doseinstruc_timing_repeat_dayofweek,
                        current_record.medreq_doseinstruc_timing_repeat_timeofday,
                        current_record.medreq_doseinstruc_timing_repeat_when,
                        current_record.medreq_doseinstruc_timing_repeat_offset,
                        current_record.medreq_doseinstruc_timing_code_system,
                        current_record.medreq_doseinstruc_timing_code_version,
                        current_record.medreq_doseinstruc_timing_code_code,
                        current_record.medreq_doseinstruc_timing_code_display,
                        current_record.medreq_doseinstruc_timing_code_text,
                        current_record.medreq_doseinstruc_asneededboolean,
                        current_record.medreq_doseinstruc_asneededcodeableconcept_system,
                        current_record.medreq_doseinstruc_asneededcodeableconcept_version,
                        current_record.medreq_doseinstruc_asneededcodeableconcept_code,
                        current_record.medreq_doseinstruc_asneededcodeableconcept_display,
                        current_record.medreq_doseinstruc_asneededcodeableconcept_text,
                        current_record.medreq_doseinstruc_site_system,
                        current_record.medreq_doseinstruc_site_version,
                        current_record.medreq_doseinstruc_site_code,
                        current_record.medreq_doseinstruc_site_display,
                        current_record.medreq_doseinstruc_site_text,
                        current_record.medreq_doseinstruc_route_system,
                        current_record.medreq_doseinstruc_route_version,
                        current_record.medreq_doseinstruc_route_code,
                        current_record.medreq_doseinstruc_route_display,
                        current_record.medreq_doseinstruc_route_text,
                        current_record.medreq_doseinstruc_method_system,
                        current_record.medreq_doseinstruc_method_version,
                        current_record.medreq_doseinstruc_method_code,
                        current_record.medreq_doseinstruc_method_display,
                        current_record.medreq_doseinstruc_method_text,
                        current_record.medreq_doseinstruc_doseandrate_type_system,
                        current_record.medreq_doseinstruc_doseandrate_type_version,
                        current_record.medreq_doseinstruc_doseandrate_type_code,
                        current_record.medreq_doseinstruc_doseandrate_type_display,
                        current_record.medreq_doseinstruc_doseandrate_type_text,
                        current_record.medreq_doseinstruc_doseandrate_doserange_low_value,
                        current_record.medreq_doseinstruc_doseandrate_doserange_low_unit,
                        current_record.medreq_doseinstruc_doseandrate_doserange_low_system,
                        current_record.medreq_doseinstruc_doseandrate_doserange_low_code,
                        current_record.medreq_doseinstruc_doseandrate_doserange_high_value,
                        current_record.medreq_doseinstruc_doseandrate_doserange_high_unit,
                        current_record.medreq_doseinstruc_doseandrate_doserange_high_system,
                        current_record.medreq_doseinstruc_doseandrate_doserange_high_code,
                        current_record.medreq_doseinstruc_doseandrate_dosequantity_value,
                        current_record.medreq_doseinstruc_doseandrate_dosequantity_comparator,
                        current_record.medreq_doseinstruc_doseandrate_dosequantity_unit,
                        current_record.medreq_doseinstruc_doseandrate_dosequantity_system,
                        current_record.medreq_doseinstruc_doseandrate_dosequantity_code,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_value,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_unit,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_system,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_code,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_value,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_unit,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_system,
                        current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_code,
                        current_record.medreq_doseinstruc_doseandrate_raterange_low_value,
                        current_record.medreq_doseinstruc_doseandrate_raterange_low_unit,
                        current_record.medreq_doseinstruc_doseandrate_raterange_low_system,
                        current_record.medreq_doseinstruc_doseandrate_raterange_low_code,
                        current_record.medreq_doseinstruc_doseandrate_raterange_high_value,
                        current_record.medreq_doseinstruc_doseandrate_raterange_high_unit,
                        current_record.medreq_doseinstruc_doseandrate_raterange_high_system,
                        current_record.medreq_doseinstruc_doseandrate_raterange_high_code,
                        current_record.medreq_doseinstruc_doseandrate_ratequantity_value,
                        current_record.medreq_doseinstruc_doseandrate_ratequantity_unit,
                        current_record.medreq_doseinstruc_doseandrate_ratequantity_system,
                        current_record.medreq_doseinstruc_doseandrate_ratequantity_code,
                        current_record.medreq_doseinstruc_maxdoseperperiod_numerator_value,
                        current_record.medreq_doseinstruc_maxdoseperperiod_numerator_comparator,
                        current_record.medreq_doseinstruc_maxdoseperperiod_numerator_unit,
                        current_record.medreq_doseinstruc_maxdoseperperiod_numerator_system,
                        current_record.medreq_doseinstruc_maxdoseperperiod_numerator_code,
                        current_record.medreq_doseinstruc_maxdoseperperiod_denominator_value,
                        current_record.medreq_doseinstruc_maxdoseperperiod_denominator_comparator,
                        current_record.medreq_doseinstruc_maxdoseperperiod_denominator_unit,
                        current_record.medreq_doseinstruc_maxdoseperperiod_denominator_system,
                        current_record.medreq_doseinstruc_maxdoseperperiod_denominator_code,
                        current_record.medreq_doseinstruc_maxdoseperadministration_value,
                        current_record.medreq_doseinstruc_maxdoseperadministration_unit,
                        current_record.medreq_doseinstruc_maxdoseperadministration_system,
                        current_record.medreq_doseinstruc_maxdoseperadministration_code,
                        current_record.medreq_doseinstruc_maxdoseperlifetime_value,
                        current_record.medreq_doseinstruc_maxdoseperlifetime_unit,
                        current_record.medreq_doseinstruc_maxdoseperlifetime_system,
                        current_record.medreq_doseinstruc_maxdoseperlifetime_code,
                        current_record.medreq_substitution_reason_system,
                        current_record.medreq_substitution_reason_version,
                        current_record.medreq_substitution_reason_code,
                        current_record.medreq_substitution_reason_display,
                        current_record.medreq_substitution_reason_text,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.medicationrequest_raw WHERE medicationrequest_id = current_record.medicationrequest_id;
                ELSE
                UPDATE db_log.medicationrequest_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.medreq_id::text,'#NULL#') = COALESCE(current_record.medreq_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_encounter_id::text,'#NULL#') = COALESCE(current_record.medreq_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_patient_id::text,'#NULL#') = COALESCE(current_record.medreq_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_system::text,'#NULL#') = COALESCE(current_record.medreq_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_value::text,'#NULL#') = COALESCE(current_record.medreq_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_start::text,'#NULL#') = COALESCE(current_record.medreq_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.medreq_identifier_end::text,'#NULL#') = COALESCE(current_record.medreq_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationreference_id::text,'#NULL#') = COALESCE(current_record.medreq_medicationreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_status::text,'#NULL#') = COALESCE(current_record.medreq_status::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_system::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_version::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_code::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_display::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_statusreason_text::text,'#NULL#') = COALESCE(current_record.medreq_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_intend::text,'#NULL#') = COALESCE(current_record.medreq_intend::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_system::text,'#NULL#') = COALESCE(current_record.medreq_category_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_version::text,'#NULL#') = COALESCE(current_record.medreq_category_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_code::text,'#NULL#') = COALESCE(current_record.medreq_category_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_display::text,'#NULL#') = COALESCE(current_record.medreq_category_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_category_text::text,'#NULL#') = COALESCE(current_record.medreq_category_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_priority::text,'#NULL#') = COALESCE(current_record.medreq_priority::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedboolean::text,'#NULL#') = COALESCE(current_record.medreq_reportedboolean::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_id::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_type::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reportedreference_display::text,'#NULL#') = COALESCE(current_record.medreq_reportedreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_medicationcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medreq_medicationcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_id::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_type::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_supportinginformation_display::text,'#NULL#') = COALESCE(current_record.medreq_supportinginformation_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_authoredon::text,'#NULL#') = COALESCE(current_record.medreq_authoredon::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_id::text,'#NULL#') = COALESCE(current_record.medreq_requester_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_type::text,'#NULL#') = COALESCE(current_record.medreq_requester_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_requester_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_requester_display::text,'#NULL#') = COALESCE(current_record.medreq_requester_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_system::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_version::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_code::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_display::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasoncode_text::text,'#NULL#') = COALESCE(current_record.medreq_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_id::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_type::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_reasonreference_display::text,'#NULL#') = COALESCE(current_record.medreq_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_id::text,'#NULL#') = COALESCE(current_record.medreq_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_type::text,'#NULL#') = COALESCE(current_record.medreq_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_basedon_display::text,'#NULL#') = COALESCE(current_record.medreq_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorstring::text,'#NULL#') = COALESCE(current_record.medreq_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.medreq_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_time::text,'#NULL#') = COALESCE(current_record.medreq_note_time::text,'#NULL#') AND
                      COALESCE(target_record.medreq_note_text::text,'#NULL#') = COALESCE(current_record.medreq_note_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_sequence::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_sequence::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_additionalinstruction_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_additionalinstruction_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_patientinstruction::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_patientinstruction::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_event::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_event::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsduration_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsduration_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_low_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsrange_high_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsperiod_start::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_boundsperiod_end::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_boundsperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_count::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_count::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_countmax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_countmax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_duration::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_duration::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_durationmax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_durationmax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_durationunit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_durationunit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_frequency::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_frequency::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_frequencymax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_frequencymax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_period::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_period::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_periodmax::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_periodmax::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_periodunit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_periodunit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_dayofweek::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_dayofweek::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_timeofday::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_timeofday::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_when::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_when::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_repeat_offset::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_repeat_offset::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_timing_code_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_timing_code_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededboolean::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededboolean::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_asneededcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_asneededcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_site_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_site_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_route_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_route_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_method_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_method_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_version::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_display::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_type_text::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_low_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_doserange_high_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_doserange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_dosequantity_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_dosequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_numerator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_rateratio_denominator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_low_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_raterange_high_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_raterange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_doseandrate_ratequantity_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_doseandrate_ratequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_numerator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperperiod_denominator_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperperiod_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperadministration_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperadministration_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_value::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_value::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_unit::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_unit::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_system::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_doseinstruc_maxdoseperlifetime_code::text,'#NULL#') = COALESCE(current_record.medreq_doseinstruc_maxdoseperlifetime_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_system::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_system::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_version::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_version::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_code::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_code::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_display::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_display::text,'#NULL#') AND
                      COALESCE(target_record.medreq_substitution_reason_text::text,'#NULL#') = COALESCE(current_record.medreq_substitution_reason_text::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.medicationrequest_raw WHERE medicationrequest_id = current_record.medicationrequest_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.medicationrequest_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE medicationrequest_id = current_record.medicationrequest_id;
            END;
    END LOOP;
    -- END medicationrequest
    -- Start medicationadministration
    FOR current_record IN (SELECT * FROM cds2db_in.medicationadministration_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.medicationadministration_raw target_record
                WHERE COALESCE(target_record.medadm_id::text,'#NULL#') = COALESCE(current_record.medadm_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_encounter_id::text,'#NULL#') = COALESCE(current_record.medadm_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_patient_id::text,'#NULL#') = COALESCE(current_record.medadm_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_partof_id::text,'#NULL#') = COALESCE(current_record.medadm_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_system::text,'#NULL#') = COALESCE(current_record.medadm_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_value::text,'#NULL#') = COALESCE(current_record.medadm_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_start::text,'#NULL#') = COALESCE(current_record.medadm_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_end::text,'#NULL#') = COALESCE(current_record.medadm_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.medadm_status::text,'#NULL#') = COALESCE(current_record.medadm_status::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_system::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_version::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_code::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_display::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_text::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_system::text,'#NULL#') = COALESCE(current_record.medadm_category_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_version::text,'#NULL#') = COALESCE(current_record.medadm_category_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_code::text,'#NULL#') = COALESCE(current_record.medadm_category_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_display::text,'#NULL#') = COALESCE(current_record.medadm_category_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_text::text,'#NULL#') = COALESCE(current_record.medadm_category_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationreference_id::text,'#NULL#') = COALESCE(current_record.medadm_medicationreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_id::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_type::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_type::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_display::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_effectivedatetime::text,'#NULL#') = COALESCE(current_record.medadm_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.medadm_effectiveperiod_start::text,'#NULL#') = COALESCE(current_record.medadm_effectiveperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medadm_effectiveperiod_end::text,'#NULL#') = COALESCE(current_record.medadm_effectiveperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_system::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_version::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_code::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_display::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_text::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_system::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_version::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_code::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_display::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_text::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_id::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_type::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_display::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_request_id::text,'#NULL#') = COALESCE(current_record.medadm_request_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorstring::text,'#NULL#') = COALESCE(current_record.medadm_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_time::text,'#NULL#') = COALESCE(current_record.medadm_note_time::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_text::text,'#NULL#') = COALESCE(current_record.medadm_note_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_version::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_display::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_version::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_display::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_version::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_display::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_code::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.medicationadministration_raw (
                        medadm_id,
                        medadm_encounter_id,
                        medadm_patient_id,
                        medadm_partof_id,
                        medadm_identifier_use,
                        medadm_identifier_type_system,
                        medadm_identifier_type_version,
                        medadm_identifier_type_code,
                        medadm_identifier_type_display,
                        medadm_identifier_type_text,
                        medadm_identifier_system,
                        medadm_identifier_value,
                        medadm_identifier_start,
                        medadm_identifier_end,
                        medadm_status,
                        medadm_statusreason_system,
                        medadm_statusreason_version,
                        medadm_statusreason_code,
                        medadm_statusreason_display,
                        medadm_statusreason_text,
                        medadm_category_system,
                        medadm_category_version,
                        medadm_category_code,
                        medadm_category_display,
                        medadm_category_text,
                        medadm_medicationreference_id,
                        medadm_medicationcodeableconcept_system,
                        medadm_medicationcodeableconcept_version,
                        medadm_medicationcodeableconcept_code,
                        medadm_medicationcodeableconcept_display,
                        medadm_medicationcodeableconcept_text,
                        medadm_supportinginformation_id,
                        medadm_supportinginformation_type,
                        medadm_supportinginformation_identifier_use,
                        medadm_supportinginformation_identifier_type_system,
                        medadm_supportinginformation_identifier_type_version,
                        medadm_supportinginformation_identifier_type_code,
                        medadm_supportinginformation_identifier_type_display,
                        medadm_supportinginformation_identifier_type_text,
                        medadm_supportinginformation_display,
                        medadm_effectivedatetime,
                        medadm_effectiveperiod_start,
                        medadm_effectiveperiod_end,
                        medadm_performer_function_system,
                        medadm_performer_function_version,
                        medadm_performer_function_code,
                        medadm_performer_function_display,
                        medadm_performer_function_text,
                        medadm_reasoncode_system,
                        medadm_reasoncode_version,
                        medadm_reasoncode_code,
                        medadm_reasoncode_display,
                        medadm_reasoncode_text,
                        medadm_reasonreference_id,
                        medadm_reasonreference_type,
                        medadm_reasonreference_identifier_use,
                        medadm_reasonreference_identifier_type_system,
                        medadm_reasonreference_identifier_type_version,
                        medadm_reasonreference_identifier_type_code,
                        medadm_reasonreference_identifier_type_display,
                        medadm_reasonreference_identifier_type_text,
                        medadm_reasonreference_display,
                        medadm_request_id,
                        medadm_note_authorstring,
                        medadm_note_authorreference_id,
                        medadm_note_authorreference_type,
                        medadm_note_authorreference_identifier_use,
                        medadm_note_authorreference_identifier_type_system,
                        medadm_note_authorreference_identifier_type_version,
                        medadm_note_authorreference_identifier_type_code,
                        medadm_note_authorreference_identifier_type_display,
                        medadm_note_authorreference_identifier_type_text,
                        medadm_note_authorreference_display,
                        medadm_note_time,
                        medadm_note_text,
                        medadm_dosage_text,
                        medadm_dosage_site_system,
                        medadm_dosage_site_version,
                        medadm_dosage_site_code,
                        medadm_dosage_site_display,
                        medadm_dosage_site_text,
                        medadm_dosage_route_system,
                        medadm_dosage_route_version,
                        medadm_dosage_route_code,
                        medadm_dosage_route_display,
                        medadm_dosage_route_text,
                        medadm_dosage_method_system,
                        medadm_dosage_method_version,
                        medadm_dosage_method_code,
                        medadm_dosage_method_display,
                        medadm_dosage_method_text,
                        medadm_dosage_dose_value,
                        medadm_dosage_dose_unit,
                        medadm_dosage_dose_system,
                        medadm_dosage_dose_code,
                        medadm_dosage_rateratio_numerator_value,
                        medadm_dosage_rateratio_numerator_comparator,
                        medadm_dosage_rateratio_numerator_unit,
                        medadm_dosage_rateratio_numerator_system,
                        medadm_dosage_rateratio_numerator_code,
                        medadm_dosage_rateratio_denominator_value,
                        medadm_dosage_rateratio_denominator_comparator,
                        medadm_dosage_rateratio_denominator_unit,
                        medadm_dosage_rateratio_denominator_system,
                        medadm_dosage_rateratio_denominator_code,
                        medadm_dosage_ratequantity_value,
                        medadm_dosage_ratequantity_unit,
                        medadm_dosage_ratequantity_system,
                        medadm_dosage_ratequantity_code,
                        input_datetime
                    )
                    VALUES (
                        current_record.medadm_id,
                        current_record.medadm_encounter_id,
                        current_record.medadm_patient_id,
                        current_record.medadm_partof_id,
                        current_record.medadm_identifier_use,
                        current_record.medadm_identifier_type_system,
                        current_record.medadm_identifier_type_version,
                        current_record.medadm_identifier_type_code,
                        current_record.medadm_identifier_type_display,
                        current_record.medadm_identifier_type_text,
                        current_record.medadm_identifier_system,
                        current_record.medadm_identifier_value,
                        current_record.medadm_identifier_start,
                        current_record.medadm_identifier_end,
                        current_record.medadm_status,
                        current_record.medadm_statusreason_system,
                        current_record.medadm_statusreason_version,
                        current_record.medadm_statusreason_code,
                        current_record.medadm_statusreason_display,
                        current_record.medadm_statusreason_text,
                        current_record.medadm_category_system,
                        current_record.medadm_category_version,
                        current_record.medadm_category_code,
                        current_record.medadm_category_display,
                        current_record.medadm_category_text,
                        current_record.medadm_medicationreference_id,
                        current_record.medadm_medicationcodeableconcept_system,
                        current_record.medadm_medicationcodeableconcept_version,
                        current_record.medadm_medicationcodeableconcept_code,
                        current_record.medadm_medicationcodeableconcept_display,
                        current_record.medadm_medicationcodeableconcept_text,
                        current_record.medadm_supportinginformation_id,
                        current_record.medadm_supportinginformation_type,
                        current_record.medadm_supportinginformation_identifier_use,
                        current_record.medadm_supportinginformation_identifier_type_system,
                        current_record.medadm_supportinginformation_identifier_type_version,
                        current_record.medadm_supportinginformation_identifier_type_code,
                        current_record.medadm_supportinginformation_identifier_type_display,
                        current_record.medadm_supportinginformation_identifier_type_text,
                        current_record.medadm_supportinginformation_display,
                        current_record.medadm_effectivedatetime,
                        current_record.medadm_effectiveperiod_start,
                        current_record.medadm_effectiveperiod_end,
                        current_record.medadm_performer_function_system,
                        current_record.medadm_performer_function_version,
                        current_record.medadm_performer_function_code,
                        current_record.medadm_performer_function_display,
                        current_record.medadm_performer_function_text,
                        current_record.medadm_reasoncode_system,
                        current_record.medadm_reasoncode_version,
                        current_record.medadm_reasoncode_code,
                        current_record.medadm_reasoncode_display,
                        current_record.medadm_reasoncode_text,
                        current_record.medadm_reasonreference_id,
                        current_record.medadm_reasonreference_type,
                        current_record.medadm_reasonreference_identifier_use,
                        current_record.medadm_reasonreference_identifier_type_system,
                        current_record.medadm_reasonreference_identifier_type_version,
                        current_record.medadm_reasonreference_identifier_type_code,
                        current_record.medadm_reasonreference_identifier_type_display,
                        current_record.medadm_reasonreference_identifier_type_text,
                        current_record.medadm_reasonreference_display,
                        current_record.medadm_request_id,
                        current_record.medadm_note_authorstring,
                        current_record.medadm_note_authorreference_id,
                        current_record.medadm_note_authorreference_type,
                        current_record.medadm_note_authorreference_identifier_use,
                        current_record.medadm_note_authorreference_identifier_type_system,
                        current_record.medadm_note_authorreference_identifier_type_version,
                        current_record.medadm_note_authorreference_identifier_type_code,
                        current_record.medadm_note_authorreference_identifier_type_display,
                        current_record.medadm_note_authorreference_identifier_type_text,
                        current_record.medadm_note_authorreference_display,
                        current_record.medadm_note_time,
                        current_record.medadm_note_text,
                        current_record.medadm_dosage_text,
                        current_record.medadm_dosage_site_system,
                        current_record.medadm_dosage_site_version,
                        current_record.medadm_dosage_site_code,
                        current_record.medadm_dosage_site_display,
                        current_record.medadm_dosage_site_text,
                        current_record.medadm_dosage_route_system,
                        current_record.medadm_dosage_route_version,
                        current_record.medadm_dosage_route_code,
                        current_record.medadm_dosage_route_display,
                        current_record.medadm_dosage_route_text,
                        current_record.medadm_dosage_method_system,
                        current_record.medadm_dosage_method_version,
                        current_record.medadm_dosage_method_code,
                        current_record.medadm_dosage_method_display,
                        current_record.medadm_dosage_method_text,
                        current_record.medadm_dosage_dose_value,
                        current_record.medadm_dosage_dose_unit,
                        current_record.medadm_dosage_dose_system,
                        current_record.medadm_dosage_dose_code,
                        current_record.medadm_dosage_rateratio_numerator_value,
                        current_record.medadm_dosage_rateratio_numerator_comparator,
                        current_record.medadm_dosage_rateratio_numerator_unit,
                        current_record.medadm_dosage_rateratio_numerator_system,
                        current_record.medadm_dosage_rateratio_numerator_code,
                        current_record.medadm_dosage_rateratio_denominator_value,
                        current_record.medadm_dosage_rateratio_denominator_comparator,
                        current_record.medadm_dosage_rateratio_denominator_unit,
                        current_record.medadm_dosage_rateratio_denominator_system,
                        current_record.medadm_dosage_rateratio_denominator_code,
                        current_record.medadm_dosage_ratequantity_value,
                        current_record.medadm_dosage_ratequantity_unit,
                        current_record.medadm_dosage_ratequantity_system,
                        current_record.medadm_dosage_ratequantity_code,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.medicationadministration_raw WHERE medicationadministration_id = current_record.medicationadministration_id;
                ELSE
                UPDATE db_log.medicationadministration_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.medadm_id::text,'#NULL#') = COALESCE(current_record.medadm_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_encounter_id::text,'#NULL#') = COALESCE(current_record.medadm_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_patient_id::text,'#NULL#') = COALESCE(current_record.medadm_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_partof_id::text,'#NULL#') = COALESCE(current_record.medadm_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_system::text,'#NULL#') = COALESCE(current_record.medadm_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_value::text,'#NULL#') = COALESCE(current_record.medadm_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_start::text,'#NULL#') = COALESCE(current_record.medadm_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.medadm_identifier_end::text,'#NULL#') = COALESCE(current_record.medadm_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.medadm_status::text,'#NULL#') = COALESCE(current_record.medadm_status::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_system::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_version::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_code::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_display::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_statusreason_text::text,'#NULL#') = COALESCE(current_record.medadm_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_system::text,'#NULL#') = COALESCE(current_record.medadm_category_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_version::text,'#NULL#') = COALESCE(current_record.medadm_category_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_code::text,'#NULL#') = COALESCE(current_record.medadm_category_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_display::text,'#NULL#') = COALESCE(current_record.medadm_category_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_category_text::text,'#NULL#') = COALESCE(current_record.medadm_category_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationreference_id::text,'#NULL#') = COALESCE(current_record.medadm_medicationreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_medicationcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medadm_medicationcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_id::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_type::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_type::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_supportinginformation_display::text,'#NULL#') = COALESCE(current_record.medadm_supportinginformation_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_effectivedatetime::text,'#NULL#') = COALESCE(current_record.medadm_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.medadm_effectiveperiod_start::text,'#NULL#') = COALESCE(current_record.medadm_effectiveperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medadm_effectiveperiod_end::text,'#NULL#') = COALESCE(current_record.medadm_effectiveperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_system::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_version::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_code::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_display::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_performer_function_text::text,'#NULL#') = COALESCE(current_record.medadm_performer_function_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_system::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_version::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_code::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_display::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasoncode_text::text,'#NULL#') = COALESCE(current_record.medadm_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_id::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_type::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_reasonreference_display::text,'#NULL#') = COALESCE(current_record.medadm_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_request_id::text,'#NULL#') = COALESCE(current_record.medadm_request_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorstring::text,'#NULL#') = COALESCE(current_record.medadm_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.medadm_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_time::text,'#NULL#') = COALESCE(current_record.medadm_note_time::text,'#NULL#') AND
                      COALESCE(target_record.medadm_note_text::text,'#NULL#') = COALESCE(current_record.medadm_note_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_version::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_display::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_site_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_site_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_version::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_display::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_route_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_route_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_version::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_version::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_display::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_display::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_method_text::text,'#NULL#') = COALESCE(current_record.medadm_dosage_method_text::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_dose_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_dose_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_numerator_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_rateratio_denominator_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_rateratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_value::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_unit::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_system::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medadm_dosage_ratequantity_code::text,'#NULL#') = COALESCE(current_record.medadm_dosage_ratequantity_code::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.medicationadministration_raw WHERE medicationadministration_id = current_record.medicationadministration_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.medicationadministration_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE medicationadministration_id = current_record.medicationadministration_id;
            END;
    END LOOP;
    -- END medicationadministration
    -- Start medicationstatement
    FOR current_record IN (SELECT * FROM cds2db_in.medicationstatement_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.medicationstatement_raw target_record
                WHERE COALESCE(target_record.medstat_id::text,'#NULL#') = COALESCE(current_record.medstat_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_system::text,'#NULL#') = COALESCE(current_record.medstat_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_value::text,'#NULL#') = COALESCE(current_record.medstat_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_start::text,'#NULL#') = COALESCE(current_record.medstat_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_end::text,'#NULL#') = COALESCE(current_record.medstat_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.medstat_encounter_id::text,'#NULL#') = COALESCE(current_record.medstat_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_patient_id::text,'#NULL#') = COALESCE(current_record.medstat_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_partof_id::text,'#NULL#') = COALESCE(current_record.medstat_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_id::text,'#NULL#') = COALESCE(current_record.medstat_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_type::text,'#NULL#') = COALESCE(current_record.medstat_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_display::text,'#NULL#') = COALESCE(current_record.medstat_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_status::text,'#NULL#') = COALESCE(current_record.medstat_status::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_system::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_version::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_code::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_display::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_text::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_system::text,'#NULL#') = COALESCE(current_record.medstat_category_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_version::text,'#NULL#') = COALESCE(current_record.medstat_category_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_code::text,'#NULL#') = COALESCE(current_record.medstat_category_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_display::text,'#NULL#') = COALESCE(current_record.medstat_category_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_text::text,'#NULL#') = COALESCE(current_record.medstat_category_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationreference_id::text,'#NULL#') = COALESCE(current_record.medstat_medicationreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_effectivedatetime::text,'#NULL#') = COALESCE(current_record.medstat_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.medstat_effectiveperiod_start::text,'#NULL#') = COALESCE(current_record.medstat_effectiveperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medstat_effectiveperiod_end::text,'#NULL#') = COALESCE(current_record.medstat_effectiveperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dateasserted::text,'#NULL#') = COALESCE(current_record.medstat_dateasserted::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_id::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_type::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_display::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_id::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_type::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_display::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_system::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_version::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_code::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_display::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_text::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_id::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_type::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_display::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorstring::text,'#NULL#') = COALESCE(current_record.medstat_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_time::text,'#NULL#') = COALESCE(current_record.medstat_note_time::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_text::text,'#NULL#') = COALESCE(current_record.medstat_note_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_sequence::text,'#NULL#') = COALESCE(current_record.medstat_dosage_sequence::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_patientinstruction::text,'#NULL#') = COALESCE(current_record.medstat_dosage_patientinstruction::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_event::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_event::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsperiod_start::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsperiod_end::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_count::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_count::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_countmax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_countmax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_duration::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_duration::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_durationmax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_durationmax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_durationunit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_durationunit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_frequency::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_frequency::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_frequencymax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_frequencymax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_period::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_period::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_periodmax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_periodmax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_periodunit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_periodunit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_dayofweek::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_dayofweek::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_timeofday::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_timeofday::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_when::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_when::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_offset::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_offset::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededboolean::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededboolean::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_code::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.medicationstatement_raw (
                        medstat_id,
                        medstat_identifier_use,
                        medstat_identifier_type_system,
                        medstat_identifier_type_version,
                        medstat_identifier_type_code,
                        medstat_identifier_type_display,
                        medstat_identifier_type_text,
                        medstat_identifier_system,
                        medstat_identifier_value,
                        medstat_identifier_start,
                        medstat_identifier_end,
                        medstat_encounter_id,
                        medstat_patient_id,
                        medstat_partof_id,
                        medstat_basedon_id,
                        medstat_basedon_type,
                        medstat_basedon_identifier_use,
                        medstat_basedon_identifier_type_system,
                        medstat_basedon_identifier_type_version,
                        medstat_basedon_identifier_type_code,
                        medstat_basedon_identifier_type_display,
                        medstat_basedon_identifier_type_text,
                        medstat_basedon_display,
                        medstat_status,
                        medstat_statusreason_system,
                        medstat_statusreason_version,
                        medstat_statusreason_code,
                        medstat_statusreason_display,
                        medstat_statusreason_text,
                        medstat_category_system,
                        medstat_category_version,
                        medstat_category_code,
                        medstat_category_display,
                        medstat_category_text,
                        medstat_medicationreference_id,
                        medstat_medicationcodeableconcept_system,
                        medstat_medicationcodeableconcept_version,
                        medstat_medicationcodeableconcept_code,
                        medstat_medicationcodeableconcept_display,
                        medstat_medicationcodeableconcept_text,
                        medstat_effectivedatetime,
                        medstat_effectiveperiod_start,
                        medstat_effectiveperiod_end,
                        medstat_dateasserted,
                        medstat_informationsource_id,
                        medstat_informationsource_type,
                        medstat_informationsource_identifier_use,
                        medstat_informationsource_identifier_type_system,
                        medstat_informationsource_identifier_type_version,
                        medstat_informationsource_identifier_type_code,
                        medstat_informationsource_identifier_type_display,
                        medstat_informationsource_identifier_type_text,
                        medstat_informationsource_display,
                        medstat_derivedfrom_id,
                        medstat_derivedfrom_type,
                        medstat_derivedfrom_identifier_use,
                        medstat_derivedfrom_identifier_type_system,
                        medstat_derivedfrom_identifier_type_version,
                        medstat_derivedfrom_identifier_type_code,
                        medstat_derivedfrom_identifier_type_display,
                        medstat_derivedfrom_identifier_type_text,
                        medstat_derivedfrom_display,
                        medstat_reasoncode_system,
                        medstat_reasoncode_version,
                        medstat_reasoncode_code,
                        medstat_reasoncode_display,
                        medstat_reasoncode_text,
                        medstat_reasonreference_id,
                        medstat_reasonreference_type,
                        medstat_reasonreference_identifier_use,
                        medstat_reasonreference_identifier_type_system,
                        medstat_reasonreference_identifier_type_version,
                        medstat_reasonreference_identifier_type_code,
                        medstat_reasonreference_identifier_type_display,
                        medstat_reasonreference_identifier_type_text,
                        medstat_reasonreference_display,
                        medstat_note_authorstring,
                        medstat_note_authorreference_id,
                        medstat_note_authorreference_type,
                        medstat_note_authorreference_identifier_use,
                        medstat_note_authorreference_identifier_type_system,
                        medstat_note_authorreference_identifier_type_version,
                        medstat_note_authorreference_identifier_type_code,
                        medstat_note_authorreference_identifier_type_display,
                        medstat_note_authorreference_identifier_type_text,
                        medstat_note_authorreference_display,
                        medstat_note_time,
                        medstat_note_text,
                        medstat_dosage_sequence,
                        medstat_dosage_text,
                        medstat_dosage_additionalinstruction_system,
                        medstat_dosage_additionalinstruction_version,
                        medstat_dosage_additionalinstruction_code,
                        medstat_dosage_additionalinstruction_display,
                        medstat_dosage_additionalinstruction_text,
                        medstat_dosage_patientinstruction,
                        medstat_dosage_timing_event,
                        medstat_dosage_timing_repeat_boundsduration_value,
                        medstat_dosage_timing_repeat_boundsduration_comparator,
                        medstat_dosage_timing_repeat_boundsduration_unit,
                        medstat_dosage_timing_repeat_boundsduration_system,
                        medstat_dosage_timing_repeat_boundsduration_code,
                        medstat_dosage_timing_repeat_boundsrange_low_value,
                        medstat_dosage_timing_repeat_boundsrange_low_unit,
                        medstat_dosage_timing_repeat_boundsrange_low_system,
                        medstat_dosage_timing_repeat_boundsrange_low_code,
                        medstat_dosage_timing_repeat_boundsrange_high_value,
                        medstat_dosage_timing_repeat_boundsrange_high_unit,
                        medstat_dosage_timing_repeat_boundsrange_high_system,
                        medstat_dosage_timing_repeat_boundsrange_high_code,
                        medstat_dosage_timing_repeat_boundsperiod_start,
                        medstat_dosage_timing_repeat_boundsperiod_end,
                        medstat_dosage_timing_repeat_count,
                        medstat_dosage_timing_repeat_countmax,
                        medstat_dosage_timing_repeat_duration,
                        medstat_dosage_timing_repeat_durationmax,
                        medstat_dosage_timing_repeat_durationunit,
                        medstat_dosage_timing_repeat_frequency,
                        medstat_dosage_timing_repeat_frequencymax,
                        medstat_dosage_timing_repeat_period,
                        medstat_dosage_timing_repeat_periodmax,
                        medstat_dosage_timing_repeat_periodunit,
                        medstat_dosage_timing_repeat_dayofweek,
                        medstat_dosage_timing_repeat_timeofday,
                        medstat_dosage_timing_repeat_when,
                        medstat_dosage_timing_repeat_offset,
                        medstat_dosage_timing_code_system,
                        medstat_dosage_timing_code_version,
                        medstat_dosage_timing_code_code,
                        medstat_dosage_timing_code_display,
                        medstat_dosage_timing_code_text,
                        medstat_dosage_asneededboolean,
                        medstat_dosage_asneededcodeableconcept_system,
                        medstat_dosage_asneededcodeableconcept_version,
                        medstat_dosage_asneededcodeableconcept_code,
                        medstat_dosage_asneededcodeableconcept_display,
                        medstat_dosage_asneededcodeableconcept_text,
                        medstat_dosage_site_system,
                        medstat_dosage_site_version,
                        medstat_dosage_site_code,
                        medstat_dosage_site_display,
                        medstat_dosage_site_text,
                        medstat_dosage_route_system,
                        medstat_dosage_route_version,
                        medstat_dosage_route_code,
                        medstat_dosage_route_display,
                        medstat_dosage_route_text,
                        medstat_dosage_method_system,
                        medstat_dosage_method_version,
                        medstat_dosage_method_code,
                        medstat_dosage_method_display,
                        medstat_dosage_method_text,
                        medstat_dosage_doseandrate_type_system,
                        medstat_dosage_doseandrate_type_version,
                        medstat_dosage_doseandrate_type_code,
                        medstat_dosage_doseandrate_type_display,
                        medstat_dosage_doseandrate_type_text,
                        medstat_dosage_doseandrate_doserange_low_value,
                        medstat_dosage_doseandrate_doserange_low_unit,
                        medstat_dosage_doseandrate_doserange_low_system,
                        medstat_dosage_doseandrate_doserange_low_code,
                        medstat_dosage_doseandrate_doserange_high_value,
                        medstat_dosage_doseandrate_doserange_high_unit,
                        medstat_dosage_doseandrate_doserange_high_system,
                        medstat_dosage_doseandrate_doserange_high_code,
                        medstat_dosage_doseandrate_dosequantity_value,
                        medstat_dosage_doseandrate_dosequantity_comparator,
                        medstat_dosage_doseandrate_dosequantity_unit,
                        medstat_dosage_doseandrate_dosequantity_system,
                        medstat_dosage_doseandrate_dosequantity_code,
                        medstat_dosage_doseandrate_rateratio_numerator_value,
                        medstat_dosage_doseandrate_rateratio_numerator_comparator,
                        medstat_dosage_doseandrate_rateratio_numerator_unit,
                        medstat_dosage_doseandrate_rateratio_numerator_system,
                        medstat_dosage_doseandrate_rateratio_numerator_code,
                        medstat_dosage_doseandrate_rateratio_denominator_value,
                        medstat_dosage_doseandrate_rateratio_denominator_comparator,
                        medstat_dosage_doseandrate_rateratio_denominator_unit,
                        medstat_dosage_doseandrate_rateratio_denominator_system,
                        medstat_dosage_doseandrate_rateratio_denominator_code,
                        medstat_dosage_doseandrate_raterange_low_value,
                        medstat_dosage_doseandrate_raterange_low_unit,
                        medstat_dosage_doseandrate_raterange_low_system,
                        medstat_dosage_doseandrate_raterange_low_code,
                        medstat_dosage_doseandrate_raterange_high_value,
                        medstat_dosage_doseandrate_raterange_high_unit,
                        medstat_dosage_doseandrate_raterange_high_system,
                        medstat_dosage_doseandrate_raterange_high_code,
                        medstat_dosage_doseandrate_ratequantity_value,
                        medstat_dosage_doseandrate_ratequantity_unit,
                        medstat_dosage_doseandrate_ratequantity_system,
                        medstat_dosage_doseandrate_ratequantity_code,
                        medstat_dosage_maxdoseperperiod_numerator_value,
                        medstat_dosage_maxdoseperperiod_numerator_comparator,
                        medstat_dosage_maxdoseperperiod_numerator_unit,
                        medstat_dosage_maxdoseperperiod_numerator_system,
                        medstat_dosage_maxdoseperperiod_numerator_code,
                        medstat_dosage_maxdoseperperiod_denominator_value,
                        medstat_dosage_maxdoseperperiod_denominator_comparator,
                        medstat_dosage_maxdoseperperiod_denominator_unit,
                        medstat_dosage_maxdoseperperiod_denominator_system,
                        medstat_dosage_maxdoseperperiod_denominator_code,
                        medstat_dosage_maxdoseperadministration_value,
                        medstat_dosage_maxdoseperadministration_unit,
                        medstat_dosage_maxdoseperadministration_system,
                        medstat_dosage_maxdoseperadministration_code,
                        medstat_dosage_maxdoseperlifetime_value,
                        medstat_dosage_maxdoseperlifetime_unit,
                        medstat_dosage_maxdoseperlifetime_system,
                        medstat_dosage_maxdoseperlifetime_code,
                        input_datetime
                    )
                    VALUES (
                        current_record.medstat_id,
                        current_record.medstat_identifier_use,
                        current_record.medstat_identifier_type_system,
                        current_record.medstat_identifier_type_version,
                        current_record.medstat_identifier_type_code,
                        current_record.medstat_identifier_type_display,
                        current_record.medstat_identifier_type_text,
                        current_record.medstat_identifier_system,
                        current_record.medstat_identifier_value,
                        current_record.medstat_identifier_start,
                        current_record.medstat_identifier_end,
                        current_record.medstat_encounter_id,
                        current_record.medstat_patient_id,
                        current_record.medstat_partof_id,
                        current_record.medstat_basedon_id,
                        current_record.medstat_basedon_type,
                        current_record.medstat_basedon_identifier_use,
                        current_record.medstat_basedon_identifier_type_system,
                        current_record.medstat_basedon_identifier_type_version,
                        current_record.medstat_basedon_identifier_type_code,
                        current_record.medstat_basedon_identifier_type_display,
                        current_record.medstat_basedon_identifier_type_text,
                        current_record.medstat_basedon_display,
                        current_record.medstat_status,
                        current_record.medstat_statusreason_system,
                        current_record.medstat_statusreason_version,
                        current_record.medstat_statusreason_code,
                        current_record.medstat_statusreason_display,
                        current_record.medstat_statusreason_text,
                        current_record.medstat_category_system,
                        current_record.medstat_category_version,
                        current_record.medstat_category_code,
                        current_record.medstat_category_display,
                        current_record.medstat_category_text,
                        current_record.medstat_medicationreference_id,
                        current_record.medstat_medicationcodeableconcept_system,
                        current_record.medstat_medicationcodeableconcept_version,
                        current_record.medstat_medicationcodeableconcept_code,
                        current_record.medstat_medicationcodeableconcept_display,
                        current_record.medstat_medicationcodeableconcept_text,
                        current_record.medstat_effectivedatetime,
                        current_record.medstat_effectiveperiod_start,
                        current_record.medstat_effectiveperiod_end,
                        current_record.medstat_dateasserted,
                        current_record.medstat_informationsource_id,
                        current_record.medstat_informationsource_type,
                        current_record.medstat_informationsource_identifier_use,
                        current_record.medstat_informationsource_identifier_type_system,
                        current_record.medstat_informationsource_identifier_type_version,
                        current_record.medstat_informationsource_identifier_type_code,
                        current_record.medstat_informationsource_identifier_type_display,
                        current_record.medstat_informationsource_identifier_type_text,
                        current_record.medstat_informationsource_display,
                        current_record.medstat_derivedfrom_id,
                        current_record.medstat_derivedfrom_type,
                        current_record.medstat_derivedfrom_identifier_use,
                        current_record.medstat_derivedfrom_identifier_type_system,
                        current_record.medstat_derivedfrom_identifier_type_version,
                        current_record.medstat_derivedfrom_identifier_type_code,
                        current_record.medstat_derivedfrom_identifier_type_display,
                        current_record.medstat_derivedfrom_identifier_type_text,
                        current_record.medstat_derivedfrom_display,
                        current_record.medstat_reasoncode_system,
                        current_record.medstat_reasoncode_version,
                        current_record.medstat_reasoncode_code,
                        current_record.medstat_reasoncode_display,
                        current_record.medstat_reasoncode_text,
                        current_record.medstat_reasonreference_id,
                        current_record.medstat_reasonreference_type,
                        current_record.medstat_reasonreference_identifier_use,
                        current_record.medstat_reasonreference_identifier_type_system,
                        current_record.medstat_reasonreference_identifier_type_version,
                        current_record.medstat_reasonreference_identifier_type_code,
                        current_record.medstat_reasonreference_identifier_type_display,
                        current_record.medstat_reasonreference_identifier_type_text,
                        current_record.medstat_reasonreference_display,
                        current_record.medstat_note_authorstring,
                        current_record.medstat_note_authorreference_id,
                        current_record.medstat_note_authorreference_type,
                        current_record.medstat_note_authorreference_identifier_use,
                        current_record.medstat_note_authorreference_identifier_type_system,
                        current_record.medstat_note_authorreference_identifier_type_version,
                        current_record.medstat_note_authorreference_identifier_type_code,
                        current_record.medstat_note_authorreference_identifier_type_display,
                        current_record.medstat_note_authorreference_identifier_type_text,
                        current_record.medstat_note_authorreference_display,
                        current_record.medstat_note_time,
                        current_record.medstat_note_text,
                        current_record.medstat_dosage_sequence,
                        current_record.medstat_dosage_text,
                        current_record.medstat_dosage_additionalinstruction_system,
                        current_record.medstat_dosage_additionalinstruction_version,
                        current_record.medstat_dosage_additionalinstruction_code,
                        current_record.medstat_dosage_additionalinstruction_display,
                        current_record.medstat_dosage_additionalinstruction_text,
                        current_record.medstat_dosage_patientinstruction,
                        current_record.medstat_dosage_timing_event,
                        current_record.medstat_dosage_timing_repeat_boundsduration_value,
                        current_record.medstat_dosage_timing_repeat_boundsduration_comparator,
                        current_record.medstat_dosage_timing_repeat_boundsduration_unit,
                        current_record.medstat_dosage_timing_repeat_boundsduration_system,
                        current_record.medstat_dosage_timing_repeat_boundsduration_code,
                        current_record.medstat_dosage_timing_repeat_boundsrange_low_value,
                        current_record.medstat_dosage_timing_repeat_boundsrange_low_unit,
                        current_record.medstat_dosage_timing_repeat_boundsrange_low_system,
                        current_record.medstat_dosage_timing_repeat_boundsrange_low_code,
                        current_record.medstat_dosage_timing_repeat_boundsrange_high_value,
                        current_record.medstat_dosage_timing_repeat_boundsrange_high_unit,
                        current_record.medstat_dosage_timing_repeat_boundsrange_high_system,
                        current_record.medstat_dosage_timing_repeat_boundsrange_high_code,
                        current_record.medstat_dosage_timing_repeat_boundsperiod_start,
                        current_record.medstat_dosage_timing_repeat_boundsperiod_end,
                        current_record.medstat_dosage_timing_repeat_count,
                        current_record.medstat_dosage_timing_repeat_countmax,
                        current_record.medstat_dosage_timing_repeat_duration,
                        current_record.medstat_dosage_timing_repeat_durationmax,
                        current_record.medstat_dosage_timing_repeat_durationunit,
                        current_record.medstat_dosage_timing_repeat_frequency,
                        current_record.medstat_dosage_timing_repeat_frequencymax,
                        current_record.medstat_dosage_timing_repeat_period,
                        current_record.medstat_dosage_timing_repeat_periodmax,
                        current_record.medstat_dosage_timing_repeat_periodunit,
                        current_record.medstat_dosage_timing_repeat_dayofweek,
                        current_record.medstat_dosage_timing_repeat_timeofday,
                        current_record.medstat_dosage_timing_repeat_when,
                        current_record.medstat_dosage_timing_repeat_offset,
                        current_record.medstat_dosage_timing_code_system,
                        current_record.medstat_dosage_timing_code_version,
                        current_record.medstat_dosage_timing_code_code,
                        current_record.medstat_dosage_timing_code_display,
                        current_record.medstat_dosage_timing_code_text,
                        current_record.medstat_dosage_asneededboolean,
                        current_record.medstat_dosage_asneededcodeableconcept_system,
                        current_record.medstat_dosage_asneededcodeableconcept_version,
                        current_record.medstat_dosage_asneededcodeableconcept_code,
                        current_record.medstat_dosage_asneededcodeableconcept_display,
                        current_record.medstat_dosage_asneededcodeableconcept_text,
                        current_record.medstat_dosage_site_system,
                        current_record.medstat_dosage_site_version,
                        current_record.medstat_dosage_site_code,
                        current_record.medstat_dosage_site_display,
                        current_record.medstat_dosage_site_text,
                        current_record.medstat_dosage_route_system,
                        current_record.medstat_dosage_route_version,
                        current_record.medstat_dosage_route_code,
                        current_record.medstat_dosage_route_display,
                        current_record.medstat_dosage_route_text,
                        current_record.medstat_dosage_method_system,
                        current_record.medstat_dosage_method_version,
                        current_record.medstat_dosage_method_code,
                        current_record.medstat_dosage_method_display,
                        current_record.medstat_dosage_method_text,
                        current_record.medstat_dosage_doseandrate_type_system,
                        current_record.medstat_dosage_doseandrate_type_version,
                        current_record.medstat_dosage_doseandrate_type_code,
                        current_record.medstat_dosage_doseandrate_type_display,
                        current_record.medstat_dosage_doseandrate_type_text,
                        current_record.medstat_dosage_doseandrate_doserange_low_value,
                        current_record.medstat_dosage_doseandrate_doserange_low_unit,
                        current_record.medstat_dosage_doseandrate_doserange_low_system,
                        current_record.medstat_dosage_doseandrate_doserange_low_code,
                        current_record.medstat_dosage_doseandrate_doserange_high_value,
                        current_record.medstat_dosage_doseandrate_doserange_high_unit,
                        current_record.medstat_dosage_doseandrate_doserange_high_system,
                        current_record.medstat_dosage_doseandrate_doserange_high_code,
                        current_record.medstat_dosage_doseandrate_dosequantity_value,
                        current_record.medstat_dosage_doseandrate_dosequantity_comparator,
                        current_record.medstat_dosage_doseandrate_dosequantity_unit,
                        current_record.medstat_dosage_doseandrate_dosequantity_system,
                        current_record.medstat_dosage_doseandrate_dosequantity_code,
                        current_record.medstat_dosage_doseandrate_rateratio_numerator_value,
                        current_record.medstat_dosage_doseandrate_rateratio_numerator_comparator,
                        current_record.medstat_dosage_doseandrate_rateratio_numerator_unit,
                        current_record.medstat_dosage_doseandrate_rateratio_numerator_system,
                        current_record.medstat_dosage_doseandrate_rateratio_numerator_code,
                        current_record.medstat_dosage_doseandrate_rateratio_denominator_value,
                        current_record.medstat_dosage_doseandrate_rateratio_denominator_comparator,
                        current_record.medstat_dosage_doseandrate_rateratio_denominator_unit,
                        current_record.medstat_dosage_doseandrate_rateratio_denominator_system,
                        current_record.medstat_dosage_doseandrate_rateratio_denominator_code,
                        current_record.medstat_dosage_doseandrate_raterange_low_value,
                        current_record.medstat_dosage_doseandrate_raterange_low_unit,
                        current_record.medstat_dosage_doseandrate_raterange_low_system,
                        current_record.medstat_dosage_doseandrate_raterange_low_code,
                        current_record.medstat_dosage_doseandrate_raterange_high_value,
                        current_record.medstat_dosage_doseandrate_raterange_high_unit,
                        current_record.medstat_dosage_doseandrate_raterange_high_system,
                        current_record.medstat_dosage_doseandrate_raterange_high_code,
                        current_record.medstat_dosage_doseandrate_ratequantity_value,
                        current_record.medstat_dosage_doseandrate_ratequantity_unit,
                        current_record.medstat_dosage_doseandrate_ratequantity_system,
                        current_record.medstat_dosage_doseandrate_ratequantity_code,
                        current_record.medstat_dosage_maxdoseperperiod_numerator_value,
                        current_record.medstat_dosage_maxdoseperperiod_numerator_comparator,
                        current_record.medstat_dosage_maxdoseperperiod_numerator_unit,
                        current_record.medstat_dosage_maxdoseperperiod_numerator_system,
                        current_record.medstat_dosage_maxdoseperperiod_numerator_code,
                        current_record.medstat_dosage_maxdoseperperiod_denominator_value,
                        current_record.medstat_dosage_maxdoseperperiod_denominator_comparator,
                        current_record.medstat_dosage_maxdoseperperiod_denominator_unit,
                        current_record.medstat_dosage_maxdoseperperiod_denominator_system,
                        current_record.medstat_dosage_maxdoseperperiod_denominator_code,
                        current_record.medstat_dosage_maxdoseperadministration_value,
                        current_record.medstat_dosage_maxdoseperadministration_unit,
                        current_record.medstat_dosage_maxdoseperadministration_system,
                        current_record.medstat_dosage_maxdoseperadministration_code,
                        current_record.medstat_dosage_maxdoseperlifetime_value,
                        current_record.medstat_dosage_maxdoseperlifetime_unit,
                        current_record.medstat_dosage_maxdoseperlifetime_system,
                        current_record.medstat_dosage_maxdoseperlifetime_code,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.medicationstatement_raw WHERE medicationstatement_id = current_record.medicationstatement_id;
                ELSE
                UPDATE db_log.medicationstatement_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.medstat_id::text,'#NULL#') = COALESCE(current_record.medstat_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_system::text,'#NULL#') = COALESCE(current_record.medstat_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_value::text,'#NULL#') = COALESCE(current_record.medstat_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_start::text,'#NULL#') = COALESCE(current_record.medstat_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.medstat_identifier_end::text,'#NULL#') = COALESCE(current_record.medstat_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.medstat_encounter_id::text,'#NULL#') = COALESCE(current_record.medstat_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_patient_id::text,'#NULL#') = COALESCE(current_record.medstat_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_partof_id::text,'#NULL#') = COALESCE(current_record.medstat_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_id::text,'#NULL#') = COALESCE(current_record.medstat_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_type::text,'#NULL#') = COALESCE(current_record.medstat_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_basedon_display::text,'#NULL#') = COALESCE(current_record.medstat_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_status::text,'#NULL#') = COALESCE(current_record.medstat_status::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_system::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_version::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_code::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_display::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_statusreason_text::text,'#NULL#') = COALESCE(current_record.medstat_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_system::text,'#NULL#') = COALESCE(current_record.medstat_category_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_version::text,'#NULL#') = COALESCE(current_record.medstat_category_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_code::text,'#NULL#') = COALESCE(current_record.medstat_category_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_display::text,'#NULL#') = COALESCE(current_record.medstat_category_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_category_text::text,'#NULL#') = COALESCE(current_record.medstat_category_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationreference_id::text,'#NULL#') = COALESCE(current_record.medstat_medicationreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_medicationcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medstat_medicationcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_effectivedatetime::text,'#NULL#') = COALESCE(current_record.medstat_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.medstat_effectiveperiod_start::text,'#NULL#') = COALESCE(current_record.medstat_effectiveperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medstat_effectiveperiod_end::text,'#NULL#') = COALESCE(current_record.medstat_effectiveperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dateasserted::text,'#NULL#') = COALESCE(current_record.medstat_dateasserted::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_id::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_type::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_informationsource_display::text,'#NULL#') = COALESCE(current_record.medstat_informationsource_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_id::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_type::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_derivedfrom_display::text,'#NULL#') = COALESCE(current_record.medstat_derivedfrom_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_system::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_version::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_code::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_display::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasoncode_text::text,'#NULL#') = COALESCE(current_record.medstat_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_id::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_type::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_reasonreference_display::text,'#NULL#') = COALESCE(current_record.medstat_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorstring::text,'#NULL#') = COALESCE(current_record.medstat_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.medstat_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_time::text,'#NULL#') = COALESCE(current_record.medstat_note_time::text,'#NULL#') AND
                      COALESCE(target_record.medstat_note_text::text,'#NULL#') = COALESCE(current_record.medstat_note_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_sequence::text,'#NULL#') = COALESCE(current_record.medstat_dosage_sequence::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_additionalinstruction_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_additionalinstruction_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_patientinstruction::text,'#NULL#') = COALESCE(current_record.medstat_dosage_patientinstruction::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_event::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_event::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsduration_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsduration_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_low_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsrange_high_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsrange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsperiod_start::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_boundsperiod_end::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_boundsperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_count::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_count::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_countmax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_countmax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_duration::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_duration::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_durationmax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_durationmax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_durationunit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_durationunit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_frequency::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_frequency::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_frequencymax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_frequencymax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_period::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_period::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_periodmax::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_periodmax::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_periodunit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_periodunit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_dayofweek::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_dayofweek::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_timeofday::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_timeofday::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_when::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_when::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_repeat_offset::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_repeat_offset::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_timing_code_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_timing_code_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededboolean::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededboolean::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_asneededcodeableconcept_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_asneededcodeableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_site_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_site_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_route_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_route_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_method_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_method_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_version::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_version::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_display::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_display::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_type_text::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_type_text::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_low_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_doserange_high_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_doserange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_dosequantity_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_dosequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_numerator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_rateratio_denominator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_rateratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_low_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_raterange_high_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_raterange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_doseandrate_ratequantity_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_doseandrate_ratequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_numerator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_comparator::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperperiod_denominator_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperperiod_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperadministration_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperadministration_code::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_value::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_value::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_unit::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_unit::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_system::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_system::text,'#NULL#') AND
                      COALESCE(target_record.medstat_dosage_maxdoseperlifetime_code::text,'#NULL#') = COALESCE(current_record.medstat_dosage_maxdoseperlifetime_code::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.medicationstatement_raw WHERE medicationstatement_id = current_record.medicationstatement_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.medicationstatement_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE medicationstatement_id = current_record.medicationstatement_id;
            END;
    END LOOP;
    -- END medicationstatement
    -- Start observation
    FOR current_record IN (SELECT * FROM cds2db_in.observation_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.observation_raw target_record
                WHERE COALESCE(target_record.obs_id::text,'#NULL#') = COALESCE(current_record.obs_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_encounter_id::text,'#NULL#') = COALESCE(current_record.obs_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_patient_id::text,'#NULL#') = COALESCE(current_record.obs_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_partof_id::text,'#NULL#') = COALESCE(current_record.obs_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_system::text,'#NULL#') = COALESCE(current_record.obs_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_value::text,'#NULL#') = COALESCE(current_record.obs_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_start::text,'#NULL#') = COALESCE(current_record.obs_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_end::text,'#NULL#') = COALESCE(current_record.obs_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_id::text,'#NULL#') = COALESCE(current_record.obs_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_type::text,'#NULL#') = COALESCE(current_record.obs_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_display::text,'#NULL#') = COALESCE(current_record.obs_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_status::text,'#NULL#') = COALESCE(current_record.obs_status::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_system::text,'#NULL#') = COALESCE(current_record.obs_category_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_version::text,'#NULL#') = COALESCE(current_record.obs_category_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_code::text,'#NULL#') = COALESCE(current_record.obs_category_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_display::text,'#NULL#') = COALESCE(current_record.obs_category_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_text::text,'#NULL#') = COALESCE(current_record.obs_category_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_system::text,'#NULL#') = COALESCE(current_record.obs_code_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_version::text,'#NULL#') = COALESCE(current_record.obs_code_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_code::text,'#NULL#') = COALESCE(current_record.obs_code_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_display::text,'#NULL#') = COALESCE(current_record.obs_code_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_text::text,'#NULL#') = COALESCE(current_record.obs_code_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_effectivedatetime::text,'#NULL#') = COALESCE(current_record.obs_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.obs_issued::text,'#NULL#') = COALESCE(current_record.obs_issued::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_value::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_unit::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_system::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_code::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_value::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_unit::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_system::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_code::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_value::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_system::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_code::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_value::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_system::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_code::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_value::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_comparator::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_comparator::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_unit::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_system::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_code::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_system::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_version::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_code::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_display::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_text::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_system::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_version::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_code::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_display::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_text::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorstring::text,'#NULL#') = COALESCE(current_record.obs_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_time::text,'#NULL#') = COALESCE(current_record.obs_note_time::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_text::text,'#NULL#') = COALESCE(current_record.obs_note_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_system::text,'#NULL#') = COALESCE(current_record.obs_method_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_version::text,'#NULL#') = COALESCE(current_record.obs_method_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_code::text,'#NULL#') = COALESCE(current_record.obs_method_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_display::text,'#NULL#') = COALESCE(current_record.obs_method_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_text::text,'#NULL#') = COALESCE(current_record.obs_method_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_id::text,'#NULL#') = COALESCE(current_record.obs_performer_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_type::text,'#NULL#') = COALESCE(current_record.obs_performer_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_display::text,'#NULL#') = COALESCE(current_record.obs_performer_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_version::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_display::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_text::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_version::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_display::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_text::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_text::text,'#NULL#') = COALESCE(current_record.obs_referencerange_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_id::text,'#NULL#') = COALESCE(current_record.obs_hasmember_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_type::text,'#NULL#') = COALESCE(current_record.obs_hasmember_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_display::text,'#NULL#') = COALESCE(current_record.obs_hasmember_display::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.observation_raw (
                        obs_id,
                        obs_encounter_id,
                        obs_patient_id,
                        obs_partof_id,
                        obs_identifier_use,
                        obs_identifier_type_system,
                        obs_identifier_type_version,
                        obs_identifier_type_code,
                        obs_identifier_type_display,
                        obs_identifier_type_text,
                        obs_identifier_system,
                        obs_identifier_value,
                        obs_identifier_start,
                        obs_identifier_end,
                        obs_basedon_id,
                        obs_basedon_type,
                        obs_basedon_identifier_use,
                        obs_basedon_identifier_type_system,
                        obs_basedon_identifier_type_version,
                        obs_basedon_identifier_type_code,
                        obs_basedon_identifier_type_display,
                        obs_basedon_identifier_type_text,
                        obs_basedon_display,
                        obs_status,
                        obs_category_system,
                        obs_category_version,
                        obs_category_code,
                        obs_category_display,
                        obs_category_text,
                        obs_code_system,
                        obs_code_version,
                        obs_code_code,
                        obs_code_display,
                        obs_code_text,
                        obs_effectivedatetime,
                        obs_issued,
                        obs_valuerange_low_value,
                        obs_valuerange_low_unit,
                        obs_valuerange_low_system,
                        obs_valuerange_low_code,
                        obs_valuerange_high_value,
                        obs_valuerange_high_unit,
                        obs_valuerange_high_system,
                        obs_valuerange_high_code,
                        obs_valueratio_numerator_value,
                        obs_valueratio_numerator_comparator,
                        obs_valueratio_numerator_unit,
                        obs_valueratio_numerator_system,
                        obs_valueratio_numerator_code,
                        obs_valueratio_denominator_value,
                        obs_valueratio_denominator_comparator,
                        obs_valueratio_denominator_unit,
                        obs_valueratio_denominator_system,
                        obs_valueratio_denominator_code,
                        obs_valuequantity_value,
                        obs_valuequantity_comparator,
                        obs_valuequantity_unit,
                        obs_valuequantity_system,
                        obs_valuequantity_code,
                        obs_valuecodableconcept_system,
                        obs_valuecodableconcept_version,
                        obs_valuecodableconcept_code,
                        obs_valuecodableconcept_display,
                        obs_valuecodableconcept_text,
                        obs_dataabsentreason_system,
                        obs_dataabsentreason_version,
                        obs_dataabsentreason_code,
                        obs_dataabsentreason_display,
                        obs_dataabsentreason_text,
                        obs_note_authorstring,
                        obs_note_authorreference_id,
                        obs_note_authorreference_type,
                        obs_note_authorreference_identifier_use,
                        obs_note_authorreference_identifier_type_system,
                        obs_note_authorreference_identifier_type_version,
                        obs_note_authorreference_identifier_type_code,
                        obs_note_authorreference_identifier_type_display,
                        obs_note_authorreference_identifier_type_text,
                        obs_note_authorreference_display,
                        obs_note_time,
                        obs_note_text,
                        obs_method_system,
                        obs_method_version,
                        obs_method_code,
                        obs_method_display,
                        obs_method_text,
                        obs_performer_id,
                        obs_performer_type,
                        obs_performer_identifier_use,
                        obs_performer_identifier_type_system,
                        obs_performer_identifier_type_version,
                        obs_performer_identifier_type_code,
                        obs_performer_identifier_type_display,
                        obs_performer_identifier_type_text,
                        obs_performer_display,
                        obs_referencerange_low_value,
                        obs_referencerange_low_unit,
                        obs_referencerange_low_system,
                        obs_referencerange_low_code,
                        obs_referencerange_high_value,
                        obs_referencerange_high_unit,
                        obs_referencerange_high_system,
                        obs_referencerange_high_code,
                        obs_referencerange_type_system,
                        obs_referencerange_type_version,
                        obs_referencerange_type_code,
                        obs_referencerange_type_display,
                        obs_referencerange_type_text,
                        obs_referencerange_appliesto_system,
                        obs_referencerange_appliesto_version,
                        obs_referencerange_appliesto_code,
                        obs_referencerange_appliesto_display,
                        obs_referencerange_appliesto_text,
                        obs_referencerange_age_low_value,
                        obs_referencerange_age_low_unit,
                        obs_referencerange_age_low_system,
                        obs_referencerange_age_low_code,
                        obs_referencerange_age_high_value,
                        obs_referencerange_age_high_unit,
                        obs_referencerange_age_high_system,
                        obs_referencerange_age_high_code,
                        obs_referencerange_text,
                        obs_hasmember_id,
                        obs_hasmember_type,
                        obs_hasmember_identifier_use,
                        obs_hasmember_identifier_type_system,
                        obs_hasmember_identifier_type_version,
                        obs_hasmember_identifier_type_code,
                        obs_hasmember_identifier_type_display,
                        obs_hasmember_identifier_type_text,
                        obs_hasmember_display,
                        input_datetime
                    )
                    VALUES (
                        current_record.obs_id,
                        current_record.obs_encounter_id,
                        current_record.obs_patient_id,
                        current_record.obs_partof_id,
                        current_record.obs_identifier_use,
                        current_record.obs_identifier_type_system,
                        current_record.obs_identifier_type_version,
                        current_record.obs_identifier_type_code,
                        current_record.obs_identifier_type_display,
                        current_record.obs_identifier_type_text,
                        current_record.obs_identifier_system,
                        current_record.obs_identifier_value,
                        current_record.obs_identifier_start,
                        current_record.obs_identifier_end,
                        current_record.obs_basedon_id,
                        current_record.obs_basedon_type,
                        current_record.obs_basedon_identifier_use,
                        current_record.obs_basedon_identifier_type_system,
                        current_record.obs_basedon_identifier_type_version,
                        current_record.obs_basedon_identifier_type_code,
                        current_record.obs_basedon_identifier_type_display,
                        current_record.obs_basedon_identifier_type_text,
                        current_record.obs_basedon_display,
                        current_record.obs_status,
                        current_record.obs_category_system,
                        current_record.obs_category_version,
                        current_record.obs_category_code,
                        current_record.obs_category_display,
                        current_record.obs_category_text,
                        current_record.obs_code_system,
                        current_record.obs_code_version,
                        current_record.obs_code_code,
                        current_record.obs_code_display,
                        current_record.obs_code_text,
                        current_record.obs_effectivedatetime,
                        current_record.obs_issued,
                        current_record.obs_valuerange_low_value,
                        current_record.obs_valuerange_low_unit,
                        current_record.obs_valuerange_low_system,
                        current_record.obs_valuerange_low_code,
                        current_record.obs_valuerange_high_value,
                        current_record.obs_valuerange_high_unit,
                        current_record.obs_valuerange_high_system,
                        current_record.obs_valuerange_high_code,
                        current_record.obs_valueratio_numerator_value,
                        current_record.obs_valueratio_numerator_comparator,
                        current_record.obs_valueratio_numerator_unit,
                        current_record.obs_valueratio_numerator_system,
                        current_record.obs_valueratio_numerator_code,
                        current_record.obs_valueratio_denominator_value,
                        current_record.obs_valueratio_denominator_comparator,
                        current_record.obs_valueratio_denominator_unit,
                        current_record.obs_valueratio_denominator_system,
                        current_record.obs_valueratio_denominator_code,
                        current_record.obs_valuequantity_value,
                        current_record.obs_valuequantity_comparator,
                        current_record.obs_valuequantity_unit,
                        current_record.obs_valuequantity_system,
                        current_record.obs_valuequantity_code,
                        current_record.obs_valuecodableconcept_system,
                        current_record.obs_valuecodableconcept_version,
                        current_record.obs_valuecodableconcept_code,
                        current_record.obs_valuecodableconcept_display,
                        current_record.obs_valuecodableconcept_text,
                        current_record.obs_dataabsentreason_system,
                        current_record.obs_dataabsentreason_version,
                        current_record.obs_dataabsentreason_code,
                        current_record.obs_dataabsentreason_display,
                        current_record.obs_dataabsentreason_text,
                        current_record.obs_note_authorstring,
                        current_record.obs_note_authorreference_id,
                        current_record.obs_note_authorreference_type,
                        current_record.obs_note_authorreference_identifier_use,
                        current_record.obs_note_authorreference_identifier_type_system,
                        current_record.obs_note_authorreference_identifier_type_version,
                        current_record.obs_note_authorreference_identifier_type_code,
                        current_record.obs_note_authorreference_identifier_type_display,
                        current_record.obs_note_authorreference_identifier_type_text,
                        current_record.obs_note_authorreference_display,
                        current_record.obs_note_time,
                        current_record.obs_note_text,
                        current_record.obs_method_system,
                        current_record.obs_method_version,
                        current_record.obs_method_code,
                        current_record.obs_method_display,
                        current_record.obs_method_text,
                        current_record.obs_performer_id,
                        current_record.obs_performer_type,
                        current_record.obs_performer_identifier_use,
                        current_record.obs_performer_identifier_type_system,
                        current_record.obs_performer_identifier_type_version,
                        current_record.obs_performer_identifier_type_code,
                        current_record.obs_performer_identifier_type_display,
                        current_record.obs_performer_identifier_type_text,
                        current_record.obs_performer_display,
                        current_record.obs_referencerange_low_value,
                        current_record.obs_referencerange_low_unit,
                        current_record.obs_referencerange_low_system,
                        current_record.obs_referencerange_low_code,
                        current_record.obs_referencerange_high_value,
                        current_record.obs_referencerange_high_unit,
                        current_record.obs_referencerange_high_system,
                        current_record.obs_referencerange_high_code,
                        current_record.obs_referencerange_type_system,
                        current_record.obs_referencerange_type_version,
                        current_record.obs_referencerange_type_code,
                        current_record.obs_referencerange_type_display,
                        current_record.obs_referencerange_type_text,
                        current_record.obs_referencerange_appliesto_system,
                        current_record.obs_referencerange_appliesto_version,
                        current_record.obs_referencerange_appliesto_code,
                        current_record.obs_referencerange_appliesto_display,
                        current_record.obs_referencerange_appliesto_text,
                        current_record.obs_referencerange_age_low_value,
                        current_record.obs_referencerange_age_low_unit,
                        current_record.obs_referencerange_age_low_system,
                        current_record.obs_referencerange_age_low_code,
                        current_record.obs_referencerange_age_high_value,
                        current_record.obs_referencerange_age_high_unit,
                        current_record.obs_referencerange_age_high_system,
                        current_record.obs_referencerange_age_high_code,
                        current_record.obs_referencerange_text,
                        current_record.obs_hasmember_id,
                        current_record.obs_hasmember_type,
                        current_record.obs_hasmember_identifier_use,
                        current_record.obs_hasmember_identifier_type_system,
                        current_record.obs_hasmember_identifier_type_version,
                        current_record.obs_hasmember_identifier_type_code,
                        current_record.obs_hasmember_identifier_type_display,
                        current_record.obs_hasmember_identifier_type_text,
                        current_record.obs_hasmember_display,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.observation_raw WHERE observation_id = current_record.observation_id;
                ELSE
                UPDATE db_log.observation_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.obs_id::text,'#NULL#') = COALESCE(current_record.obs_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_encounter_id::text,'#NULL#') = COALESCE(current_record.obs_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_patient_id::text,'#NULL#') = COALESCE(current_record.obs_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_partof_id::text,'#NULL#') = COALESCE(current_record.obs_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_system::text,'#NULL#') = COALESCE(current_record.obs_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_value::text,'#NULL#') = COALESCE(current_record.obs_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_start::text,'#NULL#') = COALESCE(current_record.obs_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.obs_identifier_end::text,'#NULL#') = COALESCE(current_record.obs_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_id::text,'#NULL#') = COALESCE(current_record.obs_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_type::text,'#NULL#') = COALESCE(current_record.obs_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_basedon_display::text,'#NULL#') = COALESCE(current_record.obs_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_status::text,'#NULL#') = COALESCE(current_record.obs_status::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_system::text,'#NULL#') = COALESCE(current_record.obs_category_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_version::text,'#NULL#') = COALESCE(current_record.obs_category_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_code::text,'#NULL#') = COALESCE(current_record.obs_category_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_display::text,'#NULL#') = COALESCE(current_record.obs_category_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_category_text::text,'#NULL#') = COALESCE(current_record.obs_category_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_system::text,'#NULL#') = COALESCE(current_record.obs_code_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_version::text,'#NULL#') = COALESCE(current_record.obs_code_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_code::text,'#NULL#') = COALESCE(current_record.obs_code_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_display::text,'#NULL#') = COALESCE(current_record.obs_code_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_code_text::text,'#NULL#') = COALESCE(current_record.obs_code_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_effectivedatetime::text,'#NULL#') = COALESCE(current_record.obs_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.obs_issued::text,'#NULL#') = COALESCE(current_record.obs_issued::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_value::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_unit::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_system::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_low_code::text,'#NULL#') = COALESCE(current_record.obs_valuerange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_value::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_unit::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_system::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuerange_high_code::text,'#NULL#') = COALESCE(current_record.obs_valuerange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_value::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_comparator::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_unit::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_system::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_numerator_code::text,'#NULL#') = COALESCE(current_record.obs_valueratio_numerator_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_value::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_comparator::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_comparator::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_unit::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_system::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valueratio_denominator_code::text,'#NULL#') = COALESCE(current_record.obs_valueratio_denominator_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_value::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_comparator::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_comparator::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_unit::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_system::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuequantity_code::text,'#NULL#') = COALESCE(current_record.obs_valuequantity_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_system::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_version::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_code::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_display::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_valuecodableconcept_text::text,'#NULL#') = COALESCE(current_record.obs_valuecodableconcept_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_system::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_version::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_code::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_display::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_dataabsentreason_text::text,'#NULL#') = COALESCE(current_record.obs_dataabsentreason_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorstring::text,'#NULL#') = COALESCE(current_record.obs_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.obs_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_time::text,'#NULL#') = COALESCE(current_record.obs_note_time::text,'#NULL#') AND
                      COALESCE(target_record.obs_note_text::text,'#NULL#') = COALESCE(current_record.obs_note_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_system::text,'#NULL#') = COALESCE(current_record.obs_method_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_version::text,'#NULL#') = COALESCE(current_record.obs_method_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_code::text,'#NULL#') = COALESCE(current_record.obs_method_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_display::text,'#NULL#') = COALESCE(current_record.obs_method_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_method_text::text,'#NULL#') = COALESCE(current_record.obs_method_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_id::text,'#NULL#') = COALESCE(current_record.obs_performer_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_type::text,'#NULL#') = COALESCE(current_record.obs_performer_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_performer_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_performer_display::text,'#NULL#') = COALESCE(current_record.obs_performer_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_low_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_low_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_high_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_high_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_version::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_display::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_type_text::text,'#NULL#') = COALESCE(current_record.obs_referencerange_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_version::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_display::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_appliesto_text::text,'#NULL#') = COALESCE(current_record.obs_referencerange_appliesto_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_low_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_low_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_value::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_value::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_unit::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_unit::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_system::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_age_high_code::text,'#NULL#') = COALESCE(current_record.obs_referencerange_age_high_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_referencerange_text::text,'#NULL#') = COALESCE(current_record.obs_referencerange_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_id::text,'#NULL#') = COALESCE(current_record.obs_hasmember_id::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_type::text,'#NULL#') = COALESCE(current_record.obs_hasmember_type::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_use::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_system::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_version::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_code::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_display::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_identifier_type_text::text,'#NULL#') = COALESCE(current_record.obs_hasmember_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.obs_hasmember_display::text,'#NULL#') = COALESCE(current_record.obs_hasmember_display::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.observation_raw WHERE observation_id = current_record.observation_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.observation_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE observation_id = current_record.observation_id;
            END;
    END LOOP;
    -- END observation
    -- Start diagnosticreport
    FOR current_record IN (SELECT * FROM cds2db_in.diagnosticreport_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.diagnosticreport_raw target_record
                WHERE COALESCE(target_record.diagrep_id::text,'#NULL#') = COALESCE(current_record.diagrep_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_encounter_id::text,'#NULL#') = COALESCE(current_record.diagrep_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_patient_id::text,'#NULL#') = COALESCE(current_record.diagrep_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_partof_id::text,'#NULL#') = COALESCE(current_record.diagrep_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_use::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_system::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_version::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_code::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_display::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_text::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_system::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_value::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_start::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_end::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_result_id::text,'#NULL#') = COALESCE(current_record.diagrep_result_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_basedon_id::text,'#NULL#') = COALESCE(current_record.diagrep_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_status::text,'#NULL#') = COALESCE(current_record.diagrep_status::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_system::text,'#NULL#') = COALESCE(current_record.diagrep_category_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_version::text,'#NULL#') = COALESCE(current_record.diagrep_category_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_code::text,'#NULL#') = COALESCE(current_record.diagrep_category_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_display::text,'#NULL#') = COALESCE(current_record.diagrep_category_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_text::text,'#NULL#') = COALESCE(current_record.diagrep_category_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_system::text,'#NULL#') = COALESCE(current_record.diagrep_code_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_version::text,'#NULL#') = COALESCE(current_record.diagrep_code_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_code::text,'#NULL#') = COALESCE(current_record.diagrep_code_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_display::text,'#NULL#') = COALESCE(current_record.diagrep_code_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_text::text,'#NULL#') = COALESCE(current_record.diagrep_code_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_effectivedatetime::text,'#NULL#') = COALESCE(current_record.diagrep_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_issued::text,'#NULL#') = COALESCE(current_record.diagrep_issued::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_id::text,'#NULL#') = COALESCE(current_record.diagrep_performer_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_type::text,'#NULL#') = COALESCE(current_record.diagrep_performer_type::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_use::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_system::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_version::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_code::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_display::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_text::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_display::text,'#NULL#') = COALESCE(current_record.diagrep_performer_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusion::text,'#NULL#') = COALESCE(current_record.diagrep_conclusion::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_system::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_version::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_code::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_display::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_text::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_text::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.diagnosticreport_raw (
                        diagrep_id,
                        diagrep_encounter_id,
                        diagrep_patient_id,
                        diagrep_partof_id,
                        diagrep_identifier_use,
                        diagrep_identifier_type_system,
                        diagrep_identifier_type_version,
                        diagrep_identifier_type_code,
                        diagrep_identifier_type_display,
                        diagrep_identifier_type_text,
                        diagrep_identifier_system,
                        diagrep_identifier_value,
                        diagrep_identifier_start,
                        diagrep_identifier_end,
                        diagrep_result_id,
                        diagrep_basedon_id,
                        diagrep_status,
                        diagrep_category_system,
                        diagrep_category_version,
                        diagrep_category_code,
                        diagrep_category_display,
                        diagrep_category_text,
                        diagrep_code_system,
                        diagrep_code_version,
                        diagrep_code_code,
                        diagrep_code_display,
                        diagrep_code_text,
                        diagrep_effectivedatetime,
                        diagrep_issued,
                        diagrep_performer_id,
                        diagrep_performer_type,
                        diagrep_performer_identifier_use,
                        diagrep_performer_identifier_type_system,
                        diagrep_performer_identifier_type_version,
                        diagrep_performer_identifier_type_code,
                        diagrep_performer_identifier_type_display,
                        diagrep_performer_identifier_type_text,
                        diagrep_performer_display,
                        diagrep_conclusion,
                        diagrep_conclusioncode_system,
                        diagrep_conclusioncode_version,
                        diagrep_conclusioncode_code,
                        diagrep_conclusioncode_display,
                        diagrep_conclusioncode_text,
                        input_datetime
                    )
                    VALUES (
                        current_record.diagrep_id,
                        current_record.diagrep_encounter_id,
                        current_record.diagrep_patient_id,
                        current_record.diagrep_partof_id,
                        current_record.diagrep_identifier_use,
                        current_record.diagrep_identifier_type_system,
                        current_record.diagrep_identifier_type_version,
                        current_record.diagrep_identifier_type_code,
                        current_record.diagrep_identifier_type_display,
                        current_record.diagrep_identifier_type_text,
                        current_record.diagrep_identifier_system,
                        current_record.diagrep_identifier_value,
                        current_record.diagrep_identifier_start,
                        current_record.diagrep_identifier_end,
                        current_record.diagrep_result_id,
                        current_record.diagrep_basedon_id,
                        current_record.diagrep_status,
                        current_record.diagrep_category_system,
                        current_record.diagrep_category_version,
                        current_record.diagrep_category_code,
                        current_record.diagrep_category_display,
                        current_record.diagrep_category_text,
                        current_record.diagrep_code_system,
                        current_record.diagrep_code_version,
                        current_record.diagrep_code_code,
                        current_record.diagrep_code_display,
                        current_record.diagrep_code_text,
                        current_record.diagrep_effectivedatetime,
                        current_record.diagrep_issued,
                        current_record.diagrep_performer_id,
                        current_record.diagrep_performer_type,
                        current_record.diagrep_performer_identifier_use,
                        current_record.diagrep_performer_identifier_type_system,
                        current_record.diagrep_performer_identifier_type_version,
                        current_record.diagrep_performer_identifier_type_code,
                        current_record.diagrep_performer_identifier_type_display,
                        current_record.diagrep_performer_identifier_type_text,
                        current_record.diagrep_performer_display,
                        current_record.diagrep_conclusion,
                        current_record.diagrep_conclusioncode_system,
                        current_record.diagrep_conclusioncode_version,
                        current_record.diagrep_conclusioncode_code,
                        current_record.diagrep_conclusioncode_display,
                        current_record.diagrep_conclusioncode_text,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.diagnosticreport_raw WHERE diagnosticreport_id = current_record.diagnosticreport_id;
                ELSE
                UPDATE db_log.diagnosticreport_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.diagrep_id::text,'#NULL#') = COALESCE(current_record.diagrep_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_encounter_id::text,'#NULL#') = COALESCE(current_record.diagrep_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_patient_id::text,'#NULL#') = COALESCE(current_record.diagrep_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_partof_id::text,'#NULL#') = COALESCE(current_record.diagrep_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_use::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_system::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_version::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_code::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_display::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_type_text::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_system::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_value::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_start::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_identifier_end::text,'#NULL#') = COALESCE(current_record.diagrep_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_result_id::text,'#NULL#') = COALESCE(current_record.diagrep_result_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_basedon_id::text,'#NULL#') = COALESCE(current_record.diagrep_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_status::text,'#NULL#') = COALESCE(current_record.diagrep_status::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_system::text,'#NULL#') = COALESCE(current_record.diagrep_category_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_version::text,'#NULL#') = COALESCE(current_record.diagrep_category_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_code::text,'#NULL#') = COALESCE(current_record.diagrep_category_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_display::text,'#NULL#') = COALESCE(current_record.diagrep_category_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_category_text::text,'#NULL#') = COALESCE(current_record.diagrep_category_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_system::text,'#NULL#') = COALESCE(current_record.diagrep_code_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_version::text,'#NULL#') = COALESCE(current_record.diagrep_code_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_code::text,'#NULL#') = COALESCE(current_record.diagrep_code_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_display::text,'#NULL#') = COALESCE(current_record.diagrep_code_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_code_text::text,'#NULL#') = COALESCE(current_record.diagrep_code_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_effectivedatetime::text,'#NULL#') = COALESCE(current_record.diagrep_effectivedatetime::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_issued::text,'#NULL#') = COALESCE(current_record.diagrep_issued::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_id::text,'#NULL#') = COALESCE(current_record.diagrep_performer_id::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_type::text,'#NULL#') = COALESCE(current_record.diagrep_performer_type::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_use::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_system::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_version::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_code::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_display::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_identifier_type_text::text,'#NULL#') = COALESCE(current_record.diagrep_performer_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_performer_display::text,'#NULL#') = COALESCE(current_record.diagrep_performer_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusion::text,'#NULL#') = COALESCE(current_record.diagrep_conclusion::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_system::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_system::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_version::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_version::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_code::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_code::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_display::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_display::text,'#NULL#') AND
                      COALESCE(target_record.diagrep_conclusioncode_text::text,'#NULL#') = COALESCE(current_record.diagrep_conclusioncode_text::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.diagnosticreport_raw WHERE diagnosticreport_id = current_record.diagnosticreport_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.diagnosticreport_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE diagnosticreport_id = current_record.diagnosticreport_id;
            END;
    END LOOP;
    -- END diagnosticreport
    -- Start servicerequest
    FOR current_record IN (SELECT * FROM cds2db_in.servicerequest_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.servicerequest_raw target_record
                WHERE COALESCE(target_record.servreq_id::text,'#NULL#') = COALESCE(current_record.servreq_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_encounter_id::text,'#NULL#') = COALESCE(current_record.servreq_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_patient_id::text,'#NULL#') = COALESCE(current_record.servreq_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_system::text,'#NULL#') = COALESCE(current_record.servreq_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_value::text,'#NULL#') = COALESCE(current_record.servreq_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_start::text,'#NULL#') = COALESCE(current_record.servreq_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_end::text,'#NULL#') = COALESCE(current_record.servreq_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_id::text,'#NULL#') = COALESCE(current_record.servreq_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_type::text,'#NULL#') = COALESCE(current_record.servreq_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_display::text,'#NULL#') = COALESCE(current_record.servreq_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_status::text,'#NULL#') = COALESCE(current_record.servreq_status::text,'#NULL#') AND
                      COALESCE(target_record.servreq_intent::text,'#NULL#') = COALESCE(current_record.servreq_intent::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_system::text,'#NULL#') = COALESCE(current_record.servreq_category_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_version::text,'#NULL#') = COALESCE(current_record.servreq_category_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_code::text,'#NULL#') = COALESCE(current_record.servreq_category_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_display::text,'#NULL#') = COALESCE(current_record.servreq_category_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_text::text,'#NULL#') = COALESCE(current_record.servreq_category_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_system::text,'#NULL#') = COALESCE(current_record.servreq_code_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_version::text,'#NULL#') = COALESCE(current_record.servreq_code_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_code::text,'#NULL#') = COALESCE(current_record.servreq_code_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_display::text,'#NULL#') = COALESCE(current_record.servreq_code_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_text::text,'#NULL#') = COALESCE(current_record.servreq_code_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_authoredon::text,'#NULL#') = COALESCE(current_record.servreq_authoredon::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_id::text,'#NULL#') = COALESCE(current_record.servreq_requester_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_type::text,'#NULL#') = COALESCE(current_record.servreq_requester_type::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_display::text,'#NULL#') = COALESCE(current_record.servreq_requester_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_id::text,'#NULL#') = COALESCE(current_record.servreq_performer_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_type::text,'#NULL#') = COALESCE(current_record.servreq_performer_type::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_display::text,'#NULL#') = COALESCE(current_record.servreq_performer_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_system::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_version::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_code::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_display::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_text::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_text::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.servicerequest_raw (
                        servreq_id,
                        servreq_encounter_id,
                        servreq_patient_id,
                        servreq_identifier_use,
                        servreq_identifier_type_system,
                        servreq_identifier_type_version,
                        servreq_identifier_type_code,
                        servreq_identifier_type_display,
                        servreq_identifier_type_text,
                        servreq_identifier_system,
                        servreq_identifier_value,
                        servreq_identifier_start,
                        servreq_identifier_end,
                        servreq_basedon_id,
                        servreq_basedon_type,
                        servreq_basedon_identifier_use,
                        servreq_basedon_identifier_type_system,
                        servreq_basedon_identifier_type_version,
                        servreq_basedon_identifier_type_code,
                        servreq_basedon_identifier_type_display,
                        servreq_basedon_identifier_type_text,
                        servreq_basedon_display,
                        servreq_status,
                        servreq_intent,
                        servreq_category_system,
                        servreq_category_version,
                        servreq_category_code,
                        servreq_category_display,
                        servreq_category_text,
                        servreq_code_system,
                        servreq_code_version,
                        servreq_code_code,
                        servreq_code_display,
                        servreq_code_text,
                        servreq_authoredon,
                        servreq_requester_id,
                        servreq_requester_type,
                        servreq_requester_identifier_use,
                        servreq_requester_identifier_type_system,
                        servreq_requester_identifier_type_version,
                        servreq_requester_identifier_type_code,
                        servreq_requester_identifier_type_display,
                        servreq_requester_identifier_type_text,
                        servreq_requester_display,
                        servreq_performer_id,
                        servreq_performer_type,
                        servreq_performer_identifier_use,
                        servreq_performer_identifier_type_system,
                        servreq_performer_identifier_type_version,
                        servreq_performer_identifier_type_code,
                        servreq_performer_identifier_type_display,
                        servreq_performer_identifier_type_text,
                        servreq_performer_display,
                        servreq_locationcode_system,
                        servreq_locationcode_version,
                        servreq_locationcode_code,
                        servreq_locationcode_display,
                        servreq_locationcode_text,
                        input_datetime
                    )
                    VALUES (
                        current_record.servreq_id,
                        current_record.servreq_encounter_id,
                        current_record.servreq_patient_id,
                        current_record.servreq_identifier_use,
                        current_record.servreq_identifier_type_system,
                        current_record.servreq_identifier_type_version,
                        current_record.servreq_identifier_type_code,
                        current_record.servreq_identifier_type_display,
                        current_record.servreq_identifier_type_text,
                        current_record.servreq_identifier_system,
                        current_record.servreq_identifier_value,
                        current_record.servreq_identifier_start,
                        current_record.servreq_identifier_end,
                        current_record.servreq_basedon_id,
                        current_record.servreq_basedon_type,
                        current_record.servreq_basedon_identifier_use,
                        current_record.servreq_basedon_identifier_type_system,
                        current_record.servreq_basedon_identifier_type_version,
                        current_record.servreq_basedon_identifier_type_code,
                        current_record.servreq_basedon_identifier_type_display,
                        current_record.servreq_basedon_identifier_type_text,
                        current_record.servreq_basedon_display,
                        current_record.servreq_status,
                        current_record.servreq_intent,
                        current_record.servreq_category_system,
                        current_record.servreq_category_version,
                        current_record.servreq_category_code,
                        current_record.servreq_category_display,
                        current_record.servreq_category_text,
                        current_record.servreq_code_system,
                        current_record.servreq_code_version,
                        current_record.servreq_code_code,
                        current_record.servreq_code_display,
                        current_record.servreq_code_text,
                        current_record.servreq_authoredon,
                        current_record.servreq_requester_id,
                        current_record.servreq_requester_type,
                        current_record.servreq_requester_identifier_use,
                        current_record.servreq_requester_identifier_type_system,
                        current_record.servreq_requester_identifier_type_version,
                        current_record.servreq_requester_identifier_type_code,
                        current_record.servreq_requester_identifier_type_display,
                        current_record.servreq_requester_identifier_type_text,
                        current_record.servreq_requester_display,
                        current_record.servreq_performer_id,
                        current_record.servreq_performer_type,
                        current_record.servreq_performer_identifier_use,
                        current_record.servreq_performer_identifier_type_system,
                        current_record.servreq_performer_identifier_type_version,
                        current_record.servreq_performer_identifier_type_code,
                        current_record.servreq_performer_identifier_type_display,
                        current_record.servreq_performer_identifier_type_text,
                        current_record.servreq_performer_display,
                        current_record.servreq_locationcode_system,
                        current_record.servreq_locationcode_version,
                        current_record.servreq_locationcode_code,
                        current_record.servreq_locationcode_display,
                        current_record.servreq_locationcode_text,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.servicerequest_raw WHERE servicerequest_id = current_record.servicerequest_id;
                ELSE
                UPDATE db_log.servicerequest_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.servreq_id::text,'#NULL#') = COALESCE(current_record.servreq_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_encounter_id::text,'#NULL#') = COALESCE(current_record.servreq_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_patient_id::text,'#NULL#') = COALESCE(current_record.servreq_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_system::text,'#NULL#') = COALESCE(current_record.servreq_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_value::text,'#NULL#') = COALESCE(current_record.servreq_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_start::text,'#NULL#') = COALESCE(current_record.servreq_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.servreq_identifier_end::text,'#NULL#') = COALESCE(current_record.servreq_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_id::text,'#NULL#') = COALESCE(current_record.servreq_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_type::text,'#NULL#') = COALESCE(current_record.servreq_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_basedon_display::text,'#NULL#') = COALESCE(current_record.servreq_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_status::text,'#NULL#') = COALESCE(current_record.servreq_status::text,'#NULL#') AND
                      COALESCE(target_record.servreq_intent::text,'#NULL#') = COALESCE(current_record.servreq_intent::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_system::text,'#NULL#') = COALESCE(current_record.servreq_category_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_version::text,'#NULL#') = COALESCE(current_record.servreq_category_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_code::text,'#NULL#') = COALESCE(current_record.servreq_category_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_display::text,'#NULL#') = COALESCE(current_record.servreq_category_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_category_text::text,'#NULL#') = COALESCE(current_record.servreq_category_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_system::text,'#NULL#') = COALESCE(current_record.servreq_code_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_version::text,'#NULL#') = COALESCE(current_record.servreq_code_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_code::text,'#NULL#') = COALESCE(current_record.servreq_code_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_display::text,'#NULL#') = COALESCE(current_record.servreq_code_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_code_text::text,'#NULL#') = COALESCE(current_record.servreq_code_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_authoredon::text,'#NULL#') = COALESCE(current_record.servreq_authoredon::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_id::text,'#NULL#') = COALESCE(current_record.servreq_requester_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_type::text,'#NULL#') = COALESCE(current_record.servreq_requester_type::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_requester_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_requester_display::text,'#NULL#') = COALESCE(current_record.servreq_requester_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_id::text,'#NULL#') = COALESCE(current_record.servreq_performer_id::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_type::text,'#NULL#') = COALESCE(current_record.servreq_performer_type::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_use::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_system::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_version::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_code::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_display::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_identifier_type_text::text,'#NULL#') = COALESCE(current_record.servreq_performer_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.servreq_performer_display::text,'#NULL#') = COALESCE(current_record.servreq_performer_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_system::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_system::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_version::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_version::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_code::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_code::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_display::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_display::text,'#NULL#') AND
                      COALESCE(target_record.servreq_locationcode_text::text,'#NULL#') = COALESCE(current_record.servreq_locationcode_text::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.servicerequest_raw WHERE servicerequest_id = current_record.servicerequest_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.servicerequest_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE servicerequest_id = current_record.servicerequest_id;
            END;
    END LOOP;
    -- END servicerequest
    -- Start procedure
    FOR current_record IN (SELECT * FROM cds2db_in.procedure_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.procedure_raw target_record
                WHERE COALESCE(target_record.proc_id::text,'#NULL#') = COALESCE(current_record.proc_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_encounter_id::text,'#NULL#') = COALESCE(current_record.proc_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_patient_id::text,'#NULL#') = COALESCE(current_record.proc_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_partof_id::text,'#NULL#') = COALESCE(current_record.proc_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_system::text,'#NULL#') = COALESCE(current_record.proc_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_value::text,'#NULL#') = COALESCE(current_record.proc_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_start::text,'#NULL#') = COALESCE(current_record.proc_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_end::text,'#NULL#') = COALESCE(current_record.proc_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_id::text,'#NULL#') = COALESCE(current_record.proc_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_type::text,'#NULL#') = COALESCE(current_record.proc_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_display::text,'#NULL#') = COALESCE(current_record.proc_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_status::text,'#NULL#') = COALESCE(current_record.proc_status::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_system::text,'#NULL#') = COALESCE(current_record.proc_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_version::text,'#NULL#') = COALESCE(current_record.proc_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_code::text,'#NULL#') = COALESCE(current_record.proc_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_display::text,'#NULL#') = COALESCE(current_record.proc_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_text::text,'#NULL#') = COALESCE(current_record.proc_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_system::text,'#NULL#') = COALESCE(current_record.proc_category_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_version::text,'#NULL#') = COALESCE(current_record.proc_category_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_code::text,'#NULL#') = COALESCE(current_record.proc_category_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_display::text,'#NULL#') = COALESCE(current_record.proc_category_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_text::text,'#NULL#') = COALESCE(current_record.proc_category_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_system::text,'#NULL#') = COALESCE(current_record.proc_code_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_version::text,'#NULL#') = COALESCE(current_record.proc_code_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_code::text,'#NULL#') = COALESCE(current_record.proc_code_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_display::text,'#NULL#') = COALESCE(current_record.proc_code_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_text::text,'#NULL#') = COALESCE(current_record.proc_code_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_performeddatetime::text,'#NULL#') = COALESCE(current_record.proc_performeddatetime::text,'#NULL#') AND
                      COALESCE(target_record.proc_performedperiod_start::text,'#NULL#') = COALESCE(current_record.proc_performedperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.proc_performedperiod_end::text,'#NULL#') = COALESCE(current_record.proc_performedperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_system::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_version::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_code::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_display::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_text::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_id::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_type::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_display::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorstring::text,'#NULL#') = COALESCE(current_record.proc_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_time::text,'#NULL#') = COALESCE(current_record.proc_note_time::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_text::text,'#NULL#') = COALESCE(current_record.proc_note_text::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.procedure_raw (
                        proc_id,
                        proc_encounter_id,
                        proc_patient_id,
                        proc_partof_id,
                        proc_identifier_use,
                        proc_identifier_type_system,
                        proc_identifier_type_version,
                        proc_identifier_type_code,
                        proc_identifier_type_display,
                        proc_identifier_type_text,
                        proc_identifier_system,
                        proc_identifier_value,
                        proc_identifier_start,
                        proc_identifier_end,
                        proc_basedon_id,
                        proc_basedon_type,
                        proc_basedon_identifier_use,
                        proc_basedon_identifier_type_system,
                        proc_basedon_identifier_type_version,
                        proc_basedon_identifier_type_code,
                        proc_basedon_identifier_type_display,
                        proc_basedon_identifier_type_text,
                        proc_basedon_display,
                        proc_status,
                        proc_statusreason_system,
                        proc_statusreason_version,
                        proc_statusreason_code,
                        proc_statusreason_display,
                        proc_statusreason_text,
                        proc_category_system,
                        proc_category_version,
                        proc_category_code,
                        proc_category_display,
                        proc_category_text,
                        proc_code_system,
                        proc_code_version,
                        proc_code_code,
                        proc_code_display,
                        proc_code_text,
                        proc_performeddatetime,
                        proc_performedperiod_start,
                        proc_performedperiod_end,
                        proc_reasoncode_system,
                        proc_reasoncode_version,
                        proc_reasoncode_code,
                        proc_reasoncode_display,
                        proc_reasoncode_text,
                        proc_reasonreference_id,
                        proc_reasonreference_type,
                        proc_reasonreference_identifier_use,
                        proc_reasonreference_identifier_type_system,
                        proc_reasonreference_identifier_type_version,
                        proc_reasonreference_identifier_type_code,
                        proc_reasonreference_identifier_type_display,
                        proc_reasonreference_identifier_type_text,
                        proc_reasonreference_display,
                        proc_note_authorstring,
                        proc_note_authorreference_id,
                        proc_note_authorreference_type,
                        proc_note_authorreference_identifier_use,
                        proc_note_authorreference_identifier_type_system,
                        proc_note_authorreference_identifier_type_version,
                        proc_note_authorreference_identifier_type_code,
                        proc_note_authorreference_identifier_type_display,
                        proc_note_authorreference_identifier_type_text,
                        proc_note_authorreference_display,
                        proc_note_time,
                        proc_note_text,
                        input_datetime
                    )
                    VALUES (
                        current_record.proc_id,
                        current_record.proc_encounter_id,
                        current_record.proc_patient_id,
                        current_record.proc_partof_id,
                        current_record.proc_identifier_use,
                        current_record.proc_identifier_type_system,
                        current_record.proc_identifier_type_version,
                        current_record.proc_identifier_type_code,
                        current_record.proc_identifier_type_display,
                        current_record.proc_identifier_type_text,
                        current_record.proc_identifier_system,
                        current_record.proc_identifier_value,
                        current_record.proc_identifier_start,
                        current_record.proc_identifier_end,
                        current_record.proc_basedon_id,
                        current_record.proc_basedon_type,
                        current_record.proc_basedon_identifier_use,
                        current_record.proc_basedon_identifier_type_system,
                        current_record.proc_basedon_identifier_type_version,
                        current_record.proc_basedon_identifier_type_code,
                        current_record.proc_basedon_identifier_type_display,
                        current_record.proc_basedon_identifier_type_text,
                        current_record.proc_basedon_display,
                        current_record.proc_status,
                        current_record.proc_statusreason_system,
                        current_record.proc_statusreason_version,
                        current_record.proc_statusreason_code,
                        current_record.proc_statusreason_display,
                        current_record.proc_statusreason_text,
                        current_record.proc_category_system,
                        current_record.proc_category_version,
                        current_record.proc_category_code,
                        current_record.proc_category_display,
                        current_record.proc_category_text,
                        current_record.proc_code_system,
                        current_record.proc_code_version,
                        current_record.proc_code_code,
                        current_record.proc_code_display,
                        current_record.proc_code_text,
                        current_record.proc_performeddatetime,
                        current_record.proc_performedperiod_start,
                        current_record.proc_performedperiod_end,
                        current_record.proc_reasoncode_system,
                        current_record.proc_reasoncode_version,
                        current_record.proc_reasoncode_code,
                        current_record.proc_reasoncode_display,
                        current_record.proc_reasoncode_text,
                        current_record.proc_reasonreference_id,
                        current_record.proc_reasonreference_type,
                        current_record.proc_reasonreference_identifier_use,
                        current_record.proc_reasonreference_identifier_type_system,
                        current_record.proc_reasonreference_identifier_type_version,
                        current_record.proc_reasonreference_identifier_type_code,
                        current_record.proc_reasonreference_identifier_type_display,
                        current_record.proc_reasonreference_identifier_type_text,
                        current_record.proc_reasonreference_display,
                        current_record.proc_note_authorstring,
                        current_record.proc_note_authorreference_id,
                        current_record.proc_note_authorreference_type,
                        current_record.proc_note_authorreference_identifier_use,
                        current_record.proc_note_authorreference_identifier_type_system,
                        current_record.proc_note_authorreference_identifier_type_version,
                        current_record.proc_note_authorreference_identifier_type_code,
                        current_record.proc_note_authorreference_identifier_type_display,
                        current_record.proc_note_authorreference_identifier_type_text,
                        current_record.proc_note_authorreference_display,
                        current_record.proc_note_time,
                        current_record.proc_note_text,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.procedure_raw WHERE procedure_id = current_record.procedure_id;
                ELSE
                UPDATE db_log.procedure_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.proc_id::text,'#NULL#') = COALESCE(current_record.proc_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_encounter_id::text,'#NULL#') = COALESCE(current_record.proc_encounter_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_patient_id::text,'#NULL#') = COALESCE(current_record.proc_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_partof_id::text,'#NULL#') = COALESCE(current_record.proc_partof_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_system::text,'#NULL#') = COALESCE(current_record.proc_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_value::text,'#NULL#') = COALESCE(current_record.proc_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_start::text,'#NULL#') = COALESCE(current_record.proc_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.proc_identifier_end::text,'#NULL#') = COALESCE(current_record.proc_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_id::text,'#NULL#') = COALESCE(current_record.proc_basedon_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_type::text,'#NULL#') = COALESCE(current_record.proc_basedon_type::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_basedon_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_basedon_display::text,'#NULL#') = COALESCE(current_record.proc_basedon_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_status::text,'#NULL#') = COALESCE(current_record.proc_status::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_system::text,'#NULL#') = COALESCE(current_record.proc_statusreason_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_version::text,'#NULL#') = COALESCE(current_record.proc_statusreason_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_code::text,'#NULL#') = COALESCE(current_record.proc_statusreason_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_display::text,'#NULL#') = COALESCE(current_record.proc_statusreason_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_statusreason_text::text,'#NULL#') = COALESCE(current_record.proc_statusreason_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_system::text,'#NULL#') = COALESCE(current_record.proc_category_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_version::text,'#NULL#') = COALESCE(current_record.proc_category_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_code::text,'#NULL#') = COALESCE(current_record.proc_category_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_display::text,'#NULL#') = COALESCE(current_record.proc_category_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_category_text::text,'#NULL#') = COALESCE(current_record.proc_category_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_system::text,'#NULL#') = COALESCE(current_record.proc_code_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_version::text,'#NULL#') = COALESCE(current_record.proc_code_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_code::text,'#NULL#') = COALESCE(current_record.proc_code_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_display::text,'#NULL#') = COALESCE(current_record.proc_code_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_code_text::text,'#NULL#') = COALESCE(current_record.proc_code_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_performeddatetime::text,'#NULL#') = COALESCE(current_record.proc_performeddatetime::text,'#NULL#') AND
                      COALESCE(target_record.proc_performedperiod_start::text,'#NULL#') = COALESCE(current_record.proc_performedperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.proc_performedperiod_end::text,'#NULL#') = COALESCE(current_record.proc_performedperiod_end::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_system::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_version::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_code::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_display::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasoncode_text::text,'#NULL#') = COALESCE(current_record.proc_reasoncode_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_id::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_type::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_type::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_reasonreference_display::text,'#NULL#') = COALESCE(current_record.proc_reasonreference_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorstring::text,'#NULL#') = COALESCE(current_record.proc_note_authorstring::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_id::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_id::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_type::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_type::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_use::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_system::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_version::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_code::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_display::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_identifier_type_text::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_authorreference_display::text,'#NULL#') = COALESCE(current_record.proc_note_authorreference_display::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_time::text,'#NULL#') = COALESCE(current_record.proc_note_time::text,'#NULL#') AND
                      COALESCE(target_record.proc_note_text::text,'#NULL#') = COALESCE(current_record.proc_note_text::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.procedure_raw WHERE procedure_id = current_record.procedure_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.procedure_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE procedure_id = current_record.procedure_id;
            END;
    END LOOP;
    -- END procedure
    -- Start consent
    FOR current_record IN (SELECT * FROM cds2db_in.consent_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.consent_raw target_record
                WHERE COALESCE(target_record.cons_id::text,'#NULL#') = COALESCE(current_record.cons_id::text,'#NULL#') AND
                      COALESCE(target_record.cons_patient_id::text,'#NULL#') = COALESCE(current_record.cons_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_use::text,'#NULL#') = COALESCE(current_record.cons_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_system::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_version::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_code::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_display::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_text::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_system::text,'#NULL#') = COALESCE(current_record.cons_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_value::text,'#NULL#') = COALESCE(current_record.cons_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_start::text,'#NULL#') = COALESCE(current_record.cons_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_end::text,'#NULL#') = COALESCE(current_record.cons_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.cons_status::text,'#NULL#') = COALESCE(current_record.cons_status::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_system::text,'#NULL#') = COALESCE(current_record.cons_scope_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_version::text,'#NULL#') = COALESCE(current_record.cons_scope_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_code::text,'#NULL#') = COALESCE(current_record.cons_scope_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_display::text,'#NULL#') = COALESCE(current_record.cons_scope_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_text::text,'#NULL#') = COALESCE(current_record.cons_scope_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_datetime::text,'#NULL#') = COALESCE(current_record.cons_datetime::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_type::text,'#NULL#') = COALESCE(current_record.cons_provision_type::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_period_start::text,'#NULL#') = COALESCE(current_record.cons_provision_period_start::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_period_end::text,'#NULL#') = COALESCE(current_record.cons_provision_period_end::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_system::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_version::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_code::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_display::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_text::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_system::text,'#NULL#') = COALESCE(current_record.cons_provision_code_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_version::text,'#NULL#') = COALESCE(current_record.cons_provision_code_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_code::text,'#NULL#') = COALESCE(current_record.cons_provision_code_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_display::text,'#NULL#') = COALESCE(current_record.cons_provision_code_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_text::text,'#NULL#') = COALESCE(current_record.cons_provision_code_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_dataperiod_start::text,'#NULL#') = COALESCE(current_record.cons_provision_dataperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_dataperiod_end::text,'#NULL#') = COALESCE(current_record.cons_provision_dataperiod_end::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.consent_raw (
                        cons_id,
                        cons_patient_id,
                        cons_identifier_use,
                        cons_identifier_type_system,
                        cons_identifier_type_version,
                        cons_identifier_type_code,
                        cons_identifier_type_display,
                        cons_identifier_type_text,
                        cons_identifier_system,
                        cons_identifier_value,
                        cons_identifier_start,
                        cons_identifier_end,
                        cons_status,
                        cons_scope_system,
                        cons_scope_version,
                        cons_scope_code,
                        cons_scope_display,
                        cons_scope_text,
                        cons_datetime,
                        cons_provision_type,
                        cons_provision_period_start,
                        cons_provision_period_end,
                        cons_provision_actor_role_system,
                        cons_provision_actor_role_version,
                        cons_provision_actor_role_code,
                        cons_provision_actor_role_display,
                        cons_provision_actor_role_text,
                        cons_provision_code_system,
                        cons_provision_code_version,
                        cons_provision_code_code,
                        cons_provision_code_display,
                        cons_provision_code_text,
                        cons_provision_dataperiod_start,
                        cons_provision_dataperiod_end,
                        input_datetime
                    )
                    VALUES (
                        current_record.cons_id,
                        current_record.cons_patient_id,
                        current_record.cons_identifier_use,
                        current_record.cons_identifier_type_system,
                        current_record.cons_identifier_type_version,
                        current_record.cons_identifier_type_code,
                        current_record.cons_identifier_type_display,
                        current_record.cons_identifier_type_text,
                        current_record.cons_identifier_system,
                        current_record.cons_identifier_value,
                        current_record.cons_identifier_start,
                        current_record.cons_identifier_end,
                        current_record.cons_status,
                        current_record.cons_scope_system,
                        current_record.cons_scope_version,
                        current_record.cons_scope_code,
                        current_record.cons_scope_display,
                        current_record.cons_scope_text,
                        current_record.cons_datetime,
                        current_record.cons_provision_type,
                        current_record.cons_provision_period_start,
                        current_record.cons_provision_period_end,
                        current_record.cons_provision_actor_role_system,
                        current_record.cons_provision_actor_role_version,
                        current_record.cons_provision_actor_role_code,
                        current_record.cons_provision_actor_role_display,
                        current_record.cons_provision_actor_role_text,
                        current_record.cons_provision_code_system,
                        current_record.cons_provision_code_version,
                        current_record.cons_provision_code_code,
                        current_record.cons_provision_code_display,
                        current_record.cons_provision_code_text,
                        current_record.cons_provision_dataperiod_start,
                        current_record.cons_provision_dataperiod_end,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.consent_raw WHERE consent_id = current_record.consent_id;
                ELSE
                UPDATE db_log.consent_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.cons_id::text,'#NULL#') = COALESCE(current_record.cons_id::text,'#NULL#') AND
                      COALESCE(target_record.cons_patient_id::text,'#NULL#') = COALESCE(current_record.cons_patient_id::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_use::text,'#NULL#') = COALESCE(current_record.cons_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_system::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_version::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_code::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_display::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_type_text::text,'#NULL#') = COALESCE(current_record.cons_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_system::text,'#NULL#') = COALESCE(current_record.cons_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_value::text,'#NULL#') = COALESCE(current_record.cons_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_start::text,'#NULL#') = COALESCE(current_record.cons_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.cons_identifier_end::text,'#NULL#') = COALESCE(current_record.cons_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.cons_status::text,'#NULL#') = COALESCE(current_record.cons_status::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_system::text,'#NULL#') = COALESCE(current_record.cons_scope_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_version::text,'#NULL#') = COALESCE(current_record.cons_scope_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_code::text,'#NULL#') = COALESCE(current_record.cons_scope_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_display::text,'#NULL#') = COALESCE(current_record.cons_scope_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_scope_text::text,'#NULL#') = COALESCE(current_record.cons_scope_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_datetime::text,'#NULL#') = COALESCE(current_record.cons_datetime::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_type::text,'#NULL#') = COALESCE(current_record.cons_provision_type::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_period_start::text,'#NULL#') = COALESCE(current_record.cons_provision_period_start::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_period_end::text,'#NULL#') = COALESCE(current_record.cons_provision_period_end::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_system::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_version::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_code::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_display::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_actor_role_text::text,'#NULL#') = COALESCE(current_record.cons_provision_actor_role_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_system::text,'#NULL#') = COALESCE(current_record.cons_provision_code_system::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_version::text,'#NULL#') = COALESCE(current_record.cons_provision_code_version::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_code::text,'#NULL#') = COALESCE(current_record.cons_provision_code_code::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_display::text,'#NULL#') = COALESCE(current_record.cons_provision_code_display::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_code_text::text,'#NULL#') = COALESCE(current_record.cons_provision_code_text::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_dataperiod_start::text,'#NULL#') = COALESCE(current_record.cons_provision_dataperiod_start::text,'#NULL#') AND
                      COALESCE(target_record.cons_provision_dataperiod_end::text,'#NULL#') = COALESCE(current_record.cons_provision_dataperiod_end::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.consent_raw WHERE consent_id = current_record.consent_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.consent_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE consent_id = current_record.consent_id;
            END;
    END LOOP;
    -- END consent
    -- Start location
    FOR current_record IN (SELECT * FROM cds2db_in.location_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.location_raw target_record
                WHERE COALESCE(target_record.loc_id::text,'#NULL#') = COALESCE(current_record.loc_id::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_use::text,'#NULL#') = COALESCE(current_record.loc_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_system::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_version::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_code::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_display::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_text::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_system::text,'#NULL#') = COALESCE(current_record.loc_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_value::text,'#NULL#') = COALESCE(current_record.loc_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_start::text,'#NULL#') = COALESCE(current_record.loc_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_end::text,'#NULL#') = COALESCE(current_record.loc_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.loc_status::text,'#NULL#') = COALESCE(current_record.loc_status::text,'#NULL#') AND
                      COALESCE(target_record.loc_name::text,'#NULL#') = COALESCE(current_record.loc_name::text,'#NULL#') AND
                      COALESCE(target_record.loc_description::text,'#NULL#') = COALESCE(current_record.loc_description::text,'#NULL#') AND
                      COALESCE(target_record.loc_alias::text,'#NULL#') = COALESCE(current_record.loc_alias::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.location_raw (
                        loc_id,
                        loc_identifier_use,
                        loc_identifier_type_system,
                        loc_identifier_type_version,
                        loc_identifier_type_code,
                        loc_identifier_type_display,
                        loc_identifier_type_text,
                        loc_identifier_system,
                        loc_identifier_value,
                        loc_identifier_start,
                        loc_identifier_end,
                        loc_status,
                        loc_name,
                        loc_description,
                        loc_alias,
                        input_datetime
                    )
                    VALUES (
                        current_record.loc_id,
                        current_record.loc_identifier_use,
                        current_record.loc_identifier_type_system,
                        current_record.loc_identifier_type_version,
                        current_record.loc_identifier_type_code,
                        current_record.loc_identifier_type_display,
                        current_record.loc_identifier_type_text,
                        current_record.loc_identifier_system,
                        current_record.loc_identifier_value,
                        current_record.loc_identifier_start,
                        current_record.loc_identifier_end,
                        current_record.loc_status,
                        current_record.loc_name,
                        current_record.loc_description,
                        current_record.loc_alias,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.location_raw WHERE location_id = current_record.location_id;
                ELSE
                UPDATE db_log.location_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.loc_id::text,'#NULL#') = COALESCE(current_record.loc_id::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_use::text,'#NULL#') = COALESCE(current_record.loc_identifier_use::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_system::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_system::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_version::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_version::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_code::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_code::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_display::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_display::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_type_text::text,'#NULL#') = COALESCE(current_record.loc_identifier_type_text::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_system::text,'#NULL#') = COALESCE(current_record.loc_identifier_system::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_value::text,'#NULL#') = COALESCE(current_record.loc_identifier_value::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_start::text,'#NULL#') = COALESCE(current_record.loc_identifier_start::text,'#NULL#') AND
                      COALESCE(target_record.loc_identifier_end::text,'#NULL#') = COALESCE(current_record.loc_identifier_end::text,'#NULL#') AND
                      COALESCE(target_record.loc_status::text,'#NULL#') = COALESCE(current_record.loc_status::text,'#NULL#') AND
                      COALESCE(target_record.loc_name::text,'#NULL#') = COALESCE(current_record.loc_name::text,'#NULL#') AND
                      COALESCE(target_record.loc_description::text,'#NULL#') = COALESCE(current_record.loc_description::text,'#NULL#') AND
                      COALESCE(target_record.loc_alias::text,'#NULL#') = COALESCE(current_record.loc_alias::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.location_raw WHERE location_id = current_record.location_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.location_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE location_id = current_record.location_id;
            END;
    END LOOP;
    -- END location
    -- Start pids_per_ward
    FOR current_record IN (SELECT * FROM cds2db_in.pids_per_ward_raw)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM db_log.pids_per_ward_raw target_record
                WHERE COALESCE(target_record.ward_name::text,'#NULL#') = COALESCE(current_record.ward_name::text,'#NULL#') AND
                      COALESCE(target_record.patient_id::text,'#NULL#') = COALESCE(current_record.patient_id::text,'#NULL#')
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO db_log.pids_per_ward_raw (
                        ward_name,
                        patient_id,
                        input_datetime
                    )
                    VALUES (
                        current_record.ward_name,
                        current_record.patient_id,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM cds2db_in.pids_per_ward_raw WHERE pids_per_ward_id = current_record.pids_per_ward_id;
                ELSE
                UPDATE db_log.pids_per_ward_raw target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE COALESCE(target_record.ward_name::text,'#NULL#') = COALESCE(current_record.ward_name::text,'#NULL#') AND
                      COALESCE(target_record.patient_id::text,'#NULL#') = COALESCE(current_record.patient_id::text,'#NULL#')
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM cds2db_in.pids_per_ward_raw WHERE pids_per_ward_id = current_record.pids_per_ward_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE cds2db_in.pids_per_ward_raw
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log Msg:'--||error_message
                    WHERE pids_per_ward_id = current_record.pids_per_ward_id;
            END;
    END LOOP;
    -- END pids_per_ward

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.copy_raw_cds_in_to_db_log();');
-----------------------------


