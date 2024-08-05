-- Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
  <%IF TAGS "\bINT_ID\b" "<%SIMPLE_TABLE_NAME%>_id int, -- Primary key of the entity - already filled in this schema - History via timestamp"%>
  <%IF NOT TAGS "\bINT_ID\b" "<%SIMPLE_TABLE_NAME%>_id serial PRIMARY KEY not null, -- Primary key of the entity"%>
  <%IF TAGS "\bTYPED\b" "<%TABLE_NAME%>_raw_id int NOT NULL, -- Primary key of the corresponding raw table"%>
  <%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES%>
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);

