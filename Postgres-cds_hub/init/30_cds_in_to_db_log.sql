-- Überführungsfunktion
CREATE OR REPLACE FUNCTION db.do_cds_in_to_db_log()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
BEGIN
    -- Funktion um Daten aus der Schnittstelle CDS2DB in den Kern/Logbereich der Datenbank persitent zu kopieren - falls es Änderungen gibt
    -- patient
    FOR current_record IN (SELECT * FROM cds2db_in.patient_raw WHERE current_dataset_status NOT LIKE 'DELETE after%') -- in Entwicklungsphase wird Datensatz noch nicht wirklich physisch gelöscht
        LOOP
            SELECT count(1) INTO data_count
            FROM db_log.patient_raw target_record
            WHERE   target_record.pat_id = current_record.pat_id AND
                    target_record.pat_identifier_value = current_record.pat_identifier_value AND
                    target_record.pat_identifier_system = current_record.pat_identifier_system AND
                    target_record.pat_identifier_type_system = current_record.pat_identifier_type_system AND
                    target_record.pat_identifier_type_version = current_record.pat_identifier_type_version AND
                    target_record.pat_identifier_type_code = current_record.pat_identifier_type_code AND
                    target_record.pat_identifier_type_display = current_record.pat_identifier_type_display AND
                    target_record.pat_identifier_type_text = current_record.pat_identifier_type_text AND
                    target_record.pat_name_given = current_record.pat_name_given AND
                    target_record.pat_name_family = current_record.pat_name_family AND
                    target_record.pat_gender = current_record.pat_gender AND
                    target_record.pat_birthdate = current_record.pat_birthdate AND
                    target_record.pat_adress_postalcode = current_record.pat_adress_postalcode
                  ;

            IF data_count=0
            THEN
                -- Füge in die Backup-Tabelle ein, wenn kein übereinstimmender Datensatz gefunden wurde
                INSERT INTO db_log.patient_raw (
                    pat_id,
                    pat_identifier_value,
                    pat_identifier_system,
                    pat_identifier_type_system,
                    pat_identifier_type_version,
                    pat_identifier_type_code,
                    pat_identifier_type_display,
                    pat_identifier_type_text,
                    pat_name_given,
                    pat_name_family,
                    pat_gender,
                    pat_birthdate,
                    pat_adress_postalcode,
                    input_datetime
                )
                VALUES (
                    current_record.pat_id,
                    current_record.pat_identifier_value,
                    current_record.pat_identifier_system,
                    current_record.pat_identifier_type_system,
                    current_record.pat_identifier_type_version,
                    current_record.pat_identifier_type_code,
                    current_record.pat_identifier_type_display,
                    current_record.pat_identifier_type_text,
                    current_record.pat_name_given,
                    current_record.pat_name_family,
                    current_record.pat_gender,
                    current_record.pat_birthdate,
                    current_record.pat_adress_postalcode,
                    current_record.input_datetime
                );

                -- Aktualisiere den Zeitstempel für die letzte Überprüfung/Insert
                UPDATE cds2db_in.patient_raw
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'DELETE after db_insert '||data_count::integer
                WHERE patient_id = current_record.patient_id;      
            END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/10 * * * *', 'CALL db.do_cds_in_to_db_log();');
