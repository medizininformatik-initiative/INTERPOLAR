-- ########################################################################################################
--
-- This file is not generated. Changes only manuel.
--
-- Rights definition file             : here
-- Rights definition file last update : 2026-02-06 12:00:00
-- Rights definition file size        : /
--
-- Create SQL Tables in Schema "db2frontend_out"
-- Create time: 2026-01-12 12:00:00
-- TABLE_DESCRIPTION:  /
-- SCRIPTNAME:  480_cre_view_fe_dataproc_last_version.sql
-- TEMPLATE:  /
-- OWNER_USER:  db2frontend_user
-- OWNER_SCHEMA:  db2frontend_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _fe_last_version
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2frontend_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _fe_last_version
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create View with last version data for typed tables for schema db2frontend_out

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_patient_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_patient_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_patient_fe_last_version AS (
        SELECT o.* FROM db_log.patient_fe o
        WHERE (o.record_id, o.pat_id, o.last_processing_nr) IN (SELECT i.record_id, i.pat_id, MAX(i.last_processing_nr)
                                                                 FROM db_log.patient_fe i
                                                                 GROUP BY i.record_id, i.pat_id
                                                                )
        );

        GRANT SELECT ON db2frontend_out.v_patient_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_fall_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_fall_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_fall_fe_last_version AS (
        SELECT o.* FROM db_log.fall_fe o
        WHERE (o.record_id, o.fall_fhir_enc_id, o.last_processing_nr) IN (SELECT i.record_id, i.fall_fhir_enc_id, MAX(i.last_processing_nr)
                                                                           FROM db_log.fall_fe i
                                                                           GROUP BY i.record_id, i.fall_fhir_enc_id
                                                                          )
        );

        GRANT SELECT ON db2frontend_out.v_fall_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_medikationsanalyse_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_medikationsanalyse_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse_fe_last_version AS (
        SELECT o.* FROM db_log.medikationsanalyse_fe o
        WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (SELECT i.record_id, i.redcap_repeat_instance, MAX(i.last_processing_nr)
                                                                                 FROM db_log.medikationsanalyse_fe i
                                                                                 GROUP BY i.record_id, i.redcap_repeat_instance
                                                                                )
        );

        GRANT SELECT ON db2frontend_out.v_medikationsanalyse_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_mrpdokumentation_validierung_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_mrpdokumentation_validierung_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung_fe_last_version AS (
        SELECT o.* FROM db_log.mrpdokumentation_validierung_fe o
        WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (SELECT i.record_id, i.redcap_repeat_instance, MAX(i.last_processing_nr)
                                                                                 FROM db_log.mrpdokumentation_validierung_fe i
                                                                                 GROUP BY i.record_id, i.redcap_repeat_instance
                                                                                )
        );

        GRANT SELECT ON db2frontend_out.v_mrpdokumentation_validierung_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_retrolektive_mrpbewertung_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version AS (
        SELECT o.* FROM db_log.retrolektive_mrpbewertung_fe o
        WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (SELECT i.record_id, i.redcap_repeat_instance, MAX(i.last_processing_nr)
                                                                                 FROM db_log.retrolektive_mrpbewertung_fe i
                                                                                 GROUP BY i.record_id, i.redcap_repeat_instance
                                                                                )
        );

        GRANT SELECT ON db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_risikofaktor_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_risikofaktor_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor_fe_last_version AS (
        SELECT o.* FROM db_log.risikofaktor_fe o
        WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (SELECT i.record_id, i.redcap_repeat_instance, MAX(i.last_processing_nr)
                                                                                 FROM db_log.risikofaktor_fe i
                                                                                 GROUP BY i.record_id, i.redcap_repeat_instance
                                                                                )
        );

        GRANT SELECT ON db2frontend_out.v_risikofaktor_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_trigger_fe_last_version'
        ) THEN
            DROP VIEW db2frontend_out.v_trigger_fe_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_trigger_fe_last_version AS (
        SELECT o.* FROM db_log.trigger_fe o
        WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (SELECT i.record_id, i.redcap_repeat_instance, MAX(i.last_processing_nr)
                                                                                 FROM db_log.trigger_fe i
                                                                                 GROUP BY i.record_id, i.redcap_repeat_instance
                                                                                )
        );

        GRANT SELECT ON db2frontend_out.v_trigger_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;

--------------------------------------------------------------------
    END IF; -- do migration
END
$$;