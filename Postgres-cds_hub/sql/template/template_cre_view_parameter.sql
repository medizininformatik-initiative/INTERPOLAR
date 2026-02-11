
------------------------------------------------------------------------------------------------------------------
-- view in schema <%OWNER_SCHEMA%> to have access to db-parameters - table is fix
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = 'v_db_parameter'
        ) THEN
            DROP VIEW <%OWNER_SCHEMA%>.v_db_parameter; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.v_db_parameter AS (SELECT * FROM db_config.db_parameter ORDER BY parameter_name);

        GRANT SELECT ON <%OWNER_SCHEMA%>.v_db_parameter TO <%OWNER_USER%>;
        GRANT USAGE ON SCHEMA <%OWNER_SCHEMA%> TO <%OWNER_USER%>;
----------------------------
    END IF; -- do migration
END
$innerview$;

