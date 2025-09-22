DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create View for frontend tables for schema <%OWNER_SCHEMA%>
<%LOOP_TABS_SUB_cre_view_last_import_TABLES%>

--SQL Role for Views in Schema <%OWNER_SCHEMA%>
<%LOOP_TABS_SUB_cre_view_last_import_GRANTS%>

--------------------------------------------------------------------
    END IF; -- do migration
END
$$;
