comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%SIMPLE_TABLE_NAME%>_id is 'Primary key of the entity';
<%IF TAGS "\bTYPED\b" "comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%SIMPLE_TABLE_NAME%>_raw_id is 'Primary key of the corresponding raw table';"%>
<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_COMMENTS%>
comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.input_datetime is 'Time at which the data record is inserted';
comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.last_check_datetime is 'Time at which data record was last checked';
comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.current_dataset_status is 'Processing status of the data record';

