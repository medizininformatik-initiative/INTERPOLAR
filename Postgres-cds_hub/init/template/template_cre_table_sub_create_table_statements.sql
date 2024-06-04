-- Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
  <%SIMPLE_TABLE_NAME%>_id serial PRIMARY KEY not null, -- Primary key of the entity
  <%CREATE_TABLE_STATEMENT_COLUMNS%>
  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input'   -- Processing status of the data record
);
