------------------------------
CREATE OR REPLACE FUNCTION db.take_over_last_check_date()
RETURNS VOID AS $$
DECLARE
    current_record record;
BEGIN
    -- Take over last check datetime Functionname: take_over_last_check_date- From: db_log -> To: db_log

    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.patient_raw to db_log.patient
    FOR current_record IN (SELECT DISTINCT p.patient_id AS id, r.last_check_datetime
                           FROM db_log.patient_raw p, db_log.patient r
                           WHERE p.patient_id = r.patient_raw_id --AND (p.last_check_datetime<r.last_check_datetime OR p.last_check_datetime is null)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.patient_raw target_record
                SET target_record.last_check_datetime = current_record.last_check_datetime
                WHERE patient_id = current_record.ID
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END patient

    -- from  db_log.encounter_raw to db_log.encounter
    FOR current_record IN (SELECT DISTINCT p.encounter_id AS id, r.last_check_datetime
                           FROM db_log.encounter_raw p, db_log.encounter r
                           WHERE p.encounter_id = r.encounter_raw_id --AND (p.last_check_datetime<r.last_check_datetime OR p.last_check_datetime is null)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.encounter_raw target_record
                SET target_record.last_check_datetime = current_record.last_check_datetime
                WHERE encounter_id = current_record.ID
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END encounter

    -- from  db_log.pids_per_ward_raw to db_log.pids_per_ward
    FOR current_record IN (SELECT DISTINCT p.pids_per_ward_id AS id, r.last_check_datetime
                           FROM db_log.pids_per_ward_raw p, db_log.pids_per_ward r
                           WHERE p.pids_per_ward_id = r.pids_per_ward_raw_id --AND (p.last_check_datetime<r.last_check_datetime OR p.last_check_datetime is null)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.pids_per_ward_raw target_record
                SET target_record.last_check_datetime = current_record.last_check_datetime
                WHERE pids_per_ward_id = current_record.ID
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END pids_per_ward

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.take_over_last_check_date();');
-----------------------------


