-- Table "<%TABLE_NAME%>" in schema "<%TARGET_SCHEMA%>"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS <%TARGET_SCHEMA%>.<%TABLE_NAME%> (
  <%TABLE_NAME%>_id serial PRIMARY KEY not null, -- Primary key of the entity
  <%CREATE_TABLE_STATEMENT_COLUMNS%>
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record
);
