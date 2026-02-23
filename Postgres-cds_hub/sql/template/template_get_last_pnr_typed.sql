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
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
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
    <%LOOP_TABS_SUB_get_last_pnr_typed%>
    );

    RETURN erg;
EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST('db' AS VARCHAR),                   -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.<%COPY_FUNC_NAME%>' AS VARCHAR),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
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
