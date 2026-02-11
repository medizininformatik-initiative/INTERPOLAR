DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create SQL View for latest Version of the FHIR-Data for schema <%OWNER_SCHEMA%>
<%LOOP_TABS_SUB_cre_view_last_version_TABLES%>

--SQL Role for Views in Schema <%OWNER_SCHEMA%>
<%LOOP_TABS_SUB_cre_view_last_version_GRANTS%>

--------------------------------------------------------------------
    END IF; -- do migration
END
$$;
