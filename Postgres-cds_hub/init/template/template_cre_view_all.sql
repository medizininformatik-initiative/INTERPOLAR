DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create View for typed tables for schema db2dataprocessor_out
<%LOOP_TABS_SUB_cre_view_all_VIEWS_AND_GRANTS%>

--------------------------------------------------------------------
    END IF; -- do migration
END
$$;
