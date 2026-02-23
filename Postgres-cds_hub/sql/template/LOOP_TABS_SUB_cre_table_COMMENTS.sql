DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------

COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%TABLE_NAME%>_id IS 'Primary key of the entity';
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%SIMPLE_TABLE_NAME%>_raw_id IS 'Primary key of the corresponding raw table';"%>
<%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.raw_already_processed IS 'Note the last RAW ID if all RAW data of this data set has already been typed previously - this data set does not need to be taken into account during the next processing';"%>
<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_COMMENTS%>
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.last_processing_nr IS 'Last processing number of the data record';
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;
