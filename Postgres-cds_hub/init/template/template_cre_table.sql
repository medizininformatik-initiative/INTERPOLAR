-----------------------------------------------------
-- Create SQL Tables in Schema "<%OWNER_SCHEMA%>" --
-----------------------------------------------------

<%LOOP_TABS_SUB_cre_table_TABLES%>

------------------------------------------------------
-- SQL Role / Trigger in Schema "<%OWNER_SCHEMA%>" --
------------------------------------------------------

<%LOOP_TABS_SUB_cre_table_GRANTS_AND_FUNCS%>

------------------------------------------------------
-- Comments on Tables in Schema "<%OWNER_SCHEMA%>" --
------------------------------------------------------

-- Output off
\o /dev/null

<%LOOP_TABS_SUB_cre_table_COMMENTS%>

-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "<%OWNER_SCHEMA%>" --
------------------------------------------------------

<%LOOP_TABS_SUB_cre_table_INDEX_ID%>
