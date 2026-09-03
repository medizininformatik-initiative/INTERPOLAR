-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-06-18 14:50:31
-- Rights definition file size        : 13564 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2026-06-18 16:06:35
-- TABLE_DESCRIPTION:  ./R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/334_cre_view_dataproc_submodules_last_import.sql
-- TEMPLATE:  template_cre_view_last_import.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _last_import
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2dataprocessor_user
-- COPY_FUNC_SCRIPTNAME:
-- COPY_FUNC_TEMPLATE:
-- COPY_FUNC_NAME:
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:
-- SCHEMA_3:
-- TABLE_POSTFIX_3:
-- ########################################################################################################
DO $$
BEGIN
    IF EXISTS ( -- do migration
        SELECT
            1
        FROM
            db_config.db_parameter
        WHERE
            parameter_name = 'current_migration_flag'
            AND parameter_value = '1') THEN
        --------------------------------------------------------------------
        --Create View for frontend tables for schema db2dataprocessor_out
        DO $innerview$
        BEGIN
            IF EXISTS ( -- do migration
                SELECT
                    1 s
                FROM
                    db_config.db_parameter
                WHERE
                    parameter_name = 'current_migration_flag'
                    AND parameter_value = '1') THEN
                IF EXISTS ( -- VIEW exists
                    SELECT
                        1 s
                    FROM
                        information_schema.columns
                    WHERE
                        table_schema = 'db2dataprocessor_out'
                        AND table_name = 'v_dp_mrp_calculations_last_import') THEN
                    DROP VIEW db2dataprocessor_out.v_dp_mrp_calculations_last_import;
            -- first drop the view
        END IF;
    -- DROP VIEW
    ----------------------------
    CREATE OR REPLACE VIEW db2dataprocessor_out.v_dp_mrp_calculations_last_import AS (
        SELECT
            *
        FROM
            db_log.dp_mrp_calculations
        WHERE
            TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                SELECT
                    TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                FROM
                    db_log.dp_mrp_calculations));
    ----------------------------
END IF;
        -- do migration
END $innerview$;
    --SQL Column Comments for Views in Schema db2dataprocessor_out
    -------- COMMENTS db2dataprocessor_out.v_dp_mrp_calculations_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.enc_id IS 'FHIR ID of the associated institution contact (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.mrp_calculation_type IS 'Type of MRP (name of the submodule which has calculated the MRP e.g. “Drug_Disease”, “Drug_Drug”, “Drug_DrugGoup”, “Drug_Kidney”) (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.meda_id IS 'optional - Redcap ID of the medication_analysis_fe (empty if no MedAna exists for this Encounter) (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.ward_name IS 'Name of the ward where the patient was during the medication analysis or the very first relevant ward (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.study_phase IS 'Study phase („PhaseA“, „PhaseBTest“ or „PhaseB“); must be filled if there was any contact with a observed ward in his medical case (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.ret_id IS 'optional – Redcap ID of the generated retrolective_mrpbewertung_fe (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.ret_redcap_repeat_instance IS 'optional – Redcap repeat instance id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.atc1_medreq_fhir_id IS 'optional – FHIR ID of ATC1 (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.mrp_proxy_type IS 'optional – ICD, ATC, OPS, LOINC (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.mrp_proxy_code IS 'optional – Code of the proxy (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.mrp_proxy_fhir_id IS 'optional – FHIR ID of the proxy (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_dp_mrp_calculations_last_import.input_file_processed_content_hash IS 'Processed content hash from input_data_files_processed_content of the MRP list (varchar)';
    --SQL Role for Views in Schema db2dataprocessor_out
    GRANT SELECT ON TABLE db2dataprocessor_out.v_dp_mrp_calculations_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    --------------------------------------------------------------------
END IF;
    -- do migration
END
$$;
