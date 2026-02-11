-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-02 13:24:46
-- Rights definition file size        : 16590 Byte
--
-- Create SQL Tables in Schema "cds2db_in"
-- Create time: 2026-02-02 13:35:15
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/140_cre_table_typ_cds2db_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_in
-- TAGS:  TYPED
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  base/150_get_last_processing_nr_typed.sql
-- COPY_FUNC_TEMPLATE:  template_get_last_pnr_typed.sql
-- COPY_FUNC_NAME:  get_last_processing_nr_typed
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  
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
------------------------------
EXECUTE $f$
-- Funktion um aktuellen Status zu erfahren
CREATE OR REPLACE FUNCTION db.get_last_processing_nr_typed()
RETURNS TEXT
SECURITY DEFINER
AS $inner$
DECLARE
    erg TEXT;
    temp VARCHAR;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
BEGIN
    -- Letzte Processing Number aus allen getypden Daten bestimmen
    err_section:='HEAD-05';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT CAST(MAX(last_processing_nr) AS TEXT) INTO erg
    FROM ( SELECT 0 AS last_processing_nr
        UNION SELECT MAX(last_processing_nr) FROM db_log.encounter AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.patient AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.condition AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.medication AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.medicationrequest AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.medicationadministration AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.medicationstatement AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.observation AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.diagnosticreport AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.servicerequest AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.procedure AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.consent AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.location AS last_processing_nr
    UNION SELECT MAX(last_processing_nr) FROM db_log.pids_per_ward AS last_processing_nr
    );

    RETURN erg;
EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST('db' AS VARCHAR),                   -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.get_last_processing_nr_typed' AS VARCHAR),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST('db.get_last_processing_nr_typed-01' AS VARCHAR),    -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: all db_log Tables e:'||erg AS VARCHAR),  -- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(0 AS INT)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler bei Abfrage ist Aufgetreten -'||SQLSTATE;
END;
$inner$ LANGUAGE plpgsql;
$f$;
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

