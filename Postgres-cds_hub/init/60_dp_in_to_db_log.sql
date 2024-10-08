-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-08-21 10:04:46
-- Rights definition file size        : 15036 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2024-09-23 17:12:30
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  42_cre_table_frontend_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  INT_ID
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _fe
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (3):  db_user
-- COPY_FUNC_SCRIPTNAME:  60_dp_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_fe_dp_in_to_db_log
-- SCHEMA_2:  db2dataprocessor_in
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

------------------------------
CREATE OR REPLACE FUNCTION db.copy_fe_dp_in_to_db_log()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
    data_count_all integer;
    last_pro_nr INT;
    temp varchar;
BEGIN
    -- Copy Functionname: copy_fe_dp_in_to_db_log - From: db2dataprocessor_in -> To: db_log

    -- Start patient_fe
    FOR current_record IN (SELECT * FROM db2dataprocessor_in.patient_fe)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM db_log.patient_fe target_record
                WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.pat_header::text,'#NULL#') = COALESCE(current_record.pat_header::text,'#NULL#') AND
                      COALESCE(target_record.pat_id::text,'#NULL#') = COALESCE(current_record.pat_id::text,'#NULL#') AND
                      COALESCE(target_record.pat_femb_1::text,'#NULL#') = COALESCE(current_record.pat_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.pat_cis_pid::text,'#NULL#') = COALESCE(current_record.pat_cis_pid::text,'#NULL#') AND
                      COALESCE(target_record.pat_name::text,'#NULL#') = COALESCE(current_record.pat_name::text,'#NULL#') AND
                      COALESCE(target_record.pat_vorname::text,'#NULL#') = COALESCE(current_record.pat_vorname::text,'#NULL#') AND
                      COALESCE(target_record.pat_gebdat::text,'#NULL#') = COALESCE(current_record.pat_gebdat::text,'#NULL#') AND
                      COALESCE(target_record.pat_aktuell_alter::text,'#NULL#') = COALESCE(current_record.pat_aktuell_alter::text,'#NULL#') AND
                      COALESCE(target_record.pat_geschlecht::text,'#NULL#') = COALESCE(current_record.pat_geschlecht::text,'#NULL#') AND
                      COALESCE(target_record.patient_complete::text,'#NULL#') = COALESCE(current_record.patient_complete::text,'#NULL#')
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO db_log.patient_fe (
                        patient_fe_id,
                        record_id,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        pat_header,
                        pat_id,
                        pat_femb_1,
                        pat_cis_pid,
                        pat_name,
                        pat_vorname,
                        pat_gebdat,
                        pat_aktuell_alter,
                        pat_geschlecht,
                        patient_complete,
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.patient_fe_id,
                        current_record.record_id,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.pat_header,
                        current_record.pat_id,
                        current_record.pat_femb_1,
                        current_record.pat_cis_pid,
                        current_record.pat_name,
                        current_record.pat_vorname,
                        current_record.pat_gebdat,
                        current_record.pat_aktuell_alter,
                        current_record.pat_geschlecht,
                        current_record.patient_complete,
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM db2dataprocessor_in.patient_fe WHERE patient_fe_id = current_record.patient_fe_id;
                ELSE
                UPDATE db_log.patient_fe target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.pat_header::text,'#NULL#') = COALESCE(current_record.pat_header::text,'#NULL#') AND
                      COALESCE(target_record.pat_id::text,'#NULL#') = COALESCE(current_record.pat_id::text,'#NULL#') AND
                      COALESCE(target_record.pat_femb_1::text,'#NULL#') = COALESCE(current_record.pat_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.pat_cis_pid::text,'#NULL#') = COALESCE(current_record.pat_cis_pid::text,'#NULL#') AND
                      COALESCE(target_record.pat_name::text,'#NULL#') = COALESCE(current_record.pat_name::text,'#NULL#') AND
                      COALESCE(target_record.pat_vorname::text,'#NULL#') = COALESCE(current_record.pat_vorname::text,'#NULL#') AND
                      COALESCE(target_record.pat_gebdat::text,'#NULL#') = COALESCE(current_record.pat_gebdat::text,'#NULL#') AND
                      COALESCE(target_record.pat_aktuell_alter::text,'#NULL#') = COALESCE(current_record.pat_aktuell_alter::text,'#NULL#') AND
                      COALESCE(target_record.pat_geschlecht::text,'#NULL#') = COALESCE(current_record.pat_geschlecht::text,'#NULL#') AND
                      COALESCE(target_record.patient_complete::text,'#NULL#') = COALESCE(current_record.patient_complete::text,'#NULL#')
                    ;

                    -- Delete updatet datasets
                    DELETE FROM db2dataprocessor_in.patient_fe WHERE patient_fe_id = current_record.patient_fe_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE db2dataprocessor_in.patient_fe
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_fe_dp_in_to_db_log'
                    , last_processing_nr = last_pro_nr
                    WHERE patient_fe_id = current_record.patient_fe_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT patient_fe_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient_fe' AS table_name, last_check_datetime, current_dataset_status, 'copy_fe_dp_in_to_db_log' AS function_name FROM db_log.patient_fe
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END patient_fe
    -----------------------------------------------------------------------------------------------------------------------

    -- Start fall_fe
    FOR current_record IN (SELECT * FROM db2dataprocessor_in.fall_fe)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM db_log.fall_fe target_record
                WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.fall_header::text,'#NULL#') = COALESCE(current_record.fall_header::text,'#NULL#') AND
                      COALESCE(target_record.fall_id::text,'#NULL#') = COALESCE(current_record.fall_id::text,'#NULL#') AND
                      COALESCE(target_record.fall_pat_id::text,'#NULL#') = COALESCE(current_record.fall_pat_id::text,'#NULL#') AND
                      COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_1::text,'#NULL#') = COALESCE(current_record.fall_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.fall_studienphase::text,'#NULL#') = COALESCE(current_record.fall_studienphase::text,'#NULL#') AND
                      COALESCE(target_record.fall_station::text,'#NULL#') = COALESCE(current_record.fall_station::text,'#NULL#') AND
                      COALESCE(target_record.fall_zimmernr::text,'#NULL#') = COALESCE(current_record.fall_zimmernr::text,'#NULL#') AND
                      COALESCE(target_record.fall_aufn_dat::text,'#NULL#') = COALESCE(current_record.fall_aufn_dat::text,'#NULL#') AND
                      COALESCE(target_record.fall_aufn_diag::text,'#NULL#') = COALESCE(current_record.fall_aufn_diag::text,'#NULL#') AND
                      COALESCE(target_record.fall_gewicht_aktuell::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktuell::text,'#NULL#') AND
                      COALESCE(target_record.fall_gewicht_aktl_einheit::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktl_einheit::text,'#NULL#') AND
                      COALESCE(target_record.fall_groesse::text,'#NULL#') = COALESCE(current_record.fall_groesse::text,'#NULL#') AND
                      COALESCE(target_record.fall_groesse_einheit::text,'#NULL#') = COALESCE(current_record.fall_groesse_einheit::text,'#NULL#') AND
                      COALESCE(target_record.fall_bmi::text,'#NULL#') = COALESCE(current_record.fall_bmi::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_2::text,'#NULL#') = COALESCE(current_record.fall_femb_2::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_3::text,'#NULL#') = COALESCE(current_record.fall_femb_3::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_4::text,'#NULL#') = COALESCE(current_record.fall_femb_4::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_5::text,'#NULL#') = COALESCE(current_record.fall_femb_5::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_6::text,'#NULL#') = COALESCE(current_record.fall_femb_6::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_chron::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_chron::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_ausmass_lbl::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_ausmass_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_ausmass::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_dialysev_lbl::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_dialysev_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_dialysev::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_dialysev::text,'#NULL#') AND
                      COALESCE(target_record.fall_leber_insuf::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf::text,'#NULL#') AND
                      COALESCE(target_record.fall_leber_insuf_ausmass_lbl::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf_ausmass_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_leber_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf_ausmass::text,'#NULL#') AND
                      COALESCE(target_record.fall_schwanger_mo::text,'#NULL#') = COALESCE(current_record.fall_schwanger_mo::text,'#NULL#') AND
                      COALESCE(target_record.fall_schwanger_mo_lbl::text,'#NULL#') = COALESCE(current_record.fall_schwanger_mo_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_status::text,'#NULL#') = COALESCE(current_record.fall_status::text,'#NULL#') AND
                      COALESCE(target_record.fall_ent_dat::text,'#NULL#') = COALESCE(current_record.fall_ent_dat::text,'#NULL#') AND
                      COALESCE(target_record.fall_complete::text,'#NULL#') = COALESCE(current_record.fall_complete::text,'#NULL#')
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO db_log.fall_fe (
                        fall_fe_id,
                        record_id,
                        fall_header,
                        fall_id,
                        fall_pat_id,
                        patient_id_fk,
                        fall_femb_1,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        fall_studienphase,
                        fall_station,
                        fall_zimmernr,
                        fall_aufn_dat,
                        fall_aufn_diag,
                        fall_gewicht_aktuell,
                        fall_gewicht_aktl_einheit,
                        fall_groesse,
                        fall_groesse_einheit,
                        fall_bmi,
                        fall_femb_2,
                        fall_femb_3,
                        fall_femb_4,
                        fall_femb_5,
                        fall_femb_6,
                        fall_nieren_insuf_chron,
                        fall_nieren_insuf_ausmass_lbl,
                        fall_nieren_insuf_ausmass,
                        fall_nieren_insuf_dialysev_lbl,
                        fall_nieren_insuf_dialysev,
                        fall_leber_insuf,
                        fall_leber_insuf_ausmass_lbl,
                        fall_leber_insuf_ausmass,
                        fall_schwanger_mo,
                        fall_schwanger_mo_lbl,
                        fall_status,
                        fall_ent_dat,
                        fall_complete,
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.fall_fe_id,
                        current_record.record_id,
                        current_record.fall_header,
                        current_record.fall_id,
                        current_record.fall_pat_id,
                        current_record.patient_id_fk,
                        current_record.fall_femb_1,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.fall_studienphase,
                        current_record.fall_station,
                        current_record.fall_zimmernr,
                        current_record.fall_aufn_dat,
                        current_record.fall_aufn_diag,
                        current_record.fall_gewicht_aktuell,
                        current_record.fall_gewicht_aktl_einheit,
                        current_record.fall_groesse,
                        current_record.fall_groesse_einheit,
                        current_record.fall_bmi,
                        current_record.fall_femb_2,
                        current_record.fall_femb_3,
                        current_record.fall_femb_4,
                        current_record.fall_femb_5,
                        current_record.fall_femb_6,
                        current_record.fall_nieren_insuf_chron,
                        current_record.fall_nieren_insuf_ausmass_lbl,
                        current_record.fall_nieren_insuf_ausmass,
                        current_record.fall_nieren_insuf_dialysev_lbl,
                        current_record.fall_nieren_insuf_dialysev,
                        current_record.fall_leber_insuf,
                        current_record.fall_leber_insuf_ausmass_lbl,
                        current_record.fall_leber_insuf_ausmass,
                        current_record.fall_schwanger_mo,
                        current_record.fall_schwanger_mo_lbl,
                        current_record.fall_status,
                        current_record.fall_ent_dat,
                        current_record.fall_complete,
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM db2dataprocessor_in.fall_fe WHERE fall_fe_id = current_record.fall_fe_id;
                ELSE
                UPDATE db_log.fall_fe target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.fall_header::text,'#NULL#') = COALESCE(current_record.fall_header::text,'#NULL#') AND
                      COALESCE(target_record.fall_id::text,'#NULL#') = COALESCE(current_record.fall_id::text,'#NULL#') AND
                      COALESCE(target_record.fall_pat_id::text,'#NULL#') = COALESCE(current_record.fall_pat_id::text,'#NULL#') AND
                      COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_1::text,'#NULL#') = COALESCE(current_record.fall_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.fall_studienphase::text,'#NULL#') = COALESCE(current_record.fall_studienphase::text,'#NULL#') AND
                      COALESCE(target_record.fall_station::text,'#NULL#') = COALESCE(current_record.fall_station::text,'#NULL#') AND
                      COALESCE(target_record.fall_zimmernr::text,'#NULL#') = COALESCE(current_record.fall_zimmernr::text,'#NULL#') AND
                      COALESCE(target_record.fall_aufn_dat::text,'#NULL#') = COALESCE(current_record.fall_aufn_dat::text,'#NULL#') AND
                      COALESCE(target_record.fall_aufn_diag::text,'#NULL#') = COALESCE(current_record.fall_aufn_diag::text,'#NULL#') AND
                      COALESCE(target_record.fall_gewicht_aktuell::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktuell::text,'#NULL#') AND
                      COALESCE(target_record.fall_gewicht_aktl_einheit::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktl_einheit::text,'#NULL#') AND
                      COALESCE(target_record.fall_groesse::text,'#NULL#') = COALESCE(current_record.fall_groesse::text,'#NULL#') AND
                      COALESCE(target_record.fall_groesse_einheit::text,'#NULL#') = COALESCE(current_record.fall_groesse_einheit::text,'#NULL#') AND
                      COALESCE(target_record.fall_bmi::text,'#NULL#') = COALESCE(current_record.fall_bmi::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_2::text,'#NULL#') = COALESCE(current_record.fall_femb_2::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_3::text,'#NULL#') = COALESCE(current_record.fall_femb_3::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_4::text,'#NULL#') = COALESCE(current_record.fall_femb_4::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_5::text,'#NULL#') = COALESCE(current_record.fall_femb_5::text,'#NULL#') AND
                      COALESCE(target_record.fall_femb_6::text,'#NULL#') = COALESCE(current_record.fall_femb_6::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_chron::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_chron::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_ausmass_lbl::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_ausmass_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_ausmass::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_dialysev_lbl::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_dialysev_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_nieren_insuf_dialysev::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_dialysev::text,'#NULL#') AND
                      COALESCE(target_record.fall_leber_insuf::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf::text,'#NULL#') AND
                      COALESCE(target_record.fall_leber_insuf_ausmass_lbl::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf_ausmass_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_leber_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf_ausmass::text,'#NULL#') AND
                      COALESCE(target_record.fall_schwanger_mo::text,'#NULL#') = COALESCE(current_record.fall_schwanger_mo::text,'#NULL#') AND
                      COALESCE(target_record.fall_schwanger_mo_lbl::text,'#NULL#') = COALESCE(current_record.fall_schwanger_mo_lbl::text,'#NULL#') AND
                      COALESCE(target_record.fall_status::text,'#NULL#') = COALESCE(current_record.fall_status::text,'#NULL#') AND
                      COALESCE(target_record.fall_ent_dat::text,'#NULL#') = COALESCE(current_record.fall_ent_dat::text,'#NULL#') AND
                      COALESCE(target_record.fall_complete::text,'#NULL#') = COALESCE(current_record.fall_complete::text,'#NULL#')
                    ;

                    -- Delete updatet datasets
                    DELETE FROM db2dataprocessor_in.fall_fe WHERE fall_fe_id = current_record.fall_fe_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE db2dataprocessor_in.fall_fe
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_fe_dp_in_to_db_log'
                    , last_processing_nr = last_pro_nr
                    WHERE fall_fe_id = current_record.fall_fe_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT fall_fe_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'fall_fe' AS table_name, last_check_datetime, current_dataset_status, 'copy_fe_dp_in_to_db_log' AS function_name FROM db_log.fall_fe
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END fall_fe
    -----------------------------------------------------------------------------------------------------------------------

    -- Start medikationsanalyse_fe
    FOR current_record IN (SELECT * FROM db2dataprocessor_in.medikationsanalyse_fe)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM db_log.medikationsanalyse_fe target_record
                WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.meda_header::text,'#NULL#') = COALESCE(current_record.meda_header::text,'#NULL#') AND
                      COALESCE(target_record.meda_femb_1::text,'#NULL#') = COALESCE(current_record.meda_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.meda_femb_2::text,'#NULL#') = COALESCE(current_record.meda_femb_2::text,'#NULL#') AND
                      COALESCE(target_record.meda_femb_3::text,'#NULL#') = COALESCE(current_record.meda_femb_3::text,'#NULL#') AND
                      COALESCE(target_record.fall_fe_id::text,'#NULL#') = COALESCE(current_record.fall_fe_id::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.meda_dat::text,'#NULL#') = COALESCE(current_record.meda_dat::text,'#NULL#') AND
                      COALESCE(target_record.meda_typ::text,'#NULL#') = COALESCE(current_record.meda_typ::text,'#NULL#') AND
                      COALESCE(target_record.meda_ma_thueberw::text,'#NULL#') = COALESCE(current_record.meda_ma_thueberw::text,'#NULL#') AND
                      COALESCE(target_record.meda_mrp_detekt::text,'#NULL#') = COALESCE(current_record.meda_mrp_detekt::text,'#NULL#') AND
                      COALESCE(target_record.meda_aufwand_zeit::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit::text,'#NULL#') AND
                      COALESCE(target_record.meda_aufwand_zeit_and_lbl::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit_and_lbl::text,'#NULL#') AND
                      COALESCE(target_record.meda_aufwand_zeit_and::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit_and::text,'#NULL#') AND
                      COALESCE(target_record.meda_notiz::text,'#NULL#') = COALESCE(current_record.meda_notiz::text,'#NULL#') AND
                      COALESCE(target_record.medikationsanalyse_complete::text,'#NULL#') = COALESCE(current_record.medikationsanalyse_complete::text,'#NULL#')
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO db_log.medikationsanalyse_fe (
                        medikationsanalyse_fe_id,
                        record_id,
                        meda_header,
                        meda_femb_1,
                        meda_femb_2,
                        meda_femb_3,
                        fall_fe_id,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        meda_dat,
                        meda_typ,
                        meda_ma_thueberw,
                        meda_mrp_detekt,
                        meda_aufwand_zeit,
                        meda_aufwand_zeit_and_lbl,
                        meda_aufwand_zeit_and,
                        meda_notiz,
                        medikationsanalyse_complete,
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.medikationsanalyse_fe_id,
                        current_record.record_id,
                        current_record.meda_header,
                        current_record.meda_femb_1,
                        current_record.meda_femb_2,
                        current_record.meda_femb_3,
                        current_record.fall_fe_id,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.meda_dat,
                        current_record.meda_typ,
                        current_record.meda_ma_thueberw,
                        current_record.meda_mrp_detekt,
                        current_record.meda_aufwand_zeit,
                        current_record.meda_aufwand_zeit_and_lbl,
                        current_record.meda_aufwand_zeit_and,
                        current_record.meda_notiz,
                        current_record.medikationsanalyse_complete,
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM db2dataprocessor_in.medikationsanalyse_fe WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
                ELSE
                UPDATE db_log.medikationsanalyse_fe target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.meda_header::text,'#NULL#') = COALESCE(current_record.meda_header::text,'#NULL#') AND
                      COALESCE(target_record.meda_femb_1::text,'#NULL#') = COALESCE(current_record.meda_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.meda_femb_2::text,'#NULL#') = COALESCE(current_record.meda_femb_2::text,'#NULL#') AND
                      COALESCE(target_record.meda_femb_3::text,'#NULL#') = COALESCE(current_record.meda_femb_3::text,'#NULL#') AND
                      COALESCE(target_record.fall_fe_id::text,'#NULL#') = COALESCE(current_record.fall_fe_id::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.meda_dat::text,'#NULL#') = COALESCE(current_record.meda_dat::text,'#NULL#') AND
                      COALESCE(target_record.meda_typ::text,'#NULL#') = COALESCE(current_record.meda_typ::text,'#NULL#') AND
                      COALESCE(target_record.meda_ma_thueberw::text,'#NULL#') = COALESCE(current_record.meda_ma_thueberw::text,'#NULL#') AND
                      COALESCE(target_record.meda_mrp_detekt::text,'#NULL#') = COALESCE(current_record.meda_mrp_detekt::text,'#NULL#') AND
                      COALESCE(target_record.meda_aufwand_zeit::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit::text,'#NULL#') AND
                      COALESCE(target_record.meda_aufwand_zeit_and_lbl::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit_and_lbl::text,'#NULL#') AND
                      COALESCE(target_record.meda_aufwand_zeit_and::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit_and::text,'#NULL#') AND
                      COALESCE(target_record.meda_notiz::text,'#NULL#') = COALESCE(current_record.meda_notiz::text,'#NULL#') AND
                      COALESCE(target_record.medikationsanalyse_complete::text,'#NULL#') = COALESCE(current_record.medikationsanalyse_complete::text,'#NULL#')
                    ;

                    -- Delete updatet datasets
                    DELETE FROM db2dataprocessor_in.medikationsanalyse_fe WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE db2dataprocessor_in.medikationsanalyse_fe
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_fe_dp_in_to_db_log'
                    , last_processing_nr = last_pro_nr
                    WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medikationsanalyse_fe_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medikationsanalyse_fe' AS table_name, last_check_datetime, current_dataset_status, 'copy_fe_dp_in_to_db_log' AS function_name FROM db_log.medikationsanalyse_fe
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END medikationsanalyse_fe
    -----------------------------------------------------------------------------------------------------------------------

    -- Start mrpdokumentation_validierung_fe
    FOR current_record IN (SELECT * FROM db2dataprocessor_in.mrpdokumentation_validierung_fe)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM db_log.mrpdokumentation_validierung_fe target_record
                WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.meda_fe_id::text,'#NULL#') = COALESCE(current_record.meda_fe_id::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.mrp_header::text,'#NULL#') = COALESCE(current_record.mrp_header::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_1::text,'#NULL#') = COALESCE(current_record.mrp_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_2::text,'#NULL#') = COALESCE(current_record.mrp_femb_2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_3::text,'#NULL#') = COALESCE(current_record.mrp_femb_3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pi_info::text,'#NULL#') = COALESCE(current_record.mrp_pi_info::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pi_info___1::text,'#NULL#') = COALESCE(current_record.mrp_pi_info___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_mf_info::text,'#NULL#') = COALESCE(current_record.mrp_mf_info::text,'#NULL#') AND
                      COALESCE(target_record.mrp_mf_info___1::text,'#NULL#') = COALESCE(current_record.mrp_mf_info___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pi_info_txt::text,'#NULL#') = COALESCE(current_record.mrp_pi_info_txt::text,'#NULL#') AND
                      COALESCE(target_record.mrp_mf_info_txt::text,'#NULL#') = COALESCE(current_record.mrp_mf_info_txt::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_4::text,'#NULL#') = COALESCE(current_record.mrp_femb_4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_5::text,'#NULL#') = COALESCE(current_record.mrp_femb_5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_6::text,'#NULL#') = COALESCE(current_record.mrp_femb_6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_entd_dat::text,'#NULL#') = COALESCE(current_record.mrp_entd_dat::text,'#NULL#') AND
                      COALESCE(target_record.mrp_kurzbeschr::text,'#NULL#') = COALESCE(current_record.mrp_kurzbeschr::text,'#NULL#') AND
                      COALESCE(target_record.mrp_entd_algorithmisch::text,'#NULL#') = COALESCE(current_record.mrp_entd_algorithmisch::text,'#NULL#') AND
                      COALESCE(target_record.mrp_hinweisgeber_lbl::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_hinweisgeber::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewissheit_lbl::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewissheit::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_22::text,'#NULL#') = COALESCE(current_record.mrp_femb_22::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewissheit_oth::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit_oth::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_23::text,'#NULL#') = COALESCE(current_record.mrp_femb_23::text,'#NULL#') AND
                      COALESCE(target_record.mrp_hinweisgeber_oth::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber_oth::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl_lbl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl_sonst_lbl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_sonst_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_7::text,'#NULL#') = COALESCE(current_record.mrp_femb_7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_8::text,'#NULL#') = COALESCE(current_record.mrp_femb_8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_9::text,'#NULL#') = COALESCE(current_record.mrp_femb_9::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_10::text,'#NULL#') = COALESCE(current_record.mrp_femb_10::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_11::text,'#NULL#') = COALESCE(current_record.mrp_femb_11::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_12::text,'#NULL#') = COALESCE(current_record.mrp_femb_12::text,'#NULL#') AND
                      COALESCE(target_record.mrp_wirkstoff::text,'#NULL#') = COALESCE(current_record.mrp_wirkstoff::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc1_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc1_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc1::text,'#NULL#') = COALESCE(current_record.mrp_atc1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc2_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc2_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc2::text,'#NULL#') = COALESCE(current_record.mrp_atc2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc3_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc3_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc3::text,'#NULL#') = COALESCE(current_record.mrp_atc3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc4_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc4_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc4::text,'#NULL#') = COALESCE(current_record.mrp_atc4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc5_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc5_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc5::text,'#NULL#') = COALESCE(current_record.mrp_atc5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_13::text,'#NULL#') = COALESCE(current_record.mrp_femb_13::text,'#NULL#') AND
                      COALESCE(target_record.mrp_med_prod::text,'#NULL#') = COALESCE(current_record.mrp_med_prod::text,'#NULL#') AND
                      COALESCE(target_record.mrp_med_prod_sonst_lbl::text,'#NULL#') = COALESCE(current_record.mrp_med_prod_sonst_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_med_prod_sonst::text,'#NULL#') = COALESCE(current_record.mrp_med_prod_sonst::text,'#NULL#') AND
                      COALESCE(target_record.mrp_dokup_fehler::text,'#NULL#') = COALESCE(current_record.mrp_dokup_fehler::text,'#NULL#') AND
                      COALESCE(target_record.mrp_dokup_intervention::text,'#NULL#') = COALESCE(current_record.mrp_dokup_intervention::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_14::text,'#NULL#') = COALESCE(current_record.mrp_femb_14::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund::text,'#NULL#') = COALESCE(current_record.mrp_pigrund::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___1::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___2::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___3::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___4::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___5::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___6::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___7::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___8::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___9::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___9::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___10::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___10::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___11::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___11::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___12::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___12::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___13::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___13::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___14::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___14::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___15::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___15::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___16::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___16::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___17::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___17::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___18::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___18::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___19::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___19::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___20::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___20::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___21::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___21::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___22::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___22::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___23::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___23::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___24::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___24::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___25::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___25::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___26::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___26::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___27::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___27::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_15::text,'#NULL#') = COALESCE(current_record.mrp_femb_15::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___1::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___2::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___3::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___4::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___5::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_16::text,'#NULL#') = COALESCE(current_record.mrp_femb_16::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_17::text,'#NULL#') = COALESCE(current_record.mrp_femb_17::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse_disease::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_disease::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse_labor::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_labor::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_18::text,'#NULL#') = COALESCE(current_record.mrp_femb_18::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am::text,'#NULL#') = COALESCE(current_record.mrp_massn_am::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___1::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___2::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___3::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___4::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___5::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___6::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___7::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___8::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___9::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___9::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___10::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___10::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_19::text,'#NULL#') = COALESCE(current_record.mrp_femb_19::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___1::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___2::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___3::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___4::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___5::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___6::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___7::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___8::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_20::text,'#NULL#') = COALESCE(current_record.mrp_femb_20::text,'#NULL#') AND
                      COALESCE(target_record.mrp_notiz::text,'#NULL#') = COALESCE(current_record.mrp_notiz::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_21::text,'#NULL#') = COALESCE(current_record.mrp_femb_21::text,'#NULL#') AND
                      COALESCE(target_record.mrp_dokup_hand_emp_akz::text,'#NULL#') = COALESCE(current_record.mrp_dokup_hand_emp_akz::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp::text,'#NULL#') = COALESCE(current_record.mrp_merp::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp_info::text,'#NULL#') = COALESCE(current_record.mrp_merp_info::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp_info___1::text,'#NULL#') = COALESCE(current_record.mrp_merp_info___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp_txt::text,'#NULL#') = COALESCE(current_record.mrp_merp_txt::text,'#NULL#') AND
                      COALESCE(target_record.mrpdokumentation_validierung_complete::text,'#NULL#') = COALESCE(current_record.mrpdokumentation_validierung_complete::text,'#NULL#')
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO db_log.mrpdokumentation_validierung_fe (
                        mrpdokumentation_validierung_fe_id,
                        record_id,
                        meda_fe_id,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        mrp_header,
                        mrp_femb_1,
                        mrp_femb_2,
                        mrp_femb_3,
                        mrp_pi_info,
                        mrp_pi_info___1,
                        mrp_mf_info,
                        mrp_mf_info___1,
                        mrp_pi_info_txt,
                        mrp_mf_info_txt,
                        mrp_femb_4,
                        mrp_femb_5,
                        mrp_femb_6,
                        mrp_entd_dat,
                        mrp_kurzbeschr,
                        mrp_entd_algorithmisch,
                        mrp_hinweisgeber_lbl,
                        mrp_hinweisgeber,
                        mrp_gewissheit_lbl,
                        mrp_gewissheit,
                        mrp_femb_22,
                        mrp_gewissheit_oth,
                        mrp_femb_23,
                        mrp_hinweisgeber_oth,
                        mrp_gewiss_grund_abl_lbl,
                        mrp_gewiss_grund_abl,
                        mrp_gewiss_grund_abl_sonst_lbl,
                        mrp_gewiss_grund_abl_sonst,
                        mrp_femb_7,
                        mrp_femb_8,
                        mrp_femb_9,
                        mrp_femb_10,
                        mrp_femb_11,
                        mrp_femb_12,
                        mrp_wirkstoff,
                        mrp_atc1_lbl,
                        mrp_atc1,
                        mrp_atc2_lbl,
                        mrp_atc2,
                        mrp_atc3_lbl,
                        mrp_atc3,
                        mrp_atc4_lbl,
                        mrp_atc4,
                        mrp_atc5_lbl,
                        mrp_atc5,
                        mrp_femb_13,
                        mrp_med_prod,
                        mrp_med_prod_sonst_lbl,
                        mrp_med_prod_sonst,
                        mrp_dokup_fehler,
                        mrp_dokup_intervention,
                        mrp_femb_14,
                        mrp_pigrund,
                        mrp_pigrund___1,
                        mrp_pigrund___2,
                        mrp_pigrund___3,
                        mrp_pigrund___4,
                        mrp_pigrund___5,
                        mrp_pigrund___6,
                        mrp_pigrund___7,
                        mrp_pigrund___8,
                        mrp_pigrund___9,
                        mrp_pigrund___10,
                        mrp_pigrund___11,
                        mrp_pigrund___12,
                        mrp_pigrund___13,
                        mrp_pigrund___14,
                        mrp_pigrund___15,
                        mrp_pigrund___16,
                        mrp_pigrund___17,
                        mrp_pigrund___18,
                        mrp_pigrund___19,
                        mrp_pigrund___20,
                        mrp_pigrund___21,
                        mrp_pigrund___22,
                        mrp_pigrund___23,
                        mrp_pigrund___24,
                        mrp_pigrund___25,
                        mrp_pigrund___26,
                        mrp_pigrund___27,
                        mrp_femb_15,
                        mrp_ip_klasse,
                        mrp_ip_klasse___1,
                        mrp_ip_klasse___2,
                        mrp_ip_klasse___3,
                        mrp_ip_klasse___4,
                        mrp_ip_klasse___5,
                        mrp_femb_16,
                        mrp_femb_17,
                        mrp_ip_klasse_disease,
                        mrp_ip_klasse_labor,
                        mrp_femb_18,
                        mrp_massn_am,
                        mrp_massn_am___1,
                        mrp_massn_am___2,
                        mrp_massn_am___3,
                        mrp_massn_am___4,
                        mrp_massn_am___5,
                        mrp_massn_am___6,
                        mrp_massn_am___7,
                        mrp_massn_am___8,
                        mrp_massn_am___9,
                        mrp_massn_am___10,
                        mrp_femb_19,
                        mrp_massn_orga,
                        mrp_massn_orga___1,
                        mrp_massn_orga___2,
                        mrp_massn_orga___3,
                        mrp_massn_orga___4,
                        mrp_massn_orga___5,
                        mrp_massn_orga___6,
                        mrp_massn_orga___7,
                        mrp_massn_orga___8,
                        mrp_femb_20,
                        mrp_notiz,
                        mrp_femb_21,
                        mrp_dokup_hand_emp_akz,
                        mrp_merp,
                        mrp_merp_info,
                        mrp_merp_info___1,
                        mrp_merp_txt,
                        mrpdokumentation_validierung_complete,
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.mrpdokumentation_validierung_fe_id,
                        current_record.record_id,
                        current_record.meda_fe_id,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.mrp_header,
                        current_record.mrp_femb_1,
                        current_record.mrp_femb_2,
                        current_record.mrp_femb_3,
                        current_record.mrp_pi_info,
                        current_record.mrp_pi_info___1,
                        current_record.mrp_mf_info,
                        current_record.mrp_mf_info___1,
                        current_record.mrp_pi_info_txt,
                        current_record.mrp_mf_info_txt,
                        current_record.mrp_femb_4,
                        current_record.mrp_femb_5,
                        current_record.mrp_femb_6,
                        current_record.mrp_entd_dat,
                        current_record.mrp_kurzbeschr,
                        current_record.mrp_entd_algorithmisch,
                        current_record.mrp_hinweisgeber_lbl,
                        current_record.mrp_hinweisgeber,
                        current_record.mrp_gewissheit_lbl,
                        current_record.mrp_gewissheit,
                        current_record.mrp_femb_22,
                        current_record.mrp_gewissheit_oth,
                        current_record.mrp_femb_23,
                        current_record.mrp_hinweisgeber_oth,
                        current_record.mrp_gewiss_grund_abl_lbl,
                        current_record.mrp_gewiss_grund_abl,
                        current_record.mrp_gewiss_grund_abl_sonst_lbl,
                        current_record.mrp_gewiss_grund_abl_sonst,
                        current_record.mrp_femb_7,
                        current_record.mrp_femb_8,
                        current_record.mrp_femb_9,
                        current_record.mrp_femb_10,
                        current_record.mrp_femb_11,
                        current_record.mrp_femb_12,
                        current_record.mrp_wirkstoff,
                        current_record.mrp_atc1_lbl,
                        current_record.mrp_atc1,
                        current_record.mrp_atc2_lbl,
                        current_record.mrp_atc2,
                        current_record.mrp_atc3_lbl,
                        current_record.mrp_atc3,
                        current_record.mrp_atc4_lbl,
                        current_record.mrp_atc4,
                        current_record.mrp_atc5_lbl,
                        current_record.mrp_atc5,
                        current_record.mrp_femb_13,
                        current_record.mrp_med_prod,
                        current_record.mrp_med_prod_sonst_lbl,
                        current_record.mrp_med_prod_sonst,
                        current_record.mrp_dokup_fehler,
                        current_record.mrp_dokup_intervention,
                        current_record.mrp_femb_14,
                        current_record.mrp_pigrund,
                        current_record.mrp_pigrund___1,
                        current_record.mrp_pigrund___2,
                        current_record.mrp_pigrund___3,
                        current_record.mrp_pigrund___4,
                        current_record.mrp_pigrund___5,
                        current_record.mrp_pigrund___6,
                        current_record.mrp_pigrund___7,
                        current_record.mrp_pigrund___8,
                        current_record.mrp_pigrund___9,
                        current_record.mrp_pigrund___10,
                        current_record.mrp_pigrund___11,
                        current_record.mrp_pigrund___12,
                        current_record.mrp_pigrund___13,
                        current_record.mrp_pigrund___14,
                        current_record.mrp_pigrund___15,
                        current_record.mrp_pigrund___16,
                        current_record.mrp_pigrund___17,
                        current_record.mrp_pigrund___18,
                        current_record.mrp_pigrund___19,
                        current_record.mrp_pigrund___20,
                        current_record.mrp_pigrund___21,
                        current_record.mrp_pigrund___22,
                        current_record.mrp_pigrund___23,
                        current_record.mrp_pigrund___24,
                        current_record.mrp_pigrund___25,
                        current_record.mrp_pigrund___26,
                        current_record.mrp_pigrund___27,
                        current_record.mrp_femb_15,
                        current_record.mrp_ip_klasse,
                        current_record.mrp_ip_klasse___1,
                        current_record.mrp_ip_klasse___2,
                        current_record.mrp_ip_klasse___3,
                        current_record.mrp_ip_klasse___4,
                        current_record.mrp_ip_klasse___5,
                        current_record.mrp_femb_16,
                        current_record.mrp_femb_17,
                        current_record.mrp_ip_klasse_disease,
                        current_record.mrp_ip_klasse_labor,
                        current_record.mrp_femb_18,
                        current_record.mrp_massn_am,
                        current_record.mrp_massn_am___1,
                        current_record.mrp_massn_am___2,
                        current_record.mrp_massn_am___3,
                        current_record.mrp_massn_am___4,
                        current_record.mrp_massn_am___5,
                        current_record.mrp_massn_am___6,
                        current_record.mrp_massn_am___7,
                        current_record.mrp_massn_am___8,
                        current_record.mrp_massn_am___9,
                        current_record.mrp_massn_am___10,
                        current_record.mrp_femb_19,
                        current_record.mrp_massn_orga,
                        current_record.mrp_massn_orga___1,
                        current_record.mrp_massn_orga___2,
                        current_record.mrp_massn_orga___3,
                        current_record.mrp_massn_orga___4,
                        current_record.mrp_massn_orga___5,
                        current_record.mrp_massn_orga___6,
                        current_record.mrp_massn_orga___7,
                        current_record.mrp_massn_orga___8,
                        current_record.mrp_femb_20,
                        current_record.mrp_notiz,
                        current_record.mrp_femb_21,
                        current_record.mrp_dokup_hand_emp_akz,
                        current_record.mrp_merp,
                        current_record.mrp_merp_info,
                        current_record.mrp_merp_info___1,
                        current_record.mrp_merp_txt,
                        current_record.mrpdokumentation_validierung_complete,
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM db2dataprocessor_in.mrpdokumentation_validierung_fe WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
                ELSE
                UPDATE db_log.mrpdokumentation_validierung_fe target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.meda_fe_id::text,'#NULL#') = COALESCE(current_record.meda_fe_id::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                      COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                      COALESCE(target_record.mrp_header::text,'#NULL#') = COALESCE(current_record.mrp_header::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_1::text,'#NULL#') = COALESCE(current_record.mrp_femb_1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_2::text,'#NULL#') = COALESCE(current_record.mrp_femb_2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_3::text,'#NULL#') = COALESCE(current_record.mrp_femb_3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pi_info::text,'#NULL#') = COALESCE(current_record.mrp_pi_info::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pi_info___1::text,'#NULL#') = COALESCE(current_record.mrp_pi_info___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_mf_info::text,'#NULL#') = COALESCE(current_record.mrp_mf_info::text,'#NULL#') AND
                      COALESCE(target_record.mrp_mf_info___1::text,'#NULL#') = COALESCE(current_record.mrp_mf_info___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pi_info_txt::text,'#NULL#') = COALESCE(current_record.mrp_pi_info_txt::text,'#NULL#') AND
                      COALESCE(target_record.mrp_mf_info_txt::text,'#NULL#') = COALESCE(current_record.mrp_mf_info_txt::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_4::text,'#NULL#') = COALESCE(current_record.mrp_femb_4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_5::text,'#NULL#') = COALESCE(current_record.mrp_femb_5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_6::text,'#NULL#') = COALESCE(current_record.mrp_femb_6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_entd_dat::text,'#NULL#') = COALESCE(current_record.mrp_entd_dat::text,'#NULL#') AND
                      COALESCE(target_record.mrp_kurzbeschr::text,'#NULL#') = COALESCE(current_record.mrp_kurzbeschr::text,'#NULL#') AND
                      COALESCE(target_record.mrp_entd_algorithmisch::text,'#NULL#') = COALESCE(current_record.mrp_entd_algorithmisch::text,'#NULL#') AND
                      COALESCE(target_record.mrp_hinweisgeber_lbl::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_hinweisgeber::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewissheit_lbl::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewissheit::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_22::text,'#NULL#') = COALESCE(current_record.mrp_femb_22::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewissheit_oth::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit_oth::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_23::text,'#NULL#') = COALESCE(current_record.mrp_femb_23::text,'#NULL#') AND
                      COALESCE(target_record.mrp_hinweisgeber_oth::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber_oth::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl_lbl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl_sonst_lbl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_sonst_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_7::text,'#NULL#') = COALESCE(current_record.mrp_femb_7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_8::text,'#NULL#') = COALESCE(current_record.mrp_femb_8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_9::text,'#NULL#') = COALESCE(current_record.mrp_femb_9::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_10::text,'#NULL#') = COALESCE(current_record.mrp_femb_10::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_11::text,'#NULL#') = COALESCE(current_record.mrp_femb_11::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_12::text,'#NULL#') = COALESCE(current_record.mrp_femb_12::text,'#NULL#') AND
                      COALESCE(target_record.mrp_wirkstoff::text,'#NULL#') = COALESCE(current_record.mrp_wirkstoff::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc1_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc1_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc1::text,'#NULL#') = COALESCE(current_record.mrp_atc1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc2_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc2_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc2::text,'#NULL#') = COALESCE(current_record.mrp_atc2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc3_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc3_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc3::text,'#NULL#') = COALESCE(current_record.mrp_atc3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc4_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc4_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc4::text,'#NULL#') = COALESCE(current_record.mrp_atc4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc5_lbl::text,'#NULL#') = COALESCE(current_record.mrp_atc5_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_atc5::text,'#NULL#') = COALESCE(current_record.mrp_atc5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_13::text,'#NULL#') = COALESCE(current_record.mrp_femb_13::text,'#NULL#') AND
                      COALESCE(target_record.mrp_med_prod::text,'#NULL#') = COALESCE(current_record.mrp_med_prod::text,'#NULL#') AND
                      COALESCE(target_record.mrp_med_prod_sonst_lbl::text,'#NULL#') = COALESCE(current_record.mrp_med_prod_sonst_lbl::text,'#NULL#') AND
                      COALESCE(target_record.mrp_med_prod_sonst::text,'#NULL#') = COALESCE(current_record.mrp_med_prod_sonst::text,'#NULL#') AND
                      COALESCE(target_record.mrp_dokup_fehler::text,'#NULL#') = COALESCE(current_record.mrp_dokup_fehler::text,'#NULL#') AND
                      COALESCE(target_record.mrp_dokup_intervention::text,'#NULL#') = COALESCE(current_record.mrp_dokup_intervention::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_14::text,'#NULL#') = COALESCE(current_record.mrp_femb_14::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund::text,'#NULL#') = COALESCE(current_record.mrp_pigrund::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___1::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___2::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___3::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___4::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___5::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___6::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___7::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___8::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___9::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___9::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___10::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___10::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___11::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___11::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___12::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___12::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___13::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___13::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___14::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___14::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___15::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___15::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___16::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___16::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___17::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___17::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___18::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___18::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___19::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___19::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___20::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___20::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___21::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___21::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___22::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___22::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___23::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___23::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___24::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___24::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___25::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___25::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___26::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___26::text,'#NULL#') AND
                      COALESCE(target_record.mrp_pigrund___27::text,'#NULL#') = COALESCE(current_record.mrp_pigrund___27::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_15::text,'#NULL#') = COALESCE(current_record.mrp_femb_15::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___1::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___2::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___3::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___4::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse___5::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_16::text,'#NULL#') = COALESCE(current_record.mrp_femb_16::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_17::text,'#NULL#') = COALESCE(current_record.mrp_femb_17::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse_disease::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_disease::text,'#NULL#') AND
                      COALESCE(target_record.mrp_ip_klasse_labor::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_labor::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_18::text,'#NULL#') = COALESCE(current_record.mrp_femb_18::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am::text,'#NULL#') = COALESCE(current_record.mrp_massn_am::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___1::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___2::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___3::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___4::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___5::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___6::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___7::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___8::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___9::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___9::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_am___10::text,'#NULL#') = COALESCE(current_record.mrp_massn_am___10::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_19::text,'#NULL#') = COALESCE(current_record.mrp_femb_19::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___1::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___2::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___2::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___3::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___3::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___4::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___4::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___5::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___5::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___6::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___6::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___7::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___7::text,'#NULL#') AND
                      COALESCE(target_record.mrp_massn_orga___8::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga___8::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_20::text,'#NULL#') = COALESCE(current_record.mrp_femb_20::text,'#NULL#') AND
                      COALESCE(target_record.mrp_notiz::text,'#NULL#') = COALESCE(current_record.mrp_notiz::text,'#NULL#') AND
                      COALESCE(target_record.mrp_femb_21::text,'#NULL#') = COALESCE(current_record.mrp_femb_21::text,'#NULL#') AND
                      COALESCE(target_record.mrp_dokup_hand_emp_akz::text,'#NULL#') = COALESCE(current_record.mrp_dokup_hand_emp_akz::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp::text,'#NULL#') = COALESCE(current_record.mrp_merp::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp_info::text,'#NULL#') = COALESCE(current_record.mrp_merp_info::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp_info___1::text,'#NULL#') = COALESCE(current_record.mrp_merp_info___1::text,'#NULL#') AND
                      COALESCE(target_record.mrp_merp_txt::text,'#NULL#') = COALESCE(current_record.mrp_merp_txt::text,'#NULL#') AND
                      COALESCE(target_record.mrpdokumentation_validierung_complete::text,'#NULL#') = COALESCE(current_record.mrpdokumentation_validierung_complete::text,'#NULL#')
                    ;

                    -- Delete updatet datasets
                    DELETE FROM db2dataprocessor_in.mrpdokumentation_validierung_fe WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE db2dataprocessor_in.mrpdokumentation_validierung_fe
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_fe_dp_in_to_db_log'
                    , last_processing_nr = last_pro_nr
                    WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT mrpdokumentation_validierung_fe_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'mrpdokumentation_validierung_fe' AS table_name, last_check_datetime, current_dataset_status, 'copy_fe_dp_in_to_db_log' AS function_name FROM db_log.mrpdokumentation_validierung_fe
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END mrpdokumentation_validierung_fe
    -----------------------------------------------------------------------------------------------------------------------

    -- Start risikofaktor_fe
    FOR current_record IN (SELECT * FROM db2dataprocessor_in.risikofaktor_fe)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM db_log.risikofaktor_fe target_record
                WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_gerhemmer::text,'#NULL#') = COALESCE(current_record.rskfk_gerhemmer::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_tah::text,'#NULL#') = COALESCE(current_record.rskfk_tah::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_immunsupp::text,'#NULL#') = COALESCE(current_record.rskfk_immunsupp::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_tumorth::text,'#NULL#') = COALESCE(current_record.rskfk_tumorth::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_opiat::text,'#NULL#') = COALESCE(current_record.rskfk_opiat::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_atcn::text,'#NULL#') = COALESCE(current_record.rskfk_atcn::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_ait::text,'#NULL#') = COALESCE(current_record.rskfk_ait::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_anzam::text,'#NULL#') = COALESCE(current_record.rskfk_anzam::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_priscus::text,'#NULL#') = COALESCE(current_record.rskfk_priscus::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_qtc::text,'#NULL#') = COALESCE(current_record.rskfk_qtc::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_meld::text,'#NULL#') = COALESCE(current_record.rskfk_meld::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_dialyse::text,'#NULL#') = COALESCE(current_record.rskfk_dialyse::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_entern::text,'#NULL#') = COALESCE(current_record.rskfk_entern::text,'#NULL#') AND
                      COALESCE(target_record.rskfkt_anz_rskamklassen::text,'#NULL#') = COALESCE(current_record.rskfkt_anz_rskamklassen::text,'#NULL#') AND
                      COALESCE(target_record.risikofaktor_complete::text,'#NULL#') = COALESCE(current_record.risikofaktor_complete::text,'#NULL#')
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO db_log.risikofaktor_fe (
                        risikofaktor_fe_id,
                        record_id,
                        patient_id_fk,
                        rskfk_gerhemmer,
                        rskfk_tah,
                        rskfk_immunsupp,
                        rskfk_tumorth,
                        rskfk_opiat,
                        rskfk_atcn,
                        rskfk_ait,
                        rskfk_anzam,
                        rskfk_priscus,
                        rskfk_qtc,
                        rskfk_meld,
                        rskfk_dialyse,
                        rskfk_entern,
                        rskfkt_anz_rskamklassen,
                        risikofaktor_complete,
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.risikofaktor_fe_id,
                        current_record.record_id,
                        current_record.patient_id_fk,
                        current_record.rskfk_gerhemmer,
                        current_record.rskfk_tah,
                        current_record.rskfk_immunsupp,
                        current_record.rskfk_tumorth,
                        current_record.rskfk_opiat,
                        current_record.rskfk_atcn,
                        current_record.rskfk_ait,
                        current_record.rskfk_anzam,
                        current_record.rskfk_priscus,
                        current_record.rskfk_qtc,
                        current_record.rskfk_meld,
                        current_record.rskfk_dialyse,
                        current_record.rskfk_entern,
                        current_record.rskfkt_anz_rskamklassen,
                        current_record.risikofaktor_complete,
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM db2dataprocessor_in.risikofaktor_fe WHERE risikofaktor_fe_id = current_record.risikofaktor_fe_id;
                ELSE
                UPDATE db_log.risikofaktor_fe target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_gerhemmer::text,'#NULL#') = COALESCE(current_record.rskfk_gerhemmer::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_tah::text,'#NULL#') = COALESCE(current_record.rskfk_tah::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_immunsupp::text,'#NULL#') = COALESCE(current_record.rskfk_immunsupp::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_tumorth::text,'#NULL#') = COALESCE(current_record.rskfk_tumorth::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_opiat::text,'#NULL#') = COALESCE(current_record.rskfk_opiat::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_atcn::text,'#NULL#') = COALESCE(current_record.rskfk_atcn::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_ait::text,'#NULL#') = COALESCE(current_record.rskfk_ait::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_anzam::text,'#NULL#') = COALESCE(current_record.rskfk_anzam::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_priscus::text,'#NULL#') = COALESCE(current_record.rskfk_priscus::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_qtc::text,'#NULL#') = COALESCE(current_record.rskfk_qtc::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_meld::text,'#NULL#') = COALESCE(current_record.rskfk_meld::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_dialyse::text,'#NULL#') = COALESCE(current_record.rskfk_dialyse::text,'#NULL#') AND
                      COALESCE(target_record.rskfk_entern::text,'#NULL#') = COALESCE(current_record.rskfk_entern::text,'#NULL#') AND
                      COALESCE(target_record.rskfkt_anz_rskamklassen::text,'#NULL#') = COALESCE(current_record.rskfkt_anz_rskamklassen::text,'#NULL#') AND
                      COALESCE(target_record.risikofaktor_complete::text,'#NULL#') = COALESCE(current_record.risikofaktor_complete::text,'#NULL#')
                    ;

                    -- Delete updatet datasets
                    DELETE FROM db2dataprocessor_in.risikofaktor_fe WHERE risikofaktor_fe_id = current_record.risikofaktor_fe_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE db2dataprocessor_in.risikofaktor_fe
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_fe_dp_in_to_db_log'
                    , last_processing_nr = last_pro_nr
                    WHERE risikofaktor_fe_id = current_record.risikofaktor_fe_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT risikofaktor_fe_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'risikofaktor_fe' AS table_name, last_check_datetime, current_dataset_status, 'copy_fe_dp_in_to_db_log' AS function_name FROM db_log.risikofaktor_fe
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END risikofaktor_fe
    -----------------------------------------------------------------------------------------------------------------------

    -- Start trigger_fe
    FOR current_record IN (SELECT * FROM db2dataprocessor_in.trigger_fe)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM db_log.trigger_fe target_record
                WHERE COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                      COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.trg_ast::text,'#NULL#') = COALESCE(current_record.trg_ast::text,'#NULL#') AND
                      COALESCE(target_record.trg_alt::text,'#NULL#') = COALESCE(current_record.trg_alt::text,'#NULL#') AND
                      COALESCE(target_record.trg_crp::text,'#NULL#') = COALESCE(current_record.trg_crp::text,'#NULL#') AND
                      COALESCE(target_record.trg_leuk_penie::text,'#NULL#') = COALESCE(current_record.trg_leuk_penie::text,'#NULL#') AND
                      COALESCE(target_record.trg_leuk_ose::text,'#NULL#') = COALESCE(current_record.trg_leuk_ose::text,'#NULL#') AND
                      COALESCE(target_record.trg_thrmb_penie::text,'#NULL#') = COALESCE(current_record.trg_thrmb_penie::text,'#NULL#') AND
                      COALESCE(target_record.trg_aptt::text,'#NULL#') = COALESCE(current_record.trg_aptt::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyp_haem::text,'#NULL#') = COALESCE(current_record.trg_hyp_haem::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_glyk::text,'#NULL#') = COALESCE(current_record.trg_hypo_glyk::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_glyk::text,'#NULL#') = COALESCE(current_record.trg_hyper_glyk::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_bilirbnm::text,'#NULL#') = COALESCE(current_record.trg_hyper_bilirbnm::text,'#NULL#') AND
                      COALESCE(target_record.trg_ck::text,'#NULL#') = COALESCE(current_record.trg_ck::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_serablmn::text,'#NULL#') = COALESCE(current_record.trg_hypo_serablmn::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_nat::text,'#NULL#') = COALESCE(current_record.trg_hypo_nat::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_nat::text,'#NULL#') = COALESCE(current_record.trg_hyper_nat::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_kal::text,'#NULL#') = COALESCE(current_record.trg_hyper_kal::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_kal::text,'#NULL#') = COALESCE(current_record.trg_hypo_kal::text,'#NULL#') AND
                      COALESCE(target_record.trg_inr_ern::text,'#NULL#') = COALESCE(current_record.trg_inr_ern::text,'#NULL#') AND
                      COALESCE(target_record.trg_inr_erh::text,'#NULL#') = COALESCE(current_record.trg_inr_erh::text,'#NULL#') AND
                      COALESCE(target_record.trg_inr_erh_antikoa::text,'#NULL#') = COALESCE(current_record.trg_inr_erh_antikoa::text,'#NULL#') AND
                      COALESCE(target_record.trg_krea::text,'#NULL#') = COALESCE(current_record.trg_krea::text,'#NULL#') AND
                      COALESCE(target_record.trg_egfr::text,'#NULL#') = COALESCE(current_record.trg_egfr::text,'#NULL#') AND
                      COALESCE(target_record.trigger_complete::text,'#NULL#') = COALESCE(current_record.trigger_complete::text,'#NULL#')
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO db_log.trigger_fe (
                        trigger_fe_id,
                        patient_id_fk,
                        record_id,
                        trg_ast,
                        trg_alt,
                        trg_crp,
                        trg_leuk_penie,
                        trg_leuk_ose,
                        trg_thrmb_penie,
                        trg_aptt,
                        trg_hyp_haem,
                        trg_hypo_glyk,
                        trg_hyper_glyk,
                        trg_hyper_bilirbnm,
                        trg_ck,
                        trg_hypo_serablmn,
                        trg_hypo_nat,
                        trg_hyper_nat,
                        trg_hyper_kal,
                        trg_hypo_kal,
                        trg_inr_ern,
                        trg_inr_erh,
                        trg_inr_erh_antikoa,
                        trg_krea,
                        trg_egfr,
                        trigger_complete,
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.trigger_fe_id,
                        current_record.patient_id_fk,
                        current_record.record_id,
                        current_record.trg_ast,
                        current_record.trg_alt,
                        current_record.trg_crp,
                        current_record.trg_leuk_penie,
                        current_record.trg_leuk_ose,
                        current_record.trg_thrmb_penie,
                        current_record.trg_aptt,
                        current_record.trg_hyp_haem,
                        current_record.trg_hypo_glyk,
                        current_record.trg_hyper_glyk,
                        current_record.trg_hyper_bilirbnm,
                        current_record.trg_ck,
                        current_record.trg_hypo_serablmn,
                        current_record.trg_hypo_nat,
                        current_record.trg_hyper_nat,
                        current_record.trg_hyper_kal,
                        current_record.trg_hypo_kal,
                        current_record.trg_inr_ern,
                        current_record.trg_inr_erh,
                        current_record.trg_inr_erh_antikoa,
                        current_record.trg_krea,
                        current_record.trg_egfr,
                        current_record.trigger_complete,
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM db2dataprocessor_in.trigger_fe WHERE trigger_fe_id = current_record.trigger_fe_id;
                ELSE
                UPDATE db_log.trigger_fe target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                      COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                      COALESCE(target_record.trg_ast::text,'#NULL#') = COALESCE(current_record.trg_ast::text,'#NULL#') AND
                      COALESCE(target_record.trg_alt::text,'#NULL#') = COALESCE(current_record.trg_alt::text,'#NULL#') AND
                      COALESCE(target_record.trg_crp::text,'#NULL#') = COALESCE(current_record.trg_crp::text,'#NULL#') AND
                      COALESCE(target_record.trg_leuk_penie::text,'#NULL#') = COALESCE(current_record.trg_leuk_penie::text,'#NULL#') AND
                      COALESCE(target_record.trg_leuk_ose::text,'#NULL#') = COALESCE(current_record.trg_leuk_ose::text,'#NULL#') AND
                      COALESCE(target_record.trg_thrmb_penie::text,'#NULL#') = COALESCE(current_record.trg_thrmb_penie::text,'#NULL#') AND
                      COALESCE(target_record.trg_aptt::text,'#NULL#') = COALESCE(current_record.trg_aptt::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyp_haem::text,'#NULL#') = COALESCE(current_record.trg_hyp_haem::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_glyk::text,'#NULL#') = COALESCE(current_record.trg_hypo_glyk::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_glyk::text,'#NULL#') = COALESCE(current_record.trg_hyper_glyk::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_bilirbnm::text,'#NULL#') = COALESCE(current_record.trg_hyper_bilirbnm::text,'#NULL#') AND
                      COALESCE(target_record.trg_ck::text,'#NULL#') = COALESCE(current_record.trg_ck::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_serablmn::text,'#NULL#') = COALESCE(current_record.trg_hypo_serablmn::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_nat::text,'#NULL#') = COALESCE(current_record.trg_hypo_nat::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_nat::text,'#NULL#') = COALESCE(current_record.trg_hyper_nat::text,'#NULL#') AND
                      COALESCE(target_record.trg_hyper_kal::text,'#NULL#') = COALESCE(current_record.trg_hyper_kal::text,'#NULL#') AND
                      COALESCE(target_record.trg_hypo_kal::text,'#NULL#') = COALESCE(current_record.trg_hypo_kal::text,'#NULL#') AND
                      COALESCE(target_record.trg_inr_ern::text,'#NULL#') = COALESCE(current_record.trg_inr_ern::text,'#NULL#') AND
                      COALESCE(target_record.trg_inr_erh::text,'#NULL#') = COALESCE(current_record.trg_inr_erh::text,'#NULL#') AND
                      COALESCE(target_record.trg_inr_erh_antikoa::text,'#NULL#') = COALESCE(current_record.trg_inr_erh_antikoa::text,'#NULL#') AND
                      COALESCE(target_record.trg_krea::text,'#NULL#') = COALESCE(current_record.trg_krea::text,'#NULL#') AND
                      COALESCE(target_record.trg_egfr::text,'#NULL#') = COALESCE(current_record.trg_egfr::text,'#NULL#') AND
                      COALESCE(target_record.trigger_complete::text,'#NULL#') = COALESCE(current_record.trigger_complete::text,'#NULL#')
                    ;

                    -- Delete updatet datasets
                    DELETE FROM db2dataprocessor_in.trigger_fe WHERE trigger_fe_id = current_record.trigger_fe_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE db2dataprocessor_in.trigger_fe
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: copy_fe_dp_in_to_db_log'
                    , last_processing_nr = last_pro_nr
                    WHERE trigger_fe_id = current_record.trigger_fe_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT trigger_fe_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'trigger_fe' AS table_name, last_check_datetime, current_dataset_status, 'copy_fe_dp_in_to_db_log' AS function_name FROM db_log.trigger_fe
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END trigger_fe
    -----------------------------------------------------------------------------------------------------------------------


END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log - SELECT cron.schedule('*/1 * * * *', 'SELECT db.copy_fe_dp_in_to_db_log();');
-----------------------------



