
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
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
        SELECT DISTINCT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM <%SCHEMA_2%>.<%SIMPLE_TABLE_NAME%> t WHERE r.<%TABLE_NAME_2%>_id = t.<%TABLE_NAME_2%>_id)) -- ORDER BY <%TABLE_NAME_2%>_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;
