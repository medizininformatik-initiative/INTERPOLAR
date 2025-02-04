-- Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
  <%IF TAGS "\bINT_ID\b" "<%TABLE_NAME%>_id int, -- Primary key of the entity - already filled in this schema - History via timestamp"%>
  <%IF NOT TAGS "\bINT_ID\b" "<%TABLE_NAME%>_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity"%>
  <%IF TAGS "\bTYPED\b" "<%TABLE_NAME%>_raw_id int NOT NULL, -- Primary key of the corresponding raw table"%>
  <%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES%>
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
--         convert_to(
             <%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_HASH%>
             '#'
--             ,'UTF8' )
      )
  ) STORED, 							-- Column for automatic hash value for comparing FHIR data
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

