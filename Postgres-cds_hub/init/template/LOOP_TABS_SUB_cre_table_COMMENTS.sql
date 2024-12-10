COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%TABLE_NAME%>_id IS 'Primary key of the entity';
<%IF TAGS "\bTYPED\b" "COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%SIMPLE_TABLE_NAME%>_raw_id IS 'Primary key of the corresponding raw table';"%>
<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_COMMENTS%>
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN <%OWNER_SCHEMA%>.<%TABLE_NAME%>.last_processing_nr IS 'Last processing number of the data record';

