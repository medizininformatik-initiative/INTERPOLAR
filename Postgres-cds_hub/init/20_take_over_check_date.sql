------------------------------
CREATE OR REPLACE FUNCTION db.take_over_last_check_date()
RETURNS VOID AS $$
DECLARE
    current_record record;
BEGIN
    -- Take over last check datetime Functionname: take_over_last_check_date- From: db_log -> To: db_log

    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.encounter_raw to db_log.encounter
    FOR current_record IN (SELECT DISTINCT p.encounter_raw_id AS id, r.last_check_datetime
                           FROM db_log.encounter p, db_log.encounter_raw r
                           WHERE p.encounter_raw_id = r.encounter_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.encounter target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE encounter_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END encounter_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.patient_raw to db_log.patient
    FOR current_record IN (SELECT DISTINCT p.patient_raw_id AS id, r.last_check_datetime
                           FROM db_log.patient p, db_log.patient_raw r
                           WHERE p.patient_raw_id = r.patient_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.patient target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE patient_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END patient_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.condition_raw to db_log.condition
    FOR current_record IN (SELECT DISTINCT p.condition_raw_id AS id, r.last_check_datetime
                           FROM db_log.condition p, db_log.condition_raw r
                           WHERE p.condition_raw_id = r.condition_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.condition target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE condition_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END condition_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.medication_raw to db_log.medication
    FOR current_record IN (SELECT DISTINCT p.medication_raw_id AS id, r.last_check_datetime
                           FROM db_log.medication p, db_log.medication_raw r
                           WHERE p.medication_raw_id = r.medication_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.medication target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE medication_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END medication_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.medicationrequest_raw to db_log.medicationrequest
    FOR current_record IN (SELECT DISTINCT p.medicationrequest_raw_id AS id, r.last_check_datetime
                           FROM db_log.medicationrequest p, db_log.medicationrequest_raw r
                           WHERE p.medicationrequest_raw_id = r.medicationrequest_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.medicationrequest target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE medicationrequest_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END medicationrequest_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.medicationadministration_raw to db_log.medicationadministration
    FOR current_record IN (SELECT DISTINCT p.medicationadministration_raw_id AS id, r.last_check_datetime
                           FROM db_log.medicationadministration p, db_log.medicationadministration_raw r
                           WHERE p.medicationadministration_raw_id = r.medicationadministration_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.medicationadministration target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE medicationadministration_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END medicationadministration_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.medicationstatement_raw to db_log.medicationstatement
    FOR current_record IN (SELECT DISTINCT p.medicationstatement_raw_id AS id, r.last_check_datetime
                           FROM db_log.medicationstatement p, db_log.medicationstatement_raw r
                           WHERE p.medicationstatement_raw_id = r.medicationstatement_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.medicationstatement target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE medicationstatement_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END medicationstatement_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.observation_raw to db_log.observation
    FOR current_record IN (SELECT DISTINCT p.observation_raw_id AS id, r.last_check_datetime
                           FROM db_log.observation p, db_log.observation_raw r
                           WHERE p.observation_raw_id = r.observation_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.observation target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE observation_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END observation_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.diagnosticreport_raw to db_log.diagnosticreport
    FOR current_record IN (SELECT DISTINCT p.diagnosticreport_raw_id AS id, r.last_check_datetime
                           FROM db_log.diagnosticreport p, db_log.diagnosticreport_raw r
                           WHERE p.diagnosticreport_raw_id = r.diagnosticreport_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.diagnosticreport target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE diagnosticreport_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END diagnosticreport_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.servicerequest_raw to db_log.servicerequest
    FOR current_record IN (SELECT DISTINCT p.servicerequest_raw_id AS id, r.last_check_datetime
                           FROM db_log.servicerequest p, db_log.servicerequest_raw r
                           WHERE p.servicerequest_raw_id = r.servicerequest_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.servicerequest target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE servicerequest_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END servicerequest_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.procedure_raw to db_log.procedure
    FOR current_record IN (SELECT DISTINCT p.procedure_raw_id AS id, r.last_check_datetime
                           FROM db_log.procedure p, db_log.procedure_raw r
                           WHERE p.procedure_raw_id = r.procedure_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.procedure target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE procedure_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END procedure_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.consent_raw to db_log.consent
    FOR current_record IN (SELECT DISTINCT p.consent_raw_id AS id, r.last_check_datetime
                           FROM db_log.consent p, db_log.consent_raw r
                           WHERE p.consent_raw_id = r.consent_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.consent target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE consent_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END consent_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.location_raw to db_log.location
    FOR current_record IN (SELECT DISTINCT p.location_raw_id AS id, r.last_check_datetime
                           FROM db_log.location p, db_log.location_raw r
                           WHERE p.location_raw_id = r.location_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.location target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE location_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END location_raw
    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  db_log.pids_per_ward_raw to db_log.pids_per_ward
    FOR current_record IN (SELECT DISTINCT p.pids_per_ward_raw_id AS id, r.last_check_datetime
                           FROM db_log.pids_per_ward p, db_log.pids_per_ward_raw r
                           WHERE p.pids_per_ward_raw_id = r.pids_per_ward_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE db_log.pids_per_ward target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE pids_per_ward_raw_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END pids_per_ward_raw

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.take_over_last_check_date();');
-----------------------------



