DO
$innerview$
BEGIN
    IF EXISTS ( -- migration on
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
        ) THEN
            DROP VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%>; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
            SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
        );
----------------------------
    END IF; -- migration on
END
$innerview$;
