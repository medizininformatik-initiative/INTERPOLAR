  <%IF TAGS "\bINT_ID\b" "CREATE INDEX IF NOT EXISTS idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> ( <%TABLE_NAME%>_id); -- Primary key of the entity - already filled in this schema - History via timestamp"%>
  <%IF TAGS "\bTYPED\b" "CREATE INDEX IF NOT EXISTS idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> ( <%TABLE_NAME%>_raw_id); -- Primary key of the corresponding raw table"%>

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt
ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr
ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt
ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr
ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
   last_processing_nr -- Last processing number of the data record
);

