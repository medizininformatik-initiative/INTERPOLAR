-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-12-05 09:58:05
-- Rights definition file size        : 15179 Byte
--
-- Create SQL Tables in Schema "cds2db_in"
-- Create time: 2024-12-05 10:04:05
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  14_cre_table_typ_cds2db_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_in
-- TAGS:  TYPED
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  15_get_last_processing_nr_typed.sql
-- COPY_FUNC_TEMPLATE:  template_get_last_pnr_typed.sql
-- COPY_FUNC_NAME:  get_last_processing_nr_typed
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

------------------------------
-- Funktion um aktuellen Status zu erfahren
CREATE OR REPLACE FUNCTION db.get_last_processing_nr_typed()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    erg TEXT;
    temp varchar;
    err_section varchar;
    err_schema varchar;
    err_table varchar;
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
        err_schema => CAST('db' AS varchar),                   -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.get_last_processing_nr_typed' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST('db.get_last_processing_nr_typed-01' AS varchar),    -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: all db_log Tables' AS varchar),  -- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(0 AS int)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;
    
    RETURN 'Fehler bei Abfrage ist Aufgetreten -'||SQLSTATE;
END;
$$ LANGUAGE plpgsql;
