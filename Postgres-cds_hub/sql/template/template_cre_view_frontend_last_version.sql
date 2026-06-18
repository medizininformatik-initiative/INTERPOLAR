DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create View with last version data for typed tables for schema <%OWNER_SCHEMA%>

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
<%LOOP_TABS_SUB_cre_view_frontend_last_version_TABLES%>

--SQL Column Comments for Views in Schema <%OWNER_SCHEMA%>
<%LOOP_TABS_SUB_cre_view_frontend_last_version_COMMENTS%>

--------------------------------------------------------------------
    END IF; -- do migration
END
$$;
