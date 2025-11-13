
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
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
        ) THEN
            DROP VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%>; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (SELECT * from <%SCHEMA_2%>.<%TABLE_NAME_2%>);

        GRANT SELECT ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> TO <%OWNER_USER%>;
        GRANT USAGE ON SCHEMA <%OWNER_SCHEMA%> TO <%OWNER_USER%>;
----------------------------
    END IF; -- do migration
END
$innerview$;

