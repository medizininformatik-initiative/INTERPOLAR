CREATE OR REPLACE FUNCTION db.take_over_last_check_date()
RETURNS VOID AS $$
DECLARE
    current_record record;
    last_pro_nr INT;
    new_last_pro_nr INT;
    max_last_pro_nr INT; -- Last processing number in core data
    last_raw_pro_nr INT; -- Last processing number in raw data - last new dataimport (offset)
BEGIN
    -- Take over last check datetime Functionname: take_over_last_check_date / last_pro_nr - From: db_log (raw) -> To: db_log
    SELECT nextval('db.db_seq') INTO new_last_pro_nr; -- Get the processing number for this sync process

    -- Last import Nr in raw-data
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

    -- Patient
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.patient;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT patient_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.patient_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.patient_raw WHERE patient_raw_id IN 
            (SELECT patient_raw_id FROM db_log.patient WHERE last_processing_nr=max_last_pro_nr
            )
         AND last_processing_nr=last_raw_pro_nr
         )
    )
        LOOP
            BEGIN
                UPDATE db_log.patient
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE patient_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT patient_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient' AS table_name, last_check_datetime, current_dataset_status, 'copy_type_cds_in_to_db_log' FROM db_log.patient
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- Patient End
END;
$$ LANGUAGE plpgsql;
